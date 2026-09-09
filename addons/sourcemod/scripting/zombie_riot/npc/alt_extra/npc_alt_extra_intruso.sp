#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/mvm/norm/spy_mvm_paincrticialdeath01.mp3",
	"vo/mvm/norm/spy_mvm_paincrticialdeath02.mp3",
	"vo/mvm/norm/spy_mvm_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/mvm/norm/spy_mvm_painsharp01.mp3",
	"vo/mvm/norm/spy_mvm_painsharp02.mp3",
	"vo/mvm/norm/spy_mvm_painsharp03.mp3",
	"vo/mvm/norm/spy_mvm_painsharp04.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/norm/spy_mvm_battlecry01.mp3",
	"vo/mvm/norm/spy_mvm_battlecry02.mp3",
	"vo/mvm/norm/spy_mvm_battlecry03.mp3",
	"vo/mvm/norm/spy_mvm_battlecry04.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};

static const char g_ZapAttackSounds[][] = {
	"npc/assassin/ball_zap1.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/blade_hit1.wav",
	"weapons/blade_hit2.wav",
	"weapons/blade_hit3.wav",
	"weapons/blade_hit4.wav",
};

static const char g_MeleeAttackBackstabSounds[][] = {
	"player/spy_shield_break.wav",
};

void AltExtra_Intruso_OnMapStart() {
	LastSpawnDiversio = 0.0;
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Intruso");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_intruso");
	strcopy(data.Icon, sizeof(data.Icon), "spy");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MISSION;
	data.Category = Type_Alt;
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
	PrecacheSoundArray(g_ZapAttackSounds);
	PrecacheSoundArray(g_MeleeAttackBackstabSounds);
	
	PrecacheModel("models/bots/spy/bot_spy.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data) {
	return AltExtra_Intruso(vecPos, vecAng, team, data);
}

