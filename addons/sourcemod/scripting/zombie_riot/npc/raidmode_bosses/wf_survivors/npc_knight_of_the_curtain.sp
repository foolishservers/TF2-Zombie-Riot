#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav",
};

static const char g_HurtSounds[][] = {
	"npc/combine_soldier/pain1.wav",
	"npc/combine_soldier/pain2.wav",
	"npc/combine_soldier/pain3.wav",
};

static const char g_IdleSounds[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/halloween_boss/knight_axe_hit.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};

static const char g_RangedAttackSounds[][] = {
	"npc/vort/attack_shoot.wav",
};

static const char g_RangedAttackSoundsSecondary[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav",
};

static const char g_RangedReloadSound[][] = {
	"weapons/ar2/npc_ar2_reload.wav",
};

void RaidbossKnightOfTheCurtain_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_DefaultMeleeMissSounds));   i++) { PrecacheSound(g_DefaultMeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) { PrecacheSound(g_RangedReloadSound[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSoundsSecondary));   i++) { PrecacheSound(g_RangedAttackSoundsSecondary[i]);   }
	
	PrecacheModel(COMBINE_CUSTOM_MODEL);
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Knight of the Curtain");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_knight_of_the_curtain");
	strcopy(data.Icon, sizeof(data.Icon), "demoknight");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Curtain;
	data.Func = ClotSummon;
	NPC_Add(data);
	
	strcopy(data.Name, sizeof(data.Name), "Servant of the Curtain");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_servant_of_the_curtain");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Curtain;
	data.Func = Servant_ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return RaidbossKnightOfTheCurtain(vecPos, vecAng, team, data);
}

static any Servant_ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return ServantOfTheCurtain(vecPos, vecAng, team, data);
}

methodmap RaidbossKnightOfTheCurtain < CClotBody {
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayRangedAttackSecondarySound() {
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_DefaultMeleeMissSounds[GetRandomInt(0, sizeof(g_DefaultMeleeMissSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	property int m_iSummonType
	{
		public get()			{	return this.m_iMedkitAnnoyance;	}
		public set(int value) 	{	this.m_iMedkitAnnoyance = value;	}
	}
	
	property float m_flNextGroupAttackTime
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	property float m_flNextSummonTime
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	
	public RaidbossKnightOfTheCurtain(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		RaidbossKnightOfTheCurtain npc = view_as<RaidbossKnightOfTheCurtain>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "240000", ally));
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		i_NpcWeight[npc.index] = 4;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		//RaidBossActive = EntIndexToEntRef(npc.index);
		//RaidAllowsBuildings = false;
		//RaidAllowLastman = true;
		
		npc.SetActivity("ACT_GENERAL_WALK");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		func_NPCDeath[npc.index] = RaidbossKnightOfTheCurtain_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = RaidbossKnightOfTheCurtain_OnTakeDamage;
		func_NPCThink[npc.index] = RaidbossKnightOfTheCurtain_ClotThink;
		func_NPCFuncWin[npc.index] = RaidbossKnightOfTheCurtain_Win;
		
		npc.m_flSpeed = 315.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		
		npc.g_TimesSummoned = 0;
		npc.m_iSummonType = 0;
		
		npc.m_flNextSummonTime = GetGameTime(npc.index) + 5.0;
		npc.m_flNextGroupAttackTime = GetGameTime(npc.index) + 3.0;
		
		AlreadySaidWin = false;
		BlockLoseSay = false;
		
		// Raid setting.
		RaidModeTime = GetGameTime() + 300.0;
		
		char buffers[3][64];
		ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
		//the very first and 2nd char are SC for scaling
		if(buffers[0][0] == 's' && buffers[0][1] == 'c')
		{
			//remove SC
			ReplaceString(buffers[0], 64, "sc", "");
			float value = StringToFloat(buffers[0]);
			RaidModeScaling = value;
		}
		else
		{	
			RaidModeScaling = float(Waves_GetRoundScale()+1);
		}

		if(RaidModeScaling < 35)
		{
			RaidModeScaling *= 0.25; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.5;
		}
		
		float amount_of_people = ZRStocks_PlayerScalingDynamic();
		if(amount_of_people > 12.0)
		{
			amount_of_people = 12.0;
		}
		amount_of_people *= 0.12;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;

		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
		RaidModeScaling *= 0.85;
		
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		RaidAllowLastman = true;
		
		Citizen_MiniBossSpawn();
		
		b_thisNpcIsARaid[npc.index] = true;
		b_thisNpcIsABoss[npc.index] = true;
		
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "KnightOfTheCurtain_Encounter_Text");
			}
		}
		
		RaidbossKnightOfTheCurtain_NPCTalkMessage(npc.index, "KnightOfTheCurtain_Encounter_%d", true, GetRandomInt(1, 2));
				
		// Wearable.
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", RUINA_CUSTOM_MODELS_2);
		SetVariantInt(RUINA_BLADE_3);
		AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
		
		npc.m_iWearable2 = npc.EquipItemSeperate("models/workshop/player/items/demo/hwn2023_blastphomet/hwn2023_blastphomet.mdl", .model_size = 1.3);
		SetVariantString("partyhat");
		AcceptEntityInput(npc.m_iWearable2, "SetParentAttachmentMaintainOffset"); 
		
		SDKCall_SetLocalAngles(npc.m_iWearable2, {90.0, 0.0, 90.0});
		SDKCall_SetLocalOrigin(npc.m_iWearable2, {0.0, 97.0, 0.0});
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/soldier/bak_caped_crusader/bak_caped_crusader.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		TE_SetupParticleEffect("utaunt_cremation_purple_parent", PATTACH_ABSORIGIN_FOLLOW, npc.m_iWearable3);
		TE_WriteNum("m_bControlPoint1", npc.m_iWearable3);	
		TE_SendToAll();
		
		npc.StartPathing();
		
		return npc;
	}
}

