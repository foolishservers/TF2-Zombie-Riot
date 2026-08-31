#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/headcrab/die1.wav",
	"npc/headcrab/die2.wav"
};

static const char g_HurtSound[][] = {
	"npc/headcrab/pain1.wav",
	"npc/headcrab/pain2.wav",
	"npc/headcrab/pain3.wav"
};

static const char g_IdleSound[][] = {
	"npc/headcrab/alert1.wav",
	"npc/headcrab/idle3.wav"
};


static const char g_MeleeAttackSounds[][] = {
	"npc/headcrab/attack1.wav",
	"npc/headcrab/attack2.wav",
	"npc/headcrab/attack3.wav"
};

static const char g_MeleeHitSounds[] = "npc/headcrab/headbite.wav";

public void ZSHeadcrab_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Headcrab");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_headcrab");
	strcopy(data.Icon, sizeof(data.Icon), "gmod_zs_headcrab");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_GmodZS;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
	
	strcopy(data.Name, sizeof(data.Name), "Angry Headcrab");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_angryheadcrab");
	strcopy(data.Icon, sizeof(data.Icon), "ds_runner");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_GmodZS;
	data.Func = ClotSummon_ALT;
	NPC_Add(data);
	
	strcopy(data.Name, sizeof(data.Name), "Z-Main Headcrab");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_zmain_headcrab");
	strcopy(data.Icon, sizeof(data.Icon), "gmod_zs_headcrab");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_GmodZS;
	data.Func = ClotSummon_ZMain;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_IdleSound);
	PrecacheSoundArray(g_HurtSound);
	PrecacheSound(g_MeleeHitSounds);
	PrecacheModel("models/headcrabclassic.mdl");
}

static any ClotSummon_ZMain(int client, float vecPos[3], float vecAng[3], int team)
{
	return ZSHeadcrab(vecPos, vecAng, team, 2);
}
static any ClotSummon_ALT(int client, float vecPos[3], float vecAng[3], int team)
{
	return ZSHeadcrab(vecPos, vecAng, team, 1);
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ZSHeadcrab(vecPos, vecAng, team, 0);
}

static char[] GetHeadcrabHealth(int SelectInt)
{
	int health = 400;
	switch(SelectInt)
	{
		case 1:health = 600;
		case 2:health = 3000;
		default:health = 400;
	}
	char buffer[16];
	IntToString(health, buffer, sizeof(buffer));
	return buffer;
}

