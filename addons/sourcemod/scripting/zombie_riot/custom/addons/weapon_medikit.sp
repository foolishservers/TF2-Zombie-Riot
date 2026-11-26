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
	
	float vecOrigin[3], vecAngles[3];
	GetClientEyePosition(client, vecOrigin);
	GetClientEyeAngles(client, vecAngles);
	
	StartPlayerOnlyLagComp(client, true);
	Handle hTrace = TR_TraceRayFilterEx(vecOrigin, vecAngles, ( MASK_SOLID | CONTENTS_SOLID ), RayType_Infinite, MedikitTrace_ClientOrNPCAlly, client);
	
	TR_GetEndPosition(vecAngles, hTrace);
	
	int target = -1;
	int iHit = TR_GetEntityIndex(hTrace);
	
	if(TR_DidHit(hTrace) && iHit != client && GetVectorDistance(vecOrigin, vecAngles, true) < 14400.0)
		target = iHit;
	delete hTrace;
	EndPlayerOnlyLagComp(client);

	if(!IsValidEntity(target))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return;
	}
	
	int PapNumber = RoundToCeil(Attributes_Get(weapon, Attrib_PapNumber, 1.0));

	int health = GetEntProp(target, Prop_Send, "m_iHealth");
	int maxHealth = ReturnEntityMaxHealth(target);
	
	float healing = 35.0;
	float overheal = 1.15 * Attributes_Get(weapon, 4002, 1.0);
	if(PapNumber==4||PapNumber==6||PapNumber==5||PapNumber==7)
	{
		//none
	}
	else if(health>=(maxHealth*overheal))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return;
	}
	
	if(health<maxHealth/2)
		healing*=1.15;
	
	healing *= Attributes_GetOnWeapon(client, weapon, 8, true);
	
	healing += float(maxHealth)*0.025;
	
	int Health_To_Max;
	if(target <= MaxClients && dieingstate[target] > 0)
	{
		if(i_CurrentEquippedPerk[client] & PERK_REGENE)
		{
			SetEntityHealth(target,  GetClientHealth(target) + 80);
			int savelive = dieingstate[target];
			savelive -= 30;
			if(savelive < 1)
				savelive = 1;
			dieingstate[target] = savelive;
		}
		else
		{
			SetEntityHealth(target,  GetClientHealth(target) + 40);
			int savelive = dieingstate[target];
			savelive -= 15;
			if(savelive < 1)
				savelive = 1;
			dieingstate[target] = savelive;
		}
		Health_To_Max=80;
	}
	else
	{
		HealEntityGlobal(client, target, healing, overheal, 0.5, .AddUberCharge = Attributes_GetOnWeapon(client, weapon, Attrib_AddUberChargeOnHeal, true));
		Health_To_Max=RoundToNearest(healing);
	}
	
	if(Health_To_Max > 0)
	{
		healing=float(Health_To_Max/2);
		HealEntityGlobal(client, client, healing, 1.0, 0.5);
	}
	
	float cooldown;
	cooldown = float(Health_To_Max) / 8.0;
	
	if(cooldown < 1.0)
		cooldown = 1.0;
	
	if(cooldown > 15.0)
		cooldown = 15.0;
	
	switch(PapNumber)
	{
		case 2,3://IFAK
		{
			ApplyStatusEffect(client, target, "Healing Resolve", 10.0);
			ApplyStatusEffect(client, client, "Healing Resolve", 10.0);
			
			ApplyStatusEffect(client, target, "Thick Blood", 5.0);
			ApplyStatusEffect(client, client, "Thick Blood", 5.0);
			ApplyStatusEffect(client, target, "Fluid Movement", 5.0);
			ApplyStatusEffect(client, client, "Fluid Movement", 5.0);
		}
		case 4,6://Stim Packs
		{
			if(dieingstate[client] <= 0 && target <= MaxClients && dieingstate[target] > 0 && PapNumber==6)
			{
				ApplyStatusEffect(client, target, "Defibrillator", 2.0);
				cooldown = 15.0;
			}
			ApplyStatusEffect(client, target, "Battle StimPacks", 8.0);
			ApplyStatusEffect(client, client, "Healing Resolve", 8.0);
		}
		case 5,7://Mana Injector
		{
			if(target <= MaxClients)
			{
				if(Current_Mana[client] > 0)
				{
					int mana_cost = RoundToCeil((max_mana[client])*(PapNumber==7 ? 1.0 : 0.75));
					if(mana_cost > Current_Mana[client])
						mana_cost = Current_Mana[client];
					if(mana_cost > 2000)
						mana_cost = 2000;
					Current_Mana[client] -= mana_cost;
					SDKhooks_SetManaRegenDelayTime(client, 5.0);
					
					mana_cost = RoundToCeil(float(mana_cost)*2.0);
					int Max_mana = RoundToCeil((400.0*Mana_Regen_Level[target]));
					if(mana_cost > Max_mana)
						mana_cost = Max_mana;
					Current_Mana[target] += mana_cost;
					cooldown = 15.0;
				}
			}
			ApplyStatusEffect(client, target, "Healing Resolve", 5.0);
			ApplyStatusEffect(client, client, "Healing Resolve", 5.0);
		}
		case 8,9://Armor Pack
		{
			healing = 86.96;
			if(target <= MaxClients)
			{
				float nerfcuredarmor = Attributes_GetOnWeapon(client, weapon, 8, true)/2.5;
				if(nerfcuredarmor < 1.0)
					nerfcuredarmor = 1.0;
				healing *= nerfcuredarmor;
				int Armor_Max = MaxArmorCalculation(Armor_Level[target], target, 1.0);
				if(Armor_Charge[target]<float(Armor_Max)/2.0)
					healing *= 1.15;
				healing *= (PapNumber == 9 ? 1.5 : 1.22);
				healing += (float(Armor_Max)*0.2);
				
				bool JustCuredArmor = false;
				if(Armor_Charge[target] < 0)
				{
					JustCuredArmor = true;
					healing *= 2.0;
				}
				GiveArmorViaPercentage(target, healing, overheal, true,_,client);

				if(JustCuredArmor && Armor_Charge[target] > 0)
					Armor_Charge[target] = 0;
			}
			else
			{
				healing *= Attributes_GetOnWeapon(client, weapon, 8, true);
				healing *= (PapNumber == 9 ? 1.5 : 1.22);
				CClotBody npc = view_as<CClotBody>(target);
				if(npc.m_flArmorCount<float(maxHealth)/2.0)
					healing *= 1.22;
				healing *= 1.5;
				healing += float(maxHealth)*0.1;
				GrantEntityArmor(target, false, overheal, 0.25, 0,
					healing, client);
			}
			cooldown = 15.0;
			ApplyStatusEffect(client, target, "Healing Resolve", 5.0);
			ApplyStatusEffect(client, client, "Healing Resolve", 5.0);
		}
		default:
		{
			ApplyStatusEffect(client, target, "Healing Resolve", 10.0);
			ApplyStatusEffect(client, client, "Healing Resolve", 10.0);
		}
	}
	
	cooldown*=Attributes_Get(weapon, 41, 1.0);
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
	if(ZR_Get_Modifier() == 2)
		BeamIndex = ConnectWithBeam(client, target, 0, 0, 255, 2.0, 2.0, 0.0, LASERBEAM);
	else
		BeamIndex = ConnectWithBeam(client, target, 30, 255, 0, 2.0, 2.0, 0.0, LASERBEAM);
	SetEntityRenderFx(BeamIndex, RENDERFX_FADE_FAST);
	CreateTimer(0.6, Timer_RemoveEntity, EntIndexToEntRef(BeamIndex), TIMER_FLAG_NO_MAPCHANGE);
	
	Ability_Apply_Cooldown(client, slot, cooldown, weapon, true);
	
	if(Ability_Check_Cooldown(client, 2) < cooldown)
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
	float overheal = 1.15 * Attributes_Get(weapon, 4002, 1.0);
	if(overheal < 1.0)
		overheal = 1.0;
	
	if(health>=(maxHealth*overheal))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return;
	}
	
	float healing = 35.0;
	
	if(health<maxHealth/2)
		healing*=1.15;
	
	healing *= Attributes_GetOnWeapon(client, weapon, 8, true);
	
	healing += float(maxHealth)*0.025;
	
	int Health_To_Max;
	if(dieingstate[client] > 0)
	{
		if(i_CurrentEquippedPerk[client] & PERK_REGENE)
		{
			SetEntityHealth(client,  GetClientHealth(client) + 80);
			int savelive = dieingstate[client];
			savelive -= 30;
			if(savelive < 1)
				savelive = 1;
			dieingstate[client] = savelive;
		}
		else
		{
			SetEntityHealth(client,  GetClientHealth(client) + 40);
			int savelive = dieingstate[client];
			savelive -= 15;
			if(savelive < 1)
				savelive = 1;
			dieingstate[client] = savelive;
		}
	}
	else
	{
		HealEntityGlobal(client, client, healing, overheal, 0.5);
		Health_To_Max=RoundToNearest(healing);
	}
	
	int PapNumber = RoundToCeil(Attributes_Get(weapon, Attrib_PapNumber, 1.0));
	
	float cooldown;
	cooldown = float(Health_To_Max) / 5.0;
	
	if(cooldown < 1.0)
		cooldown = 1.0;
		
	if(cooldown > 25.0)
		cooldown = 25.0;
	
	cooldown *= Attributes_Get(weapon, 41, 1.0);

	switch(PapNumber)
	{
		case 2,3://IFAK
		{
			ApplyStatusEffect(client, client, "Healing Resolve", 5.0);
			ApplyStatusEffect(client, client, "Thick Blood", 2.5);
			ApplyStatusEffect(client, client, "Fluid Movement", 2.5);
		}
		case 4,6://Stim Packs
		{
			if(PapNumber == 6 && dieingstate[client] > 0)
				ApplyStatusEffect(client, client, "Defibrillator", 2.0);
			ApplyStatusEffect(client, client, "Battle StimPacks", 8.0);
		}
		case 8,9://Armor Pack
		{
			healing = 86.96;
			healing *= Attributes_GetOnWeapon(client, weapon, 8, true);
			int Armor_Max = MaxArmorCalculation(Armor_Level[client], client, 1.0);
			if(Armor_Charge[client]<float(Armor_Max)/2.0)
				healing *= 1.15;
			healing *= (PapNumber == 9 ? 1.5 : 1.22);
			healing += (float(Armor_Max)*0.2);
			
			bool JustCuredArmor = false;
			if(Armor_Charge[client] < 0)
			{
				JustCuredArmor = true;
				healing *= 2.0;
			}
			GiveArmorViaPercentage(client, healing, 1.0, true,_,client);

			if(JustCuredArmor && Armor_Charge[client] > 0)
				Armor_Charge[client] = 0;
			cooldown *= 1.2;
		}
		default: ApplyStatusEffect(client, client, "Healing Resolve", 5.0);
	}
	
	cooldown *= CooldownReductionAmount(client);
	
	ClientCommand(client, "playgamesound items/smallmedkit1.wav");
	SetGlobalTransTarget(client);
	PrintHintText(client,"%t\n%t", "Medikit Healing Self", Health_To_Max, "Medi-Kit Cooldown", cooldown);
	
	if(Ability_Check_Cooldown(client, 1) < cooldown)
		Ability_Apply_Cooldown(client, 1, cooldown, weapon, true);
	if(PapNumber==6 && dieingstate[client] > 0)
		cooldown=300.0;
	Ability_Apply_Cooldown(client, slot, cooldown, weapon, true);
}

static bool MedikitTrace_ClientOrNPCAlly(int entity, int mask, any data)
{
	if(entity == data)
		return false;
	
	if(entity <= MaxClients)
	{
		if(GetTeam(entity) == GetTeam(data))
			return true;
	}
	
	if(!b_NpcHasDied[entity])
	{
		if(IsValidAlly(data, entity))
			return true;
	}
	
	return false;
}