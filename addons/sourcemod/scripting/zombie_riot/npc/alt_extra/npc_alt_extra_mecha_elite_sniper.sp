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

static const char g_TauntSounds[][] = {
	"vo/mvm/norm/taunts/sniper_mvm_taunts01.mp3",
	"vo/mvm/norm/taunts/sniper_mvm_taunts02.mp3",
	"vo/mvm/norm/taunts/sniper_mvm_taunts03.mp3",
	"vo/mvm/norm/taunts/sniper_mvm_taunts04.mp3",
	"vo/mvm/norm/taunts/sniper_mvm_taunts05.mp3",
	"vo/mvm/norm/taunts/sniper_mvm_taunts06.mp3",
	"vo/mvm/norm/taunts/sniper_mvm_taunts07.mp3",
	"vo/mvm/norm/taunts/sniper_mvm_taunts08.mp3",
};

static const char g_RangedAttackSounds[][] = {
	"weapons/sniper_shoot.wav",
};

static const char g_RangedReloadSound[][] = {
	"weapons/sniper_worldreload.wav",
};

void AltExtra_Mecha_Elite_Sniper_OnMapStart() {
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_TauntSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_RangedReloadSound);
	
	PrecacheModel("models/bots/sniper/bot_sniper.mdl");
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mecha Elite Sniper");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mecha_supply_drop");
	strcopy(data.Icon, sizeof(data.Icon), "sniper");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Alt;
	data.Func = ClotSummon_Supply;
	NPC_Add(data);
	
	/*
	strcopy(data.Name, sizeof(data.Name), "Mecha Elite Sniper");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mecha_maim_moab");
	strcopy(data.Icon, sizeof(data.Icon), "sniper_sydneysleeper");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Alt;
	data.Func = ClotSummon_MOAB;
	NPC_Add(data);
	*/
}

static any ClotSummon_Supply(int client, float vecPos[3], float vecAng[3], int team) {
	return AltExtra_Mecha_Elite_Sniper(vecPos, vecAng, team, false);
}

/*
static any ClotSummon_MOAB(int client, float vecPos[3], float vecAng[3], int team) {
	return AltExtra_Mecha_Elite_Sniper(vecPos, vecAng, team, true);
}
*/

