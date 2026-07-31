#pragma semicolon 1
#pragma newdecls required

float Uranium_TimeTillBigHit[MAXPLAYERS][MAXENTITIES];

bool SniperRifle_HeadShot[MAXPLAYERS];
static int SniperRifle_Ignore[MAXPLAYERS];
static float SniperRifle_ExplodDMG[MAXPLAYERS];
static float SniperRifle_Charge[MAXPLAYERS];

void Uranium_MapStart()
{
	Zero2(Uranium_TimeTillBigHit);
	Zero(SniperRifle_HeadShot);
	Zero(SniperRifle_Ignore);
	ZeroFloat(SniperRifle_ExplodDMG);
	ZeroFloat(SniperRifle_Charge);
}

void EnemyResetUranium(int enemy)
{
	for(int client; client <= MaxClients ; client++)
	{
		Uranium_TimeTillBigHit[client][enemy] = 0.0;
	}
}

public void Weapon_Anti_Material_Rifle(int client, int weapon, bool crit, int slot)
{
	EmitSoundToAll("npc/vort/attack_shoot.wav", client, SNDCHAN_STATIC, 80, _, 1.0);
	Client_Shake(client, 0, 50.0, 25.0, 1.5);
	Weapon_SniperRifle_M1(client, weapon, crit, slot);
}

public void Weapon_SniperRifle_M1(int client, int weapon, bool crit, int slot)
{
	bool CheckHitBox;
	if(Attributes_Get(weapon, Attrib_ExplosiveHeadshot, 1.0) > 1.0)
	{
		CheckHitBox=true;
		float charge=GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage");
		if(charge<150.0 || !TF2_IsPlayerInCondition(client, TFCond_Zoomed))
			EmitSoundToAll("weapons/sniper_shoot.wav", client, SNDCHAN_STATIC, 80, _, 1.0);
	}
	if(Attributes_Get(weapon, 390, 0.0) != 1.0)
		CheckHitBox=true;
	if(CheckHitBox)
	{
		static float vAngles[3], vOrigin[3];
		GetClientEyePosition(client, vOrigin);
		GetClientEyeAngles(client, vAngles);
		Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, BulletAndMeleeTrace, client);
		if(TR_GetFraction(trace) < 1.0)
		{
			int target = TR_GetEntityIndex(trace);
			if(target > 0 && !b_CannotBeHeadshot[target])
			{
				if(TR_GetHitGroup(trace) == HITGROUP_HEAD)
				{
					SniperRifle_Ignore[client]=EntIndexToEntRef(target);
					SniperRifle_HeadShot[client]=true;
				}
			}
		}
		delete trace;
	}
}

void WeaponUranium_OnTakeDamage(int attacker,int victim, float &damage, float damagePosition[3])
{
	if(Uranium_TimeTillBigHit[attacker][victim] < GetGameTime())
	{
		damage *= 2.2;
		if(!CheckInHud())
		{
			Uranium_TimeTillBigHit[attacker][victim] = GetGameTime() + 40.0;
			EmitSoundToClient(attacker, "weapons/physcannon/energy_sing_explosion2.wav", attacker, SNDCHAN_STATIC, 80, _, 1.0);
			TE_Particle("mvm_soldier_shockwave", damagePosition, NULL_VECTOR, {0.0,0.0,0.0}, -1, _, _, _, _, _, _, _, _, _, 0.0, .clientspec = attacker);
		}
	}
}

public void SniperRifle_NPCTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int zr_custom_damage)
{
	if(!CheckInHud())
	{
		if(SniperRifle_HeadShot[attacker])
		{
			float attrib = Attributes_Get(weapon, Attrib_ExplosiveHeadshot, 1.0);
			if(attrib > 1.0)
			{
				SpawnSmallExplosion(damagePosition);
				SniperRifle_ExplodDMG[attacker] = damage * attrib;
				Explode_Logic_Custom(0.0, attacker, attacker, -1, damagePosition, _, _, _, true, _, false, _, Func_ExplosiveHeadshot);
			}
			attrib = Attributes_Get(weapon, 390, 1.0);
			if(attrib != 1.0)
				damage*=attrib;
			SniperRifle_HeadShot[attacker]=false;
		}
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_URANIUM_RIFLE && Uranium_TimeTillBigHit[attacker][victim] < GetGameTime())
		{
			damage *= 2.2;
			if(!CheckInHud())
			{
				Uranium_TimeTillBigHit[attacker][victim] = GetGameTime() + 40.0;
				EmitSoundToClient(attacker, "weapons/physcannon/energy_sing_explosion2.wav", attacker, SNDCHAN_STATIC, 80, _, 1.0);
				TE_Particle("mvm_soldier_shockwave", damagePosition, NULL_VECTOR, {0.0,0.0,0.0}, -1, _, _, _, _, _, _, _, _, _, 0.0, .clientspec = attacker);
			}
		}
	}
}
static void Func_ExplosiveHeadshot(int entity, int victim, float damage, int weapon)
{
	if(IsValidEntity(entity) && IsValidEntity(victim) && GetTeam(entity) != GetTeam(victim))
	{
		int Ignore = EntRefToEntIndex(SniperRifle_Ignore[entity]);
		if(Ignore != victim)
			SDKHooks_TakeDamage(victim, entity, entity, SniperRifle_ExplodDMG[entity], DMG_BLAST|DMG_PREVENT_PHYSICS_FORCE);
	}
}