#pragma semicolon 1
#pragma newdecls required

void AltExtra_Mecha_Wizard_Heavy_MapStart() {
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mecha Wizard Heavy");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mecha_wizard_heavy");
	strcopy(data.Icon, sizeof(data.Icon), "heavy");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Alt;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache() {
	PrecacheSound("misc/halloween/spell_fireball_cast.wav");
	PrecacheScriptSound("Halloween.spell_fireball_impact");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team) {
	return AltExtra_Mecha_Wizard_Heavy(vecPos, vecAng, team);
}

methodmap AltExtra_Mecha_Wizard_Heavy < AltExtra_Base {
	public void PlayHurtSound() {
		EmitSoundToAll(g_RobotHeavy_HurtSounds[GetRandomInt(0, sizeof(g_RobotHeavy_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
	}
	
	public void PlayIdleAlertSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		EmitSoundToAll(g_RobotHeavy_IdleAlertedSounds[GetRandomInt(0, sizeof(g_RobotHeavy_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll("misc/halloween/spell_fireball_cast.wav", this.index);
	}
	
	public void UpdateBody() {
		float gameTime = GetGameTime(this.index);
		if (this.m_flIdleTime > gameTime) {
			return;
		}
		
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
	
	property float m_flDelayRapidAttack {
		public get()			{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float value) { fl_AbilityOrAttack[this.index][0] = value; }
	}
	
	property float m_flRunAwayTime {
		public get()			{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float value) { fl_AbilityOrAttack[this.index][1] = value; }
	}
	
	property float m_flIdleTime {
		public get()			{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float value) { fl_AbilityOrAttack[this.index][2] = value; }
	}
	
	public AltExtra_Mecha_Wizard_Heavy(float vecPos[3], float vecAng[3], int team) {
		AltExtra_Mecha_Wizard_Heavy npc = view_as<AltExtra_Mecha_Wizard_Heavy>(CClotBody(vecPos, vecAng, "models/bots/heavy/bot_heavy.mdl", "1.0", "30000", team));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_flAttackHappens_bullshit = 0.0;
		
		npc.RegisterBody();
		
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCDeath[npc.index] = AltExtra_Mecha_Wizard_Heavy_NPCDeath;
		func_NPCThink[npc.index] = AltExtra_Mecha_Wizard_Heavy_ClotThink;
		
		npc.m_flSpeed = 200.0;
		npc.m_iChanged_WalkCycle = 0;
		npc.m_bisWalking = true;
		
		npc.m_iAmmo = 0;
		
		npc.m_bDissapearOnDeath = true;
		npc.m_bNoKillFeed = true;
		
		npc.m_flIdleTime = 0.0;
		npc.m_flRunAwayTime = 0.0;
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		
		int skin = (team == TFTeam_Red) ? 0 : 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_skullbat/c_skullbat.mdl", _, skin);
		
		return npc;
	}
}

static void AltExtra_Mecha_Wizard_Heavy_ClotThink(int iNPC) {
	AltExtra_Mecha_Wizard_Heavy npc = view_as<AltExtra_Mecha_Wizard_Heavy>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if (npc.m_flNextDelayTime > gameTime) {
		return;
	}
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	npc.UpdateBody();
	
	if (npc.m_blPlayHurtAnimation) {
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if (npc.m_flNextThinkTime > gameTime) {
		return;
	}
	
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
		
		int behavior = AltExtra_Mecha_Wizard_Heavy_SelfDefense(npc, gameTime, flDistanceToTarget);
		
		switch (behavior) {
			case 0: {
				if (npc.m_iChanged_WalkCycle != 0) {
					npc.m_iChanged_WalkCycle = 0;
					npc.m_bisWalking = true;
					npc.m_flSpeed = 200.0;
					npc.StartPathing();
					
					npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
				}
				
				if (flDistanceToTarget < npc.GetLeadRadius()) {
					float vecPredictedPos[3];
					PredictSubjectPosition(npc, target, _, _, vecPredictedPos);
					npc.SetGoalVector(vecPredictedPos);
				}
				else {
					npc.SetGoalEntity(target);
				}
			}
			case 1: {
				if (npc.m_iChanged_WalkCycle != 1) {
					npc.m_iChanged_WalkCycle = 1;
					npc.m_bisWalking = true;
					npc.m_flSpeed = 300.0;
					npc.StartPathing();
					
					npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
				}
				
				float vecBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget, _, vecBackoffPos);
				npc.SetGoalVector(vecBackoffPos, true);
			}
			case 2: {
				if (npc.m_iChanged_WalkCycle != 2) {
					npc.m_iChanged_WalkCycle = 2;
					npc.m_bisWalking = false;
					npc.StopPathing();
					
					npc.SetActivity("ACT_MP_STAND_MELEE_ALLCLASS");
				}
			}
		}
	}
	else {
		if (npc.m_iChanged_WalkCycle != 2) {
			npc.m_iChanged_WalkCycle = 2;
			npc.m_bisWalking = false;
			npc.StopPathing();
			
			npc.SetActivity("ACT_MP_STAND_MELEE_ALLCLASS");
		}
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	npc.PlayIdleAlertSound();
}

/**
 * returns target engage behavior
 * 0: get closer
 * 1: run away from enemy
 * 2: stop moving
 */
static int AltExtra_Mecha_Wizard_Heavy_SelfDefense(AltExtra_Mecha_Wizard_Heavy npc, float gameTime, float distance) {
	if (npc.m_flIdleTime > gameTime) {
		return 2;
	}
	else if (npc.m_flRunAwayTime > gameTime) {
		return 1;
	}
	
	if (npc.m_iAmmo > 0 && npc.m_flDelayRapidAttack < gameTime) {
		npc.m_flDelayRapidAttack = gameTime + 0.1;
		
		float projectile_speed = 1000.0;
		
		float vecTarget[3];
		PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, projectile_speed, _,vecTarget);
		
		int projectile = npc.FireParticleRocket(vecTarget, 75.0, projectile_speed, 150.0, "spell_fireball_small_red", false, true, false, _, _, _, 4.0);
		if (projectile > MaxClients) {
			int particle = EntRefToEntIndex(i_WandParticle[projectile]);
			
			CreateTimer(5.0, Timer_RemoveEntity, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(5.0, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
			
			WandProjectile_ApplyFunctionToEntity(projectile, AltExtra_Mecha_Wizard_Heavy_Projectile_StartTouch);
		}
		
		npc.PlayRangedSound();
		
		npc.m_iAmmo--;
		
		if (npc.m_iAmmo <= 0) {
			npc.m_iAmmo = 0;
			
			int behavior = GetRandomInt(0, 4);
			if (behavior < 3) {
				npc.m_flIdleTime = gameTime + GetRandomFloat(3.0, 5.0);
			}
			else {
				npc.m_flRunAwayTime = gameTime + GetRandomFloat(6.0, 8.0);
			}
		}
	}
	
	if (npc.m_flNextRangedAttack < gameTime
		&& distance < 640000.0
		&& Can_I_See_Enemy_Only(npc.index, npc.m_iTarget)
		&& npc.IsTargetInFiringCone(npc.m_iTarget, 7.5, 7.5)) {
		npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS", _, _, _, 0.85);
		
		float vecOrigin[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", vecOrigin);
		
		npc.DispatchParticleEffect(npc.index, GetTeam(npc.index) == TFTeam_Red ? "spell_cast_wheel_red" : "spell_cast_wheel_blue", vecOrigin, NULL_VECTOR, NULL_VECTOR, _, PATTACH_ABSORIGIN_FOLLOW, true);
				
		npc.m_iAmmo = 4;
		npc.m_flDelayRapidAttack = gameTime + 0.1;
		npc.m_flNextRangedAttack = gameTime + 8.0;
	}
	
	if (npc.m_flIdleTime > gameTime) {
		return 2;
	}
	else if (npc.m_flRunAwayTime > gameTime) {
		return 1;
	}
	else if (distance < 250000.0) {
		return 1;
	}
	else if (distance < 640000.0) {
		return 2;
	}
	else {
		return 0;
	}
}

static void AltExtra_Mecha_Wizard_Heavy_NPCDeath(int iNPC) {
	AltExtra_Mecha_Wizard_Heavy npc = view_as<AltExtra_Mecha_Wizard_Heavy>(iNPC);
	
	PrintToChatAll("Player Mecha Wizard Heavy left the game (Disconnected by user.)");
	
	npc.ResetBody();
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}

static void AltExtra_Mecha_Wizard_Heavy_Projectile_StartTouch(int entity, int target) {
	float projectileLoc[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", projectileLoc);
	
	if (target > 0 && target < MAXENTITIES) {
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if (!IsValidEntity(owner))
			owner = 0;
		
		int inflictor = h_ArrowInflictorRef[entity];
		if (inflictor != -1)
			inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);

		if (inflictor == -1)
			inflictor = owner;
		
		i_ExplosiveProjectileHexArray[owner] = i_ExplosiveProjectileHexArray[entity];
		Explode_Logic_Custom(fl_rocket_particle_dmg[entity], inflictor, owner, -1, projectileLoc, 
			.explosionRadius = fl_rocket_particle_radius[entity],
			.FromBlueNpc = b_rocket_particle_from_blue_npc[entity],
			.FunctionToCallOnHit = AltExtra_Mecha_Wizard_Heavy_Projectile_Explode);
		
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if (IsValidEntity(particle))
			RemoveEntity(particle);
	}
	else {
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if (IsValidEntity(particle))
			RemoveEntity(particle);
	}
	
	TE_Particle("bombinomicon_burningdebris", projectileLoc, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
	EmitGameSoundToAll("Halloween.spell_fireball_impact", 0, _, _, projectileLoc);
	
	RemoveEntity(entity);
}

static void AltExtra_Mecha_Wizard_Heavy_Projectile_Explode(int entity, int target, float damage, int weapon) {
	// We don't wanna ignite on invuln target.
	if (!IsInvuln(target))
		NPC_Ignite(target, entity, 10.0, -1, 10.0);
}