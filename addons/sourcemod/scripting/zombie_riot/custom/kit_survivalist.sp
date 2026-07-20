#pragma semicolon 1
#pragma newdecls required

enum {
	Survivalist_Revive_None,
	Survivalist_Revive_Cooltime,
	Survivalist_Revive_NotEnoughHealth,
	Survivalist_Revive_Disabled
};

enum struct BasicTraceLogic {
	int   Client;
	float StartPoint[3];
	float EndPoint[3];
	float Angles[3];
	float Distance;
	bool  TraceHit;
	
	void DoForwardTraceRay(float distance = -1.0, TraceEntityFilter filter)
	{
		if (filter == INVALID_FUNCTION)
			filter = KitSurvivalist_TraceWallsOnly;
		
		float angles[3], startPoint[3], endPoint[3];
		GetClientEyePosition(this.Client, startPoint);
		GetClientEyeAngles(this.Client, angles);
		
		if(distance != -1.0)
			this.Distance = distance;
		
		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(this.Client);
		Handle trace = TR_TraceRayFilterEx(startPoint, angles, 11, RayType_Infinite, filter, this.Client);
		
		if (TR_DidHit(trace))
		{
			TR_GetEndPosition(endPoint, trace);
			delete trace;
			
			if (distance != -1.0)
				ConformLineDistance(endPoint, startPoint, endPoint, distance);
			
			this.StartPoint = startPoint;
			this.EndPoint = endPoint;
			this.TraceHit = true;
			this.Angles = angles;
		}
		else
		{
			delete trace;
		}
		FinishLagCompensation_Base_boss();
	}
}

static Handle WeaponTimer[MAXPLAYERS + 1];
static float  UpdateHudAt[MAXPLAYERS + 1];

static float  ReservedHealth[MAXPLAYERS + 1];
static int    WeaponLevel[MAXPLAYERS + 1];

static float  ReviveCooltime[MAXPLAYERS + 1];
static int    ReviveRound[MAXPLAYERS + 1];
static bool   ReviveRaid[MAXPLAYERS + 1];

static int TracerIndex;

void KitSurvivalist_MapStart()
{
	TracerIndex = PrecacheModel("materials/sprites/spotlight.vmt");
	PrecacheSound("weapons/grenade_launcher_shoot.wav");
	PrecacheSound("items/medcharge4.wav");
	
	ZeroFloat(UpdateHudAt);
	ZeroFloat(ReservedHealth);
	Zero(WeaponLevel);
	ZeroFloat(ReviveCooltime);
	Zero(ReviveRound);
	Zero(ReviveRaid);
}

