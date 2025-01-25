# Other Globals for using BetterUI

## Event Object
- You can use **Event** object for easy event handling and interact with elements.
- Some events are embedded to BetterUI with `Enum.EmbeddedEvents`.
```lua
    Event:onFire(Enum.EmbeddedEvents.windowOnResize, function(width,height)
        print("Window resized to " .. width .. "x" .. height)
    end)

    Event:onFire(Enum.EmbeddedEvents.windowOnKey, function(key)
        if key == "VK_ESCAPE" then
            betterUI:kill() --Kills all objects,including window.
        end
    end)

    -- Custom event example:
    Event:onFire("myEvent", function(data)
        print(data)
    end)

    Event:fire("myEvent","Hello")
```

## BetterUI Object
- You can use **betterUI** object for easy use of BetterUI.

- `betterUI:kill()` - Kills all objects,including window.
- `betterUI:addToUpdate(f)` - Adds a function to update loop.
- `betterUI:uniqueName()` - Generates a 7 character long unique name.
- `betterUI:targetFps(n)` - Sets target FPS.
> Depends on LuaRT 1.9.0 (or higher),default (LuaRT 1.8.0) is 60 and can not be changed.Also LuaRT 1.9.0* has a bug that effects Canvas module so it can't be used. <sub>*LuaRT 1.9.0 Oct 28, 2024 [Github](https://github.com/samyeyo/LuaRT/releases/tag/v1.9.0-preview)</sub>