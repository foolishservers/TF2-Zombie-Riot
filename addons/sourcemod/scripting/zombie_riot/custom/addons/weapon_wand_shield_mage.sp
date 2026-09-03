#pragma semicolon 1
#pragma newdecls required

static Handle ShieldMageTimer[MAXPLAYERS] = {null, ...};
static int ShieldMageID[MAXPLAYERS];
static int SwordMageID[MAXPLAYERS];
static int SwordLaserID[MAXPLAYERS];
static int ArmorWearableID[MAXPLAYERS];
static float ShieldMage_HudTime[MAXPLAYERS];
static float ShieldMage_CrystalShieldTime[MAXPLAYERS];
int Armor_WearableModelIndex;

static const char SwordHit_Sound[][] = {
	"weapons/samurai/tf_katana_slice_01.wav",
	"weapons/samurai/tf_katana_slice_02.wav",
	"weapons/samurai/tf_katana_slice_03.wav"
};

public void Wand_ShieldMage_MapStart()
{
	PrecacheSoundArray(SwordHit_Sound);
	PrecacheSound("weapons/bison_main_shot.wav");
	PrecacheSound("items/powerup_pickup_reflect.wav");
	PrecacheSound("items/powerup_pickup_resistance.wav");
	PrecacheModel("models/zombie_riot/weapons/ruina_models_2_5.mdl");
	PrecacheModel("models/props_moonbase/moon_gravel_crystal_blue.mdl");
	Armor_WearableModelIndex = PrecacheModel("models/effects/resist_shield/resist_shield.mdl", true);
	//ZeroFloat(ChargeUpFire);
	Zero(ShieldMageID);
	Zero(SwordMageID);
	Zero(ArmorWearableID);
	ZeroFloat(ShieldMage_HudTime);
	ZeroFloat(ShieldMage_CrystalShieldTime);
}

public void Wand_ShieldMage_Deploy(int client, int weapon)
{
	ShieldMageID[client]=EntIndexToEntRef(weapon);
	b_FUCKYOU[weapon]=false;
	b_FUCKYOU_move_anim[weapon]=false;
	int SwordMage = EntRefToEntIndex(SwordMageID[client]);
	if(IsValidEntity(SwordMage))
		RemoveEntity(SwordMage);
	SwordMage = EntRefToEntIndex(ArmorWearableID[client]);
	if(IsValidEntity(SwordMage))
		RemoveEntity(SwordMage);
	if(ShieldMageTimer[client] != null)
	{
		delete ShieldMageTimer[client];
		ShieldMageTimer[client] = null;
		DataPack pack;
		ShieldMageTimer[client] = CreateDataTimer(0.1, Management_ShieldMage, pack, TIMER_REPEAT);
		pack.WriteCell(client);
	}
	else
	{
		DataPack pack;
		ShieldMageTimer[client] = CreateDataTimer(0.1, Management_ShieldMage, pack, TIMER_REPEAT);
		pack.WriteCell(client);
	}
}

public void Wand_ShieldMage_Holster(int client, int weapon)
{
	ShieldMageID[client]=EntIndexToEntRef(weapon);
	int SwordMage = EntRefToEntIndex(SwordLaserID[client]);
	if(IsValidEntity(SwordMage))
	{
		int Wearable = view_as<CClotBody>(SwordMage).m_iWearable1;
		if(IsValidEntity(Wearable))
			RemoveEntity(Wearable);
		RemoveEntity(SwordMage);
	}
	SwordMage = EntRefToEntIndex(SwordMageID[client]);
	if(IsValidEntity(SwordMage))
		RemoveEntity(SwordMage);
	SwordMage = EntRefToEntIndex(ArmorWearableID[client]);
	if(IsValidEntity(SwordMage))
		RemoveEntity(SwordMage);
	if(Skulls_ArrayStack[client] != null)
		DeleteAllSkulls(client);
	SDKUnhook(client, SDKHook_PreThink, Wand_ShieldMage_M2_PreThink);
}

