#pragma semicolon 1
#pragma newdecls required

static const char g_TeleDeathSound[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav",
};

static const char g_DeathSounds[][] = {
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav",
};

static const char g_HurtSounds[][] = {
	"npc/combine_soldier/pain1.wav",
	"npc/combine_soldier/pain2.wav",
	"npc/combine_soldier/pain3.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/hardenthatposition.wav",
	"npc/combine_soldier/vo/overwatchreportspossiblehostiles.wav",
	"npc/combine_soldier/vo/readyweaponshostilesinbound.wav",
	"npc/combine_soldier/vo/swarmoutbreakinsector.wav",
	"npc/combine_soldier/vo/targetcompromisedmovein.wav",
	"npc/combine_soldier/vo/overwatchsectoroverrun.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
	"npc/combine_soldier/vo/prosecuting.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"npc/vort/claw_swing1.wav",
	"npc/vort/claw_swing2.wav",
};

static const char g_MeleeHitSounds[][] = {
	"physics/body/body_medium_impact_hard1.wav",
	"physics/body/body_medium_impact_hard2.wav",
	"physics/body/body_medium_impact_hard3.wav",
	"physics/body/body_medium_impact_hard4.wav",
	"physics/body/body_medium_impact_hard5.wav",
	"physics/body/body_medium_impact_hard6.wav",
};

static const char g_BoomSounds[][] = {
	"weapons/mortar/mortar_explode1.wav",
	"weapons/mortar/mortar_explode2.wav",
	"weapons/mortar/mortar_explode3.wav",
};

static char g_PullSounds[][] = {
	"weapons/rpg/rocketfire1.wav",
};

/*
static const char g_MeleeComboSounds[][] = {
	"physics/body/body_medium_break2.wav",
	"physics/body/body_medium_break3.wav",
	"physics/body/body_medium_break4.wav",
};
*/

static const char g_MeleeStunSounds[][] = {
	"ambient/energy/zap5.wav",
	"ambient/energy/zap6.wav",
	"ambient/energy/zap9.wav",
};

static char g_RangedAttackSounds[][] = {
	"npc/attack_helicopter/aheli_mine_drop1.wav",
};

static char g_ArmorSounds[][] = {
	"physics/metal/metal_box_strain2.wav"
};

static int LastEnemyTargeted[MAXENTITIES];



static float f_TalkDelayCheck;
static int i_TalkDelayCheck;
static int usage;

static int NpcID;

int OmegaRaidNpcID()
{
	return NpcID;
}

void OmegaRaid_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_TeleDeathSound));	   i++) { PrecacheSound(g_TeleDeathSound[i]);	   }
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_MeleeStunSounds));   i++) { PrecacheSound(g_MeleeStunSounds[i]);   }
	for (int i = 0; i < (sizeof(g_BoomSounds));   i++) { PrecacheSound(g_BoomSounds[i]);   }
	for (int i = 0; i < (sizeof(g_PullSounds));   i++) { PrecacheSound(g_PullSounds[i]);   }
	for (int i = 0; i < (sizeof(g_ArmorSounds));   i++) { PrecacheSound(g_ArmorSounds[i]);   }
	PrecacheModel("models/combine_super_soldier.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Omega");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_omega_raid");
	strcopy(data.Icon, sizeof(data.Icon), "omega");
	PrecacheSound("#zombiesurvival/combinehell/cauterizer.mp3");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	NpcID = NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return OmegaRaid(vecPos, vecAng, ally, data);
}

