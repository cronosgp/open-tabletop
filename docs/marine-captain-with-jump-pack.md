# Captain With Jump Pack — 11th edition scope

Source: [Wahapedia 11th-edition Captain With Jump Pack](https://wahapedia.ru/wh40k11ed/factions/space-marines/Captain-With-Jump-Pack), Space Marines App book `000000139`, datasheet `000000083`. The live page was checked on 28 October 2026; the faction page identifies Space Marines App 2.8.1 / October 2026. Datasheet facts were reconciled against the verified local Data Export snapshot `20261021T130623Z` (specification revision `20260817b`, retrieved 2026-10-21T19:46:58Z; export timestamp 2026-10-21 16:06:23 GMT+3). The machine audit records the manifest and relevant CSV SHA-256 hashes.

## Profile and equipment

The datasheet contains one model for 90 points on a 40 mm base. Its characteristics are M12, T5, Sv3+, W5, Ld6+, OC1 and a 4+ invulnerable save. The default loadout is a Heavy Bolt Pistol and Chainsword.

The three source option rows permit seven complete replacement sets: Heavy Bolt Pistol or Hand Flamer or Plasma Pistol with Chainsword; Heavy Bolt Pistol with Power Fist or Relic Weapon; or Thunder Hammer with Relic Shield, or Chainsword with Relic Shield. The focused test checks each package against the extracted weapon profiles. All eight weapon profiles/modes pass `Equipment` and `AttackPlan`. Relic Shield adds one Wound to its bearer and restoring the default removes it.

## Rules and Leader links

The local ability catalog registers Deep Strike, Leader, Combat Doctrines, Transhuman Strategist, Strategic Acumen, Angel’s Wrath and Relic Shield. The Captain can lead Assault Intercessors With Jump Packs and Vanguard Veteran Squad With Jump Packs. The source also lists Sanguinary Guard and Talonstrike Kill Team; those belong to the Blood Angels and Deathwatch Apps and remain outside the shared-book 85-profile catalog.

The suite confirms the Captain’s attached unit has Deep Strike on every model and can enter Strategic Reserves through the public choice flow. Angel’s Wrath adds one to the actual Advance and Charge results. Strategic Acumen is owner-checked, limited to once in the Command phase and expires at the start of the next own Command phase. Transhuman Strategist grants one CP when the Captain is Warlord, once per battle round. Both players materialize from the consolidated current catalog; the local catalog admits up to three copies and rejects a fourth.

## Verification

The focused offline run passed **5/5 processes**: import, Python checks, the Captain With Jump Pack suite, the paired Vanguard Veteran suite and the 153-link Leader/Support regression. It used `network: false`, `legacy_starter_staged: false` and reported no cleanup diagnostics. See `.tools/verification/20261028T011901622074Z/results.json` and the [machine audit](marine-captain-with-jump-pack-audit.json). The per-profile fixed-data comparison reports no differences; it does not certify behavior by itself.

This closes only the Captain With Jump Pack shared-book local scope. The two Chapter/Deathwatch Leader targets, full faction or army legality, network behavior, complete-match certification and human playtesting remain outside this closure. Network validation is deferred to final integration.
