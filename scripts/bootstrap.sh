#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# FILE: bootstrap.sh
# DESCRIPTION: Advanced bootstrap script to install your Capima boxes
# AUTHOR: Toan Nguyen (capima [at] nntoan [dot] com)
# VERSION: 1.0.0
# ------------------------------------------------------------------------------
set -e

while getopts "s:p:b:z:" opt; do
    case "$opt" in
        s)
          sudo_nopasswd="$OPTARG" ;;
        p)
          default_php="$OPTARG" ;;
        b)
          install_omb="$OPTARG" ;;
        z)
          install_omz="$OPTARG" ;;
    esac
done

# Default user vars
user="vagrant"
cpm_user="capima"
homedir=$(getent passwd $user | cut -d ':' -f6)

if [[ ! -f "$homedir"/.cpm_done ]]; then
  # Resize
  sudo resize2fs /dev/sda1

  # Install Capima
  export DEBIAN_FRONTEND=noninteractive; echo 'Acquire::ForceIPv4 "true";' | sudo tee /etc/apt/apt.conf.d/99force-ipv4; sudo apt-get update; sudo apt-get install curl netcat-openbsd ca-certificates wget -y; curl -4 --silent --location https://capima.nntoan.com/files/installers/install.sh | sudo bash -; export DEBIAN_FRONTEND=newt

  echo "$(date)" > "$homedir/.cpm_done"
  sudo chown $user:$user "$homedir/.cpm_done"
fi

if [[ -f "$homedir/.ssh/authorized_keys" ]]; then
  echo "Copying SSH keys..."
  cpm_homedir=$(getent passwd $cpm_user | cut -d ':' -f6)
  sudo mkdir -p "$cpm_homedir/.ssh" > ~/.log_ssh
  sudo cp "$homedir/.ssh/authorized_keys" "$cpm_homedir/.ssh/authorized_keys" >> ~/.log_ssh
  sudo chown -Rf $cpm_user:$cpm_user "$cpm_homedir/.ssh" >> ~/.log_ssh
fi