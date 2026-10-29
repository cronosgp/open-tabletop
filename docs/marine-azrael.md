# Azrael (Dark Angels App)

**Status:** source-bounded local scope passed on 28 October 2026. This closes Azrael's fixed datasheet, Leader links and declared local ability scope. It does not certify full Dark Angels roster legality, Space Marines army legality or network behavior.

## Source identity

- [Wahapedia 11th-edition Azrael](https://wahapedia.ru/wh40k11ed/factions/space-marines/Azrael), Dark Angels App datasheet `000000218`, book `000000023`.
- The live Space Marines page was checked on 28 October 2026 and lists Dark Angels App revision 2.8.1 (October 2026). Fixed data comes from verified local Data Export snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, export revision `20260817b`; source row stamp `2026-10-21 16:06:23 GMT+3`.
- The machine-readable audit records the snapshot identity and SHA-256 hashes. Raw export data remains outside Git.

## Profile and loadout

- One model, 150 points, one copy. M6, T5, Sv2+, W6, Ld6+, OC1, 4+ invulnerable save, 50 mm base.
- Fixed equipment: Lion's Wrath (24", A2, BS2+, S8, AP-3, D2; Rapid Fire 1, Devastating Wounds, Anti-Infantry 4+) and The Sword of Secrets (A6, WS2+, S6, AP-4, D2; Devastating Wounds). The Lion Helm supplies the 4+ invulnerable save.
- All source keywords are represented, including DEATHWING and the Dark Angels faction keyword.
- Leader can attach to Assault Intercessor Squad, Bladeguard Veteran Squad, Company Heroes, Hellblaster Squad, Infernus Squad, Intercessor Squad, Sternguard Veteran Squad or Inner Circle Companions. Each target is in the current local catalog.

## Rules in the checked scope

- Leader, Combat Doctrines and Transhuman Strategist are registered to their shared current paths.
- **Masterful Tactician:** in Azrael's Movement phase, select one visible friendly Adeptus Astartes unit within 9 inches and one Combat Doctrine. That doctrine applies only to that unit through the start of its owner's next Command phase; the army-wide choice and use limit are unchanged.
- **Supreme Grand Master:** Azrael's unit gains Sustained Hits 1 on ranged and melee attacks, including attacks made by attached bodyguards. A weapon with a higher Sustained Hits value keeps it.
- **Watcher in the Dark:** once per battle per unit, the defender can summon the Watcher at a supported mortal-wound decision point. The unit then has Feel No Pain 4+ against mortal wounds. The current local attack-allocation, transport, hazard, Deadly Demise and listed ability/stratagem mortal-wound windows share this response path.
- The public Leader action validates Azrael's eight source-listed bodyguard endpoints. The source Deathwing keyword is retained through Dark Angels Chapter-context normalization.

## Local verification and limits

The focused offline check passed 3/3 processes at `.tools/verification/20261028T103650933865Z/results.json`. It checks source identity, costs and copy limit, fixed characteristics and weapons, all eight Leader endpoints, attachment, both attack profiles, doctrine eligibility/timing/expiry, Sustained Hits 1, Watcher use and mortal-only Feel No Pain. A second targeted run passed 4/4 processes for capability metadata and the shared Leader/Support relation suite at `.tools/verification/20261028T103807866500Z/results.json`.

These checks do not establish full army legality, all Chapter detachment interactions, network validation, complete-match certification or human playtesting. Network validation remains deferred to final integration.
