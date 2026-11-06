#pragma semicolon 1
#pragma newdecls required

enum {
	HoldoutState_Setup,
	HoldoutState_Waiting,
	HoldoutState_Trans,
	HoldoutState_Vote,
	HoldoutState_Stage
};

enum struct HoldoutInfo
{
	char Name[64];
	char Skyname[64];
	char ArtifactKey[64];
	int RoomCount;
	int EncounterCount;
	
	MusicEnum MusicNormal;
	
	ArrayList Fights;
	ArrayList Encounters;
	ArrayList Finals;
	
	void SetupKv(KeyValues kv)
	{
		kv.GetSectionName(this.Name, 64);
		if(!TranslationPhraseExists(this.Name))
		{
			LogError("\"%s\" translation does not exist", this.Name);
			strcopy(this.Name, 64, "Missing Rogue Translation");
		}
		
		this.RoomCount = kv.GetNum("rooms", 2) - 2;
		this.EncounterCount = kv.GetNum("specials", 1);
		kv.GetString("skyname", this.Skyname, 64);
		kv.GetString("key", this.ArtifactKey, 64);
		
		this.MusicNormal.SetupKv("normal_music", kv);
		
		Stage stage;
		
		this.Fights = new ArrayList(sizeof(Stage));
		if(kv.JumpToKey("Fights"))
		{
			if(kv.GotoFirstSubKey())
			{
				do
				{
					int common = stage.SetupKv(kv, this.Skyname);
					do
					{
						this.Fights.PushArray(stage);
					}
					while(--common > 0);
				}
				while(kv.GotoNextKey());
				
				kv.GoBack();
			}
			
			kv.GoBack();
		}
		
		if(kv.JumpToKey("Encounters"))
		{
			if(kv.GotoFirstSubKey())
			{
				this.Encounters = new ArrayList(sizeof(Stage));
				
				do
				{
					int common = stage.SetupKv(kv, this.Skyname);
					do
					{
						this.Encounters.PushArray(stage);
					}
					while(--common > 0);
				}
				while(kv.GotoNextKey());
				
				kv.GoBack();
			}
			else
			{
				this.Encounters = null;
			}

			kv.GoBack();
		}
		else
		{
			this.Encounters = null;
		}
		
		if(kv.JumpToKey("Final"))
		{
			if(kv.GotoFirstSubKey())
			{
				this.Finals = new ArrayList(sizeof(Stage));
				
				do
				{
					stage.SetupKv(kv, this.Skyname);
					this.Finals.PushArray(stage);
				}
				while(kv.GotoNextKey());

				kv.GoBack();
			}
			else
			{
				this.Finals = null;
			}

			kv.GoBack();
		}
		else
		{
			this.Finals = null;
		}
	}
}

static bool InHoldoutMode;
static ArrayList HoldoutFloors;

static int HoldoutGameState;
static Handle HoldoutProgressTimer;

static int CurrentFloor;
static int CurrentStage = -1;
static int CurrentCount = -1;
static int CurrentType; // 0: Normal Battle, 1: Encounter, 2: Final Battle

static int CurrentIngots;
static int BattleIngots;

static ArrayList CurrentExclude;

bool Holdout_Mode()
{
	return InHoldoutMode;
}

bool Holdout_Started()
{
	return Holdout_Mode() && GameRules_GetRoundState() == RoundState_ZombieRiot;
}

bool Holdout_InSetup()
{
	if(!InHoldoutMode)
		return false;
	
	if(HoldoutGameState == HoldoutState_Setup || HoldoutGameState == HoldoutState_Waiting)
		return true;
	
	return HoldoutProgressTimer != null;
}

int Holdout_GetFloor()
{
	return CurrentFloor;
}

/*
int Holdout_GetStage()
{
	return CurrentCount;
}
*/

/*
int Holdout_GetIngots()
{
	return CurrentIngots;
}
*/

int Holdout_GetRound()
{
	return (CurrentFloor * 10) + CurrentCount;
}

