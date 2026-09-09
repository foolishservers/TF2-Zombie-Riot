#pragma semicolon 1
#pragma newdecls required

static char g_AngerSoundsPassed[][] = {
	"vo/taunts/soldier_taunts15.mp3",
};

void AltExtra_Sensal_Clone_Perfected_OnMapStart() {
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Perfected Sensal Clone");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_sensal_clone_perfected");
	strcopy(data.Icon, sizeof(data.Icon), "sensal_raid");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Alt;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache() {
	PrecacheSoundArray(g_AngerSoundsPassed);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team) {
	return AltExtra_Sensal_Clone_Perfected(vecPos, vecAng, team);
}

methodmap AltExtra_Sensal_Clone_Perfected < AltExtra_Sensal_Clone {
	property float m_flRangedSpecialAttackHappens {
		public get()			{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float value) { fl_AbilityOrAttack[this.index][0] = value; }
	}
	
	public AltExtra_Sensal_Clone_Perfected(float vecPos[3], float vecAng[3], int team) {
		AltExtra_Sensal_Clone_Perfected npc = view_as<AltExtra_Sensal_Clone_Perfected>(CClotBody(vecPos, vecAng, "models/player/soldier.mdl", "1.25", "300000", team));
		
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if (iActivity > 0)
			npc.StartActivity(iActivity);
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		npc.m_flMeleeArmor = 1.25;
		
		func_NPCDeath[npc.index] = AltExtra_Sensal_Clone_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = AltExtra_Sensal_Clone_Perfected_ClotThink;
		
		npc.m_flSpeed = 280.0;
		npc.StartPathing();
		
		if (!IsValidEntity(RaidBossActive) && team != TFTeam_Red) {
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 9000.0;
			RaidModeScaling = 0.0;
			RaidAllowsBuildings = true;
			RaidAllowLastman = false;
		}
		
		npc.m_bThisNpcIsABoss = true;
		
		EmitSoundToAll("mvm/mvm_tele_deliver.wav");
		
		npc.Anger = false;
		npc.m_bFUCKYOU = false;
		npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 8.0;
		npc.m_flNextRangedAttack = GetGameTime(npc.index) + 4.0;
		npc.m_flNextMeleeAttack = 0.0;
		
		int skin = (team == TFTeam_Red) ? 0 : 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", WEAPON_CUSTOM_WEAPONRY_1);
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetVariantInt(1);
		AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
		if (team == TFTeam_Red) {
			// Red sycthe!
			SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 1);
		}
		else {
			SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 0);
		}
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop_partner/player/items/all_class/tw2_roman_wreath/tw2_roman_wreath_demo.mdl");
		SetVariantString("1.1");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/soldier/short2014_soldier_fedhair/short2014_soldier_fedhair.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/soldier/coldfront_curbstompers/coldfront_curbstompers.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/soldier/spr18_veterans_attire/spr18_veterans_attire.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

