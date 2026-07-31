#pragma semicolon 1
#pragma newdecls required

static bool SmartBounce;
static int LastHitTarget;
static int SuppliesUsed;
static bool SniperSupply_DropPerWave[MAXPLAYERS];

void SniperMonkey_ResetUses()
{
	SuppliesUsed = 0;
	Zero(SniperSupply_DropPerWave);
}
void SniperMonkey_ClearAll()
{
	SmartBounce = false;
	SuppliesUsed = 0;
	Zero(SniperSupply_DropPerWave);
}

float SniperMonkey_BouncingBullets(int victim, int &attacker, int &inflictor, float damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if(LastHitTarget == victim)
		return 0.0;
	
	if(LastHitTarget != victim && !(damagetype & DMG_BLAST))
	{
		if(SmartBounce)
		{

			float pos[3];
			
			int targets[3];
			int healths[3];
			int i;
			for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
			{
				i = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
				if(IsValidEntity(i))
				{
					if(i != victim && !b_NpcHasDied[i] && GetTeam(i) != TFTeam_Red)
					{
						GetEntPropVector(i, Prop_Data, "m_vecAbsOrigin", pos);
						if(GetVectorDistance(pos, damagePosition, true) < 62500.0) 
						{
							int hp = GetEntProp(i, Prop_Data, "m_iHealth");
							if(healths[0] < hp)
							{
								healths[2] = healths[1];
								targets[2] = targets[1];
								
								healths[1] = healths[0];
								targets[1] = targets[0];
								
								healths[0] = hp;
								targets[0] = i;
							}
							else if(healths[1] < hp)
							{
								healths[2] = healths[1];
								targets[2] = targets[1];
								
								healths[1] = hp;
								targets[1] = i;
							}
							else if(healths[2] < hp)
							{
								healths[2] = hp;
								targets[2] = i;
							}
						}
					}
				}
			}
			
			for(i = 0; i < sizeof(targets); i++)
			{
				if(targets[i])
				{
					float DamageDealDo = damage * (0.875 - (0.2 * float(i)));
					if(DamageDealDo >= 0.0)
						SDKHooks_TakeDamage(targets[i], inflictor, attacker, DamageDealDo, damagetype|DMG_BLAST, weapon, damageForce, damagePosition);
				}
			}
			if(RaidbossIgnoreBuildingsLogic(1))
			{
				damage *= 1.5;
			}
		}
		else
		{
			int value = i_ExplosiveProjectileHexArray[attacker];
			i_ExplosiveProjectileHexArray[attacker] = 0;	// If DMG_TRUEDAMAGE doesn't block NPC_OnTakeDamage_Equipped_Weapon_Logic, adjust this
			LastHitTarget = victim;
			
			Explode_Logic_Custom(damage, attacker, attacker, weapon, damagePosition, 250.0, EXPLOSION_AOE_DAMAGE_FALLOFF, _, false, 4);
			if(RaidbossIgnoreBuildingsLogic(1))
			{
				damage *= 1.5;
			}			
			i_ExplosiveProjectileHexArray[attacker] = value;
			LastHitTarget = 0;
		}
	}
	return damage;
}

float SniperMonkey_MaimMoab(int victim, int &attacker, int &inflictor, float damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	float duration = 4.0;
	
	if(duration)
	{
		if((damagetype & DMG_BLAST))
			duration *= 1.5;
		
		if(f_ChargeTerroriserSniper[weapon] > 70.0)
		{
			ApplyStatusEffect(attacker, victim, "Maimed", duration);
		}
	}

	return SniperMonkey_BouncingBullets(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
}

float SniperMonkey_CrippleMoab(int victim, int &attacker, int &inflictor, float damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	float duration = 4.0;

	if(duration)
	{
		if((damagetype & DMG_BLAST))
			duration *= 1.5;
		
		if(f_ChargeTerroriserSniper[weapon] > 70.0)
		{
			ApplyStatusEffect(attacker, victim, "Maimed", duration);
			
			duration *= 1.3;
			ApplyStatusEffect(attacker, victim, "Cripple", duration);
		}
	}
	
	return SniperMonkey_BouncingBullets(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
}

public void Weapon_EnableSmartBouncing(int client)
{
	SmartBounce = true;
}

public void Weapon_EliteDefender(int client, int weapon, bool &result, int slot)
{
	float value = 0.3;
	if(!dieingstate[client] && !LastMann)
	{
		int maxhealth, health;
		for(int target=1; target<=MaxClients; target++)
		{
			if(IsClientInGame(target) && GetClientTeam(target)==2 && TeutonType[target] != TEUTON_WAITING)
			{
				if(IsPlayerAlive(target) && TeutonType[target] == TEUTON_NONE)
				{
					int maxhp = dieingstate[target] ? 1000 : SDKCall_GetMaxHealth(target);
					maxhealth += maxhp;
					
					int hp = GetClientHealth(target);
					if(hp > maxhp)
						hp = maxhp;
					
					health += hp;
				}
				else
				{
					maxhealth += 1000;
				}
			}
		}
		
		if(maxhealth)
		{
			value = float(health) / float(maxhealth);
			if(value < 0.2)
				value = 0.2;
		}
	}
	
	Attributes_Set(weapon, 396, value);
}

public void Weapon_SupplyDrop(int client, int weapon, bool &result, int slot)
{
	if(SuppliesUsed >= 2)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "Supply drop limit reached this wave");
		return;
	}
	else if(Ability_Check_Cooldown(client, slot) < 0.0)
	{
		float pos1[3], pos2[3];
		GetClientEyePosition(client, pos1);
		
		float distance;
		int target = -1;
		for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
		{
			int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
			if(IsValidEntity(entity) && !b_NpcHasDied[entity] && b_NpcForcepowerupspawn[entity] != 2 && GetTeam(entity) != TFTeam_Red)
			{
				GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos2);
				
				float dist = GetVectorDistance(pos1, pos2, true);
				if(distance < dist) 
				{
					target = entity;
					distance = dist;
				}
			}
		}
		
		if(target != -1)
		{
			b_NpcForcepowerupspawn[target] = 2;
			ClientCommand(client, "playgamesound ui/quest_status_tick_advanced_friend.wav");
			Ability_Apply_Cooldown(client, slot, 120.0);

			SuppliesUsed++;
		}
		else
		{
			ClientCommand(client, "playgamesound ui/medic_alert.wav");
			Ability_Apply_Cooldown(client, slot, 5.0);
		}
	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
		
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
	}
}

