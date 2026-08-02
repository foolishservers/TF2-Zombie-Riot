#pragma semicolon 1
#pragma newdecls required

float Uranium_TimeTillBigHit[MAXPLAYERS][MAXENTITIES];

bool SniperRifle_HeadShot[MAXPLAYERS];
static int SniperRifle_Ignore[MAXPLAYERS];
static float SniperRifle_ExplodDMG[MAXPLAYERS];
static float SniperRifle_Charge[MAXPLAYERS];
static float SniperRifle_RestTime[MAXPLAYERS];

static int SniperRifle_DMR_AIMBOT[MAXPLAYERS];
static float SniperRifle_AIMBOTTime[MAXPLAYERS];

void Uranium_MapStart()
{
	Zero2(Uranium_TimeTillBigHit);
	Zero(SniperRifle_HeadShot);
	Zero(SniperRifle_Ignore);
	Zero(SniperRifle_DMR_AIMBOT);
	ZeroFloat(SniperRifle_ExplodDMG);
	ZeroFloat(SniperRifle_Charge);
	ZeroFloat(SniperRifle_RestTime);
	ZeroFloat(SniperRifle_AIMBOTTime);
	PrecacheSound("weapons/doom_scout_pistol.wav");
	PrecacheSound("weapons/doom_scout_pistol_crit.wav");
	PrecacheSound("weapons/csgo_awp_shoot.wav");
	PrecacheSound("weapons/csgo_awp_shoot_crit.wav");
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
		
		if(!b_ThisWasAnNpc[victim] && Attributes_Get(weapon, Attrib_IsSniperRifle, 0.0)==2.0)
			b_DoGibThisNpc[victim] = true;
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

public void Weapon_SniperRifle_DMR_Holster(int client, int weapon)
{
	Weapon_Railcannon_Pap2_Holster(client, -1, false, -1);
	if(IsValidEntity(weapon))
	{
		Attributes_Set(weapon, 107, 1.0);
		TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.00001);
	}
	SDKUnhook(client, SDKHook_PreThink, Weapon_SniperRifle_DMR_M1_PreThink);
}

public void Weapon_SniperRifle_DMR_R(int client, int weapon, bool crit, int slot)
{
	float GameTime = GetGameTime();
	if(SniperRifle_AIMBOTTime[client] > GameTime)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Already Used");
		return;
	}
	float Attrib = 1.0;
	Attrib *= Attributes_Get(weapon, 3, 1.0);
	Attrib *= Attributes_Get(weapon, 4, 1.0);
	int MaxAmmo = RoundToCeil(float(i_SemiAutoStats_MaxAmmo[weapon])*Attrib);
	if(i_SemiAutoWeapon_AmmoCount[weapon] < MaxAmmo
	|| GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack") > GameTime)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return;
	}
	float Ability_CD = Ability_Check_Cooldown(client, slot);

	if(Ability_CD <= 0.0 || CvarInfiniteCash.BoolValue)
		Ability_CD = 0.0;
	if(Ability_CD > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
		return;
	}
	Handle swingTrace;
	float vecSwingForward[3];
	StartLagCompensation_Base_Boss(client);
	DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 9900.0, false, 9900.0, true); //infinite range, and does not ignore walls!
	FinishLagCompensation_Base_boss();
	
	int target = TR_GetEntityIndex(swingTrace);	
	delete swingTrace;
	if(!IsValidEnemy(client, target, true))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return;
	}
	Rogue_OnAbilityUse(client, weapon);
	Ability_Apply_Cooldown(client, slot, 65.0);
	MakePlayerGiveResponseVoice(client, 1);
	ApplyStatusEffect(client, client, "Aimbot", 2.0);
	SniperRifle_DMR_AIMBOT[client] = EntIndexToEntRef(target);
	SniperRifle_AIMBOTTime[client] = GameTime + 2.0;	
	TF2_AddCondition(client, TFCond_HalloweenCritCandy, 2.0, client);
	SDKUnhook(client, SDKHook_PreThink, Weapon_SniperRifle_DMR_M1_PreThink);
	SDKHook(client, SDKHook_PreThink, Weapon_SniperRifle_DMR_M1_PreThink);
}

