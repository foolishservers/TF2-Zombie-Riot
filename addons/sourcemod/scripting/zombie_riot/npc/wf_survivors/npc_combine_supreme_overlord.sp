#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	")npc/combine_soldier/die1.wav",
	")npc/combine_soldier/die2.wav",
	")npc/combine_soldier/die3.wav",
};

static const char g_HurtSounds[][] = {
	")npc/combine_soldier/pain1.wav",
	")npc/combine_soldier/pain2.wav",
	")npc/combine_soldier/pain3.wav",
};

static const char g_IdleSounds[][] = {
	")npc/combine_soldier/vo/alert1.wav",
	")npc/combine_soldier/vo/bouncerbouncer.wav",
	")npc/combine_soldier/vo/boomer.wav",
	")npc/combine_soldier/vo/contactconfim.wav",
};

static const char g_IdleAlertedSounds[][] = {
	")npc/combine_soldier/vo/alert1.wav",
	")npc/combine_soldier/vo/bouncerbouncer.wav",
	")npc/combine_soldier/vo/boomer.wav",
	")npc/combine_soldier/vo/contactconfim.wav",
};

static const char g_MeleeHitSounds[][] = {
	")weapons/halloween_boss/knight_axe_hit.wav",
};

static const char g_ChargeSounds[][] = {
	")weapons/physcannon/physcannon_charge.wav",
};

static const char g_MeleeAttackSounds[][] = {
	")weapons/demo_sword_swing1.wav",
	")weapons/demo_sword_swing2.wav",
	")weapons/demo_sword_swing3.wav",
};

static const char g_RangedAttackSounds[][] = {
	"weapons/ar2/fire1.wav",
};

static const char g_RangedAttackSoundsSecondary[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav",
};

static const char g_RangedReloadSound[][] = {
	"weapons/ar2/npc_ar2_reload.wav",
};

static const char g_MeleeMissSounds[][] = {
	")weapons/cbar_miss1.wav",
};

void CombineSupremeOverlord_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "W.F. Supreme Overlord");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_combine_supreme_overlord");
	strcopy(data.Icon, sizeof(data.Icon), "combine_overlord");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_WhiteflowerSpecial;
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
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_RangedReloadSound);
	PrecacheSoundArray(g_RangedAttackSoundsSecondary);
	PrecacheSoundArray(g_ChargeSounds);
	
	PrecacheModel("models/workshop/player/items/demo/cc_summer2015_bruces_bonnet/cc_summer2015_bruces_bonnet.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return CombineSupremeOverlord(vecPos, vecAng, team);
}

methodmap CombineSupremeOverlord < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayRangedAttackSecondarySound() {
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlaySpecialChargeSound() {
		EmitSoundToAll(g_ChargeSounds[GetRandomInt(0, sizeof(g_ChargeSounds) - 1)], this.index, _, 110, _, BOSS_ZOMBIE_VOLUME);
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void SetAngryLevel()
	{
		int allycount = 0;
		for (int i = 1; i <= MAXENTITIES; i++)
		{
			if (!IsValidEntity(i) || i == this.index || !IsEntityAlive(i, true))
				continue;
			
			if (GetTeam(this.index) != GetTeam(i) || Is_a_Medic[i])
				continue;
			
			if (i_NpcIsABuilding[i] || b_ThisEntityIgnoredByOtherNpcsAggro[i] || b_NpcIsInvulnerable[i])
				continue;
			
			allycount++;
		}
		
		if (allycount > 0)
		{
			this.m_flAngryModifier = 0.0;
			
			if (allycount < 10)
				this.m_flGainAngry = 0.2 / float(allycount);
			else
				this.m_flGainAngry = 0.02;
			
			this.m_iAlliesDied = 0;
			this.m_iAlliesMaxDeath = allycount;
		}
	}
	
	property float m_flRecheckIfAlliesDead
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	property int m_iAlliesDied
	{
		public get()							{ return i_OverlordComboAttack[this.index]; }
		public set(int TempValueForProperty) 	{ i_OverlordComboAttack[this.index] = TempValueForProperty; }
	}
	
	property int m_iAlliesMaxDeath
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	
	property float m_flAngryModifier
	{
		public get()							{ return fl_Charge_delay[this.index]; }
		public set(float TempValueForProperty) 	{ fl_Charge_delay[this.index] = TempValueForProperty; }
	}
	
	property float m_flGainAngry
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	
	public CombineSupremeOverlord(float vecPos[3], float vecAng[3], int ally)
	{
		CombineSupremeOverlord npc = view_as<CombineSupremeOverlord>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_2_MODEL, "1.25", "35000", ally));
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");	
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_WF_OVERLORD_RUN");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		func_NPCDeath[npc.index] = CombineSupremeOverlord_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = CombineSupremeOverlord_ClotThink;
		func_NPCDeathForward[npc.index] = CombineSupremeOverlord_AllyDeath;
		
		//npc.m_bDissapearOnDeath = true;
		npc.m_bThisNpcIsABoss = true;
		npc.m_iState = 0;
		npc.m_flSpeed = 330.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		//npc.m_flNextChargeSpecialAttack = GetGameTime(npc.index) + 5.0;
		
		Is_a_Medic[npc.index] = true;
		
		npc.SetAngryLevel();
		
		GiveNpcOutLineLastOrBoss(npc.index, true);
		
		npc.m_iWearable1 = npc.EquipItem("partyhat", "models/workshop/player/items/demo/cc_summer2015_bruces_bonnet/cc_summer2015_bruces_bonnet.mdl");
		//SetVariantString("1.25");
		//AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("0.7");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 2);
		
		return npc;
	}
}

