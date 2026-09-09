#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav",
};

static const char g_HurtSounds[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
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
	"weapons/ar2/fire1.wav",
};

static const char g_RangedAttackSoundsSecondary[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav",
};

static const char g_RangedReloadSound[][] = {
	"weapons/ar2/npc_ar2_reload.wav",
};

static int gExplosive1;

void AltExtra_CombineCollos_OnMapStart() {
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
	PrecacheSound("ambient/explosions/explode_9.wav");
	
	gExplosive1 = PrecacheModel("sprites/sprite_fire01.vmt");
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Holy Golden Collos");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_golden_collos");
	strcopy(data.Icon, sizeof(data.Icon), "combine_gold");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Alt;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team) {
	return AltExtra_CombineCollos(vecPos, vecAng, team);
}

methodmap AltExtra_CombineCollos < CClotBody {
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
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
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
	
	public AltExtra_CombineCollos(float vecPos[3], float vecAng[3], int ally) {
		AltExtra_CombineCollos npc = view_as<AltExtra_CombineCollos>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.85", "30000", ally, false, true));
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");		
		
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_COLOSUS_WALK");
		if (iActivity > 0)
			npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		npc.Anger = false;
		
		npc.m_iState = 0;
		npc.m_flSpeed = 240.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 10.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		
		func_NPCDeath[npc.index] = AltExtra_CombineCollos_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = AltExtra_CombineCollos_ClotThink;
		
		SetEntityRenderColor(npc.index, 255, 215, 0, 255);
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		
		SetEntityRenderColor(npc.m_iWearable1, 255, 215, 0, 255);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 2);
		
		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop_partner/player/items/medic/as_medic_cloud_hat/as_medic_cloud_hat.mdl");
		SetVariantString("1.4");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		SetEntityRenderColor(npc.m_iWearable2, 255, 215, 0, 255);
		
		return npc;
	}
}

