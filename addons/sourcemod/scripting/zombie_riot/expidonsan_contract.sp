#pragma semicolon 1
#pragma newdecls required

static char g_ExplosionSounds[]= "weapons/explode1.wav";

static bool CCMode;
static bool CC_ConstraintsBlock;
static bool CC_EnemyDMGBuff_A;
static bool CC_EnemyDMGBuff_B;
static bool CC_EnemyDMGBuff_C;
static bool CC_EnemyResistBuff_A;
static bool CC_EnemyResistBuff_B;
static bool CC_EnemyMoveBuff_A;
static bool CC_EnemyMoveBuff_B;
static bool CC_EnemyExplodBuff;
static bool CC_EnemyShieldBuff_A;
static bool CC_EnemyShieldBuff_B;
static bool CC_AlliesSupplyIssuesDebuff_A;
static bool CC_AlliesSupplyIssuesDebuff_B;

void CC_Contract_OnMapStart()
{
	/*PrecacheSound("ui/vote_success.wav", true);
	PrecacheSound("passtime/ball_dropped.wav", true);
	PrecacheSound("ui/mm_medal_silver.wav", true);
	PrecacheSound("ambient/halloween/thunder_01.wav", true);
	PrecacheSound("misc/halloween/spelltick_set.wav", true);
	PrecacheSound("misc/halloween/hwn_bomb_flash.wav", true);
	PrecacheSound("music/mvm_class_select.wav", true);*/
	PrecacheSound(g_ExplosionSounds);
}

bool Waves_InCCMode()
{
	return CCMode;
}

