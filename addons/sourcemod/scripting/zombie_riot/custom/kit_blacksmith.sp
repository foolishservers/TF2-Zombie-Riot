#pragma semicolon 1
#pragma newdecls required

#define TINKER_LIMIT	4

enum struct TinkerEnum
{
	int AccountId;
	int StoreIndex;
	int Attrib[TINKER_LIMIT];
	float Value[TINKER_LIMIT];
	float Luck[TINKER_LIMIT];
	char Name[128];
	int Rarity;
	bool Addition[TINKER_LIMIT];
	int CustomMode[TINKER_LIMIT];
}

static const char Enchant_Mage[][] =
{
	"1",
	"2",
	"3",
	"4"
};
static const char Enchant_Mediguns[][] =
{
	"5",
	"6",
	"7",
};
static const char Enchant_Healings[][] =
{
	"8",
	"9"
};
static const char Enchant_Wrench[][] =
{
	"10",
	"11"
};
static const char Enchant_Melee[][] =
{
	"12",
	"13",
	"14",
	"15"
};
static const char Enchant_Melee_InfiniteFire[][] =
{
	"13",
	"16",
	"17",
	"18"
};
static const char Enchant_Melee_Fire[][] =
{
	"13",
	"16",
	"17",
	"19",
	"20",
	"18",
	"21"
};
static const char Enchant_Range_InfiniteFire[][] =
{
	"13",
	"18",
	"22"
};
static const char Enchant_Flamethrower[][] =
{
	"13",
	"18",
	"21"
};
static const char Enchant_Range[][] =
{
	"13",
	"19",
	"20",
	"18",
	"21",
	"22"
};
static const char Enchant_Boomerang[][] =
{
	"13",
	"18",
	"16",
	"17"
};
static const char Enchant_SigilBlade[][] =
{
	"1",
	"2",
	"4"
};
static const char Enchant_MinecraftSword[][] =
{
	"23",
	"24",
	"25",
	"26",
	"27",
	"28",
	"29"
};
static const char Enchant_SniperRifle[][] =
{
	"30",
	"31",
	"32",
	"33",
	"34",
	"35"
};
static const char Enchant_DMR[][] =
{
	"30",
	"31",
	"19",
	"20",
	"34",
	"35",
	"21"
};

static bool EnchantRefresh[MAXENTITIES];
static int SaveRarity[MAXENTITIES][TINKER_LIMIT];
static char Enchant[MAXENTITIES][TINKER_LIMIT][64];

static const int SupportBuildings[] = { 2, 2, 5, 9, 14, 14, 15 };
static const int MetalGain[] = { 0, 5, 8, 11, 15, 20, 35 };
static const float Cooldowns[] = { 150.0, 130.0, 110.0, 90.0, 70.0, 50.0, 30.0 };
static int SmithLevel[MAXPLAYERS] = {-1, ...};
static int i_AdditionalSupportBuildings[MAXPLAYERS] = {0, ...};

static int i_TinkerTracerIndex;

static int ParticleRef[MAXPLAYERS] = {-1, ...};
static Handle EffectTimer[MAXPLAYERS];
static bool AggressiveRanger[MAXPLAYERS];

static ArrayList Tinkers;

void Blacksmith_RoundStart()
{
	Zero(i_AdditionalSupportBuildings);
	Zero(AggressiveRanger);
	delete Tinkers;
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

bool Blacksmith_HasTinker(int client, int index)
{
	if(Tinkers)
	{
		int account = GetSteamAccountID(client, false);
		if(account)
		{
			static TinkerEnum tinker;
			int length = Tinkers.Length;
			for(int a; a < length; a++)
			{
				Tinkers.GetArray(a, tinker);
				if(tinker.AccountId == account && tinker.StoreIndex == index)
					return true;
			}
		}
	}
	
	return false;
}

void Blacksmith_ExtraDesc(int client, int index)
{
	if(Tinkers)
	{
		if(!Blacksmith_Any_IsASmith())
		{
			CPrintToChat(client, "{crimson} %t" , "No Tinker Left");
			return;
		}
		int account = GetSteamAccountID(client, false);
		if(account)
		{
			static TinkerEnum tinker;
			int length = Tinkers.Length;
			for(int a; a < length; a++)
			{
				Tinkers.GetArray(a, tinker);
				if(tinker.AccountId == account && tinker.StoreIndex == index)
				{
					SetGlobalTransTarget(client);
					char buffer[128];
					FormatEx(buffer, sizeof(buffer), "%s", tinker.Name);
					if(TranslationPhraseExists(buffer))
						CPrintToChat(client, "{yellow}%t (Tier %d)", buffer, tinker.Rarity + 1);
					else
					{
						CPrintToChat(client, "{yellow}%s (Tier %d)", buffer, tinker.Rarity + 1);
						CPrintToChat(client, "{crimson}[Dev Warning] Translation not found");
					}
					
					for(int b; b < sizeof(tinker.Attrib); b++)
					{
						if(!tinker.Attrib[b])
							break;
						
						Blacksmith_PrintAttribValue(client, tinker.Attrib[b], tinker.Value[b], tinker.Luck[b],  tinker.Addition[b], tinker.CustomMode[b]);
					}

					break;
				}
			}
		}
	}
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

	if(Tinkers)
	{
		if(!Blacksmith_Any_IsASmith())
			return;
		DetectWeaponNoTinker(weapon, client);
		int account = GetSteamAccountID(client, false);
		if(account)
		{
			static TinkerEnum tinker;
			int length = Tinkers.Length;
			for(int a; a < length; a++)
			{
				Tinkers.GetArray(a, tinker);
				if(tinker.AccountId == account && tinker.StoreIndex == StoreWeapon[weapon])
				{
					ApplyStatusEffect(weapon, weapon, "Tinkering Curiosity", 99999999.9);
					for(int b; b < sizeof(tinker.Attrib); b++)
					{
						if(!tinker.Attrib[b])
							break;
						
						Attributes_SetMulti(weapon, tinker.Attrib[b], tinker.Value[b]);
					}

					break;
				}
			}
		}
	}
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
	
	FinishLagCompensation_Base_boss();
	
	CalcCorrectWeaponShootPosition({ 60.9, 13.1, -15.1 }, pos, ang);
	TE_SetupBeamPoints(pos, hitPos, i_TinkerTracerIndex, 0, 0, 0, 0.3, 3.0, 3.0, 0, 0.0, {255, 255, 255, 255}, 3);
	TE_SendToAll(0.0);
}

/*
public void Weapon_Blacksmith_ShootBullet(int client, int weapon, bool crit, int slot)
{
	float pos[3], ang[3];
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, ang);
	
	float hitPos[3];
	
	bool headshot;
	int target = -1;
	
	b_LagCompNPC_ExtendBoundingBox = true;
	StartLagCompensation_Base_Boss(client);
	
	Handle trace = TR_TraceRayFilterEx(pos, ang, MASK_SHOT, RayType_Infinite, Blacksmith_BulletTrace, client);
	
	TR_GetEndPosition(hitPos, trace);
	
	if(TR_DidHit(trace))
	{
		target = TR_GetEntityIndex(trace);
		if(target > 0)
		{
			headshot = (TR_GetHitGroup(trace) == HITGROUP_HEAD && !b_CannotBeHeadshot[target]);
		}
	}
	delete trace;
	
	FinishLagCompensation_Base_boss();
	
	CalcCorrectWeaponShootPosition({ 60.9, 13.1, -15.1 }, pos, ang);
	TE_SetupBeamPoints(pos, hitPos, i_TinkerTracerIndex, 0, 0, 0, 0.3, 3.0, 3.0, 0, 0.0, {255, 255, 255, 255}, 3);
	TE_SendToAll(0.0);
	
	if(target < 0)
		return;
	
	if(target == 0)
	{
		switch(GetRandomInt(1,3))
		{
			case 1:
				EmitSoundToAll("weapons/fx/rics/arrow_impact_metal.wav", 0, SNDCHAN_STATIC, 70, _, 0.8, .origin = hitPos);
			
			case 2:
				EmitSoundToAll("weapons/fx/rics/arrow_impact_metal2.wav", 0, SNDCHAN_STATIC, 70, _, 0.8, .origin = hitPos);
			
			case 3:
				EmitSoundToAll("weapons/fx/rics/arrow_impact_metal4.wav", 0, SNDCHAN_STATIC, 70, _, 0.8, .origin = hitPos);
		}
		return;
	}
	else if(GetTeam(client) != GetTeam(target))
	{
		float damage = 50.0;
		damage *= Attributes_Get(weapon, 2, 1.0);
		
		if (headshot)
		{
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
		}
		else
		{
			if(i_HeadshotAffinity[client] == 1)
			{
				damage *= 0.75;
			}
		}
		
		float vecForward[3];
		GetAngleVectors(ang, vecForward, NULL_VECTOR, NULL_VECTOR);
		
		float PushforceDamage[3];
		CalculateDamageForce(vecForward, 10000.0, PushforceDamage);
		
		float targetPos[3];
		WorldSpaceCenter(target, targetPos);
		
		SDKHooks_TakeDamage(target, client, client, damage, DMG_BULLET, weapon, PushforceDamage, targetPos);
	}
	else
	{
		if(i_NpcIsABuilding[target])
		{
			if(view_as<ObjectGeneric>(target).m_bConstructBuilding && IsValidEntity(view_as<ObjectGeneric>(target).m_iConstructDeathModel))
				return;
			
			//heal building?
			bool RepairDone = false;
			if(IsValidEntity(weapon) && IsValidClient(client))
				RepairDone = Building_RepairObject(client, target, weapon, {0.0,0.0,0.0}, -1, 0.5);
			
			if(!RepairDone)
				return;
			
			int count;
			int[] players = new int[MaxClients];
			for(int i = 1; i <= MaxClients; i++)
			{
				if(i != client && IsClientInGame(i))
					players[count++] = i;
			}
			
			EmitSoundToClient(client, SOUND_HOSE_HEALED, client, SNDCHAN_STATIC, 70, _, 0.8);
			EmitSound(players, count, SOUND_HOSE_HEALED, 0, SNDCHAN_STATIC, 70, _, 0.8, .origin = hitPos);
		}
	}
}
*/

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

/*
int Blacksmith_Level(int client)
{
	return SmithLevel[client];
}
*/

static int AnvilClickedOn[MAXPLAYERS];
static int ClickedWithWeapon[MAXPLAYERS];
void Blacksmith_BuildingUsed(int entity, int client)
{
	AnvilClickedOn[client] = EntIndexToEntRef(entity);
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon == -1)
		return;
	ClickedWithWeapon[client] = EntIndexToEntRef(weapon);

	Anvil_Menu(client);
}

static void Blacksmith_BuildingUsed_Internal_Custom(int weapon, int entity, int client, int owner)
{
	if(owner == -1 || SmithLevel[owner] < 0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		if(IsValidEntity(entity))
			DestroyBuildingDo(entity);
		SPrintToChat(client, "%t", "The Blacksmith Failed!");
		return;
	}
	int account = GetSteamAccountID(client, false);
	if(!account)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		if(IsValidEntity(entity))
			ApplyBuildingCollectCooldown(entity, client, 3.0);
		return;
	}
	if(Attributes_Get(weapon, Attrib_DisallowTinker, 0.0) != 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Blacksmith Underleveled");
		if(IsValidEntity(entity))
			ApplyBuildingCollectCooldown(entity, client, 2.0);
		return;
	}
	if(dieingstate[client] == 0)
	{	
		CancelClientMenu(client);
		SetStoreMenuLogic(client, false);
		static char buffer[128];
		static char EnchantName[128];
		Menu menu = new Menu(UsedAnvil_MenuH);
		AnyMenuOpen[client] = 1;

		SetGlobalTransTarget(client);
		menu.SetTitle("%t", "Custom Anvil Menu Main");
		for(int RetryTillWin; RetryTillWin < 4; RetryTillWin++)
		{
			if(!EnchantRefresh[weapon])
				Query_Enchantment_List(weapon, account, owner, RetryTillWin);
			
			int i_QueryEnchant = StringToInt(Enchant[weapon][RetryTillWin]);
			FormatEx(buffer, sizeof(buffer), "%s", Query_GetTransList(i_QueryEnchant));
			if(TranslationPhraseExists(buffer))
			{
				FormatEx(EnchantName, sizeof(EnchantName), "%s;%i", Enchant[weapon][RetryTillWin], RetryTillWin);
				FormatEx(buffer, sizeof(buffer), "%t: Lv%i", buffer, SaveRarity[weapon][RetryTillWin]+1);
				menu.AddItem(EnchantName, buffer);
			}
			else
			{
				menu.AddItem("-1", "Dev WTF", ITEMDRAW_DISABLED);
			}
			
		}
		EnchantRefresh[weapon]=true;
		
		FormatEx(buffer, sizeof(buffer), "%t", "Custom Anvil Enchant Refresh");
		menu.AddItem("-1557;0", buffer);
		
		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
}

