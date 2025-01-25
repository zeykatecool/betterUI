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