#pragma semicolon 1
#pragma newdecls required

static char g_DeathSounds[][] = {
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav",
};

static char g_HurtSounds[][] = {
	"npc/combine_soldier/pain1.wav",
	"npc/combine_soldier/pain2.wav",
	"npc/combine_soldier/pain3.wav",
};

static char g_IdleSounds[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
};

static char g_IdleAlertedSounds[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
};

static char g_MeleeHitSounds[][] = {
	"npc/vort/foot_hit.wav",
};

static char g_MeleeAttackSounds[][] = {
	"npc/combine_soldier/gear1.wav",
	"npc/combine_soldier/gear2.wav",
	"npc/combine_soldier/gear3.wav",
	"npc/combine_soldier/gear4.wav",
	"npc/combine_soldier/gear5.wav",
	"npc/combine_soldier/gear6.wav",
};

static char g_RangedAttackSounds[][] = {
	"weapons/ar2/fire1.wav",
};

static char g_RangedReloadSound[][] = {
	"weapons/ar2/npc_ar2_reload.wav",
};

static char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

void Whiteflower_CombinePretorianGuard_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "W.F. Pretorian Guard");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_combine_pretorian_guard");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_WhiteflowerSpecial;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_RangedReloadSound);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return CombinePretorianGuard(vecPos, vecAng, ally);
}

