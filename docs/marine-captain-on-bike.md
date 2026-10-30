# Captain on Bike — 11th edition scope

Source: [Wahapedia 11th-edition Captain on Bike](https://wahapedia.ru/wh40k11ed/factions/space-marines/Captain-on-Bike), Space Marines App book `000000139`, datasheet `000002702`. The live page was checked on 28 October 2026; the faction page identifies Space Marines App 2.8.1 / October 2026. Datasheet facts were reconciled against the verified local Data Export snapshot `20261021T130623Z` (specification revision `20260817b`, retrieved 2026-10-21T19:46:58Z; export timestamp 2026-10-21 16:06:23 GMT+3). The snapshot manifest SHA-256 is recorded in the machine audit; the relevant CSV hashes are preserved there.

## Profile and equipment

The datasheet contains one model for 110 points, with a 90 × 52 mm oval base. Characteristics are M12, T6, Sv3+, W6, Ld6+, OC2 and a 4+ invulnerable save. Its default equipment is a Heavy Bolt Pistol, Twin Bolt Rifle and Master-crafted Power Weapon. The local preparation flow supports the two independent replacements: Heavy Bolt Pistol to Plasma Pistol, and Master-crafted Power Weapon to Thunder Hammer.

The focused suite checks all four legal packages through the public equipment choices. Every weapon profile, including both Plasma Pistol modes, passes `Equipment` and `AttackPlan`. The local collision model records the oval base dimensions but uses a bounding-circle proxy; it does not certify exact oval placement geometry.

## Rules and Leader links

The source lists Leader, Combat Doctrines, Transhuman Strategist, Strategic Acumen and Into the Fray. The ability catalog now includes Combat Doctrines for this profile. The local tests confirm both-player current-catalog construction, a three-copy Strike Force list and rejection of a fourth Captain, attachment to the shared-book Outrider Squad, Warlord eligibility and once-per-round CP, owner-checked Strategic Acumen timing, and Cleave 1 only after a charge move. Incursion's current two-copy limit is checked separately by the shared roster-admission workflow.

Wahapedia also lists Ravenwing Black Knights as a Leader target. Its separate Dark Angels Chapter profile is now integrated, and the Captain on Bike attachment resolves to it while preserving the Outrider Squad link. This Captain sheet's own tests remain scoped to the shared-book profile; Chapter roster restrictions are not certified here. See the [Ravenwing Black Knights sheet audit](marine-ravenwing-black-knights.md).

## Verification

The focused offline regression passed 5/5 processes at `.tools/verification/20261028T091330361383Z/results.json`: import, Python checks, Ravenwing Black Knights, Captain on Bike and Outrider Squad. It used `network: false`, `legacy_starter_staged: false` and reported no cleanup diagnostics. This also checks that the newly active Chapter Leader link preserves the Captain's Outrider attachment. See the [machine audit](marine-captain-on-bike-audit.json). The per-profile fixed-data comparison reports no differences; it does not certify the other profiles or full datasheet behavior.

This closes only the Captain on Bike shared-book local datasheet scope. The oval-base proxy, complete faction or army legality, network behavior, complete-match certification and human playtesting remain outside this closure. Network validation is deferred to final integration.
