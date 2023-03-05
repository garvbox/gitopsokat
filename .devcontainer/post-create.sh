#!/usr/bin/env bash
set -ex

# Set up Pre-commit
pip3 install pre-commit
pre-commit install --install-hooks

# Import SOPS Keys
for f in $(find ./ -name .sops.pub.asc); do
    echo "Importing from ${f}"
    gpg --import $f
done
