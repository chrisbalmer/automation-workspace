# Automation Workspace

This is a container that is setup with the tools I use regularly for automation work so my workspace is identical across systems. 

## Function for Launching

Add this to your `.zshrc` or other profile:

```
function workspace() {
    dirname=${PWD##*/}
    docker run --rm -it --entrypoint=/bin/zsh -v ~/.ssh/:/root/.ssh/ -v `pwd`:/${dirname} -w /${dirname} chrisbalmer/automation-workspace:latest
}
```