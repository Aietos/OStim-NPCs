Scriptname ONpcMCM extends SKI_ConfigBase

; Settings
int setONpcsDisabled

int setAllowActiveFollowers
int setActiveFollowersEngageOtherNPCs
int setAllowCommonEnemies

int setStopWhenFound
int setTravelToLocation
int setEnemiesTravelToLocation

int setMaxFollowerScenesPerNight
int setMaxEnemyScenesPerNight
int setMaxScenes
int setMinRelation

int setMinNight
int setMaxNight

int setScanFreq

int setWeightMF
int setWeightFF
int setWeightMM

int setEnableFurniture
int setFurnitureOnlyBeds
int setScenesStartIn

int setEnemiesIgnoreScenesStartInRules

int setFollowersNoScenesDungeons
int setNoScenesInTowns
int setNoScenesInGuilds
int setNoScenesInInns
int setAllowElderRace

int setResetDefaults
int setAddSpells
int setRemoveSpells

Actor property PlayerRef auto

Spell property MatchMakerSpellTarget auto
Spell property MatchMakerSpellSelf auto

ONpcMain property ONpc auto


event OnInit()
	parent.OnInit()

	Modname = "OStim NPCs"
endEvent


event OnGameReload()
	parent.onGameReload()
endevent


event OnPageReset(string page)
	SetCursorFillMode(TOP_TO_BOTTOM)

	AddColoredHeader("$onpcs_header_main_settings")

	setONpcsDisabled = AddToggleOption("$onpcs_option_disable_onpcs", ONpc.ONpcDisabled)
	AddEmptyOption()

	setAllowActiveFollowers = AddToggleOption("$onpcs_option_allow_active_followers", ONpc.AllowActiveFollowers)
	setActiveFollowersEngageOtherNPCs = AddToggleOption("$onpcs_option_active_followers_npcs", ONpc.ActiveFollowersEngageOtherNPCs)
	setAllowElderRace = AddToggleOption("$onpcs_option_allow_elders", ONpc.AllowElderRace)
	setAllowCommonEnemies = AddToggleOption("$onpcs_option_allow_common_enemies", ONpc.AllowCommonEnemies)
	AddEmptyOption()

	setStopWhenFound = AddToggleOption("$onpcs_option_stop_when_found", ONpc.StopWhenFound)
	setTravelToLocation = AddToggleOption("$onpcs_option_travel", ONpc.TravelToLocation)
	setEnemiesTravelToLocation = AddToggleOption("$onpcs_option_travel_enemies", ONpc.EnemiesTravelToLocation)
	AddEmptyOption()

	setEnableFurniture = AddToggleOption("$onpcs_option_enable_furniture", ONpc.EnableFurniture)
	setFurnitureOnlyBeds = AddToggleOption("$onpcs_option_furniture_beds", ONpc.FurnitureOnlyBeds)
	setScenesStartIn = AddMenuOption("$onpcs_option_scenes_beds", ONpc.ScenesStartInStrings[ONpc.ScenesStartIn])
	setEnemiesIgnoreScenesStartInRules = AddToggleOption("$onpcs_option_enemies_ignore_scenes_start_in_rules", ONpc.EnemiesIgnoreScenesStartInRules)
	AddEmptyOption()

	setFollowersNoScenesDungeons = AddToggleOption("$onpcs_option_followers_dungeons", ONpc.FollowersNoScenesDungeons)
	setNoScenesInTowns = AddToggleOption("$onpcs_option_scenes_towns", ONpc.NoScenesInTowns)
	setNoScenesInGuilds = AddToggleOption("$onpcs_option_scenes_guilds", ONpc.NoScenesInGuilds)
	setNoScenesInInns = AddToggleOption("$onpcs_option_scenes_inns", ONpc.NoScenesInInns)
	AddEmptyOption()

	AddColoredHeader("$onpcs_header_reset")
	setResetDefaults = AddToggleOption("$onpcs_option_reset_defaults", false)
	setAddSpells = AddToggleOption("$onpcs_option_add_spells", false)
	setRemoveSpells = AddToggleOption("$onpcs_option_remove_spells", false)

	SetCursorPosition(1)

	AddColoredHeader("$onpcs_header_adjustments")

	setMinRelation = AddSliderOption("$onpcs_option_min_relation", ONpc.MinRelation, "{0}")
	AddEmptyOption()

	setMaxFollowerScenesPerNight = AddSliderOption("$onpcs_option_max_follower_scenes", ONpc.MaxFollowerScenesPerNight, "{0}")
	setMaxEnemyScenesPerNight = AddSliderOption("$onpcs_option_max_enemy_scenes", ONpc.MaxEnemyScenesPerNight, "{0}")
	setMaxScenes = AddSliderOption("$onpcs_option_max_scenes", ONpc.MaxScenes, "{0}")
	setMinNight = AddSliderOption("$onpcs_option_min_night", ONpc.MinNight - 12, "{0} PM")
	setMaxNight = AddSliderOption("$onpcs_option_max_night", ONpc.MaxNight, "{0} AM")
	AddEmptyOption()

	setScanFreq = AddSliderOption("$onpcs_option_scan_freq", ONpc.ScanFreq, "{0} seconds")

	AddEmptyOption()

	setWeightMF = AddSliderOption("$onpcs_option_weight_mf", ONpc.WeightMF, "{0}")
	setWeightFF = AddSliderOption("$onpcs_option_weight_ff", ONpc.WeightFF, "{0}")
	setWeightMM = AddSliderOption("$onpcs_option_weight_mm", ONpc.WeightMM, "{0}")
