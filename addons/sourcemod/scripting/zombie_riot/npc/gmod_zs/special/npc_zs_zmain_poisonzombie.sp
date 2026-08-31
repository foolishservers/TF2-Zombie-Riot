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

methodmap ZSMainPoisonZombie < CClotBody
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
		func_NPCOnTakeDamage[npc.index] = ZSMainPoisonZombie_OnTakeDamage;

		npc.m_flWaveScale = float(Waves_GetRoundScale()+1)* 0.133333;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iChanged_WalkCycle = -1;
		b_AvoidBuildingsAtAllCosts[npc.index] = true;
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

static void ZSMainPoisonZombie_ClotThink(int iNPC)
{
	ZSMainPoisonZombie npc = view_as<ZSMainPoisonZombie>(iNPC);
	
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
		ZSMainPoisonZombie_SelfDefense(npc, GameTime, vecTarget, flDistanceToTarget);
		ZSZmain npcGetInfo = view_as<ZSZmain>(npc.index);
		switch(ZSZmain_AnnoyingLogic(npcGetInfo, GameTime, vecTarget, flDistanceToTarget))
		{
			case 0:
			{
				if(npc.m_iChanged_WalkCycle != 0)
				{
					npc.m_bPathing = false;
					npc.m_bisWalking = false;
					npc.m_bAllowBackWalking = false;
					npc.m_iChanged_WalkCycle = 0;
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

static void ZSMainPoisonZombie_SelfDefense(ZSMainPoisonZombie npc, float gameTime, float VecEnemy[3], float distance)
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
					float damageDealt = 160.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 5.5;
					else
						Elemental_AddPheromoneDamage(target, npc.index, 50);
					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
					npc.PlayMeleeHitSound();
				}
				if(!ShouldNpcDealBonusDamage(target))
				{
					fl_AbilityOrAttack[npc.index][2] = gameTime + 1.0;
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
					ScaleVector(vecForward, -200.5);
					AddVectors(vecPos, vecForward, vecBuffer);
					PluginBot_Jump(npc.index, vecBuffer);
					if(fl_AbilityOrAttack[npc.index][3] < gameTime)
						npc.m_iOverlordComboAttack+=5;
				}
			}
			delete swingTrace;
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*1.1))
		{
			int Enemy_I_See;
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MELEE_ATTACK1");
				
				npc.m_flAttackHappens = gameTime + 0.71;
				npc.m_flDoingAnimation = gameTime + 0.71;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
			}
		}
	}
}

static Action ZSMainPoisonZombie_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	ZSMainPoisonZombie npc = view_as<ZSMainPoisonZombie>(victim);
	if(!NpcStats_IsEnemySilenced(victim))
	{
		if(!npc.bXenoInfectedSpecialHurt)
		{
			npc.bXenoInfectedSpecialHurt = true;
			npc.flXenoInfectedSpecialHurtTime = GetGameTime(npc.index) + 2.0;
			SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.index, 150, 255, 150, 65);
			CreateTimer(2.0, ZSMainPoisonZombie_Revert_Poison_Zombie_Resistance, EntIndexToEntRef(victim), TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(10.0, ZSMainPoisonZombie_Revert_Poison_Zombie_Resistance_Enable, EntIndexToEntRef(victim), TIMER_FLAG_NO_MAPCHANGE);
		}
		float TrueArmor = 1.0;
		if(!NpcStats_IsEnemySilenced(victim))
		{
			if(fl_TotalArmor[npc.index] == 1.0)
			{
				if(npc.flXenoInfectedSpecialHurtTime > GetGameTime(npc.index))
				{
					TrueArmor *= 0.25;
					fl_TotalArmor[npc.index] = TrueArmor;
					OnTakeDamageNpcBaseArmorLogic(victim, attacker, damage, damagetype, true);
				}
			}
		}
		fl_TotalArmor[npc.index] = TrueArmor;
	}
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static Action ZSMainPoisonZombie_Revert_Poison_Zombie_Resistance(Handle timer, int ref)
{
	int zombie = EntRefToEntIndex(ref);
	if(IsValidEntity(zombie))
	{
		SetEntityRenderMode(zombie, RENDER_NORMAL);
		SetEntityRenderColor(zombie, 255, 255, 255, 255);
	}
	return Plugin_Handled;
}

static Action ZSMainPoisonZombie_Revert_Poison_Zombie_Resistance_Enable(Handle timer, int ref)
{
	int zombie = EntRefToEntIndex(ref);
	if(IsValidEntity(zombie))
	{
		ZSMainPoisonZombie npc = view_as<ZSMainPoisonZombie>(zombie);
		npc.bXenoInfectedSpecialHurt = false;
	}
	return Plugin_Handled;
}

static void ZSMainPoisonZombie_NPCDeath(int entity)
{
	ZSMainPoisonZombie npc = view_as<ZSMainPoisonZombie>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
}