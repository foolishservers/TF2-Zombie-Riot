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

static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/soldier_taunts19.mp3",
	"vo/taunts/soldier_taunts20.mp3",
	"vo/taunts/soldier_taunts21.mp3",
	"vo/taunts/soldier_taunts18.mp3",
};

static const char g_ExplosionSounds[][]= {
	"weapons/explode1.wav",
	"weapons/explode2.wav",
	"weapons/explode3.wav"
};

static const char g_RangedReloadSound[] = "weapons/dumpster_rocket_reload.wav";
static const char g_RangeAttackSounds[] = "weapons/rocket_shoot.wav";
static const char g_SuperJumpSound[] = "misc/halloween/spell_mirv_explode_primary.wav";

public void ZsSoldier_Barrager_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Colonel Barrage");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_soldier_barrager");
	strcopy(data.Icon, sizeof(data.Icon), "gmod_zs_colonel");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_GmodZS;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_ExplosionSounds);
	PrecacheSound(g_RangedReloadSound);
	PrecacheSound(g_RangeAttackSounds);
	PrecacheSound(g_SuperJumpSound);
	PrecacheModel("models/player/soldier.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ZsSoldier_Barrager(vecPos, vecAng, team);
}

methodmap ZsSoldier_Barrager < CClotBody
{
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
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound, this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlaySuperJumpSound()
	{
		EmitSoundToAll(g_SuperJumpSound, this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_SuperJumpSound, this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	property bool b_ZsSoldierRocketJump
	{
		public get()							{ return b_NextRangedBarrage_OnGoing[this.index]; }
		public set(bool TempValueForProperty) 	{ b_NextRangedBarrage_OnGoing[this.index] = TempValueForProperty; }
	}
	
	public ZsSoldier_Barrager(float vecPos[3], float vecAng[3], int ally)
	{
		ZsSoldier_Barrager npc = view_as<ZsSoldier_Barrager>(CClotBody(vecPos, vecAng, "models/player/soldier.mdl", "1.15", "45000", ally));
		
		i_NpcWeight[npc.index] = 1;
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);
		
		if(!IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 9000.0;
			RaidModeScaling = 0.0;
			RaidAllowsBuildings = true;
		}
		
		switch(GetRandomInt(0,2))
		{
			case 0:PrintNPCMessageWithPrefixes(npc.index, "green", "ColonelBarrage_Encounter_1", true);
			case 1:PrintNPCMessageWithPrefixes(npc.index, "green", "ColonelBarrage_Encounter_2", true);
			case 2:PrintNPCMessageWithPrefixes(npc.index, "green", "ColonelBarrage_Encounter_3", true);
		}
		
		//IDLE
		npc.m_flMeleeArmor = 2.0;
		npc.m_flRangedArmor = 0.5;
		npc.m_flSpeed = 270.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_iChanged_WalkCycle = 0;

		npc.m_bisWalking = true;
		npc.Anger = false;
		npc.b_ZsSoldierRocketJump = false;
		fl_ruina_battery_max[npc.index]=100.0;
		fl_ruina_battery[npc.index]=0.0;
		npc.m_iAmmo=30;
		npc.m_iMaxAmmo=30;
		ApplyStatusEffect(npc.index, npc.index, "Battery_TM Charge", 999.0);
		ApplyStatusEffect(npc.index, npc.index, "Ammo_TM Visualization", 999.0);
		
		b_we_are_reloading[npc.index]=false;
		fl_ruina_in_combat_timer[npc.index] = 2.0 + GetGameTime(npc.index);
		npc.StartPathing();
		
		int skin = 5;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_dumpster_device/c_dumpster_device.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/Soldier/Soldier_zombie.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/soldier/hwn2023_shortness_breath/hwn2023_shortness_breath.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/soldier/sum23_stealth_bomber_style1/sum23_stealth_bomber_style1.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		
		return npc;
	}
}


static void Internal_ClotThink(int iNPC)
{
	ZsSoldier_Barrager npc = view_as<ZsSoldier_Barrager>(iNPC);

	float GameTime= GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GameTime)
		return;
	
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GameTime)
		return;
	npc.m_flNextThinkTime = GameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(!IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.PlayIdleAlertSound();
		return;
	}
		
	float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

    // bool close = (flDistanceToTarget < 60000); // 1. 거리 체크 변수 제거 (필요 시 주석 처리)
    
	if(fl_ruina_battery[npc.index]>=fl_ruina_battery_max[npc.index])
	{
		if(npc.b_ZsSoldierRocketJump)
		{
			if(npc.IsOnGround())
			{
				npc.b_ZsSoldierRocketJump = false;
				npc.Anger = false;
				fl_ruina_battery[npc.index]=0.0;
			}
			else if(npc.m_flNextRangedAttack < GameTime)
			{
				npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
				PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, 750.0, _, vecTarget);
				npc.FaceTowards(vecTarget, 20000.0);
				npc.PlayRangeSound();
				
				npc.FireRocket(vecTarget, 100.0, 900.0);
				npc.m_flNextRangedAttack = GameTime + 0.15;
				npc.m_flReloadIn = GameTime + 1.75;
			}
		}
		else if(npc.IsOnGround())
		{
			if(npc.m_iChanged_WalkCycle != 2)
			{
				npc.m_bisWalking = false;
				npc.m_iChanged_WalkCycle = 2;
				npc.SetActivity("ACT_MP_JUMP_FLOAT_PRIMARY");
				npc.StartPathing();
			}
			npc.m_iAmmo = npc.m_iMaxAmmo;
			b_we_are_reloading[npc.index]=false;
			VecSelfNpc[0] = vecTarget[0];
			VecSelfNpc[1] = vecTarget[1];
			VecSelfNpc[2] += 800.0;
			PluginBot_Jump(npc.index, VecSelfNpc);
			float flPos[3];
			npc.GetAttachment("foot_L", flPos, {0.0,0.0,0.0});
			int Particles = ParticleEffectAt_Parent(flPos, "rockettrail", npc.index, "foot_L", {0.0,0.0,0.0});
			CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(Particles), TIMER_FLAG_NO_MAPCHANGE);
			npc.GetAttachment("foot_R", flPos, {0.0,0.0,0.0});
			Particles = ParticleEffectAt_Parent(flPos, "rockettrail", npc.index, "foot_R", {0.0,0.0,0.0});
			CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(Particles), TIMER_FLAG_NO_MAPCHANGE);
			npc.m_flNextRangedAttack = 0.0;
			npc.b_ZsSoldierRocketJump = true;
			npc.PlaySuperJumpSound();
		}
		return;
	}
	else if(npc.m_iChanged_WalkCycle != 1)
	{
		npc.m_bisWalking = true;
		npc.m_iChanged_WalkCycle = 1;
		npc.SetActivity("ACT_MP_RUN_PRIMARY");
		npc.StartPathing();
	}	
	
	//Predict their pos.
	if(flDistanceToTarget < npc.GetLeadRadius())
	{
		float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
		npc.SetGoalVector(vPredictedPos);
	}
	else
	{
		npc.SetGoalEntity(PrimaryThreatIndex);
	}

	
    // 장전 상태 결정: 탄약이 0이면 무조건 장전 모드로 진입
    if(npc.m_iAmmo <= 0 && !b_we_are_reloading[npc.index])
    {
        b_we_are_reloading[npc.index] = true;
    }

    // 2. 긴급 장전 조건(close && npc.m_iAmmo<=0)이 제거된 장전 실행 로직
    if(b_we_are_reloading[npc.index] && npc.m_flReloadIn < GameTime)
    {
        npc.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY");
        npc.m_flReloadIn = 0.2 + GameTime;
        npc.m_iAmmo++;
        npc.m_flNextRangedAttack = GameTime + 0.2;
        npc.PlayRangedReloadSound();
    }

    // 비전투 중 자동 장전 로직 (유지)
    if(fl_ruina_in_combat_timer[npc.index] <= GameTime && npc.m_flReloadIn < GameTime && !b_we_are_reloading[npc.index] && npc.m_iAmmo < npc.m_iMaxAmmo)
    {
        npc.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY");
        npc.m_flReloadIn = 0.2 + GameTime;
        npc.m_iAmmo++;
        npc.m_flNextRangedAttack = GameTime + 0.2;
        npc.PlayRangedReloadSound();
    }

    if(npc.m_iAmmo >= npc.m_iMaxAmmo)
    {
		npc.m_iAmmo = npc.m_iMaxAmmo;
        b_we_are_reloading[npc.index] = false;
    }

    // 3. 후퇴 로직 수정: 이제 적과의 거리에 상관없이(close 조건 제거) 탄약이 없으면 후퇴함
    if(npc.m_iAmmo <= 0 || b_we_are_reloading[npc.index])
    {
        npc.StartPathing();
        npc.m_flSpeed = 270.0;
        
        int Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
        if(IsValidEnemy(npc.index, Enemy_I_See))
        {
            float vBackoffPos[3];
            BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex, _, vBackoffPos);
            npc.SetGoalVector(vBackoffPos, true);
        }
    }
    else if(flDistanceToTarget < 1080000.0 && npc.m_iAmmo > 0) 
    {
        npc.m_flSpeed = 270.0;
        fl_ruina_in_combat_timer[npc.index] = 2.5 + GameTime;
        
        int Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
        
        if(IsValidEnemy(npc.index, Enemy_I_See))
        {	
            // [추가/수정] 만약 적과의 거리가 원래 사정거리(120,000)보다 가까우면 뒤로 물러나며 공격
            if(flDistanceToTarget < 120000.0)
            {
                float vBackoffPos[3];
                BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex, _, vBackoffPos);
                npc.SetGoalVector(vBackoffPos, true);
            }
            
            npc.StartPathing();

			if(npc.m_flNextRangedAttack < GameTime)
			{
				npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
				PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, 750.0, _, vecTarget);
				npc.FaceTowards(vecTarget, 20000.0);
				npc.PlayRangeSound();
				
				int RocketGet = npc.FireRocket(vecTarget, 0.0, 750.0); // 로켓 발사 
				if(IsValidEntity(RocketGet))
					SDKHook(RocketGet, SDKHook_StartTouch, HEGrenade_StartTouch);
				npc.m_flNextRangedAttack = GameTime + 0.2;
				npc.m_flReloadIn = GameTime + 1.75;
				npc.m_iAmmo--;
			}
        }
    }
	else
	{
		npc.StartPathing();
	}
}

