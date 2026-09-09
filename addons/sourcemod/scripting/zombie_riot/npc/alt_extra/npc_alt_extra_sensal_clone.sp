#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/soldier_paincrticialdeath01.mp3",
	"vo/soldier_paincrticialdeath02.mp3",
	"vo/soldier_paincrticialdeath03.mp3"
};

static const char g_HurtSounds[][] = {
	"vo/soldier_painsharp01.mp3",
	"vo/soldier_painsharp02.mp3",
	"vo/soldier_painsharp03.mp3",
	"vo/soldier_painsharp04.mp3",
	"vo/soldier_painsharp05.mp3",
	"vo/soldier_painsharp06.mp3",
	"vo/soldier_painsharp07.mp3",
	"vo/soldier_painsharp08.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/soldier_taunts19.mp3",
	"vo/taunts/soldier_taunts20.mp3",
	"vo/taunts/soldier_taunts21.mp3",
	"vo/taunts/soldier_taunts18.mp3",
};

static const char g_RangedAttackSounds[][] = {
	"weapons/airstrike_fire_01.wav",
	"weapons/airstrike_fire_02.wav",
	"weapons/airstrike_fire_03.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/cbar_miss1.wav",
};

static char g_SyctheHitSound[][] = {
	"ambient/machines/slicer1.wav",
	"ambient/machines/slicer2.wav",
	"ambient/machines/slicer3.wav",
	"ambient/machines/slicer4.wav",
};

static char g_SyctheInitiateSound[][] = {
	"npc/env_headcrabcanister/incoming.wav",
};

static const char g_LaserSounds[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav",
};

static const char g_ChargeSounds[][] = {
	"weapons/bumper_car_speed_boost_start.wav",
};

void AltExtra_Sensal_Clone_OnMapStart() {
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Sensal?");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_sensal_clone");
	strcopy(data.Icon, sizeof(data.Icon), "sensal_raid");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Alt;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache() {
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_SyctheHitSound);
	PrecacheSoundArray(g_SyctheInitiateSound);
	PrecacheSoundArray(g_LaserSounds);
	PrecacheSoundArray(g_ChargeSounds);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data) {
	return AltExtra_Sensal_Clone(vecPos, vecAng, team, data);
}