methodmap OmegaRaid < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}

	public void PlayPullSound() {
		EmitSoundToAll(g_PullSounds[GetRandomInt(0, sizeof(g_PullSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	public void PlayTeleSound() {
		EmitSoundToAll(g_TeleDeathSound[GetRandomInt(0, sizeof(g_TeleDeathSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);

	}
	public void PlayMeleeStunSound() 
	{
		EmitSoundToAll(g_MeleeStunSounds[GetRandomInt(0, sizeof(g_MeleeStunSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);

	}
	public void PlayBoomSound() 
	{
		EmitSoundToAll(g_BoomSounds[GetRandomInt(0, sizeof(g_BoomSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);

	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 95);
		
	}
	public void PlayArmorSound() {
		EmitSoundToAll(g_ArmorSounds[GetRandomInt(0, sizeof(g_ArmorSounds) - 1)], this.index, _, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 95);
		
	}
	public void ArmorSet(float resistance = -1.0, bool uber = false)
	{
		if(resistance != -1.0 && resistance >= 0.0)
		{
			this.m_flMeleeArmor = resistance;
			this.m_flRangedArmor = resistance;
		}
		b_NpcIsInvulnerable[this.index] = uber;
	}

	property int i_GunMode
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	property float m_flOmegaAirbornAttack
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	property float m_flOmegaRPGCD
	{
		public get()							{ return fl_RangedSpecialDelay[this.index]; }
		public set(float TempValueForProperty) 	{ fl_RangedSpecialDelay[this.index] = TempValueForProperty; }
	}
	property float m_flOmegaRPGHappening
	{
		public get()							{ return fl_AttackHappens_2[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AttackHappens_2[this.index] = TempValueForProperty; }
	}
	property float m_flThrowSupportGrenadeHappening
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flRollermineSpawn
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	public int FireGrenade(float vecTarget[3])
	{
		int entity = CreateEntityByName("tf_projectile_pipe_remote");
		if(IsValidEntity(entity))
		{
			float vecForward[3], vecSwingStart[3], vecAngles[3];
			this.GetVectors(vecForward, vecSwingStart, vecAngles);
	
			GetAbsOrigin(this.index, vecSwingStart);
			vecSwingStart[2] += 90.0;
	
			MakeVectorFromPoints(vecSwingStart, vecTarget, vecAngles);
			GetVectorAngles(vecAngles, vecAngles);
	
			vecSwingStart[0] += vecForward[0] * 64;
			vecSwingStart[1] += vecForward[1] * 64;
			vecSwingStart[2] += vecForward[2] * 64;
	
			vecForward[0] = Cosine(DegToRad(vecAngles[0]))*Cosine(DegToRad(vecAngles[1]))*800.0;
			vecForward[1] = Cosine(DegToRad(vecAngles[0]))*Sine(DegToRad(vecAngles[1]))*800.0;
			vecForward[2] = Sine(DegToRad(vecAngles[0]))*-800.0;
			
			SetEntProp(entity, Prop_Data, "m_nNextThinkTick", -1);
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", this.index);
			SetEntProp(entity, Prop_Send, "m_iType", 1);
			
			SetEntProp(entity, Prop_Send, "m_iTeamNum", TFTeam_Blue);
			TeleportEntity(entity, vecSwingStart, vecAngles, NULL_VECTOR);
			DispatchSpawn(entity);
			SetEntityModel(entity, "models/Items/battery.mdl");
			SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 1.1);
			TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vecForward);
			b_StickyIsSticking[entity] = true;
			
	//		SetEntProp(entity, Prop_Send, "m_bTouched", true);
			SetEntityCollisionGroup(entity, 1);
			return entity;
		}
		return -1;
	}
	
	public OmegaRaid(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		OmegaRaid npc = view_as<OmegaRaid>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.25", "1000000", ally));

		bool item = StrContains(data, "item") != -1;
		if(item)
		{
			b_NpcUnableToDie[npc.index] = true;
			i_RaidGrantExtra[npc.index] = 5;
			npc.m_flSpeed = 300.0;
		}
		else
		{
			npc.m_bDissapearOnDeath = true;
			npc.m_flSpeed = 310.0;
		}
		
		i_NpcWeight[npc.index] = 5;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		RaidAllowLastman = true;
		
		int iActivity = npc.LookupActivity("ACT_BRAWLER_RUN");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iAttacksTillReload = 12;

		npc.m_fbGunout = false;

		func_NPCFuncWin[npc.index] = RaidMode_OmegaRaid_WinCondition;

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		npc.m_flOmegaRPGCD = GetGameTime(npc.index) + 6.0;
		i_TalkDelayCheck = -1;

		npc.m_iWearable2 = npc.EquipItem("head", "models/combine_super_soldier.mdl");
		npc.m_iWearable3 = npc.EquipItem("partyhat", "models/player/items/sniper/jarate_headband.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		npc.m_iWearable4 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_rocket_launcher.mdl");
		AcceptEntityInput(npc.m_iWearable4, "Disable");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetVariantString("1.25");

		func_NPCDeath[npc.index] = view_as<Function>(OmegaRaid_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(OmegaRaid_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(OmegaRaid_ClotThink);

		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0, 100);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0, 100);	

		if(item)
		{
			RaidModeTime = GetGameTime(npc.index) + 240.0;
		}
		else
		{
			RaidModeTime = GetGameTime(npc.index) + 200.0;
		}
		b_thisNpcIsARaid[npc.index] = true;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		npc.m_bWasSadAlready = false;
		npc.m_fbRangedSpecialOn = false;
		npc.m_flOmegaAirbornAttack = GetGameTime(npc.index) + 7.5;
		npc.m_flThrowSupportGrenadeHappening = GetGameTime(npc.index) + 15.0;
		npc.m_flRollermineSpawn = GetGameTime(npc.index) + 20.0;

		AlreadySaidWin = false;
		
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%s", "Omega shows up");
			}
		}
		
		if(Waves_InFreeplay())
		{
			switch(GetRandomInt(0,2))
			{
				case 0:
					NPCTalkMessage(npc.index, "Apologies for being late, got held up by this guy called {fullblue}Pablo{default}.");
				case 1:
					NPCTalkMessage(npc.index, "Time for a friendly skirmish!");
				case 2:
					NPCTalkMessage(npc.index, "So, you called?");
			}
		}
		else
		{
			switch(GetRandomInt(0,2))
			{
				case 0:
					NPCTalkMessage(npc.index, "Fuck this, I don't need my weapons to dispose of you.");
				case 1:
					NPCTalkMessage(npc.index, "We meet once again.");
				case 2:
					NPCTalkMessage(npc.index, "A lot of dead bodies on the way here.");
			}
		}

		char buffers[3][64];
		ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
		//the very first and 2nd char are SC for scaling
		if(buffers[0][0] == 's' && buffers[0][1] == 'c')
		{
			//remove SC
			ReplaceString(buffers[0], 64, "sc", "");
			float value = StringToFloat(buffers[0]);
			RaidModeScaling = value;
		}
		else
		{	
			RaidModeScaling = float(Waves_GetRoundScale()+1);
		}
		
		if(RaidModeScaling < 35)
		{
			RaidModeScaling *= 0.25; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.5;
		}
		float amount_of_people = float(CountPlayersOnRed());
		
		if(amount_of_people > 12.0)
		{
			amount_of_people = 12.0;
		}
		
		amount_of_people *= 0.15;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;
			
		RaidModeScaling *= amount_of_people;
		
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/combinehell/cauterizer.mp3");
		music.Time = 190;
		music.Volume = 2.0;
		music.Custom = false;
		strcopy(music.Name, sizeof(music.Name), "Cauterizer (+ Gravity Perforation Detail)");
		strcopy(music.Artist, sizeof(music.Artist), "Valve");
		Music_SetRaidMusic(music);

		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.Anger = false;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
				
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

static void NPCTalkMessage(int entity, const char[] message)
{
	PrintNPCMessageWithPrefixes(entity, "gold", message);
}

static void RocketBarrage_Ability(OmegaRaid npc, int target)
{
	if(npc.m_flOmegaAirbornAttack < GetGameTime(npc.index))
	{
		usage = 1;
		if(IsValidEnemy(npc.index, target))
		{
			static float flPos[3]; 
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
			flPos[2] += 5.0;
			ParticleEffectAt(flPos, "taunt_flip_land_red", 0.25);
			npc.PlayPullSound();
			flPos[2] += 500.0;
			npc.SetVelocity({0.0,0.0,0.0});
			PluginBot_Jump(npc.index, flPos);
			AcceptEntityInput(npc.m_iWearable4, "Enable");
			//ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 3.0);
			npc.m_flOmegaRPGHappening = GetGameTime(npc.index) + 1.0;
			//b_NoGravity[npc.index] = true;

			npc.AddGesture("ACT_RANGE_ATTACK_RPG");
			npc.PlayRangedSound();
			float VecEnemy[3]; WorldSpaceCenter(target, VecEnemy);
			//int MaxCount = RoundToNearest(2.0 * RaidModeScaling);
			npc.FaceTowards(VecEnemy, 99999.9);
			//float pos[3];
			//GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			//pos[2] += 5.0;
			//float ang_Look[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang_Look);
			npc.m_flOmegaAirbornAttack = GetGameTime(npc.index) + 20.0;
			if(npc.Anger)
				ApplyStatusEffect(npc.index, npc.index, "Defensive Backup", 3.0);

			if(!IsValidEntity(npc.m_iWearable8))
			{
				float flAng[3];
				npc.GetAttachment("back_lower1", flPos, flAng);
				npc.m_iWearable8 = ParticleEffectAt_Parent(flPos, "rocketpack_exhaust", npc.index, "back_lower1", {0.0, 0.0, 0.0});
			}
		}
	}
}

static bool Omega_AirAttack(OmegaRaid npc)
{
	if(npc.m_flOmegaRPGHappening)
	{
		if(!IsValidEnemy(npc.index, npc.m_iTarget))
		{
			//bool ForceRedo = false;
			npc.m_flGetClosestTargetTime = 0.0;
			
			if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
			{
				npc.m_iTarget = GetClosestTarget(npc.index);
				npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
			}
		}
		else
		{
			npc.SetGoalEntity(npc.m_iTarget);
			if(npc.m_flAttackHappens < GetGameTime(npc.index))
			{
				int TargetEnemy = false;
				TargetEnemy = GetClosestTarget(npc.index,.ingore_client = LastEnemyTargeted[npc.index],  .CanSee = true, .UseVectorDistance = true);
				LastEnemyTargeted[npc.index] = TargetEnemy;
				if(TargetEnemy == -1)
				{
					TargetEnemy = GetClosestTarget(npc.index, .CanSee = true, .UseVectorDistance = true);
				}
				if(IsValidEnemy(npc.index, TargetEnemy))
				{
					npc.m_flAttackHappens = GetGameTime(npc.index) + 0.25;
					if(npc.Anger)
					{
						npc.m_flAttackHappens = GetGameTime(npc.index) + 0.15;
					}

					npc.AddGesture("ACT_RANGE_ATTACK_RPG",_,_,_, 2.0);
					int PrimaryThreatIndex = npc.m_iTarget;
					float DamageCalc = 30.0 * RaidModeScaling;
					float VecEnemy[3]; WorldSpaceCenter(TargetEnemy, VecEnemy);
					float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
					npc.FaceTowards(VecEnemy, 100.0);
					npc.PlayRangedSound();
					npc.FireRocket(vecTarget, DamageCalc, 1000.0, "models/weapons/w_missile.mdl", 1.75);
				}
			}
		}
		if(npc.m_flOmegaRPGHappening < GetGameTime(npc.index))
		{
			if(npc.m_iChanged_WalkCycle != 999)
			{
				npc.m_iChanged_WalkCycle = 999;
				i_NpcWeight[npc.index] = 999;
				b_NoGravity[npc.index] = true;
				npc.m_flAttackHappens = 0.0;
				npc.SetVelocity({0.0,0.0,0.0});
				npc.m_flOmegaRPGHappening = GetGameTime(npc.index) + 2.0;	
				npc.m_bisWalking = false;
				//npc.SetActivity("ACT_MP_JUMP_FLOAT_MELEE_ALLCLASS");
				return true;
			}
			usage = 0;
			npc.m_iChanged_WalkCycle = 0;
			i_NpcWeight[npc.index] = 4;
			b_NoGravity[npc.index] = false;
			npc.i_GunMode = 0;
			npc.m_flAttackHappens = 0.0;
			npc.m_flOmegaRPGHappening = 0.0;	
			npc.SetVelocity({0.0,0.0,-1000.0});
			//npc.LookupActivity("ACT_BRAWLER_RUN");
			if(IsValidEntity(npc.m_iWearable8))
				RemoveEntity(npc.m_iWearable8);
			AcceptEntityInput(npc.m_iWearable4, "Disable");
			npc.m_bisWalking = true;
		}
		return true;
	}
	return false;
}

public void OmegaRaid_ClotThink(int iNPC)
{
	OmegaRaid npc = view_as<OmegaRaid>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();

	if(LastMann)
	{
		if(!npc.m_fbGunout)
		{
			npc.m_fbGunout = true;
			
			if(Waves_InFreeplay())
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
					{
						NPCTalkMessage(npc.index, "You've 'beat' me once before, come on, you can do it a second time.");
					}
					case 1:
					{
						NPCTalkMessage(npc.index, "If you can't beat me... I guess I'll get out of retirement to save the world myself.");
					}
				}
			}
			else
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
					{
						NPCTalkMessage(npc.index, "One shot, one kill.");
					}
					case 1:
					{
						NPCTalkMessage(npc.index, "Hand him over and I might just let you walk out of here alive.");
					}
				}
			}
		}
	}

	if(npc.m_bWasSadAlready)
	{
		npc.StopPathing();
		if(OmegasRabiling(npc.index))
		{
			npc.m_bDissapearOnDeath = true;
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		}
		else
		{
			float flMaxhealth = float(ReturnEntityMaxHealth(npc.index));
			flMaxhealth *= 0.01;
			HealEntityGlobal(npc.index, npc.index, flMaxhealth, 50.0, 0.0, HEAL_SELFHEAL);
			RaidModeScaling += GetRandomFloat(5.0, 10.0);
		}
		return;
	}

	if(i_RaidGrantExtra[npc.index] == RAIDITEM_INDEX_WIN_COND)
	{
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		
		NPCTalkMessage(npc.index, "Well...now what?");
		return;
	}

	//idk it never was in a bracket
	if(IsValidEntity(RaidBossActive) && RaidModeTime < GetGameTime())
	{
		if(RaidModeTime < GetGameTime())
		{
			ForcePlayerLoss();
			RaidBossActive = INVALID_ENT_REFERENCE;
			NPCTalkMessage(npc.index, "Tempus Fugit.");
			func_NPCThink[npc.index] = INVALID_FUNCTION;
			return;
		}
	}

	//Spawn Rollermines
	if(npc.m_flRollermineSpawn < GetGameTime(npc.index))
	{	
		//If he's using the RPG, this animation won't play
		if(usage != 1)
		{
			npc.AddGesture("ACT_COMBINE_THROW_GRENADE");
		}
		npc.m_fbRangedSpecialOn = true;
		OmegaCreateRollermines(iNPC);
		npc.m_flRollermineSpawn = GetGameTime(npc.index) + 17.5;
		//Half-life cooldown reduction
		if(npc.Anger)
		{
			npc.m_flRollermineSpawn = GetGameTime(npc.index) + 12.5;
		}
	}

	//Throw Grenade
	if(npc.m_flThrowSupportGrenadeHappening < GetGameTime(npc.index))
	{
		//If he's using the RPG, this animation won't play
		if(usage != 1)
		{
			npc.AddGesture("ACT_METROPOLICE_DEPLOY_MANHACK");
		}
		npc.m_fbRangedSpecialOn = true;
		OmegaThrowGrenadeHappening(npc);
		npc.m_flThrowSupportGrenadeHappening = GetGameTime(npc.index) + 30.0;
		//Half-life cooldown reduction
		if(npc.Anger)
		{
			npc.m_flRollermineSpawn = GetGameTime(npc.index) + 25.0;
		}
	}

	if(npc.m_flOmegaRPGHappening)
	{
		if(Omega_AirAttack(npc))
			return;
	}
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	int closest = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, closest))
	{
		float vecTarget[3]; WorldSpaceCenter(closest, vecTarget);
			
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		float gameTime = GetGameTime(npc.index);
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, closest, _, _, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(closest);
		}
		if(npc.m_flNextRangedSpecialAttack < GetGameTime(npc.index) && flDistanceToTarget > 62500 && flDistanceToTarget < 122500 && npc.m_flReloadDelay < GetGameTime(npc.index))
		{
			RocketBarrage_Ability(npc, closest);
			npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 20.0;
			if(npc.Anger)
			{
				npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 15.0;
			}
		}
		
		Omegas_SelfDefense(npc, gameTime, npc.m_iTarget, flDistanceToTarget);
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();

}

void OmegaThrowGrenadeHappening(OmegaRaid npc)
{
	if(npc.m_flThrowSupportGrenadeHappening)
	{
		if(npc.m_flThrowSupportGrenadeHappening < GetGameTime(npc.index))
		{
			switch(GetRandomInt(0,4)) //Armornade voicelines
			{
				case 0:
				{
					NPCTalkMessage(npc.index, "See this area? I feel like denying it.");
				}
				case 1:
				{
					NPCTalkMessage(npc.index, "You didn't think you were the only ones with grenades, did you?");
				}
				case 2:
				{
					NPCTalkMessage(npc.index, "I knew these would come in handy.");
				}
				case 3:
				{
					NPCTalkMessage(npc.index, "You've got too much space to maneuver around in, I think I'll restrict some of it.");
				}
				case 4:
				{
					NPCTalkMessage(npc.index, "I never come unprepared.");
				}
			}
			npc.m_flThrowSupportGrenadeHappening = 0.0;
			float vecTarget[3];
			float VecStart[3]; WorldSpaceCenter(npc.index, VecStart );

			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				PredictSubjectPositionForProjectiles(npc, npc.index, 800.0,_,vecTarget);
			}
			else
			{
				WorldSpaceCenter(npc.index, vecTarget);
				//incase theres no valid enemy, throw onto ourselves instead.
			}
			//damage doesnt matter.
			int Grenade = npc.FireGrenade(vecTarget);
			float GrenadeRangeSupport = 250.0;
			float damage = 60.0;
			damage *= 0.50;
			damage *= RaidModeScaling;
			float HealDo = 1.0;
			Omega_GrenadeSupportDo(npc.index, Grenade, damage, GrenadeRangeSupport, HealDo);
			float SpeedReturn[3];
			ArcToLocationViaSpeedProjectile(Grenade, vecTarget, SpeedReturn, 1.75, 1.0);
			TeleportEntity(Grenade, NULL_VECTOR, NULL_VECTOR, SpeedReturn);
			//Throw a grenade towards the target!
		}
	}
}

void Omega_GrenadeSupportDo(int entity, int grenade, float damage, float RangeSupport, float HealDo)
{
	DataPack pack;
	CreateDataTimer(1.5, Timer_Omega_SupportGrenade, pack, TIMER_REPEAT);
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteCell(EntIndexToEntRef(grenade));
	pack.WriteFloat(damage);
	pack.WriteFloat(RangeSupport * 0.9);
	pack.WriteFloat(HealDo);

	
	DataPack pack2;
	CreateDataTimer(0.25, Timer_Omega_SupportGrenadeIndication, pack2, TIMER_REPEAT);
	pack2.WriteCell(EntIndexToEntRef(entity));
	pack2.WriteCell(EntIndexToEntRef(grenade));
	pack2.WriteFloat(damage);
	pack2.WriteFloat(RangeSupport);
}

public Action Timer_Omega_SupportGrenadeIndication(Handle timer, DataPack pack)
{
	pack.Reset();
	int OwnerNpc = EntRefToEntIndex(pack.ReadCell());
	int Projectile = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(OwnerNpc))
	{
		if(IsValidEntity(Projectile))
		{
			//Cancel.
			RemoveEntity(Projectile);
		}
		return Plugin_Stop;
	}
	else
	{
		if(!IsEntityAlive(OwnerNpc))
		{
			if(IsValidEntity(Projectile))
			{
				//Cancel.
				RemoveEntity(Projectile);
			}
			return Plugin_Stop;
		}
	}
	if(!IsValidEntity(Projectile))
		return Plugin_Stop;
		
	float DamageDeal = pack.ReadFloat();
	float RangeSupport = pack.ReadFloat();
	float RangeSupport2 = RangeSupport * 0.25; 
	

	float pos[3]; GetEntPropVector(Projectile, Prop_Data, "m_vecAbsOrigin", pos);
	pos[2] += 5.0;
	if(DamageDeal >= 1.0)
	{
		spawnRing_Vectors(pos, RangeSupport * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 0, 200, 1, 0.3, 2.0, 2.0, 2);
		spawnRing_Vectors(pos, RangeSupport2 * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 0, 200, 1, 0.3, 2.0, 2.0, 2);
	}
	return Plugin_Continue;
}

public Action Timer_Omega_SupportGrenade(Handle timer, DataPack pack)
{
	pack.Reset();
	int OwnerNpc = EntRefToEntIndex(pack.ReadCell());
	int Projectile = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(OwnerNpc))
	{
		if(IsValidEntity(Projectile))
		{
			//Cancel.
			RemoveEntity(Projectile);
		}
		return Plugin_Stop;
	}
	else
	{
		if(!IsEntityAlive(OwnerNpc))
		{
			if(IsValidEntity(Projectile))
			{
				//Cancel.
				RemoveEntity(Projectile);
			}
			return Plugin_Stop;
		}
	}
	
	if(!IsValidEntity(Projectile))
		return Plugin_Stop;
		
	float DamageDeal = pack.ReadFloat();
	float RangeSupport = pack.ReadFloat();
	float HealDo = pack.ReadFloat();

	if(DamageDeal >= 1.0)
	{
		float pos[3]; GetEntPropVector(Projectile, Prop_Data, "m_vecAbsOrigin", pos);
		pos[2] += 5.0;

		spawnRing_Vectors(pos, 2.0 /*startin range*/, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 0, 200, 1, 0.5, 2.0, 2.0, 2, RangeSupport * 2.0);
	}
	if(HealDo >= 1.0)
	{
		ExpidonsaGroupHeal(Projectile, RangeSupport, 99, HealDo, 1.15, false, OmegaGiveArmor);
		EmitSoundToAll("physics/metal/metal_box_strain1.wav", Projectile, _, 100, _, 1.0, 90);
	}
	return Plugin_Continue;

}
//GrantEntityArmor doesn't support "range" so I have to do it like this lol

void OmegaGiveArmor(int entity, int victim, float &healingammount)
{
	GrantEntityArmor(victim, false, 0.2, 0.75, 0, ReturnEntityMaxHealth(victim) * 0.0125);
}

void OmegaCreateRollermines(int iNpc)
{
	switch(GetRandomInt(0,4)) //Rollermine voicelines
	{
		case 0:
		{
			NPCTalkMessage(iNpc, "Aren't they just the cutest things ever?");
		}
		case 1:
		{
			NPCTalkMessage(iNpc, "Get a load of these uh... rollermines, as I like to call them.");
		}
		case 2:
		{
			NPCTalkMessage(iNpc, "Don't underestimate my mechanical expertise.");
		}
		case 3:
		{
			NPCTalkMessage(iNpc, "Rollermines, roll out. Heh, see what I did there?");
		}
		case 4:
		{
			NPCTalkMessage(iNpc, "Protect me, zappies.");
		}
	}

	OmegaRaid npc = view_as<OmegaRaid>(iNpc);
	
	float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	int summon = NPC_CreateByName("npc_living_metal_ball", -1, pos, {0.0,0.0,0.0}, GetTeam(npc.index));
	if(IsValidEntity(summon))
	{
		OmegaRaid npcsummon = view_as<OmegaRaid>(summon);
		if(GetTeam(npc.index) != TFTeam_Red)
			Zombies_Currently_Still_Ongoing++;

		fl_Extra_Damage[npcsummon.index] = fl_Extra_Damage[npc.index];
		fl_Extra_Damage[npcsummon.index] *= 1.5;
		fl_Extra_Speed[npcsummon.index] *= 0.5;
		npcsummon.m_iTargetAlly = iNpc;
		SetEntProp(summon, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index)/120);
		SetEntProp(summon, Prop_Data, "m_iMaxHealth", ReturnEntityMaxHealth(npc.index)/120);
		NpcStats_CopyStats(npc.index, summon);
		//npcsummon.m_iWearable1 = ConnectWithBeam(npc.index, npcsummon.index, 0, 150, 195, 0.5, 0.5, 1.0, "sprites/laserbeam.vmt");
	}
	summon = NPC_CreateByName("npc_living_metal_ball", -1, pos, {0.0,0.0,0.0}, GetTeam(npc.index));
	if(IsValidEntity(summon))
	{
		OmegaRaid npcsummon = view_as<OmegaRaid>(summon);
		if(GetTeam(npc.index) != TFTeam_Red)
			Zombies_Currently_Still_Ongoing++;

		fl_Extra_Damage[npcsummon.index] = fl_Extra_Damage[npc.index];
		fl_Extra_Damage[npcsummon.index] *= 1.5;
		fl_Extra_Speed[npcsummon.index] *= 0.5;
		npcsummon.m_iTargetAlly = iNpc;
		SetEntProp(summon, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index)/120);
		SetEntProp(summon, Prop_Data, "m_iMaxHealth", ReturnEntityMaxHealth(npc.index)/120);
		NpcStats_CopyStats(npc.index, summon);
		//npcsummon.m_iWearable1 = ConnectWithBeam(npc.index, npcsummon.index, 0, 150, 195, 0.5, 0.5, 1.0, "sprites/laserbeam.vmt");
	}
}

