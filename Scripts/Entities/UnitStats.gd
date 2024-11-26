extends Resource
class_name UnitStats

## Name Unit
@export var unit_name: String = ""
## Type Unit (leader, worker, mercenary, scout, warrior, mage, ultimate)
@export var unit_type: String = ""
## Health
@export var health: int = 100
## Max Health
@export var health_max: int = 100
## Mana
@export var mana: int = 0
## Max Mana
@export var mana_max: int = 0
## Movement
@export var movement: int = 8
## Damage min
@export var damage_min: int = 0
## Damage max
@export var damage_max: int = 0
## Rate of fire | 0 - No Attack , 1 - Once , 2 - Slow , 3 - Average, 4 - Fast
@export var rate_of_fire: int = 0
## Hit mode | Base hit is 70, this is a unit modifier
@export var hit_mod: int = 0
## Range | 0 is close combat
@export var hit_range: int = 0
## Visibility | 0 = Disrupt Fog of War for all , 1 - Normal , 2 - Masked, 3 - Disguised , 4 - Hidden , 5 - Invisible
@export var visibility: int = 1
## Unit visual range
@export var sight_range: int = 0
## Capabilities | "leader" (Access to leader capabilites) , "must_not_die" (Game Over if unit died) , "worker:vital|basic|expert" (Can build and collect resources - Vital -> Vital Buildings only, Basic -> Basics Buildings only, Expert : Advanced Buildings ) , "sapper:x" (* x damage at buildings), "spells" (Can study and launch racial spells) , "lower_influence" (Loose periodicaly clan influance) , "passive" (Just walk around), "structure" (Can only damage structures), "organic" (Can only damage units), "rise" (Yavaun is angry) , "eat gold" (Steals resources) , "water" (Can be only water) , "e-field" (IEM field, biounit is disabled around) , "e-unit" (Unit can be disabled by e-field) , "hide:ruin|tree" (Take ruin or tree apparence) , "clairvoyant" (See even Invisible) , "influence:join|go:x" (Gain x influence when join, Loose x influence when go or died), "explosing_death:x" (X damage around when death) , "reduce_cost:unit_type:x" (Reduce of x % unit type cost when ingame) , "fly" (Can move over water and void) 
@export var special: String = ""
## Number of items than the unit can carry
@export var carry_item: int = 1
## Armour of the unit
@export var armour: int = 0

## Faction of unit
@export var faction: String = ""

## Image of the unit (for UI preview)
@export var unit_image: Texture = null

## Selection sound of the unit
@export var unit_sound_selection_path: String = ""
