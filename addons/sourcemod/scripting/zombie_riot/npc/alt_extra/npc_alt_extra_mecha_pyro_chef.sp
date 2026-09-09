#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/mvm/mght/pyro_mvm_m_paincrticialdeath01.mp3",
	"vo/mvm/mght/pyro_mvm_m_paincrticialdeath02.mp3",
	"vo/mvm/mght/pyro_mvm_m_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/mvm/mght/pyro_mvm_m_painsharp01.mp3",
	"vo/mvm/mght/pyro_mvm_m_painsharp02.mp3",
	"vo/mvm/mght/pyro_mvm_m_painsharp03.mp3",
	"vo/mvm/mght/pyro_mvm_m_painsharp04.mp3",
	"vo/mvm/mght/pyro_mvm_m_painsharp05.mp3",
};

static const char g_IdleSounds[][] = {
	"vo/mvm/mght/pyro_mvm_m_jeers01.mp3",	
	"vo/mvm/mght/pyro_mvm_m_jeers02.mp3",	
};

static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/mght/taunts/pyro_mvm_m_taunts01.mp3",
	"vo/mvm/mght/taunts/pyro_mvm_m_taunts02.mp3",
	"vo/mvm/mght/taunts/pyro_mvm_m_taunts03.mp3",
};

// TODO: 체력 잃을수록 속도 증가

void AltExtra_Mecha_Pyro_Chef_OnMapStart() {
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);

	PrecacheSound("weapons/flame_thrower_loop.wav");
	PrecacheSound("weapons/flame_thrower_pilot.wav");
	
	PrecacheModel("models/bots/pyro_boss/bot_pyro_boss.mdl");
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mecha Pyro Chef");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mecha_pyro_chef");
	strcopy(data.Icon, sizeof(data.Icon), "pyro");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Alt;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data) {
	return AltExtra_Mecha_Pyro_Chef(vecPos, vecAng, team);
}

methodmap AltExtra_Mecha_Pyro_Chef < AltExtra_Base {
	property int m_iGunMode {
		public get()			{ return i_TimesSummoned[this.index]; }
		public set(int value) 	{ i_TimesSummoned[this.index] = value; }
	}
	
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
	
	public void PlayMinigunSound(bool shooting) {
		if (shooting) {
			if (this.m_iGunMode != 0) {
				StopSound(this.index, SNDCHAN_STATIC, "weapons/flame_thrower_pilot.wav");
				EmitSoundToAll("weapons/flame_thrower_loop.wav", this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, 0.70);
			}
			
			this.m_iGunMode = 0;
		}
		else {
			if (this.m_iGunMode != 1) {
				StopSound(this.index, SNDCHAN_STATIC, "weapons/flame_thrower_loop.wav");
				EmitSoundToAll("weapons/flame_thrower_pilot.wav", this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, 0.70);
			}
			this.m_iGunMode = 1;
		}
	}
	
	public AltExtra_Mecha_Pyro_Chef(float vecPos[3], float vecAng[3], int team) {
		AltExtra_Mecha_Pyro_Chef npc = view_as<AltExtra_Mecha_Pyro_Chef>(CClotBody(vecPos, vecAng, "models/bots/pyro_boss/bot_pyro_boss.mdl", "1.5", "300000", team, false, true));
		
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if (iActivity > 0)
			npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		
		func_NPCDeath[npc.index] = AltExtra_Mecha_Pyro_Chef_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = AltExtra_Mecha_Pyro_Chef_OnTakeDamage;
		func_NPCThink[npc.index] = AltExtra_Mecha_Pyro_Chef_ClotThink;
		
		npc.Anger = false;
		npc.m_flSpeed = 160.0;
		npc.StartPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		
		int skin = (team == TFTeam_Red) ? 0 : 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_flamethrower/c_flamethrower.mdl");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/pyro/pyro_chef_hat.mdl");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/pyro/sf14_the_creatures_grin/sf14_the_creatures_grin.mdl");
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/hwn2020_eye_see_you/hwn2020_eye_see_you_pyro.mdl");
		
		return npc;
	}
}

