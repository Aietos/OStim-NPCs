Scriptname ONpcMain extends Quest

Actor[] ActorsMale
Actor[] ActorsFemale

bool Scanning

int property ActiveScenes auto

float property ScanFreq auto
float property ScanRadius auto

int property WeightThreesome auto
int property WeightMF auto
int property WeightFF auto
int property WeightMM auto
int property MaxScenes auto
int property MinRelation auto
int property MinNight auto
int property MaxNight auto
int property MaxEnemyScenesPerNight auto
int property MaxFollowerScenesPerNight auto

bool property ONpcDisabled auto

bool property AllowActiveFollowers auto
bool property ActiveFollowersEngageOtherNPCs auto
bool property AllowElderRace auto
bool property AllowPlayerThreesomes auto
bool property AllowCommonEnemies auto
bool property StopWhenFound auto
bool property TravelToLocation auto
bool property EnemiesTravelToLocation auto

bool property EnableFurniture auto
bool property FurnitureOnlyBeds auto
bool property EnemiesIgnoreScenesStartInRules auto

int property ScenesStartIn auto
int property Anywhere = 0 AutoReadOnly
int property AnyFurniture = 1 AutoReadOnly
int property BedsOnly = 2 AutoReadOnly

string[] Property ScenesStartInStrings Auto

bool property FollowersNoScenesDungeons auto
bool property NoScenesInTowns auto
bool property NoScenesInGuilds auto
bool property NoScenesInInns auto

bool property SettingCellChange auto

GlobalVariable property ONpcIsNight auto
GlobalVariable property GameHour auto

Actor property PlayerRef auto

Message property InviteMessage auto

AssociationType property ParentChild auto
AssociationType property Siblings auto
AssociationType property Cousins auto
AssociationType property Courting auto
AssociationType property Spouse auto

Faction property BanditFaction auto
Faction property ForswornFaction auto
Faction property NecromancerFaction auto
Faction property WarlockFaction auto
Faction property VampireFaction auto
Faction property VampireThrallFaction auto
Faction property Dlc2CultistFaction auto
Faction property BardSingerFaction auto
Faction property BardJobFaction auto
Faction property FollowerFaction auto

Keyword property LocTypeCity auto
Keyword property LocTypeTown auto
Keyword property LocTypeSettlement auto
Keyword property LocTypeInn auto
Keyword property LocTypeGuild auto
Keyword property LocTypeDungeon auto

Spell property CellChangeSpell auto

Race property ElderRace auto

OSexIntegrationMain property OStim auto

Quest property ONpcSubthreadQuest auto

int property NPCsInScene auto
int property FurnituresInUse auto
int property NPCsHadSexThisNight auto

bool property JArraysCreated auto

bool ORomanceInstalled
bool OPrivacyInstalled

int property FollowerScenesThisNight auto
int FollowerChanceLastHourChecked
int FollowerOtherNPCsLastHourChecked

int property EnemyScenesThisNight auto
bool property CurrentLocationEnemyScene auto
Location CurrentPlayerLocation

Faction OPFollowFaction

Package OPFollowPackage
Package OPApproachFGF1
Package OPApproachFGF2
Package OPApproachFGF1Follower
Package OPApproachElisif
Package OPApproachF1HouseCarls
Package OPApproachCoralyn
Package OPCoraApproachFollower


; ███████╗██╗   ██╗███████╗███╗   ██╗████████╗███████╗
; ██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝██╔════╝
; █████╗  ██║   ██║█████╗  ██╔██╗ ██║   ██║   ███████╗
; ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║   ╚════██║
; ███████╗ ╚████╔╝ ███████╗██║ ╚████║   ██║   ███████║
; ╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝


Event OnInit()
	OStim = OUtils.GetOStim()
	ONpcSubthreadQuest = Game.GetFormFromFile(0x000814, "OStimNPCs.esp") as Quest

	OnLoad()
EndEvent


