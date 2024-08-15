extends Node

class_name BDIStruct

var datas = {
	'flag_found': false,
	'under_attack':false,
	'flag_in_target_pos':false,
	'find_flag':false,
	'capture_flag':false,
	'defend_flag':false,
	'cover_space':false,
	'gain_supremacy':false,
	'search_flag':false,
	'get_flag':false,
	'attack':false,
	'defend':false
}

var beliefs = ['flag_found','under_attack','flag_in_target_pos']
var desires = ['find_flag','capture_flag','defend_flag','cover_space','gain_supremacy']
var intentions = ['search_flag','get_flag','attack','defend']

var desires_rules = {
	'find_flag':[
		['!flag_found','!under_attack']
	],
	'capture_flag':[
		['flag_found','get_flag'],
		['flag_in_target_pos','!defend']
	],
	'defend_flag':[
		['under_attack']
	],
	'cover_space':[
		['!under_attack','search_flag'],
		['!defend']
	],
	'gain_supremacy':[
		['!under_attack','attack'],
		['!defend','!search_flag'],
		['attack']
	]
}

var intentions_rules = {
	'search_flag':[
		['!under_attack','find_flag','!defend']
	],
	'get_flag':[
		['flag_in_target_pos','capture_flag'],
		['flag_in_target_pos','!defend_flag'],
		['flag_in_target_pos','!defend']
	],
	'attack':[
		['!under_attack','cover_space'],
		['!defend','!under_attack'],
		['!under_attack','gain_supremacy'],
		['!defend','gain_supremacy']
	],
	'defend':[
		['under_attack'],
		['defend']
	]
}

var priorities = ['defend','search_flag','attack','get_flag']

var Beliefs = []
var Desires = []
var Intentions = []

func eval_predicate(predicate:String):
	if predicate[0] == '!':
		predicate = predicate.substr(1)
		var function = funcref(self,predicate)
		return not function.call_func()
	var function = funcref(self,predicate)
	return function.call_func()

func eval_desire_conditions(desire:String) -> bool:
	var conditions = desires_rules[desire]
	for cond in conditions:
		var yes = true
		var r = true
		for c in cond:
			r = r and eval_predicate(c)
			if not r:
				yes = false
				break
			pass
		if not yes:
			continue
		datas[desire] = true 
		return true
	datas[desire] = false
	return false

func eval_intention_conditions(intention:String) -> bool:
	var conditions  = intentions_rules[intention]
	for cond in conditions:
		var yes = true
		var r = true
		for c in cond:
			r = r and eval_predicate(c)
			if not r:
				yes = false
				break
			pass
		if not yes:
			continue
		datas[intention] = true
		return true
	datas[intention] = false
	return false

func BRF(perception:CommanderPerception) -> Array:
	var result = []
	datas['flag_found'] = perception.FlagFound()
	datas['under_attack'] = perception.UnderAttack()
	datas['flag_in_target_pos'] = perception.FlagInTargetPos()
	if perception.FlagFound():
		result.append('flag_found')
		pass
	if perception.UnderAttack():
		result.append('under_attack')
		pass
	if perception.FlagInTargetPos():
		result.append('flag_in_target_pos')
		pass
	return result

func OPTIONS() -> Array:
	var result = []
	for desire in desires:
		if eval_desire_conditions(desire):
			result.append(desire)
			pass
		pass
	return result

func SELECT() -> Array:
	var result = []
	for intention in intentions:
		if eval_intention_conditions(intention):
			result.append(intention)
			pass
		pass
	return result

func FILTER() -> String:
	for intention in intentions:
		if intention in Intentions:
			return intention
		pass
	return 'search_flag'

func ACTION(perception:CommanderPerception) -> String:
	Beliefs = BRF(perception)
	Desires = OPTIONS()
	Intentions = SELECT()
	return FILTER()

func defend() -> bool:
	return datas['defend']

func attack() -> bool:
	return datas['attack']

func get_flag() -> bool:
	return datas['get_flag']

func search_flag() -> bool:
	return datas['search_flag']

func gain_supremacy() -> bool:
	return datas['gain_supremacy']

func cover_space() -> bool:
	return datas['cover_space']

func defend_flag() -> bool:
	return datas['defend_flag']

func capture_flag() -> bool:
	return datas['capture_flag']

func flag_found() -> bool:
	return datas['flag_found']

func under_attack() -> bool:
	return datas['under_attack']

func find_flag() -> bool:
	return datas['find_flag']

func flag_in_target_pos() -> bool:
	return datas['flag_in_target_pos']
