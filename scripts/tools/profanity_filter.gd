## ProfanityFilter -- Build-time tool for validating word content.
## Checks words and compounds against a profanity list with safe-word exceptions.
class_name ProfanityFilter
extends RefCounted

var _profanity_list: PackedStringArray = []
var _safe_words: PackedStringArray = []


func load_filter(json_path: String) -> void:
	var file := FileAccess.open(json_path, FileAccess.READ)
	if file == null:
		push_warning("ProfanityFilter: Could not load filter at " + json_path)
		return
	var json := JSON.new()
	json.parse(file.get_as_text())
	file.close()
	var data: Dictionary = json.data
	_profanity_list = PackedStringArray(data.get("profanity", []))
	_safe_words = PackedStringArray(data.get("safe_words", []))


## Check if a single word contains profanity
func check_word(word: String) -> bool:
	var lower := word.to_lower()
	if _safe_words.has(lower):
		return false  # Explicitly safe
	if _profanity_list.has(lower):
		return true  # Direct match
	# Check for substring matches
	for profane in _profanity_list:
		if lower.contains(profane):
			if not _is_safe_context(lower, profane):
				return true
	return false


## Check if a compound word pair contains profanity
func check_compound(word_a: String, word_b: String) -> bool:
	return check_word(word_a) or check_word(word_b) or check_word(word_a + word_b)


## Check if a profane substring appears in a safe context
func _is_safe_context(text: String, profane: String) -> bool:
	for safe in _safe_words:
		if safe.contains(profane) and text.contains(safe):
			return true
	return false
