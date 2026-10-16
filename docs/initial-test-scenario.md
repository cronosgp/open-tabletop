# Initial testing scenario

User-defined baseline: **Incursion, 1,000-point limit per army, 43 × 43 inches**. Keep the requested 43-inch dimensions exactly. This is a testing assumption, not a claim that this board size, terrain arrangement or mission is an official tournament specification.

Combat exercises launched from the main scene use preset `incursion-test-1000-43x43-v1`. The board is centered at the origin, with boundaries at ±21.5 inches on both axes. One world unit remains one inch. Movement/contact checks keep the entire base within the board. Visual board/grid dimensions follow the same state field. The legacy movement-only demo and standalone rules fixtures retain their previous default dimensions unless explicitly given the preset.

State metadata: `board_size = Vector2(43, 43)`, `battle_size = "Incursion"`, `points_limit = 1000`, `roster_points_validated = false`. The preset identity participates in the compatibility hash; offline, host and rejoin factories use the same preset. Changing its dimensions/assumptions requires a new preset identity.

The current Marine/Necron practice rosters are not assembled or validated as legal 1,000-point armies. The UI states this explicitly. Existing training terrain and objective exercises remain in use; the larger board does not automatically add deployment zones, terrain, official objectives, reserves or official missions. Next scenario work should define representative opposing lists, terrain density/placement, deployment zones and the mission, then implement their required validation. Visual imports remain independent of army points and rules data.

Update 16 October: the separate [prepared custom match](prepared-match.md) now supplies versioned setup and alternating deployment in custom 11-inch side zones before the existing five-round training mission. Ordinary exercises retain immediate-start behavior. These zones and rosters are not official mission/army certification.

Validation: six local suites passed (Incursion battlefield, legacy rules, individual movement, contact actions, allocation practice and gameplay layout). Boundary tests cover whole-base placement at/beyond X/Y edges, compatibility hashing, offline/host factory consistency, rendered dimensions and legacy fallback. One host/client loopback scenario passed with disconnect/rejoin during allocation and explicit synchronized size/point checks. The enlarged board and scenario label were visually inspected at 1280x800 on Windows. Separate-machine LAN/Linux remain unverified.
