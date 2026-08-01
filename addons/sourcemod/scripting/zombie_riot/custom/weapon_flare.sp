#pragma semicolon 1
#pragma newdecls required

#define SOUND_KILLINGORDER_FIRE      "Weapon_ManMelter.Single"
#define SOUND_KILLINGORDER_FIRE_CRIT "Weapon_ManMelter.SingleCrit"

void KillingOrder_Precache()
{
	PrecacheScriptSound(SOUND_KILLINGORDER_FIRE);
	PrecacheScriptSound(SOUND_KILLINGORDER_FIRE_CRIT);
	PrecacheSound("physics/metal/metal_box_impact_bullet1.wav");
}

public void KillingOrder_Fire(int client, int weapon, bool crit)
{
	b_LagCompNPC_ExtendBoundingBox = true;
	StartLagCompensation_Base_Boss(client);
	
	float pos[3], ang[3];
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, ang);
	
	float targetPos[3], hitPos[3];
	
	bool headshot;
	int target = -1;
	Handle trace = TR_TraceRayFilterEx(pos, ang, MASK_SHOT, RayType_Infinite, BulletAndMeleeTrace, client);
	
	TR_GetEndPosition(hitPos, trace);
	
	if(TR_DidHit(trace))
	{
		target = TR_GetEntityIndex(trace);
		if(target > 0)
		{
			WorldSpaceCenter(target, targetPos);
			
			headshot = (TR_GetHitGroup(trace) == HITGROUP_HEAD && !b_CannotBeHeadshot[target]);
		}
	}
	delete trace;
	
	if(target > 0 && IsValidEnemy(client, target))
	{
		float damage = 30.0;
		damage *= Attributes_Get(weapon, 1, 1.0);
		damage *= Attributes_Get(weapon, 2, 1.0);
		
		bool DoCalcReduceHeadshotFalloff = false;
		if(headshot)
		{
			if(f_HeadshotDamageMultiNpc[target] <= 0.0)
			{
				GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", targetPos);
				if(b_BoundingBoxVariant[target] == BBV_Giant)
					targetPos[2] += 120.0;
				else
					targetPos[2] += 82.0;
				TE_ParticleInt(g_particleMissText, targetPos);
				TE_SendToClient(client);
				EmitSoundToClient(client, "physics/metal/metal_box_impact_bullet1.wav", target, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(95, 105));
				headshot = false;
				damage = 0.0;
			}
			else
				DisplayCritAboveNpc(target, client, true);
			
			if(i_HeadshotAffinity[client] == 1)
			{
				damage *= 1.42;
			}
			else
			{
				damage *= 1.185;
			}
			
			if(i_CurrentEquippedPerk[client] & PERK_MARKSMAN_BEER)
			{
				damage *= 1.25;
			}
			if(i_CurrentEquippedPerk[client] & PERK_MARKSMAN_BEER_X)
			{
				damage *= 1.35;
			}
			
			DoCalcReduceHeadshotFalloff = true;
		}
		else
		{
			if(i_HeadshotAffinity[client] == 1)
			{
				damage *= 0.75;
			}
		}
		
		if(i_WeaponDamageFalloff[weapon] != 1.0)
		{
			if(b_ProximityAmmo[client])
			{
				damage *= 1.15;
			}
			
			float attackerPos[3];
			WorldSpaceCenter(client, attackerPos);

			float distance = GetVectorDistance(attackerPos, targetPos, true);
			
			distance -= 1600.0;// Give 60 units of range cus its not going from their hurt pos
			
			if(distance < 0.1)
			{
				distance = 0.1;
			}
			
			float WeaponDamageFalloff = i_WeaponDamageFalloff[weapon];
			if(b_ProximityAmmo[client])
			{
				WeaponDamageFalloff *= 0.8;
			}
			
			if(DoCalcReduceHeadshotFalloff && WeaponDamageFalloff <= 1.0)
			{
				WeaponDamageFalloff *= 1.3;
				if (WeaponDamageFalloff >= 1.0)
					WeaponDamageFalloff = 1.0;
			}
			
			damage *= Pow(WeaponDamageFalloff, (distance / 1000000.0));
		}
		
		SDKHooks_TakeDamage(target, client, client, damage, DMG_BULLET, weapon, NULL_VECTOR, targetPos);
	}
	
	FinishLagCompensation_Base_boss();
	
	CalcCorrectWeaponShootPosition({ 60.9, 13.1, -15.1 }, pos, ang);
	TE_Particle("dxhr_sniper_rail", pos, _, ang, .controlpoint = 1, .controlpointattachment = PATTACH_WORLDORIGIN, .controlpointoffset = hitPos);
	
	EmitGameSoundToAll(headshot ? SOUND_KILLINGORDER_FIRE_CRIT : SOUND_KILLINGORDER_FIRE, weapon);
}

public void KillingOrder_OnDealDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int zr_custom_damage)
{
	if((zr_custom_damage & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED))
		return;
	
	ApplyStatusEffect(attacker, victim, "Identifying Targets", 4.0);
}

void CalcCorrectWeaponShootPosition(const float vecOffset[3], float vecStartPosition[3], const float vecAngles[3]) {
	float vecForward[3], vecRight[3], vecUp[3];
	GetAngleVectors(vecAngles, vecForward, vecRight, vecUp);
	
	ScaleVector(vecForward, vecOffset[0]);
	ScaleVector(vecRight, vecOffset[1]);
	ScaleVector(vecUp, vecOffset[2]);
	
	AddVectors(vecStartPosition, vecForward, vecStartPosition);
	AddVectors(vecStartPosition, vecRight, vecStartPosition);
	AddVectors(vecStartPosition, vecUp, vecStartPosition);
}