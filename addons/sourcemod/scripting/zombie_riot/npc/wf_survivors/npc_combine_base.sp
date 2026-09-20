#pragma semicolon 1
#pragma newdecls required

char g_Combine_DeathSounds[][] = {
	"npc/metropolice/die1.wav",
	"npc/metropolice/die2.wav",
	"npc/metropolice/die3.wav",
	"npc/metropolice/die4.wav",
};

char g_Combine_HurtSounds[][] = {
	"npc/metropolice/pain1.wav",
	"npc/metropolice/pain2.wav",
	"npc/metropolice/pain3.wav",
};

char g_Combine_PickupTheCanSounds[][] = {
	"npc/metropolice/vo/putitinthetrash1.wav",
	"npc/metropolice/vo/putitinthetrash2.wav",
};

char g_Combine_SMG_AttackSounds[][] = {
	"weapons/smg1/smg1_fire1.wav",
};

char g_Combine_SMG_ReloadSound[][] = {
	"weapons/smg1/smg1_reload.wav",
};

char g_Combine_AR2_AttackSounds[][] = {
	"weapons/ar2/fire1.wav",
};

char g_Combine_AR2_ReloadSound[][] = {
	"weapons/ar2/npc_ar2_reload.wav",
};

char g_Combine_SwordAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};

char g_Combine_SwordHitSounds[][] = {	
	"weapons/blade_slice_2.wav",
	"weapons/blade_slice_3.wav",
	"weapons/blade_slice_4.wav",
};

char g_Combine_DefaultMeleeAttackSounds[][] = {
	"weapons/stunstick/stunstick_swing1.wav",
	"weapons/stunstick/stunstick_swing2.wav",
};

void Combine_Base_OnMapStart() {
	PrecacheSoundArray(g_Combine_DeathSounds);
	PrecacheSoundArray(g_Combine_HurtSounds);
	PrecacheSoundArray(g_Combine_PickupTheCanSounds);
	PrecacheSoundArray(g_Combine_SMG_AttackSounds);
	PrecacheSoundArray(g_Combine_SMG_ReloadSound);
	PrecacheSoundArray(g_Combine_AR2_AttackSounds);
	PrecacheSoundArray(g_Combine_AR2_ReloadSound);
	PrecacheSoundArray(g_Combine_SwordAttackSounds);
	PrecacheSoundArray(g_Combine_SwordHitSounds);
	PrecacheSoundArray(g_Combine_DefaultMeleeAttackSounds);
}

