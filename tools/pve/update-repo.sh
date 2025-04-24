#!/usr/bin/env bash

# Copyright (c) 2021-2025 Lutzi1112/ProxmoxVEVE
# Author: MickLesk
# License: MIT
# https://github.com/Lutzi1112/ProxmoxVE/raw/main/LICENSE

function header_info {
  clear
  cat <<"EOF"
   __  __          __      __          ____                 
  / / / /___  ____/ /___ _/ /____     / __ \___  ____  ____ 
 / / / / __ \/ __  / __ `/ __/ _ \   / /_/ / _ \/ __ \/ __ \
/ /_/ / /_/ / /_/ / /_/ / /_/  __/  / _, _/  __/ /_/ / /_/ /
\____/ .___/\__,_/\__,_/\__/\___/  /_/ |_|\___/ .___/\____/ 
    /_/                                      /_/            
1234


EOF
}

set -eEuo pipefail
BL=$(echo "\033[36m")
RD=$(echo "\033[01;31m")
GN=$(echo "\033[1;92m")
CL=$(echo "\033[m")

header_info
echo "Loading..."
NODE=$(hostname)

old="Lutzi1112/ProxmoxVEVE"
new="Lutzi1112/ProxmoxVE"

function update_container() {
  container=$1
  os=$(pct config "$container" | awk '/^ostype/ {print $2}')

  if [[ "$os" == "ubuntu" || "$os" == "debian" ]]; then
    echo -e "${BL}[Info]${GN} Checking /usr/bin/update in ${BL}$container${CL} (OS: ${GN}$os${CL})"

    if pct exec "$container" -- [ -e /usr/bin/update ]; then
      #if pct exec "$container" -- grep -q "$old" /usr/bin/update; then
      #  echo -e "${RD}[No Change]${CL} /usr/bin/update is already up to date in ${BL}$container${CL}.\n"
      if pct exec "$container" -- grep -q -v "$old" /usr/bin/update; then
        echo -e "${RD}[Warning]${CL} /usr/bin/update in ${BL}$container${CL} contains a different entry (${RD}$old${CL}). No changes made.\n"
      else
        pct exec "$container" -- bash -c "sed -i 's/$old\\/Proxmox/Lutzi1112\\/$new/g' /usr/bin/update"

        if pct exec "$container" -- grep -q "$new" /usr/bin/update; then
          echo -e "${GN}[Success]${CL} /usr/bin/update updated in ${BL}$container${CL}.\n"
        else
          echo -e "${RD}[Error]${CL} /usr/bin/update in ${BL}$container${CL} could not be updated properly.\n"
        fi
      fi
    else
      echo -e "${RD}[Error]${CL} /usr/bin/update not found in container ${BL}$container${CL}.\n"
    fi
  else
    echo -e "${BL}[Info]${GN} Skipping ${BL}$container${CL} (not Debian/Ubuntu)\n"
  fi
}

header_info
for container in $(pct list | awk '{if(NR>1) print $1}'); do
  update_container "$container"
done

header_info
echo -e "${GN}The process is complete. The repositories have been switched to $new.${CL}\n"
