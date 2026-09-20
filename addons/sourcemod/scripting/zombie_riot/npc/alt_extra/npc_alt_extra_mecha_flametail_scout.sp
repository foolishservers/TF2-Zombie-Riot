#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/mvm/norm/scout_mvm_paincrticialdeath01.mp3",
	"vo/mvm/norm/scout_mvm_paincrticialdeath02.mp3",
	"vo/mvm/norm/scout_mvm_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/mvm/norm/scout_mvm_painsharp01.mp3",
	"vo/mvm/norm/scout_mvm_painsharp02.mp3",
	"vo/mvm/norm/scout_mvm_painsharp03.mp3",
	"vo/mvm/norm/scout_mvm_painsharp04.mp3",
	"vo/mvm/norm/scout_mvm_painsharp05.mp3",
	"vo/mvm/norm/scout_mvm_painsharp06.mp3",
	"vo/mvm/norm/scout_mvm_painsharp07.mp3",
	"vo/mvm/norm/scout_mvm_painsharp08.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/norm/scout_mvm_battlecry01.mp3",
	"vo/mvm/norm/scout_mvm_battlecry02.mp3",
	"vo/mvm/norm/scout_mvm_battlecry03.mp3",
	"vo/mvm/norm/scout_mvm_battlecry04.mp3",
	"vo/mvm/norm/scout_mvm_battlecry05.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/bat_hit.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/machete_swing.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/bat_draw_swoosh1.wav",
	"weapons/bat_draw_swoosh2.wav",
};

void AltExtra_Mecha_Flametail_Scout_OnMapStart() {
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mecha Flametail Scout");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mecha_flametail_scout");
	strcopy(data.Icon, sizeof(data.Icon), "scout_giant_fast");
	data.IconCustom = false;
	data.Category = Type_Alt;
	data.Flags = MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache() {
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeMissSounds);
	
	char sound[128];
	for (int i = 1; i <= 36; i++) {
		FormatEx(sound, sizeof(sound), "vo/mvm/norm/scout_mvm_beingshotinvincible%s%d.mp3", i > 9 ? "" : "0", i);
		PrecacheSound(sound);
	}
	
	PrecacheModel("models/bots/scout/bot_scout.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data) {
	return AltExtra_Mecha_Flametail_Scout(vecPos, vecAng, team);
}

