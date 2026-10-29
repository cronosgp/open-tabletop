# Adrax Agatone datasheet audit

## Source and snapshot

This audit covers the shared Space Marines 11th-edition sheet in book `000000139`, datasheet `000002100`, from pinned Wahapedia export snapshot `20261021T130623Z` (specification revision `20260817b`). The snapshot was retrieved 2026-10-21 19:46:58 UTC and updated 2026-10-21 16:06:23 GMT+3. Manifest SHA-256: `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`; Space Marines slice manifest SHA-256: `f11ff7ddce6e12b33abf62426a245711611667a98e13969efa8679bef88c7989`. The current [Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Adrax-Agatone) was checked on 2026-10-27. The twelve relevant export-file hashes are recorded in the machine audit.

## Source profile

Adrax is one 90-point model on a 40 mm base: M6, T5, Sv2+, W5, Ld6+, OC1 and a 4+ invulnerable save. The shared profile retains the Salamanders faction keyword; no general Salamanders roster legality is inferred. Fixed weapons are Drakkis (12 inches, D6+3, Torrent, Close-quarters) and Malleus Noctum (five attacks, S10, AP-2, D3, Devastating Wounds). There are no equipment-option rows. Source abilities are Leader, Combat Doctrines, Transhuman Strategist, Lord of the Pyroclasts and Unto the Anvil.

Six source-linked bodyguards belong to this shared book. The page also lists Vanguard Veteran Squad from the Warhammer Legends book; it remains outside the common 85-sheet construction scope.

## Integrated local scope

The current-catalog suite checks the exact source identity, base/profile, costs, keywords and fixed weapon plans through Equipment and AttackPlan. Both players use the current Marine catalog. It checks Leader attachment, Warlord selection and Transhuman Strategist's once-per-round CP, Lord of the Pyroclasts against engaged and unengaged enemies, and Unto the Anvil's melee wound rerolls with and without Assault Doctrine. The shared relation suite covers all 153 in-scope Leader/Support links.

## Verification

Focused offline verification passed **5/5 processes**: import, Python checks, the Adrax suite, the Kor'sarro suite and the shared Leader/Support relation suite.

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_adrax_agatone --only test_kor_sarro_khan --only test_space_marine_leader_links --timeout 300
```

Report: `.tools/verification/20261027T121145243348Z/results.json`; SHA-256 `74608c5dded5965ecba9f88ca029e89521da757a26b95356944ba03b125d1e0a`. Network was disabled, the optional legacy starter was not staged and no cleanup diagnostics were recorded. Provenance and scope are recorded in [master profile evidence](space-marines-profile-evidence.json) and the [machine-readable audit](marine-adrax-agatone-audit.json).

## Open boundaries

This closes only Adrax's shared-book local datasheet scope. The Legends Leader target remains unavailable to new construction. Full Salamanders/Chapter legality, other Chapter contexts, Forge World, Legends, Boarding Actions, full army legality, network behavior, complete matches and human playtesting are outside this result. Network validation is deferred to final integration.
