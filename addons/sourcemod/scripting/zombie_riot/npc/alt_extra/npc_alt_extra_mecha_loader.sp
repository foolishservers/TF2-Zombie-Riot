#pragma semicolon 1
#pragma newdecls required

void AltExtra_Mecha_Loader_MapStart() {
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mecha Loader");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mecha_loader");
	strcopy(data.Icon, sizeof(data.Icon), "heavy");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Alt;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache() {
	PrecacheSound("weapons/rocket_blackbox_explode1.wav");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team) {
	return AltExtra_Mecha_Loader(vecPos, vecAng, team);
}

methodmap AltExtra_Mecha_Loader < AltExtra_Base {
	public void PlayExplosionSound() {
		EmitSoundToAll("weapons/rocket_blackbox_explode1.wav", this.index, SNDCHAN_STATIC);
	}
	
	public void PlayDeathSound() {
		EmitSoundToAll(g_RobotHeavy_DeathSounds[GetRandomInt(0, sizeof(g_RobotHeavy_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
	}
	
	public void PlayHurtSound() {
		if (this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_RobotHeavy_HurtSounds[GetRandomInt(0, sizeof(g_RobotHeavy_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
	}
	
	public void PlayIdleSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
		EmitSoundToAll(g_RobotHeavy_IdleSounds[GetRandomInt(0, sizeof(g_RobotHeavy_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
	}
	
	public void PlayIdleAlertSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		EmitSoundToAll(g_RobotHeavy_IdleAlertedSounds[GetRandomInt(0, sizeof(g_RobotHeavy_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
	}
	
	public AltExtra_Mecha_Loader(float vecPos[3], float vecAng[3], int team) {
		AltExtra_Mecha_Loader npc = view_as<AltExtra_Mecha_Loader>(CClotBody(vecPos, vecAng, "models/bots/heavy/bot_heavy.mdl", "1.0", "30000", team));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_flAttackHappens_bullshit = 0.0;
		
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCDeath[npc.index] = AltExtra_Mecha_Loader_NPCDeath;
		func_NPCThink[npc.index] = AltExtra_Mecha_Loader_ClotThink;
		
		npc.m_flSpeed = 240.0;
		npc.m_iState = 0;
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		npc.SetActivity("ACT_MP_RUN_MELEE");
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/player/items/heavy/heavy_wolf_helm.mdl");
		
		int skin = (team == TFTeam_Red) ? 0 : 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

static void AltExtra_Mecha_Loader_ClotThink(int iNPC) {
	AltExtra_Mecha_Loader npc = view_as<AltExtra_Mecha_Loader>(iNPC);
	
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
	
	if (npc.m_flGetClosestTargetTime < gameTime) {
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	int target = npc.m_iTarget;
	if (IsValidEnemy(npc.index, target)) {
		if (npc.m_flAttackHappenswillhappen) {
			if (npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime) {
				Handle swingTrace;
				if (npc.DoSwingTrace(swingTrace, target)) {
					int targetHit = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if (targetHit > 0) {
						float damage = 200.0;
						if (ShouldNpcDealBonusDamage(targetHit))
							damage *= 5.0;
						
						SDKHooks_TakeDamage(targetHit, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
						
						// Hit sound
						npc.PlayRobotHeavyMeleeHitSound();
					}
				}
				else {
					npc.PlayRobotHeavyMeleeMissSound();
				}
				delete swingTrace;
				
				npc.m_flAttackHappenswillhappen = false;
			}
			else if (npc.m_flAttackHappens_bullshit < gameTime) {
				npc.m_flAttackHappenswillhappen = false;
			}
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
		
		if (npc.m_flDoingAnimation > gameTime) {
			npc.m_iState = -1;
		}
		else if (flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED
				&& npc.m_flNextMeleeAttack < gameTime) {
			npc.m_iState = 1;
		}
		else {
			npc.m_iState = 0;
		}
		
		switch (npc.m_iState) {
			case -1:
			{
				return;
			}
			case 0:
			{
				npc.StartPathing();
			}
			case 1:
			{
				if (!npc.m_flAttackHappenswillhappen)
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					npc.PlayRobotHeavyMeleeAttackSound();
					npc.m_flAttackHappens = gameTime + 0.4;
					npc.m_flAttackHappens_bullshit = gameTime + 0.54;
					
					npc.m_flDoingAnimation = gameTime + 0.54;
					npc.m_flNextMeleeAttack = gameTime + 0.8;
					
					npc.m_flAttackHappenswillhappen = true;
				}
			}
		}
	}
	else {
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
}

static void AltExtra_Mecha_Loader_NPCDeath(int iNPC) {
	AltExtra_Mecha_Loader npc = view_as<AltExtra_Mecha_Loader>(iNPC);
	
	// Heavy goes boom on death. evil idea.
	float vecMe[3];
	WorldSpaceCenter(npc.index, vecMe);
	Explode_Logic_Custom(350.0, -1, npc.index, -1, vecMe, 200.0, _, 0.8, true);
	ParticleEffectAt(vecMe, "ExplosionCore_buildings", 0.5);
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	npc.m_bGib = true;
	
	npc.PlayDeathSound();
	npc.PlayExplosionSound();
}