static void RaidbossKnightOfTheCurtain_NPCTalkMessage(int entity, const char[] message, bool translated = false, any ...)
{
	char buffer[256];
	VFormat(buffer, sizeof(buffer), message, 4);
	PrintNPCMessageWithPrefixes(entity, "crimson", buffer, translated);
}

static void RaidbossKnightOfTheCurtain_ClotThink(int entity)
{
	RaidbossKnightOfTheCurtain npc = view_as<RaidbossKnightOfTheCurtain>(entity);
	
	float gameTime = GetGameTime(npc.index);
	
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(LastMann && !npc.m_fbGunout)
	{
		npc.m_fbGunout = true;
		RaidbossKnightOfTheCurtain_NPCTalkMessage(npc.index, "KnightOfTheCurtain_LastMann_%d", true, GetRandomInt(1, 2));
	}
	
	if(IsValidEntity(RaidBossActive) && RaidModeTime < GetGameTime())
	{
		if(RaidModeTime < GetGameTime())
		{
			ForcePlayerLoss();
			RaidBossActive = INVALID_ENT_REFERENCE;
			
			BlockLoseSay = true;
			
			RaidbossKnightOfTheCurtain_NPCTalkMessage(npc.index, "KnightOfTheCurtain_TimeOver_%d", true, GetRandomInt(1, 2));
			
			func_NPCThink[npc.index] = INVALID_FUNCTION;
			
			return;
		}
	}
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}

	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	// Don't allow special attack while attacking someone.
	if(!npc.m_flAttackHappenswillhappen)
	{
		if (RaidbossKnightOfTheCurtain_SummonServant(npc.index))
			return;
		
		if (RaidbossKnightOfTheCurtain_GroupAttack(npc.index))
			return;
	}
	
	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		RaidbossKnightOfTheCurtain_AttackThink(npc, gameTime, PrimaryThreatIndex);
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

