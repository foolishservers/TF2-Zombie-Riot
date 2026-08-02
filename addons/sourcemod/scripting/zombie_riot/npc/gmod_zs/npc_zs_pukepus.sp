#pragma semicolon 1
#pragma newdecls required
 
static char g_DeathSounds[][] = {
	"npc/zombie_poison/pz_die1.wav",
	"npc/zombie_poison/pz_die2.wav",
};
static char g_HurtSounds[][] = {
	"npc/zombie_poison/pz_pain1.wav",
	"npc/zombie_poison/pz_pain2.wav",
	"npc/zombie_poison/pz_pain3.wav",
};
static char g_IdleSounds[][] = {
	"npc/zombie_poison/pz_idle2.wav",
	"npc/zombie_poison/pz_idle3.wav",
	"npc/zombie_poison/pz_idle4.wav",
};
static char g_IdleAlertedSounds[][] = {
	"npc/zombie_poison/pz_alert1.wav",
	"npc/zombie_poison/pz_alert2.wav",
};
static char g_RangeAttackSounds[][] = {
	"npc/barnacle/barnacle_die1.wav",
	"npc/barnacle/barnacle_die2.wav",
};

public void ZS_pukepus_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Puke Pus");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_pukepus");
	strcopy(data.Icon, sizeof(data.Icon), "norm_poison_zombie");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_GmodZS;
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
	PrecacheSoundArray(g_RangeAttackSounds);
	PrecacheSound("player/flow.wav");
	PrecacheModel("models/zombie_riot/gmod_zs/zs_zombie_models_1_1.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ZSZmain(vecPos, vecAng, team);
}

methodmap ZSZmain < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
	}
	public void PlayIdleAlertSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
	}
	public void PlayHurtSound()
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound()
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayRangeSound()
	{
		EmitSoundToAll(g_RangeAttackSounds[GetRandomInt(0, sizeof(g_RangeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public ZSZmain(float vecPos[3], float vecAng[3], int ally)
	{
		ZSZmain npc = view_as<ZSZmain>(CClotBody(vecPos, vecAng, "models/zombie_riot/gmod_zs/zs_zombie_models_1_1.mdl", "1.15", "225", ally, false));
		
		i_NpcWeight[npc.index] = 4;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_WALK");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		npc.m_flSpeed = 330.0;
		func_NPCDeath[npc.index] = ZSZmain_NPCDeath;
		func_NPCThink[npc.index] = ZSZmain_ClotThink;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;

		npc.StartPathing();
		f_MaxAnimationSpeed[npc.index] = 1.5;
		
		return npc;
	}
}

public void ZSZmain_ClotThink(int iNPC)
{
	ZSZmain npc = view_as<ZSZmain>(iNPC);

	SetVariantInt(1);
	AcceptEntityInput(iNPC, "SetBodyGroup");
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		if(!npc.m_flAttackHappenswillhappen)
			npc.AddGesture("ACT_FLINCH", false);
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

	int IsAbuildingNearMe = GetClosestTarget(npc.index,false,200.0,_,_,_, _,true, _,true,true,0.0, .ExtraValidityFunction = Zmain_TryJumpOverBuildings);

	int closest = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, closest))
	{
		if(i_IsABuilding[npc.m_iTarget] && npc.m_flTryIgnorebuildings > GetGameTime(npc.index))
		{
			npc.m_iTarget = GetClosestTarget(npc.index, .IgnoreBuildings = true);
		}

		float vecTarget[3]; WorldSpaceCenter(closest, vecTarget);
			
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		ZSZmain_AnnoyingZmainwalkLogic(npc,GetGameTime(npc.index), flDistanceToTarget, IsAbuildingNearMe); 
		ZSZmain_SelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 

		if(i_IsABuilding[npc.m_iTarget])
		{
			npc.m_iTarget = GetClosestTarget(npc.index, .IgnoreBuildings = true);
			npc.m_flTryIgnorebuildings = GetGameTime(npc.index) + 1.0;
		}
		
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleSound();
}

void ZSZmain_AnnoyingZmainwalkLogic(ZSZmain npc, float gameTime, float distance, int IsAbuildingNearMe)
{
	if(npc.m_flTryIgnorebuildings > gameTime || IsValidEntity(IsAbuildingNearMe))
	{
		if(!npc.m_flAttackHappens && npc.m_flJumpCooldownZmain < gameTime)
		{
			if (npc.IsOnGround())
			{
				npc.AddGesture("ACT_HL2MP_WALK_CROUCH_ZOMBIE_01");
				npc.m_flJumpCooldownZmain = gameTime + 2.0;
				npc.GetLocomotionInterface().Jump();
				float vel[3];
				npc.GetVelocity(vel);
				vel[2] = 400.0;
				npc.SetVelocity(vel);
			}
		}
	}
	npc.m_bAllowBackWalking = false;
	if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0))
	{
		if(distance < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		//Just walk.
		return;
	}
	
	if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 0.5))
	{
		//relatively close, what do ?
		//Randomly jump
		if(!npc.m_flAttackHappens && npc.m_flJumpCooldownZmain < gameTime)
		{
			if (npc.IsOnGround())
			{
				npc.AddGesture("ACT_HL2MP_WALK_CROUCH_ZOMBIE_01");
				npc.m_flJumpCooldownZmain = gameTime + 2.0;
				npc.GetLocomotionInterface().Jump();
				float vel[3];
				npc.GetVelocity(vel);
				vel[2] = 400.0;
				npc.SetVelocity(vel);
			}	
		}
		
		npc.m_bAllowBackWalking = true;
		float vBackoffPos[3];
		BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos, 1);
		npc.SetGoalVector(vBackoffPos, true); //update more often, we need it
		return;
	}

	//relatively close, what do ?
	//Randomly jump
	if(!npc.m_flAttackHappens && npc.m_flJumpCooldownZmain < gameTime)
	{
		if (npc.IsOnGround())
		{
			npc.AddGesture("ACT_HL2MP_WALK_CROUCH_ZOMBIE_01");
			npc.m_flJumpCooldownZmain = gameTime + 2.0;
			npc.GetLocomotionInterface().Jump();
			float vel[3];
			npc.GetVelocity(vel);
			vel[2] = 400.0;
			npc.SetVelocity(vel);
		}	
	}
	float vBackoffPos[3];
	BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos, 2);
	npc.SetGoalVector(vBackoffPos, true); //update more often, we need it
	npc.m_bAllowBackWalking = true;
}

void ZSZmain_SelfDefense(ZSZmain npc, float gameTime, int target, float distance)
{
	float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
	npc.FaceTowards(VecEnemy, 500.0);
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					{
						if(!ShouldNpcDealBonusDamage(target))
							SDKHooks_TakeDamage(target, npc.index, npc.index, 50.0, DMG_CLUB, -1, _, vecHit);
						else
							SDKHooks_TakeDamage(target, npc.index, npc.index, 80.0, DMG_CLUB, -1, _, vecHit);					
					}

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_GMOD_GESTURE_RANGE_ZOMBIE");
						
				npc.m_flAttackHappens = gameTime + 0.71;
				npc.m_flDoingAnimation = gameTime + 0.71;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
			}
		}
	}
}

public void ZSZmain_NPCDeath(int entity)
{
	ZSZmain npc = view_as<ZSZmain>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
}