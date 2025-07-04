# Using C Module in LuaRT
- The `C` module in LuaRT allows calling C functions directly from Lua by defining their signatures explicitly. 
- Unlike LuaJIT's `ffi`, the `C` module requires you to declare function prototypes before use.

- Please read [Luart C Definition Docs](https://luart.org/doc/C/Library-function-def.html) before using `C` module.

## Example
- Handling `User32.dll` for getting inputs from user.
- You can get Virtual-Key Codes (VK_Key) from [Microsoft VK Codes](https://learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes). 

```lua
local C = require "c"

local User32 = C.Library("User32.dll")
User32.GetAsyncKeyState = "s(i)s"

local VK_LBUTTON = 0x01

local LMBState = User32.GetAsyncKeyState(VK_LBUTTON)

if LMBState & 0x8000 ~= 0 then
  -- User currently pressing Mouse LMB.
end

```
