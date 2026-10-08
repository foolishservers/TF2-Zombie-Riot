#pragma semicolon 1
#pragma newdecls required

void AltExtra_Mecha_Berserker_Demo_OnMapStart() {
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mecha Berserker Demo");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mecha_berserker_demo");
	strcopy(data.Icon, sizeof(data.Icon), "demoknight");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Alt;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team) {
	return AltExtra_Mecha_Berserker_Demo(vecPos, vecAng, team);
}

methodmap AltExtra_Mecha_Berserker_Demo < AltExtra_Base {
	public void PlayIdleAlertSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		if (this.Anger) {
			EmitSoundToAll(g_RobotDemo_LaughSounds[GetRandomInt(0, sizeof(g_RobotDemo_LaughSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		}
		else {
			EmitSoundToAll(g_RobotDemo_IdleAlertedSounds[GetRandomInt(0, sizeof(g_RobotDemo_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		}
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	public void PlayHurtSound() {
		EmitSoundToAll(g_RobotDemo_HurtSounds[GetRandomInt(0, sizeof(g_RobotDemo_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayLaughSound() {
		EmitSoundToAll(g_RobotDemo_LaughSounds[GetRandomInt(0, sizeof(g_RobotDemo_LaughSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public AltExtra_Mecha_Berserker_Demo(float vecPos[3], float vecAng[3], int team) {
		AltExtra_Mecha_Berserker_Demo npc = view_as<AltExtra_Mecha_Berserker_Demo>(CClotBody(vecPos, vecAng, "models/bots/demo/bot_demo.mdl", "1.0", "12500", team));
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		i_NpcWeight[npc.index] = 2;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_MP_RUN_ITEM1");
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		
		func_NPCDeath[npc.index] = AltExtra_Mecha_Berserker_Demo_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = AltExtra_Mecha_Berserker_Demo_ClotThink;
		func_NPCLostHealthBar[npc.index] = AltExtra_Mecha_Berserker_Demo_LifeLost;
		
		npc.m_flSpeed = 300.0;
		npc.m_iHealthBar = 1;
		
		npc.Anger = false;
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.StartPathing();
		
		ApplyStatusEffect(npc.index, npc.index, "Alt Extra Machine", 999999.0);
		
		int skin = (team == TFTeam_Red) ? 0 : 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/demo/hwn2022_alcoholic_automaton/hwn2022_alcoholic_automaton.mdl");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/heavy/jul13_katyusha/jul13_katyusha.mdl");
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		
		SetEntityRenderColor(npc.index, 125, 100, 100, 255);
		SetEntityRenderColor(npc.m_iWearable2, 125, 100, 100, 255);
		SetEntityRenderColor(npc.m_iWearable3, 125, 100, 100, 255);
		
		return npc;
	}
}

static void AltExtra_Mecha_Berserker_Demo_NPCDeath(int entity) {
	AltExtra_Mecha_Berserker_Demo npc = view_as<AltExtra_Mecha_Berserker_Demo>(entity);
	
	if (!npc.m_bGib)
		npc.PlayLaughSound();
	
	if (IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	
	if (IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if (IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}

static void AltExtra_Mecha_Berserker_Demo_ClotThink(int iNPC) {
	AltExtra_Mecha_Berserker_Demo npc = view_as<AltExtra_Mecha_Berserker_Demo>(iNPC);
	if (npc.m_flNextDelayTime > GetGameTime(npc.index))
		return;
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if (npc.m_blPlayHurtAnimation) {
		npc.m_blPlayHurtAnimation = false;
		
		if (!npc.Anger) {
			npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
			npc.PlayHurtSound();
		}
	}
	
	if (npc.m_flNextThinkTime > GetGameTime(npc.index)) {
		return;
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if (npc.m_flGetClosestTargetTime < GetGameTime(npc.index)) {
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if (IsValidEnemy(npc.index, npc.m_iTarget)) {
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if (flDistanceToTarget < npc.GetLeadRadius()) {
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget, _, _, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else {
			npc.SetGoalEntity(npc.m_iTarget);
		}
		
		AltExtra_Mecha_Berserker_Demo_SelfDefense(npc, GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else {
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	npc.PlayIdleAlertSound();
}

static void AltExtra_Mecha_Berserker_Demo_SelfDefense(AltExtra_Mecha_Berserker_Demo npc, float gameTime, int target, float distance) {
	if (npc.m_flAttackHappens) {
		if (npc.m_flAttackHappens < gameTime) {
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float vecTarget[3];
			WorldSpaceCenter(target, vecTarget);
			npc.FaceTowards(vecTarget, 15000.0);
			
			if (npc.DoSwingTrace(swingTrace, target)) {		
				int targetHit = TR_GetEntityIndex(swingTrace);
				
				TR_GetEndPosition(vecTarget, swingTrace);
				
				if (IsValidEnemy(npc.index, targetHit)) {
					float damageDealt = npc.Anger ? 150.0 : 100.0;
					
					if (ShouldNpcDealBonusDamage(targetHit))
						damageDealt *= 2.0;
					
					SDKHooks_TakeDamage(targetHit, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecTarget);
					
					// Hit sound
					npc.PlayDemoSwordMeleeHitSounds();
				}
			}
			delete swingTrace;
		}
	}
	
	if (gameTime > npc.m_flNextMeleeAttack) {
		if (distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED)) {
			int seenTarget = Can_I_See_Enemy(npc.index, target);
			if (IsValidEnemy(npc.index, seenTarget)) {
				npc.m_iTarget = seenTarget;
				npc.PlayDemoSwordMeleeAttackSounds();
				
				if (npc.Anger) {
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS", .SetGestureSpeed = 2.0);
					
					npc.m_flAttackHappens = gameTime + 0.125;
					npc.m_flDoingAnimation = gameTime + 0.125;
					npc.m_flNextMeleeAttack = gameTime + 0.4;
				}
				else {
					npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM1");
					
					npc.m_flAttackHappens = gameTime + 0.25;
					npc.m_flDoingAnimation = gameTime + 0.25;
					npc.m_flNextMeleeAttack = gameTime + 0.8;
				}
			}
		}
	}
}

static bool AltExtra_Mecha_Berserker_Demo_LifeLost(int iNPC, int lifeAfter) {
	AltExtra_Mecha_Berserker_Demo npc = view_as<AltExtra_Mecha_Berserker_Demo>(iNPC);
	
	if (!npc.Anger) {
		npc.DispatchParticleEffect(npc.index, "ExplosionCore_MidAir", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("eye_1"), PATTACH_POINT_FOLLOW, true);
		
		if (IsValidEntity(npc.m_iWearable2))
			RemoveEntity(npc.m_iWearable2);
		
		if (IsValidEntity(npc.m_iWearable3))
			RemoveEntity(npc.m_iWearable3);
		
		npc.Anger = true; // >:(
		npc.PlayLaughSound();
		
		// Get headshot immunity. because they doesn't have head..
		f_HeadshotDamageMultiNpc[npc.index] = 0.0;
		
		npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
	}
	
	return true;
}