void KitSurvivalist_Enable(int client, int weapon)
{
	switch (i_CustomWeaponEquipLogic[weapon])
	{
		case WEAPON_KIT_SURVIVALIST:
		{
			WeaponLevel[client] = RoundFloat(Attributes_Get(weapon, 868, 0.0));
			if(WeaponLevel[client] < 0)
			{
				WeaponLevel[client] = 0;
			}
			
			if (WeaponTimer[client] != null)
			{
				delete WeaponTimer[client];
				WeaponTimer[client] = null;
			}
			
			DataPack pack;
			WeaponTimer[client] = CreateDataTimer(0.1, KitSurvivalist_Timer, pack, TIMER_REPEAT);
			pack.WriteCell(GetClientUserId(client));
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
	}
}

public void KitSurvivalist_Unequip(int client)
{
	delete WeaponTimer[client];
}

static Action KitSurvivalist_Timer(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if (!client || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		WeaponTimer[client] = null;
		return Plugin_Stop;
	}
	
	KitSurvivalist_UpdateHud(client);
	
	return Plugin_Continue;
}

static void KitSurvivalist_UpdateHud(int client, bool immediate = false)
{
	// Short circult evaluation.
	if (!immediate && UpdateHudAt[client] > GetGameTime())
		return;
	
	char buffer[256];
	if (WeaponLevel[client] >= 1)
	{
		FormatEx(buffer, sizeof(buffer), "Reserved Health [+%d]", RoundToCeil(ReservedHealth[client]));
	}
	
	if (WeaponLevel[client] >= 3)
	{
		switch (KitSurvivalist_RefillHealthState(client))
		{
			case Survivalist_Revive_Disabled:
			{
				Format(buffer, sizeof(buffer), "%s\nRevive: Disabled", buffer);
			}
			case Survivalist_Revive_Cooltime:
			{
				float cooltime = ReviveCooltime[client] - GetGameTime();
				Format(buffer, sizeof(buffer), "%s\nRevive: %.1f (s)", buffer, cooltime);
			}
			case Survivalist_Revive_NotEnoughHealth:
			{
				Format(buffer, sizeof(buffer), "%s\nRevive: More Health to Use", buffer);
			}
			case Survivalist_Revive_None:
			{
				Format(buffer, sizeof(buffer), "%s\nRevive: Ready", buffer);
			}
		}
	}
	
	if (buffer[0])
		PrintHintText(client, "%s", buffer);
	
	UpdateHudAt[client] = GetGameTime() + 0.5;
}

/**
 * attack2 function primary weapon.
 */
public void KitSurvivalist_Primary_M2(int client, int weapon, bool crit, int slot)
{
	if (Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}
	
	Rogue_OnAbilityUse(client, weapon);
	Ability_Apply_Cooldown(client, slot, 35.0);
	
	//okay, interesting
	float damage = WeaponLevel[weapon] > 3 ? 200.0 : 150.0;
	damage *= Attributes_Get(weapon, 335, 1.0);		
	damage *= Attributes_Get(weapon, 1, 1.0);		
	damage *= Attributes_Get(weapon, 2, 1.0);
	
	BasicTraceLogic Trace;
	Trace.Client = client;
	Trace.DoForwardTraceRay(3000.0, KitSurvivalist_Grenade_TraceFilter);
	Offset_Vector({ 60.9, 13.1, -15.1 }, Trace.Angles, Trace.StartPoint);
	
	TE_SetupBeamPoints(Trace.StartPoint, Trace.EndPoint, TracerIndex, 0, 0, 0, 0.2, 5.0, 5.0, 0, 1.0, { 111, 79, 40, 255 }, 3);
	TE_SendToAll(0.0);
	
	TE_Particle("ExplosionCore_MidAir", Trace.EndPoint, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	
	Explode_Logic_Custom(damage, client, client, weapon, Trace.EndPoint, 200.0, 0.75);
	
	EmitSoundToAll("weapons/grenade_launcher_shoot.wav", weapon, SNDCHAN_WEAPON);
}

public void KitSurvivalist_Melee_M2(int client, int weapon, bool crit, int slot)
{
	if (Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}
	
	int health = GetEntProp(client, Prop_Send, "m_iHealth");
	int maxHealth = SDKCall_GetMaxHealth(client);
	
	float missing = float(maxHealth - health);
	if (missing <= 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return;
	}
	
	float healing = ReservedHealth[client];
	if (healing > missing)
		healing = missing;
	
	ReservedHealth[client] -= healing;
	if (ReservedHealth[client] < 0.0)
		ReservedHealth[client] = 0.0;
	
	HealEntityGlobal(client, client, healing, 1.0, 0.5, _);
	ClientCommand(client, "playgamesound items/smallmedkit1.wav");
	
	MakePlayerGiveResponseVoice(client, 1); //haha!
	
	Rogue_OnAbilityUse(client, weapon);
	Ability_Apply_Cooldown(client, slot, 30.0);
}

public void KitSurvivalist_OnDealDamage_Melee(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int zr_custom_damage)
{
	if(CheckInHud())
		return;
	
	if(zr_custom_damage & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED)
		return;
	
	KitSurvivalist_GiveReservedHealth(attacker);
	KitSurvivalist_UpdateHud(attacker, true);
}

public void KitSurvivalist_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, int equipped_weapon, float damagePosition[3], int zr_custom_damage)
{
	// Hmm.. I need some description about what this do
	if (CheckInHud())
		return;
	
	if (victim == attacker)
		return;
	
	int health = GetClientHealth(victim);
	if (health < damage) {
		if (KitSurvivalist_RefillHealthState(victim) > Survivalist_Revive_None)
			return;
		
		// Ignore this damage. then set health to 1.
		damage = 0.0;
		SetEntityHealth(victim, 1);
		
		ReviveRound[victim] = Waves_GetRoundScale();
		ReviveRaid[victim] = RaidbossIgnoreBuildingsLogic(1);
		
		// set cooltime first before refill health
		// to prevent reapply.
		ReviveCooltime[victim] = GetGameTime() + 180.0;
		
		KitSurvivalist_RefillHealth(victim);
	}
}

static void KitSurvivalist_GiveReservedHealth(int client)
{
	float limit = float(SDKCall_GetMaxHealth(client)) * 0.5;
	if (ReservedHealth[client] >= limit)
		return;
	
	float health = 0.0;
	switch (WeaponLevel[client])
	{
		case 1, 2:
		{
			health = 12.5;
		}
		case 3:
		{
			health = 25.0;
		}
		case 4:
		{
			health = 30.0;
		}
		case 5:
		{
			health = 40.0;
		}
		case 6:
		{
			health = 50.0;
		}
	}
	
	if (WeaponLevel[client] > 6)
		health = 75.0;
	
	ReservedHealth[client] += health;
	if (ReservedHealth[client] > limit)
		ReservedHealth[client] = health;
}

static bool KitSurvivalist_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}

static bool KitSurvivalist_Grenade_TraceFilter(int entity, int contentsMask, any data)
{
	if(entity == data)
		return false;
	
	// Ignore client
	if(0 < entity <= MaxClients)
		return false;
	
	if(!b_NpcHasDied[entity])
	{
		if(IsValidEnemy(data, entity, true, true))
			return true;
	}
	
	return !entity;
}

static int KitSurvivalist_RefillHealthState(int client)
{
	int round = Waves_GetRoundScale();
	bool raid = RaidbossIgnoreBuildingsLogic(1);
	// Revive is only one chance on round or raid. 
	if (ReviveRound[client] == round && ReviveRaid[client] == raid)
		return Survivalist_Revive_Disabled;
	
	if (ReviveCooltime[client] > GetGameTime())
		return Survivalist_Revive_Cooltime;
	
	float maxhealth = float(ReturnEntityMaxHealth(client));
	if (ReservedHealth[client] < maxhealth * 0.2)
		return Survivalist_Revive_NotEnoughHealth;
	
	return Survivalist_Revive_None;
}

static void KitSurvivalist_RefillHealth(int client)
{
	GiveCompleteInvul(client, 1.5);
	
	float HealedAlly[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", HealedAlly);
	HealedAlly[2] += 70.0;
	float HealedAllyRand[3];
	
	for (int Repeat; Repeat < 20; Repeat++)
	{
		HealedAllyRand = HealedAlly;
		HealedAllyRand[0] += GetRandomFloat(-10.0, 10.0);
		HealedAllyRand[1] += GetRandomFloat(-10.0, 10.0);
		HealedAllyRand[2] += GetRandomFloat(-10.0, 10.0);
		TE_Particle("healthgained_red", HealedAllyRand, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);	
	}
	
	ClientCommand(client, "playgamesound items/smallmedkit1.wav");
	
	HealEntityGlobal(client, client, ReservedHealth[client], _, 4.0, HEAL_SELFHEAL);
	ReservedHealth[client] = 0.0;
}