public void Wand_ShieldMage_M2(int client, int weapon, bool crit, int slot)
{
	if(!IsValidClient(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
		return;
	float Ability_CD = Ability_Check_Cooldown(client, slot);
	if(Ability_CD > 0.0 && !CvarInfiniteCash.BoolValue)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
		return;
	}
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0))*2;
	if(mana_cost > Current_Mana[client])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		return;
	}
	if(ShieldMage_CrystalShieldTime[client] && ShieldMage_CrystalShieldTime[client] > GetGameTime())
		return;
	EmitSoundToAll("items/powerup_pickup_resistance.wav", client, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 90, .soundtime = GetGameTime() - 0.219);
	b_FUCKYOU[weapon]=true;
	b_FUCKYOU_move_anim[weapon]=true;
	Rogue_OnAbilityUse(client, weapon);
	Current_Mana[client] -= mana_cost;
	if(Skulls_ArrayStack[client] != null)
		DeleteAllSkulls(client);
	SpawnCrystalShield(client);
	SpawnShieldModel(client);
	SDKhooks_SetManaRegenDelayTime(client, 3.0);
	ShieldMage_CrystalShieldTime[client] = GetGameTime() + 10.0;
	SDKUnhook(client, SDKHook_PreThink, Wand_ShieldMage_M2_PreThink);
	SDKHook(client, SDKHook_PreThink, Wand_ShieldMage_M2_PreThink);
}

public void Wand_ShieldMage_M2_Defender(int client, int weapon, bool crit, int slot)
{
	if(!IsValidClient(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
		return;
	float Ability_CD = Ability_Check_Cooldown(client, slot);
	if(Ability_CD > 0.0 && !CvarInfiniteCash.BoolValue)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
		return;
	}
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0))*2;
	if(mana_cost > Current_Mana[client])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		return;
	}
	if(ShieldMage_CrystalShieldTime[client] && ShieldMage_CrystalShieldTime[client] > GetGameTime())
		return;
	EmitSoundToAll("items/powerup_pickup_resistance.wav", client, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 90, .soundtime = GetGameTime() - 0.219);
	b_FUCKYOU[weapon]=true;
	b_FUCKYOU_move_anim[weapon]=true;
	Rogue_OnAbilityUse(client, weapon);
	Current_Mana[client] -= mana_cost;
	if(Skulls_ArrayStack[client] != null)
		DeleteAllSkulls(client);
	SpawnCrystalShield(client);
	SpawnShieldModel(client);
	SDKhooks_SetManaRegenDelayTime(client, 3.0);
	ShieldMage_CrystalShieldTime[client] = GetGameTime() + 10.0;
	SDKUnhook(client, SDKHook_PreThink, Wand_ShieldMage_M2_PreThink);
	SDKHook(client, SDKHook_PreThink, Wand_ShieldMage_M2_PreThink);
}

static void Wand_ShieldMage_M2_PreThink(int client)
{
	if(!IsValidClient(client) || !IsPlayerAlive(client))
	{
		if(Skulls_ArrayStack[client] != null)
			DeleteAllSkulls(client);
		int Wearable = EntRefToEntIndex(ArmorWearableID[client]);
		if(IsValidEntity(Wearable))
			RemoveEntity(Wearable);
		SDKUnhook(client, SDKHook_PreThink, Wand_ShieldMage_M2_PreThink);
	}
	int ShieldMage = EntRefToEntIndex(ShieldMageID[client]);
	if(IsValidEntity(ShieldMage))
	{
		if(GetClientButtons(client) & IN_ATTACK2)
		{
			int mana_cost = 2;
			if(mana_cost <= Current_Mana[client] && ShieldMage_CrystalShieldTime[client] > GetGameTime())
			{
				if(!Skulls_PlayerHasNoSkulls(client))
				{
					Skulls_OrbitAngle[client] += 2.0;
					if(Skulls_OrbitAngle[client] > 360.0)
						Skulls_OrbitAngle[client] = 0.0;
					if(SkullFloatDelay[client] < GetGameTime())
					{
						Skulls_UpdateFollowerPositions(client);
						for(int a; a < Skulls_ArrayStack[client].Length; a++)
						{
							int ent = EntRefToEntIndex(Skulls_ArrayStack[client].Get(a));
							if(IsValidEdict(ent))
								Skull_MoveToTargetPosition(ent, client);
						}
						SkullFloatDelay[client] = GetGameTime() + 0.05;
					}
				}
				Current_Mana[client] -= mana_cost;
				SDKhooks_SetManaRegenDelayTime(client, 3.0);
				return;
			}
			else
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
			}
			Ability_Apply_Cooldown(client, 2, 30.0, ShieldMage);
		}
		else
			Ability_Apply_Cooldown(client, 2, 30.0-(ShieldMage_CrystalShieldTime[client] - GetGameTime()), ShieldMage);
	}
	b_FUCKYOU[ShieldMage]=false;
	ShieldMage_CrystalShieldTime[client]=0.0;
	if(Skulls_ArrayStack[client] != null)
		DeleteAllSkulls(client);
	ShieldMage = EntRefToEntIndex(ArmorWearableID[client]);
	if(IsValidEntity(ShieldMage))
		RemoveEntity(ShieldMage);
	SDKUnhook(client, SDKHook_PreThink, Wand_ShieldMage_M2_PreThink);
}

