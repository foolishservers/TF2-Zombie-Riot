#pragma semicolon 1
#pragma newdecls required

static const int SupportBuildings[] = { 2, 2, 5, 9, 14, 14, 15 };
static const int MetalGain[] = { 0, 5, 8, 11, 15, 20, 35 };
static const float Cooldowns[] = { 150.0, 130.0, 110.0, 90.0, 70.0, 50.0, 30.0 };
static int SmithLevel[MAXPLAYERS] = {-1, ...};
static int i_AdditionalSupportBuildings[MAXPLAYERS] = {0, ...};

static int i_TinkerTracerIndex;

static int ParticleRef[MAXPLAYERS] = {-1, ...};
static Handle EffectTimer[MAXPLAYERS];
static bool AggressiveRanger[MAXPLAYERS];

// Anvil & Enchant.
#include "kit_blacksmith_enchant.sp"

void Blacksmith_RoundStart()
{
	Zero(i_AdditionalSupportBuildings);
	Zero(AggressiveRanger);
	Tinker_RoundStart();
}

public void Blacksmith_MapStart()
{
	i_TinkerTracerIndex = PrecacheModel(CLAW_TRAIL_RED);
}

bool Blacksmith_Lastman(int client)
{
	bool Purnell_Went_Nuts = false;
	if(EffectTimer[client] != null)
		Purnell_Went_Nuts = true;
	
	return Purnell_Went_Nuts;
}

int Blacksmith_Additional_SupportBuildings(int client)
{
	return i_AdditionalSupportBuildings[client];
}

bool Blacksmith_IsASmith(int client)
{
	return view_as<bool>(EffectTimer[client]);
}

bool Blacksmith_Any_IsASmith()
{
	for(int i=1; i<=MaxClients; i++)
	{
		if(Blacksmith_IsASmith(i))
			return true;
		if(MSword_IsASmith(i))
			return true;
	}
	return false;
}

void Blacksmith_Enable(int client, int weapon)
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_BLACKSMITH)
	{
		SmithLevel[client] = RoundFloat(Attributes_Get(weapon, 868, 0.0)) + 1;

		if(SmithLevel[client] >= sizeof(MetalGain))
			SmithLevel[client] = sizeof(MetalGain) - 1;

		delete EffectTimer[client];
		EffectTimer[client] = CreateTimer(0.5, Blacksmith_TimerEffect, client, TIMER_REPEAT);
		
		i_AdditionalSupportBuildings[client] = SupportBuildings[SmithLevel[client]];
		Weapon_OnBuyUpdateBuilding(client);
	}
	
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_MINECRAFT_SWORD)
	{
		SmithLevel[client] = RoundFloat(Attributes_Get(weapon, 868, 0.0)) + 1;
	}
	
	Tinker_OnWeaponEnable(client, weapon);
}

public Action Blacksmith_TimerEffect(Handle timer, int client)
{
	if(IsClientInGame(client) && SmithLevel[client] > -1)
	{
		if(!dieingstate[client] && IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE && i_ClientHasCustomGearEquipped[client] == CUSTOMGEAR_NONE)
		{
			int weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
			if(weapon != -1)
			{
				if(i_CustomWeaponEquipLogic[weapon] == WEAPON_BLACKSMITH)
				{
					if(!Waves_InSetup() && GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") == weapon)
					{
						SetAmmo(client, Ammo_Metal, GetAmmo(client, Ammo_Metal) + MetalGain[SmithLevel[client]]);
						CurrentAmmo[client][3] = GetAmmo(client, 3);
					}

					i_AdditionalSupportBuildings[client] = SupportBuildings[SmithLevel[client]];

					if(SmithLevel[client] > 0 && ParticleRef[client] == -1)
					{
						float pos[3]; GetClientAbsOrigin(client, pos);
						pos[2] += 1.0;

						int entity = ParticleEffectAt(pos, "utaunt_hands_floor2_red", -1.0);
						if(entity > MaxClients)
						{
							SetParent(client, entity);
							ParticleRef[client] = EntIndexToEntRef(entity);
						}
					}
					
					return Plugin_Continue;
				}
			}
		}
		else
		{
			if(ParticleRef[client] != -1)
			{
				int entity = EntRefToEntIndex(ParticleRef[client]);
				if(entity > MaxClients)
				{
					TeleportEntity(entity, OFF_THE_MAP);
					RemoveEntity(entity);
				}

				ParticleRef[client] = -1;
			}

			return Plugin_Continue;
		}
	}

	SmithLevel[client] = -1;
		
	if(ParticleRef[client] != -1)
	{
		int entity = EntRefToEntIndex(ParticleRef[client]);
		if(entity > MaxClients)
		{
			TeleportEntity(entity, OFF_THE_MAP);
			RemoveEntity(entity);
		}
		
		ParticleRef[client] = -1;
	}
	i_AdditionalSupportBuildings[client] = 0;
	EffectTimer[client] = null;
	return Plugin_Stop;
}

public void Weapon_Blacksmith_Primary_M1(int client, int weapon, bool crit, int slot)
{
	if (AggressiveRanger[client]) {
		Weapon_Blacksmith_ShootBullet(client, weapon);
	}
	else {
		Tinker_ShootProjectile(client, weapon, crit, slot);
	}
}

public void Weapon_Blacksmith_Primary_R(int client, int weapon, bool crit, int slot)
{
	if (Ability_Check_Cooldown(client, slot) > 0.0) {
		return;
	}
	
	// No spamming.
	Ability_Apply_Cooldown(client, slot, 0.25);
	
	AggressiveRanger[client] = !AggressiveRanger[client];
	if (AggressiveRanger[client]) {
		PrintHintText(client, "[Aggressive Mode]");
	}
	else {
		PrintHintText(client, "[Repair Mode]");
	}
}

static void Weapon_Blacksmith_ShootBullet(int client, int weapon)
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
		float damage = 50.0;
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
	
	FinishLagCompensation_Base_boss(.client = client);
	
	CalcCorrectWeaponShootPosition({ 60.9, 13.1, -15.1 }, pos, ang);
	TE_SetupBeamPoints(pos, hitPos, i_TinkerTracerIndex, 0, 0, 0, 0.3, 3.0, 3.0, 0, 0.0, {255, 255, 255, 255}, 3);
	TE_SendToAll(0.0);
}

public void Weapon_BlacksmithMelee_M2(int client, int weapon, bool crit, int slot)
{
	if(dieingstate[client] != 0 || Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	Rogue_OnAbilityUse(client, weapon);
	Ability_Apply_Cooldown(client, slot, 10.0);

	ClientCommand(client, "playgamesound weapons/gunslinger_three_hit.wav");

	ApplyTempAttrib(weapon, 2, 2.0, 2.0);
	ApplyTempAttrib(weapon, 6, 0.25, 2.0);
}

// Anvil 사용 인터페이스 (실제 처리는 kit_blacksmith_enchant.sp)
void Blacksmith_BuildingUsed(int entity, int client)
{
	Anvil_BuildingUsed(entity, client);
}

int Blacksmith_GetSmithLevel(int client)
{
	return SmithLevel[client];
}

float Blacksmith_GetAnvilCooldown(int smithLevel)
{
	return Cooldowns[smithLevel];
}