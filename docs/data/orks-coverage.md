# Orks datasheet coverage

## Source of truth

Current Orks datasheet facts for this project come from the local Wahapedia 11e Data Export. The export was retrieved at `2026-10-31T05:33:36Z`; its metadata says it was updated at `2026-10-30T22:19:16+03:00`. The selected source is the Orks App, book ID `000000046`, version `1.2`. Wahapedia is used only to resolve Core Rules definitions absent from the local datasheet extraction (`CLEAVE X` and `Super-heavy Walker` from `/wh40k11ed/the-rules/core-rules/`, June 2026 revision).

Snapshot directory: `.tools/wahapedia/11e/orks/20261031T053336Z-orks-slice`. Parent manifest SHA-256: `e292e43a4dc90ed529c60ac988d7f3351ae287a6bdfa8b85e9c818806b9020ef`. The focused Orks slice has 54 datasheets and zero subject-scoped structural findings (`slice_error_count: 0`, `external_identity_only: 4`). Slice manifest SHA-256: `e1b230898eedfa32c66ec839812270a6a3fc364eee9b95732585c204cf9d40f1`. Derived slice catalog SHA-256: `23d403a227ecaaeedd0c78492e0210e5f0b347f78faaee7549dee2d4a3bd9cb9`. The parent export still reports 68 global findings; those are not findings in this Orks slice.

The runtime record keeps these identifiers and hashes in `scripts/edition_11/current_reference_orks_profiles.gd`. The raw export and derived slice remain in the ignored `.tools/` tree and are not shipped with the game.

| Export file | SHA-256 |
|---|---|
| `Factions.csv` | `5d6fa825d2c7e8934c64cf4d85696cfea98b6e981d06103eb250ac7df2947535` |
| `Source.csv` | `20177d38c72e09e3c7a3976f197581c9258eee704433e1196e90e9664ed6e102` |
| `Datasheets.csv` | `353a6c7f769435cc4c3ff5b932a39e3b7bbbc9ed58c0f5316f1b60e98b2cd620` |
| `Datasheets_abilities.csv` | `6e68866cd1cd64096380367fd1dd957fb7c7cf64f220aaf9d660c4db1281c513` |
| `Datasheets_keywords.csv` | `3a5cd3e2b170831e830ef2189cbf3a7dff9caf817c26219f793ebe34f12e0131` |
| `Datasheets_models.csv` | `e4282a1be0b643fbf437c465aaf8c336a4bbb22ed4e5114217d836d5eacb614f` |
| `Datasheets_options.csv` | `680fabab698203695614252b649baa03a693298453f668ce07426587ce93a0f7` |
| `Datasheets_wargear.csv` | `9fdc42b03f27174ca1fc5664a59aa356b089cd34c14061849fab3251758d4863` |
| `Datasheets_unit_composition.csv` | `db79eb633bc6ee8164448e659b38bd35c7cde535d79fa1ba7ffbc35d66f4f319` |
| `Datasheets_models_cost.csv` | `2e677a38bf3036645a0efed691785c2b939c0c26a20c0da07929e60bcd59f657` |
| `Datasheets_leader.csv` | `0cc428cab9808e9431fadb5eeab8c3e389a30308be8f18b635bc6c840672df77` |
| `Datasheets_stratagems.csv` | `1b4b75d1018bfed807224e99ce18728bf503eb924714c0abddd170486e46e46b` |
| `Datasheets_enhancements.csv` | `3325055b51af129796e79d735a18a4fb80967f3ac3ada346d6d897bfa7de1446` |
| `Datasheets_detachment_abilities.csv` | `2cbcff8d7eab717d5097c36cdddef581a5a922ac36510b1fcd6b7a697b7c4795` |

## Current progress

| Scope | Status |
|---|---|
| Source identities | 54/54 matched by datasheet ID and name to the local slice (`000000046`, App v1.2). |
| Current profile facts & admission | 54/54 admitted into runtime construction (`23` saved-equipment schemas in `ork_saved_equipment.gd`, `31` fixed-equipment profiles), with copy-tier pricing, wargear surcharges (`Meganobz`, `Nobz`, `Gunwagon`), Leader/Support links, and focused local checks (`test_orks_core_rules`, `test_orks_batch1`–`test_orks_batch5_6`). |
| War Horde detachment (`000000852`) | Implemented in `war_horde.gd` (`Get Stuck In`, 4 Enhancements, 6 Stratagems). Other 14 standard + 2 Boarding Actions detachments remain deferred. |
| Core 11e Orks mechanics | `Waaagh!` (`riled up` / `War Cry` / Advance re-roll), `Da Boss`, `Unstable Energies`, `CLEAVE X`, conditioned weapon traits, `Super-heavy Walker`, and consumable tokens implemented. |
| Legends (`000000377`, 12 sheets) & Forge World (`000000378`, 1 sheet) | Explicitly excluded from standard construction. |
| Full roster legality and certification | 0/54. Separate gate, not implied by local fact checks; oval and `Use model` bases use disclosed circular proxies; separate-machine LAN remains deferred. |