methodmap AltExtra_Intruso < AltExtra_Base {
	public void PlayIdleAlertSound()  {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayZapSound() {
		EmitSoundToAll(g_ZapAttackSounds[GetRandomInt(0, sizeof(g_ZapAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeBackstabSound(int target) {
		EmitSoundToAll(g_MeleeAttackBackstabSounds[GetRandomInt(0, sizeof(g_MeleeAttackBackstabSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		if (target <= MaxClients) {
			EmitSoundToClient(target, g_MeleeAttackBackstabSounds[GetRandomInt(0, sizeof(g_MeleeAttackBackstabSounds) - 1)], target, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		}
	}
	
	public void PlayMeleeHitSound()  {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public AltExtra_Intruso(float vecPos[3], float vecAng[3], int team, const char[] data) {
		AltExtra_Intruso npc = view_as<AltExtra_Intruso>(CClotBody(vecPos, vecAng, "models/bots/spy/bot_spy.mdl", "1.0", "750", team, false, false, true));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_MP_RUN_MELEE");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		
		func_NPCDeath[npc.index] = AltExtra_Intruso_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = AltExtra_Intruso_OnTakeDamage;
		func_NPCThink[npc.index] = AltExtra_Intruso_ClotThink;
		
		npc.m_flSpeed = 280.0;
		b_TryToAvoidTraverse[npc.index] = true;
		DiversionSpawnNpcReset(npc.index);
		
		npc.StartPathing();
		
		bool final = StrContains(data, "spy_duel") != -1;
		
		if (final) {
			i_RaidGrantExtra[npc.index] = 1;
		}
		
		int skin = (team == TFTeam_Red) ? 0 : 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_eternal_reward/c_eternal_reward.mdl");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop_partner/player/items/all_class/dex_glasses/dex_glasses_spy.mdl");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/soldier/bak_caped_crusader/bak_caped_crusader.mdl");
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop_partner/player/items/spy/dex_belltower/dex_belltower.mdl");
		SetVariantString("1.1");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		
		npc.m_bCamo = true;
		
		SetUnrevealed(npc.index);
		SetUnrevealed(npc.m_iWearable1);
		SetUnrevealed(npc.m_iWearable2);
		SetUnrevealed(npc.m_iWearable3);
		SetUnrevealed(npc.m_iWearable4);
		
		if (team != TFTeam_Red) {
			if (LastSpawnDiversio < GetGameTime()) {
				EmitSoundToAll("player/spy_uncloak_feigndeath.wav", _, _, _, _, 1.0);	
				EmitSoundToAll("player/spy_uncloak_feigndeath.wav", _, _, _, _, 1.0);	
				for (int client_check = 1; client_check <= MaxClients; client_check++) {
					if (IsClientInGame(client_check) && !IsFakeClient(client_check)) {
						SetGlobalTransTarget(client_check);
						ShowGameText(client_check, "voice_player", 1, "%t", "Intruso Spawn");
					}
				}
			}
			LastSpawnDiversio = GetGameTime() + 20.0;
			TeleportDiversioToRandLocation(npc.index);
		}
		
		return npc;
	}
}

void SetRevealed(int entity, float visibleDist = 30000.0) {
	if (!IsValidEntity(entity))
		return;
	
	SetEntPropFloat(entity, Prop_Send, "m_fadeMinDist", visibleDist);
	SetEntPropFloat(entity, Prop_Send, "m_fadeMaxDist", visibleDist);
}

void SetUnrevealed(int entity, float invisibleMinDist = 350.0, float invisibleMaxDist = 500.0) {
	if (!IsValidEntity(entity))
		return;
	
	SetEntPropFloat(entity, Prop_Send, "m_fadeMinDist", invisibleMinDist);
	SetEntPropFloat(entity, Prop_Send, "m_fadeMaxDist", invisibleMaxDist);
}

static void AltExtra_Intruso_ClotThink(int iNPC) {
	AltExtra_Intruso npc = view_as<AltExtra_Intruso>(iNPC);
	
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
	
	if (npc.m_flNextThinkTime > gameTime) {
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	if (HasSpecificBuff(npc.index, "Revealed")) {
		if (npc.m_bCamo) {
			SetUnrevealed(npc.index);
			SetUnrevealed(npc.m_iWearable1);
			SetUnrevealed(npc.m_iWearable2);
			SetUnrevealed(npc.m_iWearable3);
			SetUnrevealed(npc.m_iWearable4);
			
			npc.m_bCamo = false;
		}
	}
	else if (!npc.m_bCamo) {
		SetRevealed(npc.index);
		SetRevealed(npc.m_iWearable1);
		SetRevealed(npc.m_iWearable2);
		SetRevealed(npc.m_iWearable3);
		SetRevealed(npc.m_iWearable4);
		
		npc.m_bCamo = true;
	}
	
	if (npc.m_flGetClosestTargetTime < gameTime) {
		npc.m_iTarget = GetClosestTarget(npc.index, true);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	int target = npc.m_iTarget;
	if (IsValidEnemy(npc.index, target)) {
		int AntiCheeseReply = 0;
		
		float vecTarget[3], vecMe[3];
		WorldSpaceCenter(target, vecTarget);
		WorldSpaceCenter(npc.index, vecMe);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
		if (flDistanceToTarget < npc.GetLeadRadius()) {
			float vecPredictedPos[3];
			b_TryToAvoidTraverse[npc.index] = false;
			PredictSubjectPosition(npc, target, _, _, vecPredictedPos);
			vecPredictedPos = GetBehindTarget(target, 40.0, vecPredictedPos);
			AntiCheeseReply = DiversionAntiCheese(target, npc.index, vecPredictedPos);
			b_TryToAvoidTraverse[npc.index] = true;
			
			if (AntiCheeseReply == 0) {
				if (!npc.m_bPathing)
					npc.StartPathing();
				
				npc.SetGoalVector(vecPredictedPos, true);
				
				npc.SetActivity("ACT_MP_RUN_MELEE");
			}
			else if (AntiCheeseReply == 1) {
				if (npc.m_bPathing)
					npc.StopPathing();
				
				npc.SetActivity("ACT_MP_STAND_SECONDARY");
			}
		}
		else {
			DiversionCalmDownCheese(npc.index);
			if (!npc.m_bPathing)
				npc.StartPathing();
			
			npc.SetGoalEntity(target);
			
			npc.SetActivity("ACT_MP_RUN_MELEE");
		}
		
		switch (AntiCheeseReply) {
			case 0: {
				AltExtra_Intruso_SelfDefense(npc, gameTime, target, flDistanceToTarget); 
			}
			case 1: {
				npc.m_flAttackHappens = 0.0;
				AltExtra_Intruso_SelfDefenseRanged(npc, gameTime, target); 
			}
		}
	}
	else {
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index, true);
	}
	
	npc.PlayIdleAlertSound();
}

static Action AltExtra_Intruso_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	AltExtra_Intruso npc = view_as<AltExtra_Intruso>(victim);
	
	if (attacker <= 0)
		return Plugin_Continue;
	
	if (i_RaidGrantExtra[victim]) {
		if (!i_HasBeenBackstabbed[victim]) {
			damage = 0.0;
			return Plugin_Changed;
		}
	}
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index)) {
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void AltExtra_Intruso_NPCDeath(int entity) {
	AltExtra_Intruso npc = view_as<AltExtra_Intruso>(entity);
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

static void AltExtra_Intruso_SelfDefenseRanged(AltExtra_Intruso npc, float gameTime, int target) {
	float WorldSpaceVec[3];
	WorldSpaceCenter(target, WorldSpaceVec);
	npc.FaceTowards(WorldSpaceVec, 15000.0);
	if (gameTime > npc.m_flNextRangedAttack) {
		npc.PlayZapSound();
		
		npc.AddGesture("ACT_MP_ATTACK_STAND_GRENADE");
		npc.m_flDoingAnimation = gameTime + 0.25;
		npc.m_flNextRangedAttack = gameTime + 1.2;
		float damageDealt = 85.0;
		SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, WorldSpaceVec);
		
		npc.DispatchParticleEffect(target, "mvm_soldier_shockwave", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, 0, PATTACH_CUSTOMORIGIN, true);
	}
}

static void AltExtra_Intruso_SelfDefense(AltExtra_Intruso npc, float gameTime, int target, float distance) {
	bool BackstabDone = false;
	if (gameTime > npc.m_flNextMeleeAttack) {
		if (distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED) {
			int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			
			float vecEnemy[3];
			WorldSpaceCenter(npc.m_iTarget, vecEnemy);
			npc.FaceTowards(vecEnemy, 15000.0);
			if (IsValidEnemy(npc.index, Enemy_I_See)) {
				npc.PlayMeleeSound();
				if (i_RaidGrantExtra[npc.index]) {
					if (Enemy_I_See <= MaxClients && b_FaceStabber[Enemy_I_See]) {
						BackstabDone = true;
					}
				}
				
				if (BackstabDone || IsBehindAndFacingTarget(npc.index, npc.m_iTarget) && !NpcStats_IsEnemySilenced(npc.index)) {
					BackstabDone = true;
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_SECONDARY");	
				}
				else {
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				}
				
				npc.m_flAttackHappens = 1.0;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
			}
		}
	}
	
	if (npc.m_flAttackHappens) {
		if (npc.m_flAttackHappens < gameTime) {
			npc.m_flAttackHappens = 0.0;
			
			//Ignore barricades
			Handle swingTrace;
			if (npc.DoSwingTrace(swingTrace, npc.m_iTarget,_,_, _, _, 1)) {
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if (IsValidEnemy(npc.index, target)) {
					float damageDealt = 50.0;
					
					if (BackstabDone) {
						if (i_RaidGrantExtra[npc.index]) {
							if (target <= MaxClients && b_FaceStabber[target]) {
								damageDealt *= 0.5;
							}
						}
						
						npc.PlayMeleeBackstabSound(target);
						damageDealt *= 3.0;
					}
					else if (i_RaidGrantExtra[npc.index]) {
						damageDealt *= 0.5;
					}

					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
					
					// Hit sound
					npc.PlayMeleeHitSound();
					
					// Make copies.
					if (!NpcStats_IsEnemySilenced(npc.index) && !IsValidEnemy(npc.index, target)) {
						int health = ReturnEntityMaxHealth(npc.index);
						
						float pos[3], ang[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
						GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
						
						int team = GetTeam(npc.index);
						
						if (MaxEnemiesAllowedSpawnNext(1) <= (EnemyNpcAlive - EnemyNpcAliveStatic)) {
							fl_Extra_Speed[npc.index] *= 1.1;
							fl_Extra_Damage[npc.index] *= 1.05;
							SetEntProp(npc.index, Prop_Data, "m_iHealth", RoundToCeil(float(health) * 1.1));
							SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", RoundToCeil(float(health) * 1.1));
						}
						else {
							int entity = NPC_CreateById(i_NpcInternalId[npc.index], -1, pos, ang, team);
							if (entity > MaxClients) {
								if (team != TFTeam_Red)
									NpcAddedToZombiesLeftCurrently(entity, true);
								
								SetEntProp(entity, Prop_Data, "m_iHealth", health);
								SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
								
								fl_Extra_MeleeArmor[entity] = fl_Extra_MeleeArmor[npc.index];
								fl_Extra_RangedArmor[entity] = fl_Extra_RangedArmor[npc.index];
								fl_Extra_Speed[entity] = fl_Extra_Speed[npc.index];
								fl_Extra_Damage[entity] = fl_Extra_Damage[npc.index];
							}
						}
					}
				}
			}
			
			delete swingTrace;
		}
	}
}