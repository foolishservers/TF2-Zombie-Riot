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

stock void Weapon_AddonsCustomLastMan(int client)
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
	if(IsBarracks(client))
		Barracks_OnLastManStand(client);
}

stock bool Weapon_AddonsStartCustomSoundForLastMan(int client, int WhatSoundPlay)
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
		case 17:
		{
			switch(WhatCiv(client))
			{
				case Almina_Thorns, Almina_Thornless:{
					EmitCustomToClient(client, "#zombiesurvival/iberia/wave_30.mp3",client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.5);
					SetMusicTimer(client, GetTime() + 177);
				}
				case Thorns:{
					EmitCustomToClient(client, "#zombiesurvival/expidonsa_waves/wave_45_music_1.mp3",client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
					SetMusicTimer(client, GetTime() + 279);
				}
				case Combine:{
					EmitCustomToClient(client, "#zombiesurvival/xeno_raid/xeno_shared_bossmusic.mp3",client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
					SetMusicTimer(client, GetTime() + 170);
				}
				case Alternative:{
					EmitCustomToClient(client, "#zombiesurvival/altwaves_and_blitzkrieg/music/wave60_2.mp3",client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 0.6);
					SetMusicTimer(client, GetTime() + 320);
				}
				default:{
					EmitCustomToClient(client, "#zombiesurvival/medieval_raid/kazimierz_boss.mp3",client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.8);
					SetMusicTimer(client, GetTime() + 189);
				}
			}
		}
		default:CompleteFailure=true;
	}
	/*무엇도 해당 안되면 기본 라스맨 브금 재생*/
	return CompleteFailure;
}

stock void Weapon_AddonsStopCustomSoundForLastMan(int client, int WhatSoundPlay)
{
	if(client)
	{
		/*에러 제거용*/
	}
	/*lms종료되면 트리거됨*/
	switch(WhatSoundPlay)
	{
		//case 12:StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/combinehell/escalationP2.mp3", 2.0);
		case 17:
		{
			StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/medieval_raid/kazimierz_boss.mp3", 2.0);
			StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/altwaves_and_blitzkrieg/music/wave60_2.mp3", 2.0);
			StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/iberia/wave_30.mp3", 2.0);
			StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/xeno_raid/xeno_shared_bossmusic.mp3", 2.0);
		}
	}
}

stock bool Weapon_AddonsOverlayForLastMan(int client, int Overlay)
{
	if(client)
	{
		/*에러 제거용*/
	}
	/*lms발동때 화면에 흑백 적용 안할껀지 여부*/
	switch(Overlay)
	{
		//case 12:StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/combinehell/escalationP2.mp3", 2.0);
	}
	return false;
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
