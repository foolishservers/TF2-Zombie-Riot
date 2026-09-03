#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/metropolice/die1.wav",
	"npc/metropolice/die2.wav",
	"npc/metropolice/die3.wav",
	"npc/metropolice/die4.wav"
};

static const char g_HurtSounds[] = "npc/metropolice/vo/chuckle.wav";

static const char g_IdleAlertedSounds[] = "npc/metropolice/vo/pickupthecan2.wav";

static const char g_RangedAttackSounds[] = "weapons/quake_rpg_fire_remastered.wav";

void Whiteflower_CombineBazooka_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "W.F. Rocketeer");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_wf_combine_bazooka");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_antiarmor_infantry");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_WhiteflowerSpecial;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSound(g_HurtSounds);
	PrecacheSound(g_IdleAlertedSounds);
	PrecacheSound(g_RangedAttackSounds);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return Whiteflower_CombineBazooka(vecPos, vecAng, ally);
}

methodmap Whiteflower_CombineBazooka < CClotBody {
	public void PlayIdleAlertSound()  {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds, this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_HurtSounds, this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds, this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public Whiteflower_CombineBazooka(float vecPos[3], float vecAng[3], int ally)
	{
		Whiteflower_CombineBazooka npc = view_as<Whiteflower_CombineBazooka>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "2000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextRangedAttack = GetGameTime() + 1.0;
		npc.m_flNextRangedAttackHappening = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE_METRO;
		
		func_NPCDeath[npc.index] = Whiteflower_CombineBazooka_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Whiteflower_CombineBazooka_OnTakeDamage;
		func_NPCThink[npc.index] = Whiteflower_CombineBazooka_ClotThink;
		
		//IDLE
		KillFeed_SetKillIcon(npc.index, "rocketlauncher_directhit");
		
		npc.m_bisWalking = true;
		npc.m_iChanged_WalkCycle = 1;
		npc.SetActivity("ACT_RUN_RPG");
		npc.StartPathing();
		npc.m_flSpeed = 200.0;
		
		Is_a_Medic[npc.index] = true;
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/w_rocket_launcher.mdl");
		
		if(ally != TFTeam_Red)
		{
			if(LastSpawnDiversio < GetGameTime())
			{
				EmitSoundToAll("weapons/sniper_railgun_world_reload.wav", _, _, _, _, 1.0);
				EmitSoundToAll("weapons/sniper_railgun_world_reload.wav", _, _, _, _, 1.0);
				
				for(int client_check=1; client_check<=MaxClients; client_check++)
				{
					if(IsClientInGame(client_check) && !IsFakeClient(client_check))
					{
						SetGlobalTransTarget(client_check);
						ShowGameText(client_check, "voice_player", 1, "%t", "Snipers Appear");
					}
				}
			}
			
			LastSpawnDiversio = GetGameTime() + 20.0;
			TeleportDiversioToRandLocation(npc.index, _, 1750.0, 1250.0);
		}
		
		return npc;
	}
}

static void Whiteflower_CombineBazooka_NPCDeath(int entity)
{
	Whiteflower_CombineBazooka npc = view_as<Whiteflower_CombineBazooka>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}

static Action Whiteflower_CombineBazooka_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker <= 0)
		return Plugin_Continue;
	
	Whiteflower_CombineBazooka npc = view_as<Whiteflower_CombineBazooka>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void Whiteflower_CombineBazooka_ClotThink(int iNPC)
{
	Whiteflower_CombineBazooka npc = view_as<Whiteflower_CombineBazooka>(iNPC);
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
		npc.m_iTargetWalkTo = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTargetWalkTo))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetWalkTo, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
		int ExtraBehavior = Whiteflower_CombineBazooka_SelfDefense(npc, GetGameTime(npc.index));
		switch(ExtraBehavior)
		{
			case 0:
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_RUN_RPG");
					npc.StartPathing();
					npc.m_flSpeed = 200.0;
				}	
			}
			case 1:
			{
				if(npc.m_iChanged_WalkCycle != 2)
				{
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 2;
					npc.SetActivity("ACT_IDLE_ANGRY_RPG");
					npc.StopPathing();
					npc.m_flSpeed = 0.0;
				}
			}
		}

		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTargetWalkTo,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTargetWalkTo);
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTargetWalkTo = GetClosestTarget(npc.index);
	}
	
	npc.PlayIdleAlertSound();
}

