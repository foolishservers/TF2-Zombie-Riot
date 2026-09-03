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

static const char g_MeleeHitSounds[][] =
{
	"weapons/cbar_hit1.wav",
	"weapons/cbar_hit2.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/pickaxe_swing1.wav",
	"weapons/pickaxe_swing2.wav",
	"weapons/pickaxe_swing3.wav"
};

static const char g_RangeAttackSounds[] = "weapons/rocket_shoot.wav";

public void ZSoldierGrave_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Soldier Rocketeer");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_zombie_soldier");
	strcopy(data.Icon, sizeof(data.Icon), "soldier");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_GmodZS;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
	
	strcopy(data.Name, sizeof(data.Name), "Infected Soldier");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_zombie_soldier_pickaxe");
	strcopy(data.Icon, sizeof(data.Icon), "soldier");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_GmodZS;
	data.Func = ClotSummon_ALT;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSound(g_RangeAttackSounds);
	PrecacheModel("models/player/soldier.mdl");
}

static any ClotSummon_ALT(int client, float vecPos[3], float vecAng[3], int team)
{
	return ZSoldierGrave(vecPos, vecAng, team, true);
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ZSoldierGrave(vecPos, vecAng, team, false);
}

methodmap ZSoldierGrave < CClotBody
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
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _);	
	}

	public ZSoldierGrave(float vecPos[3], float vecAng[3], int ally, bool Alt)
	{
		ZSoldierGrave npc = view_as<ZSoldierGrave>(CClotBody(vecPos, vecAng, "models/player/soldier.mdl", "1.0", (Alt ? "20000" : "15000"), ally));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity((Alt ? "ACT_MP_RUN_PRIMARY" : "ACT_MP_RUN_MELEE"));
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = ZSoldierGrave_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = ZSoldierGrave_OnTakeDamage;
		func_NPCThink[npc.index] = (Alt ? ZSoldierMelee_ClotThink : ZSoldierGrave_ClotThink);		
		
		//IDLE
		npc.m_flSpeed = (Alt ? 175.0 : 280.0);		
		npc.m_iMaxAmmo = 1;
		npc.m_iAmmo = 1;
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = (Alt ? 0.6 : 1.0);	
		
		npc.StartPathing();
		
		int skin = 5;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		if(Alt)
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_pickaxe/c_pickaxe.mdl");
		else
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_rocketlauncher/c_rocketlauncher.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		npc.m_iWearable2	= npc.EquipItem("head", "models/player/items/soldier/soldier_zombie.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		
		return npc;
	}
}


static void ZSoldierGrave_ClotThink(int iNPC)
{
	ZSoldierGrave npc = view_as<ZSoldierGrave>(iNPC);
	float gametime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gametime)
		return;
	npc.m_flNextDelayTime = gametime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gametime)
		return;
	npc.m_flNextThinkTime = gametime + 0.1;
	
	if(npc.m_flGetClosestTargetTime < gametime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gametime + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		switch(ZSoldierGrave_Work(npc,gametime,npc.m_iTarget,flDistanceToTarget,vecTarget))
		{
			case 0:
			{
				if(npc.m_iChanged_WalkCycle != 0)
				{
					npc.m_bisWalking = true;
					npc.m_bAllowBackWalking = false;
					npc.m_iChanged_WalkCycle = 0;
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
					npc.m_flSpeed = 280.0;
					npc.StartPathing();
				}
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3];
					PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
					npc.SetGoalVector(vPredictedPos);
				}
				else 
				{
					npc.SetGoalEntity(npc.m_iTarget);
				}
			}
			case 1:
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
					npc.m_bisWalking = false;
					npc.m_bAllowBackWalking = false;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_STAND_PRIMARY");
					npc.m_flSpeed = 0.0;
					npc.StopPathing();
				}
			}
			case 2:
			{
				if(npc.m_iChanged_WalkCycle != 2)
				{
					npc.m_bisWalking = true;
					npc.m_bAllowBackWalking = true;
					npc.m_iChanged_WalkCycle = 2;
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
					npc.m_flSpeed = 280.0;
					npc.StartPathing();
				}
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true);
			}
		}
	}
	else
	{
		npc.StopPathing();
		// 타겟이 사라졌으니 즉시 재탐색하도록 0.0으로 초기화
		npc.m_flGetClosestTargetTime = 0.0; 

		// 추가: 멍청하게 서 있지 않도록 애니메이션 상태도 강제로 리셋
		if(npc.m_iChanged_WalkCycle != 1)
		{
			npc.m_iChanged_WalkCycle = 1;
			npc.SetActivity("ACT_MP_STAND_PRIMARY");
			npc.m_flSpeed = 0.0;
		}
	}
	npc.PlayIdleAlertSound();
}

