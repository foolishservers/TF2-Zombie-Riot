#pragma semicolon 1
#pragma newdecls required

#define TINKER_LIMIT	4

enum struct TinkerEnum
{
	int AccountId;
	int StoreIndex;
	int Attrib[TINKER_LIMIT];
	float Value[TINKER_LIMIT];
	float Luck[TINKER_LIMIT];
	char Name[128];
	int Rarity;
	bool Addition[TINKER_LIMIT];
	int CustomMode[TINKER_LIMIT];
}

enum {
	IS_SNIPERRIFLE = 1,
	IS_DMR,
};

enum {
	TinkerEnchant_HastyMage = 0,
	TinkerEnchant_HeavyMage,
	TinkerEnchant_ConcentratedMagic,
	TinkerEnchant_TankMage,
	TinkerEnchant_FrugalityMage,
	TinkerEnchant_MageFragility,
	TinkerEnchant_HoardingDisorder,
	
	TinkerEnchant_MeleeRapidSwing,
	TinkerEnchant_MeleeHeavySwing,
	TinkerEnchant_MeleeLongSwing,
	TinkerEnchant_MeleeGlassy,
	TinkerEnchant_MeleePlateArmor,
	
	TinkerEnchant_FastHeal,
	TinkerEnchant_Overhealer,
	TinkerEnchant_Uberer,
	TinkerEnchant_BurstHeal,
	TinkerEnchant_GlassyMedic,
	
	TinkerEnchant_BuildingExtension,
	TinkerEnchant_RepairMaster,
	
	TinkerEnchant_SlowHeavyProjectile,
	TinkerEnchant_FastProjectile,
	
	TinkerEnchant_IntensiveClip,
	TinkerEnchant_ConcentratedClip,
	TinkerEnchant_HeavyTrigger,
	TinkerEnchant_SmallerSmarterBullet,
	
	TinkerEnchant_SprayAndPray,
	
	TinkerEnchant_ConcentratedClip_Infinite,
	TinkerEnchant_HasteNonMage,
	
	TinkerEnchant_MS_Sharpness,
	TinkerEnchant_MS_Smite,
	TinkerEnchant_MS_SweepingEdge,
	TinkerEnchant_MS_QuickCharge,
	TinkerEnchant_MS_BaneOfArthropods,
	TinkerEnchant_MS_FireAspect,
	TinkerEnchant_MS_CurseOfGlassy,
	
	TinkerEnchant_SR_ExplosiveHeadshot,
	TinkerEnchant_SR_KillerFocus,
	TinkerEnchant_SR_SuperCoolingChamber,
	TinkerEnchant_SR_DepletedUranium,
	TinkerEnchant_SR_HighSpeedFeedMechanism,
	TinkerEnchant_SR_HollowPointBullets,
	
	TinkerEnchant_FT_FaceMelter,
	TinkerEnchant_FT_StickyCompound,
};

#define ENCHANT_ROLL_COUNT	4

// 모루에서 굴린, 아직 적용되지 않은 인챈트 후보. (계정, StoreIndex) 단위로 보관한다.
enum struct EnchantRollEnum
{
	int AccountId;
	int StoreIndex;
	int SmithLevel;
	int Enchant[ENCHANT_ROLL_COUNT];
	int Rarity[ENCHANT_ROLL_COUNT];
}

static ArrayList EnchantRolls;

static ArrayList Tinkers;
static int AnvilClickedOn[MAXPLAYERS];
static int ClickedWithWeapon[MAXPLAYERS];

void Tinker_RoundStart()
{
	delete Tinkers;
	delete EnchantRolls;
}

void Tinker_OnWeaponEnable(int client, int weapon)
{
	if(Tinkers)
	{
		if(!Blacksmith_Any_IsASmith())
			return;
		
		DetectWeaponNoTinker(weapon, client);
		
		int account = GetSteamAccountID(client, false);
		if(account)
		{
			static TinkerEnum tinker;
			int length = Tinkers.Length;
			for(int a; a < length; a++)
			{
				Tinkers.GetArray(a, tinker);
				if(tinker.AccountId == account && tinker.StoreIndex == StoreWeapon[weapon])
				{
					ApplyStatusEffect(weapon, weapon, "Tinkering Curiosity", 99999999.9);
					for(int b; b < sizeof(tinker.Attrib); b++)
					{
						if(!tinker.Attrib[b])
							break;
						
						Attributes_SetMulti(weapon, tinker.Attrib[b], tinker.Value[b]);
					}
					
					break;
				}
			}
		}
	}
}

void Anvil_BuildingUsed(int entity, int client) {
	AnvilClickedOn[client] = EntIndexToEntRef(entity);
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if (weapon == -1)
		return;
	
	ClickedWithWeapon[client] = EntIndexToEntRef(weapon);
	
	Anvil_Menu(client);
}

bool Blacksmith_HasTinker(int client, int index) {
	if (Tinkers) {
		int account = GetSteamAccountID(client, false);
		if (account) {
			static TinkerEnum tinker;
			int length = Tinkers.Length;
			for (int a; a < length; a++) {
				Tinkers.GetArray(a, tinker);
				if(tinker.AccountId == account && tinker.StoreIndex == index)
					return true;
			}
		}
	}
	
	return false;
}

static void DetectWeaponNoTinker(int weapon, int client)
{
	if(Attributes_Get(weapon, Attrib_DisallowTinker, 0.0) == 0.0)
		return;

	SetGlobalTransTarget(client);
	
	int account = GetSteamAccountID(client, false);
	if(!account)
	{
		return;
	}

	TinkerEnum tinker;
	int found = -1;
	if(Tinkers)
	{
		int length = Tinkers.Length;
		for(int a; a < length; a++)
		{
			Tinkers.GetArray(a, tinker);
			if(tinker.AccountId == account && tinker.StoreIndex == StoreWeapon[weapon])
			{
				found = a;
				break;
			}
		}
	}
	if(found == -1)
	{
		return;
	}

	tinker.Rarity = -1;
	Tinkers.Erase(found);
	PrintToChat(client, "%T", "Removed Tinker Attributes", client);
}

static const int Enchant_Mage[] = {
	TinkerEnchant_HastyMage,
	TinkerEnchant_HeavyMage,
	TinkerEnchant_ConcentratedMagic,
	TinkerEnchant_TankMage,
	//TinkerEnchant_FrugalityMage,
	//TinkerEnchant_MageFragility,
	//TinkerEnchant_HoardingDisorder
};

static const int Enchant_Melee[] = {
	TinkerEnchant_MeleeRapidSwing,
	TinkerEnchant_MeleeHeavySwing,
	TinkerEnchant_MeleeLongSwing,
	TinkerEnchant_MeleeGlassy,
	//TinkerEnchant_MeleePlateArmor
};

static const int Enchant_Medigun[] = {
	TinkerEnchant_FastHeal,
	TinkerEnchant_Overhealer,
	TinkerEnchant_Uberer,
};

static const int Enchant_Healing[] = {
	TinkerEnchant_BurstHeal,
	TinkerEnchant_GlassyMedic
};

static const int Enchant_Wrench[] = {
	TinkerEnchant_BuildingExtension,
	TinkerEnchant_RepairMaster
};

static const int Enchant_Range[] = {
	TinkerEnchant_IntensiveClip,
	TinkerEnchant_ConcentratedClip,
	TinkerEnchant_HeavyTrigger,
	TinkerEnchant_SmallerSmarterBullet,
	TinkerEnchant_HasteNonMage
};

static const int Enchant_RangeInfinite[] = {
	TinkerEnchant_ConcentratedClip_Infinite,
	TinkerEnchant_HasteNonMage
};

static const int Enchant_ProjInfinite[] = {
	TinkerEnchant_ConcentratedClip_Infinite,
	TinkerEnchant_HasteNonMage,
	TinkerEnchant_SlowHeavyProjectile,
	TinkerEnchant_FastProjectile
};

static const int Enchant_Proj[] = {
	TinkerEnchant_IntensiveClip,
	TinkerEnchant_ConcentratedClip,
	TinkerEnchant_HeavyTrigger,
	TinkerEnchant_SmallerSmarterBullet,
	TinkerEnchant_HasteNonMage,
	TinkerEnchant_SlowHeavyProjectile,
	TinkerEnchant_FastProjectile
};

static const int Enchant_MultiBullet[] = {
	TinkerEnchant_IntensiveClip,
	TinkerEnchant_ConcentratedClip,
	TinkerEnchant_HeavyTrigger,
	TinkerEnchant_SmallerSmarterBullet,
	TinkerEnchant_HasteNonMage,
	TinkerEnchant_SprayAndPray,
};

static const int Enchant_MultiBulletInfinite[] = {
	TinkerEnchant_ConcentratedClip_Infinite,
	TinkerEnchant_HasteNonMage,
	TinkerEnchant_SprayAndPray
};

static const int Enchant_Sigil_Blade[] = {
	TinkerEnchant_HastyMage,
	TinkerEnchant_HeavyMage,
	TinkerEnchant_TankMage
};

static const int Enchant_MSSword[] = {
	TinkerEnchant_MS_Sharpness,
	TinkerEnchant_MS_Smite,
	TinkerEnchant_MS_SweepingEdge,
	TinkerEnchant_MS_QuickCharge,
	TinkerEnchant_MS_BaneOfArthropods,
	TinkerEnchant_MS_FireAspect,
	TinkerEnchant_MS_CurseOfGlassy
};

static const int Enchant_SniperRifle[] = {
	TinkerEnchant_SR_ExplosiveHeadshot,
	TinkerEnchant_SR_KillerFocus,
	TinkerEnchant_SR_SuperCoolingChamber,
	TinkerEnchant_SR_DepletedUranium,
	TinkerEnchant_SR_HighSpeedFeedMechanism,
	TinkerEnchant_SR_HollowPointBullets
};

static const int Enchant_DMR[] = {
	TinkerEnchant_IntensiveClip,
	TinkerEnchant_ConcentratedClip,
	TinkerEnchant_HeavyTrigger,
	TinkerEnchant_SR_ExplosiveHeadshot,
	TinkerEnchant_SR_HighSpeedFeedMechanism,
	TinkerEnchant_SR_HollowPointBullets
};

static const int Enchant_FlameThrower[] = {
	TinkerEnchant_ConcentratedClip_Infinite,
	TinkerEnchant_HasteNonMage,
	TinkerEnchant_FT_FaceMelter
};

// 유효한 롤이 없거나 대장장이 레벨이 달라졌으면 새로 굴려서 roll에 담아 반환한다.
static void EnchantRoll_GetOrCreate(int account, int storeIndex, int weapon, int smithLevel, EnchantRollEnum roll) {
	int index = EnchantRoll_Find(account, storeIndex);
	if(index != -1)
	{
		EnchantRolls.GetArray(index, roll);
		if(roll.SmithLevel == smithLevel)
			return;
	}
	
	roll.AccountId = account;
	roll.StoreIndex = storeIndex;
	roll.SmithLevel = smithLevel;
	for(int i; i < ENCHANT_ROLL_COUNT; i++)
	{
		roll.Rarity[i] = GetWeaponRarity(weapon, smithLevel);
		roll.Enchant[i] = Query_Enchantment(weapon);
	}
	
	if(!EnchantRolls)
		EnchantRolls = new ArrayList(sizeof(EnchantRollEnum));
	
	if(index == -1)
		EnchantRolls.PushArray(roll);
	else
		EnchantRolls.SetArray(index, roll);
}

