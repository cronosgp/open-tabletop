# Indomitor Kill Team - source-bounded local scope

**Status:** the fixed profile and declared local datasheet scope passed focused checks on 28 October 2026. This result does not certify full army legality, network behavior, complete-match behavior or human playability.

## Source identity

- Edition and mode: Warhammer 40,000 11th edition, standard army datasheet.
- Wahapedia page checked: [Indomitor Kill Team](https://wahapedia.ru/wh40k11ed/factions/space-marines/Indomitor-Kill-Team), 28 October 2026.
- Source book/datasheet IDs: Deathwatch App 000000035 / 000002781.
- Local Data Export snapshot: 20261021T130623Z, retrieved 2026-10-21T19:46:58Z, export updated 2026-10-21T16:06:23+03:00, revision 20260817b (URL query parameter).
- Snapshot manifest SHA-256: 169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf. Indomitor scoped-slice manifest SHA-256: d52d0ec3d53cf0a24bce0b7c9a89afe7612ea3d4868a8baa8bd46bbb1ce0f08d. The [machine-readable audit](marine-indomitor-kill-team-audit.json) records the snapshot filenames and file hashes.

## Profile and composition

The unit is fixed at ten models and costs 280 points for the first two copies, then 300 points from the third. Its three Aggressors carry Flamestorm Gauntlets and Twin Power Fists; three Eradicators carry Melta Rifles, Bolt Pistols and Ceramite Fists; four Heavy Intercessors carry Deathwatch Heavy Bolt Rifles and Ceramite Fists. The profile preserves the model-specific source characteristics, keywords and 40 mm bases.

Preparation can replace up to two Heavy Bolt Rifles with Deathwatch Heavy Bolters, replace the Flamestorm Gauntlets on any Aggressor with Auto Boltstorm Gauntlets and a Fragstorm Grenade Launcher, and replace one Melta Rifle with a Multi-melta. Reconfiguration preserves those limits and can restore the source defaults.

## Rules and attachments

Indomitor Doctrines adds 1 Strength to ranged attacks against the closest eligible enemy unit and 1 Strength to melee attacks if the unit charged this turn. The target comparison is evaluated for each attacking model and selected weapon profile; Hunter eligibility is applied before comparing legal targets. The modifiers are applied through the shared AttackPlan path.

The Deathwatch App lists the Captain in Gravis Armour as a Leader and the Apothecary Biologis as Support. Both source identity links are represented. Their integration here does not establish every army attachment combination or broader Deathwatch legality.

## Verification and limits

The focused offline command passed **10/10 processes** (import, Python checks and eight targeted Godot suites) at .tools/verification/20261028T234416623535Z/results.json (SHA-256 9DC322EAA1081639415AF6205FB89F3040A9945FAAB56F8808A2B462EEFBE2A0; network: false, legacy_starter_staged: true, no cleanup diagnostics). The run covers source hashes and identity, profile/composition, equipment options and caps, copy-price tiers, attachment endpoints, Indomitor Doctrines, catalog admission and capability metadata.

This closes only Indomitor's declared source-bounded local scope. Network validation, human playtesting, full Space Marine army legality and complete-match certification remain open. Forge World, Legends, Boarding Actions and other modes are separate inventories.