static void AltExtra_CombineCollos_ClotThink(int iNPC) {
	AltExtra_CombineCollos npc = view_as<AltExtra_CombineCollos>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if (npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if (npc.m_blPlayHurtAnimation) {
		npc.AddGesture("ACT_GESTURE_FLINCH_STOMACH", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	float TrueArmor = 1.0;
	if (!NpcStats_IsEnemySilenced(npc.index)) {
		if (npc.m_fbRangedSpecialOn)
			TrueArmor *= 0.15;
	}
	fl_TotalArmor[npc.index] = TrueArmor;

	//Think throttling
	if (npc.m_flNextThinkTime > gameTime) {
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	if (npc.m_flGetClosestTargetTime < gameTime) {
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	int target = npc.m_iTarget;
	if (IsValidEnemy(npc.index, target, true)) {
		float vecTarget[3], vecMe[3];
		WorldSpaceCenter(target, vecTarget);
		WorldSpaceCenter(npc.index, vecMe);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
		
		//Predict their pos.
		if (flDistanceToTarget < npc.GetLeadRadius()) {
			float vecPredictedPos[3];
			PredictSubjectPosition(npc, target, _, _, vecPredictedPos);
			npc.SetGoalVector(vecPredictedPos);
		}
		else {
			npc.SetGoalEntity(target);
		}

		if (npc.m_flNextRangedSpecialAttack < gameTime && flDistanceToTarget < 62500.0 || npc.m_fbRangedSpecialOn) {
			if (!npc.m_fbRangedSpecialOn) {
				npc.FaceTowards(vecTarget, 20000.0);
				
				npc.AddGesture("ACT_PUSH_PLAYER");
				npc.m_flRangedSpecialDelay = gameTime + 0.4;
				npc.m_fbRangedSpecialOn = true;
				npc.m_flReloadDelay = gameTime + 1.0;
				npc.StopPathing();
			}
			
			if (npc.m_flRangedSpecialDelay < gameTime) {
				npc.m_fbRangedSpecialOn = false;
				npc.m_flNextRangedSpecialAttack = gameTime + 10.0;
				npc.PlayRangedAttackSecondarySound();
				
				float vecOrigin[3];
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", vecOrigin);
				float vecAngles[3], vecForward[3], vecEnd[3];
				
				for (int ion = 1; ion <= 10; ion++) {
					MakeVectorFromPoints(vecOrigin, vecTarget, vecAngles);
					GetVectorAngles(vecAngles, vecAngles);
					
					GetAngleVectors(vecAngles, vecForward, NULL_VECTOR, NULL_VECTOR);
					ScaleVector(vecForward, 100.0 * ion);
					AddVectors(vecOrigin, vecForward, vecEnd);
					
					Ruina_Proper_To_Groud_Clip({24.0, 24.0, 24.0}, 300.0, vecEnd);
					
					AltExtra_CombineCollos_Thunder_Strike(npc.index, vecEnd, float(ion) / 5.0 + 1.0);
				}
				
				if (!npc.Anger) {
					AltExtra_CombineCollos_ProcessAnger(npc);
				}
			}
		}
		
		//Target close enough to hit
		if (flDistanceToTarget < 40000.0 && npc.m_flReloadDelay < GetGameTime(npc.index) || npc.m_flAttackHappenswillhappen) {
			npc.StartPathing();
			if (npc.m_flNextMeleeAttack < GetGameTime(npc.index)) {
				if (!npc.m_flAttackHappenswillhappen) {
					npc.AddGesture("ACT_MELEE_ATTACK_SWING_GESTURE");
					npc.PlayMeleeSound();
					npc.m_flAttackHappens = GetGameTime(npc.index)+0.4;
					npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.54;
					npc.m_flAttackHappenswillhappen = true;
				}
					
				if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen) {
					npc.FaceTowards(vecTarget, 20000.0);
					Handle swingTrace;
					if (npc.DoSwingTrace(swingTrace, target,_,_,_,1)) {
						int targetHit = TR_GetEntityIndex(swingTrace);
						
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						
						if (targetHit > 0) {
							float damage = 100.0;
							
							bool bIsBuilding = ShouldNpcDealBonusDamage(targetHit);
							if (bIsBuilding)
								damage *= 10.0;
							
							SDKHooks_TakeDamage(targetHit, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
							
							Custom_Knockback(npc.index, targetHit, 750.0);
							
							if (!bIsBuilding)
								ApplyStatusEffect(npc.index, targetHit, "Golden Curse", 3.0); 
							
							// Hit sound
							npc.PlayMeleeHitSound();
						}
					}
					delete swingTrace;
					
					npc.m_flNextMeleeAttack = gameTime + 2.0;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 2.0;
				}
			}
		}
		
		if (npc.m_flReloadDelay < GetGameTime(npc.index)) {
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

static void AltExtra_CombineCollos_NPCDeath(int entity) {
	AltExtra_CombineCollos npc = view_as<AltExtra_CombineCollos>(entity);
	
	if (!npc.m_bGib)
		npc.PlayDeathSound();
		
	if (IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if (IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if (IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}

static void AltExtra_CombineCollos_Thunder_Strike(int ref, float vecTarget[3], float Time) {
	int entity = EntRefToEntIndex(ref);
	if (IsValidEntity(entity)) {
		float Range = 100.0;
		float Dmg = 100.0;
		
		int color[4] = {255, 255, 0, 120};
		float UserLoc[3];
		GetAbsOrigin(entity, UserLoc);
		
		UserLoc[2] += 75.0;
		
		int sprite = PrecacheModel("materials/sprites/lgtning.vmt");
		
		TE_SetupBeamPoints(vecTarget, UserLoc, sprite, 0, 0, 0, 0.8, 22.0, 10.2, 1, 8.0, color, 0);
		TE_SendToAll();
		
		EmitSoundToAll("misc/halloween/gotohell.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL*0.5, SNDPITCH_NORMAL, -1, vecTarget);
		
		Handle data;
		CreateDataTimer(Time, AltExtra_CombineCollos_Thunder_Strike_Timer, data, TIMER_FLAG_NO_MAPCHANGE);
		WritePackFloat(data, vecTarget[0]);
		WritePackFloat(data, vecTarget[1]);
		WritePackFloat(data, vecTarget[2]);
		WritePackFloat(data, Range); // Range
		WritePackFloat(data, Dmg); // Damge
		WritePackCell(data, ref);
		
		TE_SetupBeamRingPoint(vecTarget, Range * 2.0, 0.0, g_Ruina_BEAM_Laser, 0, 0, 1, Time, 6.0, 0.1, color, 1, 0);
		TE_SendToAll();
	}
}

static Action AltExtra_CombineCollos_Thunder_Strike_Timer(Handle timer, DataPack data) {
	data.Reset();
	
	float startPosition[3];
	float position[3];
	startPosition[0] = ReadPackFloat(data);
	startPosition[1] = ReadPackFloat(data);
	startPosition[2] = ReadPackFloat(data);
	float Ionrange = ReadPackFloat(data);
	float Iondamage = ReadPackFloat(data);
	
	int client = EntRefToEntIndex(ReadPackCell(data));
	if (!IsValidEntity(client)) {
		return Plugin_Stop;
	}
	
	Explode_Logic_Custom(Iondamage, client, client, -1, startPosition, Ionrange, _, _, true);
	
	TE_SetupExplosion(startPosition, gExplosive1, 10.0, 1, 0, 0, 0);
	TE_SendToAll();
			
	position[0] = startPosition[0];
	position[1] = startPosition[1];
	position[2] += startPosition[2] + 900.0;
	startPosition[2] += -200;
	
	int sprite = PrecacheModel("materials/sprites/lgtning.vmt");
	
	TE_SetupBeamPoints(startPosition, position, sprite, 0, 0, 0, 0.75, 15.0, 1.0, 0, 0.75, {255, 255, 0, 200}, 3);
	TE_SendToAll();
	TE_SetupBeamPoints(startPosition, position, sprite, 0, 0, 0, 0.45, 25.0, 1.0, 0, 0.45, {255, 255, 0, 200}, 3);
	TE_SendToAll();
	TE_SetupBeamPoints(startPosition, position, sprite, 0, 0, 0, 0.3, 40.0, 1.0, 0, 0.3, {255, 255, 0, 200}, 3);
	TE_SendToAll();
	
	EmitSoundToAll("ambient/explosions/explode_9.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, startPosition);
	
	return Plugin_Continue;
}

static void AltExtra_CombineCollos_ProcessAnger(AltExtra_CombineCollos npc) {
	npc.Anger = true;
	
	ApplyStatusEffect(npc.index, npc.index, "Caffeinated Therapy", 999.0);
	
	char model[PLATFORM_MAX_PATH];
	int modelIndex = GetEntProp(npc.index, Prop_Send, "m_nModelIndex");
	ModelIndexToString(modelIndex, model, PLATFORM_MAX_PATH);
	
	if (model[0] == '\0') {
		// Not valid somehow?
		return;
	}
	
	// This enemy is quite huge. So increase the size
	npc.m_iWearable3 = TF2_CreateGlow_White(model, npc.index, 1.9);
	
	SetEntProp(npc.m_iWearable3, Prop_Send, "m_bGlowEnabled", false);
	SetEntityRenderMode(npc.m_iWearable3, RENDER_ENVIRONMENTAL);
	
	// These should always transmit! Particles will be messed up if they don't
	SetEdictFlags(npc.m_iWearable3, GetEdictFlags(npc.m_iWearable3) | FL_EDICT_ALWAYS);
	
	TE_SetupParticleEffect("utaunt_electricity_discharge", PATTACH_ABSORIGIN_FOLLOW, npc.m_iWearable3);
	TE_WriteNum("m_bControlPoint1", npc.m_iWearable3);
	TE_SendToAll();
}