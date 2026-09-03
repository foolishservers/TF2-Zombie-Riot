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
	PrecacheSound("player/flow.wav");
	PrecacheModel("models/zombie_riot/gmod_zs/zs_zombie_models_1_1.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ZSZmain(vecPos, vecAng, team);
}

methodmap ZSZmain < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
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

	property float m_flJumpCooldownZmain
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flTryIgnorebuildings
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flHitAndRun
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flBhop
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flSideStep
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	property float m_flIgnorebuildings
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	
	public ZSZmain(float vecPos[3], float vecAng[3], int ally)
	{
		ZSZmain npc = view_as<ZSZmain>(CClotBody(vecPos, vecAng, "models/zombie_riot/gmod_zs/zs_zombie_models_1_1.mdl", "1.15", "6000", ally, false));
		
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

		npc.m_flWaveScale = float(Waves_GetRoundScale()+1)* 0.133333;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iChanged_WalkCycle = -1;
		npc.Anger = false;
		npc.m_bFUCKYOU = false;
		npc.m_iOverlordComboAttack = 0;
		npc.m_flJumpCooldownZmain = 0.0;
		npc.m_flTryIgnorebuildings = 0.0;
		npc.m_flHitAndRun = 0.0;
		npc.m_flBhop = 1.0 + GetGameTime(npc.index);
		npc.m_flSideStep = 30.0 + GetGameTime(npc.index);
		npc.m_flIgnorebuildings = 0.0;
		f_MaxAnimationSpeed[npc.index] = 1.5;
		npc.m_flSpeed = 330.0;
		npc.StartPathing();
		
		return npc;
	}
}

static void ZSZmain_ClotThink(int iNPC)
{
	ZSZmain npc = view_as<ZSZmain>(iNPC);

	SetVariantInt(1);
	AcceptEntityInput(iNPC, "SetBodyGroup");
	
	float GameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GameTime)
		return;
	
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		if(!npc.m_flAttackHappenswillhappen)
			npc.AddGesture("ACT_FLINCH", false);
		npc.PlayHurtSound();
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
		ZSZmain_SelfDefense(npc, GameTime, vecTarget, flDistanceToTarget);
		switch(ZSZmain_AnnoyingLogic(npc, GameTime, vecTarget, flDistanceToTarget))
		{
			case 0:
			{
				if(npc.m_iChanged_WalkCycle != 0)
				{
					npc.m_bPathing = false;
					npc.m_bisWalking = false;
					npc.m_bAllowBackWalking = false;
					npc.m_iChanged_WalkCycle = 0;
					npc.SetActivity("ACT_MP_STAND_ITEM1");
					npc.m_flSpeed = 0.0;
					npc.StopPathing();
				}
			}
			case 1:
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
					npc.m_bPathing = true;
					npc.m_bisWalking = true;
					npc.m_bAllowBackWalking = false;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_HL2MP_WALK_ZOMBIE_01");
					npc.m_flSpeed = 330.0;
					npc.StartPathing();
				}
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3];
					b_TryToAvoidTraverse[npc.index] = false;
					PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
					vPredictedPos = GetBehindTarget(npc.m_iTarget, 30.0 ,vPredictedPos);
					int AntiCheeseReply = DiversionAntiCheese(npc.m_iTarget, npc.index, vPredictedPos);
					b_TryToAvoidTraverse[npc.index] = true;
					if(AntiCheeseReply == 0)
						npc.SetGoalVector(vPredictedPos, true);
					else if(AntiCheeseReply == 1)
					{
						if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.5))
						{
							npc.m_bAllowBackWalking = true;
							float vBackoffPos[3];
							BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
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
					if(!npc.m_bPathing)
						npc.StartPathing();

					npc.SetGoalEntity(npc.m_iTarget);
				}
			}
			case 2:
			{
				if(npc.m_iChanged_WalkCycle != 2)
				{
					npc.m_bPathing = true;
					npc.m_bisWalking = true;
					npc.m_bAllowBackWalking = false;
					npc.m_iChanged_WalkCycle = 2;
					npc.SetActivity("ACT_HL2MP_WALK_ZOMBIE_01");
					npc.m_flSpeed = 330.0;
					npc.StartPathing();
				}
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
			case 3:
			{
				if(npc.m_iChanged_WalkCycle != 3)
				{
					npc.m_bPathing = true;
					npc.m_bisWalking = true;
					npc.m_bAllowBackWalking = false;
					npc.m_iChanged_WalkCycle = 3;
					npc.SetActivity("ACT_HL2MP_WALK_CROUCH_ZOMBIE_01");
					npc.m_flSpeed = 250.0;
					npc.StartPathing();
				}
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
			case 4:
			{
				if(npc.m_iChanged_WalkCycle != 4)
				{
					npc.m_bPathing = true;
					npc.m_bisWalking = true;
					npc.m_bAllowBackWalking = true;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_HL2MP_WALK_CROUCH_ZOMBIE_01");
					npc.m_flSpeed = 250.0;
					npc.StartPathing();
				}
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true);
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

public int ZSZmain_AnnoyingLogic(ZSZmain npc, float gameTime, float vecTarget[3], float distance)
{
	if(npc.m_flTryIgnorebuildings < gameTime && ShouldNpcDealBonusDamage(npc.m_iTarget))
	{
		b_NpcIgnoresbuildings[npc.index]=true;
		npc.m_iTarget = GetClosestTarget(npc.index, true);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
		if(npc.IsOnGround())
		{
			float vecBuffer[3], vecForward[3], vecPos[3];
			GetAbsOrigin(npc.index, vecPos);
			GetEntPropVector(npc.index, Prop_Send, "m_angRotation", vecTarget);
			vecTarget[0] = 75.0;
			GetAngleVectors(vecTarget, vecForward, NULL_VECTOR, NULL_VECTOR);
			NormalizeVector(vecForward, vecForward);
			ScaleVector(vecForward, 202.0);
			AddVectors(vecPos, vecForward, vecBuffer);
			PluginBot_Jump(npc.index, vecBuffer);
			npc.GetVelocity(vecBuffer);
			vecBuffer[2] = 400.0;
			npc.SetVelocity(vecBuffer);
		}
		npc.m_flTryIgnorebuildings = 6.0 + gameTime;
		npc.m_flIgnorebuildings = 3.0 + gameTime;
		return 3;
	}
	b_NpcIgnoresbuildings[npc.index]=(npc.m_flIgnorebuildings > gameTime);
	if(npc.Anger)
	{
		npc.m_flBhop += 0.1;
		npc.m_flSideStep += 0.1;
		if(npc.m_flHitAndRun < gameTime)
			npc.Anger=false;
		return 4;
	}
	if(npc.m_flBhop < gameTime)
	{
		npc.m_flSideStep += 0.1;
		if(npc.IsOnGround())
		{
			if(npc.m_iOverlordComboAttack>30 || (npc.m_iOverlordComboAttack>10 && distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.66)))
			{
				f_NpcTurnPenalty[npc.index]=1.0;
				npc.m_iOverlordComboAttack=0;
				npc.m_flBhop = 25.0 + gameTime;
				return 1;
			}
			f_NpcTurnPenalty[npc.index]=0.95;
			float vecBuffer[3], vecForward[3], vecPos[3];
			GetAbsOrigin(npc.index, vecPos);
			GetEntPropVector(npc.index, Prop_Send, "m_angRotation", vecTarget);
			vecTarget[0] = 27.5;
			GetAngleVectors(vecTarget, vecForward, NULL_VECTOR, NULL_VECTOR);
			NormalizeVector(vecForward, vecForward);
			ScaleVector(vecForward, 125.0+((330.0*0.1)*npc.m_iOverlordComboAttack));
			AddVectors(vecPos, vecForward, vecBuffer);
			PluginBot_Jump(npc.index, vecBuffer);
			npc.GetVelocity(vecBuffer);
			vecBuffer[2] = 271.0;
			npc.SetVelocity(vecBuffer);
			npc.m_iOverlordComboAttack++;
		}
		return 3;
	}
	if(npc.m_flSideStep < gameTime)
	{
		npc.m_flBhop += 0.1;
		if(npc.IsOnGround() && npc.m_flJumpCooldownZmain < gameTime && distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0))
		{
			npc.m_flJumpCooldownZmain = gameTime + GetRandomRetargetTime();
			npc.GetLocomotionInterface().Jump();
			float vel[3];
			npc.GetVelocity(vel);
			vel[2] = 400.0;
			npc.SetVelocity(vel);
		}
	}
	return 1;
}

