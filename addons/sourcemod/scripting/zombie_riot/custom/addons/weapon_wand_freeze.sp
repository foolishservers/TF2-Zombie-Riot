#pragma semicolon 1
#pragma newdecls required

#define WEAPON_WAND_FREEZE_M1_SOUND "weapons/icicle_deploy.wav"
#define WEAPON_WAND_FREEZE_M2_SOUND "misc/jingle_bells/jingle_bells_nm_0%d.wav"

#define WEAPON_WAND_FREEZE_RADIUS		175.0
#define WEAPON_WAND_FREEZE_DISTANCE		750.0

enum struct FreezeStorm {
	float flDamage;
	float flRadius;
	float flDuration;
	float flInterval;
	int WeaponRef;
}

static int   Wand_Freeze_CurrentPap[MAXPLAYERS + 1];
static int   Wand_Freeze_ParticleRef[MAXPLAYERS + 1] = { -1, ... };
static float Wand_Freeze_M2_Expire[MAXPLAYERS + 1];
// static FreezeStorm Wand_Freeze_Storm[MAXPLAYERS + 1];

/**
 * Helper function to reset array's values to specific values.
 */
stock void ResetArrayValue(any[] array, int length, any value)
{
    for(int i; i < length; i++)
    {
        array[i] = value;
    }
}

/**
 * Reset weapon pap level.
 */
public void Weapon_Wand_Freeze_MapStart()
{
	Zero(Wand_Freeze_CurrentPap);
	ZeroFloat(Wand_Freeze_M2_Expire);
	
	ResetArrayValue(Wand_Freeze_ParticleRef, sizeof(Wand_Freeze_ParticleRef), -1);
	
	PrecacheSound(WEAPON_WAND_FREEZE_M1_SOUND);
	
	for(int i = 1; i <= 5; i++)
	{
		char buffer[64];
		FormatEx(buffer, sizeof(buffer), WEAPON_WAND_FREEZE_M2_SOUND, i);
		PrecacheSound(buffer);
	}
}

/**
 * Store weapon pap level.
 * 
 * note: 868 and 122 are both used for recording pap level. So, you need to decide it.
 */
public void Weapon_Wand_Freeze_Enable(int client, int weapon)
{
	Wand_Freeze_CurrentPap[client] = RoundFloat(Attributes_Get(weapon, 868, 0.0));
	
	if(Wand_Freeze_CurrentPap[client] < 0)
		Wand_Freeze_CurrentPap[client] = 0;
}

/**
 * Primary Attack Function of the Icicle Staff.
 */
public void Weapon_Wand_Freeze_M1(int client, int weapon, bool crit, int slot)
{
	bool abilityActivated = (Wand_Freeze_M2_Expire[client] > GetGameTime());
	
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));
	
	if (abilityActivated)
		mana_cost = RoundToCeil(mana_cost * 1.5);
	
	if(mana_cost <= Current_Mana[client])
	{
		Current_Mana[client] -= mana_cost;
		
		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		Mana_Hud_Delay[client] = 0.0;
		
		// Increases amounts of clouds.
		int count = 1;
		switch(Wand_Freeze_CurrentPap[client])
		{
			case 3, 4:
				count += 1;
		}
		
		if(abilityActivated)
			count += 1;
		
		Weapon_Wand_Freeze_SharedAttack(client, weapon, count);
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
}

public void Weapon_Wand_Freeze_M2(int client, int weapon, bool crit, int slot)
{
	float cooldown = Ability_Check_Cooldown(client, slot);
	if(cooldown > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", cooldown);
		return;
	}
	
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));
	if(mana_cost > Current_Mana[client])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		return;
	}
	
	Current_Mana[client] -= mana_cost;
	SDKhooks_SetManaRegenDelayTime(client, 2.0);
	
	Rogue_OnAbilityUse(client, weapon);
	Ability_Apply_Cooldown(client, slot, 20.0);
	
	char buffer[64];
	FormatEx(buffer, sizeof(buffer), WEAPON_WAND_FREEZE_M2_SOUND, GetRandomInt(1, 5));
	EmitSoundToAll(buffer, client);
	
	float time = 4.0;
	switch(Wand_Freeze_CurrentPap[client])
	{
		case 1:
		{
			time = 4.5;
		}
		case 2:
		{
			time = 5.0;
		}
		case 3:
		{
			time = 5.5;
		}
		case 4:
		{
			time = 6.0;
		}
	}
	
	int particle = EntRefToEntIndex(Wand_Freeze_ParticleRef[client]);
	if(IsValidEntity(particle))
	{
		RemoveEntity(particle);
		Wand_Freeze_ParticleRef[client] = -1;
	}
	
	float flPos[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
	
	particle = ParticleEffectAt(flPos, "utaunt_snowring_space_parent", time);
	if(IsValidEntity(particle))
	{
		SetParent(client, particle);
		Wand_Freeze_ParticleRef[client] = EntIndexToEntRef(particle);
	}
	
	float gameTime = GetGameTime();
	if(gameTime < Wand_Freeze_M2_Expire[client])
	{
		Wand_Freeze_M2_Expire[client] += time;
	}
	else
	{
		Wand_Freeze_M2_Expire[client] = gameTime + time;
	}
}