static int ZSoldierGrave_Work(ZSoldierGrave npc, float gameTime, int target, float distance, float vecTarget[3])
{
    if(npc.m_flAttackHappens || !npc.m_iAmmo)
    {
        if(!npc.m_flAttackHappens)
        {
            npc.m_flAttackHappens = gameTime + 1.1; 
            npc.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY", true, _, _, 1.1);
            npc.m_flAttackHappenswillhappen = false;
        }

        if(gameTime > npc.m_flAttackHappens)
        {
            npc.m_iAmmo = npc.m_iMaxAmmo;
            npc.m_flAttackHappens = 0.0;
        }
    }

    if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 25.0) || npc.m_flAttackHappenswillhappen)
    {
        int Enemy_I_See = Can_I_See_Enemy(npc.index, target);
        
        if(!npc.m_flAttackHappens && ((gameTime > npc.m_flNextRangedAttack && IsValidEnemy(npc.index, Enemy_I_See)) || npc.m_flAttackHappenswillhappen))
        {
            npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY", true);
            float ProjectileSpeed = 700.0;
            
            WorldSpaceCenter(target, vecTarget); 
            PredictSubjectPositionForProjectiles(npc, target, ProjectileSpeed, _, vecTarget);
            
            npc.FaceTowards(vecTarget, 20000.0);
            npc.FireRocket(vecTarget, 135.0, ProjectileSpeed);
            npc.PlayRangeSound();

            npc.m_flNextRangedAttack = gameTime + 2.0;
            npc.m_flAttackHappenswillhappen = true; 
            npc.m_iAmmo--;
        }
    }

    if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 9.0) || ShouldNpcDealBonusDamage(target))
    {
        return 0; // Chase
    }
    else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 8.0))
    {
        if(Can_I_See_Enemy_Only(npc.index, target))
        {
            return 2; // Backoff
        }
    }

    // 위 조건들에 해당하지 않는 "애매한 거리"이거나 재장전 중일 때의 기본 행동
    return 0; // Stand / Attack Position
}

static Action ZSoldierGrave_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	ZSoldierGrave npc = view_as<ZSoldierGrave>(victim);
	if(attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

static void ZSoldierMelee_ClotThink(int iNPC)
{
	ZSoldierGrave npc = view_as<ZSoldierGrave>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	int target = npc.m_iTarget;
	if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target))
		i_Target[npc.index] = -1;
	
	if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < gameTime)
	{
		target = GetClosestTarget(npc.index);
		npc.m_iTarget = target;
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}

	int maxhealth = ReturnEntityMaxHealth(npc.index);
	int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
	int minhealth = maxhealth / (Rogue_Paradox_RedMoon() ? 8 : 4);
	if(health < minhealth)
		health = minhealth;
	
	float hpRatio = float(maxhealth) / float(health);

	if(!NpcStats_IsEnemySilenced(npc.index))
		npc.m_flSpeed = 100.0 + (hpRatio * 75.0);
	
	if(target > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float distance = GetVectorDistance(vecTarget, VecSelfNpc, true);	
		
		if(distance < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, target,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(target);
		}

		npc.StartPathing();
		
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;
				
				Handle swingTrace;
				npc.FaceTowards(vecTarget, 15000.0);
				if(npc.DoSwingTrace(swingTrace, target, _, _, _, _))
				{
					target = TR_GetEntityIndex(swingTrace);
					if(target > 0)
					{
						float damage = 100.0 * hpRatio;
						if(ShouldNpcDealBonusDamage(target))
							damage *= 6.0;

						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB);
					}
				}

				delete swingTrace;
			}
		}

		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED) && npc.m_flNextMeleeAttack < gameTime)
		{
			target = Can_I_See_Enemy(npc.index, target);
			if(IsValidEnemy(npc.index, target))
			{
				npc.m_iTarget = target;
				npc.m_flGetClosestTargetTime = gameTime + 1.0;

				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				npc.PlayMeleeSound();
				
				npc.m_flAttackHappens = gameTime + 0.35;
				npc.m_flNextMeleeAttack = gameTime + 0.95;
			}
		}
	}
	else
	{
		npc.StopPathing();
	}

	npc.PlayIdleSound();
}

static void ZSoldierGrave_NPCDeath(int entity)
{
	ZSoldierGrave npc = view_as<ZSoldierGrave>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}