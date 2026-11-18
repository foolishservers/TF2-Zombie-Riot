#pragma semicolon 1
#pragma newdecls required

static const float ZMAIN_SPEED_BHOP   = 600.0;
static const float ZMAIN_JUMP_FORCE_Z = 400.0;
static const float ZMAIN_BHOP_JUMP_Z  = 271.0;

#define ZS_CUSTOM_MODEL_1	"models/zombie_riot/gmod_zs/zs_zombie_models_1_1.mdl"
enum
{
	ZS_MODEL_CLASSIC          = 1,
	ZS_MODEL_HEADCRABCLASSIC  = 2,
	ZS_MODEL_FAST             = 4,
	ZS_MODEL_HEADCRABFAST     = 8,
	ZS_MODEL_CORPSE           = 16,
	ZS_MODEL_ZOMBINE          = 32,
	ZS_MODEL_SKELETON         = 64,
	ZS_MODEL_FATTY            = 128,
	ZS_MODEL_POISON           = 256,
	ZS_MODEL_POISONHEADCRAB_1 = 512,
	ZS_MODEL_POISONHEADCRAB_2 = 1024,
	ZS_MODEL_POISONHEADCRAB_3 = 2048,
	ZS_MODEL_POISONHEADCRAB_4 = 4096,
	ZS_MODEL_POISONHEADCRAB_5 = 8192,
	ZS_MODEL_DOLL             = 16384,
	ZS_MODEL_CHARPLE          = 32768,
	ZS_MODEL_PUKEPUS          = 65536,
	ZS_MODEL_ERADICATOR       = 131072,
	ZS_MODEL_SHADE            = 262144
};

void ZSBase_OnMapStart_NPC()
{
	PrecacheModel(ZS_CUSTOM_MODEL_1);
}

methodmap ZSZmainBase < CClotBody {
	property float m_flHitAndRun
	{
		public get()				{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float value) 	{ fl_AbilityOrAttack[this.index][0] = value; }
	}
	
	property float m_flBhop
	{
		public get()				{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float value) 	{ fl_AbilityOrAttack[this.index][1] = value; }
	}
	
	property float m_flTryIgnorebuildings
	{
		public get()				{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float value) 	{ fl_AbilityOrAttack[this.index][2] = value; }
	}
	
	property float m_flIgnorebuildings
	{
		public get()				{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float value) 	{ fl_AbilityOrAttack[this.index][3] = value; }
	}
	
	/**
	 * State helper to remove duplication in Think loop
	 * @param stateId        상태 ID, 현재 walk cycle과 같은 경우에는 return.
	 * @param activity       상태 진입 시 실행할 애니메이션
	 * @param speed          상태 진입 시 이동 속도
	 * @param allowBackWalk  상태 진입 시 뒤로 걷기 여부
	 * @param enablePathing  상태 진입 시 pathing 여부
	 */
	public void SetMovementState(int stateId, const char[] activity, float speed, bool allowBackWalk = false, bool enablePathing = true) {
		if (this.m_iChanged_WalkCycle == stateId)
			return;
		
		this.m_iChanged_WalkCycle = stateId;
		this.m_bPathing = enablePathing;
		this.m_bisWalking = enablePathing;
		this.m_bAllowBackWalking = allowBackWalk;
		this.m_flSpeed = speed;
		
		this.SetActivity(activity);
		
		if (enablePathing) {
			this.StartPathing();
		} else {
			this.StopPathing();
		}
	}
	
	/**
	 * NPC 도약 및 속도 적용 메서드
	 * @param pitch              도약 상하 각도
	 * @param forwardScale       전진 추진력
	 * @param upVelocity         Z축 수직 속도
	 * @param yawOffset          좌우 회전 빗겨나가기 각도
	 * @param maxHorizontalSpeed 수평 속도 제한값 (0.0 이하 입력 시 제한 없음)
	 */
	public void PerformLeap(float pitch, float forwardScale, float upVelocity, float yawOffset = 0.0, float maxHorizontalSpeed = 400.0) 
	{
		float vecPos[3], vecAng[3], vecForward[3], vecTarget[3], vecVel[3];
		GetAbsOrigin(this.index, vecPos);
		GetEntPropVector(this.index, Prop_Send, "m_angRotation", vecAng);
		
		vecAng[0] = pitch;
		vecAng[1] += yawOffset;
		
		GetAngleVectors(vecAng, vecForward, NULL_VECTOR, NULL_VECTOR);
		NormalizeVector(vecForward, vecForward);
		ScaleVector(vecForward, forwardScale);
		AddVectors(vecPos, vecForward, vecTarget);
		
		PluginBot_Jump(this.index, vecTarget);
		
		// 물리 속도 가져오기 및 Z축 설정
		this.GetVelocity(vecVel);
		vecVel[2] = upVelocity;
		
		// 수평(X, Y) 속도 제한 (Clamping)
		if (maxHorizontalSpeed > 0.0)
		{
			float speed2D = SquareRoot(vecVel[0] * vecVel[0] + vecVel[1] * vecVel[1]);
			if (speed2D > maxHorizontalSpeed)
			{
				float scale = maxHorizontalSpeed / speed2D;
				vecVel[0] *= scale;
				vecVel[1] *= scale;
			}
		}
		
		this.SetVelocity(vecVel);
	}
	
	public void GetNPCMoveDirection(float vecDirection[3])
	{
		float vecMotion[3];
		this.GetGroundMotionVector(vecMotion);
		
		float flLength = GetVectorLength(vecMotion);
		
		if(flLength <= 0.001)
		{
			vecDirection[0] = 0.0;
			vecDirection[1] = 0.0;
			vecDirection[2] = 0.0;
			return;
		}
		
		vecDirection[0] = vecMotion[0] / flLength;
		vecDirection[1] = vecMotion[1] / flLength;
		vecDirection[2] = vecMotion[2] / flLength;
	}
	
	public void PerformNormalJump(float upVelocity)
	{
		this.GetLocomotionInterface().Jump();
			
		float vel[3];
		this.GetVelocity(vel);
		vel[2] = upVelocity;
		this.SetVelocity(vel);
	}
}

