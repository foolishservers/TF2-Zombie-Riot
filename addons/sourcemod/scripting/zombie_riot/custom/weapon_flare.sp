#pragma semicolon 1
#pragma newdecls required

public void KillingOrder_OnDealDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int zr_custom_damage)
{
	if((zr_custom_damage & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED))
		return;
	
	if(IgniteFor[victim] < 0)
		return;
	
	ApplyStatusEffect(victim, attacker, "Identifying Targets", 3.0);
}