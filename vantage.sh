#!/bin/bash

#Requirement: zenity, xinput, networkmanager, pulseaudio or pipewire-pulse
#Authors: Nizam (nizam@europe.com), Lanchon (https://github.com/Lanchon)

VPC="/sys/bus/platform/devices/VPC2004\:*"

get_conservation_mode_status() {
    cat $VPC/conservation_mode | awk '{print ($1 == "1") ? "On" : "Off"}'
}

get_usb_charging_status() {
    cat $VPC/usb_charging | awk '{print ($1 == "1") ? "On" : "Off"}'
}

SUBMENU_ON="Activate"
SUBMENU_OFF="Deactivate"

show_submenu() {
    local title="$1"
    local status="$2"
    zenity --list --title "$title" --text "Status: $status" --column "Menu" "${@:3}"
}

show_submenu_on_off() {
    show_submenu "$@" "$SUBMENU_ON" "$SUBMENU_OFF"
}

main() {
    while :; do
        local options=()
        test -f $VPC/conservation_mode && options+=("Conservation Mode" "$(get_conservation_mode_status)")
        test -f $VPC/usb_charging && options+=("Always-On USB" "$(get_usb_charging_status)")

        local menu="$(zenity --list --title "Lenovo Vantage" --text "Select function:" --column "Function" --column "Status" "${options[@]}" --height 340 --width 350)"
        case "$menu" in
            "Conservation Mode")
                local submenu="$(show_submenu_on_off "Conservation Mode" "$(get_conservation_mode_status)")"
                case "$submenu" in
                    "$SUBMENU_ON") echo "1" | pkexec tee $VPC/conservation_mode ;;
                    "$SUBMENU_OFF") echo "0" | pkexec tee $VPC/conservation_mode ;;
                esac
                ;;
            "Always-On USB")
                local submenu="$(show_submenu_on_off "Always-On USB" "$(get_usb_charging_status)")"
                case "$submenu" in
                    "$SUBMENU_ON") echo "1" | pkexec tee $VPC/usb_charging ;;
                    "$SUBMENU_OFF") echo "0" | pkexec tee $VPC/usb_charging ;;
                esac
                ;;
            *)
                break
                ;;
        esac
    done
}

main "$@"

