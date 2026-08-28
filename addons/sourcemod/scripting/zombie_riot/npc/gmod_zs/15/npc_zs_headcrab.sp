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

static any ClotSummon_ALT(int client, float vecPos[3], float vecAng[3], int team)
{
	return ZSHeadcrab(vecPos, vecAng, team, true);
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ZSHeadcrab(vecPos, vecAng, team, false);
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
	
	public ZSHeadcrab(float vecPos[3], float vecAng[3], int ally, bool Alt)
	{
		ZSHeadcrab npc = view_as<ZSHeadcrab>(CClotBody(vecPos, vecAng, "models/headcrabclassic.mdl", "1.25", (Alt ? "600" : "400"), ally, false));
		// 3000 x 0.15
		// 4000 x 0.15

		i_NpcWeight[npc.index] = 0;
		npc.SetActivity("ACT_RUN");
		KillFeed_SetKillIcon(npc.index, "bread_bite");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		func_NPCDeath[npc.index] = ZSHeadcrab_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = ZSHeadcrab_OnTakeDamage;
		func_NPCThink[npc.index] = ZSHeadcrab_ClotThink;
		
		npc.m_flSpeed = (Alt ? 475.0 : 260.0);	// 1.9 x 250
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_flMeleeArmor = 3.0;
		f_ExtraOffsetNpcHudAbove[npc.index] = -65.0;
		npc.m_bFUCKYOU = Alt;
		if(Alt)
		{
			SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.index, 255, 0, 0, 255);
		}

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

	if(npc.m_iTarget && !IsValidEnemy(npc.index, npc.m_iTarget))
		npc.m_iTarget = 0;
	
	if(!npc.m_iTarget || npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	if(npc.m_iTarget > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float distance = GetVectorDistance(vecTarget, VecSelfNpc, true);	
		
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
				npc.m_flAttackHappens = 0.0;
				
				Handle swingTrace;
				npc.FaceTowards(vecTarget, 15000.0);
				npc.m_bAllowBackWalking = false;
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, _))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);

					if(target > 0) 
					{
						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, (npc.m_bFUCKYOU ? 150.0 : 100.0), DMG_CLUB, -1, _, vecHit);
						if(npc.m_bFUCKYOU)
							StartBleedingTimer(target, npc.index, 5.0, 2, -1, DMG_TRUEDAMAGE, 0);
					}
				}

				delete swingTrace;
			}
		}

		if(distance < 10000.0 && npc.m_flNextMeleeAttack < gameTime)
		{
			if(npc.m_bFUCKYOU)
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
	else
	{
		npc.StopPathing();
	}

	npc.PlayIdleSound();
}

static Action ZSHeadcrab_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker < 1)
		return Plugin_Continue;
		
	ZSHeadcrab npc = view_as<ZSHeadcrab>(victim);
	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

static void ZSHeadcrab_NPCDeath(int entity)
{
	ZSHeadcrab npc = view_as<ZSHeadcrab>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	if(npc.m_bFUCKYOU)
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

