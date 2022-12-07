#!/usr/bin/env bash

GEN_DIR=$(dirname "$0")/../gen

ssh -i "$GEN_DIR/id_ecdsa" -o UserKnownHostsFile="$GEN_DIR/known_hosts" root@${ip} "$@"
