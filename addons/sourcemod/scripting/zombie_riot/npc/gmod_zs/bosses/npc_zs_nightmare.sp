#pragma semicolon 1
#pragma newdecls required
 
static const char g_DeathSounds[][] = {
	"npc/barnacle/barnacle_die1.wav",
	"npc/barnacle/barnacle_die2.wav",
};

static const char g_HurtSounds[][] = {
    "npc/barnacle/barnacle_pull1.wav",
	"npc/barnacle/barnacle_pull2.wav",
	"npc/barnacle/barnacle_pull3.wav",
	"npc/barnacle/barnacle_pull4.wav",
};

static const char g_IdleSounds[][] = {
    "npc/barnacle/barnacle_crunch2.wav",
	"npc/barnacle/neck_snap1.wav",
	"npc/barnacle/neck_snap2.wav",
};

static const char g_MeleeHitSounds[][] = {
	"npc/barnacle/barnacle_bark1.wav",
	"npc/barnacle/barnacle_bark2.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"npc/zombie/zombie_hit.wav",
	"npc/vort/foot_hit.wav",
};

static const char g_MeleeMissSounds[][] = {
	"npc/fast_zombie/claw_miss1.wav",
	"npc/fast_zombie/claw_miss2.wav",
};

static const char g_PlayHowlerWarCry[] = "zombiesurvival/medieval_raid/special_mutation/arkantos_scream_buff.mp3";

public void ZSNightmare_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Nightmare");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_nightmare");
	strcopy(data.Icon, sizeof(data.Icon), "");
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
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSound(g_PlayHowlerWarCry);
	PrecacheSound("player/flow.wav");
	PrecacheModel("models/zombie_riot/gmod_zs/zs_zombie_models_1_1.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ZSNightmare(vecPos, vecAng, team);
}

methodmap ZSNightmare < CClotBody
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
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(115, 140));
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayHowlerWarCry() {
		EmitSoundToAll(g_PlayHowlerWarCry, this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	property float m_flWhyCry
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	public ZSNightmare(float vecPos[3], float vecAng[3], int ally)
	{
		ZSNightmare npc = view_as<ZSNightmare>(CClotBody(vecPos, vecAng, "models/zombie_riot/gmod_zs/zs_zombie_models_1_1.mdl", "1.15", "15000", ally, false));
		
		i_NpcWeight[npc.index] = 4;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_HL2MP_RUN_ZOMBIE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		func_NPCDeath[npc.index] = ZSNightmare_NPCDeath;
		func_NPCThink[npc.index] = ZSNightmare_ClotThink;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;

		npc.m_flSpeed = 350.0;
		npc.m_flNextMeleeAttack = 0.0;
        npc.m_flWhyCry = 0.0;
        npc.m_flMeleeArmor = 0.8;
		npc.m_flRangedArmor = 0.8;
		
		if(!IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 9000.0;
			RaidModeScaling = 0.0;
			RaidAllowsBuildings = true;
		}
		
		npc.StartPathing();
		
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				ShowGameText(client_check, "voice_player", 1, "%t", "Nightmare Spawned");
			}
		}
		
		return npc;
	}
}

static void ZSNightmare_ClotThink(int iNPC)
{
	ZSNightmare npc = view_as<ZSNightmare>(iNPC);
	
	float GameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GameTime)
		return;
	
	SetEntProp(npc.index, Prop_Send, "m_nBody", GetEntProp(npc.index, Prop_Send, "m_nBody"));
	SetVariantInt(32768);
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
	
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	if(npc.m_flWhyCry < GameTime)
	{
		spawnRing(npc.index, ALAXIOS_BUFF_MAXRANGE * 2.0, 0.0, 0.0, 5.0, LASERBEAM, 255, 125, 125, 255, 1, 1.0, 6.0, 6.1, 1);
		spawnRing_Vectors(VecSelfNpc, 0.0, 0.0, 5.0, 0.0, LASERBEAM, 255, 125, 125, 255, 1, 0.75, 12.0, 6.1, 1, ALAXIOS_BUFF_MAXRANGE * 2.0);		
		spawnRing(npc.index, ZSHOWLER_BUFF_MAXRANGE * 2.0, 0.0, 0.0, 25.0, LASERBEAM, 255, 125, 125, 255, 1, 0.8, 6.0, 6.1, 1);
		spawnRing(npc.index, ZSHOWLER_BUFF_MAXRANGE * 2.0, 0.0, 0.0, 35.0, LASERBEAM, 255, 125, 125, 255, 1, 0.7, 6.0, 6.1, 1);
		Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, ALAXIOS_BUFF_MAXRANGE, _, _, true, _, false, _, ZSNightmare_Debuff_AoE);
		npc.m_flWhyCry = 20.0 + GameTime;
	}
	
	int closest = npc.m_iTarget;
	if(IsValidEnemy(npc.index, closest))
	{
		float vecTarget[3]; WorldSpaceCenter(closest, vecTarget);
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
							{
								if(!ShouldNpcDealBonusDamage(target))
									SDKHooks_TakeDamage(target, npc.index, npc.index, 1000.0, DMG_CLUB, -1, _, vecHit);
								else
									SDKHooks_TakeDamage(target, npc.index, npc.index, 2500.0, DMG_CLUB, -1, _, vecHit);					
							}
							
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

static void ZSNightmare_NPCDeath(int entity)
{
	ZSNightmare npc = view_as<ZSNightmare>(entity);
	SpawnMoney(npc.index, true);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
}

static void ZSNightmare_Debuff_AoE(int entity, int victim, float damage, int weapon)
{
	if(IsValidEntity(entity) && IsValidEntity(victim) && GetTeam(entity) != GetTeam(victim))
		ApplyStatusEffect(entity, victim, "Heavy Presence", 5.0);
}