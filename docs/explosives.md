# Explosives / Grenades — e11 bounded implementation

Reviewed 18 October 2026 against [Wahapedia e11 Core Rules](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/), sections 15.01, 15.05, 10.02, 09.07, 16 and 06.02. Grenades is the same stratagem, not another use. This is core-rule support for the existing fixed profiles; it does not admit additional datasheets or certify a full match.

The generic host-authoritative unit-action workflow offers a living EXPLOSIVES/GRENADES model and an enemy target together. It checks the model's own keyword, visibility and 8-inch base distance. Both units must be unengaged. The friendly unit must be eligible to shoot, must not have advanced and must not have shot. Existing shooting exceptions for Tactical Doctrine and Tactical Mainstay apply through their shared helpers. One CP is spent using existing discounts and per-phase stratagem/unit limits. Explosives does not mark the unit as having shot.

The host rolls six D6; each 4+ creates one mortal wound. The defender chooses recipients using the existing mortal allocation priority: wounded non-Character, other non-Character, wounded Character, other Character. Each wound allows applicable Feel No Pain, with no armour/invulnerable save. Remaining mortals are discarded if the target is destroyed. Slain Awakened Infantry Characters enter the existing Eternal Revenant destruction records; attack-only reactions are not triggered by this non-attack effect.

`core-reaction-stratagems-v2` changes the match content identity. Pending defender choices and roll/allocation records are plain state dictionaries. Old core-v1 matches are not silently promoted. Visibility uses the existing cylindrical tabletop proxy, not imported miniature meshes.

Validation is in `tests/test_explosives.gd`: legal Marine keyword, GRENADES alias, wrong turn, CP, Advance, already shot, Battle-shock, Fall Back, action lock, engaged units, 8-inch boundary, per-phase limits, invalid dice/stale revision rollback, six controlled rolls, Feel No Pain, mandatory defender window, wounded bodyguard priority, Variant state serialization, zero successes and destruction overflow. The serialization test is not a new multi-machine networking or complete saved-match/restart test.

Validation results and hashes are recorded in [the audit](explosives-audit.json): 30 Python checks, startup/import, ten local Godot suites and the existing host/client Reanimation recovery regression passed. That network scenario does not certify Explosives-specific remote play. The GW downloads index was opened, but its rendered content did not expose the core card text; independent GW reconciliation remains unclaimed.

Full-match and army-legality certification remain false. Smokescreen remains unsupported. Crushing Impact / Tank Shock now has bounded current 11e support; see [its implementation scope and pending checks](rules/crushing-impact.md).
