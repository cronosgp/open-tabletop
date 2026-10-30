# Judiciar datasheet audit

## Source and snapshot

This audit covers the Judiciar in shared Space Marines 11th-edition App book `000000139`, datasheet `000002707`. The current [Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Judiciar) was checked on 27 October 2026. Datasheet facts use the verified local export snapshot `20261021T130623Z`, specification revision `20260817b`; its full manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. The pinned export has no Judiciar equipment-option rows. The 27 October fixed-data comparison reports no differences for this profile. Provenance and relevant file hashes are recorded in the [machine audit](marine-judiciar-audit.json).

The source identity audit records Space Marines App 2.8.1 / October 2026 and stable `Last_update` `2026-10-19 03:47:32`. This is the shared-book profile exercised in a standard 11th-edition 1000-point Incursion training match; Chapter variants, Legends and Boarding Actions are outside this scope.

## Source profile and Support targets

The Judiciar is one 50-point model on a 40 mm base: M6, T5, Sv3+, W4, Ld6+, OC1, with a 4+ invulnerable save against melee attacks only. Its fixed weapons are an Absolvor Bolt Pistol and Executioner Relic Blade. The source lists Fights First, Support, Combat Doctrines and Tempormortis; Tempormortis gives the unit Fights First.

The five shared-book Support targets are Assault Intercessor Squad, Bladeguard Veteran Squad, Infernus Squad, Intercessor Squad and Sternguard Veteran Squad. The source page also lists seven targets from Black Templars, Dark Angels, Deathwatch and Warhammer Legends; these remain outside the shared-book construction catalog.

## Integrated local scope

The dedicated suite checks the exact source profile and catalog entry, then materializes current Marine rosters for both players. The two fixed weapons pass the shared Equipment and AttackPlan checks. The shared relation suite tests all 153 common-book Leader/Support links.

The Judiciar's melee-only invulnerable save works through grouped defenses, automatic attack resolution and manual allocation. It does not apply to shooting or transfer to attached bodyguards, preserves a better universal invulnerable save, and rejects invalid conditional values. Tempormortis grants Fights First to the living attached unit while its source is on the battlefield. The suite checks source removal and destruction, historical-implementation gating, charge priority, opposing-player selection, and an independent Fights First effect after source loss. Support attachment uses the normalized owner-checked command; checked formation validation rejects an unattached Support and preserves its separate Support slot.

## Verification

The focused offline run passed **5/5 processes**: import, Python checks, `test_judiciar`, `test_judiciar_profile_parity` and `test_space_marine_leader_links`. It used `network: false` and did not stage the optional legacy starter pack; no cleanup diagnostics were reported.

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_judiciar --only test_judiciar_profile_parity --only test_space_marine_leader_links --timeout 300
```

Report: `.tools/verification/20261027T231150548787Z/results.json` (SHA-256 `1e67c8aa3925cf6e129c9aae80e2559c7a2a2e1f81675da1fc5f8a3c94e6a8fe`). The fixed-data comparator is `.tools/marine-comparison-20261027-v12.json` (SHA-256 `30e1b54329013cda755058d3990d397036454346c6c54f2388411f3403021420`; Judiciar differences: none).

## Boundaries

This closes only the Judiciar's shared-book local datasheet scope. It does not certify Chapter interactions, complete army legality, network behavior, full-match certification or human playtesting. Network validation remains deferred to final integration.
