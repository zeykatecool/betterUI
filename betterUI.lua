local ui = require("ui")
local sys = require("sys")
require("canvas")
require("enum")
require("colorProcess")
require("event")
_G.betterUI = {
    debugging = false;
    updateHolder = true;
    currentlyEditingWindow = nil;
    alsoAddUpdate = {};
    canvas_update_func = function(s) end;
    canvas_click_func = function(s) end;
    canvas_rightclick_func = function(s) end;
    canvas_onhover_func = function(s) end;
    canvas_onmouseup_func = function(s) end;
    CURSORTO = "arrow";
    TARGET_FPS = 60;
}

_G.Brush = {}

function Brush.newLinearGradient(GradientTable,StartPositionTable,StopPositionTable,Opacity)
    assert(betterUI.currentlyEditingWindow, "No active window to edit.")
    local g = betterUI.currentlyEditingWindow.canvas:LinearGradient(GradientTable)
    g.start = StartPositionTable
    g.stop = StopPositionTable
    g.opacity = Opacity
    return g
end

function Brush.newRadialGradient(GradientTable,CenterPositionTable,RadiusPositionTable,Opacity)
    assert(betterUI.currentlyEditingWindow, "No active window to edit.")
    local g = betterUI.currentlyEditingWindow.canvas:RadialGradient(GradientTable)
    g.center = CenterPositionTable
    g.radius = RadiusPositionTable
    g.opacity = Opacity
    return g
end

function betterUI:kill()
    betterUI.updateHolder = false
end

function betterUI:targetFps(fps)
    if type(fps) ~= "number" then return betterUI.TARGET_FPS end
    betterUI.TARGET_FPS = fps
    return fps
end

function betterUI:currentlyEditing(w)
    if w == nil then
        return betterUI.currentlyEditingWindow
    end
    betterUI.currentlyEditingWindow = w
    return w
end

function betterUI:addToUpdate(f)
    if type(f) ~= "function" then return false end
    table.insert(betterUI.alsoAddUpdate,f)
    return true
end

math.randomseed(os.time())
function betterUI:uniqueName()
    local name = ""
    for i=1,7 do
        local char = math.random(97,122)
        name = name .. string.char(char)
    end
    return name
end



local function drawRectangle(canvas, x, y, width, height, radiusx, radiusy, brush)
    --require("console").writeln(canvas, x, y, width, height, radiusx, radiusy, brush)
    canvas:fillroundrect(x , y , x + width , y + height, radiusx, radiusy, brush)
end

local function drawBorder(canvas, x, y, width, height, radiusx, radiusy, brush, thickness)
    canvas:roundrect(x , y , x + width , y + height, radiusx, radiusy, brush, thickness)
end

function _G.MousePosition()
    local x,y = ui.mousepos()
    return {x=x,y=y}
end


function _G.Window(WindowProperties)
    local window = 
    ui.Window(
    WindowProperties.name or "Window",
    WindowProperties.style or Enum.WindowStyle.Fixed,
    WindowProperties.width or 300,
    WindowProperties.height or 300
    )
        
    WindowProperties.x = WindowProperties.x or 0
    WindowProperties.y = WindowProperties.y or 0

    function window:onKey(key)
        Event:fire("windowOnKey", key)
    end

    function window:onResize()
        Event:fire("windowOnResize",window.width,window.height)
    end
    
    function window:onMove()
        Event:fire("windowOnMove",window.x,window.y)
    end

    function window:onMaximize()
        Event:fire("windowOnMaximize")
    end

    function window:onMinimize()
        Event:fire("windowOnMinimize")
    end

    local canvas = ui.Canvas(window)
    canvas.align = "all"
    canvas.bgcolor = hexA(WindowProperties.bgcolor) or 0x000000FF

    function canvas:onPaint()
        self:begin()
        self:clear(canvas.bgcolor)
        betterUI.canvas_update_func(canvas)
        Event:fire("canvasOnPaint")
        self:flip()
    end
    function canvas:onClick()
        betterUI.canvas_click_func(canvas)
        Event:fire("canvasOnClick",MousePosition().x,MousePosition().y)
    end

    function canvas:onContext()
        betterUI.canvas_rightclick_func(canvas)
        Event:fire("canvasOnRightClick",MousePosition().x,MousePosition().y)
    end

    function canvas:onHover()
        betterUI.canvas_onhover_func(canvas)
        Event:fire("canvasOnHover",MousePosition().x,MousePosition().y)
    end

    function canvas:onMouseUp()
        betterUI.canvas_onmouseup_func(canvas)
        Event:fire("canvasOnMouseUp",MousePosition().x,MousePosition().y)
    end

    if WindowProperties.visible ~= false then
        window:show()
    else
        window:hide()
    end

    window._windowproperties = WindowProperties
    window._elements = {}
    window.canvas = canvas
    betterUI:currentlyEditing(window)

    function window:onClose()
        Event:fire("windowOnClose")
        betterUI:kill()
    end

    return window
end



