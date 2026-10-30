# Sammael (Dark Angels App)

**Status:** source-bounded local scope passed on 28 October 2026. The checks cover the current fixed profile, every weapon, Warlord and Combat Doctrine choices, both datasheet abilities, the source Leader links and current-catalog admission. They do not certify complete Dark Angels or Space Marines army legality.

## Source identity

- [Wahapedia 11th-edition Sammael](https://wahapedia.ru/wh40k11ed/factions/space-marines/Sammael), Dark Angels App datasheet `000002291`, book `000000023`.
- The current page was checked on 28 October 2026 against Dark Angels App revision 2.8.1 (October 2026). Fixed facts come from verified local Data Export snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, export specification revision `20260817b`; source row stamp `2026-10-21 16:06:23 GMT+3`.
- The machine audit records the scoped source slice and hashes. Its two subjects have no structural validation errors. The parent export has 68 errors outside the slice; this sheet audit does not claim those errors passed. Raw exports remain outside Git.

## Profile and weapons

- One model, 120 points, one supported copy. M12, T6, Sv3+, W7, Ld6+, OC2, 4+ invulnerable save and a 60 mm round flying base. The profile has the eleven keywords in the pinned local export plus a runtime `MOBILE` classification tag; `MOBILE` is not certified as a printed datasheet keyword.
- **Bolt Pistol:** 12", A1, BS2+, S5, AP-1, D1, Close-quarters.
- **Master-crafted Plasma Cannon:** 36", A3, BS2+, S8, AP-3, D3, Blast 1.
- **Twin Storm Bolter:** 24", A2, BS2+, S5, AP-1, D1, Twin-linked, Rapid Fire 2.
- **The Raven Sword:** A6, WS2+, S6, AP-3, D2, Sustained Hits 2.

## Rules and attachments in the checked scope

- **Leader:** Sammael can lead Outrider Squad or Ravenwing Black Knights; both links are represented. He is eligible to be selected as Warlord.
- **Transhuman Strategist:** when Sammael is the Warlord, the shared battle-round start path grants 1 CP, limited to once per battle round.
- **Cut Off Their Escape:** when an eligible enemy unit engaged with Sammael's unit Falls Back, it must use Desperate Escape. MONSTER and VEHICLE units are excluded. A Battle-shocked unit applies -1 to each Hazard roll; the modifier remains on a Command Re-roll.
- **Grand Master of the Ravenwing:** during Sammael's Command phase, choose an available Combat Doctrine for his unit. The doctrine lasts until the start of his next Command phase and uses the shared doctrine selection limits.

## Verification and limits

The current-catalog focused run passed **9/9 processes** at `.tools/verification/20261028T123024695254Z/results.json` (SHA-256 `4F9C777FDCA0F947637893E529B1331A6605B0C4660871200B2CAE6745ACBD0A`; `network: false`, no legacy starter staged, no cleanup diagnostics). It includes import, Python checks, Sammael, Ravenwing Command Squad, Ravenwing Black Knights, Wardens of Ultramar Support transfer, shared Leader/Support links, Ancient and Apothecary regressions.

These checks are local and offline. They do not certify the parent export globally, full army legality, network behavior, complete matches or human playtesting. Forge World, Legends, Boarding Actions and other alternate modes are outside this scope.
