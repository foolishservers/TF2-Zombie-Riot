#pragma semicolon 1
#pragma newdecls required

static const char g_IdleSounds[][] = {
	"vo/medic_battlecry01.mp3",
	"vo/medic_battlecry02.mp3",
	"vo/medic_battlecry03.mp3",
	"vo/medic_battlecry04.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/medic_battlecry01.mp3",
	"vo/medic_battlecry02.mp3",
	"vo/medic_battlecry03.mp3",
	"vo/medic_battlecry04.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/blade_slice_2.wav",
	"weapons/blade_slice_3.wav",
	"weapons/blade_slice_4.wav",
};

/*
	Ruina - Galahad:
	
	1. Behavior (TODO)
	- It has long range but slow attack rate.
	- Trying to lunge to you when engage is ready. (Battery)
	- Get a high resistance while engaging.
*/

void Ruina_Galahad_MapStart() {
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Galahad");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ruina_galahad");
	strcopy(data.Icon, sizeof(data.Icon), "lancelot");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Ruina;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache() {
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team) {
	return Ruina_Galahad(vecPos, vecAng, team);
}

methodmap Ruina_Galahad < CClotBody {
	public void PlayHurtSound() {
		EmitSoundToAll(g_DefaultMedic_HurtSounds[GetRandomInt(0, sizeof(g_DefaultMedic_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
	}
	
	public void PlayDeathSound() {
		EmitSoundToAll(g_DefaultMedic_DeathSounds[GetRandomInt(0, sizeof(g_DefaultMedic_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);	
	}
	
	public void PlayIdleSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	
	public void PlayIdleAlertSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void AdjustWalkCycle() {
		if (this.IsOnGround()) {
			if (this.m_iChanged_WalkCycle != 0) {
				this.SetActivity("ACT_MP_RUN_MELEE");
				this.AddGesture("ACT_MP_JUMP_LAND_MELEE");
				this.m_iChanged_WalkCycle = 0;
			}
		}
		else {
			if (this.m_iChanged_WalkCycle != 1) {
				this.SetActivity("ACT_MP_JUMP_FLOAT_MELEE");
				this.AddGesture("ACT_MP_JUMP_START_MELEE");
				this.m_iChanged_WalkCycle = 1;
			}
		}
	}
	
	property float m_flRunAwayTimer {
		public get()				{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float value) 	{ fl_AbilityOrAttack[this.index][0] = value; }
	}
	
	public Ruina_Galahad(float vecPos[3], float vecAng[3], int team) {
		Ruina_Galahad npc = view_as<Ruina_Galahad>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "200000", team));
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if (iActivity > 0)
			npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCDeath[npc.index] = Ruina_Galahad_NPCDeath;
		func_NPCThink[npc.index] = Ruina_Galahad_ClotThink;
		
		npc.m_iChanged_WalkCycle = 0;
		npc.m_flSpeed = 300.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flRunAwayTimer = 0.0;
		
		npc.StartPathing();
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", RUINA_CUSTOM_MODELS_2);
		SetVariantInt(RUINA_IMPACT_LANCE_3|RUINA_HAND_CREST_3);
		AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/soldier/hwn2023_shortness_breath/hwn2023_shortness_breath.mdl");
		SetEntityRenderColor(npc.m_iWearable2, 25, 25, 25, 255);
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/cardiologists_camo/cardiologists_camo.mdl");
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/sf14_purity_wings/sf14_purity_wings.mdl");
		
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/medic/sum25_clinical/sum25_clinical.mdl");
		
		npc.m_iWearable6 = npc.EquipItem("head", "models/player/items/medic/medic_officer.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		
		int skin = (team == TFTeam_Red) ? 0 : 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);
		
		ApplyStatusEffect(npc.index, npc.index, "Ruina Battery Charge", 99999.0);
		
		fl_ruina_battery_max[npc.index] = 2000.0;
		fl_ruina_battery[npc.index] = 0.0;
		
		b_ruina_battery_ability_active[npc.index] = false;
		fl_ruina_battery_timer[npc.index] = 0.0;
		
		return npc;
	}
}

static void Ruina_Galahad_ClotThink(int entity) {
	Ruina_Galahad npc = view_as<Ruina_Galahad>(entity);
	
	float gameTime = GetGameTime(entity);
	
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
	npc.AdjustWalkCycle();
	
	Ruina_Add_Battery(npc.index, 5.0);
	
	if (npc.m_flGetClosestTargetTime < gameTime) {
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	if (IsValidEnemy(npc.index, PrimaryThreatIndex)) {
		float vecTarget[3], vecMe[3];
		WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		WorldSpaceCenter(npc.index, vecMe);
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
		
		int iPitch = npc.LookupPoseParameter("body_pitch");
		if (iPitch >= 0) {
			//Body pitch
			float v[3], ang[3];
			SubtractVectors(vecMe, vecTarget, v); 
			NormalizeVector(v, v);
			GetVectorAngles(v, ang); 
			
			float flPitch = npc.GetPoseParameter(iPitch);
			
			npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));	
		}
		
		Ruina_Galahad_Melee(npc, flDistanceToTarget, PrimaryThreatIndex);
		
		npc.StartPathing();
	}
	else {
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_bAllowBackWalking = false;
	}
	
	npc.PlayIdleAlertSound();
}

static void Ruina_Galahad_Melee(Ruina_Galahad npc, float flDistanceToTarget, int PrimaryThreatIndex) {
	float gameTime = GetGameTime(npc.index);
	float Swing_Speed = (npc.Anger ? 1.0 : 2.0);
	float Swing_Delay = (npc.Anger ? 0.1 : 0.2);
	
	bool retreat = false;
	
	if (npc.m_flAttackHappens) {
		if (npc.m_flAttackHappens < gameTime) {
			npc.m_flAttackHappens = 0.0;
			
			npc.m_flRunAwayTimer = gameTime + (Swing_Speed * 0.5);
			
			float VecEnemy[3];
			WorldSpaceCenter(PrimaryThreatIndex, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			
			Handle swingTrace;
			if (npc.DoSwingTrace(swingTrace, PrimaryThreatIndex, _, _, _, 1)) {
				int targetHit = TR_GetEntityIndex(swingTrace);
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if (targetHit > 0) {
					float damage = 1000.0;
					if (ShouldNpcDealBonusDamage(targetHit))
						damage *= 5.0;
					
					SDKHooks_TakeDamage(targetHit, npc.index, npc.index, damage, DMG_CLUB|DMG_PLASMA, -1, _, vecHit);
					
					bool Knocked = false;
					if (IsValidClient(targetHit)) {
						if (IsInvuln(targetHit)) {
							Knocked = true;
							Custom_Knockback(npc.index, targetHit, 900.0, true);
							
							TF2_AddCondition(targetHit, TFCond_LostFooting, 0.5);
							TF2_AddCondition(targetHit, TFCond_AirCurrent, 0.5);
						}
						else {
							TF2_AddCondition(targetHit, TFCond_LostFooting, 0.5);
							TF2_AddCondition(targetHit, TFCond_AirCurrent, 0.5);
						}
					}
					
					if(!Knocked)
						Custom_Knockback(npc.index, targetHit, 450.0, true); 
					
					// Hit sound
					npc.PlayMeleeHitSound();
				}
			}
			delete swingTrace;
		}
	}
	else {
		if (npc.m_flRunAwayTimer > gameTime ||
			(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.0 && npc.m_flNextMeleeAttack > gameTime)) {
			retreat = true;
			
			npc.m_bAllowBackWalking = true;
			
			float vBackoffPos[3];
			BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex, _, vBackoffPos);
			npc.SetGoalVector(vBackoffPos, true);
			
			npc.m_flSpeed = 300.0 * RUINA_BACKWARDS_MOVEMENT_SPEED_PENALTY;
		}
		else {
			npc.m_bAllowBackWalking = false;
			
			if (flDistanceToTarget < npc.GetLeadRadius()) {
				float vecPredictedPos[3];
				PredictSubjectPosition(npc, PrimaryThreatIndex, _, _, vecPredictedPos);
				npc.SetGoalVector(vecPredictedPos);
			}
			else {
				npc.SetGoalEntity(PrimaryThreatIndex);
			}
		}
	}
	
	if (!retreat)
		npc.m_flSpeed = 300.0;
	
	if (npc.m_flNextMeleeAttack < gameTime && flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.5625)) {
		int Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
		if (IsValidEnemy(npc.index, Enemy_I_See)) {
			npc.m_iTarget = Enemy_I_See;
			
			npc.PlayMeleeSound();
			npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
			
			npc.m_flAttackHappens = gameTime + Swing_Delay;
			npc.m_flDoingAnimation = gameTime + Swing_Delay;
			npc.m_flNextMeleeAttack = gameTime + Swing_Speed;
		}
	}
}

static void Ruina_Galahad_NPCDeath(int entity) {
	Ruina_Galahad npc = view_as<Ruina_Galahad>(entity);
	
	if (!npc.m_bGib)
		npc.PlayDeathSound();
	
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
	
	if (IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
}