# Kaius Konorius datasheet audit

## Source and snapshot

This audit covers the shared Space Marines 11th-edition datasheet in App. Space Marines book `000000139`, datasheet `000004248`. The current [Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Kaius-Konorius) was checked on 27 October 2026. Datasheet facts use verified local export snapshot `20261021T130623Z`, specification revision `20260817b`; the export manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. The fixed-data comparator found no differences in Kaius's profile, keywords, default equipment, composition, cost or weapon traits. Provenance and file hashes are recorded in the [machine audit](marine-kaius-konorius-audit.json).

The source identity audit records Space Marines App 2.8.1 / October 2026 and a stable `Last_update` marker of `2026-10-19 03:47:32`. This is the shared-book Ultramarines profile, exercised in a standard 11th-edition 1000-point Incursion training match; Chapter detachment rules and Boarding Actions are outside this scope.

## Source profile and equipment

Kaius is one 100-point model on a 40 mm base: M6, T5, Sv2+, W5, Ld6+, OC1 and a 4+ invulnerable save. His fixed weapons are a Heavy Bolt Pistol (18 inches, one attack, BS2+, Strength 5, AP-1, Damage 1, Close-quarters) and Severance and Rebuke: Strike (five attacks, WS2+, Strength 10, AP-3, Damage 3, Precision) or Sweep (six attacks, WS2+, Strength 6, AP-3, Damage 2, Cleave 2). The source has no equipment-option rows. Its four Support targets are Bladeguard Veteran Squad, Sternguard Veteran Squad, Assault Intercessor Squad and Victrix Honour Guard.

## Integrated local scope

The suite checks the exact profile and local construction catalog, then materializes Kaius from the consolidated Marine catalog for both players. All fixed weapons pass the shared Equipment and AttackPlan checks. It confirms his Support role, Combat Doctrines, Veteran Bodyguard and Calgar's Champion. All four source-listed Support targets are allowed, an unlisted Intercessor target is rejected, and the preparation choices expose Kaius's attachment.

The test forms an attached unit with a Captain as Leader and Kaius as Support. Veteran Bodyguard grants Feel No Pain 4+ to the other Character, but not Kaius himself. Calgar's Champion adds hit and wound rerolls of 1 against a Character target and does not apply against ordinary Intercessors. The suite also checks Kaius's Warlord eligibility and receipt of the active army Combat Doctrine.

## Verification

The focused offline run passed **3/3 processes**: import, Python checks and `test_kaius_konorius`. It used `network: false` and `legacy_starter_staged: false`, with no cleanup diagnostics.

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_kaius_konorius --timeout 300
```

Report: `.tools/verification/20261027T225347438197Z/results.json` (SHA-256 `4114937293a141fc6bc0d9de706583120434a7247237c01b7ef73f504f8b46ca`).

## Boundaries

This closes only Kaius's shared-book local datasheet scope. Ultramarines Chapter rules, complete army legality, network behavior, complete-match certification and human playtesting remain outside this result. Network validation remains deferred to final integration.
