#pragma semicolon 1
#pragma newdecls required

methodmap CBotBody < IBody {
	public CBotBody(IBody body)
    {
        return view_as<CBotBody>(body);
    }
	
	public static float GetHeadAimTrackingInterval()
	{
		return 0.5;
	}
	
	public void AimHeadTowardsTarget(int target, int priority, float duration)
    {
        INextBot bot = this.GetBot();
        CBaseEntity ent = CBaseEntity(bot.GetEntity());
		
        if (duration <= 0.0)
            duration = 0.1;

        if (ent.GetProp(Prop_Data, "m_iLookAtPriority") > priority && ent.GetPropFloat(Prop_Data, "m_flLookAtExpireTimer") > GetGameTime())
        {
            return;
        }

        ent.SetPropEnt(Prop_Data, "m_hTarget", target);

        ent.SetPropFloat(Prop_Data, "m_flLookAtExpireTimer", GetGameTime() + duration);

        ent.SetProp(Prop_Data, "m_iLookAtPriority", priority);
        ent.SetPropFloat(Prop_Data, "m_flLookAtDurationTimer", GetGameTime());
        ent.SetProp(Prop_Data, "m_bHasBeenSightedIn", false);
    }

    public void AimHeadTowards(float pos[3], int priority, float duration)
    {
        INextBot bot = this.GetBot();
        CBaseEntity ent = CBaseEntity(bot.GetEntity());

        if (duration <= 0.0)
            duration = 0.1;

        if (ent.GetProp(Prop_Data, "m_iLookAtPriority") > priority && ent.GetPropFloat(Prop_Data, "m_flLookAtExpireTimer") > GetGameTime())
        {
            return;
        }

        ent.SetPropVector(Prop_Data, "m_vecLookAtPos", pos);
        ent.SetPropEnt(Prop_Data, "m_hTarget", -1);

        ent.SetPropFloat(Prop_Data, "m_flLookAtExpireTimer", GetGameTime() + duration);

        ent.SetProp(Prop_Data, "m_iLookAtPriority", priority);
        ent.SetPropFloat(Prop_Data, "m_flLookAtDurationTimer", GetGameTime());
        ent.SetProp(Prop_Data, "m_bHasBeenSightedIn", false);
    }

    public bool IsHeadAimingOnTarget()
    {
        INextBot bot = this.GetBot();
        CBaseEntity ent = CBaseEntity(bot.GetEntity());
        return ent.HasProp(Prop_Data, "m_bIsSightedIn") && ent.GetProp(Prop_Data, "m_bIsSightedIn");
    }

    //BUG: Sometimes it fails and return -1, despite the threat and bot see each other perfectly
    public bool IsAbleToSeeTarget(int threat, float buffer[3] = NULL_VECTOR)
    {
        INextBot bot = this.GetBot();
        float vecEyePos[3];
        this.GetEyePositionEx(vecEyePos);

        float vecTargetPos[3];
        CBaseAnimating(threat).WorldSpaceCenter(vecTargetPos);

        Handle hTrace = TR_TraceRayFilterEx(vecEyePos, vecTargetPos, (MASK_SOLID|CONTENTS_HITBOX), RayType_EndPoint, Filter_WorldOnly, bot.GetEntity());

        if (TR_GetFraction(hTrace) < 1.0)
        {
            if (TR_GetEntityIndex(hTrace) == -1)
            {
                delete hTrace;
                return false;
            }
        }

        int iTraceTarget = TR_GetEntityIndex(hTrace);
        delete hTrace;

        //We still don't see our threat (his center), if threat is a player, let's look a little bit up to their eyes
        if (iTraceTarget <= 0 && threat > 0 && threat <= MaxClients)
        {
            float vecTargetEyePos[3];
            GetClientEyePosition(threat, vecTargetEyePos);
            hTrace = TR_TraceRayFilterEx(vecEyePos, vecTargetEyePos, (MASK_SOLID|CONTENTS_HITBOX), RayType_EndPoint, Filter_WorldOnly, bot.GetEntity());

            iTraceTarget = TR_GetEntityIndex(hTrace);
            delete hTrace;

            if (iTraceTarget > 0 && iTraceTarget == threat)
                vecTargetPos = vecTargetEyePos;
        }

        //We still don't see our threat, maybe because our m_flEyePosHeight is too high, use our body center for aim
        //if (iTraceTarget <= 0)
        //{
        //    CBaseAnimating(bot.GetEntity()).WorldSpaceCenter(vecEyePos);
        //    hTrace = TR_TraceRayFilterEx(vecEyePos, vecTargetPos, (MASK_SOLID|CONTENTS_HITBOX), RayType_EndPoint, Filter_WorldOnly, ////bot.GetEntity());
        //
        //}

        if (iTraceTarget == -1)
        {
            this.HandleFailedTraces();

            //int iNum = this.GetNumOfFailedTraces();
            //PrintCenterTextAll("Failed trace -1 num %i", iNum);

            if (this.GetNumOfFailedTraces() < 11)
            {
                if (!IsNullVector(buffer))
                    buffer = vecTargetPos;
                return true;
            }
        }
        else
        {
            this.ResetFailedTraces();
        }

        if (!IsNullVector(buffer))
            buffer = vecTargetPos;

        return iTraceTarget == threat;
    }

    public bool IsEyePositionInFloor(float buffer[3])
    {
        INextBot bot = this.GetBot();
        CBaseEntity ent = CBaseEntity(bot.GetEntity());
        float vecEyePos[3];
        this.GetEyePositionWithHeight(vecEyePos);

        bool bHit = false;

        if (ent.HasProp(Prop_Data, "m_flEyePosHeight"))
        {
            float vecDir[3], vecCenter[3];
            ent.WorldSpaceCenter(vecCenter);
            vecDir = vecCenter;
            vecDir[2] += ent.GetPropFloat(Prop_Data, "m_flEyePosHeight");

            Handle hCheckHeightTrace = TR_TraceRayFilterEx(vecCenter, vecDir, (MASK_SOLID|CONTENTS_HITBOX), RayType_EndPoint, Filter_WorldOnly, bot.GetEntity());

            float vecEndPos[3];
            bHit = TR_DidHit(hCheckHeightTrace);
            //int iTraceTarget = TR_GetEntityIndex(hCheckHeightTrace);
            TR_GetEndPosition(vecEndPos, hCheckHeightTrace);
            delete hCheckHeightTrace;

#if defined DEBUG_BOT_BODY
            int iColour2[4];
            iColour2[0] = 0;
            iColour2[1] = 0;
            iColour2[2] = 255;
            iColour2[3] = 255;

            TE_SetupBeamPoints(vecCenter, vecEndPos, PrecacheModel("materials/sprites/physbeam.vmt"), PrecacheModel("materials/sprites/halo01.vmt"), 0, 15, 0.1, 1.0, 1.0, 1, 0.0, iColour2, 10);
            TE_SendToAll();
#endif
			
            //We hit a wall under our head or our eyes in a floor, we will lower it
            if (bHit)
            {
                vecEyePos = vecEndPos;
                vecEyePos[2] -= 10.0;
                //this.GetEyePosition(vecEyePos);
            }
        }

        if (!IsNullVector(buffer))
            buffer = vecEyePos;

        return bHit;
    }

    //HACK: For some reason, if we call TR_TraceRayFilterEx too much, trace can return -1, despite bot and threat see each other perfectly
    //Usually this happens if out threat rotates too much
    //I double checked that WorldSpaceCenter() is correct
    public void HandleFailedTraces()
    {
        INextBot bot = this.GetBot();
        if (HasEntProp(bot.GetEntity(), Prop_Data, "m_iNumOfFailedTraces"))
        {
            SetEntProp(bot.GetEntity(), Prop_Data, "m_iNumOfFailedTraces", GetEntProp(bot.GetEntity(), Prop_Data, "m_iNumOfFailedTraces") + 1);
        }
    }

    public int GetNumOfFailedTraces()
    {
        INextBot bot = this.GetBot();
        if (!HasEntProp(bot.GetEntity(), Prop_Data, "m_iNumOfFailedTraces"))
            return 0;
        return GetEntProp(bot.GetEntity(), Prop_Data, "m_iNumOfFailedTraces");
    }

    public void ResetFailedTraces()
    {
        INextBot bot = this.GetBot();
        if (HasEntProp(bot.GetEntity(), Prop_Data, "m_iNumOfFailedTraces"))
        {
            SetEntProp(bot.GetEntity(), Prop_Data, "m_iNumOfFailedTraces", 0);
        }
    }

    //TODO: Move to CBotVision and add Ex to function name (Because of methodmap IVIsion)
    public bool IsLineOfSightClearToEntity(int threat, float buffer[3] = NULL_VECTOR)
    {
        INextBot bot = this.GetBot();
        float vecEyePos[3];
        this.GetEyePositionEx(vecEyePos);

        float vecTargetPos[3];
        CBaseAnimating(threat).WorldSpaceCenter(vecTargetPos);

        Handle hTrace = TR_TraceRayFilterEx(vecEyePos, vecTargetPos, (MASK_SOLID|CONTENTS_HITBOX), RayType_EndPoint, Filter_WorldOnly, bot.GetEntity());

        if (TR_GetFraction(hTrace) < 1.0)
        {
            if (TR_GetEntityIndex(hTrace) == -1)
            {
                delete hTrace;
                return false;
            }
        }

        int iTraceTarget = TR_GetEntityIndex(hTrace);
        delete hTrace;

        if (iTraceTarget <= 0 && threat > 0 && threat <= MaxClients)
        {
            GetClientEyePosition(threat, vecTargetPos);
            hTrace = TR_TraceRayFilterEx(vecEyePos, vecTargetPos, (MASK_SOLID|CONTENTS_HITBOX), RayType_EndPoint, Filter_WorldOnly, bot.GetEntity());

            iTraceTarget = TR_GetEntityIndex(hTrace);
            delete hTrace;
        }

        if (iTraceTarget == -1)
        {
            this.HandleFailedTraces();

            //int iNum = this.GetNumOfFailedTraces();
            //PrintCenterTextAll("Failed trace -1 num %i", iNum);

            if (this.GetNumOfFailedTraces() < 11)
            {
                if (!IsNullVector(buffer))
                    buffer = vecTargetPos;
                return true;
            }
        }
        else
        {
            this.ResetFailedTraces();
        }

        if (!IsNullVector(buffer))
            buffer = vecTargetPos;

        return iTraceTarget == threat;
    }

    public void LookAtPos(float goal[3], float aimSpeed = 0.05)
    {
        INextBot bot = this.GetBot();

        float vecPos[3];
        this.GetEyePositionEx(vecPos);

        float angView[3];
        CBaseEntity(bot.GetEntity()).GetPropVector(Prop_Data, "m_angCurrentAngles", angView);

        float vecDir[3];
        MakeVectorFromPoints(vecPos, goal, vecDir);
        GetVectorAngles(vecDir, vecDir);

        angView[0] += AngleNormalize(vecDir[0] - angView[0]) * aimSpeed;
        angView[1] += AngleNormalize(vecDir[1] - angView[1]) * aimSpeed;

        angView[0] = AngleNormalize(angView[0]);
        angView[1] = AngleNormalize(angView[1]);

        CBaseEntity(bot.GetEntity()).SetPropVector(Prop_Data, "m_angCurrentAngles", angView);
    }

    public void UpdateAnimationYaw()
    {
        INextBot bot = this.GetBot();
        CBaseCombatCharacter anim = CBaseCombatCharacter(bot.GetEntity());
        ILocomotion loco = bot.GetLocomotionInterface();
        float vecMotion[3];
        loco.GetGroundMotionVector(vecMotion);

        float angRot[3];
        GetEntPropVector(bot.GetEntity(), Prop_Data, "m_angRotation", angRot);

        float flMoveYaw = VecToYaw(vecMotion);
        float flDiff = AngleDiff(flMoveYaw, VecAxis(angRot, 1));
        anim.SetPoseParameter(anim.LookupPoseParameter("move_yaw"), flDiff);
    }

    //TODO: Replace m_vecOrigin with eye pos
    public void UpdateBodyAimPitchYaw()
    {
        INextBot bot = this.GetBot();
        int iTarget = CBaseEntity(bot.GetEntity()).GetPropEnt(Prop_Data, "m_hLookAtSubject");

        if (iTarget <= 0)
            iTarget = CBaseEntity(bot.GetEntity()).GetPropEnt(Prop_Data, "m_hTarget");

        if (iTarget <= 0)
        {
            CBaseCombatCharacter anim = CBaseCombatCharacter(bot.GetEntity());

            int iPitch = anim.LookupPoseParameter("aim_pitch");

            anim.SetPoseParameter(iPitch, 0.0);
            return;
        }

        CBaseCombatCharacter anim = CBaseCombatCharacter(bot.GetEntity());

        float v[3], ang[3], vecTargetPos[3], vecMyPos[3];
        GetEntPropVector(iTarget, Prop_Send, "m_vecOrigin", vecTargetPos);
        GetEntPropVector(bot.GetEntity(), Prop_Send, "m_vecOrigin", vecMyPos);

        SubtractVectors(vecTargetPos, vecMyPos, v);
        NormalizeVector(v, v);
        GetVectorAngles(v, ang);

        int iPitch = anim.LookupPoseParameter("aim_pitch");

        if (ang[0] > 180.0)
            ang[0] -= 360.0;

        if (ang[0] > 90.0)
            ang[0] = 90.0;
        else if (ang[0] < -90.0)
            ang[0] = -90.0;

        anim.SetPoseParameter(iPitch, ang[0]);
        //anim.SetPoseParameter(anim.LookupPoseParameter("aim_yaw"), ang[1]);
    }

    public void UpdateAnimationXY()
	{
		INextBot bot = this.GetBot();
		int ent = bot.GetEntity();
		CBaseNPC npc = TheNPCs.FindNPCByEntIndex(ent);
		CBaseCombatCharacter pCC = CBaseCombatCharacter(ent);
		NextBotGroundLocomotion loco = npc.GetLocomotion();

		int m_moveXPoseParameter = GetEntProp(ent, Prop_Data, "m_moveXPoseParameter");
		if ( m_moveXPoseParameter < 0 )
		{
			m_moveXPoseParameter = pCC.LookupPoseParameter( "move_x" );
			SetEntProp(ent, Prop_Data, "m_moveXPoseParameter", m_moveXPoseParameter);
		}

		int m_moveYPoseParameter = GetEntProp(ent, Prop_Data, "m_moveYPoseParameter");
		if ( m_moveYPoseParameter < 0 )
		{
			m_moveYPoseParameter = pCC.LookupPoseParameter( "move_y" );
			SetEntProp(ent, Prop_Data, "m_moveYPoseParameter", m_moveYPoseParameter);
		}

        if (HasEntProp(ent, Prop_Data, "m_idleSequence"))
        {
            int m_idleSequence = GetEntProp(ent, Prop_Data, "m_idleSequence");
            if (m_idleSequence < 0)
            {
                m_idleSequence = pCC.SelectWeightedSequence(ACT_MP_STAND_MELEE);
                SetEntProp(ent, Prop_Data, "m_idleSequence", m_idleSequence);
            }
		}

        if (HasEntProp(ent, Prop_Data, "m_runSequence"))
        {
            int m_runSequence = GetEntProp(ent, Prop_Data, "m_runSequence");
            if (m_runSequence < 0)
            {
                m_runSequence = pCC.SelectWeightedSequence(ACT_MP_RUN_MELEE);
                SetEntProp(ent, Prop_Data, "m_runSequence", m_runSequence);
            }
		}

        if (HasEntProp(ent, Prop_Data, "m_airSequence"))
        {
            int m_airSequence = GetEntProp(ent, Prop_Data, "m_airSequence");
            if (m_airSequence < 0)
            {
                m_airSequence = pCC.SelectWeightedSequence(ACT_MP_JUMP_FLOAT_MELEE);
                SetEntProp(ent, Prop_Data, "m_airSequence", m_airSequence);
            }
		}

		float speed = loco.GetGroundSpeed();

		if ( speed < 0.01 )
		{
			// stopped
			if ( m_moveXPoseParameter >= 0 )
			{
				pCC.SetPoseParameter( m_moveXPoseParameter, 0.0 );
			}

			if ( m_moveYPoseParameter >= 0 )
			{
				pCC.SetPoseParameter( m_moveYPoseParameter, 0.0 );
			}
		}
		else
		{
			float fwd[3], right[3], up[3];
			pCC.GetVectors( fwd, right, up );

			float motionVector[3];
			loco.GetGroundMotionVector(motionVector);

			// move_x == 1.0 at full forward motion and -1.0 in full reverse
			if ( m_moveXPoseParameter >= 0 )
			{
				float forwardVel = GetVectorDotProduct( motionVector, fwd );

				pCC.SetPoseParameter( m_moveXPoseParameter, forwardVel );
			}

			if ( m_moveYPoseParameter >= 0 )
			{
				float sideVel = GetVectorDotProduct( motionVector, right );

				pCC.SetPoseParameter( m_moveYPoseParameter, sideVel );
			}
		}
	}

	public void UpdateBodyPitchYaw()
	{
        INextBot bot = this.GetBot();

        CBaseCombatCharacter anim = CBaseCombatCharacter(bot.GetEntity());

        int iPitch = anim.LookupPoseParameter("body_pitch");
        int iYaw = anim.LookupPoseParameter("body_yaw");
		
        float vecDir[3], angDir[3], vecEyePos[3], vecTargetPos[3], angBot[3], angEyes[3];

        this.GetEyePositionEx(vecEyePos);
        anim.GetPropVector(Prop_Data, "m_angCurrentAngles", angEyes);
        anim.GetPropVector(Prop_Data, "m_angAbsRotation", angBot);

        int iTarget = anim.GetPropEnt(Prop_Data, "m_hLookAtSubject");
        if (iTarget <= 0)
            iTarget = anim.GetPropEnt(Prop_Data, "m_hTarget");

        if (iTarget > 0)
        {
            Handle hTrace = TR_TraceRayFilterEx(vecEyePos, angEyes, (MASK_SOLID|CONTENTS_HITBOX), RayType_Infinite, Filter_WorldOnly, bot.GetEntity());

            if (TR_GetFraction(hTrace) < 1.0)
            {
                if (TR_GetEntityIndex(hTrace) == -1)
                {
                    delete hTrace;

                    anim.SetPoseParameter(iPitch, 0.0);
                    anim.SetPoseParameter(iYaw, 0.0);

                    return;
                }
            }

            TR_GetEndPosition(vecTargetPos, hTrace);

            delete hTrace;
        }
        else
        {
            float vecForward[3];
            GetAngleVectors(angEyes, vecForward, NULL_VECTOR, NULL_VECTOR);
            vecTargetPos[0] = vecEyePos[0] + vecForward[0] * 100.0;
            vecTargetPos[1] = vecEyePos[1] + vecForward[1] * 100.0;
            vecTargetPos[2] = vecEyePos[2] + vecForward[2] * 100.0;
        }

        SubtractVectors(vecEyePos, vecTargetPos, vecDir);
        NormalizeVector(vecDir, vecDir);
        GetVectorAngles(vecDir, angDir);

        //float angDir[3];
        //anim.GetPropVector(Prop_Data, "m_angCurrentAngles", angDir);
        //angDir[0] *= -1;

        //float flPitch = anim.GetPoseParameter(iPitch);
        //float flYaw = anim.GetPoseParameter(iYaw);

        angDir[0] = FloatClamp(AngleNormalize2(angDir[0]), -44.0, 89.0);
        //anim.SetPoseParameter(iPitch, ApproachAngle2(angDir[0], flPitch, 10.0));
        anim.SetPoseParameter(iPitch, angDir[0]);

        //Doens't work as intended, yaw changes too fast, faster than model rotation...
        //Nope, still works badly
        angDir[1] = FloatClamp(-AngleNormalize2(AngleDiff2(AngleNormalize2(angDir[1]), AngleNormalize2(angBot[1] + 180.0))), -44.0, 44.0);
        //anim.SetPoseParameter(iYaw, ApproachAngle2(angDir[1], flYaw, 10.0));
        //anim.SetPoseParameter(iYaw, angDir[1]);
	}

    public float GetHeadSteadyDuration()
    {
        INextBot bot = this.GetBot();
        CBaseEntity ent = CBaseEntity(bot.GetEntity());
        if (ent.HasProp(Prop_Data, "m_flHeadSteadyTimer") && ent.GetPropFloat(Prop_Data, "m_flHeadSteadyTimer") > 0.0)
            return GetGameTime() - ent.GetPropFloat(Prop_Data, "m_flHeadSteadyTimer");
    }

    public void Upkeep()
    {
        INextBot bot = this.GetBot();
        CBaseEntity ent = CBaseEntity(bot.GetEntity());

        int iTarget = CBaseEntity(bot.GetEntity()).GetPropEnt(Prop_Data, "m_hTarget");
        if (iTarget <= 0)
        {
            CBaseEntity(bot.GetEntity()).SetProp(Prop_Data, "m_bIsSightedIn", false);
        }
        int iSkill = CBaseEntity(bot.GetEntity()).GetProp(Prop_Data, "m_iSkill");

        float angEyes[3];
        ent.GetPropVector(Prop_Data, "m_angCurrentAngles", angEyes);

        float angPriorAngles[3];
        ent.GetPropVector(Prop_Data, "m_angPriorAngles", angPriorAngles);

        float vecEyePos[3];
        this.GetEyePositionEx(vecEyePos);

        if (GetGameTime() > ent.GetPropFloat(Prop_Data, "m_flLookAtExpireTimer") && ent.GetPropFloat(Prop_Data, "m_flLookAtExpireTimer") > 0.0)
        {
            iTarget = -1;
            ent.SetPropEnt(Prop_Data, "m_hTarget", -1);
            ent.SetProp(Prop_Data, "m_bIsSightedIn", false);
            ent.SetPropVector(Prop_Data, "m_vecLookAtPos", NULL_VECTOR);
            ent.SetPropFloat(Prop_Data, "m_flLookAtExpireTimer", 0.0);
        }

        float vecTargetPos[3];
        bool bSeeThreat = false;
        if (iTarget > 0)
        {
            bSeeThreat = this.IsAbleToSeeTarget(iTarget, vecTargetPos);

            if (IsNullVector(vecTargetPos))
                CBaseAnimating(iTarget).WorldSpaceCenter(vecTargetPos);
        }

        if (iTarget <= 0)
        {
            ent.GetPropVector(Prop_Data, "m_vecLookAtPos", vecTargetPos);

            //No force target or pos, looking at default pos
            if (IsNullVector(vecTargetPos))
            {
                float angRot[3], vecForward[3];
                ent.GetPropVector(Prop_Data, "m_angAbsRotation", angRot);

                GetAngleVectors(angRot, vecForward, NULL_VECTOR, NULL_VECTOR);
                vecTargetPos[0] = vecEyePos[0] + vecForward[0] * 100.0;
                vecTargetPos[1] = vecEyePos[1] + vecForward[1] * 100.0;
                vecTargetPos[2] = vecEyePos[2] + vecForward[2] * 100.0;
            }
        }

        this.LookAtPos(vecTargetPos, CBotBody.GetHeadAimTrackingInterval(iSkill));

        //float angEyes[3];
        //CBaseEntity(bot.GetEntity()).GetPropVector(Prop_Data, "m_angCurrentAngles", angEyes);

        ent.SetProp(Prop_Data, "m_bIsSightedIn", bSeeThreat);
    }

    //If your nextbot model is big, then we need apply extra offset
    //By default, eye position is located in the center of the model
    public void GetEyePositionEx(float buffer[3])
    {
        CBaseEntity ent = CBaseEntity(this.GetBot().GetEntity());
        float vecEyePos[3];
        this.GetEyePosition(vecEyePos);

        if (ent.HasProp(Prop_Data, "m_flEyePosHeight"))
        {
            vecEyePos[2] += ent.GetPropFloat(Prop_Data, "m_flEyePosHeight");

            float vecFixEye[3]
            if (this.IsEyePositionInFloor(vecFixEye))
            {
                vecEyePos = vecFixEye;
            }
        }

        buffer = vecEyePos;
    }

    public void GetEyePositionWithHeight(float buffer[3])
    {
        CBaseEntity ent = CBaseEntity(this.GetBot().GetEntity());
        float vecEyePos[3];
        this.GetEyePosition(vecEyePos);

        if (ent.HasProp(Prop_Data, "m_flEyePosHeight"))
        {
            vecEyePos[2] += ent.GetPropFloat(Prop_Data, "m_flEyePosHeight");
        }

        buffer = vecEyePos;
    }
}