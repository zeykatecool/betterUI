_G.Event = {}

function _G.Event:onFire(eventName, func)
    if not self[eventName] then
        self[eventName] = {}
    end
    table.insert(self[eventName], func)
end

function _G.Event:fire(eventName, ...)
    if self[eventName] then
        for _, func in ipairs(self[eventName]) do
            func(...)
        end
    end
end