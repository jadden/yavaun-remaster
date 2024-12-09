extends Resource
class_name UnitStats

@export_group("General Informations")
@export var unit_name: String = "" ## Name Unit
@export var unit_type: String = "" ## Type Unit (leader, worker, mercenary, scout, warrior, mage, ultimate)

@export_group("Health and Mana")
@export var health: int = 100 ## Health
@export var health_max: int = 100 ## Max Health
@export var mana: int = 0 ## Mana
@export var mana_max: int = 0 ## Max Mana

@export_group("Movement and Combat")

@export var movement: int = 8 ## Movement
@export var damage_min: int = 0 ## Damage min
@export var damage_max: int = 0 ## Damage max
@export var rate_of_fire: int = 0 ## Rate of fire | 0 - No Attack , 1 - Once , 2 - Slow , 3 - Average, 4 - Fast
@export var hit_mod: int = 0 ## Hit mode | Base hit is 70, this is a unit modifier
@export var hit_range: int = 0 ## Range | 0 is close combat

@export_group("Visibility and Sight")
@export var visibility: int = 1 ## Visibility | 0 = Disrupt Fog of War for all , 1 - Normal , 2 - Masked, 3 - Disguised , 4 - Hidden , 5 - Invisible
@export var sight_range: int = 0 ## Unit visual range

@export_group("Capabilities and Special Traits")
@export var special: String = "" ## Capabilities | "leader" (Access to leader capabilites) , "must_not_die" (Game Over if unit died) , "worker:vital|basic|expert" (Can build and collect resources - Vital -> Vital Buildings only, Basic -> Basics Buildings only, Expert : Advanced Buildings ) , "sapper:x" (* x damage at buildings), "spells" (Can study and launch racial spells) , "lower_influence" (Loose periodicaly clan influance) , "passive" (Just walk around), "structure" (Can only damage structures), "organic" (Can only damage units), "rise" (Yavaun is angry) , "eat gold" (Steals resources) , "water" (Can be only water) , "e-field" (IEM field, biounit is disabled around) , "e-unit" (Unit can be disabled by e-field) , "hide:ruin|tree" (Take ruin or tree apparence) , "clairvoyant" (See even Invisible) , "influence:join|go:x" (Gain x influence when join, Loose x influence when go or died), "explosing_death:x" (X damage around when death) , "reduce_cost:unit_type:x" (Reduce of x % unit type cost when ingame) , "fly" (Can move over water and void) 

@export_group("Inventory and Defence")
@export var carry_item: int = 1 ## Number of items than the unit can carry
@export var armour: int = 0 ## Armour of the unit

@export_group("Faction and Appearance")
@export var faction: String = "" ## Faction of unit
@export var unit_image: Texture = null ## Image of the unit (for UI preview)

@export_group("Audio")
@export var unit_sound_selection_path: String = "" ## Selection sound of the unit

func has_property(prop_name: String) -> bool:
	for prop in self.get_property_list():
		if prop.name == prop_name:
			return true
	return false
