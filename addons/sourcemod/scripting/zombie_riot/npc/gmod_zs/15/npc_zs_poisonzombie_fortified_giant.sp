#pragma semicolon 1
#pragma newdecls required

static char g_DeathSounds[][] = {
	"npc/zombie_poison/pz_die1.wav",
	"npc/zombie_poison/pz_die2.wav",
};

static char g_HurtSounds[][] = {
	"npc/zombie_poison/pz_pain1.wav",
	"npc/zombie_poison/pz_pain2.wav",
	"npc/zombie_poison/pz_pain3.wav",
};

static char g_IdleSounds[][] = {
	"npc/zombie_poison/pz_idle2.wav",
	"npc/zombie_poison/pz_idle3.wav",
	"npc/zombie_poison/pz_idle4.wav",
};

static char g_IdleAlertedSounds[][] = {
	"npc/zombie_poison/pz_alert1.wav",
	"npc/zombie_poison/pz_alert2.wav",
};

static char g_MeleeHitSounds[][] = {
	"npc/fast_zombie/claw_strike1.wav",
	"npc/fast_zombie/claw_strike2.wav",
	"npc/fast_zombie/claw_strike3.wav",
};
static char g_MeleeAttackSounds[][] = {
	"npc/zombie_poison/pz_warn1.wav",
	"npc/zombie_poison/pz_warn2.wav",
};

static char g_MeleeMissSounds[][] = {
	"npc/fast_zombie/claw_miss1.wav",
	"npc/fast_zombie/claw_miss2.wav",
};

public void ZSFortifiedGiantPoisonZombie_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Fortified Giant Poison Zombie");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_poisonzombie_fortified_giant");
	strcopy(data.Icon, sizeof(data.Icon), "norm_poison_zombie");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_GmodZS;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	Zombie_Shared_PheromonePrecache();
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheModel("models/zombie/poison.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ZSFortifiedGiantPoisonZombie(vecPos, vecAng, team);
}

methodmap ZSFortifiedGiantPoisonZombie < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
	}
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public ZSFortifiedGiantPoisonZombie(float vecPos[3], float vecAng[3], int ally)
	{
		ZSFortifiedGiantPoisonZombie npc = view_as<ZSFortifiedGiantPoisonZombie>(CClotBody(vecPos, vecAng, "models/zombie/poison.mdl", "1.75", "15000", ally, false, true));
		
		i_NpcWeight[npc.index] = 4;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_WALK");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		func_NPCDeath[npc.index] = ZSFortifiedGiantPoisonZombie_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = ZSFortifiedGiantPoisonZombie_OnTakeDamage;
		func_NPCThink[npc.index] = ZSFortifiedGiantPoisonZombie_ClotThink;	
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_flAttackHappenswillhappen = false;
		npc.m_flSpeed = 231.0;
		npc.StartPathing();
		
		return npc;
	}
}


public void ZSFortifiedGiantPoisonZombie_ClotThink(int iNPC)
{
	ZSFortifiedGiantPoisonZombie npc = view_as<ZSFortifiedGiantPoisonZombie>(iNPC);
	
	//15 in this case is full, this probably works like flags. but its wierd, tbh just trial and error
	SetVariantInt(0);
	AcceptEntityInput(iNPC, "SetBodyGroup");
	float GameTime = GetGameTime(npc.index);
	
	if(npc.m_flNextDelayTime > GameTime)
		return;
	
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
//		if(!npc.m_flAttackHappenswillhappen)
//			npc.AddGesture("ACT_SMALL_FLINCH", false);
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
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
		if(flDistanceToTarget < npc.GetLeadRadius()) {
			float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else
			npc.SetGoalEntity(PrimaryThreatIndex);
		
		if(flDistanceToTarget < GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
		{
			if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
			{
				if (!npc.m_flAttackHappenswillhappen)
				{
					npc.AddGesture("ACT_MELEE_ATTACK1");
					npc.PlayMeleeSound();
					npc.m_flAttackHappens = GameTime+0.8;
					npc.m_flAttackHappens_bullshit = GameTime+1.0;
					npc.m_flAttackHappenswillhappen = true;
				}
				if (npc.m_flAttackHappens < GameTime && npc.m_flAttackHappens_bullshit >= GameTime && npc.m_flAttackHappenswillhappen)
				{
					Handle swingTrace;
					npc.FaceTowards(vecTarget, 20000.0);
					if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex, _, _, _, 1))
					{
						int target = TR_GetEntityIndex(swingTrace);	
						
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						
						if(target > 0) 
						{
							
							if(!ShouldNpcDealBonusDamage(target))
								SDKHooks_TakeDamage(target, npc.index, npc.index, 160.0, DMG_CLUB, -1, _, vecHit);
							else
								SDKHooks_TakeDamage(target, npc.index, npc.index, 240.0, DMG_CLUB, -1, _, vecHit);
							// Hit particle
							Elemental_AddPheromoneDamage(target, npc.index, npc.index ? 500 : 500);
							if(Armor_Charge[target] > 0)
							{
								Armor_Charge[target]=0;
								f_Armor_BreakSoundDelay[target] = GameTime + 5.0;	
								EmitSoundToClient(target, "npc/assassin/ball_zap1.wav", target, SNDCHAN_STATIC, 60, _, 1.0, GetRandomInt(95,105));
							}
							// Hit sound
							npc.PlayMeleeHitSound();
							
							//Did we kill them?
							int iHealthPost = GetEntProp(target, Prop_Data, "m_iHealth");
							if(iHealthPost <= 0) 
							{
								//Yup, time to celebrate
								npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST");
							}
						} 
					}
					delete swingTrace;
					npc.m_flNextMeleeAttack = GameTime + 1.0;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GameTime && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = GameTime + 1.0;
				}
			}
		}
		else
		{
			npc.StartPathing();
		}
	}
	else
	{
		npc.StopPathing();
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action ZSFortifiedGiantPoisonZombie_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	ZSFortifiedGiantPoisonZombie npc = view_as<ZSFortifiedGiantPoisonZombie>(victim);
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

public void ZSFortifiedGiantPoisonZombie_NPCDeath(int entity)
{
	ZSFortifiedGiantPoisonZombie npc = view_as<ZSFortifiedGiantPoisonZombie>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();	
}
