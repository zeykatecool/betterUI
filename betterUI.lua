local ui = require("ui")
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

function Brush.newImage(Path)
    assert(betterUI.currentlyEditingWindow, "No active window to edit.")
    return betterUI.currentlyEditingWindow.canvas:Image(Path)
end

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
        --betterUI.canvas_update_func(canvas)
        self:clear(canvas.bgcolor)
        local elements = betterUI.currentlyEditingWindow._elements
        
        local sortedElements = {}
        for _, element in pairs(elements) do
            table.insert(sortedElements, element)
        end
        table.sort(sortedElements, function(a, b)
            return (a.zindex or 0) < (b.zindex or 0)
        end)
        
        for _, element in ipairs(sortedElements) do
            if element.visible then
                element.draw()
            end
        end
        --Event:fire("canvasOnPaint")
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
        visible = LabelProperties.visible == nil and true or LabelProperties.visible == true and true or false;
        --enabled = LabelProperties.enabled == nil and true or LabelProperties.enabled == true and true or false;
        BUI = {
            TYPE = "LABEL";
            NAME = LabelProperties.name or _G.betterUI:uniqueName();
            MOUSE_HOVERING = false;
        }
    }

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
        childs = {};
        BUI = {
            TYPE = "FRAME";
            NAME = FrameProperties.name or _G.betterUI:uniqueName();
            MOUSE_HOVERING = false;
        }
    }

    function CONTROL_TABLE:addChild(c)
        table.insert(CONTROL_TABLE.childs, c)
    end

    function CONTROL_TABLE:removeChild(c)
        table.remove(CONTROL_TABLE.childs, c)
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
        }
    }

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
        }
    }

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
        }
    }

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
        }
    }

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

    for _, element in ipairs(sortedElements) do
        if element.visible then
            element.draw()
        end
    end
end


local function onClick(canvas)
   local self = canvas
   for _, element in pairs(betterUI.currentlyEditingWindow._elements) do
        if betterUI:isMouseOnElementHitbox(element) then
            if betterUI:getTopElementAtMouse() == element then
                if element.onClick then
                    element.onClick()
                end
            end
        end
    end
end

local function onMouseUp(canvas)
   local self = canvas
   for _, element in pairs(betterUI.currentlyEditingWindow._elements) do
        if betterUI:isMouseOnElementHitbox(element) then
            if betterUI:getTopElementAtMouse() == element then
                if element.onMouseUp then
                    element.onMouseUp()
                end
            end
        end
    end
end

local function onContext(canvas)
   local self = canvas
   for _, element in pairs(betterUI.currentlyEditingWindow._elements) do
        if betterUI:isMouseOnElementHitbox(element) then
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
        if betterUI:isMouseOnElementHitbox(element) then
                if element.onHover then
                    if element.BUI.MOUSE_HOVERING then
                        return
                    end
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


_G.betterUI.canvas_click_func = onClick
_G.betterUI.canvas_update_func = onPaint
_G.betterUI.canvas_rightclick_func = onContext
_G.betterUI.canvas_onhover_func = onHover
_G.betterUI.canvas_onmouseup_func = onMouseUp


local t = os.clock()
function _G.Update(Functions)
    if not Functions then Functions=function(dt)end end
    while betterUI.updateHolder do
        ui.update()
        local dt = os.clock() - t
        t = os.clock()
        betterUI.currentlyEditingWindow.canvas.cursor = betterUI.CURSORTO
        Functions(dt)
        for i,v in pairs(betterUI.alsoAddUpdate) do
            v(dt)
        end
    end
end