#!/bin/sh

python3 -m build

twine upload dist/ppersist-0.10.0-py3-none-any.whl
