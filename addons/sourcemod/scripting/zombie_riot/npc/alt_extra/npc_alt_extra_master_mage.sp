#pragma semicolon 1
#pragma newdecls required

static const char g_MeleeHitSounds[][] = {
	"weapons/ubersaw_hit1.wav",
	"weapons/ubersaw_hit2.wav",
	"weapons/ubersaw_hit3.wav",
	"weapons/ubersaw_hit4.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};

static int gExplosive1;

void AltExtra_Medic_Master_Mage_OnMapStart() {
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_DefaultMeleeMissSounds);
	PrecacheSoundArray(g_DefaultCapperShootSound);
	PrecacheSoundArray(g_DefaultLaserLaunchSound);
	
	PrecacheSound("weapons/physcannon/energy_sing_loop4.wav", true);
	PrecacheSound("weapons/physcannon/physcannon_drop.wav", true);
	
	gExplosive1 = PrecacheModel("materials/sprites/sprite_fire01.vmt");
	
	PrecacheSound("player/flow.wav");
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Medic Master Mage");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_master_mage");
	strcopy(data.Icon, sizeof(data.Icon), "magia");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Alt;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team) {
	return AltExtra_Medic_Master_Mage(vecPos, vecAng, team);
}

methodmap AltExtra_Medic_Master_Mage < AltExtra_Base {
	property float m_flTimebeforekamehameha {
		public get()							{ return fl_BEAM_RechargeTime[this.index]; }
		public set(float TempValueForProperty) 	{ fl_BEAM_RechargeTime[this.index] = TempValueForProperty; }
	}
	
	property float m_flTimeBeforeIOC {
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	property bool m_bInKame {
		public get()							{ return b_InKame[this.index]; }
		public set(bool TempValueForProperty) 	{ b_InKame[this.index] = TempValueForProperty; }
	}
	
	public void PlayIdleAlertSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		EmitSoundToAll(g_RobotMedic_IdleAlertedSounds[GetRandomInt(0, sizeof(g_RobotMedic_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_DefaultCapperShootSound[GetRandomInt(0, sizeof(g_DefaultCapperShootSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);	
	}
	
	public void PlayHurtSound() {
		EmitSoundToAll(g_RobotMedic_HurtSounds[GetRandomInt(0, sizeof(g_RobotMedic_HurtSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);	
	}
	
	public void PlayDeathSound() {
		EmitSoundToAll(g_RobotMedic_DeathSounds[GetRandomInt(0, sizeof(g_RobotMedic_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);	
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_DefaultMeleeMissSounds[GetRandomInt(0, sizeof(g_DefaultMeleeMissSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayLaserLaunchSound() {
		int chose = GetRandomInt(0, sizeof(g_DefaultLaserLaunchSound)-1);
		EmitSoundToAll(g_DefaultLaserLaunchSound[chose], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_DefaultLaserLaunchSound[chose], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public AltExtra_Medic_Master_Mage(float vecPos[3], float vecAng[3], int team) {
		AltExtra_Medic_Master_Mage npc = view_as<AltExtra_Medic_Master_Mage>(CClotBody(vecPos, vecAng, "models/bots/medic/bot_medic.mdl", "1.25", "25000", team));
		
		i_NpcWeight[npc.index] = 3;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if (iActivity > 0)
			npc.StartActivity(iActivity);

		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NONE;
		
		npc.m_flSpeed = 300.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = true;
		npc.m_fbRangedSpecialOn = false;
		
		int skin = (team == TFTeam_Red) ? 0 : 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);
		
		npc.m_iWearable1 = npc.EquipItem("head", RUINA_CUSTOM_MODELS_1);
		SetVariantInt(RUINA_W30_HAND_CREST);
		AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
		SetVariantString("0.8");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/robo_medic_grimm_hatte/robo_medic_grimm_hatte.mdl");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/all_class/jul13_se_headset/jul13_se_headset_medic.mdl");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/cc_summer2015_the_vascular_vestment/cc_summer2015_the_vascular_vestment.mdl");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		
		SetEntityRenderColor(npc.m_iWearable2, 7, 255, 255, 255);
		SetEntityRenderColor(npc.m_iWearable3, 7, 255, 255, 255);
		SetEntityRenderColor(npc.m_iWearable4, 7, 255, 255, 255);
		
		npc.StartPathing();
		
		npc.m_flTimeBeforeIOC = GetGameTime(npc.index) + 5.0;
		npc.m_flTimebeforekamehameha = GetGameTime(npc.index) + 7.5;
		
		npc.m_bInKame = false;
		npc.Anger = false;
		
		return npc;
	}
}

static void Internal_ClotThink(int iNPC) {
	AltExtra_Medic_Master_Mage npc = view_as<AltExtra_Medic_Master_Mage>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	
	if (npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if (npc.m_blPlayHurtAnimation) {
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if (npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if (npc.m_flGetClosestTargetTime < gameTime) {
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	int target = npc.m_iTarget;
	if (IsValidEnemy(npc.index, target)) {
		float vecTarget[3];
		WorldSpaceCenter(target, vecTarget);
		if (npc.m_flReloadDelay < gameTime) {
			if (npc.m_flmovedelay < gameTime) {
				npc.m_flmovedelay = gameTime + 1.5;
				npc.m_flSpeed = 300.0;
			}
		}
		
		float vecMe[3];
		WorldSpaceCenter(npc.index, vecMe);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
		
		npc.ModifyBodyPitch(vecMe, vecTarget);
		
		//Predict their pos.
		if (flDistanceToTarget < npc.GetLeadRadius()) {
			float vPredictedPos[3];
			PredictSubjectPosition(npc, target,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else {
			npc.SetGoalEntity(target);
		}
		
		if (flDistanceToTarget > 22500.0 && flDistanceToTarget < 160000.0) {
			if (npc.m_flTimebeforekamehameha < gameTime) {
				npc.m_bInKame = true;
				Invoke_AltExtra_Medic_Master_Mage_Laser(npc);
				npc.m_flTimebeforekamehameha = gameTime + (npc.Anger ? 30.0 : 45.0);
			}
		}
		
		if (npc.m_bInKame) {
			npc.FaceTowards(vecTarget, 700.0);
			npc.m_flSpeed = 100.0;
			f_NpcTurnPenalty[npc.index] = 0.3;
		}
		else {
			npc.m_flSpeed = 300.0;
			f_NpcTurnPenalty[npc.index] = 1.0;
		}
		
		if (flDistanceToTarget > 60000 && flDistanceToTarget < 120000 && !npc.m_bInKame && npc.m_flTimeBeforeIOC < gameTime) {
			Invoke_AltExtra_Medic_Master_Mage_IOC(EntIndexToEntRef(npc.index), target);
			npc.m_flTimeBeforeIOC = gameTime + (npc.Anger ? 30.0 : 45.0);
		}
		
		//Target close enough to hit
		if (flDistanceToTarget < 22500 || npc.m_flAttackHappenswillhappen && !npc.m_bInKame) {
			//Can we attack right now?
			if (npc.m_flNextMeleeAttack < gameTime) {
				//Play attack ani
				if (!npc.m_flAttackHappenswillhappen) {
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					npc.PlayMeleeSound();
					npc.m_flAttackHappens = gameTime+0.4;
					npc.m_flAttackHappens_bullshit = gameTime+0.54;
					npc.m_flAttackHappenswillhappen = true;
				}
				
				if (npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen) {
					Handle swingTrace;
					npc.FaceTowards(vecTarget, 20000.0);
					if (npc.DoSwingTrace(swingTrace, target,_,_,_,1)) {
						int targetHit = TR_GetEntityIndex(swingTrace);	
							
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						
						if (targetHit > 0) {
							float damage = 300.0;
							
							if (ShouldNpcDealBonusDamage(targetHit))
								damage *= 3.0;
							
							if (npc.Anger)
								damage *= 1.5;
							
							SDKHooks_TakeDamage(targetHit, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
							
							Custom_Knockback(npc.index, targetHit, 400.0);
							
							// Hit sound
							npc.PlayMeleeHitSound();
						}
					}
					delete swingTrace;
					
					npc.m_flNextMeleeAttack = gameTime + 0.8;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen) {
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = gameTime + 0.8;
				}
			}
		}
		else if (flDistanceToTarget > 22500 && npc.m_flAttackHappens_2 < gameTime && !npc.m_bInKame) {
			npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
			
			npc.m_flAttackHappens_2 = gameTime + 1.5;
			npc.PlayRangedSound();
			npc.FireParticleRocket(vecTarget, npc.Anger ? 250.0 : 150.0, 600.0, 100.0, "raygun_projectile_blue");
		}
		else {
			npc.StartPathing();
		}
		
		if (npc.m_flReloadDelay < gameTime) {
			npc.StartPathing();
		}
	}
	else {
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	npc.PlayIdleAlertSound();
}

static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	// Valid attackers only.
	if (attacker <= 0)
		return Plugin_Continue;
	
	AltExtra_Medic_Master_Mage npc = view_as<AltExtra_Medic_Master_Mage>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index)) {
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	if (!npc.Anger && ((ReturnEntityMaxHealth(npc.index) / 2) >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))) {
		npc.Anger = true;
	}
	
	return Plugin_Changed;
}

static void Internal_NPCDeath(int entity) {
	AltExtra_Medic_Master_Mage npc = view_as<AltExtra_Medic_Master_Mage>(entity);
	if (!npc.m_bGib) {
		npc.PlayDeathSound();	
	}
	
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
}

static void Invoke_AltExtra_Medic_Master_Mage_Laser(AltExtra_Medic_Master_Mage npc) {
	float GameTime = GetGameTime(npc.index);
	fl_BEAM_DurationTime[npc.index] = GameTime + 10.0;
	fl_BEAM_ChargeUpTime[npc.index] = GameTime + 0.5;
	
	EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", npc.index, SNDCHAN_STATIC, 80, _, 0.25, 75);
	
	npc.PlayLaserLaunchSound();
	SDKUnhook(npc.index, SDKHook_Think, AltExtra_Medic_Master_Mage_LaserTick);
	SDKHook(npc.index, SDKHook_Think, AltExtra_Medic_Master_Mage_LaserTick);
}

static Action AltExtra_Medic_Master_Mage_LaserTick(int client) {
	AltExtra_Medic_Master_Mage npc = view_as<AltExtra_Medic_Master_Mage>(client);
	float gameTime = GetGameTime(npc.index);
	if (!IsValidEntity(client) || fl_BEAM_DurationTime[npc.index] < gameTime) {
		SDKUnhook(client, SDKHook_Think, AltExtra_Medic_Master_Mage_LaserTick);
		
		StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
		StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
		StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
		StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
		EmitSoundToAll("weapons/physcannon/physcannon_drop.wav", client, SNDCHAN_STATIC, 80, _, 1.0);
		
		npc.m_bInKame = false;
		
		return Plugin_Stop;
	}
	
	if (fl_BEAM_ChargeUpTime[npc.index] > GetGameTime(npc.index))
		return Plugin_Continue;
	
	Basic_NPC_Laser Data;
	Data.npc = npc;
	Data.Radius = 10.0;
	Data.Range = (npc.Anger ? 900.0 : 750.0);
	//divided by 6 since its every tick, and by TickrateModify
	Data.Close_Dps = (npc.Anger ? 45.0 : 30.0) / 6.0 / TickrateModify / ReturnEntityAttackspeed(npc.index);
	Data.Long_Dps = (npc.Anger ? 22.5 : 17.5) / 6.0 / TickrateModify / ReturnEntityAttackspeed(npc.index);
	Data.Color = (npc.Anger ? {255, 255, 255, 60} : {5, 9, 250, 30});
	Data.DoEffects = true;
	npc.GetAttachment("eye_2", Data.EffectsStartLoc, NULL_VECTOR);
	Basic_NPC_Laser_Logic(Data);
	
	return Plugin_Continue;
}

static void Invoke_AltExtra_Medic_Master_Mage_IOC(int ref, int enemy) {
	int entity = EntRefToEntIndex(ref);
	if (IsValidEntity(entity)) {
		static float distance = 87.0; // /29 for duartion till boom
		static float IOCDist = 250.0;
		static float IOCdamage = 200.0;
		
		float vecTarget[3];
		GetEntPropVector(enemy, Prop_Data, "m_vecAbsOrigin", vecTarget);	
		
		Handle data = CreateDataPack();
		WritePackFloat(data, vecTarget[0]);
		WritePackFloat(data, vecTarget[1]);
		WritePackFloat(data, vecTarget[2]);
		WritePackCell(data, distance); // Distance
		WritePackFloat(data, 0.0); // nphi
		WritePackFloat(data, IOCDist); // Range
		WritePackFloat(data, IOCdamage); // Damge
		WritePackCell(data, ref);
		ResetPack(data);
		AltExtra_Medic_Master_Mage_IonAttack(data);
	}
}

static Action AltExtra_Medic_Master_Mage_DrawIon(Handle timer, any data) {
	AltExtra_Medic_Master_Mage_IonAttack(data);
	
	return Plugin_Stop;
}
	
static void AltExtra_Medic_Master_Mage_DrawIonBeam(float startPosition[3], const int color[4]) {
	float position[3];
	position[0] = startPosition[0];
	position[1] = startPosition[1];
	position[2] = startPosition[2] + 3000.0;	
	
	TE_SetupBeamPoints(startPosition, position, g_Ruina_BEAM_Laser, 0, 0, 0, 0.15, 25.0, 25.0, 0, 1.0, color, 3);
	TE_SendToAll();
	position[2] -= 1490.0;
	TE_SetupGlowSprite(startPosition, g_Ruina_Glow_Blue, 1.0, 1.0, 255);
	TE_SendToAll();
}

static void AltExtra_Medic_Master_Mage_IonAttack(Handle &data) {
	float startPosition[3];
	float position[3];
	startPosition[0] = ReadPackFloat(data);
	startPosition[1] = ReadPackFloat(data);
	startPosition[2] = ReadPackFloat(data);
	float Iondistance = ReadPackCell(data);
	float nphi = ReadPackFloat(data);
	float Ionrange = ReadPackFloat(data);
	float Iondamage = ReadPackFloat(data);
	int client = EntRefToEntIndex(ReadPackCell(data));
	
	if (!IsValidEntity(client) || b_NpcHasDied[client]) {
		delete data;
		return;
	}
	spawnRing_Vectors(startPosition, Ionrange * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 212, 175, 55, 255, 1, 0.2, 12.0, 4.0, 3);	
	
	if (Iondistance > 0) {
		EmitSoundToAll("ambient/energy/weld1.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, startPosition);
		
		// Stage 1
		float s = Sine(nphi / 360 * 6.28) * Iondistance;
		float c = Cosine(nphi / 360 * 6.28) * Iondistance;

		position[0] = startPosition[0];
		position[1] = startPosition[1];
		position[2] = startPosition[2];
		position[0] -= s;
		position[1] -= c;
		AltExtra_Medic_Master_Mage_DrawIonBeam(position, {212, 212, 55, 255});
		
		// Stage 2
		s = Sine((nphi + 45.0) / 360 * 6.28) * Iondistance;
		c = Cosine((nphi + 45.0) / 360 * 6.28) * Iondistance;
		
		position[0] = startPosition[0];
		position[1] = startPosition[1];
		position[0] += s;
		position[1] += c;
		AltExtra_Medic_Master_Mage_DrawIonBeam(position, {212, 212, 55, 255});
		
		// Stage 3
		s = Sine((nphi + 90.0) / 360 * 6.28) * Iondistance;
		c = Cosine((nphi + 90.0) / 360 * 6.28) * Iondistance;
		
		position[0] = startPosition[0];
		position[1] = startPosition[1];
		position[0] -= s;
		position[1] -= c;
		AltExtra_Medic_Master_Mage_DrawIonBeam(position, {212, 212, 55, 255});
		
		// Stage 3
		s = Sine((nphi + 135.0) / 360 * 6.28) * Iondistance;
		c = Cosine((nphi + 135.0) / 360 * 6.28) * Iondistance;
		
		position[0] = startPosition[0];
		position[1] = startPosition[1];
		position[0] += s;
		position[1] += c;
		AltExtra_Medic_Master_Mage_DrawIonBeam(position, {212, 212, 55, 255});
		
		if (nphi >= 360)
			nphi = 0.0;
		else
			nphi += 5.0;
	}
	Iondistance -= 10;
	
	delete data;

	Handle nData = CreateDataPack();
	WritePackFloat(nData, startPosition[0]);
	WritePackFloat(nData, startPosition[1]);
	WritePackFloat(nData, startPosition[2]);
	WritePackCell(nData, Iondistance);
	WritePackFloat(nData, nphi);
	WritePackFloat(nData, Ionrange);
	WritePackFloat(nData, Iondamage);
	WritePackCell(nData, EntIndexToEntRef(client));
	ResetPack(nData);
	
	if (Iondistance > -30.0)
		CreateTimer(0.1, AltExtra_Medic_Master_Mage_DrawIon, nData, TIMER_FLAG_NO_MAPCHANGE);
	else {
		if (b_Anger[client])
			Explode_Logic_Custom(Iondamage * 2.0, client, client, -1, startPosition, Ionrange);
		else
			Explode_Logic_Custom(Iondamage * 2.0, client, client, -1, startPosition, Ionrange);
		
		DataPack pack_boom = new DataPack();
		pack_boom.WriteFloat(startPosition[0]);
		pack_boom.WriteFloat(startPosition[1]);
		pack_boom.WriteFloat(startPosition[2]);
		pack_boom.WriteCell(1);
		RequestFrame(MakeExplosionFrameLater, pack_boom);
		
		TE_SetupExplosion(startPosition, gExplosive1, 10.0, 1, 0, 0, 0);
		TE_SendToAll();
		
		spawnRing_Vectors(startPosition, 0.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 212, 212, 55, 255, 1, 0.5, 20.0, 10.0, 3, Ionrange * 2.0);	
		position[0] = startPosition[0];
		position[1] = startPosition[1];
		position[2] += startPosition[2] + 900.0;
		startPosition[2] += -200;
		
		TE_SetupBeamPoints(startPosition, position, g_Ruina_BEAM_Laser, 0, 0, 0, 2.0, 30.0, 30.0, 0, 1.0, {212, 212, 55, 255}, 3);
		TE_SendToAll();
		TE_SetupBeamPoints(startPosition, position, g_Ruina_BEAM_Laser, 0, 0, 0, 2.0, 50.0, 50.0, 0, 1.0, {212, 212, 55, 200}, 3);
		TE_SendToAll();
		TE_SetupBeamPoints(startPosition, position, g_Ruina_BEAM_Laser, 0, 0, 0, 2.0, 100.0, 100.0, 0, 1.0, {212, 212, 55, 75}, 3);
		TE_SendToAll();
		
		position[2] = startPosition[2] + 50.0;
		
		// Sound
		EmitSoundToAll("ambient/explosions/explode_9.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, startPosition);
	}
}