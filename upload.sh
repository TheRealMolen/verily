#!/usr/bin/env bash

PROJPATH=$(dirname "$0")
BITFILE=$PROJPATH/verily.bit

PAPILIO_PROG=/usr/local/bin/papilio-prog
SPI_BITFILE=/opt/GadgetFactory/papilio-loader/programmer/bscan_spi_xc3s500e.bit

sudo $PAPILIO_PROG -v -f $BITFILE -b $SPI_BITFILE -sa -r
sudo $PAPILIO_PROG -c

