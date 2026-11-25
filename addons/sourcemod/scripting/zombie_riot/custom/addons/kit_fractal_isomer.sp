#pragma semicolon 1
#pragma newdecls required

#define SOUND_FRACTAL_ISOMER_CANNON "ui/hitsound_space.wav"

static int   fractal_isomer_pap[MAXPLAYERS + 1];
static bool  fractal_isomer_nextproj[MAXPLAYERS + 1];
static bool  fractal_isomer_burst_use_crystal[MAXPLAYERS + 1];
static int   fractal_isomer_crystal[MAXPLAYERS + 1];
static float fractal_isomer_hudat[MAXPLAYERS + 1];
static float fractal_isomer_crystal_timer[MAXPLAYERS + 1];

static int   fractal_isomer_cosmetic[MAXPLAYERS + 1] = { -1, ... };

static bool  fractal_isomer_equipped_magia_wings[MAXPLAYERS + 1];

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
	
	property float m_flIonDamage
	{
		public get()				{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float value) 	{ fl_AbilityOrAttack[this.index][0] = value; }
	}
	
	property float m_flIonRadius
	{
		public get()				{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float value) 	{ fl_AbilityOrAttack[this.index][1] = value; }
	}
	
	property float m_flIonCastTime
	{
		public get()				{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float value) 	{ fl_AbilityOrAttack[this.index][2] = value; }
	}
	
	public float GetIonBonusDamage(int pap)
	{
		switch(pap)
		{
			case 5:
				return 1.1;
			case 6:
				return 1.25;
			case 7:
				return 1.35;
		}
		
		return 1.0;
	}
	
	public float GetIonRadius(int pap)
	{
		switch(pap)
		{
			case 5:
				return 125.0;
			case 6:
				return 150.0;
			case 7:
				return 200.0;
		}
		
		return 100.0;
	}
	
	public float GetIonCastTime(int pap)
	{
		switch(pap)
		{
			case 5:
				return 2.25;
			case 6:
				return 2.0;
			case 7:
				return 1.75;
		}
		
		return 2.5;
	}
}

/**
 * Shared
 */

public void Kit_Fractal_Isomer_OnMapStart()
{
	PrecacheSound(SOUND_FRACTAL_ISOMER_CANNON);
	
	Zero(fractal_isomer_nextproj);
	Zero(fractal_isomer_pap);
	Zero(fractal_isomer_burst_use_crystal);
	Zero(fractal_isomer_crystal);
	Zero(fractal_isomer_equipped_magia_wings);
	ZeroFloat(fractal_isomer_hudat);
	ZeroFloat(fractal_isomer_crystal_timer);
	
	ResetArrayValue(fractal_isomer_cosmetic, sizeof(fractal_isomer_cosmetic), -1);
	
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

bool Kit_Fractal_Isomer_IsEnabled(int client)
{
	return (fractal_isomer_timer[client] != null);
}

/**
 * call when become lastman.
 * gives 3 buff for lastman and refill crystal shield at maximum amount.
 */
void Kit_Fractal_Isomer_LastmanBuff(int client)
{
	int pap = fractal_isomer_pap[client];
	
	if(pap > 0)
	{
		ApplyStatusEffect(client, client, "Crystal Shield", 999999.9);
	
		int shield_amount = fractal_isomer_pap[client] * 100;
		
		CrystalShield_Add(client, shield_amount);
		CrystalShield_CapAt(client, shield_amount);
	}
}

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
		Delete_Halo(clientIndex);
		fractal_isomer_timer[clientIndex] = null;
		return Plugin_Stop;
	}
	
	if(LastMann)
	{
		int pap = fractal_isomer_pap[client];
		
		ApplyStatusEffect(client, client, "Ruina's Defense", 1.0);
		NpcStats_RuinaDefenseStengthen(client, 0.8);
		
		if(pap > 2)
		{
			ApplyStatusEffect(client, client, "Ruina's Damage", 1.0);
			NpcStats_RuinaDamageStengthen(client, 1.2);
		}
		
		if(pap > 4)
		{
			ApplyStatusEffect(client, client, "Ruina's Nimbleness", 1.0);
			NpcStats_RuinaNimblenessStengthen(client, 1.05);
		}
	}
	
	float gameTime = GetGameTime();
	if(fractal_isomer_crystal_timer[client] < gameTime)
	{
		int pap = fractal_isomer_pap[client];
		
		if(fractal_isomer_crystal[client] < fractal_isomer_max_crystal[pap])
		{
			fractal_isomer_crystal[client]++;
			
			float cooldown = IsValidEntity(RaidBossActive) ? 2.0 : 4.0;
			cooldown *= CooldownReductionAmount(client);
			fractal_isomer_crystal_timer[client] = gameTime + cooldown;
		}
	}
	
	Kit_Fractal_Isomer_UpdateHud(client);
	
	return Plugin_Continue;
}

