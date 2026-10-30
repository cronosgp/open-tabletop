# Wolf Scouts

## Scope

This record covers Space Wolves App datasheet `000004182` in the standard 11th-edition army context. Facts come from the verified local Wahapedia 11e Data Export snapshot `20261029T003124Z`, updated `2026-10-28T23:48:19+03:00`. Its subject-scoped slice has zero structural findings. The parent export has 68 findings outside this slice; those are not reported as passed. See the [machine-readable source and hash audit](marine-wolf-scouts-audit.json).

## Source-bounded profile

| Composition | First/second copy | Third-plus copy |
|---|---:|---:|
| 6 models | 95 points | 105 points |
| 12 models | 190 points | 200 points |

Each unit contains one Wolf Scout Pack Leader, one Hunting Wolf for six models or two for twelve, and four or nine Wolf Scouts respectively. The Pack Leader and ordinary Scouts have M8, T4, Sv3+, W2, Ld6+, OC1 and 32 mm bases. Each Hunting Wolf has M10, T4, Sv6+, W1, Ld8+, OC0 and a 60 x 35.5 mm oval base. The runtime uses a 30 mm circular proxy for that oval, documented as a geometry limitation rather than an exact base representation.

Default weapons are Plasma Pistol and Power Weapon for the Pack Leader, Teeth and Claws for each Hunting Wolf, and Plasma Pistol and Combat Knife for each Wolf Scout. One ordinary Scout can replace both default weapons with a Bolt Pistol, Runic Stave or Thunderclap; one can instead replace its Plasma Pistol with a Plasma Gun while keeping its Combat Knife. One Instigator Bolt Carbine is allowed per twelve models. One model with a Plasma Pistol can carry the unit's Haywire Mine.

The runtime registers Scouts 8, Infiltrators, Combat Doctrines, Deadly Stalkers, Hunting Hounds and Haywire Mine. Deadly Stalkers adds 1 to Wound against a target more than 6 inches from every other enemy unit. Hunting Hounds grants a Hunting Wolf +1 OC while within 6 inches of a friendly Space Wolves Character, excluding Wulfen, when the unit is not Battle-shocked. The Haywire Mine is used once per battle per unit in the Shooting phase against a visible enemy within 6 inches; on a 2+, it deals D3 mortal wounds, or 2D3 against a Vehicle. Its wounds enter the shared defender allocation flow.

The three source-listed Leaders—Captain, Lieutenant and Librarian in Phobos Armour—are linked through the current Leader catalog. The local positive Hunting Hounds Character test uses a synthetic Space Wolves Character fixture because no Space Wolves Character datasheet is integrated yet. The test separately confirms Chapter context does not add a Space Wolves datasheet keyword to a generic Phobos Captain.

## Verification and limits

The focused Wolf Scouts suite passed 3/3 offline processes. The connected regression passed 11/11 processes and includes catalog admission, Leader links, capability metadata, Incursor/Haywire, Fenrisian Wolves, Scout Squad and roster validation. Exact commands, reports and SHA-256 values are in the [verification log](verification/verification-results.md#wolf-scouts-source-bounded-local-scope--29-october-2026).

This closes only the local Wolf Scouts datasheet scope. The Hunting Wolf base proxy, positive Hunting Hounds fixture, deferred network/page validation, human playtesting, full Chapter restrictions and full army legality remain outside the evidence. The parent export's 68 unrelated structural findings remain unresolved and were not used to certify this sheet.
