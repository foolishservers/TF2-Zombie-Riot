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

static const char g_RangedAttackSounds[] = ")weapons/man_melter_fire.wav";

void AltExtra_Mecha_Killing_Order_OnMapStart() {
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mecha Killing Order Pyro");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mecha_killing_order");
	strcopy(data.Icon, sizeof(data.Icon), "pyro_flare");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_ALWAYSCRIT;
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
	
	PrecacheModel("models/bots/pyro/bot_pyro.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally) {
	return AltExtra_Mecha_Killing_Order(vecPos, vecAng, ally);
}

methodmap AltExtra_Mecha_Killing_Order < AltExtra_Base {
	public void PlayIdleAlertSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
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
		EmitSoundToAll(g_RangedAttackSounds, this.index, SNDCHAN_WEAPON, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0);
	}
	
	public void SetTargetPos(const float vecPos[3]) {
		this.m_flAbilityOrAttack0 = vecPos[0];
		this.m_flAbilityOrAttack1 = vecPos[1];
		this.m_flAbilityOrAttack2 = vecPos[2];
	}
	
	public void GetTargetPos(float vecPos[3]) {
		vecPos[0] = this.m_flAbilityOrAttack0;
		vecPos[1] = this.m_flAbilityOrAttack1;
		vecPos[2] = this.m_flAbilityOrAttack2;
	}
	
	public AltExtra_Mecha_Killing_Order(float vecPos[3], float vecAng[3], int team) {
		AltExtra_Mecha_Killing_Order npc = view_as<AltExtra_Mecha_Killing_Order>(CClotBody(vecPos, vecAng, "models/bots/pyro/bot_pyro.mdl", "1.0", "20000", team, false, true));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_ITEM1");
		if (iActivity > 0)
			npc.StartActivity(iActivity);
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextRangedAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		
		func_NPCDeath[npc.index] = AltExtra_Mecha_Killing_Order_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = AltExtra_Mecha_Killing_Order_ClotThink;
		
		KillFeed_SetKillIcon(npc.index, "manmelter");
		
		npc.m_iState = 0;
		npc.m_flSpeed = 200.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		npc.SetTargetPos({0.0, 0.0, 0.0});
		
		int skin = (team == TFTeam_Red) ? 0 : 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		SetEntityRenderColor(npc.index, 125, 100, 100, 255);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_drg_manmelter/c_drg_manmelter.mdl");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/pyro/robo_pyro_last_watt/robo_pyro_last_watt.mdl");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/all_class/dec15_patriot_peak/dec15_patriot_peak_pyro.mdl");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable3, 125, 100, 100, 255);
		
		return npc;
	}
}

