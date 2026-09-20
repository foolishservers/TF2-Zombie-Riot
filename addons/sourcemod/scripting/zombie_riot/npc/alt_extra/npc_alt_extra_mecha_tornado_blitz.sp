#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[] = "mvm/giant_soldier/giant_soldier_explode.wav";
static const char g_RangedAttackSounds[][] = {
	"weapons/airstrike_fire_01.wav",
	"weapons/airstrike_fire_02.wav",
	"weapons/airstrike_fire_03.wav",
};

void AltExtra_Mecha_Tornado_Blitz_MapStart() {
	PrecacheSound(g_DeathSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mecha Tornado Blitz");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mecha_tornado_blitz");
	strcopy(data.Icon, sizeof(data.Icon), "soldier_libertylauncher");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Alt;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team) {
	return AltExtra_Mecha_Tornado_Blitz(vecPos, vecAng, team);
}

methodmap AltExtra_Mecha_Tornado_Blitz < AltExtra_Base {
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds, this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayHurtSound() {
		EmitSoundToAll(g_RobotSoldier_Giant_HurtSounds[GetRandomInt(0, sizeof(g_RobotSoldier_Giant_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	/**
	 * This npc never stop, so we care about only pitch.
	 */
	public void UpdateBody() {
		float gameTime = GetGameTime(this.index);
		float flDeltaTime = (this.m_flLastBodyUpdateTime > 0.0) ? (gameTime - this.m_flLastBodyUpdateTime) : 0.05;
		this.m_flLastBodyUpdateTime = gameTime;
		
		if (flDeltaTime <= 0.0 || flDeltaTime > 0.5)
			flDeltaTime = 0.05;
		
		// if we missed the target.
		if (!IsValidEnemy(this.index, this.m_iTarget)
			|| !Can_I_See_Enemy_Only(this.index, this.m_iTarget)
			|| !this.IsTargetInFiringCone(this.m_iTarget, _, 45.0)) {
			
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
			
			return;
		}
		
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
	}
	
	public AltExtra_Mecha_Tornado_Blitz(float vecPos[3], float vecAng[3], int team) {
		AltExtra_Mecha_Tornado_Blitz npc = view_as<AltExtra_Mecha_Tornado_Blitz>(CClotBody(vecPos, vecAng, "models/bots/soldier_boss/bot_soldier_boss.mdl", "1.35", "70000", team, _, true));
		
		i_NpcWeight[npc.index] = 4;
		npc.SetActivity("ACT_MP_RUN_PRIMARY");
		
		KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		
		npc.RegisterBody();
		
		func_NPCDeath[npc.index] = AltExtra_Mecha_Tornado_Blitz_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = AltExtra_Mecha_Tornado_Blitz_ClotThink;
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		
		npc.m_flSpeed = 200.0;
		npc.StartPathing();
		
		int skin = team == TFTeam_Red ? 0 : 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.index, 125, 100, 100, 255);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_atom_launcher/c_atom_launcher.mdl");
		SetEntityRenderColor(npc.m_iWearable1, 125, 100, 100, 255);
		
		return npc;
	}
}

static void AltExtra_Mecha_Tornado_Blitz_NPCDeath(int iNPC) {
	AltExtra_Mecha_Tornado_Blitz npc = view_as<AltExtra_Mecha_Tornado_Blitz>(iNPC);
	
	npc.PlayDeathSound();
	
	npc.ResetBody();
	
	npc.m_bGib = true;
	
	if (IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}

static void AltExtra_Mecha_Tornado_Blitz_ClotThink(int iNPC) {
	AltExtra_Mecha_Tornado_Blitz npc = view_as<AltExtra_Mecha_Tornado_Blitz>(iNPC);
	
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
	
	if (npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	int target = npc.m_iTarget;
	if (IsValidEnemy(npc.index, target)) {
		float vecTarget[3], vecMe[3];
		WorldSpaceCenter(target, vecTarget);
		WorldSpaceCenter(npc.index, vecMe);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
		
		if (flDistanceToTarget < npc.GetLeadRadius()) {
			float vecPredictedPos[3];
			PredictSubjectPosition(npc, target, _, _, vecPredictedPos);
			npc.SetGoalVector(vecPredictedPos);
		}
		else {
			npc.SetGoalEntity(target);
		}
		
		AltExtra_Mecha_Tornado_Blitz_SelfDefense(npc, gameTime, target);
	}
	else {
		npc.m_flGetClosestTargetTime = 0.0;
	}
	
	if (npc.m_flGetClosestTargetTime < gameTime) {
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
}

static void AltExtra_Mecha_Tornado_Blitz_SelfDefense(AltExtra_Mecha_Tornado_Blitz npc, float gameTime, int target) {
	// I can't see the enemy!
	float origin[3];
	view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, NULL_VECTOR);
	
	float vecTarget[3];
	WorldSpaceCenter(target, vecTarget);
	
	if (!CanFireProjectileAtTarget(npc.index, target, origin, vecTarget)) {
		return;
	}
	
	// If too closed, don't check about target in cone.
	/* distance > NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && */
	
	if (!npc.IsTargetInFiringCone(target, _, 45.0)) {
		return;
	}
	
	if (npc.m_flNextRangedAttack < gameTime) {
		float projectileSpeed = 1100.0;
		// PredictSubjectPositionForProjectiles(npc, target, projectileSpeed, _, vecTarget);
		
		int projectile = npc.FireParticleRocket(vecTarget, 150.0, projectileSpeed, 10.0, "rockettrail_airstrike", false, _, true, origin, .hide_projectile = false);
		if (projectile > MaxClients) {
			int particle = EntRefToEntIndex(i_WandParticle[projectile]);
			
			ApplyCustomModelToWandProjectile(projectile, "models/weapons/w_bullet.mdl", 3.0, "", 0.0, true);
			
			CreateTimer(2.5, Timer_RemoveEntity, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(2.5, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
		}
		
		npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY", .SetGestureSpeed = 1.6);
		npc.PlayRangedSound();
		
		npc.m_flNextRangedAttack = gameTime + 0.5;
	}
}