methodmap AltExtra_Sensal_Clone < AltExtra_Base {
	public void PlaySytheInitSound() {
		int sound = GetRandomInt(0, sizeof(g_SyctheInitiateSound) - 1);
		EmitSoundToAll(g_SyctheInitiateSound[sound], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		EmitSoundToAll(g_SyctheInitiateSound[sound], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayIdleAlertSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayHurtSound() {
		if (this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayLaserSound() {
		EmitSoundToAll(g_LaserSounds[GetRandomInt(0, sizeof(g_LaserSounds) - 1)], this.index, SNDCHAN_AUTO, 100, _, 0.9, 100);
	}
	
	public void PlayChargeSound() {
		EmitSoundToAll(g_ChargeSounds[GetRandomInt(0, sizeof(g_ChargeSounds) - 1)], this.index, SNDCHAN_AUTO, 100, _, 0.9, 100);
	}
	
	public void InitiateLaserAttack(float vecTarget[3], float vecMe[3], float damage, float attackDelay = 0.75, float drawDelay = 0.5) {
		AltExtra_Sensal_Clone_InitiateLaserAttack(this, vecTarget, vecMe, damage, attackDelay, drawDelay);
	}
	
	public void SummonProjectile(int target, int amount, float damage) {
		AltExtra_Sensal_Clone_SummonProjectile(this, target, amount, damage);
	}
	
	public AltExtra_Sensal_Clone(float vecPos[3], float vecAng[3], int team, const char[] data) {
		AltExtra_Sensal_Clone npc = view_as<AltExtra_Sensal_Clone>(CClotBody(vecPos, vecAng, "models/player/soldier.mdl", "1.0", "40000", team));
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
		func_NPCThink[npc.index] = AltExtra_Sensal_Clone_ClotThink;
		
		npc.m_flSpeed = 240.0;
		npc.StartPathing();
		
		npc.m_flNextRangedAttack = GetGameTime(npc.index) + 6.0;
		npc.m_flNextMeleeAttack = 0.0;
		
		bool laser = StrContains(data, "laser") != -1;
		if (laser) {
			npc.Anger = false;
			func_NPCThink[npc.index] = AltExtra_Sensal_Clone_Laser_ClotThink;
		}
		
		int skin = (team == TFTeam_Red) ? 0 : 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		if (!laser) {
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

static void AltExtra_Sensal_Clone_ClotThink(int iNPC) {
	AltExtra_Sensal_Clone npc = view_as<AltExtra_Sensal_Clone>(iNPC);
	
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
						float damage = 110.0;
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
		else if (flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 16.0)
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
			case 1:
			{
				if (!npc.m_flAttackHappenswillhappen)
				{
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
				if (Can_I_See_Enemy_Only(npc.index, target)) {
					npc.AddGesture("ACT_MP_GESTURE_VC_FISTPUMP_MELEE");
					npc.m_flNextRangedAttack = gameTime + 10.0;
					npc.m_flDoingAnimation = gameTime + 1.25;
					
					npc.PlaySytheInitSound();
					AltExtra_Sensal_Clone_SummonProjectile(npc, target, 2, 130.0);
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

static void AltExtra_Sensal_Clone_Laser_ClotThink(int iNPC) {
	AltExtra_Sensal_Clone npc = view_as<AltExtra_Sensal_Clone>(iNPC);
	
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
	
	if (npc.m_flAttackHappenswillhappen) {
		if (npc.m_flAttackHappens < gameTime) {
			npc.m_flAttackHappenswillhappen = false;
			npc.PlayChargeSound();
		}
	}
	
	if (npc.Anger && npc.m_flAttackHappens_bullshit < gameTime) {
		npc.Anger = false;
		RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
	}
	
	if (npc.m_flDoingAnimation > gameTime) {
		return;
	}
	
	int target = npc.m_iTarget;
	if (IsValidEnemy(npc.index, target)) {
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
		
		if (flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 36.0)
			&& npc.m_flNextRangedAttack < gameTime) {
			npc.StopPathing();
			
			npc.FaceTowards(vecTarget, 30000.0);
			
			npc.SetActivity("ACT_MP_STAND_MELEE");
			int layer = npc.AddGestureViaSequence("taunt_the_fist_bump");
			if (layer != -1)
				npc.SetLayerPlaybackRate(layer, (1.5 / (ReturnEntityAttackspeed(npc.index))));
			
			AltExtra_Sensal_Clone_InitiateLaserAttack(npc, vecTarget, vecMe, 600.0);
			
			npc.m_flAttackHappens = gameTime + 0.5;
			npc.m_flAttackHappens_bullshit = gameTime + 1.5;
			npc.m_flDoingAnimation = gameTime + 1.6;
			
			npc.m_flNextRangedAttack = 0.0;
			npc.m_flAttackHappenswillhappen = true;
			npc.Anger = true;
		}
	}
	else {
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	npc.PlayIdleAlertSound();
}

public void AltExtra_Sensal_Clone_NPCDeath(int iNPC) {
	AltExtra_Sensal_Clone npc = view_as<AltExtra_Sensal_Clone>(iNPC);
	
	if (!npc.m_bGib)
		npc.PlayDeathSound();
	
	if (IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if (IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if (IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	
	if (IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	
	if (IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
}

static void AltExtra_Sensal_Clone_SummonProjectile(AltExtra_Sensal_Clone npc, int target, int amount, float damage) {
	float speed = 450.0;
	
	float pos[3], targetPos[3];
	WorldSpaceCenter(npc.index, pos);
	WorldSpaceCenter(target, targetPos);
	
	int team = GetTeam(npc.index);
	
	EmitSoundToAll("weapons/mortar/mortar_explode3.wav", 0, SNDCHAN_AUTO, 100, SND_NOFLAGS, 0.25, SNDPITCH_NORMAL, -1, pos);
	
	float angRotation[3];
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", angRotation);
	angRotation[0] = 0.0;
	
	for (int i; i < amount; i++) {
		int projectile = npc.FireParticleRocket(targetPos, damage, speed, 100.0, .hide_projectile = false);
		if (projectile > -1) {
			WandProjectile_ApplyFunctionToEntity(projectile, Sensal_Clone_Projectile_StartTouch);
			CreateTimer(15.0, Timer_RemoveEntitySensal, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE);
			
			int modelApply = ApplyCustomModelToWandProjectile(projectile, WEAPON_CUSTOM_WEAPONRY_1, 1.35, "scythe_spin");
			
			if (team == TFTeam_Red) {
				SetEntityRenderColor(modelApply, 255, 255, 255, 1);
			}
			else {
				SetEntityRenderColor(modelApply, 255, 255, 255, 0);
			}
			
			SetVariantInt(2);
			AcceptEntityInput(modelApply, "SetBodyGroup");
			
			Initiate_HomingProjectile(projectile, npc.index, 120.0, 10.0, true, true, angRotation, target);
		}
		
		if (i == 0) {
			angRotation[1] -= 50.0;
		}
		else if (i == 1) {
			angRotation[1] += (50.0 * 2.0);
		}
		else {
			angRotation[1] += 50.0;
		}
	}
}

static void Sensal_Clone_Projectile_StartTouch(int entity, int target) {
	if (target > 0 && target < MAXENTITIES) {
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if (!IsValidEntity(owner))
			owner = 0;
		
		int inflictor = h_ArrowInflictorRef[entity];
		if (inflictor != -1)
			inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);
		
		if (inflictor == -1)
			inflictor = owner;
			
		float vecOrigin[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vecOrigin);
		
		float DamageDeal = fl_rocket_particle_dmg[entity];
		if (ShouldNpcDealBonusDamage(target))
			DamageDeal *= h_BonusDmgToSpecialArrow[entity];
		
		SDKHooks_TakeDamage(target, owner, inflictor, DamageDeal, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, -1);
		
		float VulnerabilityToGive = 0.065;
		IncreaseEntityDamageTakenBy(target, VulnerabilityToGive, 5.0, true);
		
		EmitSoundToAll(g_SyctheHitSound[GetRandomInt(0, sizeof(g_SyctheHitSound) - 1)], entity, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		TE_Particle(b_rocket_particle_from_blue_npc[entity] ? "spell_batball_impact_blue" : "spell_batball_impact_red", vecOrigin, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
		
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if (IsValidEntity(particle))
			RemoveEntity(particle);
	}
	else {
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		
		float vecOrigin[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vecOrigin);
		TE_Particle(b_rocket_particle_from_blue_npc[entity] ? "spell_batball_impact_blue" : "spell_batball_impact_red", vecOrigin, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
		
		if (IsValidEntity(particle))
			RemoveEntity(particle);
	}
	
	RemoveEntity(entity);
}

static int Sensal_Beam_Hit[10];
static void AltExtra_Sensal_Clone_InitiateLaserAttack(AltExtra_Sensal_Clone npc, float vecTarget[3], float vecMe[3], float damage, float attackDelay = 0.75, float drawDelay = 0.5) {
	float vecForward[3], vecRight[3], vecAngles[3];
	
	MakeVectorFromPoints(vecMe, vecTarget, vecForward);
	GetVectorAngles(vecForward, vecAngles);
	GetAngleVectors(vecForward, vecForward, vecRight, vecTarget);
	
	Handle trace = TR_TraceRayFilterEx(vecMe, vecAngles, 11, RayType_Infinite, AlliedSensal_TraceWallsOnly);
	if (TR_DidHit(trace)) {
		TR_GetEndPosition(vecTarget, trace);
		
		float lineReduce = 10.0 * 2.0 / 3.0;
		float curDist = GetVectorDistance(vecMe, vecTarget, false);
		if (curDist > lineReduce) {
			ConformLineDistance(vecTarget, vecMe, vecTarget, curDist - lineReduce);
		}
	}
	delete trace;
	
	DataPack pack;
	CreateDataTimer(drawDelay, Timer_Sensal_Clone_DrawLaserAttack, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(npc.index));
	pack.WriteFloat(vecTarget[0]);
	pack.WriteFloat(vecTarget[1]);
	pack.WriteFloat(vecTarget[2]);
	pack.WriteFloat(damage);
	pack.WriteFloat(attackDelay);
}

static Action Timer_Sensal_Clone_DrawLaserAttack(Handle timer, DataPack pack) {
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	
	float vecTarget[3];
	vecTarget[0] = pack.ReadFloat();
	vecTarget[1] = pack.ReadFloat();
	vecTarget[2] = pack.ReadFloat();
	float damage = pack.ReadFloat();
	float attackDelay = pack.ReadFloat();
	
	if (!IsValidEntity(entity))
		return Plugin_Handled;
	
	AltExtra_Sensal_Clone npc = view_as<AltExtra_Sensal_Clone>(entity);
	
	int red = 65;
	int green = 65;
	int blue = 255;
	int alpha = 222;
	
	//we set colours of the differnet laser effects to give it more of an effect
	
	float flPos[3], flAng[3];
	GetAttachment(npc.index, "weapon_bone", flPos, flAng);
	
	int colorLayer4[4];
	float diameter = 40.0;
	SetColorRGBA(colorLayer4, red, green, blue, alpha);
	//we set colours of the differnet laser effects to give it more of an effect
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, alpha);
	int glowColor[4];
	SetColorRGBA(glowColor, red, green, blue, alpha);
	TE_SetupBeamPoints(flPos, vecTarget, Shared_BEAM_Glow, 0, 0, 0, attackDelay, ClampBeamWidth(diameter * 0.1), ClampBeamWidth(diameter * 0.1), 0, 0.5, glowColor, 0);
	TE_SendToAll(0.0);
	
	DataPack laserPack;
	CreateDataTimer(attackDelay, Timer_Sensal_Clone_InitiateLaserAttack, laserPack, TIMER_FLAG_NO_MAPCHANGE);
	laserPack.WriteCell(EntIndexToEntRef(npc.index));
	laserPack.WriteFloat(vecTarget[0]);
	laserPack.WriteFloat(vecTarget[1]);
	laserPack.WriteFloat(vecTarget[2]);
	laserPack.WriteFloat(flPos[0]);
	laserPack.WriteFloat(flPos[1]);
	laserPack.WriteFloat(flPos[2]);
	laserPack.WriteFloat(damage);
	
	return Plugin_Continue;
}

static Action Timer_Sensal_Clone_InitiateLaserAttack(Handle timer, DataPack pack) {
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	
	float vecTarget[3];
	float flPos[3];
	vecTarget[0] = pack.ReadFloat();
	vecTarget[1] = pack.ReadFloat();
	vecTarget[2] = pack.ReadFloat();
	flPos[0] = pack.ReadFloat();
	flPos[1] = pack.ReadFloat();
	flPos[2] = pack.ReadFloat();
	float damage = pack.ReadFloat();
	
	if (!IsValidEntity(entity))
		return Plugin_Handled;
	
	AltExtra_Sensal_Clone npc = view_as<AltExtra_Sensal_Clone>(entity);
	
	int red = 65;
	int green = 65;
	int blue = 255;
	float diameter = 40.0;
	
	int colorLayer4[4];
	SetColorRGBA(colorLayer4, red, green, blue, 60);
	int colorLayer3[4];
	SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, 60);
	int colorLayer2[4];
	SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 60);
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 60);
	
	TE_SetupBeamPoints(flPos, vecTarget, Shared_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	
	TE_SetupBeamPoints(flPos, vecTarget, Shared_BEAM_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
	TE_SendToAll(0.0);
	
	TE_SetupBeamPoints(flPos, vecTarget, Shared_BEAM_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.8 * 1.28), ClampBeamWidth(diameter * 0.8 * 1.28), 0, 1.0, colorLayer3, 3);
	TE_SendToAll(0.0);
	
	TE_SetupBeamPoints(flPos, vecTarget, Shared_BEAM_Laser, 0, 0, 0, 0.33, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
	TE_SendToAll(0.0);
	
	float hullMin[3];
	float hullMax[3];
	hullMin[0] = -40.0;
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];
	
	npc.PlayLaserSound();
	npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("effect_hand_r"), PATTACH_POINT_FOLLOW, true);
	
	for (int i = 0; i < 10; i++) {
		Sensal_Beam_Hit[i] = 0;
	}
	
	Handle trace = TR_TraceHullFilterEx(flPos, vecTarget, hullMin, hullMax, 1073741824, AltExtra_Sensal_Clone_Beam_TraceUsers, npc.index);	// 1073741824 is CONTENTS_LADDER?
	delete trace;
	
	float damageFallOff = 1.0;
	int enemiesHit = 0;
	for (int i = 0; i < SENSAL_MAX_TARGETS_HIT; i++) {
		if (Sensal_Beam_Hit[i] > 0) {
			if (IsValidEntity(Sensal_Beam_Hit[i])) {
				SensalCauseKnockback(npc.index, Sensal_Beam_Hit[i], 0.75, false);
				
				float vecEnemy[3];
				WorldSpaceCenter(Sensal_Beam_Hit[i], vecEnemy);
				
				SDKHooks_TakeDamage(Sensal_Beam_Hit[i], npc.index, npc.index, damage * damageFallOff, DMG_CLUB, -1, NULL_VECTOR, vecEnemy, _ , ZR_DAMAGE_REFLECT_LOGIC);	// 2048 is DMG_NOGIB?
				
				damageFallOff *= LASER_AOE_DAMAGE_FALLOFF;
				
				enemiesHit++;
				
				if (enemiesHit >= 5) {
					break;
				}
			}
		}
	}
	
	return Plugin_Continue;
}

static bool AltExtra_Sensal_Clone_Beam_TraceUsers(int entity, int contentsMask, int iExclude) {
	if (IsValidEntity(entity) && IsValidEnemy(iExclude, entity, true, true)) {
		for (int i = 0; i < 10; i++) {
			if (!Sensal_Beam_Hit[i]) {
				Sensal_Beam_Hit[i] = entity;
				break;
			}
		}
	}
	
	return false;
}