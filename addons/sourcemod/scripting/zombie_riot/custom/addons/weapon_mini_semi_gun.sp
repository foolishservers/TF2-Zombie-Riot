#pragma semicolon 1
#pragma newdecls required
static float OverheatingFeedBack_RestTime[MAXPLAYERS];
static float OverheatingFeedBack_HudTime[MAXPLAYERS];
static float OverheatingFeedBack_MeltdownTime[MAXPLAYERS];
static int OverheatingFeedBack_Charge[MAXPLAYERS];
static int OverheatingFeedBack_Sounds[MAXPLAYERS];
static bool OverheatingFeedBack_FullCharge[MAXPLAYERS];
static bool OverheatingFeedBack_Overclocking[MAXPLAYERS];
static bool OverheatingFeedBack_FullMeltdown[MAXPLAYERS];

static const char Minisemi_SoundLists[][] = {
	"weapons/sniper_railgun_bolt_back.wav",
	"weapons/syringegun_reload_air2.wav",
	"weapons/syringegun_reload_air1.wav",
	"misc/hologram_start.wav",
	"items/powerup_pickup_reflect_reflect_damage.wav",
	"player/medic_charged_death.wav"
};

public void Custom_Mini_Semi_Gun_MapStart()
{
	Zero(OverheatingFeedBack_Sounds);
	Zero(OverheatingFeedBack_Charge);
	Zero(OverheatingFeedBack_FullCharge);
	Zero(OverheatingFeedBack_Overclocking);
	Zero(OverheatingFeedBack_FullMeltdown);
	ZeroFloat(OverheatingFeedBack_RestTime);
	ZeroFloat(OverheatingFeedBack_HudTime);
	ZeroFloat(OverheatingFeedBack_MeltdownTime);
	
	PrecacheSoundArray(Minisemi_SoundLists);
}

