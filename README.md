# BetterUI for LuaRT
- This module is made for making better elements for [LuaRT](https://github.com/samyeyo/LuaRT/).
- It's less buggy than [betterElements](https://github.com/zeykatecool/betterElements) and more powerful.
- [Docs](https://github.com/zeykatecool/betterUI/tree/main/docs)
> Supports LuaRT 1.9.0,should expect it not to work on an older version.

# Features
- You can use **onHover**,**onLeave**,**onMouseUp**,**onClick**, and **onRightClick** on any element,unlike betterElements.

- New **Brush** object for creating easy gradient and image brushes.

- New **Color** object for easy use of colors.

- New **Event** object for easy event handling and interact with elements.

- New **Enum** object for easy use of pre-defined constants.

- Much better syntax for understanding.

- Much better global **betterUI**.

# Quick Start
- It's so easy to use,just require it from your main script.
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
-- Returns LuaRT Window Object.
Win:center()


local label = Label{
    x = 10;
    y = 0;
    textcolor = "#FFFFFFFF";
    font = "Arial";
    fontsize = 35;
    fontweight = 400;
    visible = true;
    text = "BetterUI Example";
    stroke = 2;
    strokecolor = "#119600FF";
}
-- Returns Control_Table of Label. It's a table that controls properties of the label not the object because canvas:print() returns void.

label:center()

label.onHover = function()
    print(MousePosition())
end

--Event and Enum are global objects of BetterUI.
Event:onFire(Enum.EmbeddedEvents.windowOnKey, function(key)
    if key == "VK_ESCAPE" then
        betterUI:kill() --Kills all objects.
    end
end)


Update(function(dt) --Using internal timer of Lua. (os.clock)
    local fps = math.floor(1 / dt)
    Win:status("FPS: " .. fps)
end)
```

- Nearly all elements using same system for creating and editing,for example:

```lua
local ELEMENT = Element{
    x = 0;
    y = 0;
    width = 100;
    height = 100;
    visible = true;
    bgcolor = "#000000FF";
    textcolor = "#FFFFFFFF"; -- If element has text.
    text = "Hello"; -- If element has text.
    font = "Arial"; -- If element has text.
    fontsize = 12; -- If element has text.
    fontweight = 400; -- If element has text.
    fontstyle = "normal"; -- If element has text.
    stroke = 2; -- If element is Label,if not you need to use Border element.
    strokecolor = "#119600FF"; -- If element is Label,if not you need to use Border element.
    radius = 10;
    zindex = 0; -- Almost all elements have zindex.
}
```