static void AltExtra_Mecha_Pyro_Chef_ClotThink(int iNPC) {
	AltExtra_Mecha_Pyro_Chef npc = view_as<AltExtra_Mecha_Pyro_Chef>(iNPC);

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
		float vecTarget[3], vecMe[3];
		WorldSpaceCenter(npc.m_iTarget, vecTarget);
		WorldSpaceCenter(npc.index, vecMe);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
		
		bool SpinSound = true;
		int SetGoalVectorIndex = AltExtra_Mecha_Pyro_Chef_SelfDefense(npc, SpinSound);
		
		if (SpinSound)
			npc.PlayMinigunSound(false);
		
		switch (SetGoalVectorIndex) {
			case 0: {
				npc.m_bAllowBackWalking = false;
				
				//Get the normal prediction code.
				if (flDistanceToTarget < npc.GetLeadRadius()) {
					float vecPredictedPos[3];
					PredictSubjectPosition(npc, target, _, _, vecPredictedPos);
					npc.SetGoalVector(vecPredictedPos);
				}
				else {
					npc.SetGoalEntity(target);
				}
			}
			case 1: {
				npc.m_bAllowBackWalking = true;
				
				float vecBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, target, _, vecBackoffPos);
				npc.SetGoalVector(vecBackoffPos, true); //update more often, we need it
			}
		}
	}
	else {
		npc.PlayMinigunSound(false);
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	npc.PlayIdleAlertSound();
}

static Action AltExtra_Mecha_Pyro_Chef_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	AltExtra_Mecha_Pyro_Chef npc = view_as<AltExtra_Mecha_Pyro_Chef>(victim);
		
	if (attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index)) {
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	if (npc.Anger)
		return Plugin_Continue;
	
	float percentageHealthLeft = float(GetEntProp(npc.index, Prop_Data, "m_iHealth")) / float(ReturnEntityMaxHealth(npc.index));
	if (percentageHealthLeft <= 0.2) {
		npc.Anger = true;
		npc.m_flSpeed = 280.0;
	}
	else if(percentageHealthLeft <= 0.4) {
		npc.m_flSpeed = 240.0;
	}
	else if(percentageHealthLeft <= 0.6) {
		npc.m_flSpeed = 200.0;
	}
	else if(percentageHealthLeft <= 0.8) {
		npc.m_flSpeed = 180.0;
	}
	
	return Plugin_Continue;
}

static void AltExtra_Mecha_Pyro_Chef_NPCDeath(int entity) {
	AltExtra_Mecha_Pyro_Chef npc = view_as<AltExtra_Mecha_Pyro_Chef>(entity);
	
	if (!npc.m_bGib)
		npc.PlayDeathSound();
	
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/flame_thrower_loop.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/flame_thrower_pilot.wav");
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
}

static int AltExtra_Mecha_Pyro_Chef_SelfDefense(AltExtra_Mecha_Pyro_Chef npc, bool &SpinSound) {
	int target = npc.m_iTarget;
	
	// some Ranged units will behave differently.
	// not this one.
	float vecTarget[3], vecMe[3];
	WorldSpaceCenter(npc.m_iTarget, vecTarget);
	WorldSpaceCenter(npc.index, vecMe);
	
	float distance = GetVectorDistance(vecTarget, vecMe, true);
	
	if (distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0)) {
		int seenTarget = Can_I_See_Enemy(npc.index, npc.m_iTarget);
		if (IsValidEnemy(npc.index, seenTarget)) {
			npc.PlayMinigunSound(true);
			SpinSound = false;
			npc.FaceTowards(vecTarget, 20000.0);
			float projectileSpeed = 1000.0;
			
			int projectile = npc.FireParticleRocket(vecTarget, 30.0, projectileSpeed, 150.0, "superrare_burning1", true);
			
			SDKUnhook(projectile, SDKHook_StartTouch, Rocket_Particle_StartTouch);
			
			int particle = EntRefToEntIndex(i_WandParticle[projectile]);
			CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
			
			WandProjectile_ApplyFunctionToEntity(projectile, AltExtra_Mecha_Pyro_Chef_Projectile_StartTouch);
		}
	}
	
	if (distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.5)) {
		//target is too far, try to close in
		return 0;
	}
	else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.5)) {
		if (Can_I_See_Enemy_Only(npc.index, target)) {
			//target is too close, try to keep distance
			return 1;
		}
	}
	
	return 0;
}

static void AltExtra_Mecha_Pyro_Chef_Projectile_StartTouch(int entity, int target) {
	if (target > 0 && target < MAXENTITIES) {
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if (!IsValidEntity(owner))
			owner = 0;
		
		int inflictor = h_ArrowInflictorRef[entity];
		if (inflictor != -1)
			inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);
		
		if (inflictor == -1)
			inflictor = owner;
		
		float damage = fl_rocket_particle_dmg[entity];
		if (ShouldNpcDealBonusDamage(target)) {
			damage *= h_BonusDmgToSpecialArrow[entity];
			damage *= 10.0;
		}
		
		// acts like a kinetic rocket
		SDKHooks_TakeDamage(target, owner, inflictor, damage, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, -1);
		
		NPC_Ignite(target, owner, 12.0, -1, 8.0);
	}
	
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	if (IsValidEntity(particle))
		RemoveEntity(particle);
	
	RemoveEntity(entity);
}