public int ZSZmain_AnnoyingLogic(ZSZmainBase npc, float gameTime, float vecTarget[3], float distance)
{
	if(npc.m_flTryIgnorebuildings < gameTime && ShouldNpcDealBonusDamage(npc.m_iTarget))
	{
		b_NpcIgnoresbuildings[npc.index] = true;
		npc.m_iTarget = GetClosestTarget(npc.index, true);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
		
		if(npc.IsOnGround()) {
			npc.PerformLeap(75.0, 200.0, ZMAIN_JUMP_FORCE_Z);
		}
		
		npc.m_flTryIgnorebuildings = 6.0 + gameTime;
		npc.m_flIgnorebuildings = 3.0 + gameTime;
		return 3;
	}
	
	b_NpcIgnoresbuildings[npc.index] = (npc.m_flIgnorebuildings > gameTime);
	
	// 1. Anger (Hit & Run) Mode
	if(npc.Anger) {
		npc.m_flBhop += 0.1;
		
		if(npc.m_flHitAndRun < gameTime) {
			npc.Anger = false;
		}
		return 4;
	}
	
	// 2. Bhop Dash Logic
	if(npc.m_flBhop < gameTime) {
		bool shouldResetCombo = false;
		
		float vecDirection[3], vecSelf[3], vecPos[3];
		WorldSpaceCenter(npc.index, vecSelf);
		
		npc.GetNPCMoveDirection(vecDirection);
		
		// 125 * 125 = 15625
		if(EntityLookPoint(npc.index, vecDirection, vecSelf, vecPos, MASK_PLAYERSOLID)
			&& GetVectorDistance(vecSelf, vecPos, true) < 15625.0)
		{
			shouldResetCombo = true;
			
			f_NpcTurnPenalty[npc.index] = 1.0;
			npc.m_iOverlordComboAttack = 0;
			npc.m_flBhop = 5.0 + gameTime;
			return 1;
		}
		
		if(!shouldResetCombo && npc.IsOnGround()) {
			shouldResetCombo = (npc.m_iOverlordComboAttack > 30) || 
								(npc.m_iOverlordComboAttack > 10 && distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.66));
			
			if(shouldResetCombo) {
				f_NpcTurnPenalty[npc.index] = 1.0;
				npc.m_iOverlordComboAttack = 0;
				npc.m_flBhop = 20.0 + gameTime;
				return 1;
			}
			
			int limitedCombo = npc.m_iOverlordComboAttack;
			if (limitedCombo > 10)
				limitedCombo = 10;
			
			f_NpcTurnPenalty[npc.index] = 0.95;
			float forwardScale = 125.0 + ((ZMAIN_SPEED_BHOP * 0.05) * limitedCombo);
			npc.PerformLeap(27.5, forwardScale, ZMAIN_BHOP_JUMP_Z);
			
			npc.m_iOverlordComboAttack++;
		}
		
		return 3;
	}
	
	// 3. Long-range Sidestep Jump
	/*
	if(npc.m_flSideStep < gameTime) {
		npc.m_flBhop += 0.1;
		
		if(npc.IsOnGround() && npc.m_flJumpCooldownZmain < gameTime && distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0)) {
			npc.m_flJumpCooldownZmain = gameTime + GetRandomRetargetTime();
			npc.PerformNormalJump(ZMAIN_JUMP_FORCE_Z);
		}
	}
	*/
	
	return 1;
}