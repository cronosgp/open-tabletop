# Lion El’jonson datasheet audit

## Source and snapshot

This audit covers Lion El’jonson in the Dark Angels 11th-edition App, source book `000000023`, datasheet `000002682`. The Wahapedia page was checked on 28 October 2026. Fixed datasheet facts come from verified local export `20261021T130623Z`, specification revision `20260817b`, retrieved 21 October 2026. The parent manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`; the single-subject audit slice is structurally valid and its manifest SHA-256 is `36bdfa57f88ea526cfcd0faad83bd160c8d855a00f3b055d4ecc09815b056720`. The parent export still reports 68 unrelated validation errors. They are retained as open source-export issues and were not treated as a successful parent validation. Relevant file hashes and the fixed-data comparison are in the [machine audit](marine-lion-eljonson-audit.json).

## Source profile and weapons

Lion is one 415-point Epic Hero on a 60 mm base: M8, T10, Sv2+, invulnerable save 3+, W16, Ld5+ and OC4. His faction keywords are Adeptus Astartes and Dark Angels; his other keywords are Epic Hero, Monster, Mobile, Imperium, Primarch and Character. His fixed physical weapons are Arma Luminis and Fealty, each represented by its source-listed modes:

- Arma Luminis — Plasma: 18", A2, BS2+, S10, AP-3, D3; Close-quarters.
- Arma Luminis — Bolt: 18", A4, BS2+, S6, AP-2, D2; Close-quarters.
- Fealty — Sweep: A12, WS2+, S6, AP-3, D2; Sustained Hits 1 and Cleave 2.
- Fealty — Strike: A8, WS2+, S12, AP-4, D4; Lethal Hits.

## Integrated local scope

The source profile is admitted to the consolidated current-reference catalog at one copy. The dedicated suite checks both-player materialization, duplicate Epic Hero rejection, all four weapon modes through Equipment and AttackPlan, and the following abilities:

- Deep Strike, Fights First, Combat Doctrines and Transhuman Strategist use the shared current rules paths.
- Supreme Commander requires Lion to be the Warlord and rejects a roster that also contains Guilliman.
- Dark Angels Bodyguard grants Lone Operative within 3" of friendly Dark Angels Infantry; Chapter context and distance are checked.
- The Emperor’s Shield worsens Wound rolls by 1 against attacks whose Strength exceeds Lion’s Toughness.
- The Watchers gives Lion Feel No Pain 4+ against psychic attacks and mortal wounds.
- Primarch of the First Legion offers up to two distinct choices at the start of the owner’s Command phase; choices expire at the next owner Command phase.
- Master Strategist selects one available Combat Doctrine for Lion’s unit for the source duration.
- Mist-wreathed Shadow Realms places the unengaged unit in Strategic Reserves and allows Lion to ingress in the ensuing own Movement phase, including battle round 1. The action observes the half-army reserve cap.
- Martial Exemplar grants nearby friendly Dark Angels melee attacks Hit and Wound re-rolls of 1.
- No Hiding from the Watchers grants nearby friendly Dark Angels Feel No Pain 5+ against psychic attacks and mortal wounds.

## Verification

Focused offline verification passed **3/3 processes**: import, Python checks and `test_lion_eljonson`. The run used `network: false`, staged no legacy starter and reported no cleanup diagnostics.

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_lion_eljonson --timeout 300
```

Report: `.tools/verification/20261028T133452864654Z/results.json` (SHA-256 `3628b2f6882c62e520141edf1682feff4ced31202af3d3394ec1524e3c2c1793`). The single-profile fixed-data comparator is `.tools/marine-comparison-lion-20261028.json` (SHA-256 `ff82ab00a357d3485825d90d16867bc73e2365104bbe341c5b99e2658272ef1a`); it reports zero differences and one source-consistent profile. The parent export’s 68 unrelated structural errors remain outside this Lion slice and outside the passed claim.

## Boundaries

This closes only Lion’s source-bounded local datasheet scope. It does not certify full Dark Angels or Space Marine army legality, all Chapter interactions, network behavior, complete-match behavior or human playtesting. Network validation remains deferred to final integration. Forge World, Legends and alternate modes are outside the current profile inventory.
