## EventBus -- Global signal relay for decoupled communication.
## All cross-system signals are declared here. No logic -- signals only.
extends Node

# --- Ad lifecycle signals ---
signal ad_banner_loaded
signal ad_banner_failed(error_code: int)
signal ad_interstitial_loaded
signal ad_interstitial_closed
signal ad_rewarded_earned(reward_type: String, amount: int)

# --- IAP signals ---
signal iap_purchase_completed(product_id: String)
signal iap_purchase_failed(product_id: String, error: String)
signal iap_restore_completed

# --- App state signals ---
signal app_state_changed(old_state: String, new_state: String)
signal screen_changed(screen_name: String)

# --- Banner region signals ---
signal banner_region_show
signal banner_region_hide

# --- Feature flag signals ---
signal feature_flag_changed(flag_name: String, value: bool)

# --- Gameplay signals ---
signal word_completed(word_index: int)
signal level_completed
signal level_failed
signal letter_input(letter: String, correct: bool)
signal word_incorrect

# --- Surge system signals ---
signal surge_changed(current_value: float, max_value: float)
signal surge_threshold_crossed(new_multiplier: float)
signal surge_bust()
signal score_updated(new_score: int)
signal bonus_mode_entered
signal bonus_mode_blink
signal bonus_mode_ended

# --- Obstacle signals ---
signal obstacle_triggered(word_index: int, obstacle_type: String)
signal obstacle_cleared(word_index: int, obstacle_type: String)

# --- Sand signals ---
signal slot_fully_sanded(slot: Node)
signal word_unsolvable(word_index: int)

# --- Boost signals ---
signal boost_used(boost_type: String, word_index: int)

# --- Content pipeline signals ---
signal content_update_available(version: String)
signal content_downloaded(land_id: String)
signal content_download_failed(land_id: String)