/**
 * Secondary Attack Alt Function of the Icicle Staff.
 */
/*
public void Weapon_Wand_Freeze_M2_Alt(int client, int weapon, bool crit, int slot)
{
	float cooldown = Ability_Check_Cooldown(client, slot);
	if(cooldown > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", cooldown);
		return;
	}
	
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));
	
	if(Wand_Freeze_CurrentPap[client] > 1)
	{
		mana_cost = RoundToFloor(mana_cost * 2.5);
	}
	else
	{
		mana_cost = RoundToFloor(mana_cost * 2.0);
	}
	
	if(mana_cost > Current_Mana[client])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		return;
	}
	
	Current_Mana[client] -= mana_cost;
	SDKhooks_SetManaRegenDelayTime(client, 2.0);
	
	Rogue_OnAbilityUse(client, weapon);
	Ability_Apply_Cooldown(client, slot, 20.0);
	
	char buffer[64];
	FormatEx(buffer, sizeof(buffer), WEAPON_WAND_FREEZE_M2_SOUND, GetRandomInt(1, 5));
	EmitSoundToAll(buffer, client);
	
	float time = 4.0;
	float damage = 3.0;
	switch(Wand_Freeze_CurrentPap[client])
	{
		case 1:
		{
			time = 4.5;
		}
		case 2:
		{
			time = 5.0;
			damage = 3.5;
		}
		case 3:
		{
			time = 5.5;
			damage = 3.5;
		}
		case 4:
		{
			time = 6.0;
			damage = 4.0;
		}
	}
	
	damage *= Attributes_Get(weapon, 410, 1.0);
	
	float radius = 300.0;
	radius *= Attributes_Get(weapon, 103, 1.0);
	radius *= Attributes_Get(weapon, 104, 1.0);
	radius *= Attributes_Get(weapon, 475, 1.0);
	radius *= Attributes_Get(weapon, 101, 1.0);
	radius *= Attributes_Get(weapon, 102, 1.0);
	
	Wand_Freeze_Storm[client].flInterval = 0.0;
	Wand_Freeze_Storm[client].flDuration = GetGameTime() + time;
	Wand_Freeze_Storm[client].flDamage = damage;
	Wand_Freeze_Storm[client].flRadius = radius;
	Wand_Freeze_Storm[client].WeaponRef = EntIndexToEntRef(weapon);
	
	float flPos[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
	
	int particle = ParticleEffectAt(flPos, "utaunt_snowring_space_parent", time);
	SetParent(client, particle);
	
	SDKUnhook(client, SDKHook_PreThink, Weapon_Wand_Freeze_M2Think);
	SDKHook(client, SDKHook_PreThink, Weapon_Wand_Freeze_M2Think);
}
*/

/*
static void Weapon_Wand_Freeze_M2Think(int client)
{
	float gameTime = GetGameTime();
	if(gameTime > Wand_Freeze_Storm[client].flDuration)
	{
		SDKUnhook(client, SDKHook_PreThink, Weapon_Wand_Freeze_M2Think);
		return;
	}
	
	if(gameTime < Wand_Freeze_Storm[client].flInterval)
	{
		return;
	}
	
	Wand_Freeze_Storm[client].flInterval = gameTime + 0.1;
	
	float range = Wand_Freeze_Storm[client].flRadius;
	int weapon = EntRefToEntIndex(Wand_Freeze_Storm[client].WeaponRef);
	
	i_ExplosiveProjectileHexArray[weapon] = EP_DEALS_PLASMA_DAMAGE;
	i_ExplosiveProjectileHexArray[weapon] |= EP_IS_ICE_DAMAGE;
	
	Explode_Logic_Custom(Wand_Freeze_Storm[client].flDamage, client, client, weapon, _, range, 0.5, .maxtargetshit = 4);
	
	float vecSelf[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", vecSelf);
	vecSelf[2] += 15.0;
	
	TE_SetupBeamRingPoint(vecSelf, range * 2.0, (range * 2.0) + 0.5, g_Ruina_BEAM_Laser, g_Ruina_BEAM_Glow, 0, 10, 0.11, 25.0, 0.8, {50, 50, 250, 250}, 10, 0);
	TE_SendToAll(0.0);
}
*/

