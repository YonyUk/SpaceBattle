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
	'defend':false,
	'enemys_seen':false,
	'enemy_close':false,
	'bullet_seen':false,
	'soldier_shooted':false,
	'bullet_close':false
}

var beliefs = ['flag_found','under_attack','flag_in_target_pos','enemys_seen','enemy_close']
var desires = ['find_flag','capture_flag','defend_flag','cover_space','gain_supremacy']
var intentions = ['search_flag','get_flag','attack','defend']
var perceptions = ['bullet_seen','soldier_shooted','bullet_close']

var beliefs_rules_generator = {
	'bullet_seen':
		['enemy_close'],# se refiere a un enemigo cerca de alguna de las naves
	'soldier_shooted':
		['enemy_close','flag_in_target_pos','enemys_seen'],
	# se refiere a balas cerca de la bandera
	'bullet_close':['under_attack']
}

var desires_rules = {
	'find_flag':[
		['!flag_found','!under_attack']
	],
	'capture_flag':[
		['flag_found'],
		['flag_in_target_pos','!defend']
	],
	'defend_flag':[
		['under_attack']
	],
	'cover_space':[
		['!under_attack','search_flag'],
		['!defend'],
		['enemy_close']
	],
	'gain_supremacy':[
		['!under_attack','enemys_seen'],
		['!search_flag','!get_flag','!defend','enemys_seen']
	]
}

var intentions_rules = {
	'search_flag':[
		['!under_attack','find_flag']
	],
	'get_flag':[
		['flag_in_target_pos','capture_flag'],
		['flag_in_target_pos','!defend_flag'],
		['flag_in_target_pos','!defend']
	],
	'attack':[
		['!under_attack','enemys_seen'],
		['!under_attack','gain_supremacy'],
	],
	'defend':[
		['under_attack'],
		['defend_flag']
	]
}

var cached_predicates = {}

var priorities = ['defend','get_flag','attack','search_flag']

var Beliefs = []
var Desires = []
var Intentions = []

func _init():
	for belief in beliefs:
		cached_predicates[belief] = funcref(self,belief)
		pass
	for desire in desires:
		cached_predicates[desire] = funcref(self,desire)
		pass
	for intention in intentions:
		cached_predicates[intention] = funcref(self,intention)
		pass
	pass

func _brf() -> void:
	for perception in perceptions:
		if datas[perception]:
			var new_beliefs = beliefs_rules_generator[perception]
			for bel in new_beliefs:
				datas[bel] = true
				pass
			pass
		pass
	pass

func eval_predicate(predicate:String):
	if predicate[0] == '!':
		predicate = predicate.substr(1)
		return not cached_predicates[predicate].call_func()
	return cached_predicates[predicate].call_func()

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
	datas['enemys_seen'] = perception.EnemysSeen()
	datas['bullet_seen'] = perception.BulletsSeen()
	datas['soldier_shooted'] = perception.ShootedSoldiers()
	datas['bullet_close'] = perception.BulletCloseToFlag()
	_brf()
	for bel in beliefs:
		if datas[bel]:
			result.append(bel)
			pass
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
	for intention in priorities:
		if intention in Intentions:
			return intention
		pass
	return 'search_flag'

func ACTION(perception:CommanderPerception) -> String:
	Beliefs = BRF(perception)
	Desires = OPTIONS()
	Intentions = SELECT()
	return FILTER()

func enemy_close() -> bool:
	return datas['enemy_close']

func enemys_seen() -> bool:
	return datas['enemys_seen']

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
