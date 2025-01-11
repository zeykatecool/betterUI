function _G.hex(d)
    if type(d) ~= "string" then
        return d
    end
    if d:find("#") == 1 then
        d = d:sub(2)
    end
    local h = "0x"..d
    if #d == 6 then
        return tonumber(h)
    else
        return 0x000000
    end
end

function _G.hexA(d)
    if type(d) ~= "string" then
        return d
    end
     if d:find("#") == 1 then
        d = d:sub(2)
    end
    local h = "0x"..d
    if #d == 6 then
        h = h .. "FF"
        return tonumber(h)
    end
    if #d == 8 then
        return tonumber(h)
    else
        return 0x000000FF
    end
end


_G.Color = {}

function Color.fromRGBA(R,G,B,A)
    return (R << 24) | (G << 16) | (B << 8) | math.floor(A)
end

function Color.fromHEX(hex)
    return hexA(hex)
end