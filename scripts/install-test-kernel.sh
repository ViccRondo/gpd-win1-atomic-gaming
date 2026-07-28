#!/usr/bin/bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: sudo ./scripts/install-test-kernel.sh RPM_DIRECTORY [--reboot]

Atomically replace the Fedora kernel with the GPD Win 1 test build.
The current deployment remains available for rollback.
EOF
}

if [[ ${EUID} -ne 0 ]]; then
    echo "Run this installer with sudo." >&2
    exit 1
fi

if [[ $# -lt 1 || $# -gt 2 ]]; then
    usage >&2
    exit 2
fi

rpm_dir=$1
reboot_after=false
if [[ ${2:-} == --reboot ]]; then
    reboot_after=true
elif [[ $# -eq 2 ]]; then
    usage >&2
    exit 2
fi

if [[ ! -d $rpm_dir ]]; then
    echo "RPM directory does not exist: $rpm_dir" >&2
    exit 1
fi

required=(
    kernel
    kernel-core
    kernel-modules
    kernel-modules-core
    kernel-modules-extra
)
declare -A selected=()

shopt -s nullglob
for rpm_file in "$rpm_dir"/*.rpm; do
    package_name=$(rpm -qp --qf '%{NAME}' "$rpm_file")
    for required_name in "${required[@]}"; do
        if [[ $package_name == "$required_name" ]]; then
            if [[ -n ${selected[$required_name]:-} ]]; then
                echo "More than one $required_name RPM was found." >&2
                exit 1
            fi
            selected[$required_name]=$rpm_file
        fi
    done
done

rpms=()
for required_name in "${required[@]}"; do
    rpm_file=${selected[$required_name]:-}
    if [[ -z $rpm_file ]]; then
        echo "Missing $required_name RPM in $rpm_dir." >&2
        exit 1
    fi
    version=$(rpm -qp --qf '%{VERSION}-%{RELEASE}' "$rpm_file")
    if [[ $version != *win1* ]]; then
        echo "Refusing non-Win1 test package: $rpm_file" >&2
        exit 1
    fi
    rpms+=("$rpm_file")
done

echo "Staging atomic kernel replacement:"
rpm -qp --qf '  %{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}\n' "${rpms[@]}"
rpm-ostree override replace "${rpms[@]}"

echo
echo "The test kernel is staged. The current deployment remains the rollback entry."
echo "Rollback command: sudo rpm-ostree rollback"

if $reboot_after; then
    systemctl reboot
else
    echo "Reboot when ready: sudo systemctl reboot"
fi

