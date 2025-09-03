#!/bin/bash

# Define the laptop screen output name
LAPTOP_SCREEN="eDP"

# Define the target refresh rate
TARGET_REFRESH_RATE="60.00"

# Find the battery device using upower
BATTERY_DEVICE=$(upower -e | grep 'BAT')

# Get the battery state
BATTERY_STATE=$(upower -i "$BATTERY_DEVICE" | grep "state" | awk '{print $2}')

# Check if the battery is discharging
if [ "$BATTERY_STATE" = "discharging" ]; then
    echo "Battery is discharging. Lowering refresh rate on $LAPTOP_SCREEN to $TARGET_REFRESH_RATE Hz."

    # Find the mode for the 60Hz refresh rate
    MODE_60HZ=$(xrandr | grep -A 10 "$LAPTOP_SCREEN" | grep "$TARGET_REFRESH_RATE" | awk '{print $1}' | head -n 1)

    # Check if a 60Hz mode was found
    if [ -n "$MODE_60HZ" ]; then
        xrandr --output eDP --mode 2560x1600 --rate 60
        echo "Refresh rate successfully set to $TARGET_REFRESH_RATE Hz."
    else
        echo "Could not find a $TARGET_REFRESH_RATE Hz mode for $LAPTOP_SCREEN."
    fi

# If the battery is charging or full, set the highest refresh rate
elif [ "$BATTERY_STATE" = "charging" ] || [ "$BATTERY_STATE" = "full" ]; then
    echo "Battery is charging or full. Setting highest refresh rate on $LAPTOP_SCREEN."

    # Find the highest refresh rate mode for the laptop screen (indicated by '*')
    HIGHEST_MODE=$(xrandr | grep -A 10 "$LAPTOP_SCREEN" | grep '*' | awk '{print $1}')
    
    if [ -n "$HIGHEST_MODE" ]; then
        xrandr --output eDP --mode 2560x1600 --rate 240
        echo "Refresh rate successfully set to highest available."
    fi
fi