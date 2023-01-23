Scriptname ONpcSubthread extends ReferenceAlias

int ONpcThreadID
bool ONpcThreadInUse

Actor DomActor
Actor SubActor
Actor ThirdActor

bool AlternativeBedSearchUsed

ObjectReference CurrentFurniture

OStimSubthread CurrentOStimSubthread

OSexIntegrationMain property OStim auto

ReferenceAlias property Nav1 auto
ReferenceAlias property Nav2 auto
ReferenceAlias property Target auto

Actor property PlayerRef auto

ONpcMain property ONpc auto

ONpcSubthreadPackages property SubthreadPackages auto


Event OnInit()
	ONpcThreadID = GetID()
	OStim = OUtils.GetOStim()
EndEvent


Event NpcSceneStart(string eventname, string strarg, float numarg, form sender)
	ONpcMain.PrintToConsole("NPC scene started!!")
	ONpcMain.PrintToConsole("IDs are: " + numarg + " and " + CurrentOStimSubthread.id)

	if numarg == CurrentOStimSubthread.id
		JArray.addForm(ONpc.NPCsHadSexThisNight, DomActor)
		JArray.addForm(ONpc.NPCsHadSexThisNight, SubActor)

		if ThirdActor
			JArray.addForm(ONpc.NPCsHadSexThisNight, ThirdActor)
		endif

		if ONpc.StopWhenFound
			while CurrentOStimSubthread.AnimationRunning() && ONpc.StopWhenFound
				if IsFound()
					CurrentOStimSubthread.EndAnimation()
				endif

				Utility.Wait(2)
			endwhile
		endif
	endif
EndEvent


Event NpcSceneEnd(string eventname, string strarg, float numarg, form sender)
	if numarg == CurrentOStimSubthread.id
		SceneEndProcedures()
	endif
EndEvent


Function StartScene()
	ONpcMain.PrintToConsole("starting scene!")

	RegisterForModEvent("ostim_subthread_start", "NpcSceneStart")
	RegisterForModEvent("ostim_subthread_end", "NpcSceneEnd")

	CurrentOStimSubthread = OStim.GetUnusedSubthread()

	if !CurrentOStimSubthread || !CheckActorsStillValid() || !CurrentOStimSubthread.StartSubthreadScene(DomActor, SubActor, zThirdActor = ThirdActor, furnitureObj = CurrentFurniture)
		SceneEndProcedures()
	endif
EndFunction


Function SetupScene(Actor dom, Actor sub, ObjectReference furnitureObj, bool alternativeBedSearch, Actor third = none)
	ONpcThreadInUse = true

	DomActor = dom
	SubActor = sub
	ThirdActor = third

	AlternativeBedSearchUsed = alternativeBedSearch

	CurrentFurniture = furnitureObj

	RegisterForSingleUpdate(0.01)
EndFunction


Event onUpdate()
	if !ONpc.TravelToLocation
		; If actors were sleeping, we must wake them up before initiating scene
		; Some mods change the NPCs clothes when they go to sleep
		; So if we start a scene without waking them up, OStim may fail to remove the clothes properly
		if AlternativeBedSearchUsed
			if DomActor.GetSleepState() != 0 || SubActor.GetSleepState() != 0
				; This wakes up the actors
				SubthreadPackages.PackageDoNothing(DomActor, SubActor, Nav1, Nav2)
			endif

			int numberLoops = 0

			; now we wait for them to wake up
			while DomActor.GetSleepState() != 0 || SubActor.GetSleepState() != 0
				numberLoops += 1

				if numberLoops >= 20
					SceneEndProcedures()
					return
				endif

				Utility.Wait(1)
			endwhile

			Utility.Wait(1.5)
		endif

		if CurrentFurniture != none
			DomActor.setposition(CurrentFurniture.x, CurrentFurniture.y, CurrentFurniture.z)
			SubActor.setposition(CurrentFurniture.x, CurrentFurniture.y, CurrentFurniture.z)
		endif

		SubthreadPackages.ClearAliases(DomActor, SubActor, Nav1, Nav2, Target)

		StartScene()
	else
		if !Invite()
			SceneEndProcedures()
			return
		endif

		debug.sendanimationevent(DomActor, "IdleComeThisWay")

		if CurrentFurniture != none
			if !GoToFurniture()
				SceneEndProcedures()
				return
			endif

			DomActor.setposition(CurrentFurniture.x, CurrentFurniture.y, CurrentFurniture.z)
			SubActor.setposition(CurrentFurniture.x, CurrentFurniture.y, CurrentFurniture.z)
		endif

		if ONPC.StopWhenFound && isFound()
			SceneEndProcedures()
			return
		endif

		StartScene()
	endif
