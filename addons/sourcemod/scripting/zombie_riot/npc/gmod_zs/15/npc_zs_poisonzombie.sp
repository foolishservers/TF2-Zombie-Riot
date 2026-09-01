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

public void ZSPoisonZombie_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Poison Zombie");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_poisonzombie");
	strcopy(data.Icon, sizeof(data.Icon), "norm_poison_zombie");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_GmodZS;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
	
	strcopy(data.Name, sizeof(data.Name), "Poison Zombie");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_poisonheadcrab_zombie");
	strcopy(data.Icon, sizeof(data.Icon), "norm_poison_zombie_forti");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_GmodZS;
	data.Func = ClotSummon_ALT;
	NPC_Add(data);
	
	strcopy(data.Name, sizeof(data.Name), "Fortified Giant Poison Zombie");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_poisonzombie_fortified_giant");
	strcopy(data.Icon, sizeof(data.Icon), "norm_poison_zombie");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_GmodZS;
	data.Func = ClotSummon_Giant;
	NPC_Add(data);
	
	strcopy(data.Name, sizeof(data.Name), "Vile Poison Zombie");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_vile_poisonheadcrab_zombie");
	strcopy(data.Icon, sizeof(data.Icon), "norm_poison_zombie_forti");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_GmodZS;
	data.Func = ClotSummon_Vile;
	NPC_Add(data);
}

static void ClotPrecache()
{
	Zombie_Shared_PheromonePrecache();
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheSound("npc/assassin/ball_zap1.wav");
	PrecacheModel("models/zombie/poison.mdl");
}

static any ClotSummon_Vile(int client, float vecPos[3], float vecAng[3], int team)
{
	return ZSPoisonZombie(vecPos, vecAng, team, 3);
}
static any ClotSummon_Giant(int client, float vecPos[3], float vecAng[3], int team)
{
	return ZSPoisonZombie(vecPos, vecAng, team, 2);
}
static any ClotSummon_ALT(int client, float vecPos[3], float vecAng[3], int team)
{
	return ZSPoisonZombie(vecPos, vecAng, team, 1);
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ZSPoisonZombie(vecPos, vecAng, team, 0);
}

static char[] GetPoisonZombieHealth(int SelectInt)
{
	int health = 2400;
	switch(SelectInt)
	{
		case 1:health = 10800;
		case 2:health = 15000;
		case 3:health = 40000;
		default:health = 2400;
	}
	char buffer[16];
	IntToString(health, buffer, sizeof(buffer));
	return buffer;
}

methodmap ZSPoisonZombie < CClotBody
{
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _, (this.m_iOverlordComboAttack>=2 ? 80 : 100));
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _, (this.m_iOverlordComboAttack>=2 ? 80 : 100));
	}
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _, (this.m_iOverlordComboAttack>=2 ? 80 : 100));
	}
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _, (this.m_iOverlordComboAttack>=2 ? 80 : 100));
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _, (this.m_iOverlordComboAttack>=2 ? 80 : 100));
	}
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _, (this.m_iOverlordComboAttack>=2 ? 80 : 100));
	}
	
	public ZSPoisonZombie(float vecPos[3], float vecAng[3], int ally, int Alt)
	{
		ZSPoisonZombie npc = view_as<ZSPoisonZombie>(CClotBody(vecPos, vecAng, "models/zombie/poison.mdl", (Alt==2 ? "1.75" : "1.15"), GetPoisonZombieHealth(Alt), ally, _, (Alt==2 ? true : false)));
		
		i_NpcWeight[npc.index] = (Alt==2 ? 4 : 2);
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_WALK");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		func_NPCDeath[npc.index] = ZSPoisonZombie_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = ZSPoisonZombie_OnTakeDamage;
		func_NPCThink[npc.index] = ZSPoisonZombie_ClotThink;		
	
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_flAttackHappenswillhappen = false;
		switch(Alt)
		{
			case 1:npc.m_flSpeed = 260.0;
			case 2:npc.m_flSpeed = 231.0;
			case 3:
			{
				npc.m_flSpeed = 300.0;
				SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.index, 150, 255, 150, 255);
			}
			default:npc.m_flSpeed = 260.0;
		}
		npc.m_iOverlordComboAttack = Alt;
		npc.StartPathing();
		
		return npc;
	}
}

