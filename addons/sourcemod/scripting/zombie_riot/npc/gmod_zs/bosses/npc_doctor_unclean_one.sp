#pragma semicolon 1
#pragma newdecls required

static int NPCId;

static char g_HurtSounds[][] =
{
	"cof/purnell/hurt1.mp3",
	"cof/purnell/hurt2.mp3",
	"cof/purnell/hurt3.mp3",
	"cof/purnell/hurt4.mp3"
};

static char g_KillSounds[][] =
{
	"cof/purnell/kill1.mp3",
	"cof/purnell/kill2.mp3",
	"cof/purnell/kill3.mp3",
	"cof/purnell/kill4.mp3"
};

static char g_SummonSounds[][] = {
	"weapons/buff_banner_horn_blue.wav",
	"weapons/buff_banner_horn_red.wav",
};

public void DasNaggenvatcher_OnMapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Das Naggenvatcher Doctor");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_doctor_unclean_one");
	strcopy(data.Icon, sizeof(data.Icon), "expidonsan_doctor");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Raid;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_KillSounds);
	PrecacheSoundArray(g_SummonSounds);
	PrecacheSoundCustom("cof/purnell/death.mp3");
	PrecacheSoundCustom("cof/purnell/intro.mp3");
	PrecacheSoundCustom("cof/purnell/converted.mp3");
	PrecacheSoundCustom("cof/purnell/reload.mp3");
	PrecacheSoundCustom("cof/purnell/shoot.mp3");
	PrecacheSoundCustom("cof/purnell/shove.mp3");
	PrecacheSoundCustom("cof/purnell/meleehit.mp3");
	PrecacheModel("models/player/spy.mdl");
	PrecacheModel("models/player/medic.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return DasNaggenvatcher(vecPos, vecAng, team, data);
}

