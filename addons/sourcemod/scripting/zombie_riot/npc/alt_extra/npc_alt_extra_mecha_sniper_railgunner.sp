#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/mvm/norm/sniper_mvm_paincrticialdeath01.mp3",
	"vo/mvm/norm/sniper_mvm_paincrticialdeath02.mp3",
	"vo/mvm/norm/sniper_mvm_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/mvm/norm/sniper_mvm_painsharp01.mp3",
	"vo/mvm/norm/sniper_mvm_painsharp02.mp3",
	"vo/mvm/norm/sniper_mvm_painsharp03.mp3",
	"vo/mvm/norm/sniper_mvm_painsharp04.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/norm/sniper_mvm_battlecry01.mp3",
	"vo/mvm/norm/sniper_mvm_battlecry02.mp3",
	"vo/mvm/norm/sniper_mvm_battlecry03.mp3",
	"vo/mvm/norm/sniper_mvm_battlecry04.mp3",
};

static const char g_RangedSpecialAttackSounds[][] = {
	"weapons/sniper_railgun_charged_shot_crit_01.wav",
};

static const char g_RangedAttackSounds[][] = {
	"weapons/sniper_railgun_charged_shot_01.wav",
	"weapons/sniper_railgun_charged_shot_02.wav",
};

static const char g_RangedReloadSound[][] = {
	"weapons/sniper_railgun_world_reload.wav",
};

void AltExtra_Mecha_Sniper_Railgunner_OnMapStart() {
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_RangedSpecialAttackSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_RangedReloadSound);
	
	PrecacheModel("models/bots/sniper/bot_sniper.mdl");
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mecha Sniper Railgunner");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mecha_sniper_railgunner");
	strcopy(data.Icon, sizeof(data.Icon), "sniper");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Alt;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team) {
	return AltExtra_Mecha_Sniper_Railgunner(vecPos, vecAng, team);
}

methodmap AltExtra_Mecha_Sniper_Railgunner < AltExtra_Base {
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
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayRangedSpecialSound() {
		EmitSoundToAll(g_RangedSpecialAttackSounds[GetRandomInt(0, sizeof(g_RangedSpecialAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public AltExtra_Mecha_Sniper_Railgunner(float vecPos[3], float vecAng[3], int team) {
		AltExtra_Mecha_Sniper_Railgunner npc = view_as<AltExtra_Mecha_Sniper_Railgunner>(CClotBody(vecPos, vecAng, "models/bots/sniper/bot_sniper.mdl", "1.0", "12500", team));
		
		i_NpcWeight[npc.index] = 1;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if (iActivity > 0)
			npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		func_NPCDeath[npc.index] = AltExtra_Mecha_Sniper_Railgunner_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = AltExtra_Mecha_Sniper_Railgunner_ClotThink;
		
		//IDLE
		npc.m_flSpeed = 250.0;
		npc.m_flNextRangedAttack = 0.0;
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		npc.m_iAmmo = 0;
		
		int skin = (team == TFTeam_Red) ? 0 : 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_dex_sniperrifle/c_dex_sniperrifle.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/Jul13_Se_Headset/Jul13_Se_Headset_sniper.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

static void AltExtra_Mecha_Sniper_Railgunner_ClotThink(int entity) {
	AltExtra_Mecha_Sniper_Railgunner npc = view_as<AltExtra_Mecha_Sniper_Railgunner>(entity);
	
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
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	if (npc.m_flGetClosestTargetTime < gameTime) {
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	int target = npc.m_iTarget;
	if (IsValidEnemy(npc.index, target)) {
		if (npc.m_flJumpStartTime < gameTime) {
			npc.m_flSpeed = 170.0;
		}
		
		float vecTarget[3], vecMe[3];
		WorldSpaceCenter(target, vecTarget);
		WorldSpaceCenter(npc.index, vecMe);
		
		npc.ModifyBodyPitch(vecMe, vecTarget);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
		
		// 1250.0 * 1250.0
		if (flDistanceToTarget < 1562500.0) {
			// too close, back off!! Now!
			if (flDistanceToTarget < 100000.0) {
				npc.StartPathing();
				
				int Enemy_I_See = Can_I_See_Enemy(npc.index, target);
				if (IsValidEnemy(npc.index, Enemy_I_See)) {
					float vecBackoffPos[3];
					BackoffFromOwnPositionAndAwayFromEnemy(npc, target, _, vecBackoffPos);
					npc.SetGoalVector(vecBackoffPos, true);
				}
			}
			else {
				int Enemy_I_See = Can_I_See_Enemy(npc.index, target);
				if (IsValidEnemy(npc.index, Enemy_I_See)) {
					// Can we attack right now?
					if (npc.m_flNextRangedAttack < gameTime) {
						npc.FaceTowards(vecTarget, 30000.0);
						
						// Play attack anim
						npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
						npc.m_flSpeed = 0.0;
						
						float damage = 100.0;
						float speed = 1250.0;
						
						if (npc.m_iAmmo > 5 && !NpcStats_IsEnemySilenced(npc.index)) {
							speed = 2000.0;
							damage = 400.0;
							npc.m_iAmmo = 0;
							npc.m_flNextRangedAttack = gameTime + 7.0;	//long reload, the gun overheated from the charge shot.
							npc.PlayRangedSpecialSound();
							
							//doesn't predict over 1000 hu
							if (flDistanceToTarget < 1000000.0)
								PredictSubjectPositionForProjectiles(npc, target, speed, _, vecTarget);
							
							npc.FireParticleRocket(vecTarget, damage, speed, 100.0, GetTeam(npc.index) == TFTeam_Red ? "raygun_projectile_red_crit" : "raygun_projectile_blue_crit");
						}
						else {
							npc.m_iAmmo++;
							npc.m_flNextRangedAttack = gameTime + 1.75;
							npc.PlayRangedSound();
							
							//Doesn't predict over 750 hu
							if (flDistanceToTarget < 562500.0)
								PredictSubjectPositionForProjectiles(npc, target, speed, _, vecTarget);
							
							npc.FireParticleRocket(vecTarget, damage, speed, 100.0, GetTeam(npc.index) == TFTeam_Red ? "raygun_projectile_red" : "raygun_projectile_blue");
						}
						
						npc.m_flJumpStartTime = gameTime + 0.9;
						npc.PlayRangedReloadSound();
					}
					
					npc.StopPathing();
				}
				else {
					npc.StartPathing();
				}
			}
		}
		else {
			npc.StartPathing();
		}
		
		//Predict their pos.
		if (flDistanceToTarget < npc.GetLeadRadius()) {
			float vecPredictedPos[3];
			PredictSubjectPosition(npc, target, _, _, vecPredictedPos);
			npc.SetGoalVector(vecPredictedPos);
		}
		else {
			npc.SetGoalEntity(target);
		}
	}
	else {
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	npc.PlayIdleAlertSound();
}

static void AltExtra_Mecha_Sniper_Railgunner_NPCDeath(int entity) {
	AltExtra_Mecha_Sniper_Railgunner npc = view_as<AltExtra_Mecha_Sniper_Railgunner>(entity);
	if (!npc.m_bGib)
		npc.PlayDeathSound();
	
	if (IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if (IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}