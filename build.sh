#!/bin/bash
~/Apps/dhall-to-yaml-ng --file 03.yaml-source.dhall --documents  --output pods.yml
~/Apps/dhall text --file 03.scripts-source.dhall --output run.sh