#pragma semicolon 1
#pragma newdecls required

static char g_DeathSounds[][] = {
	"npc/zombie/zombie_die1.wav",
	"npc/zombie/zombie_die2.wav",
	"npc/zombie/zombie_die3.wav",
};

static char g_HurtSounds[][] = {
	"npc/zombie/zombie_pain1.wav",
	"npc/zombie/zombie_pain2.wav",
	"npc/zombie/zombie_pain3.wav",
	"npc/zombie/zombie_pain4.wav",
	"npc/zombie/zombie_pain5.wav",
	"npc/zombie/zombie_pain6.wav",
};

static char g_leap_scream[][] = {
	"npc/zombie/zombie_alert1.wav",
	"npc/zombie/zombie_alert2.wav",
	"npc/zombie/zombie_alert3.wav",
};

static char g_IdleSounds[][] = {
	"npc/zombie/zombie_alert1.wav",
	"npc/zombie/zombie_alert2.wav",
	"npc/zombie/zombie_alert3.wav",
};

static char g_IdleAlertedSounds[][] = {
	"npc/zombie/zombie_alert1.wav",
	"npc/zombie/zombie_alert2.wav",
	"npc/zombie/zombie_alert3.wav",
};

static char g_MeleeHitSounds[][] = {
	"npc/fast_zombie/claw_strike1.wav",
	"npc/fast_zombie/claw_strike2.wav",
	"npc/fast_zombie/claw_strike3.wav",
};
static char g_MeleeAttackSounds[][] = {
	"npc/zombie/zo_attack1.wav",
	"npc/zombie/zo_attack2.wav",
};

static char g_MeleeMissSounds[][] = {
	"npc/fast_zombie/claw_miss1.wav",
	"npc/fast_zombie/claw_miss2.wav",
};
static char g_PlayMeleeJumpPrepare[][] = {
	"npc/fast_zombie/claw_miss1.wav",
	"npc/fast_zombie/claw_miss2.wav",
};
static char g_PlayMeleeJumpSound[][] = {
	"npc/fast_zombie/claw_miss1.wav",
	"npc/fast_zombie/claw_miss2.wav",
};

static char g_leap_prepare[] = "npc/fast_zombie/leap1.wav";

public void Bastardzine_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Bastardzine");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_bastardzine");
	strcopy(data.Icon, sizeof(data.Icon), "gmod_zs_bastardzine");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_GmodZS|MVM_CLASS_FLAG_MINIBOSS;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
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
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheSoundArray(g_PlayMeleeJumpPrepare);
	PrecacheSoundArray(g_PlayMeleeJumpSound);
	PrecacheSoundArray(g_leap_scream);
	PrecacheSound(g_leap_prepare);
	PrecacheModel("models/zombie_riot/gmod_zs/zs_zombie_models_1_1.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Bastardzine(vecPos, vecAng, team);
}

methodmap Bastardzine < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(30.0, 60.0);
	}
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(30.0, 60.0);
	}
	public void PlayLeapPrepare() {
		EmitSoundToAll(g_leap_prepare, this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayLeapDone() {
		EmitSoundToAll(g_leap_scream[GetRandomInt(0, sizeof(g_leap_scream) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeJumpPrepare() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_PlayMeleeJumpPrepare[GetRandomInt(0, sizeof(g_PlayMeleeJumpPrepare) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeJumpSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_PlayMeleeJumpSound[GetRandomInt(0, sizeof(g_PlayMeleeJumpSound) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public Bastardzine(float vecPos[3], float vecAng[3], int ally)
	{
		Bastardzine npc = view_as<Bastardzine>(CClotBody(vecPos, vecAng, "models/zombie_riot/gmod_zs/zs_zombie_models_1_1.mdl", "1.15", "15000", ally, false));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_HL2MP_RUN_ZOMBIE_FAST");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/zombie_riot/gmod_zs/zs_zombie_models_1_1.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 150, 255, 150, 255);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		func_NPCDeath[npc.index] = Bastardzine_NPCDeath;
		func_NPCThink[npc.index] = Bastardzine_BastardzineThink;	
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;	
		
		//IDLE
		npc.m_flSpeed = 350.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flJumpCooldown = GetGameTime(npc.index) + 3.0;
		npc.m_flInJump = 0.0;
		
		npc.StartPathing();

		f_MaxAnimationSpeed[npc.index] = 1.5;
		
		return npc;
	}
}

static void Bastardzine_BastardzineThink(int iNPC)
{
	Bastardzine npc = view_as<Bastardzine>(iNPC);
	
	SetEntProp(npc.index, Prop_Send, "m_nBody", GetEntProp(npc.index, Prop_Send, "m_nBody"));
	SetVariantInt(1);
	AcceptEntityInput(iNPC, "SetBodyGroup");
	SetEntProp(npc.m_iWearable1, Prop_Send, "m_nBody", 2);
	
	float GameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GameTime)
		return;
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	if(npc.m_flNextThinkTime > GameTime)
		return;
	npc.m_flNextThinkTime = GameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	int closest = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);		
		
		if(npc.m_flJumpCooldown < GameTime && npc.m_flInJump < GameTime && flDistanceToTarget > NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0)
		{
			int Enemy_I_See;
			Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			//Target close enough to hit
			if(IsValidEnemy(npc.index, Enemy_I_See) && Enemy_I_See == PrimaryThreatIndex)
			{
				npc.m_flInJump = GameTime + 0.65;
				
				npc.m_flJumpCooldown = GameTime + 0.5;
				npc.PlayLeapPrepare();
			}
		}
		if(npc.m_flJumpCooldown < GameTime && npc.m_flInJump > GameTime)
		{
			PluginBot_Jump(npc.index, vecTarget);
			npc.PlayLeapDone();
			npc.m_flJumpCooldown = GameTime + 5.0;
		}
		if(npc.m_flInJump > GameTime)
		{
			npc.StopPathing();
			npc.FaceTowards(vecTarget, 1000.0);
			return;
		}
		
		if(flDistanceToTarget < npc.GetLeadRadius()) {
			
			float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(PrimaryThreatIndex);
		}
		if(flDistanceToTarget < 10000)
		{
			if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
			{
				
				if(npc.m_flNextMeleeAttack < GameTime)
				{
					if(!npc.m_flAttackHappenswillhappen)
					{
						npc.AddGesture("ACT_GMOD_GESTURE_RANGE_ZOMBIE_SPECIAL");
						npc.PlayMeleeSound();
						npc.m_flAttackHappens = GameTime+0.7;
						npc.m_flAttackHappens_bullshit = GameTime+0.83;
						npc.m_flAttackHappenswillhappen = true;
					}

					if(npc.m_flAttackHappens < GameTime && npc.m_flAttackHappens_bullshit >= GameTime && npc.m_flAttackHappenswillhappen)
					{
						Handle swingTrace;
						npc.FaceTowards(vecTarget, 30000.0);
						if(npc.DoSwingTrace(swingTrace, closest))
						{
							int target = TR_GetEntityIndex(swingTrace);	
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);
							if(target > 0) 
							{
								if(!ShouldNpcDealBonusDamage(target))
									SDKHooks_TakeDamage(target, npc.index, npc.index, 200.0, DMG_CLUB, -1, _, vecHit);
								else
									SDKHooks_TakeDamage(target, npc.index, npc.index, 120.0, DMG_CLUB, -1, _, vecHit);	
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
					else if(npc.m_flAttackHappens_bullshit < GameTime && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = GameTime + 0.74;
					}
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

static void Bastardzine_NPCDeath(int entity)
{
	Bastardzine npc = view_as<Bastardzine>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}


