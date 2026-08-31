#pragma semicolon 1
#pragma newdecls required

void AltExtra_Mecha_Conqueror_OnMapStart() {
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Alt Extra Mecha Conqueror");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mecha_conqueror");
	strcopy(data.Icon, sizeof(data.Icon), "demoknight_samurai");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Alt;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data) {
	return AltExtra_Mecha_Conqueror(vecPos, vecAng, team, data);
}

methodmap AltExtra_Mecha_Conqueror < AltExtra_Base {
	public void PlayIdleAlertSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_RobotSoldier_IdleAlertedSounds[GetRandomInt(0, sizeof(g_RobotSoldier_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	public void PlayHurtSound() {
		if (this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_RobotSoldier_HurtSounds[GetRandomInt(0, sizeof(g_RobotSoldier_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayDeathSound() {
		EmitSoundToAll(g_RobotSoldier_DeathSounds[GetRandomInt(0, sizeof(g_RobotSoldier_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	property int m_iBuffType {
		public get()			{ return this.m_iMedkitAnnoyance; }
		public set(int value)	{ this.m_iMedkitAnnoyance = value; }
	}
	
	public AltExtra_Mecha_Conqueror(float vecPos[3], float vecAng[3], int ally, const char[] data) {
		AltExtra_Mecha_Conqueror npc = view_as<AltExtra_Mecha_Conqueror>(CClotBody(vecPos, vecAng, ALTBOTSOLDIERMODEL, "1.0", "30000", ally));
		
		i_NpcWeight[npc.index] = 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_MP_RUN_PRIMARY");
		
		npc.m_flNextRangedAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		
		func_NPCDeath[npc.index] = AltExtra_Mecha_AirStriker_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = AltExtra_Mecha_AirStriker_ClotThink;
		
		npc.m_flSpeed = 320.0;
		npc.StartPathing();
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.index, 125, 100, 100, 255);
		
		npc.m_iBuffType = StringToInt(data);
		switch (npc.m_iBuffType) {
			case 1: {
				npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_rift_fire_mace/c_rift_fire_mace.mdl");
				SetEntityRenderColor(npc.m_iWearable1, 25, 25, 25, 255);
				
				npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_buffpack/c_buffpack.mdl");
			}
			case 2: {
				npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_paintrain/c_paintrain.mdl");
				
				npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_battalion_buffpack/c_battalion_buffpack.mdl");
			}
			default: {
				npc.m_iBuffType = 0;
				
				npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_shogun_katana/c_shogun_katana_soldier.mdl");
				
				npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_shogun_warpack/c_shogun_warpack.mdl");
			}
		}
		
		return npc;
	}
}

