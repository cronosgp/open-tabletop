extends RefCounted
## Current Support targets from shared and source-reviewed Chapter books; Legends endpoints stay excluded.
const BODYGUARDS := {
	"crusade-ancient": ["crusader-squad", "sword-brethren-squad"],
	"ravenwing-command-squad": ["outrider-squad", "ravenwing-black-knights"],
 "kaius-konorius": ["bladeguard-veteran-squad", "sternguard-veteran-squad", "assault-intercessor-squad", "victrix-honour-guard"],
	"lieutenant-in-phobos-armour": ["infiltrator-squad", "eliminator-squad", "incursor-squad", "reiver-squad", "spectrus-kill-team", "wolf-scouts"],
	"ancient-in-terminator-armour": ["terminator-squad", "terminator-assault-squad", "deathwing-knights", "deathwing-terminator-squad", "deathwatch-terminator-squad", "wolf-guard-terminators"],
	"apothecary": ["bladeguard-veteran-squad", "intercessor-squad", "assault-intercessor-squad", "infernus-squad", "hellblaster-squad", "sternguard-veteran-squad", "company-heroes", "desolation-squad", "inner-circle-companions", "deathwatch-veterans", "fortis-kill-team", "decimus-kill-team", "crusader-squad", "sword-brethren-squad"],
	"sanguinary-priest": ["assault-intercessor-squad", "bladeguard-veteran-squad", "company-heroes", "desolation-squad", "hellblaster-squad", "infernus-squad", "intercessor-squad", "sternguard-veteran-squad"],
	"lieutenant": ["bladeguard-veteran-squad", "intercessor-squad", "assault-intercessor-squad", "infernus-squad", "hellblaster-squad", "sternguard-veteran-squad", "company-heroes", "desolation-squad", "inner-circle-companions", "deathwatch-veterans", "fortis-kill-team", "decimus-kill-team", "crusader-squad", "sword-brethren-squad"],
	"judiciar": ["bladeguard-veteran-squad", "intercessor-squad", "assault-intercessor-squad", "infernus-squad", "sternguard-veteran-squad", "inner-circle-companions", "deathwatch-veterans", "fortis-kill-team", "decimus-kill-team", "crusader-squad", "sword-brethren-squad"],
	"apothecary-biologis": ["aggressor-squad", "heavy-intercessor-squad", "eradicator-squad-with-heavy-bolters", "eradicator-squad-with-melta-rifles", "indomitor-kill-team"],
	"ancient": ["intercessor-squad", "assault-intercessor-squad", "infernus-squad", "hellblaster-squad", "sternguard-veteran-squad", "desolation-squad", "inner-circle-companions", "deathwatch-veterans", "fortis-kill-team", "decimus-kill-team", "sword-brethren-squad", "crusader-squad"],
	"castellan": ["assault-intercessor-squad", "bladeguard-veteran-squad", "company-heroes", "infernus-squad", "intercessor-squad", "sternguard-veteran-squad", "crusader-squad", "sword-brethren-squad"],
 "bladeguard-ancient": ["bladeguard-veteran-squad"],
 "wardens-of-ultramar": ["intercessor-squad", "bladeguard-veteran-squad", "sternguard-veteran-squad", "assault-intercessor-squad"]}
const CONDITIONAL_BODYGUARDS := {"cato-sicarius": ["victrix-honour-guard"]}

static func is_support_identity(identity: String, calgar_in_army: bool) -> bool:
 return identity in BODYGUARDS or (calgar_in_army and identity in CONDITIONAL_BODYGUARDS)

static func matching_error(entries: Array) -> String:
 var supports: Array[String] = []
 var bodies: Array[String] = []
 var calgar_in_army := false
 for entry: Dictionary in entries:
  if entry.definition_id.get_slice(":", 3) == "marneus-calgar": calgar_in_army = true
 for entry: Dictionary in entries:
  var slug: String = entry.definition_id.get_slice(":", 3)
  for copy in range(int(entry.copies)):
   if slug == "cato-sicarius":
    if calgar_in_army: supports.append(slug)
   elif slug in BODYGUARDS: supports.append(slug)
   else: bodies.append(slug)
 # A single Apothecary/Lieutenant pair may occupy one bodyguard assignment.
 for pairs in range(mini(supports.count("apothecary"), supports.count("lieutenant")) + 1):
  var trial: Array[String] = supports.duplicate()
  for pair in range(pairs):
   trial.erase("apothecary")
   trial.erase("lieutenant")
   trial.append("apothecary-and-lieutenant")
  var matching := {}
  var fits := true
  for index in range(trial.size()):
   if not _augment(index, trial, bodies, matching, {}):
    fits = false
    break
  if fits: return ""
 return "Every Support needs an eligible admitted bodyguard; only the Apothecary/Lieutenant pair may share a Support assignment."

static func links(source: String) -> Array:
 if source == "apothecary-and-lieutenant": return BODYGUARDS.apothecary
 if CONDITIONAL_BODYGUARDS.has(source): return CONDITIONAL_BODYGUARDS[source]
 return BODYGUARDS[source]

static func compatible(existing: Array[String], incoming: String) -> bool:
 if existing.is_empty(): return true
 return existing.size() == 1 and ((existing[0] == "lieutenant" and incoming == "apothecary") or (existing[0] == "apothecary" and incoming == "lieutenant"))

static func _augment(index: int, supports: Array[String], bodies: Array[String], matching: Dictionary, seen: Dictionary) -> bool:
 for slot in range(bodies.size()):
  if seen.has(slot) or bodies[slot] not in links(supports[index]): continue
  seen[slot] = true
  if not matching.has(slot) or _augment(matching[slot], supports, bodies, matching, seen):
   matching[slot] = index
   return true
 return false
