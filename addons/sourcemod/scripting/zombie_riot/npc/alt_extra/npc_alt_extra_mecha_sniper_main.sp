#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/mvm/norm/sniper_mvm_paincrticialdeath01.mp3",
	"vo/mvm/norm/sniper_mvm_paincrticialdeath02.mp3",
	"vo/mvm/norm/sniper_mvm_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/mvm/norm/sniper_mvm_painsharp01.mp3",
	"vo/mvm/norm/sniper_mvm_painsharp02.mp3",
	"vo/mvm/norm/sniper_mvm_painsharp03.mp3",
	"vo/mvm/norm/sniper_mvm_painsharp04.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/norm/sniper_mvm_battlecry01.mp3",
	"vo/mvm/norm/sniper_mvm_battlecry02.mp3",
	"vo/mvm/norm/sniper_mvm_battlecry03.mp3",
	"vo/mvm/norm/sniper_mvm_battlecry04.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/cbar_hitbod1.wav",
	"weapons/cbar_hitbod2.wav",
	"weapons/cbar_hitbod3.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/machete_swing.wav",
};

static const char g_RangedAttackSounds[][] = {
	"weapons/smg_shoot.wav",
};

static const char g_RangedReloadSound[][] = {
	"weapons/smg_worldreload.wav",
};

void AltExtra_Mecha_Sniper_Main_OnMapStart() {
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_DefaultMeleeMissSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_RangedReloadSound);
	
	PrecacheModel("models/bots/sniper/bot_sniper.mdl");
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mecha Sniper Main");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mecha_sniper_main");
	strcopy(data.Icon, sizeof(data.Icon), "sniper");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Alt;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team) {
	return AltExtra_Mecha_Sniper_Main(vecPos, vecAng, team);
}

