#pragma semicolon 1
#pragma newdecls required

public void Weapon_Medikit_M1(int client, int weapon, bool crit, int slot)
{
	if(Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}
	
	StartPlayerOnlyLagComp(client, true);
	int target = GetClientPointVisiblePlayersNPCs(client, 120.0, {0.0,0.0,0.0}, false);
	EndPlayerOnlyLagComp(client);

	if(!IsValidEntity(target))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return;
	}

	int health = GetEntProp(target, Prop_Send, "m_iHealth");
	int maxHealth = ReturnEntityMaxHealth(target);
	
	float healing = 35.0;
	float overheal = 1.15 * Attributes_Get(weapon, 4002, 1.0);
	
	if(health<maxHealth/2)
		healing*=1.15;
	
	healing *= Attributes_GetOnWeapon(client, weapon, 8, true);
	
	healing += float(maxHealth)*0.025;
	
	int Health_To_Max=HealEntityGlobal(client, target, healing, overheal, 0.5);
	
	if(Health_To_Max <= 0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return;
	}
	else
	{
		healing=float(Health_To_Max/3);
		HealEntityGlobal(client, client, healing, 1.0, 0.5);
	}
	
	float cooldown;
	cooldown = float(Health_To_Max) / 8.0;
	
	if(cooldown < 1.0)
		cooldown = 1.0;
	
	if(cooldown > 15.0)
		cooldown = 15.0;
	
	cooldown*=CooldownReductionAmount(client);
	
	ClientCommand(client, "playgamesound items/smallmedkit1.wav");
	if(target <= MaxClients)
	{
		ClientCommand(target, "playgamesound items/smallmedkit1.wav");
		PrintHintText(client, "%t\n%t", "You healed for", target, Health_To_Max, "Medi-Kit Cooldown", cooldown);
	}
	else
		PrintHintText(client, "%t\n%t", "You healed for NpcName", NpcStats_ReturnNpcName(target), Health_To_Max, "Medi-Kit Cooldown", cooldown);
	
	int BeamIndex;
	if(ZR_Get_Modifier()==2)
		BeamIndex = ConnectWithBeam(client, target, 0, 0, 255, 2.0, 2.0, 0.0, LASERBEAM);
	else
		BeamIndex = ConnectWithBeam(client, target, 30, 255, 0, 2.0, 2.0, 0.0, LASERBEAM);
	SetEntityRenderFx(BeamIndex, RENDERFX_FADE_FAST);
	CreateTimer(0.6, Timer_RemoveEntity, EntIndexToEntRef(BeamIndex), TIMER_FLAG_NO_MAPCHANGE);
	
	ApplyStatusEffect(client, target, "Healing Resolve", 10.0);
	ApplyStatusEffect(client, client, "Healing Resolve", 10.0);
	
	Ability_Apply_Cooldown(client, slot, cooldown, weapon, true);
	Ability_Apply_Cooldown(client, 2, cooldown, weapon, true);
}

public void Weapon_Medikit_M2(int client, int weapon, bool crit, int slot)
{
	if(Ability_Check_Cooldown(client, slot) > 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_Check_Cooldown(client, slot));
		return;
	}

	int health = GetEntProp(client, Prop_Send, "m_iHealth");
	int maxHealth = ReturnEntityMaxHealth(client);

	float healing = 35.0;
	float overheal = 1.15 * Attributes_Get(weapon, 4002, 1.0);
	
	if(health<maxHealth/2)
		healing*=1.15;
	
	healing *= Attributes_GetOnWeapon(client, weapon, 8, true);
	
	healing += float(maxHealth)*0.025;
	
	int Health_To_Max=HealEntityGlobal(client, client, healing, overheal, 0.5);
	
	if(Health_To_Max <= 0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return;
	}
	
	float cooldown;
	cooldown = float(Health_To_Max) / 5.0;
	
	if(cooldown < 1.0)
		cooldown = 1.0;
		
	if(cooldown > 25.0)
		cooldown = 25.0;
	
	cooldown*=CooldownReductionAmount(client);
	
	ClientCommand(client, "playgamesound items/smallmedkit1.wav");
	SetGlobalTransTarget(client);
	PrintHintText(client,"%t\n%t", "Medikit Healing Self", healing, "Medi-Kit Cooldown", cooldown);

	ApplyStatusEffect(client, client, "Healing Resolve", 5.0);

	Ability_Apply_Cooldown(client, 1, cooldown, weapon, true);
	Ability_Apply_Cooldown(client, slot, cooldown, weapon, true);
}