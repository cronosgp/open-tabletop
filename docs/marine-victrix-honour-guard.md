# Victrix Honour Guard datasheet audit

## Source and snapshot

This audit covers the shared Space Marines 11th-edition sheet in source book 000000139, datasheet 000004185, using the pinned local Wahapedia export snapshot 20261021T130623Z. The snapshot was retrieved 2026-10-21T19:46:58Z and records specification revision 20260817b; its manifest SHA-256 is 169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf. The current [Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Victrix-Honour-Guard) was checked on 2026-10-27. Local export file hashes and validation reports are recorded in the [machine-readable audit](marine-victrix-honour-guard-audit.json).

## Source profile and composition

The unit contains 3 or 6 models. Its source composition permits 0–1 Chapter Ancient, 0–1 Chapter Champion and 1–6 Victrix Honour Guard. Runtime construction exposes all eight legal role combinations across the two unit sizes. The Ancient carries a Master-crafted Bolt Carbine and Master-crafted Power Weapon; the Champion carries Blades of Honour; each ordinary Guard carries the carbine and power weapon. Role-specific keywords remain attached to the correct model.

The underlying roster costs are 120 points for 3 models and 250 for 6. A Chapter Ancient adds the 15-point Banner of Macragge, making those configurations 135 and 265. Third-plus copies use the source tiers of 150/280 before the Banner surcharge, or 165/295 when an Ancient is included.

All models share M6, T5, Sv2+, W3, Ld6+, OC2 and 40 mm bases. Source weapons, characteristics, model roles and ability behavior are checked against the pinned export.

## Integrated local scope

The dedicated suite checks all eight role configurations, roster admission and prices, default loadouts and model keywords, Cato Sicarius's exact Leader target, and the datasheet abilities. Glory of Ultramar is exercised through the completed enemy attack, optional defender decision, save/restore and resumed Surge movement. Honour Guard of Macragge applies its wound modifier. Banner of Macragge secures an objective when the Ancient is present and grants its once-per-army melee bonus, including when Cato is attached. The Army Workshop test also checks the Bannerless selection and its 120-point preview and saved cost.

## Verification

The focused offline run passed 3/3 processes: Godot import, Python checks and test_victrix_honour_guard. The Army Workshop regression passed in its own clean targeted run.

    python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_victrix_honour_guard --timeout 300
    python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_army_builder --timeout 300

Reports: .tools/verification/20261027T221923236402Z/results.json and .tools/verification/20261027T221801613709Z/results.json. Both runs were offline and did not stage the optional legacy starter pack.

## Open boundaries

This closes only the shared-book Victrix Honour Guard sheet scope. Full Chapter and army legality, network validation, complete matches and human playtesting remain outside this result. Network validation is deferred to final integration.