Function OnLoad()
	Scanning = false
	ActiveScenes = 0

	ScenesStartInStrings = new string[3]
	ScenesStartInStrings[0] = "Anywhere"
	ScenesStartInStrings[1] = "Any Furniture"
	ScenesStartInStrings[2] = "Beds Only"

	ORomanceInstalled = Game.IsPluginInstalled("ORomance.esp")
	OPrivacyInstalled = Game.IsPluginInstalled("OPrivacy.esp")

	if (OPrivacyInstalled)
		OPFollowFaction = Game.GetFormFromFile(0x00015C34, "OPrivacy.esp") as Faction

		OPFollowPackage = GetOPrivacyPackage(0x000012C3)
		OPApproachFGF1 = GetOPrivacyPackage(0x00131C1E)
		OPApproachFGF2 = GetOPrivacyPackage(0x0010E4C1)
		OPApproachFGF1Follower = GetOPrivacyPackage(0x00131C1D)
		OPApproachElisif = GetOPrivacyPackage(0x001A1365)
		OPApproachF1HouseCarls = GetOPrivacyPackage(0x001C9B8D)
		OPApproachCoralyn = GetOPrivacyPackage(0x004297FF)
		OPCoraApproachFollower = GetOPrivacyPackage(0x00442D10)
	endif

	if !PlayerRef.HasSpell(CellChangeSpell)
		PlayerRef.AddSpell(CellChangeSpell, false)
	endif

	if !ONpcDisabled
		RestartScanning()
	endif
EndFunction


Event OnUpdate()
	if !ONpcDisabled

		bool isNightTime = IsNight()

		if isNightTime && !JArraysCreated
			CreateJArrays()
		endif
	
		if !Scanning && isNightTime && !PlayerRef.IsInCombat() && ActiveScenes < MaxScenes && LocationIsValid()
			ONpcSubthread subthreadToUse = GetUnusedSubthread()

			if subthreadToUse
				Scan(subthreadToUse)
			endif
		endif

		if isNightTime
			RegisterForSingleUpdate(ScanFreq)
		else
			ResetNightVariables(0, true)
			RegisterForSingleUpdateGameTime(GetTimeUntilNight())
		endif
	endif
EndEvent


Event OnUpdateGameTime()
	PrintToConsole("Night has fallen...")

	ResetNightVariables(1, true)

	RegisterForSingleUpdate(ScanFreq)
EndEvent


; ███████╗ ██████╗ █████╗ ███╗   ██╗███╗   ██╗██╗███╗   ██╗ ██████╗ 
; ██╔════╝██╔════╝██╔══██╗████╗  ██║████╗  ██║██║████╗  ██║██╔════╝ 
; ███████╗██║     ███████║██╔██╗ ██║██╔██╗ ██║██║██╔██╗ ██║██║  ███╗
; ╚════██║██║     ██╔══██║██║╚██╗██║██║╚██╗██║██║██║╚██╗██║██║   ██║
; ███████║╚██████╗██║  ██║██║ ╚████║██║ ╚████║██║██║ ╚████║╚██████╔╝
; ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═══╝ ╚═════╝ 


Function Scan(ONpcSubthread SubthreadToUse)
	Scanning = true

	GetSurroundingActors()

	if !ActorsFemale.length && !ActorsMale.length
		Scanning = false
		return
	endif

	Actor Dom
	Actor Sub
	Actor Third

	string SexType = GetSexType()

	if SexType == "mf" || SexType == "threesome"
		if !ActorsMale.length || !ActorsFemale.length
			Scanning = false
			return
		endif

		Dom = GetRandomActor(true)

		if Dom
			Sub = GetPartnerForActor(Dom, ActorsFemale)
		endif
	elseif SexType == "ff"
		if ActorsFemale.length < 2
			Scanning = false
			return
		endif

		Dom = GetRandomActor(false)

		if Dom
			Sub = GetPartnerForActor(Dom, ActorsFemale)
		endif
	else
		if ActorsMale.length < 2
			Scanning = false
			return
		endif

		Dom = GetRandomActor(true)

		if Dom
			Sub = GetPartnerForActor(Dom, ActorsMale)
		endif
	endif

	if Dom.Is3DLoaded() && Sub.Is3DLoaded() && (!Third || Third.Is3DLoaded())
		bool alternativeBedSearch

		; If either actor is sleeping, we use an alternate bed search
		; Since the normal one will not find the bed they're sleeping on
		; We then use the bed the actor was sleeping on to prevent them from clipping into the bed
		if Dom.GetSleepState() != 0 || Sub.GetSleepState() != 0
			alternativeBedSearch = true
		endif

		ObjectReference furnitureRef

		if alternativeBedSearch
			furnitureRef = FindEmptyBed(Dom)

			if !furnitureRef
				Scanning = false
				return
			endif
		elseif EnableFurniture
			furnitureRef = FindEmptyFurniture(Dom)

			if (ScenesStartIn == AnyFurniture || ScenesStartIn == BedsOnly) && !furnitureRef
				if IsEnemy(Dom) && IsEnemy(Sub)
					if !EnemiesIgnoreScenesStartInRules
						Scanning = False
						return
					endif
				else
					Scanning = false
					return
				endif
			endif
		endif

		ActiveScenes += 1

		JArray.addForm(NPCsInScene, Dom)
		JArray.addForm(NPCsInScene, Sub)

		if Third
			JArray.addForm(NPCsInScene, third)
		endif

		SubthreadToUse.SetupScene(Dom, Sub, furnitureRef, alternativeBedSearch, None)
	endif

	Scanning = false