function _G.Label(LabelProperties)
    assert(betterUI.currentlyEditingWindow, "No active window to edit.")
    local canvas = betterUI.currentlyEditingWindow.canvas
    local current_canvas_settings = {
        font = canvas.font;
        fontsize = canvas.fontsize;
        fontstyle = canvas.fontstyle;
        fontweight = canvas.fontweight;
    }
    
    local CONTROL_TABLE = {
        ORIGINALS = current_canvas_settings;
        x = LabelProperties.x or 0;
        y = LabelProperties.y or 0;
        text = LabelProperties.text or "Label";
        font = LabelProperties.font or "Arial";
        fontsize = LabelProperties.fontsize or 12;
        fontstyle = LabelProperties.fontstyle or "normal";
        fontweight = LabelProperties.fontweight or 200;
        textcolor = LabelProperties.textcolor or 0xFFFFFFFF;
        zindex = LabelProperties.zindex or 0;
        cursor = LabelProperties.cursor or "arrow";
        stroke = LabelProperties.stroke or 0;
        strokecolor = LabelProperties.strokecolor or 0x000000FF;
        visible = LabelProperties.visible == nil and true or LabelProperties.visible == true and true or false;
        --enabled = LabelProperties.enabled == nil and true or LabelProperties.enabled == true and true or false;
        BUI = {
            TYPE = "LABEL";
            NAME = LabelProperties.name or _G.betterUI:uniqueName();
            MOUSE_HOVERING = false;
            CHILDS = {};
            PARENT = {};
        }
    }

    function CONTROL_TABLE:addChild(c)
        table.insert(CONTROL_TABLE.BUI.CHILDS, c)
        c.BUI.PARENT = CONTROL_TABLE
    end

    function CONTROL_TABLE:removeChild(c)
        table.remove(CONTROL_TABLE.BUI.CHILDS, c)
        c.BUI.PARENT = {}
    end

        canvas.font = CONTROL_TABLE.font
        canvas.fontsize = CONTROL_TABLE.fontsize
        canvas.fontstyle = CONTROL_TABLE.fontstyle
        canvas.fontweight = CONTROL_TABLE.fontweight
        CONTROL_TABLE.width, CONTROL_TABLE.height = canvas:measure(CONTROL_TABLE.text).width, canvas:measure(CONTROL_TABLE.text).height
        for i,v in pairs(CONTROL_TABLE.ORIGINALS) do
            canvas[i] = v
        end

    CONTROL_TABLE.draw = function(f)
        if f then
            f(CONTROL_TABLE)
        end

        canvas.font = CONTROL_TABLE.font
        canvas.fontsize = CONTROL_TABLE.fontsize
        canvas.fontstyle = CONTROL_TABLE.fontstyle
        canvas.fontweight = CONTROL_TABLE.fontweight

        local text = CONTROL_TABLE.text

        local xpos = CONTROL_TABLE.x
        local ypos = CONTROL_TABLE.y

        local strokeOffset = CONTROL_TABLE.stroke
        local strokeColor = hexA(CONTROL_TABLE.strokecolor)

        for dx = -strokeOffset, strokeOffset do
            for dy = -strokeOffset, strokeOffset do
                if dx ~= 0 or dy ~= 0 then
                canvas:print(text, xpos + dx, ypos + dy, strokeColor)
                end
            end
        end
        canvas:print(CONTROL_TABLE.text, CONTROL_TABLE.x, CONTROL_TABLE.y, hexA(CONTROL_TABLE.textcolor))
        

        CONTROL_TABLE.width, CONTROL_TABLE.height = canvas:measure(CONTROL_TABLE.text).width, canvas:measure(CONTROL_TABLE.text).height
        for i,v in pairs(CONTROL_TABLE.ORIGINALS) do
            canvas[i] = v
        end
        return true
    end

    function CONTROL_TABLE:center()
        CONTROL_TABLE.x = (betterUI.currentlyEditingWindow.width / 2) - (CONTROL_TABLE.width / 2)
        CONTROL_TABLE.y = (betterUI.currentlyEditingWindow.height / 2) - (CONTROL_TABLE.height / 2)
    end

    CONTROL_TABLE.onHover = LabelProperties.onHover or function() end
    CONTROL_TABLE.onLeave = LabelProperties.onLeave or function() end
    CONTROL_TABLE.onClick = LabelProperties.onClick or function() end
    CONTROL_TABLE.onRightClick = LabelProperties.onRightClick or function() end
    CONTROL_TABLE.onMouseUp = LabelProperties.onMouseUp or function() end
    

    betterUI.currentlyEditingWindow._elements[CONTROL_TABLE.BUI.NAME] = CONTROL_TABLE
    return betterUI.currentlyEditingWindow._elements[CONTROL_TABLE.BUI.NAME]
end