static char[] Query_GetTransList(int SelectInt)
{
	char buffer[256];
	switch(SelectInt)
	{
		case 1:FormatEx(buffer, sizeof(buffer), "Tinker_HasteMage");
		case 2:FormatEx(buffer, sizeof(buffer), "Tinker_HeavyMage");
		case 3:FormatEx(buffer, sizeof(buffer), "Tinker_ConcentratedMagic");
		case 4:FormatEx(buffer, sizeof(buffer), "Tinker_TankMage");
		case 5:FormatEx(buffer, sizeof(buffer), "Tinker_FastHeal");
		case 6:FormatEx(buffer, sizeof(buffer), "Tinker_Overhealer");
		case 7:FormatEx(buffer, sizeof(buffer), "Tinker_Uberer");
		case 8:FormatEx(buffer, sizeof(buffer), "Tinker_SharedGlassy");
		case 9:FormatEx(buffer, sizeof(buffer), "Tinker_BurstHeal");
		case 10:FormatEx(buffer, sizeof(buffer), "Tinker_BuilderRepairMaster");
		case 11:FormatEx(buffer, sizeof(buffer), "Tinker_BuilderLongSwing");
		case 12:FormatEx(buffer, sizeof(buffer), "Tinker_SharedGlassy");
		case 13:FormatEx(buffer, sizeof(buffer), "Tinker_MeleeRapidSwing");
		case 14:FormatEx(buffer, sizeof(buffer), "Tinker_MeleeHeavySwing");
		case 15:FormatEx(buffer, sizeof(buffer), "Tinker_MeleeLongSwing");
		case 16:FormatEx(buffer, sizeof(buffer), "Tinker_SlowHeavyProj");
		case 17:FormatEx(buffer, sizeof(buffer), "Tinker_FastProj");
		case 18:FormatEx(buffer, sizeof(buffer), "Tinker_HeavyTrigger");
		case 19:FormatEx(buffer, sizeof(buffer), "Tinker_IntensiveClip");
		case 20:FormatEx(buffer, sizeof(buffer), "Tinker_ConcentratedClip");
		case 21:FormatEx(buffer, sizeof(buffer), "Tinker_SmallerSmarterBullets");
		case 22:FormatEx(buffer, sizeof(buffer), "Tinker_SprayAndPray");
		
		case 23:FormatEx(buffer, sizeof(buffer), "Tinker_MS_Sharpness");
		case 24:FormatEx(buffer, sizeof(buffer), "Tinker_MS_Smite");
		case 25:FormatEx(buffer, sizeof(buffer), "Tinker_MS_SweepingEdge");
		case 26:FormatEx(buffer, sizeof(buffer), "Tinker_MS_QuickCharge");
		case 27:FormatEx(buffer, sizeof(buffer), "Tinker_MS_BaneofArthropods");
		case 28:FormatEx(buffer, sizeof(buffer), "Tinker_MS_FireAspect");
		case 29:FormatEx(buffer, sizeof(buffer), "Tinker_MS_CurseOfGlassy");
		
		case 30:FormatEx(buffer, sizeof(buffer), "Tinker_SR_ExplosiveHeadshot");
		case 31:FormatEx(buffer, sizeof(buffer), "Tinker_SR_KillerFocus");
		case 32:FormatEx(buffer, sizeof(buffer), "Tinker_SR_SuperCoolingChamber");
		case 33:FormatEx(buffer, sizeof(buffer), "Tinker_SR_DepletedUranium");
		case 34:FormatEx(buffer, sizeof(buffer), "Tinker_SR_HighSpeedFeedMechanism");
		case 35:FormatEx(buffer, sizeof(buffer), "Tinker_SR_HollowPointBullets");
	}
	return buffer;
}

static void Query_Enchantment_List(int weapon, int account, int owner, int Count=0)
{
	char classname[64];
	GetEntityClassname(weapon, classname, sizeof(classname));
	int slot = TF2_GetClassnameSlot(classname, weapon);

	TinkerEnum tinker;
	int found = -1;
	if(Tinkers)
	{
		int length = Tinkers.Length;
		for(int a; a < length; a++)
		{
			Tinkers.GetArray(a, tinker);
			if(tinker.AccountId == account && tinker.StoreIndex == StoreWeapon[weapon])
			{
				found = a;
				break;
			}
		}
	}

	if(found == -1)
	{
		tinker.AccountId = account;
		tinker.StoreIndex = StoreWeapon[weapon];
	}
	
	Zero(tinker.Attrib);
	Zero(tinker.CustomMode);
	Zero(tinker.Addition);
	tinker.Rarity = 0;

	switch(SmithLevel[owner])
	{
		case 0, 1:
		{
			
		}
		case 2:
		{
			if((GetURandomInt() % 4) == 0)
				tinker.Rarity = 1;
		}
		case 3:
		{
			int rand = GetURandomInt();
			if((rand % 7) == 0)
			{
				tinker.Rarity = 2;
			}
			else if((rand % 3) == 0)
			{
				tinker.Rarity = 1;
			}
		}
		case 4:
		{
			int rand = GetURandomInt();
			if((rand % 5) == 0)
			{
				tinker.Rarity = 2;
			}
			else if((rand % 2) == 0)
			{
				tinker.Rarity = 1;
			}
		}
		default:
		{
			if((GetURandomInt() % 3) == 0)
			{
				tinker.Rarity = 2;
			}
			else
			{
				tinker.Rarity = 1;
			}
		}
	}

	if(i_OverrideWeaponSlot[weapon] != -1)
	{
		slot = i_OverrideWeaponSlot[weapon];
	}
	switch(i_CustomWeaponEquipLogic[weapon])
	{
		case WEAPON_BOOMERANG:
		{
			SaveRarity[weapon][Count] = tinker.Rarity;
			strcopy(Enchant[weapon][Count], sizeof(Enchant[weapon][]), Enchant_Boomerang[GetURandomInt() % sizeof(Enchant_Boomerang)]);
			return;
		}
		case WEAPON_SIGIL_BLADE:
		{
			SaveRarity[weapon][Count] = tinker.Rarity;
			strcopy(Enchant[weapon][Count], sizeof(Enchant[weapon][]), Enchant_SigilBlade[GetURandomInt() % sizeof(Enchant_SigilBlade)]);
			return;
		}
		case WEAPON_MINECRAFT_SWORD:
		{
			switch(SmithLevel[owner])
			{
				case 0:
				{
					tinker.Rarity = 0;
				}
				case 1:
				{
					if((GetURandomInt() % 4) == 0)
						tinker.Rarity = 1;
					else tinker.Rarity = 0;
				}
				case 2:
				{
					int rand = GetURandomInt();
					if((rand % 7) == 0)
					{
						tinker.Rarity = 2;
					}
					else if((rand % 3) == 0)
					{
						tinker.Rarity = 1;
					}
					else tinker.Rarity = 0;
				}
				case 3:
				{
					int rand = GetURandomInt();
					if((rand % 12) == 0)
					{
						tinker.Rarity = 3;
					}
					else if((rand % 7) == 0)
					{
						tinker.Rarity = 2;
					}
					else if((rand % 3) == 0)
					{
						tinker.Rarity = 1;
					}
					else tinker.Rarity = 0;
				}
				case 4:
				{
					int rand = GetURandomInt();
					if((rand % 12) == 0)
					{
						tinker.Rarity = 4;
					}
					if((rand % 7) == 0)
					{
						tinker.Rarity = 3;
					}
					else if((rand % 5) == 0)
					{
						tinker.Rarity = 2;
					}
					else if((rand % 2) == 0)
					{
						tinker.Rarity = 1;
					}
					else tinker.Rarity = 0;
				}
				default:
				{
					int rand = GetURandomInt();
					if((rand % 7) == 0)
					{
						tinker.Rarity = 4;
					}
					else if((rand % 5) == 0)
					{
						tinker.Rarity = 3;
					}
					else if((rand % 3) == 0)
					{
						tinker.Rarity = 2;
					}
					else if((rand % 2) == 0)
					{
						tinker.Rarity = 1;
					}
					else tinker.Rarity = 0;
				}
			}
			SaveRarity[weapon][Count] = tinker.Rarity;
			strcopy(Enchant[weapon][Count], sizeof(Enchant[weapon][]), Enchant_MinecraftSword[GetURandomInt() % sizeof(Enchant_MinecraftSword)]);
			return;
		}
		default:
		{
			int Attrib = RoundToCeil(Attributes_Get(weapon, Attrib_IsSniperRifle, 0.0));
			if(Attrib==1)
			{
				SaveRarity[weapon][Count] = tinker.Rarity;
				strcopy(Enchant[weapon][Count], sizeof(Enchant[weapon][]), Enchant_SniperRifle[GetURandomInt() % sizeof(Enchant_SniperRifle)]);
				return;
			}
			else if(Attrib==2)
			{
				SaveRarity[weapon][Count] = tinker.Rarity;
				strcopy(Enchant[weapon][Count], sizeof(Enchant[weapon][]), Enchant_DMR[GetURandomInt() % sizeof(Enchant_DMR)]);
				return;
			}
		}
	}
	if(i_IsWandWeapon[weapon])
	{
		// Mage Weapon
		SaveRarity[weapon][Count] = tinker.Rarity;
		strcopy(Enchant[weapon][Count], sizeof(Enchant[weapon][]), Enchant_Mage[GetURandomInt() % sizeof(Enchant_Mage)]);
		return;
	}
	else if(Attributes_Get(weapon, 8, 0.0) != 0.0)
	{
		//mediguns, they work uniqurely
		if(StrEqual(classname, "tf_weapon_medigun"))
		{
			SaveRarity[weapon][Count] = tinker.Rarity;
			strcopy(Enchant[weapon][Count], sizeof(Enchant[weapon][]), Enchant_Mediguns[GetURandomInt() % sizeof(Enchant_Mediguns)]);
			return;
		}
		else
		{
			if(slot == TFWeaponSlot_Melee)
			{
				SaveRarity[weapon][Count] = tinker.Rarity;
				strcopy(Enchant[weapon][Count], sizeof(Enchant[weapon][]), "8");
				return;
			}
			else
			{
				SaveRarity[weapon][Count] = tinker.Rarity;
				strcopy(Enchant[weapon][Count], sizeof(Enchant[weapon][]), Enchant_Healings[GetURandomInt() % sizeof(Enchant_Healings)]);
				return;
			}
		}
	}
	else if(i_IsWrench[weapon] && slot != TFWeaponSlot_Melee)
	{
		SaveRarity[weapon][Count] = tinker.Rarity;
		strcopy(Enchant[weapon][Count], sizeof(Enchant[weapon][]), "10");
		return;
	}
	else if(slot == TFWeaponSlot_Melee)
	{
		if(i_IsWrench[weapon])
		{
			// Wrench Weapon
			SaveRarity[weapon][Count] = tinker.Rarity;
			strcopy(Enchant[weapon][Count], sizeof(Enchant[weapon][]), Enchant_Wrench[GetURandomInt() % sizeof(Enchant_Wrench)]);
			return;
		}
		else
		{
			// Melee Weapon
			SaveRarity[weapon][Count] = tinker.Rarity;
			strcopy(Enchant[weapon][Count], sizeof(Enchant[weapon][]), Enchant_Melee[GetURandomInt() % sizeof(Enchant_Melee)]);
			return;
		}
	}
	else if(slot < TFWeaponSlot_Melee)
	{
		if(Attributes_Has(weapon, 101) || Attributes_Has(weapon, 102) || Attributes_Has(weapon, 103) || Attributes_Has(weapon, 104))
		{
			//infinite fire
			if(Attributes_Has(weapon, 303))
			{
				SaveRarity[weapon][Count] = tinker.Rarity;
				strcopy(Enchant[weapon][Count], sizeof(Enchant[weapon][]), Enchant_Melee_InfiniteFire[GetURandomInt() % sizeof(Enchant_Melee_InfiniteFire)]);
				return;
			}
			else
			{
				SaveRarity[weapon][Count] = tinker.Rarity;
				strcopy(Enchant[weapon][Count], sizeof(Enchant[weapon][]), Enchant_Melee_Fire[GetURandomInt() % sizeof(Enchant_Melee_Fire)]);
				return;
			}
			// Projectile Weapon
		}
		else
		{
			//infinite fire
			if(Attributes_Has(weapon, 303))
			{
				SaveRarity[weapon][Count] = tinker.Rarity;
				strcopy(Enchant[weapon][Count], sizeof(Enchant[weapon][]), Enchant_Range_InfiniteFire[GetURandomInt() % (sizeof(Enchant_Range_InfiniteFire)-((Attributes_Get(weapon, 45, 0.0) > 0.0) ? 0 : 1))]);
				return;
			}
			else if(StrEqual(classname, "tf_weapon_flamethrower"))
			{
				//flamethrowers get different logic.
				SaveRarity[weapon][Count] = tinker.Rarity;
				strcopy(Enchant[weapon][Count], sizeof(Enchant[weapon][]), Enchant_Flamethrower[GetURandomInt() % sizeof(Enchant_Flamethrower)]);
				return;
			}
			else
			{
				SaveRarity[weapon][Count] = tinker.Rarity;
				strcopy(Enchant[weapon][Count], sizeof(Enchant[weapon][]), Enchant_Range[GetURandomInt() % (sizeof(Enchant_Range)-(Attributes_Get(weapon, 45, 0.0) > 0.1 ? 0 : 1))]);
				return;
			}
			// Hitscan Weapon
		}
	}
	else
	{
		SaveRarity[weapon][Count] = tinker.Rarity;
		strcopy(Enchant[weapon][Count], sizeof(Enchant[weapon][]), "-1");
	}
	return;
}

