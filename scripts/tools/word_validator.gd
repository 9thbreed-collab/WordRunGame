## WordValidator -- Build-time tool for validating word pairs.
## Checks words against a dictionary and profanity filter.
class_name WordValidator
extends RefCounted

var _dictionary: Dictionary = {}  # word -> true (hash set pattern)
var _profanity_filter: ProfanityFilter


func load_dictionary(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("WordValidator: Could not load dictionary at " + path)
		return
	while not file.eof_reached():
		var word := file.get_line().strip_edges().to_lower()
		if word.length() > 0:
			_dictionary[word] = true
	file.close()
	print("WordValidator: Loaded %d words" % _dictionary.size())


func set_profanity_filter(pf: ProfanityFilter) -> void:
	_profanity_filter = pf


func is_valid_word(word: String) -> bool:
	return _dictionary.has(word.to_lower())


func validate_pair(word_a: String, word_b: String) -> Dictionary:
	var result := {"valid": true, "errors": []}

	# Skip starter word (word_a empty)
	if word_a != "" and not is_valid_word(word_a):
		result.valid = false
		result.errors.append("Not in dictionary: " + word_a)

	if not is_valid_word(word_b):
		result.valid = false
		result.errors.append("Not in dictionary: " + word_b)

	if _profanity_filter and _profanity_filter.check_compound(word_a, word_b):
		result.valid = false
		result.errors.append("Profanity detected in: " + word_a + " + " + word_b)

	return result


func validate_level(word_pairs: Array) -> Dictionary:
	var results := {"valid_count": 0, "invalid_count": 0, "errors": []}
	for pair in word_pairs:
		var v := validate_pair(pair.get("word_a", ""), pair.get("word_b", ""))
		if v.valid:
			results.valid_count += 1
		else:
			results.invalid_count += 1
			results.errors.append_array(v.errors)
	return results
