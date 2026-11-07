Scriptname ONpcSubthread extends ReferenceAlias

; ============================================================
; Runtime state
; ============================================================

int ONpcThreadID
bool ONpcThreadInUse

Actor DomActor
Actor SubActor
Actor ThirdActor

bool AlternativeBedSearchUsed
bool IsEnemyScene
bool IsFollowerScene

bool SceneCountersReserved

ObjectReference CurrentFurniture

int CurrentOStimSubthreadID

; ============================================================
; Properties
; ============================================================

OSexIntegrationMain property OStim auto

ReferenceAlias property Nav1 auto
ReferenceAlias property Nav2 auto
ReferenceAlias property Target auto

Actor property PlayerRef auto

ONpcMain property ONpc auto

ONpcSubthreadPackages property SubthreadPackages auto

Float Property TMSFurnitureFinalCheckDistance = 192.0 Auto

Float Property CombatStopDistance = 4096.0 Auto


; ============================================================
; Events / lifecycle
; ============================================================

Event OnInit()
	ONpcThreadID = GetID()
	OStim = OUtils.GetOStim()
EndEvent


Event NpcSceneStart(string eventname, string strarg, float numarg, form sender)
	if numarg == CurrentOStimSubthreadID
		int threadID = CurrentOStimSubthreadID

		JArray.addForm(ONpc.NPCsHadSexThisNight, DomActor)
		JArray.addForm(ONpc.NPCsHadSexThisNight, SubActor)

		if ThirdActor
			JArray.addForm(ONpc.NPCsHadSexThisNight, ThirdActor)
		endif

		; Watch the scene while it runs. threadID is captured so this loop can't end up watching
		; a newer scene if this subthread gets reused while it's waiting.
		while ONpcThreadInUse && threadID == CurrentOStimSubthreadID && OThread.IsRunning(threadID)
			if ShouldStopScene()
				OThread.Stop(threadID)
				return
			endif

			Utility.Wait(2)
		endwhile
	endif
EndEvent


Event NpcSceneEnd(string eventname, string strarg, float numarg, form sender)
	if numarg == CurrentOStimSubthreadID
		SceneEndProcedures()
	endif
EndEvent


; ============================================================
; Scene setup / start
; ============================================================

Function StartScene()
	; Do every furniture gate before registering OStim events or starting the builder.
	; This avoids stale ostim_thread_start callbacks from older/other threads making the log order confusing.
	if !TMS_RunFurnitureGate("pre-start gate")
		SceneEndProcedures()
		return
	endif

	Actor[] actors = new Actor[2]
	actors[0] = DomActor
	actors[1] = SubActor

	int BuilderID = OThreadBuilder.Create(actors)

	if CurrentFurniture == none
		OThreadBuilder.NoFurniture(BuilderID)
	else
		if !TMS_RunFurnitureGate("set-furniture gate")
			SceneEndProcedures()
			return
		endif

		if CurrentFurniture == none
			OThreadBuilder.NoFurniture(BuilderID)
		else
			OThreadBuilder.SetFurniture(BuilderID, CurrentFurniture)
		endif
	endif

	if !CheckActorsStillValid()
		SceneEndProcedures()
		return
	endif

	RegisterForModEvent("ostim_thread_start", "NpcSceneStart")
	RegisterForModEvent("ostim_thread_end", "NpcSceneEnd")

	CurrentOStimSubthreadID = OThreadBuilder.Start(BuilderID)

	if CurrentOStimSubthreadID < 0
		SceneEndProcedures()
		return
	endif

	SceneCountersReserved = false
EndFunction


Function SetupScene(Actor dom, Actor sub, ObjectReference furnitureObj, bool alternativeBedSearch, Actor third = none)
	ONpcThreadInUse = true
	CurrentOStimSubthreadID = -1

	DomActor = dom
	SubActor = sub
	ThirdActor = third

	AlternativeBedSearchUsed = alternativeBedSearch

	CurrentFurniture = furnitureObj

	IsEnemyScene = false
	IsFollowerScene = false

	; The per-night counters are reserved here so concurrent setups can't exceed the limits,
	; and refunded in SceneEndProcedures if the scene never starts.
	; Otherwise every failed attempt used up a slot, and followers could be locked out for the whole night.
	if ONpc.IsEnemy(DomActor) && ONpc.IsEnemy(SubActor)
		IsEnemyScene = true
		ONpc.EnemyScenesThisNight += 1
		ONpc.CurrentLocationEnemyScene = false
	endif

	if ONpc.IsFollower(DomActor) || ONpc.IsFollower(SubActor)
		ONpc.FollowerScenesThisNight += 1
		IsFollowerScene = true
	endif

	SceneCountersReserved = IsEnemyScene || IsFollowerScene

	RegisterForSingleUpdate(0.01)