static void CombineSupremeOverlord_ClotThink(int iNPC)
{
	CombineSupremeOverlord npc = view_as<CombineSupremeOverlord>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_HURT", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	float TrueArmor = 1.0;
	if(!npc.Anger)
	{
		if (NpcStats_IsEnemySilenced(npc.index))
		{
			TrueArmor = 0.35;
		}
		else
		{
			TrueArmor = 0.1;
		}
	}
	fl_TotalArmor[npc.index] = TrueArmor;
	
	//Think throttling
	if(npc.m_flNextThinkTime > gameTime) {
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.10;
	
	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex, true))
	{
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		if (npc.m_flReloadDelay < gameTime)
		{
			if (npc.m_flmovedelay < gameTime && !npc.Anger)
			{
				if(npc.m_iChanged_WalkCycle != 7)
				{
					npc.m_iChanged_WalkCycle = 7;
					npc.SetActivity("ACT_WF_OVERLORD_RUN");
				}
				npc.m_flmovedelay = gameTime + 1.0;
				npc.m_flSpeed = 330.0;
			}
			if (npc.m_flmovedelay < gameTime && npc.Anger)
			{
				if(npc.m_iChanged_WalkCycle != 8)
				{
					npc.m_iChanged_WalkCycle = 8;
					npc.SetActivity("ACT_WF_OVERLORD_RUN_RAGE");
				}
				npc.m_flmovedelay = gameTime + 1.0;
				npc.m_flSpeed = 380.0;
			}
			//	npc.FaceTowards(vecTarget);
		}
		
		if(npc.m_flJumpStartTime > gameTime)
		{
			npc.m_flSpeed = 0.0;
		}
			
		//	npc.FaceTowards(vecTarget, 1000.0);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius()) {
			float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
			
			/*
			int color[4];
			color[0] = 255;
			color[1] = 255;
			color[2] = 0;
			color[3] = 255;
		
			int xd = PrecacheModel("materials/sprites/laserbeam.vmt");
		
			TE_SetupBeamPoints(vPredictedPos, vecTarget, xd, xd, 0, 0, 0.25, 0.5, 0.5, 5, 5.0, color, 30);
			TE_SendToAllInRange(vecTarget, RangeType_Visibility);
			*/
			
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(PrimaryThreatIndex);
		}
		
		if(!npc.Anger)
		{
			if(npc.m_flRecheckIfAlliesDead < GetGameTime())
			{
				if(!IsValidAlly(npc.index, GetClosestAlly(npc.index)))
				{
					CombineSupremeOverlord_StartRage(npc.index);
				}
				else
				{
					npc.m_flRecheckIfAlliesDead = GetGameTime() + 2.0;
				}
			}
		}

		if((npc.m_flNextRangedSpecialAttack < gameTime && flDistanceToTarget < 22500 && npc.Anger) || npc.m_fbRangedSpecialOn)
		{
			//	npc.FaceTowards(vecTarget, 2000.0);
			if(!npc.m_fbRangedSpecialOn)
			{
				npc.StopPathing();
				
				npc.AddGesture("ACT_WF_OVERLORD_ATTACK_PULSE");
				npc.m_flRangedSpecialDelay = gameTime + 0.3;
				npc.m_fbRangedSpecialOn = true;
				npc.m_flReloadDelay = gameTime + 0.4;
			}
			
			if(npc.m_flRangedSpecialDelay < gameTime)
			{
				npc.m_fbRangedSpecialOn = false;
				npc.m_flNextRangedSpecialAttack = gameTime + 10.0;
				npc.PlayRangedAttackSecondarySound();

				float vecSpread = 0.1;
				
				npc.FaceTowards(vecTarget, 20000.0);
				
				float eyePitch[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
				
				float x, y;
				x = GetRandomFloat( -0.01, 0.01 ) + GetRandomFloat( -0.01, 0.01 );
				y = GetRandomFloat( -0.01, 0.01 ) + GetRandomFloat( -0.01, 0.01 );
				
				float vecDirShooting[3], vecRight[3], vecUp[3];
				//GetAngleVectors(eyePitch, vecDirShooting, vecRight, vecUp);
				
				vecTarget[2] += 15.0;
				float SelfVecPos[3]; WorldSpaceCenter(npc.index, SelfVecPos);
				MakeVectorFromPoints(SelfVecPos, vecTarget, vecDirShooting);
				GetVectorAngles(vecDirShooting, vecDirShooting);
				vecDirShooting[1] = eyePitch[1];
				GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
				
				//add the spray
				float vecDir[3];
				vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
				vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
				vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
				NormalizeVector(vecDir, vecDir);
				float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
				npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("anim_attachment_LH"), PATTACH_POINT_FOLLOW, true);
				
				FireBullet(npc.index, npc.index, WorldSpaceVec, vecDir, 150.0, 150.0, DMG_CLUB, "bullet_tracer02_blue");
			}
		}
		
		//Target close enough to hit
		if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flReloadDelay < gameTime || npc.m_flAttackHappenswillhappen)
		{
			npc.StartPathing();
			if(npc.m_flNextMeleeAttack < gameTime)
			{
				if (!npc.m_flAttackHappenswillhappen)
				{
					npc.m_flNextRangedSpecialAttack = gameTime + 2.0;
					npc.RemoveGesture("ACT_WF_OVERLORD_ATTACK_NORMAL");
					npc.RemoveGesture("ACT_WF_OVERLORD_ATTACK_NORMAL_RAGE");
					if(npc.Anger)
					{
						npc.AddGesture("ACT_WF_OVERLORD_ATTACK_NORMAL_RAGE",_, 0.25);
					}
					else
						npc.AddGesture("ACT_WF_OVERLORD_ATTACK_NORMAL",_, 0.25);
					
					npc.PlayMeleeSound();
					npc.m_flAttackHappens = gameTime + 0.3;
					npc.m_flAttackHappens_bullshit = gameTime + 0.44;
					npc.m_flAttackHappenswillhappen = true;
				}
				
				if (npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen)
				{
					npc.FaceTowards(vecTarget, 20000.0);
					Handle swingTrace;
					if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex))
					{
						int target = TR_GetEntityIndex(swingTrace);	
						
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						
						if(target > 0) 
						{
							if(!ShouldNpcDealBonusDamage(target))
								SDKHooks_TakeDamage(target, npc.index, npc.index, 100.0, DMG_CLUB, -1, _, vecHit);
							else
								SDKHooks_TakeDamage(target, npc.index, npc.index, 400.0, DMG_CLUB, -1, _, vecHit);
									
							Custom_Knockback(npc.index, target, 450.0);
							
							// Hit particle
							
							// Hit sound
							npc.PlayMeleeHitSound();
						} 
					}
					
					delete swingTrace;
					if(npc.Anger)
					{
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.2;
					}
					else
					{
						float delay = 0.4 - npc.m_flAngryModifier;
						if (delay < 0.2)
							delay = 0.2;
						
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + delay;
					}
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					if(npc.Anger)
					{
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.2;
					}
					else
					{
						float delay = 0.4 - npc.m_flAngryModifier;
						if (delay < 0.2)
							delay = 0.2;
						
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + delay;
					}
				}
			}
		}
		
		if (npc.m_flReloadDelay < GetGameTime(npc.index))
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

