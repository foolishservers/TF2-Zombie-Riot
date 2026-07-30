#pragma semicolon 1
#pragma newdecls required

#define SOUND_KILLINGORDER_FIRE      "Weapon_ManMelter.Single"
#define SOUND_KILLINGORDER_FIRE_CRIT "Weapon_ManMelter.SingleCrit"

void KillingOrder_Precache()
{
	PrecacheScriptSound(SOUND_KILLINGORDER_FIRE);
	PrecacheScriptSound(SOUND_KILLINGORDER_FIRE_CRIT);
}

public void KillingOrder_Fire(int client, int weapon, bool crit)
{
	b_LagCompNPC_ExtendBoundingBox = true;
	StartLagCompensation_Base_Boss(client);
	
	float pos[3], ang[3], endPos[3], hullMin[3], hullMax[3], direction[3];
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, ang);
	
	hullMin[0] = -1.0;		//Very small bounds to mimic actual hitscan.
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];
	
	GetAngleVectors(ang, direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(direction, 9999.0);
	AddVectors(pos, direction, endPos);
	
	float targetPos[3], hitPos[3];
	hitPos = endPos;
	
	bool headshot;
	int target = -1;
	Handle trace = TR_TraceHullFilterEx(pos, endPos, hullMin, hullMax, MASK_SHOT, BulletAndMeleeTrace, client);
	if(TR_GetFraction(trace) < 1.0)
	{
		TR_GetEndPosition(hitPos, trace);
		
		target = TR_GetEntityIndex(trace);
		if(target > 0)
		{
			WorldSpaceCenter(target, targetPos);
			
			headshot = (TR_GetHitGroup(trace) == HITGROUP_HEAD && !b_CannotBeHeadshot[target]);
		}
	}
	delete trace;
	
	if(target > 0 && IsValidEnemy(client, target))
	{
		float damage = 30.0;
		damage *= Attributes_Get(weapon, 1, 1.0);
		damage *= Attributes_Get(weapon, 2, 1.0);
		
		bool DoCalcReduceHeadshotFalloff = false;
		if (headshot)
		{
			DisplayCritAboveNpc(target, client, true);
			
			if(i_HeadshotAffinity[client] == 1)
			{
				damage *= 1.42;
			}
			else
			{
				damage *= 1.185;
			}
			
			if(i_CurrentEquippedPerk[client] & PERK_MARKSMAN_BEER)
			{
				damage *= 1.25;
			}
			if(i_CurrentEquippedPerk[client] & PERK_MARKSMAN_BEER_X)
			{
				damage *= 1.35;
			}
			
			DoCalcReduceHeadshotFalloff = true;
		}
		else
		{
			if(i_HeadshotAffinity[client] == 1)
			{
				damage *= 0.75;
			}
		}
		
		if(i_WeaponDamageFalloff[weapon] != 1.0)
		{
			if(b_ProximityAmmo[client])
			{
				damage *= 1.15;
			}
			
			float attackerPos[3];
			WorldSpaceCenter(client, attackerPos);

			float distance = GetVectorDistance(attackerPos, targetPos, true);
			
			distance -= 1600.0;// Give 60 units of range cus its not going from their hurt pos
			
			if(distance < 0.1)
			{
				distance = 0.1;
			}
			
			float WeaponDamageFalloff = i_WeaponDamageFalloff[weapon];
			if(b_ProximityAmmo[client])
			{
				WeaponDamageFalloff *= 0.8;
			}
			
			if(DoCalcReduceHeadshotFalloff && WeaponDamageFalloff <= 1.0)
			{
				WeaponDamageFalloff *= 1.3;
				if (WeaponDamageFalloff >= 1.0)
					WeaponDamageFalloff = 1.0;
			}
			
			damage *= Pow(WeaponDamageFalloff, (distance / 1000000.0));
		}
		
		SDKHooks_TakeDamage(target, client, client, damage, DMG_BULLET, weapon, NULL_VECTOR, targetPos);
	}
	
	FinishLagCompensation_Base_boss();
	
	Offset_Vector({ 60.9, 13.1, -15.1 }, ang, pos);
	TE_Particle("dxhr_sniper_rail", pos, _, ang, .controlpoint = 1, .controlpointattachment = PATTACH_WORLDORIGIN, .controlpointoffset = hitPos);
	
	EmitGameSoundToAll(headshot ? SOUND_KILLINGORDER_FIRE_CRIT : SOUND_KILLINGORDER_FIRE, weapon);
}

public void KillingOrder_OnDealDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int zr_custom_damage)
{
	if((zr_custom_damage & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED))
		return;
	
	ApplyStatusEffect(attacker, victim, "Identifying Targets", 4.0);
}