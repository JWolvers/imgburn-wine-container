#!/bin/bash
set -x

# Define globals
download_url="https://download.imgburn.com/SetupImgBurn_2.5.8.0.exe"
exe_location="${WINEPREFIX}dosdevices/c:/Program Files (x86)/ImgBurn/ImgBurn.exe"
install_exe_path="${WINEPREFIX}dosdevices/c:/"
log_file="${WINEPREFIX}dosdevices/c:/imgburn-wine-startapp.log"

export WINEARCH="win64"
export WINEDLLOVERRIDES="mscoree=" # Disable Mono installation

log_message() {
    echo "$(date): $1" >> "$log_file"
}

# Pre-initialize Wine
if [ ! -f "${WINEPREFIX}system.reg" ]; then
    echo "WINE: Wine not initialized, initializing"
    wineboot -i
    log_message "WINE: Initialization done"
fi

#Configure Extra Mounts
for x in {d..z}
do
    if test -d "/drive_${x}" && ! test -d "${WINEPREFIX}dosdevices/${x}:"; then
        log_message "DRIVE: drive_${x} found but not mounted, mounting..."
        ln -s "/drive_${x}/" "${WINEPREFIX}dosdevices/${x}:"
    fi
done

# Set Virtual Desktop
cd $WINEPREFIX
if [ "$DISABLE_VIRTUAL_DESKTOP" = "true" ]; then
    log_message "WINE: DISABLE_VIRTUAL_DESKTOP=true - Virtual Desktop mode will be disabled"
    winetricks vd=off
else
    # Check if width and height are defined
    if [ -n "$DISPLAY_WIDTH" ] && [ -n "$DISPLAY_HEIGHT" ]; then
    log_message "WINE: Enabling Virtual Desktop mode with $DISPLAY_WIDTH:$DISPLAY_WIDTH aspect ratio"
    winetricks vd="$DISPLAY_WIDTH"x"$DISPLAY_HEIGHT"
    else
        # Default aspect ratio
        log_message "WINE: Enabling Virtual Desktop mode with recommended aspect ratio"
        winetricks vd="900x700"
    fi
fi

# Function to handle errors
handle_error() {
    echo "Error: $1" >> "$log_file"
    start_app # Start app even if there is a problem with the updater
}

fetch_and_install() {
    #Go to install_exe_path
    cd "$install_exe_path" || handle_error "INSTALLER: can't navigate to $install_exe_path"

    #Download the installer
    log_message "INSTALLER: downloading installer"
    curl -L "${download_url}" --output "install_imgburn.exe"
    log_message "INSTALLER: Starting install_imgburn.exe"
    WINEARCH="$WINEARCH" WINEPREFIX="$WINEPREFIX" wine64 "install_imgburn.exe" || handle_error "INSTALLER: Failed to install ImgBurn"
}

start_app() {
    log_message "STARTAPP: Starting ImgBurn"
    wine64 "${exe_location}" &
    sleep infinity
}

if [ -f "${exe_location}" ]; then
    start_app # start app
else # Client currently not installed
    fetch_and_install &&
    start_app
fi
