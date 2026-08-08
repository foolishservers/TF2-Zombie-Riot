#pragma semicolon 1
#pragma newdecls required

static float f_TalkDelayCheck;
static int i_TalkDelayCheck;

static int b_DoNotHideName[MAXPLAYERS + 1];

void Talker_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Back");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_talker");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = true;
	data.Flags = -1;
	data.Category = Type_Hidden; 
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Talker(vecPos, vecAng, team, data);
}
methodmap Talker < CClotBody
{
	property int m_iTalkWaveAt
	{
		public get()							{ return i_BleedType[this.index]; }
		public set(int TempValueForProperty) 	{ i_BleedType[this.index] = TempValueForProperty; }
	}
	property int m_iRandomTalkNumber
	{
		public get()							{ return i_StepNoiseType[this.index]; }
		public set(int TempValueForProperty) 	{ i_StepNoiseType[this.index] = TempValueForProperty; }
	}
	public Talker(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Talker npc = view_as<Talker>(CClotBody(vecPos, vecAng, "models/buildables/teleporter.mdl", "1.0", "100000000", ally, .NpcTypeLogic = 1));

		i_NpcWeight[npc.index] = 999;

		b_StaticNPC[npc.index] = true;
		AddNpcToAliveList(npc.index, 1);
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iOverlordComboAttack = 0;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		npc.m_bDissapearOnDeath = true;
		f_ExtraOffsetNpcHudAbove[npc.index] = 500.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flAbilityOrAttack0 = GetGameTime(npc.index) + 2.0;
		GiveNpcOutLineLastOrBoss(npc.index, false);
		b_thisNpcHasAnOutline[npc.index] = true;
		i_TalkDelayCheck = 0;
		f_TalkDelayCheck = 0.0;
		npc.m_bCamo = true;
		b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.
		b_NpcIsInvulnerable[npc.index] = true;
		b_ThisEntityIgnored[npc.index] = true;

		SetEntityRenderMode(npc.index, RENDER_NONE);
		
		// Figure out who has beaten the waveset
		Talker_GatherWavesetCompletion();
		
		// Set his non-translatable name here
		b_NameNoTranslation[npc.index] = false;
		c_NpcName[npc.index] = "???";

		npc.m_iTalkWaveAt = 0;
		int WaveAmAt;
		WaveAmAt = StringToInt(data);
		if (WaveAmAt == 1)
		{
			i_ApertureBossesDead = APERTURE_BOSS_NONE;
			
			for (int client = 1; client <= MaxClients; client++)
			{
				if (!IsClientInGame(client) || IsFakeClient(client) || !b_DoNotHideName[client])
					continue;
				
				CPrintToChat(client, "%T", "Vincent_Talk_Expidonsan_Research_Card", client);
			}
		}
		npc.m_iTalkWaveAt = WaveAmAt;
		
		npc.m_iRandomTalkNumber = -1;

		func_NPCThink[npc.index] = view_as<Function>(Talker_ClotThink);
		
		return npc;
	}
}

static void VincentTalker_NPCTalkMessage(int entity, const char[] message, bool translated = false, any ...)
{
	char buffer[256];
	VFormat(buffer, sizeof(buffer), message, 4);
	
	for (int client = 1; client <= MaxClients; client++)
	{
		if (!IsClientInGame(client) || IsFakeClient(client))
			continue;
		
		char prefix[255];
		StatusEffects_PrefixName(entity, client, prefix, sizeof(prefix));
		
		if (translated)
		{
			// Name the NPC based on whether the client owns the Expidonsan Research Card
			if (b_DoNotHideName[client])
				CPrintToChat(client, "{rare}%s%t{default}: %t", prefix, "Vincent", buffer);
			else
				CPrintToChat(client, "{rare}%s%s{default}: %t", prefix, c_NpcName[entity], buffer);
		}
		else
		{
			// Name the NPC based on whether the client owns the Expidonsan Research Card
			if (b_DoNotHideName[client])
				CPrintToChat(client, "{rare}%s%t{default}: %s", prefix, "Vincent", message);
			else
				CPrintToChat(client, "{rare}%s%s{default}: %s", prefix, c_NpcName[entity], message);
		}
	}
}