methodmap AltExtra_Mecha_Flametail_Scout < AltExtra_Base {
	public void PlayIdleAlertSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	public void PlayHurtSound() {
		if (this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMissSound(){
		char sound[128];
		int num = GetRandomInt(1, 36);
		FormatEx(sound, sizeof(sound), "vo/mvm/norm/scout_mvm_beingshotinvincible%s%d.mp3", num > 9 ? "" : "0", num);
		EmitSoundToAll(sound, this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	property float m_flNextDodgeTime {
		public get()			{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float value) { fl_AbilityOrAttack[this.index][0] = value; }
	}
	
	property float m_flDodgeEndTime {
		public get()			{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float value) { fl_AbilityOrAttack[this.index][1] = value; }
	}
	
	public AltExtra_Mecha_Flametail_Scout(float vecPos[3], float vecAng[3], int team) {
		AltExtra_Mecha_Flametail_Scout npc = view_as<AltExtra_Mecha_Flametail_Scout>(CClotBody(vecPos, vecAng, "models/bots/scout/bot_scout.mdl", "1.0", "12500", team));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if (iActivity > 0)
			npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		
		func_NPCDeath[npc.index] = AltExtra_Mecha_Flametail_Scout_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = AltExtra_Mecha_Flametail_Scout_OnTakeDamage;
		func_NPCThink[npc.index] = AltExtra_Mecha_Flametail_Scout_ClotThink;
		
		npc.m_flSpeed = 300.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		npc.Anger = false;
		npc.m_flHookDamageTaken = 0.0;
		npc.m_flNextDodgeTime = GetGameTime(npc.index) + 5.0;
		npc.m_flDodgeEndTime = 0.0;
		
		int skin = (team == TFTeam_Red) ? 0 : 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_demo_sultan_sword/c_demo_sultan_sword.mdl");
		SetEntityRenderColor(npc.m_iWearable1, 255, 165, 0, 255);
		
		return npc;
	}
}

static void AltExtra_Mecha_Flametail_Scout_ClotThink(int iNPC) {
	AltExtra_Mecha_Flametail_Scout npc = view_as<AltExtra_Mecha_Flametail_Scout>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if (npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
			
	if (npc.m_blPlayHurtAnimation) {
		if (!npc.Anger) {
			npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
			npc.PlayHurtSound();
		}
		else {
			npc.PlayMissSound();
		}
		
		npc.m_blPlayHurtAnimation = false;
	}
	
	if (npc.Anger) {
		if (npc.m_flDodgeEndTime < gameTime) {
			if (IsValidEntity(npc.m_iWearable1))
				ExtinguishTarget(npc.m_iWearable1);
			npc.Anger = false;
			npc.m_flNextDodgeTime = gameTime + 16.0;
		}
	}
	else {
		if (npc.m_flNextDodgeTime < gameTime) {
			if (IsValidEntity(npc.m_iWearable1))
				IgniteTargetEffect(npc.m_iWearable1);
			npc.Anger = true;
			npc.m_flDodgeEndTime = gameTime + 4.0;
		}
	}
	
	if (npc.m_flNextThinkTime > gameTime) {
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	if (npc.m_flGetClosestTargetTime < gameTime) {
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	int threat = npc.m_iTarget;
	if (IsValidEnemy(npc.index, threat)) {
		float vecTarget[3], vecMe[3];
		WorldSpaceCenter(threat, vecTarget);
		WorldSpaceCenter(npc.index, vecMe);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
		
		//Predict their pos.
		if (flDistanceToTarget < npc.GetLeadRadius()) {
			float vecPredictedPos[3];
			PredictSubjectPosition(npc, threat, _, _, vecPredictedPos);
			npc.SetGoalVector(vecPredictedPos);
		}
		else {
			npc.SetGoalEntity(threat);
		}
		
		if (flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen) {
			//Can we attack right now?
			if (npc.m_flNextMeleeAttack < gameTime) {
				//Play attack ani
				if (!npc.m_flAttackHappenswillhappen) {
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
					npc.PlayMeleeSound();
					npc.m_flAttackHappens = gameTime + 0.4;
					npc.m_flAttackHappens_bullshit = gameTime + 0.54;
					npc.m_flAttackHappenswillhappen = true;
				}
					
				if (npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen) {
					Handle swingTrace;
					npc.FaceTowards(vecTarget, 20000.0);
					if (npc.DoSwingTrace(swingTrace, threat)) {
						int target = TR_GetEntityIndex(swingTrace);	
						
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						
						if (target > 0) {
							if(!ShouldNpcDealBonusDamage(target))
								SDKHooks_TakeDamage(target, npc.index, npc.index, 75.0, DMG_CLUB, -1, _, vecHit);
							else
								SDKHooks_TakeDamage(target, npc.index, npc.index, 150.0, DMG_CLUB, -1, _, vecHit);
							
							// Hit sound
							npc.PlayMeleeHitSound();
						}
					}
					delete swingTrace;
					
					npc.m_flNextMeleeAttack = gameTime + 0.6;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen) {
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = gameTime + 0.6;
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
	
	npc.PlayIdleAlertSound();
}

static Action AltExtra_Mecha_Flametail_Scout_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	AltExtra_Mecha_Flametail_Scout npc = view_as<AltExtra_Mecha_Flametail_Scout>(victim);
	if (attacker <= 0)
		return Plugin_Continue;
	
	bool blocked;
	if (npc.Anger) {
		npc.m_flHookDamageTaken += damage;
		
		float origin[3];
		npc.GetAttachment("head", origin, NULL_VECTOR);
		origin[2] += 10.0;
		
		if (IsValidClient(attacker)) {
			TE_ParticleInt(g_particleMissText, origin);
			TE_SendToClient(attacker);
		}
		
		damage = 0.0;
		
		blocked = true;
	}
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index)) {
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return blocked ? Plugin_Handled : Plugin_Continue;
}

static void AltExtra_Mecha_Flametail_Scout_NPCDeath(int entity) {
	AltExtra_Mecha_Flametail_Scout npc = view_as<AltExtra_Mecha_Flametail_Scout>(entity);
	if (!npc.m_bGib)
		npc.PlayDeathSound();
	
	if (npc.m_flHookDamageTaken > (float(ReturnEntityMaxHealth(npc.index)) * 0.5)) {
		SpawnMoney(entity, true);
	}
	
	if (IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}