public void Wand_ShieldMage_M1(int client, int weapon, bool crit, int slot)
{
	if(!IsValidClient(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
		return;
	float Ability_CD = Ability_Check_Cooldown(client, slot);
	if(Ability_CD > 0.0)
		return;
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));
	float Attackspeed = 2.0;
	Attackspeed *= Attributes_Get(weapon, 6, 1.0);
	Attackspeed *= Attributes_Get(weapon, 5, 1.0);
	float WorldSpaceVec[3]; WorldSpaceCenter(client, WorldSpaceVec);
	int SwordMage = EntRefToEntIndex(SwordMageID[client]);
	if(!IsValidEntity(SwordMage))
	{
		mana_cost *= 2;
		if(mana_cost > Current_Mana[client])
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
			return;
		}
		Current_Mana[client] -= mana_cost;
		SDKhooks_SetManaRegenDelayTime(client, 1.25);
		SwordMage = Wand_Projectile_Spawn(client, 0.0, 0.0, 0.0, 0, weapon, "rockettrail_RocketJumper");
		int particle = EntRefToEntIndex(i_WandParticle[SwordMage]);
		if(IsValidEntity(particle))
			RemoveEntity(particle);
		WandProjectile_ApplyFunctionToEntity(SwordMage, NoClipSwordFunction);
		SetEntityMoveType(SwordMage, MOVETYPE_NOCLIP);
		TeleportEntity(SwordMage, NULL_VECTOR, {0.0, 0.0, 0.0}, NULL_VECTOR);
		i_State[SwordMage]=0;
		fl_Charge_delay[SwordMage]=0.0;
		fl_JumpCooldown[SwordMage]=0.0;
		b_FUCKYOU[SwordMage]=false;
		SwordMageID[client]=EntIndexToEntRef(SwordMage);
		SwordMage=ApplyCustomModelToWandProjectile(SwordMage, "models/zombie_riot/weapons/ruina_models_2_5.mdl", 1.25, "");
		SetVariantInt(64);
		AcceptEntityInput(SwordMage, "SetBodyGroup");
		TeleportEntity(SwordMage, NULL_VECTOR, {0.0, 0.0, 0.0}, NULL_VECTOR);
		
		particle = EntRefToEntIndex(SwordLaserID[client]);
		if(IsValidEntity(particle))
		{
			int Wearable = view_as<CClotBody>(particle).m_iWearable1;
			if(IsValidEntity(Wearable))
				RemoveEntity(Wearable);
			RemoveEntity(particle);
		}
		particle = CreateEntityByName("prop_dynamic");
		if(IsValidEntity(particle))
		{
			static float vAngles[3], vOrigin[3];
			GetClientEyePosition(client, vOrigin);
			GetClientEyeAngles(client, vAngles);
			DispatchKeyValue(particle, "model", "models/weapons/w_models/w_drg_ball.mdl");
			DispatchKeyValue(particle, "solid", "0");
			TeleportEntity(particle, vOrigin, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(particle);
			
			AddEntityToOwnerTransitMode(client, particle);
			SwordLaserID[client]=EntIndexToEntRef(particle);
			SetVariantString("1.5");
			AcceptEntityInput(particle, "SetModelScale");
			SetEntPropEnt(particle, Prop_Data, "m_hOwnerEntity", client);
			SetEntityRenderMode(particle, RENDER_TRANSCOLOR);
			SetEntityRenderColor(particle, 255, 0, 0, 254);
			SwordMage = ConnectWithBeam(SwordMage, particle, 50, 0, 0, 3.0, 0.1, 0.0, LASERBEAM);
			SetEntityRenderColor(SwordMage, 50, 0, 0, 255);
			AddEntityToOwnerTransitMode(client, SwordMage);
			view_as<CClotBody>(particle).m_iWearable1 = SwordMage;
		}
		ClientCommand(client, "playgamesound misc/halloween/spell_teleport.wav");
		ParticleEffectAt(WorldSpaceVec, "eyeboss_death_vortex", 1.5);
		Ability_Apply_Cooldown(client, slot, Attackspeed, .ignoreCooldown=true);
		return;
	}
	else
	{
		if(mana_cost > Current_Mana[client])
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
			return;
		}
		if(b_FUCKYOU[SwordMage])
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client, SyncHud_Notifaction, "Need Sword!!");
			return;
		}
		SDKhooks_SetManaRegenDelayTime(client, 3.0);
		Current_Mana[client] -= mana_cost;
		fl_AbilityOrAttack[SwordMage][0] = 65.0 * Attributes_Get(weapon, 410, 1.0);
		fl_AbilityOrAttack[SwordMage][1] = fl_AbilityOrAttack[SwordMage][0]*0.2;
		
		SDKUnhook(client, SDKHook_PreThink, Wand_ShieldMage_M1_PreThink);
		SDKHook(client, SDKHook_PreThink, Wand_ShieldMage_M1_PreThink);
		b_FUCKYOU[SwordMage]=true;
		Ability_Apply_Cooldown(client, slot, Attackspeed, .ignoreCooldown=true);
	}
}

