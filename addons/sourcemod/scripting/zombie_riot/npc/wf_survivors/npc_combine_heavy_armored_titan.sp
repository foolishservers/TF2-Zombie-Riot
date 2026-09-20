#pragma semicolon 1
#pragma newdecls required

static const char g_IdleSounds[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
};

static const char g_KilledSounds[][] = {
	"npc/metropolice/vo/chuckle.wav",
	"npc/metropolice/vo/keepmoving.wav",
};

static const char g_HurtArmorSounds[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};

void Combine_Heavy_Armored_Titan_OnMapStart() {	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "W.F. Heavy Armored Titan");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_combine_heavy_armored_titan");
	strcopy(data.Icon, sizeof(data.Icon), "combine_rifle");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_WhiteflowerSpecial;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache() {
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_KilledSounds);
	PrecacheSoundArray(g_HurtArmorSounds);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team) {
	return Combine_Heavy_Armored_Titan(vecPos, vecAng, team);
}

methodmap Combine_Heavy_Armored_Titan < Combine_Base {
	public void PlayIdleSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE,  BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
	}
	
	public void PlayHurtSound() {
		if (this.Anger) {
			EmitSoundToAll(g_Combine_HurtSounds[GetRandomInt(0, sizeof(g_Combine_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		}
		else {
			EmitSoundToAll(g_HurtArmorSounds[GetRandomInt(0, sizeof(g_HurtArmorSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		}
	}
	
	public void PlayDeathSound() {
		EmitSoundToAll(g_Combine_DeathSounds[GetRandomInt(0, sizeof(g_Combine_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayKilledEnemySound(int target) {
		int health = GetEntProp(target, Prop_Data, "m_iHealth");
		if (health <= 0) {
			switch (GetRandomInt(0, 2)) {
				case 0:
					NpcSpeechBubble(this.index, "Target eliminated.", 7, {255, 255, 255, 255}, {0.0, 0.0, 150.0}, "");
				case 1:
					NpcSpeechBubble(this.index, "Tango down.", 7, {255, 255, 255, 255}, {0.0, 0.0, 150.0}, "");
				case 2:
					NpcSpeechBubble(this.index, "How frails.", 7, {255, 9, 9, 255}, {0.0, 0.0, 150.0}, "");
			}
			
			EmitSoundToAll(g_KilledSounds[GetRandomInt(0, sizeof(g_KilledSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		}
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_Combine_SwordAttackSounds[GetRandomInt(0, sizeof(g_Combine_SwordAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_Combine_SwordHitSounds[GetRandomInt(0, sizeof(g_Combine_SwordHitSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);	
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_Combine_AR2_AttackSounds[GetRandomInt(0, sizeof(g_Combine_AR2_AttackSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	property float m_flCooldownDurationHurt {
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}

	property float m_flGunPickupTime {
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	
	public Combine_Heavy_Armored_Titan(float vecPos[3], float vecAng[3], int ally) {
		Combine_Heavy_Armored_Titan npc = view_as<Combine_Heavy_Armored_Titan>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.75", "150000", ally, false, true));
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");				
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		KillFeed_SetKillIcon(npc.index, "sword");
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		npc.RegisterBody();
		
		func_NPCDeath[npc.index] = Combine_Heavy_Armored_Titan_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = Combine_Heavy_Armored_Titan_ClotThink;
		func_NPCLostHealthBar[npc.index] = Combine_Heavy_Armored_Titan_LifeLost;
		
		npc.SetActivity("ACT_COLOSUS_WALK");
		npc.m_flSpeed = 260.0;
		npc.m_bisWalking = true;
		npc.m_iChanged_WalkCycle = 0;
		
		npc.m_flDoingAnimation = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_flCooldownDurationHurt = 0.0;
		npc.m_flGunPickupTime = 0.0;
		npc.Anger = false;
		
		npc.m_iHealthBar = 1;
		
		fl_TotalArmor[npc.index] = 0.6;
		
		SetEntityRenderColor(npc.index, 192, 192, 192, 255);
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("0.8");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/heavy/fall17_commando_elite/fall17_commando_elite.mdl");
		
		npc.StartPathing();
		
		return npc;
	}
}

static void Combine_Heavy_Armored_Titan_ClotThink(int iNPC) {
	Combine_Heavy_Armored_Titan npc = view_as<Combine_Heavy_Armored_Titan>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	
	if (npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	npc.HackMaxYawRate(false);
	npc.UpdateBody();
	npc.HackMaxYawRate(true);
	
	if (npc.m_blPlayHurtAnimation) {
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST");
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	if (npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	if (npc.m_flCooldownDurationHurt) {
		if (npc.m_flGunPickupTime && npc.m_flGunPickupTime < gameTime) {
			npc.m_flGunPickupTime = 0.0;
			
			npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_irifle.mdl");
			SetVariantString("1.15");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		}
		
		if (npc.m_flCooldownDurationHurt < gameTime) {
			npc.m_flCooldownDurationHurt = 0.0;
			
			fl_TotalArmor[npc.index] = 1.0;
			
			KillFeed_SetKillIcon(npc.index, "pistol");
			
			if (npc.m_iChanged_WalkCycle != 2) {
				npc.SetActivity("ACT_RUN_AIM_AR2_STIMULATED");
				npc.m_bisWalking = true;
				npc.m_iChanged_WalkCycle = 2;
				npc.m_flSpeed = 200.0;
				
				npc.StartPathing();
			}
		}
		
		return;
	}
	
	if (npc.m_flGetClosestTargetTime < gameTime) {
		npc.m_iTargetWalkTo = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	if (npc.m_flAttackHappens) {
		if (npc.m_flAttackHappens < gameTime) {
			npc.m_flAttackHappens = 0.0;
			
			if (IsValidEnemy(npc.index, npc.m_iTarget)) {
				float vecTarget[3];
				WorldSpaceCenter(npc.m_iTarget, vecTarget);
				npc.FaceTowards(vecTarget, 15000.0);
				
				Handle swingTrace;
				if (npc.DoSwingTrace(swingTrace, npc.m_iTarget, .Npc_type = 1)) {
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if (target > 0) {
						float damage = 400.0;
						if (ShouldNpcDealBonusDamage(target))
							damage *= 4.0;
						
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
						
						npc.PlayMeleeHitSound();
						
						npc.PlayKilledEnemySound(target);
					}
				}
				
				delete swingTrace;
			}
		}
	}
	
	if (IsValidEnemy(npc.index, npc.m_iTarget)) {
		int behavior = Combine_Heavy_Armored_Titan_SelfDefense(npc, gameTime, npc.m_iTarget);
		switch (behavior) {
			case 0: {
				if (npc.m_iChanged_WalkCycle != 0) {
					npc.SetActivity("ACT_COLOSUS_WALK");
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 0;
					npc.m_flSpeed = 260.0;
					
					npc.StartPathing();
				}
			}
			case 1: {
				if (npc.m_iChanged_WalkCycle != 1) {
					npc.SetActivity("ACT_COLOSUS_IDLE");
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 1;
					npc.m_flSpeed = 0.0;
					
					npc.StopPathing();
				}
			}
			case 2: {
				if (npc.m_iChanged_WalkCycle != 2) {
					npc.SetActivity("ACT_RUN_AIM_AR2_STIMULATED");
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 2;
					npc.m_flSpeed = 200.0;
					
					npc.StartPathing();
				}
			}
			case 3: {
				if (npc.m_iChanged_WalkCycle != 3) {
					npc.SetActivity("ACT_IDLE_ANGRY_AR2");
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 3;
					npc.m_flSpeed = 0.0;
					
					npc.StopPathing();
				}
			}
		}
	}
	else {
		if (npc.Anger) {
			if (npc.m_iChanged_WalkCycle != 3) {
				npc.SetActivity("ACT_IDLE_ANGRY_AR2");
				npc.m_bisWalking = false;
				npc.m_iChanged_WalkCycle = 3;
				npc.m_flSpeed = 0.0;
				
				npc.StopPathing();
			}
		}
		else {
			if (npc.m_iChanged_WalkCycle != 1) {
				npc.SetActivity("ACT_COLOSUS_IDLE");
				npc.m_bisWalking = false;
				npc.m_iChanged_WalkCycle = 1;
				npc.m_flSpeed = 0.0;
				
				npc.StopPathing();
			}
		}
		
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	npc.PlayIdleSound();
}

static void Combine_Heavy_Armored_Titan_NPCDeath(int entity) {
	Combine_Heavy_Armored_Titan npc = view_as<Combine_Heavy_Armored_Titan>(entity);
	if (!npc.m_bGib)
		npc.PlayDeathSound();
	
	npc.ResetBody();
	
	if (IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if (IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}

static bool Combine_Heavy_Armored_Titan_LifeLost(int entity, int lifeAfter) {
	Combine_Heavy_Armored_Titan npc = view_as<Combine_Heavy_Armored_Titan>(entity);
	
	if (!npc.Anger) {
		npc.Anger = true;
		fl_TotalArmor[npc.index] = 0.05;
		
		npc.m_flGunPickupTime = GetGameTime(npc.index) + 1.0;
		npc.m_flCooldownDurationHurt = GetGameTime(npc.index) + 2.0;
		
		if (IsValidEntity(npc.m_iWearable1)) {
			RemoveEntity(npc.m_iWearable1);
		}
		
		if (npc.m_iChanged_WalkCycle != 4) {
			npc.m_iChanged_WalkCycle = 4;
			
			npc.SetActivity("ACT_PICKUP_GROUND");
			npc.SetPlaybackRate(0.5);
			npc.m_bisWalking = false;
			npc.m_flSpeed = 0.0;
			
			npc.StopPathing();
		}
	}
	
	return true;
}

static int Combine_Heavy_Armored_Titan_SelfDefense(Combine_Heavy_Armored_Titan npc, float gameTime, int target) {
	int seenTarget = Can_I_See_Enemy(npc.index, target);
	if (!IsValidEnemy(npc.index, seenTarget)) {
		float vecTarget[3], vecMe[3];
		WorldSpaceCenter(target, vecTarget);
		WorldSpaceCenter(npc.index, vecMe);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
		
		// Predict their pos.
		if (flDistanceToTarget < npc.GetLeadRadius()) {
			float vPredictedPos[3];
			PredictSubjectPosition(npc, target, _, _, vPredictedPos);
			
			npc.SetGoalVector(vPredictedPos);
		}
		else {
			npc.SetGoalEntity(target);
		}
		
		return npc.Anger ? 2 : 0;
	}
	else {
		target = seenTarget;
		npc.m_iTarget = target;
	}
	
	float vecTarget[3], vecMe[3];
	WorldSpaceCenter(target, vecTarget);
	WorldSpaceCenter(npc.index, vecMe);
	
	float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
	
	// Predict their pos.
	if (flDistanceToTarget < npc.GetLeadRadius()) {
		float vPredictedPos[3]; 
		PredictSubjectPosition(npc, target,_,_,vPredictedPos);
		
		npc.SetGoalVector(vPredictedPos);
	}
	else {
		npc.SetGoalEntity(target);
	}
	//Get position for just travel here.
	
	if (npc.m_flDoingAnimation > gameTime) {
		npc.m_iState = -1;
	}
	else if (!npc.Anger) {
		if (flDistanceToTarget < GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime) {
			npc.m_iState = 1; // Engage in Close Range Destruction.
		}
		else {
			npc.m_iState = 0;
		}
	}
	else {
		// (160 * 4) ^ 2
		if (flDistanceToTarget < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 9.0) && npc.m_flNextRangedAttack < gameTime) {
			npc.m_iState = 2; // Engage in Close Range Destruction.
		}
		else {
			npc.m_iState = 0;
		}
	}
	
	switch (npc.m_iState) {
		case 1: {			
			npc.AddGesture("ACT_MELEE_ATTACK_SWING_GESTURE", _, _, _, 0.8);
			npc.PlayMeleeSound();
			
			npc.m_flAttackHappens = gameTime + 0.5;
			npc.m_flDoingAnimation = gameTime + 0.5;
			npc.m_flNextMeleeAttack = gameTime + 1.0;
		}
		case 2: {
			if (npc.IsTargetInFiringCone(target, 10.0, 10.0)) {
				float eyePitch[3], vecDirShooting[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
				
				vecTarget[2] += 15.0;
				MakeVectorFromPoints(vecMe, vecTarget, vecDirShooting);
				GetVectorAngles(vecDirShooting, vecDirShooting);
				
				float x = GetRandomFloat( -0.03, 0.03 );
				float y = GetRandomFloat( -0.03, 0.03 );
				
				float vecRight[3], vecUp[3];
				GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
				
				float vecDir[3];
				for (int i; i < 3; i++) {
					vecDir[i] = vecDirShooting[i] + x * vecRight[i] + y * vecUp[i]; 
				}
				
				NormalizeVector(vecDir, vecDir);
				
				float damage = 35.0;
				int targetHit = FireBullet(npc.index, npc.m_iWearable1, vecMe, vecDir, damage, 9000.0, DMG_BULLET, "bullet_tracer01_red");
				if (targetHit > 0) {
					npc.PlayKilledEnemySound(targetHit);
				}
				
				npc.m_flNextRangedAttack = gameTime + 0.2;
				
				npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_AR2");
				npc.PlayRangedSound();
			}
		}
	}
	
	if (npc.Anger) {
		if (npc.m_flDoingAnimation > gameTime) {
			return 3;
		}
		else if (flDistanceToTarget > (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 4.0)) {
			return 2;
		}
		else {
			return 3;
		}
	}
	else {
		return 0;
	}
}