static void Weapon_SniperRifle_DMR_M1_PreThink(int client)
{
	if(SniperRifle_AIMBOTTime[client] > GetGameTime())
	{
		int ChargeEnemy = EntRefToEntIndex(SniperRifle_DMR_AIMBOT[client]);
		if(IsValidEnemy(client, ChargeEnemy, true))
			LookAtTarget(client, ChargeEnemy);
		return;
	}
	SniperRifle_DMR_AIMBOT[client] = -1;
	SniperRifle_AIMBOTTime[client] = 0.0;
	if(TF2_IsPlayerInCondition(client, TFCond_HalloweenCritCandy))
		TF2_RemoveCondition(client, TFCond_HalloweenCritCandy);
	SDKUnhook(client, SDKHook_PreThink, Weapon_SniperRifle_DMR_M1_PreThink);
}

public void Weapon_SniperRifle_DMR_M2(int client, int weapon, bool crit, int slot)
{
	Weapon_Railcannon_Pap2_Zoom(client, -1, false, -1);
	if(IsValidEntity(weapon))
	{
		Attributes_Set(weapon, 107, client_Is_Zoom_Active(client) ? Attributes_Get(weapon, 75, 1.0) : 1.0);
		TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.00001);
	}
}

public void Weapon_SniperRifle_DMR_M1(int client, int weapon, bool crit, int slot)
{
	if(!IsValidEntity(weapon))
		return;
	if(i_SemiAutoWeapon_AmmoCount[weapon] <= 0)
	{
		int STOPIT = GetEntProp(weapon, Prop_Send, "m_nKillComboCount");
		SetEntProp(weapon, Prop_Send, "m_nKillComboCount", STOPIT+1);
		if(STOPIT>5)
		{
			int health = GetClientHealth(client);
			float WorldSpaceVec[3]; WorldSpaceCenter(client, WorldSpaceVec);
			TimedLgtning(client, WorldSpaceVec);
			if(!IsInvuln(client))
				SDKHooks_TakeDamage(client, 0, 0, float(health/2), DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE);
			SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime() + 5.0);
			ApplyStatusEffect(client, client, "Ragdolled", 5.0);
			FreezeNpcInTime(client, 5.0);
			TF2_AddCondition(client, TFCond_LostFooting, 5.0);
			TF2_AddCondition(client, TFCond_AirCurrent, 5.0);
			SetEntProp(weapon, Prop_Send, "m_nKillComboCount", 0);
			return;
		}
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "STOP USE BUG!!!!!");
		return;
	}
	SetEntProp(weapon, Prop_Send, "m_nKillComboCount", 0);

	if(Attributes_Get(weapon, Attrib_ExplosiveHeadshot, 1.0) > 1.0)
	{
		float charge=GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage");
		if(charge<150.0 || !TF2_IsPlayerInCondition(client, TFCond_Zoomed))
			EmitSoundToAll("weapons/sniper_shoot.wav", client, SNDCHAN_STATIC, 80, _, 1.0);
	}
	if(SniperRifle_RestTime[client] < GetGameTime())
		SniperRifle_RestTime[client]=0.0;
		
	float accurate = 1.0;
	accurate *= Attributes_Get(weapon, 106, 1.0);
	
	if(SniperRifle_RestTime[client]==0.0 || SniperRifle_AIMBOTTime[client]!=0.0)
		accurate=0.0;
	else
	{
		float AimSpreadDegrading=FloatAbs(SniperRifle_RestTime[client]-GetGameTime());
		AimSpreadDegrading=1.0*(AimSpreadDegrading/2.24);
		if(AimSpreadDegrading<0.0)
			AimSpreadDegrading=0.0;
		if(AimSpreadDegrading>4.0)
			AimSpreadDegrading=4.0;
		accurate*=AimSpreadDegrading;
	}
	float x = GetRandomFloat( -0.05*accurate, 0.05*accurate ) + GetRandomFloat( -0.05*accurate, 0.05*accurate );
	float y = GetRandomFloat( -0.05*accurate, 0.05*accurate ) + GetRandomFloat( -0.05*accurate, 0.05*accurate );
	
	accurate = 50.0;
	if(client_Is_Zoom_Active(client))
		accurate *= Attributes_Get(weapon, 41, 1.0);
	
	if(!SniperRifle_RestTime[client])
		SniperRifle_RestTime[client] = GetGameTime()+((i_CurrentEquippedPerk[client] & PERK_MARKSMAN_BEER
			|| i_CurrentEquippedPerk[client] & PERK_MARKSMAN_BEER_X) ? 0.72 : 1.0);
	
	static float vAngles[3], vOrigin[3], vecRight[3], vecUp[3];
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);
	GetAngleVectors(vAngles, vAngles, vecRight, vecUp);
	
	static float vecDir[3];
	vecDir[0] = vAngles[0] + x * vecRight[0] + y * vecUp[0]; 
	vecDir[1] = vAngles[1] + x * vecRight[1] + y * vecUp[1]; 
	vecDir[2] = vAngles[2] + x * vecRight[2] + y * vecUp[2]; 
	NormalizeVector(vecDir, vecDir);
	GetVectorAngles(vecDir, vecDir);
	bool b_HeadShot;
	Handle trace = TR_TraceRayFilterEx(vOrigin, vecDir, MASK_SHOT, RayType_Infinite, BulletAndMeleeTrace, client);
	if(TR_GetFraction(trace) < 1.0)
	{
		TR_GetEndPosition(vecRight, trace);
		int target = TR_GetEntityIndex(trace);
		if(target <= 0 || target > MaxClients)
		{
			float vecNormal[3]; TR_GetPlaneNormal(trace, vecNormal);
			GetVectorAngles(vecNormal, vecNormal);
			static char class[12];
			GetEntityClassname(TR_GetEntityIndex(trace), class, sizeof(class));
			if(!b_ThisWasAnNpc[target] && StrContains(class, "obj_"))
				CreateParticle("impact_concrete", vecRight, vecNormal);
		}
		if(IsValidEntity(target) && IsValidEnemy(client, target))
		{
			if((f_HeadshotDamageMultiNpc[target] <= 0.0 || b_CannotBeHeadshot[target]) && TR_GetHitGroup(trace) == HITGROUP_HEAD)
			{
				SniperRifle_HeadShot[client]=false;
				b_HeadShot=false;
				GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", vAngles);
				if(b_BoundingBoxVariant[target] == BBV_Giant)
				{
					vAngles[2] += 120.0;
				}
				else
				{
					vAngles[2] += 82.0;
				}
				TE_ParticleInt(g_particleMissText, vAngles);
				TE_SendToClient(client);
				EmitSoundToClient(client, "physics/metal/metal_box_impact_bullet1.wav", target, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(95, 105));
				accurate=0.0;
			}
			else
			{
				if(SniperRifle_AIMBOTTime[client]!=0.0 && f_HeadshotDamageMultiNpc[target] > 0.0 && !b_CannotBeHeadshot[target])
				{
					SniperRifle_HeadShot[client]=true;
					b_HeadShot=true;
				}
				if(TR_GetHitGroup(trace) == HITGROUP_HEAD)
				{
					SniperRifle_Ignore[client]=EntIndexToEntRef(target);
					SniperRifle_HeadShot[client]=true;
					b_HeadShot=true;
					if(client_Is_Zoom_Active(client))
						accurate *= Attributes_Get(weapon, 304, 1.0);
				}
			}
			CalculateBulletDamageForce(vecRight, 1.0, vecUp);
			CalcCorrectCWeaponDMG(target, client, client, accurate,
			DMG_BULLET, weapon, vecUp,
			vecRight, ZR_DAMAGE_NONE, b_HeadShot, b_HeadShot ? 2 : 0);
			if(Attributes_Get(weapon, Attrib_PapNumber, 1.0)>=2.0 && Uranium_TimeTillBigHit[client][target] < GetGameTime())
			{
				ApplyStatusEffect(client, target, "Silenced", (b_thisNpcIsARaid[target] || b_thisNpcIsABoss[target]) ? 3.0 : 5.0);
				if(Attributes_Get(weapon, Attrib_PapNumber, 1.0)>=3.0)
					IncreaseEntityDamageTakenBy(target, 0.1, (b_thisNpcIsARaid[target] || b_thisNpcIsABoss[target]) ? 3.0 : 5.0, true);
				Uranium_TimeTillBigHit[client][target] = GetGameTime() + 40.0;
			}
		}
	}
	delete trace;
	
	//view_as<CClotBody>(weapon).GetAttachment("muzzle", vecDir, vAngles);
	//Offset_Vector({ 60.9, 13.1, -15.1 }, vecDir, vecDir);
	CalcCorrectWeaponShootPosition({ 60.9, 13.1, -15.1 }, vOrigin, vecDir);
	ShootLaser(weapon, "tfc_sniper_distortion_trail", vOrigin, vecRight, false);
	ShootLaser(weapon, b_HeadShot ? "bullet_tracer01_red_crit" : "bullet_tracer01_red", vOrigin, vecRight, false);
	EmitSoundToAll(
	Attributes_Get(weapon, Attrib_PapNumber, 1.0)>=3.0 ? (b_HeadShot ? "weapons/csgo_awp_shoot_crit.wav" : "weapons/csgo_awp_shoot.wav") 
	: (b_HeadShot ? "weapons/doom_scout_pistol_crit.wav" : "weapons/doom_scout_pistol.wav")
	, weapon);
}

