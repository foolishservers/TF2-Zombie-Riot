#pragma semicolon 1
#pragma newdecls required

/*
	How it works (Sorry to bad english):
	It has fast movement (360HU/s)
	and normal melee attack rate.
	
	also has 2 lives! Its attack rate will be faster on life loss.
	then lost resistance.
*/

void AltExtra_Mecha_Duelist_MapStart() {
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mecha Duelist");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mecha_duelist");
	strcopy(data.Icon, sizeof(data.Icon), "medic");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Alt;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data) {
	return AltExtra_Mecha_Duelist(vecPos, vecAng, team);
}

methodmap AltExtra_Mecha_Duelist < AltExtra_Base {
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
	
	public AltExtra_Mecha_Duelist(float vecPos[3], float vecAng[3], int team) {
		AltExtra_Mecha_Duelist npc = view_as<AltExtra_Mecha_Duelist>(CClotBody(vecPos, vecAng, "models/bots/medic/bot_medic.mdl", "1.0", "25000", team));
		
		i_NpcWeight[npc.index] = 2;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_flAttackHappens_bullshit = 0.0;
		
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCDeath[npc.index] = AltExtra_Mecha_Duelist_NPCDeath;
		func_NPCThink[npc.index] = AltExtra_Mecha_Duelist_ClotThink;
		func_NPCLostHealthBar[npc.index] = AltExtra_Mecha_Duelist_LifeLost;
		
		npc.m_flSpeed = 360.0;
		npc.m_iState = 0;
		npc.m_iHealthBar = 1;
		
		fl_RangedArmor[npc.index] = 0.75;
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		npc.SetActivity("ACT_MP_RUN_MELEE");
		
		int skin = (team == TFTeam_Red) ? 0 : 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", WEAPON_CUSTOM_WEAPONRY_1);
		SetVariantInt(8192);
		AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
		SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 2);
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/jul13_heavy_defender/jul13_heavy_defender.mdl", _, skin);
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/sum20_flatliner/sum20_flatliner.mdl", _, skin);
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/robo_medic_pickelhaube/robo_medic_pickelhaube.mdl", _, skin);
		
		return npc;
	}
}

static void AltExtra_Mecha_Duelist_ClotThink(int iNPC) {
	AltExtra_Mecha_Duelist npc = view_as<AltExtra_Mecha_Duelist>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if (npc.m_flNextDelayTime > gameTime) {
		return;
	}
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
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
		if (npc.m_flAttackHappenswillhappen) {
			if (npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime) {
				Handle swingTrace;
				if (npc.DoSwingTrace(swingTrace, target)) {
					int targetHit = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if (targetHit > 0) {
						float damage = 110.0;
						if (ShouldNpcDealBonusDamage(targetHit))
							damage *= 5.0;
						
						SDKHooks_TakeDamage(targetHit, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
						
						// Hit sound
						npc.PlayExpidonsanSwordMeleeHitSounds();
					}
				}
				delete swingTrace;
				
				npc.m_flAttackHappenswillhappen = false;
			}
			else if (npc.m_flAttackHappens_bullshit < gameTime) {
				npc.m_flAttackHappenswillhappen = false;
			}
		}
		
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
		
		if (npc.m_flDoingAnimation > gameTime) {
			npc.m_iState = -1;
		}
		else if (flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED
				&& npc.m_flNextMeleeAttack < gameTime) {
			npc.m_iState = 1;
		}
		else {
			npc.m_iState = 0;
		}
		
		switch (npc.m_iState) {
			case -1:
			{
				return;
			}
			case 0:
			{
				npc.StartPathing();
			}
			case 1:
			{
				if (!npc.m_flAttackHappenswillhappen)
				{
					if (npc.Anger) {
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE", .SetGestureSpeed = 2.0);
						
						npc.m_flAttackHappens = gameTime + 0.175;
						npc.m_flAttackHappens_bullshit = gameTime + 0.5;
						
						npc.m_flDoingAnimation = gameTime + 0.5;
						npc.m_flNextMeleeAttack = gameTime + 0.6;
					}
					else {
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
						
						npc.m_flAttackHappens = gameTime + 0.35;
						npc.m_flAttackHappens_bullshit = gameTime + 1.0;
						
						npc.m_flDoingAnimation = gameTime + 1.0;
						npc.m_flNextMeleeAttack = gameTime + 1.2;
					}
					
					npc.PlayExpidonsanSwordMeleeAttackSounds();
					npc.m_flAttackHappenswillhappen = true;
				}
			}
		}
	}
	else {
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
}

static void AltExtra_Mecha_Duelist_NPCDeath(int iNPC) {
	AltExtra_Mecha_Duelist npc = view_as<AltExtra_Mecha_Duelist>(iNPC);
	
	npc.PlayDeathSound();
	
	if (IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if (IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if (IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	
	if (IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
}

static bool AltExtra_Mecha_Duelist_LifeLost(int iNPC, int lifeAfter) {
	AltExtra_Mecha_Duelist npc = view_as<AltExtra_Mecha_Duelist>(iNPC);
	
	if (!npc.Anger) {
		if (IsValidEntity(npc.m_iWearable2))
			RemoveEntity(npc.m_iWearable2);
		
		if (IsValidEntity(npc.m_iWearable4))
			RemoveEntity(npc.m_iWearable4);
		
		npc.Anger = true;
		npc.DispatchParticleEffect(npc.index, "ExplosionCore_buildings", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);
		
		fl_RangedArmor[npc.index] = 1.0;
		
		npc.PlayRageSound();
	}
	
	return true;
}