endEvent


event OnOptionSelect(int option)
	if (option == setONpcsDisabled)
		ONpc.ONpcDisabled = !ONpc.ONpcDisabled
		SetToggleOptionValue(setONpcsDisabled, ONpc.ONpcDisabled)

		if (!ONpc.ONpcDisabled)
			ONpc.RestartScanning()
		else
			ONpc.ResetNightVariables(0, true)
		endif

	elseif (option == setAllowActiveFollowers)
		ONpc.AllowActiveFollowers = !ONpc.AllowActiveFollowers
		SetToggleOptionValue(setAllowActiveFollowers, ONpc.AllowActiveFollowers)

	elseif (option == setActiveFollowersEngageOtherNPCs)
		ONpc.ActiveFollowersEngageOtherNPCs = !ONpc.ActiveFollowersEngageOtherNPCs
		SetToggleOptionValue(setActiveFollowersEngageOtherNPCs, ONpc.ActiveFollowersEngageOtherNPCs)

	elseif (option == setAllowElderRace)
		ONpc.AllowElderRace = !ONpc.AllowElderRace
		SetToggleOptionValue(setAllowElderRace, ONpc.AllowElderRace)

	elseif (option == setAllowCommonEnemies)
		ONpc.AllowCommonEnemies = !ONpc.AllowCommonEnemies
		SetToggleOptionValue(setAllowCommonEnemies, ONpc.AllowCommonEnemies)

	elseif (option == setStopWhenFound)
		ONpc.StopWhenFound = !ONpc.StopWhenFound
		SetToggleOptionValue(setStopWhenFound, ONpc.StopWhenFound)

	elseif (option == setTravelToLocation)
		ONpc.TravelToLocation = !ONpc.TravelToLocation
		SetToggleOptionValue(setTravelToLocation, ONpc.TravelToLocation)

	elseif (option == setEnemiesTravelToLocation)
		ONpc.EnemiesTravelToLocation = !ONpc.EnemiesTravelToLocation
		SetToggleOptionValue(setEnemiesTravelToLocation, ONpc.EnemiesTravelToLocation)

	elseif (option == setEnableFurniture)
		ONpc.EnableFurniture = !ONpc.EnableFurniture
		SetToggleOptionValue(setEnableFurniture, ONpc.EnableFurniture)

	elseif (option == setFurnitureOnlyBeds)
		ONpc.FurnitureOnlyBeds = !ONpc.FurnitureOnlyBeds
		SetToggleOptionValue(setFurnitureOnlyBeds, ONpc.FurnitureOnlyBeds)

	elseif (option == setEnemiesIgnoreScenesStartInRules)
		ONpc.EnemiesIgnoreScenesStartInRules = !ONpc.EnemiesIgnoreScenesStartInRules
		SetToggleOptionValue(setEnemiesIgnoreScenesStartInRules, ONpc.EnemiesIgnoreScenesStartInRules)

	elseif (option == setFollowersNoScenesDungeons)
		ONpc.FollowersNoScenesDungeons = !ONpc.FollowersNoScenesDungeons
		SetToggleOptionValue(setFollowersNoScenesDungeons, ONpc.FollowersNoScenesDungeons)

	elseif (option == setNoScenesInTowns)
		ONpc.NoScenesInTowns = !ONpc.NoScenesInTowns
		SetToggleOptionValue(setNoScenesInTowns, ONpc.NoScenesInTowns)

	elseif (option == setNoScenesInGuilds)
		ONpc.NoScenesInGuilds = !ONpc.NoScenesInGuilds
		SetToggleOptionValue(setNoScenesInGuilds, ONpc.NoScenesInGuilds)

	elseif (option == setNoScenesInInns)
		ONpc.NoScenesInInns = !ONpc.NoScenesInInns
		SetToggleOptionValue(setNoScenesInInns, ONpc.NoScenesInInns)

	elseif (option == setResetDefaults)
		ResetDefaults()
		ShowMessage("$onpcs_message_defaults_reset", false)
	elseif (option == setAddSpells)
		if !PlayerRef.HasSpell(MatchMakerSpellTarget)
			PlayerRef.AddSpell(MatchMakerSpellTarget, true)
		endIf
		if !PlayerRef.HasSpell(MatchMakerSpellSelf)
			PlayerRef.AddSpell(MatchMakerSpellSelf, true)
		endIf
		ShowMessage("$onpcs_message_spells_added", false)
	elseif (option == setRemoveSpells)
		if PlayerRef.HasSpell(MatchMakerSpellTarget)
			PlayerRef.RemoveSpell(MatchMakerSpellTarget)
		endIf
		if PlayerRef.HasSpell(MatchMakerSpellSelf)
			PlayerRef.RemoveSpell(MatchMakerSpellSelf)
		endIf
		ShowMessage("$onpcs_message_spells_removed", false)
	endIf
