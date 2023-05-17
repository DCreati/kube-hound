#!/bin/bash

# Command + args
command="docker run -v /var/run/docker.sock:/var/run/docker.sock --rm -it kube-hound $@"

# Exec complete command
eval "$command"