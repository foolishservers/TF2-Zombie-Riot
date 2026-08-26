#pragma semicolon 1
#pragma newdecls required

bool g_infected_messenger_died;
float g_infected_messenger_die;
static const char g_DeathSounds[][] =
{
	"vo/soldier_paincrticialdeath01.mp3",
	"vo/soldier_paincrticialdeath02.mp3",
	"vo/soldier_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] =
{
	"vo/soldier_painsharp01.mp3",
	"vo/soldier_painsharp02.mp3",
	"vo/soldier_painsharp03.mp3",
	"vo/soldier_painsharp04.mp3",
	"vo/soldier_painsharp05.mp3",
	"vo/soldier_painsharp06.mp3",
	"vo/soldier_painsharp07.mp3",
	"vo/soldier_painsharp08.mp3"
};

static const char g_IdleAlertedSounds[][] =
{
	"vo/taunts/soldier_taunts19.mp3",
	"vo/taunts/soldier_taunts20.mp3",
	"vo/taunts/soldier_taunts21.mp3",
	"vo/taunts/soldier_taunts18.mp3"
};

static const char g_MeleeHitSounds[][] =
{
	"weapons/cbar_hit1.wav",
	"weapons/cbar_hit2.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/pickaxe_swing1.wav",
	"weapons/pickaxe_swing2.wav",
	"weapons/pickaxe_swing3.wav"
};

static char g_SummonSounds[][] = {
	"weapons/buff_banner_horn_blue.wav",
	"weapons/buff_banner_horn_red.wav",
};

void InfectedMessengerOnMapStart()
{	
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Infected Messenger Soldier");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_soldier_messenger");
	strcopy(data.Icon, sizeof(data.Icon), "soldier");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_GmodZS;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return InfectedMessenger(vecPos, vecAng, ally);
}