static int Query_Enchantment(int weapon) {
	char classname[64];
	GetEntityClassname(weapon, classname, sizeof(classname));
	int slot = TF2_GetClassnameSlot(classname, weapon);
	
	switch (i_CustomWeaponEquipLogic[weapon]) {
		case WEAPON_BOOMERANG: {
			return Enchant_ProjInfinite[GetURandomInt() % sizeof(Enchant_ProjInfinite)];
		}
		case WEAPON_SIGIL_BLADE: {
			return Enchant_MSSword[GetURandomInt() % sizeof(Enchant_MSSword)];
		}
		case WEAPON_MINECRAFT_SWORD: {
			return Enchant_Sigil_Blade[GetURandomInt() % sizeof(Enchant_Sigil_Blade)];
		}
	}
	
	if (i_IsWandWeapon[weapon]) {
		return Enchant_Mage[GetURandomInt() % sizeof(Enchant_Mage)];
	}
	
	if (Attributes_Get(weapon, 8, 0.0) != 0.0) {
		if (StrEqual(classname, "tf_weapon_medigun")) {
			return Enchant_Medigun[GetURandomInt() % sizeof(Enchant_Medigun)];
		}
		else {
			if (slot == TFWeaponSlot_Melee) {
				return TinkerEnchant_GlassyMedic;
			}
			else {
				return Enchant_Healing[GetURandomInt() % sizeof(Enchant_Healing)];
			}
		}
	}
	
	int Attrib = RoundToCeil(Attributes_Get(weapon, Attrib_IsSniperRifle, 0.0));
	if (Attrib == IS_SNIPERRIFLE) {
		return Enchant_SniperRifle[GetURandomInt() % sizeof(Enchant_SniperRifle)];
	}
	else if (Attrib == IS_DMR) {
		return Enchant_DMR[GetURandomInt() % sizeof(Enchant_DMR)];
	}
	
	if (i_IsWrench[weapon]) {
		if (slot != TFWeaponSlot_Melee) {
			return TinkerEnchant_RepairMaster;
		}
		else {
			return Enchant_Wrench[GetURandomInt() % sizeof(Enchant_Wrench)];
		}
	}
	
	if (slot == TFWeaponSlot_Melee) {
		return Enchant_Melee[GetURandomInt() % sizeof(Enchant_Melee)];
	}
	else if (slot < TFWeaponSlot_Melee) {
		// Projectile Weapon
		if (Attributes_Has(weapon, 101) || Attributes_Has(weapon, 102) || Attributes_Has(weapon, 103) || Attributes_Has(weapon, 104)) {
			//infinite fire
			if (Attributes_Has(weapon, 303)) {
				return Enchant_ProjInfinite[GetURandomInt() % sizeof(Enchant_ProjInfinite)];
			}
			else {
				return Enchant_Proj[GetURandomInt() % sizeof(Enchant_Proj)];
			}
		}
		else {
			if (Attributes_Has(weapon, 303)) {
				if (Attributes_Get(weapon, 45, 0.0) > 0.0)
					return Enchant_MultiBulletInfinite[GetURandomInt() % sizeof(Enchant_MultiBulletInfinite)];
				else
					return Enchant_RangeInfinite[GetURandomInt() % sizeof(Enchant_RangeInfinite)];
			}
			else if(StrEqual(classname, "tf_weapon_flamethrower")) {
				//flamethrowers get different logic.
				return Enchant_FlameThrower[GetURandomInt() % sizeof(Enchant_FlameThrower)];
			}
			else {
				if (Attributes_Get(weapon, 45, 0.0) > 0.0)
					return Enchant_MultiBullet[GetURandomInt() % sizeof(Enchant_MultiBullet)];
				else
					return Enchant_Range[GetURandomInt() % sizeof(Enchant_Range)];
			}
		}
	}
	
	return -1;
}

void Blacksmith_ExtraDesc(int client, int index) {
	if (Tinkers) {
		if (!Blacksmith_Any_IsASmith()) {
			CPrintToChat(client, "{crimson} %t" , "No Tinker Left");
			return;
		}
		
		int account = GetSteamAccountID(client, false);
		if (account == 0)
			return;
		
		static TinkerEnum tinker;
		int length = Tinkers.Length;
		for (int a; a < length; a++) {
			Tinkers.GetArray(a, tinker);
			if (tinker.AccountId != account || tinker.StoreIndex != index)
				continue;
			
			SetGlobalTransTarget(client);
			
			char buffer[128];
			FormatEx(buffer, sizeof(buffer), "%s", tinker.Name);
			if (TranslationPhraseExists(buffer)) {
				CPrintToChat(client, "{yellow}%t (Tier %d)", buffer, tinker.Rarity + 1);
			}
			else {
				CPrintToChat(client, "{yellow}%s (Tier %d)", buffer, tinker.Rarity + 1);
				CPrintToChat(client, "{crimson}[Dev Warning] Translation not found");
			}
			
			for (int b; b < sizeof(tinker.Attrib); b++) {
				if (!tinker.Attrib[b])
					break;
				
				Blacksmith_PrintAttribValue(client, tinker.Attrib[b], tinker.Value[b], tinker.Luck[b], tinker.Addition[b], tinker.CustomMode[b]);
			}
			
			break;
		}
	}
}

static void Blacksmith_BuildingUsed_Internal_Custom(int weapon, int entity, int client, int owner)
{
	if(owner == -1)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		if(IsValidEntity(entity))
			DestroyBuildingDo(entity);
		SPrintToChat(client, "%t", "The Blacksmith Failed!");
		return;
	}
	
	int smithLevel = Blacksmith_GetSmithLevel(owner);
	if(smithLevel < 0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		if(IsValidEntity(entity))
			DestroyBuildingDo(entity);
		SPrintToChat(client, "%t", "The Blacksmith Failed!");
		return;
	}
	
	int account = GetSteamAccountID(client, false);
	if(!account)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		if(IsValidEntity(entity))
			ApplyBuildingCollectCooldown(entity, client, 3.0);
		return;
	}
	
	if(Attributes_Get(weapon, Attrib_DisallowTinker, 0.0) != 0.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Blacksmith Underleveled");
		if(IsValidEntity(entity))
			ApplyBuildingCollectCooldown(entity, client, 2.0);
		return;
	}
	
	if(dieingstate[client] == 0)
	{	
		CancelClientMenu(client);
		SetStoreMenuLogic(client, false);
		
		int storeIndex = StoreWeapon[weapon];
		if(storeIndex < 1)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			return;
		}
		
		char buffer[128], buffer2[128];
		Menu menu = new Menu(UsedAnvil_MenuH);
		AnyMenuOpen[client] = 1;
		
		SetGlobalTransTarget(client);
		menu.SetTitle("%t", "Custom Anvil Menu Main");
		
		EnchantRollEnum roll;
		EnchantRoll_GetOrCreate(account, storeIndex, weapon, smithLevel, roll);
		
		for (int i; i < ENCHANT_ROLL_COUNT; i++) {
			FormatEx(buffer, sizeof(buffer), "%s", Query_GetTransList(roll.Enchant[i]));
			if (TranslationPhraseExists(buffer)) {
				FormatEx(buffer2, sizeof(buffer2), "%d;%d", roll.Enchant[i], i);
				FormatEx(buffer, sizeof(buffer), "%t: Lv%d", buffer, roll.Rarity[i] + 1);
				menu.AddItem(buffer2, buffer);
			}
			else {
				menu.AddItem("-1", "Dev WTF", ITEMDRAW_DISABLED);
			}
		}
		
		FormatEx(buffer, sizeof(buffer), "%t", "Custom Anvil Enchant Refresh");
		menu.AddItem("-1557;0", buffer);
		
		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
}

static int EnchantRoll_Find(int account, int storeIndex)
{
	if(!EnchantRolls)
		return -1;
	
	int length = EnchantRolls.Length;
	for(int i; i < length; i++)
	{
		if(EnchantRolls.Get(i, EnchantRollEnum::AccountId) == account
		&& EnchantRolls.Get(i, EnchantRollEnum::StoreIndex) == storeIndex)
			return i;
	}
	
	return -1;
}

static void EnchantRoll_Remove(int account, int storeIndex)
{
	int index = EnchantRoll_Find(account, storeIndex);
	if(index != -1)
		EnchantRolls.Erase(index);
}

static int GetWeaponRarity(int weapon, int level) {
	int rarity = 0;
	
	switch (i_CustomWeaponEquipLogic[weapon]) {
		case WEAPON_MINECRAFT_SWORD:
		{
			switch(level)
			{
				case 0:
				{
				}
				case 1:
				{
					if((GetURandomInt() % 4) == 0)
					{
						rarity = 1;
					}
				}
				case 2:
				{
					int rand = GetURandomInt();
					if((rand % 7) == 0)
					{
						rarity = 2;
					}
					else if((rand % 3) == 0)
					{
						rarity = 1;
					}
				}
				case 3:
				{
					int rand = GetURandomInt();
					if((rand % 12) == 0)
					{
						rarity = 3;
					}
					else if((rand % 7) == 0)
					{
						rarity = 2;
					}
					else if((rand % 3) == 0)
					{
						rarity = 1;
					}
				}
				case 4:
				{
					int rand = GetURandomInt();
					if((rand % 12) == 0)
					{
						rarity = 4;
					}
					if((rand % 7) == 0)
					{
						rarity = 3;
					}
					else if((rand % 5) == 0)
					{
						rarity = 2;
					}
					else if((rand % 2) == 0)
					{
						rarity = 1;
					}
				}
				default:
				{
					int rand = GetURandomInt();
					if((rand % 7) == 0)
					{
						rarity = 4;
					}
					else if((rand % 5) == 0)
					{
						rarity = 3;
					}
					else if((rand % 3) == 0)
					{
						rarity = 2;
					}
					else if((rand % 2) == 0)
					{
						rarity = 1;
					}
				}
			}
		}
		default:
		{
			switch(level)
			{
				case 0, 1:
				{
				}
				case 2:
				{
					if((GetURandomInt() % 4) == 0)
						rarity = 1;
				}
				case 3:
				{
					int rand = GetURandomInt();
					if((rand % 7) == 0)
					{
						rarity = 2;
					}
					else if((rand % 3) == 0)
					{
						rarity = 1;
					}
				}
				case 4:
				{
					int rand = GetURandomInt();
					if((rand % 5) == 0)
					{
						rarity = 2;
					}
					else if((rand % 2) == 0)
					{
						rarity = 1;
					}
				}
				default:
				{
					if((GetURandomInt() % 3) == 0)
					{
						rarity = 2;
					}
					else
					{
						rarity = 1;
					}
				}
			}
		}
	}
	
	return rarity;
}

