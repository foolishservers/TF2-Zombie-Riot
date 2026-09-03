#pragma semicolon 1
#pragma newdecls required

/*
	이 NPC는 점프를 하면서 돌아다니고, 스폰 포인트 역할을 함.
	그게 다임.
*/

void AltExtra_Mecha_Base_Constructor_MapStart() {
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mecha Heavy Particle Rifle");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mecha_heavy_particle_rifle");
	strcopy(data.Icon, sizeof(data.Icon), "medic");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Alt;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

