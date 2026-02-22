#!/usr/bin/env python3
"""
Calculate Cognitive Entropy Score (CES) for each phrase.

CES measures how many cognitively obvious alternatives exist when a player
sees word1. A CES of 1 means the answer is obvious; higher CES means more
competing alternatives make the answer less intuitive.

CES = count of high-frequency bigrams starting with word1 that share
      the same first letter as word2
"""

import csv
import json
from pathlib import Path
from collections import defaultdict

# Paths
DATA_DIR = Path("/Users/nathanielgiddens/WordRunGame/ContentRuleDoc/data/phrases")
MASTER_FILE = DATA_DIR / "phrases_master.csv"
OUTPUT_FILE = DATA_DIR / "phrases_master_ces.csv"

# Build internal corpus of common word pairings
# This is derived from common English bigrams and the phrase bank itself
COMMON_BIGRAMS = defaultdict(list)

# Common word1 -> [word2 options] based on high-frequency English usage
KNOWN_BIGRAMS = {
    "hot": ["dog", "sauce", "tub", "air", "seat", "plate", "water", "spot", "pink", "shot"],
    "ice": ["cream", "cube", "cold", "age", "cap", "box", "pick", "berg", "water", "fishing"],
    "fire": ["truck", "place", "fighter", "house", "alarm", "pit", "drill", "escape", "work", "fly"],
    "car": ["seat", "wash", "door", "port", "pool", "park", "pet", "go", "jack", "sick"],
    "school": ["bus", "zone", "yard", "board", "work", "house", "bag", "book", "teacher", "day"],
    "bus": ["stop", "station", "driver", "route", "ticket", "fare", "ride", "line", "pass", "terminal"],
    "stop": ["sign", "light", "watch", "gap", "over", "loss", "page", "motion", "time", "action"],
    "post": ["card", "office", "box", "man", "age", "mark", "script", "date", "war", "game"],
    "card": ["game", "table", "board", "holder", "stock", "sharp", "key", "catalog", "shark", "carrier"],
    "back": ["door", "yard", "pack", "bone", "ground", "stage", "drop", "seat", "fire", "board"],
    "front": ["door", "yard", "page", "row", "desk", "line", "wheel", "porch", "end", "office"],
    "side": ["dish", "door", "walk", "line", "show", "kick", "bar", "car", "step", "effect"],
    "door": ["bell", "way", "step", "mat", "knob", "man", "frame", "prize", "stop", "handle"],
    "bed": ["room", "side", "time", "spread", "post", "frame", "cover", "sheet", "bug", "rock"],
    "bath": ["room", "tub", "robe", "mat", "towel", "time", "water", "house", "salt", "bomb"],
    "book": ["shelf", "case", "store", "mark", "worm", "bag", "end", "club", "keeper", "let"],
    "table": ["cloth", "top", "lamp", "tennis", "spoon", "salt", "leg", "saw", "ware", "land"],
    "time": ["table", "line", "frame", "zone", "keeper", "piece", "card", "out", "stamp", "share"],
    "sun": ["light", "shine", "rise", "set", "flower", "burn", "screen", "roof", "day", "dial"],
    "day": ["light", "time", "break", "dream", "care", "pack", "job", "trip", "bed", "room"],
    "night": ["club", "stand", "life", "time", "fall", "mare", "shift", "gown", "owl", "cap"],
    "rain": ["coat", "drop", "bow", "fall", "storm", "water", "forest", "check", "maker", "gauge"],
    "snow": ["ball", "flake", "man", "storm", "fall", "shoe", "plow", "drift", "mobile", "board"],
    "ball": ["game", "park", "room", "point", "player", "field", "boy", "gown", "cap", "pen"],
    "game": ["day", "plan", "board", "show", "room", "time", "piece", "play", "bird", "fish"],
    "food": ["court", "truck", "chain", "bank", "stamp", "fight", "stuff", "web", "source", "service"],
    "air": ["port", "plane", "line", "bag", "way", "force", "craft", "field", "fare", "ship"],
    "water": ["fall", "front", "proof", "melon", "shed", "way", "color", "line", "mark", "bed"],
    "house": ["boat", "hold", "wife", "work", "plant", "guest", "keeper", "warming", "fly", "coat"],
    "home": ["town", "work", "sick", "land", "made", "room", "coming", "owner", "body", "base"],
    "high": ["school", "way", "light", "land", "chair", "ball", "rise", "jack", "road", "wire"],
    "low": ["ball", "land", "life", "down", "light", "key", "rider", "brow", "boy", "gear"],
    "hand": ["bag", "book", "rail", "shake", "stand", "work", "made", "out", "gun", "cuff"],
    "head": ["band", "line", "phone", "rest", "way", "light", "ache", "gear", "room", "first"],
    "foot": ["ball", "note", "print", "wear", "step", "hill", "rest", "path", "work", "hold"],
    "eye": ["ball", "brow", "lid", "glass", "witness", "sight", "lash", "liner", "cup", "drop"],
    "sea": ["food", "shore", "shell", "side", "port", "horse", "water", "weed", "bird", "bed"],
    "road": ["side", "block", "work", "map", "trip", "way", "house", "show", "runner", "kill"],
    "street": ["car", "light", "sign", "corner", "vendor", "food", "name", "walker", "wear", "art"],
    "town": ["house", "hall", "ship", "folk", "car", "home", "center", "line", "square", "meeting"],
    "city": ["hall", "center", "life", "state", "block", "wide", "council", "limit", "bus", "park"],
    "paper": ["clip", "work", "back", "cut", "weight", "boy", "bag", "towel", "mate", "trail"],
    "wood": ["work", "land", "pile", "chip", "pecker", "shed", "cut", "grain", "wind", "block"],
    "rock": ["band", "star", "slide", "climb", "garden", "salt", "fish", "pool", "solid", "hard"],
    "tree": ["house", "top", "line", "trunk", "bark", "branch", "frog", "stand", "fort", "farm"],
    "flower": ["pot", "bed", "shop", "garden", "girl", "power", "show", "child", "box", "arrangement"],
    "grass": ["land", "root", "hopper", "court", "seed", "blade", "fire", "green", "fed", "cloth"],
    "park": ["bench", "way", "land", "ranger", "ing", "side", "keeper", "life", "service", "space"],
    "beach": ["ball", "front", "head", "side", "wear", "house", "chair", "goer", "comb", "towel"],
    "pool": ["side", "table", "room", "hall", "party", "boy", "shark", "house", "bar", "deck"],
    "good": ["luck", "news", "will", "night", "morning", "bye", "ness", "time", "looking", "faith"],
    "bad": ["luck", "news", "land", "mouth", "blood", "boy", "man", "dream", "faith", "guy"],
    "new": ["born", "comer", "paper", "stand", "year", "moon", "wave", "age", "face", "blood"],
    "old": ["timer", "man", "age", "school", "fashion", "world", "boy", "hand", "growth", "money"],
    "big": ["shot", "wig", "bang", "deal", "time", "foot", "mouth", "top", "gun", "head"],
    "small": ["talk", "pox", "time", "change", "fry", "print", "town", "scale", "holder", "minded"],
    "long": ["shot", "hand", "term", "time", "bow", "horn", "haul", "distance", "jump", "standing"],
    "short": ["cut", "hand", "cake", "bread", "fall", "stop", "age", "wave", "coming", "change"],
    "fast": ["food", "forward", "ball", "break", "track", "lane", "pitch", "back", "paced", "talk"],
    "slow": ["down", "poke", "motion", "coach", "burn", "lane", "pitch", "boat", "worm", "hand"],
    "hard": ["ball", "ware", "ship", "cover", "wood", "core", "top", "working", "copy", "line"],
    "soft": ["ball", "ware", "cover", "wood", "spoken", "shell", "core", "drink", "touch", "top"],
    "black": ["board", "bird", "out", "jack", "smith", "top", "berry", "mail", "market", "list"],
    "white": ["board", "wash", "out", "cap", "fish", "house", "water", "ware", "collar", "wall"],
    "blue": ["bird", "bell", "print", "berry", "grass", "jay", "fish", "collar", "blood", "moon"],
    "red": ["wood", "head", "cap", "bird", "eye", "coat", "neck", "bone", "line", "flag"],
    "green": ["house", "light", "back", "horn", "room", "land", "ery", "wood", "belt", "ware"],
    "gold": ["fish", "mine", "smith", "field", "digger", "en", "rush", "brick", "en", "standard"],
    "silver": ["ware", "smith", "fish", "screen", "side", "back", "lining", "tongue", "bell", "fox"],
    "pack": ["age", "horse", "rat", "ice", "man", "saddle", "thread", "et", "er", "mule"],
    "tone": ["arm", "deaf", "poem", "down", "wood", "dial", "color", "quality", "cluster", "language"],
    "bird": ["house", "bath", "cage", "seed", "song", "brain", "call", "dog", "watcher", "feeder"],
    "dog": ["house", "food", "walker", "show", "park", "fight", "pound", "catcher", "watch", "sled"],
    "cat": ["fish", "walk", "nap", "nip", "bird", "call", "gut", "fight", "house", "suit"],
    "fish": ["bowl", "tank", "pond", "hook", "net", "market", "cake", "monger", "wife", "tail"],
    "horse": ["back", "power", "shoe", "race", "play", "hair", "fly", "man", "radish", "whip"],
    "cow": ["boy", "girl", "bell", "hide", "hand", "poke", "slip", "shed", "pat", "catcher"],
    "pig": ["pen", "tail", "skin", "sty", "let", "headed", "eon", "out", "fish", "weed"],
    "chicken": ["wire", "feed", "pox", "coop", "house", "wing", "breast", "leg", "soup", "salad"],
    "egg": ["shell", "plant", "nog", "head", "cup", "roll", "white", "yolk", "beater", "timer"],
    "milk": ["shake", "man", "maid", "weed", "toast", "bottle", "carton", "bar", "chocolate", "glass"],
    "bread": ["basket", "crumb", "box", "board", "fruit", "winner", "line", "knife", "maker", "stick"],
    "butter": ["fly", "milk", "cup", "cream", "scotch", "nut", "ball", "fat", "finger", "dish"],
    "cheese": ["cake", "burger", "cloth", "board", "steak", "ball", "head", "maker", "cutter", "spread"],
    "pizza": ["box", "cutter", "dough", "maker", "oven", "pan", "parlor", "pie", "place", "sauce"],
    "coffee": ["pot", "cup", "maker", "table", "shop", "bean", "cake", "break", "house", "mug"],
    "tea": ["pot", "cup", "bag", "kettle", "time", "spoon", "leaf", "party", "room", "house"],
    "wine": ["glass", "cellar", "bottle", "bar", "rack", "list", "maker", "tasting", "cooler", "red"],
    "beer": ["bottle", "can", "mug", "glass", "garden", "gut", "hall", "belly", "pong", "mat"],
    "chair": ["lift", "man", "woman", "back", "leg", "rail", "person", "side", "arm", "seat"],
    "desk": ["top", "lamp", "chair", "job", "work", "clerk", "bound", "pad", "set", "drawer"],
    "lamp": ["shade", "post", "light", "stand", "black", "wick", "oil", "base", "holder", "chimney"],
    "light": ["house", "bulb", "weight", "ship", "ning", "beam", "year", "head", "ning", "post"],
    "dark": ["room", "ness", "horse", "side", "web", "matter", "cloud", "age", "en", "skin"],
    "work": ["shop", "place", "load", "out", "book", "day", "force", "man", "bench", "horse"],
    "play": ["ground", "time", "house", "room", "book", "thing", "mate", "boy", "pen", "date"],
    "show": ["room", "case", "time", "down", "boat", "place", "man", "girl", "stopper", "biz"],
    "movie": ["star", "theater", "goer", "maker", "script", "buff", "house", "land", "set", "premiere"],
    "music": ["box", "room", "stand", "hall", "lover", "maker", "man", "teacher", "theory", "video"],
    "song": ["bird", "book", "writer", "fest", "stress", "ster", "land", "smith", "craft", "cycle"],
    "dance": ["floor", "hall", "partner", "step", "card", "band", "class", "club", "lesson", "move"],
    "art": ["work", "ist", "gallery", "show", "room", "class", "school", "form", "board", "piece"],
    "gift": ["card", "shop", "wrap", "bag", "box", "basket", "certificate", "giving", "set", "tag"],
    "price": ["tag", "list", "cut", "war", "point", "range", "drop", "hike", "fix", "gouging"],
    "sale": ["price", "tax", "man", "person", "pitch", "room", "slip", "clerk", "force", "woman"],
    "store": ["front", "room", "house", "keeper", "wide", "bought", "brand", "owner", "manager", "clerk"],
    "shop": ["keeper", "lift", "ping", "talk", "floor", "girl", "worn", "front", "owner", "class"],
    "market": ["place", "price", "share", "value", "basket", "day", "garden", "rate", "town", "research"],
    "money": ["bag", "box", "maker", "market", "order", "lender", "back", "belt", "clip", "grubber"],
    "bank": ["account", "book", "card", "note", "roll", "er", "rupt", "loan", "teller", "vault"],
    "check": ["book", "list", "mark", "point", "up", "out", "mate", "room", "sum", "off"],
    "credit": ["card", "line", "score", "limit", "union", "report", "rating", "check", "crunch", "risk"],
    "cash": ["box", "flow", "register", "back", "cow", "crop", "desk", "machine", "out", "payment"],
    "tax": ["return", "cut", "payer", "free", "rate", "man", "break", "law", "shelter", "base"],
    "job": ["site", "hunt", "seeker", "market", "share", "less", "holder", "lot", "offer", "fair"],
    "boss": ["man", "lady", "ship", "ism", "like", "dom", "es", "hood", "ing", "y"],
}


