Scriptname ONpcSubthread extends ReferenceAlias

int ONpcThreadID
bool ONpcThreadInUse

Actor DomActor
Actor SubActor
Actor ThirdActor

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


Function SetupScene(Actor dom, Actor sub, ObjectReference furnitureObj, Actor third = none)
	ONpcThreadInUse = true

	DomActor = dom
	SubActor = sub
	ThirdActor = third

	CurrentFurniture = furnitureObj

	RegisterForSingleUpdate(0.01)
EndFunction


Event onUpdate()
	if !ONpc.TravelToLocation
		StartScene()
	else
		if !Invite()
			SceneEndProcedures()
			return
		endif

		if CurrentFurniture != none
			if !GoToFurniture()
				SceneEndProcedures()
				return
			endif
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
			return false
		endif

		stuckTimer += 1

		ONpcMain.PrintToConsole("Actor " + DomActor.GetActorBase().GetName() + " is travelling to " + SubActor.GetActorBase().GetName())

		if stuckTimer >= 20
			DomActor.setposition(SubActor.x, SubActor.y, SubActor.z)
		else
			utility.wait(1)
		endif
	endwhile

	SubthreadPackages.ClearAliases(DomActor, SubActor, Nav1, Nav2, Target)

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

		if stucktimer >= 20
			DomActor.setposition(CurrentFurniture.x, CurrentFurniture.y, CurrentFurniture.z)
			SubActor.setposition(CurrentFurniture.x, CurrentFurniture.y, CurrentFurniture.z)
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
