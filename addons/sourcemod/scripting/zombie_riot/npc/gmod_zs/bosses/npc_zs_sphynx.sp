#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/antlion_guard/antlion_guard_die1.wav",
	"npc/antlion_guard/antlion_guard_die2.wav"
};

static char g_HurtSounds[][] = {
	"npc/headcrab_poison/ph_pain1.wav",
	"npc/headcrab_poison/ph_pain2.wav",
	"npc/headcrab_poison/ph_pain3.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"npc/headcrab_poison/ph_rattle1.wav",
	"npc/headcrab_poison/ph_rattle2.wav",
	"npc/headcrab_poison/ph_rattle3.wav",
	"npc/antlion/idle1.wav",
	"npc/antlion/idle2.wav",
	"npc/antlion/idle3.wav",
	"npc/antlion/idle4.wav",
	"npc/antlion/idle5.wav",
};

static char g_MeleeAttackSounds[][] = {
	"npc/antlion_guard/angry1.wav",
	"npc/antlion_guard/angry2.wav",
	"npc/antlion_guard/angry3.wav",
};

static const char g_MeleeHitSounds[][] = {
	"npc/antlion_guard/shove1.wav",
	"npc/vort/foot_hit.wav",
};

static char g_MeleeMissSounds[][] = {
	"npc/antlion_guard/foot_light1.wav",
	"npc/antlion_guard/foot_light2.wav",
};

void ZSSphynx_OnMapStart_NPC()
{
	PrecacheModel("models/antlion_guard.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Sphynx");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_sphynx");
	strcopy(data.Icon, sizeof(data.Icon), "gmod_zs_sphynx");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_GmodZS;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	i++) { PrecacheSound(g_DeathSounds[i]);	}
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return ZSSphynx(vecPos, vecAng, team, data);
}

methodmap ZSSphynx < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 90);
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(8.0, 16.0);
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 90);
	}

	public void PlayHurtSound() 
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 90);
	}

	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 90);
	}

	public void PlayMeleeAttackSound() 
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 90);
	}

	public void PlayMeleeMissSound() 
	{
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 90);
	}
	
	public void PlayBuffSound()
	{
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 70);
	}
	
	public void PlayHealSound()
	{
		EmitSoundToAll("items/medshot4.wav", this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 110);
	}
	
	property float m_flNextBuffTime
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	property float m_flNextAllyCheckTime
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	
	property int m_iActionResult
	{
		public get()			{ return this.m_iOverlordComboAttack; }
		public set(int value) 	{ this.m_iOverlordComboAttack = value; }
	}
	
	property bool m_bDropMoney
	{
		public get()			{ return this.m_bFUCKYOU; }
		public set(bool value) 	{ this.m_bFUCKYOU = value; }
	}
	
	public ZSSphynx(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		ZSSphynx npc = view_as<ZSSphynx>(CClotBody(vecPos, vecAng, "models/antlion_guard.mdl", "1.0", "1000", ally));
		
		i_NpcWeight[npc.index] = 4;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_RUN");
		if(iActivity > 0)
			npc.StartActivity(iActivity);
		
		npc.m_iState = 0;
		npc.m_iActionResult = 0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextBuffTime = GetGameTime(npc.index) + 2.5;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		npc.m_bDropMoney = true;
		
		if(StrContains(data, "nomoney") != -1)
		{
			npc.m_bDropMoney = false;
		}
		
		SetEntityRenderColor(npc.index, 255, 0, 0, 255);
		func_NPCDeath[npc.index] = view_as<Function>(ZSSphynx_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(ZSSphynx_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ZSSphynx_ClotThink);
		
		npc.StartPathing();
		npc.m_flSpeed = 330.0;
		
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				ShowGameText(client_check, "voice_player", 1, "%t", "Sphynx Spawned");
			}
		}
		
		npc.m_bDissapearOnDeath = false;
		
		if(!IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 9000.0;
			RaidModeScaling = 0.0;
			RaidAllowsBuildings = true;
		}
		
		return npc;
	}
}

public void ZSSphynx_ExplodePost(int attacker, int victim, float damage, int weapon)
{
	Elemental_AddNervousDamage(victim, attacker, view_as<ZSSphynx>(attacker) ? 3 : 2);
	// 140 x 0.05 x 0.15
	// 160 x 0.05 x 0.15
	// 140 x 0.1 x 0.15
}

