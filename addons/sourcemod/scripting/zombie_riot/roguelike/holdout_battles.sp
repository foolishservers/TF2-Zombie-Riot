#pragma semicolon 1
#pragma newdecls required

public float Holdout_Encounter_HardBattle()
{
	Holdout_SetBattleIngots(4 + (Holdout_GetFloor() / 2));
	return 0.0;
}

public float Holdout_Encounter_BossBattle()
{
	// Holdout_SetRequiredBattle(true);
	Holdout_SetBattleIngots(5 + (Holdout_GetFloor() / 2));
	return 0.0;
}