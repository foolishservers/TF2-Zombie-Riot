#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"npc/zombie_poison/pz_die1.wav",
	"npc/zombie_poison/pz_die2.wav"
};

static const char g_HurtSounds[][] =
{
	"npc/zombie_poison/pz_pain1.wav",
	"npc/zombie_poison/pz_pain2.wav",
	"npc/zombie_poison/pz_pain3.wav"
};

static const char g_IdleAlertedSounds[][] =
{
	"npc/zombie_poison/pz_alert1.wav",
	"npc/zombie_poison/pz_alert2.wav"
};

static const char g_MeleeHitSounds[][] =
{
	"npc/fast_zombie/claw_strike1.wav",
	"npc/fast_zombie/claw_strike2.wav",
	"npc/fast_zombie/claw_strike3.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"npc/zombie_poison/pz_warn1.wav",
	"npc/zombie_poison/pz_warn2.wav"
};

public void Pregnant_Precache()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Pregnant");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_pregnant");
	strcopy(data.Icon, sizeof(data.Icon), "norm_poison_zombie_forti");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_NORMAL|MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_GmodZS;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
	
	Zombie_Shared_PheromonePrecache();
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheModel("models/zombie/poison.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Pregnant(vecPos, vecAng, team, data);
}

methodmap Pregnant < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, _);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, _);	
	}
	
	property float m_flHealingDelay
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flSelfHealing
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	
	public Pregnant(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Pregnant npc = view_as<Pregnant>(CClotBody(vecPos, vecAng, "models/zombie/poison.mdl", "1.75", "35000", ally, false, true));

		SetVariantInt(31);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		KillFeed_SetKillIcon(npc.index, "warrior_spirit");

		i_NpcWeight[npc.index] = 4;
		npc.SetActivity("ACT_WALK");
		
		npc.m_iBleedType = BLEEDTYPE_DWELLER;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_DWELLER;

		func_NPCDeath[npc.index] = Pregnant_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Pregnant_OnTakeDamage;
		func_NPCThink[npc.index] = Pregnant_ClotThink;
		
		if(!IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 9000.0;
			RaidModeScaling = 0.0;
			RaidAllowsBuildings = true;
		}
		
		npc.m_flSpeed = 320.0;	// 0.5 x 250
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_flHealingDelay = 0.0;
		npc.m_flSelfHealing = 500.0;
		npc.m_iAttacksTillReload = 0;
		npc.m_iAttacksTillMegahit = 0;
		
		static char countext[2][256];
		int count = ExplodeString(data, ";", countext, sizeof(countext), sizeof(countext[]));
		for(int i = 0; i < count; i++)
		{
			if(i>=count)break;
			else if(StrContains(countext[i], "selfhealing") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "selfhealing", "");
				npc.m_flSelfHealing = StringToFloat(countext[i]);
			}
		}
		
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				ShowGameText(client_check, "voice_player", 1, "%t", "Pregnant Spawned");
			}
		}
		return npc;
	}
}

static void Pregnant_ClotThink(int iNPC)
{
	Pregnant npc = view_as<Pregnant>(iNPC);

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
	npc.m_flGetClosestTargetTime = gameTime + 1.0;
	
	float VecSelfNpc[3], vecTarget[3];
	int GetPoisonCrab;
	WorldSpaceCenter(npc.index, VecSelfNpc);
	
	if(npc.m_flHealingDelay < gameTime)
	{
		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[i]);
			if(IsValidEntity(entity))
			{
				char npc_classname[60];
				NPC_GetPluginById(i_NpcInternalId[entity], npc_classname, sizeof(npc_classname));
				if(entity != INVALID_ENT_REFERENCE && StrEqual(npc_classname, "npc_zs_poisonheadcrab") && IsEntityAlive(entity))
				{
					WorldSpaceCenter(entity, vecTarget);
					if(GetVectorDistance(vecTarget, VecSelfNpc, true) < (300.0 * 300.0))
						GetPoisonCrab++;
				}
			}
		}
		if(GetPoisonCrab)
		{
			HealEntityGlobal(npc.index, npc.index, npc.m_flSelfHealing*float(GetPoisonCrab), 1.0);
			npc.m_flHealingDelay = gameTime + 1.0;
		}
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		WorldSpaceCenter(npc.m_iTarget, vecTarget);
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

		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;
				Handle swingTrace;
				float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1))
				{
					int target = TR_GetEntityIndex(swingTrace);
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					if(IsValidEnemy(npc.index, target))
					{
						float flDamage = 1000.0;
						if(ShouldNpcDealBonusDamage(target))
							flDamage *= 2.5;
						else
							Custom_Knockback(npc.index, target, 750.0);
						SDKHooks_TakeDamage(target, npc.index, npc.index, flDamage, DMG_CLUB, -1, _, vecHit);
						Elemental_AddPheromoneDamage(target, npc.index, 200);
						npc.PlayMeleeHitSound();
					}
					npc.m_iAttacksTillMegahit++;
					if(npc.m_iAttacksTillMegahit > 2)
					{
						Pregnant_SpawnFractal(npc, ReturnEntityMaxHealth(npc.index), 4);
						npc.m_iAttacksTillMegahit = 0;
					}
				}
				delete swingTrace;
			}
		}

		if(gameTime > npc.m_flNextMeleeAttack)
		{
			if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*1.1))
			{
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;
					npc.PlayMeleeSound();
					npc.AddGesture("ACT_MELEE_ATTACK1");
					
					npc.m_flAttackHappens = gameTime + 0.75;
					npc.m_flDoingAnimation = gameTime + 0.75;
					npc.m_flNextMeleeAttack = gameTime + 2.75;
				}
			}
		}
		if(npc.m_iChanged_WalkCycle != 1)
		{
			npc.m_iChanged_WalkCycle = 1;
			npc.m_bPathing = true;
			npc.m_bisWalking = true;
			npc.m_bAllowBackWalking = false;
			npc.m_flSpeed = 320.0;
			npc.StartPathing();
		}
	}
	else
	{
		if(npc.m_iChanged_WalkCycle != 2)
		{
			npc.m_iChanged_WalkCycle = 2;
			npc.m_bPathing = false;
			npc.m_bisWalking = false;
			npc.m_bAllowBackWalking = false;
			npc.m_flSpeed = 0.0;
			npc.StopPathing();
		}
	}
	npc.PlayIdleSound();
}

