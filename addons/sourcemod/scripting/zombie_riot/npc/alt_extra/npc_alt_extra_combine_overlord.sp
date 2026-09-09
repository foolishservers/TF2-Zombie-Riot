#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	")npc/combine_soldier/die1.wav",
	")npc/combine_soldier/die2.wav",
	")npc/combine_soldier/die3.wav",
};

static const char g_HurtSounds[][] = {
	")npc/combine_soldier/pain1.wav",
	")npc/combine_soldier/pain2.wav",
	")npc/combine_soldier/pain3.wav",
};

static const char g_IdleSounds[][] = {
	")npc/combine_soldier/vo/alert1.wav",
	")npc/combine_soldier/vo/bouncerbouncer.wav",
	")npc/combine_soldier/vo/boomer.wav",
	")npc/combine_soldier/vo/contactconfim.wav",
};

static const char g_IdleAlertedSounds[][] = {
	")npc/combine_soldier/vo/alert1.wav",
	")npc/combine_soldier/vo/bouncerbouncer.wav",
	")npc/combine_soldier/vo/boomer.wav",
	")npc/combine_soldier/vo/contactconfim.wav",
};

static const char g_MeleeHitSounds[][] = {
	")weapons/halloween_boss/knight_axe_hit.wav",
};

static const char g_ChargeSounds[][] = {
	")weapons/physcannon/physcannon_charge.wav",
};

static const char g_MeleeAttackSounds[][] = {
	")weapons/demo_sword_swing1.wav",
	")weapons/demo_sword_swing2.wav",
	")weapons/demo_sword_swing3.wav",
};

static const char g_RangedAttackSounds[][] = {
	"weapons/ar2/fire1.wav",
};

static const char g_RangedAttackSoundsSecondary[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav",
};

static const char g_RangedReloadSound[][] = {
	"weapons/ar2/npc_ar2_reload.wav",
};

static const char g_MeleeMissSounds[][] = {
	")weapons/cbar_miss1.wav",
};

void AltExtra_CombineOverlord_OnMapStart() {
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) { PrecacheSound(g_RangedReloadSound[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSoundsSecondary));   i++) { PrecacheSound(g_RangedAttackSoundsSecondary[i]);   }
	for (int i = 0; i < (sizeof(g_ChargeSounds));   i++) { PrecacheSound(g_ChargeSounds[i]);   }
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Holy Overlord");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_combine_overlord");
	strcopy(data.Icon, sizeof(data.Icon), "combine_overlord");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Alt;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return AltExtra_CombineOverlord(vecPos, vecAng, team);
}