void Holdout_AddIngots(int amount, bool silent = false)
{
	int given = amount;
	Rogue_TriggerFunction(Artifact::FuncIngotChanged, given);

	if(given)
	{
		CurrentIngots += given;
		Waves_UpdateMvMStats();

		if(!silent)
		{
			if(given < 0)
			{
				CPrintToChatAll("%t", "Lost Ingots", -given);
			}
			else
			{
				CPrintToChatAll("%t", "Gained Ingots", given);
			}
		}
	}
}

void Holdout_SetBattleIngots(int amount)
{
	BattleIngots = amount;
}

void Holdout_PluginStart()
{
	LoadTranslations("zombieriot.phrases.holdout"); 
}

void Holdout_MapStart()
{
	InHoldoutMode = false;
	Holdout_RoundEnd();
}

void Holdout_SetupVote(KeyValues kv)
{
	InHoldoutMode = true;
	Holdout_RoundEnd();

	Rogue_SetupVote(kv, "Holdout");

	if(HoldoutFloors)
	{
		HoldoutInfo floor;
		int len = HoldoutFloors.Length;
		for(int i = 0; i < len; i++)
		{
			HoldoutFloors.GetArray(i, floor);
			delete floor.Fights;
			delete floor.Encounters;
			delete floor.Finals;
		}
		delete HoldoutFloors;
	}
	
	HoldoutFloors = new ArrayList(sizeof(HoldoutInfo));
	
	if(kv.JumpToKey("Floors"))
	{
		if(kv.GotoFirstSubKey())
		{
			HoldoutInfo floor;
			do
			{
				floor.SetupKv(kv);
				HoldoutFloors.PushArray(floor);
			}
			while(kv.GotoNextKey());
			
			kv.GoBack();
		}
		kv.GoBack();
	}

	if(!HoldoutFloors.Length)
	{
		HoldoutInfo defaultFloor;
		defaultFloor.SetupKv(kv);
		HoldoutFloors.PushArray(defaultFloor);
	}
	
	SteamWorks_UpdateGameTitle();
	
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && GetClientTeam(client) > 1)
		{
			Waves_RoundStart();
			break;
		}
	}
	
	Waves_SetReadyStatus(2);
}

void Holdout_StartSetup()
{
	Rogue_StartSetup();
	Holdout_RoundEnd();
	
	s_MissionClient = "{white}Bob the First";
}

void Holdout_RoundEnd()
{
	CurrentFloor = 0;
	CurrentCount = -1;
	CurrentStage = -1;
	
	CurrentIngots = 0;
	BattleIngots = 0;
	
	HoldoutGameState = HoldoutState_Setup;
	
	delete CurrentExclude;
	delete HoldoutProgressTimer;
}

void Holdout_Start()
{
	delete HoldoutProgressTimer;
	
	Ammo_Count_Ready = 15;
	RemoveAllCustomMusic();
	
	for(int client = 1; client <= MaxClients; client++)
	{
		GrantCreditsBack(client);
	}
	
	int highestLevel;
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && !IsFakeClient(client) && GetClientTeam(client) == 2)
		{
			int amount = SkillTree_GetByName(client, "Ingot Up 1");
			if(amount > highestLevel)
				highestLevel = amount;
		}
	}
	
	CPrintToChatAll("{green}%t", "Explain Holdout Mode 1");
	CPrintToChatAll("{green}%t", "Explain Holdout Mode 2");
	
	int startingIngots = highestLevel + 8;
	Holdout_AddIngots(startingIngots, true);
	
	HoldoutInfo floor;
	HoldoutFloors.GetArray(CurrentFloor, floor);
	
	Stage stage;
	int id = Holdout_GetRandomStage(floor, stage, 0, 1, floor.RoomCount + 2);
	if(id == -1)
	{
		PrintToChatAll("NO BATTLES ON FIRST FLOOR? BAD CFG, REPORT BUG");
	}
	else
	{
		Holdout_SetNextStage(id, 0, stage, 5.0);
	}
	
	char buffer[64];
	FormatEx(buffer, sizeof(buffer), "%s Lore", floor.Name);
	if(TranslationPhraseExists(buffer))
		PrintToChatAll("%t", buffer);
}

