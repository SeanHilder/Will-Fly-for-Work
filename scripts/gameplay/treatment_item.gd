class_name TreatmentItem extends Grabbable
## TreatmentItem — a scanner / medicine / bandage that floats free until
## grabbed. All treatment logic lives on VetPatient (its TreatZone reacts to
## any held TreatmentItem that drifts near it); this script only carries a
## label so the hint UI / future art can tell items apart.

@export var item_type := "scanner"  # "scanner" | "medicine" | "bandage" — placeholder labels
