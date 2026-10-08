#pragma semicolon 1
#pragma newdecls required

void AltExtra_Mecha_Immortalizer_OnMapStart() {
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mecha Immortalizer");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mecha_immortalizer");
	strcopy(data.Icon, sizeof(data.Icon), "medic");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Alt;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team) {
	return AltExtra_Mecha_Immortalizer(vecPos, vecAng, team);
}

methodmap AltExtra_Mecha_Immortalizer < AltExtra_Base {
	public void PlayDeathSound() {
		EmitSoundToAll(g_RobotMedic_DeathSounds[GetRandomInt(0, sizeof(g_RobotMedic_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
	}
	
	public void PlayHurtSound() {
		if (this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_RobotMedic_HurtSounds[GetRandomInt(0, sizeof(g_RobotMedic_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
	}
	
	public void PlayIdleSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
		EmitSoundToAll(g_RobotMedic_IdleSounds[GetRandomInt(0, sizeof(g_RobotMedic_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
	}
	
	public void PlayIdleAlertSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		EmitSoundToAll(g_RobotMedic_IdleAlertedSounds[GetRandomInt(0, sizeof(g_RobotMedic_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
	}
	
	public void PlayRageSound() {
		EmitSoundToAll(g_RobotMedic_RageSounds[GetRandomInt(0, sizeof(g_RobotMedic_RageSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
	}
	
	public void UpdateBody() {
		float gameTime = GetGameTime(this.index);
		float flDeltaTime = (this.m_flLastBodyUpdateTime > 0.0) ? (gameTime - this.m_flLastBodyUpdateTime) : 0.05;
		this.m_flLastBodyUpdateTime = gameTime;
		
		if (flDeltaTime <= 0.0 || flDeltaTime > 0.5)
			flDeltaTime = 0.05;
		
		bool bCantSeeTarget;
		if (this.Anger) {
			bCantSeeTarget = !IsValidEnemy(this.index, this.m_iTarget) || !Can_I_See_Enemy_Only(this.index, this.m_iTarget);
		}
		else {
			bCantSeeTarget = !IsValidAlly(this.index, this.m_iTarget) || (Can_I_See_Ally(this.index, this.m_iTarget) != this.m_iTarget);
		}
		
		if (bCantSeeTarget) {
			this.UntwistBody(flDeltaTime);
			return;
		}
		
		if (this.m_iBodyPitchPoseParameter < 0 && this.m_iBodyYawPoseParameter < 0)
			return;
		
		this.UpkeepBody(flDeltaTime);
	}
	
	public AltExtra_Mecha_Immortalizer(float vecPos[3], float vecAng[3], int team) {
		AltExtra_Mecha_Immortalizer npc = view_as<AltExtra_Mecha_Immortalizer>(CClotBody(vecPos, vecAng, "models/bots/medic/bot_medic.mdl", "1.0", "30000", team));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_MP_RUN_SECONDARY");
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NONE;
		
		npc.RegisterBody();
		
		func_NPCDeath[npc.index] = AltExtra_Mecha_Overclocker_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = AltExtra_Mecha_Overclocker_ClotThink;
		
		KillFeed_SetKillIcon(npc.index, "the_maul");
		npc.Anger = false;
		npc.m_flNextRangedAttack = GetGameTime() + 3.0;
		
		Is_a_Medic[npc.index] = true;
		
		npc.m_flSpeed = 300.0;
		
		int skin = (team == TFTeam_Red) ? 0 : 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_proto_medigun/c_proto_medigun.mdl");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/tw_medibot_chariot/tw_medibot_chariot.mdl");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/jul13_se_headset/jul13_se_headset_medic.mdl");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable5 = npc.EquipItem("head", "models/player/items/medic/coh_medichat.mdl");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		
		SetEntityRenderColor(npc.index, 125, 100, 100, 255);
		SetEntityRenderColor(npc.m_iWearable1, 125, 100, 100, 255);
		SetEntityRenderColor(npc.m_iWearable3, 125, 100, 100, 255);
		SetEntityRenderColor(npc.m_iWearable5, 125, 100, 100, 255);
		
		npc.m_iWearable2 = npc.CreateHealingBeam("medicgun_beam_machinery", npc.m_iWearable1);
		
		return npc;
	}
	
	public void AdjustWalkCycle() {
		if (this.Anger) {
			if (this.IsOnGround()) {
				if (this.m_iChanged_WalkCycle != 2) {
					this.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
					this.m_iChanged_WalkCycle = 2;
				}
			}
			else {
				if(this.m_iChanged_WalkCycle != 3)
				{
					this.SetActivity("ACT_MP_JUMP_FLOAT_MELEE_ALLCLASS");
					this.m_iChanged_WalkCycle = 3;
				}
			}
		}
		else {
			if (this.IsOnGround()) {
				if (this.m_iChanged_WalkCycle != 0) {
					this.SetActivity("ACT_MP_RUN_SECONDARY");
					this.m_iChanged_WalkCycle = 0;
				}
			}
			else {
				if (this.m_iChanged_WalkCycle != 1) {
					this.SetActivity("ACT_MP_JUMP_FLOAT_SECONDARY");
					this.m_iChanged_WalkCycle = 1;
				}
			}
		}
	}
	
	public int CreateHealingBeam(const char[] particle, int entity, const char[] attachment = "muzzle") {
		int iParticle = CreateEntityByName("info_particle_system");
		DispatchKeyValue(iParticle, "effect_name", particle);
		DispatchSpawn(iParticle);
		
		if (attachment[0]) {
			float vecPos[3];
			view_as<CClotBody>(entity).GetAttachment(attachment, vecPos, NULL_VECTOR);
			TeleportEntity(iParticle, vecPos, NULL_VECTOR, NULL_VECTOR);
			
			SetVariantString("!activator");
			AcceptEntityInput(iParticle, "SetParent", entity);
			
			SetVariantString(attachment);
			AcceptEntityInput(iParticle, "SetParentAttachment");
		}
		else {
			float vecAbsOrigin[3];
			GetEntPropVector(entity, Prop_Send, "m_vecAbsOrigin", vecAbsOrigin);
			TeleportEntity(iParticle, vecAbsOrigin, NULL_VECTOR, NULL_VECTOR);
			
			SetVariantString("!activator");
			AcceptEntityInput(iParticle, "SetParent", entity);
		}
		
		return iParticle;
	}
	
	public void StartHealing(int patient) {
		this.Healing = true;
		
		CClotBody ally = view_as<CClotBody>(patient);
		this.m_flSpeed = ally.m_flSpeed;
		
		float vecTarget[3];
		WorldSpaceCenter(patient, vecTarget);
		
		this.m_iWearable6 = ParticleEffectAt_Parent(vecTarget, "3rd_trail", patient);
		
		int beam = this.m_iWearable2;
		if (IsValidEntity(beam)) {
			SetEntPropEnt(beam, Prop_Send, "m_hControlPointEnts", this.m_iWearable6, 0);
			SetEntProp(beam, Prop_Send, "m_iControlPointParents", this.m_iWearable6, _, 0);
			
			ActivateEntity(beam);
			AcceptEntityInput(beam, "Start");
		}
	}
	
	public void StopHealing() {
		this.m_flSpeed = 300.0;
		
		int beam = this.m_iWearable2;
		if (IsValidEntity(beam)) {
			// AcceptEntityInput(beam, "ClearParent");
			// RemoveEntity(beam);
			
			SetEntPropEnt(beam, Prop_Send, "m_hControlPointEnts", -1, 0);
			SetEntProp(beam, Prop_Send, "m_iControlPointParents", -1, _, 0);
			
			AcceptEntityInput(beam, "Stop");
		}
		
		int attachment = this.m_iWearable6;
		if (IsValidEntity(attachment)) {
			AcceptEntityInput(attachment, "ClearParent");
			RemoveEntity(attachment);
		}
		
		EmitSoundToAll("weapons/medigun_no_target.wav", this.index, SNDCHAN_WEAPON);
		this.Healing = false;
	}
}

static void AltExtra_Mecha_Overclocker_ClotThink(int iNPC) {
	AltExtra_Mecha_Overclocker npc = view_as<AltExtra_Mecha_Overclocker>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if (npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	npc.UpdateBody();
	
	if (npc.m_blPlayHurtAnimation) {
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	if (npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	if (!npc.Anger) {
		if (npc.m_flGetClosestTargetTime < gameTime) {
			npc.m_iTarget = GetClosestAlly(npc.index);
			npc.m_flGetClosestTargetTime = gameTime + 5000.0;
		}
		
		int target = npc.m_iTarget;
		if (IsValidAlly(npc.index, target)) {
			float vecTarget[3], vecMe[3];
			WorldSpaceCenter(target, vecTarget);
			WorldSpaceCenter(npc.index, vecMe);
			
			float distance = GetVectorDistance(vecTarget, vecMe, true);
			
			AltExtra_Mecha_Overclocker_SupportThink(npc, gameTime, target, distance);
			
			if (distance < 90000.0) {
				npc.StopPathing();
			}
			else {
				npc.StartPathing();
				npc.SetGoalEntity(target);
			}
		}
		else {
			npc.StopHealing();
			npc.m_bnew_target = false;
			
			npc.m_flGetClosestTargetTime = gameTime + 5000.0;
			// There is no valid ally in 800HU, enter rage state.
			npc.m_iTarget = GetClosestAlly(npc.index, 640000.0);
			
			if (!IsValidAlly(npc.index, npc.m_iTarget)) {
				npc.PlayRageSound();
				
				npc.Anger = true;
				
				ApplyStatusEffect(npc.index, npc.index, "Machine Overclock", 99999.0);
				
				npc.m_flSpeed = 400.0;
				npc.m_flGetClosestTargetTime = 0.0;
				
				if (IsValidEntity(npc.m_iWearable1))
					RemoveEntity(npc.m_iWearable1);
				
				npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_rfa_hammer/c_rfa_hammer.mdl");
			}
		}
	}
	else {
		if (npc.m_flGetClosestTargetTime < GetGameTime(npc.index)) {
			npc.m_iTarget = GetClosestTarget(npc.index);
			npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
		}
		
		int target = npc.m_iTarget;
		if (IsValidEnemy(npc.index, target)) {
			float vecTarget[3], vecMe[3];
			WorldSpaceCenter(target, vecTarget);
			WorldSpaceCenter(npc.index, vecMe);
			
			float distance = GetVectorDistance(vecTarget, vecMe, true);
			
			if (distance < npc.GetLeadRadius()) {
				float vecPredictedPos[3];
				PredictSubjectPosition(npc, target, _, _, vecPredictedPos);
				npc.SetGoalVector(vecPredictedPos);
			}
			else {
				npc.SetGoalEntity(target);
			}
			
			npc.StartPathing();
			
			AltExtra_Mecha_Overclocker_AttackThink(npc, gameTime, target, distance);
		}
		else {
			npc.StopPathing();
			
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index);
		}
	}
	
	npc.AdjustWalkCycle();
}

static void AltExtra_Mecha_Overclocker_AttackThink(AltExtra_Mecha_Overclocker npc, float gameTime, int target, float distance) {
	if (npc.m_flAttackHappenswillhappen) {
		if (npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime) {
			float vecTarget[3];
			WorldSpaceCenter(target, vecTarget);
			npc.FaceTowards(vecTarget, 20000.0);
			
			Handle swingTrace;
			if (npc.DoSwingTrace(swingTrace, target)) {
				int targetHit = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if (targetHit > 0)  {
					if (!ShouldNpcDealBonusDamage(targetHit))
						SDKHooks_TakeDamage(targetHit, npc.index, npc.index, 120.0, DMG_CLUB, -1, _, vecHit);
					else
						SDKHooks_TakeDamage(targetHit, npc.index, npc.index, 550.0, DMG_CLUB, -1, _, vecHit);
					
					// Hit sound
					npc.PlayExpidonsanSwordMeleeHitSounds();
					
					ApplyStatusEffect(npc.index, targetHit, "Cellular Breakdown", 6.0);
				}
			}
			delete swingTrace;
			
			npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.6;
			npc.m_flAttackHappenswillhappen = false;
		}
		else if (npc.m_flAttackHappens_bullshit < gameTime) {
			npc.m_flAttackHappenswillhappen = false;
			npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.6;
		}
	}
	else {
		if (distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime) {
			npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
			npc.PlayExpidonsanSwordMeleeAttackSounds();
			npc.m_flAttackHappens = gameTime + 0.4;
			npc.m_flAttackHappens_bullshit = gameTime + 0.54;
			npc.m_flAttackHappenswillhappen = true;
		}
	}
}

static void AltExtra_Mecha_Overclocker_SupportThink(AltExtra_Mecha_Overclocker npc, float gameTime, int target, float distance) {
	// 512.0 * 512.0
	if (distance < 262144.0 && Can_I_See_Ally(npc.index, target)) {
		if (!npc.m_bnew_target) {
			npc.StartHealing(target);
			npc.m_bnew_target = true;
		}
		
		if (npc.m_flNextMeleeAttack < gameTime) {
			int maxhealth = ReturnEntityMaxHealth(target);
			if (b_thisNpcIsABoss[target])
				maxhealth = RoundToCeil(float(maxhealth) * 0.05);
			
			HealEntityGlobal(npc.index, target, float(maxhealth / 80), 1.0);
			
			// Gives machine overclock to specific enemies...
			if (NpcStats_AltExtraMachine(target)) {
				ApplyStatusEffect(npc.index, target, "Machine Overclock", 1.1);
				ApplyStatusEffect(npc.index, npc.index, "Machine Overclock", 1.1);
			}
			
			npc.m_flNextMeleeAttack = gameTime + 1.0;
		}
		
		// float WorldSpaceVec[3];
		// WorldSpaceCenter(target, WorldSpaceVec);
		// npc.FaceTowards(WorldSpaceVec, 2000.0);
	}
	else {
		npc.StopHealing();
		npc.m_bnew_target = false;				
	}
}

static void AltExtra_Mecha_Overclocker_NPCDeath(int iNPC) {
	AltExtra_Mecha_Overclocker npc = view_as<AltExtra_Mecha_Overclocker>(iNPC);
	
	if (!npc.m_bGib)
		npc.PlayDeathSound();
	
	Is_a_Medic[npc.index] = false;
	
	npc.ResetBody();
	
	if (IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if (IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if (IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	
	if (IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	
	if (IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	
	int attachment = npc.m_iWearable6;
	if (IsValidEntity(attachment)) {
		AcceptEntityInput(attachment, "ClearParent");
		RemoveEntity(attachment);
	}
}