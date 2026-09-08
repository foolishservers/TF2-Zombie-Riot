#pragma semicolon 1
#pragma newdecls required

static const char g_BladeHitSounds[][] = {
	"weapons/blade_slice_2.wav",
	"weapons/blade_slice_3.wav",
	"weapons/blade_slice_4.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav"
};

static int ShieldCombine;

public void AltExtra_Mechanized_Wall_MapStart() {
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mechanized Wall");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mecha_wall");
	strcopy(data.Icon, sizeof(data.Icon), "alt_extra_mecha_wall");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Alt;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	ShieldCombine=NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_BladeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSound("vo/mvm/norm/taunts/heavy_mvm_taunts18.mp3");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team) {
	return AltExtra_Mechanized_Wall(vecPos, vecAng, team);
}

methodmap AltExtra_Mechanized_Wall < AltExtra_Base {
	public void PlayIdleSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_RobotHeavy_IdleSounds[GetRandomInt(0, sizeof(g_RobotHeavy_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayIdleAlertedSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll("vo/mvm/norm/taunts/heavy_mvm_taunts18.mp3", this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, .soundtime = GetGameTime() - 1.0);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound() {
		if (this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		EmitSoundToAll(g_RobotHeavy_HurtSounds[GetRandomInt(0, sizeof(g_RobotHeavy_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() {
		EmitSoundToAll(g_RobotHeavy_DeathSounds[GetRandomInt(0, sizeof(g_RobotHeavy_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_BladeHitSounds[GetRandomInt(0, sizeof(g_BladeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeAttackSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}

	property int m_iPowerUp
	{
		public get()							{ return i_OverlordComboAttack[this.index]; }
		public set(int TempValueForProperty) 	{ i_OverlordComboAttack[this.index] = TempValueForProperty; }
	}
	
	public AltExtra_Mechanized_Wall(float vecPos[3], float vecAng[3], int team)
	{
		AltExtra_Mechanized_Wall npc = view_as<AltExtra_Mechanized_Wall>(CClotBody(vecPos, vecAng, "models/bots/demo/bot_demo.mdl", "1.0", "15000", team));
		
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_flAttackHappens_bullshit = 0.0;
		
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCDeath[npc.index] = AltExtra_Mechanized_Wall_NPCDeath;
		func_NPCThink[npc.index] = AltExtra_Mechanized_Wall_ClotThink;
		
		KillFeed_SetKillIcon(npc.index, "claidheamohmor");
		
		npc.m_flSpeed = 300.0;
		npc.m_flRangedArmor = 0.75;
		npc.m_flMeleeArmor = 0.75;
		npc.m_iChanged_WalkCycle = -1;
		npc.m_iPowerUp = 0;
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		npc.SetActivity("ACT_MP_RUN_MELEE");
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/bots/heavy/bot_heavy.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_persian_shield/c_persian_shield.mdl");
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/pyro/dec23_impact_impaler/dec23_impact_impaler.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/engineer/hwn2025_heat_shield_style2/hwn2025_heat_shield_style2.mdl");
		
		int skin = (team == TFTeam_Red) ? 0 : 1;
		SetEntityRenderMode(npc.index, RENDER_NONE);
		SetEntityRenderColor(npc.index, 0, 0, 0, 0);
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetVariantString("1.5");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 125, 125, 125, 255);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		NpcColourCosmetic_ViaPaint(npc.m_iWearable4, 4360181);
		NpcColourCosmetic_ViaPaint(npc.m_iWearable5, 16777215);
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		return npc;
	}
}

static void AltExtra_Mechanized_Wall_ClotThink(int iNPC) {
	AltExtra_Mechanized_Wall npc = view_as<AltExtra_Mechanized_Wall>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	float vecTarget[3], VecSelfNpc[3];
	WorldSpaceCenter(npc.index, VecSelfNpc);
	int getCount;
	for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
		if(IsValidEntity(entity) && entity!=npc.index && !b_NpcHasDied[entity]
		&& GetTeam(entity) == GetTeam(npc.index) && i_NpcInternalId[entity] == ShieldCombine)
		{
			WorldSpaceCenter(entity, vecTarget);
			if(GetVectorDistance(vecTarget, VecSelfNpc, true)<62500.0) //250*250
				getCount++;
		}
	}
	if(getCount)
	{
		npc.m_iPowerUp = getCount;
		if(getCount>12)
			getCount=12;
		npc.m_flRangedArmor = 0.75 - (0.825*(0.05*getCount));
		npc.m_flMeleeArmor = 0.75 - (0.75*(0.05*getCount));
		npc.m_flSpeed = 300.0-(8.33*getCount);
	}
	else
	{
		npc.m_flSpeed = 300.0;
		npc.m_flRangedArmor = 0.75;
		npc.m_flMeleeArmor = 0.75;
	}
	
	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		if(npc.m_iChanged_WalkCycle != 1)
		{
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 1;
			npc.SetActivity("ACT_MP_RUN_ITEM1");
			npc.StartPathing();
		}
		WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
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
		AltExtra_Mechanized_Wall_AttackLogic(npc, gameTime, vecTarget, flDistanceToTarget); 
		npc.PlayIdleAlertedSound();
	}
	else
	{
		if(npc.m_iChanged_WalkCycle != 0)
		{
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 0;
			npc.SetActivity("ACT_MP_STAND_ITEM1");
			npc.StopPathing();
		}
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.PlayIdleSound();
	}
}

static void AltExtra_Mechanized_Wall_AttackLogic(AltExtra_Mechanized_Wall npc, float gameTime, float vecTarget[3], float distance)
{
	if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
	{
		if(npc.m_flNextMeleeAttack < gameTime)
		{
			if(!npc.m_flAttackHappenswillhappen)
			{
				npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM1");
				npc.m_flAttackHappens = gameTime+0.4;
				npc.m_flAttackHappens_bullshit = gameTime+0.54;
				npc.m_flAttackHappenswillhappen = true;
				npc.PlayMeleeAttackSound();
			}
			if(npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen)
			{
				Handle swingTrace;
				npc.FaceTowards(vecTarget, 20000.0);	
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
				{
					int target = TR_GetEntityIndex(swingTrace);
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if(IsValidEnemy(npc.index, target))
					{
						float damageDealt = 65.0;
						if(NpcStats_VestanCallToArms(npc.index))
							damageDealt *= 3.0;
						if(npc.m_iPowerUp)
							damageDealt *= 1.0 + (0.076*npc.m_iPowerUp);
						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
						npc.PlayMeleeHitSound();	
					}
				}
				delete swingTrace;
				npc.m_flNextMeleeAttack = gameTime + 0.8;
				npc.m_flAttackHappenswillhappen = false;
			}
			else if(npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen)
			{
				npc.m_flAttackHappenswillhappen = false;
				npc.m_flNextMeleeAttack = gameTime + 0.8;
			}
		}
	}
}

static void AltExtra_Mechanized_Wall_NPCDeath(int iNPC)
{
	AltExtra_Mechanized_Wall npc = view_as<AltExtra_Mechanized_Wall>(iNPC);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
}