EndFunction


; ============================================================
; Scene flow
; ============================================================

Event onUpdate()
	if !ONpc.TravelToLocation || (IsEnemyScene && !ONpc.EnemiesTravelToLocation)
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

				if numberLoops >= 10
					SceneEndProcedures()
					return
				endif

				Utility.Wait(1)
			endwhile

			Utility.Wait(1.5)
		endif

		DomActor.setposition(SubActor.x, SubActor.y, SubActor.z)

		if CurrentFurniture != none

			if CurrentFurniture != none
				DomActor.setposition(CurrentFurniture.x, CurrentFurniture.y, CurrentFurniture.z)
				SubActor.setposition(CurrentFurniture.x, CurrentFurniture.y, CurrentFurniture.z)
			endif
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


			if CurrentFurniture != none
				DomActor.setposition(CurrentFurniture.x, CurrentFurniture.y, CurrentFurniture.z)
				SubActor.setposition(CurrentFurniture.x, CurrentFurniture.y, CurrentFurniture.z)
			endif
		endif

		if !IsFollowerScene && ONpc.StopWhenFound && isFound()
			SceneEndProcedures()
			return
		endif

		StartScene()
	endif
EndEvent


; ============================================================
; TMS Furniture Guard gates
; ============================================================

Function TMS_FinalTrace(String msg, Bool ForceLog = false)
	if ForceLog
		Debug.Trace("[TMS ONPC FurnitureGuard] " + msg)
		return
	endif

	if ONpc && ONpc.TMSFurnitureGuardDebug
		Debug.Trace("[TMS ONPC FurnitureGuard] " + msg)
	endif
EndFunction


Float Function TMS_GetFinalCheckDistance()
	if TMSFurnitureFinalCheckDistance <= 0.0
		return 192.0
	endif

	return TMSFurnitureFinalCheckDistance
EndFunction


Bool Function TMS_CanFallbackToNoFurniture()
	if AlternativeBedSearchUsed
		return false
	endif

	if ONpc.ScenesStartIn == ONpc.AnyFurniture || ONpc.ScenesStartIn == ONpc.BedsOnly
		if IsEnemyScene && ONpc.EnemiesIgnoreScenesStartInRules
			return true
		endif

		return false
	endif

	return true
EndFunction


Function TMS_ReleaseCurrentFurnitureLock()
	if ONpc.JArraysCreated && CurrentFurniture
		JArray.EraseForm(ONpc.FurnituresInUse, CurrentFurniture)
	endif
EndFunction


Bool Function TMS_RunFurnitureGate(String StageName)
	if !CurrentFurniture
		TMS_FinalTrace(StageName + ": no furniture, allow no-furniture path")
		return true
	endif

	if !DomActor || !SubActor
		TMS_FinalTrace(StageName + ": missing actors, abort", true)
		return false
	endif

	Float finalCheckDistance = TMS_GetFinalCheckDistance()
	Bool closeEnough = false

	if DomActor.GetDistance(CurrentFurniture) <= finalCheckDistance
		closeEnough = true
	endif

	if SubActor.GetDistance(CurrentFurniture) <= finalCheckDistance
		closeEnough = true
	endif

	if ThirdActor && ThirdActor.GetDistance(CurrentFurniture) <= finalCheckDistance
		closeEnough = true
	endif

	if !closeEnough
		TMS_FinalTrace(StageName + ": early safety check, actors not close yet " + CurrentFurniture)
	else
		TMS_FinalTrace(StageName + ": checking furniture " + CurrentFurniture)
	endif

	if !ONpc.TMS_IsFurnitureUnsafeForSceneStart(CurrentFurniture, DomActor, SubActor, ThirdActor)
		TMS_FinalTrace(StageName + ": furniture still available " + CurrentFurniture)
		return true
	endif

	TMS_FinalTrace(StageName + ": furniture blocked or occupied " + CurrentFurniture, true)

	TMS_ReleaseCurrentFurnitureLock()

	if TMS_CanFallbackToNoFurniture()
		TMS_FinalTrace(StageName + ": fallback to ONPC no-furniture path", true)
		CurrentFurniture = None
		return true
	endif

	TMS_FinalTrace(StageName + ": furniture required, abort subthread", true)
	return false
