extends RefCounted
## Shared, read-only leader identity facts used by rules and attachment setup.

## Leader definition_id -> bodyguard definition_ids they may lead (provisional).
const ATTACHMENTS := {
	"40kdc:11e:adeptus-astartes:captain": ["40kdc:11e:adeptus-astartes:intercessor-squad", "40kdc:11e:adeptus-astartes:terminator-squad"],
	"40kdc:11e:adeptus-astartes:kaius-konorius": ["40kdc:11e:adeptus-astartes:sternguard-veteran-squad", "40kdc:11e:adeptus-astartes:bladeguard-veteran-squad", "40kdc:11e:adeptus-astartes:assault-intercessor-squad", "40kdc:11e:adeptus-astartes:victrix-honour-guard"],
	"40kdc:11e:adeptus-astartes:marneus-calgar": ["40kdc:11e:adeptus-astartes:bladeguard-veteran-squad", "40kdc:11e:adeptus-astartes:terminator-assault-squad", "40kdc:11e:adeptus-astartes:infernus-squad", "40kdc:11e:adeptus-astartes:vanguard-veteran-squad", "40kdc:11e:adeptus-astartes:intercessor-squad", "40kdc:11e:adeptus-astartes:heavy-intercessor-squad", "40kdc:11e:adeptus-astartes:terminator-squad", "40kdc:11e:adeptus-astartes:assault-intercessor-squad", "40kdc:11e:adeptus-astartes:aggressor-squad", "40kdc:11e:adeptus-astartes:sternguard-veteran-squad", "40kdc:11e:adeptus-astartes:company-heroes", "40kdc:11e:adeptus-astartes:victrix-honour-guard", "40kdc:11e:adeptus-astartes:eradicator-squad-with-heavy-bolters", "40kdc:11e:adeptus-astartes:eradicator-squad-with-melta-rifles"],
	"40kdc:11e:adeptus-astartes:kor-sarro-khan": ["40kdc:11e:adeptus-astartes:bladeguard-veteran-squad", "40kdc:11e:adeptus-astartes:sternguard-veteran-squad", "40kdc:11e:adeptus-astartes:intercessor-squad", "40kdc:11e:adeptus-astartes:assault-intercessor-squad", "40kdc:11e:adeptus-astartes:company-heroes", "40kdc:11e:adeptus-astartes:vanguard-veteran-squad"],
	"40kdc:11e:necrons:overlord": ["40kdc:11e:necrons:necron-warriors", "40kdc:11e:necrons:immortals"],
}

static func army_has_calgar(state: Dictionary, player: int) -> bool:
	for model: int in state.get("units", {}):
		if state.units[model].get("owner", -1) == player and str(state.units[model].get("definition_id", "")).get_slice(":", 3) == "marneus-calgar": return true
	return false