static void Omegas_SelfDefense(OmegaRaid npc, float gameTime, int target, float flDistanceToTarget)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < GetGameTime(npc.index))
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, target))
			{
				int HowManyEnemeisAoeMelee = 64;
				Handle swingTrace;
				float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
				npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1, _, HowManyEnemeisAoeMelee);
				delete swingTrace;
				bool PlaySound = false;
				float damage = 20.0;
				int closest = npc.m_iTarget;
				float vecTarget[3]; WorldSpaceCenter(closest, vecTarget);
				damage *= RaidModeScaling;
				bool silenced = NpcStats_IsEnemySilenced(npc.index);
				for(int counter = 1; counter <= HowManyEnemeisAoeMelee; counter++)
				{
					if(i_EntitiesHitAoeSwing_NpcSwing[counter] > 0)
					{
						if(IsValidEntity(i_EntitiesHitAoeSwing_NpcSwing[counter]))
						{
							int targetTrace = i_EntitiesHitAoeSwing_NpcSwing[counter];
							float vecHit[3];

							npc.m_iOverlordComboAttack++;
							WorldSpaceCenter(targetTrace, vecHit);

							if(damage <= 1.0)
							{
								damage = 1.0;
							}
							SDKHooks_TakeDamage(targetTrace, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
							// On Hit stuff
							bool Knocked = false;
							if(!PlaySound)
							{
								PlaySound = true;
							}
							
							if(IsValidClient(targetTrace))
							{
								if (IsInvuln(targetTrace))
								{
									Knocked = true;
									Custom_Knockback(npc.index, targetTrace, 180.0, true);
									if(!silenced)
									{
										TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.5);
										TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.5);
									}
								}
								else
								{
									if(!silenced)
									{
										TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.5);
										TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.5);
									}
								}
							}
							if(npc.m_iOverlordComboAttack >= 5)
							{
								float flPos[3];
								if(!IsValidEntity(npc.m_iWearable9))
								{
									float flAng[3];
									npc.GetAttachment("LHand", flPos, flAng);
									npc.m_iWearable9 = ParticleEffectAt_Parent(flPos, "unusual_electric_parent_gold", npc.index, "LHand", {0.0, 0.0, 0.0});
								}
								if(!IsValidEntity(npc.m_iWearable7))
								{
									float flAng[3];
									npc.GetAttachment("RHand", flPos, flAng);
									npc.m_iWearable7 = ParticleEffectAt_Parent(flPos, "unusual_electric_parent_gold", npc.index, "RHand", {0.0, 0.0, 0.0});
								}
							}
							if(npc.m_iOverlordComboAttack >= 10)
							{
								npc.AddGesture("ACT_PUSH_PLAYER");
								float duration = 1.0;
								if(target <= MaxClients && target > 0)
								{
								    TF2_AddCondition(target, TFCond_FreezeInput, duration);  
								}
								else
								{
								    FreezeNpcInTime(target, duration);
								}
								Custom_Knockback(npc.index, targetTrace, 1000.0, true, true);
								Explode_Logic_Custom(60.0 * RaidModeScaling, -1, npc.index, -1, vecTarget, 100.0, _, _, true, _, false);
								ParticleEffectAt(vecTarget, "hightower_explosion", 1.0);
								npc.PlayMeleeStunSound();
								npc.PlayBoomSound();
								//AcceptEntityInput(npc.m_iWearable4, "Enable");
								npc.m_iOverlordComboAttack = 0;
							}
							if(npc.m_iOverlordComboAttack <= 1)
							{
							
								if(IsValidEntity(npc.m_iWearable9))
								RemoveEntity(npc.m_iWearable9);
								if(IsValidEntity(npc.m_iWearable7))
								RemoveEntity(npc.m_iWearable7);
							}	
							if(!Knocked)
								Custom_Knockback(npc.index, targetTrace, 125.0, true); 
					
						} 
					}
				}
				if(PlaySound)
				{
					npc.PlayMeleeHitSound();
				}
			}
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.25))
		{
			int Enemy_I_See;
			Enemy_I_See = Can_I_See_Enemy(npc.index, target);

			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;

				npc.PlayMeleeSound();
				switch(GetRandomInt(0,1))
				{
					case 0:
					{
						npc.AddGesture("ACT_BRAWLER_ATTACK_LEFT");
					}
					case 1:
					{
						npc.AddGesture("ACT_BRAWLER_ATTACK_RIGHT");
					}
				}
				npc.m_flAttackHappens = gameTime + 0.1;
				npc.m_flNextMeleeAttack = gameTime + 0.50;
				if(npc.Anger)
				{
					npc.m_flAttackHappens = gameTime + 0.1;
					npc.m_flNextMeleeAttack = gameTime + 0.25;
				}
				return;
			}
		}
	}
	if(npc.m_fbRangedSpecialOn)
	{
		npc.StopPathing();
		npc.m_flSpeed = 0.0;
		npc.m_flRangedSpecialDelay = GetGameTime(npc.index) + 1.0;
		npc.m_fbRangedSpecialOn = false;
	}
	if(npc.m_flRangedSpecialDelay < GetGameTime(npc.index))
	{
		npc.m_flSpeed = 300.0;
		npc.StartPathing();
	}
}
static Action OmegaRaid_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	OmegaRaid npc = view_as<OmegaRaid>(victim);
	
	int closest = npc.m_iTarget;
	float vecTarget[3]; WorldSpaceCenter(closest, vecTarget);
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	
	}
	if((ReturnEntityMaxHealth(npc.index)/2) >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.Anger)
	{
		if(Waves_InFreeplay())
		{
			NPCTalkMessage(npc.index, "Alright, time to quit playing around.");
		}
		else
		{
			NPCTalkMessage(npc.index, "God damn it! Just die already!");
		}
		npc.Anger = true;
		ApplyStatusEffect(npc.index, npc.index, "Mazeat Command", 10.0);
		ParticleEffectAt(vecTarget, "hammer_bell_ring_shockwave", 1.0);
	}
	OmegaRaid_Weapon_Lines(npc, attacker);
	i_SaidLineAlready[npc.index] = 0;
	if(i_RaidGrantExtra[npc.index] == 5)
	{
		if(!npc.m_bWasSadAlready)
		{
			if(damage >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))
			{
				npc.m_bWasSadAlready = true;
				npc.Anger = false;
				OmegaRaid_DefeatAnimation(npc);
			}
		}
	}
	
		
	return Plugin_Changed;
}