bool Holdout_ShowStatus(int client)
{
	if(InHoldoutMode)
	{
		switch(HoldoutGameState)
		{
			case HoldoutState_Trans, HoldoutState_Vote, HoldoutState_Waiting:
			{
				static HoldoutInfo floor;
				HoldoutFloors.GetArray(CurrentFloor, floor);
				
				SetHudTextParams(0.15, 0.05, 0.81, 255, 255, 255, 255);
				int DisplayDo = CurrentCount + (HoldoutGameState == HoldoutState_Vote ? 2 : 1);
				if(DisplayDo <= 1)
					DisplayDo = 1;
				
				ShowSyncHudText(client, SyncHud_WandMana, "%T", "Rogue Stage Status", client, floor.Name, DisplayDo, floor.RoomCount + 2);
				return true;
			}
		}
	}
	return false;
}

void Holdout_BattleVictory()
{
	ReviveAll();
	Waves_RoundEnd();
	
	bool victory = true;
	Rogue_TriggerFunction(Artifact::FuncStageEnd, victory);
	
	Store_RogueEndFightReset();
	
	if(BattleIngots > 0)
	{
		if(CurrentType == 2)
		{
			Artifact artifact;
			if(Rogue_GetRandomArtifact(artifact, true, -1) != -1)
			{
				CPrintToChatAll("%t", "Holdout Hard Battle Victory");
				Rogue_GiveNamedArtifact(artifact.Name);
			}
		}
		else
		{
			if((GetURandomInt() % 8) < BattleIngots)
			{
				Artifact artifact;
				if(Rogue_GetRandomArtifact(artifact, true, -1) != -1)
					Rogue_GiveNamedArtifact(artifact.Name);
			}
		}
		
		Holdout_AddIngots(BattleIngots);
	}
	
	Holdout_SetProgressTime(5.0, true);
}

bool Holdout_BattleLost()
{
	bool victory = false;
	Rogue_TriggerFunction(Artifact::FuncStageEnd, victory);
	return true;
}

void Holdout_NextProgress()
{
	switch(HoldoutGameState)
	{
		case HoldoutState_Waiting:
		{
			// 준비 단계 완료 후 층 첫 스테이지(전투) 시작
			HoldoutInfo floor;
			HoldoutFloors.GetArray(CurrentFloor, floor);
			
			Stage stage;
			int id = Holdout_GetRandomStage(floor, stage, 0, 1, floor.RoomCount + 2);
			if(id != -1)
			{
				Holdout_SetNextStage(id, 0, stage, 5.0);
			}
		}
		case HoldoutState_Trans:
		{
			HoldoutInfo floor;
			HoldoutFloors.GetArray(CurrentFloor, floor);
			
			Stage stage;
			if(CurrentType == 2)
			{
				floor.Finals.GetArray(CurrentStage, stage);
			}
			else if(CurrentType == 1)
			{
				floor.Encounters.GetArray(CurrentStage, stage);
			}
			else
			{
				floor.Fights.GetArray(CurrentStage, stage);
			}
			
			Holdout_StartStage(stage);
		}
		case HoldoutState_Stage:
		{
			Holdout_StageHandler();
		}
		default:
		{
			PrintToChatAll("INVALID GAME STATE %d, REPORT BUG", HoldoutGameState);
			HoldoutGameState = HoldoutState_Stage;
			Holdout_NextProgress();
		}
	}
	
	Waves_UpdateMvMStats();
}

