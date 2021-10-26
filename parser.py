"""
Parser English words.

for "Python documentaion unique words" in `UNIQUE_WORDS_FILE`:
    Ignore Python keywords, letters, etc.
    Write "English words only" to `ENGLISH_WORDS_FILE`
"""

import keyword
import platform

import enchant

UNIQUE_WORDS_FILE = 'unique_words'
ENGLISH_WORDS_FILE = 'english_words'

PY_KEYWORDS = [kw.lower() for kw in keyword.kwlist]
print(f'Python{platform.python_version()}: {len(PY_KEYWORDS)=}')

ench_dict: enchant.Dict = enchant.Dict("en_US")

words: list[str] = []
with open(UNIQUE_WORDS_FILE) as _f:
    lines = _f.readlines()
    print(f'Python documentaion unique words: {len(lines)=}')

    for line in lines:
        word = line.lower().strip()
        english_word = ench_dict.check(word)
        python_word = word in PY_KEYWORDS
        letter = len(word) == 1
        english_word_only = all([english_word, not python_word, not letter])

        if english_word_only:
            words.append(f'{word}\n')

    print(f'English words only: {len(words)=}')

    with open(ENGLISH_WORDS_FILE, 'w') as f:
        f.writelines(words)

# $ python3 parser.py
# Python3.11.0a1+: len(PY_KEYWORDS)=35
# Python documentaion unique words: len(lines)=<LENGTH_UNIQUE_WORDS>
# English words only: len(words)=<LENGTH_ENGLISH_WORDS>
