#pragma semicolon 1
#pragma newdecls required

static const char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/airboat/airboat_gun_energy1.wav",
	"weapons/airboat/airboat_gun_energy2.wav",
};

void AltExtra_Guardus_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Guardus");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_guardus");
	strcopy(data.Icon, sizeof(data.Icon), "medic_uber");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Expidonsa;
	data.Func = ClotSummon;
	NPC_Add(data);
}