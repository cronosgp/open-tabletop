# Independent data packs

The game owns its format and rules implementation. OpenHammer is used for fast bulk discovery and provisional imports; it does not certify current rules. Wahapedia e11 and applicable current Games Workshop publications are checked for the slice selected for implementation. No upstream SDK, Python library, MCP client, or web service is required to run a match. Python is needed only for the optional import tool.

## Files and identity

A pack directory contains `manifest.json` and `units.json`. Schema version 1 uses:

- Manifest: `id`, `edition`, `implementation`, `units_sha256`, `source`, and `supported_mechanics`.
- Source: provider, URL, upstream revision (nullable when unknown), retrieval date, source-record digest, and license status. The project-authored demo has local source metadata instead.
- Unit: namespaced `id`, display `name`, normalized `stats`, base geometry, and explicit `unsupported_rules` and `playable` fields. Imported units also preserve provider ID, points, weapons, composition, keywords, and warnings.

`units_sha256` hashes the exact UTF-8 bytes of `units.json`, including whitespace. Update the digest when editing a file intentionally. A hash detects changed content; it is not a signature, a trust guarantee, or permission to distribute content. The current network checks compare the implementation ID and unit-content hash; a future configurable-match manifest must also include scenario and host settings.

Stats use numeric movement in inches and numeric save/leadership targets without the plus sign. Values the importer cannot parse become null with a warning. The OpenHammer adapter retains provider weapon fields and dice expressions. A separate two-faction adapter preserves structured weapon profiles and links; the [11e attack lab](11e-starter.md) translates a supported subset into the independent combat kernel. Missing geometry remains null. OpenHammer ability descriptions are not copied or interpreted; ability and special-rule names are recorded as unsupported. The two-faction adapter preserves community-authored structured ability definitions for future implementation without executing them.

Only the project-authored `demo` pack and `prototype-movement-v1` implementation are currently enabled for play. Imported 10e/11e packs are reference-only even if their data appears complete. OpenHammer candidate IDs, characteristics, loadouts, and ability names can seed the catalog in bulk, but implementation status requires a selected-slice source check and a deliberate project-authored rules implementation. Our runtime's allowlist controls this, not a provider's flag.

## Optional import

Python 3.10+; standard library only. From the repository root:

```text
python tools/import_openhammer.py --edition 11e --name Intercessor --limit 1 --output data/imported/my-11e-snapshot
```

Import a complete faction as a paginated, reference-only snapshot:

```text
python tools/import_openhammer.py --edition 11e --faction "Space Marines" --all-faction --limit 50 --output data/imported/openhammer-space-marines-11e-20261017
```

The manifest records every page URL and retrieval time. Supply `--source-revision` only when the provider revision is verified; otherwise the content digest identifies the exact captured response.

When the live API is unavailable, build an **identity-only** Space Marines index from the local army-builder cache:

```text
python tools/index_openhammer_candidates.py
```

This writes `.tools/openhammer-api/space-marines-candidate-index.json`. It preserves candidate names, provider IDs, keywords, and the cached composition/roster hints; it does not contain datasheet characteristics, weapon profiles, or ability definitions and cannot be loaded as a data pack. Name matches to the rules ledger are discovery hints only. Refresh the army-builder cache before treating the index as a current provider snapshot.

Import a previously retrieved JSON array with no network access:

```text
python tools/import_openhammer.py --edition 11e --input my-units.json --output data/imported/offline-snapshot
```

Supply `--source-revision` only when the upstream release is verified. Every update should use a new output directory; the importer refuses to overwrite an existing pack. Imported data stays under the ignored `data/imported/` directory by convention and is not automatically shipped or selected by the game. Keep any original source files separately if an audit requires them. Live requests have a timeout and response-size cap.

## Verification

```text
python -m unittest discover -s tests -p "test_*.py"
godot --headless --path . --script tests/test_data_pack.gd
godot --headless --path . --script tests/test_data_pack.gd -- res://data/imported/my-11e-snapshot
```

The optional final argument checks that a real imported snapshot loads offline but is rejected for enforced play. Existing movement and network tests also exercise the demo pack. Linux execution remains unverified.

## Next extension

Use bulk snapshots to expand the candidate catalog quickly, then select a coherent vertical slice. Check that slice against its current Wahapedia e11 reference before implementing or marking it supported. Preserve provider IDs rather than treating names as unique identities. Verify required geometry, and enable only units whose complete behavior is supported. External updates must never change an active match automatically.
