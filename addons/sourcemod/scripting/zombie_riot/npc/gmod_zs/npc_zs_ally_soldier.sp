#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/soldier_paincrticialdeath01.mp3",
	"vo/soldier_paincrticialdeath02.mp3",
	"vo/soldier_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/soldier_painsharp01.mp3",
	"vo/soldier_painsharp02.mp3",
	"vo/soldier_painsharp03.mp3",
	"vo/soldier_painsharp04.mp3",
	"vo/soldier_painsharp05.mp3",
	"vo/soldier_painsharp06.mp3",
	"vo/soldier_painsharp07.mp3",
	"vo/soldier_painsharp08.mp3",
};

static const char g_IdleSounds[][] = {
	"vo/taunts/soldier_taunts01.mp3",
	"vo/taunts/soldier_taunts09.mp3",
	"vo/taunts/soldier_taunts14.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/soldier_taunts19.mp3",
	"vo/taunts/soldier_taunts20.mp3",
	"vo/taunts/soldier_taunts21.mp3",
	"vo/taunts/soldier_taunts18.mp3",
};

static const char g_SelfRevive[][] = {
	"mvm/mvm_bought_in.wav",
};

static const char g_RangeAttackSounds[] = "weapons/rocket_shoot.wav";

void Allysoldier_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_SelfRevive)); i++) { PrecacheSound(g_SelfRevive[i]); }
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "ZS Kranz");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_ally_soldier");
	strcopy(data.Icon, sizeof(data.Icon), "soldier");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_GmodZS;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSound(g_RangeAttackSounds);
	PrecacheModel("models/player/soldier.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Allysoldier(vecPos, vecAng, team);
}

methodmap Allysoldier < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(NORMAL_ZOMBIE_SOUNDLEVEL, 100));
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(NORMAL_ZOMBIE_SOUNDLEVEL, 100));
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(NORMAL_ZOMBIE_SOUNDLEVEL, 100));
	}
	
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(NORMAL_ZOMBIE_SOUNDLEVEL, 100));
	}
	
	public void PlayRangeSound() {
		EmitSoundToAll(g_RangeAttackSounds, this.index, SNDCHAN_STATIC, 80, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(NORMAL_ZOMBIE_SOUNDLEVEL, 100));
	}
	public void PlaySelfRevive() 
	{
		EmitSoundToAll(g_SelfRevive[GetRandomInt(0, sizeof(g_SelfRevive) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 60);
	}
	property float m_flSelfRevival
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
	}
	property float m_flWasIdleState
	{
		public get()							{ return fl_AbilityOrAttack[this.index][7]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][7] = TempValueForProperty; }
	}
	property float m_flNextGroupHeal
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	
	public Allysoldier(float vecPos[3], float vecAng[3], int ally)
	{
		Allysoldier npc = view_as<Allysoldier>(CClotBody(vecPos, vecAng, "models/player/soldier.mdl", "1.0", "2000", ally, false, true));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = Allysoldier_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Allysoldier_OnTakeDamage;
		func_NPCThink[npc.index] = Allysoldier_ClotThink;		
		
		// IDLE
		npc.m_flSpeed = 330.0;
		npc.m_iMaxAmmo = 1;
		npc.m_iAmmo = 1;
		npc.m_bScalesWithWaves = false;
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
		SetVariantColor(view_as<int>({255, 0, 0, 0}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		
		float wave = float(Waves_GetRoundScale()+1); //Wave scaling
		
		wave *= 0.5;

		npc.m_flWaveScale = wave;
		
		int skin = 0;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_russian_riot/c_russian_riot.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/xms2013_soviet_stache/xms2013_soviet_stache_soldier.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_buffpack/c_buffpack.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/weapons/c_models/c_buffbanner/c_buffbanner.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/soldier/spr17_flakcatcher/spr17_flakcatcher.mdl");
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/all_class/fall17_jungle_ops/fall17_jungle_ops_soldier.mdl");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 0);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 0);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 0);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 0);
		
		b_ShowNpcHealthbar[npc.index] = true;
		
		return npc;
	}
}

#define ALLYSOLDIER_RANGE 350.0

static void Allysoldier_ClotThink(int iNPC)
{
	Allysoldier npc = view_as<Allysoldier>(iNPC);
	SetEntProp(npc.index, Prop_Send, "m_nBody", GetEntProp(npc.index, Prop_Send, "m_nBody"));
	
	float GameTime = GetGameTime(npc.index);

	// 다운(Stun/SelfRevive) 상태 처리
	if(npc.m_flWasIdleState > 0.0)
	{
		npc.StopPathing();
		if(npc.m_flSelfRevival > 0.0 && GameTime >= npc.m_flSelfRevival)
		{
			npc.PlaySelfRevive();
			SetDownedState_Allysoldier(iNPC, false);
		}
		return;
	}

	if(npc.m_flNextRangedAttackHappening < GetGameTime())
	{
		npc.m_flNextRangedAttackHappening = GetGameTime() + 4;
		DesertYadeamDoHealEffect(npc.index, 200.0);
	}
	if(npc.m_flNextDelayTime > GameTime)
		return;
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	if(npc.m_flNextThinkTime > GameTime)
		return;
	npc.m_flNextThinkTime = GameTime + 0.1;
	
	float VecSelfNpcabs[3]; 
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecSelfNpcabs);
	Allysoldier_ApplyBuffInLocation_Optimized(VecSelfNpcabs, GetTeam(npc.index), npc.index);

	// 1. 적 타겟 유효성 검사 및 탐색
	if(!npc.m_iTarget || !IsValidEnemy(npc.index, npc.m_iTarget) || npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GameTime + 1.0;
	}

	// 2. 아군 타겟 유효성 검사 및 가장 가까운 아군 거리 계산
	if(npc.m_iTargetAlly && !IsValidAlly(npc.index, npc.m_iTargetAlly))
		npc.m_iTargetAlly = 0;
	
	npc.m_iTargetAlly = GetClosestAlly(npc.index);
	float flDistanceToAlly = 999999.0;
	if(npc.m_iTargetAlly > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetAlly, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		flDistanceToAlly = GetVectorDistance(vecTarget, VecSelfNpc, true);
	}

	float flDistanceToEnemy = 999999.0;
	if(npc.m_iTarget > 0 && IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, vecEnemy);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		flDistanceToEnemy = GetVectorDistance(vecEnemy, VecSelfNpc, true);
	}

	// [핵심 로직] 주변 아군이 너무 멀리 있다면(예: 600유닛 이상, 제곱 거리 기준 360000.0) 공격을 멈추고 아군을 추적
	// 기준 거리: 600.0 유닛 (600.0 * 600.0 = 360000.0)
	bool bHasAllyNearby = (npc.m_iTargetAlly > 0 && flDistanceToAlly <= (600.0 * 600.0));

	if(!bHasAllyNearby && npc.m_iTargetAlly > 0)
	{
		// 주변에 아군이 없으면 무조건 아군에게 이동
		npc.StartPathing();
		npc.SetGoalEntity(npc.m_iTargetAlly);
	}
	else
	{
		// 아군이 주변에 있다면 기존 적 추적/전투 로직 수행
		if(npc.m_iTarget > 0 && IsValidEnemy(npc.index, npc.m_iTarget) && flDistanceToEnemy < (800.0 * 800.0))
		{
			npc.StartPathing();
			if(flDistanceToEnemy < (300.0 * 300.0))
			{
				npc.StopPathing();
			}
			else
			{
				npc.SetGoalEntity(npc.m_iTarget);
			}
		}
		else if(npc.m_iTargetAlly > 0)
		{
			if(flDistanceToAlly > (100.0 * 100.0))
			{
				npc.StartPathing();
				npc.SetGoalEntity(npc.m_iTargetAlly);
			}
			else
			{
				npc.StopPathing();
			}
		}
	}

	if(npc.m_flNextGroupHeal < GameTime)
	{
		npc.m_flNextGroupHeal = GameTime + 1.0;
		ExpidonsaGroupHeal(npc.index, 200.0, 14, 10.0, 1.0, true, Expidonsa_DontHealSameIndex);
	}
	
	// 5. 최종 공격 함수 호출 (주변에 아군이 있을 때만 공격 실행)
	if(bHasAllyNearby)
	{
		AllysoldierSelfDefense(npc, GameTime, npc.m_iTarget, flDistanceToEnemy); 
	}
}