methodmap ZSHeadcrab < CSeaBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSound[GetRandomInt(0, sizeof(g_IdleSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSound[GetRandomInt(0, sizeof(g_HurtSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds, this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);	
	}
	
	public ZSHeadcrab(float vecPos[3], float vecAng[3], int ally, int Alt)
	{
		ZSHeadcrab npc = view_as<ZSHeadcrab>(CClotBody(vecPos, vecAng, "models/headcrabclassic.mdl", (Alt==2 ? "1.15" : "1.25"), GetHeadcrabHealth(Alt), ally, false));

		i_NpcWeight[npc.index] = (Alt==2 ? 1 : 0);
		npc.SetActivity("ACT_RUN");
		KillFeed_SetKillIcon(npc.index, "bread_bite");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		func_NPCDeath[npc.index] = ZSHeadcrab_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = ZSHeadcrab_ClotThink;
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_flRangedArmor = 1.0;
		npc.m_flMeleeArmor = (Alt==2 ? 1.0 : 3.0);
		f_ExtraOffsetNpcHudAbove[npc.index] = -65.0;
		
		switch(Alt)
		{
			case 1:
			{
				SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.index, 255, 0, 0, 255);
				npc.m_flSpeed = 475.0;
			}
			case 2:
			{
				fl_AbilityOrAttack[npc.index][0] = 0.0;
				fl_AbilityOrAttack[npc.index][1] = 0.0;
				fl_AbilityOrAttack[npc.index][2] = 0.0;
				fl_AbilityOrAttack[npc.index][3] = 1.0 + GetGameTime(npc.index);
				fl_AbilityOrAttack[npc.index][4] = 30.0 + GetGameTime(npc.index);
				fl_AbilityOrAttack[npc.index][5] = 0.0;
				npc.m_iOverlordComboAttack = 0;
				f_MaxAnimationSpeed[npc.index] = 1.5;
				b_AvoidBuildingsAtAllCosts[npc.index] = true;
				npc.m_flSpeed = 400.0;
			}
			default:npc.m_flSpeed = 260.0;
		}
		npc.m_iState = Alt;
		npc.StartPathing();

		return npc;
	}
}

static void ZSHeadcrab_ClotThink(int iNPC)
{
	ZSHeadcrab npc = view_as<ZSHeadcrab>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float distance = GetVectorDistance(vecTarget, VecSelfNpc, true);	
		
		if(npc.m_iState==2)
		{
			ZSZmain_SelfDefense(npc, gameTime, vecTarget, distance);
			ZSZmain npcGetInfo = view_as<ZSZmain>(npc.index);
			switch(ZSZmain_AnnoyingLogic(npcGetInfo, gameTime, vecTarget, distance))
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
						npc.m_flSpeed = 400.0;
						npc.StartPathing();
					}
					if(distance < npc.GetLeadRadius()) 
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
							if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.5))
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
						npc.m_flSpeed = 400.0;
						npc.StartPathing();
					}
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
				}
				case 3:
				{
					if(npc.m_iChanged_WalkCycle != 3)
					{
						npc.m_bPathing = true;
						npc.m_bisWalking = true;
						npc.m_bAllowBackWalking = false;
						npc.m_iChanged_WalkCycle = 3;
						npc.m_flSpeed = 400.0;
						npc.StartPathing();
					}
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
				}
				case 4:
				{
					if(npc.m_iChanged_WalkCycle != 4)
					{
						npc.m_bPathing = true;
						npc.m_bisWalking = true;
						npc.m_bAllowBackWalking = true;
						npc.m_iChanged_WalkCycle = 4;
						npc.m_flSpeed = 400.0;
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
			if(distance < npc.GetLeadRadius())
			{
				float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
				npc.SetGoalVector(vPredictedPos);
			}
			else 
			{
				npc.SetGoalEntity(npc.m_iTarget);
			}
			npc.StartPathing();

			if(npc.m_flAttackHappens)
			{
				if(npc.m_flAttackHappens < gameTime)
				{
					float fDamage = 100.0;
					switch(npc.m_iState)
					{
						case 1:fDamage=150.0;
						default:fDamage=100.0;
					}
					npc.m_flAttackHappens = 0.0;
					
					Handle swingTrace;
					npc.FaceTowards(vecTarget, 15000.0);
					npc.m_bAllowBackWalking = false;
					if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
					{
						int target = TR_GetEntityIndex(swingTrace);
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);

						if(target > 0) 
						{
							if(ShouldNpcDealBonusDamage(target))
								fDamage*=5.0;
							npc.PlayMeleeHitSound();
							SDKHooks_TakeDamage(target, npc.index, npc.index, fDamage, DMG_CLUB, -1, _, vecHit);
							if(npc.m_iState==1)
								StartBleedingTimer(target, npc.index, 5.0, 2, -1, DMG_TRUEDAMAGE, 0);
						}
					}
					delete swingTrace;
				}
			}

			if(distance < 10000.0 && npc.m_flNextMeleeAttack < gameTime)
			{
				if(npc.m_iState==1)
				{
					npc.m_bAllowBackWalking = false;
					int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					if(IsValidEnemy(npc.index, target))
					{
						npc.m_iTarget = target;

						npc.AddGesture("ACT_RANGE_ATTACK1");

						npc.PlayMeleeSound();
						
						npc.m_flAttackHappens = gameTime + 0.45;
						npc.m_flNextMeleeAttack = gameTime + 1.25;
						npc.m_flHeadshotCooldown = gameTime + 1.25;
					}
				}
				else
				{
					npc.m_bAllowBackWalking = true;
					int PrimaryThreatIndex = npc.m_iTarget;
					float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
					if(flDistanceToTarget < 6000.0) //too close, back off!! Now!
					{
						npc.StartPathing();
						
						int Enemy_I_See;
					
						Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
						//Target close enough to hit
						if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
						{
							float vBackoffPos[3];
							npc.m_flSpeed = 600.0;
							BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex, 300.0, vBackoffPos);
							npc.SetGoalVector(vBackoffPos, true);
						}
					}
					else
					{
						int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
						if(IsValidEnemy(npc.index, target))
						{
							npc.m_iTarget = target;
							npc.m_flSpeed = 231.0;
							npc.AddGesture("ACT_RANGE_ATTACK1");
							PluginBot_Jump(npc.index, vecTarget);

							npc.PlayMeleeSound();

							npc.m_flAttackHappens = gameTime + 0.08;
							npc.m_flNextMeleeAttack = gameTime + 0.8;
							npc.m_flHeadshotCooldown = gameTime + 0.8;
						}
					}
				}
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.StopPathing();
	}

	npc.PlayIdleSound();
}

static void ZSZmain_SelfDefense(ZSHeadcrab npc, float gameTime, float VecEnemy[3], float distance)
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
					ScaleVector(vecForward, -282.5);
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
				npc.AddGesture("ACT_RANGE_ATTACK1");
				
				npc.m_flAttackHappens = gameTime + 0.08;
				npc.m_flNextMeleeAttack = gameTime + 0.8;
				npc.m_flHeadshotCooldown = gameTime + 0.8;
			}
		}
	}
}

static void ZSHeadcrab_NPCDeath(int entity)
{
	ZSHeadcrab npc = view_as<ZSHeadcrab>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	if(npc.m_iState==1)
	{
		float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
		Explode_Logic_Custom(40.0, npc.index, npc.index, -1, vecMe, 200.0, 1.0, _, true, 15, _, _, Angryheadcrab_ExplodePost);
		DataPack pack_boom = new DataPack();
		pack_boom.WriteFloat(vecMe[0]);
		pack_boom.WriteFloat(vecMe[1]);
		pack_boom.WriteFloat(vecMe[2]);
		pack_boom.WriteCell(1);
		RequestFrame(MakeExplosionFrameLater, pack_boom);
	}
}

static void Angryheadcrab_ExplodePost(int attacker, int victim, float damage, int weapon)
{
	StartBleedingTimer(victim, attacker, 5.0, 2, -1, DMG_TRUEDAMAGE, 0);
}

