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
	OSexIntegrationMain.Console("NPC scene started!!")
	OSexIntegrationMain.Console("IDs are: " + numarg + " and " + CurrentOStimSubthread.id)

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
	OSexIntegrationMain.Console("starting scene!")

	RegisterForModEvent("ostim_subthread_start", "NpcSceneStart")
	RegisterForModEvent("ostim_subthread_end", "NpcSceneEnd")

	CurrentOStimSubthread = OStim.GetUnusedSubthread()

	if !CurrentOStimSubthread || !CheckActorsStillLoaded() || !CurrentOStimSubthread.StartSubthreadScene(DomActor, SubActor, zThirdActor = ThirdActor, furnitureObj = CurrentFurniture)
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
		Invite()

		int stuckTimer = 0

		while CheckActorsStillLoaded() && DomActor.getdistance(SubActor) > 128
			utility.wait(1)
			stuckTimer += 1

			OSexIntegrationMain.Console("Actor " + DomActor.GetActorBase().GetName() + " is travelling to " + SubActor.GetActorBase().GetName())

			if stuckTimer >= 20
				DomActor.setposition(SubActor.x, SubActor.y, SubActor.z)
			endif
		endwhile

		SubthreadPackages.ClearAliases(DomActor, SubActor, Nav1, Nav2, Target)

		if CurrentFurniture != none
			SubthreadPackages.TravelToFurniture(DomActor, SubActor, CurrentFurniture, Nav1, Nav2, Target)

			stucktimer = 0

			while CheckActorsStillLoaded() && (DomActor.getdistance(CurrentFurniture) > 160) || (SubActor.getdistance(CurrentFurniture) > 160)
				utility.wait(1)
				stucktimer += 1
				OSexIntegrationMain.Console("Actor " + DomActor.GetActorBase().GetName() + " is travelling to Furniture")

				if stucktimer >= 20
					DomActor.setposition(CurrentFurniture.x, CurrentFurniture.y, CurrentFurniture.z)
					SubActor.setposition(CurrentFurniture.x, CurrentFurniture.y, CurrentFurniture.z)
				endif
			endwhile

			SubthreadPackages.ClearAliases(DomActor, SubActor, Nav1, Nav2, Target)
		endif

		if ONPC.StopWhenFound && isFound()
			SceneEndProcedures()
			return
		endif

		StartScene()
	endif
EndEvent


Function SceneEndProcedures()
	UnregisterForModEvent("ostim_subthread_start")
	UnregisterForModEvent("ostim_subthread_end")

	OSexIntegrationMain.Console("Running scene end procedures")

	JArray.EraseForm(ONpc.NPCsInScene, DomActor)
	JArray.EraseForm(ONpc.NPCsInScene, SubActor)
	JArray.EraseForm(ONpc.NPCsInScene, ThirdActor)

	JArray.EraseForm(ONpc.FurnituresInUse, CurrentFurniture)

	SubthreadPackages.ClearAliases(DomActor, SubActor, Nav1, Nav2, Target)

	ONpcThreadInUse = false
	ONpc.activeScenes -= 1
EndFunction


Function Invite()
	SubthreadPackages.TravelToActor(DomActor, SubActor, Nav1, Nav2, Target)
	DomActor.SetLookAt(SubActor)
	SubActor.SetLookAt(DomActor)
EndFunction


bool Function CheckActorsStillLoaded()
	return DomActor.Is3DLoaded() && SubActor.Is3DLoaded() && (!ThirdActor || (ThirdActor && !ThirdActor.Is3DLoaded()))
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