EndFunction


Function GetSurroundingActors()
	Cell currentCell = PlayerRef.GetParentCell()

	ActorsFemale = PapyrusUtil.ActorArray(50)
	ActorsMale = PapyrusUtil.ActorArray(50)

	if currentCell
		int actorRefsAmountCell = currentCell.GetNumRefs(43)

		if actorRefsAmountCell > 2
			Actor currentActor

			int femaleIndex = 0
			int maleIndex = 0

			While actorRefsAmountCell
				actorRefsAmountCell -= 1
				currentActor = currentCell.GetNthRef(actorRefsAmountCell, 43) as Actor

				if ActorIsValid(currentActor)
					if OStim.AppearsFemale(currentActor)
						ActorsFemale[femaleIndex] = currentActor
						femaleIndex += 1
					else
						ActorsMale[maleIndex] = currentActor
						maleIndex += 1
					endif
				endif
			EndWhile
		endif
	endif

	ActorsFemale = PapyrusUtil.RemoveActor(ActorsFemale, none)
	ActorsMale = PapyrusUtil.RemoveActor(ActorsMale, none)
EndFunction


String Function GetSexType()
	int weighttotal = weightthreesome + weightmf + weightff + weightmm
	int randomnum = Utility.RandomInt(0, weighttotal)

	if randomnum < weightthreesome
		return "threesome"
	elseif (randomnum >= weightthreesome) && (randomnum <= (weightthreesome + weightmf))
		return "mf"
	elseif (randomnum > (weightthreesome + weightmf)) && (randomnum <= (weightthreesome + weightmf + weightff))
		return "ff"
	else
		return "mm"
	endif
EndFunction


Actor Function GetRandomActor(bool isMale)
	Actor randomActor

	if isMale
		randomActor = ActorsMale[Utility.RandomInt(0, ActorsMale.length - 1)]

		ActorsMale = PapyrusUtil.RemoveActor(ActorsMale, randomActor)
	else
		randomActor = ActorsFemale[Utility.RandomInt(0, ActorsFemale.length - 1)]

		ActorsFemale = PapyrusUtil.RemoveActor(ActorsFemale, randomActor)
	endif

	return randomActor
EndFunction