methodmap DasNaggenvatcher < CClotBody
{
	public void PlayHurtSound()
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		this.m_flNextHurtSound = GetGameTime(this.index) + 1.0;
		EmitCustomToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, 3.0);
	}
	public void PlayDeathSound()
	{
		EmitCustomToAll("cof/purnell/death.mp3", _, _, _, _, 2.0);
	}
	public void PlayIntroSound()
	{
		EmitCustomToAll("cof/purnell/intro.mp3", _, _, _, _, 3.0);
	}
	public void PlayFriendlySound()
	{
		EmitCustomToAll("cof/purnell/converted.mp3", this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 2.0);
	}
	public void PlayReloadSound()
	{
		EmitCustomToAll("cof/purnell/reload.mp3", this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 1.75);
	}
	public void PlayShootSound()
	{
		EmitCustomToAll("cof/purnell/shoot.mp3", this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 2.7);
	}
	public void PlayMeleeSound()
	{
		this.m_flNextHurtSound = GetGameTime(this.index) + 1.0;
		EmitCustomToAll("cof/purnell/shove.mp3", this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 3.0);
	}
	public void PlayHitSound()
	{
		EmitCustomToAll("cof/purnell/meleehit.mp3", this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 3.0);
	}
	public void PlayKillSound()
	{
		this.m_flNextHurtSound = GetGameTime(this.index) + 2.0;
		EmitCustomToAll(g_KillSounds[GetRandomInt(0, sizeof(g_KillSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 3.0);
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
	public void SetActivity(const char[] animation)
	{
		int activity = this.LookupActivity(animation);
		if(activity > 0 && activity != this.m_iState)
		{
			this.m_iState = activity;
			//this.m_bisWalking = false;
			this.StartActivity(activity);
		}
	}
	
	property float m_flMaxDeath
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flReviveDasNaggenvatcherTime
	{
		public get()							{ return fl_GrappleCooldown[this.index]; }
		public set(float TempValueForProperty) 	{ fl_GrappleCooldown[this.index] = TempValueForProperty; }
	}
	property int m_iMyTrueTeam
	{
		public get()		{ return this.m_iMedkitAnnoyance; }
		public set(int value) 	{ this.m_iMedkitAnnoyance = value; }
	}
	property int m_iMaxHP
	{
		public get()							{ return i_AttacksTillMegahit[this.index]; }
		public set(int TempValueForProperty) 	{ i_AttacksTillMegahit[this.index] = TempValueForProperty; }
	}
	property float m_flNPCTalkDelay
	{
		public get()							{ return fl_NextChargeSpecialAttack[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextChargeSpecialAttack[this.index] = TempValueForProperty; }
	}
	
	public DasNaggenvatcher(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		DasNaggenvatcher npc = view_as<DasNaggenvatcher>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.0", "7000000", ally, false, true));
		i_NpcWeight[npc.index] = 4;
		
		SetEntityRenderMode(npc.index, RENDER_NONE);

		npc.m_iState = -1;
		npc.SetActivity("ACT_MP_RUN_SECONDARY");
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/player/medic.mdl");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/jul13_bro_plate/jul13_bro_plate.mdl");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/sbxo2014_medic_wintergarb_coat/sbxo2014_medic_wintergarb_coat.mdl");

		npc.m_iWearable4 = npc.EquipItem("head", "models/player/items/medic/medic_clipboard.mdl");

		npc.m_iWearable5 = npc.EquipItem("head", "models/weapons/c_models/c_ambassador/c_ambassador.mdl");
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		npc.m_iMyTrueTeam=ally;
		npc.m_bThisNpcIsABoss = true;
		npc.m_iTarget = -1;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_bDissapearOnDeath = false;
		i_ClosestAllyCDTarget[npc.index] = 0.0;
		npc.g_TimesSummoned = 0;
		WaveStart_SubWaveStart(GetGameTime() + 1000.0);
		npc.m_iMaxHP = 10000000;
		
		i_SaidLineAlready[npc.index]=0;
		npc.m_bFUCKYOU=false;
		npc.m_flNPCTalkDelay=0.0;
		
		RaidModeTime = GetGameTime(npc.index) + 60.0;
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = true;
		npc.Anger = false;
		RaidModeScaling = float(Waves_GetRoundScale()+1);
		
		static char countext[3][216];
		int count = ExplodeString(data, ";", countext, sizeof(countext), sizeof(countext[]));
		for(int i = 0; i < count; i++)
		{
			if(i>=count)break;
			else if(StrContains(countext[i], "final_item") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "final_item", "");
				npc.m_bGib = true;
				i_RaidGrantExtra[npc.index] = 1557;
			}
			else if(StrContains(countext[i], "maxhp") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "maxhp", "");
				npc.m_iMaxHP = StringToInt(countext[i]);
			}
			else if(StrContains(countext[i], "sc") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "sc", "");
				RaidModeScaling = StringToFloat(countext[i]);
			}
		}
		
		bool ScaleWithHpMore = Waves_GetRoundScale() == 0;
		float multiBoss;
		if(ScaleWithHpMore)
			multiBoss = MultiGlobalHighHealthBoss;
		if(!ScaleWithHpMore)
			multiBoss = MultiGlobalHealthBoss;
		if(!ScaleWithHpMore && Waves_GetRoundScale() > 0)
		{
			multiBoss *= MultiGlobalEnemyBoss;
			count = RoundToNearest(float(Waves_GetRoundScale()) * MultiGlobalEnemyBoss);
			
			if(count < 1)
				count = 1;
			
			if(count > 250)
				count = 250;
			
			float decrease = count / float(Waves_GetRoundScale());
			if(decrease > 1.0)
			{
				multiBoss /= decrease;
			}
		}
		int Tempomary_Health = RoundToNearest(float(npc.m_iMaxHP) * multiBoss);
		npc.m_iMaxHP=Tempomary_Health;
		
		if(RaidModeScaling < 35)
		{
			RaidModeScaling *= 0.25; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.5;
		}
		
		float amount_of_people = ZRStocks_PlayerScalingDynamic();
		
		if(amount_of_people > 12.0)
			amount_of_people = 12.0;
		
		amount_of_people *= 0.12;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;
			
		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		
		npc.m_flNextRangedAttack = 0.0;
		npc.m_iAttacksTillReload = 5;
		npc.m_flReloadDelay = GetGameTime(npc.index) + 0.8;
		
		npc.m_flNextRangedSpecialAttack = 0.0;

		func_NPCDeath[npc.index] = DasNaggenvatcher_NPCDeath;
		func_NPCThink[npc.index] = DasNaggenvatcher_ClotThink;
		func_NPCOnTakeDamage[npc.index] = DasNaggenvatcher_OnTakeDamage;
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, DasNaggenvatcher_OnTakeDamagePost);
		
		if(ally == TFTeam_Red)
			npc.PlayFriendlySound();
		else
		{
			npc.PlayIntroSound();
			EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
			EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
			for(int client_check=1; client_check<=MaxClients; client_check++)
			{
				if(IsClientInGame(client_check) && !IsFakeClient(client_check))
				{
					LookAtTarget(client_check, npc.index);
					SetGlobalTransTarget(client_check);
					ShowGameText(client_check, "voice_player", 1, "%t", "DasNaggenvatcher Spawned");
					UTIL_ScreenFade(client_check, 180, 1, FFADE_OUT, 0, 0, 0, 255);
				}
			}
		}
		return npc;
	}
}