methodmap InfectedMessenger < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _);	
	}
	public void PlaySummonSound() 
	{
		EmitSoundToAll(g_SummonSounds[GetRandomInt(0, sizeof(g_SummonSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		int r = 200;
		int g = 200;
		int b = 255;
		int a = 200;
		
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 1.0, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.9, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.8, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 35.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.7, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 45.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.6, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 55.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.5, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 65.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.4, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 75.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.3, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 85.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.2, 6.0, 6.1, 1);
	}
	property int WhatWaves
	{
		public get()							{ return i_AttacksTillMegahit[this.index]; }
		public set(int TempValueForProperty) 	{ i_AttacksTillMegahit[this.index] = TempValueForProperty; }
	}
	property int InWaves
	{
		public get()							{ return i_OverlordComboAttack[this.index]; }
		public set(int TempValueForProperty) 	{ i_OverlordComboAttack[this.index] = TempValueForProperty; }
	}
	
	public InfectedMessenger(float vecPos[3], float vecAng[3], int ally)
	{
		InfectedMessenger npc = view_as<InfectedMessenger>(CClotBody(vecPos, vecAng, "models/player/soldier.mdl", "1.0", "100000", ally));
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		i_NpcWeight[npc.index] = 3;
		npc.SetActivity("ACT_MP_RUN_MELEE");
		KillFeed_SetKillIcon(npc.index, "pickaxe");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = InfectedMessenger_OnTakeDamage;
		func_NPCThink[npc.index] = ClotThink;
		
		npc.m_flSpeed = 100.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_flRangedArmor = 0.2;
		int WaveSetting = 1;
		i_RaidGrantExtra[npc.index] = WaveSetting;
		npc.WhatWaves = 2;
		npc.InWaves = Waves_GetRoundScale()+1+npc.WhatWaves;
		npc.g_TimesSummoned = 0;
		g_infected_messenger_died=false;
		g_infected_messenger_die=0.0;
		AddNpcToAliveList(npc.index, 1);
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true;
		
		TeleportDiversioToRandLocation(npc.index,_,1750.0, 1250.0);
		
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				ShowGameText(client_check, "voice_player", 1, "%t", "Infected Messenger Spawned");
			}
		}
		
		switch(GetRandomInt(0,2))
		{
			case 0:
			{
				CPrintToChatAll("{green}감염된 전령병{default}: 떨어지는 낙엽도 조심해야 되는 때에 무슨 쌈빡질을 하자고?");
			}
			case 1:
			{
				CPrintToChatAll("{green}감염된 전령병{default}: 내일이면 전역인데 내가 이런 곳까지 끌려와야 된다니!");
			}
			case 2:
			{
				CPrintToChatAll("{green}감염된 전령병{default}: 어디 짱박혀서 숨어있을 만한데 없나..");
			}
		}
		
		int skin = 5;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_battalion_buffpack/c_battalion_buffpack.mdl");

		npc.m_iWearable2	= npc.EquipItem("head", "models/player/items/soldier/soldier_zombie.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		npc.m_iWearable3	= npc.EquipItem("head", "models/workshop/player/items/soldier/sum23_stealth_bomber_style1/sum23_stealth_bomber_style1.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		npc.m_iWearable4	= npc.EquipItem("head", "models/workshop/player/items/soldier/dec19_public_speaker/dec19_public_speaker.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		npc.m_iWearable5	= npc.EquipItem("head", "models/workshop/player/items/soldier/fall17_attack_packs/fall17_attack_packs.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		npc.m_iWearable6	= npc.EquipItem("head", "models/workshop/player/items/soldier/cloud_crasher/cloud_crasher.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);

		return npc;
	}
}

static void ClotThink(int iNPC)
{
    InfectedMessenger npc = view_as<InfectedMessenger>(iNPC);
    float gameTime = GetGameTime(npc.index);
    
    if(npc.m_flNextDelayTime > gameTime) return;
    npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
    npc.Update();

    if(npc.m_blPlayHurtAnimation)
    {
        npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
        npc.PlayHurtSound();
        npc.m_blPlayHurtAnimation = false;
    }
    
    if(npc.m_flNextThinkTime > gameTime) return;
    npc.m_flNextThinkTime = gameTime + 0.1;

    int target = npc.m_iTarget;
    if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target))
        i_Target[npc.index] = -1;
    
    if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < gameTime)
    {
        target = GetClosestTarget(npc.index);
        npc.m_iTarget = target;
        npc.m_flGetClosestTargetTime = gameTime + 1.0;
    }
	
    int maxhealth = ReturnEntityMaxHealth(npc.index);
    int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
    int minhealth = maxhealth / (Rogue_Paradox_RedMoon() ? 8 : 4);
    if(health < minhealth) health = minhealth;
    float hpRatio = float(maxhealth) / float(health);
    if(!NpcStats_IsEnemySilenced(npc.index))
        npc.m_flSpeed = 120.0 + (hpRatio * 100.0);

    if(target > 0)
    {
        float vecTarget[3];
        WorldSpaceCenter(target, vecTarget);
        float vecSelf[3]; 
        WorldSpaceCenter(npc.index, vecSelf);
        
        // 타겟과의 거리 계산
        float distance = GetVectorDistance(vecSelf, vecTarget);

        if(distance <= 1000.0)
        {
            // [도망] 거리가 1000.0 이하일 때: 적의 반대 방향으로 이동
            float vecAway[3];
            SubtractVectors(vecSelf, vecTarget, vecAway);
            NormalizeVector(vecAway, vecAway);
            
            float vecFleeGoal[3];
            ScaleVector(vecAway, 500.0);
            AddVectors(vecSelf, vecAway, vecFleeGoal);
            
            npc.SetGoalVector(vecFleeGoal);
            npc.StartPathing();
        }
        else
        {
            // [추적] 거리가 1000.0보다 멀 때: 타겟의 위치로 직접 이동
            npc.SetGoalVector(vecTarget);
            npc.StartPathing();
        }
    }
    else
    {
        npc.StopPathing();
    }
	
	if(npc.m_iTargetAlly && !IsValidAlly(npc.index, npc.m_iTargetAlly))
		npc.m_iTargetAlly = 0;
	
	if(!g_infected_messenger_died && ((npc.InWaves - (Waves_GetRoundScale()+1) <= 0) || RaidbossIgnoreBuildingsLogic(1) || LastMann))
	{
		CPrintToChatAll("{green}감염된 전령병{default}: 아 드디어 전역이다!!! 내일은 집에서 치킨 뜯어야지");
		LastHitRef[npc.index] = -1;
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		ParticleEffectAt(VecSelfNpc, "teleported_blue", 0.5);
		b_NpcForcepowerupspawn[npc.index] = 0;
		i_RaidGrantExtra[npc.index] = 0;
		b_DissapearOnDeath[npc.index] = true;
		b_DoGibThisNpc[npc.index] = true;
		b_NoKillFeed[npc.index] = true;
		g_infected_messenger_died = true;
		SmiteNpcToDeath(npc.index);
		return;
	}
	if(g_infected_messenger_died)
	{
		npc.m_flNextThinkTime = 0.0;
		npc.StopPathing();
		
		npc.m_bisWalking = false;
		npc.SetActivity("ACT_MP_CROUCH_MELEE");
		npc.m_bisWalking = false;
		if(gameTime > g_infected_messenger_die)
		{
			Spawn_Chaos(npc);
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
			npc.m_bDissapearOnDeath = true;
			SpawnMoney(npc.index, true);
			npc.PlayDeathSound();
		}
		else if(gameTime + 3.0 > g_infected_messenger_die && i_SaidLineAlready[npc.index] < 9)
		{
			i_SaidLineAlready[npc.index] = 9;
			CPrintToChatAll("{green}감염된 전령병{crimson}: 너넨 모두 이 짓거리의 대가를 치루게 될것이다");
		}
		else if(gameTime + 5.0 > g_infected_messenger_die && i_SaidLineAlready[npc.index] < 8)
		{
			i_SaidLineAlready[npc.index] = 8;
			CPrintToChatAll("{green}감염된 전령병{crimson}: 내일이 전역이란 말이다!!!!!");
		}
		else if(gameTime + 8.0 > g_infected_messenger_die && i_SaidLineAlready[npc.index] < 7)
		{
			i_SaidLineAlready[npc.index] = 7;
			CPrintToChatAll("{green}감염된 전령병{default}: 젠장...내일이 전역이란 말이다.....");
		}
		else if(gameTime + 10.0 > g_infected_messenger_die && i_SaidLineAlready[npc.index] < 6)
		{
			i_SaidLineAlready[npc.index] = 6;
			CPrintToChatAll("{green}감염된 전령병{default}: 이래서 이딴 곳에 오고싶지 않았는데 제길");
		}
		else if(gameTime + 12.0 > g_infected_messenger_die && i_SaidLineAlready[npc.index] < 5)
		{
			i_SaidLineAlready[npc.index] = 5;
			CPrintToChatAll("{green}감염된 전령병{default}: 쿨럭....쿨럭....");
		}
		else if(gameTime + 14.0 > g_infected_messenger_die && i_SaidLineAlready[npc.index] < 4)
		{
			i_SaidLineAlready[npc.index] = 4;
			CPrintToChatAll("{green}감염된 전령병{default}: 빌어먹을 행보관은 그저 정찰만 하면 되는 쉬운 임무라고 말해줬는데");
		}
		else if(gameTime + 16.0 > g_infected_messenger_die && i_SaidLineAlready[npc.index] < 3)
		{
			i_SaidLineAlready[npc.index] = 3;
			CPrintToChatAll("{green}감염된 전령병{default}: 아무것도 안하고 짱박혀 있던 날 기어코 찾아내서 죽이다니...");
		}
		else if(gameTime + 18.0 > g_infected_messenger_die && i_SaidLineAlready[npc.index] < 2)
		{
			i_SaidLineAlready[npc.index] = 2;
			CPrintToChatAll("{green}감염된 전령병{default}: 젠장 내가 대체 무슨 잘못을 했길레...");
		}
		else if(gameTime + 20.0 > g_infected_messenger_die && i_SaidLineAlready[npc.index] < 1)
		{
			i_SaidLineAlready[npc.index] = 1;
			CPrintToChatAll("{green}감염된 전령병{default}: 쿨럭...쿨럭....");
		}
	}

    npc.PlayIdleSound();
}