static void AltExtra_Sensal_Clone_Perfected_ClotThink(int iNPC) {
	AltExtra_Sensal_Clone_Perfected npc = view_as<AltExtra_Sensal_Clone_Perfected>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if (npc.m_flNextDelayTime > gameTime) {
		return;
	}
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if (npc.m_blPlayHurtAnimation) {
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if (npc.m_flNextThinkTime > gameTime) {
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	if (npc.m_flGetClosestTargetTime < gameTime) {
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	if (npc.m_bFUCKYOU) {
		if (npc.m_flRangedSpecialAttackHappens && npc.m_flRangedSpecialAttackHappens < gameTime) {
			npc.m_flRangedSpecialAttackHappens = 0.0;
			
			npc.PlayChargeSound();
		}
		
		if (npc.m_flDoingAnimation < gameTime) {
			npc.m_bFUCKYOU = false;
			
			if (IsValidEntity(npc.m_iWearable1)) {
				AcceptEntityInput(npc.m_iWearable1, "Enable");
			}
		}
	}
	
	int target = npc.m_iTarget;
	if (IsValidEnemy(npc.index, target)) {
		if (npc.m_flAttackHappenswillhappen) {
			if (npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime) {
				Handle swingTrace;
				if (npc.DoSwingTrace(swingTrace, target)) {
					int targetHit = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if (targetHit > 0) {
						float damage = 250.0;
						if (ShouldNpcDealBonusDamage(targetHit))
							damage *= 5.0;
						
						SDKHooks_TakeDamage(targetHit, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
						
						// Hit sound
						npc.PlayExpidonsanSwordMeleeHitSounds();
					}
				}
				delete swingTrace;
				
				npc.m_flAttackHappenswillhappen = false;
			}
			else if (npc.m_flAttackHappens_bullshit < gameTime) {
				npc.m_flAttackHappenswillhappen = false;
			}
		}
		
		float vecTarget[3], vecMe[3];
		WorldSpaceCenter(target, vecTarget);
		WorldSpaceCenter(npc.index, vecMe);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
		if (flDistanceToTarget < npc.GetLeadRadius()) {
			float vecPredictedPos[3];
			PredictSubjectPosition(npc, target, _, _, vecPredictedPos);
			npc.SetGoalVector(vecPredictedPos);
		}
		else {
			npc.SetGoalEntity(target);
		}
		
		if (npc.m_flDoingAnimation > gameTime) {
			npc.m_iState = -1;
		}
		else if (flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 36.0)
				&& npc.m_flNextRangedSpecialAttack < gameTime) {
			npc.m_iState = 3;
		}
		else if (flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 25.0)
				&& flDistanceToTarget > NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED
				&& npc.m_flNextRangedAttack < gameTime) {
			npc.m_iState = 2;
		}
		else if (flDistanceToTarget <= NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED
				&& npc.m_flNextMeleeAttack < gameTime) {
			npc.m_iState = 1;
		}
		else {
			npc.m_iState = 0;
		}
		
		switch (npc.m_iState) {
			case 0:
			{
				npc.StartPathing();
			}
			case 1:
			{
				npc.StartPathing();
				
				if (!npc.m_flAttackHappenswillhappen) {
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					
					npc.m_flAttackHappens = gameTime + 0.35;
					npc.m_flAttackHappens_bullshit = gameTime + 1.0;
					
					npc.m_flDoingAnimation = gameTime + 1.0;
					npc.m_flNextMeleeAttack = gameTime + 1.2;
					
					npc.PlayMeleeSound();
					npc.m_flAttackHappenswillhappen = true;
				}
			}
			case 2:
			{
				npc.StartPathing();
				
				if (Can_I_See_Enemy_Only(npc.index, target)) {
					npc.AddGesture("ACT_MP_GESTURE_VC_FISTPUMP_MELEE");
					npc.m_flNextRangedAttack = gameTime + 5.0;
					npc.m_flDoingAnimation = gameTime + 1.25;
					
					npc.PlaySytheInitSound();
					npc.SummonProjectile(target, 3, 300.0);
				}
			}
			case 3:
			{
				if (Can_I_See_Enemy_Only(npc.index, target)) {
					npc.StopPathing();
					
					npc.FaceTowards(vecTarget, 30000.0);
					
					if (IsValidEntity(npc.m_iWearable1)) {
						AcceptEntityInput(npc.m_iWearable1, "Disable");
					}
					
					int layer = npc.AddGestureViaSequence("taunt_the_fist_bump_fistbump");
					if (layer != -1)
						npc.SetLayerPlaybackRate(layer, (2.0 / (ReturnEntityAttackspeed(npc.index))));
					
					npc.InitiateLaserAttack(vecTarget, vecMe, 1000.0, _, 0.75);
					
					npc.m_bFUCKYOU = true;
					npc.m_flRangedSpecialAttackHappens = gameTime + 0.75;
					npc.m_flDoingAnimation = gameTime + 2.0;
					
					npc.m_flNextRangedSpecialAttack = gameTime + 20.0;
					
					npc.PlayChargeSound();
				}
			}
		}
	}
	else {
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	npc.PlayIdleAlertSound();
}

/*
static Action AltExtra_Sensal_Clone_Perfected_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	AltExtra_Sensal_Clone_Perfected npc = view_as<AltExtra_Sensal_Clone_Perfected>(victim);
	
	if (attacker <= 0)
		return Plugin_Continue;
	
	if (!npc.Anger && float(GetEntProp(npc.index, Prop_Data, "m_iHealth")) <= (float(ReturnEntityMaxHealth(npc.index)) * 0.5)) {
		npc.Anger = true;
		
		npc.PlayAngerSound();
		
		float flPos[3], flAng[3];
		GetAttachment(victim, "head", flPos, flAng);
		int particler = ParticleEffectAt(flPos, "scout_dodge_blue", 5.0);
		SetParent(victim, particler, "head");
		npc.m_iWearable7 = particler;
	}
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index)) {
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Continue;
}
*/