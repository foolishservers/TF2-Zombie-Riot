#pragma semicolon 1
#pragma newdecls required

static char g_DeathSounds[][] = {
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav",
};

static char g_HurtSounds[][] = {
	"npc/combine_soldier/pain1.wav",
	"npc/combine_soldier/pain2.wav",
	"npc/combine_soldier/pain3.wav",
};

static char g_IdleSounds[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
};

static char g_IdleAlertedSounds[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
};

static char g_MeleeHitSounds[][] = {
	"npc/vort/foot_hit.wav",
};

static char g_MeleeAttackSounds[][] = {
	"npc/combine_soldier/gear1.wav",
	"npc/combine_soldier/gear2.wav",
	"npc/combine_soldier/gear3.wav",
	"npc/combine_soldier/gear4.wav",
	"npc/combine_soldier/gear5.wav",
	"npc/combine_soldier/gear6.wav",
};

static char g_RangedAttackSounds[][] = {
	"weapons/ar2/fire1.wav",
};

static char g_RangedReloadSound[][] = {
	"weapons/ar2/npc_ar2_reload.wav",
};

static char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

static const char g_RangedAttackSoundsSecondary[][] = {
	"mvm/giant_soldier/giant_soldier_rocket_shoot.wav",
};

void Combine_Pretorian_Guard_OnMapStart() {
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "W.F. Pretorian Guard");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_combine_pretorian_guard");
	strcopy(data.Icon, sizeof(data.Icon), "sniper");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_WhiteflowerSpecial;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache() {
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_RangedReloadSound);
	PrecacheSoundArray(g_RangedAttackSoundsSecondary);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data) {
	return Combine_Pretorian_Guard(vecPos, vecAng, ally, data);
}

methodmap Combine_Pretorian_Guard < Combine_Base {
	public void PlayIdleSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
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
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayRangedAttackSecondarySound() {
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void DoMeleeAttack(int target, float gameTime) {
		if (this.m_flAttackHappens < gameTime && this.m_flAttackHappens_bullshit >= gameTime) {
			float vecTarget[3];
			WorldSpaceCenter(target, vecTarget);
			this.FaceTowards(vecTarget, 15000.0);
			
			Handle swingTrace;
			if (this.DoSwingTrace(swingTrace, target,
				{ 96.0, 96.0, -128.0 },
				{ -96.0, -96.0, 128.0 })) {
				int targetHit = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if (targetHit > 0) {
					SDKHooks_TakeDamage(targetHit, this.index, this.index, 250.0, DMG_CLUB, -1, _, vecHit);
					ApplyStatusEffect(this.index, targetHit, "Cudgelled", 10.0);
					Custom_Knockback(this.index, targetHit, 450.0);
					
					if (targetHit <= MaxClients)
						Client_Shake(targetHit, 0, 25.0, 25.0, 0.5);
					
					this.PlayMeleeHitSound();
				}
			}
			
			delete swingTrace;
			
			this.m_flAttackHappenswillhappen = false;
		}
		else if (this.m_flAttackHappens_bullshit < gameTime) {
			this.m_flAttackHappenswillhappen = false;
		}
	}
	
	public void DoRangeAttack(int target) {
		float vecTarget[3];
		WorldSpaceCenter(target, vecTarget);
		
		float vecSpread = 0.1;
		
		float x, y;
		x = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
		y = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
		
		float vecDirShooting[3], vecRight[3], vecUp[3];
		vecTarget[2] += 15.0;
		
		float vecMe[3];
		WorldSpaceCenter(this.index, vecMe);
		
		MakeVectorFromPoints(vecMe, vecTarget, vecDirShooting);
		GetVectorAngles(vecDirShooting, vecDirShooting);
		GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
		
		float vecEnd[3];
		vecEnd[0] = vecMe[0] + vecDirShooting[0] * 9000.0; 
		vecEnd[1] = vecMe[1] + vecDirShooting[1] * 9000.0;
		vecEnd[2] = vecMe[2] + vecDirShooting[2] * 9000.0;
		
		float vecDir[3];
		vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
		vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
		vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
		NormalizeVector(vecDir, vecDir);
		
		int targetHurt = FireBullet(this.index, this.m_iWearable1, vecMe, vecDir, 50.0, 9000.0, DMG_BULLET, "bullet_tracer01_red");
		if (IsValidEnemy(this.index, targetHurt)) {
			ApplyStatusEffect(this.index, targetHurt, "Silenced", 4.0);
		}
		
		this.m_flNextRangedAttack = GetGameTime(this.index) + 0.2;
		this.m_iAttacksTillReload--;
		
		this.AddGesture("ACT_GESTURE_RANGE_ATTACK_AR2");
		
		this.PlayRangedSound();
	}
	
	public void DoReload() {
		this.AddGesture("ACT_GESTURE_RELOAD_AR2");
		
		float gameTime = GetGameTime(this.index);
		this.m_flReloadDelay = gameTime + 1.6;
		this.m_flDoingAnimation = gameTime + 1.6;
		
		this.m_iAttacksTillReload = 15;
		
		this.PlayRangedReloadSound();
	}
	
	property float m_flNextEngageTime {
		public get()				{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float value) 	{ fl_AbilityOrAttack[this.index][0] = value; }
	}
	
	public Combine_Pretorian_Guard(float vecPos[3], float vecAng[3], int team, const char[] data) {
		Combine_Pretorian_Guard npc = view_as<Combine_Pretorian_Guard>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "30000", team));
		
		i_NpcWeight[npc.index] = 3;
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		KillFeed_SetKillIcon(npc.index, "sniperrifle");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		npc.RegisterBody();
		
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCDeath[npc.index] = Combine_Pretorian_Guard_NPCDeath;
		func_NPCThink[npc.index] = Combine_Pretorian_Guard_ClotThink;
		
		int activity = npc.LookupActivity("ACT_RUN_AIM_AR2_STIMULATED");
		if (activity > 0)
			npc.StartActivity(activity);
		
		npc.m_iAttacksTillReload = 15;
		
		// npc.m_flSpeed = 280.0;
		npc.m_flSpeed = 200.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 6.0;
		npc.m_flNextEngageTime = GetGameTime(npc.index) + 8.0;
		npc.m_flDoingAnimation = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_iChanged_WalkCycle = 0;
		
		npc.m_iState = 0;
		
		i_RaidGrantExtra[npc.index] = 0;
		bool elite = StrContains(data, "elite") != -1;
		if (elite) {
			i_RaidGrantExtra[npc.index] = 1;
		}
		
		int skin = (team != TFTeam_Red) ? 1 : 0;
		
		npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_irifle.mdl");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/sniper/sum24_aimframe/sum24_aimframe.mdl");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		
		if (elite) {
			npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/all_class/all_class_oculus_heavy_on.mdl");
			SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		}
		else {
			npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/all_class/all_class_oculus_pyro.mdl");
		}
		
		npc.StartPathing();
		
		return npc;
	}
}