function _G.Frame(FrameProperties)
    assert(betterUI.currentlyEditingWindow, "No active window to edit.")
    local canvas = betterUI.currentlyEditingWindow.canvas
    
    local CONTROL_TABLE = {
        x = FrameProperties.x or 0;
        y = FrameProperties.y or 0;
        width = FrameProperties.width or 300;
        height = FrameProperties.height or 300;
        bgcolor = FrameProperties.bgcolor or 0x000000FF;
        radius = FrameProperties.radius or 0;
        zindex = FrameProperties.zindex or 0;
        cursor = FrameProperties.cursor or "arrow";
        visible = FrameProperties.visible == nil and true or FrameProperties.visible == true and true or false,
        --enabled = FrameProperties.enabled == nil and true or FrameProperties.enabled == true and true or false,
        BUI = {
            TYPE = "FRAME";
            NAME = FrameProperties.name or _G.betterUI:uniqueName();
            MOUSE_HOVERING = false;
            CHILDS = {};
            PARENT = {};
        }
    }

    function CONTROL_TABLE:addChild(c)
        table.insert(CONTROL_TABLE.BUI.CHILDS, c)
        c.BUI.PARENT = CONTROL_TABLE
    end

    function CONTROL_TABLE:removeChild(c)
        table.remove(CONTROL_TABLE.BUI.CHILDS, c)
        c.BUI.PARENT = {}
    end

    function CONTROL_TABLE:center()
        CONTROL_TABLE.x = (betterUI.currentlyEditingWindow.width / 2) - (CONTROL_TABLE.width / 2)
        CONTROL_TABLE.y = (betterUI.currentlyEditingWindow.height / 2) - (CONTROL_TABLE.height / 2)
    end

    CONTROL_TABLE.draw = function(f)
        if f then
            f(CONTROL_TABLE)
        end
        drawRectangle(canvas, CONTROL_TABLE.x, CONTROL_TABLE.y, CONTROL_TABLE.width, CONTROL_TABLE.height, CONTROL_TABLE.radius, CONTROL_TABLE.radius, hexA(CONTROL_TABLE.bgcolor))
        return true
    end

    CONTROL_TABLE.onHover = FrameProperties.onHover or function() end
    CONTROL_TABLE.onLeave = FrameProperties.onLeave or function() end
    CONTROL_TABLE.onClick = FrameProperties.onClick or function() end
    CONTROL_TABLE.onRightClick = FrameProperties.onRightClick or function() end
    CONTROL_TABLE.onMouseUp = FrameProperties.onMouseUp or function() end


    betterUI.currentlyEditingWindow._elements[CONTROL_TABLE.BUI.NAME] = CONTROL_TABLE
    return betterUI.currentlyEditingWindow._elements[CONTROL_TABLE.BUI.NAME]
end

function _G.Button(ButtonProperties)
    assert(betterUI.currentlyEditingWindow, "No active window to edit.")
    local canvas = betterUI.currentlyEditingWindow.canvas
    local current_canvas_settings = {
        font = canvas.font;
        fontsize = canvas.fontsize;
        fontstyle = canvas.fontstyle;
        fontweight = canvas.fontweight;
    }
    
    local CONTROL_TABLE = {
        ORIGINALS = current_canvas_settings;
        x = ButtonProperties.x or 0;
        y = ButtonProperties.y or 0;
        width = ButtonProperties.width or 100;
        height = ButtonProperties.height or 100;
        bgcolor = ButtonProperties.bgcolor or 0x000000FF;
        text = ButtonProperties.text or "Button";
        font = ButtonProperties.font or "Arial";
        fontsize = ButtonProperties.fontsize or 12;
        radius = ButtonProperties.radius or 0;
        fontstyle = ButtonProperties.fontstyle or "normal";
        fontweight = ButtonProperties.fontweight or 200;
        textcolor = ButtonProperties.textcolor or 0xFFFFFFFF;
        zindex = ButtonProperties.zindex or 0;
        cursor = ButtonProperties.cursor or "hand";
        visible = ButtonProperties.visible == nil and true or ButtonProperties.visible == true and true or false;
        --enabled = ButtonProperties.enabled == nil and true or ButtonProperties.enabled == true and true or false;
        BUI = {
            TYPE = "BUTTON";
            NAME = ButtonProperties.name or _G.betterUI:uniqueName();
            MOUSE_HOVERING = false;
            CHILDS = {};
            PARENT = {};
        }
    }

    function CONTROL_TABLE:addChild(c)
        table.insert(CONTROL_TABLE.BUI.CHILDS, c)
        c.BUI.PARENT = CONTROL_TABLE
    end

    function CONTROL_TABLE:removeChild(c)
        table.remove(CONTROL_TABLE.BUI.CHILDS, c)
        c.BUI.PARENT = {}
    end

    CONTROL_TABLE.draw = function(f)
        if f then
            f(CONTROL_TABLE)
        end
        drawRectangle(canvas, CONTROL_TABLE.x, CONTROL_TABLE.y, CONTROL_TABLE.width, CONTROL_TABLE.height, CONTROL_TABLE.radius, CONTROL_TABLE.radius, hexA(CONTROL_TABLE.bgcolor))
        canvas.font = CONTROL_TABLE.font
        canvas.fontsize = CONTROL_TABLE.fontsize
        canvas.fontstyle = CONTROL_TABLE.fontstyle
        canvas.fontweight = CONTROL_TABLE.fontweight
        local centerOfRecX, centerOfRecY = CONTROL_TABLE.x + (CONTROL_TABLE.width / 2), CONTROL_TABLE.y + (CONTROL_TABLE.height / 2)
        local sizeOfText = canvas:measure(CONTROL_TABLE.text)
        canvas:print(CONTROL_TABLE.text, centerOfRecX - (sizeOfText.width / 2), centerOfRecY - (sizeOfText.height / 2), hexA(CONTROL_TABLE.textcolor))
        for i,v in pairs(CONTROL_TABLE.ORIGINALS) do
            canvas[i] = v
        end
        return true
    end


    CONTROL_TABLE.onHover = ButtonProperties.onHover or function() end
    CONTROL_TABLE.onLeave = ButtonProperties.onLeave or function() end
    CONTROL_TABLE.onClick = ButtonProperties.onClick or function() end
    CONTROL_TABLE.onRightClick = ButtonProperties.onRightClick or function() end
    CONTROL_TABLE.onMouseUp = ButtonProperties.onMouseUp or function() end


    betterUI.currentlyEditingWindow._elements[CONTROL_TABLE.BUI.NAME] = CONTROL_TABLE
    return betterUI.currentlyEditingWindow._elements[CONTROL_TABLE.BUI.NAME]
