#pragma semicolon 1
#pragma newdecls required

static const char g_SuperJumpSound[] = "misc/halloween/spell_mirv_explode_primary.wav";

void AltExtra_Mecha_AirStriker_OnMapStart() {
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mecha Airstriker");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mecha_airstriker");
	strcopy(data.Icon, sizeof(data.Icon), "soldine");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Alt;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache() {
	PrecacheSound(g_SuperJumpSound);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data) {
	return AltExtra_Mecha_AirStriker(vecPos, vecAng, team);
}

methodmap AltExtra_Mecha_AirStriker < AltExtra_Base {
	public void PlayIdleAlertSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_RobotSoldier_IdleAlertedSounds[GetRandomInt(0, sizeof(g_RobotSoldier_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	public void PlayHurtSound() {
		if (this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_RobotSoldier_HurtSounds[GetRandomInt(0, sizeof(g_RobotSoldier_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayDeathSound() {
		EmitSoundToAll(g_RobotSoldier_DeathSounds[GetRandomInt(0, sizeof(g_RobotSoldier_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlaySuperJumpSound() {
		EmitSoundToAll(g_SuperJumpSound, this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_SuperJumpSound, this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	property float m_flNextRocketJumpTime {
		public get()			{ return fl_NextRangedBarrage_Singular[this.index]; }
		public set(float value) { fl_NextRangedBarrage_Singular[this.index] = value; }
	}
	
	property float m_flRocketJumpEndTime {
		public get()			{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float value) { fl_AbilityOrAttack[this.index][0] = value; }
	}
	
	property bool m_bIsRocketJumping {
		public get()			{ return b_NextRangedBarrage_OnGoing[this.index]; }
		public set(bool value) 	{ b_NextRangedBarrage_OnGoing[this.index] = value; }
	}
	
	public AltExtra_Mecha_AirStriker(float vecPos[3], float vecAng[3], int ally) {
		AltExtra_Mecha_AirStriker npc = view_as<AltExtra_Mecha_AirStriker>(CClotBody(vecPos, vecAng, ALTBOTSOLDIERMODEL, "1.0", "40000", ally));
		
		i_NpcWeight[npc.index] = 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_MP_RUN_PRIMARY");
		
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRocketJumpTime = GetGameTime(npc.index) + 5.0;
		npc.m_bIsRocketJumping = false;
		npc.m_flRocketJumpEndTime = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		
		func_NPCDeath[npc.index] = AltExtra_Mecha_AirStriker_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = AltExtra_Mecha_AirStriker_ClotThink;
		
		npc.m_flSpeed = 280.0;
		npc.StartPathing();
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.index, 125, 100, 100, 255);
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/w_models/w_rocketlauncher.mdl");
		
		return npc;
	}
}

static void AltExtra_Mecha_AirStriker_NPCDeath(int entity) {
	AltExtra_Mecha_AirStriker npc = view_as<AltExtra_Mecha_AirStriker>(entity);
	if (!npc.m_bGib)
		npc.PlayDeathSound();
	
	if (IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}

static void AltExtra_Mecha_AirStriker_ClotThink(int iNPC) {
	AltExtra_Mecha_AirStriker npc = view_as<AltExtra_Mecha_AirStriker>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if (npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if (npc.IsOnGround() && gameTime > npc.m_flRocketJumpEndTime) {
		npc.m_bIsRocketJumping = false;
	}
	
	if (npc.m_bAllowBackWalking) {
		if (IsValidEnemy(npc.index, npc.m_iTarget)) {
			float vecTarget[3];
			WorldSpaceCenter(npc.m_iTarget, vecTarget);
			npc.FaceTowards(vecTarget, 150.0);
		}
	}
	
	if (npc.m_blPlayHurtAnimation)
	{
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
		
		npc.ModifyBodyPitch(vecMe, vecTarget);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
		
		int goal = AltExtra_Mecha_AirStriker_SelfDefense(npc, gameTime, npc.m_iTarget, flDistanceToTarget);
		switch (goal) {
			case 0:
			{
				npc.m_bAllowBackWalking = false;
				//Get the normal prediction code.
				if (flDistanceToTarget < npc.GetLeadRadius()) {
					float vecPredictedPos[3];
					PredictSubjectPosition(npc, npc.m_iTarget, _, _, vecPredictedPos);
					npc.SetGoalVector(vecPredictedPos);
				}
				else {
					npc.SetGoalEntity(npc.m_iTarget);
				}
			}
			case 1:
			{
				npc.m_bAllowBackWalking = true;
				float vecBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget, _, vecBackoffPos);
				npc.SetGoalVector(vecBackoffPos, true); //update more often, we need it
			}
		}
	}
	else {
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	if (npc.IsOnGround()) {
		if (npc.m_iChanged_WalkCycle != 1) {
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 1;
			npc.SetActivity("ACT_MP_RUN_PRIMARY");
			npc.StartPathing();
		}
	}
	else {
		if (npc.m_iChanged_WalkCycle != 2) {
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 2;
			npc.SetActivity("ACT_MP_JUMP_FLOAT_PRIMARY");
			npc.StartPathing();
		}
	}
	
	npc.PlayIdleAlertSound();
}

static int AltExtra_Mecha_AirStriker_SelfDefense(AltExtra_Mecha_AirStriker npc, float gameTime, int target, float distance) {
	// Follow target until getting closer
	if (distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 20.0) && !npc.m_bIsRocketJumping)
		return 0;
	
	if (gameTime > npc.m_flNextRocketJumpTime && !NpcStats_IsEnemySilenced(npc.index)) {
		if (Can_I_See_Enemy_Only(npc.index, target)) {
			float flMyPos[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flMyPos);
			
			static float vecMaxs[3] = { 35.0, 35.0, 500.0 };
			static float vecMins[3] = { -35.0, -35.0, 17.0 };
			if (!IsSpaceOccupiedWorldOnly(flMyPos, vecMins, vecMaxs, npc.index)) {
				float flPos[3], flAng[3];
				
				npc.GetAttachment("foot_L", flPos, flAng);
				int Particle_1 = ParticleEffectAt_Parent(flPos, "rockettrail", npc.index, "foot_L", {0.0,0.0,0.0});
				if (IsValidEntity(Particle_1))
					CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(Particle_1), TIMER_FLAG_NO_MAPCHANGE);
				
				npc.GetAttachment("foot_R", flPos, flAng);
				int Particle_2 = ParticleEffectAt_Parent(flPos, "rockettrail", npc.index, "foot_R", {0.0,0.0,0.0});
				if (IsValidEntity(Particle_2))
					CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(Particle_2), TIMER_FLAG_NO_MAPCHANGE);
				
				npc.PlaySuperJumpSound();
				
				float vecTarget[3];
				WorldSpaceCenter(target, vecTarget);
				
				flMyPos[0] = vecTarget[0];
				flMyPos[1] = vecTarget[1];
				flMyPos[2] += 800.0;
				
				PluginBot_Jump(npc.index, flMyPos);
				
				npc.m_flRocketJumpEndTime = gameTime + 1.0;
				npc.m_flNextRocketJumpTime = gameTime + 10.0;
				npc.m_bIsRocketJumping = true;
				npc.m_flNextRangedAttack = gameTime + 0.25;
			}
			else {
				// try agian later
				npc.m_flNextRocketJumpTime = gameTime + 1.0;
			}
		}
		else {
			npc.m_flNextRocketJumpTime = gameTime + 1.0;
		}
	}
	
	if((distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0) || npc.m_bIsRocketJumping) && gameTime > npc.m_flNextRangedAttack) {
		if (Can_I_See_Enemy_Only(npc.index, target)) {
			float flSpeed = 900.0;
			float flDamage = 100.0;
			
			if (npc.m_bIsRocketJumping)
				flDamage *= 0.5;
			
			float vecPredictedPos[3];
			PredictSubjectPositionForProjectiles(npc, target, flSpeed, _,vecPredictedPos);
			npc.FaceTowards(vecPredictedPos, 20000.0);
			
			// Play attack anim
			npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
			
			npc.PlayRocketLauncherShootSound();
			npc.FireRocket(vecPredictedPos, flDamage, flSpeed);
			
			npc.m_flDoingAnimation = gameTime + 0.25;
			
			if (npc.m_bIsRocketJumping) {
				npc.m_flNextRangedAttack = gameTime + 0.25;
			}
			else {
				npc.m_flNextRangedAttack = gameTime + 1.0;
			}
		}
	}
	
	if (distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 7.0)) {
		//target is too far, try to close in
		return 0;
	}
	else if (distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 4.0)) {
		if (Can_I_See_Enemy_Only(npc.index, target)) {
			//target is too close, try to keep distance
			return 1;
		}
	}
	
	//Chase target
	return 0;
}