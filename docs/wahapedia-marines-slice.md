# Shared Space Marines source slice

18 October 2026. The [Wahapedia importer](wahapedia-import.md) now has a source-bounded extraction stage and a joined local catalog. This advances structured import; it does not admit additional playable units or certify complete rule effects.

**Current follow-up boundary (20 October 2026):** the 85-row source inventory and runtime profile coverage are summarized in the [coverage matrix](space-marines-coverage.md). The six fixed-profile comparison below is historical evidence for those six only; later runtime admission does not mean the remaining 79 sheets were source-reconciled or fully implemented. Source snapshot files are not present in this worktree, so no new source comparison is claimed.

## Actual result

Source `000000139` is the e11 App Space Marines shared book. Extraction from the pinned 16 October export produces **85 subject datasheets**, **41 external identity-only Leader endpoints**, and **zero structural validation errors** in the selected tables. The parent export's **68 errors remain recorded** in the slice manifest. No global source row was deleted, guessed or repaired.

The source-less Marine entry is `Example Wargear`, ID `000003708`; it is excluded by the source-ID boundary rather than by a guessed playable-unit whitelist. The other source-less sheet is the Imperial Knights `Knight Destrier`. Dangling global references do not enter this closed selection. A broken reference that actually belongs to a selected subject is retained and fails slice validation.

The generated `catalog.json` joins models, weapons, composition, costs, options, keywords, ability bindings and Leader links for each subject. Shared ability/stratagem/enhancement/detachment definitions are stored once and linked by IDs; reused ability IDs retain faction scope. The 41 external Leader endpoints have identity records only and do not become subjects. Model characteristics and source HTML remain source data, without invented defaults or executable effects. Linked rules retain their original chapter/game-mode contexts, whose applicability is not certified by relational closure.

Local result: `.tools/wahapedia-marines-shared-catalog-v2/`. Committed [audit metadata](wahapedia-marines-slice-audit.json) records parent/slice/catalog hashes, subject/dependency counts and the six-profile result; raw rules and the joined catalog remain ignored.

## Terminator keyword context

The [e11 faction page, The Deathwing](https://wahapedia.ru/wh40k11ed/factions/space-marines/#The-Deathwing), places that keyword grant under the Dark Angels chapter rule. The [Terminator page](https://wahapedia.ru/wh40k11ed/factions/space-marines/Terminator-Squad) wraps its Deathwing keyword in a `clFl CHDA` visibility span; the faction rule is enclosed by chapter filter `CH:21`. The CSV keyword row does not export that condition.

The [checked audit context](wahapedia-keyword-context.json) records these page locators and HTML hashes, scoped to the observed export revision and exact Terminator/source-book IDs. The comparator now separates the conditional DEATHWING row from ordinary shared keywords. `TERMINATOR SQUAD` remains explicitly identified as a project identity tag, rather than an extra publisher keyword.

All six fixed profiles now have **zero numeric differences** and **consistent shared-context keyword sets** in the audit. The source comparison does not itself activate a rule. Prepared-match creation now has a separate Chapter-context step that applies conditional Dark Angels `DEATHWING`/`RAVENWING` keywords to eligible current-reference profiles; it leaves the shared base profiles and this audit input unchanged. The static `--chapter dark-angels` comparison therefore still identifies source-listed `DEATHWING` omissions in base profile records such as Ancient in Terminator Armour and Bladeguard Ancient. Read those findings as profile-record gaps, not as a report of a prepared match's contextual keywords. Focused runtime checks remain pending; a different export revision requires the contextual evidence to be rechecked instead of silently suppressing the difference.

## Reproduce

```text
python tools/slice_wahapedia.py --snapshot .tools/wahapedia-e11-20261018-reviewed --source-id 000000139 --output .tools/marines-shared-NEW
python tools/compare_wahapedia_marines.py --snapshot .tools/marines-shared-NEW --runtime-profiles .tools/wahapedia-runtime-marines.json --output .tools/marines-audit-NEW.json
```

Use a fresh output directory. Optional repeated `--datasheet-id` arguments narrow extraction within the selected source book. The tool rejects a requested identity from another book, a non-e11 source, modified parent files, reduced-slice inputs and overwrites. Headers-only tables are valid only for an explicitly scoped slice; full captures still reject empty tables. Slice/raw/catalog hashes are verified before further analysis.

## Validation and remaining work

The historical run recorded **25 Python tests passed**, including global-error isolation, selected broken-reference retention, external Leader identity boundaries, wrong-edition/cross-book rejection, repeatability, raw/catalog tampering and chapter/revision keyword checks. This increment changed offline tooling and audit metadata only; no runtime rules, UI or protocol changed. The source snapshot and those verification logs are not present in the current worktree.

Follow-up delivered: [weapon traits, default equipment, fixed model counts and default-unit costs](wahapedia-fixed-data-review.md) agree for all six fixed profiles. Next: executable effect/timing/interaction validation and focused checks for the separate conditional Chapter-context path. Optional equipment, broad Chapter-specific rules, the other 79 profiles, complete roster legality and full-match certification remain unsupported beyond their previously declared experimental scope.