def build_corpus_bigrams(phrases):
    """Build bigram index from phrase bank itself."""
    bigram_index = defaultdict(set)
    for p in phrases:
        w1 = p["word1"].lower()
        w2 = p["word2"].lower()
        if w1 and w2:
            bigram_index[w1].add(w2)
    return bigram_index


def calculate_ces(word1, word2, corpus_bigrams):
    """
    Calculate CES for a phrase.

    CES = count of alternatives starting with same letter as word2
    that are also high-frequency pairings with word1.
    """
    word1 = word1.lower()
    word2 = word2.lower()

    if not word2:
        return 1

    target_letter = word2[0]

    # Get all known bigrams for word1
    known = set(KNOWN_BIGRAMS.get(word1, []))
    corpus = corpus_bigrams.get(word1, set())
    all_options = known | corpus

    # Count alternatives with same first letter
    same_letter_options = [w for w in all_options if w and w[0] == target_letter]

    # CES is the count (minimum 1)
    ces = max(1, len(same_letter_options))

    return ces


def process_phrases():
    """Process all phrases and calculate CES."""
    # Read master file
    phrases = []
    with open(MASTER_FILE, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            phrases.append(row)

    print(f"Loaded {len(phrases)} phrases from master file")

    # Build corpus bigrams
    corpus_bigrams = build_corpus_bigrams(phrases)
    print(f"Built bigram index with {len(corpus_bigrams)} word1 entries")

    # Calculate CES for each phrase
    ces_distribution = defaultdict(int)
    for p in phrases:
        ces = calculate_ces(p["word1"], p["word2"], corpus_bigrams)
        p["CES_estimate"] = ces
        ces_distribution[ces] += 1

    # Write output
    fieldnames = list(phrases[0].keys())
    with open(OUTPUT_FILE, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for p in phrases:
            writer.writerow(p)

    print(f"\nWrote {len(phrases)} phrases to {OUTPUT_FILE}")

    # Print distribution
    print("\nCES Distribution:")
    for ces in sorted(ces_distribution.keys()):
        count = ces_distribution[ces]
        pct = count / len(phrases) * 100
        bar = "#" * int(pct / 2)
        print(f"  CES={ces}: {count:4d} ({pct:5.1f}%) {bar}")

    # Flag high-CES phrases
    high_ces_phrases = [p for p in phrases if int(p["CES_estimate"]) > 3]
    print(f"\n{len(high_ces_phrases)} phrases with CES > 3 (late-game only):")
    for p in high_ces_phrases[:20]:
        print(f"  {p['phrase']} (CES={p['CES_estimate']})")

    return phrases


if __name__ == "__main__":
    process_phrases()
