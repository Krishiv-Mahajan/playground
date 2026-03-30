#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_SETUP="${SCRIPT_DIR}/../common-setup.sh"

if [ ! -f "${COMMON_SETUP}" ]; then
	echo "common-setup.sh not found at ${COMMON_SETUP}"
	exit 1
fi

# Source common setup functions and variables
source "${COMMON_SETUP}"

# Setup kubectl environment
setupKubectl

# Generate configuration scripts and files
installKind
createCluster
cluster1Config
cluster2Config
copyConfigFilesToNode

# Create clusters on remote node
createMemberClusters

# clean screen
clear
