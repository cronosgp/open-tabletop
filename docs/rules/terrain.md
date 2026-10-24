# Ground terrain in the 11e exercise

## Event Companion terrain presets

The selected **Battlefield Dominance / Take and Hold vs Take and Hold** match offers the three matching 11th-edition Event Companion layouts: **A, B and C**. These are terrain-only presets. The selected mission, its objective locations, Hammer and Anvil deployment, and scoring stay unchanged. The prepared match also offers Meatgrinder, Reconnaissance Sweep and Secure Asset, but currently reuses these Take and Hold terrain proxies for those primaries; their own recommended Event Companion layout pairs are not implemented. This is not the older A/B/I/J mission pool.

The preview images are the 11e Wahapedia Event Companion diagrams: [Layout A](https://wahapedia.ru/wh40k11ed/img/maps/layouts/43_Take_and_Hold_vs_Take_and_Hold_Layout_A.png), [Layout B](https://wahapedia.ru/wh40k11ed/img/maps/layouts/44_Take_and_Hold_vs_Take_and_Hold_Layout_B.png), and [Layout C](https://wahapedia.ru/wh40k11ed/img/maps/layouts/45_Take_and_Hold_vs_Take_and_Hold_Layout_C.png), listed in the [11e Warhammer Event Companion](https://wahapedia.ru/wh40k11ed/the-rules/warhammer-event-companion/). To cache them on this computer, explicitly run `python tools/cache_wahapedia_11e_event_layouts.py`. They are written to `.tools/wahapedia/11e/event-layouts/take-and-hold-mirror/`, which is ignored by Git and excluded from distribution. The match never downloads them automatically, and peers do not receive them. If a diagram is unavailable, the selected playable terrain remains and the setup screen shows an English placeholder message.

The downloaded cache was checked on 22 October 2026. SHA-256: Layout A `036e71573a18b0a732ee00ce8292d97f6fe8554ff1d7766d5d9a97c091b206c8`; Layout B `a06809311f35a07b20fb7962eecaa9987d9dc8ca48b2760001bb5a9594d9c5e7`; Layout C `be0bea62715e3d9c7568a7282fe729ea7098ca1bdf5bc83e677a068b24148e32`.

The board uses project-authored, ground-level rectangular terrain proxies adapted to each reference. The images preview the official layout; they do not provide exact board measurements for these proxies or implement upper floors, ruins' footprint rules, vertical movement, or imported terrain meshes. The selected proxy layout ID is stored in the match save and public compatibility manifest.

The combat exercise defaults to `terrain-11e-v1`: a dense central ruin, exposed rubble and a light barricade. The original prototype keeps its demonstration terrain. Map geometry is part of the combat pack identity; peers with different layouts cannot share a match.

Infantry, Beasts, Swarm and Mobile models can cross dense walls horizontally. Other models cannot cross dense sections taller than 2 inches at ground level. Light and exposed features permit traversal. Models cannot finish embedded in a wall or barricade. The rendered cylinders are the gameplay visibility volumes.

Cover is evaluated separately for each attacking model against every surviving model in the defending squad, before attacks resolve. A defender qualifies by being Infantry/Beasts/Swarm within a terrain area, or by being partly hidden by terrain. Cover worsens BS by 1, capped at 6+, rather than improving armour saves. Heavy remains a separate hit modifier. Identical attacks split into pools when cover or Rapid Fire eligibility differs. Ignores Cover suppresses the BS penalty without bypassing visibility or detection.

Infantry, Beasts and Swarm models within a terrain area containing a Light or Dense feature can be Hidden if they have not fired this turn or the previous turn. A unit counts as Hidden when at least one of its models is Hidden. Detection uses base-edge distance, normally 15 inches. Hidden models partly concealed by dense physical features benefit from Gone to Ground, reducing detection to 12 inches. Shooting records the firing turn even when every attack misses. Light and dense areas can block sight across the area unless either model is within that area; physical walls can still block sight within an occupied area.

This follows the current [Core Rules, 13.09 Hidden](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) and the [Space Marines page, Phobos Shock Force](https://wahapedia.ru/wh40k11ed/factions/space-marines/). The geometry implementation remains a local proxy.

## Geometry limits

This is a ground-level implementation. Visibility searches nine witness rays between cylindrical volumes and enforces a 1 mm line width. Full visibility is conservatively checked from the observing cylinder's centre against the target's projected volume. These proxies can reject some legal sightlines; they do not reproduce every facing part of an imported miniature. Upper floors, vertical paths, plunging fire and arbitrary imported terrain remain unimplemented. The bounded contact solver also retains its documented unresolved approach exceptions.

## Verification

`tests/test_terrain.gd` checks traversal, illegal endpoints, cover pools and BS limits, Hidden timing, Light/Dense Hidden eligibility, detection boundaries, Obscuring, Gone to Ground and contact certificates using traversable ruins. `tests/test_vanguard_ambushers.gd` checks the unit-level one-hidden-model threshold, current-turn Shooting re-roll, turn expiry, Light-terrain eligibility and recent-firing exclusion. `tests/test_terrain_network.gd` checks guest movement, shooting, replicated cover/history, guides and stale requests on the new map. Older geometry fixtures explicitly select `legacy-solid-v1` to retain their original obstacle assertions.

Windows validation passed for eleven local rules/UI suites and eight two-process host/client suites. Loopback does not verify separate-machine LAN or Linux.