public void Talker_ClotThink(int iNPC)
{
	Talker npc = view_as<Talker>(iNPC);
	//10 failsafe
	if(i_TalkDelayCheck == -1 || i_TalkDelayCheck >= 10)
	{
		SmiteNpcToDeath(npc.index);
		return;
	}
	if(f_TalkDelayCheck > GetGameTime())
		return;

	f_TalkDelayCheck = GetGameTime() + 4.0;

	switch(npc.m_iTalkWaveAt)
	{
		//data is "1"
		case 1:
		{
			NpcTalker_Wave1Talk(npc);
		}
		case 2:
		{
			NpcTalker_Wave5Talk(npc);
		}
		case 3:
		{
			NpcTalker_Wave10Talk(npc);
		}
		case 4:
		{
			NpcTalker_Wave11Talk(npc);
		}
		case 5:
		{
			NpcTalker_Wave15Talk(npc);
		}
		case 6:
		{
			NpcTalker_Wave20Talk(npc);
		}
		case 7:
		{
			NpcTalker_Wave21Talk(npc);
		}
		case 8:
		{
			NpcTalker_Wave25Talk(npc);
		}
		case 9:
		{
			NpcTalker_Wave30Talk(npc);
		}
		case 10:
		{
			NpcTalker_Wave31Talk(npc);
		}
		case 11:
		{
			NpcTalker_Wave36Talk(npc);
		}
		case 12:
		{
			NpcTalker_Wave37Talk(npc);
		}
		case 13:
		{
			NpcTalker_Wave38Talk(npc);
		}
		
	}
	if(i_TalkDelayCheck != -1)
	{
		i_TalkDelayCheck++;
	}
}

stock void NpcTalker_Wave1Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(1, 3);
		/*
		Example if aris death does smth:
		if(Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3,4);
		}

		*/
	}
	
	int talk = npc.m_iRandomTalkNumber;
	if (0 < talk && talk < 4)
	{
		VincentTalker_NPCTalkMessage(npc.index, "Vincent_Talk_Wave1_%d_%d", true, talk, i_TalkDelayCheck);
		if (i_TalkDelayCheck == 6)
			i_TalkDelayCheck = -1;
	}
}



stock void NpcTalker_Wave5Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(1, 3);
		/*
		Example if aris death does smth:
		if(Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3,4);
		}

		*/
	}
	
	int talk = npc.m_iRandomTalkNumber;
	if (0 < talk && talk < 4)
	{
		VincentTalker_NPCTalkMessage(npc.index, "Vincent_Talk_Wave5_%d_%d", true, talk, i_TalkDelayCheck);
		if (i_TalkDelayCheck == 6)
			i_TalkDelayCheck = -1;
	}
}



stock void NpcTalker_Wave10Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(1, 3);
		/*
		Example if aris death does smth:
		if(Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3,4);
		}

		*/
	}
	
	int talk = npc.m_iRandomTalkNumber;
	if (0 < talk && talk < 4)
	{
		VincentTalker_NPCTalkMessage(npc.index, "Vincent_Talk_Wave10_%d_%d", true, talk, i_TalkDelayCheck);
		if (i_TalkDelayCheck == 6)
			i_TalkDelayCheck = -1;
	}
}



stock void NpcTalker_Wave11Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(1, 3);

		if(Aperture_IsBossDead(APERTURE_BOSS_CAT))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(4, 6);
		}
	}
	
	switch(npc.m_iRandomTalkNumber)
	{
		// C.A.T Alive
		case 1, 2, 3:
		{
			VincentTalker_NPCTalkMessage(npc.index, "Vincent_Talk_Wave11_%d_%d", true, npc.m_iRandomTalkNumber, i_TalkDelayCheck);
			if (i_TalkDelayCheck == 6)
				i_TalkDelayCheck = -1;
		}
		// C.A.T. Dead
		case 4:
		{
			VincentTalker_NPCTalkMessage(npc.index, "Vincent_Talk_Wave11_4_%d", true, i_TalkDelayCheck);
			if (i_TalkDelayCheck == 5)
				i_TalkDelayCheck = -1;
		}
		case 5, 6:
		{
			VincentTalker_NPCTalkMessage(npc.index, "Vincent_Talk_Wave11_%d_%d", true, npc.m_iRandomTalkNumber, i_TalkDelayCheck);
			if (i_TalkDelayCheck == 6)
				i_TalkDelayCheck = -1;
		}
	}
}



