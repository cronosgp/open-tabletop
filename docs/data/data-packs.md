# Legacy independent data-pack format

> **Source boundary:** This format and the existing OpenHammer/40kdc adapters predate the current [Wahapedia local-export policy](source-assessment.md). They are not authoritative inputs for current e11 datasheet facts. Do not use them as a fallback when a verified local Wahapedia export is missing. Migration of the reader and pack pipeline is separate work.

The game owns its runtime format and rules implementation. No upstream SDK, Python library, MCP client, or web service is required to run the clean-checkout movement demo. The local data policy and migration boundary are defined in [source assessment](source-assessment.md).

## Files and identity

A pack directory contains `manifest.json` and `units.json`. Schema version 1 uses:

- Manifest: `id`, `edition`, `implementation`, `units_sha256`, `source`, and `supported_mechanics`.
- Source: provider, URL, upstream revision (nullable when unknown), retrieval date, source-record digest, and license status. The project-authored demo has local source metadata instead.
- Unit: namespaced `id`, display `name`, normalized `stats`, base geometry, and explicit `unsupported_rules` and `playable` fields. Imported units also preserve provider ID, points, weapons, composition, keywords, and warnings.

`units_sha256` hashes the exact UTF-8 bytes of `units.json`, including whitespace. Update the digest when editing a file intentionally. A hash detects changed content; it is not a signature, a trust guarantee, or permission to distribute content. The current network checks compare the implementation ID and unit-content hash; a future configurable-match manifest must also include scenario and host settings.

Stats use numeric movement in inches and numeric save/leadership targets without the plus sign. Values the legacy importers cannot parse become null with a warning. The OpenHammer adapter retains provider weapon fields and dice expressions. A separate 40kdc-data adapter preserves structured weapon profiles and links; the [historical 11e attack lab](11e-starter.md) translates a subset into the independent combat kernel. Missing geometry remains null. These provider-specific fields and community-authored ability definitions are preserved as historical/import-format behavior, not approved current datasheet facts or executable rules.

Only the project-authored `demo` pack and `prototype-movement-v1` implementation are currently enabled for play. Imported 10e/11e packs are reference-only even if their data appears complete. Our runtime's allowlist controls this, not a provider's flag.

## Legacy import tools

The repository still contains these import commands for compatibility and isolated historical exercises. Python 3.10+; standard library only. From the repository root:

```text
python tools/import_openhammer.py --edition 11e --name Intercessor --limit 1 --output data/imported/my-11e-snapshot
```

Import a previously retrieved JSON array with no network access:

```text
python tools/import_openhammer.py --edition 11e --input my-units.json --output data/imported/offline-snapshot
```

These are legacy provider adapters, not the current e11 data-preparation workflow. Do not use their output to establish current datasheet support. Every historical reproduction should use a new output directory; imported data stays under ignored `data/imported/` and is not automatically shipped or selected by the game. Live requests have a timeout and response-size cap.

## Verification

```text
python -m unittest discover -s tests -p "test_*.py"
godot --headless --path . --script tests/test_data_pack.gd
godot --headless --path . --script tests/test_data_pack.gd -- res://data/imported/my-11e-snapshot
```

The optional final argument checks that a real imported snapshot loads offline but is rejected for enforced play. Existing movement and network tests also exercise the demo pack. Linux execution remains unverified.

## Migration direction

Do not add another external provider as an authoritative source. The next data-pipeline change must consume only a verified local Wahapedia export, preserve snapshot provenance and hashes, and fail clearly for unsupported/missing fields. Keep derived data local and offline during match resolution. Enable a profile only after its data and complete documented behavior are supported; an imported row is not proof of gameplay or general list legality.
