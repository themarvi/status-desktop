#pragma once

#include <QtCore>

namespace Status::Constants
{

const std::array SigningPhrases {
    "area", "army", "atom", "aunt", "babe", "baby", "back", "bail", "bait", "bake", "ball", "band", "bank", "barn",
    "base", "bass", "bath", "bead", "beak", "beam", "bean", "bear", "beat", "beef", "beer", "beet", "bell", "belt",
    "bend", "bike", "bill", "bird", "bite", "blow", "blue", "boar", "boat", "body", "bolt", "bomb", "bone", "book",
    "boot", "bore", "boss", "bowl", "brow", "bulb", "bull", "burn", "bush", "bust", "cafe", "cake", "calf", "call",
    "calm", "camp", "cane", "cape", "card", "care", "carp", "cart", "case", "cash", "cast", "cave", "cell", "cent",
    "chap", "chef", "chin", "chip", "chop", "chub", "chug", "city", "clam", "clef", "clip", "club", "clue", "coal",
    "coat", "code", "coil", "coin", "coke", "cold", "colt", "comb", "cone", "cook", "cope", "copy", "cord", "cork",
    "corn", "cost", "crab", "craw", "crew", "crib", "crop", "crow", "curl", "cyst", "dame", "dare", "dark", "dart",
    "dash", "data", "date", "dead", "deal", "dear", "debt", "deck", "deep", "deer", "desk", "dhow", "diet", "dill",
    "dime", "dirt", "dish", "disk", "dock", "doll", "door", "dory", "drag", "draw", "drop", "drug", "drum", "duck",
    "dump", "dust", "duty", "ease", "east", "eave", "eddy", "edge", "envy", "epee", "exam", "exit", "face", "fact",
    "fail", "fall", "fame", "fang", "farm", "fawn", "fear", "feed", "feel", "feet", "file", "fill", "film", "find",
    "fine", "fire", "fish", "flag", "flat", "flax", "flow", "foam", "fold", "font", "food", "foot", "fork", "form",
    "fort", "fowl", "frog", "fuel", "full", "gain", "gale", "galn", "game", "garb", "gate", "gear", "gene", "gift",
    "girl", "give", "glad", "glen", "glue", "glut", "goal", "goat", "gold", "golf", "gong", "good", "gown", "grab",
    "gram", "gray", "grey", "grip", "grit", "gyro", "hail", "hair", "half", "hall", "hand", "hang", "harm", "harp",
    "hate", "hawk", "head", "heat", "heel", "hell", "helo", "help", "hemp", "herb", "hide", "high", "hill", "hire",
    "hive", "hold", "hole", "home", "hood", "hoof", "hook", "hope", "hops", "horn", "hose", "host", "hour", "hunt",
    "hurt", "icon", "idea", "inch", "iris", "iron", "item", "jail", "jeep", "jeff", "joey", "join", "joke", "judo",
    "jump", "junk", "jury", "jute", "kale", "keep", "kick", "kill", "kilt", "kind", "king", "kiss", "kite", "knee",
    "knot", "lace", "lack", "lady", "lake", "lamb", "lamp", "land", "lark", "lava", "lawn", "lead", "leaf", "leek",
    "lier", "life", "lift", "lily", "limo", "line", "link", "lion", "lisa", "list", "load", "loaf", "loan", "lock",
    "loft", "long", "look", "loss", "lout", "love", "luck", "lung", "lute", "lynx", "lyre", "maid", "mail", "main",
    "make", "male", "mall", "manx", "many", "mare", "mark", "mask", "mass", "mate", "math", "meal", "meat", "meet",
    "menu", "mess", "mice", "midi", "mile", "milk", "mime", "mind", "mine", "mini", "mint", "miss", "mist", "moat",
    "mode", "mole", "mood", "moon", "most", "moth", "move", "mule", "mutt", "nail", "name", "neat", "neck", "need",
    "neon", "nest", "news", "node", "nose", "note", "oboe", "okra", "open", "oval", "oven", "oxen", "pace", "pack",
    "page", "pail", "pain", "pair", "palm", "pard", "park", "part", "pass", "past", "path", "peak", "pear", "peen",
    "peer", "pelt", "perp", "pest", "pick", "pier", "pike", "pile", "pimp", "pine", "ping", "pink", "pint", "pipe",
    "piss", "pith", "plan", "play", "plot", "plow", "poem", "poet", "pole", "polo", "pond", "pony", "poof", "pool",
    "port", "post", "prow", "pull", "puma", "pump", "pupa", "push", "quit", "race", "rack", "raft", "rage", "rail",
    "rain", "rake", "rank", "rate", "read", "rear", "reef", "rent", "rest", "rice", "rich", "ride", "ring", "rise",
    "risk", "road", "robe", "rock", "role", "roll", "roof", "room", "root", "rope", "rose", "ruin", "rule", "rush",
    "ruth", "sack", "safe", "sage", "sail", "sale", "salt", "sand", "sari", "sash", "save", "scow", "seal", "seat",
    "seed", "self", "sell", "shed", "shin", "ship", "shoe", "shop", "shot", "show", "sick", "side", "sign", "silk",
    "sill", "silo", "sing", "sink", "site", "size", "skin", "sled", "slip", "smog", "snob", "snow", "soap", "sock",
    "soda", "sofa", "soft", "soil", "song", "soot", "sort", "soup", "spot", "spur", "stag", "star", "stay", "stem",
    "step", "stew", "stop", "stud", "suck", "suit", "swan", "swim", "tail", "tale", "talk", "tank", "tard", "task",
    "taxi", "team", "tear", "teen", "tell", "temp", "tent", "term", "test", "text", "thaw", "tile", "till", "time",
    "tire", "toad", "toga", "togs", "tone", "tool", "toot", "tote", "tour", "town", "tram", "tray", "tree", "trim",
    "trip", "tuba", "tube", "tuna", "tune", "turn", "tutu", "twig", "type", "unit", "user", "vane", "vase", "vast",
    "veal", "veil", "vein", "vest", "vibe", "view", "vise", "wait", "wake", "walk", "wall", "wash", "wasp", "wave",
    "wear", "weed", "week", "well", "west", "whip", "wife", "will", "wind", "wine", "wing", "wire", "wish", "wolf",
    "wood", "wool", "word", "work", "worm", "wrap", "wren", "yard", "yarn", "yawl", "year", "yoga", "yoke", "yurt",
    "zinc", "zone"
};

}