stock void NpcTalker_Wave15Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(1, 3);

		if(Aperture_IsBossDead(APERTURE_BOSS_CAT))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(4, 6);
		}
	}
	
	int talk = npc.m_iRandomTalkNumber;
	switch(talk)
	{
		case 1, 2, 3:
		{
			VincentTalker_NPCTalkMessage(npc.index, "Vincent_Talk_Wave15_%d_%d", true, talk, i_TalkDelayCheck);
			if (i_TalkDelayCheck == 3)
				i_TalkDelayCheck = -1;
		}
		//C.A.T. Dead
		case 4, 5, 6:
		{
			VincentTalker_NPCTalkMessage(npc.index, "Vincent_Talk_Wave15_%d_%d", true, talk, i_TalkDelayCheck);
			if (i_TalkDelayCheck == 3)
				i_TalkDelayCheck = -1;
		}
	}
}



stock void NpcTalker_Wave20Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(1, 3);

		if(Aperture_IsBossDead(APERTURE_BOSS_CAT))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(4, 6);
		}
	}
	
	int talk = npc.m_iRandomTalkNumber;
	switch(talk)
	{
		case 1, 2, 3:
		{
			VincentTalker_NPCTalkMessage(npc.index, "Vincent_Talk_Wave20_%d_%d", true, talk, i_TalkDelayCheck);
			if (i_TalkDelayCheck == 4)
				i_TalkDelayCheck = -1;
		}
		//C.A.T. Dead
		case 4, 5, 6:
		{
			VincentTalker_NPCTalkMessage(npc.index, "Vincent_Talk_Wave20_%d_%d", true, talk, i_TalkDelayCheck);
			if (i_TalkDelayCheck == 4)
				i_TalkDelayCheck = -1;
		}
	}
}



stock void NpcTalker_Wave21Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(1, 3);

		//C.A.T. Dead, A.R.I.S Alive
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && !Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(4, 5);
		}
		//C.A.T. Alive, A.R.I.S Dead
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(6, 7);
		}
		//C.A.T. Dead, A.R.I.S Dead
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = 8;
		}
	}
	
	int talk = npc.m_iRandomTalkNumber;
	switch(talk)
	{
		//Canon Route
		case 1, 2, 3:
		{
			VincentTalker_NPCTalkMessage(npc.index, "Vincent_Talk_Wave21_%d_%d", true, talk, i_TalkDelayCheck);
			if (i_TalkDelayCheck == 4)
				i_TalkDelayCheck = -1;
		}
		//C.A.T. Dead, A.R.I.S Alive
		case 4, 5:
		{
			VincentTalker_NPCTalkMessage(npc.index, "Vincent_Talk_Wave21_%d_%d", true, talk, i_TalkDelayCheck);
			if (i_TalkDelayCheck == 4)
				i_TalkDelayCheck = -1;
		}
		//C.A.T. Alive, A.R.I.S Dead
		case 6, 7:
		{
			VincentTalker_NPCTalkMessage(npc.index, "Vincent_Talk_Wave21_%d_%d", true, talk, i_TalkDelayCheck);
			if (i_TalkDelayCheck == 4)
				i_TalkDelayCheck = -1;
		}
		//Locked in Genocide
		case 8:
		{
			switch(i_TalkDelayCheck)
			{
				case 1, 2, 3:
				{
					VincentTalker_NPCTalkMessage(npc.index, "Vincent_Talk_Wave21_8_%d", true, i_TalkDelayCheck);
				}
				case 4:
				{
					CPrintToChatAll("%t", "Vincent_Talk_Wave21_Genocide_Route");
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}



stock void NpcTalker_Wave25Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(1, 2);

		//C.A.T. Dead, A.R.I.S Alive
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && !Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = 3;
		}
		//C.A.T. Alive, A.R.I.S Dead
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = 5;
		}
		//C.A.T. Dead, A.R.I.S Dead
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = 7;
		}
	}
	
	int talk = npc.m_iRandomTalkNumber;
	switch(talk)
	{
		//Canon Route
		case 1, 2:
		{
			VincentTalker_NPCTalkMessage(npc.index, "Vincent_Talk_Wave25_%d_%d", true, talk, i_TalkDelayCheck);
			if (i_TalkDelayCheck == 4)
				i_TalkDelayCheck = -1;
		}
		//C.A.T. Dead, A.R.I.S Alive
		case 3:
		{
			VincentTalker_NPCTalkMessage(npc.index, "Vincent_Talk_Wave25_%d_%d", true, talk, i_TalkDelayCheck);
			if (i_TalkDelayCheck == 4)
				i_TalkDelayCheck = -1;
		}
		//C.A.T. Alive, A.R.I.S Dead
		case 5:
		{
			VincentTalker_NPCTalkMessage(npc.index, "Vincent_Talk_Wave25_%d_%d", true, talk, i_TalkDelayCheck);
			if (i_TalkDelayCheck == 4)
				i_TalkDelayCheck = -1;
		}
		//Locked in Genocide
		case 7:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}