void CC_Contract_SetUp()
{
	CCMode=true;
	CC_ConstraintsBlock=false;
	CPrintToChatAll("Contract activated.\nTap to check out Setting Constraints!");
	CPrintToChatAll("Caution! Wave starts, you cannot set constraints!");
	CreateTimer(1.0, CC_Contract_Timer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

void CC_Contract_ResetAll()
{
	CCMode=false;
	CC_ConstraintsBlock=false;
	CC_EnemyDMGBuff_A=false;
	CC_EnemyDMGBuff_B=false;
	CC_EnemyDMGBuff_C=false;
	CC_EnemyResistBuff_A=false;
	CC_EnemyResistBuff_B=false;
	CC_EnemyMoveBuff_A=false;
	CC_EnemyMoveBuff_B=false;
	CC_EnemyExplodBuff=false;
	CC_EnemyShieldBuff_A=false;
	CC_EnemyShieldBuff_B=false;
	CC_AlliesSupplyIssuesDebuff_A=false;
	CC_AlliesSupplyIssuesDebuff_B=false;
}

int CC_Contract_ScorePoint()
{
	int ScorePoint=0;
	if(CC_EnemyDMGBuff_A)ScorePoint+=1;
	if(CC_EnemyDMGBuff_B)ScorePoint+=2;
	if(CC_EnemyDMGBuff_C)ScorePoint+=3;
	if(CC_EnemyResistBuff_A)ScorePoint+=1;
	if(CC_EnemyResistBuff_B)ScorePoint+=2;
	if(CC_EnemyMoveBuff_A)ScorePoint+=1;
	if(CC_EnemyMoveBuff_B)ScorePoint+=2;
	if(CC_EnemyExplodBuff)ScorePoint+=1;
	if(CC_EnemyShieldBuff_A)ScorePoint+=1;
	if(CC_EnemyShieldBuff_B)ScorePoint+=2;
	return ScorePoint;
}

public Action CommandCC_Contract_Mod(int client, int args)
{
	CCMode=!CCMode;
	if(CCMode)
	{
		PrintToConsole(client, "CC ON");
		CC_Contract_SetUp();
	}
	else
	{
		PrintToConsole(client, "CC OFF");
		CC_Contract_ResetAll();
	}
	return Plugin_Handled;
}

public Action CommandCC_Constraints_Block(int client, int args)
{
	CC_ConstraintsBlock=!CC_ConstraintsBlock;
	if(CC_ConstraintsBlock)
		PrintToConsole(client, "ConstraintsBlock ON");
	else
		PrintToConsole(client, "ConstraintsBlock OFF");
	return Plugin_Handled;
}

void CC_ContractMenu(int client, int page)
{
	Menu menu = new Menu(CC_ContractMenuH);
	
	SetGlobalTransTarget(client);
	
	menu.SetTitle("CC 0: Operation ...\n \nConstraints\nScore: %i\n ", CC_Contract_ScorePoint());

	char buffer[64];
	if(!CC_ConstraintsBlock)
	{
		/*for(index=0; index<=10; index++)
		{
			FormatEx(buffer2, sizeof(buffer2), "Constraints_%i", index);
			FormatEx(buffer, sizeof(buffer), "%t", buffer2);
			IntToString(index, buffer2, sizeof(buffer2));
			menu.AddItem(buffer2, buffer); 
		}
		FormatEx(buffer2, sizeof(buffer2), "Constraints_0");
		FormatEx(buffer, sizeof(buffer), "%t", buffer2);
		menu.AddItem(buffer2, buffer);*/
		if(CC_EnemyDMGBuff_A)
			FormatEx(buffer, sizeof(buffer), "%t:1 [Activated]", "Constraints_0");
		else if(CC_EnemyDMGBuff_B)
			FormatEx(buffer, sizeof(buffer), "%t:1 [%t]", "Constraints_0", "Constraints_1");
		else if(CC_EnemyDMGBuff_C)
			FormatEx(buffer, sizeof(buffer), "%t:1 [%t]", "Constraints_0", "Constraints_2");
		else
			FormatEx(buffer, sizeof(buffer), "%t:1", "Constraints_0");
		menu.AddItem("0", buffer);

		if(CC_EnemyDMGBuff_B)
			FormatEx(buffer, sizeof(buffer), "%t:2 [Activated]", "Constraints_1");
		else if(CC_EnemyDMGBuff_A)
			FormatEx(buffer, sizeof(buffer), "%t:2 [%t]", "Constraints_1", "Constraints_0");
		else if(CC_EnemyDMGBuff_C)
			FormatEx(buffer, sizeof(buffer), "%t:2 [%t]", "Constraints_1", "Constraints_2");
		else
			FormatEx(buffer, sizeof(buffer), "%t:2", "Constraints_1");
		menu.AddItem("1", buffer);

		if(CC_EnemyDMGBuff_C)
			FormatEx(buffer, sizeof(buffer), "%t:3 [Activated]", "Constraints_2");
		else if(CC_EnemyDMGBuff_A)
			FormatEx(buffer, sizeof(buffer), "%t:3 [%t]", "Constraints_2", "Constraints_0");
		else if(CC_EnemyDMGBuff_B)
			FormatEx(buffer, sizeof(buffer), "%t:3 [%t]", "Constraints_2", "Constraints_1");
		else
			FormatEx(buffer, sizeof(buffer), "%t:3", "Constraints_2");
		menu.AddItem("2", buffer);

		if(CC_EnemyResistBuff_A)
			FormatEx(buffer, sizeof(buffer), "%t:1 [Activated]", "Constraints_3");
		else if(CC_EnemyResistBuff_B)
			FormatEx(buffer, sizeof(buffer), "%t:1 [%t]", "Constraints_3", "Constraints_4");
		else
			FormatEx(buffer, sizeof(buffer), "%t:1", "Constraints_3");
		menu.AddItem("3", buffer);

		if(CC_EnemyResistBuff_B)
			FormatEx(buffer, sizeof(buffer), "%t:2 [Activated]", "Constraints_4");
		else if(CC_EnemyResistBuff_A)
			FormatEx(buffer, sizeof(buffer), "%t:2 [%t]", "Constraints_4", "Constraints_3");
		else
			FormatEx(buffer, sizeof(buffer), "%t:2", "Constraints_4");
		menu.AddItem("4", buffer);

		if(CC_EnemyMoveBuff_A)
			FormatEx(buffer, sizeof(buffer), "%t:1 [Activated]", "Constraints_5");
		else if(CC_EnemyMoveBuff_B)
			FormatEx(buffer, sizeof(buffer), "%t:1 [%t]", "Constraints_5", "Constraints_6");
		else
			FormatEx(buffer, sizeof(buffer), "%t:1", "Constraints_5");
		menu.AddItem("5", buffer);

		if(CC_EnemyMoveBuff_B)
			FormatEx(buffer, sizeof(buffer), "%t:2 [Activated]", "Constraints_6");
		else if(CC_EnemyMoveBuff_A)
			FormatEx(buffer, sizeof(buffer), "%t:2 [%t]", "Constraints_6", "Constraints_5");
		else
			FormatEx(buffer, sizeof(buffer), "%t:2", "Constraints_6");
		menu.AddItem("6", buffer);

		if(CC_EnemyExplodBuff)
			FormatEx(buffer, sizeof(buffer), "%t:1 [Activated]", "Constraints_7");
		else
			FormatEx(buffer, sizeof(buffer), "%t:1", "Constraints_7");
		menu.AddItem("7", buffer);
		
		if(CC_EnemyShieldBuff_A)
			FormatEx(buffer, sizeof(buffer), "%t:2 [Activated]", "Constraints_8");
		else if(CC_EnemyShieldBuff_B)
			FormatEx(buffer, sizeof(buffer), "%t:2 [%t]", "Constraints_8", "Constraints_9");
		else
			FormatEx(buffer, sizeof(buffer), "%t:2", "Constraints_8");
		menu.AddItem("8", buffer);
		
		if(CC_EnemyShieldBuff_B)
			FormatEx(buffer, sizeof(buffer), "%t:2 [Activated]", "Constraints_9");
		else if(CC_EnemyShieldBuff_A)
			FormatEx(buffer, sizeof(buffer), "%t:2 [%t]", "Constraints_9", "Constraints_8");
		else
			FormatEx(buffer, sizeof(buffer), "%t:2", "Constraints_9");
		menu.AddItem("9", buffer);
		
		if(CC_AlliesSupplyIssuesDebuff_A)
			FormatEx(buffer, sizeof(buffer), "%t:1 [Activated]", "Constraints_10");
		else if(CC_AlliesSupplyIssuesDebuff_B)
			FormatEx(buffer, sizeof(buffer), "%t:1 [%t]", "Constraints_10", "Constraints_11");
		else
			FormatEx(buffer, sizeof(buffer), "%t:1", "Constraints_10");
		menu.AddItem("10", buffer);
		
		if(CC_AlliesSupplyIssuesDebuff_B)
			FormatEx(buffer, sizeof(buffer), "%t:2 [Activated]", "Constraints_11");
		else if(CC_AlliesSupplyIssuesDebuff_A)
			FormatEx(buffer, sizeof(buffer), "%t:2 [%t]", "Constraints_11", "Constraints_10");
		else
			FormatEx(buffer, sizeof(buffer), "%t:2", "Constraints_11");
		menu.AddItem("11", buffer);
	}
	else
	{
		bool AnyConstraintsOn=false;
		if(CC_EnemyDMGBuff_A)
		{
			FormatEx(buffer, sizeof(buffer), "%t:1", "Constraints_0");
			menu.AddItem("", buffer, ITEMDRAW_DISABLED);
			AnyConstraintsOn=true;
		}
		if(CC_EnemyDMGBuff_B)
		{
			FormatEx(buffer, sizeof(buffer), "%t:2", "Constraints_1");
			menu.AddItem("", buffer, ITEMDRAW_DISABLED);
			AnyConstraintsOn=true;
		}
		if(CC_EnemyDMGBuff_C)
		{
			FormatEx(buffer, sizeof(buffer), "%t:3", "Constraints_2");
			menu.AddItem("", buffer, ITEMDRAW_DISABLED);
			AnyConstraintsOn=true;
		}
		if(CC_EnemyResistBuff_A)
		{
			FormatEx(buffer, sizeof(buffer), "%t:1", "Constraints_3");
			menu.AddItem("", buffer, ITEMDRAW_DISABLED);
			AnyConstraintsOn=true;
		}
		if(CC_EnemyResistBuff_B)
		{
			FormatEx(buffer, sizeof(buffer), "%t:2", "Constraints_4");
			menu.AddItem("", buffer, ITEMDRAW_DISABLED);
			AnyConstraintsOn=true;
		}
		if(CC_EnemyMoveBuff_A)
		{
			FormatEx(buffer, sizeof(buffer), "%t:1", "Constraints_5");
			menu.AddItem("", buffer, ITEMDRAW_DISABLED);
			AnyConstraintsOn=true;
		}
		if(CC_EnemyMoveBuff_B)
		{
			FormatEx(buffer, sizeof(buffer), "%t:2", "Constraints_6");
			menu.AddItem("", buffer, ITEMDRAW_DISABLED);
			AnyConstraintsOn=true;
		}
		if(CC_EnemyExplodBuff)
		{
			FormatEx(buffer, sizeof(buffer), "%t:1", "Constraints_7");
			menu.AddItem("", buffer, ITEMDRAW_DISABLED);
			AnyConstraintsOn=true;
		}
		if(CC_EnemyShieldBuff_A)
		{
			FormatEx(buffer, sizeof(buffer), "%t:1", "Constraints_8");
			menu.AddItem("", buffer, ITEMDRAW_DISABLED);
			AnyConstraintsOn=true;
		}
		if(CC_EnemyShieldBuff_B)
		{
			FormatEx(buffer, sizeof(buffer), "%t:2", "Constraints_9");
			menu.AddItem("", buffer, ITEMDRAW_DISABLED);
			AnyConstraintsOn=true;
		}
		if(CC_AlliesSupplyIssuesDebuff_A)
		{
			FormatEx(buffer, sizeof(buffer), "%t:1", "Constraints_10");
			menu.AddItem("", buffer, ITEMDRAW_DISABLED);
			AnyConstraintsOn=true;
		}
		if(CC_AlliesSupplyIssuesDebuff_B)
		{
			FormatEx(buffer, sizeof(buffer), "%t:2", "Constraints_11");
			menu.AddItem("", buffer, ITEMDRAW_DISABLED);
			AnyConstraintsOn=true;
		}
		
		if(!AnyConstraintsOn)
		{
			FormatEx(buffer, sizeof(buffer), "%t", "None");
			menu.AddItem("", buffer, ITEMDRAW_DISABLED);
		}
	}
	
	menu.ExitBackButton = true;
	menu.DisplayAt(client, page / 7 * 7, MENU_TIME_FOREVER);
}

public int CC_ContractMenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			if(choice == MenuCancel_ExitBack)
				Store_Menu(client);
		}
		case MenuAction_Select:
		{
			SetGlobalTransTarget(client);
			bool descmode = false;
			if(GetEntityFlags(client) & FL_DUCKING)descmode = true;
			if(TeutonType[client] != TEUTON_NONE || !IsPlayerAlive(client))descmode = true;
			char buffer[24],buffer2[64];
			menu.GetItem(choice, buffer, sizeof(buffer));
			int index = StringToInt(buffer);
			if(!CC_ConstraintsBlock)
			{
				switch(index)
				{
					case 0:
					{
						if(descmode)
						{
							FormatEx(buffer2, sizeof(buffer2), "Constraints_desc_%i", index);
							CPrintToChat(client, "%t", buffer2);
						}
						else
						{
							CC_EnemyDMGBuff_A=!CC_EnemyDMGBuff_A;
							if(CC_EnemyDMGBuff_A)
							{
								CC_EnemyDMGBuff_B=false;
								CC_EnemyDMGBuff_C=false;
								CPrintToChatAll("{olive}%N{default} has {blue}activated.", client);
							}
							else
								CPrintToChatAll("{olive}%N{default} has {red}disabled.", client);
							FormatEx(buffer2, sizeof(buffer2), "Constraints_%i", index);
							CPrintToChatAll("%t", buffer2);
						}
					}
					case 1:
					{
						if(descmode)
						{
							FormatEx(buffer2, sizeof(buffer2), "Constraints_desc_%i", index);
							CPrintToChat(client, "%t", buffer2);
						}
						else
						{
							CC_EnemyDMGBuff_B=!CC_EnemyDMGBuff_B;
							if(CC_EnemyDMGBuff_B)
							{
								CC_EnemyDMGBuff_A=false;
								CC_EnemyDMGBuff_C=false;
								CPrintToChatAll("{olive}%N{default} has {blue}activated.", client);
							}
							else
								CPrintToChatAll("{olive}%N{default} has {red}disabled.", client);
							FormatEx(buffer2, sizeof(buffer2), "Constraints_%i", index);
							CPrintToChatAll("%t", buffer2);
						}
					}
					case 2:
					{
						if(descmode)
						{
							FormatEx(buffer2, sizeof(buffer2), "Constraints_desc_%i", index);
							CPrintToChat(client, "%t", buffer2);
						}
						else
						{
							CC_EnemyDMGBuff_C=!CC_EnemyDMGBuff_C;
							if(CC_EnemyDMGBuff_C)
							{
								CC_EnemyDMGBuff_A=false;
								CC_EnemyDMGBuff_B=false;
								CPrintToChatAll("{olive}%N{default} has {blue}activated.", client);
							}
							else
								CPrintToChatAll("{olive}%N{default} has {red}disabled.", client);
							FormatEx(buffer2, sizeof(buffer2), "Constraints_%i", index);
							CPrintToChatAll("%t", buffer2);
						}
					}
					case 3:
					{
						if(descmode)
						{
							FormatEx(buffer2, sizeof(buffer2), "Constraints_desc_%i", index);
							CPrintToChat(client, "%t", buffer2);
						}
						else
						{
							CC_EnemyResistBuff_A=!CC_EnemyResistBuff_A;
							if(CC_EnemyResistBuff_A)
							{
								CC_EnemyResistBuff_B=false;
								CPrintToChatAll("{olive}%N{default} has {blue}activated.", client);
							}
							else
								CPrintToChatAll("{olive}%N{default} has {red}disabled.", client);
							FormatEx(buffer2, sizeof(buffer2), "Constraints_%i", index);
							CPrintToChatAll("%t", buffer2);
						}
					}
					case 4:
					{
						if(descmode)
						{
							FormatEx(buffer2, sizeof(buffer2), "Constraints_desc_%i", index);
							CPrintToChat(client, "%t", buffer2);
						}
						else
						{
							CC_EnemyResistBuff_B=!CC_EnemyResistBuff_B;
							if(CC_EnemyResistBuff_B)
							{
								CC_EnemyResistBuff_A=false;
								CPrintToChatAll("{olive}%N{default} has {blue}activated.", client);
							}
							else
								CPrintToChatAll("{olive}%N{default} has {red}disabled.", client);
							FormatEx(buffer2, sizeof(buffer2), "Constraints_%i", index);
							CPrintToChatAll("%t", buffer2);
						}
					}
					case 5:
					{
						if(descmode)
						{
							FormatEx(buffer2, sizeof(buffer2), "Constraints_desc_%i", index);
							CPrintToChat(client, "%t", buffer2);
						}
						else
						{
							CC_EnemyMoveBuff_A=!CC_EnemyMoveBuff_A;
							if(CC_EnemyMoveBuff_A)
							{
								CC_EnemyMoveBuff_B=false;
								CPrintToChatAll("{olive}%N{default} has {blue}activated.", client);
							}
							else
								CPrintToChatAll("{olive}%N{default} has {red}disabled.", client);
							FormatEx(buffer2, sizeof(buffer2), "Constraints_%i", index);
							CPrintToChatAll("%t", buffer2);
						}
					}
					case 6:
					{
						if(descmode)
						{
							FormatEx(buffer2, sizeof(buffer2), "Constraints_desc_%i", index);
							CPrintToChat(client, "%t", buffer2);
						}
						else
						{
							CC_EnemyMoveBuff_B=!CC_EnemyMoveBuff_B;
							if(CC_EnemyMoveBuff_B)
							{
								CC_EnemyMoveBuff_A=false;
								CPrintToChatAll("{olive}%N{default} has {blue}activated.", client);
							}
							else
								CPrintToChatAll("{olive}%N{default} has {red}disabled.", client);
							FormatEx(buffer2, sizeof(buffer2), "Constraints_%i", index);
							CPrintToChatAll("%t", buffer2);
						}
					}
					case 7:
					{
						if(descmode)
						{
							FormatEx(buffer2, sizeof(buffer2), "Constraints_desc_%i", index);
							CPrintToChat(client, "%t", buffer2);
						}
						else
						{
							CC_EnemyExplodBuff=!CC_EnemyExplodBuff;
							if(CC_EnemyExplodBuff)
								CPrintToChatAll("{olive}%N{default} has {blue}activated.", client);
							else
								CPrintToChatAll("{olive}%N{default} has {red}disabled.", client);
							FormatEx(buffer2, sizeof(buffer2), "Constraints_%i", index);
							CPrintToChatAll("%t", buffer2);
						}
					}
					case 8:
					{
						if(descmode)
						{
							FormatEx(buffer2, sizeof(buffer2), "Constraints_desc_%i", index);
							CPrintToChat(client, "%t", buffer2);
						}
						else
						{
							CC_EnemyShieldBuff_A=!CC_EnemyShieldBuff_A;
							if(CC_EnemyShieldBuff_A)
							{
								CC_EnemyShieldBuff_B=false;
								CPrintToChatAll("{olive}%N{default} has {blue}activated.", client);
							}
							else
								CPrintToChatAll("{olive}%N{default} has {red}disabled.", client);
							FormatEx(buffer2, sizeof(buffer2), "Constraints_%i", index);
							CPrintToChatAll("%t", buffer2);
						}
					}
					case 9:
					{
						if(descmode)
						{
							FormatEx(buffer2, sizeof(buffer2), "Constraints_desc_%i", index);
							CPrintToChat(client, "%t", buffer2);
						}
						else
						{
							CC_EnemyShieldBuff_B=!CC_EnemyShieldBuff_B;
							if(CC_EnemyShieldBuff_B)
							{
								CC_EnemyShieldBuff_A=false;
								CPrintToChatAll("{olive}%N{default} has {blue}activated.", client);
							}
							else
								CPrintToChatAll("{olive}%N{default} has {red}disabled.", client);
							FormatEx(buffer2, sizeof(buffer2), "Constraints_%i", index);
							CPrintToChatAll("%t", buffer2);
						}
					}
					case 10:
					{
						if(descmode)
						{
							FormatEx(buffer2, sizeof(buffer2), "Constraints_desc_%i", index);
							CPrintToChat(client, "%t", buffer2);
						}
						else
						{
							CC_AlliesSupplyIssuesDebuff_A=!CC_AlliesSupplyIssuesDebuff_A;
							if(CC_AlliesSupplyIssuesDebuff_A)
							{
								CC_AlliesSupplyIssuesDebuff_B=false;
								CPrintToChatAll("{olive}%N{default} has {blue}activated.", client);
							}
							else
								CPrintToChatAll("{olive}%N{default} has {red}disabled.", client);
							FormatEx(buffer2, sizeof(buffer2), "Constraints_%i", index);
							CPrintToChatAll("%t", buffer2);
						}
					}
					case 11:
					{
						if(descmode)
						{
							FormatEx(buffer2, sizeof(buffer2), "Constraints_desc_%i", index);
							CPrintToChat(client, "%t", buffer2);
						}
						else
						{
							CC_AlliesSupplyIssuesDebuff_B=!CC_AlliesSupplyIssuesDebuff_B;
							if(CC_AlliesSupplyIssuesDebuff_B)
							{
								CC_AlliesSupplyIssuesDebuff_A=false;
								CPrintToChatAll("{olive}%N{default} has {blue}activated.", client);
							}
							else
								CPrintToChatAll("{olive}%N{default} has {red}disabled.", client);
							FormatEx(buffer2, sizeof(buffer2), "Constraints_%i", index);
							CPrintToChatAll("%t", buffer2);
						}
					}
				}
			}
			CC_ContractMenu(client, choice);
		}
	}
	return 0;
}