static int UsedAnvil_MenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
			if(IsValidClient(client))
				AnyMenuOpen[client] = 0;
		}
		case MenuAction_Select:
		{
			AnyMenuOpen[client] = 0;
			ResetStoreMenuLogic(client);
			static char buffer[128];
			menu.GetItem(choice, buffer, sizeof(buffer));
			static char countext[2][24];
			ExplodeString(buffer, ";", countext, sizeof(countext), sizeof(countext[]));
			int id = StringToInt(countext[0]);
			int Count = StringToInt(countext[1]);
			int weapon;
			int anvil;
			int owner;
			
			if(IsValidClient(client))
			{
				weapon = EntRefToEntIndex(ClickedWithWeapon[client]);
				anvil = EntRefToEntIndex(AnvilClickedOn[client]);
			}
			else
				return 0;

			if(!IsValidEntity(weapon) || !IsValidEntity(anvil))
				return 0;
			else
			{
				owner = GetEntPropEnt(anvil, Prop_Send, "m_hOwnerEntity");
			}
			
			int account = GetSteamAccountID(client, false);
			if(!account)
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				if(IsValidEntity(anvil))
					ApplyBuildingCollectCooldown(anvil, client, 3.0);
				return 0;
			}
			
			if(id==-1557)
			{
				ApplyBuildingCollectCooldown(anvil, client, (owner == client ? 2.5 : 10.0));
				EnchantRefresh[weapon]=false;
				ClientCommand(client, "playgamesound ui/quest_decode.wav");
				return 0;
			}
			
			TinkerEnum tinker;
			int found = -1;
			if(Tinkers)
			{
				int length = Tinkers.Length;
				for(int a; a < length; a++)
				{
					Tinkers.GetArray(a, tinker);
					if(tinker.AccountId == account && tinker.StoreIndex == StoreWeapon[weapon])
					{
						found = a;
						break;
					}
				}
			}

			if(found == -1)
			{
				tinker.AccountId = account;
				tinker.StoreIndex = StoreWeapon[weapon];
			}
			for(int i; i < sizeof(tinker.Luck); i++)
			{
				tinker.Luck[i] = GetURandomFloat();
			}
			tinker.Rarity = SaveRarity[weapon][Count];
			switch(id)
			{
				case 1:TinkerHastyMage(tinker.Rarity, tinker);
				case 2:TinkerHeavyMage(tinker.Rarity, tinker);
				case 3:TinkerConcentrationMage(tinker.Rarity, tinker);
				case 4:TinkerTankMage(tinker.Rarity, tinker);
				case 5:TinkerMedigun_FastHeal(tinker.Rarity, tinker);
				case 6:TinkerMedigun_Overhealer(tinker.Rarity, tinker);
				case 7:TinkerMedigun_Uberer(tinker.Rarity, tinker);
				case 8:TinkerMedicWeapon_GlassyMedic(tinker.Rarity, tinker);
				case 9:TinkerMedicWeapon_BurstHealMedic(tinker.Rarity, tinker);
				case 10:TinkerBuilderRepairMaster(tinker.Rarity, tinker);
				case 11:TinkerBuilderLongSwing(tinker.Rarity, tinker);
				case 12:TinkerMeleeGlassy(tinker.Rarity, tinker);
				case 13:TinkerMeleeRapidSwing(tinker.Rarity, tinker);
				case 14:TinkerMeleeHeavySwing(tinker.Rarity, tinker);
				case 15:TinkerMeleeLongSwing(tinker.Rarity, tinker);
				case 16:TinkerRangedSlowHeavyProj(tinker.Rarity, tinker);
				case 17:TinkerRangedFastProj(tinker.Rarity, tinker);
				case 18:TinkerHeavyTrigger(tinker.Rarity, tinker);
				case 19:TinkerIntensiveClip(tinker.Rarity, tinker);
				case 20:TinkerConcentratedClip(tinker.Rarity, tinker);
				case 21:TinkerSmallerSmarterBullets(tinker.Rarity, tinker);
				case 22:TinkerSprayAndPray(tinker.Rarity, tinker);
				
				case 23:Tinker_MS_Sharpness(tinker.Rarity, tinker);
				case 24:Tinker_MS_Smite(tinker.Rarity, tinker);
				case 25:Tinker_MS_SweepingEdge(tinker.Rarity, tinker);
				case 26:Tinker_MS_BaneofArthropods(tinker.Rarity, tinker);
				case 27:Tinker_MS_FireAspect(tinker.Rarity, tinker);
				case 28:Tinker_MS_QuickCharge(tinker.Rarity, tinker);
				case 29:Tinker_MS_CurseofGlassy(tinker.Rarity, tinker);
				
				case 30:Tinker_SR_ExplosiveHeadshot(tinker.Rarity, tinker);
				case 31:Tinker_SR_KillerFocus(tinker.Rarity, tinker);
				case 32:Tinker_SR_SuperCoolingChamber(tinker.Rarity, tinker);
				case 33:Tinker_SR_DepletedUranium(tinker.Rarity, tinker);
				case 34:Tinker_SR_HighSpeedFeedMechanism(tinker.Rarity, tinker);
				case 35:Tinker_SR_HollowPointBullets(tinker.Rarity, tinker);
			}
			
			SetGlobalTransTarget(client);
			FormatEx(buffer, sizeof(buffer), "%s", tinker.Name);
			if(TranslationPhraseExists(buffer))
				CPrintToChat(client, "{yellow}%t (Tier %d)", buffer, tinker.Rarity + 1);
			else
			{
				CPrintToChat(client, "{yellow}%s (Tier %d)", buffer, tinker.Rarity + 1);
				CPrintToChat(client, "{crimson}[Dev Warning] Translation not found");
			}

			for(int i; i < sizeof(tinker.Attrib); i++)
			{
				if(!tinker.Attrib[i])
					break;
				
				Blacksmith_PrintAttribValue(client, tinker.Attrib[i], tinker.Value[i], tinker.Luck[i],  tinker.Addition[i], tinker.CustomMode[i]);
			}

			if(found == -1)
			{
				if(!Tinkers)
					Tinkers = new ArrayList(sizeof(TinkerEnum));
				
				Tinkers.PushArray(tinker);
			}
			else
			{
				Tinkers.SetArray(found, tinker);
			}

			Building_GiveRewardsUse(client, owner, 25, true, 0.6, true);
			Store_ApplyAttribs(client);
			Store_GiveAll(client, GetClientHealth(client));	

			switch(tinker.Rarity)
			{
				case -1:
				{
					ClientCommand(client, "playgamesound ui/quest_decode.wav");
				}
				case 0:
				{
					ClientCommand(client, "playgamesound ui/quest_status_tick_novice.wav");
				}
				case 1:
				{
					ClientCommand(client, "playgamesound ui/quest_status_tick_advanced.wav");
				}
				case 2:
				{
					ClientCommand(client, "playgamesound ui/quest_status_tick_expert.wav");
				}
			}

			float cooldown = Cooldowns[SmithLevel[owner]];
			if(client != owner && Store_HasWeaponKit(client))
				cooldown *= 0.5;
			if(owner == client)
				cooldown /= 4.0;
			if(IsValidEntity(anvil))
				ApplyBuildingCollectCooldown(anvil, client, cooldown);

			if(!Rogue_Mode() && owner != client)
			{
				switch(tinker.Rarity)
				{
					case 0:
					{
						ClientCommand(owner, "playgamesound ui/quest_status_tick_novice_friend.wav");
					}
					case 1:
					{
						ClientCommand(owner, "playgamesound ui/quest_status_tick_advanced_friend.wav");
					}
					default:
					{
						ClientCommand(owner, "playgamesound ui/quest_status_tick_expert_friend.wav");
					}
				}
			}
		}
		case MenuAction_Cancel:
		{
			ResetStoreMenuLogic(client);
		}
	}
	return 0;
}

