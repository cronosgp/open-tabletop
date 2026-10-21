# MFM 1.6 Incursion reference rosters (A3)

Implemented 17 October 2026; source-boundary review updated 21 October. The 930/880 Incursion lists remain experimental reference rosters. MFM 1.6 values below are a preserved historical price snapshot, not a current rules/legality certificate. Wahapedia `/wh40k11ed/` is the definitive project reference; runtime manifests keep full-match certification false because the complete rules and army scope has not been established across all dependencies.

## Sources and version boundary

The [11e core reference](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/), Muster Your Army section 25, supplies the selected construction baseline. The historical official [Space Marines MFM](https://mfm.warhammer-community.com/en/space-marines) and [Necrons MFM](https://mfm.warhammer-community.com/en/necrons), version 1.6, were captured on 17 October 2026 for the earlier reference-roster snapshot. Current profile availability and prices for new construction choices come from the consolidated local runtime catalog. A selected profile or historical points snapshot does not certify general roster legality; see [current unit abilities](current-unit-abilities.md) for implemented profile scope.

For this historical roster snapshot, the live official MFM 1.6 page was used to record the prices that were then tested. This earlier choice does not set current project source policy: new construction prices come from the consolidated local Wahapedia runtime profile. The MFM snapshot below remains context for these experimental saved lists only. Cached complete HTML SHA256:

- Space Marines: `af280e710928f49d6c22775ae48fa9a5fe78de7560cf2c6712eb6d48a885c5e5` (`.tools/mfm-marines.html`).
- Necrons: `8ff758aedca89d8ea98c3912048b572b8d6ae2a5f66477a811973b91e505ee94` (`.tools/mfm-necrons.html`).

The implementation pins the source version, hashes, construction table and profile identity in its digest. This is a dated snapshot, not automatic certification of later MFM releases.

## Admitted prices

| Fixed profile | Models | MFM 1.6 points | Historical saved reference |
|---|---:|---:|---:|
| Intercessors | 5 | 85 | 80 |
| Assault Intercessors | 5 | 85 | 75 |
| Heavy Intercessors | 5 | 115 | 100 |
| Terminators | 5 | 190 | 160 |
| Captain | 1 | 90 | 80 |
| Lieutenant | 1 | 50 | 45 |
| Warriors | 10 | 85 | 85 |
| Immortals | 5 | 65 | 70 |
| Overlord | 1 | 90 | 90 |
| Royal Warden | 1 | 50 | 50 |

The fixed Terminator profile has no Cyclone missile launcher: its optional +10 cost is not silently included or admitted. The MFM third-copy Terminator cost is recorded as 230, but an Incursion third copy is rejected by the repetition rule. Optional equipment, enhancements, other squad sizes, chapter variants and allies are outside this profile. Existing fixed loadouts are used; selected optional wargear cost is zero.

## Construction and formations

- Incursion only, 1,000-point ceiling. Maximum two copies of each admitted datasheet, doubled to four for Battleline, using the curated current keyword rather than a user-supplied role. Checked lists may contain up to twelve units; the six-unit cap remains for ordinary training mixed lists.
- Incursion allowance is 2 DP, with the explicit exception permitting **one 3DP detachment as the only detachment**. Gladius and Awakened each use that exception. Duplicate detachments or additional detachments over allowance are rejected. Each selected detachment has Take and Hold disposition.
- At least one admitted Character is required. Preparation cannot finish without an owned Character Warlord and all Lieutenant Support models legally attached. Formation verification is recorded only after those declarations pass.
- No enhancements or custom equipment are admitted. Explicit unsupported saved-list selections are rejected rather than ignored. This does not implement the general enhancement system.

Saved names, prices, roles and source claims never authorize match costs. Saved lists remain unchanged; the review shows their reference total separately. Admission reconstructs canonical definitions and current prices on the host, including reserve-point accounting. Both peers, immutable preparation manifests, saves and authenticated host-restart recovery preserve the same construction/version digest. Old unchecked training sessions retain their separate prices and behavior.

Two additional selectable starter lists use these captured MFM prices: **Captain + Intercessors + Heavy Intercessors**, and **Overlord + Warriors + Immortals + Royal Warden**; each totals **290 points** under the 1,000-point ceiling. Reference Incursion lists total **930 points** for Gladius (Captain, four Heavy Intercessor Squads, two Terminator Squads) and **880 points** for Awakened (two Overlords, two Royal Wardens, four Warrior squads, four Immortal squads). They are not current-Codex legality or competitive-balance certification. They are offered alongside existing presets and are not automatically inserted into the user's saved profile.

## Certification boundary and next work

A3 MFM 1.6 pricing and the documented construction/formation checks are implemented for this fixed subset. `roster_points_validated` records the captured points scope. Since current Codex datasheet/effect applicability is not fully reconciled, runtime matches keep `official_legality_validated` and `full_match_certified` false. A passing test suite cannot establish current rules accuracy.

Filling the remaining points after 930/880 needs more admitted datasheets via the [post-Track-A catalog pipeline](../data/faction-catalog.md). Other missions, terrain layouts and armies remain separate expansions. See [Track A](../project/track-a.md), [A5](../project/track-a-a5.md) and [verification results](../verification/verification-results.md).
