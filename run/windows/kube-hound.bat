@echo off

set "command=docker run --rm -it kube-hound %*"

call %command%