static void Holdout_StageHandler()
{
	HoldoutInfo floor;
	HoldoutFloors.GetArray(CurrentFloor, floor);
	
	Stage stage;
	if(CurrentStage != -1)
	{
		if(CurrentType == 2)
		{
			floor.Finals.GetArray(CurrentStage, stage);
		}
		else if(CurrentType == 1)
		{
			floor.Encounters.GetArray(CurrentStage, stage);
		}
		else
		{
			floor.Fights.GetArray(CurrentStage, stage);
		}
	}
	
	int maxRooms = floor.RoomCount;
	int maxBattles = maxRooms - floor.EncounterCount - 1;
	
	// 1. 해당 층의 모든 스테이지 완료 (마지막 보스전 종료)
	if(CurrentCount >= maxRooms)
	{
		CurrentFloor++;
		CurrentStage = -1;
		CurrentCount = -1;
		
		if(CurrentCollection)
		{
			ArrayList list = CurrentCollection.Clone();
			
			Artifact artifact;
			int length = list.Length;
			for(int i; i < length; i++)
			{
				Artifacts.GetArray(list.Get(i), artifact);
				if(artifact.FuncFloorChange != INVALID_FUNCTION)
				{
					Call_StartFunction(null, artifact.FuncFloorChange);
					Call_PushCellRef(CurrentFloor);
					Call_PushCellRef(CurrentCount);
					Call_Finish();
				}
			}
			
			delete list;
		}
		
		bool victory = CurrentFloor >= HoldoutFloors.Length;
		if(!victory)
		{
			Native_OnSpecialModeProgress(CurrentFloor, HoldoutFloors.Length);
			HoldoutFloors.GetArray(CurrentFloor, floor);
			if(floor.ArtifactKey[0] && !Rogue_HasNamedArtifact(floor.ArtifactKey))
			{
				if(CurrentFloor == (HoldoutFloors.Length - 1))
				{
					victory = true;
				}
				else
				{
					CurrentCount = maxRooms + 1;
					Holdout_NextProgress();
					return;
				}
			}
		}
		
		SteamWorks_UpdateGameTitle();
		
		if(victory)	// 모든 층 클리어 -> 게임 승리
		{
			ForcePlayerWin();
		}
		else	// 다음 층으로 이동 및 대기 상태 진입
		{
			Holdout_MoveFloor(CurrentFloor, CurrentCount, true);
		}
	}
	// 2. 보스 스테이지 (Final)
	else if(CurrentCount >= maxRooms - 1)
	{
		int id = Holdout_GetRandomStage(floor, stage, 2, CurrentCount + 2, maxRooms + 2);
		if(id == -1)
		{
			CurrentCount = maxRooms;
			Holdout_NextProgress();
		}
		else
		{
			Holdout_SetNextStage(id, 2, stage, 5.0);
		}
	}
	// 3. 인카운터 스테이지 (Encounters)
	else if(CurrentCount >= maxBattles)
	{
		Holdout_StartStageVote();
	}
	// 4. 일반 전투 스테이지 (Fights)
	else
	{
		int id = Holdout_GetRandomStage(floor, stage, 0, CurrentCount + 2, maxRooms + 2);
		if(id == -1)
		{
			CPrintToChatAll("%t", "Holdout Ranout of Battles");
			CurrentCount = maxBattles;
			Holdout_NextProgress();
		}
		else
		{
			if(!stage.Repeat)
			{
				if(!CurrentExclude)
					CurrentExclude = new ArrayList(sizeof(stage.Name));
				
				CurrentExclude.PushString(stage.Name);
			}
			
			Holdout_SetNextStage(id, 0, stage, 5.0);
		}
	}
}

/*
public void Holdout_StartThisBattle(float time)
{
	delete HoldoutProgressTimer;

	HoldoutInfo floor;
	HoldoutFloors.GetArray(CurrentFloor, floor);
	
	Stage stage;
	if(CurrentType == 2)
	{
		floor.Finals.GetArray(CurrentStage, stage);
	}
	else if(CurrentType == 1)
	{
		floor.Encounters.GetArray(CurrentStage, stage);
	}
	else
	{
		floor.Fights.GetArray(CurrentStage, stage);
	}

	Holdout_StartBattle(stage, time);
}
*/