static void Kit_Fractal_Isomer_UpdateHud(int client, bool immediate = false)
{
	// Short circult evaluation.
	float gameTime = GetGameTime();
	if(!immediate && fractal_isomer_hudat[client] > gameTime)
		return;
	
	HaloManagment(client);
	
	fractal_isomer_hudat[client] = gameTime + 0.5;
	
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(!IsValidEntity(weapon))
		return;
	
	// If you are wielding wrench, hide your hud for helping to see vote progress.
	switch(i_CustomWeaponEquipLogic[weapon])
	{
		case WEAPON_KIT_FRACTAL_ISOMER_BURST, WEAPON_KIT_FRACTAL_ISOMER_CANNON, WEAPON_KIT_FRACTAL_ISOMER_LANCE: {}
		default: return;
	}
	
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
			Format(buffer, sizeof(buffer), "%s\n%T", buffer, fractal_isomer_burst_use_crystal[client] ? "Fractal Isomer Crystal Burst On" : "Fractal Isomer Crystal Burst Off", client);
		}
		case WEAPON_KIT_FRACTAL_ISOMER_LANCE:
		{
			if(pap > 0)
			{
				int crystal = RoundToCeil(Attributes_Get(weapon, 868, 0.0));
				Format(buffer, sizeof(buffer), "%s\n%T", buffer, "Fractal Isomer Crystal Lance", client, crystal);
			}
		}
		case WEAPON_KIT_FRACTAL_ISOMER_CANNON:
		{
			int crystal = RoundToCeil(Attributes_Get(weapon, 868, 0.0));
			Format(buffer, sizeof(buffer), "%s\n%T", buffer, "Fractal Isomer Crystal Cannon", client, crystal);
		}
	}
	
	if(buffer[0])
		PrintHintText(client, buffer);
}

/**
 * Primary
 */