methodmap CombinePretorianGuard < CClotBody {
	public void PlayIdleSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayIdleAlertSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayHurtSound() {
		if (this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void Update()
	{
		// 1) CClotBody의 기존 처리(애니메이션 블렌딩, 회피 박스, 경로 진행 등)는 그대로 실행
		view_as<CClotBody>(this).Update();
		
		// 2) 우리 전용 근거리 추적 레이어
		this.CustomFollowUpdate();
	}
	
	public void CustomFollowUpdate()
	{
		// 추격 상태(state 0)일 때만 개입. 정지 조준(1,2)이나 근접공격(3) 중엔
		// base 경로 시스템이 이미 멈춰있으므로 건드리지 않는다.
		if (this.m_iState != 0)
			return;
		
		int target = this.m_iTarget;
		if (!IsValidEnemy(this.index, target))
			return;
		
		// 시야가 확보된 상태에서만 직선 조향한다. LOS가 없으면(벽 뒤 등)
		// Approach()는 장애물을 무시하고 직진하므로 base 나브메시 경로에 맡긴다.
		if (!this.m_bCanSeeCurrentTarget)
			return;
		
		float myPos[3], targetPos[3];
		WorldSpaceCenter(this.index, myPos);
		WorldSpaceCenter(target, targetPos);
		
		// 근거리(약 700유닛 이내)에서만 매 프레임 직접 조향.
		// 그 밖에는 base의 나브메시 경로(SetGoalVector/SetGoalEntity)가 담당.
		float distSq = GetVectorDistance(myPos, targetPos, true);
		if (distSq > (700.0 * 700.0))
			return;
		
		this.Approach(targetPos);
	}
	
	public bool IsTargetInFiringCone(int target, float maxAngle = 20.0)
	{
		float vecMe[3], vecTarget[3], vecToTarget[3];
		WorldSpaceCenter(this.index, vecMe);
		WorldSpaceCenter(target, vecTarget);
		
		SubtractVectors(vecTarget, vecMe, vecToTarget);
		vecToTarget[2] = 0.0;
		NormalizeVector(vecToTarget, vecToTarget);
		
		float angRotation[3];
		GetEntPropVector(this.index, Prop_Data, "m_angRotation", angRotation);
		
		float flTargetYaw = this.UTIL_VecToYaw(vecToTarget);
		float flDiff = this.UTIL_AngleDiff(flTargetYaw, angRotation[1]);
		
		return (FloatAbs(flDiff) <= maxAngle);
	}
	
	public void DoRangeAttack(int target) {
		float gameTime = GetGameTime(this.index);
		if (this.m_flAttackHappenswillhappen || this.m_flNextRangedAttack > gameTime)
			return;
		
		float vecTarget[3];
		WorldSpaceCenter(target, vecTarget);
		//this.FaceTowards(vecTarget, 10000.0);
		
		float vecSpread = 0.1;
		//float eyePitch[3];
		//GetEntPropVector(this.index, Prop_Data, "m_angRotation", eyePitch);
		
		float x, y;
		x = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
		y = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
		
		float vecDirShooting[3], vecRight[3], vecUp[3];
		vecTarget[2] += 15.0;
		
		float vecMe[3];
		WorldSpaceCenter(this.index, vecMe);
		
		MakeVectorFromPoints(vecMe, vecTarget, vecDirShooting);
		GetVectorAngles(vecDirShooting, vecDirShooting);
		//vecDirShooting[1] = eyePitch[1];
		GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
		
		float vecEnd[3];
		vecEnd[0] = vecMe[0] + vecDirShooting[0] * 9000; 
		vecEnd[1] = vecMe[1] + vecDirShooting[1] * 9000;
		vecEnd[2] = vecMe[2] + vecDirShooting[2] * 9000;
		
		this.m_flNextRangedAttack = gameTime + 0.35;
		this.m_iAttacksTillReload -= 1;
		
		this.AddGesture("ACT_GESTURE_RANGE_ATTACK_AR2");
		
		float vecDir[3];
		vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
		vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
		vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
		NormalizeVector(vecDir, vecDir);
		
		int targetHurt = FireBullet(this.index, this.m_iWearable1, vecMe, vecDir, 50.0, 9000.0, DMG_BULLET, "bullet_tracer01_red");
		if (IsValidEnemy(this.index, targetHurt))
		{
			ApplyStatusEffect(this.index, targetHurt, "Silenced", 2.0);
		}
		
		this.PlayRangedSound();
		
		if (this.m_iAttacksTillReload == 0)
		{
			this.AddGesture("ACT_RELOAD_AR2");
			this.m_flReloadDelay = gameTime + 2.2;
			this.m_iAttacksTillReload = 10;
			this.PlayRangedReloadSound();
		}
	}

	property float m_flEyeYaw
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	property float m_flEyePitch
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	
	property float m_flCurrentFeetYaw
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	
	property float m_flGoalFeetYaw
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	
	property float m_flLastAimTurnTime
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	
	property bool m_bCanSeeCurrentTarget
	{
		public get()							{ return this.m_fbGunout; }
		public set(bool TempValueForProperty) 	{ this.m_fbGunout = TempValueForProperty; }
	}
	
	public void ComputePoseParam_AimPitch()
	{
		int m_iAimPitch = this.LookupPoseParameter("aim_pitch");
		if (m_iAimPitch < 0)
			return;
		
		float flAimPitch = this.GetPoseParameter(m_iAimPitch);
		
		// Fuck. this pose param is inverted.
		float flGoalPitch = clamp(-this.m_flEyePitch, -56.0, 89.0);
		
		flAimPitch = ApproachAngle(flGoalPitch, flAimPitch, 10.0);
		
		// Set the aim pitch and save.
		this.SetPoseParameter(m_iAimPitch, flAimPitch);
	}
	
	public void ComputePoseParam_AimYaw()
	{
		ILocomotion loco = this.GetLocomotionInterface();
		
		// Keep the torso twist inside what the aim_yaw pose parameter actually supports.
		// (the final clamp below is -44.9..44.9, so stay a hair inside that)
		#define MAX_TORSO_YAW 44.0
		
		bool bMoving = loco.GetGroundSpeed() > 0.01;
		
		// Initialize the feet on the very first tick - nothing to interpolate from yet.
		if (this.m_flLastAimTurnTime <= 0.0)
		{
			this.m_flGoalFeetYaw	= this.m_flEyeYaw;
			this.m_flCurrentFeetYaw = this.m_flEyeYaw;
			this.m_flLastAimTurnTime = GetGameTime();
		}
		else if (bMoving) {
			// The feet match the eye direction when moving - the move yaw takes care of the rest.
			this.m_flGoalFeetYaw = this.m_flEyeYaw;
		}
		else {
			// Continuously chase the eye direction with the feet, but never let the
			// torso twist further than the pose parameter allows. Because this is
			// recalculated every tick (instead of only when the 45 threshold is first
			// crossed), the body smoothly follows a moving/tracked target rather than
			// snap-turning in fixed 45 degree jumps.
			float flYawDelta = AngleNormalizeWithMod(this.m_flEyeYaw - this.m_flCurrentFeetYaw);
			if (FloatAbs(flYawDelta) > MAX_TORSO_YAW)
			{
				float flSide = (flYawDelta > 0.0) ? 1.0 : -1.0;
				this.m_flGoalFeetYaw = AngleNormalizeWithMod(this.m_flEyeYaw - (MAX_TORSO_YAW * flSide));
			}
		}
		
		// Fix up the feet yaw.
		this.m_flGoalFeetYaw = AngleNormalizeWithMod(this.m_flGoalFeetYaw);
		if (this.m_flGoalFeetYaw != this.m_flCurrentFeetYaw)
		{
			float temp = this.m_flCurrentFeetYaw;
			ConvergeYawAngles(this.m_flGoalFeetYaw, 720.0, GetGameFrameTime(), temp);
			this.m_flCurrentFeetYaw = temp;
			this.m_flLastAimTurnTime = GetGameTime();
		}
		
		// Find the aim(torso) yaw base on the eye and feet yaws.
		float flAimYaw = this.m_flEyeYaw - this.m_flCurrentFeetYaw;
		flAimYaw = clamp(AngleNormalizeWithMod(flAimYaw), -44.9, 44.9);
		
		int m_iAimYaw = this.LookupPoseParameter("aim_yaw");
		if (m_iAimYaw < 0)
			return;
		
		// Set the aim yaw and save.
		this.SetPoseParameter(m_iAimYaw, -flAimYaw);
		
		float angle[3];
		GetEntPropVector(this.index, Prop_Data, "m_angRotation", angle);
		angle[1] = this.m_flCurrentFeetYaw;
		TeleportEntity(this.index, NULL_VECTOR, angle, NULL_VECTOR);
	}
	
	public CombinePretorianGuard(float vecPos[3], float vecAng[3], int ally) {
		CombinePretorianGuard npc = view_as<CombinePretorianGuard>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "30000", ally));
		
		i_NpcWeight[npc.index] = 2;
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		// 기본은 엔진 회전 사용, 조준 진입 시에만 true로 전환
		npc.m_bAllowBackWalking = false;
		
		int activity = npc.LookupActivity("ACT_RUN_AIM_AR2_STIMULATED");
		if (activity > 0)
			npc.StartActivity(activity);
		
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCDeath[npc.index] = CombinePretorianGuard_NPCDeath;
		func_NPCThink[npc.index] = CombinePretorianGuard_ClotThink;
		
		npc.m_bCanSeeCurrentTarget = false;
		npc.m_iAttacksTillReload = 20;
		npc.m_bmovedelay = false;
		
		npc.m_flSpeed = 250.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_iChanged_WalkCycle = 1;
		
		npc.m_iState = 0;
		npc.m_flEyeYaw = 0.0;
		npc.m_flEyePitch = 0.0;
		
		KillFeed_SetKillIcon(npc.index, "sniperrifle");
		
		int skin = (ally != TFTeam_Red) ? 1 : 0;
		npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_irifle.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/sniper/sum24_aimframe/sum24_aimframe.mdl");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		
		npc.StartPathing();
		
		return npc;
	}
}