stock void CalcCorrectCWeaponDMG(int target = 0, int inflictor = 0, int attacker = 0, float damage = 0.0,
int damageType=DMG_GENERIC, int weapon=-1,const float damageForce[3]=NULL_VECTOR,
const float damagePosition[3]=NULL_VECTOR, int ZRCustom_DMGType = 0, bool headshot, int crit)
{
	if(!IsValidClient(attacker)||!IsValidEntity(target))
		return;
	if(!IsValidEntity(inflictor))
		inflictor=attacker;
	bool DoCalcReduceHeadshotFalloff = false;
	bool AlreadyValidEntity = false;
	if(IsValidEntity(weapon))
	{
		damage *= Attributes_Get(weapon, 1, 1.0);
		damage *= Attributes_Get(weapon, 2, 1.0);
		AlreadyValidEntity=true;
	}
	else
		weapon = -1;
	if(headshot)
	{
		if(AlreadyValidEntity)
			damage *= Attributes_Get(weapon, 390, 1.0);
	
		if(i_HeadshotAffinity[attacker] == 1)
			damage *= 1.42;
		else
			damage *= 1.185;
		
		if(i_CurrentEquippedPerk[attacker] & PERK_MARKSMAN_BEER)
			damage *= 1.25;
		if(i_CurrentEquippedPerk[attacker] & PERK_MARKSMAN_BEER_X)
			damage *= 1.35;
		
		DoCalcReduceHeadshotFalloff = true;
	}
	else if(i_HeadshotAffinity[attacker] == 1)
		damage *= 0.75;
	if(AlreadyValidEntity)
	{
		float GetFallOff=Custom_Inventory_Falloff(attacker, weapon);
		if(i_WeaponDamageFalloff[weapon] != 1.0 || GetFallOff != 1.0)
		{
			if(b_ProximityAmmo[attacker])
				damage *= 1.15;
			
			float attackerPos[3], targetPos[3];
			WorldSpaceCenter(attacker, attackerPos);
			WorldSpaceCenter(target, targetPos);

			float distance = GetVectorDistance(attackerPos, targetPos, true);
			
			distance -= 1600.0;
			
			if(distance < 0.1)
				distance = 0.1;
			
			float WeaponDamageFalloff = i_WeaponDamageFalloff[weapon];
			if(b_ProximityAmmo[attacker])
				WeaponDamageFalloff *= 0.8;
			
			if(DoCalcReduceHeadshotFalloff && WeaponDamageFalloff <= 1.0)
			{
				WeaponDamageFalloff *= 1.3;
				if (WeaponDamageFalloff >= 1.0)
					WeaponDamageFalloff = 1.0;
			}
			
			damage *= Pow(WeaponDamageFalloff, (distance / 1000000.0));
		}
	}
	
	if(crit)
		DisplayCritAboveNpc(target, attacker, (crit>=2));

	SDKHooks_TakeDamage(target, inflictor, attacker, damage, damageType, weapon, damageForce, damagePosition, false, ZRCustom_DMGType);
	return;
}