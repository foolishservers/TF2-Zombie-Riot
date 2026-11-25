#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/zombie/zombie_die1.wav",
	"npc/zombie/zombie_die2.wav",
	"npc/zombie/zombie_die3.wav",
};

static const char g_HurtSounds[][] = {
	"npc/zombie/zombie_pain1.wav",
	"npc/zombie/zombie_pain2.wav",
	"npc/zombie/zombie_pain3.wav",
	"npc/zombie/zombie_pain4.wav",
	"npc/zombie/zombie_pain5.wav",
	"npc/zombie/zombie_pain6.wav",
};

static const char g_IdleSounds[][] = {
	"npc/zombie/zombie_voice_idle1.wav",
	"npc/zombie/zombie_voice_idle2.wav",
	"npc/zombie/zombie_voice_idle3.wav",
	"npc/zombie/zombie_voice_idle4.wav",
	"npc/zombie/zombie_voice_idle5.wav",
	"npc/zombie/zombie_voice_idle6.wav",
	"npc/zombie/zombie_voice_idle7.wav",
	"npc/zombie/zombie_voice_idle8.wav",
	"npc/zombie/zombie_voice_idle9.wav",
	"npc/zombie/zombie_voice_idle10.wav",
	"npc/zombie/zombie_voice_idle11.wav",
	"npc/zombie/zombie_voice_idle12.wav",
	"npc/zombie/zombie_voice_idle13.wav",
	"npc/zombie/zombie_voice_idle14.wav",
};

static const char g_MeleeHitSounds[][] = {
	"npc/fast_zombie/claw_strike1.wav",
	"npc/fast_zombie/claw_strike2.wav",
	"npc/fast_zombie/claw_strike3.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"npc/zombie/zo_attack1.wav",
	"npc/zombie/zo_attack2.wav",
};

static const char g_MeleeMissSounds[][] = {
	"npc/fast_zombie/claw_miss1.wav",
	"npc/fast_zombie/claw_miss2.wav",
};

static const float ZMAIN_SPEED_CROUCH = 80.0;
static const float ZMAIN_SPEED_WALK   = 300.0;

public void ZSZmain_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Z-Main");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_zmain");
	strcopy(data.Icon, sizeof(data.Icon), "norm_headcrab_zombie");
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
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeMissSounds);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ZSZmain(vecPos, vecAng, team);
}

