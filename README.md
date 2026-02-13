# Ladeira Abaxio

Hullo!

Welcome to the repo of our game: Ladeira Abaixo. A sort of endless runner where you try to avoid crashing while going downhill on the streets of São Paulo sitting on a skateboard. 

This game built with **Noble Engine** - a Lua-based framework that makes developing for the Playdate handheld console much easier.

Below is the main structure of the project. Hopefully to give an overview of how the game is set up and working.

For more information and to play the game, check the itch page and other links. 

---

## Source Folder Overview

```
source/
├── main.lua              # Game entry point - starts everything up
├── pdxinfo              # Game metadata (name, author, version)
├── assets/              # All visual and audio content
├── classes/             # Game objects and their behaviors
├── scenes/              # Different screens in the game
├── systems/             # Core game logic managers
├── utilities/           # Helper functions and constants
└── libraries/           # Third-party code (Noble Engine)
```

---

## Main Entry Point

**`main.lua`**
- Initializes Noble Engine
- Sets up game data and settings
- Loads all scenes and starts the game

---

## 🎨 Assets

Everything visual and audio lives here:

```
assets/
├── audio/
│   ├── music/     # Background music tracks
│   └── sfx/       # Sound effects
├── fonts/         # Custom fonts for text
├── images/
│   └── sprites/   # Character and object images
└── launcher/      # Playdate home menu icons
```

---

## Scenes

Different screens and game states:

| Scene | Purpose |
|-------|---------|
| **TitleScene** | Main menu |
| **GameScene** | Where the actual gameplay happens |
| **TutorialScene** | How to play instructions |
| **SettingsScene** | Game options |
| **InitialsPostScene** | High score entry |
| **CreditsScene** | Credits roll |

Each scene handles its own:
- Display and animations
- User input
- Transition to other scenes

---

## Classes

Game objects organized by type:

### Base Classes
The foundation - all objects inherit from these:
- **GameObject** - Basic object with movement and collision
- **Enemy** - Objects that can hurt the player
- **Obstacle** - Static things to avoid
- **Boost** - Power-ups that help the player
- **Dressings** - Background decorations

### Objects
Specific game entities built on base classes:
- **Player** - The character aka you in game
- **Pipoqueiro, Uninho, Motoboy** - Different enemy types
- **Oil, Bola** - Obstacles to avoid
- **Bueiro, Pastel** - Power-ups to collect

### Background
Visual elements that are the Dressings class:
- Flags, posts, cables, curbs, signs, etc.

---

## Systems

Managers that handle core gameplay:

| System | What It Does |
|--------|--------------|
| **SpeedManager** | Controls how fast everything moves |
| **SpawnManager** | Creates new objects during gameplay |
| **MovementManager** | Handles player input and physics |
| **EffectManager** | Manages power-up effects and timers |

These work together to keep the game running smoothly.

---

## Utilities

Helper code that makes everything else easier:

- **GameConstants** - All game settings and values in one place
- **Sound** - Audio playback helpers
- **Shaker** - Screen shake effects
- **Utilities** - Misc helper functions

Tweak values in `GameConstants.lua` to change gameplay feel!

---

## Libraries

**Noble Engine** lives here as a git submodule.

Noble provides:
- Scene management and transitions
- Sprite and animation systems
- Input handling
- Menu creation
- Data persistence

Learn more:

https://noblerobot.github.io/NobleEngine/index.html

---

## Credits

### Game by

[mama-cailleach](https://github.com/mama-cailleach) & [vfiaca](https://github.com/vfiaca)

### Links

[Game Page](https://vfiaca.itch.io/ladeira-abaixo)

[Soundtrack](https://ladeira-abaixo.bandcamp.com/album/ladeira-abaixo)

[Noble Engine](https://github.com/NobleRobot/NobleEngine)

[Playdate](https://play.date) by [Panic](https://panic.com/)