stock void NpcTalker_Wave30Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(1, 2);

		//C.A.T. Dead, A.R.I.S Alive
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && !Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = 3;
		}
		//C.A.T. Alive, A.R.I.S Dead
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = 5;
		}
		//C.A.T. Dead, A.R.I.S Dead
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = 7;
		}
	}
	
	int talk = npc.m_iRandomTalkNumber;
	switch(talk)
	{
		//Canon Route
		case 1, 2:
		{
			VincentTalker_NPCTalkMessage(npc.index, "Vincent_Talk_Wave30_%d_%d", true, talk, i_TalkDelayCheck);
			if (i_TalkDelayCheck == 4)
				i_TalkDelayCheck = -1;
		}
		//C.A.T. Dead, A.R.I.S Alive
		case 3:
		{
			VincentTalker_NPCTalkMessage(npc.index, "Vincent_Talk_Wave30_%d_%d", true, talk, i_TalkDelayCheck);
			if (i_TalkDelayCheck == 3)
				i_TalkDelayCheck = -1;
		}
		//C.A.T. Alive, A.R.I.S Dead
		case 5:
		{
			VincentTalker_NPCTalkMessage(npc.index, "Vincent_Talk_Wave30_%d_%d", true, talk, i_TalkDelayCheck);
			if (i_TalkDelayCheck == 3)
				i_TalkDelayCheck = -1;
		}
		//Locked in Genocide
		case 7:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}


stock void NpcTalker_Wave31Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//C.A.T. Alive, A.R.I.S Alive, C.H.I.M.E.R.A. Alive
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && !Aperture_IsBossDead(APERTURE_BOSS_ARIS) && !Aperture_IsBossDead(APERTURE_BOSS_CHIMERA))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(1, 2);
		}
		//C.A.T. Alive, A.R.I.S Alive, C.H.I.M.E.R.A. Dead
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && !Aperture_IsBossDead(APERTURE_BOSS_ARIS) && Aperture_IsBossDead(APERTURE_BOSS_CHIMERA))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(3, 4);
		}
		//C.A.T. Dead, A.R.I.S Alive
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && !Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = 5;
		}
		//C.A.T. Alive, A.R.I.S Dead
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = 5;
		}
		//C.A.T. Dead, A.R.I.S Dead
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = GetRandomInt(7,7);
		}
	}
	
	int talk = npc.m_iRandomTalkNumber;
	switch(talk)
	{
		//C.A.T. Alive, A.R.I.S Alive, C.H.I.M.E.R.A. Alive
		case 1, 2:
		{
			VincentTalker_NPCTalkMessage(npc.index, "Vincent_Talk_Wave31_%d_%d", true, talk, i_TalkDelayCheck);
			if (i_TalkDelayCheck == 3)
				i_TalkDelayCheck = -1;
		}
		//C.A.T. Alive, A.R.I.S Alive, C.H.I.M.E.R.A. Dead
		case 3, 4:
		{
			VincentTalker_NPCTalkMessage(npc.index, "Vincent_Talk_Wave31_%d_%d", true, talk, i_TalkDelayCheck);
			if (i_TalkDelayCheck == 3)
				i_TalkDelayCheck = -1;
		}
		//One of them Dead
		case 5:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
		//Locked in Genocide
		case 7:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}