end

function _G.Image(ImageProperties)
    assert(betterUI.currentlyEditingWindow, "No active window to edit.")
    local canvas = betterUI.currentlyEditingWindow.canvas

    local CONTROL_TABLE = {
        x = ImageProperties.x or 0;
        y = ImageProperties.y or 0;
        width = ImageProperties.width or canvas:Image(ImageProperties.image).width;
        height = ImageProperties.height or canvas:Image(ImageProperties.image).height;
        image = ImageProperties.image or "";
        zindex = ImageProperties.zindex or 0;
        cursor = ImageProperties.cursor or "arrow";
        transparency = ImageProperties.transparency or 0;
        visible = ImageProperties.visible == nil and true or ImageProperties.visible == true and true or false;
        --enabled = ImageProperties.enabled == nil and true or ImageProperties.enabled == true and true or false;
        BUI = {
            TYPE = "IMAGE";
            NAME = ImageProperties.name or _G.betterUI:uniqueName();
            MOUSE_HOVERING = false;
            CHILDS = {};
            PARENT = {};
        }
    }

    function CONTROL_TABLE:addChild(c)
        table.insert(CONTROL_TABLE.BUI.CHILDS, c)
        c.BUI.PARENT = CONTROL_TABLE
    end

    function CONTROL_TABLE:removeChild(c)
        table.remove(CONTROL_TABLE.BUI.CHILDS, c)
        c.BUI.PARENT = {}
    end

    CONTROL_TABLE.draw = function(f)
        if f then
            f(CONTROL_TABLE)
        end
        local IMAGE = canvas:Image(CONTROL_TABLE.image)
        local transparency = 1 - CONTROL_TABLE.transparency
        IMAGE:drawrect(CONTROL_TABLE.x, CONTROL_TABLE.y,CONTROL_TABLE.width, CONTROL_TABLE.height, transparency)
        return true
    end


    CONTROL_TABLE.onHover = ImageProperties.onHover or function() end
    CONTROL_TABLE.onLeave = ImageProperties.onLeave or function() end
    CONTROL_TABLE.onClick = ImageProperties.onClick or function() end
    CONTROL_TABLE.onRightClick = ImageProperties.onRightClick or function() end
    CONTROL_TABLE.onMouseUp = ImageProperties.onMouseUp or function() end


    betterUI.currentlyEditingWindow._elements[CONTROL_TABLE.BUI.NAME] = CONTROL_TABLE
    return betterUI.currentlyEditingWindow._elements[CONTROL_TABLE.BUI.NAME]
end

function _G.Point(PointProperties)
    local canvas = betterUI.currentlyEditingWindow.canvas

    local CONTROL_TABLE = {
        x = PointProperties.x or 0;
        y = PointProperties.y or 0;
        zindex = PointProperties.zindex or 0;
        cursor = PointProperties.cursor or "arrow";
        bgcolor = PointProperties.bgcolor or 0x000000FF;
        visible = PointProperties.visible == nil and true or PointProperties.visible == true and true or false;
        --enabled = PointProperties.enabled == nil and true or PointProperties.enabled == true and true or false;
        BUI = {
            TYPE = "POINT";
            NAME = PointProperties.name or _G.betterUI:uniqueName();
            MOUSE_HOVERING = false;
            CHILDS = {};
            PARENT = {};
        }
    }

    function CONTROL_TABLE:addChild(c)
        table.insert(CONTROL_TABLE.BUI.CHILDS, c)
        c.BUI.PARENT = CONTROL_TABLE
    end

    function CONTROL_TABLE:removeChild(c)
        table.remove(CONTROL_TABLE.BUI.CHILDS, c)
        c.BUI.PARENT = {}
    end

    CONTROL_TABLE.draw = function(f)
        if f then
            f(CONTROL_TABLE)
        end
        canvas:point(CONTROL_TABLE.x, CONTROL_TABLE.y,hexA(CONTROL_TABLE.bgcolor))
        return true
    end

    CONTROL_TABLE.width, CONTROL_TABLE.height = 1,1

    CONTROL_TABLE.onHover = PointProperties.onHover or function() end
    CONTROL_TABLE.onLeave = PointProperties.onLeave or function() end
    CONTROL_TABLE.onClick = PointProperties.onClick or function() end
    CONTROL_TABLE.onRightClick = PointProperties.onRightClick or function() end
    CONTROL_TABLE.onMouseUp = PointProperties.onMouseUp or function() end


    betterUI.currentlyEditingWindow._elements[CONTROL_TABLE.BUI.NAME] = CONTROL_TABLE
    return betterUI.currentlyEditingWindow._elements[CONTROL_TABLE.BUI.NAME]
