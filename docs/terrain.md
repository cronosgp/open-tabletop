# Ground terrain in the 11e exercise

The combat exercise defaults to `terrain-11e-v1`: a dense central ruin, exposed rubble and a light barricade. The original prototype keeps its demonstration terrain. Map geometry is part of the combat pack identity; peers with different layouts cannot share a match.

Infantry, Beasts, Swarm and Mobile models can cross dense walls horizontally. Other models cannot cross dense sections taller than 2 inches at ground level. Light and exposed features permit traversal. Models cannot finish embedded in a wall or barricade. The rendered cylinders are the gameplay visibility volumes.

Cover is evaluated separately for each attacking model against every surviving model in the defending squad, before attacks resolve. A defender qualifies by being Infantry/Beasts/Swarm within a terrain area, or by being partly hidden by terrain. Cover worsens BS by 1, capped at 6+, rather than improving armour saves. Heavy remains a separate hit modifier. Identical attacks split into pools when cover or Rapid Fire eligibility differs. Ignores Cover suppresses the BS penalty without bypassing visibility or detection.

Infantry, Beasts and Swarm within light/dense terrain containing features can be Hidden if they have not fired this turn or the previous turn. Detection uses base-edge distance, normally 15 inches. Hidden models partly concealed by dense physical features benefit from Gone to Ground, reducing detection to 12 inches. Shooting records the firing turn even when every attack misses. Obscuring light/dense areas block sight across the area unless either model is within that area; physical walls can still block sight within an occupied area.

## Geometry limits

This is a ground-level implementation. Visibility searches nine witness rays between cylindrical volumes and enforces a 1 mm line width. Full visibility is conservatively checked from the observing cylinder's centre against the target's projected volume. These proxies can reject some legal sightlines; they do not reproduce every facing part of an imported miniature. Upper floors, vertical paths, plunging fire and arbitrary imported terrain remain unimplemented. The bounded contact solver also retains its documented unresolved approach exceptions.

## Verification

`tests/test_terrain.gd` checks traversal, illegal endpoints, cover pools and BS limits, Hidden timing, detection boundaries, Obscuring, Gone to Ground and contact certificates using traversable ruins. `tests/test_terrain_network.gd` checks guest movement, shooting, replicated cover/history, guides and stale requests on the new map. Older geometry fixtures explicitly select `legacy-solid-v1` to retain their original obstacle assertions.

Windows validation passed for eleven local rules/UI suites and eight two-process host/client suites. Loopback does not verify separate-machine LAN or Linux.