public void Weapon_Mini_Semi_Gun_OverheatingFeedBack_M1(int client, int weapon, bool crit, int slot)
{
	float GameTime = GetGameTime();
	if(OverheatingFeedBack_RestTime[client] < GameTime)
	{
		if(TF2_IsPlayerInCondition(client, TFCond_FocusBuff))
			TF2_RemoveCondition(client, TFCond_FocusBuff);
		OverheatingFeedBack_Charge[client]=0;
		OverheatingFeedBack_Sounds[client]=0;
		if(OverheatingFeedBack_FullCharge[client])
			Attributes_Set(weapon, 5, 1.0);
		OverheatingFeedBack_FullCharge[client]=false;
		OverheatingFeedBack_FullMeltdown[client]=false;
		CreateTimer(0.1, Timer_ChangeStartSound, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
	OverheatingFeedBack_Charge[client]+=(OverheatingFeedBack_Overclocking[client] ? 2 : 1);
	if(OverheatingFeedBack_Charge[client] > (OverheatingFeedBack_Overclocking[client] ? 600 : 300))
		OverheatingFeedBack_Charge[client]=(OverheatingFeedBack_Overclocking[client] ? 600 : 300);
	if(OverheatingFeedBack_Overclocking[client] && OverheatingFeedBack_Charge[client] < 300)
		OverheatingFeedBack_Charge[client]+=2;
		
	if(Ability_Check_Cooldown(client, 1) <= 0.0 && OverheatingFeedBack_Overclocking[client])
		OverheatingFeedBack_Overclocking[client]=false;
		
	float Ratio =  float(OverheatingFeedBack_Charge[client])/300.0;

	if(Ratio > (OverheatingFeedBack_Overclocking[client] ? 2.0 : 1.0))
		Ratio = (OverheatingFeedBack_Overclocking[client] ? 2.0 : 1.0);
	SetGlobalTransTarget(client);
	if(Ratio==(OverheatingFeedBack_Overclocking[client] ? 2.0 : 1.0))
	{
		if(OverheatingFeedBack_MeltdownTime[client]<GameTime && !OverheatingFeedBack_FullMeltdown[client])
		{
			Attributes_Set(weapon, 5, 1.375);
			EmitSoundToClient(client, Minisemi_SoundLists[5]);
			OverheatingFeedBack_FullMeltdown[client]=true;
		}
		if(OverheatingFeedBack_HudTime[client]<GameTime)
		{
			TF2_AddCondition(client, TFCond_FocusBuff, Attributes_Get(weapon, 6, 0.25) *0.4);
			OverheatingFeedBack_HudTime[client] = GameTime+0.5;
			if(OverheatingFeedBack_Overclocking[client])
			{
				if(OverheatingFeedBack_FullMeltdown[client])
					PrintHintText(client, "%t\n%t\n%t",
					"Custom Mini Semi Gun: Overheating FeedBack - Overclocking",
					"Custom Mini Semi Gun: Overheating FeedBack - MAX", 
					"Custom Mini Semi Gun: Overheating FeedBack - Fully Meltdown");
				else
					PrintHintText(client, "%t\n%t\n%t",
					"Custom Mini Semi Gun: Overheating FeedBack - Overclocking", "Custom Mini Semi Gun: Overheating FeedBack - MAX", 
					"Custom Mini Semi Gun: Overheating FeedBack - Meltdown in", RoundToCeil(OverheatingFeedBack_MeltdownTime[client]-GameTime));
			}
			else
			{
				if(OverheatingFeedBack_FullMeltdown[client])
					PrintHintText(client, "%t\n%t",
					"Custom Mini Semi Gun: Overheating FeedBack - MAX", 
					"Custom Mini Semi Gun: Overheating FeedBack - Fully Meltdown");
				else
					PrintHintText(client, "%t\n%t",
					"Custom Mini Semi Gun: Overheating FeedBack - MAX", 
					"Custom Mini Semi Gun: Overheating FeedBack - Meltdown in", RoundToCeil(OverheatingFeedBack_MeltdownTime[client]-GameTime));
			}
		}
		if(!OverheatingFeedBack_FullCharge[client])
		{
			EmitSoundToClient(client, Minisemi_SoundLists[3]);
			OverheatingFeedBack_FullCharge[client]=true;
		}
	}
	else
	{
		OverheatingFeedBack_MeltdownTime[client]=GameTime + (11.75*Attributes_Get(weapon, 4, 1.0));
		if(OverheatingFeedBack_HudTime[client]<GameTime)
		{
			OverheatingFeedBack_HudTime[client] = GameTime+0.5;
			if(OverheatingFeedBack_Overclocking[client])
			{
				if(OverheatingFeedBack_FullMeltdown[client])
				{
					PrintHintText(client, "%t\n%t [%.0f％]\n%t",
					"Custom Mini Semi Gun: Overheating FeedBack - Overclocking",
					"Custom Mini Semi Gun: Overheating FeedBack - Charge",100.0*Ratio,
					"Custom Mini Semi Gun: Overheating FeedBack - Fully Meltdown");
				}
				else
				{
					PrintHintText(client, "%t\n%t [%.0f％]",
					"Custom Mini Semi Gun: Overheating FeedBack - Overclocking",
					"Custom Mini Semi Gun: Overheating FeedBack - Charge",100.0*Ratio);
				}
				
			}
			else
			{
				if(OverheatingFeedBack_FullMeltdown[client])
				{
					PrintHintText(client, "%t [%.0f％]\n%t",
					"Custom Mini Semi Gun: Overheating FeedBack - Charge",100.0*Ratio,
					"Custom Mini Semi Gun: Overheating FeedBack - Fully Meltdown");
				}
				else
				{
					PrintHintText(client, "%t [%.0f％]",
					"Custom Mini Semi Gun: Overheating FeedBack - Charge",100.0*Ratio);
				}
			}
		}
	}
	OverheatingFeedBack_RestTime[client] = GameTime + Attributes_Get(weapon, 6, 0.25) *0.4;
	if(OverheatingFeedBack_FullMeltdown[client])
		Ratio*=0.5;
	Attributes_Set(weapon, 1, Ratio+1.0);
	float spread = 0.7-(0.35*Ratio);
	if(spread < 0.3)spread = 0.3;
	Attributes_Set(weapon, 106, spread);
}

public void Weapon_Mini_Semi_Gun_OverheatingFeedBack_M2(int client, int weapon, bool crit, int slot)
{
	float Ability_CD = Ability_Check_Cooldown(client, slot);
	if(Ability_CD <= 0.0 || CvarInfiniteCash.BoolValue)
		Ability_CD = 0.0;
	if(Ability_CD || OverheatingFeedBack_Overclocking[client])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
		return;
	}
	float SetCoolDown = 15.0+(45.0 * CooldownReductionAmount(client));
	Rogue_OnAbilityUse(client, weapon);
	Ability_Apply_Cooldown(client, slot, SetCoolDown, .ignoreCooldown=true);
	Ability_Apply_Cooldown(client, 1, 15.0, .ignoreCooldown=true);
	EmitSoundToClient(client, Minisemi_SoundLists[4]);
	OverheatingFeedBack_Overclocking[client]=true;
}

/*public void Weapon_Mini_Semi_Gun_BulletStorm_Enable(int client, int weapon)
{
	
}*/

public void Weapon_Mini_Semi_Gun_BulletStorm_M1(int client, int weapon, bool crit, int slot)
{
	TF2_StunPlayer(client, (Attributes_Get(weapon, 6, 0.25)*0.4), 1.0, TF_STUNFLAG_NOSOUNDOREFFECT|TF_STUNFLAG_SLOWDOWN, client);
}

static Action Timer_ChangeStartSound(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if(!IsValidClient(client) && !IsPlayerAlive(client))
		return Plugin_Stop;
	switch(OverheatingFeedBack_Sounds[client])
	{
		case 0:
		{
			EmitSoundToAll(Minisemi_SoundLists[0], client, SNDCHAN_AUTO, 65, _, 1.0, 115);
			OverheatingFeedBack_Sounds[client]++;
		}
		case 1:
		{
			EmitSoundToAll(Minisemi_SoundLists[1], client, SNDCHAN_AUTO, 65, _, 0.9, 115);
			OverheatingFeedBack_Sounds[client]++;
		}
		default:
		{
			EmitSoundToAll(Minisemi_SoundLists[2], client, SNDCHAN_AUTO, 65, _, 0.9, 115);
			OverheatingFeedBack_Sounds[client]=0;
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}