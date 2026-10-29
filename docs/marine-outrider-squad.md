# Outrider Squad — source-bounded local scope

This closes the shared-book 11th-edition local datasheet scope for [Outrider Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Outrider-Squad), source book `000000139`, datasheet `000002712`. The profile was checked against the verified local Wahapedia export snapshot and the live 11e page on 28 October 2026. This result does not certify full army legality or network behavior.

## Implemented and checked

- The source's 3/6-model compositions cost 80/160 points at every supported copy tier. Characteristics, shared keywords and all three default weapons are represented on every model. The source oval base is 90 × 52 mm; the runtime uses a clearly labelled 45 mm bounding-circle proxy, not exact oval collision geometry.
- Heavy Bolt Pistol, Twin Bolt Rifle and Chainsword match their source profiles. The Sergeant can freely replace its Chainsword with a Power Weapon or Thunder Hammer. Any model can freely replace its Heavy Bolt Pistol with a Plasma Pistol, capped at one per three starting models. All replacement profiles, including both Plasma Pistol modes, resolve through Equipment and AttackPlan. Public commands reject the wrong owner and enforce the cap; the choices can be reversed without changing points.
- Full-throttle Assault is checked in prepared melee attacks. After a Charge, Chainswords and Power Weapons gain +1 Damage and Sustained Hits 1. Thunder Hammers gain +1 to Hit and Sustained Hits 1, without a Damage increase. These bonuses are absent without a Charge.
- The shared-book Leader map contains Captain on Bike, Chaplain on Bike and Suboden Khan as eligible Leaders; the suite performs an owner-checked public Captain on Bike attachment. No common-book Support target is declared. The source's Ravenwing Command Squad relation belongs to the Dark Angels App and is outside this 85-sheet construction catalog.
- RAVENWING is removed from the prepared shared profile outside Dark Angels context and granted in Dark Angels context. Both players materialize Outriders from the consolidated local Marine catalog; the local three-copy construction ceiling is checked.

Focused offline verification passed **5/5 processes** at `.tools/verification/20261028T063311613901Z/results.json` (network disabled; legacy starter not staged; no cleanup diagnostics). See the [machine-readable audit](marine-outrider-squad-audit.json) for source hashes, implementation hashes and verification limits.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_outrider_squad_current --only test_marine_conditional_weapon_traits --only test_space_marine_leader_links --timeout 300
```

## Limits

This closes only Outrider Squad's shared-book local scope. Oval-base movement and contact still use the labelled circular proxy. The Dark Angels App Support relation, other Chapter-book content, full faction/army legality, network behavior, complete-match certification and human playtesting remain outside this result. Network validation remains deferred to final integration.
