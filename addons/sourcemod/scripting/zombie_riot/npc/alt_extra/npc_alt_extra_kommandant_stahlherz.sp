#pragma semicolon 1
#pragma newdecls required

void KommandantStahlherz_OnMapStart() {
	PrecacheModel("models/bots/demo/bot_demo.mdl");
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Kommandant Stahlherz");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_kommandant_stahlherz");
	strcopy(data.Icon, sizeof(data.Icon), "eisenhard");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Alt;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team) {
	return KommandantStahlherz(vecPos, vecAng, team);
}

methodmap KommandantStahlherz < AltExtra_Base {
	public void PlayIdleAlertSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_RobotDemo_IdleAlertedSounds[GetRandomInt(0, sizeof(g_RobotDemo_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	public void PlayHurtSound() {
		if (this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_RobotDemo_HurtSounds[GetRandomInt(0, sizeof(g_RobotDemo_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayDeathSound() {
		EmitSoundToAll(g_RobotDemo_DeathSounds[GetRandomInt(0, sizeof(g_RobotDemo_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayAngerSound() {
		EmitSoundToAll(g_RobotDemo_AngerSounds[GetRandomInt(0, sizeof(g_RobotDemo_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_RobotDemo_AngerSounds[GetRandomInt(0, sizeof(g_RobotDemo_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	property int m_iAlliesDied {
		public get()			{ return i_OverlordComboAttack[this.index]; }
		public set(int value)	{ i_OverlordComboAttack[this.index] = value; }
	}
	
	property int m_iAlliesMaxDeath {
		public get()			{ return i_TimesSummoned[this.index]; }
		public set(int value)	{ i_TimesSummoned[this.index] = value; }
	}
	
	public KommandantStahlherz(float vecPos[3], float vecAng[3], int ally) {
		KommandantStahlherz npc = view_as<KommandantStahlherz>(CClotBody(vecPos, vecAng, "models/bots/demo/bot_demo.mdl", "1.15", "250000", ally));
		
		i_NpcWeight[npc.index] = 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_MP_RUN_ITEM1");
		
		func_NPCDeath[npc.index] = KommandantStahlherz_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = KommandantStahlherz_ClotThink;
		func_NPCDeathForward[npc.index] = KommandantStahlherz_AllyDeath;
		func_NPCLostHealthBar[npc.index] = KommandantStahlherz_LifeLost;
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		
		npc.m_flSpeed = 320.0;
		npc.m_iHealthBar = 1;
		
		npc.m_iAlliesDied = 0;
		npc.m_iAlliesMaxDeath = 16;
		
		fl_TotalArmor[npc.index] = 0.65;
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		ApplyStatusEffect(npc.index, npc.index, "Extra Damage Indicator", 999.0);
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_claymore/c_claymore_xmas.mdl");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/demo/dec24_top_brass_style1/dec24_top_brass_style1.mdl");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/demo/mail_bomber/mail_bomber.mdl");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/sbox2014_armor_shoes/sbox2014_armor_shoes_demo.mdl");
		
		npc.m_iWearable5 = npc.EquipItem("head", "models/player/items/all_class/all_class_oculus_demo_on.mdl");
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		
		SetEntityRenderColor(npc.index, 125, 100, 100, 255);
		SetEntityRenderColor(npc.m_iWearable2, 125, 100, 100, 255);
		SetEntityRenderColor(npc.m_iWearable5, 125, 100, 100, 255);
		
		return npc;
	}
}

public void KommandantStahlherz_ClotThink(int iNPC) {
	KommandantStahlherz npc = view_as<KommandantStahlherz>(iNPC);
	if (npc.m_flNextDelayTime > GetGameTime(npc.index))
		return;
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if (npc.m_blPlayHurtAnimation) {
		npc.m_blPlayHurtAnimation = false;
		
		if (npc.Anger) {
			npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
			npc.PlayHurtSound();
		}
		else {
			npc.PlayHurtArmorSound();
		}
	}
	
	if (npc.Anger) {
		npc.m_flSpeed = 350.0;
	}
	else {
		npc.m_flSpeed = 320.0;
	}
	
	if (npc.m_flNextThinkTime > GetGameTime(npc.index)) {
		return;
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if (npc.m_flGetClosestTargetTime < GetGameTime(npc.index)) {
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if (IsValidEnemy(npc.index, npc.m_iTarget)) {
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if (flDistanceToTarget < npc.GetLeadRadius()) {
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget, _, _, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else {
			npc.SetGoalEntity(npc.m_iTarget);
		}
		
		KommandantStahlherzSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else {
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	npc.PlayIdleAlertSound();
}

static void KommandantStahlherz_NPCDeath(int entity) {
	KommandantStahlherz npc = view_as<KommandantStahlherz>(entity);
	if (!npc.m_bGib)
		npc.PlayDeathSound();
	
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}

void KommandantStahlherzSelfDefense(KommandantStahlherz npc, float gameTime, int target, float distance) {
	if (npc.m_flAttackHappens) {
		if (npc.m_flAttackHappens < gameTime) {
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float vecTarget[3];
			WorldSpaceCenter(target, vecTarget);
			npc.FaceTowards(vecTarget, 15000.0);
			
			if (npc.DoSwingTrace(swingTrace, target)) {		
				int targetHit = TR_GetEntityIndex(swingTrace);
				
				TR_GetEndPosition(vecTarget, swingTrace);
				
				if (IsValidEnemy(npc.index, targetHit)) {
					float damageDealt = npc.Anger ? 250.0 : 200.0;
					
					if(ShouldNpcDealBonusDamage(targetHit))
						damageDealt *= 20.0;
					
					SDKHooks_TakeDamage(targetHit, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecTarget);
					
					// Hit sound
					npc.PlayExpidonsanSwordMeleeHitSounds();
				} 
			}
			delete swingTrace;
		}
	}

	if (gameTime > npc.m_flNextMeleeAttack) {
		if (distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED)) {
			int seenTarget = Can_I_See_Enemy(npc.index, target);
			if (IsValidEnemy(npc.index, seenTarget)) {
				npc.m_iTarget = seenTarget;
				npc.PlayExpidonsanSwordMeleeAttackSounds();
				npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM1");
				
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 0.7;
			}
		}
	}
}

static void KommandantStahlherz_AllyDeath(int self, int ally) {
	KommandantStahlherz npc = view_as<KommandantStahlherz>(self);
	
	if (GetTeam(ally) != GetTeam(self)) {
		return;
	}
	
	float vecTarget[3], vecMe[3];
	GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", vecTarget);
	GetEntPropVector(self, Prop_Data, "m_vecAbsOrigin", vecMe);
	
	float flDistanceToTarget = GetVectorDistance(vecMe, vecTarget, true);
	
	if (flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 24.0)) {
		if (npc.m_iAlliesDied < npc.m_iAlliesMaxDeath) {
			npc.m_iAlliesDied++;
			fl_Extra_Damage[npc.index] += 0.125;
			fl_ruina_battery[npc.index] += 12.5;
		}
		
		HealEntityGlobal(self, self, float(ReturnEntityMaxHealth(self)) * 0.1, 1.0);
	}
}

static bool KommandantStahlherz_LifeLost(int iNPC, int lifeAfter) {
	KommandantStahlherz npc = view_as<KommandantStahlherz>(iNPC);
	
	if (!npc.Anger) {
		if (IsValidEntity(npc.m_iWearable3))
			RemoveEntity(npc.m_iWearable3);
		
		if (IsValidEntity(npc.m_iWearable4))
			RemoveEntity(npc.m_iWearable4);
		
		npc.Anger = true; //	>:(
		npc.PlayAngerSound();
		
		fl_TotalArmor[npc.index] = 1.0;
		
		// not "eye". "eye_1" is correct for this model.
		npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("eye_1"), PATTACH_POINT_FOLLOW, true);
	}
	
	return true;
}