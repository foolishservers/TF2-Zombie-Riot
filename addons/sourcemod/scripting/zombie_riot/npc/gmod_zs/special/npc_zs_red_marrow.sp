#pragma semicolon 1
#pragma newdecls required
 
static const char g_DeathSounds[][] = {
	"npc/zombie/zombie_die1.wav",
	"npc/zombie/zombie_die2.wav",
	"npc/zombie/zombie_die3.wav",
};

static const char g_HurtSounds[][] = {
    "npc/metropolice/pain1.wav",
    "npc/metropolice/pain2.wav",
    "npc/metropolice/pain3.wav",
    "npc/metropolice/pain4.wav",
};

static const char g_IdleSounds[][] = {
    "npc/strider/creak1.wav",
    "npc/strider/creak2.wav",
    "npc/strider/creak3.wav",
    "npc/strider/creak4.wav",
};

static const char g_MeleeHitSounds[][] = {
	"npc/fast_zombie/claw_strike1.wav",
	"npc/fast_zombie/claw_strike2.wav",
	"npc/fast_zombie/claw_strike3.wav",
};

static const char g_MeleeMissSounds[][] = {
	"npc/fast_zombie/claw_miss1.wav",
	"npc/fast_zombie/claw_miss2.wav",
};

static const char g_MeleeAttackSounds[] = "npc/fast_zombie/wake1.wav";

public void RedMarrow_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Red Marrow");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_red_marrow");
	strcopy(data.Icon, sizeof(data.Icon), "ds_defender");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_GmodZS;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheSound(g_MeleeAttackSounds);
	PrecacheSound("player/flow.wav");
	PrecacheModel("models/zombie_riot/gmod_zs/zs_zombie_models_1_1.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return RedMarrow(vecPos, vecAng, team);
}

methodmap RedMarrow < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(115, 125));
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(70, 75));
	}
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(122, 128));
	}
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds, this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(115, 140));
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public RedMarrow(float vecPos[3], float vecAng[3], int ally)
	{
		RedMarrow npc = view_as<RedMarrow>(CClotBody(vecPos, vecAng, "models/zombie_riot/gmod_zs/zs_zombie_models_1_1.mdl", "1.35", "15000", ally, false));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_HL2MP_RUN_ZOMBIE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		npc.m_flSpeed = 205.0;
		func_NPCDeath[npc.index] = RedMarrow_NPCDeath;
		func_NPCThink[npc.index] = RedMarrow_ClotThink;
		func_NPCOnTakeDamage[npc.index] = RedMarrow_OnTakeDamage;
		
		npc.m_flWaveScale = float(Waves_GetRoundScale()+1)* 0.133333;
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 0, 0, 255);

        npc.m_flMeleeArmor = 0.77;
		npc.m_flRangedArmor = 0.7;
		npc.Anger = false;
		npc.m_bFUCKYOU = false;
		npc.StartPathing();
		
		return npc;
	}
}

static void RedMarrow_ClotThink(int iNPC)
{
	RedMarrow npc = view_as<RedMarrow>(iNPC);
	
	float GameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GameTime)
		return;
	
	SetEntProp(npc.index, Prop_Send, "m_nBody", GetEntProp(npc.index, Prop_Send, "m_nBody"));
	SetVariantInt(64);
	AcceptEntityInput(iNPC, "SetBodyGroup");
	
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		if(!npc.m_flAttackHappenswillhappen)
			npc.AddGesture("ACT_FLINCH", false);
		npc.PlayHurtSound();
		
	}
	
	if(npc.m_flNextThinkTime > GameTime)
		return;
	npc.m_flNextThinkTime = GameTime + 0.1;
	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
		npc.StartPathing();
	}
	
	int closest = npc.m_iTarget;
	if(IsValidEnemy(npc.index, closest))
	{
		float vecTarget[3]; WorldSpaceCenter(closest, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, closest,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(closest);
		}
		
		if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
		{
			if(npc.m_flNextMeleeAttack < GameTime)
			{
				if (!npc.m_flAttackHappenswillhappen)
				{
					npc.AddGesture("ACT_GMOD_GESTURE_RANGE_ZOMBIE");
					npc.PlayMeleeSound();
					npc.m_flAttackHappens = GameTime+0.7;
					npc.m_flAttackHappens_bullshit = GameTime+0.83;
					npc.m_flAttackHappenswillhappen = true;
				}

				if (npc.m_flAttackHappens < GameTime && npc.m_flAttackHappens_bullshit >= GameTime && npc.m_flAttackHappenswillhappen)
				{
					Handle swingTrace;
					npc.FaceTowards(vecTarget, 20000.0);
					if(npc.DoSwingTrace(swingTrace, closest))
					{
						int target = TR_GetEntityIndex(swingTrace);	
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						if(target > 0) 
						{
							if(!ShouldNpcDealBonusDamage(target))
								SDKHooks_TakeDamage(target, npc.index, npc.index, 80.0 * npc.m_flWaveScale, DMG_CLUB, -1, _, vecHit);
							else
								SDKHooks_TakeDamage(target, npc.index, npc.index, 120.0 * npc.m_flWaveScale, DMG_CLUB, -1, _, vecHit);					
							npc.PlayMeleeHitSound();
						}
						else
						{
							npc.PlayMeleeMissSound();
						}
					}
					delete swingTrace;
					npc.m_flNextMeleeAttack = GameTime + 0.74;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GameTime && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = GameTime + 0.74;
				}
			}
			
		}
	}
	else
	{
		npc.StopPathing();
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleSound();
}

static Action RedMarrow_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
    if(attacker <= 0 || victim <= 0 || !IsValidEntity(victim))
        return Plugin_Continue;
    RedMarrow npc = view_as<RedMarrow>(victim);
    
    int maxHealth = ReturnEntityMaxHealth(victim);
    int currentHealth = GetEntProp(victim, Prop_Data, "m_iHealth");
    
    float expectedHealth = float(currentHealth) - damage;
    float health50Percent = float(maxHealth) * 0.5;

    if(!npc.m_bFUCKYOU && expectedHealth <= health50Percent)
    {
		npc.m_bFUCKYOU = true;
        if(!NpcStats_IsEnemySilenced(victim))
        {
            npc.bXenoInfectedSpecialHurt = true;
            npc.flXenoInfectedSpecialHurtTime = GetGameTime() + 5.0;
            
            ApplyStatusEffect(victim, victim, "Unstoppable Force", 8.0);
            
            CreateTimer(5.0, RedMarrow_Revert_Resistance_Enable, EntIndexToEntRef(victim), TIMER_FLAG_NO_MAPCHANGE);
        }
    }

    if(npc.m_flHeadshotCooldown < GetGameTime())
    {
        npc.m_flHeadshotCooldown = GetGameTime() + DEFAULT_HURTDELAY;
        npc.m_blPlayHurtAnimation = true;
    }
    
    return Plugin_Continue;
}

static Action RedMarrow_Revert_Resistance_Enable(Handle timer, int ref)
{
	int zombie = EntRefToEntIndex(ref);
	if(IsValidEntity(zombie))
	{
		RedMarrow npc = view_as<RedMarrow>(zombie);
		npc.bXenoInfectedSpecialHurt = false;
	}
	return Plugin_Handled;
}

static void RedMarrow_NPCDeath(int entity)
{
	RedMarrow npc = view_as<RedMarrow>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();	
}