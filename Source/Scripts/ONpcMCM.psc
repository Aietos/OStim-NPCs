Scriptname ONpcMCM extends SKI_ConfigBase

; Settings
int setONpcsDisabled

int setAllowActiveFollowers
int setAllowCommonEnemies

int setStopWhenFound
int setTravelToLocation

int setMaxScenes
int setMinRelation

int setMinNight
int setMaxNight

int setScanFreq
int setScanRadius

int setWeightMF
int setWeightFF
int setWeightMM

int setFurnitureOnlyBeds
int setOnlyAllowScenesInBeds

int setFollowersNoScenesDungeons
int setNoScenesInTowns
int setNoScenesInGuilds
int setNoScenesInInns

int setResetDefaults

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
	setAllowCommonEnemies = AddToggleOption("$onpcs_option_allow_common_enemies", ONpc.AllowCommonEnemies)
	AddEmptyOption()

	setStopWhenFound = AddToggleOption("$onpcs_option_stop_when_found", ONpc.StopWhenFound)
	setTravelToLocation = AddToggleOption("$onpcs_option_travel", ONpc.TravelToLocation)
	AddEmptyOption()

	setFurnitureOnlyBeds = AddToggleOption("$onpcs_option_furniture_beds", ONpc.FurnitureOnlyBeds)
	setOnlyAllowScenesInBeds = AddToggleOption("$onpcs_option_scenes_beds", ONpc.OnlyAllowScenesInBeds)
	AddEmptyOption()

	setFollowersNoScenesDungeons = AddToggleOption("$onpcs_option_followers_dungeons", ONpc.FollowersNoScenesDungeons)
	setNoScenesInTowns = AddToggleOption("$onpcs_option_scenes_towns", ONpc.NoScenesInTowns)
	setNoScenesInGuilds = AddToggleOption("$onpcs_option_scenes_guilds", ONpc.NoScenesInGuilds)
	setNoScenesInInns = AddToggleOption("$onpcs_option_scenes_inns", ONpc.NoScenesInInns)
	AddEmptyOption()

	AddColoredHeader("$onpcs_header_reset")
	setResetDefaults = AddToggleOption("$onpcs_option_reset_defaults", false)

	SetCursorPosition(1)

	AddColoredHeader("$onpcs_header_adjustments")

	setMinRelation = AddSliderOption("$onpcs_option_min_relation", ONpc.MinRelation, "{0}")
	AddEmptyOption()

	setMaxScenes = AddSliderOption("$onpcs_option_max_scenes", ONpc.MaxScenes, "{0}")
	setMinNight = AddSliderOption("$onpcs_option_min_night", ONpc.MinNight - 12, "{0} PM")
	setMaxNight = AddSliderOption("$onpcs_option_max_night", ONpc.MaxNight, "{0} AM")
	AddEmptyOption()

	setScanFreq = AddSliderOption("$onpcs_option_scan_freq", ONpc.ScanFreq, "{0} seconds")
	setScanRadius = AddSliderOption("$onpcs_option_scan_radius", ONpc.ScanRadius * 0.046875, "{0} feet")

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
		endif

	elseif (option == setAllowActiveFollowers)
		ONpc.AllowActiveFollowers = !ONpc.AllowActiveFollowers
		SetToggleOptionValue(setAllowActiveFollowers, ONpc.AllowActiveFollowers)

	elseif (option == setAllowCommonEnemies)
		ONpc.AllowCommonEnemies = !ONpc.AllowCommonEnemies
		SetToggleOptionValue(setAllowCommonEnemies, ONpc.AllowCommonEnemies)

	elseif (option == setStopWhenFound)
		ONpc.StopWhenFound = !ONpc.StopWhenFound
		SetToggleOptionValue(setStopWhenFound, ONpc.StopWhenFound)

	elseif (option == setTravelToLocation)
		ONpc.TravelToLocation = !ONpc.TravelToLocation
		SetToggleOptionValue(setTravelToLocation, ONpc.TravelToLocation)

	elseif (option == setFurnitureOnlyBeds)
		ONpc.FurnitureOnlyBeds = !ONpc.FurnitureOnlyBeds
		SetToggleOptionValue(setFurnitureOnlyBeds, ONpc.FurnitureOnlyBeds)

	elseif (option == setOnlyAllowScenesInBeds)
		ONpc.OnlyAllowScenesInBeds = !ONpc.OnlyAllowScenesInBeds
		SetToggleOptionValue(setOnlyAllowScenesInBeds, ONpc.OnlyAllowScenesInBeds)

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
	endIf
endEvent


