# Ravenwing saved equipment — 15 November 2026

## Source boundary

This is an equipment-option audit for Warhammer 40,000 11th edition, the Space Marines faction and the Dark Angels App datasheets in source book `000000023`. It covers the local matched-play construction profiles and does not add alternate game modes or certify full army legality.

The option rows and cost tables were inspected in the verified local Wahapedia Data Export snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`; `Last_update.csv` records `2026-10-21 16:06:23 GMT+3`. The export specification is revision `20260817b`. Its `manifest.json` SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. The raw export remains ignored under `.tools/wahapedia/11e/space-marines/20261021T130623Z`.

The runtime source-review registry binds both unchanged Marine profiles to the separately recorded verified-against snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, manifest SHA-256 `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`, Space Marines slice-manifest SHA-256 `63babe1ca34885808f13f7250bd2f1f490fbeb0ba386e9bae1280a93802397f8`, and Marine runtime digest `2ccdd7fecb2d18b5e3be87712c0823ca301caf3afa970610cc9e185bb36a5d68`. That binding is kept distinct from the 21 October option-row extraction used for this audit.

| Datasheet | Book | Datasheet ID | Local composition and copy prices |
|---|---:|---:|---|
| Ravenwing Black Knights | `000000023` | `000000241` | Huntmaster plus 2–5 Black Knights; 3/6 models. First two copies: 85/170 points; third-plus copies: 95/180 points. |
| Ravenwing Command Squad | `000000023` | `000002748` | Fixed Ancient, Apothecary and Champion; 3 models. First two copies: 115 points; third-plus copies: 135 points. |

Each local `Datasheets_options.csv` row says: “For every 3 models in this unit, 1 model can have their Plasma Talon replaced with 1 Grenade Launcher.” No equipment surcharge is listed. The Command Squad's three role models are fixed; its Grenade Launcher may be borne by any one of them.

| Local source file | SHA-256 |
|---|---|
| `Datasheets_options.csv` | `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853` |
| `Datasheets_models_cost.csv` | `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e` |
| `Datasheets_wargear.csv` | `565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d` |

The Black Knights row is sourced from the local export and cross-checked against the existing [Black Knights sheet audit](../marine-ravenwing-black-knights.md). The Command Squad identity, fixed roles, weapons and prices match the existing [Command Squad sheet audit](../marine-ravenwing-command-squad.md). No online lookup was needed for this implementation.

## Saved behavior

The Army Workshop stores the Plasma Talon replacement as one boolean field on each stable model/copy record. The two adapters use the local Black Knight and role-specific Command Squad weapon factories; validators reject unknown fields, unsupported compositions and more than one launcher per three starting models. The six-model Black Knights regression preserves two different launcher bearers. Saved weapons apply before Deployment, and both old Ravenwing preparation actions are hidden and reject forced edits without changing match state. Copy-tier prices and the zero equipment surcharge are unchanged.

The focused fixture writes and reopens a mixed army in another Godot process, tests 3/6-model and one/three-model caps, verifies the two- and three-copy price tiers, materializes every saved model for both players, checks the exact local weapon packages and role locks, and exercises real Workshop control signals.

## Visible evidence

These are actual staged Godot Compatibility captures at 1280×800. The model names remain visible above selectors; six-model and Command Squad lists use the inspector's inner scroll area.

- [Three-model Black Knights](../../.tools/ravenwing-equipment-20261115/after/ravenwing-black-knights-3-saved-1280x800.png)
- [Six-model Black Knights, top](../../.tools/ravenwing-equipment-20261115/after/ravenwing-black-knights-6-saved-1280x800.png)
- [Six-model Black Knights, lower rows](../../.tools/ravenwing-equipment-20261115/after/ravenwing-black-knights-6-saved-lower-1280x800.png)
- [Ravenwing Command Squad, top](../../.tools/ravenwing-equipment-20261115/after/ravenwing-command-squad-3-saved-1280x800.png)
- [Ravenwing Command Squad, lower row](../../.tools/ravenwing-equipment-20261115/after/ravenwing-command-squad-3-saved-lower-1280x800.png)
- The selected model records are also preserved in the ignored [capture observations](../../.tools/ravenwing-equipment-20261115/after/observations.json).

The capture process exited 0 but emitted Texture RID leak messages and a 55-ObjectDB cleanup warning at shutdown. These scripted screenshots show layout and state only; they are not a human usability review or small-window test.

## Verification and limits

An initial test draft called a non-public `sizes()` helper and failed; its replacement assertions exercise the real saved-loadout validator. The corrected focused run, including saved and materialized six-model Black Knights, passed **3/3 processes** at `.tools/verification/20261115T065413288112Z/results.json` (SHA-256 `CD90BEFCAC5F009EE8DA7CAD8F72A9D0005DC72EEFC95E23AA46A437591492BD`). The final Ravenwing/adjacent-profile regression command passed **13/13 processes** at `.tools/verification/20261115T070347136336Z/results.json` (SHA-256 `338DF731C8DDC0E3BFAEE4DA46EE0A81BA6CB99305791CEFBD373F0CBAB2B82A`). Both runs disabled network and staged the historical starter. In the final batch, the Army Builder and implemented-catalog processes passed with their existing shutdown cleanup diagnostics; other selected processes reported none. The Python coverage ledger suite passed 6/6 tests.

This evidence covers the local saved-equipment adapter and source-option completeness only. It does not certify every Ravenwing rule, Dark Angels or Space Marines army legality, sculpt parity, human usability, network play or completion of the wider ForceOrg visual-variant plan.