endEvent


event OnOptionSliderOpen(int option)
	If (option == setMaxScenes)
		SetSliderDialogStartValue(ONpc.MaxScenes)

		SetSliderDialogDefaultValue(2)
		SetSliderDialogRange(1, 4)
		SetSliderDialogInterval(1)

	elseif (option == setMaxFollowerScenesPerNight)
		SetSliderDialogStartValue(ONpc.MaxFollowerScenesPerNight)

		SetSliderDialogDefaultValue(2)
		SetSliderDialogRange(1, 10)
		SetSliderDialogInterval(1)

	elseif (option == setMaxEnemyScenesPerNight)
		SetSliderDialogStartValue(ONpc.MaxEnemyScenesPerNight)

		SetSliderDialogDefaultValue(3)
		SetSliderDialogRange(1, 20)
		SetSliderDialogInterval(1)

	elseif (option == setMinRelation)
		SetSliderDialogStartValue(ONpc.MinRelation)

		SetSliderDialogDefaultValue(3)
		SetSliderDialogRange(-4, 4)
		SetSliderDialogInterval(1)

	elseif (option == setMinNight)
		SetSliderDialogStartValue(ONpc.MinNight - 12)
		SetSliderDialogDefaultValue(8)
		SetSliderDialogRange(1, 12)
		SetSliderDialogInterval(1)

	elseif (option == setMaxNight)
		SetSliderDialogStartValue(ONpc.MaxNight)
		SetSliderDialogDefaultValue(4.0)
		SetSliderDialogRange(1, 11)
		SetSliderDialogInterval(1)

	elseif (option == setScanFreq)
		SetSliderDialogStartValue(ONpc.ScanFreq)
		SetSliderDialogDefaultValue(15.0)
		SetSliderDialogRange(10, 120)
		SetSliderDialogInterval(5)

	elseif (option == setWeightMF)
		SetSliderDialogStartValue(ONpc.WeightMF)
		SetSliderDialogDefaultValue(100.0)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)

	elseif (option == setWeightFF)
		SetSliderDialogStartValue(ONpc.WeightFF)
		SetSliderDialogDefaultValue(0.0)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)

	elseif (option == setWeightMM)
		SetSliderDialogStartValue(ONpc.WeightMM)
		SetSliderDialogDefaultValue(0.0)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	EndIf
endEvent