methodmap AltExtra_Mecha_Sniper_Main < AltExtra_Base {
	public void PlayIdleAlertSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayHurtSound() {
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_DefaultMeleeMissSounds[GetRandomInt(0, sizeof(g_DefaultMeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void GetEyeAngles(float vecAng[3]) {
		GetEntPropVector(this.index, Prop_Data, "m_angRotation", vecAng);
		
		if (this.m_iBodyYawPoseParameter > -1) {
			vecAng[1] -= this.GetPoseParameter(this.m_iBodyYawPoseParameter);
		}
		
		if (this.m_iBodyPitchPoseParameter > -1) {
			vecAng[0] = MyAngleDiff(vecAng[0], this.GetPoseParameter(this.m_iBodyPitchPoseParameter));
		}
		
		vecAng[1] = UTIL_AngleNormalize(vecAng[1]);
		vecAng[0] = UTIL_AngleNormalize(vecAng[0]);
	}
	
	public bool IsTargetInFiringCone(int target, float maxYawAngle = 20.0, float maxPitchAngle = 20.0) {
		float vecMe[3], vecTarget[3], vecToTarget[3];
		float angEye[3], angTarget[3];
		
		WorldSpaceCenter(this.index, vecMe);
		WorldSpaceCenter(target, vecTarget);
		
		SubtractVectors(vecTarget, vecMe, vecToTarget);
		GetVectorAngles(vecToTarget, angTarget);
		
		this.GetEyeAngles(angEye);
		
		// Yaw
		float flYawDiff = MyAngleDiff(angTarget[1], angEye[1]);
		
		if (FloatAbs(flYawDiff) > maxYawAngle) {
			return false;
		}
		
		// Pitch
		if (this.m_iBodyPitchPoseParameter > -1) {
			float flPitchDiff = MyAngleDiff(angTarget[0], angEye[0]);
			if (FloatAbs(flPitchDiff) > maxPitchAngle) {
				return false;
			}
		}
		
		return true;
	}
	
	public void RangeAttack() {
		// WorldSpaceCenter(target, vecTarget);
		
		this.m_flNextRangedAttack = GetGameTime(this.index) + 0.125;
		this.m_iAttacksTillReload--;
		
		float vecSpread = 0.1;
		
		float x, y;
		x = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
		y = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
		
		float vecDirShooting[3], vecRight[3], vecUp[3];
		
		float vecMe[3];
		WorldSpaceCenter(this.index, vecMe);
		// MakeVectorFromPoints(vecMe, vecTarget, vecDirShooting);
		this.GetEyeAngles(vecDirShooting);
		
		// GetVectorAngles(vecDirShooting, vecDirShooting);
		GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
		
		this.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
		
		float vecDir[3];
		vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
		vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
		vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
		NormalizeVector(vecDir, vecDir);
		
		FireBullet(this.index, this.m_iWearable1, vecMe, vecDir, 10.0, 9000.0, DMG_BULLET, "bullet_tracer01_blue");
		
		this.PlayRangedSound();
	}
	
	public void Reload() {
		this.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY");
		this.m_flReloadDelay = GetGameTime(this.index) + 1.4;
		this.m_iAttacksTillReload = 10;
		this.PlayRangedReloadSound();
	}
	
	public void ProcessAnger() {
		if (IsValidEntity(this.m_iWearable1))
			RemoveEntity(this.m_iWearable1);
		
		this.m_iWearable1 = this.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_scimitar/c_scimitar.mdl");
		
		this.AdjustWalkCycle(3);
	}
	
	public void AdjustWalkCycle(int walkCycle) {
		if (this.m_iChanged_WalkCycle == walkCycle)
			return;
		
		this.m_iChanged_WalkCycle = walkCycle;
		
		switch (walkCycle) {
			case 0: {
				this.SetActivity("ACT_MP_RUN_SECONDARY");
				this.m_bisWalking = true;
				this.m_bAllowBackWalking = false;
				this.m_flSpeed = 250.0;
				this.StartPathing();
			}
			case 1: {
				this.SetActivity("ACT_MP_STAND_SECONDARY");
				this.m_bisWalking = false;
				this.m_bAllowBackWalking = false;
				this.m_flSpeed = 0.0;
				this.StopPathing();
			}
			case 2: {
				this.SetActivity("ACT_MP_RUN_SECONDARY");
				this.m_bisWalking = true;
				this.m_bAllowBackWalking = true;
				this.m_flSpeed = 210.0;
				this.StartPathing();
			}
			case 3: {
				this.SetActivity("ACT_MP_RUN_MELEE");
				this.m_bisWalking = true;
				this.m_bAllowBackWalking = false;
				this.m_flSpeed = 300.0;
				this.StartPathing();
			}
			case 4: {
				this.SetActivity("ACT_MP_STAND_MELEE");
				this.m_bisWalking = false;
				this.m_bAllowBackWalking = false;
				this.m_flSpeed = 0.0;
				this.StopPathing();
			}
		}
	}
	
	public AltExtra_Mecha_Sniper_Main(float vecPos[3], float vecAng[3], int team) {
		AltExtra_Mecha_Sniper_Main npc = view_as<AltExtra_Mecha_Sniper_Main>(CClotBody(vecPos, vecAng, "models/bots/sniper/bot_sniper.mdl", "1.0", "12500", team));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		
		npc.RegisterBody();
		
		func_NPCDeath[npc.index] = AltExtra_Mecha_Sniper_Main_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = AltExtra_Mecha_Sniper_Main_OnTakeDamage;
		func_NPCThink[npc.index] = AltExtra_Mecha_Sniper_Main_ClotThink;
		
		//IDLE
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flGetClosestTargetTime = 0.0;
		
		npc.AdjustWalkCycle(0);
		
		npc.m_iAttacksTillReload = 10;
		
		int skin = (team == TFTeam_Red) ? 0 : 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.index, 125, 100, 100, 255);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_smg/c_smg.mdl");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/sniper/grfs_sniper.mdl");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable2, 125, 100, 100, 255);
		
		return npc;
	}
}

static void AltExtra_Mecha_Sniper_Main_ClotThink(int entity) {
	AltExtra_Mecha_Sniper_Main npc = view_as<AltExtra_Mecha_Sniper_Main>(entity);
	
	float gameTime = GetGameTime(npc.index);

	if (npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	npc.HackMaxYawRate(false);
	npc.UpdateBody();
	npc.HackMaxYawRate(true);
	
	if (npc.m_blPlayHurtAnimation) {
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	int target = npc.m_iTarget;
	if (IsValidEnemy(npc.index, target)) {
		float vecTarget[3], vecMe[3];
		WorldSpaceCenter(target, vecTarget);
		WorldSpaceCenter(npc.index, vecMe);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
		
		if (npc.Anger) {
			if (npc.m_flAttackHappenswillhappen) {
				if (npc.m_flAttackHappens < gameTime) {
					npc.FaceTowards(vecTarget, 20000.0);
					
					Handle swingTrace;
					if (npc.DoSwingTrace(swingTrace, target)) {
						int targetHit = TR_GetEntityIndex(swingTrace);
						
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						
						if (targetHit > 0) {
							float damage = 35.0;
							if (ShouldNpcDealBonusDamage(targetHit))
								damage *= 2.0;
							
							SDKHooks_TakeDamage(targetHit, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
							
							// Hit sound
							npc.PlayMeleeHitSound();
						}
					}
					delete swingTrace;
					
					npc.m_flNextMeleeAttack = gameTime + 0.1;
					npc.m_flAttackHappenswillhappen = false;
				}
			}
			else {
				if (flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED
					&& npc.m_flNextMeleeAttack < gameTime) {
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					npc.PlayMeleeSound();
					npc.m_flAttackHappens = gameTime + 0.4;
					npc.m_flAttackHappenswillhappen = true;
				}
			}
			
			npc.AdjustWalkCycle(3);
			
			if (flDistanceToTarget < npc.GetLeadRadius()) {
				float vecPredictedPos[3];
				PredictSubjectPosition(npc, target, _, _, vecPredictedPos);
				npc.SetGoalVector(vecPredictedPos);
			}
			else {
				npc.SetGoalEntity(target);
			}
		}
		else {
			// 350 * 350 = 122500
			if (npc.m_flNextRangedAttack < gameTime && flDistanceToTarget <= 250000.0 && npc.m_flReloadDelay < gameTime) {
				if (Can_I_See_Enemy_Only(npc.index, target) && npc.IsTargetInFiringCone(target)) {
					npc.RangeAttack();
					
					if (npc.m_iAttacksTillReload == 0) {
						npc.Reload();
					}
				}
			}
			
			if (flDistanceToTarget > 160000.0) {
				npc.AdjustWalkCycle(0);
				
				if (flDistanceToTarget < npc.GetLeadRadius()) {
					float vecPredictedPos[3];
					PredictSubjectPosition(npc, target, _, _, vecPredictedPos);
					npc.SetGoalVector(vecPredictedPos);
				}
				else {
					npc.SetGoalEntity(target);
				}
			}
			else if (flDistanceToTarget > 90000.0) {
				if (Can_I_See_Enemy_Only(npc.index, target)) {
					npc.AdjustWalkCycle(2);
					
					float vBackoffPos[3];
					BackoffFromOwnPositionAndAwayFromEnemy(npc, target, _, vBackoffPos, 1);
					npc.SetGoalVector(vBackoffPos, true);
				}
				else {
					npc.AdjustWalkCycle(0);
					
					if (flDistanceToTarget < npc.GetLeadRadius()) {
						float vecPredictedPos[3];
						PredictSubjectPosition(npc, target, _, _, vecPredictedPos);
						npc.SetGoalVector(vecPredictedPos);
					}
					else {
						npc.SetGoalEntity(target);
					}
				}
			}
			else {
				npc.AdjustWalkCycle(2);
				
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, target, _, vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true);
			}
		}
	}
	else {
		npc.AdjustWalkCycle(npc.Anger ? 4 : 1);
		
		npc.m_flGetClosestTargetTime = 0.0;
		// npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	if (npc.m_flGetClosestTargetTime < gameTime) {
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	npc.PlayIdleAlertSound();
}

static Action AltExtra_Mecha_Sniper_Main_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	AltExtra_Mecha_Sniper_Main npc = view_as<AltExtra_Mecha_Sniper_Main>(victim);
	
	if (attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index)) {
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	if (!npc.Anger && ((ReturnEntityMaxHealth(npc.index) / 2) >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))) {
		npc.Anger = true;
		npc.m_flSpeed = 300.0;
		npc.ProcessAnger();
	}
	
	return Plugin_Continue;
}

static void AltExtra_Mecha_Sniper_Main_NPCDeath(int entity) {
	AltExtra_Mecha_Sniper_Main npc = view_as<AltExtra_Mecha_Sniper_Main>(entity);
	if (!npc.m_bGib)
		npc.PlayDeathSound();
	
	npc.ResetBody();
	
	if (IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if (IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}