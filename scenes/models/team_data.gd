extends Node

class_name TeamData

enum POSITION {
	FRONT_TOP,
	FRONT_BOT,
	
	BACK_TOP,
	BACK_BOT
}

@export var units: Dictionary[POSITION, BaseUnitData]

func is_all_stunned():
	return units.values().all(func(u): return u.is_stunned())

func get_unit_row(unit: BaseUnitData) -> Array[BaseUnitData]:
	var row: Array[BaseUnitData] = []
	var key: POSITION = units.find_key(unit)
	
	if key == POSITION.FRONT_TOP or key == POSITION.FRONT_BOT:
		if units.has(POSITION.FRONT_TOP):
			row.append(units[POSITION.FRONT_TOP])
		
		if units.has(POSITION.FRONT_BOT):
			row.append(units[POSITION.FRONT_BOT])
	else:
		if units.has(POSITION.BACK_TOP):
			row.append(units[POSITION.BACK_TOP])
		
		if units.has(POSITION.BACK_BOT):
			row.append(units[POSITION.BACK_BOT])
	
	return row
	
func get_unit_col(unit: BaseUnitData) -> Array[BaseUnitData]:
	var col: Array[BaseUnitData] = []
	var key: POSITION = units.find_key(unit)
	
	if key == POSITION.FRONT_TOP or key == POSITION.BACK_TOP:
		if units.has(POSITION.FRONT_TOP):
			col.append(units[POSITION.FRONT_TOP])
		
		if units.has(POSITION.BACK_TOP):
			col.append(units[POSITION.BACK_TOP])
	else:
		if units.has(POSITION.FRONT_BOT):
			col.append(units[POSITION.FRONT_BOT])
		
		if units.has(POSITION.BACK_BOT):
			col.append(units[POSITION.BACK_BOT])
	
	return col

func get_unit_targets(unit: BaseUnitData, area: COMBAT.AREA_TYPE):
	var targets: Array[BaseUnitData]
	
	match area:
		COMBAT.AREA_TYPE.SINGLE:
			targets.append(unit)
		COMBAT.AREA_TYPE.ROW:
			targets = get_unit_row(unit)
		COMBAT.AREA_TYPE.COLUMN:
			targets = get_unit_col(unit)
	
	return targets
