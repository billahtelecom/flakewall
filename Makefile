PY = python3
VENV = .venv
PIP = $(VENV)/bin/pip
CLI = $(VENV)/bin/flakewall

.PHONY: venv install dev clean build test lint demo

venv:
	$(PY) -m venv $(VENV)
	$(PIP) install --upgrade pip

install: venv
	$(PIP) install -e .

dev: venv
	$(PIP) install -e .[dev]

build:
	$(PY) -m build

publish:
	$(PY) -m twine upload dist/*

test:
	$(VENV)/bin/pytest -q

demo: install
	$(CLI) --help

clean:
	rm -rf $(VENV) dist build *.egg-info