public void OmegaRaid_NPCDeath(int entity)
{
	OmegaRaid npc = view_as<OmegaRaid>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	if(npc.m_bDissapearOnDeath)
	{
		float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
		ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
		npc.PlayTeleSound();
	}

	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);
	if(IsValidEntity(npc.m_iWearable9))
		RemoveEntity(npc.m_iWearable9);

}

static void OmegaRaid_Weapon_Lines(OmegaRaid npc, int client)
{
	if(client > MaxClients)
		return;

	if(b_said_player_weaponline[client])	//only 1 line per player.
		return;

	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

	if(!IsValidEntity(weapon))	//invalid weapon, go back and get a valid one you <...>
		return;

	float GameTime = GetGameTime();	//no need to throttle this.

	if(fl_said_player_weaponline_time[npc.index] > GameTime)	//no spamming in chat please!
		return;

	bool valid = true;
	char Text_Lines[255];

	Text_Lines = "";

	switch(i_CustomWeaponEquipLogic[weapon])
	{
		
		case WEAPON_SENSAL_SCYTHE,WEAPON_SENSAL_SCYTHE_PAP_1,WEAPON_SENSAL_SCYTHE_PAP_2,WEAPON_SENSAL_SCYTHE_PAP_3:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "이런... {blue}그{default}가 널 보면 어떻게 반응할지 상상도 안 가는데.",client);
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "뭐냐? 네가 무슨 {midnightblue}따라쟁이{default}라도 되는거냐?");
			}
		}
		case WEAPON_FUSION,WEAPON_FUSION_PAP1,WEAPON_FUSION_PAP2:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{gold}실베스터?{default} 흐음, 몇 안 되는 괜찮은 사람이었지.",client);
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "무기가 뭔 나무에서 자라나기라도 하나? 도대체 {gold}그{default}는 이걸 왜 남한테 자꾸 공짜로 주는거야?");
			}
		}
		case WEAPON_KAHMLFIST:
		{
			if(Waves_InFreeplay())
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "메신저에게 무슨 일이 일어났는지는... {darkblue}그{default}놈만이 알 걸.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "어우.");
				}
			}
			else
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "{darkblue}카멜슈타인{default}, 난 그를 그다지 좋게 생각하지는 않지만, 흔히 말하듯이 겉모습으로 사람을 판단하지 말란 말이 있잖아.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "뭐, 이제 {darkblue}그는{default} 더 나은 장소에 있잖아! 하하... 아나.",client);
				}	
			}
		}  
		case WEAPON_KIT_BLITZKRIEG_CORE:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{gold}엑스피돈사{default}, 걔네는 가장 뛰어나면서 {crimson}멍청한{default} 실수를 하기도 하더라?");
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{gold}거기 국가{default} 사람들은 영화도 안 봤나? 점점 성장하는 {crimson}AI{default}는 클리셰잖아?",client);
			}
		}
		case WEAPON_RED_BLADE:
		{
			if(Waves_InFreeplay())
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "굴른... 자네의 검을 들고 자네를 기리는 자가 여기 있어.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "타임 머신이 있다면, 첫번째로 하고 싶은건 {crimson}배풍등이 굴른을 죽이기 전에 내가 먼저 그 미친놈을 찢어 죽이는거야{default}.");
				}
			}
			else
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "{crimson}굴른{default}... 안 돼...");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "{crimson}굴른{default}의 죽음이 날 이 곳으로 이끌었지. 그 {crimson}미친 배풍등{default}은 반드시 죽어야한다.");
				}
			}
		}
		case WEAPON_SPIKELAYER:
		{
			if(Waves_InFreeplay())
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "진짜 궁금한데, 누가 진짜 이 무슨 조그만 가시 때문에 다치기는 해?");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "이런 어이 없는 가짜 레고는 도대체 누가 만든건지.");
				}
			}
			else
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "정말 고맙다. 네 덕분에 운동 좀 되겠어, {gold}%N{default}.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "불 위를 걸어본 적 있나? 이건 나한테는 아무것도 아니다.");
				}
			}
		}
		case WEAPON_BOARD:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{gold}%N{default}, 그건 그냥 총싸움에 칼을 가져오는 거랑 다름 없잖아.",client);
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "방패가 도대체 너한테 뭘 해주겠다는건데?");
			}
		}
		case WEAPON_BOBS_GUN:  Format(Text_Lines, sizeof(Text_Lines), "이런 치사한 녀석!");
		case WEAPON_HHH_AXE:  Format(Text_Lines, sizeof(Text_Lines), "끔찍한 {darkblue}흉물{default}을 전에도 본 적이 있지만, 넌 그 이상이다, {gold}%N{default}.",client);
		case WEAPON_MLYNAR_PAP_2,WEAPON_MLYNAR_PAP,WEAPON_MLYNAR:
		{
			if(Waves_InFreeplay())
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "그 신문은 도대체 뭐야? 그렇게 멍때리고 서있어도 아무 일도 안 일어난다고.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "생각해보니... 도대체 누가 이 신문을 뿌려댄거야?");
				}
			}
			else
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "전투 도중에 신문을 볼 시간이 있다고, {gold}%N{default}? 내가 우습나?",client);	
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "미친 놈. 지금 {white}밥{default}을 인질로 잡아놓고 신문이나 보시겠다, {gold}%N{default}? {red}도발이냐?",client);
				}
			}
		}
		case WEAPON_MESSENGER_LAUNCHER:
		{
			if(Waves_InFreeplay())
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "{white}밥{default}이 내게 메신저에 대한 소식을 들려줬지...그건... 영 기분 좋은 소식은 아니었어.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "만약 내세 같은게 있다면, 메신저는 적어도 지옥엔 떨어지지 않을거라고 믿어. 그는 그냥... 순진했을 뿐이야. 불쌍한 녀석.");
				}
			}
			else
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "어어, {blue}메신저{default}가 그걸 준 건가? 역시 그는 아직 완전히 타락하지 않았어.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "{blue}메신저{default}가 그리워. 걔가 뭘 하고 있는지 궁금하네. 꽤 오랫동안 못 만났거든.",client);
				}	
			}
		}
		case WEAPON_FLAMETAIL:
		{
			if(Waves_InFreeplay())
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "어우, 하하하, 그거 이름이 '불꼬리기사'라며? ....나중에 알고 보니까 왠 여자애 이름이더라...");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "그 불꼬리기사란거, 괜찮은 무기이긴 한데, 내가 쓸만한건 아니야.");
				}
			}
			else
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "이거나 피해봐라.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "그 '무기' 같은 걸로 내 횃불 좀 밝혀봐라, {gold}%N{default}.",client);
				}
			}
		}
		case WEAPON_LEPER_MELEE, WEAPON_LEPER_MELEE_PAP:
		{
			if(Waves_InFreeplay())
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "지난 싸움 이후로 포즈를 더 잘 잡는데? {gold}%N{default}.",client);
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "그래서 그걸 더 빨리 휘두르겠다는 거야?");
				}
			}
			else
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "너희 그 말라비틀어진 팔이 그걸 잡을수 있다는게 정말 놀라울 지경이다. {gold}%N{default}.",client);
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "팬들을 위해 포즈 좀 잡아봐, {gold}%N{default}! 근데 넌 팬이 없잖아?",client);
				}
			}
		}
		case WEAPON_SKULL_SERVANT:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "흐음, 다들 {green}그 놈{default}이 돌아오는걸 싫어하던데, 난 걔가 돌아와서 미친 상황이 나오는걸 보고 싶어.",client);
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "솔직히 {green}그 놈{default}이 돌아왔으면 좋겠는데.",client);
			}
		}
		case WEAPON_DWELLER_MISC:
		{
			if(Waves_InFreeplay())
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "도대체 어떻게 시본의 힘을 부작용 없이 사용하고 있는거야?");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "Well after everything you've went through, it shouldn't surprise me that the Dweller infection doesn't affect you, {gold}%N{default}.",client);
				}
			}
			else
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "{white}밥{default}이 너 같은 놈을 이전에도 다룬 적이 있지.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "{white}밥{default}, 네가 인질로 잡혀있다는 건 알지만, {gold}%N{default} 저 놈과 한참 떨어져있어야한다.",client);
				}
			}
		}
		case WEAPON_BOOMSTICK:
		{
			if(Waves_InFreeplay())
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "붐스틱은 내가 가장 좋아하는 무기였어. RPG로 바꿨지만.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "그 붐스틱을 들고 있으니까, 어, 속된 말로 간지나보인다, {gold}%N{default}!",client);
				}
			}
			else
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "아, 붐스틱. 그리고 그걸 사용하는 놈이 쫄보마냥 뒤로 빠지는 꼴이라니!");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "그래. 넉백으로 뒤로 좀 빠져라, {gold}%N{default}. 네 팀은 네가 나대는 꼴을 보기 싫어할테니.",client);
				}
			}
		}
		case WEAPON_FIRE_WAND:
		{
			if(Waves_InFreeplay())
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "원시인의 마법이네. 아니, 그냥 농담한거야!");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "뭔가 골때리네, 네가 꼭 마치 방화범처럼 보이잖아?");
				}
			}
			else
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "어이쿠 무서워라. 불장난을 하면 오줌을 싼다는것도 안 배웠나?");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "진심으로, 저런 무기로 도대체 어떻게 전투를 하는거지? 내가 모르는 숨겨진 뭐가 있나?",client);
				}
			}
		}
		case WEAPON_CASINO:
		{
			if(Waves_InFreeplay())
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "{fullblue}도박사{default}라는 놈을 본 적 있어? 그 놈은 꼭 마치 블랙잭 도박에 미쳐있는 놈처럼 보이던데.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "아, 그걸 쓰는 {fullblue}녀석이{default} {navy}칼춤{default}의 카지노에 들어간 걸 본 적이 있어... 그의 운은 헤아릴 수 없을 정도로 좋았었지. 아, 걔 자체도 멋있었고.",client);
				}
			}
			else
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "허, 너 혹시 {navy}칼춤{default} 을 만난 적이 있나? 그 놈도 나에게 빚진 게 있는데.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "하, {gold}%N{default}, 도박중독자인 네 영혼은 내가 구해주지.",client);
				}
			}
		}
		case WEAPON_DIMENSION_RIPPER:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "이건 뭐야? 무슨 장난질인가?");
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "Where in the fuck did you get that, {gold}%N{default}?",client);
			}
		}
		case WEAPON_MAGNESIS:
		{
			if(Waves_InFreeplay())
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "바로 그게 마법이 무서운 이유야. 마법은 그냥 상식을 벗어났거든.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "나도 전에 그런 방식으로 사람을 집어드는 게임을 본 적 있어, {gold}%N{default}. 이름은 까먹었지만.");
				}
			}
			else
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "날 2초 이상 잡는 순간 너한테 무슨 일이 생길지 참 기대되는군.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "날 놓치는 순간, 날 잡은 방식으로 똑같이 네 목을 비틀어주마. {gold}%N{default}.",client);
				}
			}
		}
		case WEAPON_WRATHFUL_BLADE:
		{
			if(Waves_InFreeplay())
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "도대체 그 검에서 어떻게 불이 나오고 있는거야?");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "그거, 딱 봐도 네 생명을 흡수하는것 같은데. 조심하라고, {gold}%N{default}.",client);
				}
			}
			else
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "그것보다 더 무서운 무기는 얼마든지 봐왔다.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "아주 참 무서워죽겠군, 사람 몸에서 불 나오는게 초능력이냐? {gold}%N{default}?",client);
				}
			}
		}
		case WEAPON_CHAINSAW:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "그거 솔직히 너무 무서운 무기잖아? 어... 아니다.");
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "연료를 효율적으로 사용하길 바란다, {gold}%N{default}.",client);
			}
		}
		case WEAPON_MG42:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "그 중기관총은 대체 얼마나 빠르게 사격하는 거야?");
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "그 중기관총 참 탁월한 무기인데, {gold}%N{default}. 존중해줄게.",client);
			}
		}
		case WEAPON_GRAVATON_WAND:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "내가 마법을 얼마나 싫어하는지 넌 모를걸.");
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{gold}루이나인{default}들이 그 무기를 너한테 줬다고, {gold}%N{default}? 뭐, 네 활약을 보면 놀랄 것도 아니겠지만.",client);
			}
		}
		case WEAPON_NECRO_WANDS:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "마법이 그렇게까지 터무니 없을거란 생각은 못 했어.");
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "발로 차버리기 전에 빨리 그 해골들 치워, {gold}%N{default}.",client);
			}
		}
		case WEAPON_SPEEDFISTS:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "드디어, 가치 있는 적이로군.");
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "주먹 VS 주먹 싸움이라니. 그 존중, 정말 고맙다. {gold}%N{default}.",client);
			}
		}

		default:
		{
			valid = false;
		}
	}

	if(valid)
	{
		NPCTalkMessage(npc.index, Text_Lines);
		fl_said_player_weaponline_time[npc.index] = GameTime + GetRandomFloat(15.0, 22.0);
		b_said_player_weaponline[client] = true;
	}
}

