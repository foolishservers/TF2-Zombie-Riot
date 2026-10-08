#pragma semicolon 1
#pragma newdecls required

static char g_DeathSounds[][] = {
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav",
};

static char g_HurtSounds[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};

static char g_IdleSounds[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
};

static char g_IdleAlertedSounds[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
};

static char g_MeleeHitSounds[][] = {
	"weapons/blade_slice_2.wav",
	"weapons/blade_slice_3.wav",
	"weapons/blade_slice_4.wav",
};

static char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};

static char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

static int NPCID;

public void NecroCombine_OnMapStart_NPC() {
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Revived Knight");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_necromancy_combine");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPCID = NPC_Add(data);
	
	/*
	strcopy(data.Name, sizeof(data.Name), "Revived Knight");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_necromancy_combine_perfected");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
	*/
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team) {
	return NecroCombine(client, vecPos, vecAng, team);
}

int NecroCombine_GetID() {
	return NPCID;
}

methodmap NecroCombine < CClotBody {
	public void PlayIdleSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, 90, _, 1.0, 80);
	}
	
	public void PlayIdleAlertSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, 80);
	}
	
	public void PlayHurtSound() {
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, 80);
	}
	
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, 80);
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, 80);
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, 80);
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, 80);
	}
	
	public NecroCombine(int client, float vecPos[3], float vecAng[3], int team) {
		NecroCombine npc = view_as<NecroCombine>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_2_MODEL, "0.8", "30000", team, false, false));
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_TEUTON_WALK_NEW_XENO");
		if (iActivity > 0)
			npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		SetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity", client);
		
		func_NPCDeath[npc.index] = NecroCombine_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = NecroCombine_ClotThink;
		
		npc.m_iState = 0;
		npc.m_flSpeed = 280.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		
		b_ShowNpcHealthbar[npc.index] = true;
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("0.8");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/soldier/dec17_brass_bucket/dec17_brass_bucket.mdl");
		SetVariantString("1.35");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/soldier/bak_caped_crusader/bak_caped_crusader.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		npc.StartPathing();
		return npc;
	}
}

public void NecroCombine_ClotThink(int iNPC) {
	NecroCombine npc = view_as<NecroCombine>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	
	if (npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if (npc.m_flNextThinkTime > gameTime) {
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	if (npc.m_flGetClosestTargetTime < gameTime) {
		npc.m_iTarget = GetClosestTarget(npc.index, _, _, true, .ExtraValidityFunction = NecromancyCombine_AttackMarkOnly);
		
		if (!IsValidEnemy(npc.index, npc.m_iTarget)) {
			npc.m_iTarget = GetClosestTarget(npc.index, _, _, true);
		}
		
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	int owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
	
	if (IsValidClient(owner)) {
		int PrimaryThreatIndex = npc.m_iTarget;
		if (IsValidEnemy(npc.index, PrimaryThreatIndex, true)) {
			float vecTarget[3], VecSelfNpc[3];
			WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
			WorldSpaceCenter(npc.index, VecSelfNpc);
			
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			
			//Predict their pos.
			if (flDistanceToTarget < npc.GetLeadRadius()) {
				float vPredictedPos[3];
				PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
				npc.SetGoalVector(vPredictedPos);
			}
			else {	
				npc.SetGoalEntity(PrimaryThreatIndex);
			}
			
			if (npc.m_flAttackHappenswillhappen) {
				if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					Handle swingTrace;
					npc.FaceTowards(vecTarget, 40000.0);
					if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex,_,_,_,2))
					{
						int target = TR_GetEntityIndex(swingTrace);	
						
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						
						if (target > 0) {
							float damage = 65.0 * npc.m_flExtraDamage;
							if (!NpcStats_AlminaIsEnemyMarked(target))
								damage *= 0.75;
							
							SDKHooks_TakeDamage(target, owner, owner, damage, DMG_PLASMA, -1, _, vecHit); //Do acid so i can filter it well.
							
							npc.PlayMeleeHitSound();
						}
					}
					delete swingTrace;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.6;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.6;
				}
			}
			
			//Target close enough to hit
			if (flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED) {
				if (npc.m_flNextMeleeAttack < gameTime) {
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 2.0;
						if (!ShouldNpcDealBonusDamage(npc.m_iTarget))
							npc.AddGesture("ACT_TEUTON_ATTACK_NEW_XENO", _, _, _, 1.1);
						else
							npc.AddGesture("ACT_TEUTON_ATTACK_CADE_NEW_XENO", _, _, _, 1.1);
						
						npc.PlayMeleeSound();
						npc.m_flAttackHappens = gameTime + 0.4;
						npc.m_flAttackHappens_bullshit = gameTime + 0.54;
						npc.m_flAttackHappenswillhappen = true;
					}
				}
			}
			
			npc.StartPathing();
		}
		else {
			npc.StopPathing();
			npc.m_flGetClosestTargetTime = 0.0;
		}
		
		npc.PlayIdleAlertSound();
	}
	else {
		SmiteNpcToDeath(npc.index);
	}
}

static bool NecromancyCombine_AttackMarkOnly(int entity, int target) {
	if (NpcStats_AlminaIsEnemyMarked(target)) {
		return true;
	}
	return false;
}

static void NecroCombine_NPCDeath(int entity) {
	NecroCombine npc = view_as<NecroCombine>(entity);
	
	if (!npc.m_bGib)
		npc.PlayDeathSound();
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	
	int client = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
	if (IsValidEntity(client))
		Weapon_NecroStaff_MinionDeath(client);
}