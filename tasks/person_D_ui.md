# Person D — HUD, Evaluation, Audio & Main Menu

**Branch:** `mvp-ui`
**Focus:** everything the player reads and hears: HUD during the shift, HR-Bot review after it, audio, and the main menu.

## Tasks

### HUD (lives inside the level scene; C instantiates it)
- [ ] `hud.tscn` — CanvasLayer with:
  - [ ] Shift timer (counts down, C's timer is the source of truth — HUD only reads)
  - [ ] Task prompt line ("Treat the patient: 3 left" — driven by C's task queue signal)
  - [ ] Score counter
  - [ ] Connect to C's signals: `on_shift_completed`, task updates, timer ticks
  - [ ] Warning flash when time < 15s (use `color_flicker.gdshader` or tween the label)
- [ ] Pause button → template `pause_menu.tscn`

### Evaluation screen (AI HR-Bot)
- [ ] `evaluation.tscn` — static bot portrait + text box (README says: cheap to build, carries the tone)
  - [ ] Opens when `on_shift_completed(score)` fires
  - [ ] Shows: stars (1–3), score, 1–2 deadpan review lines referencing real stats
  - [ ] Example lines: *"Efficiency: acceptable. Hygiene: concerning. Empathy: not a measurable KPI, please disregard."* + Level 1 line: *"Gravity assist protocols unavailable. This is, statistically, your problem now."*
  - [ ] "Next" button → back to world hub (via `GameManager.level_completed` / scene transition)
- [ ] Star logic: thresholds from C's scoring (1/2/3)

### Main menu
- [ ] `main_menu.tscn` (template already exists in `scenes/samples/`)
  - [ ] Title: "Will Fly for Work" + subtitle line from the premise
  - [ ] Start → world hub; Settings (audio sliders from template); Quit
  - [ ] Wire `start_scene_path` to the world hub scene

### Audio
- [ ] Reuse `AudioManager` autoload
  - [ ] SFX: grab, release, treat-success, timer-tick, evaluation sting
  - [ ] Ambience: low space hum for hub + clinic (or skip ambience if time is tight)
  - [ ] Settings menu volume sliders already exist in template — verify they work

## Hand off to others

- Give B the evaluation screen scene path so he can hook the "back to hub" transition
- Confirm with C the exact score signal payload + star thresholds before locking the screen

## Done when

- HUD shows timer, task, score during the shift and flashes at low time
- Evaluation screen appears after shift end with stars + bot line + working "next" button
- Main menu launches the game (Start → hub) and Quit works
- Grab/treat SFX play in Level 1
