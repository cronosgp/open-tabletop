# Hellblaster Squad — source-bounded local scope

This audit closes the shared-book 11th-edition local datasheet scope for [Hellblaster Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Hellblaster-Squad), book `000000139`, datasheet `000002098`. Facts were checked against the verified local Wahapedia Data Export snapshot. This scope does not certify full army legality or network behavior.

## Verified local source

Snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`; `Last_update.csv` records `2026-10-21 16:06:23 GMT+3`; specification revision `20260817b`; 23-file manifest SHA-256 `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. Relevant file hashes are recorded in the [machine-readable audit](marine-hellblaster-squad-audit.json). The runtime profile retains its original `2026-10-16T21:03:46+03:00` export stamp; this scope records the separately verified 21 October snapshot without rewriting that provenance.

## Implemented and checked

- One Sergeant and four to nine Hellblasters; five- and ten-model units cost 115/230 points for the first two copies and 130/245 for the third-plus tier. Models use 32 mm bases and M6, T5, Sv3+, W2, Ld6+, OC1, with no invulnerable save. The keywords are `ADEPTUS ASTARTES`, `EXPLOSIVES`, `IMPERIUM`, `INFANTRY` and `TACTICUS`.
- Every model starts with a Plasma Incinerator, Bolt Pistol and Ceramite Fists. Standard and Supercharge Incinerator profiles, Bolt Pistol and Ceramite Fists are checked through `Equipment` and `AttackPlan`.
- The Sergeant may replace the Bolt Pistol with a free Plasma Pistol. The public preparation choice is reversible and restricted to the Sergeant; wrong-owner, non-Sergeant and forged-value requests are rejected without changing state. Both Plasma Pistol profiles are checked through `Equipment` and `AttackPlan`.
- Rites of Thermal Appeasement adds 1 to this unit's Hazard tests for its Plasma Incinerator and Plasma Pistol. The test resolves actual supercharged attacks from both weapons together, checks that raw 2s succeed with the modifier, raw 1 still fails, and unrelated Hazard tests receive no bonus.
- The local relation map retains seven common-book Leader/Support identities: Ancient, Apothecary, Captain, Captain Titus, Chaplain, Librarian and Lieutenant. The source's common-book `Supported by` subset is Ancient, Apothecary and Lieutenant; Apothecary attachment is exercised. Chapter-specific entries remain outside this shared-book scope.
- Both players' rosters materialize from the consolidated current Marine catalog. The checked 1,000-point Incursion roster admits two copies and rejects a third.

## Local validation

Focused offline verification passed **4/4 processes** (project import, Python checks, this datasheet suite and the shared Leader/Support relation suite) at `.tools/verification/20261028T045928351341Z/results.json` (SHA-256 `f4b8ab24dc546cb7d885abf8a5d434737d56243e9c5c31ee43eaf346e3f2d06c`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics):

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_hellblaster_squad --only test_space_marine_leader_links --timeout 300
```

The scope test uses a current-catalog local fixture with the official mission disabled. It is datasheet and local admission evidence, not a full official-mission match.

## Limits

This closes only the shared-book Hellblaster Squad local datasheet scope. Incursion is the checked roster mode and caps this non-BATTLELINE sheet at two copies; Strike Force admission is not implemented although third-plus prices remain cataloged. Chapter-specific Asmodai, Azrael, Ezekiel and Sanguinary Priest links, Forge World, Legends, Boarding Actions, full faction/army legality, network behavior, full-match certification and human playtesting remain outside this result. Network validation is deferred to final integration.