static char[] Query_GetTransList(int SelectInt) {
	char buffer[256];
	switch (SelectInt) {
		case TinkerEnchant_HastyMage:
			FormatEx(buffer, sizeof(buffer), "Tinker_HasteMage");
		case TinkerEnchant_HeavyMage:
			FormatEx(buffer, sizeof(buffer), "Tinker_HeavyMage");
		case TinkerEnchant_ConcentratedMagic:
			FormatEx(buffer, sizeof(buffer), "Tinker_ConcentratedMagic");
		case TinkerEnchant_TankMage:
			FormatEx(buffer, sizeof(buffer), "Tinker_TankMage");
		case TinkerEnchant_FrugalityMage:
			FormatEx(buffer, sizeof(buffer), "Tinker_FrugalityMage");
		case TinkerEnchant_MageFragility:
			FormatEx(buffer, sizeof(buffer), "Tinker_MageFragility");
		case TinkerEnchant_HoardingDisorder:
			FormatEx(buffer, sizeof(buffer), "Tinker_HoardingDisorder");
		
		case TinkerEnchant_MeleeRapidSwing, TinkerEnchant_HasteNonMage:
			FormatEx(buffer, sizeof(buffer), "Tinker_MeleeRapidSwing");
		case TinkerEnchant_MeleeHeavySwing:
			FormatEx(buffer, sizeof(buffer), "Tinker_MeleeHeavySwing");
		case TinkerEnchant_MeleeLongSwing:
			FormatEx(buffer, sizeof(buffer), "Tinker_MeleeLongSwing");
		case TinkerEnchant_MeleeGlassy:
			FormatEx(buffer, sizeof(buffer), "Tinker_SharedGlassy");
		case TinkerEnchant_MeleePlateArmor:
			FormatEx(buffer, sizeof(buffer), "Tinker_MeleePlateArmor");
		
		case TinkerEnchant_FastHeal:
			FormatEx(buffer, sizeof(buffer), "Tinker_FastHeal");
		case TinkerEnchant_Overhealer:
			FormatEx(buffer, sizeof(buffer), "Tinker_Overhealer");
		case TinkerEnchant_Uberer:
			FormatEx(buffer, sizeof(buffer), "Tinker_Uberer");
		case TinkerEnchant_BurstHeal:
			FormatEx(buffer, sizeof(buffer), "Tinker_BurstHeal");
		case TinkerEnchant_GlassyMedic:
			FormatEx(buffer, sizeof(buffer), "Tinker_SharedGlassy");
		
		case TinkerEnchant_BuildingExtension:
			FormatEx(buffer, sizeof(buffer), "Tinker_BuilderLongSwing");
		case TinkerEnchant_RepairMaster:
			FormatEx(buffer, sizeof(buffer), "Tinker_BuilderRepairMaster");
		
		case TinkerEnchant_SlowHeavyProjectile:
			FormatEx(buffer, sizeof(buffer), "Tinker_SlowHeavyProj");
		case TinkerEnchant_FastProjectile:
			FormatEx(buffer, sizeof(buffer), "Tinker_FastProj");
		case TinkerEnchant_IntensiveClip:
			FormatEx(buffer, sizeof(buffer), "Tinker_IntensiveClip");
		case TinkerEnchant_ConcentratedClip, TinkerEnchant_ConcentratedClip_Infinite:
			FormatEx(buffer, sizeof(buffer), "Tinker_ConcentratedClip");
		case TinkerEnchant_HeavyTrigger:
			FormatEx(buffer, sizeof(buffer), "Tinker_HeavyTrigger");
		case TinkerEnchant_SmallerSmarterBullet:
			FormatEx(buffer, sizeof(buffer), "Tinker_SmallerSmarterBullets");
		case TinkerEnchant_SprayAndPray:
			FormatEx(buffer, sizeof(buffer), "Tinker_SprayAndPray");
		
		case TinkerEnchant_MS_Sharpness:
			FormatEx(buffer, sizeof(buffer), "Tinker_MS_Sharpness");
		case TinkerEnchant_MS_Smite:
			FormatEx(buffer, sizeof(buffer), "Tinker_MS_Smite");
		case TinkerEnchant_MS_SweepingEdge:
			FormatEx(buffer, sizeof(buffer), "Tinker_MS_SweepingEdge");
		case TinkerEnchant_MS_QuickCharge:
			FormatEx(buffer, sizeof(buffer), "Tinker_MS_QuickCharge");
		case TinkerEnchant_MS_BaneOfArthropods:
			FormatEx(buffer, sizeof(buffer), "Tinker_MS_BaneofArthropods");
		case TinkerEnchant_MS_FireAspect:
			FormatEx(buffer, sizeof(buffer), "Tinker_MS_FireAspect");
		case TinkerEnchant_MS_CurseOfGlassy:
			FormatEx(buffer, sizeof(buffer), "Tinker_MS_CurseOfGlassy");
		
		case TinkerEnchant_SR_ExplosiveHeadshot:
			FormatEx(buffer, sizeof(buffer), "Tinker_SR_ExplosiveHeadshot");
		case TinkerEnchant_SR_KillerFocus:
			FormatEx(buffer, sizeof(buffer), "Tinker_SR_KillerFocus");
		case TinkerEnchant_SR_SuperCoolingChamber:
			FormatEx(buffer, sizeof(buffer), "Tinker_SR_SuperCoolingChamber");
		case TinkerEnchant_SR_DepletedUranium:
			FormatEx(buffer, sizeof(buffer), "Tinker_SR_DepletedUranium");
		case TinkerEnchant_SR_HighSpeedFeedMechanism:
			FormatEx(buffer, sizeof(buffer), "Tinker_SR_HighSpeedFeedMechanism");
		case TinkerEnchant_SR_HollowPointBullets:
			FormatEx(buffer, sizeof(buffer), "Tinker_SR_HollowPointBullets");
	}
	
	return buffer;
}

public void Anvil_Menu(int client)
{
	if(dieingstate[client] == 0)
	{	
		CancelClientMenu(client);
		SetStoreMenuLogic(client, false);
		static char buffer[128];
		Menu menu = new Menu(Anvil_MenuH);
		AnyMenuOpen[client] = 1;

		SetGlobalTransTarget(client);
		
		menu.SetTitle("%t", "Anvil Menu Main");

		/*FormatEx(buffer, sizeof(buffer), "%t", "Re-Roll Weapon Stats");
		menu.AddItem("-1", buffer);*/
		
		FormatEx(buffer, sizeof(buffer), "%t", "Custom Anvil Menu Main");
		menu.AddItem("-4", buffer);

		FormatEx(buffer, sizeof(buffer), "%t", "Remove Weapon Stats");
		menu.AddItem("-2", buffer);

		FormatEx(buffer, sizeof(buffer), "%t", "Display Current Stats");
		menu.AddItem("-3", buffer);
		
		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
}

public int Anvil_MenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
			if(IsValidClient(client))
				AnyMenuOpen[client] = 0;
		}
		case MenuAction_Select:
		{
			AnyMenuOpen[client] = 0;
			ResetStoreMenuLogic(client);
			char buffer[24];
			menu.GetItem(choice, buffer, sizeof(buffer));
			int id = StringToInt(buffer);
			int weapon;
			int anvil;
			int owner;
			
			if(IsValidClient(client))
			{
				weapon = EntRefToEntIndex(ClickedWithWeapon[client]);
				anvil = EntRefToEntIndex(AnvilClickedOn[client]);
			}
			else
				return 0;

			if(!IsValidEntity(weapon) || !IsValidEntity(anvil))
				return 0;
			else
			{
				owner = GetEntPropEnt(anvil, Prop_Send, "m_hOwnerEntity");
			}

			switch(id)
			{
				case -1:
				{
					Blacksmith_BuildingUsed_Internal(weapon, anvil, client, owner, false);
				}
				case -2:
				{
					Blacksmith_BuildingUsed_Internal(weapon, anvil, client, owner, true);
				}
				case -3:
				{
					Blacksmith_ExtraDesc(client, StoreWeapon[weapon]);
				}
				case -4:
				{
					Blacksmith_BuildingUsed_Internal_Custom(weapon, anvil, client, owner);
				}
			}
		}
		case MenuAction_Cancel:
		{
			ResetStoreMenuLogic(client);
		}
	}
	return 0;
}

static int UsedAnvil_MenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
			if (IsValidClient(client))
				AnyMenuOpen[client] = 0;
		}
		case MenuAction_Select:
		{
			AnyMenuOpen[client] = 0;
			ResetStoreMenuLogic(client);
			
			char buffer[128];
			menu.GetItem(choice, buffer, sizeof(buffer));
			
			char countext[2][24];
			ExplodeString(buffer, ";", countext, sizeof(countext), sizeof(countext[]));
			int id = StringToInt(countext[0]);
			int Count = StringToInt(countext[1]);
			
			int weapon;
			int anvil;
			int owner;
			
			if (IsValidClient(client)) {
				weapon = EntRefToEntIndex(ClickedWithWeapon[client]);
				anvil = EntRefToEntIndex(AnvilClickedOn[client]);
			}
			else
				return 0;
			
			if (!IsValidEntity(weapon) || !IsValidEntity(anvil))
				return 0;
			else {
				owner = GetEntPropEnt(anvil, Prop_Send, "m_hOwnerEntity");
			}
			
			int account = GetSteamAccountID(client, false);
			if (!account) {
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				if(IsValidEntity(anvil))
					ApplyBuildingCollectCooldown(anvil, client, 3.0);
				return 0;
			}
			
			if (id == -1557) {
				ApplyBuildingCollectCooldown(anvil, client, (owner == client ? 2.5 : 10.0));
				EnchantRoll_Remove(account, StoreWeapon[weapon]);
				ClientCommand(client, "playgamesound ui/quest_decode.wav");
				return 0;
			}
			
			// 메뉴가 열려 있는 사이 롤이 바뀌었거나 사라졌으면 무시
			int rollIndex = EnchantRoll_Find(account, StoreWeapon[weapon]);
			if (rollIndex == -1 || Count < 0 || Count >= ENCHANT_ROLL_COUNT)
				return 0;
			
			EnchantRollEnum roll;
			EnchantRolls.GetArray(rollIndex, roll);
			if (roll.Enchant[Count] != id)
				return 0;
			
			TinkerEnum tinker;
			
			int found = -1;
			if (Tinkers) {
				int length = Tinkers.Length;
				for (int a; a < length; a++) {
					Tinkers.GetArray(a, tinker);
					if (tinker.AccountId == account && tinker.StoreIndex == StoreWeapon[weapon]) {
						found = a;
						break;
					}
				}
			}
			
			if (found == -1) {
				tinker.AccountId = account;
				tinker.StoreIndex = StoreWeapon[weapon];
			}
			
			Zero(tinker.Attrib);
			Zero(tinker.CustomMode);
			Zero(tinker.Addition);
			
			for (int i; i < sizeof(tinker.Luck); i++) {
				tinker.Luck[i] = GetURandomFloat();
			}
			
			tinker.Rarity = roll.Rarity[Count];
			EnchantRolls.Erase(rollIndex);	// 사용한 롤은 폐기
			
			OnTinkerAnvilUsed(client, owner, anvil, id, tinker, found);
		}
		case MenuAction_Cancel:
		{
			ResetStoreMenuLogic(client);
		}
	}
	return 0;
}

