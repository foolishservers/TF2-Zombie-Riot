#pragma semicolon 1
#pragma newdecls required

static const char g_MeleeHitSounds[][] = {
	"weapons/boxing_gloves_hit1.wav",
	"weapons/boxing_gloves_hit2.wav",
	"weapons/boxing_gloves_hit3.wav",
	"weapons/boxing_gloves_hit4.wav",
};

void AltExtra_Mecha_Dimension_Ripper_OnMapStart() {
	PrecacheModel("models/bots/soldier_boss/bot_soldier_boss.mdl");
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSound(")weapons/cow_mangler_over_charge.wav");
	PrecacheSound("misc/halloween/spell_teleport.wav");
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mecha Dimension Ripper");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mecha_dimension_ripper");
	strcopy(data.Icon, sizeof(data.Icon), "soldier_libertylauncher");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Alt;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team) {
	return AltExtra_Mecha_Dimension_Ripper(vecPos, vecAng, team);
}

methodmap AltExtra_Mecha_Dimension_Ripper < AltExtra_Base {	
	public void PlayIdleAlertSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		EmitSoundToAll(g_RobotSoldier_IdleAlertedSounds[GetRandomInt(0, sizeof(g_RobotSoldier_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayHurtSound() {
		if (this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_RobotSoldier_HurtSounds[GetRandomInt(0, sizeof(g_RobotSoldier_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayDeathSound() {
		EmitSoundToAll(g_RobotSoldier_DeathSounds[GetRandomInt(0, sizeof(g_RobotSoldier_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayChargeSound() {
		EmitSoundToAll(g_RobotSoldier_IdleSounds[GetRandomInt(0, sizeof(g_RobotSoldier_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlaySummonSound() {
		EmitSoundToAll("misc/halloween/spell_teleport.wav", this.index, SNDCHAN_AUTO, 100, _, 1.2);
	}
	
	property float m_flNextSummonTime {
		public get()			{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float value) { fl_AbilityOrAttack[this.index][0] = value; }
	}
	
	property float m_flSummonHappens {
		public get()			{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float value) { fl_AbilityOrAttack[this.index][1] = value; }
	}
	
	public AltExtra_Mecha_Dimension_Ripper(float vecPos[3], float vecAng[3], int ally) {
		AltExtra_Mecha_Dimension_Ripper npc = view_as<AltExtra_Mecha_Dimension_Ripper>(CClotBody(vecPos, vecAng, "models/bots/soldier_boss/bot_soldier_boss.mdl", "1.35", "200000", ally, false, true));
		
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		
		func_NPCDeath[npc.index] = AltExtra_Mecha_Dimension_Ripper_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = AltExtra_Mecha_Dimension_Ripper_ClotThink;
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextSummonTime = GetGameTime(npc.index) + 8.0;
		
		// IDLE
		npc.m_flSpeed = 240.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		npc.m_bThisNpcIsABoss = true;
		GiveNpcOutLineLastOrBoss(npc.index, true);
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/player/items/soldier/bucket.mdl");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_picket/c_picket.mdl");
		
		return npc;
	}
}

static void AltExtra_Mecha_Dimension_Ripper_ClotThink(int iNPC) {
	AltExtra_Mecha_Dimension_Ripper npc = view_as<AltExtra_Mecha_Dimension_Ripper>(iNPC);
	
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
	
	AltExtra_Mecha_Dimension_Ripper_SummonThink(npc, gameTime);
	
	int target = npc.m_iTarget;
	if (IsValidEnemy(npc.index, target)) {
		float vecTarget[3], vecMe[3];
		WorldSpaceCenter(target, vecTarget);
		WorldSpaceCenter(npc.index, vecMe);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
		
		// Predict their pos.
		if (flDistanceToTarget < npc.GetLeadRadius()) {
			float vecPredictedPos[3];
			PredictSubjectPosition(npc, target,_,_, vecPredictedPos);
			npc.SetGoalVector(vecPredictedPos);
		}
		else {
			npc.SetGoalEntity(target);
		}
		
		AltExtra_Mecha_Dimemsion_Ripper_SelfDefense(npc, gameTime, target, flDistanceToTarget);
	}
	else {
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

static void AltExtra_Mecha_Dimemsion_Ripper_SelfDefense(AltExtra_Mecha_Dimension_Ripper npc, float gameTime, int target, float distance) {
	if (npc.m_flAttackHappens && npc.m_flAttackHappens < gameTime) {
		npc.m_flAttackHappens = 0.0;
		
		float vecTarget[3];
		WorldSpaceCenter(target, vecTarget);
		npc.FaceTowards(vecTarget, 20000.0);
		
		Handle swingTrace;
		if (npc.DoSwingTrace(swingTrace, target, _, _, _, 1)) {
			int targetHit = TR_GetEntityIndex(swingTrace);	
			
			float vecHit[3];
			TR_GetEndPosition(vecHit, swingTrace);
			
			if (targetHit > 0) {
				float damage = 150.0;
				if (ShouldNpcDealBonusDamage(targetHit))
					damage *= 10.0;
				
				SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);	
				
				Custom_Knockback(npc.index, target, 750.0);
				
				// Hit sound
				npc.PlayMeleeHitSound();
			}
		}
		delete swingTrace;
	}
	
	if (npc.m_flAttackHappens_2 && npc.m_flAttackHappens_2 < gameTime) {
		npc.m_flAttackHappens_2 = 0.0;
		
		npc.PlayRocketLauncherShootSound();
		
		float vecTarget[3];
		WorldSpaceCenter(target, vecTarget);
		
		int projectile = npc.FireParticleRocket(vecTarget, 200.0, 600.0, 1.0, "raygun_projectile_blue_crit");
		if (IsValidEntity(projectile)) {
			float angles[3];
			GetEntPropVector(projectile, Prop_Send, "m_angRotation", angles);
			Initiate_HomingProjectile(projectile, npc.index, 120.0, 10.0, false, false, angles, -1);
			CreateTimer(2.5, AltExtra_Shared_RemoveHoming, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	
	// If we are doing animaion, don't do attacking
	if (npc.m_flDoingAnimation > gameTime)
		return;
	
	if (distance < 22500.0) {
		if (npc.m_flNextMeleeAttack < gameTime) {
			//Play attack ani
			npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
			npc.PlayRobotHeavyMeleeAttackSound();
			npc.m_flAttackHappens = gameTime + 0.54;
			npc.m_flNextMeleeAttack = gameTime + 0.8;
			npc.m_flDoingAnimation = gameTime + 0.8;
		}
	}
	else if (npc.m_flNextRangedAttack < gameTime) {
		npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
		npc.m_flAttackHappens_2 = gameTime + 0.54;
		npc.m_flNextRangedAttack = gameTime + 3.0;
		npc.m_flDoingAnimation = gameTime + 0.8;
	}
}

static void AltExtra_Mecha_Dimension_Ripper_SummonThink(AltExtra_Mecha_Dimension_Ripper npc, float gameTime) {
	if (npc.m_flSummonHappens && npc.m_flSummonHappens < gameTime) {
		npc.m_flSummonHappens = 0.0;
		AltExtra_Mecha_Dimension_Ripper_SummonAlly(npc, gameTime);
	}
	
	if (npc.m_flDoingAnimation > gameTime)
		return;
	
	if (!npc.m_flSummonHappens && npc.m_flNextSummonTime < gameTime) {
		npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY_SUPER");
		npc.PlayChargeSound();
		npc.m_flSummonHappens = gameTime + 2.2;
		npc.m_flDoingAnimation = gameTime + 2.6;
	}
}

static void AltExtra_Mecha_Dimension_Ripper_SummonAlly(AltExtra_Mecha_Dimension_Ripper npc, float gameTime) {
	npc.m_flNextSummonTime = gameTime + 16.0;
	
	if (MaxEnemiesAllowedSpawnNext(1) <= (EnemyNpcAlive - EnemyNpcAliveStatic)) {
		// grrr i cant spawn!!!!
		// try this later.
		npc.m_flNextSummonTime = gameTime + 4.0;
		return;
	}
	
	float pos[3], ang[3];
	WorldSpaceCenter(npc.index, pos);
	ParticleEffectAt(pos, "teleported_blue", 1.5);
	
	npc.PlaySummonSound();
	
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
	
	char npcName[128];
	switch (GetRandomInt(0, 2)) {
		case 0: {
			npcName = "npc_alt_extra_mecha_loader";
		}
		case 1: {
			npcName = "npc_alt_extra_mecha_duelist";
		}
		case 2: {
			npcName = "npc_alt_extra_mecha_heavy_particle_rifle";
		}
	}
	
	if (!npcName[0])
		return;
	
	int team = GetTeam(npc.index);
	int maxhealth = ReturnEntityMaxHealth(npc.index) / 7;
	
	int entity = NPC_CreateByName(npcName, -1, pos, ang, team);
	if (entity > MaxClients) {
		NpcStats_CopyStats(npc.index, entity);
		NpcAddedToZombiesLeftCurrently(entity, true);
		SetEntProp(entity, Prop_Data, "m_iHealth", maxhealth);
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", maxhealth);
	}
}

static void AltExtra_Mecha_Dimension_Ripper_NPCDeath(int entity) {
	AltExtra_Mecha_Dimension_Ripper npc = view_as<AltExtra_Mecha_Dimension_Ripper>(entity);
	if (!npc.m_bGib) {
		npc.PlayDeathSound();	
	}
	
	if (IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if (IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}