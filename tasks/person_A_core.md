# Person A — Core Framework

**Branch:** `mvp-core`
**Focus:** make the whole loop possible. Build first, others build against you.

## Tasks

- [x] `GameManager` autoload (add to `project.godot` [autoload] section)
  - `start_level(level_id)` → transition to that level's scene via `SceneTransitionManager`
  - `level_completed(level_id, score)` → store result, transition back to world hub
  - `get_level_status(level_id) -> bool` (cleared or not)
  - **Final API (see `scripts/utilities/game_manager.gd` for full docs):**
    - `start_level(level_id: String)` — validates unlock + registry, fades into the level
    - `level_completed(level_id: String, score: int)` — records best score, fades back to hub
    - `return_to_hub()` — fade to hub without recording (pause/abandon)
    - `get_level_status(level_id) -> bool` — cleared?
    - `is_level_unlocked(level_id) -> bool` — sequential unlock, level 1 always open
    - `get_score(level_id) -> int`, `get_completed_count() -> int`
    - `reset_progress()` — dev helper
  - **Registry:** add your level to `LEVELS` in `game_manager.gd` (id -> scene path). Scenes load by path, so missing scenes won't break the project.
- [ ] Level registry: simple `Dictionary` mapping `level_id -> PackedScene` (+ world hub scene id)
- [ ] Player scene for the **world hub**: top-down movement, reuses `scripts/movement/top_down_controller.gd` (already has knockback; ignore knockback, use move input)
  - [ ] Add `Interactor` child (from `scripts/interaction/interactor.gd`) so NPC interaction works out of the box
  - [ ] Player collision shape + camera following (`camera_area.tscn` optional)
- [ ] **Level interface contract** — define a `BaseLevel` class (`scripts/gameplay/base_level.gd`):
  - `@export var level_id: String`
  - `func start_shift()`
  - `signal on_shift_completed(score: int)`
  - `func end_shift(score)` — emits signal, tells `GameManager`
- [ ] Grab API for the level: `Grabbable` component (`Area2D`/`RigidBody2D`-based)
  - `grab()`, `release(velocity)`, signal `on_grabbed` / `on_released`
  - Velocity/rotation preserved on release (momentum stays — zero-g twist)
- [ ] Wire main menu → world hub (`start_scene_path` in `scenes/samples/main_menu.tscn`)
- [ ] Pause menu reachable in hub + level (template `pause_menu.tscn`)

## Hand off to others

- Tell B: `GameManager.start_level("level_1")` signature + level ids
- Tell C: `BaseLevel` API + `Grabbable` usage example scene
- Tell D: how to reach the score signal and where evaluation screen hooks in

## Done when

- `main_menu.tscn` → world hub works with a fade transition
- `GameManager.start_level()` can load C's level scene (test with a placeholder scene)
- `Grabbable` demo scene works with mouse click-drag + release momentum