static int AllysoldierSelfDefense(Allysoldier npc, float gameTime, int target, float distance)
{
	if(!IsValidEnemy(npc.index, target))
		return 0;

	if(gameTime < npc.m_flNextRangedAttack)
		return 0;

	if(distance > (1200.0 * 1200.0))
		return 0;

	int Enemy_I_See = Can_I_See_Enemy(npc.index, target);
	if(IsValidEnemy(npc.index, Enemy_I_See))
	{
		npc.m_iTarget = Enemy_I_See;
		target = Enemy_I_See;

		npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
		
		float vecTarget[3]; 
		WorldSpaceCenter(target, vecTarget);
		npc.FaceTowards(vecTarget, 20000.0);
		
		Handle swingTrace;
		if(npc.DoSwingTrace(swingTrace, target, { 1200.0, 1200.0, 1200.0 }))
		{
			if(!NpcStats_VestanCallToArms(npc.index))
				npc.m_iAmmo--;
				
			target = TR_GetEntityIndex(swingTrace);
			float vecHit[3];
			TR_GetEndPosition(vecHit, swingTrace);
			
			float origin[3], angles[3];
			if(IsValidEntity(npc.m_iWearable5))
			{
				view_as<CClotBody>(npc.m_iWearable5).GetAttachment("muzzle", origin, angles);
			}
			else
			{
				WorldSpaceCenter(npc.index, origin);
			}
			
			ShootLaser(npc.m_iWearable1, "bullet_tracer02_blue", origin, vecHit, false);
			npc.m_flNextRangedAttack = gameTime + 1.0;

			if(IsValidEnemy(npc.index, target))
			{
				float damageDealt = 100.0;
				if(ShouldNpcDealBonusDamage(target))
					damageDealt *= 8.0;
				SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt  * npc.m_flWaveScale, DMG_BULLET, -1, _, vecHit);
			}
		}
		delete swingTrace;
		return 1;
	}
	
	return 0;
}

