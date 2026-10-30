# Cato Sicarius datasheet audit

## Source and snapshot

This audit covers Cato Sicarius in shared Space Marines book `000000139`, datasheet `000004184`, from the pinned Wahapedia 11th-edition export snapshot `20261021T130623Z` (specification revision `20260817b`). The snapshot was retrieved on 2026-10-21; its manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf` and the Space Marines slice manifest SHA-256 is `f11ff7ddce6e12b33abf62426a245711611667a98e13969efa8679bef88c7989`. The current [Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Cato-Sicarius) was checked on 2026-10-27. The twelve relevant export-file hashes are recorded in the machine audit.

## Source profile

The local export records a one-model 40 mm profile at 115 points with M6, T5, Sv2+, W5, Ld6+, OC1 and a 4+ invulnerable save. Fixed weapons: Artisan Plasma Pistol, Talassarian Tempest Blade - Strike, Talassarian Tempest Blade - Coup de Grace, Talassarian Tempest Blade - Sweep. There are no equipment-option rows.

Core abilities: Leader. Army rules: Combat Doctrines, Transhuman Strategist. Datasheet abilities: Captain of the Honour Guard, Knight Champion of Macragge (Once per phase, per army), Honour or Death.

Its exact Leader target is Victrix Honour Guard. All source-listed Victrix role compositions and Banner pricing are now covered by the linked [Victrix sheet audit](marine-victrix-honour-guard.md).

## Integrated local scope

Cato Sicarius: exact one-model 40 mm 115-point source profile, characteristics, keywords and absence of equipment-option rows; Artisan Plasma Pistol and all three Talassarian Tempest Blade modes through Equipment and AttackPlan; both players' current Marine catalogs; exact Victrix Honour Guard Leader target, Calgar-dependent Support role and Warlord boundary; Warlord selection and once-per-round Transhuman Strategist CP; Combat Doctrines; Knight Champion of Macragge opponent-Movement trigger, 8-inch boundary, optional Normal Move up to 6 inches, placement validation and persisted use; and Honour or Death's Heroic Intervention CP discount.

## Verification

Focused offline verification passed **7/7 processes**: import, Python checks, Cato Sicarius, Cato profile parity, Marneus Calgar, Victrix Honour Guard as a linked regression, and the 153-link Leader/Support relation suite. This evidence closes Cato Sicarius's declared local source-bounded scope. The Victrix suite is a dependency regression and does not close its separate sheet scope.

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_cato_sicarius --only test_cato_profile_parity --only test_marneus_calgar --only test_victrix_honour_guard --only test_space_marine_leader_links --timeout 300
```

Report: `.tools/verification/20261027T184013951006Z/results.json`; SHA-256 `fda6d470dc83ef6df9faa13f30c37ae748879ca91526b0b5faba66a546bfde01`. Network was disabled, the optional legacy starter was not staged and no cleanup diagnostics were reported. Provenance and boundaries are recorded in the [machine-readable audit](marine-cato-sicarius-audit.json) and [master profile evidence](space-marines-profile-evidence.json).

## Open boundaries

Closes only Cato Sicarius's shared-book local sheet scope. Ultramarines/Chapter restrictions, full faction/army legality, network behavior, complete matches and human playtesting remain outside this result; network validation is deferred to final integration.