void Blacksmith_BuildingUsed_Internal(int weapon, int entity, int client, int owner, bool reset)
{
	if(owner == -1)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		if(IsValidEntity(entity))
			DestroyBuildingDo(entity);
		SPrintToChat(client, "%t", "The Blacksmith Failed!");
		return;
	}
	
	int smithLevel = Blacksmith_GetSmithLevel(owner);
	if(smithLevel < 0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		if(IsValidEntity(entity))
			DestroyBuildingDo(entity);
		SPrintToChat(client, "%t", "The Blacksmith Failed!");
		return;
	}
	
	int account = GetSteamAccountID(client, false);
	if(!account)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		if(IsValidEntity(entity))
			ApplyBuildingCollectCooldown(entity, client, 3.0);
		return;
	}

	TinkerEnum tinker;
	int found = -1;
	if(Tinkers)
	{
		int length = Tinkers.Length;
		for(int a; a < length; a++)
		{
			Tinkers.GetArray(a, tinker);
			if(tinker.AccountId == account && tinker.StoreIndex == StoreWeapon[weapon])
			{
				found = a;
				break;
			}
		}
	}

	if(found == -1)
	{
		tinker.AccountId = account;
		tinker.StoreIndex = StoreWeapon[weapon];
	}
	
	Zero(tinker.Attrib);
	Zero(tinker.CustomMode);
	Zero(tinker.Addition);
	tinker.Rarity = 0;
	
	if (reset) {
		SetGlobalTransTarget(client);
		
		if (found == -1) {
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Blacksmith No Attribs");
			if(IsValidEntity(entity))
				ApplyBuildingCollectCooldown(entity, client, 2.0);
			
			return;
		}

		tinker.Rarity = -1;
		Tinkers.Erase(found);
		PrintToChat(client, "%t", "Removed Tinker Attributes");
		
		OnTinkerAnvilUsed(client, owner, entity, -1, tinker, found);
	}
	else {
		if (Attributes_Get(weapon, Attrib_DisallowTinker, 0.0) != 0.0)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Blacksmith Underleveled");
			
			if (IsValidEntity(entity))
				ApplyBuildingCollectCooldown(entity, client, 2.0);
			
			return;
		}
		
		tinker.Rarity = GetWeaponRarity(weapon, smithLevel);
		
		for(int i; i < sizeof(tinker.Luck); i++)
		{
			tinker.Luck[i] = GetURandomFloat();
		}
		
		int id = Query_Enchantment(weapon);
		if (id == 0) {
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Blacksmith Underleveled");
			if (IsValidEntity(entity))
				ApplyBuildingCollectCooldown(entity, client, 2.0);
			return;
		}
		
		OnTinkerAnvilUsed(client, owner, entity, id, tinker, found);
	}
}

static void OnTinkerAnvilUsed(int client, int owner, int anvil, int id, TinkerEnum tinker, int found) {
	if (id >= 0) {
		switch (id) {
			case TinkerEnchant_HastyMage:
				TinkerHastyMage(tinker.Rarity, tinker);
			case TinkerEnchant_HeavyMage:
				TinkerHeavyMage(tinker.Rarity, tinker);
			case TinkerEnchant_ConcentratedMagic:
				TinkerConcentrationMage(tinker.Rarity, tinker);
			case TinkerEnchant_TankMage:
				TinkerTankMage(tinker.Rarity, tinker);
			//case TinkerEnchant_FrugalityMage:
			//	TinkerFrugalityMage(tinker.Rarity, tinker);
			//case TinkerEnchant_MageFragility:
			//	TinkerMageFragility(tinker.Rarity, tinker);
			
			case TinkerEnchant_MeleeRapidSwing, TinkerEnchant_HasteNonMage:
				TinkerMeleeRapidSwing(tinker.Rarity, tinker);
			case TinkerEnchant_MeleeHeavySwing:
				TinkerMeleeHeavySwing(tinker.Rarity, tinker);
			case TinkerEnchant_MeleeLongSwing:
				TinkerMeleeLongSwing(tinker.Rarity, tinker);
			case TinkerEnchant_MeleeGlassy:
				TinkerMeleeGlassy(tinker.Rarity, tinker);
			
			case TinkerEnchant_FastHeal:
				TinkerMedigun_FastHeal(tinker.Rarity, tinker);
			case TinkerEnchant_Overhealer:
				TinkerMedigun_Overhealer(tinker.Rarity, tinker);
			case TinkerEnchant_Uberer:
				TinkerMedigun_Uberer(tinker.Rarity, tinker);
			case TinkerEnchant_BurstHeal:
				TinkerMedicWeapon_BurstHealMedic(tinker.Rarity, tinker);
			case TinkerEnchant_GlassyMedic:
				TinkerMedicWeapon_GlassyMedic(tinker.Rarity, tinker);
			
			case TinkerEnchant_BuildingExtension:
				TinkerBuilderLongSwing(tinker.Rarity, tinker);
			case TinkerEnchant_RepairMaster:
				TinkerBuilderRepairMaster(tinker.Rarity, tinker);
			
			case TinkerEnchant_SlowHeavyProjectile:
				TinkerRangedSlowHeavyProj(tinker.Rarity, tinker);
			case TinkerEnchant_FastProjectile:
				TinkerRangedFastProj(tinker.Rarity, tinker);
			case TinkerEnchant_IntensiveClip:
				TinkerIntensiveClip(tinker.Rarity, tinker);
			case TinkerEnchant_ConcentratedClip:
				TinkerConcentratedClip(tinker.Rarity, tinker);
			case TinkerEnchant_HeavyTrigger:
				TinkerHeavyTrigger(tinker.Rarity, tinker);
			case TinkerEnchant_SmallerSmarterBullet:
				TinkerSmallerSmarterBullets(tinker.Rarity, tinker);
			case TinkerEnchant_SprayAndPray:
				TinkerSprayAndPray(tinker.Rarity, tinker);
			case TinkerEnchant_ConcentratedClip_Infinite:
				TinkerConcentratedClipInfinite(tinker.Rarity, tinker);
			
			case TinkerEnchant_MS_Sharpness:
				Tinker_MS_Sharpness(tinker.Rarity, tinker);
			case TinkerEnchant_MS_Smite:
				Tinker_MS_Smite(tinker.Rarity, tinker);
			case TinkerEnchant_MS_SweepingEdge:
				Tinker_MS_SweepingEdge(tinker.Rarity, tinker);
			case TinkerEnchant_MS_QuickCharge:
				Tinker_MS_QuickCharge(tinker.Rarity, tinker);
			case TinkerEnchant_MS_BaneOfArthropods:
				Tinker_MS_BaneofArthropods(tinker.Rarity, tinker);
			case TinkerEnchant_MS_FireAspect:
				Tinker_MS_FireAspect(tinker.Rarity, tinker);
			case TinkerEnchant_MS_CurseOfGlassy:
				Tinker_MS_CurseofGlassy(tinker.Rarity, tinker);
			
			case TinkerEnchant_SR_ExplosiveHeadshot:
				Tinker_SR_ExplosiveHeadshot(tinker.Rarity, tinker);
			case TinkerEnchant_SR_KillerFocus:
				Tinker_SR_KillerFocus(tinker.Rarity, tinker);
			case TinkerEnchant_SR_SuperCoolingChamber:
				Tinker_SR_SuperCoolingChamber(tinker.Rarity, tinker);
			case TinkerEnchant_SR_DepletedUranium:
				Tinker_SR_DepletedUranium(tinker.Rarity, tinker);
			case TinkerEnchant_SR_HighSpeedFeedMechanism:
				Tinker_SR_HighSpeedFeedMechanism(tinker.Rarity, tinker);
			case TinkerEnchant_SR_HollowPointBullets:
				Tinker_SR_HollowPointBullets(tinker.Rarity, tinker);
			
			case TinkerEnchant_FT_FaceMelter:
				Tinker_FT_FaceMelter(tinker.Rarity, tinker);
		}
		
		SetGlobalTransTarget(client);
		
		char buffer[PLATFORM_MAX_PATH];
		FormatEx(buffer, sizeof(buffer), "%s", tinker.Name);
		if (TranslationPhraseExists(buffer))
			CPrintToChat(client, "{yellow}%t (Tier %d)", buffer, tinker.Rarity + 1);
		else {
			CPrintToChat(client, "{yellow}%s (Tier %d)", buffer, tinker.Rarity + 1);
			CPrintToChat(client, "{crimson}[Dev Warning] Translation not found");
		}
		
		for (int i; i < sizeof(tinker.Attrib); i++) {
			if (!tinker.Attrib[i])
				break;
			
			Blacksmith_PrintAttribValue(client, tinker.Attrib[i], tinker.Value[i], tinker.Luck[i], tinker.Addition[i], tinker.CustomMode[i]);
		}
		
		if (found == -1) {
			if(!Tinkers)
				Tinkers = new ArrayList(sizeof(TinkerEnum));
			
			Tinkers.PushArray(tinker);
		}
		else {
			Tinkers.SetArray(found, tinker);
		}
	}
	
	Building_GiveRewardsUse(client, owner, 25, true, 0.6, true);
	Store_ApplyAttribs(client);
	Store_GiveAll(client, GetClientHealth(client));
	
	switch(tinker.Rarity)
	{
		case -1:
		{
			ClientCommand(client, "playgamesound ui/quest_decode.wav");
		}
		case 0:
		{
			ClientCommand(client, "playgamesound ui/quest_status_tick_novice.wav");
		}
		case 1:
		{
			ClientCommand(client, "playgamesound ui/quest_status_tick_advanced.wav");
		}
		case 2:
		{
			ClientCommand(client, "playgamesound ui/quest_status_tick_expert.wav");
		}
	}

	float cooldown = Blacksmith_GetAnvilCooldown(Blacksmith_GetSmithLevel(owner));
	if (client != owner && Store_HasWeaponKit(client))
		cooldown *= 0.5;
	
	if (owner == client)
		cooldown /= 4.0;
	
	if (IsValidEntity(anvil))
		ApplyBuildingCollectCooldown(anvil, client, cooldown);
	
	if (!Rogue_Mode() && owner != client) {
		switch(tinker.Rarity)
		{
			case 0:
			{
				ClientCommand(owner, "playgamesound ui/quest_status_tick_novice_friend.wav");
			}
			case 1:
			{
				ClientCommand(owner, "playgamesound ui/quest_status_tick_advanced_friend.wav");
			}
			default:
			{
				ClientCommand(owner, "playgamesound ui/quest_status_tick_expert_friend.wav");
			}
		}
	}
}

static bool AttribIsInverse(int attrib)
{
	switch(attrib)
	{
		case 5, 6, 96, 97, 205, 206, 252, 343, 412, Attrib_TerrianRes:
			return true;
	}

	return false;
}