public void Kit_Fractal_Isomer_Cannon_M1(int client, int weapon, bool crit, int slot)
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
	
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));
	if(mana_cost > Current_Mana[client])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		return;
	}
	
	// Reduce crystal and mana.
	SDKhooks_SetManaRegenDelayTime(client, 1.0);
	Mana_Hud_Delay[client] = 0.0;
	
	Current_Mana[client] -= mana_cost;
	
	delay_hud[client] = 0.0;
	
	fractal_isomer_crystal[client] -= crystal;
	
	// And gives cooldown.
	Ability_Apply_Cooldown(client, slot, 30.0);
	
	EmitSoundToClient(client, SOUND_FRACTAL_ISOMER_CANNON);
	Client_Shake(client, 0, 35.0, 90.0, 0.6);
	
	// Setup damage and distance.
	float damage = 100.0;
	damage *= Attributes_Get(weapon, 410, 1.0);
	
	float distance = 1000.0;
	distance *= Attributes_Get(weapon, 101, 1.0);
	distance *= Attributes_Get(weapon, 102, 1.0);
	distance *= Attributes_Get(weapon, 103, 1.0);
	distance *= Attributes_Get(weapon, 104, 1.0);
	distance *= Attributes_Get(weapon, 475, 1.0);
	
	float radius = 15.0;
	
	int max_target_hits = 10 + ((fractal_isomer_pap[client] - 2) * 5);
	
	Player_Laser_Logic laser;
	laser.client = client;
	laser.Radius = radius;
	laser.Damage = damage;
	laser.max_targets = max_target_hits;
	laser.target_hitfalloff = 1.0;
	laser.damagetype = DMG_PLASMA;
	laser.DoForwardTrace_Basic(distance);
	
	laser.Deal_Damage();
	
	int viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if(!IsValidEntity(viewmodelModel))
		viewmodelModel = client;
	
	GetAttachment(viewmodelModel, "effect_hand_R", laser.Start_Point, NULL_VECTOR);
	
	// Kill me.
	// This is twirl's cosmic gaze laser effects.
	float diameter = radius * 2.0;
	
	float te_duration = 0.2;
	
	float vec_offset[3];
	Get_Fake_Forward_Vec(100.0, laser.Angles, vec_offset, laser.Start_Point);
	
	int color[4] = { 255, 165, 30, 255 };
	
	int colorLayer4[4];
	SetColorRGBA(colorLayer4, color[0], color[1], color[2], color[1]);
	
	int colorLayer3[4];
	SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, color[3]);
	
	int colorLayer2[4];
	SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, color[3]);
	
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 7255 / 8, colorLayer4[1] * 5 + 7255 / 8, colorLayer4[2] * 5 + 7255 / 8, color[3]);
	
	float	rng_start = GetRandomFloat(diameter * 0.5, diameter * 0.7);
	
	float	start_diameter1 = ClampBeamWidth(rng_start * 0.7),
			start_diameter2 = ClampBeamWidth(rng_start * 0.9),
			start_diameter3 = ClampBeamWidth(rng_start);
		
	float 	end_diameter1 = ClampBeamWidth(diameter * 0.7),
			end_diameter2 = ClampBeamWidth(diameter * 0.9),
			end_diameter3 = ClampBeamWidth(diameter);
	
	int beam_index = g_Ruina_BEAM_Combine_Black;
	
	TE_SetupBeamPoints(laser.Start_Point, vec_offset, beam_index, 0, 0, 66, te_duration, 0.0, start_diameter1, 0, 10.0, colorLayer2, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(laser.Start_Point, vec_offset, beam_index, 0, 0, 66, te_duration, 0.0, start_diameter2, 0, 10.0, colorLayer3, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(laser.Start_Point, vec_offset, beam_index, 0, 0, 66, te_duration, 0.0, start_diameter3, 0, 10.0, colorLayer4, 3);
	TE_SendToAll(0.0);
	
	TE_SetupBeamPoints(vec_offset, laser.End_Point, beam_index, 0, 0, 66, te_duration, start_diameter1 * 0.9, end_diameter1, 0, 0.1, colorLayer2, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(vec_offset, laser.End_Point, beam_index, 0, 0, 66, te_duration, start_diameter2 * 0.9, end_diameter2, 0, 0.1, colorLayer3, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(vec_offset, laser.End_Point, beam_index, 0, 0, 66, te_duration, start_diameter3 * 0.9, end_diameter3, 0, 0.1, colorLayer4, 3);
	TE_SendToAll(0.0);
	
	EmitSoundToClient(client, RUINA_ION_CANNON_SOUND_SPAWN, client, SNDCHAN_STATIC, SNDLEVEL_NORMAL, _, 1.0);
	
	Kit_Fractl_Isomer_Invoke_Ion_Barrage(client, weapon, damage, laser.End_Point);
}

static void Kit_Fractl_Isomer_Invoke_Ion_Barrage(int client, int weapon, float damage, float pos[3])
{
	int amount = 1;
	float castTime = 2.5;
	float ion_damage = damage;
	float radius = 100.0;
	
	switch(fractal_isomer_pap[client])
	{
		case 2:
		{
			ion_damage *= 0.35;
		}
		case 3:
		{
			amount += 1;
			castTime = 2.25;
			ion_damage *= 0.375;
			radius = 125.0;
		}
		case 4:
		{
			amount += 2;
			castTime = 2.0;
			ion_damage *= 0.4;
			radius = 150.0;
		}
		case 5:
		{
			amount += 3;
			castTime = 1.85;
			ion_damage *= 0.425;
			radius = 175.0;
		}
		case 6:
		{
			amount += 4;
			castTime = 1.6;
			ion_damage *= 0.45;
			radius = 200.0;
		}
		case 7:
		{
			amount += 5;
			castTime = 1.5;
			ion_damage *= 0.5;
			radius = 225.0;
		}
	}
	
	Kit_Fractal_Isomer_Ion_Attack(client, pos, weapon, ion_damage, castTime, radius);
	
	float vec_ion[3];
	for (int i = 1; i < amount; i++)
	{
		vec_ion = pos;
		vec_ion[0] += GetRandomFloat(-200.0, 200.0);
		vec_ion[1] += GetRandomFloat(-200.0, 200.0);
		Kit_Fractal_Isomer_Ion_Attack(client, vec_ion, weapon, ion_damage, castTime, radius);
	}
}

/**
 * Burst
 */

public void Kit_Fractal_Isomer_Burst_M1(int client, int weapon, int slot, bool crit)
{
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));
	
	bool ion = (fractal_isomer_burst_use_crystal[client] && fractal_isomer_crystal[client] > 0);
	
	if(ion)
		mana_cost = RoundToCeil(float(mana_cost) * 1.25);
	
	if(mana_cost > Current_Mana[client])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		return;
	}
	
	if(ion)
	{
		if(!Kit_Fractal_Isomer_Burst_FireLaser(client, weapon))
			return;
		
		EmitSoundToAll("weapons/capper_shoot.wav", client, SNDCHAN_WEAPON, 95);
	}
	else
	{
		if(!Kit_Fractal_Isomer_Burst_FireProjectile(client, weapon))
			return;
		
		EmitSoundToAll(fractal_isomer_burst_sound[GetRandomInt(0, sizeof(fractal_isomer_burst_sound) - 1)], client, SNDCHAN_WEAPON, 80);
	}
	
	SDKhooks_SetManaRegenDelayTime(client, 1.0);
	Mana_Hud_Delay[client] = 0.0;
	
	Current_Mana[client] -= mana_cost;
	
	delay_hud[client] = 0.0;
}