static void AltExtra_Mecha_Killing_Order_NPCDeath(int entity) {
	AltExtra_Mecha_Killing_Order npc = view_as<AltExtra_Mecha_Killing_Order>(entity);
	if (!npc.m_bGib)
		npc.PlayDeathSound();
	
	if (IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if (IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if (IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}

static void AltExtra_Mecha_Killing_Order_ClotThink(int iNPC) {
	AltExtra_Mecha_Killing_Order npc = view_as<AltExtra_Mecha_Killing_Order>(iNPC);
	
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
		npc.m_iTargetWalkTo = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	int target = npc.m_iTargetWalkTo;
	if (IsValidEnemy(npc.index, target)) {
		switch (AltExtra_Mecha_Killing_Order_SelfDefense(npc, gameTime)) {
			case 0: {
				if (npc.m_iChanged_WalkCycle != 1) {
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_RUN_ITEM1");
					npc.m_flSpeed = 240.0;
					npc.StartPathing();
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
			}
			case 1: {
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
		npc.m_iTargetWalkTo = GetClosestTarget(npc.index);
	}
	
	npc.PlayIdleAlertSound();
}

static int AltExtra_Mecha_Killing_Order_SelfDefense(AltExtra_Mecha_Killing_Order npc, float gameTime) {
	// Find valid target.
	// If we failed, move forward.
	if (!npc.m_flAttackHappens) {
		if (IsValidEnemy(npc.index, npc.m_iTarget)) {
			if (!Can_I_See_Enemy_Only(npc.index, npc.m_iTarget)) {
				npc.m_iTarget = GetClosestTarget(npc.index, _, _, _, _, _, _, true, _, _, true);
			}
		}
		else {
			npc.m_iTarget = GetClosestTarget(npc.index, _, _, _, _, _, _, true, _, _, true);
			if (!IsValidEnemy(npc.index, npc.m_iTarget)) {
				return 0;
			}
		}
		
		if (!IsValidEnemy(npc.index, npc.m_iTarget)) {
			return 0;
		}
	}
	
	// Sniper must not being stuck in spawn.
	if (Rogue_Mode() && i_npcspawnprotection[npc.index] == NPC_SPAWNPROT_ON)
		return 0;
	
	float vecTarget[3], vecMe[3];
	WorldSpaceCenter(npc.m_iTarget, vecTarget);
	WorldSpaceCenter(npc.index, vecMe);
	
	float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
	
	if (flDistanceToTarget < 4000000.0) {
		float origin[3], angles[3], vecPos[3];
		view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
		if (npc.m_flDoingAnimation > gameTime) {
			if (Can_I_See_Enemy_Only(npc.index, npc.m_iTarget)) {
				WorldSpaceCenter(npc.m_iTarget, vecPos);
				
				float vecAng[3];
				GetVectorAnglesTwoPoints(vecMe, vecPos, vecAng);
				
				Handle trace = TR_TraceRayFilterEx(vecMe, vecAng, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
				if (TR_DidHit(trace)) {
					TR_GetEndPosition(vecPos, trace);
										
					// 내가 따라갈 수 있을 때만 회전
					npc.ModifyBodyPitch(vecMe, vecPos);
					npc.FaceTowards(vecPos, 15000.0);
				}
				
				npc.SetTargetPos(vecPos);
				
				delete trace;
			}
		}
		else {
			if (npc.m_flAttackHappens) {
				npc.GetTargetPos(vecPos);
				
				float vecAng[3];
				GetVectorAnglesTwoPoints(vecMe, vecPos, vecAng);
				
				Handle trace = TR_TraceRayFilterEx(vecMe, vecAng, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
				if (TR_DidHit(trace)) {
					TR_GetEndPosition(vecPos, trace);
					npc.SetTargetPos(vecPos);
				}
				delete trace;
			}
		}
		
		int team = GetTeam(npc.index);
		if (npc.m_flAttackHappens) {
			int TeamColor[4] = {0, 0, 255, 255};
			if (team == TFTeam_Red)
				TeamColor = {255, 50, 50, 255};
			
			npc.GetTargetPos(vecPos);
			
			TE_SetupBeamPoints(origin, vecPos, Shared_BEAM_Laser, 0, 0, 0, 0.11, 5.0, 5.0, 0, 0.0, TeamColor, 3);
			TE_SendToAll(0.0);
		}
		
		if (npc.m_flAttackHappens) {
			if (npc.m_flAttackHappens < gameTime) {
				npc.m_flAttackHappens = 0.0;
				
				npc.GetTargetPos(vecPos);
				
				float vecAng[3];
				GetVectorAnglesTwoPoints(vecMe, vecPos, vecAng);
				
				ShootLaser(npc.m_iWearable1, "dxhr_sniper_rail", origin, vecPos, false);
				
				Handle trace = TR_TraceRayFilterEx(vecMe, vecAng, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
				
				int target = TR_GetEntityIndex(trace);
				if (IsValidEnemy(npc.index, target)) {
					TR_GetEndPosition(vecPos, trace);
					
					float damageDealt = 100.0;
					if (ShouldNpcDealBonusDamage(target))
						damageDealt *= 5.0;
					
					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecPos);
					
					if (!IsInvuln(target))
						NPC_Ignite(target, npc.index, 3.0, -1, 8.0);
					
					ApplyStatusEffect(npc.index, target, "Identifying Targets", 5.0);
				}
				
				delete trace;
				
				npc.PlayRangedSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
			}
		}
		
		if (gameTime > npc.m_flNextRangedAttack) {
			npc.m_flAttackHappens = gameTime + 1.25;
			npc.m_flDoingAnimation = gameTime + 0.95;
			npc.m_flNextRangedAttack = gameTime + 1.75;
		}
		
		return 1;
	}
	else {
		// Yeah we missed the target.
		// Reset and chase it.
		if (gameTime <= npc.m_flNextRangedAttack) {
			npc.m_flAttackHappens = 0.0;
			npc.m_flDoingAnimation = 0.0;
			npc.m_flNextRangedAttack = 0.0;
		}
	}
	
	return 0;
}