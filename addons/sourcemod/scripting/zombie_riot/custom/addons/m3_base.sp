#pragma semicolon 1
#pragma newdecls required

static int g_BluePoint;
//static int g_RedPoint;
static int LSPR;

static int g_ProjectileModelArmor;
//static int g_ProjectileModel;

static float f_SupportWeapon_Timer[MAXPLAYERS];

static bool b_OneDown[MAXPLAYERS];

static const char g_TeleSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav"
};

static const char SupportWeaponList[][] =
{
	"SupportWeapon SMG-43",
	"SupportWeapon APW-1 Sniperrifle",
	"SupportWeapon RD-3 Grenade Launcher",
};

static const char g_PortalSounds[]=")misc/halloween/spell_teleport.wav";

void Addon_M3_Precache()
{
	g_BluePoint = PrecacheModel("sprites/blueglow1.vmt");
	//g_RedPoint = PrecacheModel("sprites/redglow1.vmt");
	LSPR = PrecacheModel("sprites/lgtning.vmt");
	
	//g_ProjectileModel = PrecacheModel("models/healthvial.mdl");
	g_ProjectileModelArmor = PrecacheModel("models/Items/battery.mdl");
	
	PrecacheSound("weapons/gas_can_explode.wav");
	PrecacheSound("ambient/explosions/explode_9.wav");
	PrecacheSound("player/pl_scout_dodge_can_drink.wav");
	PrecacheSound("weapons/air_burster_explode3.wav");
	PrecacheSound(g_PortalSounds);
	PrecacheSoundArray(g_TeleSounds);
	/*if(FileExists("sound/baka_zr/sd_de_01.mp3", true))
		PrecacheSound("baka_zr/sd_de_01.mp3", true);
	if(FileExists("sound/baka/nuke_doom.mp3", true))
		PrecacheSound("baka/nuke_doom.mp3", true);
	if(FileExists("sound/baka_zr/sd_de_02.mp3", true))
		PrecacheSound("baka_zr/sd_de_02.mp3", true);
	if(FileExists("sound/baka_zr/sd_spw_01.mp3", true))
		PrecacheSound("baka_zr/sd_spw_01.mp3", true);
	if(FileExists("sound/baka_zr/sd_spw_02.mp3", true))
		PrecacheSound("baka_zr/sd_spw_02.mp3", true);
	if(FileExists("sound/baka_zr/sd_spw_03.mp3", true))
		PrecacheSound("baka_zr/sd_spw_03.mp3", true);*/
}

public Action CommandAdminRND(int client, int args)
{
	if(!IsValidClient(client) || IsFakeClient(client))
	{
		PrintToConsole(client, "Command is in-game only");
		return Plugin_Handled;
	}
	char buf[12];
	GetCmdArg(1, buf, sizeof(buf));
	int RNDIndex = StringToInt(buf);
	if(RNDIndex)
		DrinkRND(client, RNDIndex);
	
	return Plugin_Handled;
}

