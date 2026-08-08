> **Disclaimer:** The following scope is subject to change and is not set in stone.

## 🌌 Overview

AI has automated every clean, orderly job on Earth. You’re out of work, so you’re taking the only jobs left in the galaxy: messy, unpredictable ones involving alien creatures that no algorithm wants to touch. You are humanity’s last resort. 

Every planet’s economy has been optimized by AI except for one department: **biological chaos**. You travel from world to world taking whatever hands-on job is open, using instinct and improvisation an AI can’t model.

### Tone
**Slapstick, fast, silly.** Think *Animal Hospital* meets *Who’s Your Neighbor* meets *Overcooked*. Physical comedy under time pressure and escalating mess.

---

## 🎮 Gameplay Mechanics

### Core Loop
1. **Land on Planet:** Intro from the AI HR-Bot (recurring narrator and antagonist).
2. **Job Briefing:** 5 seconds, 1 joke, 1 instruction.
3. **Shift:** Timed task queue of physical interactions (*grab, squeeze, scan, sort, soothe*).
4. **Escalation:** Pace and difficulty ramp up as the timer runs down.
5. **Evaluation:** AI HR-Bot rates you, undercuts you, and sends you to the next planet regardless.

### Controls & Toolset
* **Shared Toolset:** Grab, squeeze, scan, soothe. Each planet applies a different physics rule to this core toolset rather than reskinning the same rule with a new creature.
* **Mouse / Touch:** Click-drag to grab, click to interact, hold to apply pressure.
* **Optional Gamepad:** Left stick to move, Button 1 to grab, Button 2 to act.
* **Design Philosophy:** No combos, no mid-shift menus, everything readable at a glance.

---

## 🤖 The Antagonist: The AI HR-Bot

Appears between every level. Does none of the physical work itself, since it refuses to touch anything organic. Delivers deadpan performance reviews referencing your stats from the level.

> *"Efficiency: acceptable. Hygiene: concerning. Empathy: not a measurable KPI, please disregard."*

* **Production Note:** Cheap to build (static portrait plus text box), carries theme and tone across all four levels.

---

## 🚀 Levels

### Level 1: Zero-G Vet Clinic
* **Twist:** No gravity. Nothing stays on the table—not the patient, not your tools, not you.
* **Setup:** A creature drifts into frame, tumbling slowly. Grabbing it wrong sends it, and you, spinning into the walls.
* **Mechanic:** Click-drag to grab, but momentum is real. You grab with the creature’s spin rather than against it. Treatment items float free and must be caught, not just clicked.
* **Escalation:** More patients drift in overlapping, tools scatter, and one patient panics and thrashes, sending everything spinning.
* **Space Theme Focus:** "Grab something tumbling in freefall" only exists because you’re in space.
* **AI HR-Bot Line:** *"Gravity assist protocols unavailable. This is, statistically, your problem now."*

---

### Level 2: Vacuum-Sealed Egg Sorting
* **Twist:** The sorting bay is depressurized. Eggs sit in fragile vacuum pods. Handle one too roughly and it ruptures, venting the egg into space.
* **Mechanic:** A conveyor of eggs in transparent pods. Read each one through the pod (glow, muffled thump, condensation) and sort into bins before it reaches the airlock. Mistakes cost cabin pressure—a slow environmental hazard that blurs your vision the longer it runs.
* **Escalation:** Multiple belts, ambiguous signals, and one pod actively venting while drifting toward the airlock.
* **Space Theme Focus:** Vacuum and depressurization are actual physical stakes, not decoration. Diagnosing through a barrier under a hazard unique to a sealed space station.

---

### Level 3: Gravity-Well Customs Checkpoint
* **Twist:** The checkpoint has uneven gravity zones. Some spots are heavy and sluggish, others near weightless.
* **Mechanic:** Travelers move through different zones as they queue. Hidden contraband behaves differently per zone: it floats free in low gravity, or gets crushed flat and hidden in high gravity. Reposition travelers between zones to shake things loose.
* **Escalation:** More zones active at once, travelers who know the map and hide in blind spots, and one traveler made of matter that responds to gravity in reverse.
* **Space Theme Focus:** The puzzle is the direct physics of the location, not a cosmetic skin on a checkpoint joke.