static void OmegaRaid_GrantItem()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if(IsValidClient(client) && GetClientTeam(client) == 2 && TeutonType[client] != TEUTON_WAITING && PlayerPoints[client] > 500)
		{
			Items_GiveNamedItem(client, "Omega's Medallion");
			CPrintToChat(client,"{white}밥{default}은 {gold}오메가{default}에게 모습을 드러내어, 당신이 밥을 죽이려는 {crimson}배풍등{default}의 무리가 아닌것을 알려주었습니다. 그리고 당신은 {gold}오메가의 메달리온{default}을 받았습니다!");
		}
	}
}

void OmegaRaid_DefeatAnimation(OmegaRaid npc)
{
	//rapid self heal to indicate power!
	npc.m_bisWalking = false;
	npc.AddActivityViaSequence("idle_NPC_impatient");
	int iActivity = npc.LookupActivity("ACT_IDLE_IMPATIENT");
	if(iActivity > 0) npc.StartActivity(iActivity);
	npc.SetActivity("ACT_IDLE_IMPATIENT");
	npc.StopPathing();
	
	npc.m_flSpeed = 0.0;
	//npc.SetCycle(0.50);//why
	//npc.SetPlaybackRate(1.0);	
	npc.ArmorSet(_, true);
	b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.
	b_DoNotUnStuck[npc.index] = true;
	b_CantCollidieAlly[npc.index] = true;
	b_CantCollidie[npc.index] = true;
	GiveProgressDelay(28.0);
		
}

