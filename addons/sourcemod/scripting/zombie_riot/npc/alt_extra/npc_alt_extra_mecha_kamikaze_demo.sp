#pragma semicolon 1
#pragma newdecls required

static const char g_HurtSounds[][] = {
	"vo/mvm/norm/demoman_mvm_painsharp01.mp3",
	"vo/mvm/norm/demoman_mvm_painsharp02.mp3",
	"vo/mvm/norm/demoman_mvm_painsharp03.mp3",
	"vo/mvm/norm/demoman_mvm_painsharp04.mp3",
	"vo/mvm/norm/demoman_mvm_painsharp05.mp3",
	"vo/mvm/norm/demoman_mvm_painsharp06.mp3",
	"vo/mvm/norm/demoman_mvm_painsharp07.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"weapons/demo_charge_windup1.wav",
	"weapons/demo_charge_windup2.wav",
	"weapons/demo_charge_windup3.wav",
};

void AltExtra_Mecha_Kamikaze_Demo_OnMapStart() {
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	
	PrecacheModel("models/bots/demo/bot_demo.mdl");
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mecha Kamikaze Demo");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mecha_kamikaze_demo");
	strcopy(data.Icon, sizeof(data.Icon), "demo");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Alt;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team) {
	return AltExtra_Mecha_Kamikaze_Demo(vecPos, vecAng, team);
}

methodmap AltExtra_Mecha_Kamikaze_Demo < CClotBody {
	public void PlayIdleAlertSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(2.0, 3.0);
	}
	
	public void PlayHurtSound() {
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public AltExtra_Mecha_Kamikaze_Demo(float vecPos[3], float vecAng[3], int team) {
		AltExtra_Mecha_Kamikaze_Demo npc = view_as<AltExtra_Mecha_Kamikaze_Demo>(CClotBody(vecPos, vecAng, "models/bots/demo/bot_demo.mdl", "0.8", "700", team));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if (iActivity > 0)
			npc.StartActivity(iActivity);
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_bDissapearOnDeath = true;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;		
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		func_NPCDeath[npc.index] = AltExtra_Mecha_Kamikaze_Demo_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = AltExtra_Mecha_Kamikaze_Demo_ClotThink;		
		
		int skin = (team == TFTeam_Red) ? 0 : 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_caber/c_caber.mdl");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/pyro/sum26_unknown_warrior/sum26_unknown_warrior.mdl");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		
		npc.m_flSpeed = 330.0;
		npc.StartPathing();
		
		return npc;
	}
}

static void AltExtra_Mecha_Kamikaze_Demo_ClotThink(int iNPC) {
	AltExtra_Mecha_Kamikaze_Demo npc = view_as<AltExtra_Mecha_Kamikaze_Demo>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if (npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();	
	
	if (npc.m_blPlayHurtAnimation) {
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if (npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if (npc.m_flGetClosestTargetTime < gameTime) {
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	int target = npc.m_iTarget;
	if (IsValidEnemy(npc.index, target)) {
		float vecTarget[3], vecMe[3];
		WorldSpaceCenter(target, vecTarget);
		WorldSpaceCenter(npc.index, vecMe);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
		
		// Predict their pos.
		if (flDistanceToTarget < npc.GetLeadRadius()) {
			float vPredictedPos[3];
			PredictSubjectPosition(npc, target, _, _, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else {
			npc.SetGoalEntity(target);
		}
		
		npc.StartPathing();
		
		if (flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen) {
			if (npc.m_flNextMeleeAttack < gameTime) {
				if (!npc.m_flAttackHappenswillhappen) {
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					npc.m_flAttackHappens = gameTime + 0.4;
					npc.m_flAttackHappens_bullshit = gameTime + 0.54;
					npc.m_flAttackHappenswillhappen = true;
				}
				
				if (npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen) {
					npc.FaceTowards(vecTarget, 20000.0);
					
					Handle swingTrace;
					if (npc.DoSwingTrace(swingTrace, target)) {
						int targetHit = TR_GetEntityIndex(swingTrace);	
						if (targetHit > 0) {
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);
							
							Explode_Logic_Custom(100.0, npc.index, npc.index, -1, vecHit, 150.0, _, _, true, 10);
							TE_Particle("ExplosionCore_MidAir", vecHit, NULL_VECTOR, {-90.0, 0.0, 0.0}, _, _, _, _, _, _, _, _, _, _, 0.0);
							EmitSoundToAll(SOUND_WAND_LIGHTNING_ABILITY_PAP_SMITE, 0, SNDCHAN_AUTO, 100, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vecHit);
						}
					}
					delete swingTrace;
					
					npc.m_flNextMeleeAttack = gameTime + 0.8;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen) {
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = gameTime + 0.8;
				}
			}
		}
		else {
			npc.StartPathing();
		}
	}
	else {
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	npc.PlayIdleAlertSound();
}

static void AltExtra_Mecha_Kamikaze_Demo_NPCDeath(int entity) {
	AltExtra_Mecha_Kamikaze_Demo npc = view_as<AltExtra_Mecha_Kamikaze_Demo>(entity);
	
	if (!NpcStats_IsEnemySilenced(npc.index)) {
		float vecMe[3];
		WorldSpaceCenter(npc.index, vecMe);
		
		// Boom Boom Boom
		DataPack pack_boom = new DataPack();
		pack_boom.WriteFloat(vecMe[0]);
		pack_boom.WriteFloat(vecMe[1]);
		pack_boom.WriteFloat(vecMe[2]);
		pack_boom.WriteCell(1);
		RequestFrame(MakeExplosionFrameLater, pack_boom);
		
		Explode_Logic_Custom(100.0, npc.index, npc.index, -1, vecMe, 150.0, _, _, true, 10);
	}
	else {
		npc.m_bDissapearOnDeath = false;
	}
	
	if (IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	
	if (IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if (IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}