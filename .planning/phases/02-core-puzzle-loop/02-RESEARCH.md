# Phase 2: Core Puzzle Loop - Research

**Researched:** 2026-01-31
**Domain:** Godot 4.5 scrolling word puzzle UI, touch keyboard, level data model, input feedback
**Confidence:** HIGH (standard Godot UI patterns, well-documented)

## Summary

Phase 2 builds the atomic gameplay mechanic: a scrolling window of word rows with letter slots, an on-screen keyboard, auto-submit/advance, and a countdown timer. All patterns use standard Godot 4.5 Control nodes. No plugins needed — pure GDScript and scenes.

## Standard Stack

| Component | Godot Nodes | Why |
|-----------|-------------|-----|
| Scrolling word display | ScrollContainer + VBoxContainer | Built-in touch scrolling, programmatic scroll_vertical via Tween |
| Word row | HBoxContainer of PanelContainer (LetterSlot) | Modular, each slot manages own state |
| On-screen keyboard | VBoxContainer of HBoxContainers of Buttons | Full control over appearance, 48dp+ targets |
| Level data | Custom Resource classes (LevelData, WordPair) | @export fields, inspector-editable, .tres files |
| Timer | Timer node + Label | 1-second timeout, MM:SS display |
| Animations | Tween-based | Scroll animation, shake feedback, color transitions |

## Architecture Patterns

### Scene Tree: GameScreen

```
GameScreen (Control, full rect)
  MainVBox (VBoxContainer, full rect)
    HUD (HBoxContainer or MarginContainer)
      TimerLabel (Label) -- MM:SS countdown
      ScoreLabel (Label) -- placeholder for Phase 3
    WordDisplay (ScrollContainer, expand fill -- takes remaining space)
      WordRows (VBoxContainer)
        WordRow instances (from word_row.tscn)
    OnScreenKeyboard (VBoxContainer, fixed height ~320px)
      Row1 (HBoxContainer) -- Q W E R T Y U I O P
      Row2 (HBoxContainer) -- A S D F G H J K L
      Row3 (HBoxContainer) -- Z X C V B N M [DEL]
  BannerAdRegion (instance of existing banner_ad_region.tscn)
```

### Letter Slot States

Each LetterSlot (PanelContainer + Label) has 4 visual states:
- EMPTY: light border, no text
- FILLED: solid background, letter shown
- CORRECT: green background, letter shown (on auto-submit)
- INCORRECT: red flash, shake animation

### Word Row Structure

```
WordRow (HBoxContainer)
  ClueLabel (Label) -- shows word_a (the clue/first word)
  LetterSlot0 (PanelContainer + Label)
  LetterSlot1 ...
  LetterSlotN ...
```

Each WordRow knows its solution word (word_b). As letters are typed, they fill slots left to right. When all slots filled correctly → auto-submit.

### On-Screen Keyboard

QWERTY layout, 3 rows + delete key. All buttons connected to single `key_pressed(key: String)` signal. At 1080px width with 10 keys per row: ~100px per key (well above 48dp ≈ 144px at standard density, adjust with spacing).

```gdscript
signal key_pressed(key: String)

func _ready() -> void:
    for hbox in get_children():
        if hbox is HBoxContainer:
            for button in hbox.get_children():
                if button is Button:
                    button.pressed.connect(_on_button_pressed.bind(button.text))

func _on_button_pressed(char: String) -> void:
    key_pressed.emit(char)
```

### Word Data Model

```gdscript
# WordPair resource
class_name WordPair
extends Resource
@export var word_a: String = ""  # clue word (displayed)
@export var word_b: String = ""  # answer word (player types)

# LevelData resource
class_name LevelData
extends Resource
@export var level_name: String = ""
@export var time_limit_seconds: int = 180
@export var word_pairs: Array[WordPair] = []
# First 12 = base words, last 3 = bonus words (indices 12-14)
```

### Auto-Submit + Scroll

When word is complete and correct:
1. Set all slots to CORRECT state
2. Wait 0.4s (visual confirmation)
3. Tween ScrollContainer.scroll_vertical to next row's position
4. Activate next word row for input

```gdscript
func scroll_to_row(row_index: int) -> void:
    var row: Control = word_rows.get_child(row_index)
    var tween: Tween = create_tween()
    tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
    tween.tween_property(self, "scroll_vertical", row.position.y, 0.5)
```

### Input Feedback

Wrong letter: shake the current word row + flash slot red.

```gdscript
func shake() -> void:
    var orig_x: float = position.x
    var t: Tween = create_tween()
    t.tween_property(self, "position:x", orig_x - 15.0, 0.05)
    t.tween_property(self, "position:x", orig_x + 15.0, 0.05)
    t.tween_property(self, "position:x", orig_x - 15.0, 0.05)
    t.tween_property(self, "position:x", orig_x, 0.05)
```

### Countdown Timer

Timer node with 1s wait_time. Each timeout decrements counter, updates label. At 0 → level failed signal.

## Integration Points

- **GameManager**: transition_to(PLAYING) when level starts, transition_to(RESULTS) when timer runs out or all words solved
- **EventBus**: New signals needed — `word_completed`, `level_completed`, `level_failed`, `letter_input`
- **BannerAdRegion**: Already built, included at bottom of GameScreen layout
- **LevelData loading**: GameManager or a new LevelManager handles loading the correct .tres

## Pitfalls

1. **ScrollContainer touch conflict**: Disable manual scrolling (scroll_horizontal/vertical = false in physics) — only allow programmatic scrolling. Player should not manually scroll the word list.
2. **Keyboard blocking native input**: Do NOT use Godot's built-in virtual keyboard (DisplayServer). Build custom buttons.
3. **Touch target size**: At 1080px width, 48dp = ~144px at 3x density. With 10 keys + spacing, each key ≈ 96px. May need to reduce to 9 keys on shortest row or increase keyboard height.
4. **Font readability**: Letter slots need large, clear font. Minimum 36px for letter text in slots.

## Open Questions

1. **Word pair content format for Phase 2**: Use hardcoded test data (Array of WordPair resources in code) or .tres files? Recommendation: hardcoded test arrays for Phase 2 speed; .tres files added in Phase 4 content pipeline.
2. **Bonus word gating**: PUZL-08 requires surge momentum check. Phase 3 builds surge. For Phase 2: stub the gate (always allow bonus words) with a clear hook point for Phase 3 to plug into.

## Sources

- Godot 4.5 docs: ScrollContainer, VBoxContainer, PanelContainer, Tween, Timer, Resource
- Standard Godot UI patterns for mobile word games