static Action Management_ShieldMage(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(ShieldMageID[client]);
	if(!IsValidClient(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		ShieldMageTimer[client] = null;
		if(IsValidEntity(weapon))
		{
			int Model = EntRefToEntIndex(iref_PropAppliedToRocket[weapon]);
			if(IsValidEntity(Model))
			{
				int Wearable = view_as<CClotBody>(Model).m_iWearable1;
				if(IsValidEntity(Wearable))
					RemoveEntity(Wearable);
				RemoveEntity(Model);
			}
		}
		weapon = EntRefToEntIndex(SwordMageID[client]);
		if(IsValidEntity(weapon))
			RemoveEntity(weapon);
		return Plugin_Stop;
	}
	float GameTime = GetGameTime();
	weapon = EntRefToEntIndex(SwordMageID[client]);
	if(IsValidEntity(weapon))
	{
		if(fl_JumpCooldown[weapon] < GameTime && !b_FUCKYOU[weapon])
		{
			float Swordvec[3], Pathing[3], SwordAng[3];
			int TooFal;
			GetClientEyePosition(client, SwordAng);
			GetClientEyeAngles(client, Swordvec);
			CalcCorrectWeaponShootPosition({ -60.9, -13.1, 30.1 }, SwordAng, Swordvec);
			GetAbsOrigin(weapon, Swordvec);
			float Dist = GetVectorDistance(SwordAng, Swordvec, true);
			if(Dist > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 22.0))
			{
				TeleportEntity(weapon, SwordAng, NULL_VECTOR, NULL_VECTOR);
				for(int help=1 ; help<=3 ; help++)
				{	
					Lanius_Teleport_Effect(RUINA_BALL_PARTICLE_RED, 0.25, Swordvec, SwordAng);
					Swordvec[2] += 12.5;
					SwordAng[2] += 12.5;
				}
				EmitSoundToAll("weapons/bison_main_shot.wav", weapon, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, 0.8);
			}
			else
			{
				if(Dist > 90000.0)
					TooFal=3;
				else if(Dist > 10000.0)
					TooFal=2;
				else if(Dist > 2500.0)
					TooFal=1;
				else
					TooFal=0;
				SubtractVectors(SwordAng, Swordvec, Pathing);
				NormalizeVector(Pathing, Pathing);
				GetVectorAngles(Pathing, SwordAng);
				GetAngleVectors(SwordAng, Pathing, NULL_VECTOR, NULL_VECTOR);
				SwordAng[2]=0.0;
				SwordAng[0]=0.0;
				SetEntPropVector(weapon, Prop_Data, "m_angRotation", SwordAng);
				switch(TooFal)
				{
					case 1:TooFal=50;
					case 2:TooFal=360;
					case 3:TooFal=500;
					default:TooFal=1;
				}
				Swordvec[0]=Pathing[0]*float(TooFal);
				Swordvec[1]=Pathing[1]*float(TooFal);
				Swordvec[2]=Pathing[2]*float(TooFal);
				SetEntPropVector(weapon, Prop_Data, "m_vInitialVelocity", Swordvec);
				Custom_SetAbsVelocity(weapon, Swordvec);	
				fl_JumpCooldown[weapon] = GameTime + (TooFal==5 ? 1.0 : 0.1);
			}
		}
		int Model = EntRefToEntIndex(iref_PropAppliedToRocket[weapon]);
		if(IsValidEntity(Model))
		{
			float Range = 500.0;
			Range *= Attributes_Get(weapon, 101, 1.0);
			Range *= Attributes_Get(weapon, 102, 1.0);
			CClotBody OBJ_Model = view_as<CClotBody>(Model);
			if(fl_Charge_delay[weapon] < GameTime && !b_FUCKYOU[weapon])
			{
				Handle swingTrace;
				float vecSwingForward[3];
				StartLagCompensation_Base_Boss(client);
				DoSwingTrace_Custom(swingTrace, client, vecSwingForward, Range, false, 1.0, true);
				FinishLagCompensation_Base_boss();
				TR_GetEndPosition(vecSwingForward, swingTrace);
				delete swingTrace;
				OBJ_Model.FaceTowards(vecSwingForward, 15000.0);
				float eyePitch[3], subPitch[3];
				GetEntPropVector(Model, Prop_Data, "m_angRotation", subPitch);
				GetEntPropVector(weapon, Prop_Data, "m_angRotation", eyePitch);
				subPitch[2] = fixAngle(OBJ_Model.UTIL_AngleDiff(subPitch[2], eyePitch[2])+3.0);
				//subPitch[0] = fixAngle(OBJ_Model.UTIL_AngleDiff(subPitch[0], eyePitch[0]));
				subPitch[1] = fixAngle(OBJ_Model.UTIL_AngleDiff(subPitch[1], eyePitch[1]));
				subPitch[1] = fixAngle(OBJ_Model.UTIL_AngleDiff(subPitch[1], 180.0));
				GetClientEyeAngles(client, eyePitch);
				subPitch[0] = fixAngle(-1.0*eyePitch[0]);
				SDKCall_SetLocalAngles(Model, subPitch);
				Model = EntRefToEntIndex(SwordLaserID[client]);
				if(IsValidEntity(Model))
				{
					TeleportEntity(Model, vecSwingForward, NULL_VECTOR, NULL_VECTOR);
					SetEntityRenderColor(Model, 255, 0, 0, 254);
					int Wearable = view_as<CClotBody>(Model).m_iWearable1;
					if(IsValidEntity(Wearable))
						SetEntityRenderColor(Wearable, 50, 0, 0, 255);
				}
			}
			else
			{
				int Pointer = EntRefToEntIndex(SwordLaserID[client]);
				if(IsValidEntity(Pointer))
				{
					float vOrigin[3], SwordOrigin[3], Pathing[3];
					GetAbsOrigin(Pointer, vOrigin);
					GetAbsOrigin(weapon, SwordOrigin);
					OBJ_Model.FaceTowards(vOrigin, 15000.0);
					SubtractVectors(vOrigin, SwordOrigin, Pathing);
					NormalizeVector(Pathing, Pathing);
					GetVectorAngles(Pathing, vOrigin);
					GetAngleVectors(vOrigin, Pathing, NULL_VECTOR, NULL_VECTOR);
					vOrigin[2]=0.0;
					vOrigin[0]=0.0;
					SetEntPropVector(weapon, Prop_Data, "m_angRotation", vOrigin);
					Pathing[0]=Pathing[0]*1300.0;
					Pathing[1]=Pathing[1]*1300.0;
					Pathing[2]=Pathing[2]*1300.0;
					SetEntPropVector(weapon, Prop_Data, "m_vInitialVelocity", Pathing);
					Custom_SetAbsVelocity(weapon, Pathing);
					GetEntPropVector(Model, Prop_Data, "m_angRotation", SwordOrigin);
					vOrigin[2] = fixAngle(OBJ_Model.UTIL_AngleDiff(vOrigin[2], SwordOrigin[2]));
					vOrigin[0] = fixAngle(OBJ_Model.UTIL_AngleDiff(vOrigin[0], SwordOrigin[0]));
					vOrigin[1] = fixAngle(OBJ_Model.UTIL_AngleDiff(vOrigin[1], SwordOrigin[1]));
					vOrigin[1] = fixAngle(OBJ_Model.UTIL_AngleDiff(vOrigin[1], 180.0));
					GetClientEyeAngles(client, SwordOrigin);
					vOrigin[0] = fixAngle(-1.0*SwordOrigin[0]);
					SDKCall_SetLocalAngles(Model, vOrigin);
					SetEntityRenderColor(Pointer, 0, 0, 0, 0);
					int Wearable = view_as<CClotBody>(Pointer).m_iWearable1;
					if(IsValidEntity(Wearable))
						SetEntityRenderColor(Wearable, 0, 0, 0, 0);
				}
			}
		}
	}
	return Plugin_Continue;
}

