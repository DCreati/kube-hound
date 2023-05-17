@echo off

set "command=docker run -v /var/run/docker.sock:/var/run/docker.sock --rm -it kube-hound %*"

call %command%