#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/mvm/norm/demoman_mvm_paincrticialdeath01.mp3",
	"vo/mvm/norm/demoman_mvm_paincrticialdeath02.mp3",
	"vo/mvm/norm/demoman_mvm_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/mvm/norm/demoman_mvm_painsharp01.mp3",
	"vo/mvm/norm/demoman_mvm_painsharp02.mp3",
	"vo/mvm/norm/demoman_mvm_painsharp03.mp3",
	"vo/mvm/norm/demoman_mvm_painsharp04.mp3",
	"vo/mvm/norm/demoman_mvm_painsharp05.mp3",
	"vo/mvm/norm/demoman_mvm_painsharp06.mp3",
	"vo/mvm/norm/demoman_mvm_painsharp07.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/norm/demoman_mvm_battlecry01.mp3",
	"vo/mvm/norm/demoman_mvm_battlecry02.mp3",
	"vo/mvm/norm/demoman_mvm_battlecry03.mp3",
	"vo/mvm/norm/demoman_mvm_battlecry04.mp3",
	"vo/mvm/norm/demoman_mvm_battlecry05.mp3",
	"vo/mvm/norm/demoman_mvm_battlecry06.mp3",
	"vo/mvm/norm/demoman_mvm_battlecry07.mp3",
};

static const char g_AngrySounds[][] = {
	"vo/mvm/mght/taunts/demoman_mvm_m_taunts01.mp3",
	"vo/mvm/mght/taunts/demoman_mvm_m_taunts02.mp3",
	"vo/mvm/mght/taunts/demoman_mvm_m_taunts04.mp3",
	"vo/mvm/mght/taunts/demoman_mvm_m_taunts05.mp3",
	"vo/mvm/mght/taunts/demoman_mvm_m_taunts06.mp3",
	"vo/mvm/mght/taunts/demoman_mvm_m_taunts07.mp3",
	"vo/mvm/mght/taunts/demoman_mvm_m_taunts08.mp3",
	"vo/mvm/mght/taunts/demoman_mvm_m_taunts09.mp3",
	"vo/mvm/mght/taunts/demoman_mvm_m_taunts10.mp3",
	"vo/mvm/mght/taunts/demoman_mvm_m_taunts11.mp3",
	"vo/mvm/mght/taunts/demoman_mvm_m_taunts12.mp3",
	"vo/mvm/mght/taunts/demoman_mvm_m_taunts13.mp3",
	"vo/mvm/mght/taunts/demoman_mvm_m_taunts14.mp3",
	"vo/mvm/mght/taunts/demoman_mvm_m_taunts15.mp3",
	"vo/mvm/mght/taunts/demoman_mvm_m_taunts16.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/samurai/tf_katana_01.wav",
	"weapons/samurai/tf_katana_02.wav",
	"weapons/samurai/tf_katana_03.wav",
	"weapons/samurai/tf_katana_04.wav",
	"weapons/samurai/tf_katana_05.wav",
	"weapons/samurai/tf_katana_06.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/samurai/tf_katana_slice_01.wav",
	"weapons/samurai/tf_katana_slice_02.wav",
	"weapons/samurai/tf_katana_slice_03.wav",
};

void Anti_Chaos_Robot_OnMapStart_NPC()
{
	PrecacheModel("models/bots/demo_boss/bot_demo_boss.mdl");
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Anti Chaos Robot");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_anti_chaos_robot");
	strcopy(data.Icon, sizeof(data.Icon), "demo_robot_nys");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_AlminaExpiAlliance;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_AngrySounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Anti_Chaos_Robot(vecPos, vecAng, ally, data);
}

