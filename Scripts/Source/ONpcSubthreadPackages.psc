Scriptname ONpcSubthreadPackages extends Quest

Function TravelToActor(Actor Act, Actor TargetActor, ReferenceAlias Navigator1, ReferenceAlias Navigator2, ReferenceAlias NavigationTarget)
	act.StartCombat(act)
	TargetActor.StartCombat(TargetActor)

	NavigationTarget.ForceRefTo(TargetActor)

	Navigator1.ForceRefTo(Act)
	Navigator2.ForceRefTo(TargetActor)

	OSexIntegrationMain.Console("Nav1 is " + Navigator1.getreference())
	OSexIntegrationMain.Console("Nav2 is " + Navigator2.getreference())
	OSexIntegrationMain.Console("Target is " + NavigationTarget.getreference())

	Act.EvaluatePackage()
	TargetActor.EvaluatePackage()
	OSexIntegrationMain.Console("Current " + Act.GetActorBase().GetName() + " package is " + Act.GetCurrentPackage())
EndFunction

Function TravelToFurniture(Actor Act, Actor Act2, ObjectReference NavigationTargetRef, ReferenceAlias Navigator1, ReferenceAlias Navigator2, ReferenceAlias NavigationTarget)
	NavigationTarget.ForceRefTo(NavigationTargetRef)
	
	Navigator1.ForceRefTo(Act)
	Navigator2.ForceRefTo(Act2)

	OSexIntegrationMain.Console("Nav1 is " + Navigator1.getreference())
	OSexIntegrationMain.Console("Nav2 is " + Navigator2.getreference())
	OSexIntegrationMain.Console("Target is " + NavigationTarget.getreference())
	OSexIntegrationMain.Console("Evaluating package for Actor " + Act.GetActorBase().GetName())

	Act.EvaluatePackage()
	Act2.EvaluatePackage()
	OSexIntegrationMain.Console("Current " + Act.GetActorBase().GetName() + " package is " + Act.GetCurrentPackage())
EndFunction

Function ClearAliases(Actor Act, Actor Act2, ReferenceAlias Navigator1, ReferenceAlias Navigator2, ReferenceAlias NavigationTarget)
	Navigator1.clear()
	Navigator2.clear()
	NavigationTarget.clear()

	Act.EvaluatePackage()
	Act2.EvaluatePackage()
EndFunction
