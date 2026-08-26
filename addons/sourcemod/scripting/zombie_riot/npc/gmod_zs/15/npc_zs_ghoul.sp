#pragma semicolon 1
#pragma newdecls required

static const char g_HurtSounds[][] = {
	"npc/zombie_poison/pz_warn1.wav",
	"npc/zombie_poison/pz_warn2.wav",
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

static const char g_IdleSounds[] = "npc/fast_zombie/fz_alert_close1.wav";
static const char g_MeleeAttackSounds[] = "npc/fast_zombie/leap1.wav";
static const char g_DeathSounds[] = "npc/zombie_poison/pz_die2.wav";

public void Ghoul_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Ghoul");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_ghoul");
	strcopy(data.Icon, sizeof(data.Icon), "gmod_zs_ghoul");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_GmodZS;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
	
	strcopy(data.Name, sizeof(data.Name), "Elder Ghoul");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_elder_ghoul");
	strcopy(data.Icon, sizeof(data.Icon), "gmod_zs_elder_ghoul");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_GmodZS;
	data.Func = ClotSummon_ALT;
	NPC_Add(data);
}

static void ClotPrecache()
{
	Zombie_Shared_PheromonePrecache();
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheSound(g_IdleSounds);
	PrecacheSound(g_MeleeAttackSounds);
	PrecacheSound(g_DeathSounds);
	PrecacheSound("player/flow.wav");
	PrecacheModel("models/zombie_riot/gmod_zs/zs_zombie_models_1_1.mdl");
}

static any ClotSummon_ALT(int client, float vecPos[3], float vecAng[3], int team)
{
	return Ghoul(vecPos, vecAng, team, true);
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Ghoul(vecPos, vecAng, team, false);
}

methodmap Ghoul < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds, this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(70, 80));
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(137, 143));
	}
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds, this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(122, 128));
	}
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds, this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(110, 130));
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public Ghoul(float vecPos[3], float vecAng[3], int ally, bool Alt)
	{
		Ghoul npc = view_as<Ghoul>(CClotBody(vecPos, vecAng, "models/zombie_riot/gmod_zs/zs_zombie_models_1_1.mdl", "1.15", "800", ally, false));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_HL2MP_WALK_ZOMBIE_01");
		if(iActivity > 0) npc.StartActivity(iActivity);
		

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		npc.m_flSpeed = 260.0;
		func_NPCDeath[npc.index] = Ghoul_NPCDeath;
		func_NPCThink[npc.index] = Ghoul_ClotThink;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		npc.StartPathing();
		
		npc.m_bFUCKYOU = Alt;
		if(Alt)
		{
			SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.index, 200, 160, 50, 255);
		}
		
		return npc;
	}
}

static void Ghoul_ClotThink(int iNPC)
{
	Ghoul npc = view_as<Ghoul>(iNPC);
	
	float GameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GameTime)
		return;
	SetEntProp(npc.index, Prop_Send, "m_nBody", GetEntProp(npc.index, Prop_Send, "m_nBody"));
	SetVariantInt(16);
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
				if(!npc.m_flAttackHappenswillhappen)
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
							float damageAmount = (ShouldNpcDealBonusDamage(target) ? 100.0 : (npc.m_bFUCKYOU ? 120 : 80));
							SDKHooks_TakeDamage(target, npc.index, npc.index, damageAmount, DMG_CLUB, -1, _, vecHit);
							if(!ShouldNpcDealBonusDamage(target))
							{
								Elemental_AddPheromoneDamage(target, npc.index, (npc.m_bFUCKYOU ? 45 : 30));
								int flagsStun = 0;
								if(!HasSpecificBuff(target, "Fluid Movement"))
											flagsStun |= TF_STUNFLAG_SLOWDOWN;
								if(target <= MaxClients)
									TF2_StunPlayer(target, 2.0, 0.5, flagsStun);
								ApplyStatusEffect(npc.index, target, "Cellular Breakdown", 8.0);
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

static void Ghoul_NPCDeath(int entity)
{
	Ghoul npc = view_as<Ghoul>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
}