static void Weapon_Wand_Freeze_SharedAttack(int client, int weapon, int count)
{
	EmitSoundToClient(client, WEAPON_WAND_FREEZE_M1_SOUND);
	
	// Setup attributes.
	float range = WEAPON_WAND_FREEZE_DISTANCE;
	range *= Attributes_Get(weapon, 103, 1.0);
	range *= Attributes_Get(weapon, 104, 1.0);
	range *= Attributes_Get(weapon, 475, 1.0);
	range *= Attributes_Get(weapon, 101, 1.0);
	range *= Attributes_Get(weapon, 102, 1.0);
	
	float radius = WEAPON_WAND_FREEZE_RADIUS;
	radius *= Attributes_Get(weapon, 103, 1.0);
	radius *= Attributes_Get(weapon, 104, 1.0);
	radius *= Attributes_Get(weapon, 475, 1.0);
	radius *= Attributes_Get(weapon, 101, 1.0);
	radius *= Attributes_Get(weapon, 102, 1.0);
	
	float damage = 100.0;
	damage *= Attributes_Get(weapon, 410, 1.0);
	
	// Setup position.
	b_LagCompNPC_No_Layers = true;
	
	StartLagCompensation_Base_Boss(client);
	
	Handle swingTrace;
	float vecSwingForward[3];
	DoSwingTrace_Custom(swingTrace, client, vecSwingForward, range, false, 45.0, true);
	
	float pos[3];
	
	int target = TR_GetEntityIndex(swingTrace);	
	if (IsValidEnemy(client, target))
	{
		WorldSpaceCenter(target, pos);
	}
	else
	{
		delete swingTrace;
		
		int maxEntityHits = -1;
		DoSwingTrace_Custom(swingTrace, client, vecSwingForward, range, false, 45.0, true, maxEntityHits);
		
		TR_GetEndPosition(pos, swingTrace);
	}
	
	FinishLagCompensation_Base_boss(.client = client);
	
	delete swingTrace;
	
	float castTime = 1.1;
	switch (Wand_Freeze_CurrentPap[client])
	{
		case 1:
		{
			castTime = 1.0;
		}
		case 2:
		{
			castTime = 0.95;
		}
		case 3:
		{
			castTime = 0.9;
		}
		case 4:
		{
			castTime = 0.85;
		}
	}
	
	int color[4] = { 120, 120, 240, 120 };
	
	int viewmodelModel = EntRefToEntIndex(WeaponRef_viewmodel[client]);
	if(IsValidEntity(viewmodelModel))
	{
		float vecPos[3], vecAng[3];
		GetAttachment(viewmodelModel, "icicle_tip_0", vecPos, vecAng);
		TE_SetupBeamPoints(vecPos, pos, g_Ruina_Laser_BEAM, 0, 0, 0, 0.25, 2.5, 2.5, 1, 4.0, color, 0);
		TE_SendToAll();
	}
	else
	{
		float vecPos[3];
		GetClientEyePosition(client, vecPos);
		TE_SetupBeamPoints(vecPos, pos, g_Ruina_Laser_BEAM, 0, 0, 0, 0.25, 2.5, 2.5, 1, 4.0, color, 0);
		TE_SendToAll();
	}
	
	// ParticleEffectAt(pos, "utaunt_snowflakesaura_rings", castTime);
	
	TE_SetupBeamRingPoint(pos, radius, 0.0, g_Ruina_Laser_BEAM, g_Ruina_Laser_BEAM, 0, 1, castTime, 3.0, 0.1, color, 1, 0);
	TE_SendToClient(client);
	
	DataPack pack;
	CreateDataTimer(castTime, Timer_Weapon_Wand_Freeze_Spawn, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(1);
	pack.WriteCell(GetClientUserId(client));
	pack.WriteCell(EntIndexToEntRef(weapon));
	pack.WriteCell(count);
	pack.WriteFloat(radius);
	pack.WriteFloat(damage);
	pack.WriteFloatArray(pos, 3);
	pack.WriteFloat(castTime);
}

static Action Timer_Weapon_Wand_Freeze_Spawn(Handle timer, DataPack pack)
{
	pack.Reset();
	
	int count = pack.ReadCell();
	int client = GetClientOfUserId(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	
	if (!client || !IsPlayerAlive(client) || !IsValidEntity(weapon))
		return Plugin_Handled;
	
	int countMax = pack.ReadCell();
	float radius = pack.ReadFloat();
	float damage = pack.ReadFloat();
	
	float pos[3];
	pack.ReadFloatArray(pos, 3);
	
	float castTime = pack.ReadFloat();
	
	pack.Reset();
	pack.WriteCell(count);
	
	Weapon_Wand_Freeze_Spawn(client, weapon, countMax, count, radius, damage, pos, castTime);
	
	return Plugin_Continue;
}

static void Weapon_Wand_Freeze_Spawn(int client, int weapon, int countMax, int count, float radius, float damage, float pos[3], float castTime)
{
	Weapon_Wand_Freeze_Attack(client, weapon, pos, radius, damage);
	
	if(count >= countMax)
	{
		return;
	}
	else
	{
		// ParticleEffectAt(pos, "utaunt_snowflakesaura_rings", castTime);
		TE_SetupBeamRingPoint(pos, radius * 1.15, 0.0, g_Ruina_Laser_BEAM, g_Ruina_Laser_BEAM, 0, 1, castTime, 3.0, 0.1, { 120, 120, 240, 120 }, 1, 0);
		TE_SendToClient(client);
		
		// Increase radius and decrease damage each explode.
		// So they can hit multiple to one target.
		DataPack pack;
		CreateDataTimer(castTime, Timer_Weapon_Wand_Freeze_Spawn, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(count + 1);
		pack.WriteCell(GetClientUserId(client));
		pack.WriteCell(EntIndexToEntRef(weapon));
		pack.WriteCell(countMax);
		pack.WriteFloat(radius * 1.15);
		pack.WriteFloat(damage * 0.75);
		pack.WriteFloatArray(pos, 3);
		pack.WriteFloat(castTime);
	}
}

static void Weapon_Wand_Freeze_Attack(int client, int weapon, float pos[3], float radius, float damage)
{
	EmitSoundToAll(SOUND_WAND_CRYO_FREEZE, 0, SNDCHAN_STATIC, 80, _, 0.65, SNDPITCH_NORMAL, -1, pos);
	ParticleEffectAt(pos, "xms_snowburst", 1.0);
	
	int EnemiesHitMax = 2;
	switch(Wand_Freeze_CurrentPap[client])
	{
		case 1:
			EnemiesHitMax += 1;
		case 2, 3:
			EnemiesHitMax += 2;
		case 4:
			EnemiesHitMax += 3;
	}
	
	i_ExplosiveProjectileHexArray[weapon] = EP_DEALS_PLASMA_DAMAGE;
	i_ExplosiveProjectileHexArray[weapon] |= EP_IS_ICE_DAMAGE;
	
	Explode_Logic_Custom(damage, client, client, weapon, pos, radius, .maxtargetshit = EnemiesHitMax);
}

public void Weapon_Wand_Freeze_NPCTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int zr_custom_damage)
{
	if(CheckInHud())
		return;
	
	if(NpcStats_IsEnemyTrueFrozen(victim) && f_TimeFrozenStill[victim] > GetGameTime(victim)) {
		float bonusDamage = 1.15;
		if(Wand_Freeze_CurrentPap[attacker] > 3)
			bonusDamage = 1.25;
		
		damage *= bonusDamage;
		DisplayCritAboveNpc(victim, attacker, true, _, _, false);
		// EmitSoundToAll(SOUND_WAND_CRYO_SHATTER, victim);
	}
	else
	{
		if(Wand_Freeze_CurrentPap[attacker] > 2)
		{
			ApplyStatusEffect(attacker, victim, "Cryo", 1.5);
			Elemental_AddCyroDamage(victim, attacker, RoundFloat(damage * 0.15), 1);
		}
		else
		{
			ApplyStatusEffect(attacker, victim, "Freeze", 1.5);
			Elemental_AddCyroDamage(victim, attacker, RoundFloat(damage * 0.25), 0);
		}
	}
}