Actor Function GetPartnerForActor(Actor act, Actor[] ActorsArrayToUse)
	int i = ActorsArrayToUse.Length

	Actor currentActor = None
	Actor currentPartner = None

	float actorDistance = 0

	bool isValid

	bool isActCourting = act.HasAssociation(Courting)
	bool isActMarried = act.HasAssociation(Spouse)

	int hour = Math.Floor(CurrentHour())

	; if player has more than 2 followers
	; this caching allows us to try to matchmake all followers in the same hour once
	; Subsequent checks in the same hour, we won't try to matchmake followers until the hour changes
	bool checkedFollowerOnFollower = FollowerChanceLastHourChecked == hour
	bool checkedFollowerOnNpc = FollowerOtherNPCsLastHourChecked == hour

	int followerSceneChance = 20
	bool multipleFollowers = false

	bool actIsFollower = IsFollower(act)
	bool currentActIsFollower

	bool followerOnNpcScene = WillBeFollowerOnNpcScene()

	while i > 0
		i -= 1
		currentActor = ActorsArrayToUse[i]

		currentActIsFollower = IsFollower(currentActor)

		isValid = true

		if PotentialPartnerInvalid(act, currentActor, isActCourting, isActMarried)
			isValid = false
		else
			if act.HasAssociation(Spouse, currentActor) || act.HasAssociation(Courting, currentActor)
				; if they're married / courting, return this partner immediately
				return currentActor
			elseif AllowCommonEnemies && isEnemy(act) && isEnemy(currentActor) && CurrentLocationEnemyScene
				isValid = True
			; this check has to be here because the above conditions might be true, but relationship rank might not match their association type!
			elseif currentActor.GetRelationshipRank(act) < MinRelation
				isValid = False
			else
				isValid = True
			endif

			; special checks for followers
			if (actIsFollower || currentActIsFollower) && (ActiveFollowersEngageOtherNPCs || AllowActiveFollowers)
				if actIsFollower && currentActIsFollower && !followerOnNpcScene && !checkedFollowerOnFollower
					FollowerChanceLastHourChecked = hour
	
					; reduce chance for each follower
					; otherwise with many followers, ChanceRoll always returns true
					if multipleFollowers
						followerSceneChance = 10
					endif
	
					; if they're both player followers, return this partner immediately
					if OUtils.ChanceRoll(followerSceneChance)
						return currentActor
					endif
	
					multipleFollowers = true
					isValid = False
				elseif ((actIsFollower && !currentActIsFollower) || (!actIsFollower && currentActIsFollower)) && followerOnNpcScene && !checkedFollowerOnNpc
					FollowerOtherNPCsLastHourChecked = hour

					if OUtils.ChanceRoll(10)
						return currentActor
					endif

					isValid = False
				else
					isValid = false
				endif
			endif
		endif

		; If partner is valid, we will check how far away the partner is
		; We prioritise the potential partners that are closest to the dom actor so the scenes take less time to setup
		; This also prevents NPCs from teleporting across large cells, making the visual experience much better
		if isValid
			; prioritise closest partner
			actorDistance = act.GetDistance(currentActor)

			if !currentPartner || actorDistance < act.GetDistance(currentPartner)
				if actorDistance < 763 ; if distance is 10 meters or less, that's close enough, return this actor
					return currentActor
				endif

				currentPartner = currentActor
			endif
		endif
	endwhile

	return currentPartner
EndFunction


ObjectReference Function FindEmptyFurniture(Actor Dom)
	ObjectReference[] Furnitures = OFurniture.FindFurniture(2, Dom, (OStim.FurnitureSearchDistance + 15) * 100.0, 96)

	int i = Furnitures.Length

	bool useFurniture

	ObjectReference currentFurniture

	While i > 0
		i -= 1

		currentFurniture = Furnitures[i]

		; Check if furniture is already being used by another OStim scene
		; Unfortunately, we have to do it our own way with JArrays since we can't reliable mark furniture
		; as being in use with Skyrim's native functions
		if JArray.FindForm(FurnituresInUse, currentFurniture) == -1
			useFurniture = true

			; If scenes are set to only start in beds, then we won't return furniture that aren't beds
			if FurnitureOnlyBeds || ScenesStartIn == BedsOnly
				if !IsFurnitureBed(currentFurniture)
					useFurniture = false
				endif
			endif

			if useFurniture
				JArray.addForm(FurnituresInUse, currentFurniture)
				return currentFurniture
			endif
		endif
	EndWhile

	return none
EndFunction


ObjectReference Function FindEmptyBed(Actor Dom)
	ObjectReference[] Beds = OSANative.FindBed(Dom, (OStim.FurnitureSearchDistance + 15) * 100.0, 96.0)

	Int i = Beds.Length

	While i > 0
		i -= 1

		ObjectReference Bed = Beds[i]

		if JArray.FindForm(FurnituresInUse, Bed) == -1
			return Bed
		endif
	EndWhile

	Return None
EndFunction


;  █████╗  ██████╗████████╗ ██████╗ ██████╗     ██╗   ██╗████████╗██╗██╗     ███████╗
; ██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗    ██║   ██║╚══██╔══╝██║██║     ██╔════╝
; ███████║██║        ██║   ██║   ██║██████╔╝    ██║   ██║   ██║   ██║██║     ███████╗
; ██╔══██║██║        ██║   ██║   ██║██╔══██╗    ██║   ██║   ██║   ██║██║     ╚════██║
; ██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║    ╚██████╔╝   ██║   ██║███████╗███████║
; ╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝     ╚═════╝    ╚═╝   ╚═╝╚══════╝╚══════╝