static void Holdout_SetNextStage(int id, int type, const Stage stage, float time = 5.0)
{
	CurrentCount++;
	CurrentStage = id;
	CurrentType = type;
	
	strcopy(WhatDifficultySetting, sizeof(WhatDifficultySetting), stage.Name);
	strcopy(WhatDifficultySetting_Internal, sizeof(WhatDifficultySetting_Internal), stage.Name);
	WavesUpdateDifficultyName();
	
	if(stage.WaveSet[0])
	{
		HoldoutGameState = HoldoutState_Trans;
		Holdout_SetProgressTime(time, true);
	}
	else
	{
		Holdout_StartStage(stage);
	}
	
	Waves_UpdateMvMStats();
}

static void Holdout_StartStage(const Stage stage)
{
	HoldoutGameState = HoldoutState_Stage;
	BattleIngots = CurrentFloor > 1 ? 4 : 3;
	
	float time = stage.WaveSet[0] ? 0.0 : 10.0;
	if(stage.FuncStart != INVALID_FUNCTION)
	{
		Call_StartFunction(null, stage.FuncStart);
		Call_Finish(time);
	}
	
	if(time <= 0.0 && stage.WaveSet[0])
	{
		Holdout_StartBattle(stage);
	}
	else
	{
		Holdout_SetProgressTime(time > 0.0 ? time : 10.0, true);
	}
	
	Waves_SetSkyName(stage.Skyname);
}

static void Holdout_StartBattle(const Stage stage, float time = 3.0)
{
	HoldoutGameState = HoldoutState_Stage;
	
	Rogue_TriggerFunction(Artifact::FuncStageStart);
	
	if(!stage.IntroMusic.Path[0])
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				Music_Stop_All(client);
				SetMusicTimer(client, GetTime() + 3);
			}
		}
	}
	
	RandomPickup_ResetTimer();
	RemoveAllCustomMusic();
	
	char buffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, stage.WaveSet);
	KeyValues kv = new KeyValues("Waves");
	kv.ImportFromFile(buffer);
	Waves_SetupWaves(kv, false);
	delete kv;
	
	CreateTimer(time, Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
	WaveStart_SubWaveStart(GetGameTime());
}

static void Holdout_StartStageVote()
{
	HoldoutInfo floor;
	HoldoutFloors.GetArray(CurrentFloor, floor);
	
	if(!floor.Encounters || floor.Encounters.Length == 0)
	{
		CurrentCount = floor.RoomCount - 1;
		Holdout_NextProgress();
		return;
	}
	
	ArrayList voting = Rogue_CreateGenericVote(Holdout_Vote_NextStage, "Holdout Stage Vote");
	
	int length = floor.Encounters.Length;
	int count = length < 3 ? length : 3;
	
	Vote vote;
	Stage stage;
	
	for(int i = 0; i < count; i++)
	{
		strcopy(vote.DisplayFormat, sizeof(vote.DisplayFormat), "");
		
		int id = Holdout_GetRandomStage(floor, stage, 1, CurrentCount + 2, floor.RoomCount + 2);
		if (id != -1)
		{
			strcopy(vote.Config, sizeof(vote.Config), stage.Name);
			
			if(stage.Hidden)
			{
				strcopy(vote.Name, sizeof(vote.Name), "Encounter");
			}
			else
			{
				strcopy(vote.Name, sizeof(vote.Name), stage.Name);
			}
			
			char buffer[64];
			FormatEx(buffer, sizeof(buffer), "Holdout %s Stage Desc", stage.Name);
			if(TranslationPhraseExists(buffer))
				strcopy(vote.Desc, sizeof(vote.Desc), buffer);
			
			voting.PushArray(vote);
		}
	}
	
	if(voting.Length)
	{
		HoldoutGameState = HoldoutState_Vote;
		Rogue_StartGenericVote(15.0);
	}
	else
	{
		delete voting;
		CurrentCount = floor.RoomCount - 1;
		Holdout_NextProgress();
	}
}

