# Ballistus Dreadnought — current e11 datasheet scope

This audit closes only the shared-book Ballistus Dreadnought profile against the verified local Wahapedia 11th-edition Data Export snapshot `20261021T130623Z`. It does not certify full faction or army legality.

## Source and profile

- **Source:** [Ballistus Dreadnought on Wahapedia](https://wahapedia.ru/wh40k11ed/factions/space-marines/Ballistus-Dreadnought), shared Space Marines book `000000139`, datasheet `000000091`.
- **Pinned export:** retrieved 2026-10-21; specification revision `20260817b`; manifest SHA-256 `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. The machine-readable audit records the relevant export filenames and hashes.
- **Profile:** one model on a 90 mm base; M8, T10, Sv2+, W12, Ld6+, OC4; 150 points for the first two copies and 170 for the third-plus tier in local construction.
- **Fixed loadout:** Ballistus Lascannon; Ballistus Missile Launcher with Frag and Krak profiles; Storm Bolters; Armoured Feet. The export contains no equipment-option rows for this sheet.

## Local behavior covered

- Every listed ranged and melee weapon mode is checked through `Equipment.select` and `AttackPlan` with its exported characteristics and weapon traits.
- Ballistus Strike grants Sustained Hits 1 to ranged attacks against a unit at or within 24 inches, including the measured base-edge boundary; it ends immediately beyond that range and does not affect melee.
- Damaged 4 applies the -1 Hit modifier at four remaining wounds and stops at five, in the actual attack plan.
- Deadly Demise D3 checks the trigger boundary, per-unit mortal-wound packets, defender-owned allocation, a chained Ballistus destruction, save/restore of the pending decision and attack frame, and resumption after the allocation.
- Current-catalog construction is exercised for both players. Local Incursion admission checks one, two and three copies at 150/300/470 total points and rejects a fourth.
- The paired Space Marines Leader/Support relation suite still checks the shared 153-link map; it does not extend this datasheet's scope to all linked units.

## Verification

Focused verification passed **5/5 processes** (import, Python checks, the Ballistus scope, fixed-data parity, and the 153-link relation suite) at `.tools/verification/20261027T084333440820Z/results.json`. The report records `network: false`, no legacy starter staging, and no cleanup diagnostics.

The implementation uses the consolidated local runtime catalog and does not fetch external catalog choices. Network validation remains deferred to final integration. Chapter-book variants, Forge World, Legends, Boarding Actions, full army legality, complete-match certification and human playtesting remain outside this result.
