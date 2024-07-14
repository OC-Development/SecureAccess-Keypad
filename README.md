Join Our Community
For support, updates, and to connect with other users, join our Discord server: OC-Development https://discord.gg/equZQCgM


# FiveM Keypad Script

## Overview

This FiveM script allows server administrators to place multiple keypad props at specified locations within the game. Players can interact with these keypads to enter a password, which can trigger various events. The script includes configurable locations, animations, and a user-friendly NUI interface for entering the password.

## Features

- Configurable keypad locations using `vector4` coordinates.
- Password-protected interaction with keypads.
- Customizable password.
- Smooth animations when interacting with keypads.
- NUI interface for entering passwords.
- Automatic keypad spawning on resource start.
- Easily integrate with other scripts for additional functionalities (e.g., heists, secret doors).

## Requirements

- FiveM Server
- Basic knowledge of installing FiveM scripts

## Installation

1. **Download the Script**: Download the script files and extract them to your FiveM server's `resources` directory.

2. **Config File**: Edit the `config.lua` file to specify your desired keypad locations.

    ```lua
    -- config.lua
    Config = {}

    Config.KeypadLocations = {
        vector4(123.4, 456.7, 789.0, 0.0),
        vector4(223.4, 556.7, 889.0, 90.0),
        -- Add more locations as needed
    }
    ```

3. **Add to Server Configuration**: Add the resource to your `server.cfg` file.

    ```cfg
    ensure SecureAccess-Keypad
    ```

4. **Start the Server**: Start your FiveM server to load the script.

## Usage

### Commands

- **`/useExternalKeypad`**: Example command to use the exported `useKeypad` function with an external password.

### Example Command

```lua
RegisterCommand('useExternalKeypad', function()
    local password = "5555"
    exports["SecureAccess-Keypad"]:useKeypad(password, function(result)
        if result then
            print("Password correct!")
        else
            print("Password incorrect!")
        end
    end)
end, false)
