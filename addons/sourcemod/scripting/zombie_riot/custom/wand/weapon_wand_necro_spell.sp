#pragma semicolon 1
#pragma newdecls required

static bool NecroStaff_MinionDecrease[MAXPLAYERS + 1];
static int NecroStaff_MinionCount[MAXPLAYERS + 1];
static int NecroStaff_WeaponRef[MAXPLAYERS + 1] = { -1, ... };
static float Necro_Damage[MAXPLAYERS + 1] = {0.0, ...};

// Necromancy Starts.
void Wand_NerosSpell_Map_Precache()
{
	Zero(NecroStaff_MinionDecrease);
	Zero(NecroStaff_MinionCount);
	ZeroFloat(Necro_Damage);
	
	int size = sizeof(NecroStaff_WeaponRef);
	for (int i; i < size; i++)
		NecroStaff_WeaponRef[i] = -1;
}

public void Weapon_NecroStaff_Enable(int client, int weapon) {
	NecroStaff_WeaponRef[client] = EntIndexToEntRef(weapon);
	Weapon_NecroStaff_Reset(client, false);
}

public void Weapon_NecroStaff_OnSellOrUnequip(int client) {
	NecroStaff_WeaponRef[client] = -1;
	Weapon_NecroStaff_Reset(client, true);
}

static void Weapon_NecroStaff_Reset(int client, bool killMinion = false) {
	NecroStaff_MinionCount[client] = 0;
	
	for (int i; i < i_MaxcountNpcTotal; i++) {
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if (entity != INVALID_ENT_REFERENCE && i_NpcInternalId[entity] == NecroCombine_GetID() && IsEntityAlive(entity) && GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == client) {
			if (killMinion) {
				RequestFrame(KillNpc, i_ObjectsNpcsTotal[i]);
			}
			else {
				NecroStaff_MinionCount[client]++;
			}
		}
	}
	
	if (!killMinion)
		Weapon_NecroStaff_AdjustMaxHealth(client);
}

public void Weapon_NecroStaff_M2(int client, int weapon, bool &result, int slot) {
	if (NecroStaff_MinionCount[client] > 2) {
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "Too many minion!");
		return;
	}
	
	int mana_cost = 250;
	if (mana_cost <= Current_Mana[client]) {
		float cooldown = Ability_Check_Cooldown(client, slot);
		if (cooldown < 0.0) {
			Rogue_OnAbilityUse(client, weapon);
			Ability_Apply_Cooldown(client, slot, 4.0);
			
			Necro_Damage[client] = 1.0;
			
			Necro_Damage[client] *= Attributes_Get(weapon, 410, 1.0);
			
			Necro_Damage[client] *= 3.2;
			
			float vecOrigin[3];
			GetClientAbsOrigin(client, vecOrigin);
			
			TE_Particle(GetTeam(client) == TFTeam_Red ? "spell_cast_wheel_red" : "spell_cast_wheel_blue",
						vecOrigin, NULL_VECTOR, NULL_VECTOR,
						client, PATTACH_ABSORIGIN_FOLLOW, _, false);
			
			EmitSoundToAll("misc/halloween/spell_teleport.wav", client, SNDCHAN_AUTO);
			
			Weapon_NecroStaff_SpawnNPC(client);
			
			SDKhooks_SetManaRegenDelayTime(client, 1.0);
			Mana_Hud_Delay[client] = 0.0;
			
			Current_Mana[client] -= mana_cost;
			
			delay_hud[client] = 0.0;
		}
		else {
			if (cooldown <= 0.0)
				cooldown = 0.0;
			
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", cooldown);
		}
	}
	else {
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
}

public void Weapon_NecroStaff_R(int client, int weapon, bool &result, int slot) {
	if (Ability_Check_Cooldown(client, slot) > 0.0) {
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return;
	}
	
	Ability_Apply_Cooldown(client, slot, 0.5);
	
	for (int i; i < i_MaxcountNpcTotal; i++) {
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if (entity != INVALID_ENT_REFERENCE && i_NpcInternalId[entity] == NecroCombine_GetID() && IsEntityAlive(entity) && GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == client) {
			RequestFrame(KillNpc, i_ObjectsNpcsTotal[i]);
		}
	}
	
	Weapon_NecroStaff_AdjustMaxHealth(client, true);
}

static void Weapon_NecroStaff_SpawnNPC(int client) {
	float flPos[3], flAng[3];
	GetClientAbsOrigin(client, flPos);
	GetClientAbsAngles(client, flAng);
	
	int npc = NPC_CreateByName("npc_necromancy_combine", client, flPos, flAng, GetTeam(client));
	if (npc > MaxClients) {
		fl_Extra_Damage[npc] = Necro_Damage[client];
		
		/**
		 * This logic can be abused by purchasing survival upgrades and sell them after summoning..
		 * But damage isn't changed after summon.
		 */
		float flMaxHealth = float(ReturnEntityMaxHealth(client));
		
		flMaxHealth *= 0.5;
		
		float flHealthPenalty = (0.25 * float(NecroStaff_MinionCount[client]));
		
		flMaxHealth *= (1.0 / (1.0 - flHealthPenalty));
		
		SetEntProp(npc, Prop_Data, "m_iHealth", RoundToNearest(flMaxHealth));
		SetEntProp(npc, Prop_Data, "m_iMaxHealth", RoundToNearest(flMaxHealth));
		
		Weapon_NecroStaff_MinionSpawn(client);
	}
}

void Weapon_NecroStaff_MinionSpawn(int client) {
	NecroStaff_MinionCount[client]++;
	Weapon_NecroStaff_AdjustMaxHealth(client);
}

void Weapon_NecroStaff_MinionDeath(int client) {
	NecroStaff_MinionCount[client]--;
	if (NecroStaff_MinionCount[client] < 0)
		NecroStaff_MinionCount[client] = 0;
	
	Weapon_NecroStaff_AdjustMaxHealth(client, true);
}

static void Weapon_NecroStaff_AdjustMaxHealth(int client, bool decrease = false) {
	NecroStaff_MinionDecrease[client] = decrease;
	Store_ApplyAttribs(client);
}

void NecroStaffHp(int client, StringMap map) {
	if (map) {
		int weapon = EntRefToEntIndex(NecroStaff_WeaponRef[client]);
		if (IsValidEntity(weapon)) {
			float healthPenalty = 1.0 - (0.25 * float(NecroStaff_MinionCount[client]));
			
			float value;
			map.GetValue("26", value);
			map.SetValue("26", value * healthPenalty);
			
			float flCurrentHealth = float(GetEntProp(client, Prop_Send, "m_iHealth"));
			float flHealth = value * healthPenalty;
			if (flCurrentHealth > flHealth) {
				SetEntProp(client, Prop_Send, "m_iHealth", RoundToNearest(flHealth));
			}
			
			map.SetValue("5007", flHealth);
		}
		else if (NecroStaff_MinionDecrease[client]) {
			float flHealth = float(GetEntProp(client, Prop_Send, "m_iHealth"));
			
			float flMaxHealth;
			map.GetValue("5007", flMaxHealth);
			
			float flpercenthpfrommax = flHealth / flMaxHealth;
			if (flpercenthpfrommax < 1.0) {
				map.GetValue("26", flMaxHealth);
				flpercenthpfrommax *= flMaxHealth;
				SetEntProp(client, Prop_Send, "m_iHealth", RoundToNearest(flpercenthpfrommax));
			}
			
			NecroStaff_MinionDecrease[client] = false;
		}
	}
}