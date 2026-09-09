#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/mvm/norm/pyro_mvm_paincrticialdeath01.mp3",
	"vo/mvm/norm/pyro_mvm_paincrticialdeath02.mp3",
	"vo/mvm/norm/pyro_mvm_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/mvm/norm/pyro_mvm_painsharp01.mp3",
	"vo/mvm/norm/pyro_mvm_painsharp02.mp3",
	"vo/mvm/norm/pyro_mvm_painsharp03.mp3",
	"vo/mvm/norm/pyro_mvm_painsharp04.mp3",
	"vo/mvm/norm/pyro_mvm_painsharp05.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/norm/taunts/pyro_mvm_taunts01.mp3",
	"vo/mvm/norm/taunts/pyro_mvm_taunts02.mp3",
	"vo/mvm/norm/taunts/pyro_mvm_taunts03.mp3",
};

static const char g_RangedAttackSounds[] = "weapons/flaregun_shoot.wav";

void AltExtra_Mecha_Flaregun_Main_OnMapStart() {
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mecha Flaregun Main");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mecha_flaregun_main");
	strcopy(data.Icon, sizeof(data.Icon), "pyro_flare");
	data.IconCustom = false;
	data.Flags = 0;			
	data.Category = Type_Alt;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache() {
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSound(g_RangedAttackSounds);
	PrecacheScriptSound("TFPlayer.FlareImpact");
	PrecacheScriptSound("TFPlayer.CritPain");
	
	PrecacheModel("models/bots/pyro/bot_pyro.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally) {
	return AltExtra_Mecha_Flaregun_Main(vecPos, vecAng, ally);
}

methodmap AltExtra_Mecha_Flaregun_Main < AltExtra_Base {
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayHurtSound() {
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds, this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void ModifyBodyPitch(float vecMe[3], float vecTarget[3]) {
		if (this.m_iPoseBodyPitch == 0) {
			this.m_iPoseBodyPitch = this.LookupPoseParameter("body_pitch");
		}
		
		if (this.m_iPoseBodyPitch < 0)
			return;
		
		//Body pitch
		float v[3], ang[3];
		SubtractVectors(vecMe, vecTarget, v); 
		NormalizeVector(v, v);
		GetVectorAngles(v, ang);
		
		float flPitch = this.GetPoseParameter(this.m_iPoseBodyPitch);						
		this.SetPoseParameter(this.m_iPoseBodyPitch, ApproachAngle(ang[0], flPitch, 10.0));
	}
	
	public bool IsTargetInFiringCone(int target, float maxYawAngle = 20.0, float maxPitchAngle = 20.0) {
		float vecMe[3], vecTarget[3], vecToTarget[3];
		WorldSpaceCenter(this.index, vecMe);
		WorldSpaceCenter(target, vecTarget);
		
		SubtractVectors(vecTarget, vecMe, vecToTarget);
		NormalizeVector(vecToTarget, vecToTarget);
		
		float angRotation[3];
		GetEntPropVector(this.index, Prop_Data, "m_angRotation", angRotation);
		
		// --- Yaw ---
		float flViewYaw = angRotation[1];
		
		if (this.m_iPoseBodyYaw > -1) {
			flViewYaw -= this.GetPoseParameter(this.m_iPoseBodyYaw);
		}
		
		flViewYaw = UTIL_AngleNormalize(flViewYaw);
		
		float flTargetYaw = this.UTIL_VecToYaw(vecToTarget);
		
		float flYawDiff = this.UTIL_AngleDiff(flTargetYaw, flViewYaw);
		
		if (FloatAbs(flYawDiff) > maxYawAngle)
			return false;
		
		// --- Pitch ---
		if (this.m_iPoseBodyPitch > -1) {
			float vecDir[3], vecAng[3];
			SubtractVectors(vecMe, vecTarget, vecDir);
			NormalizeVector(vecDir, vecDir);
			GetVectorAngles(vecDir, vecAng);
			
			float flCurrentPitch = this.GetPoseParameter(this.m_iPoseBodyPitch);
			float flPitchDiff = this.UTIL_AngleDiff(vecAng[0], flCurrentPitch);
			
			if (FloatAbs(flPitchDiff) > maxPitchAngle)
				return false;
		}
		
		return true;
	}
	
	public void RegisterBody() {
		if (this.m_iPoseBodyYaw == -1) {
			this.m_iPoseBodyYaw = this.LookupPoseParameter("body_yaw");
		}
		
		if (this.m_iPoseBodyPitch == -1) {
			this.m_iPoseBodyPitch = this.LookupPoseParameter("body_pitch");
		}
	}
	
	public void ResetBody() {
		this.m_iPoseBodyYaw = -1;
		this.m_iPoseBodyPitch = -1;
	}
	
	public void ModifyBody(int target) {
		// I can't see target. so reset poseparameter to 0.
		bool bCanISee = Can_I_See_Enemy_Only(this.index, target);
		if (this.m_bPathing || !bCanISee) {
			if (this.m_iPoseBodyYaw > -1) {
				float flYaw = this.GetPoseParameter(this.m_iPoseBodyYaw);
				
				this.SetPoseParameter(
					this.m_iPoseBodyYaw,
					ApproachAngle(0.0, flYaw, 1.0)
				);
			}
			
			if (this.m_iPoseBodyPitch > -1) {
				float flPitch = this.GetPoseParameter(this.m_iPoseBodyPitch);
				
				this.SetPoseParameter(
					this.m_iPoseBodyPitch,
					ApproachAngle(0.0, flPitch, 1.0)
				);
			}
			
			return;
		}
		
		if (this.m_iPoseBodyPitch < 0 && this.m_iPoseBodyYaw < 0)
			return;
		// if (this.m_iPoseBodyYaw <= 0)
		//	return;
		
		float vecMe[3], vecTarget[3];
		WorldSpaceCenter(this.index, vecMe);
		WorldSpaceCenter(target, vecTarget);
		
		float vecDir[3], vecAng[3];
		if (this.m_iPoseBodyPitch > -1) {
			SubtractVectors(vecMe, vecTarget, vecDir);
			NormalizeVector(vecDir, vecDir);
			GetVectorAngles(vecDir, vecAng);
			
			float flPitch = this.GetPoseParameter(this.m_iPoseBodyPitch);
			
			this.SetPoseParameter(
				this.m_iPoseBodyPitch,
				ApproachAngle(vecAng[0], flPitch, 1.0)
			);
		}
		
		if (this.m_iPoseBodyYaw > -1) {
			SubtractVectors(vecTarget, vecMe, vecDir);
			NormalizeVector(vecDir, vecDir);
			GetVectorAngles(vecDir, vecAng);
			
			float angRotation[3];
			GetEntPropVector(this.index, Prop_Data, "m_angRotation", angRotation);
			
			float relativeYaw = -UTIL_AngleDiff(vecAng[1], angRotation[1]);
			
			// relativeYaw = -relativeYaw;
			
			float flYaw = this.GetPoseParameter(this.m_iPoseBodyYaw);
			
			float bodyYaw = clamp(relativeYaw, -44.0, 44.0);
			
			this.SetPoseParameter(
				this.m_iPoseBodyYaw,
				ApproachAngle(bodyYaw, flYaw, 1.0)
			);
			
			//PrintToServer("[DEBUG] angRotation.yaw=%.1f targetAngle=%.1f relativeYaw=%.1f poseYaw(before)=%.1f",
			//	angRotation[1], vecAng[1], relativeYaw, flYaw);
			
			if (relativeYaw > 15.0 || relativeYaw < -15.0) {
				//this.FaceTowards(vecTarget);
				this.GetLocomotionInterface().FaceTowards(vecTarget);
			}
			
			// If we are pathing, facetowards are worse to look.
			// So disable it while pathing.
			/*
			if ((relativeYaw > 44.0 || relativeYaw < -44.0)) {
				this.GetLocomotionInterface().FaceTowards(vecTarget);
			}
			*/
		}
		else {
			this.GetLocomotionInterface().FaceTowards(vecTarget);
		}
	}
	
	public AltExtra_Mecha_Flaregun_Main(float vecPos[3], float vecAng[3], int team) {
		AltExtra_Mecha_Flaregun_Main npc = view_as<AltExtra_Mecha_Flaregun_Main>(CClotBody(vecPos, vecAng, "models/bots/pyro/bot_pyro.mdl", "1.0", "2000", team, false, true));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_ITEM1");
		if (iActivity > 0)
			npc.StartActivity(iActivity);
		
		npc.m_flNextRangedAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		
		npc.RegisterBody();
		
		func_NPCDeath[npc.index] = AltExtra_Mecha_Flaregun_Main_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = AltExtra_Mecha_Flaregun_Main_ClotThink;
		
		KillFeed_SetKillIcon(npc.index, "flaregun");
		
		npc.m_iState = 0;
		npc.m_flSpeed = 240.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		int skin = (team == TFTeam_Red) ? 0 : 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_flaregun_pyro/c_flaregun_pyro.mdl");
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

static void AltExtra_Mecha_Flaregun_Main_NPCDeath(int entity) {
	AltExtra_Mecha_Flaregun_Main npc = view_as<AltExtra_Mecha_Flaregun_Main>(entity);
	if (!npc.m_bGib)
		npc.PlayDeathSound();
	
	npc.ResetBody();
	
	if (IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}

static void AltExtra_Mecha_Flaregun_Main_ClotThink(int iNPC) {
	AltExtra_Mecha_Flaregun_Main npc = view_as<AltExtra_Mecha_Flaregun_Main>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if (npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if (IsValidEnemy(npc.index, npc.m_iTarget))
		npc.ModifyBody(npc.m_iTarget);
	
	if (npc.m_blPlayHurtAnimation) {
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
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
		float vecTarget[3], vecMe[3];
		WorldSpaceCenter(npc.m_iTarget, vecTarget);
		WorldSpaceCenter(npc.index, vecMe);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
		
		switch (AltExtra_Mecha_Flaregun_Main_SelfDefense(npc, gameTime, flDistanceToTarget)) {
			case 0: {
				if (npc.m_iChanged_WalkCycle != 1) {
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_RUN_ITEM1");
					npc.m_flSpeed = 240.0;
					npc.StartPathing();
				}
				
				// Recalculate it because self defense can change target.
				WorldSpaceCenter(npc.m_iTarget, vecTarget);
				flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
				
				if (flDistanceToTarget < npc.GetLeadRadius()) {
					float vecPredictedPos[3];
					PredictSubjectPosition(npc, npc.m_iTarget, _, _, vecPredictedPos);
					npc.SetGoalVector(vecPredictedPos);
				}
				else {
					npc.SetGoalEntity(npc.m_iTarget);
				}
			}
			case 1: {
				npc.ModifyBody(npc.m_iTarget);
				
				if (npc.m_iChanged_WalkCycle != 0) {
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 0;
					npc.SetActivity("ACT_MP_STAND_ITEM1");
					npc.m_flSpeed = 0.0;
					npc.StopPathing();
				}
			}
		}
	}
	else {
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	npc.PlayIdleAlertSound();
}

static int AltExtra_Mecha_Flaregun_Main_SelfDefense(AltExtra_Mecha_Flaregun_Main npc, float gameTime, float distance) {
	if (distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0)) {
		if (Can_I_See_Enemy_Only(npc.index, npc.m_iTarget)) {
			//if (!npc.IsTargetInFiringCone(npc.m_iTarget))
			//	return 1;
			
			if (!npc.IsTargetInFiringCone(npc.m_iTarget)) {
				return 1;
			}
						
			if (gameTime > npc.m_flNextRangedAttack) {
				npc.m_flNextRangedAttack = gameTime + 1.25;
				
				npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM1");
				npc.PlayRangedSound();
				
				float vecTarget[3];
				WorldSpaceCenter(npc.m_iTarget, vecTarget);
				//npc.GetLocomotionInterface().FaceTowards(vecTarget);
				// npc.FaceTowards(vecTarget, 20000.0);
				
				int team = GetTeam(npc.index);
				
				int projectile = npc.FireParticleRocket(vecTarget, 20.0, 1100.0, 10.0, team == TFTeam_Red ? "flaregun_trail_red" : "flaregun_trail_blue", .hide_projectile = false);
				if (projectile > -1) {
					int particle = EntRefToEntIndex(i_WandParticle[projectile]);
					
					ApplyCustomModelToWandProjectile(projectile, "models/weapons/w_models/w_flaregun_shell.mdl", 1.0, "idle", 0.0, true);
					
					SetEntProp(projectile, Prop_Send, "m_nSkin", team == TFTeam_Red ? 0 : 1);
					
					CreateTimer(10.0, Timer_RemoveEntity, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(10.0, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
					
					WandProjectile_ApplyFunctionToEntity(projectile, AltExtra_Mecha_Flaregun_Main_Projectile_StartTouch);
				}
			}
			
			return 1;
		}
		/*
		else {
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index);
		}
		*/
	}
	
	return 0;
	// return (distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0 && Can_I_See_Enemy_Only(npc.index, npc.m_iTarget)) ? 1 : 0;
}

static void AltExtra_Mecha_Flaregun_Main_Projectile_StartTouch(int entity, int target) {
	if (target > 0 && target < MAXENTITIES) {
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if (!IsValidEntity(owner))
			owner = 0;
		
		int inflictor = h_ArrowInflictorRef[entity];
		if (inflictor != -1)
			inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);

		if (inflictor == -1)
			inflictor = owner;
			
		float projectileLoc[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", projectileLoc);
		
		float DamageDeal = fl_rocket_particle_dmg[entity];
		if (ShouldNpcDealBonusDamage(target))
			DamageDeal *= h_BonusDmgToSpecialArrow[entity];
		
		if (IgniteFor[target] > 0) {
			DamageDeal *= 3.0;
			EmitGameSoundToAll("TFPlayer.CritPain", target, .origin = projectileLoc);
		}
		
		SDKHooks_TakeDamage(target, owner, inflictor, DamageDeal, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, -1);
		
		// We don't wanna ignite on invuln target.
		if (!IsInvuln(target))
			NPC_Ignite(target, owner, 3.0, -1, 4.0);
		
		EmitGameSoundToAll("TFPlayer.FlareImpact", target, .origin = projectileLoc);
		
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if (IsValidEntity(particle))
			RemoveEntity(particle);
	}
	else {
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if (IsValidEntity(particle))
			RemoveEntity(particle);
	}
	
	RemoveEntity(entity);
}