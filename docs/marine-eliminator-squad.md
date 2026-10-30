# Eliminator Squad

This audit closes the **shared-book local scope** for Eliminator Squad in the common Space Marines book. It uses the [11th-edition Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Eliminator-Squad), the [Core Rules](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) and the verified local Data Export snapshot recorded with hashes in the [machine audit](marine-eliminator-squad-audit.json).

## Source profile and choices

The fixed unit has one Eliminator Sergeant and two Eliminators, all on 40 mm bases. Each model has M8, T4, Sv3+, W2, Ld6+ and OC1. The unit costs 85 points. All three models start with a Bolt Pistol, Bolt Sniper Rifle and Ceramite Fists.

The Sergeant may replace its Bolt Sniper Rifle with an Instigator Bolt Carbine or a Las Fusil. Each ordinary Eliminator may independently replace its own Bolt Sniper Rifle with a Las Fusil. The local setup presents these as model-specific, reversible choices, so mixed sniper/Las Fusil squads remain legal. Incursion is the supported roster mode; its two-copy unit limit is enforced. Strike Force admission is not implemented.

The shared keywords are `INFANTRY`, `EXPLOSIVES`, `IMPERIUM`, `PHOBOS` and `SMOKE`, with `ADEPTUS ASTARTES` as the faction keyword. Source-listed Leaders are Captain in Phobos Armour and Librarian in Phobos Armour; Lieutenant in Phobos Armour is the listed Support. The common-book relation suite checks all 153 Leader/Support links.

## Rules covered

All five source weapon profiles pass the shared Equipment and AttackPlan checks. The Instigator Bolt Carbine's Rapid Fire 2 and Precision are represented, and its conditional Lethal Hits are removed against MONSTER or VEHICLE targets without mutating the stored source profile. Las Fusil retains Heavy and D3+3 Damage; the Bolt Sniper Rifle retains Heavy and Precision.

Chameleoline Cloaks applies the source -3-inch detection modifier. The sheet registers Infiltrators, Stealth and Combat Doctrines. Special-issue Optics and Ammunition offers one of the source choices when the unit is selected to shoot: ranged Ignores Cover, or +6 inches detection for one enemy within 24 inches. The selection can be revised or cancelled before shooting, locks other units out until resolved, and expires after the unit shoots even when it misses.

## Local evidence

The focused offline command passed **4/4 processes** on 28 October 2026:

```powershell
python tools/verify.py --godot C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_eliminators --only test_space_marine_leader_links --timeout 300
```

Both rosters use the consolidated Space Marines catalog. The dedicated scope run disabled networking and did not stage the optional historical starter. A broader 7/7 behavior regression also passed; that run staged the optional starter for one or more shared-rule fixtures, as recorded in its report. The [machine audit](marine-eliminator-squad-audit.json) records both reports, source revision, local snapshot, all 23 file hashes and scope limits.

This result closes only the source-bounded local datasheet scope. It does not certify full Chapter/faction or army legality, network behavior, complete matches or human playtesting. Network validation remains deferred to final integration.