static void DasNaggenvatcher_Wait(int iNPC)
{
	DasNaggenvatcher npc = view_as<DasNaggenvatcher>(iNPC);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	b_NpcIsInvulnerable[npc.index] = true;

	if(npc.m_bFUCKYOU)
	{
		npc.m_flNextThinkTime = 0.0;
		npc.StopPathing();
		
		npc.m_bisWalking = false;
		npc.SetActivity("ACT_MP_CROUCH_MELEE");
		if(gameTime > npc.m_flNPCTalkDelay)
		{
			if(i_RaidGrantExtra[npc.index] == 1557)
			{
				npc.m_bGib = true;
				float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
				int spawn_index = NPC_CreateByName("npc_zs_unspeakable", npc.index, VecSelfNpc, {0.0,0.0,0.0}, npc.m_iMyTrueTeam, "sc40;final_item");
				if(spawn_index > MaxClients)
				{
					NpcAddedToZombiesLeftCurrently(spawn_index, true);
					SetEntProp(spawn_index, Prop_Data, "m_iHealth", npc.m_iMaxHP);
					SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", npc.m_iMaxHP);
					fl_Extra_MeleeArmor[spawn_index] = fl_Extra_MeleeArmor[npc.index];
					fl_Extra_RangedArmor[spawn_index] = fl_Extra_RangedArmor[npc.index];
					fl_Extra_Speed[spawn_index] = fl_Extra_Speed[npc.index];
					fl_Extra_Damage[spawn_index] = fl_Extra_Damage[npc.index];
					IncreaseEntityDamageTakenBy(spawn_index, 0.000001, 9.5);
				}
			}
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
			npc.m_bDissapearOnDeath = true;
			SpawnMoney(npc.index, true);
			npc.PlayDeathSound();
		}
		else if(gameTime + 4.0 > npc.m_flNPCTalkDelay && i_SaidLineAlready[npc.index] < 9)
		{
			i_SaidLineAlready[npc.index] = 9;
			PrintNPCMessageWithPrefixes(npc.index, "crimson", "CaptainQuetz_Propaganda_9", true);
		}
		else if(gameTime + 8.0 > npc.m_flNPCTalkDelay && i_SaidLineAlready[npc.index] < 8)
		{
			i_SaidLineAlready[npc.index] = 8;
			PrintNPCMessageWithPrefixes(npc.index, "crimson", "CaptainQuetz_Propaganda_8", true);
		}
		else if(gameTime + 12.0 > npc.m_flNPCTalkDelay && i_SaidLineAlready[npc.index] < 7)
		{
			i_SaidLineAlready[npc.index] = 7;
			PrintNPCMessageWithPrefixes(npc.index, "crimson", "CaptainQuetz_Propaganda_7", true);
		}
		else if(gameTime + 16.0 > npc.m_flNPCTalkDelay && i_SaidLineAlready[npc.index] < 6)
		{
			i_SaidLineAlready[npc.index] = 6;
			PrintNPCMessageWithPrefixes(npc.index, "crimson", "CaptainQuetz_Propaganda_6", true);
		}
		else if(gameTime + 20.0 > npc.m_flNPCTalkDelay && i_SaidLineAlready[npc.index] < 5)
		{
			i_SaidLineAlready[npc.index] = 5;
			PrintNPCMessageWithPrefixes(npc.index, "crimson", "CaptainQuetz_Propaganda_5", true);
		}
		else if(gameTime + 24.0 > npc.m_flNPCTalkDelay && i_SaidLineAlready[npc.index] < 4)
		{
			i_SaidLineAlready[npc.index] = 4;
			PrintNPCMessageWithPrefixes(npc.index, "crimson", "CaptainQuetz_Propaganda_4", true);
		}
		else if(gameTime + 28.0 > npc.m_flNPCTalkDelay && i_SaidLineAlready[npc.index] < 3)
		{
			i_SaidLineAlready[npc.index] = 3;
			PrintNPCMessageWithPrefixes(npc.index, "crimson", "CaptainQuetz_Propaganda_3", true);
		}
		else if(gameTime + 32.0 > npc.m_flNPCTalkDelay && i_SaidLineAlready[npc.index] < 2)
		{
			i_SaidLineAlready[npc.index] = 2;
			PrintNPCMessageWithPrefixes(npc.index, "crimson", "CaptainQuetz_Propaganda_2", true);
		}
		else if(gameTime + 36.0 > npc.m_flNPCTalkDelay && i_SaidLineAlready[npc.index] < 1)
		{
			i_SaidLineAlready[npc.index] = 1;
			PrintNPCMessageWithPrefixes(npc.index, "crimson", "CaptainQuetz_Propaganda_1", true);
		}
	}
}

