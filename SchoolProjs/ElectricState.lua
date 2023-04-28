-- this is all theory it most likely dont work, there isnt even syntax errors on github.dev :(

Main:Toggle("Anti void", false, function(toggle) 
    Settings.AntiVoid = toggle
end)

Main:Toggle("Infinite jump", false, function(toggle) 
    Settings.InfiniteJump = toggle
end)

Services.Input.InputBegan:Connect(function(input, ret)
    if ret then return end

    if input.KeyCode == Enum.KeyCode.Space then
        while Services.Input:IsKeyDown(Enum.KeyCode.Space) do
            if not lp.Character or not lp.Character:findFirstChild "Humanoid" then continue end

            lp.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end

        return
    end
end)

lp.CharacterAdded:Connect(function(character) 
    local hrp, hum, backpack = character:waitForChild "HumanoidRootPart", character:waitForChild "Humanoid", lp:waitForChild "Backpack"

    
end)