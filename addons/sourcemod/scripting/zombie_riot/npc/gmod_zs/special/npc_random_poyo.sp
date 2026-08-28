#pragma semicolon 1
#pragma newdecls required

public void PoyoSummonRandom_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Random Boss");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_random_poyo");
	strcopy(data.Icon, sizeof(data.Icon), "void_gate");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Hidden;
	data.Precache = ClotPrecache_Boss;
	data.Func = ClotSummon_Boss;
	NPC_Add(data);

	strcopy(data.Name, sizeof(data.Name), "Random Boss");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_random_zombie");
	strcopy(data.Icon, sizeof(data.Icon), "void_gate");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Hidden; 
	data.Precache = ClotPrecache_AltBoss;
	data.Func = ClotSummon_AltBoss;
	NPC_Add(data);
}

static void ClotPrecache_Boss()
{
	//precaches said npcs.
	NPC_GetByPlugin("npc_zs_poisonzombie_fortified_giant");
	NPC_GetByPlugin("npc_zs_the_shit_slapper");
	NPC_GetByPlugin("npc_zs_bastardzine");
	NPC_GetByPlugin("npc_zs_butcher");
	NPC_GetByPlugin("npc_zs_amplification");
	NPC_GetByPlugin("npc_zs_howler");
	NPC_GetByPlugin("npc_zs_zombine");
	NPC_GetByPlugin("npc_zs_bonemesh");
	NPC_GetByPlugin("npc_zs_soldier_giant_grave");
}

static void ClotPrecache_AltBoss()
{
	//precaches said npcs.
	NPC_GetByPlugin("npc_zs_poisonzombie_fortified_giant");
	NPC_GetByPlugin("npc_zs_the_shit_slapper");
	NPC_GetByPlugin("npc_zs_bastardzine");
	NPC_GetByPlugin("npc_zs_butcher");
	NPC_GetByPlugin("npc_zs_amplification");
	NPC_GetByPlugin("npc_zs_howler");
	NPC_GetByPlugin("npc_zs_zombine");
	NPC_GetByPlugin("npc_zs_bonemesh");
	NPC_GetByPlugin("npc_zs_red_marrow");
}

static bool SamePoyoDisallow[11];

static any ClotSummon_Boss(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return PoyoSummonRandom(vecPos, vecAng, team, data, false);
}
static any ClotSummon_AltBoss(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return PoyoSummonRandom(vecPos, vecAng, team, data, true)
}

methodmap PoyoSummonRandom < CClotBody
{
	public PoyoSummonRandom(float vecPos[3], float vecAng[3], int ally, const char[] data, bool Alt)
	{
		PoyoSummonRandom npc = view_as<PoyoSummonRandom>(CClotBody(vecPos, vecAng, "models/empty.mdl", "0.8", "700", ally));
		
		i_NpcWeight[npc.index] = 1;

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = 0;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		npc.m_bDissapearOnDeath = true;
		npc.m_bFUCKYOU = Alt;
		
		func_NPCDeath[npc.index] = view_as<Function>(PoyoSummonRandom_NPCDeath);
		func_NPCThink[npc.index] = view_as<Function>(PoyoSummonRandom_ClotThink);

		i_RaidGrantExtra[npc.index] = StringToInt(data);
		if(i_RaidGrantExtra[npc.index] <= 40)
			Zero(SamePoyoDisallow);

		if(TeleportDiversioToRandLocation(npc.index,true,1500.0, 700.0) == 2)
			TeleportDiversioToRandLocation(npc.index, true);
		
		return npc;
	}
}

static void PoyoSummonRandom_ClotThink(int iNPC)
{
	SmiteNpcToDeath(iNPC);
}

static void PoyoSummonRandom_NPCDeath(int entity)
{
	PoyoSummonRandom npc = view_as<PoyoSummonRandom>(entity);
	//Spawns a random raid.
	if(npc.m_bFUCKYOU)
		ZombieSummonRaidboss(entity);
	else
		PoyoSummonRaidboss(entity);
}

