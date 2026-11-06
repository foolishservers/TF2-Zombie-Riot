#pragma semicolon 1
#pragma newdecls required

/*
// 인카운터 투표 생성 함수 예시
public float Holdout_Encounter_ThreeChoices()
{
	ArrayList list = Rogue_CreateGenericVote(Holdout_Vote_CustomBattle, "Choose your path");
	Vote vote;

	// 선택지 1: 위험한 광산 (웨이브 CFG 직접 지정 + 보상 주괴 15개)
	strcopy(vote.Name, sizeof(vote.Name), "Enter Dangerous Shaft (Hard)");
	strcopy(vote.Desc, sizeof(vote.Desc), "Face high risk for 15 Ingots");
	FormatEx(vote.Config, sizeof(vote.Config), "zombieriot/waves_shaft.cfg;15");
	list.PushArray(vote);

	// 선택지 2: 유적 조사 (KeyValues의 Stage 이름으로 지정 + 보상 주괴 8개)
	strcopy(vote.Name, sizeof(vote.Name), "Investigate Ruins (Normal)");
	strcopy(vote.Desc, sizeof(vote.Desc), "Fight inside ruins for 8 Ingots");
	FormatEx(vote.Config, sizeof(vote.Config), "Ruins Stage;8");
	list.PushArray(vote);

	// 선택지 3: 도망치기 (비전투)
	strcopy(vote.Name, sizeof(vote.Name), "Leave immediately");
	strcopy(vote.Desc, sizeof(vote.Desc), "Avoid combat and move on");
	FormatEx(vote.Config, sizeof(vote.Config), "leave;0");
	list.PushArray(vote);

	Rogue_StartGenericVote(20.0);

	return 25.0; // 투표 대기 시간 25초
}

public void Holdout_Vote_CustomBattle(const Vote vote)
{
	if(!vote.Config[0] || StrContains(vote.Config, "leave", false) != -1)
	{
		CPrintToChatAll("{yellow}[Holdout] 인카운터를 회피하고 진행합니다.");
		delete HoldoutProgressTimer;
		Holdout_SetProgressTime(3.0, false);
		return;
	}

	// vote.Config 파싱: "경로_또는_Stage명;보상주괴"
	char parts[2][PLATFORM_MAX_PATH];
	ExplodeString(vote.Config, ";", parts, sizeof(parts), sizeof(parts[]));

	char target[PLATFORM_MAX_PATH];
	strcopy(target, sizeof(target), parts[0]);

	// 선택지별 지정 주괴가 있으면 설정
	int ingots = parts[1][0] ? StringToInt(parts[1]) : 0;
	if(ingots > 0)
	{
		Holdout_SetBattleIngots(ingots);
	}

	delete HoldoutProgressTimer;

	// 1) .cfg 파일 경로 형태인 경우 지정된 웨이브 파일 로드
	if(StrContains(target, ".cfg", false) != -1 || StrContains(target, "/", false) != -1)
	{
		Holdout_StartWaveByPath(target);
	}
	// 2) Stage 섹션 이름인 경우 현재 Floor의 Stage 목록에서 검색하여 시작
	else
	{
		Floor floor;
		HoldoutFloors.GetArray(CurrentFloor, floor);

		Stage stage;
		bool found = false;

		ArrayList targetList = IsFinalStage ? floor.Finals : floor.Encounters;
		if(targetList)
		{
			int len = targetList.Length;
			for(int i = 0; i < len; i++)
			{
				targetList.GetArray(i, stage);
				if(StrEqual(stage.Name, target, false))
				{
					CurrentStage = i;
					found = true;
					break;
				}
			}
		}

		if(found)
		{
			StartHoldoutStage(stage);
		}
		else
		{
			LogError("[Holdout] Custom encounter stage '%s' not found!", target);
			Holdout_SetProgressTime(3.0, false);
		}
	}
}

// 경로 지정형 웨이브 직접 시작 함수
static void Holdout_StartWaveByPath(const char[] wavePath)
{
	char buffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, wavePath);
	KeyValues kv = new KeyValues("Waves");

	if(kv.ImportFromFile(buffer))
	{
		Waves_SetReadyStatus(0);
		HoldoutGameState = State_Stage;

		Rogue_TriggerFunction(Artifact::FuncStageStart);
		RandomPickup_ResetTimer();
		RemoveAllCustomMusic();

		Waves_SetupWaves(kv, false);
		delete kv;

		CreateTimer(3.0, Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
		WaveStart_SubWaveStart(GetGameTime());
	}
	else
	{
		delete kv;
		LogError("[Holdout] Failed to load encounter wave file: %s", buffer);
		Holdout_SetProgressTime(3.0, false);
	}
}
*/