static bool OmegasRabiling(int iNPC)
{
	int maxyapping = 13;
	if(i_TalkDelayCheck == maxyapping)
	{
		return true;
	}
	if(f_TalkDelayCheck < GetGameTime())
	{
		f_TalkDelayCheck = GetGameTime() + 4.0;
		RaidModeTime += 10.0; //cant afford to delete it, since duo.
		i_TalkDelayCheck++;
		switch(i_TalkDelayCheck)
		{
			case 0:
			{
				ReviveAll(true);
				NPCTalkMessage(iNPC, "Alright, that's enough of playing around, let's get this done.");
			}
			case 1:
			{
				CPrintToChatAll("{white}밥{default}: 그럴 필요 없어, 오메가.");
			}
			case 2:
			{
				NPCTalkMessage(iNPC, "Huh?");
			}
			case 3:
			{
				CPrintToChatAll("{white}밥{default}: 봐, 난 멀쩡하잖아? 그리고 위협받고 있지도 않아.");
			}
			case 4:
			{
				NPCTalkMessage(iNPC, "But {crimson}Whiteflower{default} sent his army to finish you for good!");
			}
			case 5:
			{
				CPrintToChatAll("{white}밥{default}: 뭐... 널브러져있는 그놈들 시체더미가 그 결과를 말해주고 있잖아?");
			}
			case 6:
			{
				NPCTalkMessage(iNPC, "So you're saying that all this fighting was for nothing?");
			}
			case 7:
			{
				CPrintToChatAll("{white}밥{default}: 어... 조금?");
			}
			case 8:
			{
				NPCTalkMessage(iNPC, "Damn...well, at least I'm keeping myself in check, can't become too weak.");
			}
			case 9:
			{
				NPCTalkMessage(iNPC, "Why didn't you just tell me that you weren't in any danger right off the bat?");
			}
			case 10:
			{
				CPrintToChatAll("{white}밥{default}: ...우정 테스트? 네가 날 위해 어디까지 갈 수 있나 해서.");
			}
			case 11:
			{
				NPCTalkMessage(iNPC, "Oh please, you know I would never leave you hanging.");
			}
			case 12:
			{
				NPCTalkMessage(iNPC, "Well, I suppose an apology is owed for attacking you, mercenaries.");
			}
			case 13:
			{
				NPCTalkMessage(iNPC, "Here, take this. Bob...let's get out of here.");
				i_TalkDelayCheck = maxyapping;
				OmegaRaid_GrantItem();
			}
		}
	}
	return false;
}