EndEvent


Function SceneEndProcedures()
	SubthreadPackages.ClearAliases(DomActor, SubActor, Nav1, Nav2, Target)

	UnregisterForModEvent("ostim_subthread_start")
	UnregisterForModEvent("ostim_subthread_end")

	ONpcMain.PrintToConsole("Running scene end procedures")

	JArray.EraseForm(ONpc.NPCsInScene, DomActor)
	JArray.EraseForm(ONpc.NPCsInScene, SubActor)
	JArray.EraseForm(ONpc.NPCsInScene, ThirdActor)

	JArray.EraseForm(ONpc.FurnituresInUse, CurrentFurniture)

	ONpcThreadInUse = false
	ONpc.activeScenes -= 1
EndFunction


bool Function Invite()
	SubthreadPackages.TravelToActor(DomActor, SubActor, Nav1, Nav2, Target)
	DomActor.SetLookAt(SubActor)
	SubActor.SetLookAt(DomActor)

	int stuckTimer = 0

	while DomActor.GetDistance(SubActor) > 128
		if !CheckActorsStillValid()
			DomActor.ClearLookAt()
			SubActor.ClearLookAt()

			return false
		endif

		stuckTimer += 1

		ONpcMain.PrintToConsole("Actor " + DomActor.GetActorBase().GetName() + " is travelling to " + SubActor.GetActorBase().GetName())

		if stuckTimer >= 30
			DomActor.setposition(SubActor.x, SubActor.y, SubActor.z)
		else
			utility.wait(1)
		endif
	endwhile

	SubthreadPackages.ClearAliases(DomActor, SubActor, Nav1, Nav2, Target)

	DomActor.ClearLookAt()
	SubActor.ClearLookAt()

	return true
EndFunction


bool Function GoToFurniture()
	SubthreadPackages.TravelToFurniture(DomActor, SubActor, CurrentFurniture, Nav1, Nav2, Target)

	int stuckTimer = 0

	while DomActor.GetDistance(CurrentFurniture) > 128 && SubActor.GetDistance(CurrentFurniture) > 128
		if !CheckActorsStillValid()
			return false
		endif

		stucktimer += 1
		ONpcMain.PrintToConsole("Actor " + DomActor.GetActorBase().GetName() + " is travelling to Furniture")

		if stucktimer >= 30
			return true
		else
			utility.wait(1)
		endif
	endwhile

	SubthreadPackages.ClearAliases(DomActor, SubActor, Nav1, Nav2, Target)

	return true
EndFunction


bool Function CheckActorsStillLoaded()
	return DomActor.Is3DLoaded() && SubActor.Is3DLoaded() && (!ThirdActor || (ThirdActor && !ThirdActor.Is3DLoaded()))
EndFunction


bool Function CheckActorsStillAlive()
	return !DomActor.IsDead() && !SubActor.IsDead() && (!ThirdActor || (ThirdActor && !ThirdActor.IsDead()))
EndFunction


bool Function CheckActorsNotInScenes()
	return DomActor.GetCurrentScene() == None && SubActor.GetCurrentScene() == None && (!ThirdActor || (ThirdActor && ThirdActor.GetCurrentScene() == None))
EndFunction

bool Function CheckActorsAreInCombatState()
	return ONpc.ActorIsInCombatState(DomActor) || ONpc.ActorIsInCombatState(SubActor) || (ThirdActor && ONpc.ActorIsInCombatState(ThirdActor))
EndFunction


bool Function CheckActorsStillValid()
	return CheckActorsStillLoaded() && CheckActorsStillAlive() && CheckActorsNotInScenes() && !CheckActorsAreInCombatState()
EndFunction


bool Function IsFound()
	if PlayerRef.isdetectedby(DomActor) && (PlayerRef.haslos(DomActor) || DomActor.haslos(PlayerRef))
		return true
	endif
	return false
EndFunction


Bool Function IsThreadInUse()
	return ONpcThreadInUse
EndFunction
