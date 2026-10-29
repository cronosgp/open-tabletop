# Ravenwing Command Squad (Dark Angels App)

**Status:** source-bounded local scope passed on 28 October 2026. The checks cover the fixed three-model composition, role-specific weapons, Grenade Launcher option and cap, all three role abilities, Support targets, complete attachment and current-catalog admission. They do not certify complete Dark Angels or Space Marines army legality.

## Source identity

- [Wahapedia 11th-edition Ravenwing Command Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Ravenwing-Command-Squad), Dark Angels App datasheet `000002748`, book `000000023`.
- The current page was checked on 28 October 2026 against Dark Angels App revision 2.8.1 (October 2026). Fixed facts come from verified local Data Export snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, export specification revision `20260817b`; source row stamp `2026-10-21 16:06:23 GMT+3`.
- The machine audit records the scoped source slice and hashes. Its two subjects have no structural validation errors. The parent export has 68 errors outside the slice; this sheet audit does not claim those errors passed. Raw exports remain outside Git.

## Profile, roles and weapons

- Three models: Ravenwing Ancient, Ravenwing Apothecary and Ravenwing Champion. The first and second copies cost 115 points; the third copy costs 135 points. Up to three copies are admitted by this local catalog gate.
- All roles use M12, T6, Sv3+, W4, Ld6+, OC2, 5+ invulnerable save. The source base is a 75 × 42 mm oval; local collision geometry uses a labelled 37.5 mm bounding-circle proxy.
- The Ancient and Apothecary each carry a Bolt Pistol, Plasma Talon and Corvus Hammers. The Champion carries a Bolt Pistol, Plasma Talon and Master-crafted Power Weapon.
- **Plasma Talon:** 18", A2, BS3+, standard S7/AP-2/D1; supercharge S8/AP-3/D2 with Hazardous. Both profiles have Rapid Fire 1.
- **Corvus Hammers:** A4, WS3+, S5, AP-2, D1, Devastating Wounds.
- **Master-crafted Power Weapon:** A6, WS2+, S6, AP-2, D2.
- One model per three may replace its Plasma Talon with a free **Grenade Launcher**: Frag is 24", A4, BS3+, S4/AP-1/D1, Blast 1; Krak is 24", A1, BS3+, S10/AP-2/D3, Rapid Fire 1.

## Rules and Support in the checked scope

- **Support:** the squad can join Outrider Squad or Ravenwing Black Knights. The preparation action transfers all three role models into the bodyguard unit, retaining role, wounds, inventory and defense state. Component starting strengths remain separate, so attaching it does not increase either component's per-three Grenade Launcher cap.
- **Astartes Banner:** while the Ancient is alive, every model in the combined unit has +1 OC.
- **Honour or Death:** while the Champion is alive, the combined unit adds 1 to Advance and Charge rolls. Heroic Intervention targeting it costs 1 fewer CP, to a minimum of 0.
- **Narthecium:** once per turn in the owner's Command phase, the living Apothecary can begin the shared D3+1 healing flow. The Command Squad models are Characters and cannot be returned as destroyed models by this effect.
- **Combat Doctrines:** the source-listed Army Rule uses the existing shared doctrine path.

## Verification and limits

The current-catalog focused run passed **9/9 processes** at `.tools/verification/20261028T123024695254Z/results.json` (SHA-256 `4F9C777FDCA0F947637893E529B1331A6605B0C4660871200B2CAE6745ACBD0A`; `network: false`, no legacy starter staged, no cleanup diagnostics). It includes both dedicated datasheet tests, Ravenwing Black Knights' Grenade Launcher cap, Wardens of Ultramar Support transfer, shared Leader/Support links, Ancient and Apothecary regressions, import and Python checks.

These checks are local and offline. They do not certify the parent export globally, full army legality, network behavior, complete matches or human playtesting. Forge World, Legends, Boarding Actions and other alternate modes are outside this scope.
