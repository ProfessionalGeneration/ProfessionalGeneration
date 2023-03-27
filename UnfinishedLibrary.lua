local Dinstance, Funcs = loadstring(syn.request({Url = "https://raw.githubusercontent.com/GFXTI/ProfessionalGeneration/main/SchoolProject.lua"}).Body)()
local IsInFrame, DeltaIter, GetTextSize, Lerp, GetActualPosition = Funcs.IsInFrame, Funcs.DeltaIter, Funcs.GetTextSize, Funcs.Lerp, Funcs.GetActualPosition
local sv, lib = {
    uis = cloneref(game:service "UserInputService"),
    run = cloneref(game:service "RunService"),
}, {
    Accent = Color3.new(0.1, .1, .1),
    Font = Drawing.Fonts.Monospace
}

function lib:Interface(UISettings)
    local ui = {}
    local tabs = {}
    local tabinc = 0

    local main = Dinstance.new "Gradient"
    local box = Dinstance.new "Gradient"
    local title = Dinstance.new "Text"
    local tabholder = Dinstance.new "Gradient"
    local logo

    main.Position = (cloneref(workspace.CurrentCamera).ViewportSize / 2) - Vector2.new(550 / 2, 700 / 2)
    main.Size = Vector2.new(550, 700)
    main.Visible = true
    main.Outline = true
    main.OutlineColor = lib.Accent
    main.Color = Color3.new(.15, .15, .15)
    main.Drag = true

    box.Parent = main
    box.Visible = true
    box.Outline = true
    box.OutlineColor = lib.Accent
    box.Position = Vector2.new(3, 3)
    box.Color = Color3.new(.15, .15, .15)
    box.Size = Vector2.new(544, 694)

    title.Parent = box
    title.Visible = true
    title.Outline = true
    title.Color = Color3.new(1, 1, 1)
    title.Position = Vector2.new(2 + (UISettings.Logo and 22 or 0))
    title.Size = 18
    title.Font = lib.Font
    title.Text = UISettings.Name

    tabholder.Parent = box
    tabholder.Visible = true
    tabholder.Position = Vector2.new(3, 25)
    tabholder.Size = Vector2.new(538, 40)
    tabholder.Outline = true
    tabholder.Color = Color3.new(.15, .15, .15)
    tabholder.OutlineColor = lib.Accent

    if UISettings.Logo then
        logo = Dinstance.new "Image"

        logo.Parent = box
        logo.Visible = true
        logo.Position = Vector2.new(2, 2)
        logo.Size = Vector2.new(16, 16)
        logo.__frames.Main.Data = UISettings.Logo -- fuck you luau
    end

    function ui:Tab(TabSettings)
        local tab = {}
        local subtableft = {}
        local subtabright = {}
        local stinc = 0

        local tbox = Dinstance.new "Gradient"
        tbox.Parent = box
        tbox.Position = Vector2.new(3, 69)
        tbox.Size = Vector2.new(538, 622)
        tbox.Outline = true
        tbox.Color = Color3.new(.15, .15, .15)
        tbox.OutlineColor = lib.Accent
        tbox.Visible = tabinc == 0

        do
            local addx = 4

            for i,v in tabs do
                addx += type(v) == "number" and v or GetTextSize(v, 18, lib.Font).X + 6
            end

            local tc = Dinstance.new "Gradient"

            tc.Parent = tabholder
            tc.Visible = true
            tc.Position = Vector2.new(addx, 4)
            tc.Color = tabinc == 0 and Color3.new(.22, .22, .22) or Color3.new(.15, .15, .15)
            tc.Outline = true
            tc.OutlineColor = lib.Accent
            tc.Active = true

            if TabSettings.Name then
                local tct = Dinstance.new "Text"

                tct.Parent = tc
                tct.Visible = true
                tct.Position = Vector2.new(2, 6)
                tct.Outline = true
                tct.Size = 18
                tct.Font = lib.Font
                tct.Text = TabSettings.Name
                tct.Color = Color3.new(1, 1, 1)
            end

            if TabSettings.Name then
                tc.Size = Vector2.new(GetTextSize(TabSettings.Name, 18, lib.Font).X + 6, 32)
            end
        end

        function tab:Subtab(SubtabSettings)
            local subtab = {}
            stinc += 1
            local stabi = stinc

            local addy = 4
            local x = 3 + (stabi % 2 == 0 and (538 / 2) - 1 or 0)

            for i,v in tbox:Children() do
                if v.Position.X ~= x then continue end
                addy += v.Size.Y + 4
            end

            local subframe = Dinstance.new "Gradient"

            subframe.Parent = tbox
            subframe.Position = Vector2.new(x, addy)
            subframe.Visible = true
            subframe.Outline = true
            subframe.OutlineColor = lib.Accent
            subframe.Color = Color3.new(.15, .15, .15)

            if SubtabSettings.Name then
                local sft = Dinstance.new "Text"

                sft.Parent = subframe
                sft.Visible = true
                sft.Position = Vector2.new(2)
                sft.Outline = true
                sft.Size = 18
                sft.Font = lib.Font
                sft.Text = SubtabSettings.Name
                sft.Color = Color3.new(1, 1, 1)
            end

            local function Update()
                local framesize =  4 * #subframe:Children()
                local oldsize = subframe.Size.Y
                for i,v in subframe:Children() do
                    framesize += v.Text and v.__frames.Main.TextBounds.Y or v.To and v.Size or v.Size.Y
                end

                subframe.Size = Vector2.new((538 / 2) - 5, framesize)

                for i,v in (stabi % 2 == 0 and subtableft or subtabright) do
                    if i <= stabi then continue end

                    v.Position += Vector2.new(0, framesize - oldsize)
                end
            end

            local function GetLastFramePosY()
                local y = 0

                for i,v in subframe:Children() do
                    local size = v.Text and v.__frames.Main.TextBounds.Y or v.To and v.Size or v.Size.Y

                    if v.Position.Y + size > y then
                        y = v.Position.Y + size
                    end
                end

                return y
            end

            Update();
            (stabi % 2 == 0 and subtableft or subtabright)[stabi] = subframe

            function subtab:Button(ButtonSettings)
                local button = {}

                local bf = Dinstance.new "Gradient"
                local bt = Dinstance.new "Text"

                bf.Visible = true
                bf.Position = Vector2.new(4, GetLastFramePosY() + 4)
                bf.Size = Vector2.new(subframe.Size.X - 8, 15)
                bf.Active = true
                bf.Color = Color3.new(.15, .15, .15)
                bf.Outline = true
                bf.OutlineColor = lib.Accent
                bf.Parent = subframe

                bt.Visible = true
                bt.Position = Vector2.new(2, -2)
                bt.Parent = bf
                bt.Font = lib.Font
                bt.Size = 18
                bt.Text = ButtonSettings.Name
                bt.Color = ButtonSettings.Locked and Color3.new(.5, .5, .5) or Color3.new(1, 1, 1)
                bt.Outline = true

                function button:Edit(NewButtonSettings)
                    for i,v in NewButtonSettings do
                        ButtonSettings[i] = v
                    end

                    bt.Color = ButtonSettings.Locked and Color3.new(.5, .5, .5) or Color3.new(1, 1, 1)
                    bt.Text = ButtonSettings.Name
                end

                bf.Mouse1Click:Connect(function()
                    if ButtonSettings.Locked then return end
                    local c
                    bf.Color = Color3.new(.12, .12, .12)

                    c = sv.uis.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            c:Disconnect()

                            bf.Color = Color3.new(.15, .15, .15)
                        end
                    end)

                    task.spawn(ButtonSettings.Callback)
                end)

                Update()

                return button
            end

            function subtab:Toggle(ToggleSettings)
                local toggle = {}
                local ctick = tick()

                local tf = Dinstance.new "Gradient"
                local tt = Dinstance.new "Text"
                local togbox = Dinstance.new "Frame"

                tf.Visible = true
                tf.Position = Vector2.new(4, GetLastFramePosY() + 4)
                tf.Size = Vector2.new(subframe.Size.X - 8, 15)
                tf.Color = Color3.new(.15, .15, .15)
                tf.Outline = true
                tf.OutlineColor = lib.Accent
                tf.Parent = subframe

                tt.Visible = true
                tt.Position = Vector2.new(17, -2)
                tt.Parent = tf
                tt.Font = lib.Font
                tt.Size = 18
                tt.Text = ToggleSettings.Name
                tt.Color = ToggleSettings.Locked and Color3.new(.5, .5, .5) or Color3.new(1, 1, 1)
                tt.Outline = true

                togbox.Visible = true
                togbox.Position = Vector2.new(4, 4)
                togbox.Size = Vector2.new(9, 9)
                togbox.Color = ToggleSettings.Enabled and Color3.new(0, .8, 0) or Color3.new(.8, 0, 0)
                togbox.Outline = true
                togbox.Active = true
                togbox.OutlineColor = lib.Accent
                togbox.Parent = tf

                function toggle:Edit(NewToggleSettings)
                    for i,v in NewToggleSettings do
                        ToggleSettings[i] = v
                    end

                    tt.Color = ToggleSettings.Locked and Color3.new(.5, .5, .5) or Color3.new(1, 1, 1)
                    tt.Text = ToggleSettings.Name
                    togbox.Color = ToggleSettings.Enabled and Color3.new(0, .8, 0) or Color3.new(.8, 0, 0)
                end

                togbox.Mouse1Click:Connect(function()
                    if ToggleSettings.Locked or tick() - ctick <= .15 then return end
                    ctick = tick()
                    ToggleSettings.Enabled = not ToggleSettings.Enabled

                    task.spawn(togbox.Tween, togbox, TweenInfo.new(.15), {
                        Color = ToggleSettings.Enabled and Color3.new(0, .8, 0) or Color3.new(.8, 0, 0)
                    })
                    task.spawn(ToggleSettings.Callback, ToggleSettings.Enabled)
                end)

                Update()

                return toggle
            end

            function subtab:Slider(SliderSettings)
                local slider = {}
                local size = subframe.Size.X - 8
                local start = (1 - ((SliderSettings.Max - (SliderSettings.Default or Lerp(SliderSettings.Min, SliderSettings.Max, .5))) / (SliderSettings.Max - SliderSettings.Min))) * size
                local con

                local sf = Dinstance.new "Gradient"
                local d = Dinstance.new "Gradient"
                local st = Dinstance.new "Text"

                sf.Visible = true
                sf.Position = Vector2.new(4, GetLastFramePosY() + 4)
                sf.Size = Vector2.new(subframe.Size.X - 8, 15)
                sf.Active = true
                sf.Color = Color3.new(.15, .15, .15)
                sf.Outline = true
                sf.OutlineColor = lib.Accent
                sf.Parent = subframe

                d.Visible = true
                d.Position = Vector2.zero
                d.Size = Vector2.new(start, 15)
                d.Color = Color3.new(0, .4, .8)
                d.Parent = sf

                st.Visible = true
                st.Position = Vector2.new(2, -2)
                st.Parent = sf
                st.Font = lib.Font
                st.Size = 18
                st.Text = ("%s: %i%s"):format(SliderSettings.Name, SliderSettings.Default or Lerp(SliderSettings.Min, SliderSettings.Max, .5), SliderSettings.Suffix or "")
                st.Color = SliderSettings.Locked and Color3.new(.5, .5, .5) or Color3.new(1, 1, 1)
                st.Outline = true

                sf.Mouse1Click:Connect(function()
                    if SliderSettings.Locked then return end

                    if con then
                        con:Disconnect()
                    end

                    con = sv.uis.InputChanged:Connect(function()
                        local p = math.clamp((sv.uis:GetMouseLocation().X - GetActualPosition(sf).X) / sf.Size.X, 0, 1)
					    local vtn = Lerp(SliderSettings.Min, SliderSettings.Max, p)

                        vtn = SliderSettings.Precise and tonumber(("%.2f"):format(vtn)) or math.round(vtn)
                        start = vtn
                        st.Text = ("%s: %i%s"):format(SliderSettings.Name, vtn, SliderSettings.Suffix or "")
                        d.Size = Vector2.new(p * size > 1 and p * size or 1, 15)
                        task.spawn(SliderSettings.Callback, vtn)
                    end)
                end)

                sv.uis.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if con then
                            con:Disconnect()
                        end
                    end
                end)

                function slider:Edit(NewSliderSettings)
                    for i,v in NewSliderSettings do
                        SliderSettings[i] = v
                    end

                    start = (1 - ((SliderSettings.Max - (SliderSettings.Default or start)) / (SliderSettings.Max - SliderSettings.Min))) * size
                    st.Color = SliderSettings.Locked and Color3.new(.5, .5, .5) or Color3.new(1, 1, 1)
                    st.Text = ("%s: %i%s"):format(SliderSettings.Name, start, SliderSettings.Suffix or "")
                    d.Size = Vector2.new(start, 15)
                end

                Update()

                return slider
            end

            return subtab
        end

        tabs[TabSettings] = TabSettings.Name or 38
        tabinc += 1

        return tab
    end

    task.delay(10, main.Destroy, main)

    return ui
end

local interface = lib:Interface {
    Name = "Professional Generation",
    Logo = syn.request {Url = "https://cdn.discordapp.com/attachments/907173542972502072/1081826251758653540/1f602.png"}.Body
}

local tab1 = interface:Tab {
    Name = "Tab 1"
}

local sub1 = tab1:Subtab {
    Name = "Subtab 1"
}

sub1:Button {
    Name = "Button",
    Callback = print
}

sub1:Button {
    Name = "Locked button",
    Locked = true,
    Callback = print
}

sub1:Toggle {
    Name = "Enabled toggle",
    Callback = print,
    Enabled = true,
}

sub1:Toggle {
    Name = "Disabled toggle",
    Callback = print,
}

sub1:Slider {
    Name = "Slider",
    Suffix = "px",
    Min = 0,
    Max = 100,
    Precise = true,
    Callback = print,
}

local sub2 = tab1:Subtab {
    Name = "Subtab 2"
}

local sub3 = tab1:Subtab {
    Name = "Subtab 3"
}

return lib
