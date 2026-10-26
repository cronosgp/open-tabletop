# Vow-sworn Crusaders

Vow-sworn Crusaders is a **partial local implementation** for the 11th-edition Space Marines rules. It requires Black Templars Chapter context and the current unit-abilities option.

At the start of the first battle round, the Black Templars player may select the supported `Uphold the Honour of the Emperor` Vow or skip selection. The other two Templar Vows are not offered.

When selected, the supported Vow has two local effects:

- At the end of the player's Movement phase, an objective is secured if a controlling current-reference Adeptus Astartes Infantry unit is controlling it.
- A current-reference Adeptus Astartes Infantry unit can start an otherwise eligible action after Advancing. Falling Back still prevents action starts unless another supported rule permits them. All other action gates remain active.

## Unsupported scope

The game does not implement the other two Templar Vows, Vow-sworn Crusaders enhancements or stratagems, or the detachment's 2 DP Force Disposition. This option is for local practice and does not certify army legality. Focused checks, playtesting and network validation remain pending.

## Source and implementation record

- Rules reference: [Wahapedia, Space Marines, 11th edition](https://wahapedia.ru/wh40k11ed/factions/space-marines/), App 2.8.1, observed 26 October 2026.
- Local Data Export: snapshot `20261021T130623Z`, revision `20260817b`, retrieved 21 October 2026 at `2026-10-21T19:46:58Z`.
- `Detachments.csv`, row `000001230`: SHA-256 `e8790f57ee8210513102bc736ddd72d24e4a70ddffba6f09d92244d68b12c585`.
- `Detachment_abilities.csv`, row `000011171` (`Templar Vows`): SHA-256 `92121fb215c41e5ff2c7c33a38c7ca0835f91887fb41670dc6a17694d1c3d7fe`.
- Runtime implementation: `scripts/edition_11/templar_vows.gd`; enabled capability: `templar-vows-uphold`.

The export supplies local detachment and ability facts; the live 11th-edition faction page remains the selected rules reference. No export data is copied into this document beyond row identity and provenance.
