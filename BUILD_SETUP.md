# Build Configuration Setup

## Overview
The ComputerCraft build system uses `BuildProgramsAndPaths.lua` for configuration, which is ignored by Git to allow personal customization.

## Setup Instructions

1. Copy the template file:
   ```bash
   copy tools\BuildProgramsAndPaths.lua.template tools\BuildProgramsAndPaths.lua
   ```

2. Edit `tools/BuildProgramsAndPaths.lua` to match your local setup:
   - Update paths to point to your Minecraft save directory
   - Adjust ComputerCraft computer IDs as needed
   - Enable/disable programs using the `disabled` flag

## Configuration Format

```lua
local ProgramsAndPaths = {
    {
        program = "programs.YourProgram",
        disabled = false,  -- Set to true to build but not copy
        paths = {
            {
                path = "C:/path/to/your/computercraft/computer/X/",
                rename = "startup.lua"  -- Optional: rename the copied file
            }
        }
    }
}
```

## Why is this ignored?
- Personal paths differ between developers
- Prevents accidental commits of local configurations  
- Allows each developer to customize their deployment setup

## Building
Simply run:
```bash
lua tools/bundler.lua
```

The system will:
1. Build all programs listed in `BuildPrograms`
2. Output minified versions to `build/`
3. Output readable versions to `build/unminified/`
4. Copy programs to configured paths (unless `disabled = true`)
