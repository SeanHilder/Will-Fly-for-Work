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
- [x] Level registry: simple `Dictionary` mapping `level_id -> PackedScene` (+ world hub scene id) — done inside `game_manager.gd` (`LEVELS` + `LEVEL_ORDER`)
- [x] Player scene for the **world hub**: top-down movement, reuses `scripts/movement/top_down_controller.gd` (already has knockback; ignore knockback, use move input) — `scenes/world_hub/hub_player.tscn`
  - [x] Add `Interactor` child (from `scripts/interaction/interactor.gd`) so NPC interaction works out of the box
  - [x] Player collision shape + camera following (`camera_area.tscn` optional) — Camera2D in `world_hub.tscn`
- [x] **Level interface contract** — `scripts/gameplay/base_level.gd`:
  - `@export var level_id: String`, `@export var shift_duration := 60.0`
  - `func start_shift()` — override in the concrete level
  - `signal on_shift_completed(score: int)`
  - `func end_shift(score)` — emits the signal; does NOT call GameManager (evaluation "Next" button does)
  - `_ready` warns if `level_id` mismatches `GameManager.current_level_id`
- [x] Grab API for the level:
  - **`scripts/gameplay/grabbable.gd`** (`class_name Grabbable extends RigidBody2D`):
    - `grab(grab_offset := Vector2.ZERO)`, `update_target(pos)`, `release(velocity, angular_velocity)`
    - `is_held()`, signals `on_grabbed` / `on_released`
    - Held = frozen physics + smooth cursor follow; release restores momentum (zero-g twist)
    - Scene setup: collision layer 5 ("Dynamic Object"), `PhysicsMaterial` friction 0
  - **`scripts/gameplay/grab_controller.gd`** (`class_name GrabController extends Node`):
    - Left-click (`shoot` action) physics-picks layer-5 grabbables under cursor
    - Tracks cursor history; release passes avg velocity + spin (arcs become rotation)
    - `try_grab_at(world_pos)`, `release_held()`, `held` property
- [x] Wire main menu → world hub (`start_scene_path` in `scenes/samples/main_menu.tscn`)
- [x] Pause menu reachable in hub (`pause_menu.tscn` instanced in `world_hub.tscn`; levels get it via D's HUD)
- [x] Placeholder level for testing: `scenes/levels/level_1.tscn` + `scripts/gameplay/placeholder_level.gd`
  - Full loop: `start_level("level_1")` → briefing delay → shift timer → `end_shift(42)` → auto `level_completed` → back to hub
  - Person C replaces the scene content; keep the `level_1` id + BaseLevel contract

## Hand off to others

- Tell B: `GameManager.start_level("level_1")` signature + level ids
- Tell C: `BaseLevel` API + `Grabbable` usage example scene
  - Level root script extends `BaseLevel`, sets `level_id = "level_1"`
  - Player grabs objects via the scene's `GrabController` (left-click drag)
  - Creatures/items that can be picked up are `RigidBody2D` + `grabbable.gd`, collision layer 5
  - `end_shift(score)` emits `on_shift_completed`; do NOT call `GameManager` directly
- Tell D: how to reach the score signal and where evaluation screen hooks in
  - Evaluation screen listens to `on_shift_completed(score)`; its "Next" button calls `GameManager.level_completed(level_id, score)`

## TODO — open coordination item

- [ ] **Resolve the dual level-launch systems** (see TASKS.md "OPEN DECISION"): `GameManager.start_level` (A's BaseLevel flow) vs `MinigameHost.launch`/`GameState`/`QuestNPC` (teammate's Minigame overlay system). Decide the single entry point for MVP Level 1 and update these docs. Both boot fine together today — ownership is undecided, not broken.

## Done when

- `main_menu.tscn` → world hub works with a fade transition
- `GameManager.start_level()` loads the placeholder level and returns to the hub after the shift
- `Grabbable` demo works: click-drag a crate, release with momentum (crate keeps flying)