static Action RaidbossKnightOfTheCurtain_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (attacker < 0)
		return Plugin_Continue;
	
	RaidbossKnightOfTheCurtain npc = view_as<RaidbossKnightOfTheCurtain>(victim);
	
	float gameTime = GetGameTime(npc.index);
	
	if(npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	if(!npc.Anger)
	{
		if(GetEntProp(npc.index, Prop_Data, "m_iHealth") <= (ReturnEntityMaxHealth(npc.index) / 2))
		{
			npc.Anger = true;
			npc.m_flSpeed = 340.0;
			RaidbossKnightOfTheCurtain_NPCTalkMessage(npc.index, "KnightOfTheCurtain_Anger_%d", true, GetRandomInt(1, 2));
		}
	}
	
	return Plugin_Continue;
}

static void RaidbossKnightOfTheCurtain_NPCDeath(int entity)
{
	RaidbossKnightOfTheCurtain npc = view_as<RaidbossKnightOfTheCurtain>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int other = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(other != INVALID_ENT_REFERENCE && other != npc.index)
		{
			ServantOfTheCurtain npc2 = view_as<ServantOfTheCurtain>(other);
			if(npc2.m_bOwner == npc.index)
			{
				SmiteNpcToDeath(other);
			}
		}
	}
	
	if(BlockLoseSay)
		return;
	
	RaidbossKnightOfTheCurtain_NPCTalkMessage(npc.index, "KnightOfTheCurtain_Death_%d", true, GetRandomInt(1, 2));
}

static void RaidbossKnightOfTheCurtain_Win(int entity)
{
	i_RaidGrantExtra[entity] = RAIDITEM_INDEX_WIN_COND;
	func_NPCThink[entity] = INVALID_FUNCTION;
	
	if(AlreadySaidWin)
		return;

	AlreadySaidWin = true;
	BlockLoseSay = true;
	
	RaidbossKnightOfTheCurtain npc = view_as<RaidbossKnightOfTheCurtain>(entity);
	if (npc.Anger)
	{
		RaidbossKnightOfTheCurtain_NPCTalkMessage(npc.index, "KnightOfTheCurtain_Win_Anger", true);
	}
	else
	{
		RaidbossKnightOfTheCurtain_NPCTalkMessage(npc.index, "KnightOfTheCurtain_Win", true);
	}
}

