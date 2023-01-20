Scriptname ONpcMain extends Quest

Actor[] Actors

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

bool property ONpcDisabled auto

bool property AllowActiveFollowers auto
bool property AllowElderRace auto
bool property AllowPlayerThreesomes auto
bool property AllowCommonEnemies auto
bool property StopWhenFound auto
bool property TravelToLocation auto

bool property FurnitureOnlyBeds auto
bool property OnlyAllowScenesInBeds auto

bool property FollowersNoScenesDungeons auto
bool property NoScenesInTowns auto
bool property NoScenesInGuilds auto
bool property NoScenesInInns auto


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

Keyword property LocTypeCity auto
Keyword property LocTypeTown auto
Keyword property LocTypeSettlement auto
Keyword property LocTypeInn auto
Keyword property LocTypeGuild auto
Keyword property LocTypeDungeon auto

Race property ElderRace auto

OSexIntegrationMain property OStim auto

Quest property ONpcSubthreadQuest auto

int property NPCsInScene auto
int property FurnituresInUse auto
int property NPCsHadSexThisNight auto

bool OPrivacyInstalled

Faction OPFollowFaction

Package OPFollowPackage
Package OPApproachFGF1
Package OPApproachFGF2
Package OPApproachFGF1Follower
Package OPApproachElisif
Package OPApproachF1HouseCarls
Package OPApproachCoralyn
Package OPCoraApproachFollower


Event OnInit()
	OStim = OUtils.GetOStim()
	ONpcSubthreadQuest = Game.GetFormFromFile(0x000814, "ONPCs.esp") as Quest

	NPCsInScene = JArray.object()
	JValue.retain(NPCsInScene, "npcsInScene")

	FurnituresInUse = JArray.object()
	JValue.retain(FurnituresInUse, "furnituresInUse")

	NPCsHadSexThisNight = JArray.object()
	JValue.retain(NPCsHadSexThisNight, "npcsHadSexThisNight")

	OnLoad()
EndEvent


Function OnLoad()
	Scanning = false
	ActiveScenes = 0

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

	if !ONpcDisabled
		RegisterForSingleUpdate(scanfreq)
	endif
EndFunction


Event OnUpdate()
	if !ONpcDisabled

		bool isNightTime = IsNight()
	
		if !Scanning && isNightTime && !PlayerRef.IsInCombat() && ActiveScenes < MaxScenes && LocationIsValid()
			PrintToConsole("scanning!")

			ONpcSubthread subthreadToUse = GetUnusedSubthread()
			PrintToConsole(subthreadToUse)

			if subthreadToUse
				Scan(subthreadToUse)
			endif
		endif

		PrintToConsole("Scan is over! Checking for night...")

		if isNightTime
			PrintToConsole("Is night!!")
			RegisterForSingleUpdate(scanfreq)
		else
			PrintToConsole("Is not night...")
			RegisterForSingleUpdateGameTime(GetTimeUntilNight())
		endif
	endif
EndEvent


Event OnUpdateGameTime()
	PrintToConsole("Night has fallen....")
	JArray.Clear(NPCsHadSexThisNight)
	RegisterForSingleUpdate(scanfreq)
EndEvent


Function Scan(ONpcSubthread SubthreadToUse)
	Scanning = true
	PrintToConsole("now scanning!")

	PrintToConsole("Scan radius is " + ScanRadius)
	GetSurroundingActors()
	PrintToConsole("Actors length is " + Actors.length)

	if !Actors.length
		return
	endif

	Actor Dom
	Actor Sub
	Actor Third

	string SexType = GetSexType()

	PrintToConsole("Sex type is " + SexType)

	if SexType == "mf" || SexType == "threesome"
		if !ActorsMale.length || !ActorsFemale.length
			return
		endif

		Dom = GetRandomActor(true)

		if Dom
			Sub = GetPartnerForActor(Dom, ActorsFemale)
		endif
	elseif SexType == "ff"
		if ActorsFemale.length < 2
			return
		endif

		Dom = GetRandomActor(false)

		if Dom
			Sub = GetPartnerForActor(Dom, ActorsFemale)
		endif
	else
		if ActorsMale.length < 2
			return
		endif

		Dom = GetRandomActor(true)

		if Dom
			Sub = GetPartnerForActor(Dom, ActorsMale)
		endif
	endif

	PrintToConsole("Dom Actor is " + Dom.GetActorBase().GetName())
	PrintToConsole("Sub Actor is " + Sub.GetActorBase().GetName())

	PrintToConsole("Checking if Actors are loaded")

	if Dom.Is3DLoaded() && Sub.Is3DLoaded() && (!Third || Third.Is3DLoaded())
		PrintToConsole("starting scene setup")

		ObjectReference furnitureRef

		if OStim.useFurniture
			furnitureRef = FindEmptyFurniture(Dom)

			if OnlyAllowScenesInBeds && !furnitureRef
				Scanning = false
				return
			endif
		endif

		ActiveScenes += 1

		JArray.addForm(NPCsInScene, Dom)
		JArray.addForm(NPCsInScene, Sub)

		if Third
			JArray.addForm(NPCsInScene, third)
		endif

		SubthreadToUse.SetupScene(Dom, Sub, furnitureRef, None)
		Scanning = false
	else
		PrintToConsole("They were not loaded")
		Scanning = false
	endif

	Scanning = false
EndFunction


