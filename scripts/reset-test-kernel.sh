#!/usr/bin/bash
set -euo pipefail

if [[ ${EUID} -ne 0 ]]; then
    echo "Run this reset helper with sudo." >&2
    exit 1
fi

rpm-ostree override reset \
    kernel \
    kernel-core \
    kernel-modules \
    kernel-modules-core \
    kernel-modules-extra

echo "Fedora's original kernel is staged. Reboot when ready."

