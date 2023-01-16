scriptname ONpcMMSpellAliasScript extends ReferenceAlias

actor[] actorsForScene


event OnInit()
	OnPlayerLoadGame()
endEvent


event OnPlayerLoadGame()
	if !PlayerRef.HasSpell(MatchMakerSpellTarget)
		PlayerRef.AddSpell(MatchMakerSpellTarget, true)
	endIf
	if !PlayerRef.HasSpell(MatchMakerSpellSelf)
		PlayerRef.AddSpell(MatchMakerSpellSelf, true)
	endIf

	OStim = OUtils.GetOStim()
	actorsForScene = PapyrusUtil.ResizeActorArray(actorsForScene, 0)
endEvent


event OnUpdate()
	StartScene()
endEvent


int function RegisterActor(actor act)
	; 0 -> failure
	; 1 -> success
	; 2 -> removed
	int status = 0

	if !act.isChild() && act.HasKeywordString("ActorTypeNPC")
		if PapyrusUtil.CountActor(actorsForScene, act) == 0
			if actorsForScene.Length < 3
				actorsForScene = PapyrusUtil.PushActor(actorsForScene, act)
				status = 1
			endif
		else
			actorsForScene = PapyrusUtil.RemoveActor(actorsForScene, act)
			status = 2
		endif
	endif

	if actorsForScene.Length > 1
		RegisterForSingleUpdate(5.0)
	endif

	return status
endFunction


function StartScene()
	if actorsForScene.length < 2
		return
	endif

	if PapyrusUtil.CountActor(actorsForScene, PlayerRef) > 0
		if actorsForScene.Length == 2
			OStim.StartScene(actorsForScene[0], actorsForScene[1])
		elseif actorsForScene.Length == 3
			OStim.StartScene(actorsForScene[0], actorsForScene[1], zThirdActor = actorsForScene[2])
		endif
	else
		; we must reorder actors properly for NPC scenes
		actor domActor = actorsForScene[0]
		actor subActor = actorsForScene[1]
		actor thirdActor

		If (OStim.AppearsFemale(domActor) && !OStim.AppearsFemale(subActor))
			domActor = actorsForScene[1]
			subActor = actorsForScene[0]
		EndIf
	
		If actorsForScene.Length == 3
			If OStim.AppearsFemale(DomActor) && !OStim.AppearsFemale(actorsForScene[2])
				thirdActor = domActor
				domActor = actorsForScene[2]
			EndIf
		EndIf

		if actorsForScene.Length == 2
			OStim.GetUnusedSubthread().StartSubthreadScene(domActor, subActor)
		elseif actorsForScene.Length == 3
			OStim.GetUnusedSubthread().StartSubthreadScene(domActor, subActor, zThirdActor = thirdActor)
		endif
	endif

	actorsForScene = PapyrusUtil.ResizeActorArray(actorsForScene, 0)
endFunction


Actor property PlayerRef auto

Spell property MatchMakerSpellTarget auto
Spell property MatchMakerSpellSelf auto

OSexIntegrationMain property OStim auto