static void DasNaggenvatcher_ClotThink(int iNPC)
{
	DasNaggenvatcher npc = view_as<DasNaggenvatcher>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.04;
	npc.Update();
	
	if(npc.m_flNextRangedSpecialAttack < gameTime)
	{
		npc.m_flNextRangedSpecialAttack = gameTime + 0.25;
		// 250.0*250.0 = 62500.0
		int target = GetClosestAlly(npc.index, 62500.0, _,DasNaggenvatcherBuffAlly);
		if(target && !HasSpecificBuff(target, "False Therapy"))
		{
			VausMagicaGiveShield(target, 20, true, 20);
			ApplyStatusEffect(npc.index, target, "False Therapy", 30.0);
			npc.AddGesture("ACT_MP_GESTURE_VC_FISTPUMP_SECONDARY",_,_,_,3.0);
		}
	}
	
	if(npc.m_iTarget > 0 && !IsValidEnemy(npc.index, npc.m_iTarget))
	{
		if(npc.m_iTarget <= MaxClients)
			npc.PlayKillSound();
		
		npc.m_iTarget = 0;
		npc.m_flGetClosestTargetTime = 0.0;
	}

	if(!IsValidAlly(npc.index, npc.m_iTargetAlly))
	{
		if(i_ClosestAllyCDTarget[npc.index] < gameTime)
		{
			npc.m_iTargetAlly = GetClosestAlly(npc.index, _, _,DasNaggenvatcherBuffAlly);
			i_ClosestAllyCDTarget[npc.index] = gameTime + 1.0;
		}
	}
	else
	{
		i_ClosestAllyCDTarget[npc.index] = gameTime + 0.0;
	}

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_flGetClosestTargetTime = gameTime + 0.5;
		npc.m_iTarget = GetClosestTarget(npc.index, true);
	}
	if(IsValidAlly(npc.index, npc.m_iTargetAlly) && IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTargetally[3]; WorldSpaceCenter(npc.m_iTargetAlly, vecTargetally);
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float vecPos[3]; WorldSpaceCenter(npc.index, vecPos);
		
		float distanceToAlly = GetVectorDistance(vecTargetally, vecPos, true);
		float distanceToEnemy = GetVectorDistance(vecTarget, vecTargetally, true);
		if(distanceToAlly > (140.0 * 140.0) && npc.m_iTargetWalkTo < (50.0 * 50.0)) //get close to ally but not too close
		{
			npc.m_iTargetWalkTo = npc.m_iTargetAlly;
		}
		else
		{
			if(distanceToEnemy < (200.0 * 200.0)) //enemy is too close to friend, follow enemy
			{
				npc.m_iTargetWalkTo = npc.m_iTargetAlly;
			}
		}
	}
	else
	{
		npc.m_iTargetWalkTo = npc.m_iTarget;
	}
	
	int behavior = -1;
	
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			npc.m_iAttacksTillReload++;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				Handle swingTrace;
				float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if(target > 0) 
					{
						float damage = 50.0;
						damage *= RaidModeScaling;
						if(ShouldNpcDealBonusDamage(target))
							damage *= 3.0;
						else
							CaptainQuetz_DebuffApply(npc.index, target);
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);

						Custom_Knockback(npc.index, target, 500.0);
						SensalCauseKnockback(npc.index, target, (600.0 / 900.0), false);
						npc.m_iAttacksTillReload++;
						npc.PlayHitSound();
					}
				}
				delete swingTrace;
			}
		}
		
		behavior = 0;
	}
	
	if(behavior == -1)
	{
		if(npc.m_iTarget > 0 && npc.m_iTargetWalkTo > 0)	// We have a target
		{
			float vecPos[3]; WorldSpaceCenter(npc.index, vecPos );
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
			
			float distance = GetVectorDistance(vecTarget, vecPos, true);
			if(distance < 10000.0 && npc.m_flNextMeleeAttack < gameTime)	// Close at any time: Melee
			{
				npc.FaceTowards(vecTarget, 15000.0);
				
				npc.AddGesture("ACT_MP_THROW");
				npc.PlayMeleeSound();
				
				npc.m_flAttackHappens = gameTime + 0.3;
				npc.m_flReloadDelay = gameTime + 0.6;
				npc.m_flNextMeleeAttack = gameTime + 1.0;
				
				behavior = 0;
			}
			else if(npc.m_flReloadDelay > gameTime)	// Reloading
			{
				behavior = 0;
			}
			else if(distance < 80000.0)	// In shooting range
			{
				if(npc.m_flNextRangedAttack < gameTime)	// Not in attack cooldown
				{
					if(npc.m_iAttacksTillReload > 0)	// Has ammo
					{
						int Enemy_I_See;
				
						Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
						//Target close enough to hit
						if(IsValidEnemy(npc.index, npc.m_iTarget) && npc.m_iTarget == Enemy_I_See)
						{
							behavior = 0;
							npc.SetActivity("ACT_MP_STAND_SECONDARY");
							
							npc.FaceTowards(vecTarget, 15000.0);
							
							npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
							
							npc.m_flNextRangedAttack = gameTime + 1.0;
							npc.m_iAttacksTillReload--;
							
							PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 700.0, _,vecTarget);
							float damage = 50.0;
							damage *= 0.9;
							damage *= RaidModeScaling;
							int RocketGet = npc.FireRocket(vecTarget, damage, 700.0, "models/weapons/w_bullet.mdl", 2.0);
							if(IsValidEntity(RocketGet))
								SDKHook(RocketGet, SDKHook_StartTouch, HEGrenade_StartTouch);
							
							npc.PlayShootSound();
						}
						else	// Something in the way, move closer
						{
							behavior = 1;
						}
					}
					else	// No ammo, retreat
					{
						behavior = 3;
					}
				}
				else	// In attack cooldown
				{
					behavior = 0;
					npc.SetActivity("ACT_MP_STAND_SECONDARY");
				}
			}
			else if(npc.m_iAttacksTillReload < 0)	// Take the time to reload
			{
				//Only if low ammo, otherwise it can be abused.
				behavior = 4;
			}
			else	// Sprint Time
			{
				behavior = 2;
			}
		}
		else if(npc.m_flReloadDelay > gameTime)	// Reloading...
		{
			behavior = 0;
		}
		else if(npc.m_iAttacksTillReload < 5)	// Nobody here..?
		{
			behavior = 4;
		}
		else	// What do I do...
		{
			behavior = 0;
		}
	}
	
	// Reload anyways if we can't run
	if(npc.m_flRangedSpecialDelay && behavior == 3 && npc.m_flRangedSpecialDelay > gameTime)
		behavior = 4;
	
	switch(behavior)
	{
		case 0:	// Stand
		{
			// Activity handled above
			npc.m_flSpeed = 0.0;
			
			if(npc.m_bPathing)
			{
				npc.StopPathing();
				
			}
		}
		case 1:	// Move After the Player
		{
			npc.SetActivity("ACT_MP_RUN_SECONDARY");
			npc.m_flSpeed = 200.0;
			npc.m_flRangedSpecialDelay = 0.0;
			
			npc.SetGoalEntity(npc.m_iTargetWalkTo);
			if(!npc.m_bPathing)
				npc.StartPathing();
		}
		case 2:	// Sprint After the Player
		{
			npc.SetActivity("ACT_MP_RUN_SECONDARY");
			npc.m_flSpeed = 250.0;
			npc.m_flRangedSpecialDelay = 0.0;
			
			npc.SetGoalEntity(npc.m_iTargetWalkTo);
			if(!npc.m_bPathing)
				npc.StartPathing();
		}
		case 3:	// Retreat
		{
			npc.m_flSpeed = 500.0;
			
			if(!npc.m_flRangedSpecialDelay)	// Reload anyways timer
				npc.m_flRangedSpecialDelay = gameTime + 4.0;
			
			float vBackoffPos[3]; BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTargetWalkTo,_,vBackoffPos);
			npc.SetGoalVector(vBackoffPos);
			
			if(!npc.m_bPathing)
				npc.StartPathing();
		}
		case 4:	// Reload
		{
			npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY",_,_,_,0.25);
			npc.m_flSpeed = 0.0;
			npc.m_flRangedSpecialDelay = 0.0;
			npc.m_flReloadDelay = gameTime + 4.25;
			npc.m_iAttacksTillReload = 5;
			
			if(npc.m_bPathing)
			{
				npc.StopPathing();
				
			}
			
			npc.PlayReloadSound();
		}
	}
	if(GetTeam(npc.index) != TFTeam_Red && LastMann)
	{
		if(!npc.m_fbGunout)
		{
			npc.m_fbGunout = true;
			RaidModeTime += 10.0;
			switch(GetRandomInt(0,3))
			{
				case 0: PrintNPCMessageWithPrefixes(npc.index, "crimson", "CaptainQuetz_LastMann_1", true);
				case 1: PrintNPCMessageWithPrefixes(npc.index, "crimson", "CaptainQuetz_LastMann_2", true);
				case 2: PrintNPCMessageWithPrefixes(npc.index, "crimson", "CaptainQuetz_LastMann_3", true);
				case 3: PrintNPCMessageWithPrefixes(npc.index, "crimson", "CaptainQuetz_LastMann_4", true);
			}
		}
	}
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	if(npc.m_flDoingSpecial < gameTime)
	{
		npc.m_flRangedArmor = 1.0;
		npc.m_flMeleeArmor = 1.25;
	}
	else
	{
		npc.m_flRangedArmor = 0.5;
		npc.m_flMeleeArmor = 0.65;
	}
	if(npc.g_TimesSummoned == 4)
	{
		bool allyAlive = false;
		for(int targ; targ<i_MaxcountNpcTotal; targ++)
		{
			int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
			if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index] && i_NpcInternalId[baseboss_index] != NPCId && GetTeam(npc.index) == GetTeam(baseboss_index))
			{
				allyAlive = true;
			}
		}
		if(!Waves_IsEmpty())
			allyAlive = true;

		if(GetTeam(npc.index) == TFTeam_Red)
			allyAlive = false;

		if(allyAlive)
		{
			b_NpcIsInvulnerable[npc.index] = true;
		}
		else
		{
			if(!npc.Anger)
			{
				if(i_RaidGrantExtra[npc.index] == 1557)
					DasNaggenvatcherSayWords(npc.index, true);
				npc.Anger = true;
				b_NpcIsInvulnerable[npc.index] = false;
			}
		}
	}
	if(!npc.m_flMaxDeath && RaidModeTime < GetGameTime())
	{
		npc.m_flMaxDeath = 1.0;
		ForcePlayerLoss();
		RaidBossActive = INVALID_ENT_REFERENCE;
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		switch(GetRandomInt(0,3))
		{
			case 0: PrintNPCMessageWithPrefixes(npc.index, "crimson", "CaptainQuetz_Death_1", true);
			case 1: PrintNPCMessageWithPrefixes(npc.index, "crimson", "CaptainQuetz_Death_2", true);
			case 2: PrintNPCMessageWithPrefixes(npc.index, "crimson", "CaptainQuetz_Death_3", true);
			case 3: PrintNPCMessageWithPrefixes(npc.index, "crimson", "Castellan_Talk_Lastman-1", true);
		}
		
		return;
	}
}

