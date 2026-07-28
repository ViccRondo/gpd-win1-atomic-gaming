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
optional_pins=(
    gamescope
    wlroots0.18
)

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
    for optional_name in "${optional_pins[@]}"; do
        if [[ $package_name == "$optional_name" ]]; then
            if [[ -n ${selected[$optional_name]:-} ]]; then
                echo "More than one $optional_name RPM was found." >&2
                exit 1
            fi
            selected[$optional_name]=$rpm_file
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

transaction_options=()
gamescope_rpm=${selected[gamescope]:-}
wlroots_rpm=${selected[wlroots0.18]:-}
if [[ -n $gamescope_rpm || -n $wlroots_rpm ]]; then
    if [[ -z $gamescope_rpm || -z $wlroots_rpm ]]; then
        echo "Both gamescope and wlroots0.18 pin RPMs are required." >&2
        exit 1
    fi
    echo "Pinning the validated gaming-session baseline:"
    rpm -qp --qf '  %{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}\n' \
        "$gamescope_rpm" "$wlroots_rpm"
    transaction_options+=(
        --uninstall=gamescope
        "--install=$gamescope_rpm"
        "--install=$wlroots_rpm"
    )
fi

rpm-ostree override replace "${transaction_options[@]}" "${rpms[@]}"

echo
echo "The test kernel is staged. The current deployment remains the rollback entry."
echo "Rollback command: sudo rpm-ostree rollback"

if $reboot_after; then
    systemctl reboot
else
    echo "Reboot when ready: sudo systemctl reboot"
fi
