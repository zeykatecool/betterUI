_G.Enum = {}

Enum.WindowStyle = {
    Dialog = "dialog",
    Fixed = "fixed",
    Float = "float",
    Single = "single",
    Raw = "raw",
}

Enum.EmbeddedEvents = {
    windowOnKey = "windowOnKey",
    windowOnResize = "windowOnResize",
    windowOnMove = "windowOnMove",
    windowOnMaximize = "windowOnMaximize",
    windowOnMinimize = "windowOnMinimize",
    windowOnDrop = "windowOnDrop",
    windowOnThemeChange = "windowOnThemeChange",
    windowOnClose = "windowOnClose",
    canvasOnPaint = "canvasOnPaint",
    canvasOnClick = "canvasOnClick",
    canvasOnRightClick = "canvasOnRightClick",
    canvasOnHover = "canvasOnHover",
    canvasOnMouseUp = "canvasOnMouseUp",
}

Enum.MouseCursors = {
    Arrow = "arrow",
    Cross = "cross",
    Working = "working",
    Hand = "hand",
    Help = "help",
    IBeam = "ibeam",
    Forbidden = "forbidden",
    Cardinal = "cardinal",
    Horizontal = "horizontal",
    Vertical = "vertical",
    LeftDiagonal = "leftdiagonal",
    RightDiagonal = "rightdiagonal",
    Up = "up",
    Wait = "wait",
    None = "none"
}

_G.Enum = setmetatable(Enum, {
    __newindex = function()
        error("Attempt to modify read-only table: 'Enum'")
    end
})
