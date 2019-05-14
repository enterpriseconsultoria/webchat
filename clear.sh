#!/bin/bash

if [ -z $1 ]; then
PTH="/opt/webchat/app/"
else
PTH=$1
fi

cd $PTH"chatapp/utils"
for i in $(ls *.py | grep -v __init__.py| sed "s/.py//g" ); do
rm $i.py* $i.c
done

cd $PTH"chatapp/management/commands/"
for i in $(ls *.py | grep -v __init__.py| sed "s/.py//g" ); do
rm $i.py* $i.c
done

cd $PTH"chatapp"
for i in $(ls *.py | grep -v __init__.py| sed "s/.py//g" ); do
rm $i.py* $i.c
done