end

function _G.CheckBox(CheckBoxProperties)
    local canvas = betterUI.currentlyEditingWindow.canvas

    local CONTROL_TABLE = {
        x = CheckBoxProperties.x or 0;
        y = CheckBoxProperties.y or 0;
        width = CheckBoxProperties.width or 20;
        height = CheckBoxProperties.height or 20;
        radius = CheckBoxProperties.radius or 0;
        zindex = CheckBoxProperties.zindex or 0;
        cursor = CheckBoxProperties.cursor or "arrow";
        bgcolor = CheckBoxProperties.bgcolor or 0x000000FF;
        color = CheckBoxProperties.color or 0xFFFFFFFF;
        checked = CheckBoxProperties.checked or false;
        visible = CheckBoxProperties.visible == nil and true or CheckBoxProperties.visible == true and true or false;
        --enabled = CheckBoxProperties.enabled == nil and true or CheckBoxProperties.enabled == true and true or false;
        BUI = {
            TYPE = "CHECKBOX";
            NAME = CheckBoxProperties.name or _G.betterUI:uniqueName();
            MOUSE_HOVERING = false;
            CHILDS = {};
            PARENT = {};
        }
    }

    function CONTROL_TABLE:addChild(c)
        table.insert(CONTROL_TABLE.BUI.CHILDS, c)
        c.BUI.PARENT = CONTROL_TABLE
    end

    function CONTROL_TABLE:removeChild(c)
        table.remove(CONTROL_TABLE.BUI.CHILDS, c)
        c.BUI.PARENT = {}
    end

    CONTROL_TABLE.draw = function(f)
        if f then
            f(CONTROL_TABLE)
        end
            drawRectangle(canvas, CONTROL_TABLE.x, CONTROL_TABLE.y, CONTROL_TABLE.width, CONTROL_TABLE.height, CONTROL_TABLE.radius, CONTROL_TABLE.radius, hexA(CONTROL_TABLE.bgcolor))
        if CONTROL_TABLE.checked then
            drawRectangle(canvas, CONTROL_TABLE.x + 2, CONTROL_TABLE.y + 2, CONTROL_TABLE.width - 4, CONTROL_TABLE.height - 4, CONTROL_TABLE.radius, CONTROL_TABLE.radius, hexA(CONTROL_TABLE.color))
        end
        return true
    end

    CONTROL_TABLE.onHover = CheckBoxProperties.onHover or function() end
    CONTROL_TABLE.onLeave = CheckBoxProperties.onLeave or function() end
    CONTROL_TABLE.onClick = CheckBoxProperties.onClick or function() end
    CONTROL_TABLE.onRightClick = CheckBoxProperties.onRightClick or function() end
    CONTROL_TABLE.onMouseUp = CheckBoxProperties.onMouseUp or function() end


    betterUI.currentlyEditingWindow._elements[CONTROL_TABLE.BUI.NAME] = CONTROL_TABLE
    return betterUI.currentlyEditingWindow._elements[CONTROL_TABLE.BUI.NAME]
end

function _G.Line(LineProperties)
    local canvas = betterUI.currentlyEditingWindow.canvas

    local CONTROL_TABLE = {
        x0 = LineProperties.x0 or 0;
        y0 = LineProperties.y0 or 0;
        x1 = LineProperties.x1 or 0;
        y1 = LineProperties.y1 or 0;
        thickness = LineProperties.thickness or 1;
        zindex = LineProperties.zindex or 0;
        cursor = LineProperties.cursor or "arrow";
        bgcolor = LineProperties.bgcolor or 0x000000FF;
        visible = LineProperties.visible == nil and true or LineProperties.visible == true and true or false;
        --enabled = LineProperties.enabled == nil and true or LineProperties.enabled == true and true or false;
        BUI = {
            TYPE = "LINE";
            NAME = LineProperties.name or _G.betterUI:uniqueName();
            MOUSE_HOVERING = false;
        }
    }

    CONTROL_TABLE.draw = function(f)
        if f then
            f(CONTROL_TABLE)
        end
        canvas:line(CONTROL_TABLE.x0, CONTROL_TABLE.y0, CONTROL_TABLE.x1, CONTROL_TABLE.y1, hexA(CONTROL_TABLE.bgcolor), CONTROL_TABLE.thickness)
        return true
    end

    CONTROL_TABLE.onHover = LineProperties.onHover or function() end
    CONTROL_TABLE.onLeave = LineProperties.onLeave or function() end
    CONTROL_TABLE.onClick = LineProperties.onClick or function() end
    CONTROL_TABLE.onRightClick = LineProperties.onRightClick or function() end
    CONTROL_TABLE.onMouseUp = LineProperties.onMouseUp or function() end


    betterUI.currentlyEditingWindow._elements[CONTROL_TABLE.BUI.NAME] = CONTROL_TABLE
    return betterUI.currentlyEditingWindow._elements[CONTROL_TABLE.BUI.NAME]
end

