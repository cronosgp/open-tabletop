# Sternguard Veteran Squad — source-bounded local scope

This audit closes the shared-book 11th-edition local datasheet scope for [Sternguard Veteran Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Sternguard-Veteran-Squad), book `000000139`, datasheet `000002255`. Datasheet facts were checked against the verified local Wahapedia Data Export snapshot. This does not certify full army legality or network behavior.

## Verified local source

Snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`; `Last_update.csv` records `2026-10-21 16:06:23 GMT+3`; specification revision `20260817b`; 23-file manifest SHA-256 `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. The machine-readable [audit](marine-sternguard-veteran-squad-audit.json) records hashes for the relevant export files and implementation. The runtime profile keeps its original `2026-10-16T21:03:46+03:00` export stamp.

## Implemented and checked

- One Sergeant and four to nine Veterans; five- and ten-model units cost 105/210 points for the first two copies and 120/225 for third-plus. The models use 32 mm bases and M6, T5, Sv3+, W2, Ld6+, OC1. Shared keywords are `ADEPTUS ASTARTES`, `EXPLOSIVES`, `IMPERIUM`, `INFANTRY` and `TACTICUS`. The conditional Dark Angels `DEATHWING` keyword remains outside the shared profile.
- The Sergeant starts with an Artificer Firearm, Bolt Pistol and Chainsword. Other Veterans start with an Artificer Firearm, Bolt Pistol and Ceramite Fists. All three Artificer Firearm modes, the Bolt Pistol, Ceramite Fists, Sergeant melee choices, Heavy Bolter and Pyrecannon pass the shared Equipment and AttackPlan checks.
- Infernus retains Assault and Rapid Fire 2; Purgatus retains Assault and Rapid Fire 1; Damnatus retains Assault and Melta 2, including the half-range boundary. The Heavy Bolter is S5 with Heavy, Rapid Fire 2 and Sustained Hits 1. The Pyrecannon keeps Torrent and Blast 2, including the ten-model Blast attack count.
- The Sergeant may replace the Chainsword with a Power Fist or Power Weapon. One ordinary Veteran per five models may replace the Artificer Firearm with a Heavy Bolter or Pyrecannon. The suite checks the Sergeant and player boundaries, forged-choice rejection, five- and ten-model caps, changing a special weapon while at capacity, restoration and re-use. An attached Captain does not change the five-model cap.
- Veteran Marksmen re-rolls ranged Hit rolls of 1 for the unit, including its attached Leader. The suite checks actual Hit resolution, prevents a replacement 1 from being rolled again, and confirms the ability does not grant melee re-rolls or bypass the Snap Shooting restriction. It also checks the effect ends when the Sternguard source is destroyed.
- The common-book map retains eight Leader identities and six `Supported by` identities. The paired relation suite verifies all 153 represented common-book links; this sheet suite exercises Captain attachment.
- Both players build from the consolidated current Marine catalog with exact five/ten-model sizes and costs. The local 1,000-point Incursion path admits two copies and rejects a third.

## Local validation

Focused offline verification passed **4/4 processes** at `.tools/verification/20261028T052655350303Z/results.json` (SHA-256 `1484ae1ece4357ca226379e80a3d08212f2cbed774b55198aa21d55e6fd80716`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics):

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_sternguard_veteran_squad --only test_space_marine_leader_links --timeout 300
```

The Incursion check admits two copies and rejects a third. The current cross-profile Marine check also exercises Strike Force admission and source-priced copy limits for this datasheet. These local checks do not certify complete army legality. Network validation remains deferred to final integration.

## Limits

This closes only the shared-book Sternguard Veteran Squad local datasheet scope. Chapter-specific variants and rules, Forge World, Legends, full faction/army legality, network behavior, complete-match certification and human playtesting remain outside this result.
