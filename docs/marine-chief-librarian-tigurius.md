# Chief Librarian Tigurius datasheet audit

## Source and snapshot

This audit covers the shared Space Marines 11th-edition datasheet in App. Space Marines book `000000139`, datasheet `000001611`. The current [Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Chief-Librarian-Tigurius) was checked on 27 October 2026. Datasheet facts use verified local export snapshot `20261021T130623Z`, specification revision `20260817b`; the export manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. The fixed-data comparison found no differences in Tigurius's profile, keywords, default equipment, composition, cost or mapped weapon traits. The verified local options table contains no Tigurius equipment-option rows. Provenance and per-file hashes are recorded in the [machine audit](marine-chief-librarian-tigurius-audit.json).

The source identity audit records Space Marines App 2.8.1 / October 2026 and a stable `Last_update` marker of `2026-10-19 03:47:32`. This is the shared-book Ultramarines profile, exercised in a standard 11th-edition 1000-point Incursion training match; Chapter detachment rules and Boarding Actions are outside this scope.

## Source profile and equipment

Tigurius is one 115-point model on a 40 mm base: M6, T5, Sv3+, W5, Ld6+, OC1 and a 4+ invulnerable save. His fixed weapons are Bolt Pistol, Storm of the Emperor's Wrath and Rod of Tigurius. The source lists no equipment replacements.

The shared-book Leader targets are Assault Intercessor Squad, Bladeguard Veteran Squad, Desolation Squad, Infernus Squad, Intercessor Squad and Sternguard Veteran Squad. The page also lists Vanguard Veteran Squad from Warhammer Legends; that pairing is excluded from the 85 shared-book catalog.

## Integrated local scope

The dedicated suite checks the exact source profile, fixed loadout and current construction catalog, then materializes current Marine rosters for both players. Each of Tigurius's three weapons passes the shared Equipment and AttackPlan checks. All six current shared-book Leader links are covered by the relation suite; Heavy Intercessors are rejected as an unlisted target.

Hood of Hellfire grants Feel No Pain 4+ to Tigurius and attached bodyguards against Psychic attacks and mortal wounds. Prescience tests the owner-checked Movement-phase choice, Battle-shock on a psychic roll of 1, +1 to saves through the opponent turn, and expiry at the start of his next turn. Telepathic Assault is checked against a visible target within 24 inches, including Battle-shock on a 1, 2D3 mortal wounds through defender-owned allocation, save/restore of the pending choice, wrong-player rejection and the Shooting phase-close gate. The test also checks both psychic powers can be used in the same turn, plus Warlord eligibility and Transhuman Strategist's CP timing.

## Verification

The focused offline run passed **4/4 processes**: import, Python checks, `test_chief_librarian_tigurius` and `test_space_marine_leader_links`. It used `network: false` and `legacy_starter_staged: false`, with no cleanup diagnostics.

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_chief_librarian_tigurius --only test_space_marine_leader_links --timeout 300
```

Report: `.tools/verification/20261027T225949381745Z/results.json` (SHA-256 `E1DEF037ECD1863C961DA8ECA1F8C7B2A55D4BA343AE53C6EFD4F8926C7682DF`).

## Boundaries

This closes only Tigurius's shared-book local datasheet scope. Ultramarines Chapter rules, the Legends Vanguard Veteran pairing, complete army legality, network behavior, complete-match certification and human playtesting remain outside this result. Network validation remains deferred to final integration.