void Blacksmith_BuildingUsed_Internal(int weapon ,int entity, int client, int owner, bool reset)
{
	if(owner == -1 || SmithLevel[owner] < 0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		if(IsValidEntity(entity))
			DestroyBuildingDo(entity);
		SPrintToChat(client, "%t", "The Blacksmith Failed!");
		return;
	}
	
	int account = GetSteamAccountID(client, false);
	if(!account)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		if(IsValidEntity(entity))
			ApplyBuildingCollectCooldown(entity, client, 3.0);
		return;
	}

	TinkerEnum tinker;
	int found = -1;
	if(Tinkers)
	{
		int length = Tinkers.Length;
		for(int a; a < length; a++)
		{
			Tinkers.GetArray(a, tinker);
			if(tinker.AccountId == account && tinker.StoreIndex == StoreWeapon[weapon])
			{
				found = a;
				break;
			}
		}
	}

	if(found == -1)
	{
		tinker.AccountId = account;
		tinker.StoreIndex = StoreWeapon[weapon];
	}
	
	Zero(tinker.Attrib);
	Zero(tinker.CustomMode);
	Zero(tinker.Addition);
	tinker.Rarity = 0;
	if(reset)
	{
		SetGlobalTransTarget(client);
		
		if(found == -1)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Blacksmith No Attribs");
			if(IsValidEntity(entity))
				ApplyBuildingCollectCooldown(entity, client, 2.0);
			return;
		}

		tinker.Rarity = -1;
		Tinkers.Erase(found);
		PrintToChat(client, "%t", "Removed Tinker Attributes");
	}
	else
	{
		switch(SmithLevel[owner])
		{
			case 0, 1:
			{
				
			}
			case 2:
			{
				if((GetURandomInt() % 4) == 0)
					tinker.Rarity = 1;
			}
			case 3:
			{
				int rand = GetURandomInt();
				if((rand % 7) == 0)
				{
					tinker.Rarity = 2;
				}
				else if((rand % 3) == 0)
				{
					tinker.Rarity = 1;
				}
			}
			case 4:
			{
				int rand = GetURandomInt();
				if((rand % 5) == 0)
				{
					tinker.Rarity = 2;
				}
				else if((rand % 2) == 0)
				{
					tinker.Rarity = 1;
				}
			}
			default:
			{
				if((GetURandomInt() % 3) == 0)
				{
					tinker.Rarity = 2;
				}
				else
				{
					tinker.Rarity = 1;
				}
			}
		}

		for(int i; i < sizeof(tinker.Luck); i++)
		{
			tinker.Luck[i] = GetURandomFloat();
		}

		char classname[64];
		GetEntityClassname(weapon, classname, sizeof(classname));
		int slot = TF2_GetClassnameSlot(classname, weapon);

		if(i_OverrideWeaponSlot[weapon] != -1)
		{
			slot = i_OverrideWeaponSlot[weapon];
		}
		bool BlockNormal = false;
		switch(i_CustomWeaponEquipLogic[weapon])
		{
			case WEAPON_BOOMERANG:
			{
				BlockNormal = true;
				//boomerang is very special.
				switch(GetURandomInt() % 4)
				{
					case 0:
						TinkerMeleeRapidSwing(tinker.Rarity, tinker);
					case 1:
						TinkerHeavyTrigger(tinker.Rarity, tinker);
					case 2:
						TinkerRangedSlowHeavyProj(tinker.Rarity, tinker);
					case 3:
						TinkerRangedFastProj(tinker.Rarity, tinker);
				}
			}
			case WEAPON_SIGIL_BLADE:
			{
				BlockNormal = true;
				// Mage Weapon
				switch(GetURandomInt() % 3)
				{
					case 0:
						TinkerHastyMage(tinker.Rarity, tinker);
					case 1:
						TinkerHeavyMage(tinker.Rarity, tinker);
					case 2:
						TinkerTankMage(tinker.Rarity, tinker);
				}
			}
			case WEAPON_MINECRAFT_SWORD:
			{
				BlockNormal = true;
				switch(SmithLevel[owner])
				{
					case 0:
					{
						tinker.Rarity = 0;
					}
					case 1:
					{
						if((GetURandomInt() % 4) == 0)
							tinker.Rarity = 1;
						else tinker.Rarity = 0;
					}
					case 2:
					{
						int rand = GetURandomInt();
						if((rand % 7) == 0)
						{
							tinker.Rarity = 2;
						}
						else if((rand % 3) == 0)
						{
							tinker.Rarity = 1;
						}
						else tinker.Rarity = 0;
					}
					case 3:
					{
						int rand = GetURandomInt();
						if((rand % 12) == 0)
						{
							tinker.Rarity = 3;
						}
						else if((rand % 7) == 0)
						{
							tinker.Rarity = 2;
						}
						else if((rand % 3) == 0)
						{
							tinker.Rarity = 1;
						}
						else tinker.Rarity = 0;
					}
					case 4:
					{
						int rand = GetURandomInt();
						if((rand % 12) == 0)
						{
							tinker.Rarity = 4;
						}
						if((rand % 7) == 0)
						{
							tinker.Rarity = 3;
						}
						else if((rand % 5) == 0)
						{
							tinker.Rarity = 2;
						}
						else if((rand % 2) == 0)
						{
							tinker.Rarity = 1;
						}
						else tinker.Rarity = 0;
					}
					default:
					{
						int rand = GetURandomInt();
						if((rand % 7) == 0)
						{
							tinker.Rarity = 4;
						}
						else if((rand % 5) == 0)
						{
							tinker.Rarity = 3;
						}
						else if((rand % 3) == 0)
						{
							tinker.Rarity = 2;
						}
						else if((rand % 2) == 0)
						{
							tinker.Rarity = 1;
						}
						else tinker.Rarity = 0;
					}
				}
				switch(GetURandomInt() % 7)
				{
					case 0:Tinker_MS_Sharpness(tinker.Rarity, tinker);
					case 1:Tinker_MS_Smite(tinker.Rarity, tinker);
					case 2:Tinker_MS_SweepingEdge(tinker.Rarity, tinker);
					case 3:Tinker_MS_BaneofArthropods(tinker.Rarity, tinker);
					case 4:Tinker_MS_FireAspect(tinker.Rarity, tinker);
					case 5:Tinker_MS_QuickCharge(tinker.Rarity, tinker);
					case 6:Tinker_MS_CurseofGlassy(tinker.Rarity, tinker);
					default:Tinker_MS_Sharpness(tinker.Rarity, tinker);
				}
			}
			default:
			{
				int Attrib = RoundToCeil(Attributes_Get(weapon, Attrib_IsSniperRifle, 0.0));
				if(Attrib==1)
				{
					BlockNormal = true;
					switch(GetURandomInt() % 6)
					{
						case 0:
							Tinker_SR_ExplosiveHeadshot(tinker.Rarity, tinker);
						case 1:
							Tinker_SR_KillerFocus(tinker.Rarity, tinker);
						case 2:
							Tinker_SR_SuperCoolingChamber(tinker.Rarity, tinker);
						case 3:
							Tinker_SR_DepletedUranium(tinker.Rarity, tinker);
						case 4:
							Tinker_SR_HighSpeedFeedMechanism(tinker.Rarity, tinker);
						case 5:
							Tinker_SR_HollowPointBullets(tinker.Rarity, tinker);
						default:
							Tinker_SR_ExplosiveHeadshot(tinker.Rarity, tinker);
					}
				}
				else if(Attrib==2)
				{
					BlockNormal = true;
					switch(GetURandomInt() % 7)
					{
						case 0:
							Tinker_SR_ExplosiveHeadshot(tinker.Rarity, tinker);
						case 1:
							Tinker_SR_KillerFocus(tinker.Rarity, tinker);
						case 2:
							TinkerIntensiveClip(tinker.Rarity, tinker);
						case 3:
							TinkerConcentratedClip(tinker.Rarity, tinker);
						case 4:
							Tinker_SR_HighSpeedFeedMechanism(tinker.Rarity, tinker);
						case 5:
							Tinker_SR_HollowPointBullets(tinker.Rarity, tinker);
						case 6:
							TinkerSmallerSmarterBullets(tinker.Rarity, tinker);
						default:
							Tinker_SR_ExplosiveHeadshot(tinker.Rarity, tinker);
					}
				}
			}
		}
		if(Attributes_Get(weapon, Attrib_DisallowTinker, 0.0) != 0.0)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Blacksmith Underleveled");
			if(IsValidEntity(entity))
				ApplyBuildingCollectCooldown(entity, client, 2.0);
			return;
		}
		if(!BlockNormal)
		{
			if(i_IsWandWeapon[weapon])
			{
				// Mage Weapon
				switch(GetURandomInt() % 4)
				{
					case 0:
						TinkerHastyMage(tinker.Rarity, tinker);
					case 1:
						TinkerHeavyMage(tinker.Rarity, tinker);
					case 2:
						TinkerConcentrationMage(tinker.Rarity, tinker);
					case 3:
						TinkerTankMage(tinker.Rarity, tinker);
				}
			}
			else if(Attributes_Get(weapon, 8, 0.0) != 0.0)
			{
				//mediguns, they work uniqurely
				if(StrEqual(classname, "tf_weapon_medigun"))
				{
					switch(GetURandomInt() % 3)
					{
						case 0:
							TinkerMedigun_FastHeal(tinker.Rarity, tinker);
						case 1:
							TinkerMedigun_Overhealer(tinker.Rarity, tinker);
						case 2:
							TinkerMedigun_Uberer(tinker.Rarity, tinker);
					}
				}
				else
				{
					if(slot == TFWeaponSlot_Melee)
					{
						TinkerMedicWeapon_GlassyMedic(tinker.Rarity, tinker);
					}
					else
					{
						switch(GetURandomInt() % 2)
						{
							case 0:
								TinkerMedicWeapon_GlassyMedic(tinker.Rarity, tinker);
							case 1:
								TinkerMedicWeapon_BurstHealMedic(tinker.Rarity, tinker);
						}					
					}

					//anything else.
				}
			}
			else if(i_IsWrench[weapon] && slot != TFWeaponSlot_Melee)
			{
				//any wrench weapon that isnt melee?
				TinkerBuilderRepairMaster(tinker.Rarity, tinker);
			}
			else if(slot == TFWeaponSlot_Melee)
			{
				if(i_IsWrench[weapon])
				{
					if(Attributes_Get(weapon, 264, 0.0) != 0.0)
					{
						switch(GetURandomInt() % 2)
						{
							case 0:
								TinkerBuilderRepairMaster(tinker.Rarity, tinker);
							case 1:
								TinkerBuilderLongSwing(tinker.Rarity, tinker);
						}
					}
					else
					{
						switch(GetURandomInt() % 2)
						{
							case 0:
								TinkerBuilderRepairMaster(tinker.Rarity, tinker);
							case 1:
								TinkerBuilderLongSwing(tinker.Rarity, tinker);
						}					
					}
					// Wrench Weapon
				}
				else
				{
					// Melee Weapon
					switch(GetURandomInt() % 4)
					{
						case 0:
							TinkerMeleeGlassy(tinker.Rarity, tinker);
						case 1:
							TinkerMeleeRapidSwing(tinker.Rarity, tinker);
						case 2:
							TinkerMeleeHeavySwing(tinker.Rarity, tinker);
						case 3:
							TinkerMeleeLongSwing(tinker.Rarity, tinker);
					}
				}
			}
			else if(slot < TFWeaponSlot_Melee)
			{
				if(Attributes_Has(weapon, 101) || Attributes_Has(weapon, 102) || Attributes_Has(weapon, 103) || Attributes_Has(weapon, 104))
				{
					//infinite fire
					if(Attributes_Has(weapon, 303))
					{
						switch(GetURandomInt() % 4)
						{
							case 0:
								TinkerMeleeRapidSwing(tinker.Rarity, tinker);
							case 1:
								TinkerRangedSlowHeavyProj(tinker.Rarity, tinker);
							case 2:
								TinkerRangedFastProj(tinker.Rarity, tinker);
							case 3:
								TinkerHeavyTrigger(tinker.Rarity, tinker);
						}
					}
					else
					{
						switch(GetURandomInt() % 6)
						{
							case 0:
								TinkerMeleeRapidSwing(tinker.Rarity, tinker);
							case 1:
								TinkerRangedSlowHeavyProj(tinker.Rarity, tinker);
							case 2:
								TinkerRangedFastProj(tinker.Rarity, tinker);
							case 3:
								TinkerIntensiveClip(tinker.Rarity, tinker);
							case 4:
								TinkerConcentratedClip(tinker.Rarity, tinker);
							case 5:
								TinkerHeavyTrigger(tinker.Rarity, tinker);
							case 6:
								TinkerSmallerSmarterBullets(tinker.Rarity, tinker);
						}
					}
					// Projectile Weapon
				}
				else
				{
					//infinite fire
					if(Attributes_Has(weapon, 303))
					{
						for(int RetryTillWin; RetryTillWin < 10; RetryTillWin++)
						{
							switch(GetURandomInt() % 3)
							{
								case 0:
								{
									TinkerMeleeRapidSwing(tinker.Rarity, tinker);
									RetryTillWin = 11;
								}
								case 1:
								{
									TinkerHeavyTrigger(tinker.Rarity, tinker);
									RetryTillWin = 11;
								}
								case 2:
								{
									if(Attributes_Get(weapon, 45, 0.0) > 0.0)
									{
										RetryTillWin = 11;
										TinkerSprayAndPray(tinker.Rarity, tinker);
									}
								}
							}	
						}
					}
					else if(StrEqual(classname, "tf_weapon_flamethrower"))
					{
						//flamethrowers get different logic.
						switch(GetURandomInt() % 3)
						{
							case 0:
							{
								TinkerMeleeRapidSwing(tinker.Rarity, tinker);
							}
							case 1:
							{
								TinkerHeavyTrigger(tinker.Rarity, tinker);
							}
							case 2:
							{
								TinkerSmallerSmarterBullets(tinker.Rarity, tinker);
							}
						}	
					}
					else
					{
						for(int RetryTillWin; RetryTillWin < 10; RetryTillWin++)
						{
							switch(GetURandomInt() % 6)
							{
								case 0:
								{
									TinkerMeleeRapidSwing(tinker.Rarity, tinker);
									RetryTillWin = 11;
								}
								case 1:
								{
									TinkerIntensiveClip(tinker.Rarity, tinker);
									RetryTillWin = 11;
								}
								case 2:
								{
									TinkerConcentratedClip(tinker.Rarity, tinker);
									RetryTillWin = 11;
								}
								case 3:
								{
									TinkerHeavyTrigger(tinker.Rarity, tinker);
									RetryTillWin = 11;
								}
								case 4:
								{
									TinkerSmallerSmarterBullets(tinker.Rarity, tinker);
									RetryTillWin = 11;
								}
								case 5:
								{
									if(Attributes_Get(weapon, 45, 0.0) > 0.1)
									{
										RetryTillWin = 11;
										TinkerSprayAndPray(tinker.Rarity, tinker);
									}
								}
							}	
						}
					}
					// Hitscan Weapon
				}
			}
			else
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Blacksmith Underleveled");
				if(IsValidEntity(entity))
					ApplyBuildingCollectCooldown(entity, client, 2.0);
				return;
			}
		}
		
		SetGlobalTransTarget(client);
		char buffer[128];
		FormatEx(buffer, sizeof(buffer), "%s", tinker.Name);
		if(TranslationPhraseExists(buffer))
			CPrintToChat(client, "{yellow}%t (Tier %d)", buffer, tinker.Rarity + 1);
		else
		{
			CPrintToChat(client, "{yellow}%s (Tier %d)", buffer, tinker.Rarity + 1);
			CPrintToChat(client, "{crimson}[Dev Warning] Translation not found");
		}
		for(int i; i < sizeof(tinker.Attrib); i++)
		{
			if(!tinker.Attrib[i])
				break;
			
			Blacksmith_PrintAttribValue(client, tinker.Attrib[i], tinker.Value[i], tinker.Luck[i],  tinker.Addition[i], tinker.CustomMode[i]);
		}

		if(found == -1)
		{
			if(!Tinkers)
				Tinkers = new ArrayList(sizeof(TinkerEnum));
			
			Tinkers.PushArray(tinker);
		}
		else
		{
			Tinkers.SetArray(found, tinker);
		}
	}

	Building_GiveRewardsUse(client, owner, 25, true, 0.6, true);
	Store_ApplyAttribs(client);
	Store_GiveAll(client, GetClientHealth(client));	

	switch(tinker.Rarity)
	{
		case -1:
		{
			ClientCommand(client, "playgamesound ui/quest_decode.wav");
		}
		case 0:
		{
			ClientCommand(client, "playgamesound ui/quest_status_tick_novice.wav");
		}
		case 1:
		{
			ClientCommand(client, "playgamesound ui/quest_status_tick_advanced.wav");
		}
		case 2:
		{
			ClientCommand(client, "playgamesound ui/quest_status_tick_expert.wav");
		}
	}

	float cooldown = Cooldowns[SmithLevel[owner]];
	if(client != owner && Store_HasWeaponKit(client))
		cooldown *= 0.5;
	if(tinker.Rarity == -1)
		cooldown /= 5.0;
	if(IsValidEntity(entity))
		ApplyBuildingCollectCooldown(entity, client, cooldown);

	if(!Rogue_Mode() && owner != client)
	{
		switch(tinker.Rarity)
		{
			case 0:
			{
				ClientCommand(owner, "playgamesound ui/quest_status_tick_novice_friend.wav");
			}
			case 1:
			{
				ClientCommand(owner, "playgamesound ui/quest_status_tick_advanced_friend.wav");
			}
			default:
			{
				ClientCommand(owner, "playgamesound ui/quest_status_tick_expert_friend.wav");
			}
		}
	}
}

