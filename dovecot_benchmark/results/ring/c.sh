#!/bin/bash

MOUNTPOINT=/mnt/dovecot

mkdir -p $MOUNTPOINT/$1
chown doveusers:doveusers $MOUNTPOINT/$1
