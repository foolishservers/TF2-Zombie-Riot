/*
	Purpose: Fast Quick Slap of all sounds we use all the time all over the code, instead of bloating the plugin ill quickly put it here
	to also compile it faster

	I did this in a hurry so there is little to no coordination.
	Sorry.
	its almost 1am as im writing this.
	10/04/2025

	i got work tomorrow fuck
*/

	//ATTACK SOUNDS//
char g_DefaultCapperShootSound[][] = {
	"weapons/capper_shoot.wav",
};
char g_DefaultLaserLaunchSound[][] = {
	"weapons/physcannon/superphys_launch1.wav",
	"weapons/physcannon/superphys_launch2.wav",
	"weapons/physcannon/superphys_launch3.wav",
	"weapons/physcannon/superphys_launch4.wav"
}
char g_DefaultMeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};
char g_RuinaLaserLoop[][] = {
	"zombiesurvival/seaborn/loop_laser.mp3"
};

	//NPC VOICE SOUNDS//

//Medic:
char g_DefaultMedic_DeathSounds[][] = {
	"vo/medic_paincrticialdeath01.mp3",
	"vo/medic_paincrticialdeath02.mp3",
	"vo/medic_paincrticialdeath03.mp3",
	"vo/medic_paincrticialdeath04.mp3",
};
//REPLACEME_MEDICAAA
char g_DefaultMedic_HurtSounds[][] = {
	"vo/medic_painsharp01.mp3",
	"vo/medic_painsharp02.mp3",
	"vo/medic_painsharp03.mp3",
	"vo/medic_painsharp04.mp3",
	"vo/medic_painsharp05.mp3",
	"vo/medic_painsharp06.mp3",
	"vo/medic_painsharp07.mp3",
	"vo/medic_painsharp08.mp3",
};
char g_DefaultMedic_IdleAlertedSounds[][] = {
	"vo/medic_battlecry01.mp3",
	"vo/medic_battlecry02.mp3",
	"vo/medic_battlecry03.mp3",
	"vo/medic_battlecry04.mp3",
};
char g_DefaultMedic_PlayAnnoyedSound[][] = {
	"vo/medic_jeers01.mp3",
	"vo/medic_jeers04.mp3",
	"vo/medic_jeers05.mp3",
	"vo/medic_jeers06.mp3",
};

// Robot Heavy.
char g_RobotHeavy_DeathSounds[][] = {
	"vo/mvm/norm/heavy_mvm_paincrticialdeath01.mp3",
	"vo/mvm/norm/heavy_mvm_paincrticialdeath02.mp3",
	"vo/mvm/norm/heavy_mvm_paincrticialdeath03.mp3",
};

char g_RobotHeavy_HurtSounds[][] = {
	"vo/mvm/norm/heavy_mvm_painsharp01.mp3",
	"vo/mvm/norm/heavy_mvm_painsharp02.mp3",
	"vo/mvm/norm/heavy_mvm_painsharp03.mp3",
	"vo/mvm/norm/heavy_mvm_painsharp04.mp3",
	"vo/mvm/norm/heavy_mvm_painsharp05.mp3",
};

char g_RobotHeavy_IdleSounds[][] = {
	"vo/mvm/norm/heavy_mvm_jeers03.mp3",
	"vo/mvm/norm/heavy_mvm_jeers04.mp3",
	"vo/mvm/norm/heavy_mvm_jeers06.mp3",
	"vo/mvm/norm/heavy_mvm_jeers09.mp3",
};

char g_RobotHeavy_IdleAlertedSounds[][] = {
	"vo/mvm/norm/taunts/heavy_mvm_taunts16.mp3",
	"vo/mvm/norm/taunts/heavy_mvm_taunts18.mp3",
	"vo/mvm/norm/taunts/heavy_mvm_taunts19.mp3",
};

// Robot Medic.
char g_RobotMedic_DeathSounds[][] = {
	"vo/mvm/norm/medic_mvm_paincrticialdeath01.mp3",
	"vo/mvm/norm/medic_mvm_paincrticialdeath02.mp3",
	"vo/mvm/norm/medic_mvm_paincrticialdeath03.mp3",
};

char g_RobotMedic_HurtSounds[][] = {
	"vo/mvm/norm/medic_mvm_painsharp01.mp3",
	"vo/mvm/norm/medic_mvm_painsharp02.mp3",
	"vo/mvm/norm/medic_mvm_painsharp03.mp3",
	"vo/mvm/norm/medic_mvm_painsharp04.mp3",
};

char g_RobotMedic_IdleSounds[][] = {
	"vo/mvm/norm/medic_mvm_jeers01.mp3",
	"vo/mvm/norm/medic_mvm_jeers02.mp3",
	"vo/mvm/norm/medic_mvm_jeers03.mp3",
	"vo/mvm/norm/medic_mvm_jeers04.mp3",
};

char g_RobotMedic_IdleAlertedSounds[][] = {
	"vo/mvm/norm/medic_mvm_battlecry01.mp3",
	"vo/mvm/norm/medic_mvm_battlecry02.mp3",
	"vo/mvm/norm/medic_mvm_battlecry03.mp3",
	"vo/mvm/norm/medic_mvm_battlecry04.mp3",
};