void Allysoldier_ApplyBuffInLocation_Optimized(float BannerPos[3], int Team, int iMe = 0)
{
	float rangeSq = ALLYSOLDIER_RANGE * ALLYSOLDIER_RANGE; 
	float targPos[3];

	for(int ally=1; ally<=MaxClients; ally++)
	{
		if(IsClientInGame(ally) && IsPlayerAlive(ally) && GetTeam(ally) == Team)
		{
			GetClientAbsOrigin(ally, targPos);
			if (FloatAbs(BannerPos[0] - targPos[0]) > ALLYSOLDIER_RANGE) continue; 
			
			if (GetVectorDistance(BannerPos, targPos, true) <= rangeSq)
			{
				ApplyStatusEffect(ally, ally, "Ally Empowerment", 1.0);
			}
		}
	}

	for(int i = 0; i < i_MaxcountNpcTotal; i++)
	{
		int ally = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		
		if (ally != -1 && IsValidEntity(ally) && !b_NpcHasDied[ally] && GetTeam(ally) == Team && iMe != ally)
		{
			GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", targPos);
			if (GetVectorDistance(BannerPos, targPos, true) <= rangeSq)
			{
				ApplyStatusEffect(ally, ally, "Ally Empowerment", 1.0);
			}
		}
	}
}

static Action Allysoldier_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Allysoldier npc = view_as<Allysoldier>(victim);
	
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	if(RoundToNearest(damage) < GetEntProp(victim, Prop_Data, "m_iHealth"))
		return Plugin_Changed;

	SetDownedState_Allysoldier(victim, true);
	damage = 0.0;
	return Plugin_Changed;
}

void SetDownedState_Allysoldier(int iNpc, bool StateDo)
{
	Allysoldier npc = view_as<Allysoldier>(iNpc);
	if(StateDo)
	{
		npc.m_flSelfRevival = GetGameTime() + 30.0;
		b_ShowNpcHealthbar[iNpc] = false;	
		b_ThisEntityIgnored[iNpc] = true;
		b_NpcIsInvulnerable[iNpc] = true;
		SetEntProp(iNpc, Prop_Data, "m_iHealth", 1);
		if(!npc.m_flWasIdleState)
		{
			npc.m_flWasIdleState = 1.0;
			npc.StopPathing();
			npc.m_bisWalking = false;
			npc.AddGesture("ACT_MP_STUN_BEGIN");
			npc.SetActivity("ACT_MP_STUN_MIDDLE");
		}
		SetEntityRenderMode(npc.index, RENDER_TRANSALPHA);
		if(IsValidEntity(npc.m_iWearable1)) SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSALPHA);
		if(IsValidEntity(npc.m_iWearable2)) SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSALPHA);
		if(IsValidEntity(npc.m_iWearable3)) SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSALPHA);
		if(IsValidEntity(npc.m_iWearable4)) SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSALPHA);
		if(IsValidEntity(npc.m_iWearable5)) SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSALPHA);
		if(IsValidEntity(npc.m_iWearable6)) SetEntityRenderMode(npc.m_iWearable6, RENDER_TRANSALPHA);
	}
	else
	{
		if(npc.m_flWasIdleState)
		{
			npc.m_flWasIdleState = 0.0;
			npc.SetActivity("ACT_MP_RUN_SECONDARY");
		}
		npc.m_flSelfRevival = 0.0;
		b_ShowNpcHealthbar[iNpc] = true;
		b_ThisEntityIgnored[iNpc] = false;
		b_NpcIsInvulnerable[iNpc] = false;
		SetEntProp(iNpc, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(iNpc));
		SetEntityRenderMode(npc.index, RENDER_NORMAL);
		if(IsValidEntity(npc.m_iWearable1)) SetEntityRenderMode(npc.m_iWearable1, RENDER_NORMAL);
		if(IsValidEntity(npc.m_iWearable2)) SetEntityRenderMode(npc.m_iWearable2, RENDER_NORMAL);
		if(IsValidEntity(npc.m_iWearable3)) SetEntityRenderMode(npc.m_iWearable3, RENDER_NORMAL);
		if(IsValidEntity(npc.m_iWearable4)) SetEntityRenderMode(npc.m_iWearable4, RENDER_NORMAL);
		if(IsValidEntity(npc.m_iWearable5)) SetEntityRenderMode(npc.m_iWearable5, RENDER_NORMAL);
		if(IsValidEntity(npc.m_iWearable6)) SetEntityRenderMode(npc.m_iWearable6, RENDER_NORMAL);
	}
}

static void Allysoldier_NPCDeath(int entity)
{
	Allysoldier npc = view_as<Allysoldier>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();	
	
	if(IsValidEntity(npc.m_iWearable6)) RemoveEntity(npc.m_iWearable6);
	if(IsValidEntity(npc.m_iWearable5)) RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable4)) RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3)) RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2)) RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1)) RemoveEntity(npc.m_iWearable1);
}