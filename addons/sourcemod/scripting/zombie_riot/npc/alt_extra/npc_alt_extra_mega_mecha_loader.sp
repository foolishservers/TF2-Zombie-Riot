#pragma semicolon 1
#pragma newdecls required

void AltExtra_Mega_Mecha_Loader_MapStart() {
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mega Mecha Loader");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mega_mecha_loader");
	strcopy(data.Icon, sizeof(data.Icon), "heavy");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Alt;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache() {
	PrecacheSound("weapons/rocket_blackbox_explode1.wav");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally) {
	return AltExtra_Mega_Mecha_Loader(vecPos, vecAng, ally, false);
}

methodmap AltExtra_Mega_Mecha_Loader < AltExtra_Base {
	public AltExtra_Mega_Mecha_Loader(float vecPos[3], float vecAng[3], int team, bool alt) {
		AltExtra_Mega_Mecha_Loader npc = view_as<AltExtra_Mega_Mecha_Loader>(CClotBody(vecPos, vecAng, "models/bots/heavy_boss/bot_heavy_boss.mdl", "1.5", "100000", team, false, true));
		
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if (iActivity > 0)
			npc.StartActivity(iActivity);
		
		if (alt) {
			SetVariantInt(1);
			AcceptEntityInput(npc.index, "SetBodyGroup");
		}
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		
		func_NPCDeath[npc.index] = VestanIronShield_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = VestanIronShield_OnTakeDamage;
		func_NPCThink[npc.index] = VestanIronShield_ClotThink;
		
		KillFeed_SetKillIcon(npc.index, "steel_fists");
		
		npc.m_iState = 0;
		npc.m_flSpeed = 150.0;
		npc.m_iChanged_WalkCycle = 0;
		npc.Anger = false;
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/heavy/tw_heavybot_helmet/tw_heavybot_helmet.mdl");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/heavy/tw_heavybot_armor/tw_heavybot_armor.mdl");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		
		return npc;
	}
}