methodmap Combine_Base < CClotBody {
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
	
	// Alert!! Inverted pose parameter.
	public bool IsTargetInFiringCone(int target, float maxYawAngle = 20.0, float maxPitchAngle = 20.0, bool ignorePitch = false) {
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
			flViewYaw += this.GetPoseParameter(this.m_iBodyYawPoseParameter);
		}
		
		flViewYaw = UTIL_AngleNormalize(flViewYaw);
		
		float flTargetYaw = this.UTIL_VecToYaw(vecToTarget);
		
		float flYawDiff = MyAngleDiff(flTargetYaw, flViewYaw);
		
		if (FloatAbs(flYawDiff) > maxYawAngle) {
			return false;
		}
		
		// --- Pitch ---
		if (!ignorePitch && this.m_iBodyPitchPoseParameter > -1) {
			float vecDir[3], vecAng[3];
			SubtractVectors(vecMe, vecTarget, vecDir);
			NormalizeVector(vecDir, vecDir);
			GetVectorAngles(vecDir, vecAng);
			
			float flCurrentPitch = -this.GetPoseParameter(this.m_iBodyPitchPoseParameter);
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
			this.m_iBodyYawPoseParameter = this.LookupPoseParameter("aim_yaw");
		}
		
		if (this.m_iBodyPitchPoseParameter == -1) {
			this.m_iBodyPitchPoseParameter = this.LookupPoseParameter("aim_pitch");
		}
	}
	
	public void ResetBody() {
		this.m_iBodyYawPoseParameter = -1;
		this.m_iBodyPitchPoseParameter = -1;
		
		this.m_bPitchHandedOff = true;
		this.m_bYawHandedOff = true;
	}
	
	public void Update()
	{
		float flNextBotGroundSpeed;
		if(i_IsNpcType[this.index] != 1)
		{
			if (this.m_iPoseMoveX == 0)   
			{
				this.m_iPoseMoveX = this.LookupPoseParameter("move_x");
			}
			if (this.m_iPoseMoveY == 0)  
			{
				this.m_iPoseMoveY = this.LookupPoseParameter("move_y");
			}
			if (this.m_iPose_MoveYaw == 0) 
			{
				this.m_iPose_MoveYaw = this.LookupPoseParameter("move_yaw");
			}
			if (this.m_iPose_MoveScale == 0) 
			{
				this.m_iPose_MoveScale = this.LookupPoseParameter("move_scale");
			}
			
			flNextBotGroundSpeed = this.GetGroundSpeed();
			
			if (flNextBotGroundSpeed < 0.01) 
			{
				if (this.m_iPoseMoveX != -1) 
				{
					this.SetPoseParameter(this.m_iPoseMoveX, 0.0);
				}
				if (this.m_iPoseMoveY != -1) 
				{
					this.SetPoseParameter(this.m_iPoseMoveY, 0.0);
				}
				if (this.m_iPose_MoveYaw != -1) 
				{
					this.SetPoseParameter(this.m_iPose_MoveYaw, 0.0);
				}
				if (this.m_iPose_MoveScale != -1) 
				{
					this.SetPoseParameter(this.m_iPose_MoveScale, 0.0);
				}
			}
			else 
			{
				float vecFwd[3], vecRight[3], vecUp[3];
				this.GetVectors(vecFwd, vecRight, vecUp);
				
				float vecMotion[3]; this.GetGroundMotionVector(vecMotion);
			
				if (this.m_iPoseMoveX != -1) 
				{
					this.SetPoseParameter(this.m_iPoseMoveX, GetVectorDotProduct(vecMotion, vecFwd));
				}
				if (this.m_iPoseMoveY != -1) 
				{
					this.SetPoseParameter(this.m_iPoseMoveY, GetVectorDotProduct(vecMotion, vecRight));
				}
				if (this.m_iPose_MoveYaw != -1) 
				{
					float flYaw = RadToDeg(
						ArcTangent2(
							GetVectorDotProduct(vecMotion, vecRight),
							GetVectorDotProduct(vecMotion, vecFwd)
						)
					);
					
					if (this.m_bAllowBackWalking)
						flYaw = -flYaw;
					
					this.SetPoseParameter(this.m_iPose_MoveYaw, flYaw);
				}
			}
			this.GetBaseNPC().flRunSpeed = this.GetRunSpeed();
			this.GetBaseNPC().flWalkSpeed = this.GetRunSpeed();
		}

		if(f_TimeFrozenStill[this.index] && f_TimeFrozenStill[this.index] < GetGameTime(this.index))
		{
			// Was frozen before, reset layers
			int layerCount = this.GetNumAnimOverlays();
			for(int i; i < layerCount; i++)
			{
				//we lazely use ReturnEntityAttackspeed(this.index)
				view_as<CClotBody>(this.index).SetLayerPlaybackRate(i, ReturnEntityAttackspeed(this.index));
			}
			view_as<CClotBody>(this.index).SetPlaybackRate(f_LayerSpeedFrozeRestore[this.index], true);

			if(IsValidEntity(view_as<CClotBody>(this.index).m_iFreezeWearable))
				RemoveEntity(view_as<CClotBody>(this.index).m_iFreezeWearable);

			f_TimeFrozenStill[this.index] = 0.0;
		}
		
		if(this.m_bisWalking && i_IsNpcType[this.index] != 1) //This exists to make sure that if there is any idle animation played, it wont alter the playback rate and keep it at a flat 1, or anything altered that the user desires.
		{
			float m_flGroundSpeed = GetEntPropFloat(this.index, Prop_Data, "m_flGroundSpeed");
			if (this.m_iPose_MoveScale != -1)
			{
				//robots use this wierdly enough.
				m_flGroundSpeed = 300.0;
			}
			
			if(m_flGroundSpeed != 0.0)
			{
				float PlaybackSpeed = clamp((flNextBotGroundSpeed / m_flGroundSpeed), -4.0, 12.0);
				if (this.m_iPose_MoveScale != -1)
				{
					//how much they move
					this.SetPoseParameter(this.m_iPose_MoveScale, (clamp((PlaybackSpeed), 0.0, 1.0)));
				}
				if(PlaybackSpeed > f_MaxAnimationSpeed[this.index])
					PlaybackSpeed = f_MaxAnimationSpeed[this.index];
				
				if(PlaybackSpeed <= 0.01)
					PlaybackSpeed = 0.01;
				
				this.SetPlaybackRate(PlaybackSpeed, true);
			}
			else
			{
				//if its lower then this value, then itll mess up and particles wont animate.
				this.SetPlaybackRate(0.01, true);
			}
		}
		
		//Run and StuckMonitor
		if(i_IsNpcType[this.index] != 1)
		{
			if(this.m_flNextRunTime < GetGameTime())
			{
				this.m_flNextRunTime = GetGameTime() + 0.15; //Only update every 0.1 seconds, we really dont need more, 
				this.GetLocomotionInterface().Run();
			}
			
			if(this.m_bAllowBackWalking)
			{
				this.GetBaseNPC().flMaxYawRate = 0.0;
			}
			else
			{
				this.GetBaseNPC().flMaxYawRate = (NPC_DEFAULT_YAWRATE * this.GetDebuffPercentage() * f_NpcTurnPenalty[this.index]);
			}
			
			if(f_AvoidObstacleNavTime[this.index] < GetGameTime()) //add abit of delay for optimisation
			{
				CNavArea areaNavget;
				CNavArea areaNavget2;
				Segment segment;
				Segment segment2;
				segment = this.GetPathFollower().FirstSegment();
				if(segment != NULL_PATH_SEGMENT)
				{
					segment2 = this.GetPathFollower().NextSegment(segment);
					segment2 = this.GetPathFollower().NextSegment(segment2);
				}

				if(segment != NULL_PATH_SEGMENT && segment2 != NULL_PATH_SEGMENT)
				{
					areaNavget = segment.area;
					areaNavget2 = segment2.area;
				}

				b_AvoidObstacleType[this.index] = false;
				
				if(areaNavget != NULL_AREA && areaNavget2 != NULL_AREA)
				{
					int NavAttribs = areaNavget.GetAttributes();
					int NavAttribs2 = areaNavget2.GetAttributes();
					if(NavAttribs & NAV_MESH_WALK || NavAttribs2 & NAV_MESH_WALK)
					{
						b_AvoidObstacleType[this.index] = true;
					}
					if(NavAttribs & NAV_MESH_JUMP && NavAttribs2 & NAV_MESH_JUMP)
					{
						//They are in some position where we need to jump, lets jump.
						if(this.m_flJumpStartTimeInternal < GetGameTime())
						{
							this.m_flJumpStartTimeInternal = GetGameTime() + 2.0;
							float VecPos[3];
							areaNavget2.GetCenter(VecPos);
							PluginBot_Jump(this.index,VecPos);
						}
					}
				}
				f_AvoidObstacleNavTime[this.index] = GetGameTime() + 0.1;
			}

			//increase the size of the avoid box by 2x

			int IgnoreObstacles = 0;

			if(b_AvoidObstacleType_Time[this.index] > GetGameTime())
				IgnoreObstacles = 1;

			if(b_AvoidObstacleType[this.index])
				IgnoreObstacles = 2;
			
			if((VIPBuilding_Active() && GetTeam(this.index) != TFTeam_Red))
				IgnoreObstacles = 2;
			
			if(IgnoreObstacles == 0)
			{
				float ModelSize = GetEntPropFloat(this.index, Prop_Send, "m_flModelScale");
				//avoid obstacle code scales with modelsize, we dont want that.
				float f3_AvoidModifMax[3];
				float f3_AvoidModifMin[3];

				for(int axis; axis < 3; axis++)
				{
					f3_AvoidModifMax[axis] = f3_AvoidOverrideMax[this.index][axis];
					f3_AvoidModifMin[axis] = f3_AvoidOverrideMin[this.index][axis];
					f3_AvoidModifMax[axis] /= ModelSize;
					f3_AvoidModifMin[axis] /= ModelSize;
					if(this.m_bIsGiant) //giants need abit more space.
					{
						f3_AvoidModifMax[axis] *= 1.35;
						f3_AvoidModifMin[axis] *= 1.35;
					}
				}
				this.GetBaseNPC().SetBodyMaxs(f3_AvoidModifMax);
				this.GetBaseNPC().SetBodyMins(f3_AvoidModifMin);	
			}
			else
			{
				if(IgnoreObstacles == 2)
				{
					//was in obstacle avoid before, reuse.
					//some stairs really dont like navs, so they think they are on no nav and then try to avoid stairs, oof!
					//this is a good solution, if any stairs are bigger

					//unused.
					b_AvoidObstacleType_Time[this.index] = GetGameTime() + 0.0;
				}
				//if in tower defense, never avoid.
				this.GetBaseNPC().SetBodyMaxs({1.0,1.0,1.0});
				this.GetBaseNPC().SetBodyMins({0.0,0.0,0.0});
			}
			
			if(VIPBuilding_Active() && GetTeam(this.index) != TFTeam_Red)
			{
				if(f_UnstuckSuckMonitor[this.index] < GetGameTime())
				{
					this.GetLocomotionInterface().ClearStuckStatus("UN-STUCK");
					f_UnstuckSuckMonitor[this.index] = GetGameTime() + 1.0;
				}
			}

			if(this.m_bPathing)
			{
				this.GetPathFollower().Update(this.GetBot());
			}

			this.GetBaseNPC().SetBodyMaxs(f3_AvoidOverrideMaxNorm[this.index]);
			this.GetBaseNPC().SetBodyMins(f3_AvoidOverrideMinNorm[this.index]);	
		}
	}
	
	public void UpdateBody() {
		float gameTime = GetGameTime(this.index);
		float flDeltaTime = (this.m_flLastBodyUpdateTime > 0.0) ? (gameTime - this.m_flLastBodyUpdateTime) : 0.05;
		this.m_flLastBodyUpdateTime = gameTime;
		
		if (flDeltaTime <= 0.0 || flDeltaTime > 0.5)
			flDeltaTime = 0.05;
		
		bool bCantSeeTarget = !IsValidEnemy(this.index, this.m_iTarget) || !Can_I_See_Enemy_Only(this.index, this.m_iTarget);
		if (this.m_bPathing && bCantSeeTarget) {
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
			
			return;
		}
		
		if (this.m_iBodyPitchPoseParameter < 0 && this.m_iBodyYawPoseParameter < 0)
			return;
		
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
			
			float flBodyPitch = -clamp(vecAng[0], -56.2, 88.9);
			
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
			
			// Yeah. combine pose param is inverted.
			float relativeYaw = MyAngleDiff(vecAng[1], angRotation[1]);
			
			// 돌아야 할 각도가 40도를 넘으면 body_yaw 포즈파라미터를 0으로 풀어준다.
			if (relativeYaw > 40.0 || relativeYaw < -40.0) {
				float flYaw = this.GetPoseParameter(this.m_iBodyYawPoseParameter);
				
				if (FloatAbs(flYaw) > 0.1) {					
					float flCurrentFacingYaw = angRotation[1] - flYaw;
					
					float flMaxYawRate = this.GetBaseNPC().flMaxYawRate;
					float flMaxTurnThisFrame = flMaxYawRate * flDeltaTime;
					
					float flReleaseAmount;
					
					bool bAimTargetFresh = (gameTime - this.m_flAimTargetSetTime) <= 0.25;
					
					if (!IsValidEntity(this.m_iTarget) || !bAimTargetFresh) {
						flReleaseAmount = fmin(FloatAbs(flYaw), flMaxTurnThisFrame);
					}
					else {
						float vecAimTarget[3];
						this.GetAimTarget(vecAimTarget);
						
						float vecAimDir[3], vecAimAng[3];
						SubtractVectors(vecAimTarget, vecMe, vecAimDir);
						NormalizeVector(vecAimDir, vecAimDir);
						GetVectorAngles(vecAimDir, vecAimAng);
						
						// pose param으로 추정한 "현재 실제 방향" 기준, 조준 목표까지 얼마나 남았는지
						float flAimRelativeYaw = MyAngleDiff(vecAimAng[1], flCurrentFacingYaw);
						
						flReleaseAmount = fmin(FloatAbs(flYaw), fmin(flMaxTurnThisFrame, FloatAbs(flAimRelativeYaw)));
					}
					
					if (flReleaseAmount < 0.1)
						flReleaseAmount = 0.1; // 완전히 멈춰버리지 않도록 최소 진행 보장
					
					this.SetPoseParameter(
						this.m_iBodyYawPoseParameter,
						ApproachAngle(0.0, flYaw, flReleaseAmount)
					);
				}
				
				// We don't wanna set aim target while moving.
				if (!this.m_bPathing || this.m_bAllowBackWalking) {
					this.SetAimTarget(vecTarget);
					this.m_flAimTargetSetTime = gameTime; // 타임스탬프 갱신
					this.GetLocomotionInterface().FaceTowards(vecTarget);
				}
			}
			else {
				float flYaw = this.GetPoseParameter(this.m_iBodyYawPoseParameter);
				
				float bodyYaw = clamp(relativeYaw, -39.9, 39.9);
				
				this.SetPoseParameter(
					this.m_iBodyYawPoseParameter,
					ApproachAngle(bodyYaw, flYaw, ALT_EXTRA_BODY_YAW_TRACK_SPEED * flDeltaTime)
				);
			}
			
			this.m_bYawHandedOff = false;
		}
		else {
			if (!this.m_bPathing || this.m_bAllowBackWalking) {
				this.SetAimTarget(vecTarget);
				this.m_flAimTargetSetTime = gameTime; // 타임스탬프 갱신
				this.GetLocomotionInterface().FaceTowards(vecTarget);
			}
		}
	}
	
	/*
	public void UpdateBody() {
		float gameTime = GetGameTime(this.index);
		float flDeltaTime = (this.m_flLastBodyUpdateTime > 0.0) ? (gameTime - this.m_flLastBodyUpdateTime) : 0.05;
		this.m_flLastBodyUpdateTime = gameTime;
		
		if (flDeltaTime <= 0.0 || flDeltaTime > 0.5)
			flDeltaTime = 0.05;
		
		bool bCantSeeTarget = !IsValidEnemy(this.index, this.m_iTarget) || !Can_I_See_Enemy_Only(this.index, this.m_iTarget);
		if (this.m_bPathing && bCantSeeTarget) {
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
			
			return;
		}
		
		if (this.m_iBodyPitchPoseParameter < 0 && this.m_iBodyYawPoseParameter < 0)
			return;
		
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
			
			float flBodyPitch = -clamp(vecAng[0], -56.2, 88.9);
			
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
			
			// Yeah. combine pose param is inverted.
			float relativeYaw = MyAngleDiff(vecAng[1], angRotation[1]);
			
			if (relativeYaw > 45.0 || relativeYaw < -45.0) {
				float flYaw = this.GetPoseParameter(this.m_iBodyYawPoseParameter);
				
				if (FloatAbs(flYaw) > 0.1) {
					this.SetPoseParameter(
						this.m_iBodyYawPoseParameter,
						ApproachAngle(0.0, flYaw, ALT_EXTRA_BODY_YAW_UNTWIST_SPEED * flDeltaTime)
					);
				}
				
				// We don't wanna set aim target while moving.
				if (!this.m_bPathing || this.m_bAllowBackWalking) {
					this.SetAimTarget(vecTarget);
					this.GetLocomotionInterface().FaceTowards(vecTarget);
				}
			}
			else {
				float flYaw = this.GetPoseParameter(this.m_iBodyYawPoseParameter);
				
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
				this.SetAimTarget(vecTarget);
				this.GetLocomotionInterface().FaceTowards(vecTarget);
			}
		}
	}
	*/
	
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
	
	public void SetAimTarget(const float vec[3]) {
		this.SetPropVector(Prop_Data, "m_vecAimTarget", vec);
	}
	
	public void GetAimTarget(float vec[3]) {
		this.GetPropVector(Prop_Data, "m_vecAimTarget", vec);
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
	
	property float m_flAimTargetSetTime {
		public get()			{ return this.GetPropFloat(Prop_Data, "m_flAimTargetSetTime"); }
		public set(float value)	{ this.SetPropFloat(Prop_Data, "m_flAimTargetSetTime", value); }
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

/**
 * This is literally same as ArcToLocationViaSpeedProjectile.
 * But this one require vecStart instead projectile. So you can simulate speed.
 */
stock void ArcToLocationViaSpeedSimulation(const float vecStart[3], float vecEnd[3], float vecVelocity[3], float flTimeUntilReachToDest = 1.0, float flGravityChange = 1.0) {
	float vecJumpVel[3];
	
	float gravity;
	if (gravity <= 0.0)
		gravity = FindConVar("sv_gravity").FloatValue;
	
	gravity *= flGravityChange;
	
	// How fast does the headcrab need to travel to reach the position given gravity?
	float flActualHeight = vecEnd[2] - vecStart[2];
	float height = flActualHeight;
	
	if (height < 0.0) {
		//tickrate gravity downwards is bad.
		gravity *= TickrateModify;
		if (height >= -20.0) {
			height = -20.0;
		}
	}
	else {
		//invert for gravity the otherway
		gravity *= (((TickrateModify - 1.0) * -1.0) + 1.0);
		if (height <= 20.0) {
			height = 20.0;
		}
	}
	
	float speed = SquareRoot( 2.0 * gravity * fabs(height) );
	float time = speed / gravity;
	
	time += SquareRoot( (2.0 * fabs(height)) / gravity );
	
	time *= flTimeUntilReachToDest;
	speed *= flTimeUntilReachToDest;
	
	// Scale the sideways velocity to get there at the right time
	SubtractVectors( vecEnd, vecStart, vecJumpVel );
	vecJumpVel[0] /= time;
	vecJumpVel[1] /= time;
	vecJumpVel[2] /= time;
	
	// Speed to offset gravity at the desired height.
	vecJumpVel[2] = speed;
	
	vecVelocity = vecJumpVel;
}