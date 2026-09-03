#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"mvm/giant_heavy/giant_heavy_explode.wav"
};

static const char g_HurtSounds[][] =
{
	"vo/mvm/norm/heavy_mvm_painsharp01.mp3",
	"vo/mvm/norm/heavy_mvm_painsharp02.mp3",
	"vo/mvm/norm/heavy_mvm_painsharp03.mp3",
	"vo/mvm/norm/heavy_mvm_painsharp04.mp3",
	"vo/mvm/norm/heavy_mvm_painsharp05.mp3",
};

static const char g_IdleSounds[][] =
{
	"mvm/giant_heavy/giant_heavy_entrance.wav",
};

static const char g_MeleeHitSounds[][] =
{
	"weapons/metal_gloves_hit_flesh1.wav",
	"weapons/metal_gloves_hit_flesh2.wav",
	"weapons/metal_gloves_hit_flesh3.wav",
	"weapons/metal_gloves_hit_flesh4.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"ui/item_robot_arm_drop.wav"
};

static const char g_AngerSounds[][] =
{
	"mvm/giant_heavy/giant_heavy_gunwindup.wav"
};

static const char g_SecurityAlertSounds[][] =
{
	"ambient/alarms/klaxon1.wav"
};

void Raidboss_WFVerteidiger_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "W.F. Verteidiger");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_wf_verteidiger");
	strcopy(data.Icon, sizeof(data.Icon), "heavy_champ_vac_blast");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_WhiteflowerSpecial;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Raidboss_WFVerteidiger(vecPos, vecAng, team, data);
}

methodmap Raidboss_WFVerteidiger < CClotBody {
	public Raidboss_WFVerteidiger(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Raidboss_WFVerteidiger npc = view_as<Raidboss_WFVerteidiger>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.75", "125000", ally, false, true));
		
		
	}
}