public void ZSSphynx_ClotThink(int iNPC)
{
	ZSSphynx npc = view_as<ZSSphynx>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		//npc.AddGesture("ACT_BIG_FLINCH", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flDoingAnimation < gameTime)
	{
		switch (npc.m_iActionResult)
		{
			// Melee.
			case 1:
			{
				ExpidonsaGroupHeal(npc.index, 350.0, 15, 1000.0, 1.0, false, Expidonsa_DontHealSameIndex);
				
				float vecMe[3];
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", vecMe);
				spawnRing_Vectors(vecMe, 1.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 125, 0, 0, 200, 1, 0.3, 5.0, 8.0, 3, 700.0);	
				
				npc.PlayHealSound();
				
				//WorldSpaceCenter(npc.index, vecMe);
				//Explode_Logic_Custom(1.0, -1, npc.index, -1, vecMe, 175.0, 150.0, 150.0, true, 14, false);
				
				npc.StartPathing();
				npc.m_iActionResult = 0;
			}
			
			// Special Buff.
			case 2:
			{
				npc.StartPathing();
				npc.m_iActionResult = 0;
			}
		}
	}
	
	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	if(!npc.Anger && npc.m_flNextAllyCheckTime < gameTime)
	{
		if(!IsValidAlly(npc.index, GetClosestAlly(npc.index)))
		{
			npc.Anger = true;
		}
		else
		{
			npc.m_flNextAllyCheckTime = gameTime + 4.0;
		}
	}
	
	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; 
		float vecMe[3];
		
		WorldSpaceCenter(npc.m_iTarget, vecTarget);
		WorldSpaceCenter(npc.index, vecMe);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
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
		
		ZSSphynxSelfDefense(npc, gameTime, npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	npc.PlayIdleAlertSound();
}

#define ZSSPHYNX_RANGE 350.0
#define ZSSPHYNX_RANGE_SQ 122500.0
void ZSSphynx_ApplyBuffInLocation_Optimized(int me, float myPos[3], int team, int ignoreEntity = 0, float duration = 10.0)
{
	float targetPos[3];
	
	// 1. 플레이어 루프
	for(int ally = 1; ally <= MaxClients; ally++)
	{
		if(IsClientInGame(ally) && IsPlayerAlive(ally) && GetTeam(ally) == team)
		{
			GetClientAbsOrigin(ally, targetPos);
			
			// 단순 X, Y 거리 필터링 (선택 사항)
			if (GetVectorDistance(myPos, targetPos, true) <= ZSSPHYNX_RANGE_SQ)
			{
				ApplyStatusEffect(me, ally, "Godly Motivation", duration);
			}
		}
	}
	
	for(int i = 0; i < i_MaxcountNpcTotal; i++)
	{
		int ally = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		
		if (ally != -1 && IsValidEntity(ally) && !b_NpcHasDied[ally] && GetTeam(ally) == team && ignoreEntity != ally)
		{
			GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", targetPos);
			
			if (GetVectorDistance(myPos, targetPos, true) <= ZSSPHYNX_RANGE_SQ)
			{
				ApplyStatusEffect(me, ally, "Godly Motivation", duration);
			}
		}
	}
}

static Action ZSSphynx_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	ZSSphynx npc = view_as<ZSSphynx>(victim);
	
	if(attacker <= 0)
		return Plugin_Continue;
	
	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void ZSSphynx_NPCDeath(int entity)
{
	ZSSphynx npc = view_as<ZSSphynx>(entity);
	
	if(npc.m_bDropMoney)
		SpawnMoney(npc.index, true);
	
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();
	}
}

/*
static Action Timer_RemoveEntityZSSphynx(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		float pos[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		TE_Particle("env_sawblood", pos, NULL_VECTOR, NULL_VECTOR, entity, _, _, _, _, _, _, _, _, _, 0.0);
		//TeleportEntity(entity, OFF_THE_MAP, NULL_VECTOR, NULL_VECTOR); // send it away first in case it feels like dying dramatically
		RemoveEntity(entity);
	}
	return Plugin_Handled;
}
*/

