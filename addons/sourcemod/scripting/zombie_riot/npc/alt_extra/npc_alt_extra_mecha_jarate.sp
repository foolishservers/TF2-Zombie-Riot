#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/mvm/norm/sniper_mvm_paincrticialdeath01.mp3",
	"vo/mvm/norm/sniper_mvm_paincrticialdeath02.mp3",
	"vo/mvm/norm/sniper_mvm_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/mvm/norm/sniper_mvm_painsharp01.mp3",
	"vo/mvm/norm/sniper_mvm_painsharp02.mp3",
	"vo/mvm/norm/sniper_mvm_painsharp03.mp3",
	"vo/mvm/norm/sniper_mvm_painsharp04.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/norm/sniper_mvm_battlecry01.mp3",
	"vo/mvm/norm/sniper_mvm_battlecry02.mp3",
	"vo/mvm/norm/sniper_mvm_battlecry03.mp3",
	"vo/mvm/norm/sniper_mvm_battlecry04.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/cbar_hitbod1.wav",
	"weapons/cbar_hitbod2.wav",
	"weapons/cbar_hitbod3.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/machete_swing.wav",
};

void AltExtra_Mecha_Sniper_Main_OnMapStart() {
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_DefaultMeleeMissSounds);
	
	PrecacheModel("models/bots/sniper/bot_sniper.mdl");
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mecha Sniper Main");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mecha_sniper_main");
	strcopy(data.Icon, sizeof(data.Icon), "sniper");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Alt;
	data.Func = ClotSummon;
	NPC_Add(data);
}