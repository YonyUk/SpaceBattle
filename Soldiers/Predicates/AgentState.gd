extends Node

class_name AgentState
# this class defines the internal state of an agent in this game

var Properties = {
	'AutoDefending': false,
	'Attacking': false,
	'Moving': false,
	'Defending': false,
	'CanShoot': false,
	'CanRotate': false,
	'CanHide': false
}

func SetCanShoot(value: bool) -> void:
	Properties['CanShoot'] = value
	pass

func SetCanRotate(value: bool) -> void:
	Properties["CanRotate"] = value
	pass

func SetCanHide(value: bool) -> void:
	Properties["CanHide"] = value
	pass

func SetAutoDefending(value: bool) -> void:
	Properties["AutoDefending"] = value
	pass

func SetAttacking(value: bool) -> void:
	Properties["Attacking"] = value
	pass

func SetMoving(value: bool) -> void:
	Properties["Moving"] = value
	pass

func SetDefending(value: bool) -> void:
	Properties["Defending"] = value
	pass

func SetProperty(property:String,value:bool) -> void:
	if property in Properties.keys():
		Properties[property] = value
		pass
	pass

func Moving() -> bool:
	return Properties['Moving']

func AutoDefending() -> bool:
	return Properties['AutoDefending']

func Attacking() -> bool:
	return Properties['Attacking']

func Defending() -> bool:
	return Properties['Defending']

func CanShoot() -> bool:
	return Properties['CanShoot']

func CanRotate() -> bool:
	return Properties['CanRotate']

func CanHide() -> bool:
	return Properties['CanHide']
