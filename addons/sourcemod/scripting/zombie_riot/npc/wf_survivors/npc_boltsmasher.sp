#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/metropolice/die1.wav",
	"npc/metropolice/die2.wav",
	"npc/metropolice/die3.wav",
	"npc/metropolice/die4.wav"
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav"
};

static const char g_MeleeHitSounds[][] = {
	"vehicles/v8/vehicle_impact_heavy1.wav",
	"vehicles/v8/vehicle_impact_heavy2.wav",
	"vehicles/v8/vehicle_impact_heavy3.wav",
	"vehicles/v8/vehicle_impact_heavy4.wav",
};

static const char g_MeleeHandAttackSounds[][] = {
	"weapons/boxing_gloves_swing1.wav",
	"weapons/boxing_gloves_swing2.wav",
	"weapons/boxing_gloves_swing4.wav",
};

static const char g_MeleeHandHitSounds[][] = {
	"weapons/metal_gloves_hit_flesh1.wav",
	"weapons/metal_gloves_hit_flesh2.wav",
	"weapons/metal_gloves_hit_flesh3.wav",
	"weapons/metal_gloves_hit_flesh4.wav",
};

static const char g_HurtSounds[] = "npc/metropolice/vo/chuckle.wav";

static const char g_IdleAlertedSounds[] = "npc/metropolice/vo/pickupthecan2.wav";

static const char g_ExplosionSounds[] = "weapons/explode1.wav";

void WhiteFlower_BoltSmasher_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "W.F. Bolt Smasher");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_boltsmasher");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_basebreaker");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Vesta;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSound(g_HurtSounds);
	PrecacheSound(g_IdleAlertedSounds);
	PrecacheSound(g_ExplosionSounds);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return WhiteFlower_BoltSmasher(vecPos, vecAng, ally);
}

