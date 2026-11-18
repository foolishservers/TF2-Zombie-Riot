#pragma semicolon 1
#pragma newdecls required

static int   fractal_isomer_pap[MAXPLAYERS + 1];
static bool  fractal_isomer_nextproj[MAXPLAYERS + 1];
static bool  fractal_isomer_penetrate[MAXPLAYERS + 1];
static int   fractal_isomer_crystal[MAXPLAYERS + 1];
static float fractal_isomer_hudat[MAXPLAYERS + 1];
static float fractal_isomer_crystal_timer[MAXPLAYERS + 1];

// static float fractal_isomer_geometric[MAXPLAYERS + 1];
// static float fractal_isomer_optical[MAXPLAYERS + 1];

static int   fractal_isomer_max_crystal[] = { 10, 15, 20, 25, 30, 35, 40, 45 };

static Handle fractal_isomer_timer[MAXPLAYERS + 1];

static char fractal_isomer_burst_sound[][] = {
	"ui/hitsound_vortex1.wav",
	"ui/hitsound_vortex2.wav",
	"ui/hitsound_vortex3.wav",
	"ui/hitsound_vortex4.wav",
	"ui/hitsound_vortex5.wav"
};

/**
 * method map name: IsomerParticle
 * functioning: interface to use i_GunAmmo. it will be reset on entitycreated.
 */
methodmap IsomerBurstParticle < CClotBody
{
	property int m_iPenetrateCount
	{
		public get()			{ return i_GunAmmo[this.index]; }
		public set(int value) 	{ i_GunAmmo[this.index] = value; }
	}
}

/**
 * Shared
 */

public void Kit_Fractal_Isomer_OnMapStart()
{
	Zero(fractal_isomer_nextproj);
	Zero(fractal_isomer_pap);
	Zero(fractal_isomer_crystal);
	ZeroFloat(fractal_isomer_hudat);
	
	PrecacheSoundArray(fractal_isomer_burst_sound);
}

public void Kit_Fractal_Isomer_Enable(int client, int weapon)
{
	// 122
	fractal_isomer_pap[client] = RoundToFloor(Attributes_Get(weapon, Attrib_PapNumber, 0.0));
	
	if(fractal_isomer_timer[client])
	{
		delete fractal_isomer_timer[client];
		fractal_isomer_timer[client] = null;
	}
	
	DataPack pack;
	fractal_isomer_timer[client] = CreateDataTimer(0.1, Kit_Fractal_Isomer_Timer, pack, TIMER_REPEAT);
	pack.WriteCell(client);
	pack.WriteCell(GetClientUserId(client));
	pack.WriteCell(EntIndexToEntRef(weapon));
}

/*
bool Kit_Fractal_Isomer_IsEnabled(int client)
{
	return (fractal_isomer_timer[client] != null);
}
*/

public void Kit_Fractal_Isomer_Unequip(int client)
{
	fractal_isomer_crystal[client] = 0;
}

