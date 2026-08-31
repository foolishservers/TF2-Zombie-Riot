#pragma semicolon 1
#pragma newdecls required

static const char g_RobotHeavy_MeleeHitSounds[][] = {
	"weapons/metal_gloves_hit_flesh1.wav",
	"weapons/metal_gloves_hit_flesh2.wav",
	"weapons/metal_gloves_hit_flesh3.wav",
	"weapons/metal_gloves_hit_flesh4.wav",
};

static const char g_RobotHeavy_MeleeAttackSounds[][] = {
	"weapons/boxing_gloves_swing1.wav",
	"weapons/boxing_gloves_swing2.wav",
	"weapons/boxing_gloves_swing4.wav",
};

static const char g_RobotHeavy_MeleeMissSounds[][] = {
	"weapons/bat_draw_swoosh1.wav",
	"weapons/bat_draw_swoosh2.wav",
};

static const char g_RocketLaucher_ShootSounds[] = ")weapons/rocket_shoot.wav";

static const char g_ExpidonsanSword_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};

static const char g_ExpidonsanSword_MeleeHitSounds[][] = {
	"weapons/neon_sign_hit_01.wav",
	"weapons/neon_sign_hit_02.wav",
	"weapons/neon_sign_hit_03.wav",
	"weapons/neon_sign_hit_04.wav"
};

void AltExtra_Base_MapStart()
{
	PrecacheModel("models/bots/heavy/bot_heavy.mdl");
	
	PrecacheSoundArray(g_RobotHeavy_DeathSounds);
	PrecacheSoundArray(g_RobotHeavy_HurtSounds);
	PrecacheSoundArray(g_RobotHeavy_IdleSounds);
	PrecacheSoundArray(g_RobotHeavy_IdleAlertedSounds);
	PrecacheSoundArray(g_RobotHeavy_MeleeHitSounds);
	PrecacheSoundArray(g_RobotHeavy_MeleeAttackSounds);
	PrecacheSoundArray(g_RobotHeavy_MeleeMissSounds);
	
	PrecacheSoundArray(g_RobotMedic_DeathSounds);
	PrecacheSoundArray(g_RobotMedic_HurtSounds);
	PrecacheSoundArray(g_RobotMedic_IdleSounds);
	PrecacheSoundArray(g_RobotMedic_IdleAlertedSounds);
	PrecacheSoundArray(g_RobotMedic_RageSounds);
	
	PrecacheSoundArray(g_RobotSoldier_DeathSounds);
	PrecacheSoundArray(g_RobotSoldier_HurtSounds);
	PrecacheSoundArray(g_RobotSoldier_IdleSounds);
	PrecacheSoundArray(g_RobotSoldier_IdleAlertedSounds);
	
	PrecacheSoundArray(g_RobotSoldier_Giant_HurtSounds);
	
	PrecacheSoundArray(g_RobotDemo_DeathSounds);
	PrecacheSoundArray(g_RobotDemo_HurtSounds);
	PrecacheSoundArray(g_RobotDemo_IdleAlertedSounds);
	PrecacheSoundArray(g_RobotDemo_AngerSounds);
	
	PrecacheSound(g_RocketLaucher_ShootSounds);
	
	PrecacheSoundArray(g_ExpidonsanSword_MeleeAttackSounds);
	PrecacheSoundArray(g_ExpidonsanSword_MeleeHitSounds);
}

methodmap AltExtra_Base < CClotBody {
	public void PlayRobotHeavyMeleeAttackSound() {
		EmitSoundToAll(g_RobotHeavy_MeleeAttackSounds[GetRandomInt(0, sizeof(g_RobotHeavy_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
	}
	
	public void PlayRobotHeavyMeleeHitSound() {
		EmitSoundToAll(g_RobotHeavy_MeleeHitSounds[GetRandomInt(0, sizeof(g_RobotHeavy_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
	}

	public void PlayRobotHeavyMeleeMissSound() {
		EmitSoundToAll(g_RobotHeavy_MeleeMissSounds[GetRandomInt(0, sizeof(g_RobotHeavy_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
	}
	
	public void PlayRocketLauncherShootSound() {
		EmitSoundToAll(g_RocketLaucher_ShootSounds, this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayExpidonsanSwordMeleeAttackSounds() {
		EmitSoundToAll(g_ExpidonsanSword_MeleeAttackSounds[GetRandomInt(0, sizeof(g_ExpidonsanSword_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
	}
	
	public void PlayExpidonsanSwordMeleeHitSounds() {
		EmitSoundToAll(g_ExpidonsanSword_MeleeHitSounds[GetRandomInt(0, sizeof(g_ExpidonsanSword_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
	}
	
	public void ModifyBodyPitch(float vecMe[3], float vecTarget[3]) {
		int iPitch = this.LookupPoseParameter("body_pitch");
		if (iPitch < 0)
			return;
		
		//Body pitch
		float v[3], ang[3];
		SubtractVectors(vecMe, vecTarget, v); 
		NormalizeVector(v, v);
		GetVectorAngles(v, ang);
		
		float flPitch = this.GetPoseParameter(iPitch);						
		this.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));
	}
}

public Action AltExtra_Shared_RemoveHoming(Handle timer, int ref) {
	int entity = EntRefToEntIndex(ref);
	if (IsValidEntity(entity)) {
		HomingProjectile_Deactivate(entity);
	}
	return Plugin_Stop;
}