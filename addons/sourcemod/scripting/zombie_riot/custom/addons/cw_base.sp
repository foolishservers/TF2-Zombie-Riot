/*
잦은 업데이트로 이렇게 기능(상태효과 제외)은 따로 분리함 <<< 적어도 나한텐 관리가 편했음.
만약 *특별한* 기능을 제작할 예정이면

행운을 빕니다.
*/
public void Weapon_AddonsCustom_OnMapStart()
{
	/*초기화*/
	PrecacheSoundCustom("#baka_zr/metal_pipe.mp3");
	MajorSteam_Launcher_OnMapStart();
	LockDown_Wand_MapStart();
	MSword_OnMapStart();
}

public void Weapon_AddonsCustom_Enable(int client, int weapon)
{
	/*로드아웃 새로고침, 아이템 착용시 트리거됨*/
	Enable_MajorSteam_Launcher(client, weapon);
	LockDown_Enable(client, weapon);
	MSword_Enable(client, weapon);
}

void Weapon_AddonsCustomLastMan(int client)
{
	if(client)
	{
		/*에러 제거용*/
	}
	/*lms일때 트리거됨*/
	/*if(Wkit_Omega_LastMann(client))
	{
		CPrintToChatAll("{gold}%N are now alone,however,he won't give up that early...", client);
		Yakuza_Lastman(12);
	}
	if(Sigil_LastMann(client))
	{
		CPrintToChatAll("{blue}Diabolus Ex Machina", client);
		Yakuza_Lastman(13);
	}*/
}

bool Weapon_AddonsStartCustomSoundForLastMan(int client, int WhatSoundPlay)
{
	if(client)
	{
		/*에러 제거용*/
	}
	bool CompleteFailure;
	switch(WhatSoundPlay)
	{
		/*Yakuza_Lastman(번호)는 해당하는 lms브금을 재생 시킴*/
		/*case 12:
		{
			EmitCustomToClient(client, "#zombiesurvival/combinehell/escalationP2.mp3", client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
			SetMusicTimer(client, GetTime() + 195);
		}*/
		default:CompleteFailure=true;
	}
	/*무엇도 해당 안되면 기본 라스맨 브금 재생*/
	return CompleteFailure;
}

void Weapon_AddonsStopCustomSoundForLastMan(int client, int WhatSoundPlay)
{
	if(client)
	{
		/*에러 제거용*/
	}
	/*lms종료되면 트리거됨*/
	switch(WhatSoundPlay)
	{
		//case 12:StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/combinehell/escalationP2.mp3", 2.0);
	}
}

void Weapon_AddonsCustom_WaveEnd()
{
	/*웨이브 끝나면 트리거됨*/
	MajorSteam_Launcher_WaveEnd();
}

void Weapon_AddonsCustom_OnKill(int attacker)
{
	/*처치하면 트리거됨*/
	if(!IsValidEntity(attacker))
		return;
}
