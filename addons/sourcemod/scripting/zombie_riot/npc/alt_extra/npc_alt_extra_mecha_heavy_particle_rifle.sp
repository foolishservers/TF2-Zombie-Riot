#pragma semicolon 1
#pragma newdecls required

/*
	How it works (Sorry to bad english):
	Simillar to rifal manu. But this one has long range.
	
	Fire heavy particle rifle projectile. damage will be increased by consuming ammo.
	If out of ammo, damage will be reset and process reload.
*/

static const char g_HeavyParticle_ShootSound[] = "weapons/sniper_rifle_classic_shoot.wav";

void AltExtra_Mecha_HeavyParticleRifle_MapStart() {
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mecha Heavy Particle Rifle");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mecha_heavy_particle_rifle");
	strcopy(data.Icon, sizeof(data.Icon), "medic");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Alt;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache() {
	PrecacheSound("weapons/sentry_wire_connect.wav");
	PrecacheSound("weapons/sentry_upgrading_steam1.wav");
	PrecacheSound("ambient/energy/weld1.wav");
	PrecacheSound(g_HeavyParticle_ShootSound);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team) {
	return AltExtra_Mecha_HeavyParticleRifle(vecPos, vecAng, team);
}

methodmap AltExtra_Mecha_HeavyParticleRifle < AltExtra_Base {
	public void PlayDeathSound() {
		EmitSoundToAll(g_RobotMedic_DeathSounds[GetRandomInt(0, sizeof(g_RobotMedic_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
	}
	
	public void PlayHurtSound() {
		if (this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_RobotMedic_HurtSounds[GetRandomInt(0, sizeof(g_RobotMedic_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
	}
	
	public void PlayIdleSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
		EmitSoundToAll(g_RobotMedic_IdleSounds[GetRandomInt(0, sizeof(g_RobotMedic_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
	}
	
	public void PlayIdleAlertSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		EmitSoundToAll(g_RobotMedic_IdleAlertedSounds[GetRandomInt(0, sizeof(g_RobotMedic_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_HeavyParticle_ShootSound, this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
		EmitSoundToAll("ambient/energy/weld1.wav", this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
	}
	
	public void PlayFullPowerSound() {
		EmitSoundToAll("weapons/sentry_upgrading_steam1.wav", this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
	}
	
	public void PlayBeginReactorSound() {
		EmitSoundToAll("weapons/sentry_wire_connect.wav", this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
	}
	
	property bool m_bReachedFullPower {
		public get()			{ return this.m_bFUCKYOU; }
		public set(bool value)	{ this.m_bFUCKYOU = value; }
	}
	
	property float m_flReactorExpireTime {
		public get()			{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float value) { fl_AbilityOrAttack[this.index][0] = value; }
	}
	
	property int m_iReactorCombo {
		public get()			{ return this.m_iOverlordComboAttack; }
		public set(int value) 	{ this.m_iOverlordComboAttack = value; }
	}
	
	public bool IsTargetInFiringCone(int target, float maxAngle = 20.0)
	{
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
	
	public AltExtra_Mecha_HeavyParticleRifle(float vecPos[3], float vecAng[3], int team) {
		AltExtra_Mecha_HeavyParticleRifle npc = view_as<AltExtra_Mecha_HeavyParticleRifle>(CClotBody(vecPos, vecAng, "models/bots/medic/bot_medic.mdl", "1.0", "20000", team));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flReloadDelay = 0.0;
		
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCDeath[npc.index] = AltExtra_Mecha_HeavyParticleRifle_NPCDeath;
		func_NPCThink[npc.index] = AltExtra_Mecha_HeavyParticleRifle_ClotThink;
		
		npc.m_flSpeed = 250.0;
		npc.m_iState = 0;
		npc.m_iAmmo = 20;
		npc.m_iMaxAmmo = 20;
		npc.m_flReactorExpireTime = 0.0;
		npc.m_iReactorCombo = 0;
		npc.m_bReachedFullPower = false;
		
		npc.SetActivity("ACT_MP_RUN_PRIMARY");
		npc.m_bisWalking = true;
		npc.m_iChanged_WalkCycle = 1;
		npc.m_flGetClosestTargetTime = 0.0;
		
		npc.StartPathing();
		
		int skin = (team == TFTeam_Red) ? 0 : 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_drg_pomson/c_drg_pomson.mdl", _, skin);
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/hwn2021_optic_nerve/hwn2021_optic_nerve.mdl");
		
		return npc;
	}
}

static void AltExtra_Mecha_HeavyParticleRifle_ClotThink(int iNPC) {
	AltExtra_Mecha_HeavyParticleRifle npc = view_as<AltExtra_Mecha_HeavyParticleRifle>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if (npc.m_flNextDelayTime > gameTime) {
		return;
	}
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if (npc.m_blPlayHurtAnimation) {
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		// npc.PlayHurtSound();
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
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecMe[3], vecTarget[3];
		WorldSpaceCenter(npc.index, vecMe);
		WorldSpaceCenter(target, vecTarget);
		
		npc.ModifyBodyPitch(vecMe, vecTarget);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
		
		switch (AltExtra_Mecha_HeavyParticleRifle_SelfDefense(npc, gameTime, target, flDistanceToTarget)) {
			case 0:
			{
				npc.m_bAllowBackWalking = false;
				if (flDistanceToTarget < npc.GetLeadRadius()) {
					float vecPredictedPos[3];
					PredictSubjectPosition(npc, target, _, _, vecPredictedPos);
					npc.SetGoalVector(vecPredictedPos);
				}
				else {
					npc.SetGoalEntity(target);
				}
			}
			case 1:
			{
				npc.m_bAllowBackWalking = true;
				float vecBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget, _, vecBackoffPos);
				npc.SetGoalVector(vecBackoffPos, true);
			}
		}
	}
	else
	{
		if (npc.m_iChanged_WalkCycle != 1) {
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 1;
			npc.SetActivity("ACT_MP_RUN_PRIMARY");
			npc.m_flSpeed = 250.0;
			npc.StartPathing();
		}
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	npc.PlayIdleAlertSound();
}

static void AltExtra_Mecha_HeavyParticleRifle_NPCDeath(int iNPC)
{
	AltExtra_Mecha_HeavyParticleRifle npc = view_as<AltExtra_Mecha_HeavyParticleRifle>(iNPC);
	if (!npc.m_bGib)
		npc.PlayDeathSound();
	
	if (IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if (IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}

static int AltExtra_Mecha_HeavyParticleRifle_SelfDefense(AltExtra_Mecha_HeavyParticleRifle npc, float gameTime, int target, float distance) {
	// 750.0 * 750.0 = 562500.0
	// gives long range to avoid this critical projectile barrage.
	if (distance < 562500.0) {
		int seenTarget = Can_I_See_Enemy(npc.index, target);
		if (IsValidEnemy(npc.index, seenTarget)) {
			float vecTarget[3];
			WorldSpaceCenter(seenTarget, vecTarget);
			npc.FaceTowards(vecTarget, 750.0);
			
			// We can't see the target. Move!
			if (!npc.IsTargetInFiringCone(seenTarget)) {
				if (npc.m_iChanged_WalkCycle != 1) {
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
					npc.m_flSpeed = 250.0;
					npc.StartPathing();
				}
			}
			else {
				if (npc.m_iChanged_WalkCycle != 2)
				{
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 2;
					npc.SetActivity("ACT_MP_STAND_PRIMARY");
					npc.m_flSpeed = 0.0;
					npc.StopPathing();
				}
				
				if (npc.m_flReloadDelay < gameTime
					&& gameTime > npc.m_flNextRangedAttack) {
					npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY", false);
					npc.PlayRangedSound();
					
					if (!npc.m_iReactorCombo || npc.m_flReactorExpireTime < gameTime) {
						npc.m_iReactorCombo = 0;
						npc.PlayBeginReactorSound();
					}
					
					float origin[3], angles[3], fwd[3], vecEnd[3];
					view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
					GetAngleVectors(angles, fwd, NULL_VECTOR, NULL_VECTOR);
					
					NormalizeVector(fwd, fwd);
					ScaleVector(fwd, 100.0);
					
					vecEnd = origin;
					AddVectors(vecEnd, fwd, vecEnd);
					
					// Evil moment.
					float damage = 160.0;
					float damageBonus = 1.0;
					if (npc.m_iReactorCombo >= 16) {
						if (!npc.m_bReachedFullPower) {
							npc.m_bReachedFullPower = true;
							npc.PlayFullPowerSound();
						}
						
						damageBonus = 3.0;
					}
					else if (npc.m_iReactorCombo >= 12) {
						damageBonus = 2.5;
					}
					else if (npc.m_iReactorCombo >= 8) {
						damageBonus = 2.0;
					}
					else if (npc.m_iReactorCombo >= 4) {
						damageBonus = 1.5;
					}
					
					damage *= damageBonus;
					
					// Dealing less damage agianst building.
					npc.FireParticleRocket(vecEnd, damage, 1000.0, 1.0, "unusual_genplasmos_b_parent", _, _, true, origin, .bonusdmg = 0.5);
					
					float fireDelay = (0.3 / damageBonus);
					if (fireDelay < 0.1)
						fireDelay = 0.1;
					npc.m_flNextRangedAttack = gameTime + fireDelay;
					
					npc.m_flReactorExpireTime = gameTime + 0.5;
					npc.m_iReactorCombo++;
					
					npc.m_iAmmo--;
					if (npc.m_iAmmo <= 0) {
						npc.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY", false);
						npc.m_iAmmo = npc.m_iMaxAmmo;
						npc.m_flReloadDelay = gameTime + 1.5;
						
						npc.m_bReachedFullPower = false;
						npc.m_flReactorExpireTime = 0.0;
						npc.m_iReactorCombo = 0;
					}
				}
			}
		}
		else {
			if (npc.m_iChanged_WalkCycle != 1) {
				npc.m_bisWalking = true;
				npc.m_iChanged_WalkCycle = 1;
				npc.SetActivity("ACT_MP_RUN_PRIMARY");
				npc.m_flSpeed = 250.0;
				npc.StartPathing();
			}
		}
	}
	
	if (distance > 562500.0) {
		//target is too far, try to close in
		if (npc.m_iChanged_WalkCycle != 1) {
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 1;
			npc.SetActivity("ACT_MP_RUN_PRIMARY");
			npc.m_flSpeed = 250.0;
			npc.StartPathing();
		}
		
		return 0;
	}
	else if (distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED) {
		if (Can_I_See_Enemy_Only(npc.index, target)) {
			//target is too close, try to keep distance
			if (npc.m_iChanged_WalkCycle != 1) {
				npc.m_bisWalking = true;
				npc.m_iChanged_WalkCycle = 1;
				npc.SetActivity("ACT_MP_RUN_PRIMARY");
				npc.m_flSpeed = 250.0;
				npc.StartPathing();
			}
			
			return 1;
		}
	}
	
	//Chase target. let previous choice
	return 0;
}