static bool AttribIsInverse(int attrib)
{
	switch(attrib)
	{
		case 5, 6, 96, 97, 205, 206, 252, 343, 412, Attrib_TerrianRes:
			return true;
	}

	return false;
}

void Blacksmith_PrintAttribValue(int client, int attrib, float value, float luck, bool addition = false, int CustomMode = 0)
{
	if(attrib == 264)
	{
		return;
	}
	bool inverse = AttribIsInverse(attrib);

	char buffer[128];
	char TranslationBuffer[128];
	if(addition)
	{
		FormatEx(buffer, sizeof(buffer), "%d ", RoundToCeil(value));
	}
	else if(value < 1.0)
	{
		FormatEx(buffer, sizeof(buffer), "%d％ ", RoundToCeil((1.0 - value) * 100.0));
	}
	else
	{
		FormatEx(buffer, sizeof(buffer), "%d％ ", RoundToCeil((value - 1.0) * 100.0));
	}

	//inverse the inverse!
	bool inverse_color = false;
	if(attrib == 733)
	{
		inverse_color = true;
	}
	if(attrib == 41 && CustomMode==1)
		inverse=true;

	if(((value < (addition ? 0.0 : 1.0)) ^ inverse))
	{
		if(!inverse_color)
		{
			Format(buffer, sizeof(buffer), "{crimson}-%s", buffer);
		}
		else
		{
			Format(buffer, sizeof(buffer), "{green}-%s", buffer);
		}
	}
	else
	{
		if(!inverse_color)
		{
			Format(buffer, sizeof(buffer), "{green}+%s", buffer);
		}
		else
		{
			Format(buffer, sizeof(buffer), "{crimson}+%s", buffer);
		}
	}
	SetGlobalTransTarget(client);
	FormatEx(TranslationBuffer, sizeof(TranslationBuffer), "%s", Query_GetTinkerAttrib(attrib, CustomMode));
	if(TranslationPhraseExists(TranslationBuffer))
		Format(TranslationBuffer, sizeof(TranslationBuffer), "%t", TranslationBuffer);
	Format(buffer, sizeof(buffer), "%s %s", buffer, TranslationBuffer);
	
	CPrintToChat(client, "%s {yellow}(%d％)", buffer, RoundToCeil(luck * 100.0));
}

static void TinkerMeleeGlassy(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_SharedGlassy");
	tinker.Attrib[0] = 2;
	tinker.Attrib[1] = 205;
	tinker.Attrib[2] = 206;
	float DamageLuck = (0.1 * (tinker.Luck[0]));
	float RangedDmgVulLuck = (0.05 * (1.0 + (-1.0*(tinker.Luck[1]))));
	float MeleeDmgVulLuck = (0.05 * (1.0 + (-1.0*(tinker.Luck[2]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.1 + DamageLuck;
			tinker.Value[1] = 1.05 + RangedDmgVulLuck;
			tinker.Value[2] = 1.05 + MeleeDmgVulLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.15 + DamageLuck;
			tinker.Value[1] = 1.05 + RangedDmgVulLuck;
			tinker.Value[2] = 1.05 + MeleeDmgVulLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.2 + DamageLuck;
			tinker.Value[1] = 1.05 + RangedDmgVulLuck;
			tinker.Value[2] = 1.05 + MeleeDmgVulLuck;
		}
	}
}


static void TinkerMeleeRapidSwing(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_MeleeRapidSwing");
	tinker.Attrib[0] = 2; //damage
	tinker.Attrib[1] = 6; //attackspeed
	//less damage
	//but faster attackspeed
	//inverts the luck
	float DamageLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[0]))));
	float AttackspeedLuck = (0.1 * (tinker.Luck[1]));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 0.95 - DamageLuck;
			tinker.Value[1] = 0.9 - AttackspeedLuck;
		}
		case 1:
		{
			tinker.Value[0] = 0.85 - DamageLuck;
			tinker.Value[1] = 0.8 - AttackspeedLuck;
		}
		case 2:
		{
			tinker.Value[0] = 0.8 - DamageLuck;
			tinker.Value[1] = 0.7 - AttackspeedLuck;
		}
	}
}

static void TinkerMeleeHeavySwing(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_MeleeHeavySwing");
	tinker.Attrib[0] = 2; //damage
	tinker.Attrib[1] = 6; //attackspeed
	//less damage
	//but faster attackspeed
	//inverts the luck
	float DamageLuck = (0.1 * (tinker.Luck[0]));
	float AttackspeedLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[1]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.25 + DamageLuck;
			tinker.Value[1] = 1.15 + AttackspeedLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.3 + DamageLuck;
			tinker.Value[1] = 1.2 + AttackspeedLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.4 + DamageLuck;
			tinker.Value[1] = 1.25 + AttackspeedLuck;
		}
	}
}

static void TinkerMeleeLongSwing(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_MeleeLongSwing");
	tinker.Attrib[0] = 2; //damage
	tinker.Attrib[1] = 6; //attackspeed
	tinker.Attrib[2] = 4001; //ExtraMeleeRange
	
	float DamageLuck = (0.1 * (tinker.Luck[0]));
	float AttackspeedLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[1]))));
	float ExtraRangeLuck = (0.1 * (tinker.Luck[2]));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.10 + DamageLuck;
			tinker.Value[1] = 1.15 + AttackspeedLuck;
			tinker.Value[2] = 1.15 + ExtraRangeLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.15 + DamageLuck;
			tinker.Value[1] = 1.2 + AttackspeedLuck;
			tinker.Value[2] = 1.2 + ExtraRangeLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.20 + DamageLuck;
			tinker.Value[1] = 1.25 + AttackspeedLuck;
			tinker.Value[2] = 1.35 + ExtraRangeLuck;
		}
	}
}

static void TinkerHastyMage(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_HasteMage");
	tinker.Attrib[0] = 6;
	tinker.Attrib[1] = 733;
	float AttackspeedLuck = (0.1 * (tinker.Luck[1]));
	float MageShootExtraCost = (0.15 * (1.0 + (-1.0*(tinker.Luck[1]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 0.8 + AttackspeedLuck;
			tinker.Value[1] = 1.25 + MageShootExtraCost;
		}
		case 1:
		{
			tinker.Value[0] = 0.75 + AttackspeedLuck;
			tinker.Value[1] = 1.35 + MageShootExtraCost;
		}
		case 2:
		{
			tinker.Value[0] = 0.7 + AttackspeedLuck;
			tinker.Value[1] = 1.45 + MageShootExtraCost;
		}
	}
}
static void TinkerHeavyMage(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_HeavyMage");
	tinker.Attrib[0] = 6;
	tinker.Attrib[1] = 733;
	tinker.Attrib[2] = 410;
	float AttackspeedLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[1]))));
	float MageShootExtraCost = (0.15 * (1.0 + (-1.0*(tinker.Luck[1]))));
	float DamageLuck = (0.1 * (tinker.Luck[2]));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.1 + AttackspeedLuck;
			tinker.Value[1] = 1.55 + MageShootExtraCost;
			tinker.Value[2] = 1.25 + DamageLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.15 + AttackspeedLuck;
			tinker.Value[1] = 1.65 + MageShootExtraCost;
			tinker.Value[2] = 1.3 + DamageLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.2 + AttackspeedLuck;
			tinker.Value[1] = 1.75 + MageShootExtraCost;
			tinker.Value[2] = 1.35 + DamageLuck;
		}
	}
}

static void TinkerConcentrationMage(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_ConcentratedMagic");
	tinker.Attrib[0] = 103;
	tinker.Attrib[1] = 410;
	float ProjectileSpeed = (0.1 * (tinker.Luck[0]));
	float DamageLuck = (0.1 * (tinker.Luck[1]));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 0.4 + ProjectileSpeed;
			tinker.Value[1] = 1.15 + DamageLuck;
		}
		case 1:
		{
			tinker.Value[0] = 0.45 + ProjectileSpeed;
			tinker.Value[1] = 1.2 + DamageLuck;
		}
		case 2:
		{
			tinker.Value[0] = 0.5 + ProjectileSpeed;
			tinker.Value[1] = 1.25 + DamageLuck;
		}
	}
}


static void TinkerTankMage(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_TankMage");
	tinker.Attrib[0] = 733;
	tinker.Attrib[1] = 410;
	tinker.Attrib[2] = 205;
	tinker.Attrib[3] = 206;
	float MageShotCost = (0.1 * (1.0 + (-1.0*(tinker.Luck[0]))));
	float DamageLuck = (0.1 * (tinker.Luck[1]));
	float RangedDmgLuck = (0.05 * (tinker.Luck[2]));
	float MeleeDmgLuck = (0.05 * (tinker.Luck[3]));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.15 + MageShotCost;
			tinker.Value[1] = 0.95 + DamageLuck;
			tinker.Value[2] = 0.95 - RangedDmgLuck;
			tinker.Value[3] = 0.95 - MeleeDmgLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.2 + MageShotCost;
			tinker.Value[1] = 0.93 + DamageLuck;
			tinker.Value[2] = 0.93 - RangedDmgLuck;
			tinker.Value[3] = 0.93 - MeleeDmgLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.25 + MageShotCost;
			tinker.Value[1] = 0.92 + DamageLuck;
			tinker.Value[2] = 0.9 - RangedDmgLuck;
			tinker.Value[3] = 0.9 - MeleeDmgLuck;
		}
	}
}