static bool Kit_Fractal_Isomer_Burst_FireProjectile(int client, int weapon)
{
	float damage = 65.0;
	damage *= Attributes_Get(weapon, 410, 1.0);
	
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
	
	char particle[64];
	particle = fractal_isomer_nextproj[client] ? "raygun_projectile_blue" : "raygun_projectile_red";
	
	int projectile = Wand_Projectile_Spawn(client, speed, time, damage, 0, weapon, particle);
	if(!IsValidEntity(projectile))
		return false;
	
	int penetrate_count = 1; 
	switch(fractal_isomer_pap[client])
	{
		case 1, 2:
			penetrate_count = 2;
		case 3, 4:
			penetrate_count = 3;
		case 5, 6, 7:
			penetrate_count = 4;
	}
	
	if(penetrate_count > 1)
	{
		IsomerBurstParticle proj = view_as<IsomerBurstParticle>(projectile);
		
		proj.m_iPenetrateCount = penetrate_count;
		
		WandProjectile_ApplyFunctionToEntity(projectile, Kit_Fractal_Isomer_Burst_PenetrateTouch);
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
		15.0,		// float lockonAngleMax,
		3.0,		// float homingaSec,
		false,		// bool LockOnlyOnce,
		false,		// bool changeAngles,
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
			
			float damage = f_WandDamage[entity];
			if(b_thisNpcIsARaid[target])
			{
				damage *= 1.7;
			}
			else if(b_thisNpcIsABoss[target]
				|| b_thisNpcHasAnOutline[target]
				|| b_StaticNPC[target]
				|| b_ThisNpcIsImmuneToNuke[target])
			{
				damage *= 1.35;
			}
			
			SDKHooks_TakeDamage(target, owner, owner, damage, DMG_PLASMA, weapon, vecDamageForce, vecTarget);	// 2048 is DMG_NOGIB?
			
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
		
		float damage = f_WandDamage[entity];
		if(b_thisNpcIsARaid[target])
		{
			damage *= 1.7;
		}
		else if(b_thisNpcIsABoss[target]
			|| b_thisNpcHasAnOutline[target]
			|| b_StaticNPC[target]
			|| b_ThisNpcIsImmuneToNuke[target])
		{
			damage *= 1.35;
		}
		
		SDKHooks_TakeDamage(target, owner, owner, damage, DMG_PLASMA, weapon, vecDamageForce, vecTarget);	// 2048 is DMG_NOGIB?
	}
	
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	if(IsValidEntity(particle))
		RemoveEntity(particle);
	
	RemoveEntity(entity);
}