static void CombineSupremeOverlord_NPCDeath(int entity)
{
	CombineSupremeOverlord npc = view_as<CombineSupremeOverlord>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}

static void CombineSupremeOverlord_AllyDeath(int self, int ally)
{
	CombineSupremeOverlord npc = view_as<CombineSupremeOverlord>(self);
	
	if(npc.Anger)
	{
		return;
	}
	
	if(GetTeam(ally) != GetTeam(self))
	{
		return;
	}
	
	npc.m_iAlliesDied++;
	if(npc.m_iAlliesDied >= npc.m_iAlliesMaxDeath)
	{
		CombineSupremeOverlord_StartRage(self);
	}
	else
	{
		npc.m_flAngryModifier += npc.m_flGainAngry;
	}
}

static void CombineSupremeOverlord_StartRage(int entity)
{
	CombineSupremeOverlord npc = view_as<CombineSupremeOverlord>(entity);
	
	float gameTime = GetGameTime(npc.index);
	
	// npc.m_flPercentAngry = 0.0;
	fl_TotalArmor[npc.index] = 1.0;
	
	npc.m_flReloadDelay = gameTime + 1.5;
	//npc.m_flRangedSpecialDelay = gameTime + 1.5;
	npc.Anger = true;
	
	if(npc.m_bThisNpcIsABoss)
	{
		npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("anim_attachment_LH"), PATTACH_POINT_FOLLOW, true);
	}
	
	npc.PlaySpecialChargeSound();
	npc.AddGesture("ACT_WF_OVERLORD_RAGE_START");
	npc.m_flmovedelay = gameTime + 0.5;
	npc.m_flJumpStartTime = gameTime + 1.5;
	npc.StopPathing();
}