function _G.Circle(CircleProperties)
    local canvas = betterUI.currentlyEditingWindow.canvas

    local CONTROL_TABLE = {
        x = CircleProperties.x or 0;
        y = CircleProperties.y or 0;
        width = CircleProperties.width or 20;
        height = CircleProperties.height or 20;
        radius = CircleProperties.radius or 0;
        zindex = CircleProperties.zindex or 0;
        cursor = CircleProperties.cursor or "arrow";
        bgcolor = CircleProperties.bgcolor or 0x000000FF;
        visible = CircleProperties.visible == nil and true or CircleProperties.visible == true and true or false;
        --enabled = CircleProperties.enabled == nil and true or CircleProperties.enabled == true and true or false;
        BUI = {
            TYPE = "CIRCLE";
            NAME = CircleProperties.name or _G.betterUI:uniqueName();
            MOUSE_HOVERING = false;
            CHILDS = {};
            PARENT = {};
        }
    }

    function CONTROL_TABLE:addChild(c)
        table.insert(CONTROL_TABLE.BUI.CHILDS, c)
        c.BUI.PARENT = CONTROL_TABLE
    end

    function CONTROL_TABLE:removeChild(c)
        table.remove(CONTROL_TABLE.BUI.CHILDS, c)
        c.BUI.PARENT = {}
    end

    CONTROL_TABLE.draw = function(f)
        if f then
            f(CONTROL_TABLE)
        end
        CONTROL_TABLE.radius = CONTROL_TABLE.width / 2
        drawRectangle(canvas, CONTROL_TABLE.x, CONTROL_TABLE.y, CONTROL_TABLE.width, CONTROL_TABLE.height, CONTROL_TABLE.radius, CONTROL_TABLE.radius, hexA(CONTROL_TABLE.bgcolor))
        return true
    end


    CONTROL_TABLE.onHover = CircleProperties.onHover or function() end
    CONTROL_TABLE.onLeave = CircleProperties.onLeave or function() end
    CONTROL_TABLE.onClick = CircleProperties.onClick or function() end
    CONTROL_TABLE.onRightClick = CircleProperties.onRightClick or function() end
    CONTROL_TABLE.onMouseUp = CircleProperties.onMouseUp or function() end


    betterUI.currentlyEditingWindow._elements[CONTROL_TABLE.BUI.NAME] = CONTROL_TABLE
    return betterUI.currentlyEditingWindow._elements[CONTROL_TABLE.BUI.NAME]
end

function _G.Border(BorderProperties)
    local canvas = betterUI.currentlyEditingWindow.canvas

    local CONTROL_TABLE = {
        x = BorderProperties.x or 0;
        y = BorderProperties.y or 0;
        width = BorderProperties.width or 20;
        height = BorderProperties.height or 20;
        radius = BorderProperties.radius or 0;
        zindex = BorderProperties.zindex or 0;
        cursor = BorderProperties.cursor or "arrow";
        thickness = BorderProperties.thickness or 1;
        color = BorderProperties.color or 0x000000FF;
        element = BorderProperties.element;
        visible = BorderProperties.visible == nil and true or BorderProperties.visible == true and true or false;
        --enabled = BorderProperties.enabled == nil and true or BorderProperties.enabled == true and true or false;
        BUI = {
            TYPE = "BORDER";
            NAME = BorderProperties.name or _G.betterUI:uniqueName();
            MOUSE_HOVERING = false;
            BORDER_OF_ELEMENT = BorderProperties.element;
        }
    }

    CONTROL_TABLE.draw = function(f)
        if f then
            f(CONTROL_TABLE)
        end
        if CONTROL_TABLE.element then
            CONTROL_TABLE.x = CONTROL_TABLE.element.x
            CONTROL_TABLE.y = CONTROL_TABLE.element.y
            CONTROL_TABLE.width = CONTROL_TABLE.element.width
            CONTROL_TABLE.height = CONTROL_TABLE.element.height
            if CONTROL_TABLE.element.radius then
                CONTROL_TABLE.radius = CONTROL_TABLE.element.radius
            end
            CONTROL_TABLE.zindex = CONTROL_TABLE.element.zindex + 1
        end
        drawBorder(canvas, CONTROL_TABLE.x, CONTROL_TABLE.y, CONTROL_TABLE.width, CONTROL_TABLE.height, CONTROL_TABLE.radius, CONTROL_TABLE.radius, hexA(CONTROL_TABLE.color), CONTROL_TABLE.thickness)
        return true
    end

    CONTROL_TABLE.onHover = BorderProperties.onHover or function() end
    CONTROL_TABLE.onLeave = BorderProperties.onLeave or function() end
    CONTROL_TABLE.onClick = BorderProperties.onClick or function() end
    CONTROL_TABLE.onRightClick = BorderProperties.onRightClick or function() end
    CONTROL_TABLE.onMouseUp = BorderProperties.onMouseUp or function() end


    betterUI.currentlyEditingWindow._elements[CONTROL_TABLE.BUI.NAME] = CONTROL_TABLE
    return betterUI.currentlyEditingWindow._elements[CONTROL_TABLE.BUI.NAME]
end