Bool Function ActorIsValid(Actor Act)
	if IsInvalidNpc(Act) || IsPlayerORomancePartner(Act) || ActorIsInCombatState(Act) || Act.GetCurrentScene() != None || !Act.Is3DLoaded() || Act.IsInDialogueWithPlayer() || OStim.IsActorActive(Act) || IsInJArrays(Act) || ActorHasOPrivacyPackage(Act)
		return false
	endif

	return true
EndFunction


Bool Function ActorIsInCombatState(Actor Act)
	return Act.GetCombatState() != 0 || Act.IsBleedingOut() || Act.IsWeaponDrawn() || Act.IsUnconscious() || Act.IsInKillMove() || Act.IsArrested() || Act.IsCommandedActor() || Act.IsOnMount()
EndFunction


Bool Function IsInvalidNpc(Actor Act)
	return !Act || Act == PlayerRef || !Act.HasKeywordString("ActorTypeNPC") || Act.IsDead() || Act.isDisabled() || Act.IsChild() || Act.isGhost() || IsInvalidNpcUserPreferences(Act)
EndFunction


Bool Function IsFollower(Actor Act)
	return Act.IsPlayerTeamMate() || Act.IsInFaction(FollowerFaction)
EndFunction


Bool Function IsInvalidNpcUserPreferences(Actor Act)
	if Act.GetRace() == ElderRace && !AllowElderRace
		return true
	endif

	if !AllowActiveFollowers && !ActiveFollowersEngageOtherNPCs && IsFollower(Act)
		return true
	endif

	if (AllowActiveFollowers || ActiveFollowersEngageOtherNPCs) && IsFollower(Act)
		if FollowerScenesThisNight >= MaxFollowerScenesPerNight
			return true
		endif

		if FollowersNoScenesDungeons && IsDungeon(PlayerRef.GetCurrentLocation())
			return true
		endif
	endif

	if !AllowCommonEnemies && isEnemy(Act)
		return true
	endif

	if AllowCommonEnemies && isEnemy(Act) && EnemyScenesThisNight >= MaxEnemyScenesPerNight
		return true
	endif

	return false
EndFunction


Bool Function IsPlayerORomancePartner(Actor Act)
	if !ORomanceInstalled
		return false 
	endif 

	return StorageUtil.GetIntValue(Act, "or_k_part", -1) == 1
EndFunction


Bool Function ActorHasOPrivacyPackage(Actor Act)
	if OPrivacyInstalled
		if Act.IsInFaction(OPFollowFaction)
			return true
		endif

		bool approachEnabled = (Game.GetFormFromFile(0x001646B2, "OPrivacy.esp") as GlobalVariable).GetValueInt() == 1

		if approachEnabled
			Package currentActorPackage = Act.GetCurrentPackage()

			return currentActorPackage == OPFollowPackage || currentActorPackage == OPApproachFGF1 || currentActorPackage == OPApproachFGF2 || currentActorPackage == OPApproachFGF1Follower || currentActorPackage == OPApproachElisif || currentActorPackage == OPApproachF1HouseCarls || currentActorPackage == OPApproachCoralyn || currentActorPackage == OPCoraApproachFollower
		endif
	endif

	return false
EndFunction


Bool Function IsInJArrays(Actor Act)
	return JArray.FindForm(NPCsInScene, Act) != -1 || JArray.FindForm(NPCsHadSexThisNight, Act) != -1
EndFunction


Bool Function IsBard(Actor Act)
	return Act.IsInFaction(BardSingerFaction) || Act.IsInFaction(BardJobFaction)
EndFunction


Bool Function isEnemy(Actor Act)
	return Act.IsInFaction(BanditFaction) || Act.IsInFaction(ForswornFaction) || Act.IsInFaction(NecromancerFaction) || Act.IsInFaction(WarlockFaction) || Act.IsInFaction(VampireFaction) || Act.IsInFaction(VampirethrallFaction) || Act.IsInFaction(Dlc2CultistFaction)
EndFunction


Bool Function InvitePlayer()
	int button = invitemessage.show()
	if button == 0
		return true
	endif
	return false
EndFunction


