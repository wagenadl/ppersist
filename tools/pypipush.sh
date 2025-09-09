#!/bin/sh

python3 -m build

twine upload dist/ppersist-0.10.1-py3-none-any.whl