static void TinkerMedigun_FastHeal(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_FastHeal");
	tinker.Attrib[0] = 8; //more heal rate
	tinker.Attrib[1] = 9; //Less uber rate
	tinker.Attrib[2] = 4002; //Less Overheal
	float MoreHealRateLuck = (0.1 * (tinker.Luck[0]));
	float LessUberRateLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[1]))));
	float LessOverhealRateLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[2]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.15 + MoreHealRateLuck;
			tinker.Value[1] = 0.95 - LessUberRateLuck;
			tinker.Value[2] = 0.96 - LessOverhealRateLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.25 + MoreHealRateLuck;
			tinker.Value[1] = 0.92 - LessUberRateLuck;
			tinker.Value[2] = 0.95 - LessOverhealRateLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.35 + MoreHealRateLuck;
			tinker.Value[1] = 0.88 - LessUberRateLuck;
			tinker.Value[2] = 0.9 - LessOverhealRateLuck;
		}
	}
}
static void TinkerMedigun_Overhealer(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_Overhealer");
	tinker.Attrib[0] = 8;
	tinker.Attrib[1] = 4002; 
	float LessHealRateLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[0]))));
	float MoreOverhealLuck = (0.1 * (tinker.Luck[1]));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.05 - LessHealRateLuck;
			tinker.Value[1] = 1.1 + MoreOverhealLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.0 - LessHealRateLuck;
			tinker.Value[1] = 1.15 + MoreOverhealLuck;
		}
		case 2:
		{
			tinker.Value[0] = 0.95 - LessHealRateLuck;
			tinker.Value[1] = 1.20 + MoreOverhealLuck;
		}
	}
}


static void TinkerMedigun_Uberer(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_Uberer");
	tinker.Attrib[0] = 8;
	tinker.Attrib[1] = 9;
	float LessHealRate = (0.1 * (1.0 + (-1.0*(tinker.Luck[0]))));
	float MoreUberRate = (0.1 * (tinker.Luck[1]));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 0.9 - LessHealRate;
			tinker.Value[1] = 1.1 + MoreUberRate;
		}
		case 1:
		{
			tinker.Value[0] = 0.85 - LessHealRate;
			tinker.Value[1] = 1.15 + MoreUberRate;
		}
		case 2:
		{
			tinker.Value[0] = 0.8 - LessHealRate;
			tinker.Value[1] = 1.25 + MoreUberRate;
		}
	}
}


static void TinkerMedicWeapon_GlassyMedic(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_SharedGlassy");
	tinker.Attrib[0] = 8; //more heal rate
	tinker.Attrib[1] = 6; 
	tinker.Attrib[2] = 205;
	tinker.Attrib[3] = 206;
	float HealRateLuck = (0.1 * (tinker.Luck[0]));
	float AttackRateLuck = (0.1 * (tinker.Luck[1]));
	float RangedDmgVulLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[2]))));
	float MeleeDmgVulLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[3]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.05 + HealRateLuck;
			tinker.Value[1] = 0.9 - AttackRateLuck;
			tinker.Value[2] = 1.05 + RangedDmgVulLuck;
			tinker.Value[3] = 1.05 + MeleeDmgVulLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.1 + HealRateLuck;
			tinker.Value[1] = 0.86 - AttackRateLuck;
			tinker.Value[2] = 1.075 + RangedDmgVulLuck;
			tinker.Value[3] = 1.075 + MeleeDmgVulLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.15 + HealRateLuck;
			tinker.Value[1] = 0.84 - AttackRateLuck;
			tinker.Value[2] = 1.10 + RangedDmgVulLuck;
			tinker.Value[3] = 1.10 + MeleeDmgVulLuck;
		}
	}
}


static void TinkerMedicWeapon_BurstHealMedic(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_BurstHeal");
	tinker.Attrib[0] = 8; //more heal rate
	tinker.Attrib[1] = 6; 
	tinker.Attrib[2] = 97; 
	float HealRateLuck = (0.2 * (tinker.Luck[0]));
	float AttackRateLuck = (0.12 * (tinker.Luck[1]));
	float ReloadRateLuck = (0.12 * (tinker.Luck[2]));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.75 + HealRateLuck;
			tinker.Value[1] = 1.6 + AttackRateLuck;
			tinker.Value[2] = 1.6 + ReloadRateLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.9 + HealRateLuck;
			tinker.Value[1] = 1.75 + AttackRateLuck;
			tinker.Value[2] = 1.75 + ReloadRateLuck;
		}
		case 2:
		{
			tinker.Value[0] = 2.1 + HealRateLuck;
			tinker.Value[1] = 1.85 + AttackRateLuck;
			tinker.Value[2] = 1.85 + ReloadRateLuck;
		}
	}
}


static void TinkerBuilderLongSwing(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_BuilderLongSwing");
	tinker.Attrib[0] = 6; //attackspeed
	tinker.Attrib[1] = 264; //ExtraMeleeRange
	tinker.Attrib[2] = 4001; //ExtraMeleeRange
	
	float AttackspeedLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[0]))));
	float ExtraRangeLuck = (0.1 * (tinker.Luck[1]));

	tinker.Luck[2] = tinker.Luck[1];

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.25 + AttackspeedLuck;
			tinker.Value[1] = 1.5 + ExtraRangeLuck;
			tinker.Value[2] = 1.5 + ExtraRangeLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.35 + AttackspeedLuck;
			tinker.Value[1] = 1.5 + ExtraRangeLuck;
			tinker.Value[2] = 1.75 + ExtraRangeLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.4 + AttackspeedLuck;
			tinker.Value[1] = 1.5 + ExtraRangeLuck;
			tinker.Value[2] = 2.0 + ExtraRangeLuck;
		}
	}
}


static void TinkerBuilderRepairMaster(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_BuilderRepairMaster");
	tinker.Attrib[0] = 95; //RepairRate
	tinker.Attrib[1] = 107; //movementspeed
	
	float RepairRate = (0.1 * (tinker.Luck[0]));
	float MovementSpeed = (0.05 * (1.0 + (-1.0*(tinker.Luck[1]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.25 + RepairRate;
			tinker.Value[1] = 0.98 - MovementSpeed;
		}
		case 1:
		{
			tinker.Value[0] = 1.3 + RepairRate;
			tinker.Value[1] = 0.98 - MovementSpeed;
		}
		case 2:
		{
			tinker.Value[0] = 1.4 + RepairRate;
			tinker.Value[1] = 0.98 - MovementSpeed;
		}
	}
}



static void TinkerRangedSlowHeavyProj(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_SlowHeavyProj");
	tinker.Attrib[0] = 2; //damage
	tinker.Attrib[1] = 103; //ProjectileSpeed
	tinker.Attrib[2] = 6; //attackspeed
	
	float DamageLuck = (0.1 * (tinker.Luck[0]));
	float ProjectileSpeedLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[1]))));
	float AttackspeedLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[2]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.15 + DamageLuck;
			tinker.Value[1] = 0.7 - ProjectileSpeedLuck;
			tinker.Value[2] = 1.05 + AttackspeedLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.20 + DamageLuck;
			tinker.Value[1] = 0.65 - ProjectileSpeedLuck;
			tinker.Value[2] = 1.1 + AttackspeedLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.3 + DamageLuck;
			tinker.Value[1] = 0.6 - ProjectileSpeedLuck;
			tinker.Value[2] = 1.12 + AttackspeedLuck;
		}
	}
}

static void TinkerRangedFastProj(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_FastProj");
	tinker.Attrib[0] = 2; //damage
	tinker.Attrib[1] = 103; //ProjectileSpeed
	tinker.Attrib[2] = 6; //attackspeed
	
	float DamageLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[0]))));
	float ProjectileSpeedLuck = (0.1 * (tinker.Luck[1]));
	float AttackspeedLuck = (0.1 * (tinker.Luck[2]));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 0.9 - DamageLuck;
			tinker.Value[1] = 1.35 + ProjectileSpeedLuck;
			tinker.Value[2] = 0.95 - AttackspeedLuck;
		}
		case 1:
		{
			tinker.Value[0] = 0.9 - DamageLuck;
			tinker.Value[1] = 1.5 + ProjectileSpeedLuck;
			tinker.Value[2] = 0.93 - AttackspeedLuck;
		}
		case 2:
		{
			tinker.Value[0] = 0.85 - DamageLuck;
			tinker.Value[1] = 1.65 + ProjectileSpeedLuck;
			tinker.Value[2] = 0.9 - AttackspeedLuck;
		}
	}
}


static void TinkerIntensiveClip(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_IntensiveClip");
	tinker.Attrib[0] = 6; //attackspeed
	tinker.Attrib[1] = 4; //Clipsize
	tinker.Attrib[2] = 97; //ReloadSpeed
	
	float AttackSpeedLuck = (0.07 * (tinker.Luck[0]));
	float ClipSizeLuck = (0.15 * (tinker.Luck[1]));
	float ReloadSpeedLuck = (0.15 * (1.0 + (-1.0*(tinker.Luck[2]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 0.95 - AttackSpeedLuck;
			tinker.Value[1] = 1.5 + ClipSizeLuck;
			tinker.Value[2] = 1.7 + ReloadSpeedLuck;
		}
		case 1:
		{
			tinker.Value[0] = 0.93 - AttackSpeedLuck;
			tinker.Value[1] = 1.65 + ClipSizeLuck;
			tinker.Value[2] = 1.8 + ReloadSpeedLuck;
		}
		case 2:
		{
			tinker.Value[0] = 0.92 - AttackSpeedLuck;
			tinker.Value[1] = 1.75 + ClipSizeLuck;
			tinker.Value[2] = 1.9 + ReloadSpeedLuck;
		}
	}
}

static void TinkerConcentratedClip(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_ConcentratedClip");
	tinker.Attrib[0] = 2; //Damage
	tinker.Attrib[1] = 97; //ReloadSpeed
	
	float ExtraDamage = (0.1 * (tinker.Luck[0]));
	float ReloadSpeedLuck = (0.2 * (1.0 + (-1.0*(tinker.Luck[1]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.15 + ExtraDamage;
			tinker.Value[1] = 1.35 + ReloadSpeedLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.2 + ExtraDamage;
			tinker.Value[1] = 1.4 + ReloadSpeedLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.25 + ExtraDamage;
			tinker.Value[1] = 1.5 + ReloadSpeedLuck;
		}
	}
}


static void TinkerHeavyTrigger(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_HeavyTrigger");
	tinker.Attrib[0] = 2; //Damage
	tinker.Attrib[1] = 6; //attackspeed
	tinker.Attrib[2] = 97; //Reload speed
	
	float ExtraDamage = (0.1 * (tinker.Luck[0]));
	float attackspeedSpeedLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[1]))));
	float reloadSpeedLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[2]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.2 + ExtraDamage;
			tinker.Value[1] = 1.1 + attackspeedSpeedLuck;
			tinker.Value[2] = 1.1 + reloadSpeedLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.25 + ExtraDamage;
			tinker.Value[1] = 1.15 + attackspeedSpeedLuck;
			tinker.Value[2] = 1.15 + reloadSpeedLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.3 + ExtraDamage;
			tinker.Value[1] = 1.2 + attackspeedSpeedLuck;
			tinker.Value[2] = 1.2 + reloadSpeedLuck;
		}
	}
}

static void TinkerSprayAndPray(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_SprayAndPray");
	tinker.Attrib[0] = 45; //BulletsPetShot
	tinker.Attrib[1] = 2; //damage
	
	float BulletPetShotBonus = (0.1 * (tinker.Luck[0]));
	float AccuracySuffering = (0.1 * (1.0 + (-1.0*(tinker.Luck[1]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.35 + BulletPetShotBonus;
			tinker.Value[1] = 0.85 - AccuracySuffering;
		}
		case 1:
		{
			tinker.Value[0] = 1.4 + BulletPetShotBonus;
			tinker.Value[1] = 0.83 - AccuracySuffering;
		}
		case 2:
		{
			tinker.Value[0] = 1.45 + BulletPetShotBonus;
			tinker.Value[1] = 0.8 - AccuracySuffering;
		}
	}
}

static void TinkerSmallerSmarterBullets(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_SmallerSmarterBullets");
	tinker.Attrib[0] = 2; //Less Damage
	tinker.Attrib[1] = 6; //Faster Shooting
	tinker.Attrib[2] = 97; //faster Reload
	
	float DamageLuck = (0.1 * (tinker.Luck[0]));
	float AttackSpeedLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[1]))));
	float FasterReloadLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[2]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 0.85 + DamageLuck;
			tinker.Value[1] = 0.8 + AttackSpeedLuck;
			tinker.Value[2] = 0.8 + FasterReloadLuck;
		}
		case 1:
		{
			tinker.Value[0] = 0.8 + DamageLuck;
			tinker.Value[1] = 0.7 + AttackSpeedLuck;
			tinker.Value[2] = 0.7 + FasterReloadLuck;
		}
		case 2:
		{
			tinker.Value[0] = 0.7 + DamageLuck;
			tinker.Value[1] = 0.6 + AttackSpeedLuck;
			tinker.Value[2] = 0.6 + FasterReloadLuck;
		}
	}
}


