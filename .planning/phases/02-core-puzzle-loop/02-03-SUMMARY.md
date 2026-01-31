---
phase: 02-core-puzzle-loop
plan: 03
subsystem: ui
tags: [godot, gdscript, ui, gameplay, puzzle-loop, keyboard, scroll-container, timer]

# Dependency graph
requires:
  - phase: 02-01
    provides: LevelData and WordPair resources with gameplay signals in EventBus
  - phase: 02-02
    provides: LetterSlot and WordRow UI components with input handling

provides:
  - OnScreenKeyboard component (QWERTY layout with DEL key, key_pressed signal)
  - GameplayScreen with complete puzzle loop orchestration
  - Timer countdown system (MM:SS display, level_failed at zero)
  - Auto-scroll animation between word completions
  - Bonus word gate stub ready for Phase 3 surge integration

affects: [03-game-feel, gameplay-integration, phase-3-surge]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Dynamic button connection pattern for keyboard (iterates HBoxContainer children)"
    - "Tween-based auto-scroll with cubic easing for smooth word transitions"
    - "Stub gate pattern at word index 11 for future surge integration"

key-files:
  created:
    - scripts/ui/on_screen_keyboard.gd
    - scenes/ui/on_screen_keyboard.tscn
    - scripts/screens/gameplay_screen.gd
    - scenes/screens/gameplay_screen.tscn
  modified: []

key-decisions:
  - "OnScreenKeyboard uses dynamic iteration in _ready() to auto-connect all buttons (no manual connections needed)"
  - "Auto-scroll uses cubic easing over 0.4s for natural feel"
  - "Bonus gate stub at word 11 (not 12) because word_pairs is zero-indexed"
  - "ScrollContainer vertical_scroll_mode = 2 (show scrollbar when needed)"

patterns-established:
  - "Dynamic child iteration for signal connection (scales to any keyboard layout)"
  - "Tween-based UI animation for gameplay transitions"
  - "Stub pattern with inline comment for future phase integration"

# Metrics
duration: 1min
completed: 2026-01-31
---

# Phase 02 Plan 03: Keyboard and GameplayScreen Summary

**QWERTY on-screen keyboard with full puzzle loop - level loading, input routing, countdown timer, auto-scroll on word completion, and level completion/failure signals**

## Performance

- **Duration:** 1 min
- **Started:** 2026-01-31T20:55:57Z
- **Completed:** 2026-01-31T20:57:26Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments
- OnScreenKeyboard component with QWERTY layout and DEL key, emits key_pressed signal
- GameplayScreen loads test_level_01.tres and creates 15 WordRow instances
- Keyboard input routes to active WordRow (letters to handle_input, DEL to delete_letter)
- Auto-scroll with Tween animation (cubic easing, 0.4s) on word completion
- Countdown timer displays MM:SS, ticks every second, emits level_failed at zero
- EventBus signals emitted: word_completed, letter_input, level_completed, level_failed
- Bonus word gate stub at word index 11 ready for Phase 3 surge integration

## Task Commits

Each task was committed atomically:

1. **Task 1: Create On-Screen Keyboard** - `a532538` (feat)
2. **Task 2: Create GameplayScreen** - `2a6d6ff` (feat)

## Files Created/Modified

- `scripts/ui/on_screen_keyboard.gd` - QWERTY keyboard with key_pressed signal, dynamic button connection
- `scenes/ui/on_screen_keyboard.tscn` - 3-row VBoxContainer with 26 letter buttons + DEL (all 88x72px minimum)
- `scripts/screens/gameplay_screen.gd` - Main puzzle loop: level loading, input routing, timer, auto-scroll, completion/failure
- `scenes/screens/gameplay_screen.tscn` - Control layout with HUD, ScrollContainer, Keyboard, BannerAdRegion, Timer

## Decisions Made

**D1: Dynamic button connection via child iteration**
- OnScreenKeyboard iterates HBoxContainer children in _ready() to auto-connect all buttons
- Eliminates manual signal connections in scene editor
- Scales easily if keyboard layout changes

**D2: Cubic easing for auto-scroll**
- Tween uses TRANS_CUBIC with EASE_OUT over 0.4s
- Natural deceleration feels responsive without being jarring
- Consistent with shake animation approach from 02-02

**D3: Bonus gate stub at word index 11**
- Check occurs after completing word at index 11 (12th word, last base word)
- Always calls _advance_to_next_word(12) to proceed to first bonus word
- Inline comment marks integration point for Phase 3 surge momentum check

**D4: ScrollContainer vertical scrolling enabled**
- Set vertical_scroll_mode = 2 (show scrollbar when needed)
- Allows manual scrolling during gameplay if desired
- Auto-scroll via Tween takes priority for UX flow

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None - all components integrated cleanly with existing WordRow and LetterSlot APIs.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

**Ready for Phase 3 (Game Feel - Surge, Score, and Audio):**
- Complete puzzle loop operational with all EventBus signals firing
- Bonus gate stub at word 11 ready for surge momentum check integration
- Timer countdown active and level_failed/level_completed signals working
- All UI components (keyboard, word rows, timer, scroll) functional

**Outstanding work from Phase 2:**
- Plan 02-04 remaining: Level completion/failure result screens

**No blockers or concerns.**

---
*Phase: 02-core-puzzle-loop*
*Completed: 2026-01-31*