char g_RobotMedic_RageSounds[][] = {
	"vo/mvm/norm/medic_mvm_go01.mp3",
	"vo/mvm/norm/medic_mvm_go02.mp3",
	"vo/mvm/norm/medic_mvm_go03.mp3",
	"vo/mvm/norm/medic_mvm_go04.mp3",
	"vo/mvm/norm/medic_mvm_go05.mp3",
};

// Robot Soldier.
char g_RobotSoldier_DeathSounds[][] = {
	"vo/mvm/norm/soldier_mvm_paincrticialdeath01.mp3",
	"vo/mvm/norm/soldier_mvm_paincrticialdeath02.mp3",
	"vo/mvm/norm/soldier_mvm_paincrticialdeath03.mp3",
};

char g_RobotSoldier_HurtSounds[][] = {
	"vo/mvm/norm/soldier_mvm_painsevere01.mp3",
	"vo/mvm/norm/soldier_mvm_painsevere02.mp3",
	"vo/mvm/norm/soldier_mvm_painsevere03.mp3",
	"vo/mvm/norm/soldier_mvm_painsevere04.mp3",
	"vo/mvm/norm/soldier_mvm_painsevere05.mp3",
	"vo/mvm/norm/soldier_mvm_painsevere06.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp01.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp02.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp03.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp04.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp05.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp06.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp07.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp08.mp3",
};

char g_RobotSoldier_IdleSounds[][] = {
	"vo/mvm/norm/taunts/soldier_mvm_taunts01.mp3",
	"vo/mvm/norm/taunts/soldier_mvm_taunts09.mp3",
	"vo/mvm/norm/taunts/soldier_mvm_taunts14.mp3",
};

char g_RobotSoldier_IdleAlertedSounds[][] = {
	"vo/mvm/norm/taunts/soldier_mvm_taunts18.mp3",
	"vo/mvm/norm/taunts/soldier_mvm_taunts19.mp3",
	"vo/mvm/norm/taunts/soldier_mvm_taunts20.mp3",
	"vo/mvm/norm/taunts/soldier_mvm_taunts21.mp3",
};

char g_RobotSoldier_Giant_HurtSounds[][] = {
	"vo/mvm/mght/soldier_mvm_m_painsevere01.mp3",
	"vo/mvm/mght/soldier_mvm_m_painsevere02.mp3",
	"vo/mvm/mght/soldier_mvm_m_painsevere03.mp3",
	"vo/mvm/mght/soldier_mvm_m_painsevere04.mp3",
	"vo/mvm/mght/soldier_mvm_m_painsevere05.mp3",
	"vo/mvm/mght/soldier_mvm_m_painsevere06.mp3",
	"vo/mvm/mght/soldier_mvm_m_painsharp01.mp3",
	"vo/mvm/mght/soldier_mvm_m_painsharp02.mp3",
	"vo/mvm/mght/soldier_mvm_m_painsharp03.mp3",
	"vo/mvm/mght/soldier_mvm_m_painsharp04.mp3",
	"vo/mvm/mght/soldier_mvm_m_painsharp05.mp3",
	"vo/mvm/mght/soldier_mvm_m_painsharp06.mp3",
	"vo/mvm/mght/soldier_mvm_m_painsharp07.mp3",
	"vo/mvm/mght/soldier_mvm_m_painsharp08.mp3",
};

// Robot Demo.
char g_RobotDemo_DeathSounds[][] = {
	"vo/mvm/norm/demoman_mvm_paincrticialdeath01.mp3",
	"vo/mvm/norm/demoman_mvm_paincrticialdeath02.mp3",
	"vo/mvm/norm/demoman_mvm_paincrticialdeath03.mp3",
	"vo/mvm/norm/demoman_mvm_paincrticialdeath04.mp3",
	"vo/mvm/norm/demoman_mvm_paincrticialdeath05.mp3",
};

char g_RobotDemo_HurtSounds[][] = {
	"vo/mvm/norm/demoman_mvm_painsharp01.mp3",
	"vo/mvm/norm/demoman_mvm_painsharp02.mp3",
	"vo/mvm/norm/demoman_mvm_painsharp03.mp3",
	"vo/mvm/norm/demoman_mvm_painsharp04.mp3",
	"vo/mvm/norm/demoman_mvm_painsharp05.mp3",
	"vo/mvm/norm/demoman_mvm_painsharp06.mp3",
	"vo/mvm/norm/demoman_mvm_painsharp07.mp3",
};

char g_RobotDemo_IdleAlertedSounds[][] = {
	"vo/mvm/norm/demoman_mvm_battlecry01.mp3",
	"vo/mvm/norm/demoman_mvm_battlecry02.mp3",
	"vo/mvm/norm/demoman_mvm_battlecry03.mp3",
	"vo/mvm/norm/demoman_mvm_battlecry04.mp3",
};

char g_RobotDemo_AngerSounds[][] = {
	"vo/mvm/norm/taunts/demoman_mvm_taunts10.mp3",
};