# Persistent match history

The HUD's **Log** action opens an overlay with events, phases, position and wound changes, model assignments, attack pools and D6 order. **Previous**, **Next** and **Latest** navigate pages of up to 20 records. Selecting a record shows its timestamp, revision, active player, event, stage results and details already present in the state patch. Reading history never runs commands, changes match state or consumes the random-number generator. Closing the panel returns to the same match.

The history covers the main match scene, including the allocation exercise. The separate attack lab does not use it. The compact combat log remains available during play; the independent journal retains entries that fall out of its 30-message window. D6 order identifies the phase and active player, who may differ from the player making a defensive decision. When a consolidated attack result exists, the history also presents its hit, wound, save, damage and prevention groups.

## Recording and resume

The local game and LAN host write to `user://matches/journals/<id>.journal`. A save records the journal identity, confirmed record count, byte offset and hash. Each binary record stores its sequence, UTC time, previous hash, public-state changes and resulting-state hash. The format does not deserialize objects.

The journal is written before the save snapshot is replaced. On resume, the game verifies the confirmed prefix and reconstructs it to compare with the snapshot. It does not call rules or roll dice during this check; the random-number-generator state comes from the save. Repeated snapshots and reconnects without a state change do not create duplicate records.

When the active file approaches 48 MiB, the game creates a new hash chain with a full-state checkpoint and keeps up to 1,000 recent records, reducing that count as needed to keep the new file at or below 32 MiB. The history screen identifies the checkpoint and the number of earlier records it summarizes. Records before that checkpoint are not shown in the compacted journal. Another save slot that still references the older journal keeps its independent history. After a new snapshot commits, retired journal IDs are removed from managed slot directories only when no primary or recovery-backup snapshot references them; cleanup waits if any occupied snapshot cannot be read.

Compaction writes to a new journal identity. If a crash or failed append leaves records beyond the current confirmed prefix, resume or the next in-session append validates and copies only that prefix to a temporary file, then renames it before continuing under the new identity. The original file and uncommitted tail remain untouched. Later records are not applied to the resumed match. Corruption or a missing record inside the confirmed prefix blocks loading without replacing the current match.

When transferring a save or its `.bak` recovery copy, include the referenced journal file from the matching slot's `journals` directory. Older saves without a journal reference remain loadable; their history starts from the state available at resume without inventing earlier events. Guest-seat credentials remain separate.

## LAN and limits

The authenticated guest receives public history pages from the host. They do not include credentials, the random-number-generator state or full internal patches. The guest does not write the host's journal. Reopen the tab or use **Latest** to refresh the view.

Journal files are limited to 64 MiB and individual records to 2 MiB. If compaction or a write fails, the error appears in the interface and the last confirmed save remains intact. A match with no active save slot can continue recording a local journal, but that journal alone cannot resume the match; save a snapshot to a slot first. Retired IDs are checked in the five managed slot directories and the unslotted journal directory after a successful save. There is no board replay or undo.

The existing verification evidence covers Windows and loopback only. Cross-machine and cross-platform checks remain part of distribution validation; focused compaction and slot-cleanup checks are pending.