static bool Kit_Fractal_Isomer_Burst_FireLaser(int client, int weapon)
{
	float damage = 78.0;
	damage *= Attributes_Get(weapon, 410, 1.0);
	
	float speed = 1500.0;
	speed *= Attributes_Get(weapon, 103, 1.0);
	speed *= Attributes_Get(weapon, 104, 1.0);
	speed *= Attributes_Get(weapon, 475, 1.0);
	
	float time = 1500.0 / speed;
	time *= Attributes_Get(weapon, 101, 1.0);
	time *= Attributes_Get(weapon, 102, 1.0);
	
	int projectile = Wand_Projectile_Spawn(client, speed, time, damage, 0, weapon, "");
	if(!IsValidEntity(projectile))
		return false;
	
	WandProjectile_ApplyFunctionToEntity(projectile, Kit_Fractal_Isomer_Burst_LaserTouch);
	
	fractal_isomer_crystal[client]--;
	
	// Gives crystal regen cooldown
	float cooldown = IsValidEntity(RaidBossActive) ? 1.25 : 4.5;
	fractal_isomer_crystal_timer[client] = GetGameTime() + (cooldown * CooldownReductionAmount(client));
	
	IsomerBurstParticle particle = view_as<IsomerBurstParticle>(projectile);
	
	particle.m_iPenetrateCount = 1;
	
	/*
	int pap = fractal_isomer_pap[client];
	if(pap > 3)
	{
		particle.m_flIonDamage = damage * particle.GetIonBonusDamage(pap);
		particle.m_flIonRadius = particle.GetIonRadius(pap);
		particle.m_flIonCastTime = particle.GetIonCastTime(pap);
	}
	*/
	
	float radius = 15.0;
	float laser_damage = damage * 0.35;
	
	DataPack pack;
	CreateDataTimer(0.1, Kit_Fractal_Isomer_Laser_Timer, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	pack.WriteCell(GetClientUserId(client));
	if(!AtEdictLimit(EDICT_EFFECT))
	{
		int viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
		if(!IsValidEntity(viewmodelModel))
			viewmodelModel = client;
		
		int beam = ConnectWithBeam(viewmodelModel, projectile, 250, 180, 100, 4.5, 3.0, 0.25, LASERBEAM, _, _, "effect_hand_R");
		i_WandParticle[projectile] = EntIndexToEntRef(beam);
		pack.WriteCell(i_WandParticle[projectile]);
	}
	else
	{
		pack.WriteCell(-1);
	}
	pack.WriteCell(EntIndexToEntRef(projectile));
	pack.WriteFloat(radius);
	pack.WriteFloat(laser_damage);
	
	return true;
}

static void Kit_Fractal_Isomer_Burst_LaserTouch(int entity, int target)
{
	IsomerBurstParticle projectile = view_as<IsomerBurstParticle>(entity);
	
	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
	
	if(target > 0)
	{	
		if(!IsIn_HitDetectionCooldown(entity, target))
		{
			Set_HitDetectionCooldown(entity, target, FAR_FUTURE);
			
			// Reduce the call of this function..
			if(projectile.m_iPenetrateCount > 0)
			{
				float angles[3];
				GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
				
				float vecForward[3];
				GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
				
				float vecTarget[3];
				WorldSpaceCenter(target, vecTarget);
				
				float vecDamageForce[3];
				CalculateDamageForce(vecForward, 10000.0, vecDamageForce);
				
				float damage = f_WandDamage[entity];
				if(b_thisNpcIsARaid[target]
					|| b_thisNpcIsABoss[target]
					|| b_thisNpcHasAnOutline[target]
					|| b_StaticNPC[target]
					|| b_ThisNpcIsImmuneToNuke[target])
				{
					damage *= 1.3;
				}
				
				SDKHooks_TakeDamage(target, owner, owner, damage, DMG_PLASMA, weapon, vecDamageForce, vecTarget);	// 2048 is DMG_NOGIB?
				
				f_WandDamage[entity] *= LASER_AOE_DAMAGE_FALLOFF;
				
				projectile.m_iPenetrateCount--;
			}
		}
		
		return;
	}
	
	if(projectile.m_flIonDamage > 0.0)
	{
		float pos[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
		pos[2] += 5.0;
		
		Kit_Fractal_Isomer_Ion_Attack(owner, pos, weapon, projectile.m_flIonDamage, projectile.m_flIonCastTime, projectile.m_flIonRadius);
	}
	
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	if(IsValidEntity(particle))
		RemoveEntity(particle);
	
	RemoveEntity(entity);
}

static Action Kit_Fractal_Isomer_Laser_Timer(Handle timer, DataPack pack)
{
	pack.Reset();
	
	int client = GetClientOfUserId(pack.ReadCell());
	int laser_entity = pack.ReadCell();
	
	if(laser_entity != -1)
		laser_entity = EntRefToEntIndex(laser_entity);
	
	int projectile = EntRefToEntIndex(pack.ReadCell());
	float radius = pack.ReadFloat();
	float damage = pack.ReadFloat();
	
	if(!client || (!IsValidEntity(laser_entity) && laser_entity != -1) || !IsValidEntity(projectile))
	{
		if(IsValidEntity(laser_entity))
			RemoveEntity(laser_entity);
		
		if(IsValidEntity(projectile))
			RemoveEntity(projectile);
		
		return Plugin_Stop;
	}
	
	float vec_self[3], vec_proj[3];
	WorldSpaceCenter(client, vec_self);
	GetEntPropVector(projectile, Prop_Data, "m_vecAbsOrigin", vec_proj);
	
	float distance = GetVectorDistance(vec_self, vec_proj, true);
	if(distance > 90000.0)
		SetEntityMoveType(projectile, MOVETYPE_FLYGRAVITY);
	
	Player_Laser_Logic laser;
	
	laser.client = client;
	laser.Start_Point = vec_self;
	laser.End_Point = vec_proj;
	
	laser.Radius = radius;
	laser.Damage = damage;
	laser.damagetype = DMG_PLASMA;
	
	if(laser_entity == -1)	//The projectile was fired when we are at edict criticality, as such we will render the "laser" with a TE rather then env beam.
	{
		TE_SetupBeamPoints(laser.Start_Point, laser.End_Point, g_Ruina_BEAM_Laser, 0, 0, 0, 0.1, radius * 2.0, radius * 2.0, 0, 0.1, {250, 180, 100, 255}, 3);
		TE_SendToAll();
	}
	
	laser.Deal_Damage();
	
	return Plugin_Continue;
}

public void Kit_Fractal_Isomer_Burst_M2(int client, int weapon, bool crit, int slot)
{
	FakeClientCommandEx(client, "use tf_weapon_club");
}

public void Kit_Fractal_Isomer_Burst_R(int client, int weapon, bool crit, int slot)
{
	fractal_isomer_burst_use_crystal[client] = !fractal_isomer_burst_use_crystal[client];
	
	ClientCommand(client, "playgamesound misc/halloween/spelltick_02.wav");
	
	Kit_Fractal_Isomer_UpdateHud(client, true);
}

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
	Ability_Apply_Cooldown(client, slot, 20.0);
	
	ApplyStatusEffect(client, client, "Crystal Shield", 999999.9);
	
	int shield_amount = fractal_isomer_pap[client] * 50;
	int shield_max_amount = fractal_isomer_pap[client] * 100;
	
	if(LastMann)
		shield_amount = shield_max_amount;
	
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
			crystal += 2;
		case 6, 7:
			crystal += 3;
	}
	
	fractal_isomer_crystal[attacker] += crystal;
	
	if(fractal_isomer_crystal[attacker] > fractal_isomer_max_crystal[pap])
		fractal_isomer_crystal[attacker] = fractal_isomer_max_crystal[pap];
	
	Kit_Fractal_Isomer_UpdateHud(attacker, true);
}

