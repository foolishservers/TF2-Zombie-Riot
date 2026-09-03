#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[] = "mvm/giant_soldier/giant_soldier_explode.wav";
static const char g_RangedAttackSounds[] = "mvm/giant_soldier/giant_soldier_rocket_shoot.wav";

void AltExtra_Mecha_Base_Destroyer_MapStart() {
	PrecacheSound(g_DeathSounds);
	PrecacheSound(g_RangedAttackSounds);
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mecha Base Destroyer Buff");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mecha_base_destroyer_buff");
	strcopy(data.Icon, sizeof(data.Icon), "soldier_buff");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Alt;
	data.Func = ClotSummon_Buff;
	NPC_Add(data);
	
	strcopy(data.Name, sizeof(data.Name), "Mecha Base Destroyer Backup");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mecha_base_destroyer_backup");
	strcopy(data.Icon, sizeof(data.Icon), "soldier_backup");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Alt;
	data.Func = ClotSummon_Backup;
	NPC_Add(data);
	
	strcopy(data.Name, sizeof(data.Name), "Mecha Base Destroyer Conch");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mecha_base_destroyer_conch");
	strcopy(data.Icon, sizeof(data.Icon), "soldier_conch");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Alt;
	data.Func = ClotSummon_Conch;
	NPC_Add(data);
}

static any ClotSummon_Buff(int client, float vecPos[3], float vecAng[3], int team, const char[] data) {
	return AltExtra_Mecha_Base_Destroyer(vecPos, vecAng, team, data, 0);
}

static any ClotSummon_Backup(int client, float vecPos[3], float vecAng[3], int team, const char[] data) {
	return AltExtra_Mecha_Base_Destroyer(vecPos, vecAng, team, data, 1);
}

static any ClotSummon_Conch(int client, float vecPos[3], float vecAng[3], int team, const char[] data) {
	return AltExtra_Mecha_Base_Destroyer(vecPos, vecAng, team, data, 2);
}