static void Wand_ShieldMage_M1_PreThink(int client)
{
	int weapon = EntRefToEntIndex(ShieldMageID[client]);
	int Sword = EntRefToEntIndex(SwordMageID[client]);
	int Prop = EntRefToEntIndex(SwordLaserID[client]);
	if(IsValidClient(client) && ShieldMageTimer[client] != null && IsValidEntity(weapon) && IsValidEntity(Sword) && IsValidEntity(Prop))
	{
		float SwordPos[3], PropPos[3];
		GetAbsOrigin(Sword, SwordPos);
		GetAbsOrigin(Prop, PropPos);
		bool GetOtherTargets;
		if(GetVectorDistance(SwordPos, PropPos, true)<256.0)
		{
			switch(i_State[Sword])
			{
				case 0, 1, 2:
				{
					i_State[Sword]++;
					GetOtherTargets=true;
				}
				default:
				{
					fl_Charge_delay[Sword]=0.0;
					b_FUCKYOU[Sword]=false;
					i_State[Sword]=0;
					GetOtherTargets=false;
				}
			
			}
			if(GetOtherTargets)
			{
				int GetTarget = SonOfOsiris_GetClosestTargetNotAffectedByLightning(client, PropPos, true);
				if(IsValidEntity(GetTarget))
				{
					float WorldSpaceVec[3]; WorldSpaceCenter(GetTarget, WorldSpaceVec);
					TeleportEntity(Prop, WorldSpaceVec, NULL_VECTOR, NULL_VECTOR);
				}
				return;
			}
			SonOfOsiris_Lightning_Strike_Reset();
			SDKUnhook(client, SDKHook_PreThink, Wand_ShieldMage_M1_PreThink);
			return;
		}
	}
	else
	{
		SDKUnhook(client, SDKHook_PreThink, Wand_ShieldMage_M1_PreThink);
		return;
	}
}