static void RaidbossKnightOfTheCurtain_AttackThink(RaidbossKnightOfTheCurtain npc, float gameTime, int primaryThreatIndex)
{
	float vecTarget[3]; 
	WorldSpaceCenter(primaryThreatIndex, vecTarget);
	float VecSelfNpc[3];
	WorldSpaceCenter(npc.index, VecSelfNpc);
	
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
	
	//Predict their pos.
	if(flDistanceToTarget < npc.GetLeadRadius()) {
		float vPredictedPos[3];
		PredictSubjectPosition(npc, primaryThreatIndex,_,_, vPredictedPos);
		npc.SetGoalVector(vPredictedPos);
	} else {
		npc.SetGoalEntity(primaryThreatIndex);
	}
	
	//Target close enough to hit
	if((flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flReloadDelay < gameTime) || npc.m_flAttackHappenswillhappen)
	{
		//	npc.FaceTowards(vecTarget, 1000.0);
		if(npc.m_flNextMeleeAttack < gameTime)
		{
			if (npc.m_iOverlordComboAttack == 2)
			{
				if (!npc.m_flAttackHappenswillhappen)
				{
					//npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 2.0;
					
					npc.PlayRangedSound();
					if(npc.Anger)
					{
						npc.AddGesture("ACT_GENERAL_ATTACK_OVERHEAD", .SetGestureSpeed = 2.0);
						npc.m_flAttackHappens = gameTime + 0.2;
						npc.m_flAttackHappens_bullshit = gameTime + 0.27;
					}
					else
					{
						npc.AddGesture("ACT_GENERAL_ATTACK_OVERHEAD");
						npc.m_flAttackHappens = gameTime + 0.4;
						npc.m_flAttackHappens_bullshit = gameTime + 0.54;
					}
					
					npc.m_flAttackHappenswillhappen = true;
				}
				
				if (npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen)
				{
					float DamageCalc = 50.0;
					DamageCalc *= RaidModeScaling;
					
					// basically oneshots
					NemalAirSlice(npc.index, primaryThreatIndex, DamageCalc, 255, 125, 125, 300.0, 8, 1200.0, "raygun_projectile_red", false, true, false);
					
					npc.m_flAttackHappenswillhappen = false;
					if(npc.Anger)
					{
						npc.m_flNextMeleeAttack = gameTime + 1.5;
					}
					else
					{
						npc.m_flNextMeleeAttack = gameTime + 3.0;
					}
					
					npc.m_iOverlordComboAttack = 0;
				}
				else if (npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					if(npc.Anger)
					{
						npc.m_flNextMeleeAttack = gameTime + 1.5;
					}
					else
					{
						npc.m_flNextMeleeAttack = gameTime + 3.0;
					}
					
					npc.m_iOverlordComboAttack = 0;
				}
			}
			else
			{
				if (!npc.m_flAttackHappenswillhappen)
				{
					//npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 2.0;
					
					npc.PlayMeleeSound();
					if(npc.Anger)
					{
						npc.AddGesture("ACT_GENERAL_ATTACK_POKE", .SetGestureSpeed = 2.0);
						npc.m_flAttackHappens = gameTime + 0.2;
						npc.m_flAttackHappens_bullshit = gameTime + 0.27;
					}
					else
					{
						npc.AddGesture("ACT_GENERAL_ATTACK_POKE");
						npc.m_flAttackHappens = gameTime + 0.4;
						npc.m_flAttackHappens_bullshit = gameTime + 0.54;
					}
					
					npc.m_flAttackHappenswillhappen = true;
				}
					
				if (npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen)
				{
					Handle swingTrace;
					npc.FaceTowards(vecTarget, 20000.0);
					if(npc.DoSwingTrace(swingTrace, primaryThreatIndex))
					{
						int target = TR_GetEntityIndex(swingTrace);	
						
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						
						if(target > 0) 
						{
							float damage = 40.0;
							SDKHooks_TakeDamage(target, npc.index, npc.index, damage * RaidModeScaling, DMG_CLUB, -1, _, vecHit);
							
							if (IsValidClient(target))
							{
								TF2_AddCondition(target, TFCond_LostFooting, 0.5);
								TF2_AddCondition(target, TFCond_AirCurrent, 0.5);
							}
							Custom_Knockback(npc.index, target, 450.0, true);
							
							// Hit particle
							
							// Hit sound
							npc.PlayMeleeHitSound();
						}
					}
					delete swingTrace;
					
					if(npc.Anger)
					{
						npc.m_flNextMeleeAttack = gameTime + 0.5;
					}
					else
					{
						npc.m_flNextMeleeAttack = gameTime + 1.0;
					}
					
					npc.m_flAttackHappenswillhappen = false;
					
					npc.m_iOverlordComboAttack++;
				}
				else if (npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = gameTime + 1.0;
					
					npc.m_iOverlordComboAttack++;
				}
			}
		}
	}
	
	if (npc.m_flReloadDelay < gameTime)
	{
		npc.StartPathing();
	}
}

