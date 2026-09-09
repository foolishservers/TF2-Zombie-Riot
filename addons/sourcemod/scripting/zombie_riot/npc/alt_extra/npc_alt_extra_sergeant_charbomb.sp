#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"mvm/giant_common/giant_common_explodes_01.wav",
	"mvm/giant_common/giant_common_explodes_02.wav",
};

static const char g_HurtSounds[][] = {
	"vo/mvm/mght/demoman_mvm_m_painsharp01.mp3",
	"vo/mvm/mght/demoman_mvm_m_painsharp02.mp3",
	"vo/mvm/mght/demoman_mvm_m_painsharp03.mp3",
	"vo/mvm/mght/demoman_mvm_m_painsharp04.mp3",
	"vo/mvm/mght/demoman_mvm_m_painsharp05.mp3",
	"vo/mvm/mght/demoman_mvm_m_painsharp06.mp3",
	"vo/mvm/mght/demoman_mvm_m_painsharp07.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/mght/demoman_mvm_m_specialcompleted01.mp3",
	"vo/mvm/mght/demoman_mvm_m_specialcompleted02.mp3",
	"vo/mvm/mght/demoman_mvm_m_specialcompleted03.mp3",
	"vo/mvm/mght/demoman_mvm_m_specialcompleted04.mp3",
	"vo/mvm/mght/demoman_mvm_m_specialcompleted05.mp3",
	"vo/mvm/mght/demoman_mvm_m_specialcompleted06.mp3",
	"vo/mvm/mght/demoman_mvm_m_specialcompleted07.mp3",
	"vo/mvm/mght/demoman_mvm_m_specialcompleted08.mp3",
	"vo/mvm/mght/demoman_mvm_m_specialcompleted09.mp3",
	"vo/mvm/mght/demoman_mvm_m_specialcompleted10.mp3",
	"vo/mvm/mght/demoman_mvm_m_specialcompleted11.mp3",
	"vo/mvm/mght/demoman_mvm_m_specialcompleted12.mp3",
};

static const char g_ChargeSounds[][] = {
	"weapons/demo_charge_windup1.wav",
	"weapons/demo_charge_windup2.wav",
	"weapons/demo_charge_windup3.wav",
};

static const char g_AngerSounds[][] = {
	"vo/mvm/mght/demoman_mvm_m_laughevil03.mp3",
};

static const char g_KaboomSounds[][] = {
	"vo/mvm/mght/demoman_mvm_m_specialcompleted11.mp3",
	"vo/mvm/mght/demoman_mvm_m_specialcompleted12.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/axe_hit_flesh1.wav",
	"weapons/axe_hit_flesh2.wav",
	"weapons/axe_hit_flesh3.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/machete_swing.wav",
};

void AltExtra_Sergeant_Charbomb_OnMapStart() {
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_ChargeSounds);
	PrecacheSoundArray(g_AngerSounds);
	PrecacheSoundArray(g_KaboomSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	
	PrecacheModel("models/bots/demo_boss/bot_demo_boss.mdl");
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Sergeant Charbomb");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_sergeant_charbomb");
	strcopy(data.Icon, sizeof(data.Icon), "demo");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Alt;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team) {
	return AltExtra_Sergeant_Charbomb(vecPos, vecAng, team);
}

