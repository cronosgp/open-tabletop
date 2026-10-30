# Tarantula Sentry Battery datasheet audit

## Source identity and provenance

The current [Wahapedia 11th edition datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Tarantula-Sentry-Battery) identifies book `000000356`, datasheet `000000098`, and labels it Space Marines (Warhammer Legends). This profile uses the hash-verified local Data Export `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, retrieved `2026-10-30T01:33:48.347556Z` and updated `2026-10-28T23:48:19+03:00`. The parent manifest SHA-256 is `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`; the Legends slice SHA-256 is `d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c`.

Relevant export filenames and snapshot file SHA-256 values:

| Export file | SHA-256 |
|---|---|
| `Datasheets.csv` | `cf5b733a7802192e263a1a3a25afbf86b570319b75a88b2122052d36f1a1593c` |
| `Datasheets_abilities.csv` | `2acdb9d5ae8ba2dbc2f82783f6863c8c14c89c63f61a6b0fde6036cfad68a7a9` |
| `Datasheets_keywords.csv` | `7f9782c1fc29cada10481788fb8abb8aa8d3d5cfeea60e397a732c5a557326dc` |
| `Datasheets_models.csv` | `70ef48a6ccfc72c9aef9e8bd1cdeae9edd1baf1ae9ddc57b9ab8f6bfb8130412` |
| `Datasheets_options.csv` | `6d0606fffae83d2928333a04664dee6c3b59a7d14b9f46480e8efae9ed7d9d08` |
| `Datasheets_wargear.csv` | `8da7df62e8e3b1c7eabd64b8073872ab12b7d662282b8827c00f9fc9a7c0897f` |
| `Datasheets_unit_composition.csv` | `94403ec4a93eda94bea0cf18d88373453217a88a7c07ca82d1c5ff1be9c3785a` |
| `Datasheets_models_cost.csv` | `133787b7d71432e4cfbf585f366d703825451eb60e174a913616516007562eb1` |

## Represented datasheet

- A unit contains 1, 2 or 3 Tarantula Sentry Battery models, at 30 points per model: 30, 60 or 90 points.
- Each model has M−, T6, Sv3+, W4, Ld6+ and OC1; it has Vehicle, Artillery, Frame, Imperium and Adeptus Astartes keywords.
- The fixed Armoured Hull is A1, WS6+, S3, AP0, D1.
- Each Twin Heavy Bolter is 36", A3, BS3+, S5, AP−1, D2 with Sustained Hits 1 and Rapid Fire 2.
- Any number of models can replace their Twin Heavy Bolter with a Twin Lascannon: 48", A1, BS3+, S12, AP−3, D3+3, Twin-linked. Each model's equipment is selected independently during army preparation; the replacement costs no extra points.
- Combat Doctrines is registered. Sentinel Protocols lets this unit's Fire Overwatch snap shooting hit on unmodified 4+ until resolved, once per phase per unit. It does not override the core limit of one use of Fire Overwatch per player per phase; another unit using it first blocks this unit. This profile pays the normal CP cost and does not receive the separate Tarantula Air Defence Battery's free-use Sentry Programming or Deadly Demise 1. Firestrike Servo-turrets have additional wording explicitly bypassing the shared use limit; that wording is absent here.

## Table and event use

Games Workshop's [current Space Marines Legends guidance](https://www.warhammer-community.com/en-gb/articles/bbnskauh/big-space-marines-news/) allows Legends in home, store, club and campaign games; competitive events require the organiser's permission. The builder labels this unit Warhammer Legends and displays that event condition. Its source gives the footprint as `Use model` with no diameter; the simulation uses a 60 mm circular proxy for each model. Exact physical measurement clearance is not certified.

Local construction applies the project’s existing unit-copy ceilings (up to two copies in Incursion and three in Strike Force) and validates every source-priced unit size. That is a checked local roster scope, not certification of every army combination or all rules interactions. Network validation, exact physical footprint, a full match and human playtesting remain separate checks.

## Verification

The focused regression covers export provenance, model counts and points, all characteristics and weapon profiles, per-model replacement, roster reprice/admission, repetition limits, Legends labelling, normal-cost Sentinel Protocols, the global stratagem-use limit, unmodified 4+ snap shooting and the exclusion of the other Tarantula's rules. The test is `tests/test_tarantula_sentry_battery.gd`; batch evidence is recorded in [verification results](verification/verification-results.md).