public Action InfectedMessenger_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	InfectedMessenger npc = view_as<InfectedMessenger>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	if(g_infected_messenger_died)
		return Plugin_Continue;
	
	float maxhealth = float(ReturnEntityMaxHealth(npc.index));
	float health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
	float Ratio = health / maxhealth;
	if((maxhealth/2) >= health && !npc.Anger)
		npc.Anger = true;
	if(RoundToCeil(damage) >= health)
	{
		if(!g_infected_messenger_died)
		{
			b_NpcIsInvulnerable[npc.index] = true;
			b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true;
			g_infected_messenger_died=true;
			npc.m_bThisNpcIsABoss = false;
			if(EntRefToEntIndex(RaidBossActive)==npc.index)
				RaidBossActive = INVALID_ENT_REFERENCE;
			g_infected_messenger_die = GetGameTime(npc.index) + 22.0;
			
			SetEntProp(npc.index, Prop_Data, "m_iHealth", 1);
			damage = 0.0;
		}
	}
	else
	{
		if(Ratio <= 0.85 && npc.g_TimesSummoned < 1)
		{
			npc.g_TimesSummoned = 1;
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			npc.PlaySummonSound();
			CPrintToChatAll("{crimson}감염된 전령병{default}: 젠장 기습이다!!!! 이곳에 지원군을 보내라 지금 당장!!!!");
			InfectedMessengerSpawnEnemy(npc.index,"npc_zs_cleaner",50000, RoundToCeil(6.0 * MultiGlobalEnemy));
			InfectedMessengerSpawnEnemy(npc.index,"npc_zs_zombie_soldier",30000, RoundToCeil(2.0 * MultiGlobalEnemy));
			InfectedMessengerSpawnEnemy(npc.index,"npc_zs_mlsm",50000, RoundToCeil(6.0 * MultiGlobalEnemy));
			InfectedMessengerSpawnEnemy(npc.index,"npc_infected_tomislav_main",20000, RoundToCeil(4.0 * MultiGlobalEnemy));
			InfectedMessengerSpawnEnemy(npc.index,"npc_zs_zombie_sniper_jarate",40000, RoundToCeil(2.0 * MultiGlobalEnemy));
		}
		else if(Ratio <= 0.50 && npc.g_TimesSummoned < 2)
		{
			npc.g_TimesSummoned = 2;
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			npc.PlaySummonSound();
			CPrintToChatAll("{crimson}감염된 전령병{default}: 이곳에 당장 암살부대를 보내 지금 당장!!!");
			InfectedMessengerSpawnEnemy(npc.index,"npc_zs_ninja_zombie_spy",65, RoundToCeil(12.0 * MultiGlobalEnemy));
			InfectedMessengerSpawnEnemy(npc.index,"npc_zs_sniper",6000, RoundToCeil(8.0 * MultiGlobalEnemy));
		}
		else if(Ratio <= 0.20 && npc.g_TimesSummoned < 3)
		{
			npc.g_TimesSummoned = 3;
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			npc.PlaySummonSound();
			CPrintToChatAll("{crimson}감염된 전령병{default}: 아직도 놈들이 살아있다!!! 이곳에 당장 공습을 때려!!!!");
			InfectedMessengerSpawnEnemy(npc.index,"npc_zs_manhattan_parrot",30000, RoundToCeil(12.0 * MultiGlobalEnemy));
			InfectedMessengerSpawnEnemy(npc.index,"npc_zs_kamikaze_demo",6000, RoundToCeil(8.0 * MultiGlobalEnemy));
		}
	}
	return Plugin_Changed;
}
static void Spawn_Chaos(InfectedMessenger npc)
{
	float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
	int maxhealth = ReturnEntityMaxHealth(npc.index);
	int heck;
	int spawn_index;
	heck= maxhealth;
	maxhealth= heck;
	CPrintToChatAll("{crimson} 전령병의 강렬한 소원이 끔찍한 것을 소환했습니다..", NpcStats_ReturnNpcName(npc.index, true));

	spawn_index = NPC_CreateByName("npc_zs_stranger", npc.index, pos, ang, GetTeam(npc.index));
	NpcAddedToZombiesLeftCurrently(spawn_index, true);
	if(spawn_index > MaxClients)
	{
		NpcStats_CopyStats(npc.index, spawn_index);
		SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
		SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
	}
	maxhealth= (heck*5);
	spawn_index = NPC_CreateByName("npc_random_zombie", npc.index, pos, ang, GetTeam(npc.index));
	NpcAddedToZombiesLeftCurrently(spawn_index, true);
	if(spawn_index > MaxClients)
	{
		NpcStats_CopyStats(npc.index, spawn_index);
		SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
		SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
	}
	maxhealth= (heck*5);
	spawn_index = NPC_CreateByName("npc_random_zombie", npc.index, pos, ang, GetTeam(npc.index));
	NpcAddedToZombiesLeftCurrently(spawn_index, true);
	if(spawn_index > MaxClients)
	{
		NpcStats_CopyStats(npc.index, spawn_index);
		SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
		SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
	}
}

