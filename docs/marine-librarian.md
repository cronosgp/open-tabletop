# Librarian datasheet audit

## Source and snapshot

This audit covers the Librarian in shared Space Marines 11th-edition App book `000000139`, datasheet `000002266`. The current [Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Librarian) was checked on 27 October 2026. Datasheet facts use verified local export snapshot `20261021T130623Z`, specification revision `20260817b`; the full manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. The source has no equipment-option rows. The 27 October fixed-data comparison reports no differences for the Librarian. Provenance and relevant file hashes are recorded in the [machine audit](marine-librarian-audit.json).

The source identity audit records Space Marines App 2.8.1 / October 2026 and stable `Last_update` `2026-10-19 03:47:32`. This is the shared-book profile exercised in a standard 11th-edition 1000-point Incursion training match; Chapter variants, Legends and Boarding Actions remain outside scope.

## Source profile and Leader targets

The Librarian is one 75-point model on a 40 mm base: M6, T5, Sv3+, W4, Ld6+, OC1, without an invulnerable save. Its fixed loadout is a Bolt Pistol, Smite and Force Weapon. Smite has Focused Witchfire (D3+3 attacks, Devastating Wounds, Psychic and Hazardous) and Witchfire (D6 attacks, Psychic) profiles.

The sheet lists Leader, Combat Doctrines, Librarius, Librarian psychic level 1, Psychic Hood (Psychic), Veil of Time and Force Dome. The six shared-book Leader targets are Assault Intercessor Squad, Desolation Squad, Hellblaster Squad, Infernus Squad, Intercessor Squad and Sternguard Veteran Squad. The other five source-listed targets belong to Dark Angels, Deathwatch or Warhammer Legends and remain outside this shared-book scope.

## Integrated local scope

The dedicated suite checks the fixed profile and catalog entry, weapon plans for all four weapon profiles, and current Marine catalog materialization for both players. The shared relation suite tests all 153 common-book Leader/Support links; the Librarian suite checks each of its six common-book Leader targets and rejects an unlisted Heavy Intercessor Squad.

Psychic Hood provides a 4+ Feel No Pain against Psychic attacks to every model in the attached unit; the suite confirms it does not apply to ordinary damage. Force Dome is an owner-checked Movement-phase choice, grants the unit a 4+ invulnerable save until the start of the Librarian player's next turn, preserves better saves and is limited to one Librarius power per battle round. On a psychic roll of 1 the unit becomes Battle-shocked and still receives the save. Veil of Time is chosen before an eligible Advance; the final roll becomes 6 after the normal Advance re-roll window, while a roll of 1 still Battle-shocks the unit and arms the replacement.

## Verification

The focused offline run passed **4/4 processes**: import, Python checks, `test_librarian_current` and `test_space_marine_leader_links`. It used `network: false`, did not stage the optional legacy starter and reported no cleanup diagnostics.

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_librarian_current --only test_space_marine_leader_links --timeout 300
```

Report: `.tools/verification/20261027T232136941877Z/results.json` (SHA-256 `2df8150f38cd565e9c825d8420d34a94fe77379f352a4dbe00ce29ac7250a971`). The fixed-data comparator is `.tools/marine-comparison-20261027-v12.json` (SHA-256 `30e1b54329013cda755058d3990d397036454346c6c54f2388411f3403021420`; Librarian differences: none).

## Boundaries

This closes only the Librarian's shared-book local datasheet scope. It does not certify Chapter interactions, complete army legality, network behavior, complete-match certification or human playtesting. Network validation remains deferred to final integration.