function _G.Blur(BlurProperties)
    local canvas = betterUI.currentlyEditingWindow.canvas

    local CONTROL_TABLE = {
        x = BlurProperties.x or 0;
        y = BlurProperties.y or 0;
        width = BlurProperties.width or 20;
        height = BlurProperties.height or 20;
        radius = BlurProperties.radius or 0;
        zindex = BlurProperties.zindex or 0;
        cursor = BlurProperties.cursor or "arrow";
        bgcolor = BlurProperties.bgcolor or 0x000000FF;
        visible = BlurProperties.visible == nil and true or BlurProperties.visible == true and true or false;
        --enabled = BlurProperties.enabled == nil and true or BlurProperties.enabled == true and true or false;
        BUI = {
            TYPE = "BLUR";
            NAME = BlurProperties.name or _G.betterUI:uniqueName();
            MOUSE_HOVERING = false;
            PARENT = {};
        }
    }

    CONTROL_TABLE.draw = function(f)
        

    end

end

function betterUI:MousePositionAccordToWindow(window)
    local mouseX, mouseY = ui.mousepos()
    local windowX, windowY = window.x, window.y
    return mouseX - windowX, mouseY - windowY
end

function betterUI:getTopElementAtMouse()
    assert(betterUI.currentlyEditingWindow, "No active window to check elements.")
    

    local mouseX, mouseY = ui.mousepos()
    if betterUI.currentlyEditingWindow._windowproperties.style ~= Enum.WindowStyle.Raw then
        mouseY = mouseY - 32
    end

    local windowX = betterUI.currentlyEditingWindow.x
    local windowY = betterUI.currentlyEditingWindow.y

    local localMouseX = mouseX - windowX
    local localMouseY = mouseY - windowY

    local topElement = nil
    local maxZIndex = -math.huge

    for _, element in pairs(betterUI.currentlyEditingWindow._elements) do

        if element.visible then
            local elementX = element.x
            local elementY = element.y
            local elementWidth = element.width
            local elementHeight = element.height

            local isInsideX = localMouseX >= elementX and localMouseX <= (elementX + elementWidth)
            local isInsideY = localMouseY >= elementY and localMouseY <= (elementY + elementHeight)

            if isInsideX and isInsideY then
                if element.zindex > maxZIndex then
                    maxZIndex = element.zindex
                    topElement = element
         
        end
    end
    end
end
    return topElement
end

function betterUI:isMouseOnElementHitbox(element)
    assert(betterUI.currentlyEditingWindow, "No active window to check elements.")

    local mouseX, mouseY = ui.mousepos()

    if betterUI.currentlyEditingWindow._windowproperties.style ~= Enum.WindowStyle.Raw then
        if betterUI.currentlyEditingWindow.y == 0 then
            mouseY = mouseY - 22
        else
            mouseY = mouseY - 32
        end
    end

    local windowX = betterUI.currentlyEditingWindow.x
    local windowY = betterUI.currentlyEditingWindow.y

    local localMouseX = mouseX - windowX
    local localMouseY = mouseY - windowY

    local elementX = element.x
    local elementY = element.y
    local elementWidth = element.width
    local elementHeight = element.height

    local radius = element.radius or 0

    if radius > 0 then

        if localMouseX < (elementX + radius) and localMouseY < (elementY + radius) then
            local dx = localMouseX - (elementX + radius)
            local dy = localMouseY - (elementY + radius)
            return (dx * dx + dy * dy) <= (radius * radius)
        end


        if localMouseX > (elementX + elementWidth - radius) and localMouseY < (elementY + radius) then
            local dx = localMouseX - (elementX + elementWidth - radius)
            local dy = localMouseY - (elementY + radius)
            return (dx * dx + dy * dy) <= (radius * radius)
        end


        if localMouseX < (elementX + radius) and localMouseY > (elementY + elementHeight - radius) then
            local dx = localMouseX - (elementX + radius)
            local dy = localMouseY - (elementY + elementHeight - radius)
            return (dx * dx + dy * dy) <= (radius * radius)
        end


        if localMouseX > (elementX + elementWidth - radius) and localMouseY > (elementY + elementHeight - radius) then
            local dx = localMouseX - (elementX + elementWidth - radius)
            local dy = localMouseY - (elementY + elementHeight - radius)
            return (dx * dx + dy * dy) <= (radius * radius)
        end
    end


    local isInsideX = localMouseX >= elementX and localMouseX <= (elementX + elementWidth)
    local isInsideY = localMouseY >= elementY and localMouseY <= (elementY + elementHeight)

    return isInsideX and isInsideY
end

function betterUI:isMouseOnLine(line)
    local mouseX, mouseY = ui.mousepos()
    if betterUI.currentlyEditingWindow._windowproperties.style ~= Enum.WindowStyle.Raw then
        if betterUI.currentlyEditingWindow.y == 0 then
            mouseY = mouseY - 22
        else
            mouseY = mouseY - 32
        end
    end

    local x0, y0 = line.x0, line.y0
    local x1, y1 = line.x1, line.y1

    local windowX = betterUI.currentlyEditingWindow.x
    local windowY = betterUI.currentlyEditingWindow.y
    local localMouseX = mouseX - windowX
    local localMouseY = mouseY - windowY

    local lineDX = x1 - x0
    local lineDY = y1 - y0
    local lineLength = math.sqrt(lineDX * lineDX + lineDY * lineDY)

    local t = ((localMouseX - x0) * lineDX + (localMouseY - y0) * lineDY) / (lineLength * lineLength)
    t = math.max(0, math.min(1, t))

    local closestX = x0 + t * lineDX
    local closestY = y0 + t * lineDY

    local distance = math.sqrt((localMouseX - closestX)^2 + (localMouseY - closestY)^2)

    return distance <= (line.thickness / 2)