---

### Level 4 (Finale): Milking Station on a Tidally Locked World
* **Twist:** The planet doesn’t rotate. One side is permanent day, the other permanent night. The creature only stays calm on the narrow twilight line between them.
* **Mechanic:** Combines all previous verbs while also herding. The creature drifts toward day or night based on mood; reposition it back to the line while performing tasks live on broadcast.
* **Finale Twist:** The AI HR-bot tries to take over remotely and calculates a fixed terminator coordinate, but the line drifts as the planet wobbles. Its static model can’t track a moving target—the player must finish the job by feel.
* **Ending Beat:** The AI HR-Bot updates its review template with a stat it still can’t define, grudgingly labeled *"Reading a room that won't sit still."*

---

## 🎨 Art, Audio & Scoring

* **Art Style:** Simple, flat-shaded 2D / pixel art.
* **Audio:** Small reused SFX bank, plus space-specific environmental cues (depressurization hiss, muffled vacuum thuds) where sound carries real mechanical information.
* **Level Scoring:** 1 to 3 star ratings per level, with categories tied directly to that level’s physics (*Control vs. Chaos, Pressure Maintained, Zones Cleared, Time on the Terminator*) rather than generic speed or cleanliness.

---

## World Design
* **Art Style:** flat 2d world walk around like in pokemon.
* **purpose** walk between minigames on the world
* 
## 🏆 Win Condition & Minimum Viable Scope

### Win Condition
Complete all four jobs to get hired and beat the AI HR-bot’s final review. The ending is a joke stat screen mocking corporate KPIs, landing the game's core thesis: **humans win not by being faster or more efficient than AI, but by being adaptable in ways a fixed model isn't.**

### Minimum Viable Scope (MVS)
If the four-level build is at risk, cut to **Levels 1 and 4 only**. They bookend the narrative arc (learning the physics twist, then beating the AI with it) while fully preserving the thematic payoff.




# Starting Framework

![](https://github.com/GuilhermeGSousa/game-base-2D/blob/master/main_menu.gif)

Check out the [wiki](https://github.com/GuilhermeGSousa/game-base-2D/wiki) for more info on how to use everything in this repo!

## About
A base structure for 2D games using Godot 4.

It aims to include everything needed to create a polished 2D game, from movement scripts to screen postprocessing shaders, while leveraging the new features of Godot 4 and using a clean, scalable and extensible code architecture.

## Install :computer:
This repo uses Godot 4.1 and above!

Simply fork this repo and start working on your game! Some sample scenes are available under `scenes/samples`.

## Itch.io Integration :robot:
This repo also contains workflows to automatically publish this game on itch.io, every time a commit is pushed to `master`. [Check out this wiki page](https://github.com/GuilhermeGSousa/game-base-2D/wiki/Itch.io-Integration) to learn how to set this up for your own game!

## Content

### Samples :video_game:

- A scene showcasing post-processing effects
- A simple top-down scene
- A simple platformer scene
- A simple platformer character scene with a basin animation state machine setup

### Game systems :wrench:
- A simple audio manager
- Scene transition system with some cool effects!
- A save system. Simply add nodes you want to save to a "Saveable" group to mark them for save!

### UI :pencil:
- A main menu
- A settings menu with audio sliders
- A pause menu
- Save/Load game buttons
- An dialog box for NPC and object interations
- A shader based minimap!

### Movement :running:
- Top-down movement
- Side scroller movement with coyote jump and jump buffering

### Shaders :art:
- Scene transition shaders
- Post processing shaders, including blur, chromatic aberration, CRT effect and vignette
- Shaders for in game effects, such as color flickering, color replace, 2D shake and outlines

### Camera :movie_camera:
- Camera following
- Camera 2D shake
- Camera areas (the camera will stay in bounds while the player is inside that area)
