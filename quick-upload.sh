#!/usr/bin/env bash

PROJPATH=$(dirname "$0")
BITFILE=$PROJPATH/verily.bit

PAPILIO_PROG=/usr/local/bin/papilio-prog

sudo $PAPILIO_PROG -f $BITFILE