methodmap AltExtra_Sergeant_Charbomb < AltExtra_Base {
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayHurtSound() {
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayChargeSound() {
		EmitSoundToAll(g_ChargeSounds[GetRandomInt(0, sizeof(g_ChargeSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayAngerSound() {
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 90);
	}
	
	public void PlayKaboomSound() {
		EmitSoundToAll(g_KaboomSounds[GetRandomInt(0, sizeof(g_KaboomSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 90);
	}
	
	public void PlayIdleAlertSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 32.0);
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 100));
	}
	
	property float m_flNextExplodeTime {
		public get()			{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float value) { fl_AbilityOrAttack[this.index][0] = value; }
	}
	
	property float m_flNextKaboomTime {
		public get()			{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float value) { fl_AbilityOrAttack[this.index][1] = value; }
	}
	
	public AltExtra_Sergeant_Charbomb(float vecPos[3], float vecAng[3], int team) {
		AltExtra_Sergeant_Charbomb npc = view_as<AltExtra_Sergeant_Charbomb>(CClotBody(vecPos, vecAng, "models/bots/demo_boss/bot_demo_boss.mdl", "1.35", "4500", team));
		
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_ITEM1");
		if (iActivity > 0)
			npc.StartActivity(iActivity);
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		
		npc.Anger = false;
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		func_NPCDeath[npc.index] = AltExtra_Sergeant_Charbomb_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = AltExtra_Sergeant_Charbomb_OnTakeDamage;
		func_NPCThink[npc.index] = AltExtra_Sergeant_Charbomb_ClotThink;		
		
		int skin = (team == TFTeam_Red) ? 0 : 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_caber/c_caber.mdl");
		SetVariantString("2.5");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/demo/sbox2014_juggernaut_jacket/sbox2014_juggernaut_jacket.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/pyro/dec25_veterans_visor/dec25_veterans_visor.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/pyro/dec25_commonwealth/dec25_commonwealth.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		
		npc.m_flSpeed = 200.0;
		npc.StartPathing();
		
		return npc;
	}
}

static void AltExtra_Sergeant_Charbomb_ClotThink(int iNPC) {
	AltExtra_Sergeant_Charbomb npc = view_as<AltExtra_Sergeant_Charbomb>(iNPC);
	
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
	
	if (npc.Anger) {
		if (npc.m_flNextExplodeTime) {
			if (npc.m_flNextExplodeTime < gameTime) {
				int layer = npc.AddGestureViaSequence("taunt01");
				if (layer != -1)
					npc.SetLayerPlaybackRate(layer, (0.75 / (ReturnEntityAttackspeed(npc.index))));
				
				float vecMe[3];
				WorldSpaceCenter(npc.index, vecMe);
				spawnRing_Vectors(vecMe, 500.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 255, 100, 50, 255, 1, 1.5, 5.0, 0.0, 1);
				spawnRing_Vectors(vecMe, 0.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 255, 100, 50, 255, 1, 1.5, 5.0, 0.0, 1, 500.0);
				
				npc.PlayKaboomSound();
				
				npc.m_flNextExplodeTime = 0.0;
				npc.m_flNextKaboomTime = gameTime + 1.5;
				b_NpcIsInvulnerable[npc.index] = true;
				
				npc.m_bisWalking = false;
				npc.m_bAllowBackWalking = false;
				npc.m_flSpeed = 0.0;
				npc.StopPathing();
				return;
			}
		}
		
		if (npc.m_flNextKaboomTime) {
			if (npc.m_flNextKaboomTime < gameTime) {
				KillFeed_SetKillIcon(npc.index, "megaton");
				
				float vecMe[3];
				WorldSpaceCenter(npc.index, vecMe);
				
				TE_Particle("asplode_hoodoo", vecMe, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
				Explode_Logic_Custom(200.0, npc.index, npc.index, -1, vecMe, 250.0, 1.0, _, true, 10);
				
				b_NpcIsInvulnerable[npc.index] = false;
				
				SmiteNpcToDeath(iNPC);
			}
			return;
		}
	}
	
	if (npc.m_flGetClosestTargetTime < gameTime) {
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	int target = npc.m_iTarget;
	if (IsValidEnemy(npc.index, target)) {
		float vecTarget[3], vecMe[3];
		WorldSpaceCenter(target, vecTarget);
		WorldSpaceCenter(npc.index, vecMe);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
		
		if (npc.Anger) {
			npc.m_flSpeed = 350.0;
		}
		else {
			npc.m_flSpeed = 200.0;
		}
		
		if (!npc.Anger && npc.m_flCharge_Duration < gameTime) {
			if (npc.m_flCharge_delay < gameTime) {
				if (Can_I_See_Enemy_Only(npc.index, target) && flDistanceToTarget > GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED && flDistanceToTarget < GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0) {
					npc.PlayChargeSound();
					npc.m_flCharge_delay = gameTime + 5.0;
					npc.m_flCharge_Duration = gameTime + 2.0;
					PluginBot_Jump(npc.index, vecTarget);
				}
			}
		}
		
		if (flDistanceToTarget < npc.GetLeadRadius()) {
			float vPredictedPos[3];
			PredictSubjectPosition(npc, target, _, _, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else {
			npc.SetGoalEntity(target);
		}
		
		AltExtra_Sergeant_Charbomb_SelfDefense(npc, gameTime, target, flDistanceToTarget); 
	}
	else {
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	npc.PlayIdleAlertSound();
}

static Action AltExtra_Sergeant_Charbomb_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom){
	AltExtra_Sergeant_Charbomb npc = view_as<AltExtra_Sergeant_Charbomb>(victim);
	
	if (!npc.Anger && float(GetEntProp(npc.index, Prop_Data, "m_iHealth")) <= (float(ReturnEntityMaxHealth(npc.index)) * 0.15)) {
		npc.Anger = true;
		
		npc.PlayAngerSound();
		npc.m_flNextExplodeTime = GetGameTime(npc.index) + 5.0;
		
		float flPos[3], flAng[3];
		GetAttachment(victim, "head", flPos, flAng);
		int particler = ParticleEffectAt(flPos, "scout_dodge_blue", 5.0);
		SetParent(victim, particler, "head");
		npc.m_iWearable7 = particler;
	}
	
	if (attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index)) {
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	return Plugin_Changed;
}

static void AltExtra_Sergeant_Charbomb_NPCDeath(int entity) {
	AltExtra_Sergeant_Charbomb npc = view_as<AltExtra_Sergeant_Charbomb>(entity);
	if (!npc.m_bGib)
		npc.PlayDeathSound();
	
	if (IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	
	if (IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	
	if (IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if (IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}

void AltExtra_Sergeant_Charbomb_SelfDefense(AltExtra_Sergeant_Charbomb npc, float gameTime, int target, float distance) {
	if (npc.m_flAttackHappens) {
		if (npc.m_flAttackHappens < gameTime) {
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float vecEnemy[3];
			WorldSpaceCenter(npc.m_iTarget, vecEnemy);
			npc.FaceTowards(vecEnemy, 15000.0);
			if (npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1)) {
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if (IsValidEnemy(npc.index, target)) {
					float damageDealt = 75.0;
					if (ShouldNpcDealBonusDamage(target))
						damageDealt *= 4.0;
					
					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
					
					Explode_Logic_Custom(100.0, npc.index, npc.index, -1, vecHit, 150.0, _, _, true, 10);
					TE_Particle("ExplosionCore_MidAir", vecHit, NULL_VECTOR, {-90.0, 0.0, 0.0}, _, _, _, _, _, _, _, _, _, _, 0.0);
					EmitSoundToAll(SOUND_WAND_LIGHTNING_ABILITY_PAP_SMITE, 0, SNDCHAN_AUTO, 100, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vecHit);
					
					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
	}

	if (gameTime > npc.m_flNextMeleeAttack) {
		if (distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED)) {
			int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if (IsValidEnemy(npc.index, Enemy_I_See)) {
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM1");
				
				npc.m_flAttackHappens = gameTime + 0.54;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
			}
		}
	}
}