void Blacksmith_PrintAttribValue(int client, int attrib, float value, float luck, bool addition = false, int CustomMode = 0)
{
	if(attrib == 264)
	{
		return;
	}
	bool inverse = AttribIsInverse(attrib);

	char buffer[128];
	char TranslationBuffer[128];
	if(addition)
	{
		FormatEx(buffer, sizeof(buffer), "%d ", RoundToCeil(value));
	}
	else if(value < 1.0)
	{
		FormatEx(buffer, sizeof(buffer), "%d％ ", RoundToCeil((1.0 - value) * 100.0));
	}
	else
	{
		FormatEx(buffer, sizeof(buffer), "%d％ ", RoundToCeil((value - 1.0) * 100.0));
	}

	//inverse the inverse!
	bool inverse_color = false;
	if(attrib == 733)
	{
		inverse_color = true;
	}
	if(attrib == 41 && CustomMode==1)
		inverse=true;

	if(((value < (addition ? 0.0 : 1.0)) ^ inverse))
	{
		if(!inverse_color)
		{
			Format(buffer, sizeof(buffer), "{crimson}-%s", buffer);
		}
		else
		{
			Format(buffer, sizeof(buffer), "{green}-%s", buffer);
		}
	}
	else
	{
		if(!inverse_color)
		{
			Format(buffer, sizeof(buffer), "{green}+%s", buffer);
		}
		else
		{
			Format(buffer, sizeof(buffer), "{crimson}+%s", buffer);
		}
	}
	SetGlobalTransTarget(client);
	FormatEx(TranslationBuffer, sizeof(TranslationBuffer), "%s", Query_GetTinkerAttrib(attrib, CustomMode));
	if(TranslationPhraseExists(TranslationBuffer))
		Format(TranslationBuffer, sizeof(TranslationBuffer), "%t", TranslationBuffer);
	Format(buffer, sizeof(buffer), "%s %s", buffer, TranslationBuffer);
	
	CPrintToChat(client, "%s {yellow}(%d％)", buffer, RoundToCeil(luck * 100.0));
}

static char[] Query_GetTinkerAttrib(int Attrib, int CustomMode)
{
	char buffer[256];
	switch(Attrib)
	{
		case 1:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_PhysicalDamage");
		case 2:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_BaseDamage");
		case 3, 4:
		{
			if (CustomMode == 1)
				FormatEx(buffer, sizeof(buffer), "TinkerAttrib_SweepingEdge_MaxHit");
			else
				FormatEx(buffer, sizeof(buffer), "TinkerAttrib_ClipSize");
		}
		case 5, 6:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_FireRate");
		case 8:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_HealingRate");
		case 10, 9:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_UberChargeRate");
		case 16:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_HealthOnHit");
		case 26:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_MaxHealth");
		case 41:
		{
			if (CustomMode==1)
				FormatEx(buffer, sizeof(buffer), "TinkerAttrib_SweepingEdge_ChargeRate");
			else
				FormatEx(buffer, sizeof(buffer), "TinkerAttrib_ChargeRate");
		}
		case 45:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_BulletsPerShot");
		case 54, 107:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_MovementSpeed");
		case 57:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_HealthRegen");
		case 95:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_RepairRate");
		case 96, 97:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_ReloadSpeed");
		case 99, 100:
		{
			if (CustomMode==1)
				FormatEx(buffer, sizeof(buffer), "TinkerAttrib_SweepingEdgeRange");
			else
				FormatEx(buffer, sizeof(buffer), "TinkerAttrib_BlastRadius");
		}
		case 101, 102:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_ProjectileSpeed");
		case 103, 104:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_ProjectileRange");
		case 106:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_BulletSpread");
		case 149:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_BleedDuration");
		case 205:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_RangedResistance");
		case 206:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_MeleeResistance");
		case 252:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_KnockbackResistance");
		case 287:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_SentryDamage");
		case 319:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_BuffDuration");
		case 326:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_JumpHeight");
		case 343:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_SentryFiringSpeed");
		case 397:
		{
			if (CustomMode == 1)
				FormatEx(buffer, sizeof(buffer), "TinkerAttrib_FireAspect");
		}
		case 410:
		{
			if(CustomMode == 1)
				FormatEx(buffer, sizeof(buffer), "TinkerAttrib_JumpCrit");
			else
				FormatEx(buffer, sizeof(buffer), "TinkerAttrib_BaseDamage");
		}
		case 411:
		{
			if (CustomMode == 1)
				FormatEx(buffer, sizeof(buffer), "TinkerAttrib_BaneofArthropods");
		}
		case 412:FormatEx(buffer, sizeof(buffer), "TinkerAttrib_Resistance");
		case 425:
		{
			if (CustomMode == 1)
				FormatEx(buffer, sizeof(buffer), "TinkerAttrib_SweepingEdgeDamage");
		}
		
		case 733:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_MagicCost");
		
		case 4001:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_ExtraMeleeRange");
		
		case 4002:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_Overheal");
		
		case Attrib_TerrianRes:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_TerrianResistance");
		case Attrib_ElementalDef:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_ElementalResistance");
		case Attrib_SlowImmune:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_SlowResistance");
		case Attrib_ObjTerrianAbsorb:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_BuildingTerrianAbsorb");
		
		case Attrib_SetArchetype:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_WeaponArchetype");
		
		case 4019:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_MaxMana");
		
		case Attrib_ExplosiveHeadshot:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_ExplosiveHeadshot");
		case Attrib_DamageBonusFullCharge:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_FullChargeDamage");
		case 390:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_HeadshotDamage");
		
		case 173:
			FormatEx(buffer, sizeof(buffer), "TinkerAttrib_FlamethrowerAmmoConsumed");
	}
	return buffer;
}

//---------------
// Detailed TinkerEnum
//---------------

static void TinkerMeleeGlassy(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_SharedGlassy");
	tinker.Attrib[0] = 2;
	tinker.Attrib[1] = 205;
	tinker.Attrib[2] = 206;
	float DamageLuck = (0.1 * (tinker.Luck[0]));
	float RangedDmgVulLuck = (0.05 * (1.0 + (-1.0*(tinker.Luck[1]))));
	float MeleeDmgVulLuck = (0.05 * (1.0 + (-1.0*(tinker.Luck[2]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.1 + DamageLuck;
			tinker.Value[1] = 1.05 + RangedDmgVulLuck;
			tinker.Value[2] = 1.05 + MeleeDmgVulLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.15 + DamageLuck;
			tinker.Value[1] = 1.05 + RangedDmgVulLuck;
			tinker.Value[2] = 1.05 + MeleeDmgVulLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.2 + DamageLuck;
			tinker.Value[1] = 1.05 + RangedDmgVulLuck;
			tinker.Value[2] = 1.05 + MeleeDmgVulLuck;
		}
	}
}

static void TinkerMeleeRapidSwing(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_MeleeRapidSwing");
	tinker.Attrib[0] = 2; //damage
	tinker.Attrib[1] = 6; //attackspeed
	//less damage
	//but faster attackspeed
	//inverts the luck
	float DamageLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[0]))));
	float AttackspeedLuck = (0.1 * (tinker.Luck[1]));
	
	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 0.95 - DamageLuck;
			tinker.Value[1] = 0.9 - AttackspeedLuck;
		}
		case 1:
		{
			tinker.Value[0] = 0.85 - DamageLuck;
			tinker.Value[1] = 0.8 - AttackspeedLuck;
		}
		case 2:
		{
			tinker.Value[0] = 0.8 - DamageLuck;
			tinker.Value[1] = 0.7 - AttackspeedLuck;
		}
	}
}

static void TinkerMeleeHeavySwing(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_MeleeHeavySwing");
	tinker.Attrib[0] = 2; //damage
	tinker.Attrib[1] = 6; //attackspeed
	//less damage
	//but faster attackspeed
	//inverts the luck
	float DamageLuck = (0.1 * (tinker.Luck[0]));
	float AttackspeedLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[1]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.25 + DamageLuck;
			tinker.Value[1] = 1.15 + AttackspeedLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.3 + DamageLuck;
			tinker.Value[1] = 1.2 + AttackspeedLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.4 + DamageLuck;
			tinker.Value[1] = 1.25 + AttackspeedLuck;
		}
	}
}

static void TinkerMeleeLongSwing(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_MeleeLongSwing");
	tinker.Attrib[0] = 2; //damage
	tinker.Attrib[1] = 6; //attackspeed
	tinker.Attrib[2] = 4001; //ExtraMeleeRange
	
	float DamageLuck = (0.1 * (tinker.Luck[0]));
	float AttackspeedLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[1]))));
	float ExtraRangeLuck = (0.1 * (tinker.Luck[2]));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.10 + DamageLuck;
			tinker.Value[1] = 1.15 + AttackspeedLuck;
			tinker.Value[2] = 1.15 + ExtraRangeLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.15 + DamageLuck;
			tinker.Value[1] = 1.2 + AttackspeedLuck;
			tinker.Value[2] = 1.2 + ExtraRangeLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.20 + DamageLuck;
			tinker.Value[1] = 1.25 + AttackspeedLuck;
			tinker.Value[2] = 1.35 + ExtraRangeLuck;
		}
	}
}

static void TinkerHastyMage(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_HasteMage");
	tinker.Attrib[0] = 6;
	tinker.Attrib[1] = 733;
	float AttackspeedLuck = (0.1 * (tinker.Luck[1]));
	float MageShootExtraCost = (0.15 * (1.0 + (-1.0*(tinker.Luck[1]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 0.8 + AttackspeedLuck;
			tinker.Value[1] = 1.25 + MageShootExtraCost;
		}
		case 1:
		{
			tinker.Value[0] = 0.75 + AttackspeedLuck;
			tinker.Value[1] = 1.35 + MageShootExtraCost;
		}
		case 2:
		{
			tinker.Value[0] = 0.7 + AttackspeedLuck;
			tinker.Value[1] = 1.45 + MageShootExtraCost;
		}
	}
}
static void TinkerHeavyMage(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_HeavyMage");
	tinker.Attrib[0] = 6;
	tinker.Attrib[1] = 733;
	tinker.Attrib[2] = 410;
	float AttackspeedLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[1]))));
	float MageShootExtraCost = (0.15 * (1.0 + (-1.0*(tinker.Luck[1]))));
	float DamageLuck = (0.1 * (tinker.Luck[2]));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.1 + AttackspeedLuck;
			tinker.Value[1] = 1.55 + MageShootExtraCost;
			tinker.Value[2] = 1.25 + DamageLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.15 + AttackspeedLuck;
			tinker.Value[1] = 1.65 + MageShootExtraCost;
			tinker.Value[2] = 1.3 + DamageLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.2 + AttackspeedLuck;
			tinker.Value[1] = 1.75 + MageShootExtraCost;
			tinker.Value[2] = 1.35 + DamageLuck;
		}
	}
}

static void TinkerConcentrationMage(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_ConcentratedMagic");
	tinker.Attrib[0] = 103;
	tinker.Attrib[1] = 410;
	float ProjectileSpeed = (0.1 * (tinker.Luck[0]));
	float DamageLuck = (0.1 * (tinker.Luck[1]));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 0.4 + ProjectileSpeed;
			tinker.Value[1] = 1.15 + DamageLuck;
		}
		case 1:
		{
			tinker.Value[0] = 0.45 + ProjectileSpeed;
			tinker.Value[1] = 1.2 + DamageLuck;
		}
		case 2:
		{
			tinker.Value[0] = 0.5 + ProjectileSpeed;
			tinker.Value[1] = 1.25 + DamageLuck;
		}
	}
}


