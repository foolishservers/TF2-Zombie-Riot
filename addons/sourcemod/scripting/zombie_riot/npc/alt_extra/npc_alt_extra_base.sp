#pragma semicolon 1
#pragma newdecls required

#define ALT_EXTRA_BODY_YAW_UNTWIST_SPEED   60.0   // 큰 각도일 때 트위스트를 0으로 풀어주는 속도 (도/초)
#define ALT_EXTRA_BODY_YAW_TRACK_SPEED     120.0  // 작은 각도일 때 relativeYaw를 따라가는 속도 (도/초)
#define ALT_EXTRA_BODY_PITCH_TRACK_SPEED   90.0   // pitch가 타겟 방향을 따라가는 속도 (도/초)

static const char g_RobotHeavy_MeleeHitSounds[][] = {
	"weapons/metal_gloves_hit_flesh1.wav",
	"weapons/metal_gloves_hit_flesh2.wav",
	"weapons/metal_gloves_hit_flesh3.wav",
	"weapons/metal_gloves_hit_flesh4.wav",
};

static const char g_RobotHeavy_MeleeAttackSounds[][] = {
	"weapons/boxing_gloves_swing1.wav",
	"weapons/boxing_gloves_swing2.wav",
	"weapons/boxing_gloves_swing4.wav",
};

static const char g_RobotHeavy_MeleeMissSounds[][] = {
	"weapons/bat_draw_swoosh1.wav",
	"weapons/bat_draw_swoosh2.wav",
};

static const char g_RocketLaucher_ShootSounds[] = ")weapons/rocket_shoot.wav";

static const char g_ExpidonsanSword_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};

static const char g_ExpidonsanSword_MeleeHitSounds[][] = {
	"weapons/neon_sign_hit_01.wav",
	"weapons/neon_sign_hit_02.wav",
	"weapons/neon_sign_hit_03.wav",
	"weapons/neon_sign_hit_04.wav"
};

static const char g_DemoSword_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};

static const char g_DemoSword_MeleeHitSounds[][] = {
	"weapons/blade_slice_2.wav",
	"weapons/blade_slice_3.wav",
	"weapons/blade_slice_4.wav",
};

void AltExtra_Base_MapStart()
{
	PrecacheModel("models/bots/heavy/bot_heavy.mdl");
	
	PrecacheSoundArray(g_RobotHeavy_DeathSounds);
	PrecacheSoundArray(g_RobotHeavy_HurtSounds);
	PrecacheSoundArray(g_RobotHeavy_IdleSounds);
	PrecacheSoundArray(g_RobotHeavy_IdleAlertedSounds);
	PrecacheSoundArray(g_RobotHeavy_MeleeHitSounds);
	PrecacheSoundArray(g_RobotHeavy_MeleeAttackSounds);
	PrecacheSoundArray(g_RobotHeavy_MeleeMissSounds);
	
	PrecacheSoundArray(g_RobotMedic_DeathSounds);
	PrecacheSoundArray(g_RobotMedic_HurtSounds);
	PrecacheSoundArray(g_RobotMedic_IdleSounds);
	PrecacheSoundArray(g_RobotMedic_IdleAlertedSounds);
	PrecacheSoundArray(g_RobotMedic_RageSounds);
	
	PrecacheSoundArray(g_RobotSoldier_DeathSounds);
	PrecacheSoundArray(g_RobotSoldier_HurtSounds);
	PrecacheSoundArray(g_RobotSoldier_IdleSounds);
	PrecacheSoundArray(g_RobotSoldier_IdleAlertedSounds);
	
	PrecacheSoundArray(g_RobotSoldier_Giant_HurtSounds);
	
	PrecacheSoundArray(g_RobotDemo_DeathSounds);
	PrecacheSoundArray(g_RobotDemo_HurtSounds);
	PrecacheSoundArray(g_RobotDemo_IdleAlertedSounds);
	PrecacheSoundArray(g_RobotDemo_AngerSounds);
	PrecacheSoundArray(g_RobotDemo_LaughSounds);
	
	PrecacheSound(g_RocketLaucher_ShootSounds);
	
	PrecacheSoundArray(g_ExpidonsanSword_MeleeAttackSounds);
	PrecacheSoundArray(g_ExpidonsanSword_MeleeHitSounds);
	
	PrecacheSoundArray(g_DemoSword_MeleeAttackSounds);
	PrecacheSoundArray(g_DemoSword_MeleeHitSounds);
}

