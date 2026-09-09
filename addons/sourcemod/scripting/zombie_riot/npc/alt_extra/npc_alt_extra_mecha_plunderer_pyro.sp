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

static const char g_IdleSounds[][] = {
	"vo/mvm/norm/pyro_mvm_jeers01.mp3",	
	"vo/mvm/norm/pyro_mvm_jeers02.mp3",	
};

static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/norm/taunts/pyro_mvm_taunts01.mp3",
	"vo/mvm/norm/taunts/pyro_mvm_taunts02.mp3",
	"vo/mvm/norm/taunts/pyro_mvm_taunts03.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/axe_hit_flesh1.wav",
	"weapons/axe_hit_flesh2.wav",
	"weapons/axe_hit_flesh3.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/machete_swing.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/bat_draw_swoosh1.wav",
	"weapons/bat_draw_swoosh2.wav",
};

static const char g_ChargeDashSound[][] = {
	"misc/halloween/spell_blast_jump.wav",
};

void AltExtra_Mecha_Plunderer_Pyro_OnMapStart() {
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheSoundArray(g_ChargeDashSound);
	
	PrecacheModel("models/bots/pyro/bot_pyro.mdl");
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mecha Plunderer Pyro");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mecha_plunderer_pyro");
	strcopy(data.Icon, sizeof(data.Icon), "pyro");
	data.IconCustom = false;
	data.Flags = 0;			
	data.Category = Type_Alt;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data) {
	return AltExtra_Mecha_Plunderer_Pyro(vecPos, vecAng, team);
}

methodmap AltExtra_Mecha_Plunderer_Pyro < AltExtra_Base {
	public void PlayIdleSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	
	public void PlayIdleAlertSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
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
	
	public void PlayChargeSound() {
		EmitSoundToAll(g_ChargeDashSound[GetRandomInt(0, sizeof(g_ChargeDashSound) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
	}
	
	public AltExtra_Mecha_Plunderer_Pyro(float vecPos[3], float vecAng[3], int team) {
		AltExtra_Mecha_Plunderer_Pyro npc = view_as<AltExtra_Mecha_Plunderer_Pyro>(CClotBody(vecPos, vecAng, "models/bots/pyro/bot_pyro.mdl", "1.0", "35000", team, false, true));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if (iActivity > 0)
			npc.StartActivity(iActivity);
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;

		func_NPCDeath[npc.index] = AltExtra_Mecha_Plunderer_Pyro_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = AltExtra_Mecha_Plunderer_Pyro_ClotThink;
		
		//IDLE
		npc.m_flSpeed = 300.0;
		npc.m_iState = 0;
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		int skin = (team == TFTeam_Red) ? 0 : 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.index, 125, 100, 100, 255);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/pyro/hwn2023_dead_heat/hwn2023_dead_heat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/pyro/short2014_spiked_armourgeddon/short2014_spiked_armourgeddon.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_axtinguisher/c_axtinguisher_pyro.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

static void AltExtra_Mecha_Plunderer_Pyro_ClotThink(int iNPC) {
	AltExtra_Mecha_Plunderer_Pyro npc = view_as<AltExtra_Mecha_Plunderer_Pyro>(iNPC);

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
	
	if (npc.IsOnGround()) {
		if (npc.m_iChanged_WalkCycle != 1) {
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 1;
			npc.SetActivity("ACT_MP_RUN_MELEE");
			npc.StartPathing();
		}
	}
	else {
		if (npc.m_iChanged_WalkCycle != 2) {
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 2;
			npc.SetActivity("ACT_MP_JUMP_FLOAT_MELEE");
			npc.StartPathing();
		}
	}
	
	int target = npc.m_iTarget;
	if (IsValidEnemy(npc.index, target)) {
		float vecTarget[3], vecMe[3];
		WorldSpaceCenter(target, vecTarget);
		WorldSpaceCenter(npc.index, vecMe);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
		
		if (npc.m_flCharge_delay < gameTime) {
			if (flDistanceToTarget > NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0) {
				npc.PlayChargeSound();
				npc.m_flCharge_delay = gameTime + 5.0;
				PluginBot_Jump(npc.index, vecTarget);
				
				float flPos[3], flAng[3];
				npc.GetBonePositionSimple(npc.index, "bip_foot_L", flPos, flAng);
				int Particle_1 = ParticleEffectAt_Parent(flPos, "rockettrail", npc.index, _, {0.0,0.0,0.0});
				
				npc.GetBonePositionSimple(npc.index, "bip_foot_R", flPos, flAng);
				int Particle_2 = ParticleEffectAt_Parent(flPos, "rockettrail", npc.index, _, {0.0,0.0,0.0});
				
				CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(Particle_1), TIMER_FLAG_NO_MAPCHANGE);
				CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(Particle_2), TIMER_FLAG_NO_MAPCHANGE);
			}
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
		
		//Target close enough to hit
		if (flDistanceToTarget < 22500.0 || npc.m_flAttackHappenswillhappen) {
			// Look at target so we hit.
			// npc.FaceTowards(vecTarget, 1000.0);
			
			// Can we attack right now?
			if (npc.m_flNextMeleeAttack < gameTime) {
				//Play attack ani
				if (!npc.m_flAttackHappenswillhappen) {
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					npc.PlayMeleeSound();
					npc.m_flAttackHappens = gameTime + 0.4;
					npc.m_flAttackHappens_bullshit = gameTime + 0.54;
					npc.m_flAttackHappenswillhappen = true;
				}
				
				if (npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen) {
					npc.FaceTowards(vecTarget, 20000.0);
					
					Handle swingTrace;
					if (npc.DoSwingTrace(swingTrace, target, _, _, _, 1)) {
						int targetHit = TR_GetEntityIndex(swingTrace);	
						
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						
						if (targetHit > 0) {
							int damagetype = DMG_CLUB;
							float damage = 150.0;
							if (IgniteFor[target] > 0) {
								damagetype = DMG_TRUEDAMAGE;
								damage = 300.0;
							}
							
							if (ShouldNpcDealBonusDamage(targetHit))
								damage *= 6.0;
							
							SDKHooks_TakeDamage(targetHit, npc.index, npc.index, damage, damagetype, -1, _, vecHit);
							
							// Hit sound
							npc.PlayMeleeHitSound();
						}
					}
					delete swingTrace;
					
					npc.m_flNextMeleeAttack = gameTime + 0.8;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen) {
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = gameTime + 0.8;
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

static void AltExtra_Mecha_Plunderer_Pyro_NPCDeath(int entity) {
	AltExtra_Mecha_Plunderer_Pyro npc = view_as<AltExtra_Mecha_Plunderer_Pyro>(entity);
	if (!npc.m_bGib)
		npc.PlayDeathSound();
	
	if (IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if (IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if (IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}