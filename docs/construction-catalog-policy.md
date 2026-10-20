Current status (19 October 2026): all 85 shared-book Space Marine identities, including Wardens of Ultramar, now pass the local construction gate. Four Necron profiles remain outside this Space Marines construction catalog. This publication boundary does not certify full faction legality or final network readiness.

User decision, 18 October 2026: the army builder offers only sheets whose rules are consolidated in the game. It no longer fetches the broad OpenHammer API catalog or loads its cached catalogs.

`scripts/implemented_army_catalog.gd` derives choices from the explicit runtime admission inventory. Its conservative publication gate requires a current-reference profile, no `tests_written_not_run` or `local_checks_pending` marker, a resolvable runtime definition and declared current model-count prices. Sizes and prices come from that same local profile; this does not independently establish full army legality or final network readiness. Rule authority remains Wahapedia e11 under `rules-source-policy.md`.

Current status (19 October 2026): all 85 shared-book Space Marine identities, including Wardens of Ultramar, pass the local construction gate. Four Necron profiles remain outside this Space Marines construction catalog. This publication boundary does not certify full faction legality or final network readiness.

The workshop's reload action rebuilds local data without HTTP or API-cache reads/writes. Existing API-provider code is retained only for historical tooling/tests and is not referenced by production scripts. Model-file downloading remains a separate explicit visual workflow and cannot add rules support.

Old lists are not deleted, silently repriced or promoted to consolidated status. Entries with an unavailable identity or unsupported composition are labeled as legacy drafts. New Add submissions are re-resolved against the local catalog, and model-count edits on available sheets must use declared supported compositions. Historical training-template creation buttons are removed from the workshop; existing named training exercises and their admission tests remain separate, with their historical limits intact.

Saving a draft confirms local persistence only. Complete faction/army legality, remaining model-count/copy/attachment interactions, broader playtesting and connected-peer validation remain governed by their existing support boundaries.
