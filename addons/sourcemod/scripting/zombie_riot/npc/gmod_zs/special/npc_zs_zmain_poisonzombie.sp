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

static char g_MeleeHitSounds[][] = {
	"npc/fast_zombie/claw_strike1.wav",
	"npc/fast_zombie/claw_strike2.wav",
	"npc/fast_zombie/claw_strike3.wav",
};
static char g_MeleeAttackSounds[][] = {
	"npc/zombie_poison/pz_warn1.wav",
	"npc/zombie_poison/pz_warn2.wav",
};

static char g_MeleeMissSounds[][] = {
	"npc/fast_zombie/claw_miss1.wav",
	"npc/fast_zombie/claw_miss2.wav",
};

static const float ZMAIN_POISON_SPEED_CROUCH = 60.0;
static const float ZMAIN_POISON_SPEED_WALK   = 200.0;

public void ZSMainPoisonZombie_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Z-Main Poison Zombie");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_zmain_poisonzombie");
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
	Zombie_Shared_PheromonePrecache();
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheSound("npc/assassin/ball_zap1.wav");
	PrecacheModel("models/zombie/poison.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ZSMainPoisonZombie(vecPos, vecAng, team);
}

methodmap ZSMainPoisonZombie < ZSZmainBase
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _, (this.m_iOverlordComboAttack>=2 ? 80 : 100));
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _, (this.m_iOverlordComboAttack>=2 ? 80 : 100));
	}
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _, (this.m_iOverlordComboAttack>=2 ? 80 : 100));
	}
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _, (this.m_iOverlordComboAttack>=2 ? 80 : 100));
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _, (this.m_iOverlordComboAttack>=2 ? 80 : 100));
	}
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _, (this.m_iOverlordComboAttack>=2 ? 80 : 100));
	}
	
	public ZSMainPoisonZombie(float vecPos[3], float vecAng[3], int ally)
	{
		ZSMainPoisonZombie npc = view_as<ZSMainPoisonZombie>(CClotBody(vecPos, vecAng, "models/zombie/poison.mdl", "1.15", "5000", ally, false));
		
		i_NpcWeight[npc.index] = 2;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_WALK");
		if(iActivity > 0) npc.StartActivity(iActivity);
		KillFeed_SetKillIcon(npc.index, "infection_heavy");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		func_NPCDeath[npc.index] = ZSMainPoisonZombie_NPCDeath;
		func_NPCThink[npc.index] = ZSMainPoisonZombie_ClotThink;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iChanged_WalkCycle = -1;
		
		// b_AvoidBuildingsAtAllCosts[npc.index] = true;
		
		npc.Anger = false;
		npc.m_bFUCKYOU = false;
		npc.m_iOverlordComboAttack = 0;
		
		npc.m_flTryIgnorebuildings = 0.0;
		npc.m_flHitAndRun = 0.0;
		npc.m_flBhop = 1.0 + GetGameTime(npc.index);
		npc.m_flIgnorebuildings = 0.0;
		
		f_MaxAnimationSpeed[npc.index] = 1.5;
		
		npc.m_flSpeed = ZMAIN_POISON_SPEED_WALK;
		npc.StartPathing();
		
		return npc;
	}
}