static bool RaidbossKnightOfTheCurtain_SummonServant(int entity)
{
	RaidbossKnightOfTheCurtain npc = view_as<RaidbossKnightOfTheCurtain>(entity);
	
	float gameTime = GetGameTime(npc.index);
	if (npc.m_flNextSummonTime > gameTime)
		return false;
	
	if(npc.g_TimesSummoned >= 12)
	{
		// Wait until servant dies.
		npc.m_flNextSummonTime = GetGameTime(npc.index) + 2.0;
	}
	
	if(npc.Anger)
	{
		npc.m_flNextSummonTime = GetGameTime(npc.index) + 20.0;
	}
	else
	{
		npc.m_flNextSummonTime = GetGameTime(npc.index) + 30.0;
	}
	
	float flPos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", flPos);
	flPos[2] += 45;
	ParticleEffectAt(flPos, "eyeboss_tp_vortex", 1.0);
	
	//players only
	float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
	
	char buffer[64];
	switch (npc.m_iSummonType)
	{
		case 1:
		{
			buffer = "pickaxe";
		}
	}
	
	npc.m_iSummonType = npc.m_iSummonType == 1 ? 0 : 1;
	
	RaidbossKnightOfTheCurtain_NPCTalkMessage(npc.index, "KnightOfTheCurtain_Summon_Servant_%d", true, GetRandomInt(1, 3));
	
	int summon = min(12 - npc.g_TimesSummoned, 3);
	for (int i; i < summon; i++)
	{
		int servant = NPC_CreateByName("npc_servant_of_the_curtain", -1, pos, ang, GetTeam(npc.index), buffer);
		if (IsValidEntity(servant))
		{
			if(GetTeam(npc.index) != TFTeam_Red)
				Zombies_Currently_Still_Ongoing++;
			
			ServantOfTheCurtain npc2 = view_as<ServantOfTheCurtain>(servant);
			npc2.m_bOwner = entity;
			npc.g_TimesSummoned++;
			
			flPos = pos;
			flPos[2] += 400.0;
			flPos[0] += GetRandomInt(0,1) ? GetRandomFloat(-200.0, -100.0) : GetRandomFloat(100.0, 200.0);
			flPos[1] += GetRandomInt(0,1) ? GetRandomFloat(-200.0, -100.0) : GetRandomFloat(200.0, 200.0);
			npc.SetVelocity({0.0,0.0,0.0});
			PluginBot_Jump(servant, flPos);
		}
	}
	
	return true;
}