public void Holdout_Vote_NextStage(const Vote vote)
{
	HoldoutInfo floor;
	HoldoutFloors.GetArray(CurrentFloor, floor);
	
	Stage stage;
	int id = Holdout_GetStageByName(floor, vote.Config, 1, stage);
	
	if(id == -1)
	{
		PrintToChatAll("STAGE \"%s\" VANISHED, REPORT BUG", vote.Config);
		floor.Encounters.GetArray(0, stage);
		id = 0;
	}
	else if(!stage.Repeat)
	{
		if(!CurrentExclude)
			CurrentExclude = new ArrayList(sizeof(stage.Name));
		
		CurrentExclude.PushString(stage.Name);
	}
	
	Holdout_SetNextStage(id, 1, stage);
}

static void Holdout_SetProgressTime(float time, bool hud)
{
	if(!InHoldoutMode)
		return;
	
	delete HoldoutProgressTimer;
	HoldoutProgressTimer = CreateTimer(time, Holdout_ProgressTimer, _, TIMER_FLAG_NO_MAPCHANGE);

	if(hud)
		SpawnTimer(time);
}

public Action Holdout_ProgressTimer(Handle timer)
{
	HoldoutProgressTimer = null;
	Holdout_NextProgress();
	return Plugin_Stop;
}

static void Holdout_MoveFloor(int floorIndex, int stageIndex = -1, bool moveForward = true)
{
	CurrentFloor = floorIndex;
	CurrentCount = stageIndex;
	CurrentStage = -1;
	
	if(CurrentCollection && moveForward)
	{
		ArrayList list = CurrentCollection.Clone();

		Artifact artifact;
		int length = list.Length;
		for(int i; i < length; i++)
		{
			Artifacts.GetArray(list.Get(i), artifact);
			if(artifact.FuncFloorChange != INVALID_FUNCTION)
			{
				Call_StartFunction(null, artifact.FuncFloorChange);
				Call_PushCellRef(CurrentFloor);
				Call_PushCellRef(CurrentCount);
				Call_Finish();
			}
		}

		delete list;
	}
	
	HoldoutInfo floor;
	HoldoutFloors.GetArray(CurrentFloor, floor);
	
	Waves_SetSkyName(floor.Skyname);
	
	strcopy(WhatDifficultySetting, sizeof(WhatDifficultySetting), floor.Name);
	strcopy(WhatDifficultySetting_Internal, sizeof(WhatDifficultySetting_Internal), floor.Name);
	WavesUpdateDifficultyName();
	
	char buffer[64];
	
	SetHudTextParamsEx(-1.0, -1.0, 8.0, {255, 255, 255, 255}, {255, 200, 155, 255}, 2, 0.1, 0.1);
	for(int client = 1; client <= MaxClients; client++)
	{
		if(!b_IsPlayerABot[client] && IsClientInGame(client))
		{
			SetGlobalTransTarget(client);
			ShowHudText(client, -1, "%t", floor.Name);
			Music_Stop_All(client);
		}
	}
	
	FormatEx(buffer, sizeof(buffer), "%s Lore", floor.Name);
	if(TranslationPhraseExists(buffer))
		PrintToChatAll("%t", buffer);
	
	HoldoutGameState = HoldoutState_Waiting;
	Waves_SetReadyStatus(1);
}

static int Holdout_GetStageByName(const HoldoutInfo floor, const char[] name, int type, Stage stage)
{
	ArrayList list;
	switch (type) {
		case 0: list = floor.Fights;
		case 1: list = floor.Encounters;
		case 2: list = floor.Finals;
	}
	
	if(!list)
		list = floor.Fights;
	
	int length = list.Length;
	for(int i; i < length; i++)
	{
		list.GetArray(i, stage);
		if(StrEqual(name, stage.Name, false))
			return i;
	}
	
	return -1;
}