static void CombinePretorianGuard_ClotThink(int iNPC)
{
	CombinePretorianGuard npc = view_as<CombinePretorianGuard>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if (npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if (npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_STOMACH", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if (npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	if (npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	int target = npc.m_iTarget;
	if (IsValidEnemy(npc.index, target))
	{
		float vecMe[3], vecTarget[3];
		WorldSpaceCenter(npc.index, vecMe);
		WorldSpaceCenter(target, vecTarget);
		
		if (npc.m_flAttackHappenswillhappen)
		{
			if (npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime)
			{
				npc.FaceTowards(vecTarget, 15000.0);
				
				Handle swingTrace;
				if(npc.DoSwingTrace(swingTrace, target))
				{
					int targetHit = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if(targetHit > 0)
					{
						SDKHooks_TakeDamage(targetHit, npc.index, npc.index, 300.0, DMG_CLUB, -1, _, vecHit);
						ApplyStatusEffect(npc.index, targetHit, "Cudgelled", 3.0);
						Custom_Knockback(npc.index, targetHit, 450.0);
						
						if(targetHit <= MaxClients)
							Client_Shake(targetHit, 0, 25.0, 25.0, 0.5);
						
						npc.PlayMeleeHitSound();
					} 
				}
				
				delete swingTrace;
				
				npc.m_flNextMeleeAttack = gameTime + 3.0;
				npc.m_flAttackHappenswillhappen = false;
			}
			else if (npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen)
			{
				npc.m_flAttackHappenswillhappen = false;
				npc.m_flNextMeleeAttack = gameTime + 3.0;
			}
		}
		
		// ===== 시야 확인 (완화된 판정: 예전처럼 IsValidEnemy 기반) =====
		int seenTarget = Can_I_See_Enemy(npc.index, target);
		bool canSeeTarget = IsValidEnemy(npc.index, seenTarget);
		
		// 시야를 가로막은 게 "다른 유효한 적"이면, 억지로 원래 타겟(플레이어 등)을 보려다
		// 멈춰버리지 않도록 그 적으로 타겟을 전환한다. (근접공격 진행 중이면 스윙 대상은 유지)
		if (canSeeTarget && seenTarget != target)
		{
			target = seenTarget;
			npc.m_iTarget = seenTarget;
			canSeeTarget = true; // 이제 target == seenTarget 이므로 확실히 보임
		}
		else
		{
			canSeeTarget = (seenTarget == target);
		}
		
		npc.m_bCanSeeCurrentTarget = canSeeTarget;
		
		WorldSpaceCenter(target, vecTarget);
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
		
		bool inEngageRange = (flDistanceToTarget < 360000.0);
		bool weaponReady   = (npc.m_flReloadDelay < gameTime && npc.m_flNextRangedAttack < gameTime);
		
		if (flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime)
		{
			npc.m_iState = 3;
		}
		else if (inEngageRange)
		{
			if (!weaponReady)
			{
				// 재장전/쿨다운 중이면 LOS와 상관없이 무조건 제자리 조준 (이동 금지)
				npc.m_iState = 1;
			}
			else if (canSeeTarget)
			{
				npc.m_iState = 2;
			}
			else
			{
				// 사격 준비는 됐는데 완전히 안 보임(벽 등) -> 재배치 위해 이동
				npc.m_iState = 0;
			}
		}
		else
		{
			npc.m_iState = 0;
		}
		
		if (flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vecPredictedPos[3]; 
			PredictSubjectPosition(npc, target, _, _, vecPredictedPos);
			npc.SetGoalVector(vecPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(target);
		}
		
		// ===== 조준 모드(state 1/2) 여부에 따라 회전 방식 전환 =====
		bool wantAimMode = (npc.m_iState == 1 || npc.m_iState == 2);
		
		if (wantAimMode)
		{
			if (!npc.m_bAllowBackWalking)
			{
				npc.m_bAllowBackWalking = true;
				npc.m_flLastAimTurnTime = 0.0; // 조준 모드 진입 시 발 각도 스냅
			}
			
			float vecAng[3], vecDir[3];
			SubtractVectors(vecMe, vecTarget, vecDir); 
			NormalizeVector(vecDir, vecDir);
			GetVectorAngles(vecDir, vecAng);
			
			npc.m_flEyePitch = AngleNormalizeWithMod(vecAng[0]);
			npc.m_flEyeYaw   = AngleNormalizeWithMod(vecAng[1] + 180.0);
			
			npc.ComputePoseParam_AimPitch();
			npc.ComputePoseParam_AimYaw();
		}
		else
		{
			if (npc.m_bAllowBackWalking)
				npc.m_bAllowBackWalking = false;
			
			int m_iAimPitch = npc.LookupPoseParameter("aim_pitch");
			if (m_iAimPitch > -1)
			{
				npc.SetPoseParameter(m_iAimPitch, 0.0);
			}
			
			int m_iAimYaw = npc.LookupPoseParameter("aim_yaw");
			if (m_iAimYaw > -1)
			{
				npc.SetPoseParameter(m_iAimYaw, 0.0);
			}
		}
		
		switch (npc.m_iState)
		{
			case -1:
			{
				return;
			}
			case 0:
			{
				if(!npc.m_bPathing)
					npc.StartPathing();
					
				if(npc.m_iChanged_WalkCycle != 1)
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_RUN_AIM_AR2_STIMULATED");
					npc.m_flSpeed = 250.0;
					npc.StartPathing();
				}
			}
			case 1:
			{
				// 재장전 중 또는 사격 간격: 제자리에서 계속 정조준
				if(npc.m_bPathing)
					npc.StopPathing();
					
				if(npc.m_iChanged_WalkCycle != 2) 	
				{
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 2;
					npc.SetActivity("ACT_IDLE_ANGRY_AR2");
					npc.m_flSpeed = 0.0;
					npc.StopPathing();
				}
			}
			case 2:
			{
				if (npc.IsTargetInFiringCone(target))
				{
					if(npc.m_bPathing)
						npc.StopPathing();
						
					if(npc.m_iChanged_WalkCycle != 2) 	
					{
						npc.m_bisWalking = false;
						npc.m_iChanged_WalkCycle = 2;
						npc.SetActivity("ACT_IDLE_ANGRY_AR2");
						npc.m_flSpeed = 0.0;
						npc.StopPathing();
					}
					
					float vecSpread = 0.1;
					float x, y;
					x = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
					y = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
					
					float vecDirShooting[3], vecRight[3], vecUp[3];
					vecTarget[2] += 15.0;
					
					MakeVectorFromPoints(vecMe, vecTarget, vecDirShooting);
					GetVectorAngles(vecDirShooting, vecDirShooting);
					GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
					
					npc.m_flNextRangedAttack = gameTime + 0.35;
					npc.m_iAttacksTillReload -= 1;
					
					npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_AR2");
					
					float vecDirFire[3];
					vecDirFire[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
					vecDirFire[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
					vecDirFire[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
					NormalizeVector(vecDirFire, vecDirFire);
					
					int hitEnt = FireBullet(npc.index, npc.m_iWearable1, vecMe, vecDirFire, 50.0, 9000.0, DMG_BULLET, "bullet_tracer01_red");
					if (IsValidEnemy(npc.index, hitEnt))
					{
						ApplyStatusEffect(npc.index, hitEnt, "Silenced", 2.0);
					}
					
					npc.PlayRangedSound();
					
					if (npc.m_iAttacksTillReload == 0)
					{
						npc.AddGesture("ACT_RELOAD_AR2");
						npc.m_flReloadDelay = gameTime + 2.2;
						npc.m_iAttacksTillReload = 10;
						npc.PlayRangedReloadSound();
						
						if(npc.m_bPathing)
							npc.StopPathing();
						
						// 발이 아직 target 쪽으로 안 돌아온 짧은 순간: 조준 유지한 채 제자리 대기
						// (ConvergeYawAngles 회전속도가 빨라서 몇 틱 내에 해소됨. 여기서 멈추는 건 일시적)
						if(npc.m_iChanged_WalkCycle != 2) 	
						{
							npc.m_bisWalking = false;
							npc.m_iChanged_WalkCycle = 2;
							npc.SetActivity("ACT_IDLE_ANGRY_AR2");
							npc.m_flSpeed = 0.0;
							npc.StopPathing();
						}
					}
				}
				else
				{
					if(!npc.m_bPathing)
						npc.StartPathing();
					
					if(npc.m_iChanged_WalkCycle != 1)
					{
						npc.m_bisWalking = true;
						npc.m_iChanged_WalkCycle = 1;
						npc.SetActivity("ACT_RUN_AIM_AR2_STIMULATED");
						npc.m_flSpeed = 250.0;
						npc.StartPathing();
					}
				}
			}
			case 3:
			{
				if (!npc.m_flAttackHappenswillhappen)
				{
					npc.AddGestureViaSequence("MeleeAttack01");
					npc.PlayMeleeSound();
					npc.m_flAttackHappens = gameTime + 0.4;
					npc.m_flAttackHappens_bullshit = gameTime + 0.54;
					npc.m_flAttackHappenswillhappen = true;
				}
				
				if(!npc.m_bPathing)
					npc.StartPathing();
					
				if(npc.m_iChanged_WalkCycle != 1)
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_RUN_AIM_AR2_STIMULATED");
					npc.m_flSpeed = 250.0;
					npc.StartPathing();
				}
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_bCanSeeCurrentTarget = false;
		
		if (npc.m_bAllowBackWalking)
			npc.m_bAllowBackWalking = false;
	}
}

/*
static void CombinePretorianGuard_AttackThink(CombinePretorianGuard npc, int primaryThreatIndex)
{
	npc.PlayIdleAlertSound();
	
	float gameTime = GetGameTime(npc.index);
	
	if (npc.m_bStopMoving)
	{
		npc.SetActivity("ACT_IDLE_ANGRY_AR2");
		npc.m_bmovedelay = false;
	}
	else if (!npc.m_fbGunout && npc.m_flReloadDelay < gameTime)
	{
		if (!npc.m_bmovedelay)
		{
			npc.SetActivity("ACT_RUN_AIM_AR2_STIMULATED");
			npc.m_bmovedelay = true;
		}
	}
	else if (npc.m_fbGunout && npc.m_flReloadDelay < gameTime)
	{
		npc.SetActivity("ACT_IDLE_ANGRY_AR2");
		npc.m_bmovedelay = false;
	}
	
	float vecTarget[3];
	WorldSpaceCenter(primaryThreatIndex, vecTarget);
	
	float VecSelfNpc[3];
	WorldSpaceCenter(npc.index, VecSelfNpc);
	
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
	if (flDistanceToTarget < npc.GetLeadRadius() && flDistanceToTarget > 261144.0) {
		float vPredictedPos[3];
		PredictSubjectPosition(npc, primaryThreatIndex, _, _, vPredictedPos);
		npc.SetGoalVector(vPredictedPos);
		
		npc.m_bStopMoving = false;
	}
	else if (flDistanceToTarget < 262144.0) {
		npc.m_bStopMoving = true;
	}
	else {
		npc.SetGoalEntity(primaryThreatIndex);
		
		npc.m_bStopMoving = false;
	}
	
	if (npc.m_flNextRangedAttack < gameTime
		&& npc.m_flReloadDelay < gameTime
		&& flDistanceToTarget < 640000.0)
	{
		int target = Can_I_See_Enemy(npc.index, primaryThreatIndex);
		if (!IsValidEnemy(npc.index, primaryThreatIndex))
		{
			if (!npc.m_bmovedelay)
			{
				npc.SetActivity("ACT_RUN_AIM_AR2_STIMULATED");
				npc.m_bmovedelay = true;
			}
			npc.StartPathing();
			
			npc.m_fbGunout = false;
		}
		else {
			npc.m_fbGunout = true;
				
			WorldSpaceCenter(primaryThreatIndex, vecTarget);
			npc.FaceTowards(vecTarget, 10000.0);
			
			float vecSpread = 0.1;
			float eyePitch[3];
			GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
			
			float x, y;
			x = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
			y = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
			
			float vecDirShooting[3], vecRight[3], vecUp[3];
			
			vecTarget[2] += 15.0;
			float SelfVecPos[3]; WorldSpaceCenter(npc.index, SelfVecPos);
			MakeVectorFromPoints(SelfVecPos, vecTarget, vecDirShooting);
			GetVectorAngles(vecDirShooting, vecDirShooting);
			vecDirShooting[1] = eyePitch[1];
			GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
			
			float m_vecSrc[3];
			
			WorldSpaceCenter(npc.index, m_vecSrc);
			
			float vecEnd[3];
			vecEnd[0] = m_vecSrc[0] + vecDirShooting[0] * 9000; 
			vecEnd[1] = m_vecSrc[1] + vecDirShooting[1] * 9000;
			vecEnd[2] = m_vecSrc[2] + vecDirShooting[2] * 9000;
			
			npc.m_flNextRangedAttack = gameTime + 0.35;
			npc.m_iAttacksTillReload -= 1;
			
			if (npc.m_iAttacksTillReload == 0)
			{
				npc.AddGesture("ACT_RELOAD_AR2");
				npc.m_flReloadDelay = gameTime + 2.2;
				npc.m_iAttacksTillReload = 20;
				npc.PlayRangedReloadSound();
			}
			
			npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_AR2");
			float vecDir[3];
			vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
			vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
			vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
			NormalizeVector(vecDir, vecDir);
			float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
			
			target = FireBullet(npc.index, npc.m_iWearable1, WorldSpaceVec, vecDir, 50.0, 9000.0, DMG_BULLET, "bullet_tracer01_red");
			if (IsValidEnemy(npc.index, target))
			{
				ApplyStatusEffect(npc.index, target, "Silenced", 2.0);
			}
			
			npc.PlayRangedSound();
		}
	}
	
	if (npc.m_flReloadDelay < gameTime)
	{
		if (!npc.m_bStopMoving)
			npc.StartPathing();
		
		npc.m_fbGunout = false;
		
		if ((npc.m_flNextMeleeAttack < gameTime && flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED) || npc.m_flAttackHappenswillhappen)
		{
			if (!npc.m_flAttackHappenswillhappen)
			{
				npc.AddGestureViaSequence("MeleeAttack01");
				npc.PlayMeleeSound();
				npc.m_flAttackHappens = gameTime + 0.4;
				npc.m_flAttackHappens_bullshit = gameTime + 0.54;
				npc.m_flAttackHappenswillhappen = true;
			}
				
			if (npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen)
			{
				Handle swingTrace;
				npc.FaceTowards(vecTarget, 20000.0);
				if(npc.DoSwingTrace(swingTrace, primaryThreatIndex))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if(target > 0) 
					{
						SDKHooks_TakeDamage(target, npc.index, npc.index, 300.0, DMG_CLUB, -1, _, vecHit);
						ApplyStatusEffect(npc.index, target, "Cudgelled", 3.0);
						
						Custom_Knockback(npc.index, target, 250.0);
						
						npc.PlayMeleeHitSound();
						
						//Did we kill them?
						int iHealthPost = GetEntProp(target, Prop_Data, "m_iHealth");
						if(iHealthPost <= 0) 
						{
							//Yup, time to celebrate
							npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST");
						}
					} 
				}
				delete swingTrace;
				
				npc.m_flNextMeleeAttack = gameTime + 6.0;
				npc.m_flAttackHappenswillhappen = false;
			}
			else if (npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen)
			{
				npc.m_flAttackHappenswillhappen = false;
				npc.m_flNextMeleeAttack = gameTime + 6.0;
			}
		}
	}
}
*/

static void CombinePretorianGuard_NPCDeath(int entity)
{
	CombinePretorianGuard npc = view_as<CombinePretorianGuard>(entity);
	
	if (!npc.m_bGib)
		npc.PlayDeathSound();
	
	if (IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if (IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}

void ConvergeYawAngles( float flGoalYaw, float flYawRate, float flDeltaTime, float &flCurrentYaw )
{
	// Find the yaw delta.
	float flDeltaYaw = flGoalYaw - flCurrentYaw;
	float flDeltaYawAbs = FloatAbs( flDeltaYaw );
	flDeltaYaw = AngleNormalize( flDeltaYaw );

	// Always do at least a bit of the turn (1%).
	float flScale = 1.0;
	flScale = flDeltaYawAbs / 60.0;
	flScale = clamp( flScale, 0.01, 1.0 );

	float flYaw = flYawRate * flDeltaTime * flScale;
	if ( flDeltaYawAbs < flYaw )
	{
		flCurrentYaw = flGoalYaw;
	}
	else
	{
		float flSide = ( flDeltaYaw < 0.0 ) ? -1.0 : 1.0;
		flCurrentYaw += ( flYaw * flSide );
	}

	flCurrentYaw = AngleNormalize( flCurrentYaw );
}

stock float AngleNormalizeWithMod(float angle)
{
	angle = fmodf(angle, 360.0);
	if (angle > 180.0) angle -= 360.0;
	if (angle < -180.0) angle += 360.0;
	return angle;
}