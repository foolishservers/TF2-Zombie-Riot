#pragma semicolon 1
#pragma newdecls required

static char g_DeathSounds[][] = {
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav",
};

static char g_HurtSound[][] = {
	"npc/combine_soldier/pain1.wav",
	"npc/combine_soldier/pain2.wav",
	"npc/combine_soldier/pain3.wav",
};

static char g_IdleSound[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
};

static char g_IdleAlertedSounds[][] = {
	"npc/metropolice/vo/chuckle.wav",
};

static char g_MeleeAttackSounds[][] = {
	"weapons/boxing_gloves_swing1.wav",
	"weapons/boxing_gloves_swing2.wav",
	"weapons/boxing_gloves_swing4.wav",
};

static char g_MeleeHitSounds[][] = {
	"weapons/boxing_gloves_hit1.wav",
	"weapons/boxing_gloves_hit2.wav",
	"weapons/boxing_gloves_hit3.wav",
	"weapons/boxing_gloves_hit4.wav",
};

void Combine_Expert_Fighter_OnMapStart() {
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "W.F. Expert Fighter");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_combine_expert_fighter");
	strcopy(data.Icon, sizeof(data.Icon), "heavy_champ");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_WhiteflowerSpecial;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache() {
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_IdleSound);
	PrecacheSoundArray(g_HurtSound);
	PrecacheSoundArray(g_IdleAlertedSounds);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team) {
	return Combine_Expert_Fighter(vecPos, vecAng, team);
}

methodmap Combine_Expert_Fighter < Combine_Base {
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
		EmitSoundToAll(g_IdleSound[GetRandomInt(0, sizeof(g_IdleSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayHurtSound() {
		EmitSoundToAll(g_HurtSound[GetRandomInt(0, sizeof(g_HurtSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	
	public void PlayKilledEnemySound(int target) {
		if (!IsEntityAlive(target)) {
			EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
			this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(5.0, 10.0);
		}
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);	
	}
	
	public void AdjustWalkCycle(int walkCycle) {
		if (this.m_iChanged_WalkCycle == walkCycle)
			return;
		
		this.m_iChanged_WalkCycle = walkCycle;
		
		switch (walkCycle) {
			case 0: {
				this.SetActivity("ACT_BRAWLER_RUN");
				this.m_flSpeed = 320.0;
				this.m_bisWalking = true;
				this.StartPathing();
			}
			case 1: {
				this.SetActivity("ACT_BRAWLER_IDLE");
				this.m_flSpeed = 0.0;
				this.m_bisWalking = true;
				this.StopPathing();
			}
		}
	}
	
	public Combine_Expert_Fighter(float vecPos[3], float vecAng[3], int ally) {
		Combine_Expert_Fighter npc = view_as<Combine_Expert_Fighter>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "1000", ally));
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		i_NpcWeight[npc.index] = 2;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		KillFeed_SetKillIcon(npc.index, "fists");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE_METRO;
		
		npc.RegisterBody();
		
		func_NPCDeath[npc.index] = Combine_Expert_Fighter_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = Combine_Expert_Fighter_ClotThink;
		
		npc.m_iChanged_WalkCycle = -1;
		npc.AdjustWalkCycle(0);
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_flDoingAnimation = 0.0;
		
		npc.m_bAllowBackWalking = false;
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/all_class/riflemans_rallycap/riflemans_rallycap_soldier.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		return npc;
	}	
}

static void Combine_Expert_Fighter_ClotThink(int iNPC) {
	Combine_Expert_Fighter npc = view_as<Combine_Expert_Fighter>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	
	if (npc.m_flNextDelayTime > gameTime) {
		return;
	}
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	npc.UpdateBody();
	
	if (npc.m_blPlayHurtAnimation && npc.m_flDoingAnimation < gameTime) {
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST");
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	if (npc.m_flNextThinkTime > gameTime) {
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	if (npc.m_flGetClosestTargetTime < gameTime) {
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 3.0;
	}
	
	if (npc.m_flAttackHappens && npc.m_flAttackHappens < gameTime) {
		npc.m_flAttackHappens = 0.0;
		
		if (IsValidEnemy(npc.index, npc.m_iTarget)) {
			Handle swingTrace;
			if (npc.DoSwingTrace(swingTrace, npc.m_iTarget)) {
				int target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				float damage = 110.0;
				
				if (ShouldNpcDealBonusDamage(target)) {
					damage *= 3.0;
				}
				
				if (target > 0) {
					SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB);
					// Hit sound
					npc.PlayMeleeHitSound();
				}
			}
			
			delete swingTrace;
		}
	}
	
	if (IsValidEnemy(npc.index, npc.m_iTarget)) {
		float vecTarget[3], vecMe[3];
		WorldSpaceCenter(npc.m_iTarget, vecTarget);
		WorldSpaceCenter(npc.index, vecMe);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
		
		// Predict their pos.
		if (flDistanceToTarget < npc.GetLeadRadius()) {
			float vPredictedPos[3]; 
			PredictSubjectPosition(npc, npc.m_iTarget,_,_,vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else {
			npc.SetGoalEntity(npc.m_iTarget);
		}
		
		if (npc.m_flDoingAnimation > gameTime) {
			npc.m_iState = -1;
		}
		else if (flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime) {
			npc.m_iState = 1;
		}
		else {
			npc.m_iState = 0;
		}
		
		switch(npc.m_iState) {
			case -1: {
				return;
			}
			case 0: {
				npc.AdjustWalkCycle(0);
			}
			case 1: {
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				if (IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See)
					&& npc.IsTargetInFiringCone(Enemy_I_See, 5.0, 45.0)) {
					npc.m_iTarget = Enemy_I_See;
					switch (GetRandomInt(0, 1)) {
						case 0: {
							npc.AddGesture("ACT_BRAWLER_ATTACK_LEFT");
						}
						case 1: {
							npc.AddGesture("ACT_BRAWLER_ATTACK_RIGHT");
						}
					}
					
					npc.PlayMeleeSound();
					
					npc.m_flAttackHappens = gameTime + 0.25;
					npc.m_flDoingAnimation = gameTime + 0.25;
					npc.m_flNextMeleeAttack = gameTime + 0.35;
				}
				
				npc.AdjustWalkCycle(0);
			}
		}		
	}
	else {
		npc.AdjustWalkCycle(1);
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	npc.PlayIdleSound();
}

static void Combine_Expert_Fighter_NPCDeath(int entity) {
	Combine_Expert_Fighter npc = view_as<Combine_Expert_Fighter>(entity);
	if (!npc.m_bGib) {
		npc.PlayDeathSound();
	}
	
	npc.ResetBody();
	
	if (IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}