YELLOW := "\e[1;33m"
NC := "\e[0m"
INFO := @bash -c 'printf $(YELLOW); echo "=> $$1"; printf $(NC)' MESSAGE

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
	${INFO} "$(PY_ARCHIVE_WEB) downloading..."
	@wget -o $(WGET_LOG) -P .. -O $(PY_ARCHIVE_LOC) $(PY_ARCHIVE_WEB)
	${INFO} "Downloaded"

untar: ## tar extract verbose bzip2 $(PY_ARCHIVE_LOC).
	${INFO} "$(PY_ARCHIVE_LOC) extracting..."
	@mkdir -p $(PY_DOC_LOC) && tar -xvjf $(PY_ARCHIVE_LOC) --directory $(PY_DOC_LOC)
	${INFO} "Extracted"

dw: download-python-documentaion untar ## Download CPython documentation and untar its.

clean-words: ## Clear $(UNIQUE_WORDS).
	${INFO} "$(UNIQUE_WORDS),$(ROW_WORDS) clearing..."
	@truncate -s 0 $(UNIQUE_WORDS) $(ROW_WORDS)
	${INFO} "Cleared"

generate-unique-words: clean-words ## To only print each word once, disregarding case.
	${INFO} "Unique words generation..."
	@grep --recursive --no-filename --extended-regexp '\w+' $(PY_DOC_LOC) \
	| tr -sc 'A-Za-z' '\n' \
	| LC_ALL=C sort --unique --ignore-case >> $(UNIQUE_WORDS)
	${INFO} "Unique words generated"

gen: generate-unique-words ## generate-unique-words alias.

generate-row-words: clean-words ## Generate all words with file names.
	${INFO} "Row words generation..."
	@grep --recursive --extended-regexp '\w+' $(PY_DOC_LOC) \
	| LC_ALL=C sort --unique --ignore-case >> $(ROW_WORDS)
	${INFO} "Row words generated"

gen-all: ## make generate-row-words generate-unique-words.
	@make -j2 generate-row-words generate-unique-words

dw-gen: dw gen-all ## make dw gen-all.

rm: ## rm logs, result-files, tar-untar-dirs.
	${INFO} "Logs, result-files and tar-untar-dirs removing..."
	@rm -f $(WGET_LOG) $(UNIQUE_WORDS) $(README)
	@rm -rf $(PY_ARCHIVE_LOC) $(PY_DOC_LOC)
	${INFO} "Removed"

# NOTE: see https://askubuntu.com/a/668859 for more information about `-o=Dpkg::Use-Pty=0`
install: ## pip and apt-get install requirements.
	${INFO} "Packages [$$(echo $$(cat requirements_ubuntu.txt requirements.txt))] downloading..."
	@sudo apt-get update -qq -y \
	&& sudo xargs apt-get install -qq -o=Dpkg::Use-Pty=0 -y < requirements_ubuntu.txt \
	&& python3 -m venv ../.venv \
	&& ../.venv/bin/python -m pip install --quiet --upgrade pip \
	&& ../.venv/bin/pip install --quiet -r requirements.txt
	${INFO} "All packages successfully installed"

parse: ## Parse `$(UNIQUE_WORDS)` and create `english_words` file with Python.
	${INFO} "English words parsing..."
	@../.venv/bin/python parser.py
	${INFO} "Successfully parsed. $$(wc -l english_words) lines"
