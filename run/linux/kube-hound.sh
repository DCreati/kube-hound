#!/bin/bash

# Command + args
command="docker run --rm -it kube-hound $@"

# Exec complete command
eval "$command"