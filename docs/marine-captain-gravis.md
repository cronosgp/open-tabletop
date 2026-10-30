# Captain in Gravis Armour — 11th edition scope

Source: Wahapedia 11th edition Captain in Gravis Armour (https://www.wahapedia.ru/wh40k11ed/factions/space-marines/Captain-In-Gravis-Armour), Space Marines App book 000000139, datasheet 000001172. The live page was checked on 27 October 2026. Datasheet facts were reconciled against the verified local Data Export snapshot 20261021T130623Z (specification revision 20260817b, retrieved 2026-10-21T19:46:58Z; source timestamp 2026-10-21 16:06:23 GMT+3). Snapshot manifest SHA-256: 169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf. Relevant CSV hashes are preserved in the audit JSON.

## Profile and equipment

The Captain is one model for 90 points on a 40 mm base. Its characteristics are M5, T6, Sv3+, W6, Ld6+, OC1 and a 4+ invulnerable save. The default weapons are a Master-crafted Heavy Bolt Rifle and Master-crafted Power Weapon.

The preparation selector supports all three source replacements. Each replaces both defaults with a Boltstorm Gauntlet and one relic: Relic Blade, Relic Chainsword or Relic Power Fist. All three relics have Extra Attacks. The dedicated suite exercises the default and every replacement through Equipment and AttackPlan, including the gauntlet's ordinary attacks plus the relic attacks, and checks restoring the default package.

## Rules and Leader links

The four common-book Leader targets are Aggressor Squad, Eradicator Squad with Heavy Bolters, Eradicator Squad with Melta Rifles and Heavy Intercessor Squad. The source page also names Deathwatch Indomitor Kill Team; it is outside the shared-book 85-sheet scope.

Strategic Acumen lets the Captain's unit select one Combat Doctrine in the owner's Command phase. The choice is used once in that Command phase, remains active through the opponent's Command phase, and expires at the start of the owner's next Command phase.

Refuse to Yield reduces Damage from attacks allocated to the Captain by one, to a minimum of one. The check follows actual attack allocation and confirms that an attached Heavy Intercessor bodyguard does not receive the Captain's reduction.

Transhuman Strategist grants one CP once per battle round while the Captain is the Warlord. The current catalog permits up to three copies and rejects a fourth; this local limit does not certify complete army legality.

## Verification

The focused offline run passed 5/5 processes: import, Python checks, this suite, profile parity and the 153-link Leader/Support suite. It used network: false, legacy_starter_staged: false and reported no cleanup diagnostics. Result SHA-256: d3e8554dcc01eefa0836ff41506c2b4aa56b0413e597602451f506f9aa2b4e3d. The per-profile fixed-data comparison reports no differences; it does not certify complete datasheet behavior.

See the machine audit (marine-captain-gravis-audit.json), coverage matrix (space-marines-coverage.md) and verification record (verification/verification-results.md).

This closes only the Captain in Gravis Armour common-book local datasheet scope. Chapter-book and Deathwatch targets, full faction or army legality, network behavior, complete-match certification and human playtesting remain outside this closure. Network validation remains deferred to final integration.
