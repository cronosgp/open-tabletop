# Corvus Blackstar local datasheet scope

## Source identity

The Deathwatch App datasheet is source `000000358` in Wahapedia 11th edition. The profile uses the verified local Data Export snapshot `20261029T003124Z`, exported at `2026-10-28T23:48:19+03:00`, specification revision `20260817b`. The parent manifest SHA-256 is `457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d`; the scoped Corvus slice SHA-256 is `fb094a1ec9d55c54de7d19d3b0b61f4d7517c00341bfa3c331b5d32d6109530b`. The subject slice has no structural errors; the parent export has 68 unrelated validation errors. Raw exports stay in ignored `.tools/`. Per-file hashes and checked facts are in the [machine-readable audit](marine-corvus-blackstar-audit.json).

## Integrated local scope

The construction catalog now offers the one-model, 180-point Corvus Blackstar: M14, T10, Sv 3+, W14, Ld 6+, OC0. It has FLY, Hover, Stealth, Damaged 5, Deadly Demise D6 and Combat Doctrines. The corrected keyword set has no AIRCRAFT.

The loadout includes two Blackstar Rocket Launchers, Twin Assault Cannon and Armoured Hull. Army Preparation can add a Hurricane Bolter, replace Twin Assault Cannon with Twin Lascannon, or replace both rocket launchers together with two Stormstrike Missile Launchers. Auspex Array grants Ignores Cover to each ranged weapon profile. The transport carries up to 12 DEATHWATCH INFANTRY; GRAVIS, JUMP PACK and TERMINATOR models each use two spaces.

At the end of a Normal move, the optional Blackstar Cluster Launcher can target one enemy unit crossed by the Corvus route. It rolls six D6 and causes one mortal wound per result of 4+. The normal mortal-wound allocation and prevention flow resolves those wounds before the movement continuation closes.

## Verification and limits

The targeted verifier passed all 11 processes: import, Python and nine selected suites (`test_corvus_blackstar`, transport admission, profiles, weapon options, transport rules, destruction, core reactions, implemented catalog and capabilities). The report is `.tools/verification/20261029T014037131740Z/results.json` (SHA-256 `208952A8F4E703098FD80F8F434288DE8A3D4E7948AAFA390EA7FE5FDB11E24D`; `network: false`; no cleanup diagnostics). The focused Corvus suite checks source identity, characteristics and ability gates, all loadout operations, actual move-window opening, recorded route segments, six-die result, mortal allocation and movement continuation. Network validation, full faction/army legality, human playtesting and complete-match certification remain open.

Movement-over checks use the recorded two-dimensional movement segments and a labelled 60 mm bounding-circle proxy for the 120 x 92 mm oval. They do not model vertical separation or exact oval-footprint collision. This closes the declared local sheet scope, not certification of every interaction.