public void Anvil_Menu(int client)
{
	if(dieingstate[client] == 0)
	{	
		CancelClientMenu(client);
		SetStoreMenuLogic(client, false);
		static char buffer[128];
		Menu menu = new Menu(Anvil_MenuH);
		AnyMenuOpen[client] = 1;

		SetGlobalTransTarget(client);
		
		menu.SetTitle("%t", "Anvil Menu Main");

		/*FormatEx(buffer, sizeof(buffer), "%t", "Re-Roll Weapon Stats");
		menu.AddItem("-1", buffer);*/
		
		FormatEx(buffer, sizeof(buffer), "%t", "Custom Anvil Menu Main");
		menu.AddItem("-4", buffer);

		FormatEx(buffer, sizeof(buffer), "%t", "Remove Weapon Stats");
		menu.AddItem("-2", buffer);

		FormatEx(buffer, sizeof(buffer), "%t", "Display Current Stats");
		menu.AddItem("-3", buffer);
		
		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
}

public int Anvil_MenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
			if(IsValidClient(client))
				AnyMenuOpen[client] = 0;
		}
		case MenuAction_Select:
		{
			AnyMenuOpen[client] = 0;
			ResetStoreMenuLogic(client);
			char buffer[24];
			menu.GetItem(choice, buffer, sizeof(buffer));
			int id = StringToInt(buffer);
			int weapon;
			int anvil;
			int owner;
			
			if(IsValidClient(client))
			{
				weapon = EntRefToEntIndex(ClickedWithWeapon[client]);
				anvil = EntRefToEntIndex(AnvilClickedOn[client]);
			}
			else
				return 0;

			if(!IsValidEntity(weapon) || !IsValidEntity(anvil))
				return 0;
			else
			{
				owner = GetEntPropEnt(anvil, Prop_Send, "m_hOwnerEntity");
			}

			switch(id)
			{
				case -1:
				{
					Blacksmith_BuildingUsed_Internal(weapon, anvil, client, owner, false);
				}
				case -2:
				{
					Blacksmith_BuildingUsed_Internal(weapon, anvil, client, owner, true);
				}
				case -3:
				{
					Blacksmith_ExtraDesc(client, StoreWeapon[weapon]);
				}
				case -4:
				{
					Blacksmith_BuildingUsed_Internal_Custom(weapon, anvil, client, owner);
				}
			}
		}
		case MenuAction_Cancel:
		{
			ResetStoreMenuLogic(client);
		}
	}
	return 0;
}

static void Tinker_MS_Sharpness(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_MS_Sharpness");
	tinker.Attrib[0] = 2;
	float DamageLuck = (0.1 * (tinker.Luck[0]));
	
	switch(rarity)
	{
		case 0:tinker.Value[0] = 1.1 + DamageLuck;
		case 1:tinker.Value[0] = 1.15 + DamageLuck;
		case 2:tinker.Value[0] = 1.2 + DamageLuck;
		case 3:tinker.Value[0] = 1.25 + DamageLuck;
		case 4:tinker.Value[0] = 1.32 + DamageLuck;
	}
}

static void Tinker_MS_Smite(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_MS_Smite");
	tinker.Attrib[0] = 2;
	tinker.Attrib[1] = 410;
	tinker.Attrib[2] = 41;
	tinker.CustomMode[1]=1;
	tinker.CustomMode[2]=1;
	float DamageLuck = (0.01 * (tinker.Luck[0]));
	float CritLuck = (0.025 * (tinker.Luck[1]));
	float ChargeRate = (0.1 * (tinker.Luck[2]));
	
	switch(rarity)
	{
		case 0:{tinker.Value[0] = 1.1 + DamageLuck;tinker.Value[1] = 1.2 + CritLuck;tinker.Value[2] = 2.0 + ChargeRate;}
		case 1:{tinker.Value[0] = 1.12 + DamageLuck;tinker.Value[1] = 1.26 + CritLuck;tinker.Value[2] = 1.75 + ChargeRate;}
		case 2:{tinker.Value[0] = 1.15 + DamageLuck;tinker.Value[1] = 1.31 + CritLuck;tinker.Value[2] = 1.5 + ChargeRate;}
		case 3:{tinker.Value[0] = 1.2 + DamageLuck;tinker.Value[1] = 1.35 + CritLuck;tinker.Value[2] = 1.25 + ChargeRate;}
		case 4:{tinker.Value[0] = 1.35 + DamageLuck;tinker.Value[1] = 1.43 + CritLuck;tinker.Value[2] = 1.1 + ChargeRate;}
	}
}

static void Tinker_MS_SweepingEdge(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_MS_SweepingEdge");
	tinker.Attrib[0] = 99;
	tinker.Attrib[1] = 4;
	tinker.Attrib[2] = 425;
	tinker.CustomMode[0]=1;
	tinker.CustomMode[1]=1;
	tinker.CustomMode[2]=1;
	tinker.Addition[1]=true;
	float RangeLuck = (0.1 * (tinker.Luck[0]));
	float MaxTargetLuck = (0.5 * (tinker.Luck[1]));
	float DamageLuck = (0.1 * (tinker.Luck[2]));

	switch(rarity)
	{
		case 0:{tinker.Value[0] = 1.25 + RangeLuck;tinker.Value[1] = 1.0 + MaxTargetLuck;tinker.Value[2] = 1.05 + DamageLuck;}
		case 1:{tinker.Value[0] = 1.5 + RangeLuck;tinker.Value[1] = 2.0 + MaxTargetLuck;tinker.Value[2] = 1.1 + DamageLuck;}
		case 2:{tinker.Value[0] = 1.75 + RangeLuck;tinker.Value[1] = 3.0 + MaxTargetLuck;tinker.Value[2] = 1.2 + DamageLuck;}
		case 3:{tinker.Value[0] = 2.0 + RangeLuck;tinker.Value[1] = 4.0 + MaxTargetLuck;tinker.Value[2] = 1.25 + DamageLuck;}
		case 4:{tinker.Value[0] = 2.5 + RangeLuck;tinker.Value[1] = 4.5 + MaxTargetLuck;tinker.Value[2] = 1.3 + DamageLuck;}
	}
}

static void Tinker_MS_QuickCharge(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_MS_QuickCharge");
	tinker.Attrib[0] = 41;
	tinker.Attrib[1] = 6;
	tinker.Attrib[2] = 425;
	tinker.CustomMode[0]=1;
	tinker.CustomMode[2]=1;
	float ChargeRate = (0.01 * (1.0 + (-1.0*(tinker.Luck[0]))));
	float AttackSpeedLuck = (0.1 * (tinker.Luck[1]));
	float DamageLuck = (0.1 * (tinker.Luck[2]));

	switch(rarity)
	{
		case 0:{tinker.Value[0] = 0.9 + ChargeRate;tinker.Value[1] = 0.9 - AttackSpeedLuck;tinker.Value[2] = 0.7 + DamageLuck;}
		case 1:{tinker.Value[0] = 0.87 + ChargeRate;tinker.Value[1] = 0.87 - AttackSpeedLuck;tinker.Value[2] = 0.72 + DamageLuck;}
		case 2:{tinker.Value[0] = 0.8 + ChargeRate;tinker.Value[1] = 0.85 - AttackSpeedLuck;tinker.Value[2] = 0.75 + DamageLuck;}
		case 3:{tinker.Value[0] = 0.65 + ChargeRate;tinker.Value[1] = 0.8 - AttackSpeedLuck;tinker.Value[2] = 0.77 + DamageLuck;}
		case 4:{tinker.Value[0] = 0.5 + ChargeRate;tinker.Value[1] = 0.75 - AttackSpeedLuck;tinker.Value[2] = 0.8 + DamageLuck;}
	}
}

static void Tinker_MS_BaneofArthropods(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_MS_BaneofArthropods");
	tinker.Attrib[0] = 2;
	tinker.Attrib[1] = 411;
	tinker.Addition[1]=true;
	tinker.CustomMode[1]=1;
	float DamageLuck = (0.1 * (tinker.Luck[0]));
	float SilencedLuck = (0.5 * (tinker.Luck[1]));

	switch(rarity)
	{
		case 0:{tinker.Value[0] = 0.65 + DamageLuck;tinker.Value[1] = 1.0 + SilencedLuck;}
		case 1:{tinker.Value[0] = 0.7 + DamageLuck;tinker.Value[1] = 1.5 + SilencedLuck;}
		case 2:{tinker.Value[0] = 0.72 + DamageLuck;tinker.Value[1] = 2.0 + SilencedLuck;}
		case 3:{tinker.Value[0] = 0.75 + DamageLuck;tinker.Value[1] = 3.0 + SilencedLuck;}
		case 4:{tinker.Value[0] = 0.79 + DamageLuck;tinker.Value[1] = 4.0 + SilencedLuck;}
	}
}

static void Tinker_MS_FireAspect(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_MS_FireAspect");
	tinker.Attrib[0] = 2;
	tinker.Attrib[1] = 397;
	tinker.Addition[1]=true;
	tinker.CustomMode[1]=1;
	float DamageLuck = (0.1 * (tinker.Luck[0]));
	float FireLuck = (0.5 * (tinker.Luck[1]));

	switch(rarity)
	{
		case 0:{tinker.Value[0] = 0.62 + DamageLuck;tinker.Value[1] = 1.0 + FireLuck;}
		case 1:{tinker.Value[0] = 0.66 + DamageLuck;tinker.Value[1] = 2.0 + FireLuck;}
		case 2:{tinker.Value[0] = 0.71 + DamageLuck;tinker.Value[1] = 3.0 + FireLuck;}
		case 3:{tinker.Value[0] = 0.73 + DamageLuck;tinker.Value[1] = 5.0 + FireLuck;}
		case 4:{tinker.Value[0] = 0.76 + DamageLuck;tinker.Value[1] = 8.0 + FireLuck;}
	}
}

static void Tinker_MS_CurseofGlassy(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_MS_CurseOfGlassy");
	tinker.Attrib[0] = 2;
	tinker.Attrib[1] = 425;
	tinker.Attrib[2] = 205;
	tinker.Attrib[3] = 206;
	tinker.CustomMode[1]=1;
	float DamageLuck = (0.1 * (tinker.Luck[0]));
	float SweepingLuck = (0.1 * (tinker.Luck[1]));
	float RangedDmgVulLuck = (0.05 * (1.0 + (-1.0*(tinker.Luck[2]))));
	float MeleeDmgVulLuck = (0.05 * (1.0 + (-1.0*(tinker.Luck[3]))));

	switch(rarity)
	{
		case 0:{tinker.Value[0] = 1.1 + DamageLuck;tinker.Value[1] = 1.25 + SweepingLuck;tinker.Value[2] = 1.05 + RangedDmgVulLuck;tinker.Value[3] = 1.05 + MeleeDmgVulLuck;}
		case 1:{tinker.Value[0] = 1.3 + DamageLuck;tinker.Value[1] = 1.3 + SweepingLuck;tinker.Value[2] = 1.075 + RangedDmgVulLuck;tinker.Value[3] = 1.075 + MeleeDmgVulLuck;}
		case 2:{tinker.Value[0] = 1.4 + DamageLuck;tinker.Value[1] = 1.35 + SweepingLuck;tinker.Value[2] = 1.1 + RangedDmgVulLuck;tinker.Value[3] = 1.1 + MeleeDmgVulLuck;}
		case 3:{tinker.Value[0] = 1.5 + DamageLuck;tinker.Value[1] = 1.4 + SweepingLuck;tinker.Value[2] = 1.25 + RangedDmgVulLuck;tinker.Value[3] = 1.25 + MeleeDmgVulLuck;}
		case 4:{tinker.Value[0] = 1.6 + DamageLuck;tinker.Value[1] = 1.45 + SweepingLuck;tinker.Value[2] = 1.35 + RangedDmgVulLuck;tinker.Value[3] = 1.35 + MeleeDmgVulLuck;}
	}
}