methodmap AltExtra_Mecha_Base_Destroyer < AltExtra_Base {
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds, this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayHurtSound() {
		EmitSoundToAll(g_RobotSoldier_Giant_HurtSounds[GetRandomInt(0, sizeof(g_RobotSoldier_Giant_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds, this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void ReloadSingly() {
		switch (this.m_iReloadState) {
			case 0: {	// TF_RELOAD_START
				this.m_bIsFirstReload = true;
				
				this.m_iReloadState = 1;
			}
			case 1: {	// TF_RELOADING
				float gameTime = GetGameTime(this.index);
				
				if (this.m_bIsFirstReload) {
					this.m_bIsFirstReload = false;
					this.m_flReloadDelay = gameTime + 0.92;
					this.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY");
				}
				else {
					this.m_flReloadDelay = gameTime + 0.8;
					this.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY_LOOP");
				}
				
				this.m_iReloadState = 2;
			}
			case 2: {	// TF_RELOAD_CONTINUE
				this.m_iAmmo++;
				
				if (this.m_iAmmo == this.m_iMaxAmmo) {
					this.m_iReloadState = 3;
				}
				else {
					this.m_iReloadState = 1;
				}
			}
			case 3: {	// TF_RELOAD_END
				// Gives time.
				this.m_flNextRangedAttack = GetGameTime(this.index) + 0.6;
				this.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY_END");
				
				this.m_bReloaded = true;
				this.m_iReloadState = 0;
			}
		}
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
	
	property int m_iBuffType {
		public get()			{ return this.m_iMedkitAnnoyance; }
		public set(int value)	{ this.m_iMedkitAnnoyance = value; }
	}
	
	property int m_iReloadState {
		public get()			{ return this.m_iOverlordComboAttack; }
		public set(int value)	{ this.m_iOverlordComboAttack = value; }
	}
	
	property bool m_bIsFirstReload {
		public get()			{ return this.m_bFUCKYOU; }
		public set(bool value)	{ this.m_bFUCKYOU = value; }
	}
	
	public AltExtra_Mecha_Base_Destroyer(float vecPos[3], float vecAng[3], int team, const char[] data, int buffType) {
		AltExtra_Mecha_Base_Destroyer npc = view_as<AltExtra_Mecha_Base_Destroyer>(CClotBody(vecPos, vecAng, "models/bots/soldier_boss/bot_soldier_boss.mdl", "1.6", "300000", team, _, true));
		
		i_NpcWeight[npc.index] = 4;
		npc.SetActivity("ACT_MP_RUN_PRIMARY");
		
		KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_PANZER;
		
		func_NPCDeath[npc.index] = AltExtra_Mecha_Base_Destroyer_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = AltExtra_Mecha_Base_Destroyer_ClotThink;
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		
		npc.m_iAmmo = 4;
		npc.m_iMaxAmmo = 4;
		npc.m_bReloaded = true;
		npc.m_bIsFirstReload = false;
		
		npc.m_flSpeed = 140.0;
		npc.StartPathing();
		
		npc.m_iState = 0;
		if (StrContains(data, "opti") != -1) {
			npc.m_iState = 1;
		}
		
		int skin = team == TFTeam_Red ? 0 : 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.index, 125, 100, 100, 255);
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/w_models/w_rocketlauncher.mdl");
		
		npc.m_iBuffType = buffType;
		switch (npc.m_iBuffType) {
			case 1: {
				npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_battalion_buffpack/c_battalion_buffpack.mdl");
				
				npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_battalion_buffbanner/c_battalion_buffbanner.mdl");
				
				npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/soldier/sum20_breach_and_bomb/sum20_breach_and_bomb.mdl");
			}
			case 2: {
				npc.m_iWearable2 = npc.EquipItem("head", "models/workshop_partner/weapons/c_models/c_shogun_warpack/c_shogun_warpack.mdl");
				
				npc.m_iWearable3 = npc.EquipItem("head", "models/workshop_partner/weapons/c_models/c_shogun_warbanner/c_shogun_warbanner.mdl");
				
				npc.m_iWearable4 = npc.EquipItem("head", "models/player/items/soldier/soldier_samurai.mdl");
				SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
				SetEntityRenderColor(npc.m_iWearable4, 125, 100, 100, 255);
			}
			default: {
				npc.m_iBuffType = 0;
				
				npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_buffpack/c_buffpack.mdl");
				
				npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_buffbanner/c_buffbanner.mdl");
			}
		}
		
		return npc;
	}
}

static void AltExtra_Mecha_Base_Destroyer_ClotThink(int iNPC) {
	AltExtra_Mecha_Base_Destroyer npc = view_as<AltExtra_Mecha_Base_Destroyer>(iNPC);
	
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
	
	float vecOrigin[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", vecOrigin);
	
	float range = 250.0;
	AltExtra_Mecha_Base_Destroyer_ApplyBuffInLocation(npc, vecOrigin, GetTeam(npc.index), range);
	
	if (!npc.m_bReloaded) {
		if (npc.m_flReloadDelay < gameTime)
			npc.ReloadSingly();
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
		
		if (npc.m_bReloaded) {
			AltExtra_Mecha_Base_Destroyer_SelfDefense(npc, gameTime, target, flDistanceToTarget);
		}
	}
	else {
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
}

static void AltExtra_Mecha_Base_Destroyer_SelfDefense(AltExtra_Mecha_Base_Destroyer npc, float gameTime, int target, float distance) {
	if (npc.m_flNextRangedAttack < gameTime) {
		if (!Can_I_See_Enemy_Only(npc.index, target)) {
			npc.m_flNextRangedAttack = gameTime + 0.1;
			return;
		}
		
		float origin[3];
		view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, NULL_VECTOR);
		
		// If too closed, don't check about target in cone.
		if (distance > NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && !npc.IsTargetInFiringCone(target)) {
			npc.m_flNextRangedAttack = gameTime + 0.1;
			return;
		}
		
		npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
		npc.PlayRangedSound();
		
		float projectileSpeed = 900.0;
		
		float vecTarget[3], vecAngles[3], vecForward[3];
		PredictSubjectPositionForProjectiles(npc, target, projectileSpeed, _, vecTarget);
		
		MakeVectorFromPoints(origin, vecTarget, vecAngles);
		GetVectorAngles(vecAngles, vecAngles);
		
		vecForward[0] = Cosine(DegToRad(vecAngles[0])) * Cosine(DegToRad(vecAngles[1])) * projectileSpeed;
		vecForward[1] = Cosine(DegToRad(vecAngles[0])) * Sine(DegToRad(vecAngles[1])) * projectileSpeed;
		vecForward[2] = Sine(DegToRad(vecAngles[0])) * -projectileSpeed;
		
		int projectile = npc.FireRocket(vecTarget, 200.0, projectileSpeed);
		if (projectile > -1) {
			TeleportEntity(projectile, origin, vecAngles, vecForward, true);
		}
		
		npc.m_iAmmo--;
		
		if (npc.m_iAmmo < 1) {
			npc.m_iAmmo = 0;
			npc.m_bReloaded = false;
			npc.m_flReloadDelay = gameTime + 0.8;
		}
		else {
			npc.m_flNextRangedAttack = gameTime + 0.8;
		}
	}
}

static void AltExtra_Mecha_Base_Destroyer_NPCDeath(int entity) {
	AltExtra_Mecha_Base_Destroyer npc = view_as<AltExtra_Mecha_Base_Destroyer>(entity);
	
	npc.PlayDeathSound();
	
	npc.m_bGib = true;
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
}

static void AltExtra_Mecha_Base_Destroyer_ApplyBuffInLocation(AltExtra_Mecha_Base_Destroyer npc, float pos[3], int team, float range) {
	char buffName[32] = "War Cry";
	int color[4] = { 200, 200, 50, 200 };
	switch (npc.m_iBuffType) {
		case 1: {
			buffName = "Defensive Backup";
			color = { 50, 50, 200, 200 };
		}
		case 2: {
			buffName = "Ancient Melodies";
			color = { 50, 200, 200, 200 };
		}
	}
	
	if (!buffName[0])
		return;
	
	if (!npc.m_iState)
		spawnRing_Vectors(pos, range * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", color[0], color[1], color[2], color[3], 1, /*duration*/ 0.11, 10.0, 2.0, 1);
	
	float targetPos[3];
	for (int target = 1; target <= MaxClients; target++) {
		if (IsClientInGame(target) && IsPlayerAlive(target) && GetTeam(target) == team) {
			GetClientAbsOrigin(target, targetPos);
			if (GetVectorDistance(pos, targetPos, true) <= (range * range)) {
				ApplyStatusEffect(target, target, buffName, 1.0);
			}
		}
	}
	
	for (int entitycount_again; entitycount_again < i_MaxcountNpcTotal; entitycount_again++) {
		int target = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount_again]);
		if (IsValidEntity(target) && !b_NpcHasDied[target] && GetTeam(target) == team) {
			GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", targetPos);
			if (GetVectorDistance(pos, targetPos, true) <= (range * range)) {
				ApplyStatusEffect(target, target, buffName, 1.0);
			}
		}
	}
}