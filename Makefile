WGET_LOG := ../wget-file
# https://docs.python.org/3/download.html
PY_ARCHIVE_WEB := https://docs.python.org/3/archives/python-3.10.0-docs-text.tar.bz2
PY_ARCHIVE_LOC := ../py_archive.tar.bz2
PY_DOC_LOC := ../python-docs-test
UNIQUE_WORDS := unique_words
ROW_WORDS := row_words

help: # Use `make help` to see targets-doc-string.
	@grep -E '^[ a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

pyenv: ## See all the available CPython 3.10.* through 3.11.* .
	$@ install --list | grep " 3\.1[01]"

download-python-documentaion: ## Download Plain Text.
	wget -o $(WGET_LOG) -P .. -O $(PY_ARCHIVE_LOC) $(PY_ARCHIVE_WEB)

untar: ## tar extract verbose bzip2 $(PY_ARCHIVE_LOC).
	mkdir -p $(PY_DOC_LOC) && tar -xvjf $(PY_ARCHIVE_LOC) --directory $(PY_DOC_LOC)

dw: download-python-documentaion untar ## Download CPython documentation and untar its.

clean-words: ## Clear $(UNIQUE_WORDS).
	@truncate -s 0 $(UNIQUE_WORDS)

generate-unique-words: clean-words ## To only print each word once, disregarding case.
	@grep --recursive --no-filename --extended-regexp '\w+' $(PY_DOC_LOC) \
	| tr -sc 'A-Za-z' '\n' \
	| LC_ALL=C sort --unique --ignore-case >> $(UNIQUE_WORDS)

gen: generate-unique-words ## generate-unique-words alias.

generate-row-words: ## Generate all words with file names.
	@truncate -s 0 $(ROW_WORDS) \
	&& grep --recursive --extended-regexp '\w+' $(PY_DOC_LOC) \
	| LC_ALL=C sort --unique --ignore-case >> $(ROW_WORDS)

gen-all: ## make generate-row-words generate-unique-words.
	make -j2 generate-row-words generate-unique-words

dw-gen: dw gen-all ## make dw gen-all.