static void ZSSphynxSelfDefense(ZSSphynx npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens && npc.m_flAttackHappens < gameTime)
	{
		npc.m_flAttackHappens = 0.0;
		
		float vecEnemy[3];
		WorldSpaceCenter(npc.m_iTarget, vecEnemy);
		npc.FaceTowards(vecEnemy, 15000.0);
		
		static float vecMax[3] = {150.0, 150.0, 150.0};
		static float vecMin[3] = {-150.0 ,-150.0, -150.0};
		
		// Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
		Handle swingTrace;
		if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, vecMax, vecMin))
		{
			int targetHit = TR_GetEntityIndex(swingTrace);
			
			float vecHit[3];
			TR_GetEndPosition(vecHit, swingTrace);
			
			if(IsValidEnemy(npc.index, targetHit))
			{
				float damageDealt = 300.0;
				
				if(ShouldNpcDealBonusDamage(targetHit))
					damageDealt *= 1.5;
				
				float DamageDoExtra = MultiGlobalHealth;
				if (DamageDoExtra != 1.0)
					DamageDoExtra *= 1.5;
				
				damageDealt *= DamageDoExtra;
				
				KillFeed_SetKillIcon(npc.index, "warrior_spirit");
				
				SDKHooks_TakeDamage(targetHit, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
				
				if (targetHit <= MaxClients)
					Custom_Knockback(npc.index, targetHit, 600.0);
				
				CreateEarthquake(vecHit, 1.0, 128.0, 16.0, 255.0);
				
				// Hit sound
				npc.PlayMeleeHitSound();
			}
		}
		
		delete swingTrace;
	}
	
	if(gameTime < npc.m_flDoingAnimation)
	{
		npc.m_iState = -1;
	}
	else if(gameTime > npc.m_flNextBuffTime)
	{
		npc.m_iState = 2;
	}
	else if(gameTime > npc.m_flNextMeleeAttack && distance < GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED)
	{
		npc.m_iState = 1;
	}
	else
	{
		npc.m_iState = 0;
	}
	
	switch(npc.m_iState)
	{
		case -1:
		{
			return;
		}
		case 0:
		{
			if (!npc.m_bPathing)
				npc.StartPathing();
			
			npc.SetActivity("ACT_RUN");
		}
		case 1:
		{
			int Enemy_I_See = Can_I_See_Enemy(npc.index, target);
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				
				if(npc.Anger)
				{
					npc.AddGesture("ACT_MELEE_ATTACK1", .SetGestureSpeed = 1.5);
					
					npc.m_flAttackHappens = gameTime + 0.2345;
					npc.m_flDoingAnimation = gameTime + 1.072;
					npc.m_flNextMeleeAttack = gameTime + 1.34;
				}
				else
				{
					npc.AddGesture("ACT_MELEE_ATTACK1");
					
					npc.m_flAttackHappens = gameTime + 0.35;
					npc.m_flDoingAnimation = gameTime + 1.6;
					npc.m_flNextMeleeAttack = gameTime + 2.0;
				}
				
				npc.m_iActionResult = 1;
				
				npc.StopPathing();
			}
		}
		case 2:
		{
			npc.AddGesture("ACT_ANTLIONGUARD_BARK");
			
			npc.m_flDoingAnimation = gameTime + 2.5;
			npc.m_flNextBuffTime = gameTime + 12.5;
			npc.m_iActionResult = 2;
			
			npc.PlayBuffSound();
			
			float vecMe[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", vecMe);
			ZSSphynx_ApplyBuffInLocation_Optimized(npc.index, vecMe, GetTeam(npc.index), npc.Anger ? 0 : npc.index);
			
			spawnRing_Vectors(vecMe, 0.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 125, 50, 50, 200, 1, 3.0, 20.0, 10.0, 1, ZSSPHYNX_RANGE * 2.0);
			spawnRing_Vectors(vecMe, 0.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 125, 50, 50, 200, 1, 2.0, 20.0, 10.0, 1, ZSSPHYNX_RANGE * 2.5);
			spawnRing_Vectors(vecMe, 0.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 125, 50, 50, 200, 1, 1.0, 20.0, 10.0, 1, ZSSPHYNX_RANGE * 3.0);
			
			npc.StopPathing();
		}
	}
}