static Action Kit_Fractal_Isomer_Timer(Handle timer, DataPack pack)
{
	pack.Reset();
	
	int clientIndex = pack.ReadCell();
	int client = GetClientOfUserId(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	
	if(!client || !IsPlayerAlive(client)
		|| !IsValidEntity(weapon))
	{
		fractal_isomer_timer[clientIndex] = null;
		return Plugin_Stop;
	}
	
	float gameTime = GetGameTime();
	if(fractal_isomer_crystal_timer[client] < gameTime)
	{
		int pap = fractal_isomer_pap[client];
		
		if(fractal_isomer_crystal[client] < fractal_isomer_max_crystal[pap])
		{
			fractal_isomer_crystal[client]++;
			
			float cooldown = 5.0 * CooldownReductionAmount(client);
			fractal_isomer_crystal_timer[client] = gameTime + cooldown;
		}
	}
	
	Kit_Fractal_Isomer_UpdateHud(client);
	
	return Plugin_Continue;
}

static void Kit_Fractal_Isomer_UpdateHud(int client, int weapon = -1, bool immediate = false)
{
	// Short circult evaluation.
	float gameTime = GetGameTime();
	if(!immediate && fractal_isomer_hudat[client] > gameTime)
		return;
	
	if(weapon == -1)
		weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	
	fractal_isomer_hudat[client] = gameTime + 0.5;
	
	if(!IsValidEntity(weapon))
		return;
	
	int pap = fractal_isomer_pap[client];
	
	char buffer[256];
	if(fractal_isomer_crystal[client] < fractal_isomer_max_crystal[pap])
	{
		FormatEx(buffer, sizeof(buffer), "%T", "Fractal Isomer Crystal Recharge", client, fractal_isomer_crystal[client], fractal_isomer_max_crystal[pap], fractal_isomer_crystal_timer[client] - gameTime);
	}
	else
	{
		FormatEx(buffer, sizeof(buffer), "%T", "Fractal Isomer Crystal", client, fractal_isomer_crystal[client], fractal_isomer_max_crystal[pap]);
	}
	
	switch(i_CustomWeaponEquipLogic[weapon])
	{
		case WEAPON_KIT_FRACTAL_ISOMER_BURST:
		{
			Format(buffer, sizeof(buffer), "%s\n%T", buffer, fractal_isomer_penetrate[client] ? "Fractal Isomer Crystal Burst On" : "Fractal Isomer Crystal Burst Off", client);
		}
	}
	
	if(buffer[0])
		PrintHintText(client, buffer);
}

/**
 * Primary
 */
/*
public void Kit_Fractal_Isomer_Cannon_M1(int client, int weapon, int slot, bool crit)
{
	int crystal = RountToCeil(Attributes_Get(weapon, 868, 0.0));
	if(crystal > fractal_isomer_crystal[client])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Crystal", crystal - fractal_isomer_crystal[client]);
		return;
	}
	
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));
	
	if(mana_cost > Current_Mana[client])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		return;
	}
	
	// Reduce crystal and mana.
	SDKhooks_SetManaRegenDelayTime(client, 1.0);
	Mana_Hud_Delay[client] = 0.0;
	
	Current_Mana[client] -= mana_cost;
	
	delay_hud[client] = 0.0;
	
	fractal_isomer_crystal[client] -= crystal;
	
	// Setup damage and distance.
	float damage = 100.0;
	damage *= Attributes_Get(weapon, 410, 1.0);
	
	float distance = 1200.0;
	distance *= Attributes_Get(weapon, 101, 1.0);
	distance *= Attributes_Get(weapon, 102, 1.0);
	distance *= Attributes_Get(weapon, 103, 1.0);
	distance *= Attributes_Get(weapon, 104, 1.0);
	distance *= Attributes_Get(weapon, 475, 1.0);
	
	Player_Laser_Logic laser;
	float Radius = 10.0;
	laser.client = client;
	laser.Radius = Radius;
	laser.damagetype = DMG_PLASMA;
	laser.DoForwardTrace_Basic(1500.0);
	PlayerLaserDoDamageCombined(laser, damage, damage);
	Offset_Vector({0.0, -8.0, -10.0}, laser.Angles, laser.Start_Point);
}
*/

/**
 * Burst
 */
public void Kit_Fractal_Isomer_Burst_M1(int client, int weapon, int slot, bool crit)
{
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));
	
	bool penetrate = (fractal_isomer_penetrate[client] && fractal_isomer_crystal[client] > 0);
	
	if(penetrate)
		mana_cost = RoundToCeil(float(mana_cost) * 1.25);
	
	if(mana_cost > Current_Mana[client])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		return;
	}
	
	float damage = 65.0;
	damage *= Attributes_Get(weapon, 410, 1.0);
	
	if(penetrate)
		damage *= 1.25;
	
	float speed = 1500.0;
	speed *= Attributes_Get(weapon, 103, 1.0);
	speed *= Attributes_Get(weapon, 104, 1.0);
	speed *= Attributes_Get(weapon, 475, 1.0);
	
	float time = 1500.0 / speed;
	time *= Attributes_Get(weapon, 101, 1.0);
	time *= Attributes_Get(weapon, 102, 1.0);
	
	Handle swing_trace;
	float vec_swing_forward[3];
	DoSwingTrace_Custom(swing_trace, client, vec_swing_forward, 1500.0, false, 30.0, true);
	
	int target = TR_GetEntityIndex(swing_trace);
	
	delete swing_trace;
	
	if(!IsValidEnemy(client, target) || !IsEntityAlive(target))
		target = -1;
	
	if(!Kit_Fractal_Isomer_Burst_FireProjectile(client, weapon, speed, time, damage, penetrate, target))
		return;
	
	SDKhooks_SetManaRegenDelayTime(client, 1.0);
	Mana_Hud_Delay[client] = 0.0;
	
	Current_Mana[client] -= mana_cost;
	
	delay_hud[client] = 0.0;
	
	EmitSoundToAll(fractal_isomer_burst_sound[GetRandomInt(0, sizeof(fractal_isomer_burst_sound) - 1)], client, SNDCHAN_VOICE, 80);
}