static bool RaidbossKnightOfTheCurtain_GroupAttack(int entity)
{
	RaidbossKnightOfTheCurtain npc = view_as<RaidbossKnightOfTheCurtain>(entity);
	
	if(npc.m_flNextGroupAttackTime > GetGameTime(npc.index))
		return false;
	
	if(npc.Anger)
	{
		npc.m_flNextGroupAttackTime = GetGameTime(npc.index) + 10.0;
	}
	else
	{
		npc.m_flNextGroupAttackTime = GetGameTime(npc.index) + 16.0;
	}
	
	RaidbossKnightOfTheCurtain_NPCTalkMessage(npc.index, "KnightOfTheCurtain_GroupAttack_%d", true, GetRandomInt(1, 3));
	
	npc.AddGesture("ACT_GENERAL_ATTACK_OVERHEAD");
	npc.PlayMeleeSound();
	
	UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
	int enemy[RAIDBOSS_GLOBAL_ATTACKLIMIT]; 
	//It should target upto 20 people only, if its anymore it starts becomming un dodgeable due to the nature of AOE laser attacks
	GetHighDefTargets(npcGetInfo, enemy, sizeof(enemy), true, false, npc.index);
	
	ResetTEStatusSilvester();
	SetSilvesterPillarColour({125, 0, 125, 200});
	
	float vecHitPart[3];
	npc.GetAttachment("anim_attachment_RH", vecHitPart, NULL_VECTOR);
	
	for(int i; i < sizeof(enemy); i++)
	{
		if(enemy[i])
		{
			int target = enemy[i];
			
			float vecHit[3];
			WorldSpaceCenter(target, vecHit);
			
			int projectile = npc.FireParticleRocket(vecHit, 0.0, 700.0, 1.0, "spell_teleport_black", false,_,true, vecHitPart);
			WandProjectile_ApplyFunctionToEntity(projectile, RaidbossKnightOfTheCurtain_ProjectileTouch);
			
			static float ang_Look[3];
			GetEntPropVector(projectile, Prop_Send, "m_angRotation", ang_Look);
			Initiate_HomingProjectile(projectile,
			npc.index,
				180.0,			// float lockonAngleMax,
				10.0,				//float homingaSec,
				true,				// bool LockOnlyOnce,
				true,				// bool changeAngles,
				ang_Look,			
				target); //home onto this enemy
			CreateTimer(4.0, Chimera_Removehoming, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	
	return true;
}

static void RaidbossKnightOfTheCurtain_ProjectileTouch(int entity, int target)
{
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	if (IsValidEntity(particle)) {
		RemoveEntity(particle);
	}
	
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (!IsValidEntity(owner)) {
		RemoveEntity(entity);
		return;
	}
	
	float pos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
	float ang_Look[3];
	GetEntPropVector(owner, Prop_Data, "m_angRotation", ang_Look);
	
	float damageDealt = 35.0 * RaidModeScaling;
	float QuakeSize = 1.2;
	float ReactionTime = 0.75;
	
	Silvester_Damaging_Pillars_Ability(owner, damageDealt, 0, ReactionTime, 1.0, ang_Look, pos, 0.35, QuakeSize);
	
	EmitSoundToAll("npc/env_headcrabcanister/explosion.wav", 0, _, 80, _, 0.8, 130, _, pos);
	EmitSoundToAll("npc/env_headcrabcanister/explosion.wav", 0, _, 80, _, 0.8, 130, _, pos);
	
	RemoveEntity(entity);
}

methodmap ServantOfTheCurtain < CClotBody {
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_DefaultMeleeMissSounds[GetRandomInt(0, sizeof(g_DefaultMeleeMissSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	property int m_bOwner {
		public get() {
			int returnint = EntRefToEntIndex(i_ally_index[this.index]);
			if(returnint == -1)
			{
				return 0;
			}
			
			return returnint;
		}
		public set(int iInt) {
			if(iInt == 0 || iInt == -1 || iInt == INVALID_ENT_REFERENCE)
			{
				i_ally_index[this.index] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_ally_index[this.index] = EntIndexToEntRef(iInt);
			}
		}
	}
	
	public ServantOfTheCurtain(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		ServantOfTheCurtain npc = view_as<ServantOfTheCurtain>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "10000", ally));
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE_METRO;
		
		npc.m_bDissapearOnDeath = true;
		
		npc.m_iState = 0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		
		if (StrEqual(data, "pickaxe"))
		{
			npc.SetActivity("ACT_ACHILLES_RUN_DAGGER");
			
			npc.m_flSpeed = 300.0;
			
			func_NPCDeath[npc.index] = ServantOfTheCurtain_NPCDeath;
			func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
			func_NPCThink[npc.index] = ServantOfTheCurtain_Pickaxe_ClotThink;
			
			npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_pickaxe/c_pickaxe.mdl");
			
			npc.m_iWearable2 = npc.EquipItemSeperate("models/workshop/player/items/demo/hwn2023_blastphomet/hwn2023_blastphomet.mdl", .model_size = 1.3);
			SetVariantString("partyhat");
			AcceptEntityInput(npc.m_iWearable2, "SetParentAttachmentMaintainOffset"); 
			
			SDKCall_SetLocalAngles(npc.m_iWearable2, {90.0, 0.0, 90.0});
			SDKCall_SetLocalOrigin(npc.m_iWearable2, {0.0, 97.0, 0.0});
			
			//TE_SetupParticleEffect("utaunt_cremation_purple_parent", PATTACH_ABSORIGIN_FOLLOW, npc.index);
			//TE_WriteNum("m_bControlPoint1", npc.index);	
			//TE_SendToAll();
			
			SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.index, 0, 0, 0, 150);
			
			SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable1, 0, 0, 0, 150);
			
			SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable2, 0, 0, 0, 150);
		}
		else
		{
			int iActivity = npc.LookupActivity("ACT_BRAWLER_RUN");
			if (iActivity > 0)
				npc.StartActivity(iActivity);
			
			npc.m_flSpeed = 330.0;
			npc.m_flMeleeArmor = 1.25;
			
			func_NPCDeath[npc.index] = ServantOfTheCurtain_NPCDeath;
			func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
			func_NPCThink[npc.index] = ServantOfTheCurtain_Warrior_ClotThink;
			
			npc.m_iWearable1 = npc.EquipItem("weapon_bone", RUINA_CUSTOM_MODELS_2);
			SetVariantInt(RUINA_BLADE_3);
			AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
			
			npc.m_iWearable2 = npc.EquipItemSeperate("models/workshop/player/items/demo/hwn2023_blastphomet/hwn2023_blastphomet.mdl", .model_size = 1.3);
			SetVariantString("partyhat");
			AcceptEntityInput(npc.m_iWearable2, "SetParentAttachmentMaintainOffset"); 
			
			SDKCall_SetLocalAngles(npc.m_iWearable2, {90.0, 0.0, 90.0});
			SDKCall_SetLocalOrigin(npc.m_iWearable2, {0.0, 97.0, 0.0});
			
			//TE_SetupParticleEffect("utaunt_cremation_purple_parent", PATTACH_ABSORIGIN_FOLLOW, npc.index);
			//TE_WriteNum("m_bControlPoint1", npc.index);	
			//TE_SendToAll();
			
			SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.index, 0, 0, 0, 150);
			
			SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable1, 0, 0, 0, 150);
			
			SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable2, 0, 0, 0, 150);
		}
		
		npc.StartPathing();
		
		return npc;
	}
}