static void ZSMainPoisonZombie_ClotThink(int iNPC)
{
	ZSMainPoisonZombie npc = view_as<ZSMainPoisonZombie>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		
		if(!npc.m_flAttackHappenswillhappen)
			npc.AddGesture("ACT_FLINCH", false);
		
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	if(!IsValidEnemy(npc.index, npc.m_iTarget)) {
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.PlayIdleSound();
		return;
	}
	
	float vecTarget[3], vecSelf[3];
	WorldSpaceCenter(npc.m_iTarget, vecTarget);
	WorldSpaceCenter(npc.index, vecSelf);
	float flDistanceToTarget = GetVectorDistance(vecTarget, vecSelf, true);
	
	ZSMainPoisonZombie_SelfDefense(npc, gameTime, vecTarget, flDistanceToTarget);

	int logicState = ZSZmain_AnnoyingLogic(npc, gameTime, vecTarget, flDistanceToTarget);
	float leadRadius = npc.GetLeadRadius();
	
	switch(logicState)
	{
		case 0: { // Idle / Stop
			npc.SetMovementState(0, "ACT_IDLE", 0.0, false, false);
		}
		case 1: { // Normal Chase & Anti-Cheese
			npc.SetMovementState(1, "ACT_WALK", ZMAIN_POISON_SPEED_WALK, false, true);

			if(flDistanceToTarget < leadRadius) {
				float vPredictedPos[3];
				b_TryToAvoidTraverse[npc.index] = false;
				PredictSubjectPosition(npc, npc.m_iTarget, _, _, vPredictedPos);
				vPredictedPos = GetBehindTarget(npc.m_iTarget, 30.0, vPredictedPos);
				
				int antiCheeseReply = DiversionAntiCheese(npc.m_iTarget, npc.index, vPredictedPos);
				b_TryToAvoidTraverse[npc.index] = true;
				
				if (antiCheeseReply == 0)
				{
					npc.SetGoalVector(vPredictedPos, true);
				}
				else if (antiCheeseReply == 1)
				{
					if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.5))
					{
						npc.m_bAllowBackWalking = true;
						float vBackoffPos[3];
						BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget, _, vBackoffPos);
						npc.SetGoalVector(vBackoffPos, true);
					}
					else
					{
						npc.SetGoalEntity(npc.m_iTarget);
					}
				}
			}
			else
			{
				DiversionCalmDownCheese(npc.index);
				npc.SetGoalEntity(npc.m_iTarget);
			}
		}
		case 3: { // Bhop Pursuit
			npc.SetMovementState(3, "ACT_WALK", ZMAIN_POISON_SPEED_CROUCH, false, true);
			
			if(flDistanceToTarget < leadRadius)
			{
				float vPredictedPos[3];
				PredictSubjectPosition(npc, npc.m_iTarget, _, _, vPredictedPos);
				npc.SetGoalVector(vPredictedPos);
			}
			else
			{
				npc.SetGoalEntity(npc.m_iTarget);
			}
		}
	}
	
	npc.PlayIdleSound();
}

static void ZSMainPoisonZombie_SelfDefense(ZSMainPoisonZombie npc, float gameTime, float VecEnemy[3], float distance)
{
	float turnSpeed = 500.0 * npc.GetDebuffPercentage() * f_NpcTurnPenalty[npc.index];
	npc.FaceTowards(VecEnemy, turnSpeed, true);
	
	// Hit execution
	if(npc.m_flAttackHappens && npc.m_flAttackHappens < gameTime) {
		npc.m_flAttackHappens = 0.0;
		Handle swingTrace;
		WorldSpaceCenter(npc.m_iTarget, VecEnemy);
		npc.FaceTowards(VecEnemy, 15000.0);

		if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1)) {
			int target = TR_GetEntityIndex(swingTrace);
			float vecHit[3];
			TR_GetEndPosition(vecHit, swingTrace);

			if(IsValidEnemy(npc.index, target)) {
				float damage = 160.0;
				if (ShouldNpcDealBonusDamage(target))
					damage *= 5.5;
				//else
				//	Elemental_AddPheromoneDamage(target, npc.index, 50);
				
				SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
				npc.PlayMeleeHitSound();
			}
		}
		delete swingTrace;
	}
	
	// Attack Trigger
	if(gameTime > npc.m_flNextMeleeAttack && distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED) {
		int visibleEnemy = Can_I_See_Enemy(npc.index, npc.m_iTarget);
		if(IsValidEnemy(npc.index, visibleEnemy)) {
			npc.m_iTarget = visibleEnemy;
			npc.PlayMeleeSound();
			npc.AddGesture("ACT_MELEE_ATTACK1");
			
			npc.m_flAttackHappens = gameTime + 0.71;
			npc.m_flDoingAnimation = gameTime + 0.71;
			npc.m_flNextMeleeAttack = gameTime + 1.2;
		}
	}
}

static void ZSMainPoisonZombie_NPCDeath(int entity)
{
	ZSMainPoisonZombie npc = view_as<ZSMainPoisonZombie>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
}