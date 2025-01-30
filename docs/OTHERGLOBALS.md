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
- `betterUI:uniqueName()` - Generates a 7 character long unique name.
- `betterUI:targetFps(n)` - Sets target FPS.
> Warning for `targetFps`:
- Sometimes it doesn't work properly and I have no idea why.