Function GetSurroundingActors()
	Actors = MiscUtil.ScanCellNpcs(centeron = PlayerRef, radius = ScanRadius)

	int i = Actors.length

	if !i
		return
	endif

	ActorsFemale = PapyrusUtil.ActorArray(50)
	ActorsMale = PapyrusUtil.ActorArray(50)

	int femaleIndex = 0
	int maleIndex = 0

	Actor currentActor

	while i > 0
		i -= 1

		currentActor = Actors[i]

		if ActorIsValid(currentActor)
			if currentActor.GetActorBase().GetSex() == 1
				ActorsFemale[femaleIndex] = currentActor
				femaleIndex += 1
			else
				ActorsMale[maleIndex] = currentActor
				maleIndex += 1
			endif
		endif
	endwhile

	ActorsFemale = PapyrusUtil.RemoveActor(ActorsFemale, none)
	ActorsMale = PapyrusUtil.RemoveActor(ActorsMale, none)
EndFunction


String Function GetSexType()
	int weighttotal = weightthreesome + weightmf + weightff + weightmm
	int randomnum = OSANative.RandomInt(0, weighttotal)

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
		randomActor = ActorsMale[OSANative.RandomInt(0, ActorsMale.length - 1)]

		ActorsMale = PapyrusUtil.RemoveActor(ActorsMale, randomActor)
	else
		randomActor = ActorsFemale[OSANative.RandomInt(0, ActorsFemale.length - 1)]

		ActorsFemale = PapyrusUtil.RemoveActor(ActorsFemale, randomActor)
	endif

	return randomActor
EndFunction


Actor Function GetPartnerForActor(Actor act, Actor[] ActorsArrayToUse)
	int i = ActorsArrayToUse.Length

	Actor currentActor

	bool isValid

	bool isActCourting = act.HasAssociation(Courting)
	bool isActMarried = act.HasAssociation(Spouse)

	while i > 0
		i -= 1
		isValid = true
		currentActor = ActorsArrayToUse[i]

		if !AllowActiveFollowers && currentActor.IsPlayerTeamMate()
			isValid = False
		elseif AllowActiveFollowers && currentActor.IsPlayerTeamMate() && FollowersNoScenesDungeons && IsDungeon(PlayerRef.GetCurrentLocation())
			isValid = False
		elseif currentActor.HasAssociation(ParentChild, act) || currentActor.HasAssociation(Siblings, act) || currentActor.HasAssociation(Cousins, act)
			isValid = False
		elseif isActCourting && !act.HasAssociation(Courting, currentActor)
			isValid = False
		elseif isActMarried && !act.HasAssociation(Spouse, currentActor)
			isValid = False
		elseif (isEnemy(act) && !isEnemy(currentActor)) || (!isEnemy(act) && isEnemy(currentActor))
			isValid = False
		elseif !AllowCommonEnemies && (isEnemy(act) || isEnemy(currentActor))
			isValid = False
		else
			if AllowCommonEnemies && isEnemy(act) && isEnemy(currentActor)
				isValid = True
			elseif act.HasAssociation(Spouse, currentActor) || act.HasAssociation(Courting, currentActor)
				isValid = True
			elseif currentActor.GetRelationshipRank(act) < MinRelation
				isValid = False
			else
				isValid = True
			endif
		endif

		if isValid
			return currentActor
		endif
	endwhile

	return None
EndFunction


ObjectReference Function FindEmptyFurniture(actor dom)
	ObjectReference[] Furnitures = OFurniture.FindFurniture(2, dom, (OStim.FurnitureSearchDistance + 1) * 100.0, 96)

	int i = Furnitures.Length

	bool useFurniture

	While i > 0
		i -= 1

		if JArray.FindForm(FurnituresInUse, Furnitures[i]) == -1
			useFurniture = true

			if (FurnitureOnlyBeds || OnlyAllowScenesInBeds)
				if OFurniture.GetFurnitureType(Furnitures[i]) != OStim.FURNITURE_TYPE_BED
					useFurniture = false
				endif
			endif

			if useFurniture
				JArray.addForm(FurnituresInUse, Furnitures[i])
				return Furnitures[i]
			endif
		endif
	EndWhile

	return none
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


Bool Function ActorIsValid(Actor Act)
	if IsInvalidNpc(Act) || ActorIsInCombatState(Act) || Act.GetCurrentScene() != None || !Act.Is3DLoaded() || Act.IsInDialogueWithPlayer() || OStim.IsActorActive(Act) || IsInJArrays(Act) || ActorHasOPrivacyPackage(Act)
		return false
	endif

	return true
EndFunction


Bool Function ActorIsInCombatState(Actor Act)
	return Act.GetCombatState() || Act.IsBleedingOut() || Act.IsWeaponDrawn() || Act.IsUnconscious() || Act.IsInKillMove() || Act.IsArrested() || Act.IsCommandedActor() || Act.IsOnMount()
EndFunction


Bool Function IsInvalidNpc(Actor Act)
	return !Act || Act == PlayerRef || Act.IsDead() || Act.isDisabled() || Act.IsChild() || !Act.HasKeywordString("ActorTypeNPC") || Act.isGhost() || (Act.GetRace() == ElderRace && !AllowElderRace)
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


Bool Function IsNight()
	float hour = CurrentHour()
	if ((hour <= maxnight) || (hour >= minnight))
		return true
	endif
	return false
EndFunction


Float Function CurrentHour()
	float time = Utility.GetCurrentGameTime()

	time -= Math.Floor(time)
	time *= 24

	return time
EndFunction


Float Function GetTimeUntilNight()
	if IsNight()
		return 0.0
	else 
		float ret = (20 - currenthour())
		if ret < 0.1
			ret = 0.0
		endif 
		return ret
	endif
EndFunction


Function RestartScanning()
	RegisterForSingleUpdate(ScanFreq)
EndFunction


Function PrintToConsole(String In) Global
	MiscUtil.PrintConsole("OStim NPCs: " + In)
EndFunction


Package Function GetOPrivacyPackage(int PackageID)
	return Game.GetFormFromFile(PackageID, "OPrivacy.esp") as Package
EndFunction