static void ServantOfTheCurtain_Warrior_ClotThink(int entity)
{
	ServantOfTheCurtain npc = view_as<ServantOfTheCurtain>(entity);
	
	float gameTime = GetGameTime(entity);

	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.m_blPlayHurtAnimation = false;
	}
	
	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				Handle swingTrace;
				float TargetVecPos[3]; WorldSpaceCenter(npc.m_iTarget, TargetVecPos);
				npc.FaceTowards(TargetVecPos, 15000.0); 
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, { 80.0, 80.0, 80.0 }, { -80.0, -80.0, -80.0 })) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float damage = 135.0;
					
					if(ShouldNpcDealBonusDamage(target))
					{
						damage *= 15.0;
					}
					npc.PlayMeleeHitSound();
					
					if(target > 0)
					{
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
					}
				}
				delete swingTrace;
			}
		}
	}
	
	if(npc.m_flInJump)
	{
		if(npc.m_flInJump < gameTime)
		{
			npc.m_flInJump = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				float TargetLocation[3]; 
				GetEntPropVector( npc.index, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
				float EntityLocation[3]; 
				GetEntPropVector( npc.m_iTarget, Prop_Data, "m_vecAbsOrigin", EntityLocation ); 
				float distance = GetVectorDistance( EntityLocation, TargetLocation, true );  
					
				float vecTarget[3];
				WorldSpaceCenter(npc.m_iTarget, vecTarget);

				if(distance <= (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 16.0)) //Sanity check! we want to change targets but if they are too far away then we just dont cast it.
				{
					PluginBot_Jump(npc.index, vecTarget);
				}
			}
		}
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			
		//Predict their pos.
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
		//Get position for just travel here.

		if(npc.m_flDoingAnimation > gameTime) //I am doing an animation or doing something else, default to doing nothing!
		{
			npc.m_iState = -1;
		}
		else if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime)
		{
			npc.m_iState = 1; //Engage in Close Range Destruction.
		}
		else if(flDistanceToTarget > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 4.5) && flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 9.0) && npc.m_flJumpCooldown < gameTime)
		{
			npc.m_iState = 2; //Jump
		}
		else 
		{
			npc.m_iState = 0; //stand and look if close enough.
		}
		
		switch(npc.m_iState)
		{
			case -1:
			{
				return; //Do nothing.
			}
			case 0:
			{
				//Walk to target
				if(!npc.m_bPathing)
				{
					npc.StartPathing();
					npc.m_bisWalking = true;
					npc.m_flSpeed = 330.0;
				}
					
				if(npc.m_iChanged_WalkCycle != 5) 	
				{
					npc.m_iChanged_WalkCycle = 5;
					npc.SetActivity("ACT_ACHILLES_RUN_DAGGER");
				}
			}
			case 1:
			{			
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					npc.AddGesture("ACT_ACHILLES_ATTACK_DAGGER");

					npc.PlayMeleeSound();
					
					npc.m_flAttackHappens = gameTime + 0.25;

					npc.m_flDoingAnimation = gameTime + 0.25;
					npc.m_flNextMeleeAttack = gameTime + 0.55;
					npc.m_bisWalking = true;
				}
			}
			case 2:
			{			
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);

				// jump at them.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					if(npc.m_iChanged_WalkCycle != 7) 	
					{
						npc.StopPathing();
						
						npc.m_flSpeed = 0.0;
						npc.m_bisWalking = false;
						npc.m_iChanged_WalkCycle = 7;
						npc.SetActivity("ACT_BRAWLER_RUN");
					}

					npc.PlayMeleeSound();
					
					npc.m_flInJump = gameTime + 0.5;

					npc.m_flDoingAnimation = gameTime + 0.5;
					npc.m_flJumpCooldown = gameTime + 10.0;
					npc.m_bisWalking = true;
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
}