static Action DasNaggenvatcher_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	DasNaggenvatcher npc = view_as<DasNaggenvatcher>(victim);
	if(npc.m_flReviveDasNaggenvatcherTime > GetGameTime(npc.index))
	{
		damage = 0.0;
		return Plugin_Handled;
	}
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	if(i_RaidGrantExtra[victim] >= 1557)
	{
		if(!npc.Anger)
		{
			int health = GetEntProp(victim, Prop_Data, "m_iHealth") - RoundToCeil(damage);
			if(health < 1)
			{
				SetEntProp(victim, Prop_Data, "m_iHealth", 1);
				damage = 0.0;
				return Plugin_Handled;
			}
		}
		if(npc.Anger && RoundToCeil(damage) >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))
		{
			if(!npc.m_bFUCKYOU)
			{
				b_NpcIsInvulnerable[npc.index] = true;
				b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true;
				npc.m_bFUCKYOU=true;
				npc.m_bThisNpcIsABoss = false;
				RemoveNpcFromEnemyList(npc.index);
				if(EntRefToEntIndex(RaidBossActive)==npc.index)
					RaidBossActive = INVALID_ENT_REFERENCE;
				npc.m_flNPCTalkDelay = GetGameTime(npc.index) + 40.0;
				RaidModeTime += 120.0;
				SetEntProp(npc.index, Prop_Data, "m_iHealth", 1);
				damage = 0.0;
				func_NPCThink[npc.index] = DasNaggenvatcher_Wait;
				
				GiveOneRevive(false);
				Music_EndLastmann(true);
				LastMann = false;
				applied_lastmann_buffs_once = false;

				for(int i=0 ; i < MaxClients ; i++)
				{
					if(IsValidClient(i) && IsClientInGame(i) && IsPlayerAlive(i) && TeutonType[i] == TEUTON_NONE && dieingstate[i] == 0)
					{
						SDKHooks_UpdateMarkForDeath(i, true);
						SDKHooks_UpdateMarkForDeath(i, false);
						TF2_AddCondition(i, TFCond_SpeedBuffAlly, 2.0);
						int maxhealth = SDKCall_GetMaxHealth(i);
						if(GetClientHealth(i)<maxhealth)
							SetEntityHealth(i, maxhealth);
						GiveArmorViaPercentage(i, 0.5, 1.0);
						SetGlobalTransTarget(i);
						GiveCompleteInvul(i, 3.5);
					}
				}
				return Plugin_Handled;
			}
		}
	}
	else if(!npc.Anger)
	{
		int health = GetEntProp(victim, Prop_Data, "m_iHealth") - RoundToCeil(damage);
		if(health < 1)
		{
			SetEntProp(victim, Prop_Data, "m_iHealth", 1);
			damage = 0.0;
			return Plugin_Handled;
		}
	}
	return Plugin_Changed;
}
public void DasNaggenvatcher_OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	DasNaggenvatcher npc = view_as<DasNaggenvatcher>(victim);
	float maxhealth = float(ReturnEntityMaxHealth(npc.index));
	float health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
	float Ratio = health / maxhealth;
	if(Ratio <= 0.85 && npc.g_TimesSummoned < 1)
	{
		npc.g_TimesSummoned = 1;
		npc.PlaySummonSound();
		npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
		RaidModeTime += 80.0;
		
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_zombie_soldier_pickaxe",40000, RoundToCeil(6.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_zombie_soldier",30000, RoundToCeil(6.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_zombie_demoknight",25000, RoundToCeil(6.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_zombie_heavy",30000, RoundToCeil(4.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_zombie_engineer",20000, RoundToCeil(4.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_kamikaze_demo",3000, RoundToCeil(6.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_huntsman",20000, RoundToCeil(4.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_infected_tomislav_main",20000, RoundToCeil(4.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_zombie_sniper_jarate",20000, RoundToCeil(2.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_random_zombie", RoundToCeil(100000.0 * MultiGlobalHighHealthBoss), 1);
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_nightmare", RoundToCeil(300000.0 * MultiGlobalHighHealthBoss), 1);
	}
	else if(Ratio <= 0.55 && npc.g_TimesSummoned < 2)
	{
		npc.g_TimesSummoned = 2;
		npc.PlaySummonSound();
		npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
		RaidModeTime += 80.0;
		
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_eradicator",70000, RoundToCeil(6.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_vile_poisonheadcrab_zombie",80000, RoundToCeil(6.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_fastheadcrab_zombie",30000, RoundToCeil(6.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_vile_bloated_zombie",50000, RoundToCeil(6.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_gore_blaster",30000, RoundToCeil(6.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_runner",30000, RoundToCeil(6.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_random_zombie", RoundToCeil(100000.0 * MultiGlobalHighHealthBoss), 1);
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_pregnant", RoundToCeil(300000.0 * MultiGlobalHighHealthBoss), 1);
	}
	else if(Ratio <= 0.35 && npc.g_TimesSummoned < 3)
	{
		npc.g_TimesSummoned = 3;
		npc.PlaySummonSound();
		npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
		RaidModeTime += 80.0;
		
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_ihbc",45000, RoundToCeil(5.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_firefighter",50000, RoundToCeil(5.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_zombie_breadmonster",50000, RoundToCeil(5.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_zombie_fatscout",60000, RoundToCeil(5.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_zombie_fatspy",50000, RoundToCeil(2.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_sniper",20000, RoundToCeil(2.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_cleaner",50000, RoundToCeil(2.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_ninja_zombie_spy",65, RoundToCeil(2.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_malfunctioning_heavy", RoundToCeil(300000.0 * MultiGlobalHighHealthBoss), 1);
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_sphynx", RoundToCeil(300000.0 * MultiGlobalHighHealthBoss), 1);
	}
	else if(Ratio <= 0.20 && npc.g_TimesSummoned < 4)
	{
		SetEntProp(npc.index, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index) / 4);
		DasNaggenvatcherSayWords(npc.index);
		npc.g_TimesSummoned = 4;
		npc.PlaySummonSound();
		RaidModeTime += 120.0;
		
		npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_sniper",20000, RoundToCeil(2.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_mlsm",50000, RoundToCeil(3.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_sam",40000, RoundToCeil(3.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_medic_main",40000, RoundToCeil(6.0 * MultiGlobalEnemy));
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_major_vulture",RoundToCeil(300000.0 * MultiGlobalHighHealthBoss), 1);
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_soldier_barrager", RoundToCeil(300000.0 * MultiGlobalHighHealthBoss), 1, true);
		DasNaggenvatcherSpawnEnemy(npc.index,"npc_zs_flesh_creeper", RoundToCeil(300000.0 * MultiGlobalHighHealthBoss), 1, true);
	}			
}

static void DasNaggenvatcherSpawnEnemy(int dasnaggenvatcher, char[] plugin_name, int health = 0, int count, bool is_a_boss = false)
{
	if(GetTeam(dasnaggenvatcher) == TFTeam_Red)
	{
		count /= 2;
		if(count < 1)
		{
			count = 1;
		}
		for(int Spawns; Spawns <= count; Spawns++)
		{
			float pos[3]; GetEntPropVector(dasnaggenvatcher, Prop_Data, "m_vecAbsOrigin", pos);
			float ang[3]; GetEntPropVector(dasnaggenvatcher, Prop_Data, "m_angRotation", ang);
			
			int summon = NPC_CreateByName(plugin_name, -1, pos, ang, GetTeam(dasnaggenvatcher));
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
	enemy.Team = GetTeam(dasnaggenvatcher);
	
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

static void DasNaggenvatcherSayWords(int entity, bool ImAngry=false)
{
	if(ImAngry)
	{
		switch(GetRandomInt(0,3))
		{
			case 0: PrintNPCMessageWithPrefixes(entity, "crimson", "CaptainQuetz_LastMann_2", true);
			case 1: PrintNPCMessageWithPrefixes(entity, "crimson", "CaptainQuetz_BattleCry_1", true);
			case 2: PrintNPCMessageWithPrefixes(entity, "crimson", "CaptainQuetz_BattleCry_2", true);
			case 3: PrintNPCMessageWithPrefixes(entity, "crimson", "CaptainQuetz_BattleCry_3", true);
		}
	}
	else
	{
		switch(GetRandomInt(0,3))
		{
			case 0: PrintNPCMessageWithPrefixes(entity, "crimson", "CaptainQuetz_BattleCry_4", true);
			case 1: PrintNPCMessageWithPrefixes(entity, "crimson", "Castellan_Talk_Ability2-3", true);
			case 2: PrintNPCMessageWithPrefixes(entity, "crimson", "CaptainQuetz_BattleCry_5", true);
			case 3: PrintNPCMessageWithPrefixes(entity, "crimson", "CaptainQuetz_BattleCry_6", true);
		}
	}
}

static void DasNaggenvatcher_NPCDeath(int entity)
{
	DasNaggenvatcher npc = view_as<DasNaggenvatcher>(entity);
	npc.SetModel("models/player/medic.mdl");
	SetEntityRenderColor(npc.index, 255, 255, 255, 255);

	for(int i = 1; i < MAXENTITIES; i++)
	{
		if(!IsValidEntity(i) || !b_IsAProjectile[i])
			continue;
		if(GetEntPropEnt(i, Prop_Send, "m_hOwnerEntity") != entity)
			continue;
		RemoveEntity(i);
	}
	
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
	npc.PlayDeathSound();
}

static bool DasNaggenvatcherBuffAlly(int provider, int entity)
{
	if(HasSpecificBuff(entity, "False Therapy"))
		return false;
	return true;
}

static PurnellBuff PurnellDebuffs[] =
{
	{ "Icy Dereliction", "-res, -spd" },
	{ "Raiding Dereliction", "-res" },
	{ "Degrading Dereliction", "-dmg" },
	{ "Zero Therapy", "-res, -spd" },
	{ "Debt-Causing Dereliction", "-res" },
	{ "Headache-Inducing Dereliction", "-res" },
	{ "Shocking Dereliction", "-res, -spd" },
	{ "Therapist's Aura", "--spd" },
	{ "Electric Dereliction", "-res, -spd" },
	{ "Caffeinated Dereliction", "-res" },
};

static void CaptainQuetz_DebuffApply(int entity, int target)
{
	char buff[64];
	int buffId = GetURandomInt() % 10;
	strcopy(buff, sizeof(buff), PurnellDebuffs[buffId].buffName);
	
	ApplyStatusEffect(entity, target, buff, 10.0);
	ApplyStatusEffect(entity, target, "Therapy Duration", 10.0);
}

static void HEGrenade_StartTouch(int entity, int target)
{
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(owner))
		owner = -1;
	int inflictor = h_ArrowInflictorRef[entity];
	if(inflictor != -1)
		inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);

	if(inflictor == -1)
		inflictor = owner;
	
	float ProjectileLoc[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
	Explode_Logic_Custom(0.0, owner, inflictor, -1, ProjectileLoc, EXPLOSION_RADIUS, _, _, true, _, false, _, HEGrenade);
}

static void HEGrenade(int entity, int victim, float damage, int weapon)
{
	if(IsValidEntity(entity) && GetTeam(entity) != GetTeam(victim))
	{
		if(!ShouldNpcDealBonusDamage(victim))
		{
			int flagsStun = 0;
			if(Rogue_Paradox_RedMoon())
				flagsStun |= TF_STUNFLAGS_LOSERSTATE;
			if(!HasSpecificBuff(victim, "Fluid Movement"))
				flagsStun |= TF_STUNFLAG_SLOWDOWN;
			if(victim <= MaxClients)
				TF2_StunPlayer(victim, 0.6, 0.9, flagsStun);
		}
	}
}