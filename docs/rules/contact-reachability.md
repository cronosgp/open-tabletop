# Certifying contact approach exceptions

The contact validator now accepts some previously rejected “if possible” exceptions. It does not treat failure to find a path as evidence that no path exists. A threshold is waived only when a relaxed movement/placement problem is proved impossible.

The baseline remains [11e Core Rules](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/), §§11.04, 12.03 and 12.08. Charges check the 1-inch approach and engagement approach independently. Proving that 1 inch is impossible never waives a reachable engagement requirement. Other final conditions, including coherency, declared charge targets, closer movement and retained engagements, still apply.

## Terrain certificates

The host computes a visibility graph around rectangular obstacles in a relaxed flat configuration space. Unions of inner expanded rectangles approximate circular-base clearance from below, including rounded corners. The goal square contains the target's entire approach disk. Enemy bases and battlefield bounds are omitted from this calculation, making it easier to reach the goal than in actual play.

If even this shorter relaxed route exceeds the move's original full allowance, with a numerical margin, the host has a valid obstruction certificate. It never uses the remaining allowance after a player's detour as evidence of impossibility. All live models in every eligible target unit are considered.

For example, on the current exercise board, a model at `(-5, 0)` charging a target at `(5, 0)` with a 10-inch roll can route above the central block and finish around 1.9 inches away. The host now certifies that approaching within 1 inch is impossible, while still requiring engagement.

## Coherency certificates

Each friendly model has a relaxed reachable domain based on its origin and full movement allowance. Base-contact locks are preserved. Non-charge moves also retain each model's required enemy engagements. The focused model's domain is constrained to the approach being checked.

The analysis checks circular constraints, the 9-inch diameter bound, and whether a connected 2-inch-neighbour graph can exist. It can subdivide remaining domains to rule out arrangements. Teammates are allowed to rearrange throughout their full reachable domains; they are not frozen at either their origins or submitted destinations.

An example now supported is a pile-in with a locked anchor and another model that must retain a different enemy. If the middle model cannot reach engagement without disconnecting that formation, a smaller closer move can be accepted.

## Limits and records

The search is deterministic and bounded to 1,024 domain boxes, with padded geometry and a minimum box width. Exhausting the bound or reaching an unresolved boundary means **unknown**, so the requirement remains enforced. These are certificates of impossibility, not a complete pathfinding or squad-layout solver. Enemy-base blockades, some obstacle layouts, and complex combined arrangements may still be rejected despite being legal. The solver uses current terrain obstacles for each model: Infantry-traversable ruins cannot certify impossible routes. Upper floors and full multi-squad fight queues remain separate work. Original obstacle fixtures explicitly select the legacy map.

Accepted certificates are stored in `last_contact_proofs` and replicated in authoritative snapshots. The event log identifies the model, threshold, and reason. The match implementation identifier changed to `11e-3d-integration-v7`; older clients cannot join this implementation.

Verification:

```text
godot --headless --path . --script tests/test_contact_reachability.gd
godot --headless --path . --script tests/test_contact_exceptions_network.gd -- --host-test
godot --headless --path . --script tests/test_contact_exceptions_network.gd -- --client-test
```

Run the network commands in separate terminals. Tests include terrain and coherency exceptions, independent engagement duties, reachable alternative target models, known legal complete arrangements, bounded-search exhaustion, retained dice/state, and replicated certificates.
