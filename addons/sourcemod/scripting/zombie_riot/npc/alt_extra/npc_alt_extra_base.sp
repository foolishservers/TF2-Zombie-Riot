#pragma semicolon 1
#pragma newdecls required

#define ALT_EXTRA_BODY_YAW_UNTWIST_SPEED   60.0   // 큰 각도일 때 트위스트를 0으로 풀어주는 속도 (도/초)
#define ALT_EXTRA_BODY_YAW_TRACK_SPEED     120.0  // 작은 각도일 때 relativeYaw를 따라가는 속도 (도/초)
#define ALT_EXTRA_BODY_PITCH_TRACK_SPEED   90.0   // pitch가 타겟 방향을 따라가는 속도 (도/초)

// 몸통이 타겟 쪽으로 도는 최대 속도 (도/초). FaceTowards의 기본 회전 속도가 빠를 때 이 값으로 제한한다.
// 엔진의 yaw rate가 이 값보다 낮으면 엔진 쪽 값이 우선한다.
#define ALT_EXTRA_BODY_TURN_SPEED          90.0

#define TF2_BODY_YAW_LIMIT          44.9   // pose parameter 로 표현 가능한 최대 yaw
#define TF2_BODY_TURN_START         45.0   // 이 각도를 넘으면 몸통 회전 시작
#define TF2_BODY_TURN_STOP          20.0   // 이 각도 안으로 들어오면 몸통 회전 종료
#define TF2_BODY_SETTLE_EPSILON     0.1

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
		
		// --- Yaw ---
		float flViewYaw = this.GetViewYaw();
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
		
		this.m_bHeadYawValid = false;
		this.m_bBodyTurning = false;
		this.m_bBodyHandedOff = false;
		this.m_bDisallowTurning = false;
	}
	
	// -----------------------------------------------------------------------
	// 현재 몸통 yaw 기준 "시선 yaw(월드)"를 pose parameter용 로컬 값으로 변환
	// -----------------------------------------------------------------------
	public float WorldYawToPose(float flWorldYaw, float flBodyYaw) {
		return -MyAngleDiff(flWorldYaw, flBodyYaw);
	}
	
	// -----------------------------------------------------------------------
	// pose parameter 값을 월드 yaw로 역변환 (헤드 초기화용)
	// -----------------------------------------------------------------------
	public float PoseToWorldYaw(float flPose, float flBodyYaw) {
		return UTIL_AngleNormalize(flBodyYaw - flPose);
	}
	
	// -----------------------------------------------------------------------
	// 이번 틱의 몸통 yaw 읽기
	// -----------------------------------------------------------------------
	public float GetBodyYaw() {
		float angRotation[3];
		GetEntPropVector(this.index, Prop_Data, "m_angRotation", angRotation);
		return angRotation[1];
	}
	
	// -----------------------------------------------------------------------
	// 이번 틱의 pose yaw를 읽고, World Yaw로 변환
	// -----------------------------------------------------------------------
	public float GetViewYaw() {
		float flPose = 0.0;
		if (this.m_iBodyYawPoseParameter > -1) {
			flPose = this.GetPoseParameter(this.m_iBodyYawPoseParameter);
		}
		return this.PoseToWorldYaw(flPose, this.GetBodyYaw());
	}
	
	// -----------------------------------------------------------------------
	// 헤드 월드 yaw가 아직 없으면 현재 pose parameter로부터 복원
	// -----------------------------------------------------------------------
	public void EnsureHeadYaw(float flBodyYaw) {
		if (this.m_bHeadYawValid) {
			return;
		}

		float flPose = 0.0;
		if (this.m_iBodyYawPoseParameter > -1) {
			flPose = this.GetPoseParameter(this.m_iBodyYawPoseParameter);
		}

		this.m_flHeadYawWorld = this.PoseToWorldYaw(flPose, flBodyYaw);
		this.m_bHeadYawValid = true;
	}
	
	// -----------------------------------------------------------------------
	// 경로 이동 중 타겟이 없을 때: 목표를 "몸 정면"으로 두고 풀어줌
	// -----------------------------------------------------------------------
	public void UntwistBody(float flDeltaTime = 0.05) {
		if (!this.m_bPathing || this.m_bBodyHandedOff) {
			return;
		}

		bool bSettled = true;
		// float flBodyYaw = this.GetBodyYaw();

		if (this.m_iBodyYawPoseParameter > -1) {
			// 목표 = pose parameter 0.0 (몸 정면). pose 공간에서 직접 접근한다.
			// 월드 yaw를 목표로 쓰면 클램프 전 값이 한계를 넘는 동안
			// 화면상 변화 없이 시간만 흘러가는 구간이 생긴다.
			float flPose = this.GetPoseParameter(this.m_iBodyYawPoseParameter);

			if (FloatAbs(flPose) > TF2_BODY_SETTLE_EPSILON) {
				this.SetPoseParameter(
					this.m_iBodyYawPoseParameter,
					MyApproachAngle(0.0, flPose, 1.0)
				);
				bSettled = false;
			}

			// 추적 재개 시 현재 pose로부터 시선을 다시 복원하도록 무효화
			this.m_bHeadYawValid = false;
		}

		if (this.m_iBodyPitchPoseParameter > -1) {
			float flPitch = this.GetPoseParameter(this.m_iBodyPitchPoseParameter);

			if (FloatAbs(flPitch) > TF2_BODY_SETTLE_EPSILON) {
				this.SetPoseParameter(
					this.m_iBodyPitchPoseParameter,
					MyApproachAngle(0.0, flPitch, 1.0)
				);
				bSettled = false;
			}
		}

		if (bSettled) {
			this.m_bBodyHandedOff = true;
			this.m_bHeadYawValid = false;   // 다음 추적 시 pose로부터 다시 복원
			this.m_bBodyTurning = false;
		}
	}
	
	// -----------------------------------------------------------------------
	// 몸통을 flTargetYaw(월드) 쪽으로 돌린다. 한 번 호출에 ALT_EXTRA_BODY_TURN_SPEED * dt 만큼만 돈다.
	// FaceTowards에 목표를 직접 주면 엔진의 기본 회전 속도로 돌아가므로, 중간 방향을 만들어 넘긴다.
	// -----------------------------------------------------------------------
	public void TurnBodyTowards(float flTargetYaw, float flDeltaTime) {
		float vecMe[3], vecFace[3];
		WorldSpaceCenter(this.index, vecMe);
		
		float flFaceYaw = ApproachAngle(flTargetYaw, this.GetBodyYaw(), ALT_EXTRA_BODY_TURN_SPEED * flDeltaTime);
		vecFace[0] = vecMe[0] + Cosine(DegToRad(flFaceYaw)) * 100.0;
		vecFace[1] = vecMe[1] + Sine(DegToRad(flFaceYaw)) * 100.0;
		vecFace[2] = vecMe[2];
		
		if (!this.m_bDisallowTurning)
			this.GetLocomotionInterface().FaceTowards(vecFace);
		else
			this.FaceTowards(vecFace);
	}
	
	// -----------------------------------------------------------------------
	// 타겟 추적
	// -----------------------------------------------------------------------
	public void UpkeepBody(float flDeltaTime = 0.05) {
		float vecMe[3], vecTarget[3];
		WorldSpaceCenter(this.index, vecMe);
		WorldSpaceCenter(this.m_iTarget, vecTarget);

		this.m_bBodyHandedOff = false;

		float vecDir[3], vecAng[3];

		// ---------------- Pitch ----------------
		// pitch는 몸통 회전과 무관하므로 pose parameter 자체를 상태로 사용
		if (this.m_iBodyPitchPoseParameter > -1) {
			SubtractVectors(vecMe, vecTarget, vecDir);
			NormalizeVector(vecDir, vecDir);
			GetVectorAngles(vecDir, vecAng);

			float flAimPitch = clamp(UTIL_AngleNormalize(vecAng[0]), -45.0, 90.0);
			float flPitch = this.GetPoseParameter(this.m_iBodyPitchPoseParameter);

			this.SetPoseParameter(
				this.m_iBodyPitchPoseParameter,
				MyApproachAngle(flAimPitch, flPitch, ALT_EXTRA_BODY_PITCH_TRACK_SPEED * flDeltaTime)
			);
		}

		// ---------------- Yaw ----------------
		float flBodyYaw = this.GetBodyYaw();

		// 목표 월드 yaw (이번 틱 타겟 방향)
		SubtractVectors(vecTarget, vecMe, vecDir);
		NormalizeVector(vecDir, vecDir);
		GetVectorAngles(vecDir, vecAng);
		float flAimYawWorld = vecAng[1];
		
		bool bCanTurnBody = (!this.m_bPathing || this.m_bAllowBackWalking);

		// 시선은 항상 "월드 기준"으로 목표에 수렴 (몸통이 돌든 말든 흔들리지 않음)
		if (this.m_iBodyYawPoseParameter > -1) {
			// 시선(gaze): 목표 방향을 속도 제한으로 따라가는 "월드 기준" 방향. 클램프하지 않은 값이다.
			// 몸통도 이 값을 따라가므로, 타겟이 바뀌어도 시선과 몸통이 한 번에 튀지 않는다.
			this.EnsureHeadYaw(flBodyYaw);
			
			this.m_flHeadYawWorld = ApproachAngle(
				flAimYawWorld,
				this.m_flHeadYawWorld,
				ALT_EXTRA_BODY_YAW_TRACK_SPEED * flDeltaTime
			);
			
			// 몸통 기준 시선 각도 (몸통 회전 판단용). 타겟 원래 방향이 아니라 시선을 기준으로 한다.
			float flGazeRelative = this.WorldYawToPose(this.m_flHeadYawWorld, flBodyYaw);
			
			// 히스테리시스: START 초과 시 회전 시작, STOP 미만이 되면 종료
			if (this.m_bBodyTurning) {
				if (FloatAbs(flGazeRelative) < TF2_BODY_TURN_STOP) {
					this.m_bBodyTurning = false;
				}
			}
			else if (FloatAbs(flGazeRelative) > TF2_BODY_TURN_START) {
				this.m_bBodyTurning = true;
			}
			
			if (this.m_bBodyTurning && bCanTurnBody) {
				// this.TurnBodyTowards(this.m_flHeadYawWorld, flDeltaTime);
				if (!this.m_bDisallowTurning)
					this.GetLocomotionInterface().FaceTowards(vecTarget);
				else
					this.FaceTowards(vecTarget);
				
				// FaceTowards는 m_angRotation을 즉시 바꾼다. (로그로 확인: 호출 전후 yaw가 틱당 약 3도 차이)
				// 이 값을 다시 읽지 않으면 pose가 회전 전 몸 기준으로 계산되어
				// 몸이 도는 동안 시선이 몸 방향으로 밀렸다가 돌아온다.
				flBodyYaw = this.GetBodyYaw();
			}
			
			// 마지막에 한 번만 로컬(pose) 값으로 변환. 클램프는 보이는 값에만 적용하고 시선은 그대로 둔다.
			// (시선은 타겟 방향을 따라갈 뿐이라 한계 밖에서 누적되지 않는다)
			float flPose = clamp(
				this.WorldYawToPose(this.m_flHeadYawWorld, flBodyYaw),
				-TF2_BODY_YAW_LIMIT, TF2_BODY_YAW_LIMIT
			);
			this.SetPoseParameter(this.m_iBodyYawPoseParameter, flPose);
		}
		else if (bCanTurnBody) {
			// pose parameter가 없는 모델은 기존처럼 몸통만 회전
			if (!this.m_bDisallowTurning)
				this.GetLocomotionInterface().FaceTowards(vecTarget);
			else
				this.FaceTowards(vecTarget);
		}
	}
	
	public void UpdateBody() {
		float gameTime = GetGameTime(this.index);
		float flDeltaTime = (this.m_flLastBodyUpdateTime > 0.0) ? (gameTime - this.m_flLastBodyUpdateTime) : 0.05;
		this.m_flLastBodyUpdateTime = gameTime;
		
		// 업데이트 간격이 길게 벌어졌으면(공격 중 등) 저장된 월드 시선은 신뢰할 수 없다.
		// 그 사이 몸이 돌았을 수 있으므로 현재 pose로부터 다시 복원한다.
		if (flDeltaTime > 0.25)
			this.m_bHeadYawValid = false;
		
		if (flDeltaTime <= 0.0 || flDeltaTime > 0.5)
			flDeltaTime = 0.05;
		
		bool bCantSeeTarget = !IsValidEnemy(this.index, this.m_iTarget) || !Can_I_See_Enemy_Only(this.index, this.m_iTarget);

		if (bCantSeeTarget) {
			// 추적하지 않은 틱에는 시선을 항상 무효화한다.
			// (Untwist가 early return하는 경우에도 몸은 계속 돌기 때문)
			this.m_bHeadYawValid = false;
			this.UntwistBody(flDeltaTime);
			
			return;
		}
		
		if (this.m_iBodyPitchPoseParameter < 0 && this.m_iBodyYawPoseParameter < 0)
			return;
		
		this.UpkeepBody(flDeltaTime);
	}

	
	public void HackMaxYawRate(bool reset) {
		if (!this.m_bDisallowTurning && this.m_bAllowBackWalking) {
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
	
	property float m_flHeadYawWorld {
		public get()			{ return this.GetPropFloat(Prop_Data, "m_flHeadYawWorld"); }
		public set(float value)	{ this.SetPropFloat(Prop_Data, "m_flHeadYawWorld", value); }
	}
	
	property bool m_bHeadYawValid {
		public get()			{ return view_as<bool>(this.GetProp(Prop_Data, "m_bHeadYawValid")); }
		public set(bool value)	{ this.SetProp(Prop_Data, "m_bHeadYawValid", value); }
	}
	
	property bool m_bBodyTurning {
		public get()			{ return view_as<bool>(this.GetProp(Prop_Data, "m_bBodyTurning")); }
		public set(bool value)	{ this.SetProp(Prop_Data, "m_bBodyTurning", value); }
	}
	
	property bool m_bBodyHandedOff {
		public get()			{ return view_as<bool>(this.GetProp(Prop_Data, "m_bBodyHandedOff")); }
		public set(bool value)	{ this.SetProp(Prop_Data, "m_bBodyHandedOff", value); }
	}
	
	property bool m_bDisallowTurning {
		public get()			{ return view_as<bool>(this.GetProp(Prop_Data, "m_bDisallowTurning")); }
		public set(bool value)	{ this.SetProp(Prop_Data, "m_bDisallowTurning", value); }
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

stock float MyApproachAngle( float target, float value, float speed )
{
	float delta = MyAngleDiff(target, value);

    if (speed < 0.0)
        speed = -speed;

    if (delta > speed)
        value += speed;
    else if (delta < -speed)
        value -= speed;
    else
        value = target;

    return value;
}

/**
 * destAngle과 srcAngle를 입력받아 두 각도 간의 차이(diff)를 반환하는 함수.
 * 그 과정에서 fmodf 연산을 사용한다.
 * 
 * 기존 Util_AngleDiff은 fmodf를 사용하는데
 * fmodf는 C언어에서의 구현과 달리, 입력한 숫자의 부호를 유지하지 않는다.
 * 그래서 -180도 이하를 처리하는 분기가 있음에도 불구하고 실제로 작동하지 않는다.
 * 
 * 이 함수는 Myfmodf를 사용하여, 그 문제를 해결한다.
 */
stock float MyAngleDiff(float destAngle, float srcAngle) {
	float delta = Myfmodf(destAngle - srcAngle, 360.0);
	
	if (delta >= 180.0)
		delta -= 360.0;
	else if (delta <= -180.0)
		delta += 360.0;
	
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