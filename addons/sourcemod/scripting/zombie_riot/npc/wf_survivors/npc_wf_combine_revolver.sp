#pragma semicolon 1
#pragma newdecls required

static char g_DeathSounds[][] = {
	"npc/metropolice/die1.wav",
	"npc/metropolice/die2.wav",
	"npc/metropolice/die3.wav",
	"npc/metropolice/die4.wav",
};

static char g_HurtSounds[][] = {
	"npc/metropolice/pain1.wav",
	"npc/metropolice/pain2.wav",
	"npc/metropolice/pain3.wav",
};

void WFCombineRevolver_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "W.F. Marksman");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_wf_combine_revolver");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_WhiteflowerSpecial;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()	//lol this shit is messy as fuck but ignore it, aight?
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSound("weapons/357/357_fire2.wav");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return WFCombineRevolver(vecPos, vecAng, team);
}

methodmap WFCombineRevolver < CClotBody {
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayRevolverSound()
	{
		EmitSoundToAll("weapons/357/357_fire2.wav", this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void SetWeaponModel()		//dynamic weapon model change, don't touch
	{
		float origin[3], angles[3];
		this.GetAttachment("anim_attachment_RH", origin, angles);
		
		this.m_iWearable1 = this.EquipItemSeperate("models/weapons/w_357.mdl",_ ,_ , 1.15, _, true);
		angles[1] += 180.0;
		angles[2] += 270.0;
		TeleportEntity(this.m_iWearable1, origin, angles);
		
		SetParent(this.index, this.m_iWearable1, "anim_attachment_RH", {0.0, 0.0, 4.0});
	}
	
	public WFCombineRevolver(float vecPos[3], float vecAng[3], int ally)
	{
		WFCombineRevolver npc = view_as<WFCombineRevolver>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "1350", ally, false));
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
					
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_RUN_AIM_PISTOL");
		
		KillFeed_SetKillIcon(npc.index, "headshot");
		
		func_NPCDeath[npc.index] = WFCombineRevolver_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = WFCombineRevolver_OnTakeDamage;
		func_NPCThink[npc.index] = WFCombineRevolver_ClotThink;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		npc.m_flSpeed = 300.0;
		npc.m_iTarget = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.5;
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		
		npc.StartPathing();
		
		npc.SetWeaponModel();
		
		return npc;
	}
}

static void WFCombineRevolver_ClotThink(int iNPC)
{
	WFCombineRevolver npc = view_as<WFCombineRevolver>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if (npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	int target = npc.m_iTarget;
	if(target != -1 && !IsValidEnemy(npc.index, target))
	{
		target = -1;
		npc.m_flAttackHappens = 0.0;
	}
	
	if(target == -1 || npc.m_flGetClosestTargetTime < gameTime)
	{
		target = GetClosestTarget(npc.index);
		npc.m_iTarget = target;
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	if(target > 0)
	{
		float vecMe[3], vecTarget[3];
		WorldSpaceCenter(npc.index, vecMe);
		WorldSpaceCenter(target, vecTarget);
		
		float distance = GetVectorDistance(vecTarget, vecMe, true);
		
		if(npc.m_flNextMeleeAttack >= gameTime && distance < npc.GetLeadRadius()) 
		{
			PredictSubjectPosition(npc, target, _, _, vecTarget);
			npc.SetGoalVector(vecTarget);
		}
		else
		{
			npc.SetGoalEntity(target);
		}
		
		int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
		if(distance < 10000.0)
		{
			if(IsValidEnemy(npc.index, Enemy_I_See)) 
			{
				npc.m_bAllowBackWalking = true;
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget, _, vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true); //update more often, we need it
			}
		}
		else
		{
			npc.m_bAllowBackWalking = false;
		}
		
		npc.StartPathing();
		if(distance < 160000.0 && npc.m_flNextMeleeAttack < gameTime)	// 400 HU
		{
			if(Can_I_See_Enemy_Only(npc.index, target))
			{
				KillFeed_SetKillIcon(npc.index, "enforcer");
				
				npc.FaceTowards(vecTarget, 25000.0);
				
				npc.PlayRevolverSound();
				npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_PISTOL");
				
				float eyePitch[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
				
				float vecDirShooting[3], vecRight[3], vecUp[3];
				vecTarget[2] += 15.0;
				MakeVectorFromPoints(vecMe, vecTarget, vecDirShooting);
				GetVectorAngles(vecDirShooting, vecDirShooting);
				vecDirShooting[1] = eyePitch[1];
				GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
				
				float vecDir[3];
				
				float damageDealt = 40.0;
				vecDir = vecDirShooting;
				NormalizeVector(vecDir, vecDir);
				
				FireBullet(npc.index, npc.m_iWearable1, vecMe, vecDir, damageDealt, 3000.0, DMG_BULLET, "bullet_tracer01_red");
				
				npc.m_flNextMeleeAttack = gameTime + 2.0;
			}
		}
	}
}

static Action WFCombineRevolver_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	WFCombineRevolver npc = view_as<WFCombineRevolver>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

static void WFCombineRevolver_NPCDeath(int entity)
{
	WFCombineRevolver npc = view_as<WFCombineRevolver>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();
	}
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}