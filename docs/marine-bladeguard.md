Subsequent increment (18 October 2026): [Bladeguard Ancient](marine-ancients.md) is now an additional admitted Support for Bladeguard Veterans; the earlier linked-character boundary below is historical.

# Bladeguard Veteran Squad — current e11 implementation

Reviewed 18 October 2026 against [Wahapedia Bladeguard Veteran Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Bladeguard-Veteran-Squad), datasheet `000000071`, shared book `000000139`, App. Space Marines (11th edition). The joined export revision is 16 October 2026, 21:03:46 GMT+3. Chapter, Legends and Boarding Actions variants remain excluded.

Admitted formations are three models at 90 points or six at 180, each with a 40mm base, M6/T5/Sv3/W3/Ld6/OC1 and a general 4+ invulnerable save. Each carries a Heavy Bolt Pistol and Master-crafted Power Sword. The Sergeant can replace the pistol with a Neo-volkite Pistol or Plasma Pistol, including both plasma profiles. The shared profile includes Explosives and Tacticus; the conditional Deathwing keyword remains outside this profile, as with Sternguard. Current Captain, Chaplain, Lieutenant and Judiciar links are admitted. Other linked characters remain outside scope.

Bladeguard offers a once-per-turn choice when selected to fight or targeted by an enemy during Fight: +1 to the unit’s melee hit rolls, or -1 to enemy hit rolls against the unit. Core [01.02.02 Persisting Rules Effects](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/#Persisting-Rules-Effects) gives the effect phase duration when no explicit duration is printed.

## Declaration and resolution

Attack legality is checked before offering a stance. The declaration stores independent copies of assignments and targets; no attack dice are rolled while choices remain. The selecting unit receives its selection trigger first, followed by each targeted Bladeguard unit once, in deterministic target order. Both stance options and an explicit decline are available at each trigger. Declining preserves the use for a later legal trigger in the same turn. Selecting either effect spends the one use for that current unit and turn; it cannot be changed at a later trigger. No CP is spent, and Battle-shock does not prevent this datasheet ability.

The final response resumes the same attack declaration and recalculates attack modifiers with the chosen effects. Bonuses and penalties combine before the final +1/-1 cap. The offensive effect applies only to melee; the defensive effect applies to attacks targeting that unit during Fight. Attached characters receive the unit effect. Core 19.04 also limits the effect to its living source: losing the last Bladeguard ends the benefit for surviving attached characters, after the attacking unit finishes all its attacks when that source was destroyed by an attack. A frozen allocation snapshot preserves it during that resolution, then later attacks cannot recover it from the spent record. A new player turn restores availability.

The window also precedes completion of an eligible unengaged fight. Manual allocation, Precision, attack/damage reroll windows and Hazardous resolution continue through their existing paths after the declaration response. Invalid actors, stale revisions, illegal declarations and invalid dice cannot commit a different choice or consume the final response. Already-resolved responses cannot replay the attack. Historical ability implementations do not activate this rule.

Only the first two copies are admitted, including in custom training: the export’s third-and-later prices (110/200) are retained as source evidence, and the generic admission layer explicitly rejects those copies rather than pricing them as the first two. This increment does not add additional game sizes or certify intermediate formations.

## UI brief and evidence

The player must identify which unit responds, choose an effect or decline, and understand that attacks are waiting. Existing selector, confirmation button, panel layout, type and semantic colors are preserved. The decision banner names Bladeguard; visible help states both effects, Fight-phase expiry, one use per turn, zero CP, and that declining preserves the use. Full option labels remain available through tooltips. No new placement controls or decorative assets are added.

Inspected real Godot captures at 1600x1000 use a staged Marine-versus-Marine training fixture: `.tools/bladeguard-before.png`, `.tools/bladeguard-after.png` and `.tools/bladeguard-defender.png`. The latter shows the defender’s response after the attacker chose its stance. The initial capture used a stale fixture priority annotation; the final fixture explicitly labels the remaining-fighters step. These captures verify the local controls and copy, not army legality, a completed match, network behavior or other viewport sizes. Checked admission is tested separately in the supported Marine-versus-Necron mission.

The [audit](marine-bladeguard-audit.json) records numeric comparison and local regression results. Full faction, army and match certification remain incomplete. Network validation remains deferred to final integration by user instruction.