public void Wand_ShieldMage_PlayerTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, int equipped_weapon, float damagePosition[3], int zr_custom_damage)
{
	if(CheckInHud())
		return;
	
	if(!IsValidEntity(attacker) || GetTeam(attacker) == TFTeam_Red)
		return;
	
	if(!IsValidClient(victim))
		return;
	if(damagetype & DMG_TRUEDAMAGE)
		return;
	
	if(b_FUCKYOU[equipped_weapon])
	{
		if(!Skulls_PlayerHasNoSkulls(victim))
		{
			int mana_cost = RoundToCeil(damage-(damage*0.7));
			if(b_FUCKYOU_move_anim[equipped_weapon] &&
			ShieldMage_CrystalShieldTime[victim] && ShieldMage_CrystalShieldTime[victim] > GetGameTime() + 9.2)
			{
				damage*=0.5;
				b_FUCKYOU_move_anim[equipped_weapon]=false;
			}
			damage*=0.7;
			Current_Mana[victim] -= mana_cost;
		
			for(int a; a < Skulls_ArrayStack[victim].Length; a++)
			{
				int ent = EntRefToEntIndex(Skulls_ArrayStack[victim].Get(a));
				if(IsValidEdict(ent))
				{
					int Beam = ConnectWithBeam(ent, victim, 66, 135, 245, 3.0, 0.1, 0.0, LASERBEAM);
					CreateTimer(0.25, Timer_RemoveEntity, EntIndexToEntRef(Beam), TIMER_FLAG_NO_MAPCHANGE);
				}
			}
			if(fl_NextHurtSound[equipped_weapon] <= GetGameTime())
			{
				EmitSoundToAll("items/powerup_pickup_reflect.wav", victim, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 90, .soundtime = GetGameTime() - 0.123);
				fl_NextHurtSound[equipped_weapon] = GetGameTime() + 0.5;
			}
		}
	}
}