stock void NpcTalker_Wave36Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(1, 2);
		
		//C.A.T. Dead, A.R.I.S Alive
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && !Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = 3;
		}
		//C.A.T. Alive, A.R.I.S Dead
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = 5;
		}
		//C.A.T. Dead, A.R.I.S Dead
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = 7;
		}
	}
	
	switch(npc.m_iRandomTalkNumber)
	{
		//Canon Route
		case 1, 2:
		{
			VincentTalker_NPCTalkMessage(npc.index, "Vincent_Talk_Wave36_%d_%d", true, npc.m_iRandomTalkNumber, i_TalkDelayCheck);
			if (i_TalkDelayCheck == 9)
				i_TalkDelayCheck = -1;
		}
		//One of them(C.A.T or A.R.I.S) Dead
		case 3, 5:
		{
			VincentTalker_NPCTalkMessage(npc.index, "Vincent_Talk_Wave36_3_%d", true, i_TalkDelayCheck);
			if (i_TalkDelayCheck == 2)
				i_TalkDelayCheck = -1;
		}
		//Locked in Genocide
		case 7:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}


stock void NpcTalker_Wave37Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = GetRandomInt(1, 2);

		//C.A.T. Dead, A.R.I.S Alive
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && !Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = 3;
		}
		//C.A.T. Alive, A.R.I.S Dead
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = 5;
		}
		//C.A.T. Dead, A.R.I.S Dead
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = 7;
		}
	}
	switch(npc.m_iRandomTalkNumber)
	{
		//Canon Route
		case 1, 2:
		{
			VincentTalker_NPCTalkMessage(npc.index, "Vincent_Talk_Wave37_%d_%d", true, npc.m_iRandomTalkNumber, i_TalkDelayCheck);
			if (i_TalkDelayCheck == 2)
				i_TalkDelayCheck = -1;
		}
		//C.A.T. Dead, A.R.I.S Alive
		case 3:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
		//C.A.T. Alive, A.R.I.S Dead
		case 5:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
		//Locked in Genocide
		case 7:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}



stock void NpcTalker_Wave38Talk(Talker npc)
{
	if(npc.m_iRandomTalkNumber == -1)
	{
		//no random asigned yet. get one.
		npc.m_iRandomTalkNumber = 1;

		//C.A.T. Dead, A.R.I.S Alive
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && !Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = 3;
		}
		//C.A.T. Alive, A.R.I.S Dead
		if(!Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = 5;
		}
		//C.A.T. Dead, A.R.I.S Dead
		if(Aperture_IsBossDead(APERTURE_BOSS_CAT) && Aperture_IsBossDead(APERTURE_BOSS_ARIS))
		{
			npc.m_iRandomTalkNumber = 7;
		}

	}
	switch(npc.m_iRandomTalkNumber)
	{
		//Canon Route
		case 1:
		{
			VincentTalker_NPCTalkMessage(npc.index, "Vincent_Talk_Wave38_1_%d", true, npc.m_iRandomTalkNumber, i_TalkDelayCheck);
			if (i_TalkDelayCheck == 2)
				i_TalkDelayCheck = -1;
		}
		//C.A.T. Dead, A.R.I.S Alive
		case 3:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
		//C.A.T. Alive, A.R.I.S Dead
		case 5:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
		//Locked in Genocide
		case 7:
		{
			switch(i_TalkDelayCheck)
			{
				case 1:
				{
					i_TalkDelayCheck = -1;
				}
			}
		}
	}
}

static void Talker_GatherWavesetCompletion()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (!IsClientInGame(client) || IsFakeClient(client) || AprilFoolsIconOverride() == 1)
		{
			// Also specifically get past this if the steam happy modifier is on
			b_DoNotHideName[client] = false;
			continue;
		}
		
		b_DoNotHideName[client] = Items_HasNamedItem(client, "Expidonsan Research Card");
	}
}