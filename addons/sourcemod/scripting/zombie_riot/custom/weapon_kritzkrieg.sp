#pragma semicolon 1
#pragma newdecls required

//static Handle OC_Timer = null;

public void Kritzkrieg_OnMapStart()
{
	PrecacheSound("player/invuln_on_vaccinator.wav");
	PrecacheSound("player/mannpower_invulnerable.wav");
}
public void Kritzkrieg_PluginStart()
{
	HookEvent("player_chargedeployed", OnKritzkriegDeployed);
}

static void OnKritzkriegDeployed(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(!IsValidClient(client) || !IsPlayerAlive(client))
		return;

	int medigun;
	bool Continune = false, Adaptive = false;
	int ie;
	int entity;
	while(TF2_GetItem(client, entity, ie))
	{
		if(i_CustomWeaponEquipLogic[entity] == WEAPON_KRITZKRIEG)
		{
			medigun = entity;
			Continune = true;
		}
		if(i_CustomWeaponEquipLogic[entity] == WEAPON_ADAPTIVE_MEDIGUN)
		{
			medigun = entity;
			Adaptive = true;
		}
	}
	GiveMedigunBuffUber(medigun, client, client);
	int target = GetHealingTarget(client);
	if(IsValidAlly(client, target))
	{
		GiveMedigunBuffUber(medigun, client, target);
	}
	if(!Continune)
	{
		if(IsValidEntity(target) && IsValidClient(target))
			EmitSoundToClient(target, "player/invuln_on_vaccinator.wav", target, SNDCHAN_AUTO, 65, _, 0.6);

		EmitSoundToAll("player/invuln_on_vaccinator.wav", client, SNDCHAN_AUTO, 65, _, 0.6);
		
		if(Adaptive)
		{
			float Healing_Value = Attributes_GetOnWeapon(client, medigun, 8, true);
			if(IsValidClient(target) && IsPlayerAlive(target))
			{
				if(dieingstate[target] > 0)
					dieingstate[target] = 1;
				else
					HealEntityGlobal(client, target, (float(SDKCall_GetMaxHealth(target))*0.2)+Healing_Value, 1.25*Attributes_Get(medigun, 4002, 1.0), 1.0, HEAL_ABSOLUTE);
			}
			if(dieingstate[client] > 0)
				dieingstate[client] = 1;
			else
				HealEntityGlobal(client, client, (float(SDKCall_GetMaxHealth(client))*0.2)+Healing_Value, 1.25*Attributes_Get(medigun, 4002, 1.0), 1.0, HEAL_SELFHEAL);
			float position[3]; WorldSpaceCenter(client, position);
			for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
			{
				int npc = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
				if(IsValidEntity(npc) && GetTeam(npc) == TFTeam_Red)
				{
					float position2[3];
					WorldSpaceCenter(npc, position2);
					if(GetVectorDistance(position, position2,true)<250000.0)
						ApplyStatusEffect(client, npc, "UBERCHARGED", 3.0);
				}
			}
			for(int AoE=1; AoE<=MaxClients; AoE++)
			{
				if(IsValidClient(AoE) && IsPlayerAlive(AoE) && TeutonType[AoE] == TEUTON_NONE)
				{
					float position2[3];
					WorldSpaceCenter(AoE, position2);
					if(GetVectorDistance(position, position2,true)<250000.0)
					{
						TF2_AddCondition(AoE, TFCond_UberBulletResist, 3.0);
						TF2_AddCondition(AoE, TFCond_UberBlastResist, 3.0);
						TF2_AddCondition(AoE, TFCond_UberFireResist, 3.0);
						ApplyStatusEffect(client, AoE, "UBERCHARGED", 3.0);
					}
				}
			}
		}
		return;
	}
	if(IsValidEntity(target) && IsValidClient(target))
		EmitSoundToClient(target, "player/mannpower_invulnerable.wav", target, SNDCHAN_AUTO, 65, _, 0.6);

	EmitSoundToAll("player/mannpower_invulnerable.wav", client, SNDCHAN_AUTO, 65, _, 0.6);

	if(IsValidClient(target) && IsPlayerAlive(target)) 
		GiveArmorViaPercentage(target, 0.5, 1.0,_,_,client);
	else if(IsValidEntity(target) && !b_NpcHasDied[target])
		GrantEntityArmor(target, false, 0.5, 0.7, 0);
	GiveArmorViaPercentage(client, 0.5, 1.0,_,_,client);
	if(RaidbossIgnoreBuildingsLogic(1))
	{
		float flChargeLevel = GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel");
		flChargeLevel *= 0.65;
		SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", flChargeLevel);
	}
}
static int GetHealingTarget(int client)
{
	int medigun;
	int ie;
	int entity;
	int ActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	while(TF2_GetItem(client, entity, ie))
	{
		if(b_IsAMedigun[entity] && entity == ActiveWeapon)
		{
			medigun = entity;
		}
	}

	if(IsValidEntity(medigun))
	{
		static char classname[64];
		GetEntityClassname(medigun, classname, sizeof(classname));
		if(StrEqual(classname, "tf_weapon_medigun", false))
		{
			if(GetEntProp(medigun, Prop_Send, "m_bHealing"))
				return GetEntPropEnt(medigun, Prop_Send, "m_hHealingTarget");
		}
	}
	return -1;
}

void Kritzkrieg_Magical(int client, float Scale, bool apply)
{
	int entity, i;
	bool HasMageWeapon;
	while(TF2_GetItem(client, entity, i))
	{
		if(i_IsWandWeapon[entity])
		{
			HasMageWeapon = true;
			break;
		}
	}
	if(HasMageWeapon)
	{
		if(apply)
		{
			ManaCalculationsBefore(client);
			if(Current_Mana[client] < RoundToCeil(max_mana[client]))
			{
				Current_Mana[client] += RoundToCeil(mana_regen[client] * 20.0 * Scale);
					
				if(Current_Mana[client] > RoundToCeil(max_mana[client])) //Should only apply during actual regen
				{
					Current_Mana[client] = RoundToCeil(max_mana[client]);
				}
			}
		}
	}
}

int Adaptive_FastRevive(int client)
{
	int speed = 6;
	if(i_CurrentEquippedPerk[client] & 1)
		speed = 12;
	
	if(HasSpecificBuff(client, "Dimensional Turbulence"))
		speed *= 2;
	
	int activeWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(IsValidEntity(activeWeapon))
		speed = RoundToNearest(float(speed) * Attributes_Get(activeWeapon, Attrib_ReviveSpeedBonus, 1.0));
	Rogue_ReviveSpeed(speed);
	return speed;
}