static int Holdout_GetRandomStage(const HoldoutInfo floor, Stage stage, int type, int pos = 0, int maxstages = 0)
{
	ArrayList list;
	switch (type) {
		case 0: list = floor.Fights;
		case 1: list = floor.Encounters;
		case 2: list = floor.Finals;
	}
	
	if(!list)
		list = floor.Fights;
	
	int length = list.Length;
	int rand = GetURandomInt();
	int start = rand % length;
	int i = start;
	
	if(type == 2)
	{
		int choosen = -1;
		do
		{
			if(i >= length)
			{
				i = 0;
				continue;
			}
			
			list.GetArray(i, stage);
			if(stage.ArtifactKey[0])
			{
				if(Rogue_HasNamedArtifact(stage.ArtifactKey) != stage.InverseKey)
					return i;
			}
			else if(choosen == -1)
			{
				choosen = i;
			}

			i++;
		}
		while(i != start);

		if(choosen != -1)
			list.GetArray(choosen, stage);
		
		return choosen;
	}
	else
	{
		do
		{
			if(i >= length)
			{
				i = 0;
				continue;
			}
			
			list.GetArray(i, stage);

			if(stage.ForcePosition != 0)
			{
				if(stage.ForcePosition == pos || (stage.ForcePosition == (pos - maxstages)))
				{
					if(!stage.ArtifactKey[0] || Rogue_HasNamedArtifact(stage.ArtifactKey) != stage.InverseKey)
						return i;
				}
			}

			i++;
		}
		while(i != start);
		
		do
		{
			if(i >= length)
			{
				i = 0;
				continue;
			}
			
			list.GetArray(i, stage);
			
			if(stage.ForcePosition != 0)
			{
				i++;
				continue;
			}
			
			if(Rogue_VoteActive())
			{
				ArrayList voting = Rogue_GetActiveVote();
				if(voting.FindString(stage.Name, Vote::Config) != -1)
				{
					i++;
					continue;
				}
			}
			
			if(stage.ArtifactKey[0] && Rogue_HasNamedArtifact(stage.ArtifactKey) == stage.InverseKey)
			{
				i++;
				continue;
			}
			
			if(!CurrentExclude || CurrentExclude.FindString(stage.Name) == -1)
				return i;
			
			i++;
		}
		while(i != start);
	}

	return -1;
}

// Waves_UpdateMvMStats
bool Holdout_UpdateMvMStats()
{
	if(!Holdout_Mode() || !Holdout_InSetup())
		return false;
	
	int objective = FindEntityByClassname(-1, "tf_objective_resource");
	if(objective != -1)
	{
		SetEntProp(objective, Prop_Send, "m_nMvMWorldMoney", 0);
		SetEntProp(objective, Prop_Send, "m_nMannVsMachineWaveEnemyCount", 0);
		SetEntProp(objective, Prop_Send, "m_nMannVsMachineWaveCount", 0);
		SetEntProp(objective, Prop_Send, "m_nMannVsMachineMaxWaveCount", 0);
		
		for(int i; i < 24; i++)
		{
			switch(i)
			{
				case 0:
				{
					Waves_SetWaveClass(objective, i, CurrentIngots, "rogue_ingots", MVM_CLASS_FLAG_NORMAL, true);
					continue;
				}
			}
			
			Waves_SetWaveClass(objective, i);
		}
	}
	
	Waves_SetCreditAcquired(0);
	return true;
}

// Waves_SetReadyStatus
void Holdout_SetReadyStatus(int status)
{
	switch(status)
	{
		case 0:
		{
			if (HoldoutGameState == HoldoutState_Waiting)
			{
				Holdout_NextProgress();
				return;
			}
		}
	}
}

#include "roguelike/holdout_battles.sp"
#include "roguelike/holdout_encounters.sp"