#pragma semicolon 1
#pragma newdecls required

void Dimension_Abomination_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Abomination");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_dimension_abomination");
	strcopy(data.Icon, sizeof(data.Icon), "pyro_armored2_1");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Interitus;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Dimension_Abomination(vecPos, vecAng, team);
}

methodmap Dimension_Abomination < AnarchyAbomination
{
	public Dimension_Abomination(float vecPos[3], float vecAng[3], int ally)
	{
		Dimension_Abomination npc = view_as<Dimension_Abomination>(AnarchyAbomination(vecPos, vecAng, ally));
		
		func_NPCThink[npc.index] = view_as<Function>(Dimension_Abomination_ClotThink);
		
		int skin = 0;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		if(IsValidEntity(npc.m_iWearable1))
			SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		if(IsValidEntity(npc.m_iWearable2))
			SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		if(IsValidEntity(npc.m_iWearable3))
			SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		if(IsValidEntity(npc.m_iWearable4))
			SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		if(IsValidEntity(npc.m_iWearable5))
			SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

static void Dimension_Abomination_ClotThink(int iNPC)
{
	Dimension_Abomination npc = view_as<Dimension_Abomination>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;
	
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if (npc.IsOnGround())
	{
		if(npc.m_iChanged_WalkCycle != 1)
		{
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 1;
			npc.SetActivity("ACT_MP_RUN_PRIMARY");
			npc.StartPathing();
		}	
	}
	else
	{
		if(npc.m_iChanged_WalkCycle != 2)
		{
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 2;
			npc.SetActivity("ACT_MP_JUMP_FLOAT_PRIMARY");
			npc.StartPathing();
		}	
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(npc.m_flCharge_delay < GetGameTime(npc.index))
		{
			if(flDistanceToTarget > NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0)
			{
				npc.PlayChargeSound();
				npc.m_flCharge_delay = GetGameTime(npc.index) + 5.0;
				PluginBot_Jump(npc.index, vecTarget);
				float flPos[3];
				float flAng[3];
				int Particle_1;
				int Particle_2;
				npc.GetAttachment("foot_L", flPos, flAng);
				Particle_1 = ParticleEffectAt_Parent(flPos, "rockettrail", npc.index, "foot_L", {0.0,0.0,0.0});

				npc.GetAttachment("foot_R", flPos, flAng);
				Particle_2 = ParticleEffectAt_Parent(flPos, "rockettrail", npc.index, "foot_R", {0.0,0.0,0.0});
				CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(Particle_1), TIMER_FLAG_NO_MAPCHANGE);
				CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(Particle_2), TIMER_FLAG_NO_MAPCHANGE);
			}
		}
		
		bool SpinSound = true;
		int SetGoalVectorIndex = 0;
		SetGoalVectorIndex = Dimension_Abomination_SelfDefense(npc, SpinSound); 
		
		if(SpinSound)
			npc.PlayMinigunSound(false);
		
		switch(SetGoalVectorIndex)
		{
			case 0:
			{
				npc.m_bAllowBackWalking = false;
				//Get the normal prediction code.
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3];
					PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
					npc.SetGoalVector(vPredictedPos);
				}
				else 
				{
					npc.SetGoalEntity(npc.m_iTarget);
				}
			}
			case 1:
			{
				npc.m_bAllowBackWalking = true;
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true); //update more often, we need it
			}
		}
	}
	else
	{
		npc.PlayMinigunSound(false);
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	npc.PlayIdleAlertSound();
}

static int Dimension_Abomination_SelfDefense(Dimension_Abomination npc, bool &SpinSound)
{
	int target;
	target = npc.m_iTarget;
	//some Ranged units will behave differently.
	//not this one.
	float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float distance = GetVectorDistance(vecTarget, VecSelfNpc, true);
	
	if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0))
	{
		int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				
		if(IsValidEnemy(npc.index, Enemy_I_See))
		{
			npc.PlayMinigunSound(true);
			SpinSound = false;
			npc.FaceTowards(vecTarget, 20000.0);
			float ProjectileSpeed = 1000.0;

			int projectile;
			
			if(npc.Anger)
			{
				PredictSubjectPositionForProjectiles(npc, target, ProjectileSpeed, _,vecTarget);
				projectile = npc.FireParticleRocket(vecTarget, 30.0, ProjectileSpeed, 150.0, "superrare_burning2", true);
				static float ang_Look[3];
				GetEntPropVector(projectile, Prop_Send, "m_angRotation", ang_Look);
				Initiate_HomingProjectile(projectile,
				npc.index,
					90.0,			// float lockonAngleMax,
					90.0,				//float homingaSec,
					true,				// bool LockOnlyOnce,
					true,				// bool changeAngles,
					ang_Look,			
					target); //home onto this enemy
			}
			else
			{
				projectile = npc.FireParticleRocket(vecTarget, 30.0, ProjectileSpeed, 150.0, "superrare_burning1", true);
			}
			SDKUnhook(projectile, SDKHook_StartTouch, Rocket_Particle_StartTouch);
			int particle = EntRefToEntIndex(i_WandParticle[projectile]);
			CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
			
			WandProjectile_ApplyFunctionToEntity(projectile, Dimension_Abomination_Rocket_Particle_StartTouch);	
		}
		
		if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.5))
		{
			//target is too far, try to close in
			return 0;
		}
		else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.5))
		{
			if(Can_I_See_Enemy_Only(npc.index, target))
			{
				//target is too close, try to keep distance
				return 1;
			}
		}
		
		return 0;
	}
	else
	{
		if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.5))
		{
			//target is too far, try to close in
			return 0;
		}
		else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.5))
		{
			if(Can_I_See_Enemy_Only(npc.index, target))
			{
				//target is too close, try to keep distance
				return 1;
			}
		}
	}
	
	return 0;
}

static void Dimension_Abomination_Rocket_Particle_StartTouch(int entity, int target)
{
	if(target > 0 && target < MAXENTITIES)	//did we hit something???
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if(!IsValidEntity(owner))
		{
			owner = 0;
		}
		
		int inflictor = h_ArrowInflictorRef[entity];
		if(inflictor != -1)
			inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);

		if(inflictor == -1)
			inflictor = owner;
			
		float ProjectileLoc[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
		float DamageDeal = fl_rocket_particle_dmg[entity];
		if(ShouldNpcDealBonusDamage(target))
			DamageDeal *= h_BonusDmgToSpecialArrow[entity];

		if(ShouldNpcDealBonusDamage(target))
			DamageDeal *= 17.5;

		SDKHooks_TakeDamage(target, owner, inflictor, DamageDeal, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, -1);	//acts like a kinetic rocket	
		
		NPC_Ignite(target, owner, 12.0, -1, 8.0);
		
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
	}
	else
	{
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		//we uhh, missed?
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
	}
	
	RemoveEntity(entity);
}