public void RaidMode_OmegaRaid_WinCondition(int entity)
{
	i_RaidGrantExtra[entity] = RAIDITEM_INDEX_WIN_COND;
	func_NPCThink[entity] = INVALID_FUNCTION;
	if(AlreadySaidWin)
		return;

	AlreadySaidWin = true;
	if(Waves_InFreeplay())
	{
		switch(GetRandomInt(0,2))
		{
			case 0:
			{
				NPCTalkMessage(entity, "Aw come on, I was rootin' for you.");
			}
			case 1:
			{
				NPCTalkMessage(entity, "You've gone soft, you need to get stronger to keep up.");
			}
			case 2:
			{
				NPCTalkMessage(entity, "You're not ready to take on bigger threats just yet. I'll take care of business.");
			}
		}
	}
	else
	{
		switch(GetRandomInt(0, 6))
		{
			case 0:
			{
				NPCTalkMessage(entity, "Well {white}Bob{default}, I saved you once again, no need to thank me.");
			}
			case 1:
			{
				NPCTalkMessage(entity, "Wanna grab some beer after this, {white}Bob{default}?");
			}
			case 2:
			{
				NPCTalkMessage(entity, "Survival of the fittest.");
			}
			case 3:
			{
				NPCTalkMessage(entity, "You gotta do what you gotta do to survive.");
			}
			case 4:
			{
				NPCTalkMessage(entity, "You shouldn't have kept him captive.");
			}
			case 5:
			{
				NPCTalkMessage(entity, "{crimson}Whiteflower {default}must've cut his budget huh?");
			}
			case 6:
			{
				NPCTalkMessage(entity, "Well, that wasn't nearly as difficult as I was expecting it to be.");
			}
		}
	}
}