public void Weapon_SupplyDropElite(int client, int weapon, bool &result, int slot)
{
	if(SuppliesUsed >= 2)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "Supply drop limit reached this wave");
		return;
	}
	if(Ability_Check_Cooldown(client, slot) < 0.0)
	{
		int target = -1;
		for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
		{
			int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
			if(IsValidEntity(entity) && !b_NpcHasDied[entity] && b_NpcForcepowerupspawn[entity] != 2 && GetTeam(entity) != TFTeam_Red)
			{
				target = entity;
				break;
			}
		}
		
		if(target != -1)
		{
			b_NpcForcepowerupspawn[target] = 2;
			ClientCommand(client, "playgamesound ui/quest_status_tick_expert_friend.wav");
			Ability_Apply_Cooldown(client, slot, 90.0);
			SuppliesUsed++;
		}
		else
		{
			ClientCommand(client, "playgamesound ui/medic_alert.wav");
			Ability_Apply_Cooldown(client, slot, 5.0);
		}
	}
	else
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
		
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
	}
}
static Handle SniperSupply_Management[MAXPLAYERS] = {null, ...};

public void SniperSupply_OnMap(int client, int weapon)
{
	Zero(SniperSupply_DropPerWave);
}

public void SniperSupply_Deploy(int client, int weapon)
{
	if(SniperSupply_Management[client] != null)
	{
		delete SniperSupply_Management[client];
		SniperSupply_Management[client] = null;
		DataPack pack;
		SniperSupply_Management[client] = CreateDataTimer(0.1, Timer_Management_SniperSupply, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(weapon);
	}
	else
	{
		DataPack pack;
		SniperSupply_Management[client] = CreateDataTimer(0.1, Timer_Management_SniperSupply, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(weapon);
	}
}

public void SniperSupply_Holster(int client)
{
	if(SniperSupply_Management[client] != null)
	{
		delete SniperSupply_Management[client];
		SniperSupply_Management[client] = null;
	}
}

static Action Timer_Management_SniperSupply(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = pack.ReadCell();
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		if(SniperSupply_Management[client] != null)
		{
			delete SniperSupply_Management[client];
			SniperSupply_Management[client] = null;
		}
		return Plugin_Stop;
	}
	if(CvarInfiniteCash.BoolValue)
		SniperSupply_DropPerWave[client]=false;
	
	if(Ability_Check_Cooldown(client, 1) <= 0.0 && !SniperSupply_DropPerWave[client])
	{
		int target = -1;
		for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
		{
			int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
			if(IsValidEntity(entity) && !b_NpcHasDied[entity] && b_NpcForcepowerupspawn[entity] != 2 && GetTeam(entity) != TFTeam_Red
			&& GetTeam(entity) != TFTeam_Stalkers && !b_ThisEntityIgnored[entity] && !b_NpcIsInvulnerable[entity] && !b_thisNpcIsARaid[entity] && !b_thisNpcIsABoss[entity]
			&& !b_StaticNPC[entity] && !b_ThisEntityIgnoredByOtherNpcsAggro[entity])
			{
				target = entity;
				break;
			}
		}
		
		if(target != -1)
		{
			b_NpcForcepowerupspawn[target] = 2;
			CClotBody npc = view_as<CClotBody>(target);
			if(!IsValidEntity(npc.m_iTeamGlow))
			{
				npc.m_bTeamGlowDefault = false;
				Update_TransmitState(target);
				npc.m_iTeamGlow = TF2_CreateGlow(target);
				
				SetVariantColor(view_as<int>({136, 200, 5, 200}));
				AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
			}
			else
			{
				if(IsValidEntity(npc.m_iTeamGlow)) 
				{
					npc.m_bTeamGlowDefault = false;
					Update_TransmitState(target);
					SetVariantColor(view_as<int>({136, 200, 5, 200}));
					AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
				}		
			}
			ClientCommand(client, "playgamesound ui/quest_status_tick_expert_friend.wav");
			Rogue_OnAbilityUse(client, weapon);
			Ability_Apply_Cooldown(client, 1, 90.0);
			SniperSupply_DropPerWave[client]=true;
		}
		else
			Ability_Apply_Cooldown(client, 1, 5.0, .ignoreCooldown=true);
	}
	
	return Plugin_Continue;
}

public void SniperSupply_M1(int client, int weapon, bool crit, int slot)
{
	static float vAngles[3], vOrigin[3];
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);
	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, BulletAndMeleeTrace, client);
	if(TR_GetFraction(trace) < 1.0)
	{
		TR_GetEndPosition(vOrigin, trace);
		int target = TR_GetEntityIndex(trace);
		if(target > 0 && !b_CannotBeHeadshot[target])
		{
			if(TR_GetHitGroup(trace) == HITGROUP_HEAD)
			{
				DisplayCritAboveNpc(target, client, true);
				SniperRifle_HeadShot[client]=true;
			}
		}
	}
	delete trace;
	if(SniperRifle_HeadShot[client])
	{
		if(i_CurrentEquippedPerk[client] & PERK_MARKSMAN_BEER
		|| i_CurrentEquippedPerk[client] & PERK_MARKSMAN_BEER_X)
		{
			float Ability_CD = Ability_Check_Cooldown(client, 3)-3.0;
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
			Ability_Apply_Cooldown(client, 3, Ability_CD, .ignoreCooldown=true);
			Ability_CD = Ability_Check_Cooldown(client, 1)-5.0;
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
			Ability_Apply_Cooldown(client, 1, Ability_CD, .ignoreCooldown=true);
		}
		SniperRifle_HeadShot[client]=false;
	}
	if(TF2_IsPlayerInCondition(client, TFCond_FocusBuff))
	{
		int KITER_Pack=RandomPickup_SpawnPickup(vOrigin);
		if(IsValidEntity(KITER_Pack))
		{
			int MaxPickups = 8;
			if(ZR_Get_Modifier() == KITERS_DREAM)
				MaxPickups *= 2;
			CClotBody npc = view_as<CClotBody>(KITER_Pack);
			if(!IsValidEntity(npc.m_iTeamGlow))
			{
				npc.m_bTeamGlowDefault = false;
				Update_TransmitState(KITER_Pack);
				npc.m_iTeamGlow = TF2_CreateGlow(KITER_Pack);
				
				SetVariantColor(view_as<int>({136, 200, 5, 200}));
				AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
				CreateTimer(45.0 * MaxPickups, Timer_RemoveEntity, EntIndexToEntRef(npc.m_iTeamGlow), TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				if(IsValidEntity(npc.m_iTeamGlow)) 
				{
					npc.m_bTeamGlowDefault = false;
					Update_TransmitState(KITER_Pack);
					SetVariantColor(view_as<int>({136, 200, 5, 200}));
					AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
					CreateTimer(45.0 * MaxPickups, Timer_RemoveEntity, EntIndexToEntRef(npc.m_iTeamGlow), TIMER_FLAG_NO_MAPCHANGE);
				}		
			}
			if(Ability_Check_Cooldown(client, 3) < 999.0 && Attributes_Get(weapon, Attrib_PapNumber, 0.0)==2)
				Ability_Apply_Cooldown(client, 3, 9999999.0, .ignoreCooldown=true);
			else
				Ability_Apply_Cooldown(client, 3, 60.0);
			vOrigin[2] += 5.0;
			spawnRing_Vectors(vOrigin, 0.0, 0.0, 0.0, 0.0, LASERBEAM, 0, 255, 0, 255, 5, 0.5, 3.0, 1.0, 3, 150.0);
			ClientCommand(client, "playgamesound ui/medic_alert.wav");
			TF2_RemoveCondition(client, TFCond_FocusBuff);
		}
	}
}

public void SniperSupply_R(int client, int weapon, bool crit, int slot)
{
	float Ability_CD = Ability_Check_Cooldown(client, slot);
	
	if(Ability_CD <= 0.0 || CvarInfiniteCash.BoolValue)
		Ability_CD = 0.0;
	if(Ability_CD <= 0.0 || Ability_CD > 999.0)
	{
		if(TF2_IsPlayerInCondition(client, TFCond_FocusBuff))
			TF2_RemoveCondition(client, TFCond_FocusBuff);
		else
			TF2_AddCondition(client, TFCond_FocusBuff, 5.0);
		return;
	}
	ClientCommand(client, "playgamesound items/medshotno1.wav");
	SetDefaultHudPosition(client);
	SetGlobalTransTarget(client);
	ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
}