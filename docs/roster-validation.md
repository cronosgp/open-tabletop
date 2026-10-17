# Checked Incursion rosters (A3)

Implemented 17 October 2026. Enable **Next prepared match: checked Incursion rosters (MFM 1.6)** in Match setup. This enables the selected current mission and required ability profiles. It validates construction and prices for ten fixed profiles; it does not certify a complete official match.

## Sources and version boundary

The requested [11e core reference](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/), Muster Your Army section 25, supplies the detailed Incursion construction rules. The official June core PDF continues army construction in the app, so it is not claimed as an independent reproduction of that whole section. Current official [Space Marines MFM](https://mfm.warhammer-community.com/en/space-marines) and [Necrons MFM](https://mfm.warhammer-community.com/en/necrons), live **version 1.6**, were checked on 17 October 2026 for points and detachment DP. Individual current `/wh40k11ed/` faction datasheets were checked for admitted counts, Battleline and equipment permissions; existing ability-source boundaries remain in [current unit abilities](current-unit-abilities.md).

Search-indexed official pages still exposed version 1.0. Ordinary direct HTML retrieval returned live version 1.6; streamed React card references were reconstructed before extracting each selected unit's count and price. Historical imported costs and older indexed prices are not current-price certification. The live official MFM takes precedence for this profile. Cached complete HTML SHA256:

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

Two additional selectable starter lists use current prices: **Captain + Intercessors + Heavy Intercessors**, and **Overlord + Warriors + Immortals + Royal Warden**. Each totals **290 points**, under the 1,000-point ceiling. Checked Incursion lists under the same ceiling are a **930-point Gladius** list (Captain, four Heavy Intercessor Squads, two Terminator Squads) and an **880-point Awakened** list (two Overlords, two Royal Wardens, four Warrior squads, four Immortal squads). They are not competitive balance certification. They are offered alongside existing presets and are not automatically inserted into the user's saved profile.

## Certification boundary and next work

A3 current pricing and the documented construction/formation checks are implemented for this fixed subset. `roster_points_validated` records points scope. Checked CA matches now set `official_legality_validated` and `full_match_certified` for the implemented Gladius 930 vs Awakened 880 infantry core. Passing tests still cannot establish rules accuracy beyond the checked sources and declared scope.

Filling the remaining points after 930/880 needs more admitted datasheets via the [post-Track-A catalog pipeline](faction-catalog.md). Other missions, terrain layouts and armies remain separate expansions. See [Track A](track-a.md), [A5](track-a-a5.md) and [verification results](verification-results.md).
