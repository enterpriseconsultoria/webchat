#!/bin/bash
cd /opt/webchat/app
export DISPLAY=:1
export DISPLAY_WIDTH=1024
export DISPLAY_HEIGHT=768

screen -d -m bash -c /usr/bin/awesome&