/**
 * Ion.
 */

public void Kit_Fractal_Isomer_Ion_Attack(int attacker, float end_point[3], int weapon, float damage, float time, float radius)
{
	int color[4] = { 255, 165, 30, 255 };
	int inner_color[4] = { 255, 165, 30, 100 };
	
	float Thickness = 6.0;
	TE_SetupBeamRingPoint(end_point, radius * 2.0, 0.0, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, time, Thickness, 0.75, inner_color, 1, 0);
	Send_Te_Client_ZR(attacker);
	TE_SetupBeamRingPoint(end_point, radius * 2.0, radius * 2.0 + 0.5, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, time, Thickness, 0.1, color, 1, 0);
	Send_Te_Client_ZR(attacker);
	
	if(LastMann)
	{
		Ruina_IonSoundInvoke(end_point);
	}
	else
	{
		EmitSoundToClient(attacker, RUINA_ION_CANNON_SOUND_SPAWN, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, end_point);
		EmitSoundToClient(attacker, RUINA_ION_CANNON_SOUND_SPAWN, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, end_point);
	}
	
	DataPack pack;
	CreateDataTimer(time, Kit_Fractal_Isomer_Manaflow_Ion, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(attacker));
	pack.WriteCell(EntIndexToEntRef(weapon));
	pack.WriteFloatArray(end_point, sizeof(end_point));
	pack.WriteFloat(radius);
	pack.WriteFloat(damage);
	
	if(AtEdictLimit(EDICT_NPC))
		return;
	
	float sky_pos[3];
	sky_pos = end_point;
	sky_pos[2] += 500.0;
	
	int laser = ConnectWithBeam(-1, -1, color[0], color[1], color[2], 4.0, 4.0, 5.0, BEAM_COMBINE_BLACK, end_point, sky_pos);
	
	CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
}

