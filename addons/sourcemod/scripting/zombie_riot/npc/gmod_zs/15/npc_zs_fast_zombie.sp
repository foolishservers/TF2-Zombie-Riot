#pragma semicolon 1
#pragma newdecls required

static char g_IdleAlertedSounds[][] = {
	"npc/fast_zombie/fz_alert_close1.wav",
	"npc/fast_zombie/fz_alert_far1.wav",
};

static char g_MeleeHitSounds[][] = {
	"npc/fast_zombie/claw_strike1.wav",
	"npc/fast_zombie/claw_strike2.wav",
	"npc/fast_zombie/claw_strike3.wav",
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

static char g_MeleeAttackSounds[] = "zombie_riot/gmod_zs/fast/gurgle.wav";
static char g_DeathSounds[] = "npc/fast_zombie/wake1.wav";
static char g_HurtSounds[] = "npc/fast_zombie/wake1.wav";
static char g_leap_prepare[] = "npc/fast_zombie/leap1.wav";
static char g_leap_scream[] = "npc/fast_zombie/fz_scream1.wav";

public void ZSFastZombie_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Fast Zombie");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_fast_zombie");
	strcopy(data.Icon, sizeof(data.Icon), "norm_fast_zombie");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_GmodZS;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
	
	strcopy(data.Name, sizeof(data.Name), "Fast Zombie");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_fastheadcrab_zombie");
	strcopy(data.Icon, sizeof(data.Icon), "norm_fast_zombie_forti");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_GmodZS;
	data.Func = ClotSummon_ALT;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_PlayMeleeJumpPrepare);
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheSoundArray(g_PlayMeleeJumpSound);
	PrecacheSound(g_MeleeAttackSounds);
	PrecacheSound(g_DeathSounds);
	PrecacheSound(g_HurtSounds);
	PrecacheSound(g_leap_prepare);
	PrecacheSound(g_leap_scream);
	PrecacheModel("models/zombie_riot/gmod_zs/zs_zombie_models_1_1.mdl");
}

static any ClotSummon_ALT(int client, float vecPos[3], float vecAng[3], int team)
{
	return ZSFastZombie(vecPos, vecAng, team, true);
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ZSFastZombie(vecPos, vecAng, team, false);
}

methodmap ZSFastZombie < CClotBody
{
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
	}
	public void PlayLeapPrepare() {
		EmitSoundToAll(g_leap_prepare, this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayLeapDone() {
		EmitSoundToAll(g_leap_scream, this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
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
		EmitSoundToAll(g_HurtSounds, this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds, this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds, this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public ZSFastZombie(float vecPos[3], float vecAng[3], int ally, bool Alt)
	{
		ZSFastZombie npc = view_as<ZSFastZombie>(CClotBody(vecPos, vecAng, "models/zombie_riot/gmod_zs/zs_zombie_models_1_1.mdl", "1.15", (Alt ? "3200" : "700"), ally, false));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_HL2MP_RUN_ZOMBIE_FAST");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		func_NPCDeath[npc.index] = ZSFastZombie_NPCDeath;
		func_NPCThink[npc.index] = ZSFastZombie_ZSFastZombieThink;	
		func_NPCOnTakeDamage[npc.index] = ZSFastZombie_OnTakeDamage;	
		
		SetEntityRenderMode(npc.index, RENDER_NORMAL);
		SetEntityRenderColor(npc.index, 255, 165, 0, 255);
		
		//IDLE
		npc.m_flSpeed = 400.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flJumpCooldown = GetGameTime(npc.index) + 3.0;
		npc.m_flInJump = 0.0;
		
		npc.StartPathing();

		f_MaxAnimationSpeed[npc.index] = 1.5;
		
		npc.m_bFUCKYOU = Alt;
		if(Alt)
		{
			npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/zombie_riot/gmod_zs/zs_zombie_models_1_1.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		}
		
		return npc;
	}
}

static void ZSFastZombie_ZSFastZombieThink(int iNPC)
{
	ZSFastZombie npc = view_as<ZSFastZombie>(iNPC);
	
	float GameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GameTime)
		return;
	
	SetEntProp(npc.index, Prop_Send, "m_nBody", GetEntProp(npc.index, Prop_Send, "m_nBody"));
	SetVariantInt(4);
	AcceptEntityInput(iNPC, "SetBodyGroup");
	
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
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);		
		
		if(npc.m_flJumpCooldown < GameTime && npc.m_flInJump < GameTime && flDistanceToTarget > NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED
		&& flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0)
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
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius()) {
			
			float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
			
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(PrimaryThreatIndex);
		}
		//Target close enough to hit
		if(flDistanceToTarget < 10000)
		{
			//Look at target so we hit.
		//	npc.FaceTowards(vecTarget, 1000.0);
			
			//Can we attack right now?
			if(npc.m_flNextMeleeAttack < GameTime)
			{
				//Play attack anim
				npc.AddGesture("ACT_GMOD_GESTURE_RANGE_FRENZY");
				
				Handle swingTrace;
				npc.FaceTowards(vecTarget, 20000.0);
				if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex))
				{
						
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if(target > 0) 
					{
						if(!ShouldNpcDealBonusDamage(target))
							SDKHooks_TakeDamage(target, npc.index, npc.index, (npc.m_bFUCKYOU ? 60.0 : 30.0), DMG_CLUB, -1, _, vecHit);
						else
							SDKHooks_TakeDamage(target, npc.index, npc.index, (npc.m_bFUCKYOU ? 100.0 : 50.0), DMG_CLUB, -1, _, vecHit);
						
						npc.PlayMeleeSound();
						npc.PlayMeleeHitSound();
					} 
				}
				delete swingTrace;
				npc.m_flNextMeleeAttack = GameTime + 0.32;
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

static Action ZSFastZombie_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	ZSFastZombie npc = view_as<ZSFastZombie>(victim);
	
	if(!NpcStats_IsEnemySilenced(victim))
	{
		if(!npc.bXenoInfectedSpecialHurt)
		{
			npc.bXenoInfectedSpecialHurt = true;
			SetEntityRenderMode(npc.index, RENDER_NORMAL);
			SetEntityRenderColor(npc.index, 255, 255, 255, 255);
			damage = 0.0;
			EmitSoundToAll("physics/metal/metal_box_impact_bullet1.wav", attacker, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, 0.5);
			return Plugin_Changed;
		}
	}
	
	/*
	if(attacker > MaxClients && !IsValidEnemy(npc.index, attacker))
		return Plugin_Continue;
	*/
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.PlayHurtSound();
		
	}
	
	return Plugin_Changed;
}

static void ZSFastZombie_NPCDeath(int entity)
{
	ZSFastZombie npc = view_as<ZSFastZombie>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();	
	if(npc.m_bFUCKYOU)
	{
		if(IsValidEntity(npc.m_iWearable1))
			RemoveEntity(npc.m_iWearable1);
		if(!NpcStats_IsEnemySilenced(entity))
		{
			int maxhealth = ReturnEntityMaxHealth(npc.index);
			float startPosition[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", startPosition);
			maxhealth /= 2;
			for(int i; i<1; i++)
			{
				float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
				float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
				
				int spawn_index = NPC_CreateByName("npc_zs_fast_headcrab", -1, pos, ang, GetTeam(npc.index));
				if(spawn_index > MaxClients)
				{
					NpcStats_CopyStats(npc.index, spawn_index);
					NpcAddedToZombiesLeftCurrently(spawn_index, true);
					SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
					SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
				}
			}
		}
	}
}