static Action HEGrenade_StartTouch(int entity, int target)
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
	ParticleEffectAt(ProjectileLoc, "ExplosionCore_MidAir", 1.0);
	EmitSoundToAll(g_ExplosionSounds[GetRandomInt(0, sizeof(g_ExplosionSounds) - 1)], 0, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _, -1, ProjectileLoc);
	RemoveEntity(entity);
	return Plugin_Handled;
}

static void HEGrenade(int entity, int victim, float damage, int weapon)
{
	float vecHit[3]; WorldSpaceCenter(victim, vecHit);
	if(IsValidEntity(entity) && GetTeam(entity) != GetTeam(victim))
	{
		char npc_classname[60];
		NPC_GetPluginById(i_NpcInternalId[entity], npc_classname, sizeof(npc_classname));
		if(entity != INVALID_ENT_REFERENCE && StrEqual(npc_classname, "npc_zs_soldier_barrager") && IsEntityAlive(entity))
		{
			if(!b_Anger[entity])
			{
				fl_ruina_battery[entity]+=5.0;
				if(fl_ruina_battery[entity]>=fl_ruina_battery_max[entity])
				{
					fl_ruina_battery[entity]=fl_ruina_battery_max[entity];
					b_Anger[entity]=true;
				}
			}
		}
	
		int inflictor = h_ArrowInflictorRef[entity];
		if(inflictor != -1)
			inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);

		if(inflictor == -1)
			inflictor = entity;
		damage = 200.0;
		if(ShouldNpcDealBonusDamage(victim))
			damage *= 3.0;
		SDKHooks_TakeDamage(victim, entity, inflictor, damage, DMG_BLAST, -1, _, vecHit);
	}
}

static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	ZsSoldier_Barrager npc = view_as<ZsSoldier_Barrager>(victim);
	
	if(attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void Internal_NPCDeath(int entity)
{
	ZsSoldier_Barrager npc = view_as<ZsSoldier_Barrager>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	PrintNPCMessageWithPrefixes(npc.index, "green", "ColonelBarrage_Death", true);
	
	for(int i = 1; i < MAXENTITIES; i++)
	{
		if(!IsValidEntity(i) || !b_IsAProjectile[i])
			continue;
		if(GetEntPropEnt(i, Prop_Send, "m_hOwnerEntity") != entity)
			continue;
		RemoveEntity(i);
	}
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
}