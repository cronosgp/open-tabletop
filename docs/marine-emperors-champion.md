# Emperor’s Champion datasheet audit

## Source and snapshot

This audit covers Emperor’s Champion in the Black Templars 11th-edition App, source book `000000162`, datasheet `000002795`. The Wahapedia page was checked on 28 October 2026. Fixed facts come from verified local export `20261021T130623Z`, retrieved 21 October 2026, specification revision `20260817b`. The parent manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`; the Black Templars slice is structurally valid with manifest SHA-256 `8a6d9529ae553b06203cdb2b6c8f1edd736f2a737ba1c215d2241bd1cdfb5bbe`. Its catalog SHA-256 is `a3f5ca78fb12c38e6a5ca80e446befca7370b36dd5a017dd97e54ea6c00483c9`. The parent export has 68 unrelated validation errors, which remain open. See the [machine-readable audit](marine-emperors-champion-audit.json) for source-file hashes, comparator and verification evidence.

## Source profile and weapons

Emperor’s Champion is a one-model, 100-point Epic Hero on a 40 mm base: M8, T5, Sv2+, invulnerable save 4+, W5, Ld6+ and OC1. Its keywords include Infantry, Character, Explosives, Imperium, Tacticus, Adeptus Astartes and Black Templars. It carries a Bolt Pistol and the Black Sword:

- Bolt Pistol — 12", A1, BS2+, S5, AP-1, D1; Close-quarters.
- Black Sword — Sweep: A10, WS2+, S6, AP-2, D1.
- Black Sword — Strike: A6, WS2+, S8, AP-3, D3; Precision, Anti-Character 5+ and Devastating Wounds.

## Integrated local scope

The profile is admitted to the consolidated current-reference catalog at one copy. The dedicated suite checks source facts, equipment and attack-plan weapon modes, both-player materialization, copy-limit admission and the following abilities:

- Leader and Lone Operative use their shared rules paths; the source Leader targets are Assault Intercessors, Intercessors, Sternguard Veterans, Crusader Squad and Sword Brethren Squad.
- Armour of Faith reduces Damage from attacks allocated to the model by 1, to a minimum of 1; mortal-wound handling remains separate.
- Chosen of the Emperor limits the army to one Emperor’s Champion.
- Sigismund’s Heir adds 1 to Charge rolls.
- Combat Doctrines use the shared selection path.

The Sword Brethren Leader endpoint is now admitted at the source-priced sizes 4, 5, 9 and 10; the 6–8-model sizes remain blocked because the local export has no prices. Crusader Squad remains a partial Chapter scope.

## Verification

Focused offline verification passed **5/5 processes**: import, Python checks, Emperor’s Champion, Marine Leader links and Lion El’jonson.

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_emperors_champion --only test_space_marine_leader_links --only test_lion_eljonson --timeout 300
```

Report: `.tools/verification/20261028T134519884776Z/results.json` (SHA-256 `4bc3a07f8aa33f4e018884d4e7645c59be6aa1d85ffb042c01217cc985b44c24`, `network: false`, no legacy starter staged, no cleanup diagnostics). The fixed-data comparator `.tools/marine-comparison-emperors-champion-20261028.json` (SHA-256 `b888dee168c0e528b7bc5e70cadf139da15909ced49672e9dd9c3b4e428644ba`) reports one source-consistent profile with no fixed-data differences. The subject slice is structurally valid; the parent export’s 68 unrelated errors were not treated as passed.

## Boundaries

This closes only Emperor’s Champion’s source-bounded local datasheet scope and one-copy catalog admission. It does not certify full Black Templars or Space Marine army legality, all roster-wide Leader restrictions, network behavior, complete-match behavior or human playtesting. Network validation remains deferred to final integration. Forge World, Legends and alternate modes are outside the current profile inventory.
