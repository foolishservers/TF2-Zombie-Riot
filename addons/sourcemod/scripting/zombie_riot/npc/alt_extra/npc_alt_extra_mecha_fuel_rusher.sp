#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/mvm/norm/scout_mvm_paincrticialdeath01.mp3",
	"vo/mvm/norm/scout_mvm_paincrticialdeath02.mp3",
	"vo/mvm/norm/scout_mvm_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/mvm/norm/scout_mvm_painsharp01.mp3",
	"vo/mvm/norm/scout_mvm_painsharp02.mp3",
	"vo/mvm/norm/scout_mvm_painsharp03.mp3",
	"vo/mvm/norm/scout_mvm_painsharp04.mp3",
	"vo/mvm/norm/scout_mvm_painsharp05.mp3",
	"vo/mvm/norm/scout_mvm_painsharp06.mp3",
	"vo/mvm/norm/scout_mvm_painsharp07.mp3",
	"vo/mvm/norm/scout_mvm_painsharp08.mp3",
};

static const char g_IdleSounds[][] = {
	"vo/mvm/norm/scout_mvm_standonthepoint01.mp3",
	"vo/mvm/norm/scout_mvm_standonthepoint02.mp3",
	"vo/mvm/norm/scout_mvm_standonthepoint03.mp3",
	"vo/mvm/norm/scout_mvm_standonthepoint04.mp3",
	"vo/mvm/norm/scout_mvm_standonthepoint05.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/norm/scout_mvm_battlecry01.mp3",
	"vo/mvm/norm/scout_mvm_battlecry02.mp3",
	"vo/mvm/norm/scout_mvm_battlecry03.mp3",
	"vo/mvm/norm/scout_mvm_battlecry04.mp3",
	"vo/mvm/norm/scout_mvm_battlecry05.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/bat_hit.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/machete_swing.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/bat_draw_swoosh1.wav",
	"weapons/bat_draw_swoosh2.wav",
};

void Mecha_Scout_OnMapStart_NPC() {
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheModel("models/bots/scout/bot_scout.mdl");
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mecha Fuel Rusher");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mecha_fuel_rusher");
	strcopy(data.Icon, sizeof(data.Icon), "scout_giant_fast");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Alt;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data) {
	return AltExtra_Mecha_Fuel_Rusher(vecPos, vecAng, team);
}

methodmap AltExtra_Mecha_Fuel_Rusher < AltExtra_Base {
	public void PlayIdleSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	
	public void PlayIdleAlertSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	public void PlayHurtSound() {
		if (this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public AltExtra_Mecha_Fuel_Rusher(float vecPos[3], float vecAng[3], int team) {
		AltExtra_Mecha_Fuel_Rusher npc = view_as<AltExtra_Mecha_Fuel_Rusher>(CClotBody(vecPos, vecAng, "models/bots/scout/bot_scout.mdl", "1.0", "1250", team));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if (iActivity > 0)
			npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		
		func_NPCDeath[npc.index] = Internal_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = Internal_ClotThink;
		
		npc.m_flSpeed = 300.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
			
		int skin = (team == TFTeam_Red) ? 0 : 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_gascan/c_gascan.mdl");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

static void Internal_ClotThink(int iNPC)
{
	AltExtra_Mecha_Fuel_Rusher npc = view_as<AltExtra_Mecha_Fuel_Rusher>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if (npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
			
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	if (IsValidEnemy(npc.index, PrimaryThreatIndex)) {
		float vecTarget[3], vecMe[3];
		WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		WorldSpaceCenter(npc.index, vecMe);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
		
		// Predict their pos.
		if (flDistanceToTarget < npc.GetLeadRadius()) {
			float vPredictedPos[3];
			PredictSubjectPosition(npc, PrimaryThreatIndex, _, _, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else {
			npc.SetGoalEntity(PrimaryThreatIndex);
		}
		
		//Target close enough to hit
		if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
		{
			//Look at target so we hit.
			//npc.FaceTowards(vecTarget, 1000.0);
			
			//Can we attack right now?
			if(npc.m_flNextMeleeAttack < gameTime)
			{
				//Play attack ani
				if (!npc.m_flAttackHappenswillhappen) {
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					npc.PlayMeleeSound();
					npc.m_flAttackHappens = gameTime+0.4;
					npc.m_flAttackHappens_bullshit = gameTime+0.54;
					npc.m_flAttackHappenswillhappen = true;
				}
					
				if (npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen) {
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
								SDKHooks_TakeDamage(target, npc.index, npc.index, 75.0, DMG_CLUB, -1, _, vecHit);
							else
								SDKHooks_TakeDamage(target, npc.index, npc.index, 150.0, DMG_CLUB, -1, _, vecHit);
							
							// Hit sound
							npc.PlayMeleeHitSound();
						} 
					}
					delete swingTrace;
					npc.m_flNextMeleeAttack = gameTime + 0.6;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = gameTime + 0.6;
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

static void Internal_NPCDeath(int entity) {
	AltExtra_Mecha_Fuel_Rusher npc = view_as<AltExtra_Mecha_Fuel_Rusher>(entity);
	if (!npc.m_bGib)
		npc.PlayDeathSound();
	
	if (IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}