static void TinkerTankMage(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_TankMage");
	tinker.Attrib[0] = 733;
	tinker.Attrib[1] = 410;
	tinker.Attrib[2] = 205;
	tinker.Attrib[3] = 206;
	float MageShotCost = (0.1 * (1.0 + (-1.0*(tinker.Luck[0]))));
	float DamageLuck = (0.1 * (tinker.Luck[1]));
	float RangedDmgLuck = (0.05 * (tinker.Luck[2]));
	float MeleeDmgLuck = (0.05 * (tinker.Luck[3]));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.15 + MageShotCost;
			tinker.Value[1] = 0.95 + DamageLuck;
			tinker.Value[2] = 0.95 - RangedDmgLuck;
			tinker.Value[3] = 0.95 - MeleeDmgLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.2 + MageShotCost;
			tinker.Value[1] = 0.93 + DamageLuck;
			tinker.Value[2] = 0.93 - RangedDmgLuck;
			tinker.Value[3] = 0.93 - MeleeDmgLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.25 + MageShotCost;
			tinker.Value[1] = 0.92 + DamageLuck;
			tinker.Value[2] = 0.9 - RangedDmgLuck;
			tinker.Value[3] = 0.9 - MeleeDmgLuck;
		}
	}
}

/*
static void TinkerFrugalityMage(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_FrugalityMage");
	tinker.Attrib[0] = 6;
	tinker.Attrib[1] = 410;
	tinker.Attrib[2] = 733;
	float AttackspeedLuck = (0.05 * (tinker.Luck[0]));
	float DamageLuck = (0.1 * (tinker.Luck[1]));
	float MageShootDiscount = (0.15 * (1.0 + (-1.0*(tinker.Luck[1]))));
	
	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 0.95 + AttackspeedLuck;
			tinker.Value[1] = 0.95 + DamageLuck;
		}
		case 1:
		{
			tinker.Value[0] = 0.9 + AttackspeedLuck;
			tinker.Value[1] = 0.9 + DamageLuck;
		}
		case 2:
		{
			tinker.Value[0] = 0.8 + AttackspeedLuck;
			tinker.Value[1] = 0.85 + DamageLuck;
		}
	}
}
*/

/**
 * Thinking about multiple mage weapon have this upgrades..
 */
/*
static void TinkerMageFragility(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_MageFragility");
	tinker.Attrib[0] = 2;
	tinker.Attrib[1] = 405;
	tinker.Attrib[2] = 5005;
	float DamageLuck = (0.05 * tinker.Luck[0]);
	float MaxManaLuck = (0.05 * tinker.Luck[1]);
	float MaxHealthLuck = (0.05 * (1.0 - tinker.Luck[2]));
	
	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.05 + DamageLuck;
			tinker.Value[1] = 1.05 + MaxManaLuck;
			tinker.Value[2] = 0.9 - MaxHealthLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.1 + DamageLuck;
			tinker.Value[1] = 1.1 + MaxManaLuck;
			tinker.Value[2] = 0.8 - MaxHealthLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.15 + DamageLuck;
			tinker.Value[1] = 1.15 + MaxManaLuck;
			tinker.Value[2] = 0.75 - MaxHealthLuck;
		}
	}
}
*/

static void TinkerMedigun_FastHeal(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_FastHeal");
	tinker.Attrib[0] = 8; //more heal rate
	tinker.Attrib[1] = 9; //Less uber rate
	tinker.Attrib[2] = 4002; //Less Overheal
	float MoreHealRateLuck = (0.1 * (tinker.Luck[0]));
	float LessUberRateLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[1]))));
	float LessOverhealRateLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[2]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.15 + MoreHealRateLuck;
			tinker.Value[1] = 0.95 - LessUberRateLuck;
			tinker.Value[2] = 0.96 - LessOverhealRateLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.25 + MoreHealRateLuck;
			tinker.Value[1] = 0.92 - LessUberRateLuck;
			tinker.Value[2] = 0.95 - LessOverhealRateLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.35 + MoreHealRateLuck;
			tinker.Value[1] = 0.88 - LessUberRateLuck;
			tinker.Value[2] = 0.9 - LessOverhealRateLuck;
		}
	}
}
static void TinkerMedigun_Overhealer(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_Overhealer");
	tinker.Attrib[0] = 8;
	tinker.Attrib[1] = 4002; 
	float LessHealRateLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[0]))));
	float MoreOverhealLuck = (0.1 * (tinker.Luck[1]));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.05 - LessHealRateLuck;
			tinker.Value[1] = 1.1 + MoreOverhealLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.0 - LessHealRateLuck;
			tinker.Value[1] = 1.15 + MoreOverhealLuck;
		}
		case 2:
		{
			tinker.Value[0] = 0.95 - LessHealRateLuck;
			tinker.Value[1] = 1.20 + MoreOverhealLuck;
		}
	}
}


static void TinkerMedigun_Uberer(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_Uberer");
	tinker.Attrib[0] = 8;
	tinker.Attrib[1] = 9;
	float LessHealRate = (0.1 * (1.0 + (-1.0*(tinker.Luck[0]))));
	float MoreUberRate = (0.1 * (tinker.Luck[1]));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 0.9 - LessHealRate;
			tinker.Value[1] = 1.1 + MoreUberRate;
		}
		case 1:
		{
			tinker.Value[0] = 0.85 - LessHealRate;
			tinker.Value[1] = 1.15 + MoreUberRate;
		}
		case 2:
		{
			tinker.Value[0] = 0.8 - LessHealRate;
			tinker.Value[1] = 1.25 + MoreUberRate;
		}
	}
}


static void TinkerMedicWeapon_GlassyMedic(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_SharedGlassy");
	tinker.Attrib[0] = 8; //more heal rate
	tinker.Attrib[1] = 6; 
	tinker.Attrib[2] = 205;
	tinker.Attrib[3] = 206;
	float HealRateLuck = (0.1 * (tinker.Luck[0]));
	float AttackRateLuck = (0.1 * (tinker.Luck[1]));
	float RangedDmgVulLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[2]))));
	float MeleeDmgVulLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[3]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.05 + HealRateLuck;
			tinker.Value[1] = 0.9 - AttackRateLuck;
			tinker.Value[2] = 1.05 + RangedDmgVulLuck;
			tinker.Value[3] = 1.05 + MeleeDmgVulLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.1 + HealRateLuck;
			tinker.Value[1] = 0.86 - AttackRateLuck;
			tinker.Value[2] = 1.075 + RangedDmgVulLuck;
			tinker.Value[3] = 1.075 + MeleeDmgVulLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.15 + HealRateLuck;
			tinker.Value[1] = 0.84 - AttackRateLuck;
			tinker.Value[2] = 1.10 + RangedDmgVulLuck;
			tinker.Value[3] = 1.10 + MeleeDmgVulLuck;
		}
	}
}

static void TinkerMedicWeapon_BurstHealMedic(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_BurstHeal");
	tinker.Attrib[0] = 8; //more heal rate
	tinker.Attrib[1] = 6; 
	tinker.Attrib[2] = 97; 
	float HealRateLuck = (0.2 * (tinker.Luck[0]));
	float AttackRateLuck = (0.12 * (tinker.Luck[1]));
	float ReloadRateLuck = (0.12 * (tinker.Luck[2]));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.75 + HealRateLuck;
			tinker.Value[1] = 1.6 + AttackRateLuck;
			tinker.Value[2] = 1.6 + ReloadRateLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.9 + HealRateLuck;
			tinker.Value[1] = 1.75 + AttackRateLuck;
			tinker.Value[2] = 1.75 + ReloadRateLuck;
		}
		case 2:
		{
			tinker.Value[0] = 2.1 + HealRateLuck;
			tinker.Value[1] = 1.85 + AttackRateLuck;
			tinker.Value[2] = 1.85 + ReloadRateLuck;
		}
	}
}

static void TinkerBuilderLongSwing(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_BuilderLongSwing");
	tinker.Attrib[0] = 6; //attackspeed
	tinker.Attrib[1] = 264; //ExtraMeleeRange
	tinker.Attrib[2] = 4001; //ExtraMeleeRange
	
	float AttackspeedLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[0]))));
	float ExtraRangeLuck = (0.1 * (tinker.Luck[1]));

	tinker.Luck[2] = tinker.Luck[1];

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.25 + AttackspeedLuck;
			tinker.Value[1] = 1.5 + ExtraRangeLuck;
			tinker.Value[2] = 1.5 + ExtraRangeLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.35 + AttackspeedLuck;
			tinker.Value[1] = 1.5 + ExtraRangeLuck;
			tinker.Value[2] = 1.75 + ExtraRangeLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.4 + AttackspeedLuck;
			tinker.Value[1] = 1.5 + ExtraRangeLuck;
			tinker.Value[2] = 2.0 + ExtraRangeLuck;
		}
	}
}

static void TinkerBuilderRepairMaster(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_BuilderRepairMaster");
	tinker.Attrib[0] = 95; //RepairRate
	tinker.Attrib[1] = 107; //movementspeed
	
	float RepairRate = (0.1 * (tinker.Luck[0]));
	float MovementSpeed = (0.05 * (1.0 + (-1.0*(tinker.Luck[1]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.25 + RepairRate;
			tinker.Value[1] = 0.98 - MovementSpeed;
		}
		case 1:
		{
			tinker.Value[0] = 1.3 + RepairRate;
			tinker.Value[1] = 0.98 - MovementSpeed;
		}
		case 2:
		{
			tinker.Value[0] = 1.4 + RepairRate;
			tinker.Value[1] = 0.98 - MovementSpeed;
		}
	}
}

static void TinkerRangedSlowHeavyProj(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_SlowHeavyProj");
	tinker.Attrib[0] = 2; //damage
	tinker.Attrib[1] = 103; //ProjectileSpeed
	tinker.Attrib[2] = 6; //attackspeed
	
	float DamageLuck = (0.1 * (tinker.Luck[0]));
	float ProjectileSpeedLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[1]))));
	float AttackspeedLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[2]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.15 + DamageLuck;
			tinker.Value[1] = 0.7 - ProjectileSpeedLuck;
			tinker.Value[2] = 1.05 + AttackspeedLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.20 + DamageLuck;
			tinker.Value[1] = 0.65 - ProjectileSpeedLuck;
			tinker.Value[2] = 1.1 + AttackspeedLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.3 + DamageLuck;
			tinker.Value[1] = 0.6 - ProjectileSpeedLuck;
			tinker.Value[2] = 1.12 + AttackspeedLuck;
		}
	}
}