methodmap AltExtra_Base < CClotBody {
	public void PlayRobotHeavyMeleeAttackSound() {
		EmitSoundToAll(g_RobotHeavy_MeleeAttackSounds[GetRandomInt(0, sizeof(g_RobotHeavy_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
	}
	
	public void PlayRobotHeavyMeleeHitSound() {
		EmitSoundToAll(g_RobotHeavy_MeleeHitSounds[GetRandomInt(0, sizeof(g_RobotHeavy_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
	}

	public void PlayRobotHeavyMeleeMissSound() {
		EmitSoundToAll(g_RobotHeavy_MeleeMissSounds[GetRandomInt(0, sizeof(g_RobotHeavy_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
	}
	
	public void PlayRocketLauncherShootSound() {
		EmitSoundToAll(g_RocketLaucher_ShootSounds, this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayExpidonsanSwordMeleeAttackSounds() {
		EmitSoundToAll(g_ExpidonsanSword_MeleeAttackSounds[GetRandomInt(0, sizeof(g_ExpidonsanSword_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
	}
	
	public void PlayExpidonsanSwordMeleeHitSounds() {
		EmitSoundToAll(g_ExpidonsanSword_MeleeHitSounds[GetRandomInt(0, sizeof(g_ExpidonsanSword_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
	}
	
	public void PlayDemoSwordMeleeAttackSounds() {
		EmitSoundToAll(g_DemoSword_MeleeAttackSounds[GetRandomInt(0, sizeof(g_DemoSword_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayDemoSwordMeleeHitSounds() {
		EmitSoundToAll(g_DemoSword_MeleeHitSounds[GetRandomInt(0, sizeof(g_DemoSword_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void ModifyBodyPitch(float vecMe[3], float vecTarget[3]) {
		int iPitch = this.LookupPoseParameter("body_pitch");
		if (iPitch < 0)
			return;
		
		//Body pitch
		float v[3], ang[3];
		SubtractVectors(vecMe, vecTarget, v); 
		NormalizeVector(v, v);
		GetVectorAngles(v, ang);
		
		float flPitch = this.GetPoseParameter(iPitch);						
		this.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));
	}
	
	public void GetBonePositionSimple(int entity, const char[] name, float origin[3], float angles[3]) {
		int iBone = SDKCall_LookupBone(entity, name);
		if (iBone != -1) {
			SDKCall_GetBonePosition(entity, iBone, origin, angles);
		}
	}
	
	public int FireRocketCustom(float vecTarget[3], float rocket_damage, float rocket_speed, const char[] rocket_model = "", float model_scale = 1.0, int flags = 0, bool overrideSpawn = false, const float vecSpawnOverride[3] = NULL_VECTOR, int inflictor = INVALID_ENT_REFERENCE) {
		float vecStart[3];
		if (overrideSpawn) {
			vecStart = vecSpawnOverride;
		}
		else {
			GetAbsOrigin(this.index, vecStart);
			vecStart[2] += 54.0;
		}
		
		float vecForward[3], vecAngles[3];
		MakeVectorFromPoints(vecStart, vecTarget, vecAngles);
		GetVectorAngles(vecAngles, vecAngles);
		
		float speed = rocket_speed;
		
		Rogue_Paradox_ProjectileSpeed(this.index, speed);
		
		vecForward[0] = Cosine(DegToRad(vecAngles[0])) * Cosine(DegToRad(vecAngles[1])) * speed;
		vecForward[1] = Cosine(DegToRad(vecAngles[0])) * Sine(DegToRad(vecAngles[1])) * speed;
		vecForward[2] = Sine(DegToRad(vecAngles[0])) * -speed;
		
		int entity = CreateEntityByName("tf_projectile_rocket");
		if (IsValidEntity(entity)) {
			fl_Extra_Damage[entity] = fl_Extra_Damage[this.index];
			h_ArrowInflictorRef[entity] = inflictor < 1 ? INVALID_ENT_REFERENCE : EntIndexToEntRef(inflictor);
			i_ExplosiveProjectileHexArray[entity] = flags;
			
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", this.index);
			
			SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, rocket_damage, true);	// Damage
			
			SetTeam(entity, GetTeam(this.index));
			SetEntPropVector(entity, Prop_Send, "m_vInitialVelocity", vecForward);
			
			TeleportEntity(entity, vecStart, vecAngles, NULL_VECTOR, true);
			DispatchSpawn(entity);
			
			if (rocket_model[0]) {
				int g_ProjectileModelRocket = PrecacheModel(rocket_model);
				for (int i; i < 4 ; i++) {
					SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_ProjectileModelRocket, _, i);
				}
			}
			
			if (model_scale != 1.0) {
				SetEntPropFloat(entity, Prop_Send, "m_flModelScale", model_scale);
			}
			
			TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vecForward, true);
			
			SetEntityCollisionGroup(entity, 24); //our savior
			
			Set_Projectile_Collision(entity); //If red, set to 27
		}
		
		return entity;
	}
	
	public bool IsTargetInFiringCone(int target, float maxYawAngle = 20.0, float maxPitchAngle = 20.0) {
		float vecMe[3], vecTarget[3], vecToTarget[3];
		WorldSpaceCenter(this.index, vecMe);
		WorldSpaceCenter(target, vecTarget);
		
		SubtractVectors(vecTarget, vecMe, vecToTarget);
		NormalizeVector(vecToTarget, vecToTarget);
		
		float angRotation[3];
		GetEntPropVector(this.index, Prop_Data, "m_angRotation", angRotation);
		
		// --- Yaw ---
		float flViewYaw = angRotation[1];
		
		if (this.m_iBodyYawPoseParameter > -1) {
			flViewYaw -= this.GetPoseParameter(this.m_iBodyYawPoseParameter);
		}
		
		flViewYaw = UTIL_AngleNormalize(flViewYaw);
		
		float flTargetYaw = this.UTIL_VecToYaw(vecToTarget);
		
		float flYawDiff = MyAngleDiff(flTargetYaw, flViewYaw);
		
		if (FloatAbs(flYawDiff) > maxYawAngle) {
			return false;
		}
		
		// --- Pitch ---
		if (this.m_iBodyPitchPoseParameter > -1) {
			float vecDir[3], vecAng[3];
			SubtractVectors(vecMe, vecTarget, vecDir);
			NormalizeVector(vecDir, vecDir);
			GetVectorAngles(vecDir, vecAng);
			
			float flCurrentPitch = this.GetPoseParameter(this.m_iBodyPitchPoseParameter);
			float flPitchDiff = MyAngleDiff(vecAng[0], flCurrentPitch);
			
			if (FloatAbs(flPitchDiff) > maxPitchAngle) {
				return false;
			}
		}
		
		return true;
	}
	
	public void RegisterBody() {
		// we muset reset to -1. because pose parameter indexes are start with 0.
		this.ResetBody();
		
		if (this.m_iBodyYawPoseParameter == -1) {
			this.m_iBodyYawPoseParameter = this.LookupPoseParameter("body_yaw");
		}
		
		if (this.m_iBodyPitchPoseParameter == -1) {
			this.m_iBodyPitchPoseParameter = this.LookupPoseParameter("body_pitch");
		}
	}
	
	public void ResetBody() {
		this.m_iBodyYawPoseParameter = -1;
		this.m_iBodyPitchPoseParameter = -1;
		
		this.m_bPitchHandedOff = true;
		this.m_bYawHandedOff = true;
	}
	
	public void UntwistBody(float flDeltaTime = 0.05) {
		if (this.m_bPathing) {
			if (!this.m_bYawHandedOff && this.m_iBodyYawPoseParameter > -1) {
				float flYaw = this.GetPoseParameter(this.m_iBodyYawPoseParameter);
				
				if (FloatAbs(flYaw) > 0.1) {
					this.SetPoseParameter(
						this.m_iBodyYawPoseParameter,
						ApproachAngle(0.0, flYaw, ALT_EXTRA_BODY_YAW_UNTWIST_SPEED * flDeltaTime)
					);
				}
				else {
					this.m_bYawHandedOff = true;
				}
			}
			
			if (!this.m_bPitchHandedOff && this.m_iBodyPitchPoseParameter > -1) {
				float flPitch = this.GetPoseParameter(this.m_iBodyPitchPoseParameter);
				
				if (FloatAbs(flPitch) > 0.1) {
					this.SetPoseParameter(
						this.m_iBodyPitchPoseParameter,
						ApproachAngle(0.0, flPitch, ALT_EXTRA_BODY_PITCH_TRACK_SPEED * flDeltaTime)
					);
				}
				else {
					this.m_bPitchHandedOff = true;
				}
			}
		}
	}
	
	public void UpkeepBody(float flDeltaTime = 0.05) {
		float vecMe[3], vecTarget[3];
		WorldSpaceCenter(this.index, vecMe);
		WorldSpaceCenter(this.m_iTarget, vecTarget);
		
		float vecDir[3], vecAng[3];
		if (this.m_iBodyPitchPoseParameter > -1) {
			SubtractVectors(vecMe, vecTarget, vecDir);
			NormalizeVector(vecDir, vecDir);
			GetVectorAngles(vecDir, vecAng);
			
			vecAng[0] = UTIL_AngleNormalize(vecAng[0]);
			
			float flPitch = this.GetPoseParameter(this.m_iBodyPitchPoseParameter);
			
			float flBodyPitch = clamp(vecAng[0], -45.0, 90.0);
			
			this.SetPoseParameter(
				this.m_iBodyPitchPoseParameter,
				ApproachAngle(flBodyPitch, flPitch, ALT_EXTRA_BODY_PITCH_TRACK_SPEED * flDeltaTime)
			);
			
			this.m_bPitchHandedOff = false;
		}
		
		if (this.m_iBodyYawPoseParameter > -1) {
			SubtractVectors(vecTarget, vecMe, vecDir);
			NormalizeVector(vecDir, vecDir);
			GetVectorAngles(vecDir, vecAng);
			
			float angRotation[3];
			GetEntPropVector(this.index, Prop_Data, "m_angRotation", angRotation);
			
			float relativeYaw = -MyAngleDiff(vecAng[1], angRotation[1]);
			
			float flYaw = this.GetPoseParameter(this.m_iBodyYawPoseParameter);
			
			if (relativeYaw > 45.0 || relativeYaw < -45.0) {
				if (FloatAbs(flYaw) > 0.1) {
					this.SetPoseParameter(
						this.m_iBodyYawPoseParameter,
						ApproachAngle(0.0, flYaw, ALT_EXTRA_BODY_YAW_UNTWIST_SPEED * flDeltaTime)
					);
				}
				
				if (!this.m_bPathing || this.m_bAllowBackWalking) {
					this.GetLocomotionInterface().FaceTowards(vecTarget);
				}
			}
			else {
				float bodyYaw = clamp(relativeYaw, -44.9, 44.9);
				
				this.SetPoseParameter(
					this.m_iBodyYawPoseParameter,
					ApproachAngle(bodyYaw, flYaw, ALT_EXTRA_BODY_YAW_TRACK_SPEED * flDeltaTime)
				);
			}
			
			this.m_bYawHandedOff = false;
		}
		else {
			if (!this.m_bPathing || this.m_bAllowBackWalking) {
				this.GetLocomotionInterface().FaceTowards(vecTarget);
			}
		}
	}
	
	public void UpdateBody() {
		float gameTime = GetGameTime(this.index);
		float flDeltaTime = (this.m_flLastBodyUpdateTime > 0.0) ? (gameTime - this.m_flLastBodyUpdateTime) : 0.05;
		this.m_flLastBodyUpdateTime = gameTime;
		
		if (flDeltaTime <= 0.0 || flDeltaTime > 0.5)
			flDeltaTime = 0.05;
		
		bool bCantSeeTarget = !IsValidEnemy(this.index, this.m_iTarget) || !Can_I_See_Enemy_Only(this.index, this.m_iTarget);
		if (bCantSeeTarget) {
			this.UntwistBody(flDeltaTime);
			return;
		}
		
		if (this.m_iBodyPitchPoseParameter < 0 && this.m_iBodyYawPoseParameter < 0)
			return;
		
		this.UpkeepBody(flDeltaTime);
	}
	
	public void HackMaxYawRate(bool reset) {
		if (this.m_bAllowBackWalking) {
			if (reset) {
				this.GetBaseNPC().flMaxYawRate = 0.0;
			}
			else {
				this.GetBaseNPC().flMaxYawRate = (NPC_DEFAULT_YAWRATE * this.GetDebuffPercentage() * f_NpcTurnPenalty[this.index]);
			}
		}
	}
	
	property int m_iBodyYawPoseParameter {
		public get()			{ return this.GetProp(Prop_Data, "m_iBodyYawPoseParameter"); }
		public set(int value)	{ this.SetProp(Prop_Data, "m_iBodyYawPoseParameter", value); }
	}
	
	property int m_iBodyPitchPoseParameter {
		public get()			{ return this.GetProp(Prop_Data, "m_iBodyPitchPoseParameter"); }
		public set(int value)	{ this.SetProp(Prop_Data, "m_iBodyPitchPoseParameter", value); }
	}
	
	property float m_flLastBodyUpdateTime {
		public get()			{ return this.GetPropFloat(Prop_Data, "m_flLastBodyUpdateTime"); }
		public set(float value)	{ this.SetPropFloat(Prop_Data, "m_flLastBodyUpdateTime", value); }
	}
	
	property bool m_bYawHandedOff {
		public get()			{ return view_as<bool>(this.GetProp(Prop_Data, "m_bYawHandedOff")); }
		public set(bool value)	{ this.SetProp(Prop_Data, "m_bYawHandedOff", value); }
	}
	
	property bool m_bPitchHandedOff {
		public get()			{ return view_as<bool>(this.GetProp(Prop_Data, "m_bPitchHandedOff")); }
		public set(bool value)	{ this.SetProp(Prop_Data, "m_bPitchHandedOff", value); }
	}
}

/*
methodmap AltExtra_Medic_Base < AltExtra_Base {
	public void UpdateBody() {
		float gameTime = GetGameTime(this.index);
		float flDeltaTime = (this.m_flLastBodyUpdateTime > 0.0) ? (gameTime - this.m_flLastBodyUpdateTime) : 0.05;
		this.m_flLastBodyUpdateTime = gameTime;
		
		if (flDeltaTime <= 0.0 || flDeltaTime > 0.5)
			flDeltaTime = 0.05;
		
		bool bCantSeeTarget;
		if (this.Anger) {
			bCantSeeTarget = !IsValidEnemy(this.index, this.m_iTarget) || !Can_I_See_Enemy_Only(this.index, this.m_iTarget);
		}
		else {
			bCantSeeTarget = !IsValidAlly(this.index, this.m_iTarget) || (Can_I_See_Ally(this.index, this.m_iTarget) != this.m_iTarget);
		}
		
		if (bCantSeeTarget) {
			this.UntwistBody(flDeltaTime);
			return;
		}
		
		if (this.m_iBodyPitchPoseParameter < 0 && this.m_iBodyYawPoseParameter < 0)
			return;
		
		this.UpkeepBody(flDeltaTime);
	}
}
*/

public Action AltExtra_Shared_RemoveHoming(Handle timer, int ref) {
	int entity = EntRefToEntIndex(ref);
	if (IsValidEntity(entity)) {
		HomingProjectile_Deactivate(entity);
	}
	return Plugin_Stop;
}

stock float UTIL_AngleNormalize(float angle) {
	angle = Myfmodf(angle, 360.0);
	
	if (angle > 180.0)
		angle -= 360.0;
	
	if (angle < -180.0)
		angle += 360.0;
	
	return angle;
}

stock float MyAngleDiff( float destAngle, float srcAngle ) {
	float delta = Myfmodf(destAngle - srcAngle, 360.0);
	
	if ( delta > 180.0 )
		delta -= 360.0;
	
	return delta;
}

stock bool CanFireProjectileAtTarget(int shooter, int target, const float vecFireOrigin[3], const float vecTargetPos[3], bool onlyTarget = false) {
	AddEntityToTraceStuckCheck(target);
	
	Handle trace = TR_TraceRayFilterEx(vecFireOrigin, vecTargetPos, MASK_SHOT, RayType_EndPoint, TraceRayCanSeeAllySpecific, shooter);
	
	RemoveEntityToTraceStuckCheck(target);
	
	bool bClear;
	if (!TR_DidHit(trace)) {
		bClear = true;
	}
	else {
		int hitEntity = TR_GetEntityIndex(trace);
		if (onlyTarget) {
			bClear = (hitEntity == target);
		}
		else {
			bClear = IsValidEnemy(shooter, hitEntity);
		}
	}
	
	delete trace;
	return bClear;
}

stock float Myfmodf(float num, float denom) {
    return num - denom * float(RoundToZero(num / denom));
}