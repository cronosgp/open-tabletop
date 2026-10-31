# Standard 11th-edition faction inventory

Snapshot checked locally on 31 October 2026 against Wahapedia's 11e Data Export, updated `2026-10-30T22:19:16+03:00`. Parent manifest SHA-256: `e292e43a4dc90ed529c60ac988d7f3351ae287a6bdfa8b85e9c818806b9020ef`. All 22 CSV file hashes matched the manifest. The parent export has 68 global structural findings, so these counts are an inventory only; each book needs a clean subject-scoped validation before its datasheet facts are certified.

The Necrons App slice (`000000029`, version 1.2) contains 51 datasheets and has zero scoped structural findings. Its slice manifest SHA-256 is `651601ce1262894f1fb5f20429daab8e88e0eab6fd8260b5b40041dc9dfbaae4`; derived catalog SHA-256 is `cee4e1ebfb73eda7c9596be33c4fed12fc421ed15f02932e11a948758078283f`. Runtime metadata now matches all 51 source identities. Thirty-two datasheets have transcribed current profile facts; all remain blocked from construction pending remaining rules, loadout and focused validation work. The other 19 currently have identity metadata only. See the [Necrons coverage ledger](necrons-coverage.md) for per-scope status and source hashes.

Counts are unique, non-virtual datasheet IDs in each active 11e App, Faction Pack or Codex; support-only datasheets count as datasheets. The ranked list excludes Legends, alternate modes, and source books whose export metadata is edition 0; these are tracked as separate scopes, not treated as absent. Space Marines has 192 current page-indexed datasheet identities across standard, Legends and Forge World sources; see the [extended Marine inventory](space-marine-extended-inventory.md). The local Chaos Knights slice (`000000070`) has 11 sheets and zero scoped structural findings; its manifest SHA-256 is `0c9d43b7a3b7621c0a108a687145c775969c8e4934d426924562cfe8ef0cd870`, and its derived catalog SHA-256 is `728f504ef0dd1c14964e93a15f107d7dae636105fd1ee2ba449799afd5fea9cb`. The 11 Chaos Knights profiles are not yet admitted to runtime construction.

## Next standard factions

| Order | Faction | Source book ID | Datasheets |
|---:|---|---|---:|
| 1 | Chaos Knights | `000000070` | 11 |
| 2 | Imperial Knights | `000000034` | 13 |
| 3 | Leagues of Votann | `000000203` | 22 |
| 4 | Drukhari | `000000031` | 23 |
| 5 | Emperor's Children | `000000280` | 24 |
| 5 | Genestealer Cults | `000000053` | 24 |
| 7 | Grey Knights | `000000013` | 25 |
| 8 | Adeptus Custodes | `000000024` | 27 |
| 9 | Imperial Agents | `000000259` | 29 |
| 10 | World Eaters | `000000210` | 31 |
| 11 | Adepta Sororitas | `000000112` | 33 |
| 12 | Thousand Sons | `000000027` | 35 |
| 13 | Death Guard | `000000014` | 37 |
| 14 | Adeptus Mechanicus | `000000015` | 39 |
| 14 | T'au Empire | `000000028` | 39 |
| 16 | Necrons | `000000029` | 51 |
| 17 | Chaos Daemons | `000000025` | 53 |
| 18 | Orks | `000000046` | 54 |
| 19 | Tyranids | `000000020` | 64 |
| 20 | Chaos Space Marines | `000000012` | 82 |
| 21 | Aeldari | `000000186` | 88 |
| 22 | Astra Militarum | `000000016` | 120 |

The five Space Marine Chapter books are already consolidated into the 161-profile Marine audit: shared Codex (85), Black Templars (15), Blood Angels (14), Dark Angels (16), Deathwatch (10) and Space Wolves (21). Deathwatch therefore does not appear as an unstarted faction above. See [Space Marine coverage](../space-marines-coverage.md).

This ranking does not mark a faction or any datasheet ready for use. Before adding a faction to the current runtime catalog, validate its source-book slice, reconcile every supported composition and price, implement required rules or keep the affected profile unavailable, and run local admission/combat checks. Final network validation stays deferred to integration.