EndFunction


Bool Function TMS_PreStartFurnitureGate()
	return TMS_RunFurnitureGate("pre-start gate")
EndFunction


Bool Function TMS_HandleFinalFurnitureCheck()
	return TMS_RunFurnitureGate("furniture gate")
EndFunction


; ============================================================
; Cleanup
; ============================================================

Function SceneEndProcedures()
	SubthreadPackages.ClearAliases(DomActor, SubActor, Nav1, Nav2, Target)

	UnregisterForModEvent("ostim_thread_start")
	UnregisterForModEvent("ostim_thread_end")

	; do this check for edge case where NPC OStim scene ends after night has ended, and thus JArrays are already cleared
	if ONpc.JArraysCreated
		JArray.EraseForm(ONpc.NPCsInScene, DomActor)
		JArray.EraseForm(ONpc.NPCsInScene, SubActor)
		JArray.EraseForm(ONpc.NPCsInScene, ThirdActor)

		JArray.EraseForm(ONpc.FurnituresInUse, CurrentFurniture)
	endif

	RefundSceneCounters()

	CurrentOStimSubthreadID = -1
	ONpcThreadInUse = false
	ONpc.activeScenes -= 1
EndFunction


Function RefundSceneCounters()
	if !SceneCountersReserved
		return
	endif

	SceneCountersReserved = false

	; the counters may have been reset by the night ending while this setup was running
	if IsFollowerScene && ONpc.FollowerScenesThisNight > 0
		ONpc.FollowerScenesThisNight -= 1
	endif

	if IsEnemyScene && ONpc.EnemyScenesThisNight > 0
		ONpc.EnemyScenesThisNight -= 1
	endif
EndFunction


; ============================================================
; Travel / validation helpers
; ============================================================

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

		if stuckTimer >= 20
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
	if !TMS_RunFurnitureGate("go-to before travel")
		return false
	endif

	if !CurrentFurniture
		return true
	endif

	SubthreadPackages.TravelToFurniture(DomActor, SubActor, CurrentFurniture, Nav1, Nav2, Target)

	int stuckTimer = 0

	while CurrentFurniture && DomActor.GetDistance(CurrentFurniture) > 128 && SubActor.GetDistance(CurrentFurniture) > 128
		if !CheckActorsStillValid()
			return false
		endif

		stucktimer += 1

		if stucktimer >= 20
			TMS_FinalTrace("go-to after travel: travel timed out, let later gate handle it " + CurrentFurniture, true)
			return true
		else
			utility.wait(1)
		endif
	endwhile

	if !TMS_RunFurnitureGate("go-to after travel")
		return false
	endif

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


bool Function CheckActorsAreInDialogue()
	return DomActor.IsInDialogueWithPlayer() || SubActor.IsInDialogueWithPlayer()
EndFunction


bool Function CheckActorsStillValid()
	return CheckActorsStillLoaded() && CheckActorsStillAlive() && CheckActorsNotInScenes() && !CheckActorsAreInCombatState() && !CheckActorsAreInDialogue()
EndFunction


bool Function IsFound()
	if PlayerRef.isdetectedby(DomActor) && (PlayerRef.haslos(DomActor) || DomActor.haslos(PlayerRef))
		return true
	endif
	return false
EndFunction


; OStim already stops a scene when one of its actors IsInCombat(). This also covers
; combat happening around the scene that hasn't pulled the scene actors in
bool Function IsCombatNearScene()
	if DomActor.GetCombatState() != 0 || SubActor.GetCombatState() != 0 || (ThirdActor && ThirdActor.GetCombatState() != 0)
		return true
	endif

	return PlayerRef.IsInCombat() && DomActor.GetDistance(PlayerRef) <= CombatStopDistance
EndFunction


bool Function ShouldStopScene()
	if IsCombatNearScene()
		return true
	endif

	return !IsFollowerScene && ONpc.StopWhenFound && IsFound()
EndFunction


Bool Function IsThreadInUse()
	return ONpcThreadInUse
EndFunction
