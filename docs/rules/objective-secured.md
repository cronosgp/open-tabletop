# Intercessor Objective Secured

Implemented on 16 October 2026 as an explicit prepared-match option. This adds one verified unit ability; it does not enable complete datasheets, faction rules or official army construction.

## Source and scope

The [Games Workshop Space Marines datasheet cards](https://assets.warhammer-community.com/eng_04-06_warhammer40k_new40k_armageddon_spacemarines_datasheet_cards-hcuj9cke0r-h2rfuky1yw.pdf), page 5 of the PDF (Intercessor Squad), were checked on 16 October 2026. The ability secures an objective controlled by that unit at the end of its owner's Command phase. Its retained-control behavior uses the existing core [objective control implementation](objectives.md): equal opposing OC does not remove secured status; greater opposing OC removes it at a control boundary.

Only the ability effect is adopted here. Existing exercise model counts, profiles, equipment and local point costs remain the pinned starter references; this is not certification that the whole snapshot matches those current datasheets. Imported enrichment/ability DSL remains data and is never executed.

## Use

In **Match setup → Advanced match options**, enable **Next prepared match: Intercessor Objective Secured** before starting a prepared match or a saved/default-list match. The option is off initially. In LAN both players must select the same setting. Changing the checkbox during a running match configures the next setup; it does not change the frozen running rules.

No separate action or CP payment is required. End Command normally after resolving any Battle-shock decisions. The engine first determines control, then secures qualifying objectives. A living, in-range Intercessor with positive OC is required; a battle-shocked unit with zero OC cannot trigger it. Only pure squads using the canonical Intercessor definition qualify. Terminators, Necron units, renamed unrelated squads and future mixed attachments do not inherit it automatically.

The terrain objectives in the custom mission and the existing marker-range helper both use this effect. The objective can remain controlled after the Intercessors leave, but superior enemy OC at the next phase boundary removes that secured status. An objective retained without any Intercessor in range is not newly secured by this ability.

The objective summary displays **(secured)** and the selected qualifying squad displays **Ability: Objective Secured**. The phase event names newly secured objectives, including in the journal and the latest notice. An already-secured objective produces no duplicate ability event.

## Compatibility and verification

Capability ID: `intercessor-objective-secured-v1`. It is frozen in the match manifest and, for saved-list matches, the public setup options. The setting, enabled squad ability and objective state survive local saves and authenticated LAN rejoin. Old saves without this option default to disabled; conflicting save or peer settings are rejected. Other unsupported abilities stay disabled, and old disabled setup hashes are preserved.

`test_objective_secured.gd` covers activation timing, phase/owner/revision guards, enabled/disabled identities, unresolved/resolved Battle-shock, zero OC, leaving/loss, marker objectives, unit identity, journal publication, mixed setup reconstruction, save/resume, old saves and conflicting save/peer options. The network suite covers a guest Intercessor's Command request, replicated securing and authenticated rejoin with mixed lists. A Windows graphical fixture verifies the setup checkbox, unit label and secured-objective summary. Logs/captures remain under `.tools`; no rule PDF is bundled.