static bool Kit_Fractal_Isomer_Burst_FireProjectile(int client, int weapon, float speed, float time, float damage, bool penetrate, int target)
{
	char particle[64];
	if(penetrate)
	{
		particle = fractal_isomer_nextproj[client] ? "raygun_projectile_blue_crit" : "raygun_projectile_red_crit";
	}
	else
	{
		particle = fractal_isomer_nextproj[client] ? "raygun_projectile_blue" : "raygun_projectile_red";
	}
	
	int projectile = Wand_Projectile_Spawn(client, speed, time, damage, 0, weapon, particle);
	if(!IsValidEntity(projectile))
		return false;
	
	if(penetrate)
	{
		IsomerBurstParticle proj = view_as<IsomerBurstParticle>(projectile);
		
		switch(fractal_isomer_pap[client])
		{
			case 0, 1:
				proj.m_iPenetrateCount = 2;
			case 2, 3, 4, 5:
				proj.m_iPenetrateCount = 3;
			case 6, 7:
				proj.m_iPenetrateCount = 4;
		}
		
		WandProjectile_ApplyFunctionToEntity(projectile, Kit_Fractal_Isomer_Burst_PenetrateTouch);
		
		fractal_isomer_crystal[client]--;
		if(fractal_isomer_crystal[client] < 0)
			fractal_isomer_crystal[client] = 0;
		
		// Gives crystal regen cooldown
		fractal_isomer_crystal_timer[client] = GetGameTime() + (6.0 * CooldownReductionAmount(client));
	}
	else
	{
		WandProjectile_ApplyFunctionToEntity(projectile, Kit_Fractal_Isomer_Burst_ProjectileTouch);
	}
	
	float fAng[3];
	GetEntPropVector(projectile, Prop_Send, "m_angRotation", fAng);
	
	// Allow lock-on again on penetrate projectile.
	Initiate_HomingProjectile(projectile,
	client,
		15.0,			// float lockonAngleMax,
		3.0,			// float homingaSec,
		!penetrate,		// bool LockOnlyOnce,
		false,			// bool changeAngles,
		fAng,
		target);
	
	fractal_isomer_nextproj[client] = !fractal_isomer_nextproj[client];
	
	return true;
}

static void Kit_Fractal_Isomer_Burst_PenetrateTouch(int entity, int target)
{
	if(target > 0)
	{
		if(!IsIn_HitDetectionCooldown(entity, target))
		{
			Set_HitDetectionCooldown(entity, target, FAR_FUTURE);
			
			float angles[3];
			GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
			
			float vecForward[3];
			GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
			
			float vecTarget[3];
			WorldSpaceCenter(target, vecTarget);
			
			int owner = EntRefToEntIndex(i_WandOwner[entity]);
			int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
			
			float vecDamageForce[3];
			CalculateDamageForce(vecForward, 10000.0, vecDamageForce);
			
			SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_PLASMA, weapon, vecDamageForce, vecTarget);	// 2048 is DMG_NOGIB?
			
			f_WandDamage[entity] *= LASER_AOE_DAMAGE_FALLOFF;
			
			IsomerBurstParticle projectile = view_as<IsomerBurstParticle>(entity);
			
			projectile.m_iPenetrateCount--;
			
			if(projectile.m_iPenetrateCount > 0)
				return;
			
			int particle = EntRefToEntIndex(i_WandParticle[entity]);
			if(IsValidEntity(particle))
				RemoveEntity(particle);
			
			RemoveEntity(entity);
		}
	}
	else
	{
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(IsValidEntity(particle))
			RemoveEntity(particle);
		
		RemoveEntity(entity);
	}
}

static void Kit_Fractal_Isomer_Burst_ProjectileTouch(int entity, int target)
{
	if(target > 0)
	{
		float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		
		float vecTarget[3];
		WorldSpaceCenter(target, vecTarget);
		
		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
		
		float vecDamageForce[3];
		CalculateDamageForce(vecForward, 10000.0, vecDamageForce);
		
		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_PLASMA, weapon, vecDamageForce, vecTarget);	// 2048 is DMG_NOGIB?
	}
	
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	if(IsValidEntity(particle))
		RemoveEntity(particle);
	
	RemoveEntity(entity);
}

