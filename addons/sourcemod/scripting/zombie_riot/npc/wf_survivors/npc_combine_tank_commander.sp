#pragma semicolon 1
#pragma newdecls required

static char g_DeathSounds[][] = {
	"npc/metropolice/die1.wav",
	"npc/metropolice/die2.wav",
	"npc/metropolice/die3.wav",
	"npc/metropolice/die4.wav",
};

static char g_HurtSounds[][] = {
	"npc/metropolice/pain1.wav",
	"npc/metropolice/pain2.wav",
	"npc/metropolice/pain3.wav",
};

static char g_IdleSounds[][] = {
	"npc/metropolice/vo/putitinthetrash1.wav",
	"npc/metropolice/vo/putitinthetrash2.wav",
};

static char g_IdleAlertedSounds[][] = {
	"npc/metropolice/vo/takecover.wav",
	"npc/metropolice/vo/readytojudge.wav",
	"npc/metropolice/vo/subject.wav",
	"npc/metropolice/vo/subjectis505.wav",
};

static char g_MeleeAttackSounds[][] = {
	"weapons/stunstick/stunstick_swing1.wav",
	"weapons/stunstick/stunstick_swing2.wav",
};

static char g_RangedAttackSounds[][] = {
	"weapons/smg1/smg1_fire1.wav",
};

static const char g_RangedAttackSoundsSecondary[][] = {
	"weapons/grenade_launcher1.wav",
};

static char g_RangedReloadSound[][] = {
	"weapons/smg1/smg1_reload.wav",
};

// ACT_COMBINE_THROW_GRENADE
void Combine_Tank_Commander_OnMapStart() {
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "W.F. Tank Commander");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_combine_tank_commander");
	strcopy(data.Icon, sizeof(data.Icon), "combine_smg");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_ALWAYSCRIT;
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
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_RangedAttackSoundsSecondary);
	PrecacheSoundArray(g_RangedReloadSound);
	
	PrecacheModel("models/weapons/w_grenade.mdl");
	PrecacheModel("models/weapons/ar2_grenade.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally) {
	return Combine_Tank_Commander(vecPos, vecAng, ally);
}

methodmap Combine_Tank_Commander < Combine_Base {
	public void PlayIdleSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	
	public void PlayIdleAlertSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	public void PlayHurtSound() {
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayRangedAttackSecondarySound() {
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	property float m_flNextGrenadeThrowTime {
		public get()				{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float value) 	{ fl_AbilityOrAttack[this.index][0] = value; }
	}
	
	public Combine_Tank_Commander(float vecPos[3], float vecAng[3], int team) {
		Combine_Tank_Commander npc = view_as<Combine_Tank_Commander>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "40000", team));
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("run_aiming_smg1_all", true);
		
		npc.m_fbGunout = false;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		npc.RegisterBody();
		
		func_NPCDeath[npc.index] = Combine_Tank_Commander_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = Combine_Tank_Commander_ClotThink;
		
		npc.m_iAttacksTillReload = 30;
		npc.m_bmovedelay = false;
		
		npc.m_iState = 0;
		npc.m_iChanged_WalkCycle = 0;
		
		npc.m_flSpeed = 240.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 4.0;
		npc.m_flNextGrenadeThrowTime = GetGameTime(npc.index) + 8.0;
		npc.m_flAttackHappenswillhappen = false;
		
		npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_smg1.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/soldier/armored_authority.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.StartPathing();
		
		return npc;
	}
}

