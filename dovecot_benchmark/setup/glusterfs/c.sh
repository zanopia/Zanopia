#!/bin/bash

MOUNTPOINT=/mnt/glusterfs

mkdir -p $MOUNTPOINT/$1
chown doveusers:doveusers $MOUNTPOINT/$1