methodmap WhiteFlower_BoltSmasher < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleAlertedSounds, this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_HurtSounds, this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}

	public void PlayFistMeleeSound()
	{
		EmitSoundToAll(g_MeleeHandAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayFistMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHandHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayExplosionSound() 
	{
		EmitSoundToAll(g_ExplosionSounds, this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	property float m_flAbilityDuration
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
	}
	
	public WhiteFlower_BoltSmasher(float vecPos[3], float vecAng[3], int ally)
	{
		WhiteFlower_BoltSmasher npc = view_as<WhiteFlower_BoltSmasher>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "2.0", "15000", ally));
		
		i_NpcWeight[npc.index] = 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_ROGUE2_CHAOS_KNIGHT_WALK");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(16);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedAttackHappening = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;

		func_NPCDeath[npc.index] = view_as<Function>(WhiteFlower_BoltSmasher_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(WhiteFlower_BoltSmasher_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(WhiteFlower_BoltSmasher_ClotThink);

		npc.m_bLostHalfHealth = false;
		
		//IDLE
		//KillFeed_SetKillIcon(npc.index, "rocketlauncher_directhit");
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 250.0;
		
		int skin = 1;

		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_rift_fire_mace/c_rift_fire_mace.mdl");
		SetVariantString("2.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/mvm_loot/engineer/robo_engy_hat.mdl", .model_size = 1.25);
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		
		SetEntityRenderColor(npc.index, 200, 200, 200, 255);
		SetEntityRenderColor(npc.m_iWearable1, 25, 25, 100, 255);
		SetEntityRenderColor(npc.m_iWearable2, 125, 125, 125, 255);
		
		return npc;
	}
}

static void WhiteFlower_BoltSmasher_ClotThink(int iNPC)
{
	WhiteFlower_BoltSmasher npc = view_as<WhiteFlower_BoltSmasher>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}

	if(npc.Anger)
	{
		switch(npc.m_iState)
		{
			case 0:
			{
				npc.StopPathing();				
				npc.SetActivity("ACT_MUDROCK_WALK");
				npc.AddGesture("ACT_MUDROCK_ATTACK_OVERHEAD");
				npc.SetCycle(0.05);
				npc.SetPlaybackRate(1.25);
				npc.PlayMeleeSound();
				IncreaseEntityDamageTakenBy(npc.index, 0.15, 1.5);
				npc.m_flAttackHappens = 0.0;
				npc.m_flSpeed = 0.0;
				npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 4.0;
				npc.m_flAbilityDuration = GetGameTime(npc.index) + 0.5;
				ApplyStatusEffect(npc.index, npc.index, "Very Defensive Backup", 1.0);
				ApplyStatusEffect(npc.index, npc.index, "Defensive Backup", 1.0);
				npc.m_iState=1;
				npc.m_bisWalking = false;
			}
			case 1:
			{
				if(npc.m_flAbilityDuration < GetGameTime(npc.index))
				{
					float VecMe[3]; WorldSpaceCenter(npc.index, VecMe);
					Explode_Logic_Custom(40.0, -1, npc.index, -1, VecMe, 150.0, _, 0.75, true, _, false, _, WhiteFlower_BoltSmasher_ExplodeHit);
					ParticleEffectAt(VecMe, "ExplosionCore_buildings", 0.5);
					if(IsValidEntity(npc.m_iWearable1))
						RemoveEntity(npc.m_iWearable1);
					npc.PlayExplosionSound();
					npc.m_iState=2;
					npc.m_flAbilityDuration = GetGameTime(npc.index) + 0.25;
				}
				
			}	
			case 2:
			{
				if(npc.m_flAbilityDuration < GetGameTime(npc.index))
				{
					npc.StartPathing();
					npc.SetActivity("ACT_BRAWLER_RUN");
					npc.m_flSpeed = 300.0;
					npc.m_iState=3;
					npc.m_bisWalking = true;
					npc.Anger = false;
					ApplyStatusEffect(npc.index, npc.index, "Taurine", 8.0);
				}
			}
		}
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
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
		WhiteFlower_BoltSmasherSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

static void WhiteFlower_BoltSmasher_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	WhiteFlower_BoltSmasher npc = view_as<WhiteFlower_BoltSmasher>(victim);
		
	if(attacker <= 0)
		return;
	
	if((ReturnEntityMaxHealth(npc.index)/2) >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.m_bLostHalfHealth) 
	{
		npc.m_bLostHalfHealth = true;
		npc.Anger = true;
		KillFeed_SetKillIcon(npc.index, "sword");
	}

	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
}

static void WhiteFlower_BoltSmasher_NPCDeath(int entity)
{
	WhiteFlower_BoltSmasher npc = view_as<WhiteFlower_BoltSmasher>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();	

	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}

static void WhiteFlower_BoltSmasherSelfDefense(WhiteFlower_BoltSmasher npc, float gameTime, int target, float distance)
{
	if(npc.Anger)
		return;
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
			{
							
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 200.0;
					if(npc.m_bLostHalfHealth)
					{
						damageDealt *= 0.75;
					}
					else
					{
						if(ShouldNpcDealBonusDamage(target))
							damageDealt *= 5.0;
					}
						


					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
	}
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(npc.m_bLostHalfHealth)
		{
			if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
			{
				int Enemy_I_See;
									
				Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
						
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;
					npc.PlayMeleeSound();
					switch(GetRandomInt(0,1))
					{
						case 0:
						{
							npc.AddGesture("ACT_BRAWLER_ATTACK_LEFT");
						}
						case 1:
						{
							npc.AddGesture("ACT_BRAWLER_ATTACK_RIGHT");
						}
					}
							
					npc.m_flAttackHappens = gameTime + 0.25;
					npc.m_flDoingAnimation = gameTime + 0.25;
					npc.m_flNextMeleeAttack = gameTime + 1.0;
				}
			}
		}
		else
		{
			 if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.15))
			{
				int Enemy_I_See;
									
				Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
						
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;
					npc.PlayMeleeSound();
					npc.AddGesture("ACT_ROGUE2_CHAOS_KNIGHT_ATTACK3");
							
					npc.m_flAttackHappens = gameTime + 0.75;
					npc.m_flDoingAnimation = gameTime + 0.75;
					npc.m_flNextMeleeAttack = gameTime + 2.0;
				}
			}
		}
	}
}

static void WhiteFlower_BoltSmasher_ExplodeHit(int entity, int victim, float damage, int weapon)
{
	float vecHit[3]; WorldSpaceCenter(victim, vecHit);
	if(GetTeam(entity) != GetTeam(victim))
	{
		int inflictor = h_ArrowInflictorRef[entity];
		if(inflictor != -1)
			inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);

		if(inflictor == -1)
			inflictor = entity;
		damage = 400.0;
		if(ShouldNpcDealBonusDamage(victim))
			damage *= 8.0;
		SDKHooks_TakeDamage(victim, entity, inflictor, damage, DMG_BLAST, -1, _, vecHit);
	}
}