event OnOptionSliderOpen(int option)
	If (option == setMaxScenes)
		SetSliderDialogStartValue(ONpc.MaxScenes)

		SetSliderDialogDefaultValue(2)
		SetSliderDialogRange(1, 4)
		SetSliderDialogInterval(1)

	elseif (option == setMinRelation)
		SetSliderDialogStartValue(ONpc.MinRelation)

		SetSliderDialogDefaultValue(3)
		SetSliderDialogRange(-4, 4)
		SetSliderDialogInterval(1)

	elseif (option == setMinNight)
		SetSliderDialogStartValue(ONpc.MinNight - 12)
		SetSliderDialogDefaultValue(8)
		SetSliderDialogRange(5, 12)
		SetSliderDialogInterval(1)

	elseif (option == setMaxNight)
		SetSliderDialogStartValue(ONpc.MaxNight)
		SetSliderDialogDefaultValue(4.0)
		SetSliderDialogRange(1, 6)
		SetSliderDialogInterval(1)

	elseif (option == setScanFreq)
		SetSliderDialogStartValue(ONpc.ScanFreq)
		SetSliderDialogDefaultValue(20.0)
		SetSliderDialogRange(5, 180)
		SetSliderDialogInterval(5)

	elseif (option == setScanRadius)
		SetSliderDialogStartValue(ONpc.ScanRadius * 0.046875)
		SetSliderDialogDefaultValue(48.0)
		SetSliderDialogRange(2, 200)
		SetSliderDialogInterval(2)

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

	elseif (option == setMinRelation)
	ONpc.MinRelation = value as int
	SetSliderOptionValue(setMinRelation, value, "{0}")

	elseif (option == setMinNight)
		ONpc.MinNight = (value+12) as int
		SetSliderOptionValue(setMinNight, value, "{0} PM")

	elseif (option == setMaxNight)
		ONpc.MaxNight = value as int
		SetSliderOptionValue(setMaxNight, value, "{0} AM")

	elseif (option == setScanFreq)
		ONpc.ScanFreq = value as int
		SetSliderOptionValue(setScanFreq, value, "{0}")

	elseif (option == setScanRadius)
		ONpc.ScanRadius = value / 0.046875
		SetSliderOptionValue(setScanRadius, value, "{0}")

	elseif (option == setWeightMF)
		ONpc.WeightMF = value as int
		SetSliderOptionValue(setWeightMF, value, "{0}")

	elseif (option == setWeightFF)
		ONpc.WeightMF = value as int
		SetSliderOptionValue(setWeightFF, value, "{0}")

	elseif (option == setWeightMM)
		ONpc.WeightMM = value as int
		SetSliderOptionValue(setWeightMM, value, "{0}")
	EndIf
endEvent


event OnOptionHighlight(int option)
	if (option == setONpcsDisabled)
		SetInfoText("$onpcs_highlight_onpcs_disabled")

	elseif (option == setAllowActiveFollowers)
		SetInfoText("$onpcs_highlight_allow_active_followers")

	elseif (option == setAllowCommonEnemies)
		SetInfoText("$onpcs_highlight_allow_common_enemies")

	elseif (option == setStopWhenFound)
		SetInfoText("$onpcs_highlight_stop_found")

	elseif (option == setTravelToLocation)
		SetInfoText("$onpcs_highlight_travel")

	elseif (option == setFurnitureOnlyBeds)
		SetInfoText("$onpcs_highlight_furniture_only_beds")

	elseif (option == setOnlyAllowScenesInBeds)
		SetInfoText("$onpcs_highlight_allow_scenes_in_beds")

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

	elseif (option == setMinNight)
		SetInfoText("$onpcs_highlight_min_night")

	elseif (option == setMaxNight)
		SetInfoText("$onpcs_highlight_max_night")

	elseif (option == setScanFreq)
		SetInfoText("$onpcs_highlight_scan_freq")

	elseif (option == setScanRadius)
		SetInfoText("$onpcs_highlight_scan_radius")

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

	ONpc.AllowCommonEnemies = true
	SetToggleOptionValue(setAllowCommonEnemies, ONpc.AllowCommonEnemies)

	ONpc.StopWhenFound = true
	SetToggleOptionValue(setStopWhenFound, ONpc.StopWhenFound)

	ONpc.TravelToLocation = true
	SetToggleOptionValue(setTravelToLocation, ONpc.TravelToLocation)

	ONpc.FurnitureOnlyBeds = true
	SetToggleOptionValue(setFurnitureOnlyBeds, ONpc.FurnitureOnlyBeds)

	ONpc.OnlyAllowScenesInBeds = true
	SetToggleOptionValue(setOnlyAllowScenesInBeds, ONpc.OnlyAllowScenesInBeds)

	ONpc.FollowersNoScenesDungeons = true
	SetToggleOptionValue(setFollowersNoScenesDungeons, ONpc.FollowersNoScenesDungeons)

	ONpc.NoScenesInTowns = true
	SetToggleOptionValue(setNoScenesInTowns, ONpc.NoScenesInTowns)

	ONpc.NoScenesInGuilds = false
	SetToggleOptionValue(setNoScenesInGuilds, ONpc.NoScenesInGuilds)

	ONpc.NoScenesInInns = false
	SetToggleOptionValue(setNoScenesInInns, ONpc.NoScenesInInns)

	ONpc.MinRelation = 3
	SetSliderOptionValue(setMinRelation, 3.0, "{0}")

	ONpc.MaxScenes = 2
	SetSliderOptionValue(setMaxScenes, 2.0, "{0}")
	
	ONpc.MinNight = 20
	SetSliderOptionValue(setMinNight, 8.0, "{0} PM")

	ONpc.MaxNight = 4
	SetSliderOptionValue(setMaxNight, 4.0, "{0} AM")

	ONpc.ScanFreq = 10
	SetSliderOptionValue(setScanFreq, 10.0, "{0}")

	ONpc.ScanRadius = 48.0 / 0.046875
	SetSliderOptionValue(setScanRadius, 48.0, "{0}")

	ONpc.WeightMF = 100
	SetSliderOptionValue(setWeightMF, 100.0, "{0}")

	ONpc.WeightFF = 0
	SetSliderOptionValue(setWeightFF, 0.0, "{0}")

	ONpc.WeightMM = 0
	SetSliderOptionValue(setWeightMM, 0.0, "{0}")
endFunction