void CC_Contract_OnNPCDeath(int entity)
{
	if(CCMode)
	{
		if(CC_EnemyExplodBuff)
		{
			float ExplodeNPCDamage = 125.0;
			if(CC_EnemyDMGBuff_A)
				ExplodeNPCDamage *= 1.2;
			if(CC_EnemyDMGBuff_B)
				ExplodeNPCDamage *= 1.5;
			if(CC_EnemyDMGBuff_C)
				ExplodeNPCDamage  *= 2.0;
			float startPosition[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", startPosition); 
			KillFeed_SetKillIcon(entity, "ullapool_caber_explosion");
			Explode_Logic_Custom(ExplodeNPCDamage, entity, entity, -1, startPosition, 150.0, 0.75, _, false);
			EmitSoundToAll(g_ExplosionSounds, entity, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80,125));
		}
	}
}

void CC_Contract_SpawnEnemy(int entity)
{
	if(CCMode)
	{
		//CreateTimer(0.01, Delay_SpawnEffect, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
		if(entity <= 0 || !IsValidEntity(entity))
			return;
			
		float CC_Extra_Speed = 1.0;
		float CC_Extra_MeleeArmor = 1.0;
		float CC_Extra_RangedArmor = 1.0;
		float CC_Extra_Damage = 1.0;
		if(CC_EnemyDMGBuff_A)
			CC_Extra_Damage *= 1.2;
		if(CC_EnemyDMGBuff_B)
			CC_Extra_Damage *= 1.5;
		if(CC_EnemyDMGBuff_C)
			CC_Extra_Damage *= 2.0;
		if(CC_EnemyResistBuff_A)
		{
			CC_Extra_MeleeArmor *= 0.8;
			CC_Extra_RangedArmor *= 0.8;
		}
		if(CC_EnemyResistBuff_B)
		{
			CC_Extra_MeleeArmor *= 0.65;
			CC_Extra_RangedArmor *= 0.65;
		}
		if(CC_EnemyMoveBuff_A)
			CC_Extra_Speed *= 1.15;
		if(CC_EnemyMoveBuff_B)
			CC_Extra_Speed *= 1.33;
		if(CC_EnemyShieldBuff_A)
			VausMagicaGiveShield(entity, 3, _, true);
		if(CC_EnemyShieldBuff_B)
			VausMagicaGiveShield(entity, 6, _, true);

		fl_Extra_Speed[entity]*=CC_Extra_Speed;
		fl_Extra_MeleeArmor[entity] *= CC_Extra_MeleeArmor;
		fl_Extra_RangedArmor[entity] *= CC_Extra_RangedArmor;
		fl_Extra_Damage[entity] *= CC_Extra_Damage;
	}
}
/*
public Action Delay_SpawnEffect(Handle timer, any Ref)
{
	int entity = EntRefToEntIndex(Ref);
	if(entity <= 0 || !IsValidEntity(entity) || !CCMode)
		return Plugin_Stop;
		
	float CC_Extra_Speed = 1.0;
	float CC_Extra_MeleeArmor = 1.0;
	float CC_Extra_RangedArmor = 1.0;
	float CC_Extra_Damage = 1.0;
	if(CC_EnemyDMGBuff_A)
		CC_Extra_Damage *= 1.2;
	if(CC_EnemyDMGBuff_B)
		CC_Extra_Damage *= 1.5;
	if(CC_EnemyDMGBuff_C)
		CC_Extra_Damage *= 2.0;
	if(CC_EnemyResistBuff_A)
	{
		CC_Extra_MeleeArmor *= 0.8;
		CC_Extra_RangedArmor *= 0.8;
	}
	if(CC_EnemyResistBuff_B)
	{
		CC_Extra_MeleeArmor *= 0.65;
		CC_Extra_RangedArmor *= 0.65;
	}
	if(CC_EnemyMoveBuff_A)
		CC_Extra_Speed *= 1.15;
	if(CC_EnemyMoveBuff_B)
		CC_Extra_Speed *= 1.33;
	if(CC_EnemyShieldBuff_A)
		VausMagicaGiveShield(entity, 3, true);
	if(CC_EnemyShieldBuff_B)
		VausMagicaGiveShield(entity, 6, true);

	fl_Extra_Speed[entity]*=CC_Extra_Speed;
	fl_Extra_MeleeArmor[entity] *= CC_Extra_MeleeArmor;
	fl_Extra_RangedArmor[entity] *= CC_Extra_RangedArmor;
	fl_Extra_Damage[entity] *= CC_Extra_Damage;
	return Plugin_Stop;
}*/
void CC_Contract_OnEndWave(int &cash)
{
	if(CCMode)
	{
		if(CC_AlliesSupplyIssuesDebuff_A)Ammo_Count_Ready -= 1;
		if(CC_AlliesSupplyIssuesDebuff_B)Ammo_Count_Ready -= 2;
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsValidClient(client))
			{
				if(CC_AlliesSupplyIssuesDebuff_A)Ammo_Count_Used[client] += 1;
				if(CC_AlliesSupplyIssuesDebuff_B)Ammo_Count_Used[client] += 2;
			}
		}
	}
}

static Action CC_Contract_Timer(Handle CCTimer)
{
	if(!CC_ConstraintsBlock)
	{
		if(Waves_InSetup())
			return Plugin_Continue;
		CC_ConstraintsBlock=true;
	}

	for (int client = 0; client < MaxClients; client++)
	{
		if(IsValidClient(client) && IsPlayerAlive(client))
		{
			if(Waves_InSetup())
			{
			}
			else
			{
			}
		}
	}
	for(int entitycount_again; entitycount_again<i_MaxcountNpcTotal; entitycount_again++)
	{
		int ally = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount_again]);
		if (IsValidEntity(ally) && !b_NpcHasDied[ally] && GetTeam(ally) == TFTeam_Red)
		{
			if(Waves_InSetup())
			{
			}
			else
			{
			}
		}
	}

	return Plugin_Continue;
}