#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf install -y kitty

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging
 
dnf -y copr enable yalter/niri
dnf -y install niri

dnf -y copr enable alternateved/keyd
dnf -y install keyd

echo <<EOF
[ids]

*

[main]
rightalt = layer(movement)

[movement:G]
h = left
k = up
j = down
l = right
enter = leftmouse
backspace = rightmouse
EOF | sudo tee /etc/keyd/default.conf

#### Example for enabling a System Unit File

systemctl enable podman.socket

#### Enabling biometric unlock for the Bitwarden Flatpak
# Based on instructions from: https://bitwarden.com/help/biometrics/#tab-linux-2vCWb5iFg4OqKS0B2xXpqW
echo <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE policyconfig PUBLIC
 "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN"
 "http://www.freedesktop.org/standards/PolicyKit/1.0/policyconfig.dtd">

<policyconfig>
    <action id="com.bitwarden.Bitwarden.unlock">
      <description>Unlock Bitwarden</description>
      <message>Authenticate to unlock Bitwarden</message>
      <defaults>
        <allow_any>no</allow_any>
        <allow_inactive>no</allow_inactive>
        <allow_active>auth_self</allow_active>
      </defaults>
    </action>
</policyconfig>
EOF | sudo tee /usr/share/polkit-1/actions/com.Bitwarden.policy && \
  sudo chown root:root /usr/share/polkit-1/actions/com.Bitwarden.policy && \
  sudo chcon system_u:object_r:usr_t:s0

