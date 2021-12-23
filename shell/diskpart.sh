#!/bin/bash

## pve4
## be sure to do --zap-all (not just --zap) to remove GPT ~AND~ MBR stuff

sgdisk /dev/sda --zap-all
