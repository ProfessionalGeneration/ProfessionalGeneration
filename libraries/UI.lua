-- v3 isnt updated.... this is a whole new challenge
local UIs = {}
local Get, Directory, File = loadfile("Progen/libraries/FileSystem.lua")()
local Libraries = Get:Get"libraries"
local Services, Draw, DrawObjects, Easing, Math, Tween = Libraries:Get"Services":Load(), Libraries:Get"Draw":Load(), Libraries:Get"DrawObjects":Load(), Libraries:Get"Easing":Load(), Libraries:Get"Math":Load(), Libraries:Get"Tween":Load() -- lmao wtf

local Interactables = {}
Interactables.__index = Interactables

function Interactables:Button(frame)
    local ButtonFrame = DrawObjects.Frame()

    
end


return UIs