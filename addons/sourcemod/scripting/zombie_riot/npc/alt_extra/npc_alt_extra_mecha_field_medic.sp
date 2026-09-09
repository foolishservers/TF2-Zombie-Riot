#pragma semicolon 1
#pragma newdecls required

void AltExtra_Mecha_Field_Medic_OnMapStart() {
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mecha Field Medic");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mecha_field_medic");
	strcopy(data.Icon, sizeof(data.Icon), "monk");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Alt;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team) {
	return AltExtra_Mecha_Field_Medic(vecPos, vecAng, team);
}

methodmap AltExtra_Mecha_Field_Medic < AltExtra_Base {
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
	
	public AltExtra_Mecha_Field_Medic(float vecPos[3], float vecAng[3], int team) {
		AltExtra_Mecha_Field_Medic npc = view_as<AltExtra_Mecha_Field_Medic>(CClotBody(vecPos, vecAng, "models/bots/medic/bot_medic.mdl", "1.0", "30000", team));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NONE;
		
		func_NPCDeath[npc.index] = AltExtra_Mecha_Field_Medic_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = AltExtra_Mecha_Field_Medic_ClotThink;
		
		npc.Anger = false;
		npc.m_flNextRangedAttack = GetGameTime() + 3.0;
		
		Is_a_Medic[npc.index] = true;
		
		npc.m_flSpeed = 300.0;
		
		int skin = (team == TFTeam_Red) ? 0 : 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", RUINA_CUSTOM_MODELS_2);
		SetVariantInt(RUINA_EUR_STAFF_2);
		AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/sf14_medic_herzensbrecher/sf14_medic_herzensbrecher.mdl");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/hwn2025_professor_photon/hwn2025_professor_photon.mdl");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/robo_medic_archimedes/robo_medic_archimedes.mdl");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable5 = npc.EquipItem("head", "models/player/items/medic/hwn_medic_hat.mdl");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

static void AltExtra_Mecha_Field_Medic_ClotThink(int iNPC) {
	AltExtra_Mecha_Field_Medic npc = view_as<AltExtra_Mecha_Field_Medic>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if (npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if (npc.m_blPlayHurtAnimation) {
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	if (npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	if (!npc.Anger) {
		if (npc.m_flNextRangedAttack < gameTime) {
			npc.m_flNextRangedAttack = gameTime + 2.5;
			ExpidonsaGroupHeal(npc.index, 300.0, 99, 1250.0, 1.5, false, Expidonsa_DontHealSameIndex);
			DesertYadeamDoHealEffect(npc.index, 300.0);
		}
		
		if (npc.m_flGetClosestTargetTime < GetGameTime(npc.index)) {
			npc.m_iTarget = GetClosestAlly(npc.index);
			npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 5000.0;
		}
		
		int target = npc.m_iTarget;
		if (IsValidAlly(npc.index, target)) {
			float vecTarget[3], vecMe[3];
			WorldSpaceCenter(target, vecTarget);
			WorldSpaceCenter(npc.index, vecMe);
			
			float distance = GetVectorDistance(vecTarget, vecMe, true);
			
			if (distance < 40000.0) {
				npc.StopPathing();
			}
			else {
				npc.StartPathing();
				npc.SetGoalEntity(target);
			}
		}
		else {
			npc.StopPathing();
			
			npc.PlayRageSound();
			npc.m_flSpeed = 450.0;
			npc.m_flGetClosestTargetTime = 0.0;
			
			if (IsValidEntity(npc.m_iWearable5))
				SetEntityRenderColor(npc.m_iWearable5, 255, 255, 0, 255);
			
			npc.Anger = true;
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
			
			// Target close enough to hit
			if (distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen) {
				//Can we attack right now?
				if (npc.m_flNextMeleeAttack < GetGameTime(npc.index)) {
					//Play attack ani
					if (!npc.m_flAttackHappenswillhappen) {
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
						npc.PlayExpidonsanSwordMeleeAttackSounds();
						npc.m_flAttackHappens = GetGameTime(npc.index)+0.4;
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.54;
						npc.m_flAttackHappenswillhappen = true;
					}
						
					if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen) {
						Handle swingTrace;
						npc.FaceTowards(vecTarget, 20000.0);
						
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
					else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen) {
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.6;
					}
				}
			}
			else {
				npc.StartPathing();
			}
		}
		else {
			npc.StopPathing();
			
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index);
		}
	}
}

static void AltExtra_Mecha_Field_Medic_NPCDeath(int iNPC) {
	AltExtra_Mecha_Field_Medic npc = view_as<AltExtra_Mecha_Field_Medic>(iNPC);
	
	if (!npc.m_bGib)
		npc.PlayDeathSound();
	
	Is_a_Medic[npc.index] = false;
	
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
}