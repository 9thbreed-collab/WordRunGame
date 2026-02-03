# Phase 3 Research: Game Feel -- Surge, Score, and Audio

## Surge Bar UI
- Use TextureProgressBar with tint properties for track/progress/mask
- Threshold markers: child VSeparator or NinePatchRect nodes positioned via anchor percentages
- Animate fill/drain with Tween (not direct _process value set) using TRANS_SINE over ~0.2s
- Kill running tween before creating new one to prevent overlap

## Surge System Architecture
- SurgeSystem node lives as child of GameplayScreen (not autoload -- scoped to gameplay)
- Drain: _process(delta) with frame-rate independent drain (surge_value -= drain_rate * delta)
- Fill: connect to EventBus.word_completed, add fixed amount
- State machine enum: IDLE, SURGING, IMMINENT, BUSTED
- Different drain rates per state; BUSTED runs tween to zero, ignores fill

## SurgeConfig Resource
- class_name SurgeConfig extends Resource
- Properties: max_value, idle_drain_rate, imminent_drain_rate, fill_per_correct_word
- Thresholds array and multipliers array (parallel arrays)
- bust_on_drop_after_imminent flag
- Added to LevelData as @export var surge_config: SurgeConfig

## Score System
- Score tracked in GameplayScreen as local var
- SurgeSystem emits multiplier_updated(new_multiplier) signal
- On word_completed: points = BASE_WORD_SCORE * current_multiplier
- Pass score to ResultsScreen on level end

## Audio Manager
- AudioManager autoload singleton
- 2x AudioStreamPlayer for BGM (crossfade support)
- Pool of 8-12 AudioStreamPlayer for SFX (concurrent sounds)
- API: play_sfx(stream, bus), play_bgm(stream)
- Audio buses: Master, BGM, SFX (configured in Project Settings)

## Haptic Feedback
- Built-in: Input.vibrate_handheld(duration_ms) -- works iOS + Android, no plugin
- Light (50ms) for letter input, medium (100ms) for word complete, heavy (200ms) for bust

## Animation Polish
- Letter pop-in: Tween scale Vector2.ZERO to Vector2.ONE with TRANS_BACK
- Word completion: Tween modulate flash or scale pulse
- Surge threshold cross: Tween scale pulse + color flash on bar
- Bust sequence: AnimationPlayer for multi-track (bar flash red, drain, BUST label)
- Simple = Tween, complex/multi-track = AnimationPlayer

## Plan Breakdown
- Plan 1: SurgeConfig resource + SurgeSystem node + surge bar UI + score/multiplier (Wave 1)
- Plan 2: AudioManager autoload + SFX + BGM + haptics (Wave 2, depends on Plan 1)
- Plan 3: Animation polish -- letter pop, word celebration, surge bar animations (Wave 3, depends on Plan 1+2)
