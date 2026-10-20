Subsequent increment (18 October 2026): [Bladeguard Veterans](marine-bladeguard.md) are now admitted as an additional Chaplain bodyguard; the historical increment below records the earlier boundary.

# Chaplain — current e11 implementation

Reviewed 18 October 2026 against [Wahapedia Chaplain](https://wahapedia.ru/wh40k11ed/factions/space-marines/Chaplain), datasheet `000001174`, shared book `000000139`, App. Space Marines (11th edition), and the local export updated 16 October 2026, 21:03:46 GMT+3. Chapter and Boarding Actions adaptations are not enabled.

One model costs 60 points, with a 40mm base, M6/T5, four wounds, Leadership 5+, 3+ armour and a 4+ invulnerable save. The fixed equipment is an Absolvor Bolt Pistol and Crozius Arcanum; the sheet has no weapon replacements. The Crozius retains five attacks, WS2+, Strength 6, AP-1, Damage 2 and Cleave 1. Incursion allows two copies.

The Chaplain is selectable as Warlord and may remain standalone or lead the admitted Intercessor, Assault Intercessor, Infernus, Hellblaster and Sternguard profiles. It occupies the Leader slot, so another Leader cannot join the same bodyguard; the existing permitted Support slot is separate. Other linked bodyguards remain outside admission. The model retains its own defense and Leadership when attached.

Litany of Hate gives the current unit's melee weapons Lance while a living battlefield Chaplain source remains. This includes bodyguards and attached characters. The existing charge condition produces +1 to wound when that unit charged; the ability is not an unconditional wound bonus and does not affect ranged attacks or stack another copy of Lance. Source weapons remain immutable; source death removes the passive benefit.

Spiritual Leader is available at the start of Command, Movement, Shooting, Charge and Fight, during either player's turn. It removes Battle-shock from one friendly Astartes unit within 6 inches of the Chaplain model, with no line-of-sight or CP requirement. A shocked Chaplain can use it, including on its own unit. Dead and off-board sources cannot act. Usage is recorded once per battle round against the persistent Chaplain source model, so a second phase, the opponent's turn or attachment changes cannot refresh it. The next battle round restores availability.

The existing start-of-phase window offers the ability and an explicit decline. Other available start effects remain accessible in that window. Clearing a shocked SMOKE unit can restore its eligibility for Smokescreen before the window closes. This interaction is exercised through the public command path, including actor/revision checks and CP recording.

## Controls and validation

The existing ability selector identifies the Chaplain and target, with a full-label tooltip and contextual help explaining range, round limit and zero CP. The inspected real Godot capture `.tools/chaplain-spiritual-leader.png` uses admitted profiles in a staged start-of-Movement fixture at 1600x1000. It is not a completed match or proof of other viewport sizes. The earlier start-window controls remain documented in [the marksmen increment](marine-eliminators.md).

The [audit](marine-chaplain-audit.json) records the runtime-versus-export numeric comparison and the final local regression. Network validation remains deferred to final integration. Full army, faction, match and imported-mesh visibility certification remain false.
