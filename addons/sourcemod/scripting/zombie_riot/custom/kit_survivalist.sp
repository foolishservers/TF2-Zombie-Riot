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

public void KitSurvivalist_MapStart()
{
	TracerIndex = PrecacheModel("materials/sprites/spotlight.vmt");
	PrecacheSound("weapons/grenade_launcher_shoot.wav");
	
	ZeroFloat(UpdateHudAt);
	ZeroFloat(ReservedHealth);
	Zero(WeaponLevel);
	ZeroFloat(ReviveCooltime);
	Zero(ReviveRound);
	Zero(ReviveRaid);
}

public void KitSurvivalist_Enable(int client, int weapon)
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

bool KitSurvivalist_IsEnabled(int client)
{
	return (WeaponTimer[client] != null);
}

void KitSurvivalist_LastmanBuff(int client)
{
	ClientCommand(client, "playgamesound items/smallmedkit1.wav");
	
	float maxhealth = float(ReturnEntityMaxHealth(client));
	float healing = maxhealth - float(GetClientHealth(client));
	HealEntityGlobal(client, client, healing, _, 2.0, HEAL_SELFHEAL);
	
	if (WeaponLevel[client])
		ReservedHealth[client] = maxhealth;
	
	if (WeaponLevel[client] > 2)
	{
		ReviveRound[client] = -1;
		ReviveRaid[client] = false;
		ReviveCooltime[client] = GetGameTime();
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
	
	b_IsCannibal[client] = true;
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
		FormatEx(buffer, sizeof(buffer), "%T", "Survivalist Kit Reserved Health", client, RoundToCeil(ReservedHealth[client]));
	}
	
	if (WeaponLevel[client] >= 3)
	{
		switch (KitSurvivalist_RefillHealthState(client))
		{
			case Survivalist_Revive_Disabled:
			{
				Format(buffer, sizeof(buffer), "%s\n%T", buffer, "Survivalist Kit Disabled", client);
			}
			case Survivalist_Revive_Cooltime:
			{
				float cooltime = ReviveCooltime[client] - GetGameTime();
				Format(buffer, sizeof(buffer), "%s\n%T", buffer, "Survivalist Kit Cooltime", client, cooltime);
			}
			case Survivalist_Revive_NotEnoughHealth:
			{
				Format(buffer, sizeof(buffer), "%s\n%T", buffer, "Survivalist Kit Not Enough Health", client);
			}
			case Survivalist_Revive_None:
			{
				Format(buffer, sizeof(buffer), "%s\n%T", buffer, "Survivalist Kit Can Revive", client);
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
	
	float cooltime = 35.0;
	if (LastMann) {
		cooltime = 27.5;
	}
	else if (WeaponLevel[client] > 5) {
		cooltime = 30.0;
	}
	Rogue_OnAbilityUse(client, weapon);
	Ability_Apply_Cooldown(client, slot, cooltime);
	
	//okay, interesting
	float damage = WeaponLevel[client] > 3 ? 200.0 : 150.0;
	damage *= Attributes_Get(weapon, 335, 1.0);		
	damage *= Attributes_Get(weapon, 1, 1.0);		
	damage *= Attributes_Get(weapon, 2, 1.0);
	
	BasicTraceLogic Trace;
	Trace.Client = client;
	Trace.DoForwardTraceRay(3000.0, KitSurvivalist_Grenade_TraceFilter);
	
	CalcCorrectWeaponShootPosition({ 60.9, 13.1, -15.1 }, Trace.StartPoint, Trace.Angles);
	
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
	
	float cooltime = 30.0;
	if (LastMann) {
		cooltime = 25.0;
	}
	else if (WeaponLevel[client] > 5) {
		cooltime = 27.5;
	}
	Rogue_OnAbilityUse(client, weapon);
	Ability_Apply_Cooldown(client, slot, cooltime);
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
	float limit = float(SDKCall_GetMaxHealth(client));
	if (!LastMann)
		limit *= 0.5;
	
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
	
	if (LastMann)
		health *= 1.5;
	
	ReservedHealth[client] += health;
	if (ReservedHealth[client] > limit)
		ReservedHealth[client] = limit;
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
	if(0 < entity && entity <= MaxClients)
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
	GiveCompleteInvul(client, 2.0);
	
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