methodmap AltExtra_CombineOverlord < CClotBody {
	public void PlayIdleSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayIdleAlertSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayRangedAttackSecondarySound() {
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlaySpecialChargeSound() {
		EmitSoundToAll(g_ChargeSounds[GetRandomInt(0, sizeof(g_ChargeSounds) - 1)], this.index, _, 110, _, BOSS_ZOMBIE_VOLUME);
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public AltExtra_CombineOverlord(float vecPos[3], float vecAng[3], int ally) {
		AltExtra_CombineOverlord npc = view_as<AltExtra_CombineOverlord>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_2_MODEL, "1.25", "35000", ally));
		
		i_NpcWeight[npc.index] = 3;
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_WF_OVERLORD_RUN");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		func_NPCDeath[npc.index] = AltExtra_CombineOverlord_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = AltExtra_CombineOverlord_ClotThink;	
		
		npc.m_bThisNpcIsABoss = true;
		npc.m_iState = 0;
		npc.m_flSpeed = 250.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 5.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		npc.m_flNextChargeSpecialAttack = GetGameTime(npc.index) + 5.0;
		
		GiveNpcOutLineLastOrBoss(npc.index, true);
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_shogun_katana/c_shogun_katana.mdl");
		SetVariantString("0.8");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/all_class/jul13_se_headset/jul13_se_headset_soldier.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/soldier/bak_caped_crusader/bak_caped_crusader.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		npc.m_iWearable4 = npc.EquipItem("partyhat", "models/player/items/demo/crown.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		SetEntityRenderColor(npc.index, 150, 175, 255, 255);
		SetEntityRenderColor(npc.m_iWearable1, 255, 1, 1, 255);
		SetEntityRenderColor(npc.m_iWearable2, 100, 150, 255, 255);
		SetEntityRenderColor(npc.m_iWearable3, 100, 150, 255, 255);
		
		return npc;
	}
}


static void AltExtra_CombineOverlord_ClotThink(int iNPC) {
	AltExtra_CombineOverlord npc = view_as<AltExtra_CombineOverlord>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_HURT", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
		
	float TrueArmor = 1.0;
	if (!NpcStats_IsEnemySilenced(npc.index)) {
		if (npc.m_flAngerDelay > gameTime)
			TrueArmor *= 0.25;
		
		if (npc.m_fbRangedSpecialOn)
			TrueArmor *= 0.15;
	}
	
	fl_TotalArmor[npc.index] = TrueArmor;
	
	//Think throttling
	if(npc.m_flNextThinkTime > gameTime) {
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	int target = npc.m_iTarget;
	if(IsValidEnemy(npc.index, target, true)) {
		if (npc.m_flReloadDelay < gameTime) {
			if (npc.m_flmovedelay < gameTime && npc.m_flAngerDelay < gameTime) {
				if (npc.m_iChanged_WalkCycle != 7) {
					npc.m_iChanged_WalkCycle = 7;
					npc.SetActivity("ACT_WF_OVERLORD_RUN");
				}
				
				npc.m_flmovedelay = gameTime + 1.0;
				npc.m_flSpeed = 330.0;
			}
			
			if (npc.m_flmovedelay < gameTime && npc.m_flAngerDelay > gameTime) {
				if (npc.m_iChanged_WalkCycle != 8) {
					npc.m_iChanged_WalkCycle = 8;
					npc.SetActivity("ACT_WF_OVERLORD_RUN_RAGE");
				}
				
				npc.m_flmovedelay = gameTime + 1.0;
				npc.m_flSpeed = 380.0;
			}
		}
		
		float vecTarget[3];
		WorldSpaceCenter(target, vecTarget);
		
		if (npc.m_flJumpStartTime > gameTime) {
			npc.m_flSpeed = 0.0;
		}
		
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
		//Predict their pos.
		if (flDistanceToTarget < npc.GetLeadRadius()) {
			float vPredictedPos[3];
			PredictSubjectPosition(npc, target,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		} 
		else {
			npc.SetGoalEntity(target);
		}
		
		if (npc.m_flNextChargeSpecialAttack < gameTime && npc.m_flReloadDelay < gameTime && flDistanceToTarget < 160000) {
			npc.m_flNextChargeSpecialAttack = gameTime + 20.0;
			npc.m_flReloadDelay = gameTime + 1.5;
			npc.m_flRangedSpecialDelay += gameTime + 1.5;
			npc.m_flAngerDelay = gameTime + 12.0;
			
			if (npc.m_bThisNpcIsABoss) {
				npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("anim_attachment_LH"), PATTACH_POINT_FOLLOW, true);
			}
			
			npc.PlaySpecialChargeSound();
			npc.AddGesture("ACT_WF_OVERLORD_RAGE_START");
			npc.m_flmovedelay = gameTime + 0.5;
			npc.m_flJumpStartTime = gameTime + 1.5;
			npc.StopPathing();
		}
		
		if (npc.m_flNextRangedSpecialAttack < gameTime && npc.m_flAngerDelay < gameTime || npc.m_fbRangedSpecialOn) {
			if (!npc.m_fbRangedSpecialOn) {
				npc.StopPathing();
				
				npc.AddGesture("ACT_WF_OVERLORD_ATTACK_PULSE");
				npc.m_flRangedSpecialDelay = gameTime + 0.3;
				npc.m_fbRangedSpecialOn = true;
				npc.m_flReloadDelay = gameTime + 0.4;
			}
			
			if (npc.m_flRangedSpecialDelay < gameTime) {
				npc.m_fbRangedSpecialOn = false;
				npc.m_flNextRangedSpecialAttack = gameTime + 8.0;
				npc.PlayRangedAttackSecondarySound();
				
				npc.FaceTowards(vecTarget, 20000.0);
				
				float Angles[3], distance = 100.0, UserLoc[3];
				GetAbsOrigin(npc.index, UserLoc);
				
				MakeVectorFromPoints(UserLoc, vecTarget, Angles);
				GetVectorAngles(Angles, Angles);
				
				float type;
				float projectileSpeed = 450.0;
				// 250 * 250 = 62500.0
				// if target is close, we do wide attack
				// if target is far, we do long range attack.
				if (flDistanceToTarget < 62500.0) {
					Angles[1] -= 22.5;
					type = 9.0;
				}
				else {
					Angles[1] -= 10.0;
					type = 4.0;
					projectileSpeed = 600.0;
				}
				
				for (int i = 1; i <= 5; i++) {
					float tempAngles[3], endLoc[3], Direction[3];
					tempAngles[0] = -32.5;
					tempAngles[1] = Angles[1] + type * i;
					tempAngles[2] = 0.0;
					
					GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
					ScaleVector(Direction, distance);
					AddVectors(UserLoc, Direction, endLoc);
					
					npc.FireParticleRocket(endLoc, 125.0, projectileSpeed, 100.0, "raygun_projectile_blue", .bonusdmg = 3.0);
				}
			}
		}
		
		//Target close enough to hit
		if (flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flReloadDelay < gameTime || npc.m_flAttackHappenswillhappen) {
			npc.StartPathing();
			if(npc.m_flNextMeleeAttack < gameTime)
			{
				if (!npc.m_flAttackHappenswillhappen)
				{
					npc.m_flNextRangedSpecialAttack = gameTime + 2.0;
					npc.RemoveGesture("ACT_WF_OVERLORD_ATTACK_NORMAL");
					npc.RemoveGesture("ACT_WF_OVERLORD_ATTACK_NORMAL_RAGE");
					if(npc.m_flAngerDelay > gameTime)
					{
						npc.AddGesture("ACT_WF_OVERLORD_ATTACK_NORMAL_RAGE",_, 0.25);
					}
					else
						npc.AddGesture("ACT_WF_OVERLORD_ATTACK_NORMAL",_, 0.25);

					npc.PlayMeleeSound();
					npc.m_flAttackHappens = gameTime + 0.3;
					npc.m_flAttackHappens_bullshit = gameTime + 0.44;
					npc.m_flAttackHappenswillhappen = true;
				}
				
				if (npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen) {
					npc.FaceTowards(vecTarget, 20000.0);
					
					Handle swingTrace;
					if (npc.DoSwingTrace(swingTrace, target)) {
						target = TR_GetEntityIndex(swingTrace);	
						
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						
						if (target > 0) {
							if (!ShouldNpcDealBonusDamage(target))
								SDKHooks_TakeDamage(target, npc.index, npc.index, 100.0, DMG_CLUB, -1, _, vecHit);
							else
								SDKHooks_TakeDamage(target, npc.index, npc.index, 400.0, DMG_CLUB, -1, _, vecHit);
									
							Custom_Knockback(npc.index, target, 450.0);
							
							// Hit sound
							npc.PlayMeleeHitSound();
						} 
					}
					delete swingTrace;
					
					if (npc.m_flAngerDelay > gameTime) {
						npc.m_flNextMeleeAttack = gameTime + 0.2;
					}
					else {
						npc.m_flNextMeleeAttack = gameTime + 0.4;
					}
					
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen) {
					npc.m_flAttackHappenswillhappen = false;
					
					if (npc.m_flAngerDelay > gameTime) {
						npc.m_flNextMeleeAttack = gameTime + 0.2;
					}
					else {
						npc.m_flNextMeleeAttack = gameTime + 0.4;
					}
				}
			}
		}
		
		if (npc.m_flReloadDelay < gameTime) {
			npc.StartPathing();
		}
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	npc.PlayIdleAlertSound();
}

static void AltExtra_CombineOverlord_NPCDeath(int entity) {
	AltExtra_CombineOverlord npc = view_as<AltExtra_CombineOverlord>(entity);
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
}