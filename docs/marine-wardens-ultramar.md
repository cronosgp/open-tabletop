# Wardens of Ultramar

Implemented from the pinned local [Wahapedia e11 Space Marines export](https://wahapedia.ru/wh40k11ed/factions/space-marines/Wardens-of-Ultramar-1), shared book `000000139`, datasheet `000004188`, export timestamp `2026-10-16T21:03:46+03:00`. The six-model composition costs 115 points and uses 40 mm bases. Construction admits one copy, matching its EPIC HERO status and local admission scope.

The profile preserves each model's own Toughness, Save, Wounds, Objective Control and invulnerable save, as well as its fixed weapons. Ancient Gadriel carries both Bolt Rifle profiles; Gaius Silva alone has a 5+ invulnerable save. The local composition/equipment rows spell the Librarian's name **Dainal Kornelius**, while the model-characteristics table spells it **Dainal Komelius**; the implementation preserves the discrepancy in its source comment.

Implemented datasheet rules are **Combat Doctrines**, **Raise the Banner**, **Support**, and **Strategium Command**. The support targets are Intercessor Squad, Bladeguard Veteran Squad, Sternguard Veteran Squad, Assault Intercessor Squad and Vanguard Veteran Squad. Strategium Command resolves after both armies deploy and before Scouts; it can select up to three deployed friendly Adeptus Astartes units, repositioning them under normal set-up restrictions or placing them in Strategic Reserves without the normal points cap.

Focused offline validation passed in `.tools/verification/20261019T211419295401Z/results.json` (10/10 processes), `.tools/verification/20261019T212547325101Z/results.json` (8/8 processes) and `.tools/verification/20261019T212717951667Z/results.json` (7/7 processes). Checks cover source characteristics and weapon profiles, mixed-model defense/allocation, materialization, support eligibility, one-copy construction admission, the public Strategium action flow and reserve exception, pre-battle Scout sequencing, roster validation and adjacent leader/ability regressions.

Network validation is deferred to final integration, as requested. This profile's local checks do not certify complete Space Marine faction coverage or full army legality.