methodmap ZSZmain < ZSZmainBase
{
	// PlaySound Methods
	public void PlayIdleSound() {
		float gameTime = GetGameTime(this.index);
		if(this.m_flNextIdleSound > gameTime)
			return;
		
		this.m_flNextIdleSound = gameTime + GetRandomFloat(3.0, 6.0);
		
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayHurtSound() {
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public ZSZmain(float vecPos[3], float vecAng[3], int ally)
	{
		ZSZmain npc = view_as<ZSZmain>(CClotBody(vecPos, vecAng, ZS_CUSTOM_MODEL_1, "1.15", "6000", ally, false));
		
		SetVariantInt(ZS_MODEL_CLASSIC);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_HL2MP_WALK_ZOMBIE_01");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		func_NPCDeath[npc.index] = ZSZmain_NPCDeath;
		func_NPCThink[npc.index] = ZSZmain_ClotThink;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iChanged_WalkCycle = -1;
		b_AvoidBuildingsAtAllCosts[npc.index] = true;
		
		npc.Anger = false;
		npc.m_bFUCKYOU = false;
		npc.m_iOverlordComboAttack = 0;
		
		float gameTime = GetGameTime(npc.index);
		npc.m_flTryIgnorebuildings = FAR_FUTURE;
		npc.m_flHitAndRun = 0.0;
		npc.m_flBhop = 1.0 + gameTime;
		npc.m_flIgnorebuildings = 0.0;
		
		f_MaxAnimationSpeed[npc.index] = 1.5;
		
		npc.m_flSpeed = ZMAIN_SPEED_WALK;
		npc.StartPathing();
		
		return npc;
	}
}

static void ZSZmain_ClotThink(int iNPC)
{
	ZSZmain npc = view_as<ZSZmain>(iNPC);
	
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

	ZSZmain_SelfDefense(npc, gameTime, vecTarget, flDistanceToTarget);

	int logicState = ZSZmain_AnnoyingLogic(npc, gameTime, vecTarget, flDistanceToTarget);
	float leadRadius = npc.GetLeadRadius();
	
	switch(logicState)
	{
		case 0: { // Idle / Stop
			npc.SetMovementState(0, "ACT_HL2MP_IDLE_ZOMBIE", 0.0, false, false);
		}
		case 1: { // Normal Chase & Anti-Cheese
			npc.SetMovementState(1, "ACT_HL2MP_WALK_ZOMBIE_01", ZMAIN_SPEED_WALK, false, true);

			if(flDistanceToTarget < leadRadius) {
				float vPredictedPos[3];
				b_TryToAvoidTraverse[npc.index] = false;
				PredictSubjectPosition(npc, npc.m_iTarget, _, _, vPredictedPos);
				vPredictedPos = GetBehindTarget(npc.m_iTarget, 30.0, vPredictedPos);
				
				int antiCheeseReply = DiversionAntiCheese(npc.m_iTarget, npc.index, vPredictedPos);
				b_TryToAvoidTraverse[npc.index] = true;
				
				if (antiCheeseReply == 0) {
					npc.SetGoalVector(vPredictedPos, true);
				} else if (antiCheeseReply == 1) {
					if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.5)) {
						npc.m_bAllowBackWalking = true;
						float vBackoffPos[3];
						BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget, _, vBackoffPos);
						npc.SetGoalVector(vBackoffPos, true);
					} else {
						npc.SetGoalEntity(npc.m_iTarget);
					}
				}
			} else {
				DiversionCalmDownCheese(npc.index);
				npc.SetGoalEntity(npc.m_iTarget);
			}
		}
		case 3: { // Crouch Walk / Bhop Pursuit
			npc.SetMovementState(3, "ACT_HL2MP_WALK_CROUCH_ZOMBIE_01", ZMAIN_SPEED_CROUCH, false, true);

			if(flDistanceToTarget < leadRadius) {
				float vPredictedPos[3];
				PredictSubjectPosition(npc, npc.m_iTarget, _, _, vPredictedPos);
				npc.SetGoalVector(vPredictedPos);
			} else {
				npc.SetGoalEntity(npc.m_iTarget);
			}
		}
		case 4: { // Hit & Run Evade
			npc.SetMovementState(4, "ACT_HL2MP_WALK_CROUCH_ZOMBIE_01", ZMAIN_SPEED_CROUCH, true, true);

			float vBackoffPos[3];
			BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget, _, vBackoffPos);
			npc.SetGoalVector(vBackoffPos, true);
		}
	}

	npc.PlayIdleSound();
}

static void ZSZmain_SelfDefense(ZSZmain npc, float gameTime, float VecEnemy[3], float distance)
{
	float turnSpeed = 500.0 * npc.GetDebuffPercentage() * f_NpcTurnPenalty[npc.index];
	npc.FaceTowards(VecEnemy, turnSpeed, true);
	
	// Hit execution & Hit-and-Run trigger
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
				float damage = ShouldNpcDealBonusDamage(target) ? 80.0 : 50.0;
				SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
				npc.PlayMeleeHitSound();
				
				// Hit & Run evasion trigger on non-structure target
				if(!ShouldNpcDealBonusDamage(target)) {
					npc.m_flHitAndRun = gameTime + 1.0;
					npc.Anger = true;
					
					float pitch = 23.5 + GetRandomFloat(-5.0, 5.0);
					float yawOffset = (GetRandomInt(1, 4) >= 3) ? 30.0 : -30.0;
					npc.PerformLeap(pitch, -200.0, 400.0, yawOffset);
						
					if(npc.m_flBhop < gameTime) {
						npc.m_iOverlordComboAttack += 4;
					}
				}
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
			npc.AddGesture("ACT_GMOD_GESTURE_RANGE_ZOMBIE");
			
			npc.m_flAttackHappens = gameTime + 0.71;
			npc.m_flDoingAnimation = gameTime + 0.71;
			npc.m_flNextMeleeAttack = gameTime + 1.2;
		}
	}
}

static void ZSZmain_NPCDeath(int entity)
{
	ZSZmain npc = view_as<ZSZmain>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
}