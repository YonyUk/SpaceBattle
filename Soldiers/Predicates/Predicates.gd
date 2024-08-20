extends Node

class_name Predicates
# this class encapsules the reasoning procedure of an agent

var DeductionRules = {
	"AutoDefending":["LowLifePoints","HasBeenShooted,HasNoSeenEnemys"],
	"Defending":["CloseTo,!Attacking"],
	"Moving":["!OnPosition"],
	"CanRotate":["See"],
	"CanShoot":["See"],
	"CanHide":["AutoDefending,!See"],
	"Attacking":["!AutoDefending,See"]
}

var CachedPredicates = {}

var PredicatesCaller = {}

func _init():
	for value in DeductionRules.keys():
		CachedPredicates[value] = GetFuncRerences(DeductionRules[value])
		PredicatesCaller[value] = funcref(self,value)
		pass
	pass

# gets the func references for all the functions named in the deduction rule
func GetFuncRerences(predicates:Array) -> Dictionary:
	var result_conditions = []
	for conditions in predicates:
		var condition = {}
		var functions_names = conditions.split(',')
		for function in functions_names:
			if function[0] == '!':
				var function_name = function.substr(1)
				condition[funcref(self,function_name)] = true
				pass
			else:
				condition[funcref(self,function)] = false
				pass
			pass
		result_conditions.append(condition)
		pass
	return result_conditions

# evals the predicates given a conditions set and a perception
func EvalPredicates(perception:SoldierAgentPerception,conditions:Array) -> bool:
	for predicates in conditions:
		var result = true
		for predicate in predicates.keys():
			var predicate_result = predicate.call_func(perception)
			if predicates[predicate]:
				result = result and not predicate_result
				pass
			else:
				result = result and predicate_result
				pass
			if not result:
				break
			pass
		if result:
			return true
		pass
	return false

func AutoDefending(perception:SoldierAgentPerception) -> bool:
	return EvalPredicates(perception,CachedPredicates['AutoDefending'])

func Defending(perception:SoldierAgentPerception) -> bool:
	return EvalPredicates(perception,CachedPredicates['Defending'])

func Moving(perception:SoldierAgentPerception) -> bool:
	return EvalPredicates(perception,CachedPredicates['Moving'])

func CanShoot(perception:SoldierAgentPerception) -> bool:
	return EvalPredicates(perception,CachedPredicates['CanShoot'])

func CanRotate(perception:SoldierAgentPerception) -> bool:
	return EvalPredicates(perception,CachedPredicates['CanRotate'])

func CanHide(perception:SoldierAgentPerception) -> bool:
	return EvalPredicates(perception,CachedPredicates['CanHide'])

func Attacking(perception:SoldierAgentPerception) -> bool:
	return EvalPredicates(perception,CachedPredicates['Attacking'])

func LowLifePoints(perception:SoldierAgentPerception) -> bool:
	return perception.LifePoints < perception.LowLimitLifePoints

func OnPosition(perception:SoldierAgentPerception) -> bool:
	return perception.CurrentPosition == perception.TargetPosition

func HasBeenShooted(perception:SoldierAgentPerception) -> bool:
	return perception.Shooted

func HasNoSeenEnemys(perception:SoldierAgentPerception) -> bool:
	return perception.EnemysSeen.size() == 0

func CloseTo(perception:SoldierAgentPerception) -> bool:
	return (perception.TargetPosition - perception.CurrentPosition).length_squared() < perception.DefendingDistance

func See(perception:SoldierAgentPerception) -> bool:
	return perception.CanRotate()

# makes the reasoning procedure
func SoldierReasoning(perception:SoldierAgentPerception) -> SoldierAgentPerception:
	for predicate in PredicatesCaller.keys():
		perception.SelfState.SetProperty(predicate,PredicatesCaller[predicate].call_func(perception))
		pass
	return perception

######### completar la implementacion para el enemigo ##########
