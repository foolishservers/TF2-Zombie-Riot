#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/pyro_paincrticialdeath01.mp3",
	"vo/pyro_paincrticialdeath02.mp3",
	"vo/pyro_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/pyro_painsharp01.mp3",
	"vo/pyro_painsharp02.mp3",
	"vo/pyro_painsharp03.mp3",
	"vo/pyro_painsharp04.mp3",
	"vo/pyro_painsharp05.mp3",
};

static const char g_SuperJumpSound[][] = {
	"npc/zombie_poison/pz_warn1.wav",
	"npc/zombie_poison/pz_warn2.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/stunstick/spark1.wav",
	"weapons/stunstick/spark2.wav",
	"weapons/stunstick/spark3.wav",
};

static const char g_IdleAlertedSounds[] = "vo/pyro_helpme01.mp3";

public void Zsvulture_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Major Vulture");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_major_vulture");
	strcopy(data.Icon, sizeof(data.Icon), "gmod_zs_major_vulture");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_GmodZS;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_SuperJumpSound);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSound(g_IdleAlertedSounds);
	PrecacheModel("models/player/pyro.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Zsvulture(vecPos, vecAng, team);
}

methodmap Zsvulture < CClotBody
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
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlaySuperJumpSound()
	{
		EmitSoundToAll(g_SuperJumpSound[GetRandomInt(0, sizeof(g_SuperJumpSound) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	property float m_flPulveriserAttackDelay
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	public Zsvulture(float vecPos[3], float vecAng[3], int ally)
	{
		Zsvulture npc = view_as<Zsvulture>(CClotBody(vecPos, vecAng, "models/player/pyro.mdl", "1.15", "50000", ally));
		
		i_NpcWeight[npc.index] = 4;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");	
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		func_NPCDeath[npc.index] = view_as<Function>(Zsvulture_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Zsvulture_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Zsvulture_ClotThink);
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flSpeed = 400.0;
		npc.m_flMeleeArmor = 0.2;
		npc.m_flRangedArmor = 1.5;
		fl_ruina_battery_max[npc.index]=50.0;
		fl_ruina_battery[npc.index]=0.0;
		ApplyStatusEffect(npc.index, npc.index, "Battery_TM Charge", 999.0);
		npc.Anger = false;
		npc.StartPathing();
		
		if(!IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 9000.0;
			RaidModeScaling = 0.0;
			RaidAllowsBuildings = true;
		}
		
		PrintNPCMessageWithPrefixes(npc.index, "green", "MajorVulture_Encounter", true);
		
		int skin = 5;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop_partner/weapons/c_models/c_ai_flamethrower/c_ai_flamethrower.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/pyro/sf14_hw2014_robot_legg/sf14_hw2014_robot_legg.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/pyro/sf14_hw2014_robot_arm/sf14_hw2014_robot_arm.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/pyro/dec25_veterans_visor/dec25_veterans_visor.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/player/items/pyro/pyro_zombie.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);
		
		return npc;
	}
}

public void Zsvulture_ClotThink(int iNPC)
{
	Zsvulture npc = view_as<Zsvulture>(iNPC);
	
	float GameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GameTime)
		return;
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_bAllowBackWalking)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float WorldSpaceVec[3]; WorldSpaceCenter(npc.m_iTarget, WorldSpaceVec);
			npc.FaceTowards(WorldSpaceVec, 150.0);
		}
	}

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GameTime)
		return;
	npc.m_flNextThinkTime = GameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
	}
	
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	if(!npc.Anger && npc.m_flNextRangedAttack < GameTime)
	{
		if(IsValidEntity(npc.m_iWearable6))
			RemoveEntity(npc.m_iWearable6);
		fl_ruina_battery[npc.index]+=2.0;
		if(fl_ruina_battery[npc.index]>=fl_ruina_battery_max[npc.index])
		{
			int particle_power = ParticleEffectAt(VecSelfNpc, "teleporter_blue_wisps_level3", 999.0);
			if(IsValidEntity(particle_power))
			{
				SetParent(npc.index, particle_power);
				npc.m_iWearable6 = particle_power;
			}
			fl_ruina_battery[npc.index]=fl_ruina_battery_max[npc.index];
			npc.Anger=true;
		}
		npc.m_flNextRangedAttack = 1.0 + GameTime;
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		int SetGoalVectorIndex = 0;
		SetGoalVectorIndex = ZsvultureSelfDefense(npc,GameTime, npc.m_iTarget, flDistanceToTarget); 
		switch(SetGoalVectorIndex)
		{
			case 0:
			{
				npc.m_bAllowBackWalking = false;
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3];
					PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
					npc.SetGoalVector(vPredictedPos);
				}
				else 
				{		
					if(npc.m_flJumpCooldown < GameTime)
					{
						if(flDistanceToTarget > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 4.0) && flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0))
						{
							if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
							{
								npc.FaceTowards(vecTarget, 15000.0);
								PluginBot_Jump(npc.index, vecTarget);
								npc.PlayIdleAlertSound();
								npc.m_flJumpCooldown = GameTime + 7.5;
								npc.PlaySuperJumpSound();
							}
						}
					}
					npc.SetGoalEntity(npc.m_iTarget);
				}
			}
			case 1:
			{
				npc.m_bAllowBackWalking = true;
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true); //update more often, we need it
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

