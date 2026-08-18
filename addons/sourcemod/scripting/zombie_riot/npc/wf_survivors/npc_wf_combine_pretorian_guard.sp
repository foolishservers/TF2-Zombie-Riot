#pragma semicolon 1
#pragma newdecls required

static char g_DeathSounds[][] = {
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav",
};

static char g_HurtSounds[][] = {
	"npc/combine_soldier/pain1.wav",
	"npc/combine_soldier/pain2.wav",
	"npc/combine_soldier/pain3.wav",
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
	"npc/vort/foot_hit.wav",
};

static char g_MeleeAttackSounds[][] = {
	"npc/combine_soldier/gear1.wav",
	"npc/combine_soldier/gear2.wav",
	"npc/combine_soldier/gear3.wav",
	"npc/combine_soldier/gear4.wav",
	"npc/combine_soldier/gear5.wav",
	"npc/combine_soldier/gear6.wav",
};

static char g_RangedAttackSounds[][] = {
	"weapons/ar2/fire1.wav",
};

static char g_RangedReloadSound[][] = {
	"weapons/ar2/npc_ar2_reload.wav",
};

static char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

void Whiteflower_CombinePretorianGuard_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "W.F. Pretorian Guard");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_wf_combine_pretorian_guard");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_WhiteflowerSpecial;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_RangedReloadSound);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return CombinePretorianGuard(vecPos, vecAng, ally);
}

methodmap CombinePretorianGuard < CClotBody {
	public void PlayIdleSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
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
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public float GetLeadRadius() {
		return 409600.0;
	}
	
	property bool m_bStopMoving {
		public get()							{ return b_FUCKYOU[this.index]; }
		public set(bool TempValueForProperty) 	{ b_FUCKYOU[this.index] = TempValueForProperty; }
	}
	
	public CombinePretorianGuard(float vecPos[3], float vecAng[3], int ally) {
		CombinePretorianGuard npc = view_as<CombinePretorianGuard>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "30000", ally));
		
		i_NpcWeight[npc.index] = 2;
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		int activity = npc.LookupActivity("ACT_RUN_AIM_AR2_STIMULATED");
		if (activity > 0)
			npc.StartActivity(activity);
		
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCDeath[npc.index] = CombinePretorianGuard_NPCDeath;
		func_NPCThink[npc.index] = CombinePretorianGuard_ClotThink;
		
		npc.m_fbGunout = false;
		npc.m_iAttacksTillReload = 20;
		npc.m_bmovedelay = false;
		
		npc.m_bStopMoving = false;
		
		npc.m_flSpeed = 250.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		
		KillFeed_SetKillIcon(npc.index, "sniperrifle");
		
		int skin = (ally != TFTeam_Red) ? 1 : 0;
		npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_irifle.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/sniper/sum24_aimframe/sum24_aimframe.mdl");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		
		npc.StartPathing();
		
		return npc;
	}
}

