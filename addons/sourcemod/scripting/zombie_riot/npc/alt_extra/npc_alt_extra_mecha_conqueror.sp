#pragma semicolon 1
#pragma newdecls required

static const char g_MeleeAttackSounds[][] = {
	"weapons/pickaxe_swing1.wav",
	"weapons/pickaxe_swing2.wav",
	"weapons/pickaxe_swing3.wav",
};

static const char g_MeleeHitSounds[][] = {
	"mvm/melee_impacts/bat_baseball_hit_robo01.wav",
};

void AltExtra_Mecha_Conqueror_OnMapStart() {
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mecha Conqueror");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mecha_conqueror");
	strcopy(data.Icon, sizeof(data.Icon), "soldier");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Alt;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache() {
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team) {
	return AltExtra_Mecha_Conqueror(vecPos, vecAng, team);
}

methodmap AltExtra_Mecha_Conqueror < AltExtra_Base {
	public void PlayIdleAlertSound() {
		EmitSoundToAll(g_RobotSoldier_IdleAlertedSounds[GetRandomInt(0, sizeof(g_RobotSoldier_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
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
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public AltExtra_Mecha_Conqueror(float vecPos[3], float vecAng[3], int team) {
		AltExtra_Mecha_Conqueror npc = view_as<AltExtra_Mecha_Conqueror>(CClotBody(vecPos, vecAng, ALTBOTSOLDIERMODEL, "1.0", "30000", team));
		
		i_NpcWeight[npc.index] = 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_MP_RUN_MELEE");
		
		npc.m_flNextRangedAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		
		func_NPCDeath[npc.index] = AltExtra_Mecha_Conqueror_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = AltExtra_Mecha_Conqueror_ClotThink;
		
		npc.m_flSpeed = 320.0;
		npc.StartPathing();
		
		int skin = (team == TFTeam_Red) ? 0 : 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.index, 125, 100, 100, 255);
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_rift_fire_mace/c_rift_fire_mace.mdl");
		SetEntityRenderColor(npc.m_iWearable1, 25, 25, 25, 255);
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/soldier/robo_soldier_shako/robo_soldier_shako.mdl");
		SetVariantString("1.5");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable2, 125, 100, 100, 255);
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/soldier/robo_soldier_sparkplug/robo_soldier_sparkplug.mdl");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

static void AltExtra_Mecha_Conqueror_ClotThink(int iNPC) {
	AltExtra_Mecha_Conqueror npc = view_as<AltExtra_Mecha_Conqueror>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if (npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
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
	
	int target = npc.m_iTarget;
	if (IsValidEnemy(npc.index, target)) {
		float vecTarget[3], vecMe[3];
		WorldSpaceCenter(target, vecTarget);
		WorldSpaceCenter(npc.index, vecMe);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
		if (flDistanceToTarget < npc.GetLeadRadius()) {
			float vecPredictedPos[3];
			PredictSubjectPosition(npc, target,_,_, vecPredictedPos);
			npc.SetGoalVector(vecPredictedPos);
		}
		else {
			npc.SetGoalEntity(target);
		}
		
		AltExtra_Mecha_Conqueror_SelfDefense(npc, gameTime, target, flDistanceToTarget); 
	}
	else {
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
}

void AltExtra_Mecha_Conqueror_SelfDefense(AltExtra_Mecha_Conqueror npc, float gameTime, int target, float distance) {
	if (npc.IsOnGround()) {
		if (npc.m_iChanged_WalkCycle != 3) {
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 3;
			npc.SetActivity("ACT_MP_RUN_MELEE");
			npc.StartPathing();
		}	
	}
	else {
		if (npc.m_iChanged_WalkCycle != 4) {
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 4;
			npc.SetActivity("ACT_MP_JUMP_FLOAT_MELEE");
			npc.StartPathing();
		}	
	}
	
	if (gameTime > npc.m_flNextRangedAttack) {
		if (distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.0) && distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0)) {
			float flMyPos[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flMyPos);
			
			static float hullcheckmaxs[3] = { 35.0, 35.0, 200.0 };
			static float hullcheckmins[3] = { -35.0, -35.0, 17.0 };
			
			if (!IsSpaceOccupiedWorldOnly(flMyPos, hullcheckmins, hullcheckmaxs, npc.index)) {
				int Enemy_I_See = Can_I_See_Enemy(npc.index, target);	
				if (IsValidEnemy(npc.index, Enemy_I_See)) {
					static float flMyPos_2[3];
					flMyPos[2] += 250.0;
					WorldSpaceCenter(Enemy_I_See, flMyPos_2);

					flMyPos[0] = flMyPos_2[0];
					flMyPos[1] = flMyPos_2[1];
					PluginBot_Jump(npc.index, flMyPos);
					npc.PlayIdleAlertSound();
					
					npc.m_flDoingAnimation = gameTime + 0.15;
					npc.m_flNextRangedAttack = gameTime + 5.85;
				}
			}
			else {
				npc.m_flNextRangedAttack = gameTime + 0.5;
			}
		}
	}
	
	if (npc.m_flAttackHappens) {
		if (npc.m_flAttackHappens < gameTime) {
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3];
			WorldSpaceCenter(target, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			
			static float MaxVec[3];
			static float MinVec[3];
			MaxVec = {64.0, 64.0, 64.0};
			MinVec = {-64.0, -64.0, -64.0};
			
			if (!npc.IsOnGround()) {
				MaxVec = {128.0, 128.0, 128.0};
				MinVec = {-128.0, -128.0, -128.0};
			}
			
			if (npc.DoSwingTrace(swingTrace, target, MaxVec, MinVec)) {
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if (IsValidEnemy(npc.index, target)) {
					float damageDealt = 100.0;
					if (ShouldNpcDealBonusDamage(target)) {
						damageDealt *= 10.0;
						
						Explode_Logic_Custom(200.0, npc.index, npc.index, -1, vecHit, 200.0, 0.8, _, true, 20);
						TE_Particle("ExplosionCore_MidAir", vecHit, NULL_VECTOR, {-90.0, 0.0, 0.0}, _, _, _, _, _, _, _, _, _, _, 0.0);
						EmitSoundToAll(SOUND_WAND_LIGHTNING_ABILITY_PAP_SMITE, 0, SNDCHAN_AUTO, 100, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vecHit);
					}
					
					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
					
					// Hit sound
					npc.PlayMeleeHitSound();
				}
			}
			delete swingTrace;
		}
	}
	
	if (gameTime > npc.m_flNextMeleeAttack) {
		float CheckDistance = NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED;
		if (!npc.IsOnGround())
			CheckDistance = GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED;
		
		if (distance < CheckDistance) {
			int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if (IsValidEnemy(npc.index, Enemy_I_See)) {
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
			}
		}
	}
}

static void AltExtra_Mecha_Conqueror_NPCDeath(int entity) {
	AltExtra_Mecha_Conqueror npc = view_as<AltExtra_Mecha_Conqueror>(entity);
	if (!npc.m_bGib)
		npc.PlayDeathSound();
	
	if (IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	
	if (IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if (IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}