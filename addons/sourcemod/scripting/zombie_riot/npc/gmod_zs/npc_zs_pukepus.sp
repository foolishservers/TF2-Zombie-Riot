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

public void ZS_Pukepus_OnMapStart_NPC()
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
	PrecacheModel("models/zombie_riot/gmod_zs/zs_zombie_models_1_1.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ZS_Pukepus(vecPos, vecAng, team);
}

methodmap ZS_Pukepus < CClotBody
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
		EmitSoundToAll(g_RangeAttackSounds[GetRandomInt(0, sizeof(g_RangeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80,110));
	}
	
	public ZS_Pukepus(float vecPos[3], float vecAng[3], int ally)
	{
		ZS_Pukepus npc = view_as<ZS_Pukepus>(CClotBody(vecPos, vecAng, "models/zombie_riot/gmod_zs/zs_zombie_models_1_1.mdl", "1.0", "5800", ally, false));
		
		i_NpcWeight[npc.index] = 4;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_WALK");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		func_NPCDeath[npc.index] = ZS_Pukepus_NPCDeath;
		func_NPCThink[npc.index] = ZS_Pukepus_ClotThink;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		
		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 0.5;
		
		SetVariantInt(65536);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		npc.m_iChanged_WalkCycle = -1;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flSpeed = 110.0;
		f_MaxAnimationSpeed[npc.index] = 1.5;
		npc.m_bisWalking = true;
		npc.StartPathing();
		
		return npc;
	}
}

static void ZS_Pukepus_ClotThink(int iNPC)
{
	ZS_Pukepus npc = view_as<ZS_Pukepus>(iNPC);
	float GameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GameTime)
		return;
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
		if(!npc.m_flAttackHappenswillhappen)
			npc.AddGesture("ACT_SMALL_FLINCH", false);
	}
	
	if(npc.m_flNextThinkTime > GameTime)
		return;
	npc.m_flNextThinkTime = GameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
	}

	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		switch(ZS_Pukepus_AttackLogic(npc, GameTime, flDistanceToTarget, vecTarget))
		{
			case 0:
			{
				if(npc.m_iChanged_WalkCycle != 0)
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 0;
					npc.SetActivity("ACT_WALK");
					npc.m_flSpeed = 110.0;
					npc.StartPathing();
				}
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3];
					PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
					npc.SetGoalVector(vPredictedPos);
				}
				else 
					npc.SetGoalEntity(npc.m_iTarget);
			}
			case 1:
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_WALK");
					npc.m_flSpeed = 110.0;
					npc.StartPathing();
				}
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true);
			}
			case 2:
			{
				if(npc.m_iChanged_WalkCycle != 2)
				{
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 2;
					npc.SetActivity("ACT_IDLE");
					npc.m_flSpeed = 0.0;
					npc.StopPathing();
				}
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleSound();
}

static int ZS_Pukepus_AttackLogic(ZS_Pukepus npc, float GameTime, float Distance, float vecTarget[3])
{
	if(GameTime > npc.m_flNextRangedAttack)
	{
		if(Distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 12.0))
		{
			if(IsValidEnemy(npc.index, Can_I_See_Enemy(npc.index, npc.m_iTarget)))
			{
				if(npc.m_iOverlordComboAttack==0)
					npc.PlayRangeSound();
				float vecDest[3];
				vecDest = vecTarget;
				vecDest[0] += GetRandomFloat(-50.0, 50.0);
				vecDest[1] += GetRandomFloat(-50.0, 50.0);
				vecDest[2] += GetRandomFloat(-50.0, 50.0);
				int Projectile = npc.FireParticleRocket(vecTarget, 35.0, 1000.0, 0.0, "blood_impact_green_01", true, .bonusdmg=3.0);
				if(IsValidEntity(Projectile))
				{
					SetEntityGravity(Projectile, 1.0);
					float SpeedReturn[3];
					ArcToLocationViaSpeedProjectile(Projectile, vecDest, SpeedReturn, GetRandomFloat(0.8, 1.35), GetRandomFloat(0.8, 1.0));
					Better_Gravity_Rocket(Projectile, 55.0);
					TeleportEntity(Projectile, NULL_VECTOR, NULL_VECTOR, SpeedReturn);
					WandProjectile_ApplyFunctionToEntity(Projectile, PukepusProjectile_StartTouch);
					int Particle = EntRefToEntIndex(i_WandParticle[Projectile]);
					CreateTimer(8.0, Timer_RemoveEntity, EntIndexToEntRef(Projectile), TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(8.0, Timer_RemoveEntity, EntIndexToEntRef(Particle), TIMER_FLAG_NO_MAPCHANGE);
				}
				npc.m_iOverlordComboAttack++;
				if(npc.m_iOverlordComboAttack>12)
				{
					npc.m_flNextRangedAttack = GameTime + 5.0;
					npc.m_iOverlordComboAttack = 0;
				}
			}
		}
		else
		{
			npc.m_flNextRangedAttack = GameTime + 1.0;
			npc.m_iOverlordComboAttack = 0;
		}
	}

	if(Distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.0))
	{
		if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
		{
			if(Distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.25))
				return 1;
			npc.FaceTowards(vecTarget, 20000.0);
			return 2;
		}
		return 0;
	}
	return 0;
}

static void PukepusProjectile_StartTouch(int entity, int target)
{
	if(target > 0 && target < MAXENTITIES)
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if(!IsValidEntity(owner))
			owner = 0;
		
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
		else
			Elemental_AddPheromoneDamage(target, owner, 15);

		SDKHooks_TakeDamage(target, owner, inflictor, DamageDeal, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, -1);
		
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(IsValidEntity(particle))
			RemoveEntity(particle);
	}
	else
	{
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(IsValidEntity(particle))
			RemoveEntity(particle);
	}
	RemoveEntity(entity);
}

static void ZS_Pukepus_NPCDeath(int entity)
{
	ZS_Pukepus npc = view_as<ZS_Pukepus>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
}