static void Combine_Tank_Commander_NPCDeath(int entity) {
	Combine_Tank_Commander npc = view_as<Combine_Tank_Commander>(entity);
	if (!npc.m_bGib)
		npc.PlayDeathSound();
	
	npc.ResetBody();
	
	if (IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if (IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}

static void Combine_Tank_Commander_ClotThink(int iNPC) {
	Combine_Tank_Commander npc = view_as<Combine_Tank_Commander>(iNPC);
	
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
	
	int target = npc.m_iTarget;
	if (IsValidEnemy(npc.index, target)) {
		float vecTarget[3], vecMe[3];
		WorldSpaceCenter(target, vecTarget);
		WorldSpaceCenter(npc.index, vecMe);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
		
		int behavior = Combine_Tank_Commander_SelfDefense(npc, gameTime, target, flDistanceToTarget);
		switch (behavior) {
			case 0: {
				if (npc.m_iChanged_WalkCycle != 0) {
					npc.m_iChanged_WalkCycle = 0;
					npc.m_bAllowBackWalking = false;
					npc.m_bisWalking = true;
					npc.m_flSpeed = 240.0;
					npc.StartPathing();
					
					npc.SetActivity("run_aiming_smg1_all", true);
				}
				
				if (flDistanceToTarget < npc.GetLeadRadius()) {
					float vecPredictedPos[3];
					PredictSubjectPosition(npc, npc.m_iTarget, _, _, vecPredictedPos);
					npc.SetGoalVector(vecPredictedPos);
				}
				else {
					npc.SetGoalEntity(target);
				}
			}
			case 1: {
				if (npc.m_iChanged_WalkCycle != 1) {
					npc.m_iChanged_WalkCycle = 1;
					npc.m_bAllowBackWalking = true;
					npc.m_bisWalking = true;
					npc.m_flSpeed = 210.0;
					npc.StartPathing();
					
					npc.SetActivity("run_aiming_smg1_all", true);
				}
				
				float vecBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, target, _, vecBackoffPos);
				npc.SetGoalVector(vecBackoffPos, true);
			}
			case 2: {
				if (npc.m_iChanged_WalkCycle != 2) {
					npc.m_iChanged_WalkCycle = 2;
					npc.m_bAllowBackWalking = false;
					npc.m_bisWalking = false;
					npc.StopPathing();
					
					npc.SetActivity("smg1angryidle1", true);
				}
				
				if (flDistanceToTarget < npc.GetLeadRadius()) {
					float vecPredictedPos[3];
					PredictSubjectPosition(npc, npc.m_iTarget, _, _, vecPredictedPos);
					npc.SetGoalVector(vecPredictedPos);
				}
				else {
					npc.SetGoalEntity(target);
				}
			}
		}
	}
	else {
		if (npc.m_iChanged_WalkCycle != 2) {
			npc.m_iChanged_WalkCycle = 2;
			npc.m_bAllowBackWalking = false;
			npc.m_bisWalking = false;
			npc.StopPathing();
			
			npc.SetActivity("smg1angryidle1", true);
		}
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	npc.PlayIdleAlertSound();
}

static int Combine_Tank_Commander_SelfDefense(Combine_Tank_Commander npc, float gameTime, int target, float flDistanceToTarget) {
	if (npc.m_flDoingAnimation > gameTime) {
		npc.m_iState = -1;
	}
	else if (npc.m_flNextRangedSpecialAttack < gameTime
		&& flDistanceToTarget > 62500.0
		&& flDistanceToTarget < 360000.0) {
		npc.m_iState = 2;
	}
	else if (npc.m_flNextGrenadeThrowTime < gameTime
		&& flDistanceToTarget > 62500.0
		&& flDistanceToTarget < 250000.0) {
		npc.m_iState = 3;
	}
	else if (npc.m_flNextRangedAttack < gameTime
		&& flDistanceToTarget < 250000.0) {
		npc.m_iState = 1;
	}
	else {
		npc.m_iState = 0;
	}
	
	switch (npc.m_iState) {
		case -1: {
			return 2;
		}
		case 3: {
			if (Can_I_See_Enemy_Only(npc.index, target) &&
				npc.IsTargetInFiringCone(target, 5.0, 5.0)) {
				float vecTarget[3];
				WorldSpaceCenter(target, vecTarget);
				npc.FaceTowards(vecTarget, 15000.0);
				
				float origin[3];
				npc.GetAttachment("anim_attachment_LH", origin, NULL_VECTOR);
				
				float vecVelocity[3];
				ArcToLocationViaSpeedSimulation(origin, vecTarget, vecVelocity, 1.75, 1.0);
				
				npc.AddGesture("ACT_COMBINE_THROW_GRENADE");
				npc.m_flDoingAnimation = gameTime + 1.35;
				npc.m_flNextGrenadeThrowTime = gameTime + 10.0;
				
				DataPack pack;
				CreateDataTimer(0.75, Timer_Combine_Tank_Commander_ThrowGrenade, pack, TIMER_FLAG_NO_MAPCHANGE);
				pack.WriteCell(EntIndexToEntRef(npc.index));
				pack.WriteFloatArray(origin, 3, true);
				pack.WriteFloatArray(vecTarget, 3, true);
				pack.WriteFloatArray(vecVelocity, 3, true);
			}
		}
		case 2: {
			float vecTarget[3];
			WorldSpaceCenter(target, vecTarget);
			
			float origin[3];
			view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, NULL_VECTOR);
			
			if (CanFireProjectileAtTarget(npc.index, target, origin, vecTarget)
				&& npc.IsTargetInFiringCone(target, 5.0, 5.0)) {
				npc.FaceTowards(vecTarget, 15000.0);
				
				int projectile = npc.FireRocketCustom(vecTarget, 300.0, 500.0, "models/weapons/ar2_grenade.mdl", 3.0, _, true, origin);
				
				SetEntityGravity(projectile, 1.0);
				
				float vecPredictedPos[3];
				PredictSubjectPosition(npc, target, _, _, vecPredictedPos);
				
				float vecVelocity[3];
				ArcToLocationViaSpeedProjectile(projectile, vecPredictedPos, vecVelocity, 1.75, 1.0);
				SetEntityMoveType(projectile, MOVETYPE_FLYGRAVITY);
				TeleportEntity(projectile, NULL_VECTOR, NULL_VECTOR, vecVelocity);
				
				npc.m_flNextRangedSpecialAttack = gameTime + 12.5;
				npc.m_flDoingAnimation = gameTime + 0.7;
				
				npc.AddGesture("ACT_COMBINE_AR2_ALTFIRE");
				npc.PlayRangedAttackSecondarySound();
			}
		}
		case 1: {
			if (Can_I_See_Enemy_Only(npc.index, target)
				&& npc.IsTargetInFiringCone(target, 10.0, 10.0)) {
				float vecSpread = 0.1;
				
				float x, y;
				x = GetRandomFloat( -0.5, 0.5 ) + GetRandomFloat( -0.5, 0.5 );
				y = GetRandomFloat( -0.5, 0.5 ) + GetRandomFloat( -0.5, 0.5 );
				
				float vecTarget[3], vecMe[3];
				WorldSpaceCenter(target, vecTarget);
				WorldSpaceCenter(npc.index, vecMe);
				
				float vecDirShooting[3], vecRight[3], vecUp[3];
				
				vecTarget[2] += 15.0;
				MakeVectorFromPoints(vecMe, vecTarget, vecDirShooting);
				GetVectorAngles(vecDirShooting, vecDirShooting);
				GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
				
				float vecDir[3];
				vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
				vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
				vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
				NormalizeVector(vecDir, vecDir);
				
				FireBullet(npc.index, npc.m_iWearable1, vecMe, vecDir, 25.0, 9000.0, DMG_BULLET, "bullet_tracer01_red");
				
				npc.m_flNextRangedAttack = gameTime + 0.125;
				npc.m_iAttacksTillReload--;
				
				npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_SMG1");
				npc.PlayRangedSound();
				
				if (npc.m_iAttacksTillReload <= 0) {
					npc.AddGesture("ACT_GESTURE_RELOAD_PISTOL");
					npc.m_flReloadDelay = gameTime + 1.5;
					npc.m_flDoingAnimation = gameTime + 1.5;
					npc.m_iAttacksTillReload = 30;
					npc.PlayRangedReloadSound();
				}
			}
		}
	}
	
	if (npc.m_flDoingAnimation > gameTime) {
		return 2;
	}
	else if (flDistanceToTarget > 160000.0) {
		return 0;
	}
	else if (flDistanceToTarget < 62500.0) {
		if (Can_I_See_Enemy_Only(npc.index, target)) {
			return 1;
		}
		else {
			return 0;
		}
	}
	else {
		if (Can_I_See_Enemy_Only(npc.index, target)) {
			return 2;
		}
		else {
			return 0;
		}
	}
}

static Action Timer_Combine_Tank_Commander_ThrowGrenade(Handle timer, DataPack pack) {
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	
	float origin[3], vecTarget[3], vecVelocity[3];
	pack.ReadFloatArray(origin, 3);
	pack.ReadFloatArray(vecTarget, 3);
	pack.ReadFloatArray(vecVelocity, 3);
	
	if (!IsValidEntity(entity))
		return Plugin_Handled;
	
	Combine_Tank_Commander npc = view_as<Combine_Tank_Commander>(entity);
	
	int projectile = npc.FireRocketCustom(vecTarget, 150.0, 600.0, "models/weapons/w_grenade.mdl", 1.0, _, true, origin);
	if (projectile > MaxClients) {
		SetEntityGravity(projectile, 1.0);
		SetEntityMoveType(projectile, MOVETYPE_FLYGRAVITY);
		TeleportEntity(projectile, NULL_VECTOR, NULL_VECTOR, vecVelocity);
	}
	
	return Plugin_Continue;
}