static void ServantOfTheCurtain_Pickaxe_ClotThink(int entity)
{
	ServantOfTheCurtain npc = view_as<ServantOfTheCurtain>(entity);
	
	float gameTime = GetGameTime(entity);

	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.m_blPlayHurtAnimation = false;
	}
	
	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				Handle swingTrace;
				float TargetVecPos[3]; WorldSpaceCenter(npc.m_iTarget, TargetVecPos);
				npc.FaceTowards(TargetVecPos, 15000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, { 80.0, 80.0, 80.0 }, { -80.0, -80.0, -80.0 })) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float damage = 70.0;

					if(ShouldNpcDealBonusDamage(target))
					{
						damage *= 15.0;
					}
					npc.PlayMeleeHitSound();
					
					if(target > 0)
					{
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
						if (npc.m_bOwner)
						{
							// TODO: gives armor to owner when hit.
							GrantEntityArmor(npc.m_bOwner, false, 0.2, 0.5, 0, ReturnEntityMaxHealth(npc.m_bOwner) * 0.005, npc.index);
						}
					}
				}
				delete swingTrace;
			}
		}
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			
		//Predict their pos.
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
		//Get position for just travel here.

		if(npc.m_flDoingAnimation > gameTime) //I am doing an animation or doing something else, default to doing nothing!
		{
			npc.m_iState = -1;
		}
		else if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime)
		{
			npc.m_iState = 1; //Engage in Close Range Destruction.
		}
		else 
		{
			npc.m_iState = 0; //stand and look if close enough.
		}
		
		switch(npc.m_iState)
		{
			case -1:
			{
				return; //Do nothing.
			}
			case 0:
			{
				//Walk to target
				if(!npc.m_bPathing)
				{
					npc.StartPathing();
					npc.m_bisWalking = true;
					npc.m_flSpeed = 300.0;
				}
				
				if(npc.m_iChanged_WalkCycle != 5) 	
				{
					npc.m_iChanged_WalkCycle = 5;
					npc.SetActivity("ACT_ACHILLES_RUN_DAGGER");
				}
			}
			case 1:
			{			
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					npc.AddGesture("ACT_ACHILLES_ATTACK_DAGGER");

					npc.PlayMeleeSound();
					
					npc.m_flAttackHappens = gameTime + 0.25;

					npc.m_flDoingAnimation = gameTime + 0.25;
					npc.m_flNextMeleeAttack = gameTime + 0.55;
					npc.m_bisWalking = true;
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
}

static void ServantOfTheCurtain_NPCDeath(int entity)
{
	ServantOfTheCurtain npc = view_as<ServantOfTheCurtain>(entity);
	if (!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	if (npc.m_bOwner)
	{
		RaidbossKnightOfTheCurtain npc2 = view_as<RaidbossKnightOfTheCurtain>(npc.m_bOwner);
		npc2.g_TimesSummoned--;
	}
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}