static void CombinePretorianGuard_ClotThink(int iNPC)
{
	CombinePretorianGuard npc = view_as<CombinePretorianGuard>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if (npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if (npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_STOMACH", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if (npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	if (npc.m_flReloadDelay > gameTime)
	{
		npc.m_flSpeed = 0.0;
		npc.StopPathing();
	}
	else if (npc.m_bStopMoving)
	{
		npc.m_flSpeed = 0.0;
		npc.StopPathing();
	}
	else
	{
		npc.m_flSpeed = 250.0;
	}
	
	if (npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	int primaryThreatIndex = npc.m_iTarget;
	if (IsValidEnemy(npc.index, primaryThreatIndex))
	{
		CombinePretorianGuard_AttackThink(npc, primaryThreatIndex);
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
}

static void CombinePretorianGuard_AttackThink(CombinePretorianGuard npc, int primaryThreatIndex)
{
	npc.PlayIdleAlertSound();
	
	float gameTime = GetGameTime(npc.index);
	
	if (npc.m_bStopMoving)
	{
		npc.SetActivity("ACT_IDLE_ANGRY_AR2");
		npc.m_bmovedelay = false;
	}
	else if (!npc.m_fbGunout && npc.m_flReloadDelay < gameTime)
	{
		if (!npc.m_bmovedelay)
		{
			npc.SetActivity("ACT_RUN_AIM_AR2_STIMULATED");
			npc.m_bmovedelay = true;
		}
	}
	else if (npc.m_fbGunout && npc.m_flReloadDelay < gameTime)
	{
		npc.SetActivity("ACT_IDLE_ANGRY_AR2");
		npc.m_bmovedelay = false;
	}
	
	float vecTarget[3];
	WorldSpaceCenter(primaryThreatIndex, vecTarget);
	
	float VecSelfNpc[3];
	WorldSpaceCenter(npc.index, VecSelfNpc);
	
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
	if (flDistanceToTarget < npc.GetLeadRadius() && flDistanceToTarget > 261144.0) {
		float vPredictedPos[3];
		PredictSubjectPosition(npc, primaryThreatIndex, _, _, vPredictedPos);
		npc.SetGoalVector(vPredictedPos);
		
		npc.m_bStopMoving = false;
	}
	else if (flDistanceToTarget < 262144.0) {
		npc.m_bStopMoving = true;
	}
	else {
		npc.SetGoalEntity(primaryThreatIndex);
		
		npc.m_bStopMoving = false;
	}
	
	if (npc.m_flNextRangedAttack < gameTime
		&& npc.m_flReloadDelay < gameTime
		&& flDistanceToTarget < 640000.0)
	{
		int target = Can_I_See_Enemy(npc.index, primaryThreatIndex);
		if (!IsValidEnemy(npc.index, primaryThreatIndex))
		{
			if (!npc.m_bmovedelay)
			{
				npc.SetActivity("ACT_RUN_AIM_AR2_STIMULATED");
				npc.m_bmovedelay = true;
			}
			npc.StartPathing();
			
			npc.m_fbGunout = false;
		}
		else {
			npc.m_fbGunout = true;
				
			WorldSpaceCenter(primaryThreatIndex, vecTarget);
			npc.FaceTowards(vecTarget, 10000.0);
			
			float vecSpread = 0.1;
			float eyePitch[3];
			GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
			
			float x, y;
			x = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
			y = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
			
			float vecDirShooting[3], vecRight[3], vecUp[3];
			
			vecTarget[2] += 15.0;
			float SelfVecPos[3]; WorldSpaceCenter(npc.index, SelfVecPos);
			MakeVectorFromPoints(SelfVecPos, vecTarget, vecDirShooting);
			GetVectorAngles(vecDirShooting, vecDirShooting);
			vecDirShooting[1] = eyePitch[1];
			GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
			
			float m_vecSrc[3];
			
			WorldSpaceCenter(npc.index, m_vecSrc);
			
			float vecEnd[3];
			vecEnd[0] = m_vecSrc[0] + vecDirShooting[0] * 9000; 
			vecEnd[1] = m_vecSrc[1] + vecDirShooting[1] * 9000;
			vecEnd[2] = m_vecSrc[2] + vecDirShooting[2] * 9000;
			
			npc.m_flNextRangedAttack = gameTime + 0.35;
			npc.m_iAttacksTillReload -= 1;
			
			if (npc.m_iAttacksTillReload == 0)
			{
				npc.AddGesture("ACT_RELOAD_AR2");
				npc.m_flReloadDelay = gameTime + 2.2;
				npc.m_iAttacksTillReload = 20;
				npc.PlayRangedReloadSound();
			}
			
			npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_AR2");
			float vecDir[3];
			vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
			vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
			vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
			NormalizeVector(vecDir, vecDir);
			float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
			
			target = FireBullet(npc.index, npc.m_iWearable1, WorldSpaceVec, vecDir, 50.0, 9000.0, DMG_BULLET, "bullet_tracer01_red");
			if (IsValidEnemy(npc.index, target))
			{
				ApplyStatusEffect(npc.index, target, "Silenced", 2.0);
			}
			
			npc.PlayRangedSound();
		}
	}
	
	if (npc.m_flReloadDelay < gameTime)
	{
		if (!npc.m_bStopMoving)
			npc.StartPathing();
		
		npc.m_fbGunout = false;
		
		if ((npc.m_flNextMeleeAttack < gameTime && flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED) || npc.m_flAttackHappenswillhappen)
		{
			if (!npc.m_flAttackHappenswillhappen)
			{
				npc.AddGestureViaSequence("MeleeAttack01");
				npc.PlayMeleeSound();
				npc.m_flAttackHappens = gameTime + 0.4;
				npc.m_flAttackHappens_bullshit = gameTime + 0.54;
				npc.m_flAttackHappenswillhappen = true;
			}
				
			if (npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen)
			{
				Handle swingTrace;
				npc.FaceTowards(vecTarget, 20000.0);
				if(npc.DoSwingTrace(swingTrace, primaryThreatIndex))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if(target > 0) 
					{
						SDKHooks_TakeDamage(target, npc.index, npc.index, 300.0, DMG_CLUB, -1, _, vecHit);
						ApplyStatusEffect(npc.index, target, "Cudgelled", 3.0);
						
						Custom_Knockback(npc.index, target, 250.0);
						
						npc.PlayMeleeHitSound();
						
						//Did we kill them?
						int iHealthPost = GetEntProp(target, Prop_Data, "m_iHealth");
						if(iHealthPost <= 0) 
						{
							//Yup, time to celebrate
							npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST");
						}
					} 
				}
				delete swingTrace;
				
				npc.m_flNextMeleeAttack = gameTime + 6.0;
				npc.m_flAttackHappenswillhappen = false;
			}
			else if (npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen)
			{
				npc.m_flAttackHappenswillhappen = false;
				npc.m_flNextMeleeAttack = gameTime + 6.0;
			}
		}
	}
}

static void CombinePretorianGuard_NPCDeath(int entity)
{
	CombinePretorianGuard npc = view_as<CombinePretorianGuard>(entity);
	
	if (!npc.m_bGib)
		npc.PlayDeathSound();
	
	if (IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if (IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}