static int Whiteflower_CombineBazooka_SelfDefense(Whiteflower_CombineBazooka npc, float gameTime)
{
	if(!npc.m_flAttackHappens)
	{
		if(IsValidEnemy(npc.index,npc.m_iTarget))
		{
			if(!Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
			{
				npc.m_iTarget = GetClosestTarget(npc.index, .CanSee = true, .UseVectorDistance = true);
			}
		}
		else
		{
			npc.m_iTarget = GetClosestTarget(npc.index, .CanSee = true, .UseVectorDistance = true);
			if(!IsValidEnemy(npc.index,npc.m_iTarget))
			{
				return 0;
			}
		}
		
		if(!IsValidEnemy(npc.index,npc.m_iTarget))
		{
			return 0;
		}
	}
	
	if(Rogue_Mode() && i_npcspawnprotection[npc.index] == NPC_SPAWNPROT_ON)
		return 0;
		
	float pos[3];
	WorldSpaceCenter(npc.m_iTarget, pos);
	npc.FaceTowards(pos, 15000.0);
	
	float origin[3], angles[3];
	if (IsValidEntity(npc.m_iWearable1))
	{
		view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
	}
	
	if(npc.m_flDoingAnimation > gameTime)
	{
		if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
		{
			WorldSpaceCenter(npc.m_iTarget, pos);
			
			float pos_npc[3];
			WorldSpaceCenter(npc.index, pos_npc);
			
			float AngleAim[3];
			GetVectorAnglesTwoPoints(pos_npc, pos, AngleAim);
			
			Handle hTrace = TR_TraceRayFilterEx(pos_npc, AngleAim, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
			
			if(TR_DidHit(hTrace))
			{
				TR_GetEndPosition(pos, hTrace);
			}
			
			delete hTrace;
		}
	}
	else
	{	
		if(npc.m_flAttackHappens)
		{
			float pos_npc[3];
			WorldSpaceCenter(npc.index, pos_npc);
			
			float AngleAim[3];
			GetVectorAnglesTwoPoints(pos_npc, pos, AngleAim);
			
			Handle hTrace = TR_TraceRayFilterEx(pos_npc, AngleAim, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
			
			if(TR_DidHit(hTrace))
			{
				TR_GetEndPosition(pos, hTrace);
			}
			
			delete hTrace;
		}
	}
	
	if(npc.m_flAttackHappens)
	{
		TE_SetupBeamPoints(origin, pos, Shared_BEAM_Laser, 0, 0, 0, 0.11, 5.0, 5.0, 0, 0.0, {0,0,255,255}, 3);
		TE_SendToAll(0.0);
	}
	
	npc.FaceTowards(pos, 15000.0);
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			float pos_npc[3];
			WorldSpaceCenter(npc.index, pos_npc);
			float AngleAim[3];
			GetVectorAnglesTwoPoints(pos_npc, pos, AngleAim);
			
			Handle hTrace = TR_TraceRayFilterEx(pos_npc, AngleAim, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
			
			int Traced_Target = TR_GetEntityIndex(hTrace);
			if(Traced_Target > 0)
			{
				WorldSpaceCenter(Traced_Target, pos);
			}
			else if(TR_DidHit(hTrace))
			{
				TR_GetEndPosition(pos, hTrace);
			}
			
			delete hTrace;
			
			npc.m_flNextRangedAttack = gameTime + 0.25;
			npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_RPG");
			npc.m_flDoingAnimation = gameTime + 0.25;
		}
	}
	
	if(npc.m_flNextRangedAttack)
	{
		if(npc.m_flNextRangedAttack < gameTime)
		{
			float EnemyPos[3];
			WorldSpaceCenter(npc.m_iTarget, EnemyPos);
			npc.FaceTowards(EnemyPos, 15000.0);
			
			float damage = 100.0;
			int entity = npc.FireRocket(EnemyPos, damage, 1500.0);
			if(entity != -1)
			{
				SetEntProp(entity, Prop_Send, "m_bCritical", true);
			}
			
			npc.m_flNextRangedAttack = 0.0;
			npc.PlayRangedSound();
			npc.m_flDoingAnimation = gameTime + 0.25;
		}
	}
	
	if(gameTime > npc.m_flNextRangedAttack)
	{
		npc.m_flAttackHappens = gameTime + 2.0;
		npc.m_flNextRangedAttack = gameTime + 2.5;
	}
	
	return 1;
}