end



local function onPaint(canvas)
    local self = canvas
    self:clear(canvas.bgcolor)
    local elements = betterUI.currentlyEditingWindow._elements

    local sortedElements = {}
    for _, element in pairs(elements) do
        table.insert(sortedElements, element)
    end
    table.sort(sortedElements, function(a, b)
        return (a.zindex or 0) < (b.zindex or 0)
    end)
    local function drawElement(element, parentX, parentY)
        if not element.visible then return end
        local effectiveX = (parentX or 0) + element.x
        local effectiveY = (parentY or 0) + element.y
        element.draw()
        --drawRectangle(canvas, effectiveX, effectiveY, element.width, element.height, element.radius, element.radius, hexA(element.bgcolor))
        if element.BUI.CHILDS and #element.BUI.CHILDS > 0 then
            for _, child in ipairs(element.BUI.CHILDS) do
                drawElement(child, effectiveX, effectiveY)
            end
        end
    end

    for _, element in ipairs(sortedElements) do
        if not element.BUI.PARENT or next(element.BUI.PARENT) == nil then
            drawElement(element)
        end
    end
end



local function onClick(canvas)
    for _, element in pairs(betterUI.currentlyEditingWindow._elements) do
         if element.BUI.TYPE == "LINE" then
             if betterUI:isMouseOnLine(element) then
                 if element.onClick then
                     element.onClick()
                 end
             end
         elseif betterUI:isMouseOnElementHitbox(element) then
             if betterUI:getTopElementAtMouse() == element then
                 if element.onClick then
                     element.onClick()
                 end
             end
         end
    end
 end
 
 local function onMouseUp(canvas)
    for _, element in pairs(betterUI.currentlyEditingWindow._elements) do
         if element.BUI.TYPE == "LINE" then
             if betterUI:isMouseOnLine(element) then
                 if element.onMouseUp then
                     element.onMouseUp()
                 end
             end
         elseif betterUI:isMouseOnElementHitbox(element) then
             if betterUI:getTopElementAtMouse() == element then
                 if element.onMouseUp then
                     element.onMouseUp()
                 end
             end
         end
     end
 end
 
 local function onContext(canvas)
    for _, element in pairs(betterUI.currentlyEditingWindow._elements) do
         if element.BUI.TYPE == "LINE" then
             if betterUI:isMouseOnLine(element) then
                 if element.onRightClick then
                     element.onRightClick()
                 end
             end
         elseif betterUI:isMouseOnElementHitbox(element) then
             if betterUI:getTopElementAtMouse() == element then
                 if element.onRightClick then
                     element.onRightClick()
                 end
             end
         end
     end
 end

local function onHover(canvas)
    local self = canvas
    for _, element in pairs(betterUI.currentlyEditingWindow._elements) do
         if element.BUI.TYPE == "LINE" then
             if betterUI:isMouseOnLine(element) then
                 if element.onHover and not element.BUI.MOUSE_HOVERING then
                     element.onHover()
                     element.BUI.MOUSE_HOVERING = true
                     if element.cursor then
                         betterUI.CURSORTO = element.cursor
                     end
                 end
             else
                 if element.BUI.MOUSE_HOVERING then
                     element.onLeave()
                     element.BUI.MOUSE_HOVERING = false
                     betterUI.CURSORTO = "arrow"
                 end
             end
         else
             if betterUI:isMouseOnElementHitbox(element) then
                 if element.onHover and not element.BUI.MOUSE_HOVERING then
                     element.onHover()
                     element.BUI.MOUSE_HOVERING = true
                     if element.cursor then
                         betterUI.CURSORTO = element.cursor
                     end
                 end
             else
                 if element.BUI.MOUSE_HOVERING then
                     element.onLeave()
                     element.BUI.MOUSE_HOVERING = false
                     betterUI.CURSORTO = "arrow"
                 end
             end
         end
     end
 end


_G.betterUI.canvas_click_func = onClick
_G.betterUI.canvas_update_func = onPaint
_G.betterUI.canvas_rightclick_func = onContext
_G.betterUI.canvas_onhover_func = onHover
_G.betterUI.canvas_onmouseup_func = onMouseUp



local t = sys.clock()
function _G.Update(Functions)
    if not Functions then Functions = function(dt) end end
    while betterUI.updateHolder do
        local targetFPS = betterUI.TARGET_FPS
        local targetFrameTime = 1000 / targetFPS
        local startTime = sys.clock()
        ui.update()
        local dt = startTime - t
        t = startTime
        betterUI.currentlyEditingWindow.canvas.cursor = betterUI.CURSORTO
        Functions(dt)

        local frameTime = sys.clock() - startTime
        local sleepTime = targetFrameTime - frameTime
        if sleepTime > 0 then
            sleep(math.floor(sleepTime))
        end
        for i, v in pairs(betterUI.alsoAddUpdate) do
            v(dt)
        end
    end
end