static void Pregnant_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Pregnant npc = view_as<Pregnant>(victim);
	if(attacker > 0)
	{
		if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
		{
			npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
			npc.m_blPlayHurtAnimation = true;
			npc.m_iAttacksTillReload++;
			if(npc.m_iAttacksTillReload > 9)
			{
				Pregnant_SpawnFractal(npc, ReturnEntityMaxHealth(npc.index), 4);
				npc.m_iAttacksTillReload = 0;
			}
		}
	}
	if(!NpcStats_IsEnemySilenced(victim))
	{
		if(!npc.bXenoInfectedSpecialHurt)
		{
			npc.bXenoInfectedSpecialHurt = true;
			npc.flXenoInfectedSpecialHurtTime = GetGameTime(npc.index) + 2.0;
			SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.index, 150, 255, 150, 65);
			CreateTimer(2.0, Pregnant_Revert_Poison_Zombie_Resistance, EntIndexToEntRef(victim), TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(10.0, Pregnant_Revert_Poison_Zombie_Resistance_Enable, EntIndexToEntRef(victim), TIMER_FLAG_NO_MAPCHANGE);
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
}

static Action Pregnant_Revert_Poison_Zombie_Resistance(Handle timer, int ref)
{
	int zombie = EntRefToEntIndex(ref);
	if(IsValidEntity(zombie))
	{
		SetEntityRenderMode(zombie, RENDER_NORMAL);
		SetEntityRenderColor(zombie, 255, 255, 255, 255);
	}
	return Plugin_Handled;
}

static Action Pregnant_Revert_Poison_Zombie_Resistance_Enable(Handle timer, int ref)
{
	int zombie = EntRefToEntIndex(ref);
	if(IsValidEntity(zombie))
	{
		Pregnant npc = view_as<Pregnant>(zombie);
		npc.bXenoInfectedSpecialHurt = false;
	}
	return Plugin_Handled;
}

static void Pregnant_NPCDeath(int entityy)
{
	Pregnant npc = view_as<Pregnant>(entityy);
	SpawnMoney(npc.index, true);
	if(!npc.m_bGib)
		npc.PlayDeathSound();

	int team = GetTeam(entityy);
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(entity != INVALID_ENT_REFERENCE && i_NpcInternalId[entity] == ZSPoisonHeadcrab_ID()
		&& IsEntityAlive(entity) && GetTeam(entity) == team && b_FUCKYOU[entity])
		{
			RequestFrame(KillNpc, i_ObjectsNpcsTotal[i]);
		}
	}
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
}

static void Pregnant_SpawnFractal(Pregnant npc, int health, int limit)
{
	int team = GetTeam(npc.index);
	int count;
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(entity != INVALID_ENT_REFERENCE && i_NpcInternalId[entity] == ZSPoisonHeadcrab_ID()
		&& IsEntityAlive(entity) && GetTeam(entity) == team && b_FUCKYOU[entity])
		{
			if(++count == limit)
				return;
		}
	}

	float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
	
	int entity = NPC_CreateById(ZSPoisonHeadcrab_ID(), -1, pos, ang, GetTeam(npc.index));
	if(entity > MaxClients)
	{
		if(GetTeam(npc.index) != TFTeam_Red)
			Zombies_Currently_Still_Ongoing++;
		if(health > RoundToCeil(float(health)*0.05))
			SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iHealth")-RoundToCeil(float(health)*0.05));
		health *= (1 / 5);
		SetEntProp(entity, Prop_Data, "m_iHealth", health);
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);

		fl_Extra_MeleeArmor[entity] = fl_Extra_MeleeArmor[npc.index];
		fl_Extra_RangedArmor[entity] = fl_Extra_RangedArmor[npc.index];
		fl_Extra_Speed[entity] = fl_Extra_Speed[npc.index];
		fl_Extra_Damage[entity] = fl_Extra_Damage[npc.index];
		b_FUCKYOU[entity]=true;
	}
}