static void ZSZmain_SelfDefense(ZSZmain npc, float gameTime, float VecEnemy[3], float distance)
{
	npc.FaceTowards(VecEnemy, (500.0 * npc.GetDebuffPercentage() * f_NpcTurnPenalty[npc.index]), true);
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			Handle swingTrace;
			WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1))
			{
				int target = TR_GetEntityIndex(swingTrace);
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				if(IsValidEnemy(npc.index, target))
				{
					if(!ShouldNpcDealBonusDamage(target))
						SDKHooks_TakeDamage(target, npc.index, npc.index, 50.0, DMG_CLUB, -1, _, vecHit);
					else
						SDKHooks_TakeDamage(target, npc.index, npc.index, 80.0, DMG_CLUB, -1, _, vecHit);
					npc.PlayMeleeHitSound();
				}
				if(!ShouldNpcDealBonusDamage(target))
				{
					npc.m_flHitAndRun = gameTime + 1.0;
					npc.Anger = true;
					float vecBuffer[3], vecForward[3], vecPos[3];
					GetAbsOrigin(npc.index, vecPos);
					GetEntPropVector(npc.index, Prop_Send, "m_angRotation", VecEnemy);
					VecEnemy[0] = 23.5+GetRandomFloat(-5.0, 5.0);
					if(GetRandomInt(1, 4) >=3)
						VecEnemy[1] += 30.0;
					else
						VecEnemy[1] -= 30.0;
					GetAngleVectors(VecEnemy, vecForward, NULL_VECTOR, NULL_VECTOR);
					NormalizeVector(vecForward, vecForward);
					ScaleVector(vecForward, -282.5);
					AddVectors(vecPos, vecForward, vecBuffer);
					PluginBot_Jump(npc.index, vecBuffer);
					if(npc.m_flBhop < gameTime)
						npc.m_iOverlordComboAttack+=5;
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

static void ZSZmain_NPCDeath(int entity)
{
	ZSZmain npc = view_as<ZSZmain>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
}