static void NoClipSwordFunction(int entity, int target)
{
	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
	if(!IsValidClient(owner)||!IsValidEntity(weapon))
	{
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(IsValidEntity(particle))
			RemoveEntity(particle);
		RemoveEntity(entity);
		return;
	}
	
	if(b_FUCKYOU[entity])
	{
		if(target > 0 && target < MAXENTITIES)
		{
			if(IsIn_HitDetectionCooldown(entity, target))
				return;
			float SwordPos[3], SwordRight[3];
			GetEntPropVector(entity, Prop_Data, "m_angRotation", SwordRight);
			GetAngleVectors(SwordRight, SwordPos, SwordRight, NULL_VECTOR);
			GetAbsOrigin(entity, SwordPos);
			Weapon_Sigil_Blade_Hit_Target_Effect(target, SwordPos, SwordRight, SwordPos);
			EmitSoundToAll(SwordHit_Sound[GetRandomInt(0, sizeof(SwordHit_Sound) - 1)], entity, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 90);
			SDKHooks_TakeDamage(target, owner, owner, fl_AbilityOrAttack[entity][0], DMG_CLUB, weapon, _, SwordPos);
			if(fl_AbilityOrAttack[entity][0]<fl_AbilityOrAttack[entity][1])
				fl_AbilityOrAttack[entity][0]=fl_AbilityOrAttack[entity][1];
			else
				fl_AbilityOrAttack[entity][0]*=0.67;
			Set_HitDetectionCooldown(entity, target, GetGameTime() + 0.5);
		}
	}
}

static void AddEntityToOwnerTransitMode(int client, int entity)
{
	i_OwnerEntityEnvLaser[entity] = EntIndexToEntRef(client);
	SDKHook(entity, SDKHook_SetTransmit, OwerTransmitEnvLaser);
}

static Action OwerTransmitEnvLaser(int entity, int client)
{
	if(client > 0 && client <= MaxClients)
	{
		int owner = EntRefToEntIndex(i_OwnerEntityEnvLaser[entity]);
		if(owner == client)
		{
			return Plugin_Continue;
		}
	}
	return Plugin_Stop;
}