Bool Function PotentialPartnerInvalid(Actor Act, Actor PotentialPartner, bool isActCourting, bool isActMarried)
	if PotentialPartner.HasAssociation(ParentChild, act) || PotentialPartner.HasAssociation(Siblings, act) || PotentialPartner.HasAssociation(Cousins, act)
		return true
	endif

	if isActCourting && !act.HasAssociation(Courting, PotentialPartner)
		return true
	endif

	if isActMarried && !act.HasAssociation(Spouse, PotentialPartner)
		return true
	endif

	if (isEnemy(act) && !isEnemy(PotentialPartner)) || (!isEnemy(act) && isEnemy(PotentialPartner))
		return true
	endif

	return false
EndFunction


Bool Function WillBeFollowerOnNpcScene()
	if AllowActiveFollowers && !ActiveFollowersEngageOtherNPCs
		return false
	endif

	if !AllowActiveFollowers && ActiveFollowersEngageOtherNPCs
		return true
	endif

	return OUtils.ChanceRoll(50)
EndFunction


; ██╗      ██████╗  ██████╗ █████╗ ████████╗██╗ ██████╗ ███╗   ██╗    ██╗   ██╗████████╗██╗██╗     ███████╗
; ██║     ██╔═══██╗██╔════╝██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║    ██║   ██║╚══██╔══╝██║██║     ██╔════╝
; ██║     ██║   ██║██║     ███████║   ██║   ██║██║   ██║██╔██╗ ██║    ██║   ██║   ██║   ██║██║     ███████╗
; ██║     ██║   ██║██║     ██╔══██║   ██║   ██║██║   ██║██║╚██╗██║    ██║   ██║   ██║   ██║██║     ╚════██║
; ███████╗╚██████╔╝╚██████╗██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║    ╚██████╔╝   ██║   ██║███████╗███████║
; ╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝     ╚═════╝    ╚═╝   ╚═╝╚══════╝╚══════╝


Bool Function IsSettlement(Location Loc)
	return Loc.HasKeyword(LocTypeTown) || Loc.HasKeyword(LocTypeCity) || Loc.HasKeyword(LocTypeSettlement)
EndFunction


Bool Function IsInn(Location Loc)
	return Loc.HasKeyword(LocTypeInn)
EndFunction


Bool Function IsGuild(Location Loc)
	return Loc.HasKeyword(LocTypeGuild)
EndFunction


Bool Function IsDungeon(Location Loc)
	return Loc.HasKeyword(LocTypeDungeon)
EndFunction


Bool Function LocationIsValid()
	Location playerLocation = PlayerRef.GetCurrentLocation()

	if !playerLocation
		return true
	endif

	if NoScenesInTowns && IsSettlement(playerLocation)
		return false
	endif

	if NoScenesInGuilds && IsGuild(playerLocation)
		return false
	endif

	if NoScenesInInns && IsInn(playerLocation)
		return false
	endif

	return true
EndFunction


; ███╗   ██╗██╗ ██████╗ ██╗  ██╗████████╗    ██╗   ██╗████████╗██╗██╗     ███████╗
; ████╗  ██║██║██╔════╝ ██║  ██║╚══██╔══╝    ██║   ██║╚══██╔══╝██║██║     ██╔════╝
; ██╔██╗ ██║██║██║  ███╗███████║   ██║       ██║   ██║   ██║   ██║██║     ███████╗
; ██║╚██╗██║██║██║   ██║██╔══██║   ██║       ██║   ██║   ██║   ██║██║     ╚════██║
; ██║ ╚████║██║╚██████╔╝██║  ██║   ██║       ╚██████╔╝   ██║   ██║███████╗███████║
; ╚═╝  ╚═══╝╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝        ╚═════╝    ╚═╝   ╚═╝╚══════╝╚══════╝


Bool Function IsNight()
	float hour = CurrentHour()

	return hour <= MaxNight || hour >= MinNight
EndFunction


Float Function CurrentHour()
	return GameHour.GetValue()
EndFunction


Float Function GetTimeUntilNight()
	if IsNight()
		return 0.05
	else 
		float ret = (MinNight - CurrentHour())
		if ret < 0.1
			ret = 0.05
		endif 
		return ret
	endif
EndFunction