public void Kit_Fractal_Isomer_Burst_M2(int client, int weapon, bool crit, int slot)
{
	FakeClientCommandEx(client, "use tf_weapon_club");
}

public void Kit_Fractal_Isomer_Burst_R(int client, int weapon, bool crit, int slot)
{
	fractal_isomer_penetrate[client] = !fractal_isomer_penetrate[client];
	
	ClientCommand(client, "playgamesound misc/halloween/spelltick_02.wav");
	
	Kit_Fractal_Isomer_UpdateHud(client, weapon, true);
}

/*
static Action Kit_Fractal_Isomer_Burst_AccelerateThink(int entity)
{
	
}
*/

/**
 * Melee
 */

public void Kit_Fractal_Isomer_Melee_DamageCalc(int client, int weapon, float &damage, bool checkvalidity)
{
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0) * LaserWeapons_ReturnManaCost(weapon));
	if(mana_cost <= Current_Mana[client])
	{
		if(!checkvalidity)
		{
			SDKhooks_SetManaRegenDelayTime(client, 1.5);
			Mana_Hud_Delay[client] = 0.0;
			
			Current_Mana[client] -= mana_cost;
			
			delay_hud[client] = 0.0;
			
			damage *= Attributes_Get(weapon, 410, 1.0);
		}
	}
	else
	{
		damage = 0.0;
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
}

public void Kit_Fractal_Isomer_Melee_CustomMeleeTrace(int client, int weapon, float &CustomMeleeRange, float &CustomMeleeWide, bool &ignore_walls, int &enemies_hit_aoe)
{
	CustomMeleeRange = 75.0;
	CustomMeleeWide = 10.0;
	
	switch(fractal_isomer_pap[client])
	{
		case 0:
		{
		}
		case 1, 2:
		{
			CustomMeleeRange += 15.0;
			CustomMeleeWide += 2.0;
		}
		case 3, 4:
		{
			CustomMeleeRange += 25.0;
			CustomMeleeWide += 4.0;
		}
		case 5, 6, 7:
		{
			CustomMeleeRange += 45.0;
			CustomMeleeWide += 6.0;
		}
	}
}

public void Kit_Fractal_Isomer_Melee_M2(int client, int weapon, bool crit, int slot)
{
	FakeClientCommandEx(client, "use tf_weapon_bonesaw");
}

public void Kit_Fractal_Isomer_Melee_R(int client, int weapon, bool crit, int slot)
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
	
	int crystal = RoundToCeil(Attributes_Get(weapon, 868, 0.0));
	if(crystal > fractal_isomer_crystal[client])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Not Enough Crystal", crystal - fractal_isomer_crystal[client]);
		return;
	}
	
	fractal_isomer_crystal[client] -= crystal;
	
	ClientCommand(client, "playgamesound items/powerup_pickup_resistance.wav");
	
	Rogue_OnAbilityUse(client, weapon);
	Ability_Apply_Cooldown(client, slot, 25.0);
	
	ApplyStatusEffect(client, client, "Crystal Shield", 999999.9);
	
	int shield_amount = fractal_isomer_pap[client] * 50;
	int shield_max_amount = fractal_isomer_pap[client] * 100;
	
	CrystalShield_Add(client, shield_amount);
	CrystalShield_CapAt(client, shield_max_amount);
}

public void Kit_Fractal_Isomer_Melee_NPCTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int zr_custom_damage) {
	if(CheckInHud())
		return;
	
	if(zr_custom_damage & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED)
		return;
	
	int pap = fractal_isomer_pap[attacker];
	
	int crystal = 2;
	switch(pap)
	{
		case 2, 3:
			crystal += 1;
		case 4, 5:
			crystal += 3;
		case 6, 7:
			crystal += 5;
	}
	
	fractal_isomer_crystal[attacker] += crystal;
	
	if(fractal_isomer_crystal[attacker] > fractal_isomer_max_crystal[pap])
		fractal_isomer_crystal[attacker] = fractal_isomer_max_crystal[pap];
	
	Kit_Fractal_Isomer_UpdateHud(attacker, weapon, true);
}