static void Tinker_SR_ExplosiveHeadshot(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_SR_ExplosiveHeadshot");
	tinker.Attrib[0] = Attrib_ExplosiveHeadshot;
	tinker.Attrib[1] = 2;
	tinker.Attrib[2] = 6;
	float EHSLuck = (0.25 * (tinker.Luck[0]));
	float DamageLuck = (0.1 * (tinker.Luck[1]));
	float AttackSpeedLuck = (0.1 * (tinker.Luck[2]));

	switch(rarity)
	{
		case 0:{tinker.Value[0] = 1.0 + EHSLuck;tinker.Value[1] = 0.6 + DamageLuck;tinker.Value[2] = 2.0 - AttackSpeedLuck;}
		case 1:{tinker.Value[0] = 1.25 + EHSLuck;tinker.Value[1] = 0.7 + DamageLuck;tinker.Value[2] = 1.75 - AttackSpeedLuck;}
		case 2:{tinker.Value[0] = 1.5 + EHSLuck;tinker.Value[1] = 0.8 + DamageLuck;tinker.Value[2] = 1.5 - AttackSpeedLuck;}
	}
}
static void Tinker_SR_KillerFocus(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_SR_KillerFocus");
	tinker.Attrib[0] = 41;
	tinker.Attrib[1] = 2;
	float ChargeRate = (0.2 * (tinker.Luck[0]));
	float DamageLuck = (0.2 * (tinker.Luck[1]));

	switch(rarity)
	{
		case 0:{tinker.Value[0] = 1.0 + ChargeRate;tinker.Value[1] = 0.7 + DamageLuck;}
		case 1:{tinker.Value[0] = 1.1 + ChargeRate;tinker.Value[1] = 0.75 + DamageLuck;}
		case 2:{tinker.Value[0] = 1.2 + ChargeRate;tinker.Value[1] = 0.85 + DamageLuck;}
	}
}

static void Tinker_SR_SuperCoolingChamber(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_SR_SuperCoolingChamber");
	tinker.Attrib[0] = Attrib_DamageBonusFullCharge;
	tinker.Attrib[1] = 6;
	tinker.Attrib[2] = 41;
	float FullChargeDMGLuck = (0.5 * (tinker.Luck[0]));
	float AttackSpeedLuck = (0.25 * (1.0 + (-1.0*(tinker.Luck[1]))));
	float ChargeRate = (0.35 * (1.0 + (-1.0*(tinker.Luck[2]))));

	switch(rarity)
	{
		case 0:{tinker.Value[0] = 1.3 + FullChargeDMGLuck;tinker.Value[1] = 1.4 + AttackSpeedLuck;tinker.Value[2] = 0.7 - ChargeRate;}
		case 1:{tinker.Value[0] = 1.5 + FullChargeDMGLuck;tinker.Value[1] = 1.5 + AttackSpeedLuck;tinker.Value[2] = 0.7 - ChargeRate;}
		case 2:{tinker.Value[0] = 1.7 + FullChargeDMGLuck;tinker.Value[1] = 1.6 + AttackSpeedLuck;tinker.Value[2] = 0.7 - ChargeRate;}
	}
}

static void Tinker_SR_DepletedUranium(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_SR_DepletedUranium");
	tinker.Attrib[0] = 2;
	tinker.Attrib[1] = 6;
	tinker.Attrib[2] = 41;
	float DamageLuck = (0.3 * (tinker.Luck[0]));
	float AttackSpeedLuck = (0.25 * (tinker.Luck[1]));

	switch(rarity)
	{
		case 0:{tinker.Value[0] = 1.25 + DamageLuck;tinker.Value[1] = 1.3 - AttackSpeedLuck;tinker.Value[2] = 0.0;}
		case 1:{tinker.Value[0] = 1.3 + DamageLuck;tinker.Value[1] = 1.25 - AttackSpeedLuck;tinker.Value[2] = 0.0;}
		case 2:{tinker.Value[0] = 1.4 + DamageLuck;tinker.Value[1] = 1.15 - AttackSpeedLuck;tinker.Value[2] = 0.0;}
	}
}

static void Tinker_SR_HighSpeedFeedMechanism(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_SR_HighSpeedFeedMechanism");
	tinker.Attrib[0] = 2;
	tinker.Attrib[1] = 6;
	float DamageLuck = (0.325 * (1.0 + (-1.0*(tinker.Luck[0]))));
	float AttackSpeedLuck = (0.25 * (tinker.Luck[1]));

	switch(rarity)
	{
		case 0:{tinker.Value[0] = 0.9 - DamageLuck;tinker.Value[1] = 0.9 - AttackSpeedLuck;}
		case 1:{tinker.Value[0] = 0.95 - DamageLuck;tinker.Value[1] = 0.8 - AttackSpeedLuck;}
		case 2:{tinker.Value[0] = 1.0 - DamageLuck;tinker.Value[1] = 0.75 - AttackSpeedLuck;}
	}
}

static void Tinker_SR_HollowPointBullets(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_SR_HollowPointBullets");
	tinker.Attrib[0] = 2;
	tinker.Attrib[1] = 390;
	float DamageLuck = (0.25 * (tinker.Luck[0]));
	float HeadDMGLuck = (0.3 * (tinker.Luck[1]));

	switch(rarity)
	{
		case 0:{tinker.Value[0] = 0.75 + DamageLuck;tinker.Value[1] = 1.35 + HeadDMGLuck;}
		case 1:{tinker.Value[0] = 0.7 + DamageLuck;tinker.Value[1] = 1.5 + HeadDMGLuck;}
		case 2:{tinker.Value[0] = 0.675 + DamageLuck;tinker.Value[1] = 1.672 + HeadDMGLuck;}
	}
}

void DetectWeaponNoTinker(int weapon, int client)
{
	if(Attributes_Get(weapon, Attrib_DisallowTinker, 0.0) == 0.0)
		return;

	SetGlobalTransTarget(client);
	
	int account = GetSteamAccountID(client, false);
	if(!account)
	{
		return;
	}

	TinkerEnum tinker;
	int found = -1;
	if(Tinkers)
	{
		int length = Tinkers.Length;
		for(int a; a < length; a++)
		{
			Tinkers.GetArray(a, tinker);
			if(tinker.AccountId == account && tinker.StoreIndex == StoreWeapon[weapon])
			{
				found = a;
				break;
			}
		}
	}
	if(found == -1)
	{
		return;
	}

	tinker.Rarity = -1;
	Tinkers.Erase(found);
	PrintToChat(client, "%T", "Removed Tinker Attributes", client);
}

public bool Blacksmith_BulletTrace(int entity, int contentsMask, any iExclude)
{
	if(!entity)
		return true;
	
	if(entity == iExclude)
		return false;
	
	if(i_IsABuilding[entity])
	{
		if(i_IsABuilding[iExclude])
		{
			ObjectGeneric objstats = view_as<ObjectGeneric>(iExclude);
			if(objstats.m_iExtrabuilding1 == entity)
				return false;
			else if(objstats.m_iExtrabuilding2 == entity)
				return false;
		}
		
		//dont try to collide with your dependant building.
		if(EntRefToEntIndex(i_IDependOnThisBuilding[iExclude]) == entity)
			return false;
		
		if(EntRefToEntIndex(Building_Mounted[iExclude]) == entity)
			return false;
		
		return true;
	}
	
	// Below lines are default bulletandmeleetrace.
	if(entity > 0 && entity <= MaxClients) 
	{
		if(TeutonType[entity])
		{
			return false;
		}
	}
	
	if(b_ThisEntityIsAProjectileForUpdateContraints[entity])
	{
		return false;
	}
	else if(!b_NpcHasDied[entity])
	{
		if(!b_NpcIsTeamkiller[iExclude] && GetTeam(iExclude) == GetTeam(entity))
		{
			if(!b_AllowCollideWithSelfTeam[iExclude] && !b_AllowCollideWithSelfTeam[entity])
				return false;
		}
		else if(!b_IsCamoNPC[entity] && b_CantCollidie[entity] && b_CantCollidieAlly[entity])
		{
			return false;
		}
	}

	//if anything else is team
	if(b_IsARespawnroomVisualiser[entity])
	{
		return false;
	}	

	if(b_ThisEntityIgnored[entity])
	{
		return false;
	}
	
	if(!b_NpcIsTeamkiller[iExclude] && GetTeam(iExclude) == GetTeam(entity))
	{
		//buildings MUST pass through this if interacting with eacother.
		int Wasbuilding = 0;
		if(i_IsABuilding[iExclude])
			Wasbuilding++;

		if(i_IsABuilding[entity])
			Wasbuilding++;
		if(Wasbuilding == 2 || !b_AllowCollideWithSelfTeam[iExclude] || !b_AllowCollideWithSelfTeam[entity])
		{
			return false;
		}
	}
	
	if(Saga_EnemyDoomed(entity) && Saga_EnemyDoomed(iExclude))
	{
		return false;
	}
	
	if(YakuzaTestStunOnlyTrace())
	{
		if(f_TimeFrozenStill[entity] < GetGameTime(entity))
		{
			//The target was NOT stunned.
			return false;
		}
		//if its not a valid enemy ,ignore.
		if(!IsValidEnemy(iExclude, entity, true, false))
		{
			return false;
		}
	}
	
	if(!b_NpcHasDied[iExclude])
	{	
		//1 means we treat it as a bullet trace
		return NpcCollisionCheck(iExclude, entity, 1);
	}
	
	return !(entity == iExclude);
}

static char[] Query_GetTinkerAttrib(int Attrib, int CustomMode)
{
	char buffer[256];
	switch(Attrib)
	{
		case 1:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_PhysicalDamage");
		case 2:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_BaseDamage");
		case 3, 4:
		{
			if(CustomMode==1)
				FormatEx(buffer, sizeof(buffer), "TinkerAttrib_SweepingEdge_MaxHit");
			else
				FormatEx(buffer, sizeof(buffer), "TinkerAttrib_ClipSize");
		}
		case 5, 6:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_FireRate");
		case 8:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_HealingRate");
		case 10, 9:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_UberChargeRate");
		case 16:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_HealthOnHit");
		case 26:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_MaxHealth");
		case 41:
		{
			if(CustomMode==1)
				FormatEx(buffer, sizeof(buffer), "TinkerAttrib_SweepingEdge_ChargeRate");
			else
				FormatEx(buffer, sizeof(buffer), "TinkerAttrib_ChargeRate");
		}
		case 45:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_BulletsPerShot");
		case 54, 107:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_MovementSpeed");
		case 57:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_HealthRegen");
		case 95:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_RepairRate");
		case 96, 97:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_ReloadSpeed");
		case 99, 100:
		{
			if(CustomMode==1)
				FormatEx(buffer, sizeof(buffer), "TinkerAttrib_SweepingEdgeRange");
			else
				FormatEx(buffer, sizeof(buffer), "TinkerAttrib_BlastRadius");
		}
		case 101, 102:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_ProjectileSpeed");
		case 103, 104:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_ProjectileRange");
		case 106:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_BulletSpread");
		case 149:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_BleedDuration");
		case 205:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_RangedResistance");
		case 206:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_MeleeResistance");
		case 252:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_KnockbackResistance");
		case 287:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_SentryDamage");
		case 319:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_BuffDuration");
		case 326:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_JumpHeight");
		case 343:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_SentryFiringSpeed");
		case 397:
		{
			if(CustomMode==1)
				FormatEx(buffer, sizeof(buffer), "TinkerAttrib_FireAspect");
		}
		case 410:
		{
			if(CustomMode==1)
				FormatEx(buffer, sizeof(buffer), "TinkerAttrib_JumpCrit");
			else
				FormatEx(buffer, sizeof(buffer), "TinkerAttrib_BaseDamage");
		}
		case 411:
		{
			if(CustomMode==1)
				FormatEx(buffer, sizeof(buffer), "TinkerAttrib_BaneofArthropods");
		}
		case 412:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_Resistance");
		case 425:
		{
			if(CustomMode==1)
				FormatEx(buffer, sizeof(buffer), "TinkerAttrib_SweepingEdgeDamage");
		}
		case 733:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_MagicCost");
		case 4001:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_ExtraMeleeRange");
		case 4002:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_Overheal");
		case Attrib_TerrianRes:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_TerrianResistance");
		case Attrib_ElementalDef:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_ElementalResistance");
		case Attrib_SlowImmune:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_SlowResistance");
		case Attrib_ObjTerrianAbsorb:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_BuildingTerrianAbsorb");
		case Attrib_SetArchetype:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_WeaponArchetype");
		case 4019:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_MaxMana");
		case Attrib_ExplosiveHeadshot:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_ExplosiveHeadshot");
		case Attrib_DamageBonusFullCharge:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_FullChargeDamage");
		case 390:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_HeadshotDamage");
	}
	return buffer;
}