static void TinkerRangedFastProj(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_FastProj");
	tinker.Attrib[0] = 2; //damage
	tinker.Attrib[1] = 103; //ProjectileSpeed
	tinker.Attrib[2] = 6; //attackspeed
	
	float DamageLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[0]))));
	float ProjectileSpeedLuck = (0.1 * (tinker.Luck[1]));
	float AttackspeedLuck = (0.1 * (tinker.Luck[2]));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 0.9 - DamageLuck;
			tinker.Value[1] = 1.35 + ProjectileSpeedLuck;
			tinker.Value[2] = 0.95 - AttackspeedLuck;
		}
		case 1:
		{
			tinker.Value[0] = 0.9 - DamageLuck;
			tinker.Value[1] = 1.5 + ProjectileSpeedLuck;
			tinker.Value[2] = 0.93 - AttackspeedLuck;
		}
		case 2:
		{
			tinker.Value[0] = 0.85 - DamageLuck;
			tinker.Value[1] = 1.65 + ProjectileSpeedLuck;
			tinker.Value[2] = 0.9 - AttackspeedLuck;
		}
	}
}


static void TinkerIntensiveClip(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_IntensiveClip");
	tinker.Attrib[0] = 6; //attackspeed
	tinker.Attrib[1] = 4; //Clipsize
	tinker.Attrib[2] = 97; //ReloadSpeed
	
	float AttackSpeedLuck = (0.07 * (tinker.Luck[0]));
	float ClipSizeLuck = (0.15 * (tinker.Luck[1]));
	float ReloadSpeedLuck = (0.15 * (1.0 + (-1.0*(tinker.Luck[2]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 0.95 - AttackSpeedLuck;
			tinker.Value[1] = 1.5 + ClipSizeLuck;
			tinker.Value[2] = 1.7 + ReloadSpeedLuck;
		}
		case 1:
		{
			tinker.Value[0] = 0.93 - AttackSpeedLuck;
			tinker.Value[1] = 1.65 + ClipSizeLuck;
			tinker.Value[2] = 1.8 + ReloadSpeedLuck;
		}
		case 2:
		{
			tinker.Value[0] = 0.92 - AttackSpeedLuck;
			tinker.Value[1] = 1.75 + ClipSizeLuck;
			tinker.Value[2] = 1.9 + ReloadSpeedLuck;
		}
	}
}

static void TinkerConcentratedClip(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_ConcentratedClip");
	tinker.Attrib[0] = 2; //Damage
	tinker.Attrib[1] = 97; //ReloadSpeed
	
	float ExtraDamage = (0.1 * (tinker.Luck[0]));
	float ReloadSpeedLuck = (0.2 * (1.0 + (-1.0*(tinker.Luck[1]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.15 + ExtraDamage;
			tinker.Value[1] = 1.35 + ReloadSpeedLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.2 + ExtraDamage;
			tinker.Value[1] = 1.4 + ReloadSpeedLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.25 + ExtraDamage;
			tinker.Value[1] = 1.5 + ReloadSpeedLuck;
		}
	}
}

static void TinkerConcentratedClipInfinite(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_ConcentratedClip");
	tinker.Attrib[0] = 2; //Damage
	tinker.Attrib[1] = 6; //attackspeed
	
	float ExtraDamage = (0.1 * (tinker.Luck[0]));
	float AttackspeedLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[1]))));
	
	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.2 + ExtraDamage;
			tinker.Value[1] = 1.15 + AttackspeedLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.25 + ExtraDamage;
			tinker.Value[1] = 1.2 + AttackspeedLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.35 + ExtraDamage;
			tinker.Value[1] = 1.25 + AttackspeedLuck;
		}
	}
}

static void TinkerHeavyTrigger(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_HeavyTrigger");
	tinker.Attrib[0] = 2; //Damage
	tinker.Attrib[1] = 6; //attackspeed
	tinker.Attrib[2] = 97; //Reload speed
	
	float ExtraDamage = (0.1 * (tinker.Luck[0]));
	float attackspeedSpeedLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[1]))));
	float reloadSpeedLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[2]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.2 + ExtraDamage;
			tinker.Value[1] = 1.1 + attackspeedSpeedLuck;
			tinker.Value[2] = 1.1 + reloadSpeedLuck;
		}
		case 1:
		{
			tinker.Value[0] = 1.25 + ExtraDamage;
			tinker.Value[1] = 1.15 + attackspeedSpeedLuck;
			tinker.Value[2] = 1.15 + reloadSpeedLuck;
		}
		case 2:
		{
			tinker.Value[0] = 1.3 + ExtraDamage;
			tinker.Value[1] = 1.2 + attackspeedSpeedLuck;
			tinker.Value[2] = 1.2 + reloadSpeedLuck;
		}
	}
}

static void TinkerSprayAndPray(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_SprayAndPray");
	tinker.Attrib[0] = 45; //BulletsPetShot
	tinker.Attrib[1] = 2; //damage
	
	float BulletPetShotBonus = (0.1 * (tinker.Luck[0]));
	float AccuracySuffering = (0.1 * (1.0 + (-1.0*(tinker.Luck[1]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 1.35 + BulletPetShotBonus;
			tinker.Value[1] = 0.85 - AccuracySuffering;
		}
		case 1:
		{
			tinker.Value[0] = 1.4 + BulletPetShotBonus;
			tinker.Value[1] = 0.83 - AccuracySuffering;
		}
		case 2:
		{
			tinker.Value[0] = 1.45 + BulletPetShotBonus;
			tinker.Value[1] = 0.8 - AccuracySuffering;
		}
	}
}

static void TinkerSmallerSmarterBullets(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_SmallerSmarterBullets");
	tinker.Attrib[0] = 2; //Less Damage
	tinker.Attrib[1] = 6; //Faster Shooting
	tinker.Attrib[2] = 97; //faster Reload
	
	float DamageLuck = (0.1 * (tinker.Luck[0]));
	float AttackSpeedLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[1]))));
	float FasterReloadLuck = (0.1 * (1.0 + (-1.0*(tinker.Luck[2]))));

	switch(rarity)
	{
		case 0:
		{
			tinker.Value[0] = 0.85 + DamageLuck;
			tinker.Value[1] = 0.8 + AttackSpeedLuck;
			tinker.Value[2] = 0.8 + FasterReloadLuck;
		}
		case 1:
		{
			tinker.Value[0] = 0.8 + DamageLuck;
			tinker.Value[1] = 0.7 + AttackSpeedLuck;
			tinker.Value[2] = 0.7 + FasterReloadLuck;
		}
		case 2:
		{
			tinker.Value[0] = 0.7 + DamageLuck;
			tinker.Value[1] = 0.6 + AttackSpeedLuck;
			tinker.Value[2] = 0.6 + FasterReloadLuck;
		}
	}
}

static void Tinker_MS_Sharpness(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_MS_Sharpness");
	tinker.Attrib[0] = 2;
	float DamageLuck = (0.1 * (tinker.Luck[0]));
	
	switch(rarity)
	{
		case 0:tinker.Value[0] = 1.1 + DamageLuck;
		case 1:tinker.Value[0] = 1.15 + DamageLuck;
		case 2:tinker.Value[0] = 1.2 + DamageLuck;
		case 3:tinker.Value[0] = 1.25 + DamageLuck;
		case 4:tinker.Value[0] = 1.32 + DamageLuck;
	}
}

static void Tinker_MS_Smite(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_MS_Smite");
	tinker.Attrib[0] = 2;
	tinker.Attrib[1] = 410;
	tinker.Attrib[2] = 41;
	tinker.CustomMode[1]=1;
	tinker.CustomMode[2]=1;
	float DamageLuck = (0.01 * (tinker.Luck[0]));
	float CritLuck = (0.025 * (tinker.Luck[1]));
	float ChargeRate = (0.1 * (tinker.Luck[2]));
	
	switch(rarity)
	{
		case 0:{tinker.Value[0] = 1.1 + DamageLuck;tinker.Value[1] = 1.2 + CritLuck;tinker.Value[2] = 2.0 + ChargeRate;}
		case 1:{tinker.Value[0] = 1.12 + DamageLuck;tinker.Value[1] = 1.26 + CritLuck;tinker.Value[2] = 1.75 + ChargeRate;}
		case 2:{tinker.Value[0] = 1.15 + DamageLuck;tinker.Value[1] = 1.31 + CritLuck;tinker.Value[2] = 1.5 + ChargeRate;}
		case 3:{tinker.Value[0] = 1.2 + DamageLuck;tinker.Value[1] = 1.35 + CritLuck;tinker.Value[2] = 1.25 + ChargeRate;}
		case 4:{tinker.Value[0] = 1.35 + DamageLuck;tinker.Value[1] = 1.43 + CritLuck;tinker.Value[2] = 1.1 + ChargeRate;}
	}
}

static void Tinker_MS_SweepingEdge(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_MS_SweepingEdge");
	tinker.Attrib[0] = 99;
	tinker.Attrib[1] = 4;
	tinker.Attrib[2] = 425;
	tinker.CustomMode[0]=1;
	tinker.CustomMode[1]=1;
	tinker.CustomMode[2]=1;
	tinker.Addition[1]=true;
	float RangeLuck = (0.1 * (tinker.Luck[0]));
	float MaxTargetLuck = (0.5 * (tinker.Luck[1]));
	float DamageLuck = (0.1 * (tinker.Luck[2]));

	switch(rarity)
	{
		case 0:{tinker.Value[0] = 1.25 + RangeLuck;tinker.Value[1] = 1.0 + MaxTargetLuck;tinker.Value[2] = 1.05 + DamageLuck;}
		case 1:{tinker.Value[0] = 1.5 + RangeLuck;tinker.Value[1] = 2.0 + MaxTargetLuck;tinker.Value[2] = 1.1 + DamageLuck;}
		case 2:{tinker.Value[0] = 1.75 + RangeLuck;tinker.Value[1] = 3.0 + MaxTargetLuck;tinker.Value[2] = 1.2 + DamageLuck;}
		case 3:{tinker.Value[0] = 2.0 + RangeLuck;tinker.Value[1] = 4.0 + MaxTargetLuck;tinker.Value[2] = 1.25 + DamageLuck;}
		case 4:{tinker.Value[0] = 2.5 + RangeLuck;tinker.Value[1] = 4.5 + MaxTargetLuck;tinker.Value[2] = 1.3 + DamageLuck;}
	}
}

static void Tinker_MS_QuickCharge(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_MS_QuickCharge");
	tinker.Attrib[0] = 41;
	tinker.Attrib[1] = 6;
	tinker.Attrib[2] = 425;
	tinker.CustomMode[0]=1;
	tinker.CustomMode[2]=1;
	float ChargeRate = (0.01 * (1.0 + (-1.0*(tinker.Luck[0]))));
	float AttackSpeedLuck = (0.1 * (tinker.Luck[1]));
	float DamageLuck = (0.1 * (tinker.Luck[2]));

	switch(rarity)
	{
		case 0:{tinker.Value[0] = 0.9 + ChargeRate;tinker.Value[1] = 0.9 - AttackSpeedLuck;tinker.Value[2] = 0.7 + DamageLuck;}
		case 1:{tinker.Value[0] = 0.87 + ChargeRate;tinker.Value[1] = 0.87 - AttackSpeedLuck;tinker.Value[2] = 0.72 + DamageLuck;}
		case 2:{tinker.Value[0] = 0.8 + ChargeRate;tinker.Value[1] = 0.85 - AttackSpeedLuck;tinker.Value[2] = 0.75 + DamageLuck;}
		case 3:{tinker.Value[0] = 0.65 + ChargeRate;tinker.Value[1] = 0.8 - AttackSpeedLuck;tinker.Value[2] = 0.77 + DamageLuck;}
		case 4:{tinker.Value[0] = 0.5 + ChargeRate;tinker.Value[1] = 0.75 - AttackSpeedLuck;tinker.Value[2] = 0.8 + DamageLuck;}
	}
}