static int ZsvultureSelfDefense(Zsvulture npc, float gameTime, int target, float distance)
{
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.5))
		{
			int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeHitSound();
				float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
				int projectile = npc.FireParticleRocket(vecTarget, 30.0, 1000.0, 150.0, "superrare_burning1", true);
				if(IsValidEntity(projectile))
				{
					CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE);
					if(npc.Anger)
					{
						b_Anger[projectile]=true;
						fl_ruina_battery[npc.index]-=2.0;
						if(fl_ruina_battery[npc.index]<=0.0)
						{
							fl_ruina_battery[npc.index]=0.0;
							npc.Anger=false;
						}
					}
					WandProjectile_ApplyFunctionToEntity(projectile, Zsvulture_Rocket_Particle_StartTouch);
					npc.m_flNextMeleeAttack = gameTime + 0.2;
					int particle = EntRefToEntIndex(i_WandParticle[projectile]);
					if(IsValidEntity(particle))
						CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
				}
			}
			if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.5))
			{
				//target is too far, try to close in
				return 0;
			}
			else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.5))
			{
				if(Can_I_See_Enemy_Only(npc.index, target))
				{
					//target is too close, try to keep distance
					return 1;
				}
			}
			return 0;
		}
		else
		{
			if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.5))
			{
				//target is too far, try to close in
				return 0;
			}
			else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.5))
			{
				if(Can_I_See_Enemy_Only(npc.index, target))
				{
					//target is too close, try to keep distance
					return 1;
				}
			}
		}
	}
	else
	{
		if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.5))
		{
			//target is too far, try to close in
			return 0;
		}
		else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.5))
		{
			if(Can_I_See_Enemy_Only(npc.index, target))
			{
				//target is too close, try to keep distance
				return 1;
			}
		}
	}
	return 0;
}

static Action Zsvulture_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Zsvulture npc = view_as<Zsvulture>(victim);
	
	if(attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

static void Zsvulture_NPCDeath(int entity)
{
	Zsvulture npc = view_as<Zsvulture>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	PrintNPCMessageWithPrefixes(npc.index, "green", "MajorVulture_Death", true);
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
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

static void Zsvulture_Rocket_Particle_StartTouch(int entity, int target)
{
	if(target > 0 && target < MAXENTITIES)
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if(!IsValidEntity(owner))
			owner = 0;
		
		int inflictor = h_ArrowInflictorRef[entity];
		if(inflictor != -1)
			inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);

		if(inflictor == -1)
			inflictor = owner;
		
		float ProjectileLoc[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
		float DamageDeal = fl_rocket_particle_dmg[entity];
		if(ShouldNpcDealBonusDamage(target))
			DamageDeal *= 10.5;
		if(b_Anger[entity])
			AP_TakeDamage(target, owner, inflictor, DamageDeal, DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE);
		else
			SDKHooks_TakeDamage(target, owner, inflictor, DamageDeal, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, -1);
		NPC_Ignite(target, owner,12.0, -1, 8.0);
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(IsValidEntity(particle))
			RemoveEntity(particle);
	}
	else
	{
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		//we uhh, missed?
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
	}
	RemoveEntity(entity);
}