static void PoyoSummonRaidboss(int ZombieSummonbase)
{
	Enemy enemy;
	enemy.Health = ReturnEntityMaxHealth(ZombieSummonbase);
	enemy.Is_Boss = view_as<int>(b_thisNpcIsABoss[ZombieSummonbase]);
	enemy.Is_Immune_To_Nuke = true;
	enemy.ExtraMeleeRes = fl_Extra_MeleeArmor[ZombieSummonbase];
	enemy.ExtraRangedRes = fl_Extra_RangedArmor[ZombieSummonbase];
	enemy.ExtraSpeed = fl_Extra_Speed[ZombieSummonbase];
	enemy.ExtraDamage = fl_Extra_Damage[ZombieSummonbase];
	enemy.ExtraSize = 1.0;		
	enemy.Team = GetTeam(ZombieSummonbase);
	enemy.Does_Not_Scale = 1; //scaling was already done.
	//18 is max bosses?
	char PluginName[255];
	char CharData[255];
	
	Format(CharData, sizeof(CharData), "sc%i;",i_RaidGrantExtra[ZombieSummonbase]);
	int NumberRand;
	SamePoyoDisallow[0] = true;
	while(SamePoyoDisallow[NumberRand])
	{
		NumberRand = GetRandomInt(1,10);
	}
	SamePoyoDisallow[NumberRand] = true;
	switch(NumberRand)
	{
		case 1:
		{
			PluginName = "npc_zs_poisonzombie_fortified_giant";	
			enemy.Is_Boss = 1;
		}
		case 2:
		{
			PluginName = "npc_zs_the_shit_slapper";
			enemy.Is_Boss = 1;
		}
		case 3:
		{
			PluginName = "npc_zs_bastardzine";
			enemy.Is_Boss = 1;
		}
		case 4:
		{
			PluginName = "npc_zs_butcher";
			enemy.Is_Boss = 1;
		}
		case 5:
		{
			PluginName = "npc_zs_amplification";
			enemy.Is_Boss = 1;
		}
		case 6:
		{
			PluginName = "npc_zs_howler";
			enemy.Is_Boss = 1;
		}
		case 7:
		{
			PluginName = "npc_zs_zombine";
			enemy.Is_Boss = 1;
		}
		case 8:
		{
			PluginName = "npc_zs_bonemesh";
			enemy.Is_Boss = 1;
		}
		case 9:
		{
			PluginName = "npc_zs_soldier_giant_grave";
			enemy.Is_Boss = 1;
		}
		case 10:
		{
			PluginName = "npc_zs_red_marrow";
			enemy.Is_Boss = 1;
		}
	}
	Format(enemy.Data, sizeof(enemy.Data), "%s",CharData);
	enemy.Index = NPC_GetByPlugin(PluginName);
	Waves_AddNextEnemy(enemy);
	Zombies_Currently_Still_Ongoing += 1;
}

static void ZombieSummonRaidboss(int ZombieSummonbase)
{
	Enemy enemy;
	enemy.Health = ReturnEntityMaxHealth(ZombieSummonbase);
	enemy.Is_Boss = view_as<int>(b_thisNpcIsABoss[ZombieSummonbase]);
	enemy.Is_Immune_To_Nuke = true;
	enemy.ExtraMeleeRes = fl_Extra_MeleeArmor[ZombieSummonbase];
	enemy.ExtraRangedRes = fl_Extra_RangedArmor[ZombieSummonbase];
	enemy.ExtraSpeed = fl_Extra_Speed[ZombieSummonbase];
	enemy.ExtraDamage = fl_Extra_Damage[ZombieSummonbase];
	enemy.ExtraSize = 1.0;		
	enemy.Team = GetTeam(ZombieSummonbase);
	enemy.Does_Not_Scale = 1; //scaling was already done.
	//18 is max bosses?
	char PluginName[255];
	char CharData[255];
	
	Format(CharData, sizeof(CharData), "sc%i;",i_RaidGrantExtra[ZombieSummonbase]);
	int NumberRand;
	SameZombieDisallow[0] = true;
	while(SameZombieDisallow[NumberRand])
	{
		NumberRand = GetRandomInt(1,10);
	}
	SameZombieDisallow[NumberRand] = true;
	switch(NumberRand)
	{
		case 1:
		{
			PluginName = "npc_zs_poisonzombie_fortified_giant";	
			enemy.Is_Boss = 1;
		}
		case 2:
		{
			PluginName = "npc_zs_the_shit_slapper";
			enemy.Is_Boss = 1;
		}
		case 3:
		{
			PluginName = "npc_zs_bastardzine";
			enemy.Is_Boss = 1;
		}
		case 4:
		{
			PluginName = "npc_zs_butcher";
			enemy.Is_Boss = 1;
		}
		case 5:
		{
			PluginName = "npc_zs_amplification";
			enemy.Is_Boss = 1;
		}
		case 6:
		{
			PluginName = "npc_zs_howler";
			enemy.Is_Boss = 1;
		}
		case 7:
		{
			PluginName = "npc_zs_zombine";
			enemy.Is_Boss = 1;
		}
		case 8:
		{
			PluginName = "npc_zs_bonemesh";
			enemy.Is_Boss = 1;
		}
		case 9:
		{
			PluginName = "npc_zs_red_marrow";
			enemy.Is_Boss = 1;
		}
	}
	Format(enemy.Data, sizeof(enemy.Data), "%s",CharData);
	enemy.Index = NPC_GetByPlugin(PluginName);
	Waves_AddNextEnemy(enemy);
	Zombies_Currently_Still_Ongoing += 1;
}