static void Tinker_MS_BaneofArthropods(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_MS_BaneofArthropods");
	tinker.Attrib[0] = 2;
	tinker.Attrib[1] = 411;
	tinker.Addition[1]=true;
	tinker.CustomMode[1]=1;
	float DamageLuck = (0.1 * (tinker.Luck[0]));
	float SilencedLuck = (0.5 * (tinker.Luck[1]));

	switch(rarity)
	{
		case 0:{tinker.Value[0] = 0.65 + DamageLuck;tinker.Value[1] = 1.0 + SilencedLuck;}
		case 1:{tinker.Value[0] = 0.7 + DamageLuck;tinker.Value[1] = 1.5 + SilencedLuck;}
		case 2:{tinker.Value[0] = 0.72 + DamageLuck;tinker.Value[1] = 2.0 + SilencedLuck;}
		case 3:{tinker.Value[0] = 0.75 + DamageLuck;tinker.Value[1] = 3.0 + SilencedLuck;}
		case 4:{tinker.Value[0] = 0.79 + DamageLuck;tinker.Value[1] = 4.0 + SilencedLuck;}
	}
}

static void Tinker_MS_FireAspect(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_MS_FireAspect");
	tinker.Attrib[0] = 2;
	tinker.Attrib[1] = 397;
	tinker.Addition[1]=true;
	tinker.CustomMode[1]=1;
	float DamageLuck = (0.1 * (tinker.Luck[0]));
	float FireLuck = (0.5 * (tinker.Luck[1]));

	switch(rarity)
	{
		case 0:{tinker.Value[0] = 0.62 + DamageLuck;tinker.Value[1] = 1.0 + FireLuck;}
		case 1:{tinker.Value[0] = 0.66 + DamageLuck;tinker.Value[1] = 2.0 + FireLuck;}
		case 2:{tinker.Value[0] = 0.71 + DamageLuck;tinker.Value[1] = 3.0 + FireLuck;}
		case 3:{tinker.Value[0] = 0.73 + DamageLuck;tinker.Value[1] = 5.0 + FireLuck;}
		case 4:{tinker.Value[0] = 0.76 + DamageLuck;tinker.Value[1] = 8.0 + FireLuck;}
	}
}

static void Tinker_MS_CurseofGlassy(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_MS_CurseOfGlassy");
	tinker.Attrib[0] = 2;
	tinker.Attrib[1] = 425;
	tinker.Attrib[2] = 205;
	tinker.Attrib[3] = 206;
	tinker.CustomMode[1]=1;
	float DamageLuck = (0.1 * (tinker.Luck[0]));
	float SweepingLuck = (0.1 * (tinker.Luck[1]));
	float RangedDmgVulLuck = (0.05 * (1.0 + (-1.0*(tinker.Luck[2]))));
	float MeleeDmgVulLuck = (0.05 * (1.0 + (-1.0*(tinker.Luck[3]))));

	switch(rarity)
	{
		case 0:{tinker.Value[0] = 1.1 + DamageLuck;tinker.Value[1] = 1.25 + SweepingLuck;tinker.Value[2] = 1.05 + RangedDmgVulLuck;tinker.Value[3] = 1.05 + MeleeDmgVulLuck;}
		case 1:{tinker.Value[0] = 1.3 + DamageLuck;tinker.Value[1] = 1.3 + SweepingLuck;tinker.Value[2] = 1.075 + RangedDmgVulLuck;tinker.Value[3] = 1.075 + MeleeDmgVulLuck;}
		case 2:{tinker.Value[0] = 1.4 + DamageLuck;tinker.Value[1] = 1.35 + SweepingLuck;tinker.Value[2] = 1.1 + RangedDmgVulLuck;tinker.Value[3] = 1.1 + MeleeDmgVulLuck;}
		case 3:{tinker.Value[0] = 1.5 + DamageLuck;tinker.Value[1] = 1.4 + SweepingLuck;tinker.Value[2] = 1.25 + RangedDmgVulLuck;tinker.Value[3] = 1.25 + MeleeDmgVulLuck;}
		case 4:{tinker.Value[0] = 1.6 + DamageLuck;tinker.Value[1] = 1.45 + SweepingLuck;tinker.Value[2] = 1.35 + RangedDmgVulLuck;tinker.Value[3] = 1.35 + MeleeDmgVulLuck;}
	}
}

static void Tinker_SR_ExplosiveHeadshot(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_SR_ExplosiveHeadshot");
	tinker.Attrib[0] = Attrib_ExplosiveHeadshot;
	tinker.Attrib[1] = 2;
	tinker.Attrib[2] = 6;
	float EHSLuck = (0.25 * (tinker.Luck[0]));
	float DamageLuck = (0.1 * (tinker.Luck[1]));
	float AttackSpeedLuck = (0.1 * (tinker.Luck[2]));

	switch(rarity)
	{
		case 0:{tinker.Value[0] = 1.0 + EHSLuck;tinker.Value[1] = 0.6 + DamageLuck;tinker.Value[2] = 2.0 - AttackSpeedLuck;}
		case 1:{tinker.Value[0] = 1.25 + EHSLuck;tinker.Value[1] = 0.7 + DamageLuck;tinker.Value[2] = 1.75 - AttackSpeedLuck;}
		case 2:{tinker.Value[0] = 1.5 + EHSLuck;tinker.Value[1] = 0.8 + DamageLuck;tinker.Value[2] = 1.5 - AttackSpeedLuck;}
	}
}
static void Tinker_SR_KillerFocus(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_SR_KillerFocus");
	tinker.Attrib[0] = 41;
	tinker.Attrib[1] = 2;
	float ChargeRate = (0.2 * (tinker.Luck[0]));
	float DamageLuck = (0.2 * (tinker.Luck[1]));

	switch(rarity)
	{
		case 0:{tinker.Value[0] = 1.0 + ChargeRate;tinker.Value[1] = 0.7 + DamageLuck;}
		case 1:{tinker.Value[0] = 1.1 + ChargeRate;tinker.Value[1] = 0.75 + DamageLuck;}
		case 2:{tinker.Value[0] = 1.2 + ChargeRate;tinker.Value[1] = 0.85 + DamageLuck;}
	}
}

static void Tinker_SR_SuperCoolingChamber(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_SR_SuperCoolingChamber");
	tinker.Attrib[0] = Attrib_DamageBonusFullCharge;
	tinker.Attrib[1] = 6;
	tinker.Attrib[2] = 41;
	float FullChargeDMGLuck = (0.5 * (tinker.Luck[0]));
	float AttackSpeedLuck = (0.25 * (1.0 + (-1.0*(tinker.Luck[1]))));
	float ChargeRate = (0.35 * (1.0 + (-1.0*(tinker.Luck[2]))));

	switch(rarity)
	{
		case 0:{tinker.Value[0] = 1.3 + FullChargeDMGLuck;tinker.Value[1] = 1.4 + AttackSpeedLuck;tinker.Value[2] = 0.7 - ChargeRate;}
		case 1:{tinker.Value[0] = 1.5 + FullChargeDMGLuck;tinker.Value[1] = 1.5 + AttackSpeedLuck;tinker.Value[2] = 0.7 - ChargeRate;}
		case 2:{tinker.Value[0] = 1.7 + FullChargeDMGLuck;tinker.Value[1] = 1.6 + AttackSpeedLuck;tinker.Value[2] = 0.7 - ChargeRate;}
	}
}

static void Tinker_SR_DepletedUranium(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_SR_DepletedUranium");
	tinker.Attrib[0] = 2;
	tinker.Attrib[1] = 6;
	tinker.Attrib[2] = 41;
	float DamageLuck = (0.3 * (tinker.Luck[0]));
	float AttackSpeedLuck = (0.25 * (tinker.Luck[1]));

	switch(rarity)
	{
		case 0:{tinker.Value[0] = 1.25 + DamageLuck;tinker.Value[1] = 1.3 - AttackSpeedLuck;tinker.Value[2] = 0.0;}
		case 1:{tinker.Value[0] = 1.3 + DamageLuck;tinker.Value[1] = 1.25 - AttackSpeedLuck;tinker.Value[2] = 0.0;}
		case 2:{tinker.Value[0] = 1.4 + DamageLuck;tinker.Value[1] = 1.15 - AttackSpeedLuck;tinker.Value[2] = 0.0;}
	}
}

static void Tinker_SR_HighSpeedFeedMechanism(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_SR_HighSpeedFeedMechanism");
	tinker.Attrib[0] = 2;
	tinker.Attrib[1] = 6;
	float DamageLuck = (0.325 * (1.0 + (-1.0*(tinker.Luck[0]))));
	float AttackSpeedLuck = (0.25 * (tinker.Luck[1]));

	switch(rarity)
	{
		case 0:{tinker.Value[0] = 0.9 - DamageLuck;tinker.Value[1] = 0.9 - AttackSpeedLuck;}
		case 1:{tinker.Value[0] = 0.95 - DamageLuck;tinker.Value[1] = 0.8 - AttackSpeedLuck;}
		case 2:{tinker.Value[0] = 1.0 - DamageLuck;tinker.Value[1] = 0.75 - AttackSpeedLuck;}
	}
}

static void Tinker_SR_HollowPointBullets(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_SR_HollowPointBullets");
	tinker.Attrib[0] = 2;
	tinker.Attrib[1] = 390;
	float DamageLuck = (0.25 * (tinker.Luck[0]));
	float HeadDMGLuck = (0.3 * (tinker.Luck[1]));

	switch(rarity)
	{
		case 0:{tinker.Value[0] = 0.75 + DamageLuck;tinker.Value[1] = 1.35 + HeadDMGLuck;}
		case 1:{tinker.Value[0] = 0.7 + DamageLuck;tinker.Value[1] = 1.5 + HeadDMGLuck;}
		case 2:{tinker.Value[0] = 0.675 + DamageLuck;tinker.Value[1] = 1.672 + HeadDMGLuck;}
	}
}

static void Tinker_FT_FaceMelter(int rarity, TinkerEnum tinker)
{
	strcopy(tinker.Name, sizeof(tinker.Name), "Tinker_FT_FaceMelter");
	tinker.Attrib[0] = 2;
	tinker.Attrib[1] = 173;
	float DamageLuck = (0.25 * (tinker.Luck[0]));
	float AmmoPerSecLuck = (0.3 * (1.0 + (-1.0 * (tinker.Luck[0]))));
	
	switch (rarity) {
		case 0: {
			tinker.Value[0] = 1.2 + DamageLuck;
			tinker.Value[1] = 1.5 + AmmoPerSecLuck;
		}
		case 1: {
			tinker.Value[0] = 1.35 + DamageLuck;
			tinker.Value[1] = 1.75 + AmmoPerSecLuck;
		}
		case 2: {
			tinker.Value[0] = 1.5 + DamageLuck;
			tinker.Value[1] = 2.0 + AmmoPerSecLuck;
		}
	}
}