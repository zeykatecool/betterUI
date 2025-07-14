# Coloring

## Using Color Object
- You can use **Color** object for easy use of colors.
##
- `Color.fromRGBA(R,G,B,A)`
- `Color.fromHEX("#RRGGBBAA")`

### Color Example
```lua
require("betterUI")

local Win = Window{
    name = "BetterUI";
    x = 0;
    y = 0;
    width = 300;
    height = 300;
    style = Enum.WindowStyle.Fixed;
    visible = true;
    bgcolor = Color.fromRGBA(119, 136, 153, 255);-- or Color.fromHEX("#778899FF"); -- LightSlateGray ,Transparency 0
}
Win:center()

Update(function(dt)
    local fps = math.floor(1 / dt)
    Win:status("FPS: " .. fps)
end)
```

## Using Brush Object
- **Brush** is a bit different from **Color** object,you can use it for creating Gradients.
##
- `Brush.newRadialGradient(GradientTable,CenterPositionTable,RadiusPositionTable,Opacity)`
- `Brush.newLinearGradient(GradientTable,StartPositionTable,StopPositionTable,Opacity)`

### LinearGradient Example:
```lua
require("betterUI")
function print(...)
    require("console").writeln(...)
end

local Win = Window{
    name = "BetterUI";
    x = 0;
    y = 0;
    width = 300;
    height = 300;
    style = Enum.WindowStyle.Fixed;
    visible = true;
    bgcolor = "#000000FF";
}
Win:center()

local brush = Brush.newLinearGradient({[0] = Color.fromHEX("#FF0000FF"), [1] = Color.fromHEX("#00FF00FF")}, {0,0}, {Win.width,Win.height}, 1)

local label = Label{
    x = 10;
    y = 0;
    textcolor = brush;
    font = "Arial";
    fontsize = 35;
    fontweight = 400;
    visible = true;
    text = "BetterUI Example";
}

label:center()

Update(function(dt)
    local fps = math.floor(1 / dt)
    Win:status("FPS: " .. fps)
end)
```

### RadialGradient Example:
```lua
require("betterUI")

local Win = Window{
    name = "BetterUI";
    x = 0;
    y = 0;
    width = 300;
    height = 300;
    style = Enum.WindowStyle.Fixed;
    visible = true;
    bgcolor = "#000000FF";
}
Win:center()

local brush = Brush.newRadialGradient({[0] = Color.fromHEX("#FF0000FF"), [1] = Color.fromHEX("#00FF00FF")},{0,0},{300,600},1)

local label = Label{
    x = 10;
    y = 0;
    textcolor = brush;
    font = "Arial";
    fontsize = 35;
    fontweight = 400;
    visible = true;
    text = "BetterUI Example";
}

label:center()

Update(function(dt)
    local fps = math.floor(1 / dt)
    Win:status("FPS: " .. fps)
end)
```

### Window Transparency via C Module
- It's a function for `Window` element.
```lua
    --[[
    function window:makeTransparency()
        local C = require("c")
        local bit32 = require("bit32")
        local user32 = C.Library("user32.dll")
        user32.FindWindowA = "(ZZ)p"
        user32.GetWindowLongA = "(pi)i"
        user32.SetWindowLongA = "(pii)i"
        user32.SetLayeredWindowAttributes = "(piCi)i"

        --thank god this is the correct ones
        local GWL_EXSTYLE = -20
        local WS_EX_LAYERED = 0x80000
        local LWA_COLORKEY = 0x1
        local HWND = user32.FindWindowA(nil, window.title)

        if HWND ~= nil then
            local style = user32.GetWindowLongA(HWND, GWL_EXSTYLE)
            user32.SetWindowLongA(HWND, GWL_EXSTYLE, bit32.bor(style, WS_EX_LAYERED))
            user32.SetLayeredWindowAttributes(HWND, 0x000000, 255, LWA_COLORKEY)
        else
            error("Window name is wrong,this is weird.")
        end
    end
    ]]--

    window:makeTransparency() -- Makes the Window transparent,not the elements. Works best with `Raw` Window's.

```
