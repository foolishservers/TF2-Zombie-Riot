#pragma semicolon 1
#pragma newdecls required

void AltExtra_Mecha_Shotgun_Main_OnMapStart() {
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mecha Shotgun Heavy");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mecha_shotgun_heavy");
	strcopy(data.Icon, sizeof(data.Icon), "heavy_shotgun");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Alt;
	data.Func = ClotSummon;
	NPC_Add(data);
	
	strcopy(data.Name, sizeof(data.Name), "Mecha Shotgun Engineer");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_extra_mecha_shotgun_engineer");
	strcopy(data.Icon, sizeof(data.Icon), "engineer");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Alt;
	data.Func = ClotSummon_Engineer;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team) {
	return AltExtra_Mecha_Shotgun_Main(vecPos, vecAng, team, 0);
}

static any ClotSummon_Engineer(int client, float vecPos[3], float vecAng[3], int team) {
	return AltExtra_Mecha_Shotgun_Main(vecPos, vecAng, team, 1);
}

methodmap AltExtra_Mecha_Shotgun_Main < AltExtra_Base {
	public AltExtra_Mecha_Shotgun_Main(float vecPos[3], float vecAng[3], int team, int class) {
		
	}
}

static void AltExtra_Mecha_Shotgun_Main_ClotThink(int iNPC)
{
	AltExtra_Mecha_Shotgun_Main npc = view_as<AltExtra_Mecha_Shotgun_Main>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if (npc.m_flNextDelayTime > gameTime) {
		return;
	}
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	npc.HackMaxYawRate(false);
	npc.UpdateBody();
	npc.HackMaxYawRate(true);

	if (npc.m_blPlayHurtAnimation) {
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if (npc.m_flNextThinkTime > gameTime) {
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	if (npc.m_flGetClosestTargetTime < gameTime) {
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	if (IsValidEnemy(npc.index, npc.m_iTarget)) {
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		switch(VestanTankerSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget))
		{
			case 0:
			{
				npc.m_bAllowBackWalking = false;
				// Get the normal prediction code.
				if (flDistanceToTarget < npc.GetLeadRadius()) {
					float vPredictedPos[3];
					PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
					npc.SetGoalVector(vPredictedPos);
				}
				else {
					npc.SetGoalEntity(npc.m_iTarget);
				}
			}
			case 1: {
				npc.m_bAllowBackWalking = true;
				
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true);
			}
		}
	}
	else {
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	npc.PlayIdleAlertSound();
}