event OnOptionSliderAccept(int option, float value)
	If (option == setMaxScenes)
		ONpc.MaxScenes = value as int
		SetSliderOptionValue(setMaxScenes, value, "{0}")

	elseif (option == setMaxFollowerScenesPerNight)
		ONpc.MaxFollowerScenesPerNight = value as int
		SetSliderOptionValue(setMaxFollowerScenesPerNight, value, "{0}")

	elseif (option == setMaxEnemyScenesPerNight)
		ONpc.MaxEnemyScenesPerNight = value as int
		SetSliderOptionValue(setMaxEnemyScenesPerNight, value, "{0}")

	elseif (option == setMinRelation)
		ONpc.MinRelation = value as int
		SetSliderOptionValue(setMinRelation, value, "{0}")

	elseif (option == setMinNight)
		bool isNightTime = ONpc.IsNight()

		ONpc.MinNight = (value+12) as int
		SetSliderOptionValue(setMinNight, value, "{0} PM")

		if !isNightTime
			ONpc.RestartScanning()
		endif

	elseif (option == setMaxNight)
		ONpc.MaxNight = value as int
		SetSliderOptionValue(setMaxNight, value, "{0} AM")

	elseif (option == setScanFreq)
		ONpc.ScanFreq = value as int
		SetSliderOptionValue(setScanFreq, value, "{0} seconds")

	elseif (option == setWeightMF)
		ONpc.WeightMF = value as int
		SetSliderOptionValue(setWeightMF, value, "{0}")

	elseif (option == setWeightFF)
		ONpc.WeightFF = value as int
		SetSliderOptionValue(setWeightFF, value, "{0}")

	elseif (option == setWeightMM)
		ONpc.WeightMM = value as int
		SetSliderOptionValue(setWeightMM, value, "{0}")
	EndIf
endEvent


event OnOptionMenuOpen(int option)
	if (option == setScenesStartIn)
		SetMenuDialogOptions(ONpc.ScenesStartInStrings)
		SetMenuDialogStartIndex(ONpc.ScenesStartIn)
		SetMenuDialogDefaultIndex(2)
	endIf
endEvent


event OnOptionMenuAccept(int option, int index)
	if (option == setScenesStartIn)
		ONpc.ScenesStartIn = index
		SetMenuOptionValue(setScenesStartIn, ONpc.ScenesStartInStrings[index])
	endIf
endEvent


event OnOptionHighlight(int option)
	if (option == setONpcsDisabled)
		SetInfoText("$onpcs_highlight_onpcs_disabled")

	elseif (option == setAllowActiveFollowers)
		SetInfoText("$onpcs_highlight_allow_active_followers")

	elseif (option == setActiveFollowersEngageOtherNPCs)
		SetInfoText("$onpcs_highlight_active_followers_npcs")

	elseif (option == setAllowElderRace)
		SetInfoText("$onpcs_highlight_allow_elders")

	elseif (option == setAllowCommonEnemies)
		SetInfoText("$onpcs_highlight_allow_common_enemies")

	elseif (option == setStopWhenFound)
		SetInfoText("$onpcs_highlight_stop_found")

	elseif (option == setTravelToLocation)
		SetInfoText("$onpcs_highlight_travel")

	elseif (option == setEnemiesTravelToLocation)
		SetInfoText("$onpcs_highlight_travel_enemies")

	elseif (option == setEnableFurniture)
		SetInfoText("$onpcs_highlight_enable_furniture")

	elseif (option == setFurnitureOnlyBeds)
		SetInfoText("$onpcs_highlight_furniture_only_beds")

	elseif (option == setScenesStartIn)
		SetInfoText("$onpcs_highlight_allow_scenes_in_beds")

	elseif (option == setEnemiesIgnoreScenesStartInRules)
		SetInfoText("$onpcs_highlight_enemies_ignore_scenes_start_in_rules")

	elseif (option == setFollowersNoScenesDungeons)
		SetInfoText("$onpcs_highlight_followers_dungeons")

	elseif (option == setNoScenesInTowns)
		SetInfoText("$onpcs_highlight_scenes_towns")

	elseif (option == setNoScenesInGuilds)
		SetInfoText("$onpcs_highlight_scenes_guilds")

	elseif (option == setNoScenesInInns)
		SetInfoText("$onpcs_highlight_scenes_inns")

	elseif (option == setMinRelation)
		SetInfoText("$onpcs_highlight_min_relation")

	elseif (option == setMaxScenes)
		SetInfoText("$onpcs_highlight_max_scenes")

	elseif (option == setMaxFollowerScenesPerNight)
		SetInfoText("$onpcs_highlight_max_follower_scenes")

	elseif (option == setMaxEnemyScenesPerNight)
		SetInfoText("$onpcs_highlight_max_enemy_scenes")

	elseif (option == setMinNight)
		SetInfoText("$onpcs_highlight_min_night")

	elseif (option == setMaxNight)
		SetInfoText("$onpcs_highlight_max_night")

	elseif (option == setScanFreq)
		SetInfoText("$onpcs_highlight_scan_freq")

	elseif (option == setWeightMF)
		SetInfoText("$onpcs_highlight_weight_mf")

	elseif (option == setWeightFF)
		SetInfoText("$onpcs_highlight_weight_ff")

	elseif (option == setWeightMM)
		SetInfoText("$onpcs_highlight_weight_mm")
	endif