static int SpawnShieldModel(int client)
{
	int wearable = CreateEntityByName("tf_wearable");
	if(wearable > MaxClients)
	{
		int team = GetClientTeam(client);
		SetEntProp(wearable, Prop_Send, "m_nModelIndex", Armor_WearableModelIndex);

		SetTeam(wearable, team);
		SetEntProp(wearable, Prop_Send, "m_nSkin", team-2);
		SetEntProp(wearable, Prop_Send, "m_usSolidFlags", 4);
		SetEntityCollisionGroup(wearable, 11);
		SetEntProp(wearable, Prop_Send, "m_bValidatedAttachedEntity", 1);
		
		DispatchSpawn(wearable);
		SetVariantString("!activator");
		ActivateEntity(wearable);

		ArmorWearableID[client] = EntIndexToEntRef(wearable);
		SDKCall_EquipWearable(client, wearable);

		SetEntProp(wearable, Prop_Send, "m_fEffects", 0);
		SetVariantString("!activator");
		AcceptEntityInput(wearable, "SetParent", client);

		SetEntityRenderMode(wearable, RENDER_TRANSCOLOR);
		SetEntityRenderColor(wearable, 125, 125, 0, 200);
		return wearable;
	}
	return -1;
}

static void SpawnCrystalShield(int client, int Spawn = 3)
{
	for(int a; a < Spawn; a++)
	{
		int prop = CreateEntityByName("prop_physics_override");
		if(IsValidEntity(prop))
		{
			b_EntityIgnoredByShield[prop] = true;
			DispatchKeyValue(prop, "targetname", "droneparent"); 
			DispatchKeyValue(prop, "spawnflags", "4"); 
			DispatchKeyValue(prop, "model", "models/props_c17/canister01a.mdl");
			DispatchSpawn(prop);
			ActivateEntity(prop);
			
			int Drone = CreateEntityByName("prop_dynamic_override");
			if(IsValidEntity(Drone))
			{
				float spawnLoc[3];
				float eyePos[3];
				float eyeAng[3];
				
				GetClientEyePosition(client, eyePos);
				GetClientEyeAngles(client, eyeAng);
				for (int i = 0; i < 3; i++)
				{
					eyeAng[i] += GetRandomFloat(0.0, 360.0);
				}
				
				Handle trace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
				
				if (TR_DidHit(trace))
				{
					TR_GetEndPosition(spawnLoc, trace);
				}
				
				delete trace;
				
				if (GetVectorDistance(spawnLoc, eyePos, true) >= (200.0 * 200.0)) //Constraint logic, borrowed from Dynamic Point Teleport and converted to a for loop
				{
					float constraint = 200.0/GetVectorDistance(spawnLoc, eyePos);
					
					for (int i = 0; i < 3; i++)
					{
						spawnLoc[i] = ((spawnLoc[i] - eyePos[i]) * constraint) + eyePos[i];
					}
				}
				
				SetEntityModel(Drone, "models/props_moonbase/moon_gravel_crystal_blue.mdl");
				
				DispatchKeyValue(Drone, "StartDisabled", "false");

				DispatchKeyValue(prop, "Health", "9999999999");
				//SetEntProp(prop, Prop_Data, "m_takedamage", 2, 1);
				SetEntProp(prop, Prop_Data, "m_takedamage", 0, 1);
				
				DispatchSpawn(Drone);
				SetEntPropFloat(Drone, Prop_Send, "m_flModelScale", 1.25);
				
				AcceptEntityInput(Drone, "Enable");
				
				SetEntPropEnt(prop, Prop_Data, "m_hOwnerEntity", client);
				SetEntProp(prop, Prop_Send, "m_fEffects", 32); //EF_NODRAW
				TeleportEntity(prop, spawnLoc, NULL_VECTOR, NULL_VECTOR);
				TeleportEntity(Drone, spawnLoc, NULL_VECTOR, NULL_VECTOR);
				
				DispatchKeyValue(Drone, "spawnflags", "1");
				SetEntPropEnt(Drone, Prop_Data, "m_hOwnerEntity", client);
				SetVariantString("!activator");
				AcceptEntityInput(Drone, "SetParent", prop);
				
				SetEntityGravity(prop, 0.0);
				SetEntityGravity(Drone, 0.0);
				MakeObjectIntangeable(Drone);
				MakeObjectIntangeable(prop);
				SetEntityRenderColor(Drone, 125, 125, 0, 255);
				SetEntityRenderFx(Drone, RENDERFX_GLOWSHELL);
				if(Skulls_ArrayStack[client] == null)
					Skulls_ArrayStack[client] = new ArrayList();
				Skulls_ArrayStack[client].Push(EntIndexToEntRef(prop));
			}
		}
	}
}