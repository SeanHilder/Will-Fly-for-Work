# Person B — World Hub & NPC Interaction

**Branch:** `mvp-world`
**Focus:** the Pokemon-style hub: walk around a flat 2D world, talk to NPCs, start levels.

## Tasks

- [ ] `world_hub.tscn` scene (root: Node2D)
  - [ ] Ground via `better_tilemap.gd` or simple StaticBody2D floors — flat, walkable
  - [ ] Decor (walls, crates, signs) — placeholder shapes are fine today
  - [ ] Add player scene from A, camera 2D following
  - [ ] Clear color / ambient space vibe (dark + stars later, shader `color_flicker` available)
- [ ] **NPC template** scene: `npc.tscn` (Sprite + `Interactable` + `CollisionShape`)
  - [ ] Reuses `scripts/interaction/interactible.gd` (note: file is `interactible.gd`, class `Interactable`)
  - [ ] Floating "!" prompt above head when player is in range
- [ ] **Dialog wrapper** around template `dialog_box.tscn`
  - [ ] `show_lines(lines: Array, on_finished: Callable)` — typewriter text via `dialog_box.gd`
  - [ ] Click / `use` advances lines
  - [ ] Pause player movement while dialog is open
- [ ] **Level-start NPC** (the HR-Bot or station hand):
  - Walk to them → press `use` → dialogue: 1 joke + 1 instruction (briefing lines)
  - On dialog end → `GameManager.start_level("level_1")`
  - Use `SceneTransitionManager.change_scene_with_transition` (fade looks good)
- [ ] **"Coming soon" NPCs/portals** for Levels 2–4 (tomorrow's stretch):
  - [ ] Interact → one line like *"Shifts here are full right now. HR-Bot is reviewing your application."*
  - [ ] If `GameManager.get_level_status("level_1")` → change their line to *"Go get them"* style
- [ ] Player spawn point in front of the first NPC

## Hand off to others

- Tell A if you need `start_level` to accept a transition type
- Tell C the level scene should NOT auto-start — it waits for the briefing dialog to close
- Tell D which node names/ids the HUD is expected in (if HUD lives in the level, not the hub)

## Done when

- Walk around the hub with collision, camera follows
- One NPC starts Level 1 through dialog → fade → level loads
- One "coming soon" NPC gives a one-liner and does nothing else
- Returning from level lands the player back at the hub spawn