static Action Kit_Fractal_Isomer_Manaflow_Ion(Handle timer, DataPack pack)
{
	pack.Reset();
	
	int attacker = EntRefToEntIndex(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	
	float end_point[3];
	pack.ReadFloatArray(end_point, sizeof(end_point));
	
	float radius = pack.ReadFloat();
	float damage = pack.ReadFloat();
	
	float Thickness = 6.0;
	TE_SetupBeamRingPoint(end_point, 0.0, radius * 2.0, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, 0.75, Thickness, 0.75, { 255, 165, 30, 255 }, 1, 0);
	Send_Te_Client_ZR(attacker);
	
	if(LastMann)
	{
		EmitSoundToAll(RUINA_ION_CANNON_SOUND_TOUCHDOWN, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, end_point);
		EmitSoundToAll(RUINA_ION_CANNON_SOUND_TOUCHDOWN, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, end_point);
	}
	else
	{
		EmitSoundToClient(attacker, RUINA_ION_CANNON_SOUND_TOUCHDOWN, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, end_point);
		EmitSoundToClient(attacker, RUINA_ION_CANNON_SOUND_TOUCHDOWN, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, end_point);
	}
	
	EmitSoundToClient(attacker, RUINA_ION_CANNON_SOUND_ATTACK, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, end_point);
	EmitSoundToClient(attacker, RUINA_ION_CANNON_SOUND_ATTACK, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, end_point);
	
	Explode_Logic_Custom(damage, attacker, attacker, weapon, end_point, radius, .maxtargetshit = 5);
	
	return Plugin_Stop;
}

/**
 * Misc.
 */

static void HaloManagment(int client)
{
	if(AtEdictLimit(EDICT_PLAYER))
	{
		Delete_Halo(client);
		return;
	}
	
	int halo_particle = EntRefToEntIndex(fractal_isomer_cosmetic[client]);
	
	bool magia_wings = MagiaWingsDo(client);
	
	if(IsValidEntity(halo_particle))
	{
		if((!magia_wings && !fractal_isomer_equipped_magia_wings[client])
			|| (magia_wings && fractal_isomer_equipped_magia_wings[client]))
		{
			return;
		}
		
		Delete_Halo(client);
	}
	
	fractal_isomer_equipped_magia_wings[client] = magia_wings;
	
	int viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	
	if(magia_wings && IsValidEntity(viewmodelModel))
	{
		// :3
		float pos[3];
		GetAttachment(viewmodelModel, "head", pos, NULL_VECTOR);
		pos[2] += 10.0;
		
		int particle = ParticleEffectAt(pos, "unusual_invasion_boogaloop", 0.0);
		AddEntityToThirdPersonTransitMode(client, particle);
		SetParent(viewmodelModel, particle, "head");
		
		fractal_isomer_cosmetic[client] = EntIndexToEntRef(particle);
		
		return;
	}
	
	float pos[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos);
	pos[2] += 2.0;
	
	int particle = ParticleEffectAt(pos, "utaunt_poison_floorrays_o", -1.0);
	SetParent(client, particle);
	
	fractal_isomer_cosmetic[client] = EntIndexToEntRef(particle);
}

static void Delete_Halo(int client)
{
	int halo_particle = EntRefToEntIndex(fractal_isomer_cosmetic[client]);
	
	if(IsValidEntity(halo_particle))
	{
		TeleportEntity(halo_particle, OFF_THE_MAP);
		RemoveEntity(halo_particle);
		fractal_isomer_cosmetic[client] = -1;
	}
}

static void Get_Fake_Forward_Vec(float range, float vec_angles[3], float vec_target[3], float pos[3])
{
	float direction[3];
	
	GetAngleVectors(vec_angles, direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(direction, range);
	AddVectors(pos, direction, vec_target);
}