static void ZSPoisonZombie_ClotThink(int iNPC)
{
	ZSPoisonZombie npc = view_as<ZSPoisonZombie>(iNPC);
	SetVariantInt(((npc.m_iOverlordComboAttack==1||npc.m_iOverlordComboAttack==3) ? 1 : 0));
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
		if(!npc.m_flAttackHappenswillhappen)
			npc.AddGesture("ACT_SMALL_FLINCH", false);
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
		
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(PrimaryThreatIndex);
		}
		
		if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
		{
			if(npc.m_flNextMeleeAttack < GameTime)
			{
				//Play attack ani
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
					if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex,_,_,_,(npc.m_iOverlordComboAttack==2 ? 1 : 0)))
					{
						int target = TR_GetEntityIndex(swingTrace);
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						
						if(target > 0) 
						{
							float fDamage = 160.0;
							if(!ShouldNpcDealBonusDamage(target))
							{
								switch(npc.m_iOverlordComboAttack)
								{
									case 1:fDamage=380.0;
									case 2:fDamage=380.0;
									case 3:fDamage=400.0;
									default:fDamage=160.0;
								}
								SDKHooks_TakeDamage(target, npc.index, npc.index, fDamage, DMG_CLUB, -1, _, vecHit);
								Elemental_AddPheromoneDamage(target, npc.index, npc.m_iOverlordComboAttack==2 ? 500 : 50);
								if(npc.m_iOverlordComboAttack==2 && IsValidClient(target) && Armor_Charge[target] > 0)
								{
									Armor_Charge[target]=0;
									f_Armor_BreakSoundDelay[target] = GameTime + 5.0;	
									EmitSoundToClient(target, "npc/assassin/ball_zap1.wav", target, SNDCHAN_STATIC, 60, _, 1.0, GetRandomInt(95,105));
								}
							}
							else
							{
								switch(npc.m_iOverlordComboAttack)
								{
									case 1:fDamage=720.0;
									case 2:fDamage=720.0;
									case 3:fDamage=1000.0;
									default:fDamage=240.0;
								}
								SDKHooks_TakeDamage(target, npc.index, npc.index, fDamage, DMG_CLUB, -1, _, vecHit);
							}
							npc.PlayMeleeHitSound();
							int iHealthPost = GetEntProp(target, Prop_Data, "m_iHealth");
							if(iHealthPost <= 0) 
								npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST");
						} 
					}
					delete swingTrace;
					npc.m_flNextMeleeAttack = GameTime + (npc.m_iOverlordComboAttack>=2 ? 1.0 : 0.6);
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GameTime && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = GameTime + (npc.m_iOverlordComboAttack>=2 ? 1.0 : 0.6);
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

static Action ZSPoisonZombie_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker <= 0)
		return Plugin_Continue;
	
	ZSPoisonZombie npc = view_as<ZSPoisonZombie>(victim);
	if(npc.m_iOverlordComboAttack<2 && !NpcStats_IsEnemySilenced(victim))
	{
		if(!npc.bXenoInfectedSpecialHurt)
		{
			npc.bXenoInfectedSpecialHurt = true;
			npc.flXenoInfectedSpecialHurtTime = GetGameTime(npc.index) + 2.0;
			SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.index, 150, 255, 150, 65);
			CreateTimer(2.0, ZSPoisonZombie_Revert_Poison_Zombie_Resistance, EntIndexToEntRef(victim), TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(10.0, ZSPoisonZombie_Revert_Poison_Zombie_Resistance_Enable, EntIndexToEntRef(victim), TIMER_FLAG_NO_MAPCHANGE);
		}
		float TrueArmor = 1.0;
		if(!NpcStats_IsEnemySilenced(victim))
		{
			if(fl_TotalArmor[npc.index] == 1.0)
			{
				if(npc.flXenoInfectedSpecialHurtTime > GetGameTime(npc.index))
				{
					TrueArmor *= 0.25;
					fl_TotalArmor[npc.index] = TrueArmor;
					OnTakeDamageNpcBaseArmorLogic(victim, attacker, damage, damagetype, true);
				}
			}
		}
		fl_TotalArmor[npc.index] = TrueArmor;
	}
	
	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

static Action ZSPoisonZombie_Revert_Poison_Zombie_Resistance(Handle timer, int ref)
{
	int zombie = EntRefToEntIndex(ref);
	if(IsValidEntity(zombie))
	{
		SetEntityRenderMode(zombie, RENDER_NORMAL);
		SetEntityRenderColor(zombie, 255, 255, 255, 255);
	}
	return Plugin_Handled;
}

static Action ZSPoisonZombie_Revert_Poison_Zombie_Resistance_Enable(Handle timer, int ref)
{
	int zombie = EntRefToEntIndex(ref);
	if(IsValidEntity(zombie))
	{
		ZSPoisonZombie npc = view_as<ZSPoisonZombie>(zombie);
		npc.bXenoInfectedSpecialHurt = false;
	}
	return Plugin_Handled;
}

static void ZSPoisonZombie_NPCDeath(int entity)
{
	ZSPoisonZombie npc = view_as<ZSPoisonZombie>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	if(npc.m_iOverlordComboAttack==1 && !NpcStats_IsEnemySilenced(entity))
	{
		int maxhealth = ReturnEntityMaxHealth(npc.index);
		float startPosition[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", startPosition);
		maxhealth /= 2;
		for(int i; i<1; i++)
		{
			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
			
			int spawn_index = NPC_CreateByName("npc_zs_poisonheadcrab", -1, pos, ang, GetTeam(npc.index));
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