;  ██████╗ ███████╗███╗   ██╗███████╗██████╗  █████╗ ██╗         ██╗   ██╗████████╗██╗██╗     ███████╗
; ██╔════╝ ██╔════╝████╗  ██║██╔════╝██╔══██╗██╔══██╗██║         ██║   ██║╚══██╔══╝██║██║     ██╔════╝
; ██║  ███╗█████╗  ██╔██╗ ██║█████╗  ██████╔╝███████║██║         ██║   ██║   ██║   ██║██║     ███████╗
; ██║   ██║██╔══╝  ██║╚██╗██║██╔══╝  ██╔══██╗██╔══██║██║         ██║   ██║   ██║   ██║██║     ╚════██║
; ╚██████╔╝███████╗██║ ╚████║███████╗██║  ██║██║  ██║███████╗    ╚██████╔╝   ██║   ██║███████╗███████║
;  ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝     ╚═════╝    ╚═╝   ╚═╝╚══════╝╚══════╝


Function PrintToConsole(String In) Global
	MiscUtil.PrintConsole("OStim NPCs: " + In)
EndFunction


Function UpdateCurrentPlayerLocation(Location newLocation)
	if newLocation == None
		CurrentLocationEnemyScene = False
		CurrentPlayerLocation = None
	elseif CurrentPlayerLocation != newLocation
		; RNG on top of RNG because one RNG isn't enough
		int locationEnemySceneChance = Utility.RandomInt(30, 100)
		CurrentLocationEnemyScene = Utility.RandomInt(0, 99) < locationEnemySceneChance
		CurrentPlayerLocation = newLocation
	endif
EndFunction


Function RestartScanning()
	if isNight()
		ResetNightVariables(1, false)
		RegisterForSingleUpdate(ScanFreq)
	else
		RegisterForSingleUpdateGameTime(GetTimeUntilNight())
	endif
EndFunction


ONpcSubthread Function GetUnusedSubthread()
	int i = 0
	int max = 4

	while i < max 
		ONpcSubthread thread = ONpcSubthreadQuest.GetNthAlias(i) as ONpcSubthread

		if thread && !thread.IsThreadInUse()
			return thread
		endif

		i += 1
	endwhile
EndFunction


Bool Function IsFurnitureBed(ObjectReference FurnitureToCheck)
	String furnitureType = OFurniture.GetFurnitureType(FurnitureToCheck)

	return furnitureType == "bedroll" || furnitureType == "singlebed" || furnitureType == "doublebed"
EndFunction


Function SetIsNightGlobal(float value)
	ONpcIsNight.SetValue(value)
EndFunction


Int Function GetNightGlobal()
	return ONpcIsNight.GetValue() as int
EndFunction


Int Function GetFollowerSceneChance()
	float hour = CurrentHour()

	int totalNightHours = (24 - MinNight) + MaxNight

	float hoursSinceNightStarted = 0.0

	if hour >= 0 && hour <= MaxNight
		hoursSinceNightStarted = (24 - MinNight) + hour
	else
		hoursSinceNightStarted = hour - MinNight
	endif

	; as night progresses, the chance of followers engaging in OStim scenes increases
	return Math.Ceiling((hoursSinceNightStarted / totalNightHours) * 100)

EndFunction


Function CreateJArrays()
	NPCsInScene = JArray.object()
	JValue.retain(NPCsInScene, "npcsInScene")

	FurnituresInUse = JArray.object()
	JValue.retain(FurnituresInUse, "furnituresInUse")

	NPCsHadSexThisNight = JArray.object()
	JValue.retain(NPCsHadSexThisNight, "npcsHadSexThisNight")

	JArraysCreated = true
EndFunction


Function ClearJArrays()
	JArray.Clear(NPCsInScene)
	JArray.Clear(NPCsHadSexThisNight)
	JArray.Clear(FurnituresInUse)

	JValue.release(NPCsInScene)
	JValue.release(NPCsHadSexThisNight)
	JValue.release(FurnituresInUse)

	JArraysCreated = false
EndFunction


Function ResetNightVariables(int NightValue, bool ResetJArrays)
	FollowerChanceLastHourChecked = -1
	FollowerOtherNPCsLastHourChecked = -1
	EnemyScenesThisNight = 0
	FollowerScenesThisNight = 0

	SetIsNightGlobal(NightValue)

	if JArraysCreated && ResetJArrays
		ClearJArrays()
	endif
EndFunction


Package Function GetOPrivacyPackage(int PackageID)
	return Game.GetFormFromFile(PackageID, "OPrivacy.esp") as Package
EndFunction
