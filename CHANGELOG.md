# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-10-16

Initial public prototype. See the [support matrix](docs/support-matrix.md) for
the current feature surface and the [roadmap](docs/roadmap.md) for what remains.

### Added

- Individual miniature movement with coherency, terrain and board-edge checks.
- Morale (Battle-shock), shooting, charges/melee, attack planning, weapon
  selection, defender allocation, mixed defense/Precision, Feel No Pain,
  Hazardous and Devastating Wounds.
- Opt-in unit abilities: Intercessor Objective Secured and Immortal Implacable
  Eradication (training reference).
- Core stratagems: Insane Bravery and Command Re-roll windows for
  Advance/Charge, hit/wound/save pools, attack counts, damage, Hazardous and
  Desperate Escape.
- Authoritative LAN/direct multiplayer with guest seat credentials and
  rejoin after host restart.
- Versioned match persistence, autosave, and a hash-chained event/dice journal
  with verified reconstruction and paged history.
- Army planner (OpenHammer catalog, budgets, local profiles) and saved-list
  matches for four reference core profiles.
- Local OBJ+diffuse model import and automatic ForceOrg catalog/model linking.
- Offline verification runner, CI definition, and demo export.
