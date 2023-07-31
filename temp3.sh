#!/bin/bash

if ! command -v yq >/dev/null 2>&1 || ! type yq >/dev/null 2>&1 || ! hash yq 2>/dev/null; then
  echo "yq è necessario per continuare"
  sudo snap install yq
fi