methodmap Anti_Chaos_Robot < CClotBody {
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayAngrySound() 
	{
		EmitSoundToAll(g_AngrySounds[GetRandomInt(0, sizeof(g_AngrySounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public Anti_Chaos_Robot(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Anti_Chaos_Robot npc = view_as<Anti_Chaos_Robot>(CClotBody(vecPos, vecAng, "models/bots/demo_boss/bot_demo_boss.mdl", "1.5", "4000", ally, false, true));
		
		i_NpcWeight[npc.index] = 4;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_MP_RUN_ITEM1");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_PANZER;
		
		npc.m_iState = 0;
		if(StrContains(data, "bossrush") != -1)
		{
			npc.m_iState = 1;
		}
		
		if(StrContains(data, "almina") == -1)
		{
			FormatEx(c_NpcName[npc.index], sizeof(c_NpcName[]), "Captured Anti Chaos Robot");
		}
		
		func_NPCDeath[npc.index] = Anti_Chaos_Robot_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Anti_Chaos_Robot_OnTakeDamage;
		func_NPCThink[npc.index] = Anti_Chaos_Robot_ClotThink;
		
		npc.m_bLostHalfHealth = false;
		npc.m_bThisNpcIsABoss = true;
		
		npc.StartPathing();
		npc.m_flSpeed = 175.0;
		npc.m_flGetClosestTargetTime = 0.0;
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/demo/hwn2022_nightbane_brim/hwn2022_nightbane_brim.mdl");
		
		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/workshop/player/items/demo/sf14_deadking_pauldrons/sf14_deadking_pauldrons.mdl");
		
		npc.m_iWearable3 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_shogun_katana/c_shogun_katana.mdl");
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/soldier/bak_caped_crusader/bak_caped_crusader.mdl");
		
		SetEntityRenderColor(npc.m_iWearable1, 175, 100, 100, 255);
		SetEntityRenderColor(npc.m_iWearable2, 200, 50, 50, 255);
		SetEntityRenderColor(npc.m_iWearable3, 150, 150, 150, 255);
		SetEntityRenderColor(npc.m_iWearable4, 200, 150, 100, 255);
		
		return npc;
	}
}

static void Anti_Chaos_Robot_ClotThink(int entity)
{
	Anti_Chaos_Robot npc = view_as<Anti_Chaos_Robot>(entity);
	
	float gameTime = GetGameTime(npc.index);
	if (npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if (npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if (npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	if (npc.m_bLostHalfHealth)
	{
		npc.m_flSpeed = 300.0;
	}
	else
	{
		npc.m_flSpeed = 175.0;
	}
	
	float vecSelfPos[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", vecSelfPos);
	
	float range = 250.0;
	ApplyHeavyPresenceDebuffInLocation(vecSelfPos, GetTeam(npc.index), range);
	
	if (npc.m_iState == 0)
	{
		spawnRing_Vectors(vecSelfPos, range * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", 125, 50, 50, 200, 1, /*duration*/ 0.11, 20.0, 5.0, 1);	
	}
	
	if (npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3];
		WorldSpaceCenter(npc.m_iTarget, vecTarget);
		WorldSpaceCenter(npc.index, vecSelfPos);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecSelfPos, true);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vecPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget, _, _, vecPredictedPos);
			npc.SetGoalVector(vecPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		
		Anti_Chaos_Robot_AttackThink(npc, gameTime, npc.m_iTarget, flDistanceToTarget);
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	npc.PlayIdleAlertSound();
}

static Action Anti_Chaos_Robot_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Anti_Chaos_Robot npc = view_as<Anti_Chaos_Robot>(victim);
	
	if ((ReturnEntityMaxHealth(npc.index) / 2) >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.m_bLostHalfHealth)
	{
		npc.PlayAngrySound();
		
		npc.m_bLostHalfHealth = true;
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 2);
		IgniteTargetEffect(npc.m_iWearable3);
	}
	
	if (attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void Anti_Chaos_Robot_NPCDeath(int entity)
{
	Anti_Chaos_Robot npc = view_as<Anti_Chaos_Robot>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();
	}
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
}

static void Anti_Chaos_Robot_AttackThink(Anti_Chaos_Robot npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			
			float vecEnemy[3];
			WorldSpaceCenter(npc.m_iTarget, vecEnemy);
			
			npc.FaceTowards(vecEnemy, 15000.0);
			
			static float MaxVec[3] = {150.0, 150.0, 150.0};
			static float MinVec[3] = {-150.0, -150.0, -150.0};
			
			// Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			if (npc.DoSwingTrace(swingTrace, npc.m_iTarget, MaxVec, MinVec))
			{
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 250.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 3.0;
					
					if(npc.m_bLostHalfHealth)
					{
						damageDealt *= 1.2;
						NPC_Ignite(target, npc.index, 12.0, -1, damageDealt * 0.05);
					}
					
					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
					
					// Hit sound
					npc.PlayMeleeHitSound();
				}
			}
			
			delete swingTrace;
		}
	}
	
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		// 150 * 150
		if(distance < 22500.0)
		{
			int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM1");
						
				npc.m_flAttackHappens = gameTime + 0.35;
				npc.m_flDoingAnimation = gameTime + 0.35;
				npc.m_flNextMeleeAttack = gameTime + 0.75;
			}
		}
	}
}

void ApplyHeavyPresenceDebuffInLocation(float pos[3], int team, float range)
{
	float targetPos[3];
	for (int target = 1; target <= MaxClients; target++)
	{
		if(IsClientInGame(target) && IsPlayerAlive(target) && GetTeam(target) != team)
		{
			GetClientAbsOrigin(target, targetPos);
			if (GetVectorDistance(pos, targetPos, true) <= (range * range))
			{
				ApplyStatusEffect(target, target, "Heavy Presence", 1.0);
			}
		}
	}
	
	for (int entitycount_again; entitycount_again < i_MaxcountNpcTotal; entitycount_again++)
	{
		int target = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount_again]);
		if (IsValidEntity(target) && !b_NpcHasDied[target] && GetTeam(target) != team)
		{
			GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", targetPos);
			if (GetVectorDistance(pos, targetPos, true) <= (range * range))
			{
				ApplyStatusEffect(target, target, "Heavy Presence", 1.0);
			}
		}
	}
}