static void Combine_Pretorian_Guard_ClotThink(int iNPC) {
	Combine_Pretorian_Guard npc = view_as<Combine_Pretorian_Guard>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if (npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	npc.HackMaxYawRate(false);
	npc.UpdateBody();
	npc.HackMaxYawRate(true);
	
	if (npc.m_blPlayHurtAnimation) {
		npc.AddGesture("ACT_GESTURE_FLINCH_STOMACH", false);
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
	
	if (IsValidEnemy(npc.index, npc.m_iTarget)) {
		int behavior = Combine_Pretorian_Guard_SelfDefense(npc, gameTime);
		switch (behavior) {
			case 0: {
				if (npc.m_iChanged_WalkCycle != 0) {
					npc.m_iChanged_WalkCycle = 0;
					npc.m_bAllowBackWalking = false;
					npc.m_bisWalking = true;
					// npc.m_flSpeed = 280.0;
					npc.m_flSpeed = 200.0;
					npc.StartPathing();
					
					npc.SetActivity("ACT_RUN_AIM_AR2_STIMULATED");
				}
			}
			case 1: {
				if (npc.m_iChanged_WalkCycle != 1) {
					npc.m_iChanged_WalkCycle = 1;
					npc.m_bAllowBackWalking = true;
					npc.m_bisWalking = true;
					// npc.m_flSpeed = 260.0;
					npc.m_flSpeed = 150.0;
					npc.StartPathing();
					
					npc.SetActivity("ACT_WALK_AIM_AR2");
				}
				
				float vecBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget, _, vecBackoffPos);
				npc.SetGoalVector(vecBackoffPos, true);
			}
			case 2: {
				if (npc.m_iChanged_WalkCycle != 2) {
					npc.m_iChanged_WalkCycle = 2;
					npc.m_bAllowBackWalking = false;
					npc.m_bisWalking = false;
					npc.m_flSpeed = 0.0;
					npc.StopPathing();
					
					npc.SetActivity("ACT_IDLE_ANGRY_AR2");
				}
			}
			case 3: {
				if (npc.m_iChanged_WalkCycle != 3) {
					npc.m_iChanged_WalkCycle = 3;
					npc.m_bAllowBackWalking = false;
					npc.m_bisWalking = true;
					// npc.m_flSpeed = 320.0;
					npc.m_flSpeed = 240.0;
					npc.StartPathing();
					
					npc.SetActivity("ACT_RUN_AIM_AR2_STIMULATED");
				}
			}
		}
	}
	else {
		if (npc.m_iChanged_WalkCycle != 2) {
			npc.m_iChanged_WalkCycle = 2;
			npc.m_bAllowBackWalking = false;
			npc.m_bisWalking = false;
			npc.m_flSpeed = 0.0;
			npc.StopPathing();
			
			npc.SetActivity("ACT_IDLE_ANGRY_AR2");
		}
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
}

static int Combine_Pretorian_Guard_SelfDefense(Combine_Pretorian_Guard npc, float gameTime) {
	if (npc.m_flAttackHappenswillhappen) {
		npc.DoMeleeAttack(npc.m_iTarget, gameTime);
	}
	
	int seenTarget = Can_I_See_Enemy(npc.index, npc.m_iTarget);
	if (!IsValidEnemy(npc.index, seenTarget)) {
		// fuck I can't see our enemy. move it!
		float vecTarget[3], vecMe[3];
		WorldSpaceCenter(npc.m_iTarget, vecTarget);
		WorldSpaceCenter(npc.index, vecMe);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
		
		// Predict their pos.
		if (flDistanceToTarget < npc.GetLeadRadius()) {
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget, _, _, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else {
			npc.SetGoalEntity(npc.m_iTarget);
		}
		
		return 0;
	}
	else {
		npc.m_iTarget = seenTarget;
	}
	
	float vecTarget[3], vecMe[3];
	WorldSpaceCenter(npc.m_iTarget, vecTarget);
	WorldSpaceCenter(npc.index, vecMe);
	
	float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
	
	if (npc.m_flDoingAnimation > gameTime) {
		npc.m_iState = -1;
	}
	else if (flDistanceToTarget > NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED
		&& flDistanceToTarget < 490000.0
		&& npc.m_flNextRangedSpecialAttack < gameTime) {
		npc.m_iState = 3;
	}
	else if (flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED
		&& npc.m_flNextMeleeAttack < gameTime) {
		npc.m_iState = 2;
	}
	else if (flDistanceToTarget < 360000.0
		&& npc.m_flNextRangedAttack < gameTime) {
		npc.m_iState = 1;
	}
	else {
		npc.m_iState = 0;
	}
	
	if (flDistanceToTarget < npc.GetLeadRadius()) {
		float vecPredictedPos[3]; 
		PredictSubjectPosition(npc, npc.m_iTarget, _, _, vecPredictedPos);
		npc.SetGoalVector(vecPredictedPos);
	}
	else {
		npc.SetGoalEntity(npc.m_iTarget);
	}
	
	switch (npc.m_iState) {
		case -1: {
			return 2;
		}
		case 1: {
			if (npc.IsTargetInFiringCone(npc.m_iTarget, 10.0, 10.0)) {
				npc.DoRangeAttack(npc.m_iTarget);
				if (npc.m_iAttacksTillReload <= 0) {
					npc.DoReload();
				}
			}
		}
		case 2: {
			if (!npc.m_flAttackHappenswillhappen) {
				npc.AddGestureViaSequence("MeleeAttack01");
				npc.PlayMeleeSound();
				npc.m_flAttackHappens = gameTime + 0.4;
				npc.m_flAttackHappens_bullshit = gameTime + 0.54;
				npc.m_flNextMeleeAttack = gameTime + 1.1;
				npc.m_flNextRangedAttack = gameTime + 1.1;
				npc.m_flDoingAnimation = gameTime + 1.0;
				npc.m_flAttackHappenswillhappen = true;
				
				if (npc.m_flNextEngageTime < gameTime)
					npc.m_flNextEngageTime = gameTime + 12.0;
			}
		}
		case 3: {
			float origin[3];
			view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, NULL_VECTOR);
			
			float vecPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget, _, _, vecPredictedPos);
			
			if (CanFireProjectileAtTarget(npc.index, npc.m_iTarget, origin, vecPredictedPos)
				&& npc.IsTargetInFiringCone(npc.m_iTarget, 5.0, 5.0)) {
				npc.GetLocomotionInterface().FaceTowards(vecPredictedPos);
				
				// npc.FireParticleRocket(vecPredictedPos, 250.0, 750.0, 150.0, "combineball", true, _, true, origin);
				
				npc.FireRocketCustom(vecPredictedPos, 250.0, 750.0, _, _, _, true, origin);
				
				npc.m_flNextRangedSpecialAttack = gameTime + 12.0;
				npc.m_flNextRangedAttack = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				
				npc.AddGesture("ACT_COMBINE_AR2_ALTFIRE");
				npc.PlayRangedAttackSecondarySound();
			}
		}
	}
	
	if (npc.m_flReloadDelay > gameTime) {
		if (flDistanceToTarget < 90000.0) {
			return 1;
		}
		else {
			return 2;
		}
	}
	else if (npc.m_flDoingAnimation > gameTime) {
		return 2;
	}
	else if (flDistanceToTarget >= 360000.0) {
		return 0;
	}
	else if (flDistanceToTarget < 90000.0) {
		// closer when melee is ready.
		if (npc.m_flNextEngageTime < gameTime && npc.m_flNextMeleeAttack < gameTime) {
			return 3;
		}
		else {
			return 1;
		}
	}
	else {
		return 2;
	}
}

static void Combine_Pretorian_Guard_NPCDeath(int entity) {
	Combine_Pretorian_Guard npc = view_as<Combine_Pretorian_Guard>(entity);
	
	if (!npc.m_bGib)
		npc.PlayDeathSound();
	
	npc.ResetBody();
	
	if (IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if (IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if (IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}