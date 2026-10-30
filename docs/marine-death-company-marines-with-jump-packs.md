# Death Company Marines With Jump Packs datasheet audit

## Source and snapshot

This audit covers Blood Angels App datasheet `000002737` in source book `000000021` for Warhammer 40,000 11th edition. The [current Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Death-Company-Marines-With-Jump-Packs) was checked on 28 October 2026; the page does not publish a separate revision identifier.

Fixed facts use the verified Wahapedia Data Export snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, export timestamp `2026-10-21T16:06:23+03:00`, specification revision `20260817b`. The parent manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`; the Blood Angels App slice SHA-256 is `74de1b23c1319c395f9071449b47531870067eb0aa9c2de3ff6110ccd9e162c5`.

The source export files and SHA-256 hashes are the same verified Blood Angels slice listed in the [Death Company Marines snapshot table](marine-death-company-marines.md#source-and-snapshot). The ignored raw export remains under `.tools`; recheck a later adopted export before updating this profile.

## Integrated local scope

The unit has 5 or 10 models. The first and second copies cost 130/260 points; each third-or-later copy costs 160/290 points, with a three-copy construction limit. Each model uses a 32 mm base and has M12, T5, Sv3+, W2, Ld6+, OC1. The fixed profile records the Blood Angels, Adeptus Astartes, Death Company, Infantry, Jump Pack, Fly, Tacticus, Explosives and Imperium keywords. Each model starts with a Heavy Bolt Pistol and Chainsword.

For every five models, one model may replace its Chainsword with an Eviscerator or Power Fist; one may replace its Heavy Bolt Pistol with a Hand Flamer or Inferno Pistol. Up to two models per five may replace their Chainswords with Power Weapons and up to two may replace their Heavy Bolt Pistols with Plasma Pistols. The implementation enforces those separate melee and pistol limits and does not add points for these listed options.

The local ability scope includes Deep Strike, Combat Doctrines, Feel No Pain 6+, Black Rage and Savage Fury. Black Rage grants melee Hit rerolls of 1. If the unit is outside either supporting range—6 inches from a friendly Blood Angels Character or 12 inches from a friendly Chaplain—it cannot Fall Back and has OC 0. Savage Fury adds 1 to Charge rolls. An Honourable Death in Combat is not on this datasheet and is not granted to this unit.

## Local checks and limits

The targeted offline verification passed **5/5 processes** at `.tools/verification/20261028T195743838575Z/results.json` (SHA-256 `2679C2D11638DD385AB4C5F1B444FA0F1C345D378A11A96C470BF459DF9EABD9`; `network: false`, `legacy_starter_staged: true`, no cleanup diagnostics):

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_death_company_marines --only test_implemented_catalog --only test_capabilities --timeout 300
```

The suite checks the pinned source identity and facts, weapon profiles, option limits, both point tiers, public preparation choices, FNP, Deep Strike, Savage Fury, Black Rage melee/support/Fall Back/OC effects, exclusion of the foot squad's ability, catalog count and capability records. This closes only the declared local scope; it does not certify full Blood Angels or Space Marine army legality, network behavior, all roster interactions or human playtesting. See the [machine-readable audit](marine-death-company-marines-with-jump-packs-audit.json).