stock void Addon_OnBombDrop(int entity, const char [] name)
{
	if(!IsValidEntity(entity))
		return;
	if(StrContains(name, "ZR_SupportWeaponPOD_", false) != -1)
	{
		int client = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
		float position[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
		AcceptEntityInput(entity, "KillHierarchy");
		position[2]-=10.0;
		if(IsValidClient(client))
		{
			Explode_Logic_Custom(0.0, client, client, -1, position, 125.0, _, _, true, _, false, _, PodKill);
			int Prop = CreateEntityByName("prop_dynamic");
			if(IsValidEntity(Prop))
			{
				//position[2]+=30.0;
				DispatchKeyValue(Prop, "model", "models/props_urban/urban_crate002.mdl");
				DispatchKeyValue(Prop, "angles", "0 0 0");
				DispatchKeyValue(Prop, "solid", "0");
				TeleportEntity(Prop, position, NULL_VECTOR, NULL_VECTOR);
				DispatchSpawn(Prop);
				/*CClotBody npc = view_as<CClotBody>(Prop);
				npc.m_bThisEntityIgnored = true;*/
				
				M3_Ability_Duration(Prop, GetGameTime() + 30.0);
				
				SetEntProp(Prop, Prop_Data, "m_nNextThinkTick", -1);
				DataPack pack;
				CreateDataTimer(0.1, Timer_SupportWeapon_Get, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				pack.WriteCell(EntIndexToEntRef(Prop));
				pack.WriteCell(GetClientUserId(client));
			}
		}
	}
}

stock void Addon_M3_Abilities(int client, int slot)
{
	if(!IsValidClient(client))
		return;
	switch(slot)
	{
		case 1000:DrinkRND(client);
		case 1001:Seeyou_in_HELL(client);
		case 1002:DeployingSupportWeapon(client);
	}
}

stock void Addon_M3_WaveEnd()
{
	return;
}

stock void Addon_M3_ClearAll()
{
	Zero(b_OneDown);
	ZeroFloat(f_SupportWeapon_Timer);
	return;
}
static void DeployingSupportWeapon(int client)
{
	float GameTime = GetGameTime();
	float cooldown = M3_Ability_Cooldown(client);
	if(CvarInfiniteCash.BoolValue)
		cooldown=0.0;
	if(cooldown > GameTime)
	{
		float Ability_CD = cooldown - GameTime;

		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;

		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
		return;
	}
	int entity = ThrowTheGrenade(client, b_StickyExtraGrenades[client]);
	if(IsValidEntity(entity))
	{
		M3_Ability_Delay(entity, GameTime + 5.0);
		M3_Ability_Duration(entity, 0.0);
		i_AttacksTillReload[entity]=0;
		DataPack pack;
		CreateDataTimer(0.1, Timer_SupportWeapon_Stratagems, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		pack.WriteCell(EntIndexToEntRef(entity));
		pack.WriteCell(GetClientUserId(client));
		M3_Ability_Cooldown(client, GameTime + (300.0 * CooldownReductionAmount(client)));
	}
}

static Action Timer_SupportWeapon_Stratagems(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int client = GetClientOfUserId(pack.ReadCell());
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		if(IsValidClient(client))
		{
			float position[3], Laserpos[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
			
			EmitSoundToAll("ambient/energy/weld1.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, position);
			Laserpos[0] = position[0];
			Laserpos[1] = position[1];
			Laserpos[2] = position[2] + 1500.0;
			
			TE_SetupBeamPoints(Laserpos, position, g_iLaserMaterial_Trace, -1, 0, 0, 0.1, 0.1, 25.0, 0, 0.0, {0, 150, 255, 150}, 3);
			TE_SendToAll();
			Laserpos[2] -= 1490.0;
			TE_SetupGlowSprite(Laserpos, g_BluePoint, 0.1, 1.0, 150);
			TE_SendToAll();
			if(M3_Ability_Delay(entity) < GetGameTime())
			{
				switch(i_AttacksTillReload[entity])
				{
					case 1:
					{
						Drop_Prop(client, position, 2000.0, "ZR_SupportWeaponPOD_", "models/props_urban/urban_crate002.mdl");
						EmitSoundToAll("weapons/air_burster_explode3.wav", 0, SNDCHAN_AUTO, SNDLEVEL_TRAIN, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, position);
						i_AttacksTillReload[entity]=2;
					}
					default:
					{
						i_AttacksTillReload[entity]++;
					}
				}
   			}
   			if(i_AttacksTillReload[entity]>=2)
   			{
   				RemoveEntity(entity);
   				return Plugin_Stop;	
   			}
   			return Plugin_Continue;	
		}
		else
		{
			return Plugin_Stop;	
		}
	}
	else
	{
		return Plugin_Stop;	
	}
}

static Action Timer_SupportWeapon_Get(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int client = GetClientOfUserId(pack.ReadCell());
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		if(IsValidClient(client))
		{
			float position[3], position2[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
			for(int target=1; target<=MaxClients; target++)
			{
				if(IsValidClient(target) && IsPlayerAlive(target) && TeutonType[target] == TEUTON_NONE)
				{
					if(i_ClientHasCustomGearEquipped[target]!=CUSTOMGEAR_NONE)
						continue;
					GetEntPropVector(target, Prop_Send, "m_vecOrigin", position2);
					float distance = GetVectorDistance(position, position2, true);
					if(distance<=2500.0)
					{
						int RNDSupportWeapons=GetRandomInt(0, 2);
						int SupportWeapon = Store_GiveSpecificItem(target, SupportWeaponList[RNDSupportWeapons]);
						if(IsValidEntity(SupportWeapon))
						{
							if(Store_HasNamedItem(client, "Accurate Marksman"))
							{
								Attributes_SetMulti(SupportWeapon, 106, 0.9);
								Attributes_SetMulti(SupportWeapon, 103, 1.2);
							}
							if(Store_HasNamedItem(client, "Ammo Coat"))
								Attributes_SetMulti(SupportWeapon, 2, 1.5);
							if(Store_HasNamedItem(client, "Compacted Rounds"))
							{
								Attributes_SetMulti(SupportWeapon, 6, 0.87);
								Attributes_SetMulti(SupportWeapon, 97, 0.87);
								Attributes_SetMulti(SupportWeapon, 4, 1.25);
							}
							if(Store_HasNamedItem(client, "Ammo Coat Elite"))
								Attributes_SetMulti(SupportWeapon, 2, 1.6);
							if(Store_HasNamedItem(client, "Antidote Coated Bullets"))
								Attributes_SetMulti(SupportWeapon, 2, 1.6);
							if(Store_HasNamedItem(client, "Anti-Matter Bullets"))
								Attributes_SetMulti(SupportWeapon, 2, 1.65);
							if(Store_HasNamedItem(client, "Expidonsan's Black hole Storage Unit"))
							{
								Attributes_SetMulti(SupportWeapon, 2, 1.6);
								Attributes_SetMulti(SupportWeapon, 6, 0.87);
								Attributes_SetMulti(SupportWeapon, 97, 0.87);
								Attributes_SetMulti(SupportWeapon, 4, 1.25);
							}
							if(Store_HasNamedItem(client, "Birdeye Ammo"))
							{
								Attributes_SetMulti(SupportWeapon, 2, 1.75);
								Attributes_SetMulti(SupportWeapon, 106, 0.9);
								Attributes_SetMulti(SupportWeapon, 103, 1.1);
								Attributes_SetMulti(SupportWeapon, 6, 0.95);
								Attributes_SetMulti(SupportWeapon, 97, 0.95);
							}
							if(Store_HasNamedItem(client, "Waldch's Railgun Rounds"))
							{
								Attributes_SetMulti(SupportWeapon, 2, 1.75);
								Attributes_SetMulti(SupportWeapon, 106, 0.8);
								Attributes_SetMulti(SupportWeapon, 103, 1.25);
								Attributes_SetMulti(SupportWeapon, 6, 0.925);
								Attributes_SetMulti(SupportWeapon, 97, 0.9);
							}
							if(Store_HasNamedItem(client, "Cheesy Doomsday Pack"))
							{
								Attributes_SetMulti(SupportWeapon, 2, 2.0);
								Attributes_SetMulti(SupportWeapon, 106, 0.65);
								Attributes_SetMulti(SupportWeapon, 103, 1.5);
								Attributes_SetMulti(SupportWeapon, 6, 0.85);
								Attributes_SetMulti(SupportWeapon, 97, 0.85);
							}
							i_ClientHasCustomGearEquipped[target] = CUSTOMGEAR_SUPPORT_WEAPON;
							if(RNDSupportWeapons!=1)
							{
								DataPack pack2 = new DataPack();
								CreateDataTimer(0.5, Timer_SupportWeapon_ClipFullUp, pack2, TIMER_FLAG_NO_MAPCHANGE);
								pack2.WriteCell(EntIndexToEntRef(SupportWeapon));
								pack2.WriteCell(GetClientUserId(target));
								Clip_GiveWeaponClipFullUp(target, SupportWeapon);
							}
						}
						SetAmmo(target, 1, 9999);
						SetAmmo(target, 2, 9999);
						RemoveEntity(entity);
						f_SupportWeapon_Timer[target] =  GetGameTime() + 50.0;
						ApplyStatusEffect(target, target, "Support Weapon License", 9999.9);
						return Plugin_Stop;	
					}
				}
			}
   			if(M3_Ability_Duration(entity) < GetGameTime())
   			{
   				RemoveEntity(entity);
   				return Plugin_Stop;	
   			}
   			return Plugin_Continue;	
		}
		else
		{
   			RemoveEntity(entity);
			return Plugin_Stop;	
		}
	}
	else
	{
		return Plugin_Stop;	
	}
}

static Action Timer_SupportWeapon_ClipFullUp(Handle timer, DataPack pack)
{
	pack.Reset();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	int client = GetClientOfUserId(pack.ReadCell());
	if(!IsValidEntity(client)|| !IsValidEntity(weapon))
		return Plugin_Handled;
	
	Clip_GiveWeaponClipFullUp(client, weapon);
	return Plugin_Continue;
}

stock float GetSupportWeaponTimer(int client)
{
	return f_SupportWeapon_Timer[client] - GetGameTime();
}

static void Seeyou_in_HELL(int client)
{
	float GameTime = GetGameTime();
	float cooldown = M3_Ability_Cooldown(client);
	if(CvarInfiniteCash.BoolValue)
		cooldown=0.0;
	if(dieingstate[client] > 0)
	{
		if(cooldown > GameTime)
		{
			float Ability_CD = cooldown - GameTime;

			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;

			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
			return;
		}
		if(b_OneDown[client])
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Already Used");
			return;
		}
		M3_Ability_Cooldown(client, GameTime + (10.0 * CooldownReductionAmount(client)));
		b_OneDown[client]=true;
		
		float clientpos[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", clientpos);
		EmitSoundToAll("weapons/air_burster_explode3.wav", 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 0.8, SNDPITCH_NORMAL, -1, clientpos);
		spawnRing_Vectors(clientpos, 0.0, 0.0, 0.0, 0.0, LASERBEAM, 145, 47, 47, 200, 1, 1.0, 3.0, 1.0, 3, 650.0);
		SpawnSmallExplosion(clientpos);
		MakePlayerGiveResponseVoice(client, 4);
		Explode_Logic_Custom(0.0, client, client, -1, clientpos, 650.0, _, _, true, _, false, _, KamikazeBoomb);
		CreateTimer(0.1, Timer_Seeyou_in_HELL_Reload, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Use Only Down");
	}
}

static void KamikazeBoomb(int entity, int victim, float damage, int weapon)
{
	if(IsValidEntity(entity) && IsValidEntity(victim) && GetTeam(entity) != GetTeam(victim) && Can_I_See_Enemy(entity, victim))
	{
		FreezeNpcInTime(victim, (b_thisNpcIsARaid[victim] || b_thisNpcIsABoss[victim] ? 1.0 : 3.0), true);
		ApplyStatusEffect(entity, victim, "Silenced", (b_thisNpcIsARaid[victim] || b_thisNpcIsABoss[victim] ? 1.0 : 3.0));
		ApplyStatusEffect(entity, victim, "Teslar Shock", (b_thisNpcIsARaid[victim] || b_thisNpcIsABoss[victim] ? 1.0 : 3.0));
		float MaxHealth = float(ReturnEntityMaxHealth(victim));
		damage=(MaxHealth*0.01)+(Pow(float(CashSpentTotal[entity]), 1.18)/9.0);
		SDKHooks_TakeDamage(victim, entity, entity, damage, DMG_BLAST|DMG_PREVENT_PHYSICS_FORCE);
	}
}
static void PodKill(int entity, int victim, float damage, int weapon)
{
	if(IsValidEntity(entity) && IsValidEntity(victim) && GetTeam(entity) != GetTeam(victim) && Can_I_See_Enemy(entity, victim))
	{
		float MaxHealth = float(ReturnEntityMaxHealth(victim));
		damage=(MaxHealth*2.0);
		if(b_thisNpcIsARaid[victim] || b_thisNpcIsABoss[victim] || b_IsGiant[victim])
			damage=(MaxHealth*0.05)+(Pow(float(CashSpentTotal[entity]), 1.18)/10.0);
		SDKHooks_TakeDamage(victim, entity, entity, damage, DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE);
	}
}

static Action Timer_Seeyou_in_HELL_Reload(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if(IsValidClient(client))
	{
		if(dieingstate[client] <= 0 || TeutonType[client] != TEUTON_NONE || !IsPlayerAlive(client))
		{
			b_OneDown[client]=false;
			return Plugin_Stop;
		}
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

static void DrinkRND(int client, int Overrides=-1)
{
	float cooldown=M3_Ability_Cooldown(client);
	float GameTime = GetGameTime();
	if(cooldown < GameTime || Overrides!=-1 || CvarInfiniteCash.BoolValue)
	{
		EmitSoundToAll("player/pl_scout_dodge_can_drink.wav", client, SNDCHAN_STATIC, 70, _, 0.9);
		if(Overrides==-1)
			M3_Ability_Cooldown(client, GameTime + (30.0 * CooldownReductionAmount(client)));
		int GetRND=Overrides;
		if(GetRND==-1) GetRND=GetRandomInt(1, 21);
		float AddTime;
		char RNDDrinkName[512];
		FormatEx(RNDDrinkName, sizeof(RNDDrinkName), "Get_DrinkRND_%i", GetRND);
		if(TranslationPhraseExists(RNDDrinkName))
		{
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", RNDDrinkName);
		}
		else PrintToChat(client, "[%i] No Translation?", GetRND);
		switch(GetRND)
		{
			case 5:
			{
				SetEntityHealth(client, 1);
				return;
			}
			case 6:
			{
				ApplyStatusEffect(client, client, "Defensive Backup", 30.0);
				ApplyStatusEffect(client, client, "War Cry", 30.0);
				ApplyStatusEffect(client, client, "Ancient Melodies", 30.0);
				return;
			}
			case 8:
			{
				TF2_StunPlayer(client, 30.0, 0.5, TF_STUNFLAG_NOSOUNDOREFFECT|TF_STUNFLAG_SLOWDOWN, client);
				return;
			}
			case 9:
			{
				TF2_RemoveCondition(client, TFCond_UberchargedCanteen);
				TF2_AddCondition(client, TFCond_UberchargedCanteen, 10.0);
				ApplyStatusEffect(client, client, "Intangible", 10.0);
				ApplyStatusEffect(client, client, "Fluid Movement", 10.0);
				ApplyStatusEffect(client, client, "Solid Stance", 10.0);
				return;
			}
			case 10:
			{
				int health = GetClientHealth(client);
				float WorldSpaceVec[3]; WorldSpaceCenter(client, WorldSpaceVec);
				TimedLgtning(client, WorldSpaceVec);
				if(!IsInvuln(client))
					SDKHooks_TakeDamage(client, 0, 0, float(health/2), DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE);
				if(!HasSpecificBuff(client, "Solid Stance"))
				{
					SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime() + 5.0);
					ApplyStatusEffect(client, client, "Ragdolled", 5.0);
					FreezeNpcInTime(client, 5.0);
				}
				if(!HasSpecificBuff(client, "Fluid Movement"))
				{
					TF2_AddCondition(client, TFCond_LostFooting, 5.0);
					TF2_AddCondition(client, TFCond_AirCurrent, 5.0);
				}
				return;
			}
			case 12:
			{
				float RNGPos[3]; WorldSpaceCenter(client, RNGPos);
				ParticleEffectAt(RNGPos, "teleported_red", 0.5);
				if(PickRandomAreaLoc(client, 500.0, 2048.0, RNGPos))
				{
					Player_Teleport_Safe(client, RNGPos);
					Player_Teleport_Safe(client, RNGPos);
					WorldSpaceCenter(client, RNGPos);
					ParticleEffectAt(RNGPos, "teleported_blue", 0.5);
					EmitSoundToAll(g_TeleSounds[GetRandomInt(0, sizeof(g_TeleSounds) - 1)], client, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
				}
				else
					M3_Ability_Cooldown(client, GameTime + (5.0 * CooldownReductionAmount(client)));
				return;
			}
			case 13:
			{
				ApplyStatusEffect(client, client, "Depot Transfer", 10.0);
				return;
			}
			case 14:
			{
				float WorldSpaceVec[3]; WorldSpaceCenter(client, WorldSpaceVec);
				int entity = NPC_CreateByName("npc_invisible_trigger", client, WorldSpaceVec, {0.0,0.0,0.0}, TFTeam_Stalkers);
				if(entity > MaxClients)
				{
					Ruina_Add_Mana_Sickness(entity, client, 5.0, 100, true);
					Ruina_Add_Mana_Sickness(entity, client, 5.0, 100, true);
					Current_Mana[client]=0;
					SDKhooks_SetManaRegenDelayTime(client, 5.0);
				}
				return;
			}
			case 16:
			{
				float Lvl = 1.0+((float(CashSpentTotal[client])/5000.0)*0.15);
				int SummonNPC=Dimension_Summon_Npc_Parkuri(client, GetRandomInt(1, 11), CashSpentTotal[client]>20000 ? true : false, Lvl, Lvl);
				if(IsValidEntity(SummonNPC))
				{
					float WorldSpaceVec[3]; WorldSpaceCenter(client, WorldSpaceVec);
					EmitSoundToAll(g_PortalSounds, client, SNDCHAN_STATIC, 70, _, 1.2);
					ParticleEffectAt(WorldSpaceVec, "eyeboss_death_vortex", 1.5);
				}
				return;
			}
			case 17:
			{
				ApplyStatusEffect(client, client, "Armor Melt", 20.0);
				return;
			}
			case 18:
			{
				if(Armor_Charge[client] > 0)
				{
					Armor_Charge[client]=0;
					f_Armor_BreakSoundDelay[client] = GameTime + 5.0;	
					EmitSoundToClient(client, "npc/assassin/ball_zap1.wav", client, SNDCHAN_STATIC, 60, _, 1.0, GetRandomInt(95,105));
				}
				return;
			}
			case 19:
			{
				ApplyStatusEffect(client, client, "Eye for an Eye", GetRandomFloat(10.0, 20.0));
				return;
			}
			case 20:
			{
				ApplyStatusEffect(client, client, "Nightmare Terror", GetRandomFloat(10.0, 20.0));
				return;
			}
			case 21:
			{
				ApplyStatusEffect(client, client, "Defibrillator", 20.0);
				return;
			}
			default:AddTime=20.0;
		}
		M3_Ability_Delay(client, 0.0);
		M3_Ability_Duration(client, GameTime + AddTime);
		DataPack pack;
		CreateDataTimer(0.1, Timer_DrinkRND, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		pack.WriteCell(GetClientUserId(client));
		pack.WriteCell(GetRND);
	}
	else
	{
		float Ability_CD = cooldown - GameTime;
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
		
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
	}
}

static Action Timer_DrinkRND(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	int GetRND = pack.ReadCell();
	float Delay = M3_Ability_Delay(client);
	float Duration = M3_Ability_Duration(client);
	float GameTime = GetGameTime();
	if(IsValidClient(client))
	{
		switch(GetRND)
		{
			case 1:
			{
				if(Delay < GameTime)
				{
					GiveArmorViaPercentage(client, 0.075, 1.0);
					Delay=GameTime + 0.2;
				}
			}
			case 2:
			{
				if(Delay < GameTime)
				{
					if(dieingstate[client] > 0)
					{
						if(i_CurrentEquippedPerk[client] == 1)
						{
							SetEntityHealth(client,  GetClientHealth(client) + 12);
							dieingstate[client] -= 20;
						}
						else
						{
							SetEntityHealth(client,  GetClientHealth(client) + 6);
							dieingstate[client] -= 10;
						}
						if(dieingstate[client] < 1)
						{
							dieingstate[client] = 1;
						}
					}
					else
					{
						HealEntityGlobal(client, client, 25.0, 1.0, _, HEAL_SELFHEAL);
					}
					Delay=GameTime + 0.2;
				}
			}
			case 3:
			{
				int health = GetClientHealth(client), selfDMG = 5;
				int safety = health-selfDMG;
				if(health>1)
				{
					if(safety>1)
						AP_TakeDamage(client, _, _, 5.0, DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE);
					else
						SetEntityHealth(client, 1);
				}
			}
			case 4:
			{
				TF2_RemoveCondition(client, TFCond_ObscuredSmoke);
				TF2_AddCondition(client, TFCond_ObscuredSmoke, 1.0);
				TF2_RemoveCondition(client, TFCond_SpeedBuffAlly);
				TF2_AddCondition(client, TFCond_SpeedBuffAlly, 1.0);
				ApplyStatusEffect(client, client, "Caffinated", 2.6);
				ApplyStatusEffect(client, client, "Caffinated Drain", 1.1);
				if(Duration < GameTime)
				{
					TF2_RemoveCondition(client, TFCond_MarkedForDeath);
					TF2_AddCondition(client, TFCond_MarkedForDeath, 10.0);
					TF2_StunPlayer(client, 10.0, 0.9, TF_STUNFLAG_NOSOUNDOREFFECT|TF_STUNFLAG_SLOWDOWN, client);
				}
			}
			case 7:
			{
				if(!TF2_IsPlayerInCondition(client, TFCond_OnFire))
				{
					TF2_IgnitePlayer(client, client, 10.0);
					TF2_AddCondition(client, TFCond_HealingDebuff, 10.0);
				}
				SDKHooks_TakeDamage(client, 0, 0, 4.0, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE);
			}
			case 11:
			{
				float damage = 10.0+(Pow(float(CashSpentTotal[client]), 1.225))/10000.0;
				if(damage<10.0)damage=10.0;
				float position[3]; WorldSpaceCenter(client, position);
				for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
				{
					int npc = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
					if(IsValidEntity(npc) && GetTeam(npc) != TFTeam_Red)
					{
						float position2[3], distance;
						GetEntPropVector(npc, Prop_Send, "m_vecOrigin", position2);
						distance = GetVectorDistance(position, position2);
						if(distance<300.0)
						{
							SDKHooks_TakeDamage(npc, client, client, damage, DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE);
							//NpcStats_SpeedModifyEnemy(npc, 1.0, 0.9, true);
						}
					}
				}
				if(Delay < GameTime)
				{
					position[2] += 50.0;
					float fPos[3], fDir[2];
					for (int i = 0; i < RoundFloat(200.0 / 64.0); ++i)
					{
						float fRadius = GetRandomFloat(170.0, 200.0);

						fDir[0] = GetRandomFloat(0.0, 2.0 * 3.1415); // radians
						fDir[1] = GetRandomFloat(0.0, 2.0 * 3.1415);
						GetPointOnSphere(position, fDir, fRadius, fPos);

						ParticleEffectAt(fPos, "peejar_impact_cloud_gas", 1.0);
					}
					Delay = GameTime + 0.6;
				}
			}
			case 15:
			{
				if(Delay < GameTime)
				{
					Current_Mana[client]=RoundToCeil(max_mana[client]*0.1);
					Delay = GameTime + 0.2;
				}
			}
		}
		if(Duration < GetGameTime() || TeutonType[client] != TEUTON_NONE || !IsPlayerAlive(client))
			return Plugin_Stop;	
		return Plugin_Continue;
	}
	else
		return Plugin_Stop;
}

stock void GetPointOnSphere(const float fOrigin[3], const float fDirectionRads[2], float fRadius, float fOut[3])
{
	fOut[0] = fOrigin[0] + fRadius * Cosine(fDirectionRads[0]) * Sine(fDirectionRads[1]);
	fOut[1] = fOrigin[1] + fRadius * Sine(fDirectionRads[0]) * Sine(fDirectionRads[1]);
	fOut[2] = fOrigin[2] + fRadius * Cosine(fDirectionRads[1]);
}

stock void TimedLgtning(int client, float flPos[3])
{
	float LgtningPos[3];
	
	flPos[2] -= 26.0; // increase y-axis by 26 to strike at player's chest instead of the ground
	
	LgtningPos[0] = flPos[0] + 500.0 + GetRandomFloat(-125.0, 125.0);
	LgtningPos[1] = flPos[1] + 5000.0 + GetRandomFloat(-125.0, 125.0);
	LgtningPos[2] = flPos[2] + 1500.0;
	
	float dir[3] =  { 0.0, 0.0, 0.0 };
	
	TE_SetupBeamPoints(LgtningPos, flPos, LSPR, 0, 0, 0, 0.2, 160.0, 80.0, 0, 50.0, { 255, 255, 255, 255 }, 3);
	TE_SendToAll();
	
	TE_SetupSparks(flPos, dir, 7500, 2500);
	TE_SendToAll();
	
	TE_SetupEnergySplash(flPos, dir, false);
	TE_SendToAll();
	
	EmitAmbientSound("ambient/explosions/explode_9.wav", LgtningPos, client, SNDLEVEL_HELICOPTER);
}

static bool PickRandomAreaLoc(int client, float min, float max, float output[3])
{
	bool Success;
	int AreasCollected = 0;
	float CurrentPoints = 0.0;
	float vecTarget[3]; WorldSpaceCenter(client, vecTarget);
	for(int loop = 1; loop <= 500; loop++)
	{
		CNavArea RandomArea = GetRandomNearbyArea(vecTarget, max);
		if(RandomArea == NULL_AREA)
			break;
		int NavAttribs = RandomArea.GetAttributes();
		if(NavAttribs & NAV_MESH_AVOID)
			continue;
		float vPredictedPos[3]; RandomArea.GetCenter(vPredictedPos);
		vPredictedPos[2] += 1.0;
		
		if(GetVectorDistance(vPredictedPos, vecTarget, true) < (min * min))
			continue;
		
		if(IsPointHazard(vPredictedPos))
			continue;
		if(IsPointHazard(vPredictedPos))
			continue;
			
		static float hullcheckmaxs_Player_Again[3];
		static float hullcheckmins_Player_Again[3];
		
		hullcheckmaxs_Player_Again = view_as<float>( { 24.0, 24.0, 82.0 } );
		hullcheckmins_Player_Again = view_as<float>( { -24.0, -24.0, 0.0 } );	
		
		if(IsPointHazard(vPredictedPos))
			continue;
		
		vPredictedPos[2] += 18.0;
		if(IsPointHazard(vPredictedPos))
			continue;
		
		vPredictedPos[2] -= 18.0;
		vPredictedPos[2] -= 18.0;
		vPredictedPos[2] -= 18.0;
		if(IsPointHazard(vPredictedPos))
			continue;
		vPredictedPos[2] += 18.0;
		vPredictedPos[2] += 18.0;
		
		if(IsSpaceOccupiedIgnorePlayers(vPredictedPos, hullcheckmins_Player_Again, hullcheckmaxs_Player_Again, client) || IsSpaceOccupiedOnlyPlayers(vPredictedPos, hullcheckmins_Player_Again, hullcheckmaxs_Player_Again, client))
			continue;
		float Accumulated_Points;
		for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
		{
			int GetNPC = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
			if(IsValidEntity(GetNPC) && !b_NpcHasDied[GetNPC] && GetTeam(GetNPC) != TFTeam_Red)
			{
				float f3_PositionTemp[3];
				WorldSpaceCenter(GetNPC, f3_PositionTemp);
				float distance = GetVectorDistance( f3_PositionTemp, vPredictedPos, true); 
				//leave it all squared for optimsation sake!
				float inverting_score_calc;

				inverting_score_calc = ( distance / 100000000.0);

				Accumulated_Points += inverting_score_calc;
			}
		}
		if(Accumulated_Points > CurrentPoints)
		{
			vPredictedPos[2] -= 20.0;
			output = vPredictedPos;
			CurrentPoints = Accumulated_Points;
		}
		AreasCollected += 1;
		if(AreasCollected >= MAXTRIESVILLAGER)
		{
			if(vPredictedPos[0])
			{
				output=vPredictedPos;
				Success=true;
				break;
			}
		}
	}
	return Success;
}

static int Dimension_Summon_Npc_Parkuri(int client, int SetWave, bool Elite=false, float HealthMulti=1.0, float DamageMulti=1.0)
{
	int WhoIsNPC=GetRandomInt(1, (Elite ? 6 : 5));
	float Dimension_Loc[3]; WorldSpaceCenter(client, Dimension_Loc);
	switch(SetWave)
	{
		case 1: //Almina
		{
			switch(WhoIsNPC)
			{
				case 1:
				{
					WhoIsNPC=NPC_CreateByName("npc_speedus_instantus", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.2;
					DamageMulti*=1.3;
				}
				case 2: 
				{
					WhoIsNPC=NPC_CreateByName("npc_almina_morato", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					DamageMulti*=1.4;
				}
				case 3: 
				{
					WhoIsNPC=NPC_CreateByName("npc_sea_xploder", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.1;
					DamageMulti*=1.4;
				}
				case 4: 
				{
					WhoIsNPC=NPC_CreateByName("npc_kumbai", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.2;
					DamageMulti*=1.3;
				}
				case 5: 
				{
					WhoIsNPC=NPC_CreateByName("npc_inqusitor_iidutas", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.5;
					DamageMulti*=1.2;
				}
				default: 
				{
					WhoIsNPC=NPC_CreateByName("npc_anti_sea_robot", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.75;
					DamageMulti*=0.5;
				}
			}
		}
		case 2: //Void
		{
			switch(WhoIsNPC)
			{
				case 1:
				{
					WhoIsNPC=NPC_CreateByName("npc_blood_pollutor", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.3;
					DamageMulti*=1.2;
				}
				case 2: 
				{
					WhoIsNPC=NPC_CreateByName("npc_voided_expidonsan_fortifier", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.0;
					DamageMulti*=1.2;
				}
				case 3: 
				{
					WhoIsNPC=NPC_CreateByName("npc_growing_exat", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.5;
					DamageMulti*=1.2;
				}
				case 4: 
				{
					WhoIsNPC=NPC_CreateByName("npc_void_sprayer", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.2;
					DamageMulti*=1.4;
				}
				case 5: 
				{
					WhoIsNPC=NPC_CreateByName("npc_void_ixufan", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.75;
					DamageMulti*=1.2;
				}
				default: 
				{
					WhoIsNPC=NPC_CreateByName("npc_void_total_growth", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.5;
					DamageMulti*=1.3;
				}
			}
		}
		case 3: //Twirl
		{
			switch(WhoIsNPC)
			{
				case 1:
				{
					WhoIsNPC=NPC_CreateByName("npc_ruina_laniun", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.2;
					DamageMulti*=1.3;
				}
				case 2: 
				{
					WhoIsNPC=NPC_CreateByName("npc_ruina_astriana", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.2;
					DamageMulti*=1.4;
				}
				case 3: 
				{
					WhoIsNPC=NPC_CreateByName("npc_ruina_ruianus", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.3;
					DamageMulti*=1.2;
				}
				case 4: 
				{
					WhoIsNPC=NPC_CreateByName("npc_ruina_heliara", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.3;
					DamageMulti*=1.3;
				}
				case 5: 
				{
					WhoIsNPC=NPC_CreateByName("npc_ruina_lex", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.7;
					DamageMulti*=1.4;
				}
				default: 
				{
					WhoIsNPC=NPC_CreateByName("npc_ruina_lancelot", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.7;
					DamageMulti*=1.4;
				}
			}
		}
		case 4: //Interitus
		{
			switch(WhoIsNPC)
			{
				case 1:
				{
					WhoIsNPC=NPC_CreateByName("npc_khazaan", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.1;
					DamageMulti*=1.2;
				}
				case 2: 
				{
					WhoIsNPC=NPC_CreateByName("npc_yadeam", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					DamageMulti*=1.4;
				}
				case 3: 
				{
					WhoIsNPC=NPC_CreateByName("npc_freezing_cleaner", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.1;
					DamageMulti*=1.3;
				}
				case 4: 
				{
					WhoIsNPC=NPC_CreateByName("npc_airborn_explorer", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.3;
					DamageMulti*=1.5;
				}
				case 5: 
				{
					WhoIsNPC=NPC_CreateByName("npc_irritated_person", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.6;
					DamageMulti*=1.3;
				}
				default: 
				{
					WhoIsNPC=NPC_CreateByName("npc_braindead", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.1;
					DamageMulti*=1.4;
				}
			}
		}
		case 5: //Expidonsa
		{
			switch(WhoIsNPC)
			{
				case 1:
				{
					WhoIsNPC=NPC_CreateByName("npc_dualrea", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.1;
					DamageMulti*=1.2;
				}
				case 2: 
				{
					WhoIsNPC=NPC_CreateByName("npc_protecta", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.4;
					DamageMulti*=1.1;
				}
				case 3: 
				{
					WhoIsNPC=NPC_CreateByName("npc_rifal_manu", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.0;
					DamageMulti*=1.5;
				}
				case 4: 
				{
					WhoIsNPC=NPC_CreateByName("npc_sergeant_ideal", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=2.0;
					DamageMulti*=1.3;
				}
				case 5: 
				{
					WhoIsNPC=NPC_CreateByName("npc_vaus_magica", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.2;
					DamageMulti*=1.3;
				}
				default: 
				{
					WhoIsNPC=NPC_CreateByName("npc_soldine", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.4;
					DamageMulti*=1.4;
				}
			}
		}
		case 6: //Dweller
		{
			switch(WhoIsNPC)
			{
				case 1:
				{
					WhoIsNPC=NPC_CreateByName("npc_abysspredator", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.0;
					DamageMulti*=1.3;
				}
				case 2: 
				{
					WhoIsNPC=NPC_CreateByName("npc_abyssreefbreaker", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.3;
					DamageMulti*=1.2;
				}
				case 3: 
				{
					WhoIsNPC=NPC_CreateByName("npc_abyssspewer", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.0;
					DamageMulti*=1.5;
				}
				case 4: 
				{
					WhoIsNPC=NPC_CreateByName("npc_dweller_grunwald_beserker", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.6;
					DamageMulti*=1.3;
				}
				case 5: 
				{
					WhoIsNPC=NPC_CreateByName("npc_abyssswarmcaller", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.0;
					DamageMulti*=1.3;
				}
				default: 
				{
					WhoIsNPC=NPC_CreateByName("npc_dwellerhybrid", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.8;
					DamageMulti*=1.75;
				}
			}
		}
		case 7: //Medeival
		{
			switch(WhoIsNPC)
			{
				case 1:
				{
					WhoIsNPC=NPC_CreateByName("npc_medival_swordsman", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.3;
					DamageMulti*=1.1;
				}
				case 2: 
				{
					WhoIsNPC=NPC_CreateByName("npc_medival_crossbow", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					DamageMulti*=1.5;
				}
				case 3: 
				{
					WhoIsNPC=NPC_CreateByName("npc_medival_brawler", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.2;
					DamageMulti*=1.3;
				}
				case 4: 
				{
					WhoIsNPC=NPC_CreateByName("npc_medival_construct", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.5;
					DamageMulti*=1.2;
				}
				case 5: 
				{
					WhoIsNPC=NPC_CreateByName("npc_medival_light_cav", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.2;
					DamageMulti*=1.3;
				}
				default: 
				{
					if(GetRandomInt(0, 100)>=80)
					{
						WhoIsNPC=NPC_CreateByName("npc_medival_man_at_arms", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
						HealthMulti*=5.5;
						DamageMulti*=3.0;
					}
					else
					{
						WhoIsNPC=NPC_CreateByName("npc_medival_son_of_osiris", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
						HealthMulti*=1.5;
						DamageMulti*=1.0;
					}
				}
			}
		}
		case 8: //Xeno
		{
			switch(WhoIsNPC)
			{
				case 1:
				{
					WhoIsNPC=NPC_CreateByName("npc_xeno_combine_soldier_shotgun", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.2;
					DamageMulti*=1.5;
				}
				case 2: 
				{
					WhoIsNPC=NPC_CreateByName("npc_xeno_combine_soldier_giant_swordsman", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.5;
					DamageMulti*=1.3;
				}
				case 3: 
				{
					WhoIsNPC=NPC_CreateByName("npc_xeno_zombie_soldier_grave", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.1;
					DamageMulti*=1.4;
				}
				case 4: 
				{
					WhoIsNPC=NPC_CreateByName("npc_xeno_last_survivor", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.75;
					DamageMulti*=1.6;
				}
				case 5: 
				{
					WhoIsNPC=NPC_CreateByName("npc_xeno_poisonzombie_fortified_giant", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.5;
					DamageMulti*=1.3;
				}
				default: 
				{
					WhoIsNPC=NPC_CreateByName("npc_xeno_spy_trickstabber", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.3;
					DamageMulti*=1.2;
				}
			}
		}
		case 9: //Blitz
		{
			switch(WhoIsNPC)
			{
				case 1:
				{
					WhoIsNPC=NPC_CreateByName("npc_alt_mecha_soldier_barrager", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.2;
					DamageMulti*=1.4;
				}
				case 2: 
				{
					WhoIsNPC=NPC_CreateByName("npc_alt_medic_charger", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.3;
					DamageMulti*=1.2;
				}
				case 3: 
				{
					WhoIsNPC=NPC_CreateByName("npc_alt_sniper_railgunner", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.0;
					DamageMulti*=1.5;
				}
				case 4: 
				{
					WhoIsNPC=NPC_CreateByName("npc_alt_medic_supperior_mage", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.5;
					DamageMulti*=1.3;
				}
				case 5: 
				{
					WhoIsNPC=NPC_CreateByName("npc_alt_mecha_scout", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.2;
					DamageMulti*=1.3;
				}
				default: 
				{
					WhoIsNPC=NPC_CreateByName("npc_alt_schwertkrieg", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.3;
					DamageMulti*=1.0;
				}
			}
		}
		case 10: //Normal
		{
			switch(WhoIsNPC)
			{
				case 1:
				{
					WhoIsNPC=NPC_CreateByName("npc_headcrabzombie_fortified", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.3;
					DamageMulti*=1.2;
				}
				case 2: 
				{
					WhoIsNPC=NPC_CreateByName("npc_pental", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.3;
					DamageMulti*=1.2;
				}
				case 3: 
				{
					WhoIsNPC=NPC_CreateByName("npc_alt_combine_soldier_mage", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.0;
					DamageMulti*=1.5;
				}
				case 4: 
				{
					WhoIsNPC=NPC_CreateByName("npc_combine_police_smg", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.2;
					DamageMulti*=1.4;
				}
				case 5: 
				{
					WhoIsNPC=NPC_CreateByName("npc_kamikaze_demo", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=0.5;
					DamageMulti*=2.5;
				}
				default: 
				{
					WhoIsNPC=NPC_CreateByName("npc_spy_boss", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.75;
					DamageMulti*=1.0;
				}
			}
		}
		case 11: //Vesta
		{
			switch(WhoIsNPC)
			{
				case 1:
				{
					WhoIsNPC=NPC_CreateByName("npc_ballista", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.1;
					DamageMulti*=1.3;
				}
				case 2: 
				{
					WhoIsNPC=NPC_CreateByName("npc_bulldozer", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.5;
					DamageMulti*=1.0;
				}
				case 3: 
				{
					WhoIsNPC=NPC_CreateByName("npc_scorcher", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.5;
					DamageMulti*=0.9;
				}
				case 4: 
				{
					WhoIsNPC=NPC_CreateByName("npc_shotgunner", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=1.2;
					DamageMulti*=1.2;
				}
				case 5: 
				{
					WhoIsNPC=NPC_CreateByName("npc_vesta_anvil", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red);
					HealthMulti*=0.5;
					DamageMulti*=1.5;
					if(WhoIsNPC > MaxClients)
						b_ThisEntityIgnored[WhoIsNPC] = true;
				}
				default: 
				{
					WhoIsNPC=NPC_CreateByName("npc_avangard", client, Dimension_Loc, {0.0,0.0,0.0}, TFTeam_Red, "only imcomplete");
					HealthMulti*=1.75;
					DamageMulti*=1.0;
				}
			}
		}
	}
	if(WhoIsNPC > MaxClients)
	{
		float f_MaxHealth = 100.0;
		f_MaxHealth *= HealthMulti;
		f_MaxHealth *= 1.1;
		SetEntProp(WhoIsNPC, Prop_Data, "m_iHealth", RoundToNearest(f_MaxHealth));
		SetEntProp(WhoIsNPC, Prop_Data, "m_iMaxHealth", RoundToNearest(f_MaxHealth));
		fl_MeleeArmor[WhoIsNPC] = 1.0;
		fl_RangedArmor[WhoIsNPC] = 1.0;
		DamageMulti *= 0.9;
		fl_Extra_Damage[WhoIsNPC] *= DamageMulti;
		CreateTimer(60.0, Dimension_KillNPC, EntIndexToEntRef(WhoIsNPC), TIMER_FLAG_NO_MAPCHANGE);
		i_NpcOverrideAttacker[WhoIsNPC] = EntIndexToEntRef(client);
		b_IsCamoNPC[WhoIsNPC] = false;
		b_thisNpcIsABoss[WhoIsNPC] = false;
		b_thisNpcIsARaid[WhoIsNPC] = false;
		b_ShowNpcHealthbar[WhoIsNPC] = true;
		if(EntRefToEntIndex(RaidBossActive) == WhoIsNPC)
			RaidBossActive = INVALID_ENT_REFERENCE;
		return WhoIsNPC;
	}
	return -1;
}

static int ThrowTheGrenade(int client, bool IsSticky=false, float speed=1500.0)
{
	int entity;		
	if(IsSticky)
		entity = CreateEntityByName("tf_projectile_pipe_remote");
	else
		entity = CreateEntityByName("tf_projectile_pipe");

	if(IsValidEntity(entity))
	{
		SetEntitySpike(entity, 3);
		b_StickyIsSticking[entity] = true; //Make them not stick to npcs.
		static float pos[3], ang[3], vel_2[3];
		GetClientEyeAngles(client, ang);
		GetClientEyePosition(client, pos);	
	
		ang[0] -= 8.0;
		
		vel_2[0] = Cosine(DegToRad(ang[0]))*Cosine(DegToRad(ang[1]))*speed;
		vel_2[1] = Cosine(DegToRad(ang[0]))*Sine(DegToRad(ang[1]))*speed;
		vel_2[2] = Sine(DegToRad(ang[0]))*speed;
		vel_2[2] *= -1;
		
		int team = GetClientTeam(client);
		
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(entity, Prop_Send, "m_iTeamNum", team, 1);
		SetEntProp(entity, Prop_Send, "m_nSkin", (team-2));
		SetEntPropFloat(entity, Prop_Send, "m_flDamage", 0.0); 
		SetEntPropEnt(entity, Prop_Send, "m_hThrower", client);
		SetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher", 0);
		if(IsSticky)
			SetEntProp(entity, Prop_Send, "m_iType", 1);

		for(int i; i<4; i++)
		{
			SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_ProjectileModelArmor, _, i);
		}
		
		SetVariantInt(team);
		AcceptEntityInput(entity, "TeamNum", -1, -1, 0);
		SetVariantInt(team);
		AcceptEntityInput(entity, "SetTeam", -1, -1, 0); 
		
		SetEntPropEnt(entity, Prop_Send, "m_hLauncher", EntRefToEntIndex(i_StickyAccessoryLogicItem[client]));
		//Make them barely bounce at all.
		DispatchSpawn(entity);
		TeleportEntity(entity, pos, ang, vel_2);
		
		IsCustomTfGrenadeProjectile(entity, 9999999.0);
		view_as<CClotBody>(entity).m_bThisEntityIgnored = true;
		
		SetEntProp(entity, Prop_Data, "m_nNextThinkTick", -1);
		return entity;
	}
	return -1;
}