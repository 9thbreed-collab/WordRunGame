## WordPair -- A single word puzzle pair (clue word + answer word).
## This custom resource holds one compound word split into two parts:
## word_a is the clue word shown to the player, word_b is the answer they type.
class_name WordPair
extends Resource

## The clue word displayed to the player (e.g., "sea" for "seashell")
@export var word_a: String = ""

## The answer word the player must type (e.g., "shell" for "seashell")
@export var word_b: String = ""