methodmap AltExtra_Mecha_Elite_Sniper < AltExtra_Base {
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
	
	public void PlayTauntSound() {
		EmitSoundToAll(g_TauntSounds[GetRandomInt(0, sizeof(g_TauntSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, .soundtime = GetGameTime() + 0.5);
	}
	
	public void UpdateBody() {
		float gameTime = GetGameTime(this.index);
		if (this.m_flDoingAnimation > gameTime)
			return;
		
		float flDeltaTime = (this.m_flLastBodyUpdateTime > 0.0) ? (gameTime - this.m_flLastBodyUpdateTime) : 0.05;
		this.m_flLastBodyUpdateTime = gameTime;
		
		if (flDeltaTime <= 0.0 || flDeltaTime > 0.5)
			flDeltaTime = 0.05;
		
		bool bCantSeeTarget = !IsValidEnemy(this.index, this.m_iTarget) || !Can_I_See_Enemy_Only(this.index, this.m_iTarget);
		if (bCantSeeTarget) {
			if (!this.m_bYawHandedOff && this.m_iBodyYawPoseParameter > -1) {
				float flYaw = this.GetPoseParameter(this.m_iBodyYawPoseParameter);
				
				if (FloatAbs(flYaw) > 0.1) {
					this.SetPoseParameter(
						this.m_iBodyYawPoseParameter,
						ApproachAngle(0.0, flYaw, ALT_EXTRA_BODY_YAW_UNTWIST_SPEED * flDeltaTime)
					);
				}
				else {
					this.m_bYawHandedOff = true;
				}
			}
			
			if (!this.m_bPitchHandedOff && this.m_iBodyPitchPoseParameter > -1) {
				float flPitch = this.GetPoseParameter(this.m_iBodyPitchPoseParameter);
				
				if (FloatAbs(flPitch) > 0.1) {
					this.SetPoseParameter(
						this.m_iBodyPitchPoseParameter,
						ApproachAngle(0.0, flPitch, ALT_EXTRA_BODY_PITCH_TRACK_SPEED * flDeltaTime)
					);
				}
				else {
					this.m_bPitchHandedOff = true;
				}
			}
			
			return;
		}
		
		if (this.m_flAttackHappens_bullshit > gameTime && this.m_flAttackHappens < gameTime)
			return;
		
		if (this.m_iBodyPitchPoseParameter < 0 && this.m_iBodyYawPoseParameter < 0)
			return;
		
		float vecMe[3], vecTarget[3];
		WorldSpaceCenter(this.index, vecMe);
		WorldSpaceCenter(this.m_iTarget, vecTarget);
		
		float vecDir[3], vecAng[3];
		if (this.m_iBodyPitchPoseParameter > -1) {
			SubtractVectors(vecMe, vecTarget, vecDir);
			NormalizeVector(vecDir, vecDir);
			GetVectorAngles(vecDir, vecAng);
			
			vecAng[0] = UTIL_AngleNormalize(vecAng[0]);
			
			float flPitch = this.GetPoseParameter(this.m_iBodyPitchPoseParameter);
			
			this.SetPoseParameter(
				this.m_iBodyPitchPoseParameter,
				ApproachAngle(vecAng[0], flPitch, ALT_EXTRA_BODY_PITCH_TRACK_SPEED * flDeltaTime)
			);
			
			this.m_bPitchHandedOff = false;
		}
		
		if (this.m_iBodyYawPoseParameter > -1) {
			SubtractVectors(vecTarget, vecMe, vecDir);
			NormalizeVector(vecDir, vecDir);
			GetVectorAngles(vecDir, vecAng);
			
			float angRotation[3];
			GetEntPropVector(this.index, Prop_Data, "m_angRotation", angRotation);
			
			float relativeYaw = -MyAngleDiff(vecAng[1], angRotation[1]);
			
			if (relativeYaw > 44.0 || relativeYaw < -44.0) {
				float flYaw = this.GetPoseParameter(this.m_iBodyYawPoseParameter);
				
				if (FloatAbs(flYaw) > 0.1) {
					this.SetPoseParameter(
						this.m_iBodyYawPoseParameter,
						ApproachAngle(0.0, flYaw, ALT_EXTRA_BODY_YAW_UNTWIST_SPEED * flDeltaTime)
					);
				}
				
				if (!this.m_bPathing)
					this.GetLocomotionInterface().FaceTowards(vecTarget);
			}
			else {
				float flYaw = this.GetPoseParameter(this.m_iBodyYawPoseParameter);
				
				float bodyYaw = clamp(relativeYaw, -44.9, 44.9);
				
				this.SetPoseParameter(
					this.m_iBodyYawPoseParameter,
					ApproachAngle(bodyYaw, flYaw, ALT_EXTRA_BODY_YAW_TRACK_SPEED * flDeltaTime)
				);
			}
			
			this.m_bYawHandedOff = false;
		}
		else {
			if (!this.m_bPathing)
				this.GetLocomotionInterface().FaceTowards(vecTarget);
		}
	}
	
	public void DoRangeAttack(float vecTarget[3]) {
		KillFeed_SetKillIcon(this.index, "sniperrifle");
		
		float vecMe[3];
		WorldSpaceCenter(this.index, vecMe);
		
		float vecDirShooting[3], vecRight[3], vecUp[3];
		
		MakeVectorFromPoints(vecMe, vecTarget, vecDirShooting);
		GetVectorAngles(vecDirShooting, vecDirShooting);
		GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
		
		float vecEnd[3];
		vecEnd[0] = vecMe[0] + vecDirShooting[0] * 9000.0; 
		vecEnd[1] = vecMe[1] + vecDirShooting[1] * 9000.0;
		vecEnd[2] = vecMe[2] + vecDirShooting[2] * 9000.0;
		
		NormalizeVector(vecDirShooting, vecDirShooting);
		
		FireBullet(this.index, this.m_iWearable1, vecMe, vecDirShooting, 100.0, 9000.0, DMG_BULLET, "bullet_tracer01_red");
		
		this.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
		this.PlayRangedSound();
	}
	
	public void DoRangeAttackAlt(float vecTarget[3]) {
		float vecMe[3];
		WorldSpaceCenter(this.index, vecMe);
		
		float vecDirShooting[3], vecRight[3], vecUp[3];
		
		MakeVectorFromPoints(vecMe, vecTarget, vecDirShooting);
		GetVectorAngles(vecDirShooting, vecDirShooting);
		GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
		
		float vecEnd[3];
		vecEnd[0] = vecMe[0] + vecDirShooting[0] * 9000.0; 
		vecEnd[1] = vecMe[1] + vecDirShooting[1] * 9000.0;
		vecEnd[2] = vecMe[2] + vecDirShooting[2] * 9000.0;
		
		NormalizeVector(vecDirShooting, vecDirShooting);
		
		float damage = 100.0;
		int target = FireBullet(this.index, this.m_iWearable1, vecMe, vecDirShooting, damage, 9000.0, DMG_BULLET, "bullet_tracer01_red");
		if (target > 0) {
			WorldSpaceCenter(target, vecEnd);
			Explode_Logic_Custom(damage, this.index, this.index, -1, vecEnd, 250.0, EXPLOSION_AOE_DAMAGE_FALLOFF, _, true, 4);
		}
		
		this.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
		this.PlayRangedSound();
	}
	
	public void SetTargetPos(const float vecPos[3]) {
		this.m_flAbilityOrAttack1 = vecPos[0];
		this.m_flAbilityOrAttack2 = vecPos[1];
		this.m_flAbilityOrAttack3 = vecPos[2];
	}
	
	public void GetTargetPos(float vecPos[3]) {
		vecPos[0] = this.m_flAbilityOrAttack1;
		vecPos[1] = this.m_flAbilityOrAttack2;
		vecPos[2] = this.m_flAbilityOrAttack3;
	}
	
	property float m_flNextSupplyDropTime {
		public get()			{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float value) { fl_AbilityOrAttack[this.index][0] = value; }
	}
	
	public AltExtra_Mecha_Elite_Sniper(float vecPos[3], float vecAng[3], int team, bool alt) {
		AltExtra_Mecha_Elite_Sniper npc = view_as<AltExtra_Mecha_Elite_Sniper>(CClotBody(vecPos, vecAng, "models/bots/sniper/bot_sniper.mdl", "1.0", "12500", team));
		
		i_NpcWeight[npc.index] = 1;
		
		int iActivity = npc.LookupActivity(alt ? "ACT_MP_DEPLOYED_PRIMARY" : "ACT_MP_RUN_PRIMARY");
		if (iActivity > 0)
			npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		
		npc.RegisterBody();
		
		func_NPCDeath[npc.index] = AltExtra_Mecha_Elite_Sniper_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = AltExtra_Mecha_Elite_Sniper_ClotThink;
		
		//IDLE
		npc.m_flSpeed = 280.0;
		npc.m_flDoingAnimation = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_flAttackHappens_bullshit = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextSupplyDropTime = GetGameTime(npc.index) + 8.0;
		
		npc.m_iChanged_WalkCycle = 0;
		npc.m_bisWalking = true;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		KillFeed_SetKillIcon(npc.index, "sniperrifle");
		
		int skin = (team == TFTeam_Red) ? 0 : 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		if (!alt) {
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_sniperrifle/c_sniperrifle.mdl");
			SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
			
			npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/all_class/bdayhat_sniper.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
			SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		}
		else {
			npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_sydney_sleeper/c_sydney_sleeper.mdl");
			SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		}
		
		return npc;
	}
}

static void AltExtra_Mecha_Elite_Sniper_ClotThink(int entity) {
	AltExtra_Mecha_Elite_Sniper npc = view_as<AltExtra_Mecha_Elite_Sniper>(entity);
	
	float gameTime = GetGameTime(npc.index);

	if (npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	npc.UpdateBody();
	
	if (npc.m_blPlayHurtAnimation) {
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	if (npc.m_flGetClosestTargetTime < gameTime) {
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	int target = npc.m_iTarget;
	if (IsValidEnemy(npc.index, target)) {
		int behavior = AltExtra_Mecha_Elite_Sniper_SelfDefense(npc, gameTime);
		switch (behavior) {
			case 0: {
				if (npc.m_iChanged_WalkCycle != 0) {
					npc.m_iChanged_WalkCycle = 0;
					npc.m_bisWalking = true;
					npc.m_flSpeed = 280.0;
					npc.StartPathing();
					
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
				}
			}
			case 1: {
				if (npc.m_iChanged_WalkCycle != 1) {
					npc.m_iChanged_WalkCycle = 1;
					npc.m_bisWalking = true;
					npc.m_flSpeed = 250.0;
					npc.StartPathing();
					
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
				}
				
				float vecBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget, _, vecBackoffPos);
				npc.SetGoalVector(vecBackoffPos, true);
			}
			case 2: {
				if (npc.m_iChanged_WalkCycle != 2) {
					npc.m_iChanged_WalkCycle = 2;
					npc.m_bisWalking = false;
					npc.m_flSpeed = 0.0;
					npc.StopPathing();
					
					npc.SetActivity("ACT_MP_STAND_PRIMARY");
				}
			}
		}
	}
	else {
		if (npc.m_iChanged_WalkCycle != 2) {
			npc.m_iChanged_WalkCycle = 2;
			npc.m_bisWalking = false;
			npc.m_flSpeed = 0.0;
			npc.StopPathing();
			
			npc.SetActivity("ACT_MP_STAND_PRIMARY");
		}
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	npc.PlayIdleAlertSound();
}

static void AltExtra_Mecha_Elite_Sniper_NPCDeath(int entity) {
	AltExtra_Mecha_Elite_Sniper npc = view_as<AltExtra_Mecha_Elite_Sniper>(entity);
	if (!npc.m_bGib)
		npc.PlayDeathSound();
	
	npc.ResetBody();
	
	if (IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if (IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}

static bool AltExtra_Mecha_Elite_Sniper_AimThink(AltExtra_Mecha_Elite_Sniper npc, float gameTime) {
	if (!IsValidEnemy(npc.index, npc.m_iTarget) || !Can_I_See_Enemy_Only(npc.index, npc.m_iTarget)) {
		npc.m_flAttackHappens = 0.0;
		npc.m_flAttackHappens_bullshit = 0.0;
		npc.m_flNextRangedAttack = gameTime + 1.0;
		
		npc.m_iTarget = GetClosestTarget(npc.index, _, _, _, _, _, _, true, _, _, true);
		
		return false;
	}
	
	float vecTarget[3], vecMe[3];
	WorldSpaceCenter(npc.m_iTarget, vecTarget);
	WorldSpaceCenter(npc.index, vecMe);
	
	float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
	
	if (flDistanceToTarget <= 1000000.0) {
		float origin[3], angles[3], vecPos[3];
		view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
		if (npc.m_flAttackHappens > gameTime) {
			WorldSpaceCenter(npc.m_iTarget, vecPos);
			
			float vecAng[3];
			GetVectorAnglesTwoPoints(vecMe, vecPos, vecAng);
			
			Handle trace = TR_TraceRayFilterEx(vecMe, vecAng, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
			if (TR_DidHit(trace)) {
				TR_GetEndPosition(vecPos, trace);
			}
			
			npc.SetTargetPos(vecPos);
			
			delete trace;
		}
		else {
			npc.GetTargetPos(vecPos);
			
			float vecAng[3];
			GetVectorAnglesTwoPoints(vecMe, vecPos, vecAng);
			
			Handle trace = TR_TraceRayFilterEx(vecMe, vecAng, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
			if (TR_DidHit(trace)) {
				TR_GetEndPosition(vecPos, trace);
				npc.SetTargetPos(vecPos);
			}
			
			delete trace;
		}
		
		int team = GetTeam(npc.index);
		int TeamColor[4] = {0, 0, 255, 255};
		if (team == TFTeam_Red)
			TeamColor = {255, 50, 50, 255};
		
		npc.GetTargetPos(vecPos);
		
		TE_SetupBeamPoints(origin, vecPos, Shared_BEAM_Laser, 0, 0, 0, 0.11, 5.0, 5.0, 0, 0.0, TeamColor, 3);
		TE_SendToAll(0.0);
		
		if (npc.m_flAttackHappens_bullshit < gameTime) {
			npc.m_flAttackHappens_bullshit = 0.0;
			npc.DoRangeAttack(vecPos);
		}
	}
	else {
		npc.m_flAttackHappens = 0.0;
		npc.m_flAttackHappens_bullshit = 0.0;
		npc.m_flNextRangedAttack = gameTime + 1.75;
		
		return false;
	}
	
	return true;
}

static int AltExtra_Mecha_Elite_Sniper_SelfDefense(AltExtra_Mecha_Elite_Sniper npc, float gameTime) {
	if (Rogue_Mode() && i_npcspawnprotection[npc.index] == NPC_SPAWNPROT_ON)
		return 0;
	
	if (npc.m_flAttackHappens_bullshit) {
		if (AltExtra_Mecha_Elite_Sniper_AimThink(npc, gameTime)) {
			return 2;
		}
		else {
			return 0;
		}
	}
	
	if (npc.m_flDoingAnimation > gameTime) {
		return 2;
	}
	
	if (npc.m_flNextSupplyDropTime < gameTime) {
		npc.AddGestureViaSequence("taunt01");
		npc.m_flDoingAnimation = gameTime + 2.67;
		
		npc.PlayTauntSound();
		
		AltExtra_Mecha_Elite_Sniper_CallSupply(npc);
		
		return 2;
	}
	
	int seenTarget = Can_I_See_Enemy(npc.index, npc.m_iTarget);
	if (!IsValidEnemy(npc.index, seenTarget)) {
		// fuck I can't see our enemy. move it!
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
		
		float vecTarget[3], vecMe[3];
		WorldSpaceCenter(npc.m_iTarget, vecTarget);
		WorldSpaceCenter(npc.index, vecMe);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
		
		if (flDistanceToTarget < npc.GetLeadRadius()) {
			float vecPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget, _, _, vecPredictedPos);
			npc.SetGoalVector(vecPredictedPos);
		}
		else {
			npc.SetGoalEntity(npc.m_iTarget);
		}
		
		return 0;
	}
	
	npc.m_iTarget = seenTarget;
	
	float vecTarget[3], vecMe[3];
	WorldSpaceCenter(npc.m_iTarget, vecTarget);
	WorldSpaceCenter(npc.index, vecMe);
	
	float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
	
	int behavior = 0;
	if (flDistanceToTarget <= 1000000.0 &&
		npc.m_flNextRangedAttack < gameTime) {
		behavior = 1;
	}
	else {
		behavior = 0;
	}
	
	if (flDistanceToTarget < npc.GetLeadRadius()) {
		float vecPredictedPos[3]; 
		PredictSubjectPosition(npc, npc.m_iTarget, _, _, vecPredictedPos);
		npc.SetGoalVector(vecPredictedPos);
	}
	else {
		npc.SetGoalEntity(npc.m_iTarget);
	}
	
	switch (behavior) {
		case 1: {
			if (npc.IsTargetInFiringCone(npc.m_iTarget, 15.0, 15.0)) {
				npc.m_flAttackHappens = gameTime + 1.0;
				npc.m_flAttackHappens_bullshit = gameTime + 1.25;
				npc.m_flNextRangedAttack = gameTime + 1.75;
			}
		}
	}
	
	if (flDistanceToTarget > 1000000.0) {
		return 0;
	}
	else if (flDistanceToTarget < 160000.0) {
		return 1;
	}
	else {
		return 2;
	}
}

static void AltExtra_Mecha_Elite_Sniper_CallSupply(AltExtra_Mecha_Elite_Sniper npc) {
	int team = GetTeam(npc.index);
	
	ArrayList teammates = new ArrayList();
	for (int other = 1; other <= MaxClients; other++) {
		if (IsValidClient(other) && !IsFakeClient(other) && IsEntityAlive(other, _, true) && team != GetTeam(other) && npc.index != other)
			teammates.Push(other);
	}
	
	int amount = 3;
	if (teammates.Length < amount) {
		for (int entitycount_again; entitycount_again < i_MaxcountNpcTotal; entitycount_again++) {
			int target = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount_again]);
			if (IsValidEntity(target) && !b_NpcHasDied[target] && GetTeam(target) != team) {
				teammates.Push(target);
			}
		}
	}
	
	if (teammates.Length < amount) {
		amount = teammates.Length;
	}
	
	if (amount > 0) {
		teammates.Sort(Sort_Random, Sort_Integer);
	}
	else {
		npc.m_flNextSupplyDropTime = GetGameTime(npc.index) + 4.0;
		return;
	}
	
	KillFeed_SetKillIcon(npc.index, "pumpkindeath");
	
	for (int i = 0; i < amount; i++) {
		int other = teammates.Get(i);
		float pos[3];
		WorldSpaceCenter(other, pos);
		
		AltExtra_Mecha_Elite_Sniper_SpawnSupplyHeadingToPos(npc.index, pos);
	}
	
	delete teammates;
	
	char flareParticle[64];
	if (team != TFTeam_Red)
		flareParticle = "utaunt_celebrationtime_blue_flare1";
	else
		flareParticle = "utaunt_celebrationtime_red_flare1";
	
	if (flareParticle[0]) {
		EmitSoundToAll("weapons/flare_detonator_launch.wav", npc.index, SNDCHAN_STATIC, .volume = 0.5, .pitch = 85, .soundtime = GetGameTime() - 0.12);
		
		float pos[3];
		WorldSpaceCenter(npc.index, pos);
		ParticleEffectAt(pos, flareParticle, 2.5);
	}
	
	npc.m_flNextSupplyDropTime = GetGameTime(npc.index) + 25.0;
}

static void AltExtra_Mecha_Elite_Sniper_SpawnSupplyHeadingToPos(int entity, float initialPos[3]) {
	float mins[3], maxs[3], pos[3];
	mins = { -48.0, -48.0, 0.0 };
	maxs = { 48.0, 48.0, 48.0 };
	
	pos = initialPos;
	pos[2] += 1000.0;
	
	Handle trace;
	trace = TR_TraceHullFilterEx(initialPos, pos, mins, maxs, MASK_PLAYERSOLID_BRUSHONLY, TraceRayHitWorldOnly);
	TR_GetEndPosition(pos, trace);
	delete trace;
	
	pos[2] -= 16.0;
	
	CClotBody npc = view_as<CClotBody>(entity); // steamhappy!
	int rocket = npc.FireParticleRocket(initialPos, 1000.0, 100.0, 10.0, "", .FromBlueNpc = false, .Override_Spawn_Loc = true, .Override_VEC = pos);
	SetEntityCollisionGroup(rocket, COLLISION_GROUP_DEBRIS);
	
	SetEntityGravity(rocket, 0.5);
	SetEntityMoveType(rocket, MOVETYPE_FLYGRAVITY);
	
	WandProjectile_ApplyFunctionToEntity(rocket, AltExtra_Mecha_Elite_Sniper_Supply_StartTouch);
	
	int crate = CreateEntityByName("prop_dynamic_override");
	if (IsValidEntity(crate)) {
		DispatchKeyValue(crate, "model", "models/props_urban/urban_crate002.mdl");
		DispatchKeyValue(crate, "StartDisabled", "false");
		DispatchKeyValue(crate, "Solid", "2");
		DispatchKeyValue(crate, "skin", "1");
		
		pos[2] += 20.0;
		TeleportEntity(crate, pos);
		DispatchSpawn(crate);
		SetEntProp(crate, Prop_Send, "m_usSolidFlags", 12); 
		SetEntityCollisionGroup(crate, 27);
		
		SetEntPropFloat(crate, Prop_Send, "m_flModelScale", 0.6);
		
		SetVariantString("!activator");
		AcceptEntityInput(crate, "SetParent", rocket);
	}
}

static void AltExtra_Mecha_Elite_Sniper_Supply_StartTouch(int entity, int target) {
	float pos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
	
	if (0 < target < MAXENTITIES) {
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if (!IsValidEntity(owner))
			owner = 0;
		
		int inflictor = h_ArrowInflictorRef[entity];
		if (inflictor != -1)
			inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);

		if (inflictor == -1)
			inflictor = owner;
		
		float damage = fl_rocket_particle_dmg[entity];
		if (ShouldNpcDealBonusDamage(target))
			damage *= h_BonusDmgToSpecialArrow[entity];
		
		int damagetype = DMG_CLUB|DMG_PREVENT_PHYSICS_FORCE;
		
		SDKHooks_TakeDamage(target, owner, inflictor, damage, damagetype, -1);	//acts like a kinetic rocket
	}
	
	ParticleEffectAt(pos, "crate_drop");
	
	if (GetRandomInt(0, 9) == 0) {
		WorldSpaceCenter(entity, pos);
		RandomPickup_SpawnPickup(pos, 60.0);
	}
	
	EmitSoundToAll("weapons/air_burster_explode3.wav", entity, SNDCHAN_STATIC);
	
	RemoveEntity(entity);
}