endEvent


; Shamelessly copied from OStim's OSexIntegrationMCM.psc
bool Color1
function AddColoredHeader(String In)
	string Blue = "#6699ff"
	string Pink = "#ff3389"
	string Color

	If Color1
		Color = Pink
		Color1 = False
	Else
		Color = Blue
		Color1 = True
	EndIf

	AddHeaderOption("<font color='" + Color +"'>" + In)
endFunction


function ResetDefaults()
	ONpc.ONpcDisabled = false
	SetToggleOptionValue(setONpcsDisabled, ONpc.ONpcDisabled)

	ONpc.AllowActiveFollowers = true
	SetToggleOptionValue(setAllowActiveFollowers, ONpc.AllowActiveFollowers)

	ONpc.ActiveFollowersEngageOtherNPCs = false
	SetToggleOptionValue(setActiveFollowersEngageOtherNPCs, ONpc.ActiveFollowersEngageOtherNPCs)

	ONpc.AllowElderRace = false
	SetToggleOptionValue(setAllowElderRace, ONpc.AllowElderRace)

	ONpc.AllowCommonEnemies = true
	SetToggleOptionValue(setAllowCommonEnemies, ONpc.AllowCommonEnemies)

	ONpc.StopWhenFound = true
	SetToggleOptionValue(setStopWhenFound, ONpc.StopWhenFound)

	ONpc.TravelToLocation = true
	SetToggleOptionValue(setTravelToLocation, ONpc.TravelToLocation)

	ONpc.EnemiesTravelToLocation = false
	SetToggleOptionValue(setEnemiesTravelToLocation, ONpc.EnemiesTravelToLocation)

	ONpc.EnableFurniture = true
	SetToggleOptionValue(setEnableFurniture, ONpc.EnableFurniture)

	ONpc.FurnitureOnlyBeds = true
	SetToggleOptionValue(setFurnitureOnlyBeds, ONpc.FurnitureOnlyBeds)

	ONpc.ScenesStartIn = ONpc.BedsOnly
	SetMenuOptionValue(setScenesStartIn,  ONpc.ScenesStartInStrings[ONpc.BedsOnly])

	ONpc.EnemiesIgnoreScenesStartInRules = false
	SetToggleOptionValue(setEnemiesIgnoreScenesStartInRules, ONpc.EnemiesIgnoreScenesStartInRules)

	ONpc.FollowersNoScenesDungeons = true
	SetToggleOptionValue(setFollowersNoScenesDungeons, ONpc.FollowersNoScenesDungeons)

	ONpc.NoScenesInTowns = true
	SetToggleOptionValue(setNoScenesInTowns, ONpc.NoScenesInTowns)

	ONpc.NoScenesInGuilds = true
	SetToggleOptionValue(setNoScenesInGuilds, ONpc.NoScenesInGuilds)

	ONpc.NoScenesInInns = false
	SetToggleOptionValue(setNoScenesInInns, ONpc.NoScenesInInns)

	ONpc.MinRelation = 3
	SetSliderOptionValue(setMinRelation, 3.0, "{0}")

	ONpc.MaxScenes = 2
	SetSliderOptionValue(setMaxScenes, 2.0, "{0}")

	ONpc.MaxFollowerScenesPerNight = 2
	SetSliderOptionValue(setMaxFollowerScenesPerNight, 2.0, "{0}")

	ONpc.MaxEnemyScenesPerNight = 3
	SetSliderOptionValue(setMaxEnemyScenesPerNight, 3.0, "{0}")

	ONpc.MinNight = 20
	SetSliderOptionValue(setMinNight, 8.0, "{0} PM")

	ONpc.MaxNight = 4
	SetSliderOptionValue(setMaxNight, 4.0, "{0} AM")

	ONpc.ScanFreq = 15
	SetSliderOptionValue(setScanFreq, 15.0, "{0} seconds")

	ONpc.WeightMF = 100
	SetSliderOptionValue(setWeightMF, 100.0, "{0}")

	ONpc.WeightFF = 0
	SetSliderOptionValue(setWeightFF, 0.0, "{0}")

	ONpc.WeightMM = 0
	SetSliderOptionValue(setWeightMM, 0.0, "{0}")
endFunction
