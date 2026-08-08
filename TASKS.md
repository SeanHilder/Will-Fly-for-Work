# Will Fly for Work — MVP Coordination

**Goal for today:** playable MVP — main menu → walk around world hub → talk to NPC → play Level 1 (Zero-G Vet Clinic) → get evaluated → back to world.
**Tomorrow (stretch):** add Levels 2–4 at the same NPC/portal slots.

## MVP Flow

```
Main Menu ──▶ World Hub (Pokemon-style walkaround)
                  │
                  ▼ (approach NPC, press interact)
             Dialogue (HR-Bot briefing, 1 joke, 1 instruction)
                  │
                  ▼
             Level 1: Zero-G Vet Clinic (timed shift)
                  │
                  ▼
             Evaluation screen (HR-Bot review + stars)
                  │
                  └──────▶ back to World Hub (level marked done)
```

## Team & Files

| Person | File | Scope |
|---|---|---|
| A | `tasks/person_A_core.md` | Game flow, shared interfaces, player movement + grab API |
| B | `tasks/person_B_world.md` | World hub map, NPCs, dialogue, interact-to-start-level |
| C | `tasks/person_C_level1.md` | Level 1 minigame: zero-g physics, creature, grab, timer |
| D | `tasks/person_D_ui.md` | HUD, HR-Bot evaluation screen, stars, audio, main menu wiring |

## Integration contracts (define before writing levels)

- **GameManager (A)** — autoload (DONE, see `scripts/utilities/game_manager.gd`):
  - `start_level(level_id: String)` — fades into the level scene (validates unlock)
  - `level_completed(level_id: String, score: int)` — records best score, returns to hub
  - `is_level_unlocked(level_id) -> bool` / `get_level_status(level_id) -> bool` / `get_score(level_id) -> int`
  - Level registry lives in `LEVELS` in `game_manager.gd` — add your level scene path there
- **Level interface (A)** — every level scene must expose:
  - `level_id`, `start_shift()`, signal `on_shift_completed(score: int)`
- **HUD (D)** — reads from the level's signals; never from level internals.
- **Dialog (B)** — wraps `dialog_box.tscn`; exposes `show_lines(lines: Array, on_finished: Callable)`.

## OPEN DECISION — two level-launching systems

- [ ] **Decide who owns launching levels into the game.** The team currently has TWO parallel systems:
  - **`GameManager.start_level(level_id)`** (Person A) — fades into a `BaseLevel` scene (hub → level → evaluation → hub flow)
  - **`MinigameHost.launch(quest_id, minigame_scene)`** + `GameState` + `QuestNPC` (samin1010) — overlays a `Minigame` on a CanvasLayer above the current scene, tracks quest state and saves progress
- [ ] Agree which one the MVP actually uses for Level 1 (recommend: one becomes the single entry point; the other either wraps it or waits for a later feature)
- [ ] Update this doc + `tasks/person_A_core.md` / the quest owner's task file once decided
- [ ] Note: both are registered autoloads and boot fine together — no conflict yet, just ownership ambiguity

## MVP Definition of Done

- [ ] Launch from main menu → world hub
- [ ] Player walks around world (top-down, no jumping)
- [ ] One NPC (HR-Bot or station hand) starts Level 1 via dialogue
- [ ] Level 1 fully playable: grab patient/tools, treat them, timer ends shift
- [ ] Evaluation screen shows score + stars + a deadpan bot line
- [ ] Return to world, level marked complete
- [ ] World has 1+ extra "coming soon" slot so tomorrow's levels plug in
- [ ] No errors in Godot output

## Git rules

- One branch per person: `mvp-core`, `mvp-world`, `mvp-level1`, `mvp-ui`
- Merge to master only when your task list is ticked and the game still runs
- Don't touch files outside your person's scope without saying so in the PR