void InfectedMessengerSpawnEnemy(int infectedmessenger, char[] plugin_name, int health = 0, int count, bool is_a_boss = false)
{
	if(GetTeam(infectedmessenger) == TFTeam_Red)
	{
		count /= 2;
		if(count < 1)
		{
			count = 1;
		}
		for(int Spawns; Spawns <= count; Spawns++)
		{
			float pos[3]; GetEntPropVector(infectedmessenger, Prop_Data, "m_vecAbsOrigin", pos);
			float ang[3]; GetEntPropVector(infectedmessenger, Prop_Data, "m_angRotation", ang);
			
			int summon = NPC_CreateByName(plugin_name, -1, pos, ang, GetTeam(infectedmessenger));
			if(summon > MaxClients)
			{
				fl_Extra_Damage[summon] = 10.0;
				if(!health)
				{
					health = GetEntProp(summon, Prop_Data, "m_iMaxHealth");
				}
				SetEntProp(summon, Prop_Data, "m_iHealth", health / 10);
				SetEntProp(summon, Prop_Data, "m_iMaxHealth", health / 10);
			}
		}
		return;
	}
		
	Enemy enemy;
	enemy.Index = NPC_GetByPlugin(plugin_name);
	if(health != 0)
	{
		enemy.Health = health;
	}
	enemy.Is_Boss = view_as<int>(is_a_boss);
	enemy.Is_Immune_To_Nuke = true;
	//do not bother outlining.
	enemy.ExtraMeleeRes = 1.0;
	enemy.ExtraRangedRes = 1.0;
	enemy.ExtraSpeed = 1.0;
	enemy.ExtraDamage = 1.0;
	enemy.ExtraSize = 1.0;		
	enemy.Team = GetTeam(infectedmessenger);
	
	if(!Waves_InFreeplay())
	{
		for(int i; i<count; i++)
		{
			Waves_AddNextEnemy(enemy);
		}
	}
	else
	{
		int postWaves = CurrentRound[Rounds_Default] - Waves_GetMaxRound();
		char npc_classname[60];
		NPC_GetPluginById(i_NpcInternalId[enemy.Index], npc_classname, sizeof(npc_classname));

		Freeplay_AddEnemy(postWaves, enemy, count, true);
		if(count > 0)
		{
			for(int a; a < count; a++)
			{
				Waves_AddNextEnemy(enemy);
			}
		}
	}

	Zombies_Currently_Still_Ongoing += count;
}
static void ClotDeath(int entity)
{
	InfectedMessenger npc = view_as<InfectedMessenger>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
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
}