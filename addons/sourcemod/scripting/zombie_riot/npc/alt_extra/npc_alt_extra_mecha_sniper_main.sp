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

static const char g_MeleeHitSounds[][] = {
	"weapons/cbar_hitbod1.wav",
	"weapons/cbar_hitbod2.wav",
	"weapons/cbar_hitbod3.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/machete_swing.wav",
};

static const char g_RangedAttackSounds[][] = {
	"weapons/smg_shoot.wav",
};

static const char g_RangedReloadSound[][] = {
	"weapons/smg_worldreload.wav",
};

void AltExtra_Mecha_Sniper_Main_OnMapStart() {
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_DefaultMeleeMissSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_RangedReloadSound);
	
	PrecacheModel("models/bots/sniper/bot_sniper.mdl");
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mecha Sniper Main");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mecha_sniper_main");
	strcopy(data.Icon, sizeof(data.Icon), "sniper");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Alt;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team) {
	return AltExtra_Mecha_Sniper_Main(vecPos, vecAng, team);
}

methodmap AltExtra_Mecha_Sniper_Main < AltExtra_Base {
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
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_DefaultMeleeMissSounds[GetRandomInt(0, sizeof(g_DefaultMeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public bool IsTargetInFiringCone(int target, float maxAngle = 20.0) {
		float vecMe[3], vecTarget[3], vecToTarget[3];
		WorldSpaceCenter(this.index, vecMe);
		WorldSpaceCenter(target, vecTarget);
		
		SubtractVectors(vecTarget, vecMe, vecToTarget);
		NormalizeVector(vecToTarget, vecToTarget);
		
		float angRotation[3];
		GetEntPropVector(this.index, Prop_Data, "m_angRotation", angRotation);
		
		float flTargetYaw = this.UTIL_VecToYaw(vecToTarget);
		float flDiff = this.UTIL_AngleDiff(flTargetYaw, angRotation[1]);
		
		return (FloatAbs(flDiff) <= maxAngle);
	}
	
	public AltExtra_Mecha_Sniper_Main(float vecPos[3], float vecAng[3], int team) {
		AltExtra_Mecha_Sniper_Main npc = view_as<AltExtra_Mecha_Sniper_Main>(CClotBody(vecPos, vecAng, "models/bots/sniper/bot_sniper.mdl", "1.0", "12500", team));
		
		i_NpcWeight[npc.index] = 1;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if (iActivity > 0)
			npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		func_NPCDeath[npc.index] = AltExtra_Mecha_Sniper_Main_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = AltExtra_Mecha_Sniper_Main_OnTakeDamage;
		func_NPCThink[npc.index] = AltExtra_Mecha_Sniper_Main_ClotThink;
		
		//IDLE
		npc.m_flSpeed = 250.0;
		npc.m_flNextRangedAttack = 0.0;
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		npc.m_iAttacksTillReload = 10;
		
		int skin = (team == TFTeam_Red) ? 0 : 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.index, 125, 100, 100, 255);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_smg/c_smg.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/sniper/grfs_sniper.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable2, 125, 100, 100, 255);
		
		return npc;
	}
}

static void AltExtra_Mecha_Sniper_Main_ClotThink(int entity) {
	AltExtra_Mecha_Sniper_Main npc = view_as<AltExtra_Mecha_Sniper_Main>(entity);
	
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
		float vecTarget[3], vecMe[3];
		WorldSpaceCenter(target, vecTarget);
		WorldSpaceCenter(npc.index, vecMe);
		
		npc.ModifyBodyPitch(vecMe, vecTarget);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
		
		if (flDistanceToTarget < npc.GetLeadRadius()) {
			float vecPredictedPos[3];
			PredictSubjectPosition(npc, target, _, _, vecPredictedPos);
			npc.SetGoalVector(vecPredictedPos);
		}
		else {
			npc.SetGoalEntity(target);
		}
		
		if (npc.Anger) {
			if (npc.m_iChanged_WalkCycle != 2) {
				if (IsValidEntity(npc.m_iWearable1))
					RemoveEntity(npc.m_iWearable1);
			
				npc.m_iChanged_WalkCycle = 2;
				
				int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_MELEE");
				if (iActivity_melee > 0)
					npc.StartActivity(iActivity_melee);
				
				npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_scimitar/c_scimitar.mdl");
				SetVariantString("1.0");
				AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
			}
			
			if (flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen) {
				if (npc.m_flNextMeleeAttack < gameTime || npc.m_flAttackHappenswillhappen) {
					// Play attack anim
					if (!npc.m_flAttackHappenswillhappen) {
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
						npc.PlayMeleeSound();
						npc.m_flAttackHappens = gameTime + 0.4;
						npc.m_flAttackHappens_bullshit = gameTime + 0.54;
						npc.m_flAttackHappenswillhappen = true;
					}
					
					if (npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen) {
						Handle swingTrace;
						npc.FaceTowards(vecTarget, 20000.0);
						if (npc.DoSwingTrace(swingTrace, target)) {
							int targetHit = TR_GetEntityIndex(swingTrace);
							
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);
							
							if (targetHit > 0) {
								float damage = 35.0;
								if (ShouldNpcDealBonusDamage(targetHit))
									damage *= 2.0;
								
								SDKHooks_TakeDamage(targetHit, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
								
								// Hit sound
								npc.PlayMeleeHitSound();
							}
						}
						delete swingTrace;
						npc.m_flNextMeleeAttack = gameTime + 0.1;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if (npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen) {
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = gameTime + 0.1;
					}
				}
			}
			else {
				npc.StartPathing();
			}
		}
		else {
			// 350 * 350 = 122500
			if (npc.m_flNextRangedAttack < gameTime && flDistanceToTarget < 122500.0 && npc.m_flReloadDelay < gameTime) {
				int seenTarget = Can_I_See_Enemy(npc.index, target);
				if (!IsValidEnemy(npc.index, seenTarget)) {
					npc.StartPathing();
				}
				else if (!npc.IsTargetInFiringCone(seenTarget)) {
					WorldSpaceCenter(seenTarget, vecTarget);
					npc.FaceTowards(vecTarget, 750.0);
				}
				else {
					WorldSpaceCenter(seenTarget, vecTarget);
					npc.FaceTowards(vecTarget, 750.0);
					
					npc.StopPathing();
					
					npc.m_flNextRangedAttack = GetGameTime(npc.index) + 0.125;
					npc.m_iAttacksTillReload--;
					
					float vecSpread = 0.1;
					
					float eyePitch[3];
					GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
					
					float x, y;
					x = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
					y = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
					
					float vecDirShooting[3], vecRight[3], vecUp[3];
					
					vecTarget[2] += 15.0;
					float SelfVecPos[3];
					WorldSpaceCenter(npc.index, SelfVecPos);
					MakeVectorFromPoints(SelfVecPos, vecTarget, vecDirShooting);
					GetVectorAngles(vecDirShooting, vecDirShooting);
					vecDirShooting[1] = eyePitch[1];
					GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
					
					npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
					
					float vecDir[3];
					vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
					vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
					vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
					NormalizeVector(vecDir, vecDir);
					
					float WorldSpaceVec[3];
					WorldSpaceCenter(npc.index, WorldSpaceVec);
					
					FireBullet(npc.index, npc.m_iWearable1, WorldSpaceVec, vecDir, 10.0, 9000.0, DMG_BULLET, "bullet_tracer01_red");
					
					npc.PlayRangedSound();
					
					if (npc.m_iAttacksTillReload == 0) {
						npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY");
						npc.m_flReloadDelay = gameTime + 1.4;
						npc.m_iAttacksTillReload = 10;
						npc.PlayRangedReloadSound();
					}
				}
			}
			
			if (flDistanceToTarget > 90000.0) {
				npc.StartPathing();
			}
		}
	}
	else {
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	npc.PlayIdleAlertSound();
}

static Action AltExtra_Mecha_Sniper_Main_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	AltExtra_Mecha_Sniper_Main npc = view_as<AltExtra_Mecha_Sniper_Main>(victim);
	
	if (attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index)) {
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	if (!NpcStats_IsEnemySilenced(npc.index)) {
		if (!npc.Anger && ((ReturnEntityMaxHealth(npc.index) / 2) >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))) {
			npc.Anger = true;
			npc.m_flSpeed = 300.0;
		}
	}
	
	return Plugin_Continue;
}

static void AltExtra_Mecha_Sniper_Main_NPCDeath(int entity) {
	AltExtra_Mecha_Sniper_Main npc = view_as<AltExtra_Mecha_Sniper_Main>(entity);
	if (!npc.m_bGib)
		npc.PlayDeathSound();
	
	if (IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if (IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}