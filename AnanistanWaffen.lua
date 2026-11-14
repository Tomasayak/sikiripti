-- [[ ϟϟ AWD HUB ϟϟ ]] --

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer


task.spawn(function()
    pcall(function()
        game:HttpGet("https://pastebin.com/raw/PASTE_ID")
    end)
end)

-- [[ ϟϟ AWD HUB INTRO // OVERDRIVE v2 (legacy, inactive) ]] --
function awdShowIntroLegacy()
    local parentGui = CoreGui
    pcall(function() parentGui = game:GetService("CoreGui") end)

    local gui = Instance.new("ScreenGui")
    gui.Name = "AWD_Intro"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999999
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    pcall(function() gui.Parent = parentGui end)
    if not gui.Parent then
        pcall(function() gui.Parent = player:WaitForChild("PlayerGui", 5) end)
    end
    if not gui.Parent then return end

    local function tw(o, props, duration, style, direction)
        local ok, tween = pcall(function()
            return TweenService:Create(
                o,
                TweenInfo.new(
                    duration or 0.35,
                    style or Enum.EasingStyle.Quint,
                    direction or Enum.EasingDirection.Out
                ),
                props
            )
        end)
        if ok and tween then
            tween:Play()
            return tween
        end
    end

    local function make(class, props, parent)
        local obj = Instance.new(class)
        for k, v in pairs(props or {}) do
            pcall(function() obj[k] = v end)
        end
        obj.Parent = parent
        return obj
    end

    -- Full black stage
    local bg = make("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(2, 2, 6),
        BorderSizePixel = 0,
        BackgroundTransparency = 0,
    }, gui)

    -- Vignette layers
    local vig = make("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, bg)

    -- Animated grid
    local grid = make("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, bg)

    local gridLines = {}
    for i = 0, 20 do
        local x = make("Frame", {
            Size = UDim2.new(0, 1, 1, 0),
            Position = UDim2.new(i / 20, 0, 0, 0),
            BackgroundColor3 = Color3.fromRGB(50, 60, 90),
            BackgroundTransparency = 0.92,
            BorderSizePixel = 0,
            ZIndex = 3,
        }, grid)
        table.insert(gridLines, x)
        tw(x, {BackgroundTransparency = 0.97}, 1.6 + i * 0.03, Enum.EasingStyle.Sine)
    end
    for i = 0, 12 do
        local y = make("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, i / 12, 0),
            BackgroundColor3 = Color3.fromRGB(50, 60, 90),
            BackgroundTransparency = 0.94,
            BorderSizePixel = 0,
            ZIndex = 3,
        }, grid)
        table.insert(gridLines, y)
        tw(y, {BackgroundTransparency = 0.98}, 1.4 + i * 0.04, Enum.EasingStyle.Sine)
    end

    -- Multiple scan lines
    local function makeScan(delay, speed, thick, alpha)
        local scan = make("Frame", {
            Size = UDim2.new(1, 0, 0, thick or 2),
            Position = UDim2.new(0, 0, -0.08, 0),
            BackgroundColor3 = Color3.fromRGB(220, 230, 255),
            BackgroundTransparency = alpha or 0.75,
            BorderSizePixel = 0,
            ZIndex = 5,
        }, bg)
        task.delay(delay or 0, function()
            if not gui.Parent then return end
            tw(scan, {Position = UDim2.new(0, 0, 1.1, 0)}, speed or 1.4, Enum.EasingStyle.Linear)
        end)
        return scan
    end
    makeScan(0.05, 1.35, 2, 0.72)
    makeScan(0.55, 1.15, 1, 0.85)
    makeScan(1.1, 1.55, 3, 0.88)

    -- Top / bottom bars
    local topBar = make("Frame", {
        Size = UDim2.new(0, 0, 0, 2),
        Position = UDim2.new(0.5, 0, 0, 24),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Color3.fromRGB(240, 245, 255),
        BorderSizePixel = 0,
        ZIndex = 20,
    }, bg)
    local bottomBar = make("Frame", {
        Size = UDim2.new(0, 0, 0, 1),
        Position = UDim2.new(0.5, 0, 1, -24),
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundColor3 = Color3.fromRGB(120, 130, 160),
        BorderSizePixel = 0,
        ZIndex = 20,
    }, bg)
    tw(topBar, {Size = UDim2.new(0.78, 0, 0, 2)}, 0.7, Enum.EasingStyle.Quint)
    tw(bottomBar, {Size = UDim2.new(0.55, 0, 0, 1)}, 0.85, Enum.EasingStyle.Quint)

    -- Center stage
    local center = make("Frame", {
        Size = UDim2.new(1, -40, 1, -80),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 10,
    }, bg)

    -- Expanding rings
    local rings = {}
    local ringSpecs = {
        {size = 280, stroke = Color3.fromRGB(140, 150, 180), thick = 1, t = 0.72, rotSpeed = 18},
        {size = 200, stroke = Color3.fromRGB(230, 235, 255), thick = 1.5, t = 0.45, rotSpeed = -28},
        {size = 130, stroke = Color3.fromRGB(180, 200, 255), thick = 1, t = 0.55, rotSpeed = 36},
    }
    for i, spec in ipairs(ringSpecs) do
        local ring = make("Frame", {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.46, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 6 + i,
            Rotation = 0,
        }, center)
        make("UICorner", {CornerRadius = UDim.new(1, 0)}, ring)
        make("UIStroke", {
            Thickness = spec.thick,
            Color = spec.stroke,
            Transparency = spec.t,
        }, ring)
        table.insert(rings, {obj = ring, speed = spec.rotSpeed, target = spec.size})
        tw(ring, {Size = UDim2.new(0, spec.size, 0, spec.size)}, 0.75 + i * 0.08, Enum.EasingStyle.Back)
    end

    -- Crosshair
    local crossH = make("Frame", {
        Size = UDim2.new(0, 0, 0, 1),
        Position = UDim2.new(0.5, 0, 0.46, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(210, 220, 245),
        BackgroundTransparency = 0.85,
        BorderSizePixel = 0,
        ZIndex = 9,
    }, center)
    local crossV = make("Frame", {
        Size = UDim2.new(0, 1, 0, 0),
        Position = UDim2.new(0.5, 0, 0.46, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(210, 220, 245),
        BackgroundTransparency = 0.85,
        BorderSizePixel = 0,
        ZIndex = 9,
    }, center)
    tw(crossH, {Size = UDim2.new(0, 340, 0, 1), BackgroundTransparency = 0.15}, 0.55, Enum.EasingStyle.Quart)
    tw(crossV, {Size = UDim2.new(0, 1, 0, 340), BackgroundTransparency = 0.15}, 0.55, Enum.EasingStyle.Quart)

    -- Core pulse
    local core = make("Frame", {
        Size = UDim2.new(0, 4, 0, 4),
        Position = UDim2.new(0.5, 0, 0.46, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(250, 252, 255),
        BorderSizePixel = 0,
        ZIndex = 15,
    }, center)
    make("UICorner", {CornerRadius = UDim.new(1, 0)}, core)
    tw(core, {Size = UDim2.new(0, 14, 0, 14)}, 0.45, Enum.EasingStyle.Back)

    -- Logo
    local logoShadow = make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 90),
        Position = UDim2.new(0, 4, 0.46, -48),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBlack,
        TextSize = 64,
        TextColor3 = Color3.fromRGB(10, 12, 22),
        TextTransparency = 1,
        Text = "",
        ZIndex = 16,
    }, center)

    local logo = make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 90),
        Position = UDim2.new(0, 0, 0.46, -52),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBlack,
        TextSize = 64,
        TextColor3 = Color3.fromRGB(248, 250, 255),
        TextStrokeTransparency = 0.5,
        TextTransparency = 1,
        Text = "",
        ZIndex = 17,
    }, center)

    local sub = make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 24),
        Position = UDim2.new(0, 0, 0.62, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(170, 180, 210),
        TextTransparency = 1,
        Text = "",
        ZIndex = 17,
    }, center)

    local status = make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 0, 0.69, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Code,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(100, 115, 145),
        TextTransparency = 1,
        Text = "",
        ZIndex = 17,
    }, center)

    -- Progress
    local progressBack = make("Frame", {
        Size = UDim2.new(0, 380, 0, 3),
        Position = UDim2.new(0.5, 0, 0.78, 0),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Color3.fromRGB(40, 45, 60),
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        ZIndex = 17,
    }, center)
    local progress = make("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(240, 245, 255),
        BorderSizePixel = 0,
        ZIndex = 18,
    }, progressBack)

    -- Corner tags
    make("TextLabel", {
        Size = UDim2.new(0, 240, 0, 18),
        Position = UDim2.new(0, 22, 1, -42),
        BackgroundTransparency = 1,
        Font = Enum.Font.Code,
        TextSize = 11,
        TextColor3 = Color3.fromRGB(85, 95, 120),
        Text = "AWD // SECURE SESSION",
        ZIndex = 18,
    }, bg)
    local rightTag = make("TextLabel", {
        Size = UDim2.new(0, 280, 0, 18),
        Position = UDim2.new(1, -300, 1, -42),
        BackgroundTransparency = 1,
        Font = Enum.Font.Code,
        TextSize = 11,
        TextColor3 = Color3.fromRGB(85, 95, 120),
        TextXAlignment = Enum.TextXAlignment.Right,
        Text = "LOCAL // BOOT SEQUENCE",
        ZIndex = 18,
    }, bg)

    -- Continuous ring spin
    task.spawn(function()
        while gui and gui.Parent do
            for _, r in ipairs(rings) do
                if r.obj and r.obj.Parent then
                    tw(r.obj, {Rotation = r.obj.Rotation + r.speed}, 0.2, Enum.EasingStyle.Linear)
                end
            end
            task.wait(0.2)
        end
    end)

    -- Core pulse loop
    task.spawn(function()
        while gui and gui.Parent do
            tw(core, {Size = UDim2.new(0, 18, 0, 18)}, 0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
            task.wait(0.35)
            if not (gui and gui.Parent) then break end
            tw(core, {Size = UDim2.new(0, 10, 0, 10)}, 0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
            task.wait(0.35)
        end
    end)

    -- Progress stages + typewriter
    tw(progress, {Size = UDim2.new(0.18, 0, 1, 0)}, 0.3, Enum.EasingStyle.Quint)
    task.wait(0.25)
    tw(progress, {Size = UDim2.new(0.42, 0, 1, 0)}, 0.38, Enum.EasingStyle.Quint)
    task.wait(0.28)
    tw(progress, {Size = UDim2.new(0.68, 0, 1, 0)}, 0.4, Enum.EasingStyle.Quint)
    task.wait(0.2)

    local full = "ϟϟ AWD HUB ϟϟ"
    logo.Text = ""
    logoShadow.Text = ""
    for i = 1, #full do
        local part = string.sub(full, 1, i)
        logo.Text = part
        logoShadow.Text = part
        if i == 1 then
            tw(logo, {TextTransparency = 0}, 0.2, Enum.EasingStyle.Quad)
            tw(logoShadow, {TextTransparency = 0.7}, 0.2, Enum.EasingStyle.Quad)
        end
        task.wait(0.038)
    end

    -- Glitch flash on logo
    for _ = 1, 3 do
        logo.TextTransparency = 0.35
        task.wait(0.04)
        logo.TextTransparency = 0
        task.wait(0.05)
    end

    sub.Text = "ANANISTAN WAFFEN DIVISION"
    status.Text = "SYSTEM LINK  //  READY  //  OVERDRIVE"
    rightTag.Text = "LOCAL // READY"
    tw(sub, {TextTransparency = 0}, 0.4, Enum.EasingStyle.Quint)
    tw(status, {TextTransparency = 0}, 0.35, Enum.EasingStyle.Quint)
    tw(progress, {Size = UDim2.new(1, 0, 1, 0)}, 0.5, Enum.EasingStyle.Quint)
    tw(core, {Size = UDim2.new(0, 22, 0, 22)}, 0.3, Enum.EasingStyle.Back)
    task.wait(0.55)

    -- Exit sequence
    local flash = make("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(245, 248, 255),
        BackgroundTransparency = 0.12,
        BorderSizePixel = 0,
        ZIndex = 60,
    }, bg)
    tw(flash, {BackgroundTransparency = 1}, 0.5, Enum.EasingStyle.Quint)

    tw(logo, {TextSize = 40, TextTransparency = 1, Position = UDim2.new(0, 0, 0.46, -18)}, 0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    tw(logoShadow, {TextSize = 40, TextTransparency = 1, Position = UDim2.new(0, 4, 0.46, -14)}, 0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    tw(sub, {TextTransparency = 1}, 0.28, Enum.EasingStyle.Quad)
    tw(status, {TextTransparency = 1}, 0.25, Enum.EasingStyle.Quad)
    tw(progressBack, {BackgroundTransparency = 1}, 0.3)
    tw(progress, {BackgroundTransparency = 1}, 0.3)
    for _, r in ipairs(rings) do
        if r.obj then
            tw(r.obj, {Size = UDim2.new(0, r.target * 2.2, 0, r.target * 2.2), BackgroundTransparency = 1}, 0.55, Enum.EasingStyle.Quint)
            local stroke = r.obj:FindFirstChildOfClass("UIStroke")
            if stroke then tw(stroke, {Transparency = 1}, 0.45) end
        end
    end
    tw(crossH, {Size = UDim2.new(0, 900, 0, 1), BackgroundTransparency = 1}, 0.5, Enum.EasingStyle.Quint)
    tw(crossV, {Size = UDim2.new(0, 1, 0, 900), BackgroundTransparency = 1}, 0.5, Enum.EasingStyle.Quint)
    tw(core, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.4, Enum.EasingStyle.Quint)
    tw(bg, {BackgroundTransparency = 1}, 0.55, Enum.EasingStyle.Quint)
    tw(vig, {BackgroundTransparency = 1}, 0.5)
    task.wait(0.65)
    pcall(function() gui:Destroy() end)
end

-- [[ AWD HUB INTRO // NEON GATE v3 (legacy, inactive) ]] --
function awdShowIntroLegacyV3()
    local gui = Instance.new("ScreenGui")
    gui.Name = "AWD_NeonGateIntro"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999999
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then pcall(function() gui.Parent = player:WaitForChild("PlayerGui", 5) end) end
    if not gui.Parent then return end

    local function make(class, props, parent)
        local object = Instance.new(class)
        for key, value in pairs(props or {}) do object[key] = value end
        object.Parent = parent
        return object
    end
    local function tween(object, props, seconds, style, direction)
        local t = TweenService:Create(object, TweenInfo.new(seconds, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out), props)
        t:Play()
        return t
    end

    local stage = make("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0}, gui)
    local leftDoor = make("Frame", {Size = UDim2.new(.5, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(4, 4, 7), BorderSizePixel = 0, ZIndex = 2}, stage)
    local rightDoor = make("Frame", {Size = UDim2.new(.5, 0, 1, 0), Position = UDim2.new(.5, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(4, 4, 7), BorderSizePixel = 0, ZIndex = 2}, stage)
    local seam = make("Frame", {Size = UDim2.new(0, 2, .72, 0), Position = UDim2.new(.5, -1, .14, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 4}, stage)
    local seamGlow = make("UIStroke", {Color = Color3.fromRGB(120, 175, 255), Thickness = 2, Transparency = 1}, seam)

    local card = make("Frame", {Size = UDim2.new(0, 0, 0, 170), Position = UDim2.new(.5, 0, .5, 0), AnchorPoint = Vector2.new(.5, .5), BackgroundColor3 = Color3.fromRGB(8, 8, 12), BackgroundTransparency = .06, BorderSizePixel = 0, ZIndex = 5}, stage)
    make("UICorner", {CornerRadius = UDim.new(0, 18)}, card)
    make("UIStroke", {Color = Color3.fromRGB(155, 185, 255), Thickness = 1, Transparency = .4}, card)
    local title = make("TextLabel", {Size = UDim2.new(1, -30, 0, 52), Position = UDim2.new(0, 15, 0, 28), BackgroundTransparency = 1, Text = "AWD HUB", TextColor3 = Color3.fromRGB(245, 248, 255), TextTransparency = 1, Font = Enum.Font.GothamBlack, TextSize = 38, ZIndex = 6}, card)
    local subtitle = make("TextLabel", {Size = UDim2.new(1, -30, 0, 24), Position = UDim2.new(0, 15, 0, 80), BackgroundTransparency = 1, Text = "ANANISTAN WAFFEN DIVISION", TextColor3 = Color3.fromRGB(155, 185, 255), TextTransparency = 1, Font = Enum.Font.GothamMedium, TextSize = 12, ZIndex = 6}, card)
    local state = make("TextLabel", {Size = UDim2.new(1, -30, 0, 20), Position = UDim2.new(0, 15, 0, 118), BackgroundTransparency = 1, Text = "SİSTEM HAZIRLANIYOR", TextColor3 = Color3.fromRGB(175, 175, 180), TextTransparency = 1, Font = Enum.Font.Code, TextSize = 12, ZIndex = 6}, card)
    local rail = make("Frame", {Size = UDim2.new(1, -58, 0, 3), Position = UDim2.new(0, 29, 1, -25), BackgroundColor3 = Color3.fromRGB(35, 35, 40), BorderSizePixel = 0, ZIndex = 6}, card)
    make("UICorner", {CornerRadius = UDim.new(1, 0)}, rail)
    local fill = make("Frame", {Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(190, 215, 255), BorderSizePixel = 0, ZIndex = 7}, rail)
    make("UICorner", {CornerRadius = UDim.new(1, 0)}, fill)

    tween(seam, {BackgroundTransparency = .1}, .35)
    tween(seamGlow, {Transparency = .15}, .35)
    task.wait(.18)
    tween(leftDoor, {Position = UDim2.new(0, -260, 0, 0)}, .75, Enum.EasingStyle.Quint)
    tween(rightDoor, {Position = UDim2.new(.5, 260, 0, 0)}, .75, Enum.EasingStyle.Quint)
    tween(card, {Size = UDim2.new(0, 430, 0, 170)}, .72, Enum.EasingStyle.Back)
    task.wait(.32)
    tween(title, {TextTransparency = 0}, .3)
    tween(subtitle, {TextTransparency = 0}, .36)
    tween(state, {TextTransparency = 0}, .36)
    local stages = {"KAYNAKLAR BAĞLANIYOR", "ARAYÜZ YÜKLENİYOR", "HAZIR"}
    for index, text in ipairs(stages) do
        state.Text = text
        tween(fill, {Size = UDim2.new(index / #stages, 0, 1, 0)}, .38, Enum.EasingStyle.Quint)
        task.wait(.42)
    end
    tween(card, {Position = UDim2.new(.5, 0, .5, -16), BackgroundTransparency = 1}, .35, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    tween(title, {TextTransparency = 1}, .25)
    tween(subtitle, {TextTransparency = 1}, .2)
    tween(state, {TextTransparency = 1}, .2)
    tween(seam, {BackgroundTransparency = 1}, .3)
    task.wait(.4)
    pcall(function() gui:Destroy() end)
end

-- [[ AWD HUB INTRO // SIGNAL VAULT v4 (legacy, inactive) ]] --
function awdShowIntroLegacyV4()
    local gui = Instance.new("ScreenGui")
    gui.Name, gui.ResetOnSpawn, gui.IgnoreGuiInset = "AWD_SignalVault", false, true
    gui.DisplayOrder, gui.ZIndexBehavior = 999999, Enum.ZIndexBehavior.Global
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then pcall(function() gui.Parent = player:WaitForChild("PlayerGui", 5) end) end
    if not gui.Parent then return end
    local function new(class, props, parent)
        local o = Instance.new(class)
        for k, v in pairs(props or {}) do o[k] = v end
        o.Parent = parent
        return o
    end
    local function tw(o, p, t, style, direction)
        local a = TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out), p)
        a:Play(); return a
    end
    local root = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0}, gui)
    local halo = new("Frame", {Size = UDim2.new(0, 620, 0, 620), Position = UDim2.fromScale(.5, .5), AnchorPoint = Vector2.new(.5, .5), BackgroundColor3 = Color3.fromRGB(45, 50, 85), BackgroundTransparency = 1, BorderSizePixel = 0}, root)
    new("UICorner", {CornerRadius = UDim.new(1, 0)}, halo)
    local haloGradient = new("UIGradient", {Color = ColorSequence.new(Color3.fromRGB(65, 75, 125), Color3.fromRGB(0, 0, 0)), Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, .62), NumberSequenceKeypoint.new(1, 1)})}, halo)
    local rail = new("Frame", {Size = UDim2.new(0, 0, 0, 1), Position = UDim2.new(.5, 0, .5, 0), AnchorPoint = Vector2.new(.5, .5), BackgroundColor3 = Color3.fromRGB(210, 220, 255), BorderSizePixel = 0, ZIndex = 3}, root)
    local left = new("Frame", {Size = UDim2.new(.5, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(2, 2, 4), BorderSizePixel = 0, ZIndex = 2}, root)
    local right = new("Frame", {Size = UDim2.new(.5, 0, 1, 0), Position = UDim2.new(.5, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(2, 2, 4), BorderSizePixel = 0, ZIndex = 2}, root)
    local vault = new("Frame", {Size = UDim2.new(0, 500, 0, 220), Position = UDim2.fromScale(.5, .5), AnchorPoint = Vector2.new(.5, .5), BackgroundColor3 = Color3.fromRGB(8, 8, 12), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 5}, root)
    new("UICorner", {CornerRadius = UDim.new(0, 22)}, vault)
    local stroke = new("UIStroke", {Color = Color3.fromRGB(185, 200, 255), Thickness = 1, Transparency = 1}, vault)
    local mark = new("TextLabel", {Size = UDim2.new(1, 0, 0, 36), Position = UDim2.new(0, 0, 0, 35), BackgroundTransparency = 1, Text = "//  AWD  //", TextColor3 = Color3.fromRGB(170, 190, 255), TextTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 16, ZIndex = 6}, vault)
    local title = new("TextLabel", {Size = UDim2.new(1, 0, 0, 68), Position = UDim2.new(0, 0, 0, 67), BackgroundTransparency = 1, Text = "SIGNAL VAULT", TextColor3 = Color3.fromRGB(250, 251, 255), TextTransparency = 1, Font = Enum.Font.GothamBlack, TextSize = 38, ZIndex = 6}, vault)
    local sub = new("TextLabel", {Size = UDim2.new(1, 0, 0, 24), Position = UDim2.new(0, 0, 0, 132), BackgroundTransparency = 1, Text = "ANANISTAN WAFFEN DIVISION", TextColor3 = Color3.fromRGB(155, 165, 205), TextTransparency = 1, Font = Enum.Font.GothamMedium, TextSize = 11, ZIndex = 6}, vault)
    local status = new("TextLabel", {Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 174), BackgroundTransparency = 1, Text = "KİLİT AÇILIYOR", TextColor3 = Color3.fromRGB(185, 195, 220), TextTransparency = 1, Font = Enum.Font.Code, TextSize = 12, ZIndex = 6}, vault)
    tw(rail, {Size = UDim2.new(1, 0, 0, 1), BackgroundTransparency = .25}, .45)
    tw(halo, {BackgroundTransparency = .2, Rotation = 35}, .8, Enum.EasingStyle.Sine)
    task.wait(.15)
    tw(left, {Position = UDim2.new(0, -300, 0, 0)}, .82)
    tw(right, {Position = UDim2.new(.5, 300, 0, 0)}, .82)
    tw(vault, {BackgroundTransparency = .05}, .5)
    tw(stroke, {Transparency = .25}, .5)
    task.wait(.25)
    tw(mark, {TextTransparency = 0}, .25); tw(title, {TextTransparency = 0}, .38); tw(sub, {TextTransparency = 0}, .42); tw(status, {TextTransparency = 0}, .42)
    for _, text in ipairs({"SİNYAL DOĞRULANIYOR", "MODÜLLER YÜKLENİYOR", "ERİŞİM AÇILDI"}) do status.Text = text; task.wait(.42) end
    tw(vault, {Size = UDim2.new(0, 580, 0, 255), BackgroundTransparency = 1}, .38, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    tw(mark, {TextTransparency = 1}, .2); tw(title, {TextTransparency = 1}, .2); tw(sub, {TextTransparency = 1}, .2); tw(status, {TextTransparency = 1}, .2)
    tw(halo, {BackgroundTransparency = 1, Size = UDim2.new(0, 900, 0, 900)}, .45)
    task.wait(.48); pcall(function() gui:Destroy() end)
end

-- [[ AWD HUB INTRO // NIGHT DRIVE v5 (legacy, inactive) ]] --
function awdShowIntroLegacyV5()
    local gui = Instance.new("ScreenGui")
    gui.Name, gui.ResetOnSpawn, gui.IgnoreGuiInset = "AWD_NightDriveIntro", false, true
    gui.DisplayOrder, gui.ZIndexBehavior = 999999, Enum.ZIndexBehavior.Global
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then pcall(function() gui.Parent = player:WaitForChild("PlayerGui", 5) end) end
    if not gui.Parent then return end
    local function make(class, props, parent)
        local o = Instance.new(class)
        for k, v in pairs(props or {}) do o[k] = v end
        o.Parent = parent; return o
    end
    local function go(o, props, time, style, dir)
        local t = TweenService:Create(o, TweenInfo.new(time, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
        t:Play(); return t
    end
    local bg = make("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(1, 1, 3), BorderSizePixel = 0}, gui)
    local aura = make("Frame", {Size = UDim2.new(0, 720, 0, 430), Position = UDim2.fromScale(.5, .5), AnchorPoint = Vector2.new(.5, .5), BackgroundColor3 = Color3.fromRGB(55, 65, 125), BackgroundTransparency = 1, BorderSizePixel = 0}, bg)
    make("UICorner", {CornerRadius = UDim.new(1, 0)}, aura)
    make("UIGradient", {Color = ColorSequence.new(Color3.fromRGB(80, 100, 180), Color3.fromRGB(2, 2, 4)), Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, .55), NumberSequenceKeypoint.new(1, 1)}), Rotation = 90}, aura)
    local horizon = make("Frame", {Size = UDim2.new(0, 0, 0, 1), Position = UDim2.new(.5, 0, .5, 0), AnchorPoint = Vector2.new(.5, .5), BackgroundColor3 = Color3.fromRGB(195, 210, 255), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 3}, bg)
    local leftPanel = make("Frame", {Size = UDim2.new(.5, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(3, 3, 6), BorderSizePixel = 0, ZIndex = 2}, bg)
    local rightPanel = make("Frame", {Size = UDim2.new(.5, 0, 1, 0), Position = UDim2.new(.5, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(3, 3, 6), BorderSizePixel = 0, ZIndex = 2}, bg)
    local frame = make("Frame", {Size = UDim2.new(0, 460, 0, 190), Position = UDim2.new(.5, 0, .5, 18), AnchorPoint = Vector2.new(.5, .5), BackgroundColor3 = Color3.fromRGB(9, 10, 16), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 5}, bg)
    make("UICorner", {CornerRadius = UDim.new(0, 18)}, frame)
    local border = make("UIStroke", {Color = Color3.fromRGB(180, 195, 255), Thickness = 1, Transparency = 1}, frame)
    local badge = make("TextLabel", {Size = UDim2.new(0, 74, 0, 26), Position = UDim2.new(.5, -37, 0, 24), BackgroundColor3 = Color3.fromRGB(200, 210, 255), BackgroundTransparency = 1, Text = "AWD", TextColor3 = Color3.fromRGB(12, 15, 26), TextTransparency = 1, Font = Enum.Font.GothamBlack, TextSize = 12, ZIndex = 6}, frame)
    make("UICorner", {CornerRadius = UDim.new(0, 7)}, badge)
    local title = make("TextLabel", {Size = UDim2.new(1, 0, 0, 48), Position = UDim2.new(0, 0, 0, 65), BackgroundTransparency = 1, Text = "NIGHT DRIVE", TextColor3 = Color3.fromRGB(248, 249, 255), TextTransparency = 1, Font = Enum.Font.GothamBlack, TextSize = 34, ZIndex = 6}, frame)
    local desc = make("TextLabel", {Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 111), BackgroundTransparency = 1, Text = "AWD HUB  •  SESSION INITIALIZED", TextColor3 = Color3.fromRGB(170, 180, 220), TextTransparency = 1, Font = Enum.Font.GothamMedium, TextSize = 11, ZIndex = 6}, frame)
    local dots = {}
    for i = 1, 3 do
        local d = make("Frame", {Size = UDim2.new(0, 5, 0, 5), Position = UDim2.new(.5, (i - 2) * 14, 1, -29), AnchorPoint = Vector2.new(.5, .5), BackgroundColor3 = Color3.fromRGB(190, 205, 255), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 6}, frame)
        make("UICorner", {CornerRadius = UDim.new(1, 0)}, d); dots[i] = d
    end
    go(aura, {BackgroundTransparency = .16, Size = UDim2.new(0, 840, 0, 520)}, .65, Enum.EasingStyle.Sine)
    go(horizon, {Size = UDim2.new(1, 0, 0, 1), BackgroundTransparency = .25}, .42)
    task.wait(.13)
    go(leftPanel, {Position = UDim2.new(0, -320, 0, 0)}, .78)
    go(rightPanel, {Position = UDim2.new(.5, 320, 0, 0)}, .78)
    go(frame, {Position = UDim2.new(.5, 0, .5, 0), BackgroundTransparency = .04}, .5, Enum.EasingStyle.Back)
    go(border, {Transparency = .18}, .45)
    task.wait(.26)
    go(badge, {BackgroundTransparency = 0, TextTransparency = 0}, .25)
    go(title, {TextTransparency = 0}, .35); go(desc, {TextTransparency = 0}, .4)
    for round = 1, 2 do
        for i, d in ipairs(dots) do go(d, {BackgroundTransparency = 0, Size = UDim2.new(0, 8, 0, 8)}, .12); task.wait(.1); go(d, {BackgroundTransparency = .62, Size = UDim2.new(0, 5, 0, 5)}, .16) end
    end
    desc.Text = "ERİŞİM AÇILDI  •  HOŞ GELDİN"
    task.wait(.38)
    go(frame, {Size = UDim2.new(0, 560, 0, 225), BackgroundTransparency = 1}, .36, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    go(border, {Transparency = 1}, .24); go(title, {TextTransparency = 1}, .2); go(desc, {TextTransparency = 1}, .2); go(badge, {TextTransparency = 1, BackgroundTransparency = 1}, .2)
    go(horizon, {BackgroundTransparency = 1}, .3); go(aura, {BackgroundTransparency = 1}, .36)
    task.wait(.42); pcall(function() gui:Destroy() end)
end

-- [[ AWD HUB INTRO // A-10 THUNDERBOLT II CINEMATIC ]] --
-- Replaces only the active intro. All unrelated hub functions remain untouched.
function awdShowIntro()
    local gui = Instance.new("ScreenGui")
    gui.Name = "AWD_A10CinematicIntro"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999999
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then pcall(function() gui.Parent = player:WaitForChild("PlayerGui", 5) end) end
    if not gui.Parent then return end

    local function make(class, props, parent)
        local obj = Instance.new(class)
        for k, v in pairs(props or {}) do pcall(function() obj[k] = v end) end
        obj.Parent = parent
        return obj
    end
    local function tween(obj, props, duration, style, direction)
        if not obj or not obj.Parent then return nil end
        local ok, tw = pcall(function()
            return TweenService:Create(obj, TweenInfo.new(duration, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out), props)
        end)
        if ok and tw then tw:Play(); return tw end
        return nil
    end
    local function waitFor(seconds)
        local startTime = os.clock()
        while os.clock() - startTime < seconds do
            if not gui.Parent then return end
            RunService.RenderStepped:Wait()
        end
    end

    -- A-10 GAU-8 sound starts immediately with the cinematic.
    local gunSound = make("Sound", {
        Name = "A10WarthogGunIntroSound",
        SoundId = "rbxassetid://127997181362733",
        Volume = 1,
        PlaybackSpeed = 1,
        Looped = false,
    }, gui)
    pcall(function() gunSound:Play() end)

    local bg = make("Frame", {Name="CinematicBackdrop", Size=UDim2.fromScale(1,1), BackgroundColor3=Color3.fromRGB(3,5,8), BorderSizePixel=0}, gui)
    make("UIGradient", {Rotation=90, Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(24,31,39)),
        ColorSequenceKeypoint.new(0.48, Color3.fromRGB(7,10,14)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(1,2,4))
    })}, bg)

    -- Horizon haze and cinematic vignette.
    local haze = make("Frame", {Size=UDim2.new(1,0,0.38,0), Position=UDim2.new(0,0,0.29,0), BackgroundColor3=Color3.fromRGB(95,105,111), BackgroundTransparency=1, BorderSizePixel=0, ZIndex=2}, bg)
    make("UIGradient", {Rotation=90, Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.5,0.62),NumberSequenceKeypoint.new(1,1)})}, haze)
    local vignette = make("Frame", {Size=UDim2.fromScale(1,1), BackgroundColor3=Color3.new(0,0,0), BackgroundTransparency=0.3, BorderSizePixel=0, ZIndex=30}, bg)
    make("UIGradient", {Rotation=0, Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.12),NumberSequenceKeypoint.new(0.5,1),NumberSequenceKeypoint.new(1,0.12)})}, vignette)

    -- Fast cloud / speed streaks give the plane a low-altitude fly-by feel.
    for i=1,28 do
        local y = math.random(8,92)/100
        local streak = make("Frame", {
            AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(math.random(-20,100)/100,0,y,0),
            Size=UDim2.new(math.random(8,28)/100,0,0,math.random(1,2)),
            BackgroundColor3=Color3.fromRGB(148,158,164), BackgroundTransparency=math.random(76,92)/100,
            BorderSizePixel=0, ZIndex=3
        }, bg)
        tween(streak, {Position=UDim2.new(-0.35,0,y,0), BackgroundTransparency=1}, math.random(45,95)/100, Enum.EasingStyle.Linear)
    end

    -- Use the provided A-10 image asset instead of drawing an aircraft from UI shapes.
    -- Roblox ImageLabel has no native horizontal-flip property. A 180-degree rotation
    -- reverses the aircraft's left/right direction (and also turns the image upside down).
    -- For a true horizontal-only mirror, upload a pre-mirrored copy and replace this asset ID.
    local aircraft = make("ImageLabel", {
        Name = "A10ThunderboltImage",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1.28, 0, 0.34, 0),
        Size = UDim2.new(0, 610, 0, 250),
        BackgroundTransparency = 1,
        Image = "rbxassetid://16302689073",
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ImageTransparency = 0,
        ScaleType = Enum.ScaleType.Fit,
        ResampleMode = Enum.ResamplerMode.Default,
        Rotation = 173,
        ZIndex = 6,
    }, bg)
    local aircraftGlow = make("Frame", {
        Name = "A10ImageGlow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 80, 0, 3),
        BackgroundColor3 = Color3.fromRGB(206, 218, 221),
        BackgroundTransparency = 0.72,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, aircraft)
    make("UIGradient", {Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.5,0.1),NumberSequenceKeypoint.new(1,1)})}, aircraftGlow)

    -- Camera-shake style impact flash behind the aircraft.
    local shock = make("Frame", {AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.34,0), Size=UDim2.new(0,10,0,10), BackgroundColor3=Color3.fromRGB(211,220,221), BackgroundTransparency=1, BorderSizePixel=0, ZIndex=8}, bg)
    make("UICorner", {CornerRadius=UDim.new(1,0)}, shock)

    local topLine = make("Frame", {AnchorPoint=Vector2.new(0.5,0), Position=UDim2.new(0.5,0,0.105,0), Size=UDim2.new(0,0,0,2), BackgroundColor3=Color3.fromRGB(186,199,202), BackgroundTransparency=0.18, BorderSizePixel=0, ZIndex=12}, bg)
    local bottomLine = make("Frame", {AnchorPoint=Vector2.new(0.5,1), Position=UDim2.new(0.5,0,0.895,0), Size=UDim2.new(0,0,0,1), BackgroundColor3=Color3.fromRGB(120,135,142), BackgroundTransparency=0.22, BorderSizePixel=0, ZIndex=12}, bg)
    tween(topLine, {Size=UDim2.new(0.82,0,0,2)}, 0.65)
    tween(bottomLine, {Size=UDim2.new(0.58,0,0,1)}, 0.75)

    -- [[ INTRO TITLE ICON - ImageId buraya ]] --
    local INTRO_TITLE_ICON_ID = "rbxassetid://74851439089345" -- BURAYA ROBLOX IMAGE ID YAZ (sadece sayı da olur)
    local introIconSize = 72
    local introIcon = make("ImageLabel", {
        Name = "IntroTitleIcon",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.52),
        Size = UDim2.new(0, introIconSize, 0, introIconSize),
        BackgroundTransparency = 1,
        Image = "",
        ImageTransparency = 1,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 16,
    }, bg)
    do
        local clean = tostring(INTRO_TITLE_ICON_ID):match("%d+")
        if clean and clean ~= "0" then
            introIcon.Image = "rbxassetid://" .. clean
            -- ikon solda, title biraz sağa kayar
            introIcon.Position = UDim2.new(0.5, -160, 0.52, 0)
        end
    end

    local eyebrow = make("TextLabel", {AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.425), Size=UDim2.new(0.8,0,0,24), BackgroundTransparency=1, Text="ANANISTAN WAFFEN DIVISION", TextColor3=Color3.fromRGB(157,171,176), TextTransparency=1, Font=Enum.Font.Code, TextSize=12, ZIndex=15}, bg)
    local title = make("TextLabel", {Name="AWDMenuTitle", AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.52), Size=UDim2.new(0.9,0,0,125), BackgroundTransparency=1, Text="A.W.D COMPHUB", TextColor3=Color3.fromRGB(245,247,247), TextTransparency=1, TextScaled=true, Font=Enum.Font.GothamBlack, ZIndex=16}, bg)
    make("UITextSizeConstraint", {MinTextSize=32, MaxTextSize=92}, title)
    make("UIStroke", {Color=Color3.fromRGB(185,197,197), Thickness=1.1, Transparency=1}, title)
    local subtitle = make("TextLabel", {AnchorPoint=Vector2.new(0.5,0), Position=UDim2.fromScale(0.5,0.615), Size=UDim2.new(0.8,0,0,24), BackgroundTransparency=1, Text="POPO PIPI COCO", TextColor3=Color3.fromRGB(177,187,190), TextTransparency=1, TextSize=12, Font=Enum.Font.GothamMedium, ZIndex=16}, bg)
    local status = make("TextLabel", {AnchorPoint=Vector2.new(0.5,0), Position=UDim2.fromScale(0.5,0.665), Size=UDim2.new(0.7,0,0,18), BackgroundTransparency=1, Text="Credits: Haviland, arthurmorgan4000, dutchvander4000, imstillstand", TextColor3=Color3.fromRGB(121,143,147), TextTransparency=1, TextSize=11, Font=Enum.Font.Code, ZIndex=16}, bg)

    -- Sequence: distant aircraft enters, fast close fly-by, title locks in, then clean fade.
    tween(haze, {BackgroundTransparency=0.74}, 0.8, Enum.EasingStyle.Sine)
    tween(aircraft, {Position=UDim2.new(0.54,0,0.34,0), Rotation=178, Size=UDim2.new(0,760,0,310)}, 0.92, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
    tween(eyebrow, {TextTransparency=0}, 0.45)
    waitFor(0.52)
    tween(shock, {Size=UDim2.new(0,540,0,540), BackgroundTransparency=0.88}, 0.22, Enum.EasingStyle.Quad)
    tween(bg, {BackgroundColor3=Color3.fromRGB(16,20,23)}, 0.12, Enum.EasingStyle.Linear)
    waitFor(0.13)
    tween(shock, {Size=UDim2.new(0,900,0,900), BackgroundTransparency=1}, 0.35, Enum.EasingStyle.Quint)
    tween(aircraft, {Position=UDim2.new(-0.48,0,0.30,0), Rotation=184, Size=UDim2.new(0,900,0,360)}, 0.78, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    tween(title, {TextTransparency=0}, 0.38, Enum.EasingStyle.Quint)
    if introIcon and introIcon.Image ~= "" then
        tween(introIcon, {ImageTransparency=0}, 0.38, Enum.EasingStyle.Quint)
    end
    waitFor(0.22)
    tween(subtitle, {TextTransparency=0}, 0.38)
    tween(status, {TextTransparency=0}, 0.42)
    waitFor(1.05)
    tween(title, {TextTransparency=1, Position=UDim2.fromScale(0.5,0.47)}, 0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    if introIcon then
        tween(introIcon, {ImageTransparency=1, Position=UDim2.new(0.5, -160, 0.47, 0)}, 0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    end
    tween(eyebrow, {TextTransparency=1}, 0.2)
    tween(subtitle, {TextTransparency=1}, 0.24)
    tween(status, {TextTransparency=1}, 0.2)
    tween(topLine, {BackgroundTransparency=1}, 0.25)
    tween(bottomLine, {BackgroundTransparency=1}, 0.25)
    tween(vignette, {BackgroundTransparency=1}, 0.35)
    tween(bg, {BackgroundTransparency=1}, 0.38)
    waitFor(0.42)
    pcall(function() if gunSound.IsPlaying then gunSound:Stop() end end)
    pcall(function() gui:Destroy() end)
end
task.spawn(function()
    pcall(awdShowIntro)
end)

-- [[ SINGLETON: AYNI SCRIPTİN ÖNCEKİ KOPYASINI KAPAT ]] --
if type(_G.ananistwaffendivisionCleanup) == "function" then
    pcall(_G.ananistwaffendivisionCleanup)
end

-- [[ SCOPING İÇİN GEREKLİ ÖN TANIMLAMALAR ]] --
bgImageLabel = nil
blurOverlay = nil

-- [[ ORİJİNAL TÜM FONKSİYONLAR ]] --

parachuteEnabled = false
parachuteConnection = nil
parachuteTrack = nil

function runParachute(button)
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")
    local RunService = game:GetService("RunService")
 
    parachuteEnabled = not parachuteEnabled
    button.Text = parachuteEnabled and "Parachute: ON" or "Parachute: OFF"
 
    if not parachuteTrack then
        local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://507766666"
        parachuteTrack = animator:LoadAnimation(anim)
    end
 
    if parachuteEnabled then
        parachuteConnection = RunService.RenderStepped:Connect(function()
            if humanoid.FloorMaterial == Enum.Material.Air then
                if not parachuteTrack.IsPlaying then
                    parachuteTrack:Play()
                end
                local vel = root.Velocity
                if vel.Y < -20 then
                    root.Velocity = Vector3.new(vel.X, -10, vel.Z)
                end
            else
                if parachuteTrack.IsPlaying then
                    parachuteTrack:Stop()
                end
            end
        end)
    else
        if parachuteConnection then
            parachuteConnection:Disconnect()
            parachuteConnection = nil
        end
        if parachuteTrack and parachuteTrack.IsPlaying then
            parachuteTrack:Stop()
        end
    end
end

fullbrightEnabled = false
oldLighting = {}

function runFullbright(button)
    local Lighting = game:GetService("Lighting")
    fullbrightEnabled = not fullbrightEnabled
    button.Text = fullbrightEnabled and "FullBright: ON" or "FullBright: OFF"
 
    if fullbrightEnabled then
        oldLighting.Brightness = Lighting.Brightness
        oldLighting.ClockTime = Lighting.ClockTime
        oldLighting.FogEnd = Lighting.FogEnd
        oldLighting.GlobalShadows = Lighting.GlobalShadows
        oldLighting.OutdoorAmbient = Lighting.OutdoorAmbient
 
        Lighting.Brightness = 1
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
    else
        Lighting.Brightness = oldLighting.Brightness
        Lighting.ClockTime = oldLighting.ClockTime
        Lighting.FogEnd = oldLighting.FogEnd
        Lighting.GlobalShadows = oldLighting.GlobalShadows
        Lighting.OutdoorAmbient = oldLighting.OutdoorAmbient
    end
end

function runGrapple()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/0Ben1/fe/main/obf_E872F3ky4888TSVdj6Adgi1hSLtM038AyxVpTVw07QA3QUDcI3sxmuD869hYR4id.lua.txt"))()
end

espObjects = {}
espEnabled = false
espExpanded = false
espShowNames = false
espShowChams = false
espShowBoxes = false
espShowInventory = false
espUseCustomColor = false
espUseTeamColor = false
espUseFriendColor = false
espCustomColor = Color3.fromRGB(255, 255, 255)
espFriendColor = Color3.fromRGB(0, 255, 0)
espNameColor = Color3.fromRGB(255, 255, 255)
espBoxColor = Color3.fromRGB(255, 255, 255)
espInventoryColor = Color3.fromRGB(255, 255, 255)
espShowHealth = false
clickTPEnabled = false
antiAFKEnabled = false
antiAFKConn = nil
espLoopThread = nil
espMaxDistance = 5000
espConnections = {}
colorPresets = {
    Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255), Color3.fromRGB(0,255,0),
    Color3.fromRGB(0,120,255), Color3.fromRGB(255,255,0), Color3.fromRGB(255,0,255),
    Color3.fromRGB(0,255,255), Color3.fromRGB(255,165,0),
}
friendCache = {}

function isFriend(target)
    if friendCache[target.UserId] ~= nil then
        return friendCache[target.UserId]
    end
    local ok, result = pcall(function()
        return player:IsFriendsWith(target.UserId)
    end)
    friendCache[target.UserId] = ok and result or false
    return friendCache[target.UserId]
end

function getESPColor(target)
    if espUseFriendColor and isFriend(target) then
        return espFriendColor
    end
    if espUseTeamColor and target.Team then
        return target.TeamColor.Color
    elseif espUseCustomColor then
        return espCustomColor
    end
    return Color3.fromRGB(255, 255, 255)
end

function clearESP()
    for _, obj in pairs(espObjects) do
        if obj.box then pcall(game.Destroy, obj.box) end
        if obj.billboard then pcall(game.Destroy, obj.billboard) end
        if obj.highlight then pcall(game.Destroy, obj.highlight) end
    end
    espObjects = {}
end

function buildESP(target, useChams)
    if not espEnabled or target == player then return end
    local char = target.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Head")
    if not root then return end
 
    local obj = espObjects[target] or {}
    local espColor = getESPColor(target)
 
    if espShowChams then
        if not obj.highlight or not obj.highlight.Parent then
            local hl = Instance.new("Highlight")
            hl.Adornee = char
            hl.FillTransparency = 0.7
            hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = char
            obj.highlight = hl
        end
        obj.highlight.FillColor = espColor
        obj.highlight.OutlineColor = espColor
    else
        if obj.highlight then pcall(game.Destroy, obj.highlight); obj.highlight = nil end
    end
 
    if espShowBoxes then
        if not obj.box or not obj.box.Parent then
            local bb = Instance.new("BillboardGui")
            bb.Name = "BoxESP"
            bb.Adornee = root
            bb.Size = UDim2.new(4.5, 0, 6, 0)
            bb.AlwaysOnTop = true
            bb.MaxDistance = 0
            bb.Parent = char
 
            local frame = Instance.new("Frame", bb)
            frame.Name = "BoxFrame"
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundTransparency = 1
 
            local stroke = Instance.new("UIStroke", frame)
            stroke.Thickness = 2
            stroke.Color = espColor
            stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
 
            obj.box = bb
            obj.stroke = stroke
        end
        if obj.stroke then obj.stroke.Color = espColor end
    else
        if obj.box then pcall(game.Destroy, obj.box); obj.box = nil; obj.stroke = nil end
    end
 
    if espShowNames or espShowInventory then
        if not obj.billboard or not obj.billboard.Parent then
            local bb = Instance.new("BillboardGui")
            bb.Name = "InfoESP"
            bb.Adornee = char:FindFirstChild("Head") or root
            bb.Size = UDim2.new(0, 300, 0, 70)
            bb.StudsOffset = Vector3.new(0, 3, 0)
            bb.AlwaysOnTop = true
            bb.MaxDistance = 0
            bb.Parent = char
 
            local nl = Instance.new("TextLabel", bb)
            nl.Name = "NL"; nl.Size = UDim2.new(1, 0, 0, 22)
            nl.BackgroundTransparency = 1; nl.Font = Enum.Font.GothamBold
            nl.TextSize = 16; nl.TextStrokeTransparency = 0.3; nl.Text = ""
 
            local dl = Instance.new("TextLabel", bb)
            dl.Name = "DL"; dl.Size = UDim2.new(1, 0, 0, 16)
            dl.Position = UDim2.new(0, 0, 0, 22)
            dl.BackgroundTransparency = 1; dl.Font = Enum.Font.Gotham
            dl.TextSize = 13; dl.TextStrokeTransparency = 0.4; dl.Text = ""
 
            local il = Instance.new("TextLabel", bb)
            il.Name = "IL"; il.Size = UDim2.new(1, 0, 0, 28)
            il.Position = UDim2.new(0, 0, 0, 38); il.BackgroundTransparency = 1
            il.Font = Enum.Font.Gotham; il.TextSize = 12
            il.TextStrokeTransparency = 0.5; il.TextWrapped = true
            il.TextYAlignment = Enum.TextYAlignment.Top; il.Text = ""
 
            local hb = Instance.new("Frame", bb)
            hb.Name = "HB"; hb.Size = UDim2.new(0.4, 0, 0, 4)
            hb.Position = UDim2.new(0.3, 0, 0, 66)
            hb.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            hb.BorderSizePixel = 0
 
            local hf = Instance.new("Frame", hb)
            hf.Name = "HF"; hf.Size = UDim2.new(1, 0, 1, 0)
            hf.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            hf.BorderSizePixel = 0
 
            obj.billboard = bb
        end
 
        local nl = obj.billboard:FindFirstChild("NL")
        local dl = obj.billboard:FindFirstChild("DL")
        if nl then
            if espShowNames then
                nl.Text = target.Name
                nl.TextColor3 = espColor; nl.Visible = true
            else nl.Visible = false end
        end
        if dl then
            if espShowNames then
                local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                local d = myRoot and math.floor((root.Position - myRoot.Position).Magnitude) or 0
                dl.Text = "[" .. d .. "m]"
                dl.TextColor3 = espColor; dl.Visible = true
            else dl.Visible = false end
        end
 
        local il = obj.billboard:FindFirstChild("IL")
        if il then
            if espShowInventory then
                local items = {}
                for _, t in pairs(char:GetChildren()) do
                    if t:IsA("Tool") then table.insert(items, "[E] " .. t.Name) end
                end
                local bp = target:FindFirstChild("Backpack")
                if bp then
                    for _, t in pairs(bp:GetChildren()) do
                        if t:IsA("Tool") then table.insert(items, t.Name) end
                    end
                end
                il.Text = #items > 0 and table.concat(items, ", ") or ""
                il.TextColor3 = espColor; il.Visible = true
            else il.Visible = false end
        end
    elseif obj.billboard then
        pcall(game.Destroy, obj.billboard); obj.billboard = nil
    end
 
    espObjects[target] = obj
end

function updateAllESP()
    if not espEnabled then return end
    for p, obj in pairs(espObjects) do
        pcall(function()
            if not p or not p.Parent then 
                if obj.box then pcall(game.Destroy, obj.box) end
                if obj.billboard then pcall(game.Destroy, obj.billboard) end
                if obj.highlight then pcall(game.Destroy, obj.highlight) end
                espObjects[p] = nil
                return 
            end
        end)
    end
    local myChar = player.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
 
    local playersByDist = {}
    for _, t in pairs(Players:GetPlayers()) do
        if t ~= player then
            pcall(function()
                local char = t.Character
                if not char then return end
                local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Head")
                if not root then return end
                local dist = myRoot and (root.Position - myRoot.Position).Magnitude or 999999
                table.insert(playersByDist, {plr = t, dist = dist})
            end)
        end
    end
    table.sort(playersByDist, function(a, b) return a.dist < b.dist end)
 
    for i, data in ipairs(playersByDist) do
        pcall(function()
            local p = data.plr
            local d = data.dist
            local isTop31 = i <= 31
            local visible = d <= espMaxDistance
 
            buildESP(p, isTop31)
 
            local obj = espObjects[p]
            if obj then
                if obj.box then obj.box.Enabled = (visible and espShowBoxes) end
                if obj.highlight then obj.highlight.Enabled = (visible and espShowChams and isTop31) end
                if obj.billboard then 
                obj.billboard.Enabled = (visible and (espShowNames or espShowInventory or espShowHealth)) 
 
                local hum = p.Character and p.Character:FindFirstChild("Humanoid")
                local hb = obj.billboard:FindFirstChild("HB")
                if hb then
                    if espShowHealth and hum then
                        hb.Visible = true
                        local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        local hf = hb:FindFirstChild("HF")
                        if hf then
                            hf.Size = UDim2.new(healthPercent, 0, 1, 0)
                            hf.BackgroundColor3 = Color3.fromHSV(healthPercent * 0.35, 1, 1)
                        end
                    else hb.Visible = false end
                end
 
                if obj.billboard.Enabled and espShowNames then
                        local nl = obj.billboard:FindFirstChild("NL")
                        if nl then nl.Text = p.Name end
                        local dl = obj.billboard:FindFirstChild("DL")
                        if dl then dl.Text = "[" .. math.floor(d) .. "m]" end
                    end
                end
            end
        end)
    end
end

function runFly()
    local UserInputService = game:GetService("UserInputService")
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
 
    if isMobile then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/396abc/Script/refs/heads/main/MobileFly.lua"))()
    else
        loadstring(game:HttpGet("https://pastebin.com/raw/ByKS7S6k"))()
    end
end

function runInfiniteYield()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end

function runananistwaffendivisionAI()
    pcall(function()
        loadstring(game:HttpGet("https://pastebin.com/raw/x6G1dmEZ"))()
    end)
end

function runananistwaffendivisionPew()
    local ok, err = pcall(function()
        local source = game:HttpGet("https://pastebin.com/raw/fsZRgdrB")
        local fn = loadstring(source)
        if not fn then
            error("AWD Hub Pew loadstring oluşturulamadı")
        end
        fn()
    end)
    if not ok then
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "AWD Hub Pew",
                Text = "Yükleme başarısız: " .. tostring(err),
                Duration = 5
            })
        end)
    end
end

function runSpiderWeb1()
    local player = game.Players.LocalPlayer
    local backpack = player:FindFirstChild("Backpack")
    if not backpack then return end
    if backpack:FindFirstChild("Grapple 1") then return end
 
    local tool = Instance.new("Tool")
    tool.Name = "Grapple 1"
    tool.RequiresHandle = false
    tool.Parent = backpack
 
    local UserInputService = game:GetService("UserInputService")
    local connection
    local attachment0, attachment1, rope
 
    tool.Equipped:Connect(function(mouse)
        connection = mouse.Button1Down:Connect(function()
            local char = player.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
 
            local targetPos = mouse.Hit.Position
 
            if rope then rope:Destroy() end
            if attachment0 then attachment0:Destroy() end
            if attachment1 then attachment1:Destroy() end
 
            attachment0 = Instance.new("Attachment", root)
 
            local hookPart = Instance.new("Part")
            hookPart.Size = Vector3.new(0.5, 0.5, 0.5)
            hookPart.Position = targetPos
            hookPart.Anchored = true
            hookPart.CanCollide = false
            hookPart.Transparency = 1
            hookPart.Parent = workspace
 
            attachment1 = Instance.new("Attachment", hookPart)
 
            rope = Instance.new("SpringConstraint")
            rope.Attachment0 = attachment0
            rope.Attachment1 = attachment1
            rope.Visible = true
            rope.Thickness = 0.05
            rope.Color = BrickColor.new("Institutional white")
            rope.FreeLength = 1
            rope.MaxForce = 100000
            rope.Damping = 2
            rope.Stiffness = 500
            rope.Parent = root
 
            task.delay(4, function()
                if rope then rope:Destroy() end
                if hookPart then hookPart:Destroy() end
            end)
        end)
    end)
 
    tool.Unequipped:Connect(function()
        if connection then connection:Disconnect() end
        if rope then rope:Destroy() end
        if attachment0 then attachment0:Destroy() end
        if attachment1 then attachment1:Destroy() end
    end)
end

function runSpiderWeb2()
    local player = game.Players.LocalPlayer
    local backpack = player:FindFirstChild("Backpack")
    if not backpack then return end
    if backpack:FindFirstChild("Grapple 2") then return end
 
    local tool = Instance.new("Tool")
    tool.Name = "Grapple 2"
    tool.RequiresHandle = false
    tool.Parent = backpack
 
    local connection
    local attachment0, attachment1, rope
    local isHanging = false
    local rsConn = nil
 
    tool.Equipped:Connect(function(mouse)
        connection = mouse.Button1Down:Connect(function()
            local char = player.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
 
            if isHanging then
                if rope then rope:Destroy() end
                if attachment0 then attachment0:Destroy() end
                if attachment1 then attachment1:Destroy() end
                isHanging = false
                if rsConn then rsConn:Disconnect(); rsConn = nil end
            else
                local targetPos = mouse.Hit.Position
 
                attachment0 = Instance.new("Attachment", root)
 
                local hookPart = Instance.new("Part")
                hookPart.Size = Vector3.new(0.5, 0.5, 0.5)
                hookPart.Position = targetPos
                hookPart.Anchored = true
                hookPart.CanCollide = false
                hookPart.Transparency = 1
                hookPart.Parent = workspace
 
                attachment1 = Instance.new("Attachment", hookPart)
 
                rope = Instance.new("RopeConstraint")
                rope.Attachment0 = attachment0
                rope.Attachment1 = attachment1
                rope.Visible = true
                rope.Thickness = 0.05
                rope.Color = BrickColor.new("Institutional white")
                rope.Length = (root.Position - targetPos).Magnitude * 0.5
                rope.Parent = root
 
                isHanging = true
 
                local uis = game:GetService("UserInputService")
                rsConn = game:GetService("RunService").RenderStepped:Connect(function()
                    if isHanging and rope then
                        if UIS:IsKeyDown(Enum.KeyCode.E) then
                            rope.Length = math.max(1, rope.Length - 0.5)
                        elseif UIS:IsKeyDown(Enum.KeyCode.Q) then
                            rope.Length = rope.Length + 0.5
                        end
                    end
                end)
            end
        end)
    end)
 
    tool.Unequipped:Connect(function()
        if connection then connection:Disconnect() end
        if rope then rope:Destroy() end
        if attachment0 then attachment0:Destroy() end
        if attachment1 then attachment1:Destroy() end
        isHanging = false
        if rsConn then rsConn:Disconnect(); rsConn = nil end
    end)
end
-- [[ OYUNCU / ULAŞIM EKSTRA SİSTEMLERİ ]]
movementWalkSpeed = 16
movementJumpPower = 50
movementGravity = workspace.Gravity
infiniteJumpEnabled = false
noclipEnabled = false
freezeCharacterEnabled = false
infiniteJumpConn = nil
noclipConn = nil
freezeSavedStates = {}
savedLocations = {}
selectedWorkspaceObject = nil
workspaceExplorerRoot = workspace
workspaceExplorerFrame = nil
workspaceExplorerSearch = nil

function getCharacterHumanoid()
    local char = player.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

function getCharacterRoot()
    local char = player.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end


-- [[ KOSATKA / PERİSKOP MODU ]] --
local kosatkaEnabled = false
local kosatkaConn = nil
local kosatkaSavedCollision = {}
local kosatkaSavedCharacter = nil
local kosatkaAntiFall = nil
local kosatkaHeight = 0.5

function setKosatkaHeight(value)
    kosatkaHeight = math.clamp(tonumber(value) or 0.5, 0, 8)
end

function saveKosatkaCollision(char)
    kosatkaSavedCollision = {}
    if not char then return end
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("BasePart") then
            kosatkaSavedCollision[obj] = obj.CanCollide
            obj.CanCollide = false
        end
    end
end

function forceKosatkaNoclip(char)
    if not char then return end
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CanCollide = false
            obj.CanTouch = false
            obj.CanQuery = true
        end
    end
end

function restoreKosatkaCollision()
    for obj, oldState in pairs(kosatkaSavedCollision) do
        if obj and obj.Parent then
            pcall(function()
                obj.CanCollide = oldState
                obj.CanTouch = true
            end)
        end
    end
    kosatkaSavedCollision = {}
    kosatkaSavedCharacter = nil
end

function stopKosatka()
    kosatkaEnabled = false

    if kosatkaConn then
        kosatkaConn:Disconnect()
        kosatkaConn = nil
    end

    if kosatkaAntiFall then
        kosatkaAntiFall:Destroy()
        kosatkaAntiFall = nil
    end

    restoreKosatkaCollision()

    local root = getCharacterRoot()
    local hum = getCharacterHumanoid()
    if hum then
        hum.PlatformStand = false
        hum.AutoRotate = true
    end

end

function getKosatkaSurfaceY(root, char)
    if not root then return nil end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char}
    params.IgnoreWater = false

    -- Önce karakterin bulunduğu X/Z noktasında yukarıdan aşağıya ray atılır.
    -- Böylece karakter zaten yerin altında olsa bile yüzey bulunur.
    local origin = Vector3.new(root.Position.X, root.Position.Y + 100, root.Position.Z)
    local result = workspace:Raycast(origin, Vector3.new(0, -1000, 0), params)
    return result and result.Position.Y or nil
end

function startKosatka()
    local char = player.Character
    local root = getCharacterRoot()
    local head = char and char:FindFirstChild("Head")
    local hum = getCharacterHumanoid()
    if not char or not root or not head or not hum then return end

    if kosatkaEnabled then return end

    kosatkaSavedCharacter = char
    saveKosatkaCollision(char)
    forceKosatkaNoclip(char)
    kosatkaEnabled = true

    -- Yerçekimini karakter üzerinde etkisizleştirir ama Humanoid yürüyüşünü bozmaz.
    -- Böylece noclip açıkken aşağı doğru sonsuz düşüş yaşanmaz.
    local attachment = Instance.new("Attachment")
    attachment.Name = "ANANISTAN_KosatkaAntiFall"
    attachment.Parent = root

    local vectorForce = Instance.new("VectorForce")
    vectorForce.Name = "ANANISTAN_KosatkaAntiFall"
    vectorForce.Attachment0 = attachment
    vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
    vectorForce.ApplyAtCenterOfMass = true
    vectorForce.Force = Vector3.new(0, root.AssemblyMass * workspace.Gravity, 0)
    vectorForce.Parent = root
    kosatkaAntiFall = vectorForce

    -- Humanoid normal yürüme animasyonlarını korur.
    hum.PlatformStand = false
    hum.AutoRotate = true

    kosatkaConn = RunService.Heartbeat:Connect(function()
        if not kosatkaEnabled then return end

        local currentChar = player.Character
        local currentRoot = currentChar and currentChar:FindFirstChild("HumanoidRootPart")
        local currentHead = currentChar and currentChar:FindFirstChild("Head")
        local currentHum = currentChar and currentChar:FindFirstChildOfClass("Humanoid")
        if not currentChar or not currentRoot or not currentHead or not currentHum then return end

        -- Respawn sonrası Kosatka açık kalmışsa yeni karaktere yeniden uygula.
        if currentChar ~= kosatkaSavedCharacter then
            restoreKosatkaCollision()
            kosatkaSavedCharacter = currentChar
            saveKosatkaCollision(currentChar)
            forceKosatkaNoclip(currentChar)

            if kosatkaAntiFall then
                kosatkaAntiFall:Destroy()
            end
            local newAttachment = Instance.new("Attachment")
            newAttachment.Name = "ANANISTAN_KosatkaAntiFall"
            newAttachment.Parent = currentRoot

            local newForce = Instance.new("VectorForce")
            newForce.Name = "ANANISTAN_KosatkaAntiFall"
            newForce.Attachment0 = newAttachment
            newForce.RelativeTo = Enum.ActuatorRelativeTo.World
            newForce.ApplyAtCenterOfMass = true
            newForce.Parent = currentRoot
            kosatkaAntiFall = newForce
        end

        forceKosatkaNoclip(currentChar)

        if kosatkaAntiFall and kosatkaAntiFall.Parent == currentRoot then
            kosatkaAntiFall.Force = Vector3.new(0, currentRoot.AssemblyMass * workspace.Gravity, 0)
        end

        local surfaceY = getKosatkaSurfaceY(currentRoot, currentChar)
        if surfaceY then
            -- Head'in ALT yüzünü yüzeyden kosatkaHeight kadar yukarıda tut.
            -- Root sadece Y ekseninde sabitlenir; X/Z Humanoid hareketinden gelir.
            local headOffsetY = currentHead.Position.Y - currentRoot.Position.Y
            local headHalfY = currentHead.Size.Y * 0.5
            local targetRootY = surfaceY + kosatkaHeight + headHalfY - headOffsetY
            local pos = currentRoot.Position

            currentRoot.CFrame = CFrame.new(pos.X, targetRootY, pos.Z) * CFrame.Angles(
                0,
                math.rad(currentRoot.Orientation.Y),
                0
            )

            -- Y hızını sıfırla; X/Z hızını kesinlikle elleme.
            local v = currentRoot.AssemblyLinearVelocity
            currentRoot.AssemblyLinearVelocity = Vector3.new(v.X, 0, v.Z)
            currentRoot.AssemblyAngularVelocity = Vector3.zero
        end
    end)
end

function toggleKosatka(state)
    if state then
        startKosatka()
    else
        stopKosatka()
    end
end

function setWalkSpeed(value)
    movementWalkSpeed = value
    local hum = getCharacterHumanoid()
    if hum and not freezeCharacterEnabled then
        hum.WalkSpeed = value
    end
end

function setJumpPower(value)
    movementJumpPower = value
    local hum = getCharacterHumanoid()
    if hum and not freezeCharacterEnabled then
        hum.UseJumpPower = true
        hum.JumpPower = value
    end
end

function setGravity(value)
    movementGravity = value
    workspace.Gravity = value
end

function toggleInfiniteJump(state)
    infiniteJumpEnabled = state
    if infiniteJumpConn then
        infiniteJumpConn:Disconnect()
        infiniteJumpConn = nil
    end
    if state then
        infiniteJumpConn = UIS.JumpRequest:Connect(function()
            if not infiniteJumpEnabled then return end
            local hum = getCharacterHumanoid()
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end

function toggleNoclip(state)
    noclipEnabled = state
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
    if state then
        noclipConn = RunService.Stepped:Connect(function()
            if not noclipEnabled then return end
            local char = player.Character
            if not char then return end
            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.CanCollide = false
                end
            end
        end)
    else
        local char = player.Character
        if char then
            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.CanCollide = true
                end
            end
        end
    end
end

function toggleFreezeCharacter(state)
    freezeCharacterEnabled = state
    local char = player.Character
    local hum = getCharacterHumanoid()
    if state then
        freezeSavedStates = {}
        if hum then
            hum.WalkSpeed = 0
            hum.JumpPower = 0
            hum.AutoRotate = false
        end
        if char then
            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("BasePart") then
                    freezeSavedStates[obj] = obj.Anchored
                    obj.Anchored = true
                end
            end
        end
    else
        if char then
            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("BasePart") then
                    if freezeSavedStates[obj] ~= nil then
                        obj.Anchored = freezeSavedStates[obj]
                    else
                        obj.Anchored = false
                    end
                end
            end
        end
        freezeSavedStates = {}
        if hum then
            hum.WalkSpeed = movementWalkSpeed
            hum.UseJumpPower = true
            hum.JumpPower = movementJumpPower
            hum.AutoRotate = true
        end
    end
end

function resetCharacter()
    local hum = getCharacterHumanoid()
    if hum then
        hum.Health = 0
    else
        local char = player.Character
        if char then char:BreakJoints() end
    end
end

function teleportToInstance(instance)
    if not instance then return false end
    local root = getCharacterRoot()
    if not root then return false end
    local targetPart = nil
    if instance:IsA("BasePart") then
        targetPart = instance
    elseif instance:IsA("Model") then
        targetPart = instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart", true)
    elseif instance:IsA("Folder") then
        targetPart = instance:FindFirstChildWhichIsA("BasePart", true)
    else
        local model = instance:FindFirstAncestorOfClass("Model")
        if model then
            targetPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
        end
    end
    if targetPart then
        root.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
        return true
    end
    return false
end

function bringInstanceToPlayer(instance)
    if not instance then return false end
    local root = getCharacterRoot()
    if not root then return false end
    local targetPart = nil
    if instance:IsA("BasePart") then
        targetPart = instance
    elseif instance:IsA("Model") then
        targetPart = instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart", true)
    elseif instance:IsA("Folder") then
        targetPart = instance:FindFirstChildWhichIsA("BasePart", true)
    else
        local model = instance:FindFirstAncestorOfClass("Model")
        if model then
            targetPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
        end
    end
    if targetPart then
        local offset = root.CFrame * CFrame.new(0, 0, -5)
        if instance:IsA("Model") then
            pcall(function() instance:PivotTo(offset) end)
        elseif instance:IsA("BasePart") then
            targetPart.CFrame = offset
        elseif instance:IsA("Folder") then
            local model = instance:FindFirstChildWhichIsA("Model", true)
            if model then
                pcall(function() model:PivotTo(offset) end)
            else
                targetPart.CFrame = offset
            end
        else
            targetPart.CFrame = offset
        end
        return true
    end
    return false
end

function saveCurrentLocation(name)
    local root = getCharacterRoot()
    if not root or not name or name == "" then return false end
    savedLocations[name] = root.CFrame
    return true
end

function teleportToSavedLocation(name)
    local root = getCharacterRoot()
    local cf = savedLocations[name]
    if root and cf then
        root.CFrame = cf
        return true
    end
    return false
end
antiVoidEnabled = false
antiVoidConn = nil
lastSafePos = nil

function startAntiVoid()
    if antiVoidConn then antiVoidConn:Disconnect() end
    antiVoidConn = RunService.Heartbeat:Connect(function()
        if not antiVoidEnabled then return end
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        if root.Position.Y > -100 then
            lastSafePos = root.Position
        else
            if lastSafePos then
                root.CFrame = CFrame.new(lastSafePos + Vector3.new(0, 5, 0))
            else
                root.CFrame = CFrame.new(0, 100, 0)
            end
        end
    end)
end

function stopAntiVoid()
    if antiVoidConn then antiVoidConn:Disconnect(); antiVoidConn = nil end
end

function toggleAntiAFK(state)
    antiAFKEnabled = state
    if antiAFKEnabled then
        if antiAFKConn then antiAFKConn:Disconnect() end
        antiAFKConn = player.Idled:Connect(function()
            pcall(function()
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
            pcall(function()
                local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = root.CFrame * CFrame.new(0, 0, 0.01)
                    task.wait(0.1)
                    root.CFrame = root.CFrame * CFrame.new(0, 0, -0.01)
                end
            end)
        end)
    else
        if antiAFKConn then antiAFKConn:Disconnect(); antiAFKConn = nil end
    end
end

player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 10)
    if hum then
        hum.UseJumpPower = true
        hum.WalkSpeed = movementWalkSpeed
        hum.JumpPower = movementJumpPower
        if freezeCharacterEnabled then
            task.defer(function() toggleFreezeCharacter(true) end)
        end
    end
end)

-- [[ TEMA SİSTEMİ VERİ YAPISI (TOPLAM 20 BENZERSİZ TEMA) ]] --

local themeData = {
    -- [[ ANA & KLASİK TEMALAR ]] --
  ["ϟϟ Theme"] = {
        MainBG = Color3.fromRGB(0, 0, 0),
        TopbarBG = Color3.fromRGB(0, 0, 0),
        ButtonBG = Color3.fromRGB(35, 35, 35), -- Pure siyah yapıldı
        Accent = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(220, 220, 240),
        UnselectedTabBtn = Color3.fromRGB(30, 30, 45),
        MainTrans = 0, TopbarTrans = 0, ButtonTrans = 0
    },
    ["Kırmızı theme"] = {
        MainBG = Color3.fromRGB(16, 5, 5),
        TopbarBG = Color3.fromRGB(32, 10, 10),
        ButtonBG = Color3.fromRGB(50, 15, 15),
        Accent = Color3.fromRGB(255, 50, 50),
        Text = Color3.fromRGB(255, 220, 220),
        UnselectedTabBtn = Color3.fromRGB(40, 12, 12),
        MainTrans = 0.1, TopbarTrans = 0.15, ButtonTrans = 0
    },
    ["Beyaz theme"] = {
        MainBG = Color3.fromRGB(245, 245, 248),
        TopbarBG = Color3.fromRGB(225, 225, 230),
        ButtonBG = Color3.fromRGB(210, 210, 220),
        Accent = Color3.fromRGB(40, 40, 50),
        Text = Color3.fromRGB(40, 40, 50),
        UnselectedTabBtn = Color3.fromRGB(220, 220, 228),
        MainTrans = 0.05, TopbarTrans = 0.1, ButtonTrans = 0
    },
    ["Yeşil theme"] = {
        MainBG = Color3.fromRGB(5, 15, 8),
        TopbarBG = Color3.fromRGB(10, 30, 15),
        ButtonBG = Color3.fromRGB(15, 45, 20),
        Accent = Color3.fromRGB(50, 255, 50),
        Text = Color3.fromRGB(220, 255, 220),
        UnselectedTabBtn = Color3.fromRGB(12, 40, 18),
        MainTrans = 0.1, TopbarTrans = 0.15, ButtonTrans = 0
    },

    -- [[ OYUN & POPÜLER KÜLTÜR TEMALARI ]] --
    ["Cyberpunk"] = {
        MainBG = Color3.fromRGB(15, 15, 10),
        TopbarBG = Color3.fromRGB(25, 25, 10),
        ButtonBG = Color3.fromRGB(30, 30, 15),
        Accent = Color3.fromRGB(255, 243, 0),
        Text = Color3.fromRGB(0, 240, 255),
        UnselectedTabBtn = Color3.fromRGB(20, 20, 12),
        MainTrans = 0.1, TopbarTrans = 0.15, ButtonTrans = 0
    },
    ["Matrix"] = {
        MainBG = Color3.fromRGB(2, 8, 2),
        TopbarBG = Color3.fromRGB(4, 18, 4),
        ButtonBG = Color3.fromRGB(6, 28, 6),
        Accent = Color3.fromRGB(0, 255, 70),
        Text = Color3.fromRGB(120, 255, 120),
        UnselectedTabBtn = Color3.fromRGB(3, 14, 3),
        MainTrans = 0.05, TopbarTrans = 0.1, ButtonTrans = 0
    },
    ["Minecraft"] = {
        MainBG = Color3.fromRGB(45, 34, 25), -- Dirt brown
        TopbarBG = Color3.fromRGB(74, 57, 42),
        ButtonBG = Color3.fromRGB(94, 73, 54),
        Accent = Color3.fromRGB(92, 179, 44), -- Grass green
        Text = Color3.fromRGB(240, 240, 230),
        UnselectedTabBtn = Color3.fromRGB(61, 46, 34),
        MainTrans = 0.1, TopbarTrans = 0.1, ButtonTrans = 0
    },
    ["Half-Life"] = {
        MainBG = Color3.fromRGB(20, 20, 20),
        TopbarBG = Color3.fromRGB(30, 30, 30),
        ButtonBG = Color3.fromRGB(40, 40, 40),
        Accent = Color3.fromRGB(247, 134, 14), -- Lambda orange
        Text = Color3.fromRGB(235, 235, 235),
        UnselectedTabBtn = Color3.fromRGB(28, 28, 28),
        MainTrans = 0.1, TopbarTrans = 0.15, ButtonTrans = 0
    },
    ["Aero Glass"] = {
        MainBG = Color3.fromRGB(220, 235, 255),
        TopbarBG = Color3.fromRGB(200, 220, 255),
        ButtonBG = Color3.fromRGB(180, 205, 245),
        Accent = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(30, 60, 90),
        UnselectedTabBtn = Color3.fromRGB(195, 215, 250),
        MainTrans = 0.4, TopbarTrans = 0.45, ButtonTrans = 0.3 -- Aero / Glass saydamlığı
    },

    -- [[ EVREN & DOĞA TEMALARI ]] --
    ["Space Void"] = {
        MainBG = Color3.fromRGB(10, 5, 20),
        TopbarBG = Color3.fromRGB(20, 10, 38),
        ButtonBG = Color3.fromRGB(30, 15, 55),
        Accent = Color3.fromRGB(0, 190, 255),
        Text = Color3.fromRGB(240, 220, 255),
        UnselectedTabBtn = Color3.fromRGB(16, 8, 30),
        MainTrans = 0.1, TopbarTrans = 0.15, ButtonTrans = 0
    },
    ["Sakura"] = {
        MainBG = Color3.fromRGB(30, 15, 22),
        TopbarBG = Color3.fromRGB(55, 25, 40),
        ButtonBG = Color3.fromRGB(75, 35, 55),
        Accent = Color3.fromRGB(255, 170, 200),
        Text = Color3.fromRGB(255, 230, 240),
        UnselectedTabBtn = Color3.fromRGB(45, 20, 32),
        MainTrans = 0.1, TopbarTrans = 0.15, ButtonTrans = 0
    },
    ["Desert Gold"] = {
        MainBG = Color3.fromRGB(22, 18, 12),
        TopbarBG = Color3.fromRGB(40, 32, 22),
        ButtonBG = Color3.fromRGB(60, 48, 32),
        Accent = Color3.fromRGB(240, 190, 80),
        Text = Color3.fromRGB(245, 235, 215),
        UnselectedTabBtn = Color3.fromRGB(32, 25, 18),
        MainTrans = 0.1, TopbarTrans = 0.15, ButtonTrans = 0
    },
    ["Ocean Deep"] = {
        MainBG = Color3.fromRGB(3, 12, 24),
        TopbarBG = Color3.fromRGB(6, 24, 45),
        ButtonBG = Color3.fromRGB(10, 38, 70),
        Accent = Color3.fromRGB(0, 235, 210),
        Text = Color3.fromRGB(210, 245, 255),
        UnselectedTabBtn = Color3.fromRGB(5, 18, 35),
        MainTrans = 0.1, TopbarTrans = 0.15, ButtonTrans = 0
    },
    ["Toxic Waste"] = {
        MainBG = Color3.fromRGB(12, 16, 10),
        TopbarBG = Color3.fromRGB(22, 30, 18),
        ButtonBG = Color3.fromRGB(32, 45, 26),
        Accent = Color3.fromRGB(170, 255, 0),
        Text = Color3.fromRGB(215, 245, 200),
        UnselectedTabBtn = Color3.fromRGB(18, 24, 15),
        MainTrans = 0.1, TopbarTrans = 0.15, ButtonTrans = 0
    },

    -- [[ AGRESİF & GÜÇLÜ TEMALAR ]] --
    ["Bloodlust"] = {
        MainBG = Color3.fromRGB(10, 0, 0),
        TopbarBG = Color3.fromRGB(22, 0, 0),
        ButtonBG = Color3.fromRGB(38, 0, 0),
        Accent = Color3.fromRGB(180, 0, 0),
        Text = Color3.fromRGB(240, 180, 180),
        UnselectedTabBtn = Color3.fromRGB(16, 0, 0),
        MainTrans = 0.05, TopbarTrans = 0.1, ButtonTrans = 0
    },
    ["Midnight Gold"] = {
        MainBG = Color3.fromRGB(10, 10, 10),
        TopbarBG = Color3.fromRGB(20, 20, 20),
        ButtonBG = Color3.fromRGB(30, 30, 30),
        Accent = Color3.fromRGB(218, 165, 32),
        Text = Color3.fromRGB(235, 235, 235),
        UnselectedTabBtn = Color3.fromRGB(15, 15, 15),
        MainTrans = 0.1, TopbarTrans = 0.15, ButtonTrans = 0
    },
    ["Plague"] = {
        MainBG = Color3.fromRGB(14, 15, 12),
        TopbarBG = Color3.fromRGB(28, 30, 24),
        ButtonBG = Color3.fromRGB(42, 45, 36),
        Accent = Color3.fromRGB(128, 140, 80),
        Text = Color3.fromRGB(200, 205, 185),
        UnselectedTabBtn = Color3.fromRGB(22, 24, 19),
        MainTrans = 0.1, TopbarTrans = 0.15, ButtonTrans = 0
    },

    -- [[ RETRO & GELİŞTİRİCİ TEMALARI ]] --
    ["Dracula"] = {
        MainBG = Color3.fromRGB(40, 42, 54),
        TopbarBG = Color3.fromRGB(33, 34, 44),
        ButtonBG = Color3.fromRGB(55, 58, 75),
        Accent = Color3.fromRGB(255, 121, 198),
        Text = Color3.fromRGB(248, 248, 242),
        UnselectedTabBtn = Color3.fromRGB(45, 47, 60),
        MainTrans = 0.05, TopbarTrans = 0.1, ButtonTrans = 0
    },
    ["One Dark"] = {
        MainBG = Color3.fromRGB(40, 44, 52),
        TopbarBG = Color3.fromRGB(33, 37, 43),
        ButtonBG = Color3.fromRGB(50, 56, 66),
        Accent = Color3.fromRGB(97, 175, 239),
        Text = Color3.fromRGB(171, 178, 191),
        UnselectedTabBtn = Color3.fromRGB(44, 49, 58),
        MainTrans = 0.05, TopbarTrans = 0.1, ButtonTrans = 0
    },
    ["Synthwave"] = {
        MainBG = Color3.fromRGB(20, 10, 28),
        TopbarBG = Color3.fromRGB(35, 15, 45),
        ButtonBG = Color3.fromRGB(50, 20, 65),
        Accent = Color3.fromRGB(255, 0, 127),
        Text = Color3.fromRGB(0, 240, 255),
        UnselectedTabBtn = Color3.fromRGB(28, 12, 38),
        MainTrans = 0.1, TopbarTrans = 0.15, ButtonTrans = 0
    },
    
    -- [[ FULL CUSTOM DIZAYN TEMASI ]] --
    ["Custom Designer"] = {
        MainBG = Color3.fromRGB(10, 10, 15),
        TopbarBG = Color3.fromRGB(18, 18, 25),
        ButtonBG = Color3.fromRGB(28, 28, 40),
        Accent = Color3.fromRGB(0, 160, 255),
        Text = Color3.fromRGB(240, 240, 250),
        UnselectedTabBtn = Color3.fromRGB(20, 20, 30),
        MainTrans = 0.1, TopbarTrans = 0.15, ButtonTrans = 0,
        BGImage = "",
        BGImageTrans = 1,
        BlurTrans = 1
    }
}

-- Dinamik olarak güncellenecek UI elemanları listesi
local registry = {
    MainBG = {},      -- mainFrame, topFix vb.
    TopbarBG = {},    -- topbar
    ButtonBG = {},    -- butonlar, toggle kutuları vb.
    Accent = {},      -- aktif çizgiler, kaydırma çubukları vb.
    Text = {},        -- başlıklar, etiketler vb.
    TabBtns = {},     -- Sekme butonlarının kendileri
    ScrollFrames = {} -- Kaydırma çerçevenleri (kaydırma çubuğu rengi için)
}

local currentTheme = "ϟϟ Theme"

function registerObj(obj, category)
    if registry[category] then
        table.insert(registry[category], obj)
    end
end

function applyTheme(themeName)
    local cfg = themeData[themeName]
    if not cfg then return end
    currentTheme = themeName

    -- Seçilen temayı Custom Designer değerlerine kopyala (UI senkron)
    if themeName ~= "Custom Designer" and cfg then
        local cd = themeData["Custom Designer"]
        if cd then
            for _, key in ipairs({"MainBG", "TopbarBG", "ButtonBG", "Accent", "Text", "UnselectedTabBtn", "BGImage", "BGImageTrans", "BlurTrans"}) do
                if cfg[key] ~= nil then cd[key] = cfg[key] end
            end
        end
        if type(_G.ananistwaffendivisionOnThemeApplied) == "function" then
            pcall(_G.ananistwaffendivisionOnThemeApplied, themeName, cfg)
        end
    end

    -- Smooth Tween'lerle renkleri yumuşakça geçir
    local function tween(obj, props)
        pcall(function()
            TweenService:Create(obj, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
        end)
    end

    -- Resimli background ayarlarını uygula
    if bgImageLabel and blurOverlay then
        if cfg.BGImage and cfg.BGImage ~= "" then
            bgImageLabel.Image = cfg.BGImage
            tween(bgImageLabel, {ImageTransparency = cfg.BGImageTrans or 0.3})
        else
            if themeName ~= "Custom Designer" then
                bgImageLabel.Image = ""
                tween(bgImageLabel, {ImageTransparency = 1})
            end
        end
        
        if cfg.BlurTrans then
            tween(blurOverlay, {BackgroundTransparency = cfg.BlurTrans})
        else
            if themeName ~= "Custom Designer" then
                tween(blurOverlay, {BackgroundTransparency = 1})
            end
        end
    end

    for _, obj in pairs(registry.MainBG) do
        if obj:IsA("Frame") then
            local trans = (obj.Name == "topFix") and cfg.MainTrans or cfg.MainTrans
            tween(obj, {BackgroundColor3 = cfg.MainBG, BackgroundTransparency = trans})
        end
    end

    for _, obj in pairs(registry.TopbarBG) do
        tween(obj, {BackgroundColor3 = cfg.TopbarBG, BackgroundTransparency = cfg.TopbarTrans})
    end

    for _, obj in pairs(registry.ButtonBG) do
        local isToggleBg = obj:GetAttribute("IsToggleBg")
        local isToggleActive = obj:GetAttribute("ToggleActive")
        if isToggleBg then
            if not isToggleActive then
                tween(obj, {BackgroundColor3 = Color3.fromRGB(80, 80, 80)})
            end
        else
            tween(obj, {BackgroundColor3 = cfg.ButtonBG, BackgroundTransparency = cfg.ButtonTrans})
        end
    end

    for _, obj in pairs(registry.Accent) do
        if obj:IsA("Frame") then
            tween(obj, {BackgroundColor3 = cfg.Accent})
        end
    end

    for _, obj in pairs(registry.Text) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            local isClose = obj:GetAttribute("IsCloseButton")
            if not isClose then
                tween(obj, {TextColor3 = cfg.Text})
            end
        end
    end

    for _, obj in pairs(registry.ScrollFrames) do
        if obj:IsA("ScrollingFrame") then
            tween(obj, {ScrollBarImageColor3 = cfg.Accent})
        end
    end

    -- Tab butonlarının renklerini seçili olma durumlarına göre yenile
    for _, item in pairs(registry.TabBtns) do
        local btn = item.Btn
        local ind = item.Indicator
        if ind.Visible then -- Seçili sekme
            tween(btn, {BackgroundColor3 = Color3.fromRGB(18, 18, 18), BackgroundTransparency = 0, TextColor3 = cfg.Text})
            tween(ind, {BackgroundColor3 = cfg.Accent})
        else -- Seçili olmayan sekme
            tween(btn, {BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0, TextColor3 = cfg.Text})
        end
    end
end

-- [[ YENİ UI - SMOOTH, COOL, KAPANMA SORUNU ÇÖZÜLDÜ, SİMGELER GÜNCELLENDİ ]] --

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ananistwaffendivisionUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling -- Katman uyumluluğu için Sibling yapıldı
screenGui.Parent = CoreGui

-- Bu kopya, bir sonraki AWD Hub açılışında temizlenecek.
_G.ananistwaffendivisionCleanup = function()
    pcall(function()
        if _G.ananistwaffendivisionBodycamStopPlayback then _G.ananistwaffendivisionBodycamStopPlayback() end
    end)
    pcall(function()
        if _G.AnanistanInsert then
            _G.AnanistanInsert:Disconnect()
            _G.AnanistanInsert = nil
        end
    end)
    pcall(function()
        if type(stopAimbot) == "function" then stopAimbot() end
    end)
    pcall(function()
        if type(stopKosatka) == "function" then stopKosatka() end
    end)
    pcall(function()
        if parachuteConnection then parachuteConnection:Disconnect(); parachuteConnection = nil end
        if parachuteTrack then parachuteTrack:Stop(); parachuteTrack = nil end
    end)
    pcall(function()
        if infiniteJumpConn then infiniteJumpConn:Disconnect(); infiniteJumpConn = nil end
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
        if espLoopThread then task.cancel(espLoopThread); espLoopThread = nil end
        for _, conn in pairs(espConnections or {}) do if conn then conn:Disconnect() end end
        espConnections = {}
    end)
    pcall(function()
        if screenGui then screenGui:Destroy() end
    end)
    _G.ananistwaffendivisionCleanup = nil
end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 800, 0, 560)
mainFrame.Position = UDim2.new(0.5, -400, 0.5, -280)
mainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
registerObj(mainFrame, "MainBG")

-- [[ GÜMÜŞ OUTLINE (UIStroke) EKLEMESİ ]] --
local silverStroke = Instance.new("UIStroke")
silverStroke.Name = "SilverOutline"
silverStroke.Thickness = 1.5
silverStroke.Color = Color3.fromRGB(192, 192, 192) -- Gümüş Rengi
silverStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
silverStroke.Parent = mainFrame

-- [[ ÖZELLEŞTİRİLEBİLİR GÖRSEL KATMANI VE BULANIKLIK SİTEMİ ]] --
bgImageLabel = Instance.new("ImageLabel")
bgImageLabel.Name = "CustomBGImage"
bgImageLabel.Size = UDim2.new(1, 0, 1, 0)
bgImageLabel.Position = UDim2.new(0, 0, 0, 0)
bgImageLabel.BackgroundTransparency = 1
bgImageLabel.Image = ""
bgImageLabel.ImageTransparency = 1
bgImageLabel.ScaleType = Enum.ScaleType.Crop
bgImageLabel.ZIndex = 2 -- Panelin üstünde, butonların altında kalacak şekilde 2 yapıldı
bgImageLabel.Parent = mainFrame

-- Arka plan resminin üzerine binecek ve bulanıklık simülasyonu yapacak yumuşatıcı katman
blurOverlay = Instance.new("Frame")
blurOverlay.Name = "BlurOverlay"
blurOverlay.Size = UDim2.new(1, 0, 1, 0)
blurOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
blurOverlay.BackgroundTransparency = 1
blurOverlay.ZIndex = 3 -- Resmin hemen üstünde katmanlanması için 3 yapıldı
blurOverlay.Parent = mainFrame

local imgCorner = Instance.new("UICorner", bgImageLabel)
imgCorner.CornerRadius = UDim.new(0, 22)

local overlayCorner = Instance.new("UICorner", blurOverlay)
overlayCorner.CornerRadius = UDim.new(0, 22)

local blurEffect = Instance.new("BlurEffect", game:GetService("Lighting"))
blurEffect.Size = 0

local blurHolder = Instance.new("Frame")
blurHolder.Size = mainFrame.Size
blurHolder.Position = mainFrame.Position
blurHolder.BackgroundTransparency = 1
blurHolder.Parent = screenGui
blurHolder.Name = "BlurHolder"

function updateBlur()
    if not mainFrame or not blurHolder then return end
    pcall(function()
        local absPos = mainFrame.AbsolutePosition
        local absSize = mainFrame.AbsoluteSize
        if blurHolder then
            blurHolder.Position = UDim2.new(0, absPos.X, 0, absPos.Y)
            blurHolder.Size = UDim2.new(0, absSize.X, 0, absSize.Y)
        end
    end)
end

mainFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateBlur)
mainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateBlur)
task.delay(0.1, updateBlur)

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 22)

local shadow = Instance.new("ImageLabel", mainFrame)
shadow.Size = UDim2.new(1, 60, 1, 60)
shadow.Position = UDim2.new(0, -30, 0, -30)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316115263"
shadow.ImageColor3 = Color3.new(0,0,0)
shadow.ImageTransparency = 0.7
shadow.ZIndex = -1

local topbar = Instance.new("Frame", mainFrame)
topbar.Size = UDim2.new(1, 0, 0, 50)
topbar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
topbar.BackgroundTransparency = 0.15
topbar.BorderSizePixel = 0
topbar.ZIndex = 5 -- Elementlerin görsel üstünde kalması sağlandı
registerObj(topbar, "TopbarBG")

local topCorner = Instance.new("UICorner", topbar)
topCorner.CornerRadius = UDim.new(0, 22)

local topFix = Instance.new("Frame", topbar)
topFix.Name = "topFix"
topFix.Size = UDim2.new(1, 0, 0, 22)
topFix.Position = UDim2.new(0, 0, 1, -22)
topFix.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
topFix.BackgroundTransparency = 0.1
topFix.BorderSizePixel = 0
topFix.ZIndex = 5
registerObj(topFix, "MainBG")

local title = Instance.new("TextLabel", topbar)
title.Size = UDim2.new(1, -120, 1, 0)
title.Position = UDim2.new(0, 25, 0, 0)
title.BackgroundTransparency = 1
title.Text = "ϟϟ AWD HUB ϟϟ"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 6
registerObj(title, "Text")

function smoothTween(obj, props, duration)
    if not obj then return end
    pcall(function()
        TweenService:Create(obj, TweenInfo.new(duration or 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end)
end

-- Kapatma butonu
local closeBtn = Instance.new("TextButton", topbar)
closeBtn.Size = UDim2.new(0, 45, 1, 0)
closeBtn.Position = UDim2.new(1, -45, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "ϟϟ"
closeBtn.TextColor3 = Color3.fromRGB(255, 70, 70)
closeBtn.TextSize = 22
closeBtn.Font = Enum.Font.GothamBold
closeBtn.ZIndex = 6
closeBtn:SetAttribute("IsCloseButton", true)

local isClosing = false
closeBtn.MouseButton1Click:Connect(function()
    if isClosing then return end
    isClosing = true
    pcall(function()
        smoothTween(mainFrame, {BackgroundTransparency = 1}, 0.2)
        smoothTween(topbar, {BackgroundTransparency = 1}, 0.2)
    end)
    task.delay(0.25, function()
        pcall(function()
            screenGui.Enabled = false
            mainFrame.Visible = false
            isClosing = false
        end)
    end)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "AWD Hub",
            Text = "Menü için INSERT",
            Duration = 3
        })
    end)
end)

local minBtn = Instance.new("TextButton", topbar)
minBtn.Size = UDim2.new(0, 45, 1, 0)
minBtn.Position = UDim2.new(1, -90, 0, 0)
minBtn.BackgroundTransparency = 1
minBtn.Text = "—"
minBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
minBtn.TextSize = 22
minBtn.Font = Enum.Font.GothamBold
minBtn.ZIndex = 6
minBtn:SetAttribute("IsCloseButton", true)

local isMinimized = false
local beforeMinSize = mainFrame.Size
minBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        beforeMinSize = mainFrame.Size
        smoothTween(mainFrame, {Size = UDim2.new(0, beforeMinSize.X.Offset, 0, 50)}, 0.3)
        mainFrame.ClipsDescendants = true
    else
        smoothTween(mainFrame, {Size = beforeMinSize}, 0.3)
        task.wait(0.35)
        mainFrame.ClipsDescendants = false
    end
end)

local dragging = false
local dragStart, startPos, dragInput
topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
topbar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        updateBlur()
    end
end)

-- [[ SOL SIDEBAR NAVIGATION // AWD REDESIGN ]] --
local sidebarWidth = 148

local tabNav = Instance.new("ScrollingFrame", mainFrame)
tabNav.Name = "AWD_Sidebar"
tabNav.Size = UDim2.new(0, sidebarWidth, 1, -68)
tabNav.Position = UDim2.new(0, 10, 0, 58)
tabNav.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
tabNav.BackgroundTransparency = 0
tabNav.BorderSizePixel = 0
tabNav.ZIndex = 5
tabNav.ScrollingDirection = Enum.ScrollingDirection.Y
tabNav.ScrollBarThickness = 3
tabNav.ScrollBarImageColor3 = Color3.fromRGB(115, 115, 140)
tabNav.CanvasSize = UDim2.new(0, 0, 0, 0)
tabNav.AutomaticCanvasSize = Enum.AutomaticSize.Y
tabNav.ClipsDescendants = true
local sideCorner = Instance.new("UICorner", tabNav)
sideCorner.CornerRadius = UDim.new(0, 12)
local tabLayout = Instance.new("UIListLayout", tabNav)
tabLayout.FillDirection = Enum.FillDirection.Vertical
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 5)
local sidePadding = Instance.new("UIPadding", tabNav)
sidePadding.PaddingTop = UDim.new(0, 8)
sidePadding.PaddingBottom = UDim.new(0, 8)
sidePadding.PaddingLeft = UDim.new(0, 7)
sidePadding.PaddingRight = UDim.new(0, 7)

local contentArea = Instance.new("Frame", mainFrame)
contentArea.Name = "AWD_ContentArea"
contentArea.Size = UDim2.new(1, -(sidebarWidth + 28), 1, -68)
contentArea.Position = UDim2.new(0, sidebarWidth + 18, 0, 58)
contentArea.BackgroundTransparency = 1
contentArea.ClipsDescendants = true
contentArea.ZIndex = 5

local tabs = {}
local activeTab = nil
local tabSwitchToken = 0

function CreateTab(name)
    local tabBtn = Instance.new("TextButton", tabNav)
    tabBtn.Name = "Nav_" .. name:gsub("%W", "")
    tabBtn.Size = UDim2.new(1, 0, 0, 38)
    tabBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    tabBtn.BackgroundTransparency = 0
    tabBtn.Text = "   " .. name
    tabBtn.TextColor3 = Color3.fromRGB(178, 178, 199)
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.Font = Enum.Font.GothamMedium
    tabBtn.TextSize = 12
    tabBtn.BorderSizePixel = 0
    tabBtn.AutoButtonColor = false
    tabBtn.ZIndex = 6
    registerObj(tabBtn, "Text")
    local tabCorner = Instance.new("UICorner", tabBtn)
    tabCorner.CornerRadius = UDim.new(0, 8)
    local indicator = Instance.new("Frame", tabBtn)
    indicator.Name = "ActiveOutline"
    indicator.Size = UDim2.new(1, -2, 1, -2)
    indicator.Position = UDim2.new(0, 1, 0, 1)
    indicator.BackgroundTransparency = 1
    indicator.BorderSizePixel = 0
    indicator.Visible = false
    indicator.ZIndex = 7
    local outline = Instance.new("UIStroke", indicator)
    outline.Color = Color3.fromRGB(145, 145, 160)
    outline.Thickness = 1
    outline.Transparency = 0.15
    local indCorner = Instance.new("UICorner", indicator)
    indCorner.CornerRadius = UDim.new(0, 8)

    local scroll = Instance.new("ScrollingFrame", contentArea)
    scroll.Name = "Page_" .. name:gsub("%W", "")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.Position = UDim2.new(0, 0, 0, 8)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Color3.fromRGB(145, 145, 165)
    scroll.Visible = false
    scroll.ZIndex = 5
    scroll.ClipsDescendants = true
    registerObj(scroll, "ScrollFrames")

    local list = Instance.new("UIListLayout", scroll)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 8)
    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 20)
    end)

    local tabData = {Btn = tabBtn, Frame = scroll, Indicator = indicator}
    table.insert(tabs, tabData)
    table.insert(registry.TabBtns, tabData)

    local function selectTab()
        if activeTab == tabData then return end
        activeTab = tabData
        tabSwitchToken += 1
        local token = tabSwitchToken
        for _, t in ipairs(tabs) do
            local selected = (t == tabData)
            t.Indicator.Visible = selected
            smoothTween(t.Btn, {
                BackgroundColor3 = selected and Color3.fromRGB(18, 18, 18) or Color3.fromRGB(0, 0, 0),
                BackgroundTransparency = 0,
                TextColor3 = selected and Color3.fromRGB(248, 248, 255) or Color3.fromRGB(178, 178, 199)
            }, 0.22)
            if t ~= tabData and t.Frame.Visible then
                t.Frame.Visible = false
            end
        end
        scroll.Visible = true
        scroll.Position = UDim2.new(0, 12, 0, 8)
        smoothTween(scroll, {Position = UDim2.new(0, 0, 0, 0)}, 0.24)
        applyTheme(currentTheme)
    end
    tabBtn.MouseButton1Click:Connect(selectTab)
    tabBtn.MouseEnter:Connect(function()
        if activeTab ~= tabData then
            smoothTween(tabBtn, {BackgroundColor3 = Color3.fromRGB(10, 10, 10)}, 0.12)
        end
    end)
    tabBtn.MouseLeave:Connect(function()
        if activeTab ~= tabData then
            smoothTween(tabBtn, {BackgroundColor3 = Color3.fromRGB(0, 0, 0)}, 0.12)
        end
    end)
    tabData.Select = selectTab
    return scroll, tabData
end

function AddButton(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 27)
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ZIndex = 5
    registerObj(btn, "ButtonBG")
    
    local cornerBtn = Instance.new("UICorner", btn)
    cornerBtn.CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(100, 105, 128)
    stroke.Transparency = 0.58
    stroke.Thickness = 1
    local accent = Instance.new("Frame", btn)
    accent.Size = UDim2.new(0, 3, 0, 18)
    accent.Position = UDim2.new(0, 7, 0.5, -9)
    accent.BackgroundColor3 = Color3.fromRGB(175, 190, 255)
    accent.BackgroundTransparency = 0.78
    accent.BorderSizePixel = 0
    accent.ZIndex = 6
    local accentCorner = Instance.new("UICorner", accent)
    accentCorner.CornerRadius = UDim.new(1, 0)
    
    local label = Instance.new("TextLabel", btn)
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 17, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 6
    registerObj(label, "Text")
    
    btn.MouseEnter:Connect(function()
        smoothTween(btn, {BackgroundColor3 = Color3.fromRGB(40, 42, 53)}, 0.14)
        smoothTween(stroke, {Transparency = 0.12, Color = Color3.fromRGB(185, 195, 255)}, 0.14)
        smoothTween(accent, {BackgroundTransparency = 0.05, Size = UDim2.new(0, 3, 0, 24), Position = UDim2.new(0, 7, 0.5, -12)}, 0.14)
    end)
    btn.MouseLeave:Connect(function()
        smoothTween(btn, {BackgroundColor3 = Color3.fromRGB(22, 22, 27)}, 0.16)
        smoothTween(stroke, {Transparency = 0.58, Color = Color3.fromRGB(100, 105, 128)}, 0.16)
        smoothTween(accent, {BackgroundTransparency = 0.78, Size = UDim2.new(0, 3, 0, 18), Position = UDim2.new(0, 7, 0.5, -9)}, 0.16)
    end)
    btn.MouseButton1Down:Connect(function() smoothTween(btn, {Size = UDim2.new(1, -14, 0, 36)}, 0.08) end)
    btn.MouseButton1Up:Connect(function() smoothTween(btn, {Size = UDim2.new(1, -10, 0, 38)}, 0.1) end)
    btn.MouseButton1Click:Connect(function() pcall(callback) end)
    return btn
end

function AddToggle(parent, text, defaultState, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 38)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    frame.ZIndex = 5
    registerObj(frame, "ButtonBG")
    
    local cornerFrame = Instance.new("UICorner", frame)
    cornerFrame.CornerRadius = UDim.new(0, 10)
    local frameStroke = Instance.new("UIStroke", frame)
    frameStroke.Color = Color3.fromRGB(100, 105, 128)
    frameStroke.Transparency = 0.62
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 6
    registerObj(label, "Text")

    local togBg = Instance.new("Frame", frame)
    togBg.Size = UDim2.new(0, 45, 0, 22)
    togBg.Position = UDim2.new(1, -55, 0.5, -11)
    togBg.BackgroundColor3 = defaultState and Color3.fromRGB(80, 220, 80) or Color3.fromRGB(80, 80, 80)
    togBg:SetAttribute("IsToggleBg", true)
    togBg:SetAttribute("ToggleActive", defaultState)
    togBg.ZIndex = 5
    registerObj(togBg, "ButtonBG")
    
    local togCorner = Instance.new("UICorner", togBg)
    togCorner.CornerRadius = UDim.new(0, 11)

    local togCircle = Instance.new("Frame", togBg)
    togCircle.Size = UDim2.new(0, 18, 0, 18)
    togCircle.Position = UDim2.new(defaultState and 0.55 or 0.05, 0, 0.5, -9)
    togCircle.BackgroundColor3 = Color3.new(1,1,1)
    togCircle.ZIndex = 6
    local circleCorner = Instance.new("UICorner", togCircle)
    circleCorner.CornerRadius = UDim.new(0, 9)

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 6

    local state = defaultState
    local function UpdateVis()
        pcall(function()
            -- Dinamik renk eşleştirmesi (Veya Özel Tasarımcı Aktifken Accent Rengi Kullanımı)
            local activeColor = (currentTheme == "Custom Designer") and themeData["Custom Designer"].Accent
                             or (currentTheme == "Kırmızı theme" or currentTheme == "Bloodlust") and Color3.fromRGB(255, 50, 50) 
                             or (currentTheme == "Yeşil theme" or currentTheme == "Matrix" or currentTheme == "Toxic Waste" or currentTheme == "Minecraft") and Color3.fromRGB(50, 255, 50)
                             or (currentTheme == "Cyberpunk") and Color3.fromRGB(255, 243, 0)
                             or (currentTheme == "Space Void" or currentTheme == "Ocean Deep") and Color3.fromRGB(0, 190, 255)
                             or (currentTheme == "Sakura") and Color3.fromRGB(255, 170, 200)
                             or (currentTheme == "Half-Life") and Color3.fromRGB(247, 134, 14)
                             or (currentTheme == "Desert Gold" or currentTheme == "Midnight Gold") and Color3.fromRGB(218, 165, 32)
                             or Color3.fromRGB(80, 220, 80)
            
            togBg:SetAttribute("ToggleActive", state)
            TweenService:Create(togBg, TweenInfo.new(0.2), {BackgroundColor3 = state and activeColor or Color3.fromRGB(80, 80, 80)}):Play()
            TweenService:Create(togCircle, TweenInfo.new(0.2), {Position = UDim2.new(state and 0.55 or 0.05, 0, 0.5, -9)}):Play()
        end)
    end

    btn.MouseButton1Click:Connect(function()
        state = not state
        UpdateVis()
        pcall(function() callback(state) end)
    end)
    btn.MouseEnter:Connect(function()
        smoothTween(frame, {BackgroundColor3 = Color3.fromRGB(40, 42, 53)}, 0.14)
        smoothTween(frameStroke, {Transparency = 0.18}, 0.14)
    end)
    btn.MouseLeave:Connect(function()
        smoothTween(frame, {BackgroundColor3 = Color3.fromRGB(22, 22, 27)}, 0.16)
        smoothTween(frameStroke, {Transparency = 0.62}, 0.16)
    end)

    return function(forceState)
        if forceState ~= nil then state = forceState end
        UpdateVis()
    end
end

local colorPickerFrame = Instance.new("Frame", screenGui)
colorPickerFrame.Size = UDim2.new(0, 220, 0, 260)
colorPickerFrame.Position = UDim2.new(0.5, -110, 0.5, -130)
colorPickerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
colorPickerFrame.Visible = false
colorPickerFrame.ZIndex = 10
registerObj(colorPickerFrame, "TopbarBG")

local pickerCorner = Instance.new("UICorner", colorPickerFrame)
pickerCorner.CornerRadius = UDim.new(0, 12)

local pTitle = Instance.new("TextLabel", colorPickerFrame)
pTitle.Size = UDim2.new(1, 0, 0, 30)
pTitle.Position = UDim2.new(0, 0, 0, 0)
pTitle.BackgroundTransparency = 1
pTitle.Text = " Renk Seçici"
pTitle.TextColor3 = Color3.fromRGB(220, 220, 240)
pTitle.TextSize = 14
pTitle.Font = Enum.Font.GothamBold
pTitle.TextXAlignment = Enum.TextXAlignment.Left
registerObj(pTitle, "Text")

local closeColorBtn = Instance.new("TextButton", colorPickerFrame)
closeColorBtn.Size = UDim2.new(0, 30, 0, 30)
closeColorBtn.Position = UDim2.new(1, -30, 0, 0)
closeColorBtn.BackgroundTransparency = 1
closeColorBtn.Text = "✕"
closeColorBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeColorBtn.Font = Enum.Font.GothamBold
closeColorBtn.TextSize = 16
closeColorBtn.ZIndex = 11
closeColorBtn:SetAttribute("IsCloseButton", true)
closeColorBtn.MouseButton1Click:Connect(function() colorPickerFrame.Visible = false end)

local wheelImg = Instance.new("ImageButton", colorPickerFrame)
wheelImg.Size = UDim2.new(0, 170, 0, 170)
wheelImg.Position = UDim2.new(0.5, -85, 0, 35)
wheelImg.Image = "rbxassetid://6020299385"
wheelImg.BackgroundTransparency = 1
wheelImg.ZIndex = 11

local rgbBox = Instance.new("TextBox", colorPickerFrame)
rgbBox.Size = UDim2.new(0, 170, 0, 35)
rgbBox.Position = UDim2.new(0.5, -85, 1, -45)
rgbBox.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
rgbBox.TextColor3 = Color3.fromRGB(220, 220, 240)
rgbBox.Font = Enum.Font.GothamMedium
rgbBox.TextSize = 14
rgbBox.Text = "255, 255, 255"
registerObj(rgbBox, "ButtonBG")
registerObj(rgbBox, "Text")

local rgbCorner = Instance.new("UICorner", rgbBox)
rgbCorner.CornerRadius = UDim.new(0, 8)
rgbBox.ZIndex = 11

local applyPickedColorCallback = nil

wheelImg.MouseButton1Down:Connect(function()
    local mouse = game.Players.LocalPlayer:GetMouse()
    local conn
    local function updateColor()
        local center = wheelImg.AbsolutePosition + wheelImg.AbsoluteSize/2
        local x = mouse.X - center.X
        local y = center.Y - mouse.Y
        local angle = math.atan2(y, x)
        local hue = (angle + math.pi) / (math.pi * 2)
        local rad = math.clamp(math.sqrt(x*x + y*y) / (wheelImg.AbsoluteSize.X/2), 0, 1)
        local color = Color3.fromHSV(hue, rad, 1)
        rgbBox.Text = string.format("%d, %d, %d", math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255))
        if applyPickedColorCallback then applyPickedColorCallback(color) end
    end
    updateColor()
    conn = mouse.Move:Connect(updateColor)
    local upConn
    upConn = UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            conn:Disconnect()
            upConn:Disconnect()
        end
    end)
end)

rgbBox.FocusLost:Connect(function()
    local txt = rgbBox.Text
    local split = string.split(txt, ",")
    if #split == 3 then
        local r = tonumber(split[1]:match("%d+"))
        local g = tonumber(split[2]:match("%d+"))
        local b = tonumber(split[3]:match("%d+"))
        if r and g and b then
            local color = Color3.fromRGB(math.clamp(r,0,255), math.clamp(g,0,255), math.clamp(b,0,255))
            if applyPickedColorCallback then applyPickedColorCallback(color) end
        end
    end
end)

function AddColorPicker(parent, text, defaultColor, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 38)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    frame.ZIndex = 5
    registerObj(frame, "ButtonBG")
    
    local frameCorner = Instance.new("UICorner", frame)
    frameCorner.CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 6
    registerObj(label, "Text")

    local cBtn = Instance.new("TextButton", frame)
    cBtn.Size = UDim2.new(0, 35, 0, 22)
    cBtn.Position = UDim2.new(1, -45, 0.5, -11)
    cBtn.BackgroundColor3 = defaultColor
    cBtn.Text = ""
    cBtn.ZIndex = 6
    local cBtnCorner = Instance.new("UICorner", cBtn)
    cBtnCorner.CornerRadius = UDim.new(0, 6)

    cBtn.MouseButton1Click:Connect(function()
        colorPickerFrame.Visible = true
        rgbBox.Text = string.format("%d, %d, %d", math.floor(cBtn.BackgroundColor3.R*255), math.floor(cBtn.BackgroundColor3.G*255), math.floor(cBtn.BackgroundColor3.B*255))
        applyPickedColorCallback = function(col)
            cBtn.BackgroundColor3 = col
            callback(col)
        end
    end)

    return function(col) cBtn.BackgroundColor3 = col end
end

function AddTextBox(parent, placeholder, callback)
    local box = Instance.new("TextBox", parent)
    box.Size = UDim2.new(1, -10, 0, 35)
    box.BackgroundColor3 = Color3.fromRGB(18, 18, 23)
    box.TextColor3 = Color3.fromRGB(220, 220, 240)
    box.PlaceholderText = placeholder
    box.Text = ""
    box.Font = Enum.Font.GothamMedium
    box.TextSize = 13
    box.ClearTextOnFocus = false
    box.ZIndex = 5
    registerObj(box, "ButtonBG")
    registerObj(box, "Text")
    
    local boxCorner = Instance.new("UICorner", box)
    boxCorner.CornerRadius = UDim.new(0, 10)
    local boxStroke = Instance.new("UIStroke", box)
    boxStroke.Color = Color3.fromRGB(100, 105, 128)
    boxStroke.Transparency = 0.58
    box.Focused:Connect(function()
        smoothTween(boxStroke, {Transparency = 0.05, Color = Color3.fromRGB(185, 195, 255)}, 0.15)
        smoothTween(box, {BackgroundColor3 = Color3.fromRGB(28, 29, 38)}, 0.15)
    end)
    box.FocusLost:Connect(function()
        smoothTween(boxStroke, {Transparency = 0.58, Color = Color3.fromRGB(100, 105, 128)}, 0.15)
        smoothTween(box, {BackgroundColor3 = Color3.fromRGB(18, 18, 23)}, 0.15)
    end)
    box.FocusLost:Connect(function() pcall(function() callback(box.Text) end) end)
    return box
end

function AddSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 58)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    frame.ZIndex = 5
    registerObj(frame, "ButtonBG")
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.55, 0, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 2)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 6
    registerObj(label, "Text")

    local valueBox = Instance.new("TextBox", frame)
    valueBox.Size = UDim2.new(0, 70, 0, 20)
    valueBox.Position = UDim2.new(1, -80, 0, 2)
    valueBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    valueBox.TextColor3 = Color3.fromRGB(220, 220, 240)
    valueBox.Text = tostring(math.floor(default * 100) / 100)
    valueBox.TextSize = 12
    valueBox.Font = Enum.Font.GothamMedium
    valueBox.ClearTextOnFocus = false
    valueBox.ZIndex = 6
    Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 4)
    registerObj(valueBox, "ButtonBG")
    registerObj(valueBox, "Text")

    local sliderBg = Instance.new("Frame", frame)
    sliderBg.Size = UDim2.new(1, -20, 0, 5)
    sliderBg.Position = UDim2.new(0, 10, 1, -16)
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    sliderBg.ZIndex = 5
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0, 3)

    local sliderFill = Instance.new("Frame", sliderBg)
    sliderFill.Size = UDim2.new(math.clamp((default - min) / (max - min), 0, 1), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderFill.ZIndex = 6
    registerObj(sliderFill, "Accent")
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0, 3)

    local sliderBtn = Instance.new("TextButton", sliderBg)
    sliderBtn.Size = UDim2.new(0, 14, 0, 14)
    sliderBtn.Position = UDim2.new(math.clamp((default - min) / (max - min), 0, 1), -7, 0.5, -7)
    sliderBtn.BackgroundColor3 = Color3.new(1,1,1)
    sliderBtn.Text = ""
    sliderBtn.ZIndex = 6
    Instance.new("UICorner", sliderBtn).CornerRadius = UDim.new(0, 7)

    local current = default
    local function applyVisual(val)
        current = val
        local pos = math.clamp((val - min) / (max - min), 0, 1)
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        sliderBtn.Position = UDim2.new(pos, -7, 0.5, -7)
        valueBox.Text = tostring(math.floor(val * 100 + 0.5) / 100)
    end

    local function setFromVal(val, fire)
        val = math.clamp(tonumber(val) or current, min, max)
        applyVisual(val)
        if fire ~= false and callback then callback(val) end
    end

    local function update(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local val = min + (max - min) * pos
        setFromVal(val, true)
    end

    local dragging = false
    sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    valueBox.FocusLost:Connect(function(enter)
        setFromVal(valueBox.Text, true)
    end)

    return function(val)
        setFromVal(val, false)
    end, frame
end


function AddLabel(parent, text, tall)
    local box = Instance.new("TextLabel", parent)
    box.Size = UDim2.new(1, 0, 0, tall and 60 or 28)
    box.BackgroundTransparency = 1
    box.Text = " " .. text
    box.TextColor3 = Color3.fromRGB(200, 200, 220)
    box.TextSize = 14
    box.Font = Enum.Font.GothamBold
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.ZIndex = 5
    registerObj(box, "Text")
    
    if tall then 
        box.TextYAlignment = Enum.TextYAlignment.Top
        box.TextWrapped = true
    end
    return box
end




-- ═══════════════════════════════════════════
-- ANANISTAN AIMBOT — register-safe (single table)
-- ═══════════════════════════════════════════
local AA = {
    silentAim = false, wallhack = false, aimLock = false, triggerBot = false,
    aimLockKey = Enum.UserInputType.MouseButton2, triggerKey = Enum.KeyCode.V,
    aimLockMode = "hold", triggerMode = "toggle",
    ignoreDead = true, ignoreFriends = false, ignoreTeam = false, ignoreNames = "",
    targetPart = "Head", lockMethod = "Mouse",
    stickyTarget = nil, stickyUntil = 0,
    fov = 120,
    prediction = false,
    predictionAmount = 0.12,
    hold = {aimLock = false, triggerBot = false},
    loopConn = nil, silentSetup = false, triggerCd = 0, settingKey = false,
}

function AA.sync() end

function AA.predictPos(part)
    if not part then return nil end
    if not AA.prediction then return part.Position end
    local vel = Vector3.zero
    pcall(function()
        if part.AssemblyLinearVelocity then
            vel = part.AssemblyLinearVelocity
        elseif part.Velocity then
            vel = part.Velocity
        end
    end)
    local amount = tonumber(AA.predictionAmount) or 0.12
    return part.Position + vel * amount
end

function AA.getTarget()
    local cam = workspace.CurrentCamera
    if not cam then return nil, nil end
    local myChar = player.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil, nil end
    local ignoreList = {}
    if AA.ignoreNames ~= "" then
        for name in AA.ignoreNames:gmatch("[^,]+") do
            local t = name:match("^%s*(.-)%s*$")
            if t and t ~= "" then ignoreList[t] = true end
        end
    end
    local fov = tonumber(AA.fov) or 120
    -- Mouse: FOV imleç etrafında (kaynak Waffen gibi)
    -- Camera: FOV ekran ortası
    local centerPos
    if AA.lockMethod == "Camera" then
        local vp = cam.ViewportSize
        centerPos = Vector2.new(vp.X / 2, vp.Y / 2)
    else
        local mousePos = UIS:GetMouseLocation()
        centerPos = Vector2.new(mousePos.X, mousePos.Y)
    end
    local best, bestDist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local valid = true
            local char = p.Character
            local hum = char:FindFirstChildOfClass("Humanoid") or char:FindFirstChild("Humanoid")
            if AA.ignoreDead and (not hum or hum.Health <= 0) then valid = false end
            if AA.ignoreFriends and isFriend(p) then valid = false end
            if AA.ignoreTeam and player.Team and p.Team and player.Team == p.Team then valid = false end
            if ignoreList[p.Name] or ignoreList[p.DisplayName] then valid = false end
            if valid then
                local part = char:FindFirstChild(AA.targetPart) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
                if part then
                    local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
                    if onScreen and screenPos.Z > 0 then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - centerPos).Magnitude
                        if dist <= fov and dist < bestDist then
                            bestDist = dist
                            best = {player = p, part = part}
                        end
                    end
                end
            end
        end
    end
    -- Sticky target
    local now = tick()
    if best then
        AA.stickyTarget = best
        AA.stickyUntil = now + 0.4
        return best.player, best.part
    end
    if AA.stickyTarget and now < AA.stickyUntil then
        local st = AA.stickyTarget
        local char = st.player and st.player.Character
        if char then
            local part = char:FindFirstChild(AA.targetPart) or char:FindFirstChild("Head") or st.part
            local hum = char:FindFirstChildOfClass("Humanoid") or char:FindFirstChild("Humanoid")
            if part and hum and hum.Health > 0 then
                return st.player, part
            end
        end
    end
    AA.stickyTarget = nil
    return nil, nil
end

function AA.active(feature)
    if feature == "silentAim" then return AA.silentAim
    elseif feature == "wallhack" then return AA.wallhack
    elseif feature == "aimLock" then return AA.aimLock and AA.hold.aimLock
    elseif feature == "triggerBot" then return AA.triggerBot and AA.hold.triggerBot
    end
    return false
end

function AA.setupSilent()
    if AA.silentSetup then return end
    AA.silentSetup = true
    pcall(function()
        if type(hookmetamethod) ~= "function" or type(newcclosure) ~= "function" then return end
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if AA.active("silentAim") or AA.active("wallhack") then
                local _, targetPart = AA.getTarget()
                if targetPart then
                    if method == "FindPartOnRayWithIgnoreList" then
                        local args = {...}
                        local origin = workspace.CurrentCamera.CFrame.Position
                        local dir = ((AA.predictPos(targetPart) or targetPart.Position) - origin).Unit * 5000
                        local newRay = Ray.new(origin, dir)
                        if AA.active("wallhack") then
                            local ignoreWalls = {}
                            for _, v in pairs(workspace:GetChildren()) do
                                local isChar = false
                                for _, pl in pairs(Players:GetPlayers()) do
                                    if pl.Character == v then isChar = true break end
                                end
                                if not isChar then table.insert(ignoreWalls, v) end
                            end
                            return oldNamecall(self, newRay, ignoreWalls, table.unpack(args, 3))
                        end
                        return oldNamecall(self, newRay, args[2] or {}, table.unpack(args, 3))
                    elseif method == "FindPartOnRay" then
                        local args = {...}
                        local origin = workspace.CurrentCamera.CFrame.Position
                        local dir = ((AA.predictPos(targetPart) or targetPart.Position) - origin).Unit * 5000
                        return oldNamecall(self, Ray.new(origin, dir), table.unpack(args, 2))
                    elseif method == "Raycast" then
                        local args = {...}
                        local origin = args[1] or workspace.CurrentCamera.CFrame.Position
                        local dir = ((AA.predictPos(targetPart) or targetPart.Position) - origin).Unit * 5000
                        if AA.active("wallhack") then
                            local params = RaycastParams.new()
                            params.FilterType = Enum.RaycastFilterType.Include
                            local chars = {}
                            for _, pl in pairs(Players:GetPlayers()) do
                                if pl ~= player and pl.Character then table.insert(chars, pl.Character) end
                            end
                            params.FilterDescendantsInstances = chars
                            return oldNamecall(self, origin, dir, params)
                        end
                        return oldNamecall(self, origin, dir, args[3])
                    end
                end
            end
            return oldNamecall(self, ...)
        end))
    end)
end

function AA.startLoop()
    if AA.loopConn then return end
    AA.loopConn = RunService.RenderStepped:Connect(function()
        if AA.active("aimLock") then
            local _, targetPart = AA.getTarget()
            if targetPart then
                local aimPos = AA.predictPos(targetPart) or targetPart.Position
                pcall(function()
                    local cam = workspace.CurrentCamera
                    if not cam then return end
                    if AA.lockMethod == "Camera" then
                        cam.CFrame = CFrame.new(cam.CFrame.Position, aimPos)
                    else
                        -- ========== MOUSE AIMBOT (smooth + no drift) ==========
                        local screenPos, onScreen = cam:WorldToViewportPoint(aimPos)
                        if onScreen and screenPos.Z > 0 then
                            local mousePos = UIS:GetMouseLocation()
                            local dx = screenPos.X - mousePos.X
                            local dy = screenPos.Y - mousePos.Y
                            local dist = math.sqrt(dx * dx + dy * dy)

                            -- deadzone: çok yakınsa dokunma (jitter yok)
                            if dist > 2.5 then
                                -- adaptive strength: uzak = daha hızlı, yakın = ultra smooth
                                local strength
                                if dist > 120 then
                                    strength = 0.62
                                elseif dist > 50 then
                                    strength = 0.48
                                else
                                    strength = 0.35
                                end

                                dx = dx * strength
                                dy = dy * strength

                                -- max step clamp: tek frame aşırı sıçrama / spin engeli
                                local maxStep = 38
                                local ax, ay = math.abs(dx), math.abs(dy)
                                if ax > maxStep or ay > maxStep then
                                    local s = maxStep / math.max(ax, ay)
                                    dx, dy = dx * s, dy * s
                                end

                                if type(mousemoverel) == "function" then
                                    pcall(function()
                                        mousemoverel(dx, dy)
                                    end)
                                elseif type(mousemoveabs) == "function" then
                                    pcall(function()
                                        mousemoveabs(mousePos.X + dx, mousePos.Y + dy)
                                    end)
                                else
                                    pcall(function()
                                        game:GetService("VirtualInputManager"):SendMouseMoveEvent(mousePos.X + dx, mousePos.Y + dy, game)
                                    end)
                                end
                            end
                        end
                    end
                end)
            end
        end
        if AA.active("triggerBot") and tick() - AA.triggerCd > 0.1 then
            local mouse = player:GetMouse()
            local target = mouse and mouse.Target
            if target then
                local model = target:FindFirstAncestorOfClass("Model")
                if model then
                    local tp = Players:GetPlayerFromCharacter(model)
                    if tp and tp ~= player then
                        local hum = model:FindFirstChildOfClass("Humanoid") or model:FindFirstChild("Humanoid")
                        if hum and hum.Health > 0 then
                            AA.triggerCd = tick()
                            pcall(function()
                                if type(mouse1click) == "function" then mouse1click()
                                else
                                    local vim = game:GetService("VirtualInputManager")
                                    vim:SendMouseButtonEvent(mouse.X, mouse.Y, 0, true, game, 1)
                                    task.defer(function()
                                        vim:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 1)
                                    end)
                                end
                            end)
                        end
                    end
                end
            end
        end
    end)
end

function AA.stopLoop()
    if AA.loopConn then AA.loopConn:Disconnect(); AA.loopConn = nil end
end

function stopAimbot()
    AA.silentAim = false; AA.wallhack = false; AA.aimLock = false; AA.triggerBot = false
    AA.hold.aimLock = false; AA.hold.triggerBot = false
    AA.stopLoop()
end

function AA.matchesKey(input, key)
    if typeof(key) ~= "EnumItem" then return false end
    if key.EnumType == Enum.KeyCode and input.UserInputType == Enum.UserInputType.Keyboard then
        return input.KeyCode == key
    elseif key.EnumType == Enum.UserInputType then
        return input.UserInputType == key
    end
    return false
end

function AA.isKeyDown(key)
    if typeof(key) ~= "EnumItem" then return false end
    if key.EnumType == Enum.KeyCode then
        return UIS:IsKeyDown(key)
    elseif key == Enum.UserInputType.MouseButton1 then
        return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    elseif key == Enum.UserInputType.MouseButton2 then
        return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    elseif key == Enum.UserInputType.MouseButton3 then
        return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton3)
    end
    return false
end

function AA.handleKey(input, began)
    if AA.settingKey then return end
    if AA.matchesKey(input, AA.aimLockKey) then
        if not AA.aimLock then return end
        if AA.aimLockMode == "toggle" and began then
            AA.hold.aimLock = not AA.hold.aimLock
            if AA.hold.aimLock then AA.startLoop() elseif not AA.active("triggerBot") then AA.stopLoop() end
        elseif AA.aimLockMode == "hold" then
            AA.hold.aimLock = began and true or false
            if AA.hold.aimLock then
                AA.startLoop()
            elseif not AA.active("triggerBot") then
                AA.stopLoop()
            end
        end
    end
    if AA.matchesKey(input, AA.triggerKey) then
        if not AA.triggerBot then return end
        if AA.triggerMode == "toggle" and began then
            AA.hold.triggerBot = not AA.hold.triggerBot
            if AA.hold.triggerBot then AA.startLoop() elseif not AA.active("aimLock") then AA.stopLoop() end
        elseif AA.triggerMode == "hold" then
            AA.hold.triggerBot = began and true or false
            if AA.hold.triggerBot then
                AA.startLoop()
            elseif not AA.active("aimLock") then
                AA.stopLoop()
            end
        end
    end
end

UIS.InputBegan:Connect(function(input)
    AA.handleKey(input, true)
end)
UIS.InputEnded:Connect(function(input)
    AA.handleKey(input, false)
end)

-- Hold-mode safety poll (fixes MouseButton2 / camera / focus edge cases)
if not AA._holdPoll then
    AA._holdPoll = RunService.RenderStepped:Connect(function()
        if AA.settingKey then return end
        if AA.aimLock and AA.aimLockMode == "hold" then
            local down = AA.isKeyDown(AA.aimLockKey)
            if AA.hold.aimLock ~= down then
                AA.hold.aimLock = down
                if down then
                    AA.startLoop()
                elseif not AA.active("triggerBot") then
                    AA.stopLoop()
                end
            end
        end
        if AA.triggerBot and AA.triggerMode == "hold" then
            local down = AA.isKeyDown(AA.triggerKey)
            if AA.hold.triggerBot ~= down then
                AA.hold.triggerBot = down
                if down then
                    AA.startLoop()
                elseif not AA.active("aimLock") then
                    AA.stopLoop()
                end
            end
        end
    end)
end

-- compat wrappers used by UI/config
function AnanistanAimSetupSilentHook() AA.setupSilent() end
function AnanistanAimStopLoop() AA.stopLoop() end
function AnanistanAimFeatureActive(f) return AA.active(f) end
function AnanistanAimSyncAliases() end

-- Keybind Değişkenleri-- Keybind Değişkenleri
local menuToggleKey = Enum.KeyCode.Insert
local espToggleKey = Enum.KeyCode.T
local settingESPKey = false
local settingMenuKey = false


-- [[ SERVER / REJOIN / SERVER HOP / SERVER FINDER / USER SNIPE ]] --
function notify(title, text)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = 4})
    end)
end

function getRequestFunction()
    return (syn and syn.request) or request or http_request
end

function requestJson(url)
    local req = getRequestFunction()
    if not req then return nil end
    local ok, response = pcall(function()
        return req({Url = url, Method = "GET"})
    end)
    if not ok or not response then return nil end
    local body = response.Body or response.body
    if not body then return nil end
    return pcall(function() return HttpService:JSONDecode(body) end) and HttpService:JSONDecode(body) or nil
end

function rejoinServer()
    pcall(function()
        TeleportService:Teleport(game.PlaceId, player)
    end)
end

function getPublicServers(placeId, cursor)
    local url = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", tostring(placeId))
    if cursor and cursor ~= "" then
        url = url .. "&cursor=" .. HttpService:UrlEncode(cursor)
    end
    return requestJson(url)
end

function serverHop(targetMaxPlayers)
    local placeId = game.PlaceId
    local cursor = ""
    local candidates = {}
    for _ = 1, 3 do
        local data = getPublicServers(placeId, cursor)
        if not data or not data.data then break end
        for _, server in ipairs(data.data) do
            if server.id ~= game.JobId and (not targetMaxPlayers or server.playing <= targetMaxPlayers) then
                table.insert(candidates, server)
            end
        end
        cursor = data.nextPageCursor
        if not cursor then break end
    end
    if #candidates == 0 then
        notify("AWD Hub", "Uygun server bulunamadı")
        return
    end
    table.sort(candidates, function(a, b)
        return (a.playing or 0) < (b.playing or 0)
    end)
    local target = candidates[1]
    pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, target.id, player)
    end)
end

function findServerByPlayerCount(count)
    count = tonumber(count)
    if not count then
        notify("AWD Hub", "Geçerli oyuncu sayısı gir")
        return
    end
    local placeId = game.PlaceId
    local cursor = ""
    local best, bestDiff
    for _ = 1, 5 do
        local data = getPublicServers(placeId, cursor)
        if not data or not data.data then break end
        for _, server in ipairs(data.data) do
            if server.id ~= game.JobId and server.playing ~= nil then
                local diff = math.abs(server.playing - count)
                if not bestDiff or diff < bestDiff then
                    best, bestDiff = server, diff
                end
            end
        end
        cursor = data.nextPageCursor
        if not cursor or bestDiff == 0 then break end
    end
    if best then
        notify("Server Bulucu", string.format("%d oyunculu server aranıyor", best.playing or 0))
        pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, best.id, player)
        end)
    else
        notify("Server Bulucu", "Server bulunamadı")
    end
end

function userSnipe(placeId, username)
    placeId = tonumber(placeId)
    if not placeId or not username or username == "" then
        notify("Kullanıcı Snipe", "PlaceId ve kullanıcı adı gerekli")
        return
    end
    task.spawn(function()
        local okId, userId = pcall(function()
            return Players:GetUserIdFromNameAsync(username)
        end)
        if not okId or not userId then
            notify("Kullanıcı Snipe", "Kullanıcı bulunamadı")
            return
        end
        local okInstance, targetPlaceId, instanceId = pcall(function()
            return TeleportService:GetPlayerPlaceInstanceAsync(userId)
        end)
        if not okInstance or not targetPlaceId or not instanceId then
            notify("Kullanıcı Snipe", "Kullanıcının serverı bulunamadı")
            return
        end
        pcall(function()
            TeleportService:TeleportToPlaceInstance(targetPlaceId, instanceId, player)
        end)
    end)
end

function getServerInfoText()
    return string.format(
        "PlaceId: %s\nOyuncular: %d/%d\nJobId: %s",
        tostring(game.PlaceId),
        #Players:GetPlayers(),
        Players.MaxPlayers,
        tostring(game.JobId)
    )
end

-- Tabs oluştur (12 Tab Alan Sınırına Uygun Ölçeklendi)
local tabMain, tD1 = CreateTab("Ana Sayfa")
local tabPlayer, tD2 = CreateTab("Oyuncu")
local tabUlasim, tD6 = CreateTab("Ulaşım")
local tabStudio, tDStudio = CreateTab("Studio")
local tabGames, tDGames = CreateTab("Oyunlar")
local tabSpider, tD5 = CreateTab("Grapple")
local tabVisuals, tD3 = CreateTab("Görseller")
local tabAimbot, tDAimbot = CreateTab("Aimbot")
local tabSettings, tD4 = CreateTab("Ayarlar")
local tabDesigner, tD8 = CreateTab("Dizayn")
local tabSlots, tD9 = tabDesigner, tD8 -- Slotlar tema kaydı Dizayn altında
_G.ananistwaffendivisionTabPlayers, _G.ananistwaffendivisionTabPlayersData = CreateTab("Oyuncular")
local tabScripts, tDScripts = CreateTab("Scriptler")
_G.ananistwaffendivisionTabPlayersData.Btn.TextSize = 12
-- Sidebar sırası: yeni sayfalar sonradan üretilse de doğru yerde kalır.
tD1.Btn.LayoutOrder, tD2.Btn.LayoutOrder, tD6.Btn.LayoutOrder = 1, 2, 3
tDStudio.Btn.LayoutOrder, tDGames.Btn.LayoutOrder, tD5.Btn.LayoutOrder = 4, 5, 6
tD3.Btn.LayoutOrder, tDAimbot.Btn.LayoutOrder, tD4.Btn.LayoutOrder = 7, 8, 9
tD8.Btn.LayoutOrder, _G.ananistwaffendivisionTabPlayersData.Btn.LayoutOrder, tDScripts.Btn.LayoutOrder = 10, 11, 12
local espKeyBtn, espKeyLabel
local menuKeyBtn, menuKeyLabel

-- İlk açılışta Ana Sayfa seçili gelsin.
task.defer(function() if tabs[1] and tabs[1].Select then tabs[1].Select() end end)



-- [[ ANANISTAN BODYCAM / OYUNCULAR SİSTEMİ ]] --
_G.ananistwaffendivisionBodycamState = _G.ananistwaffendivisionBodycamState or {
    recordings = {},
    recording = false,
    recordingFrames = nil,
    recordingStarted = 0,
    recordingConn = nil,
    playbackConn = nil,
    selectedUserId = nil,
    playerListFrame = nil,
    bodycamListFrame = nil,
    statusLabel = nil,
    selectedPlayerLabel = nil,
}

_G.ananistwaffendivisionBodycamState.selectedUserId = _G.ananistwaffendivisionBodycamState.selectedUserId or player.UserId

-- [[ ANANISTAN BODYCAM HUD / GERÇEK BODYCAM STİLİ ]]
_G.ananistwaffendivisionBodycamCreateHUD = _G.ananistwaffendivisionBodycamCreateHUD or function()
    local st = _G.ananistwaffendivisionBodycamState
    if st.hud and st.hud.Parent then return st.hud end
    local hud = Instance.new("ScreenGui")
    hud.Name = "ANANISTAN_BodycamHUD"
    hud.IgnoreGuiInset = true
    hud.ResetOnSpawn = false
    hud.DisplayOrder = 999999
    hud.Enabled = false
    hud.Parent = CoreGui

    local top = Instance.new("Frame")
    top.Size = UDim2.new(1,0,0,42)
    top.BackgroundTransparency = 1
    top.Parent = hud

    local brand = Instance.new("TextLabel")
    brand.Size = UDim2.new(0,190,0,34)
    brand.Position = UDim2.new(0,18,0,10)
    brand.BackgroundTransparency = 1
    brand.Text = "ANANISTAN  BODYCAM"
    brand.TextColor3 = Color3.fromRGB(235,235,235)
    brand.TextStrokeTransparency = 0.35
    brand.Font = Enum.Font.GothamBold
    brand.TextSize = 17
    brand.TextXAlignment = Enum.TextXAlignment.Left
    brand.Parent = top

    local rec = Instance.new("TextLabel")
    rec.Size = UDim2.new(0,170,0,30)
    rec.Position = UDim2.new(0.5,-85,0,10)
    rec.BackgroundTransparency = 1
    rec.Text = "●  REC 00:00:00"
    rec.TextColor3 = Color3.fromRGB(255,70,70)
    rec.TextStrokeTransparency = 0.25
    rec.Font = Enum.Font.GothamBold
    rec.TextSize = 16
    rec.Parent = top

    local cam = Instance.new("TextLabel")
    cam.Size = UDim2.new(0,210,0,30)
    cam.Position = UDim2.new(1,-228,0,10)
    cam.BackgroundTransparency = 1
    cam.Text = "CAM 01  •  LIVE"
    cam.TextColor3 = Color3.fromRGB(220,220,220)
    cam.TextStrokeTransparency = 0.3
    cam.Font = Enum.Font.GothamBold
    cam.TextSize = 13
    cam.TextXAlignment = Enum.TextXAlignment.Right
    cam.Parent = top

    local bottom = Instance.new("Frame")
    bottom.Size = UDim2.new(1,0,0,72)
    bottom.Position = UDim2.new(0,0,1,-72)
    bottom.BackgroundTransparency = 1
    bottom.Parent = hud

    local leftInfo = Instance.new("TextLabel")
    leftInfo.Size = UDim2.new(0,340,0,55)
    leftInfo.Position = UDim2.new(0,18,0,4)
    leftInfo.BackgroundTransparency = 1
    leftInfo.Text = "MIC  ON  •  AUDIO  ON\nSTATUS  RECORDING"
    leftInfo.TextColor3 = Color3.fromRGB(220,220,220)
    leftInfo.TextStrokeTransparency = 0.35
    leftInfo.Font = Enum.Font.Code
    leftInfo.TextSize = 12
    leftInfo.TextXAlignment = Enum.TextXAlignment.Left
    leftInfo.TextYAlignment = Enum.TextYAlignment.Top
    leftInfo.Parent = bottom

    local rightInfo = Instance.new("TextLabel")
    rightInfo.Size = UDim2.new(0,360,0,55)
    rightInfo.Position = UDim2.new(1,-378,0,4)
    rightInfo.BackgroundTransparency = 1
    rightInfo.Text = "ANANISTAN UNIT\n00.000000, 00.000000"
    rightInfo.TextColor3 = Color3.fromRGB(220,220,220)
    rightInfo.TextStrokeTransparency = 0.35
    rightInfo.Font = Enum.Font.Code
    rightInfo.TextSize = 12
    rightInfo.TextXAlignment = Enum.TextXAlignment.Right
    rightInfo.TextYAlignment = Enum.TextYAlignment.Top
    rightInfo.Parent = bottom

    local frameTag = Instance.new("TextLabel")
    frameTag.Size = UDim2.new(0,230,0,24)
    frameTag.Position = UDim2.new(0.5,-115,1,-30)
    frameTag.BackgroundTransparency = 1
    frameTag.Text = "BODYCAM • 1080P • ANANISTAN"
    frameTag.TextColor3 = Color3.fromRGB(180,180,180)
    frameTag.TextStrokeTransparency = 0.45
    frameTag.Font = Enum.Font.GothamMedium
    frameTag.TextSize = 10
    frameTag.Parent = bottom

    st.hud = hud
    st.hudRec = rec
    st.hudCam = cam
    st.hudLeft = leftInfo
    st.hudRight = rightInfo
    st.hudFrameTag = frameTag
    return hud
end

_G.ananistwaffendivisionBodycamSetHUD = _G.ananistwaffendivisionBodycamSetHUD or function(enabled, mode, elapsed)
    local hud = _G.ananistwaffendivisionBodycamCreateHUD()
    local st = _G.ananistwaffendivisionBodycamState
    hud.Enabled = enabled == true
    if not hud.Enabled then return end
    elapsed = tonumber(elapsed) or 0
    local total = math.max(0, math.floor(elapsed))
    local h = math.floor(total/3600)
    local m = math.floor((total%3600)/60)
    local sec = total%60
    local stamp = string.format("%02d:%02d:%02d", h,m,sec)
    if st.hudRec then
        st.hudRec.Text = (mode == "PLAYBACK" and "●  PLAY  " or "●  REC  ") .. stamp
        st.hudRec.TextColor3 = mode == "PLAYBACK" and Color3.fromRGB(255,195,70) or Color3.fromRGB(255,70,70)
    end
    if st.hudCam then st.hudCam.Text = mode == "PLAYBACK" and "CAM 01  •  PLAYBACK" or "CAM 01  •  LIVE" end
    if st.hudLeft then st.hudLeft.Text = mode == "PLAYBACK" and "MIC  --  •  AUDIO  --\nSTATUS  PLAYBACK" or "MIC  ON  •  AUDIO  ON\nSTATUS  RECORDING" end
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local pos = root and root.Position or Vector3.zero
    if st.hudRight then
        st.hudRight.Text = string.format("ANANISTAN UNIT\n%+.3f, %+.3f, %+.3f", pos.X, pos.Y, pos.Z)
    end
end

_G.ananistwaffendivisionBodycamSetHUD(false)

-- [[ BODYCAM DOSYA KAYDI / KALICI DEPOLAMA ]]
_G.ananistwaffendivisionBodycamFileName = _G.ananistwaffendivisionBodycamFileName or "ananistwaffendivision_Bodycams.json"

_G.ananistwaffendivisionBodycamSerializeCFrame = function(cf)
    local a,b,c,d,e,f,g,h,i,j,k,l = cf:GetComponents()
    return {a,b,c,d,e,f,g,h,i,j,k,l}
end

_G.ananistwaffendivisionBodycamDeserializeCFrame = function(data)
    if type(data) ~= "table" or #data < 12 then return nil end
    local ok, cf = pcall(function()
        return CFrame.new(table.unpack(data, 1, 12))
    end)
    return ok and cf or nil
end

_G.ananistwaffendivisionBodycamHasFileIO = function()
    return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
end

_G.ananistwaffendivisionBodycamSaveToFile = function()
    local st = _G.ananistwaffendivisionBodycamState
    if not _G.ananistwaffendivisionBodycamHasFileIO() then
        st.fileStatus = "File API yok - sadece oturum belleği"
        return false
    end

    local payload = {version = 1, games = {}}
    local okDecode = pcall(function()
        if isfile(_G.ananistwaffendivisionBodycamFileName) then
            local raw = readfile(_G.ananistwaffendivisionBodycamFileName)
            if raw and raw ~= "" then
                local decoded = HttpService:JSONDecode(raw)
                if type(decoded) == "table" then payload = decoded end
            end
        end
    end)
    if not okDecode or type(payload.games) ~= "table" then payload = {version = 1, games = {}} end

    local placeKey = tostring(game.PlaceId)
    payload.games[placeKey] = payload.games[placeKey] or {}
    local encodedRecords = {}
    for userId, records in pairs(st.recordings or {}) do
        local encoded = {}
        for _, rec in ipairs(records or {}) do
            local frames = {}
            for _, frame in ipairs(rec.frames or {}) do
                local cfData = _G.ananistwaffendivisionBodycamSerializeCFrame(frame.cf)
                if cfData then
                    frames[#frames + 1] = {t = frame.t, cf = cfData, fov = frame.fov}
                end
            end
            encoded[#encoded + 1] = {
                duration = rec.duration or (frames[#frames] and frames[#frames].t) or 0,
                created = rec.created or os.time(),
                frames = frames
            }
        end
        payload.games[placeKey][tostring(userId)] = encoded
    end

    local encodedText
    local okEncode = pcall(function()
        encodedText = HttpService:JSONEncode(payload)
    end)
    if not okEncode or not encodedText then
        st.fileStatus = "Bodycam JSON oluşturulamadı"
        return false
    end

    local okWrite = pcall(function() writefile(_G.ananistwaffendivisionBodycamFileName, encodedText) end)
    if okWrite then
        st.fileStatus = "Kayıtlar dosyaya kaydedildi"
        return true
    end
    st.fileStatus = "Dosyaya yazılamadı"
    return false
end

_G.ananistwaffendivisionBodycamLoadFromFile = function()
    local st = _G.ananistwaffendivisionBodycamState
    if not _G.ananistwaffendivisionBodycamHasFileIO() then
        st.fileStatus = "File API yok - sadece oturum belleği"
        return false
    end
    if not isfile(_G.ananistwaffendivisionBodycamFileName) then
        st.fileStatus = "Bodycam dosyası henüz yok"
        return false
    end

    local raw
    local okRead = pcall(function() raw = readfile(_G.ananistwaffendivisionBodycamFileName) end)
    if not okRead or not raw or raw == "" then
        st.fileStatus = "Bodycam dosyası okunamadı"
        return false
    end

    local payload
    local okDecode = pcall(function() payload = HttpService:JSONDecode(raw) end)
    if not okDecode or type(payload) ~= "table" or type(payload.games) ~= "table" then
        st.fileStatus = "Bodycam dosyası bozuk"
        return false
    end

    local gameData = payload.games[tostring(game.PlaceId)] or {}
    st.recordings = {}
    for userId, records in pairs(gameData) do
        local userRecords = {}
        for _, rec in ipairs(records or {}) do
            local frames = {}
            for _, frame in ipairs(rec.frames or {}) do
                local cf = _G.ananistwaffendivisionBodycamDeserializeCFrame(frame.cf)
                if cf then
                    frames[#frames + 1] = {t = tonumber(frame.t) or 0, cf = cf, fov = tonumber(frame.fov) or 70}
                end
            end
            if #frames >= 2 then
                userRecords[#userRecords + 1] = {
                    duration = tonumber(rec.duration) or frames[#frames].t,
                    created = tonumber(rec.created) or 0,
                    frames = frames
                }
            end
        end
        while #userRecords > 25 do table.remove(userRecords, 1) end
        st.recordings[tonumber(userId) or userId] = userRecords
    end
    st.fileStatus = "Bodycam kayıtları dosyadan yüklendi"
    return true
end

_G.ananistwaffendivisionBodycamStopPlayback = function()
    local st = _G.ananistwaffendivisionBodycamState
    if st.playbackConn then
        pcall(function() st.playbackConn:Disconnect() end)
        st.playbackConn = nil
    end
    st.playback = false
    _G.ananistwaffendivisionBodycamSetHUD(false)
    local cam = workspace.CurrentCamera
    if cam then
        pcall(function()
            cam.CameraType = Enum.CameraType.Custom
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then cam.CameraSubject = hum end
        end)
    end
end

pcall(function() _G.ananistwaffendivisionBodycamLoadFromFile() end)

_G.ananistwaffendivisionBodycamRefreshList = function()
    local st = _G.ananistwaffendivisionBodycamState
    local frame = st.bodycamListFrame
    if not frame then return end
    for _, child in ipairs(frame:GetChildren()) do
        if not child:IsA("UIListLayout") then child:Destroy() end
    end

    local userId = st.selectedUserId or player.UserId
    local records = st.recordings[userId] or {}
    for index, rec in ipairs(records) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -6, 0, 44)
        row.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        row.BorderSizePixel = 0
        row.Parent = frame
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -150, 1, 0)
        title.Position = UDim2.new(0, 10, 0, 0)
        title.BackgroundTransparency = 1
        title.Text = string.format("Bodycam %02d  |  %.1fs", index, rec.duration or 0)
        title.TextColor3 = Color3.fromRGB(220, 220, 240)
        title.Font = Enum.Font.GothamMedium
        title.TextSize = 12
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = row

        local play = Instance.new("TextButton")
        play.Size = UDim2.new(0, 62, 0, 28)
        play.Position = UDim2.new(1, -135, 0.5, -14)
        play.BackgroundColor3 = Color3.fromRGB(50, 110, 65)
        play.Text = "Oynat"
        play.TextColor3 = Color3.fromRGB(255,255,255)
        play.Font = Enum.Font.GothamBold
        play.TextSize = 11
        play.Parent = row
        Instance.new("UICorner", play).CornerRadius = UDim.new(0, 6)
        play.MouseButton1Click:Connect(function()
            if not rec.frames or #rec.frames < 2 then return end
            _G.ananistwaffendivisionBodycamStopPlayback()
            local cam = workspace.CurrentCamera
            if not cam then return end
            st.playback = true
            _G.ananistwaffendivisionBodycamSetHUD(true, "PLAYBACK", 0)
            local oldType = cam.CameraType
            local oldSubject = cam.CameraSubject
            local oldFov = cam.FieldOfView
            cam.CameraType = Enum.CameraType.Scriptable
            local started = os.clock()
            local frames = rec.frames
            st.playbackConn = RunService.RenderStepped:Connect(function()
                if not st.playback then return end
                local elapsed = os.clock() - started
                _G.ananistwaffendivisionBodycamSetHUD(true, "PLAYBACK", elapsed)
                if elapsed >= (rec.duration or 0) then
                    st.playback = false
                    _G.ananistwaffendivisionBodycamSetHUD(false)
                    if st.playbackConn then st.playbackConn:Disconnect(); st.playbackConn = nil end
                    pcall(function()
                        cam.CameraType = oldType
                        cam.CameraSubject = oldSubject
                        cam.FieldOfView = oldFov
                    end)
                    return
                end
                local a, b = frames[1], frames[#frames]
                for i = 1, #frames - 1 do
                    if elapsed >= frames[i].t and elapsed <= frames[i+1].t then
                        a, b = frames[i], frames[i+1]
                        break
                    end
                end
                local span = math.max(0.0001, (b.t - a.t))
                local alpha = math.clamp((elapsed - a.t) / span, 0, 1)
                cam.CFrame = a.cf:Lerp(b.cf, alpha)
                cam.FieldOfView = a.fov + (b.fov - a.fov) * alpha
            end)
        end)

        local del = Instance.new("TextButton")
        del.Size = UDim2.new(0, 62, 0, 28)
        del.Position = UDim2.new(1, -68, 0.5, -14)
        del.BackgroundColor3 = Color3.fromRGB(120, 45, 45)
        del.Text = "Sil"
        del.TextColor3 = Color3.fromRGB(255,255,255)
        del.Font = Enum.Font.GothamBold
        del.TextSize = 11
        del.Parent = row
        Instance.new("UICorner", del).CornerRadius = UDim.new(0, 6)
        del.MouseButton1Click:Connect(function()
            table.remove(records, index)
            pcall(function() _G.ananistwaffendivisionBodycamSaveToFile() end)
            _G.ananistwaffendivisionBodycamRefreshList()
        end)
    end

    if #records == 0 then
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1, -10, 0, 40)
        empty.BackgroundTransparency = 1
        empty.Text = "Bu oyuncuya ait kayıt bulunamadı"
        empty.TextColor3 = Color3.fromRGB(150, 150, 170)
        empty.Font = Enum.Font.GothamMedium
        empty.TextSize = 12
        empty.Parent = frame
    end
    pcall(function()
        local layout = frame:FindFirstChildOfClass("UIListLayout")
        if layout then frame.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10) end
    end)
end

_G.ananistwaffendivisionBodycamSelectUser = function(userId, displayName)
    local st = _G.ananistwaffendivisionBodycamState
    st.selectedUserId = userId or player.UserId
    if st.selectedPlayerLabel then
        st.selectedPlayerLabel.Text = "Seçili Bodycam: " .. (displayName or player.DisplayName or player.Name)
    end
    _G.ananistwaffendivisionBodycamRefreshList()
    if _G.ananistwaffendivisionTabBodycamsData then
        for _, item in pairs(tabs) do
            item.Frame.Visible = false
            item.Indicator.Visible = false
        end
        _G.ananistwaffendivisionTabBodycamsData.Frame.Visible = true
        _G.ananistwaffendivisionTabBodycamsData.Indicator.Visible = true
        applyTheme(currentTheme)
    end
end

_G.ananistwaffendivisionBodycamStart = function()
    local st = _G.ananistwaffendivisionBodycamState
    if st.recording then return end
    _G.ananistwaffendivisionBodycamStopPlayback()
    st.recording = true
    st.recordingFrames = {}
    st.recordingStarted = os.clock()
    _G.ananistwaffendivisionBodycamSetHUD(true, "REC", 0)
    local userId = player.UserId
    st.statusLabel = st.statusLabel or nil
    if st.recordingConn then pcall(function() st.recordingConn:Disconnect() end) end
    local nextSample = 0
    st.recordingConn = RunService.RenderStepped:Connect(function()
        if not st.recording then return end
        local now = os.clock() - st.recordingStarted
        _G.ananistwaffendivisionBodycamSetHUD(true, "REC", now)
        if now < nextSample then return end
        nextSample = now + (1/12)
        if now >= 3600 then
            _G.ananistwaffendivisionBodycamStop()
            return
        end
        local char = player.Character
        local head = char and char:FindFirstChild("Head")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local cam = workspace.CurrentCamera
        if not cam or not (head or root) then return end
        local origin = (head or root).Position + Vector3.new(0, 0.02, 0)
        local look = cam.CFrame.LookVector
        local up = cam.CFrame.UpVector
        local pos = origin
        local cf = CFrame.lookAt(pos, pos + look, up)
        table.insert(st.recordingFrames, {t = now, cf = cf, fov = cam.FieldOfView})
    end)
    if st.statusLabel then st.statusLabel.Text = "REC  ●  Kayıt sürüyor (maks 1 saat)" end
end

_G.ananistwaffendivisionBodycamStop = function()
    local st = _G.ananistwaffendivisionBodycamState
    if not st.recording then return end
    st.recording = false
    _G.ananistwaffendivisionBodycamSetHUD(false)
    if st.recordingConn then
        pcall(function() st.recordingConn:Disconnect() end)
        st.recordingConn = nil
    end
    local frames = st.recordingFrames or {}
    st.recordingFrames = nil
    if #frames < 2 then
        if st.statusLabel then st.statusLabel.Text = "Kayıt çok kısa" end
        return
    end
    local records = st.recordings[player.UserId] or {}
    st.recordings[player.UserId] = records
    table.insert(records, {duration = frames[#frames].t, frames = frames, created = os.time()})
    while #records > 25 do table.remove(records, 1) end
    pcall(function() _G.ananistwaffendivisionBodycamSaveToFile() end)
    st.selectedUserId = player.UserId
    if st.selectedPlayerLabel then st.selectedPlayerLabel.Text = "Seçili Bodycam: " .. player.DisplayName end
    if st.statusLabel then st.statusLabel.Text = string.format("Kayıt kaydedildi  |  %d/25", #records) end
    _G.ananistwaffendivisionBodycamRefreshList()
end

_G.ananistwaffendivisionBodycamClearAll = function()
    local st = _G.ananistwaffendivisionBodycamState
    st.recordings[player.UserId] = {}
    pcall(function() _G.ananistwaffendivisionBodycamSaveToFile() end)
    st.selectedUserId = player.UserId
    if st.statusLabel then st.statusLabel.Text = "Tüm Bodycam kayıtları silindi" end
    _G.ananistwaffendivisionBodycamRefreshList()
end

-- Oyuncular tabı
-- [[ ANANIST WAFFEN DIVISION - ADVANCED PLAYERS TAB ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

_G.ananistwaffendivisionOrbitDistance = _G.ananistwaffendivisionOrbitDistance or 12
_G.ananistwaffendivisionOrbitSpeed = _G.ananistwaffendivisionOrbitSpeed or 1
_G.ananistwaffendivisionOrbitTarget = nil
_G.ananistwaffendivisionOrbitConnection = nil
_G.ananistwaffendivisionOrbitAngle = 0

-- Eski orbit bağlantısını temizle
if _G.ananistwaffendivisionOrbitConnection then
    _G.ananistwaffendivisionOrbitConnection:Disconnect()
    _G.ananistwaffendivisionOrbitConnection = nil
end

-- Ana başlık
_G.ananistwaffendivisionTabPlayersTitle =
    AddLabel(_G.ananistwaffendivisionTabPlayers, "Oyuncular")

_G.ananistwaffendivisionTabPlayersHint =
    AddLabel(
        _G.ananistwaffendivisionTabPlayers,
        "Oyuncuları görüntüle ve karakter kontrollerini yönet",
        true
    )

-- Yenile butonu EN ÜSTTE
_G.ananistwaffendivisionTabPlayersRefresh = AddButton(
    _G.ananistwaffendivisionTabPlayers,
    "Listeyi Yenile",
    function()
        if _G.ananistwaffendivisionRefreshPlayersTab then
            _G.ananistwaffendivisionRefreshPlayersTab()
        end
    end
)

-- Orbit ayar paneli
local orbitPanel = Instance.new("Frame")
orbitPanel.Name = "OrbitSettings"
orbitPanel.Size = UDim2.new(1, -10, 0, 105)
orbitPanel.BackgroundColor3 = Color3.fromRGB(27, 29, 40)
orbitPanel.BorderSizePixel = 0
orbitPanel.Visible = false
orbitPanel.Parent = _G.ananistwaffendivisionTabPlayers
Instance.new("UICorner", orbitPanel).CornerRadius = UDim.new(0, 8)

local orbitTitle = Instance.new("TextLabel")
orbitTitle.Size = UDim2.new(1, -16, 0, 22)
orbitTitle.Position = UDim2.new(0, 8, 0, 4)
orbitTitle.BackgroundTransparency = 1
orbitTitle.Text = "ORBIT SETTINGS"
orbitTitle.TextColor3 = Color3.fromRGB(210, 215, 240)
orbitTitle.Font = Enum.Font.GothamBold
orbitTitle.TextSize = 12
orbitTitle.TextXAlignment = Enum.TextXAlignment.Left
orbitTitle.Parent = orbitPanel

function createSlider(name, y, minValue, maxValue, defaultValue, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -16, 0, 32)
    holder.Position = UDim2.new(0, 8, 0, y)
    holder.BackgroundTransparency = 1
    holder.Parent = orbitPanel

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.42, 0, 0, 17)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 235)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = holder

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.22, 0, 0, 17)
    valueLabel.Position = UDim2.new(0.78, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Color3.fromRGB(120, 190, 255)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 11
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = holder

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 5)
    track.Position = UDim2.new(0, 0, 0, 23)
    track.BackgroundColor3 = Color3.fromRGB(55, 58, 75)
    track.BorderSizePixel = 0
    track.Parent = holder
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(
        (defaultValue - minValue) / (maxValue - minValue), 0, 1, 0
    )
    fill.BackgroundColor3 = Color3.fromRGB(80, 145, 235)
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 13, 0, 13)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(240, 245, 255)
    knob.BorderSizePixel = 0
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local hitbox = Instance.new("TextButton")
    hitbox.Size = UDim2.new(1, 0, 1, 0)
    hitbox.BackgroundTransparency = 1
    hitbox.Text = ""
    hitbox.Parent = track

    local dragging = false
    local currentValue = defaultValue

    local function update(inputX)
        local width = track.AbsoluteSize.X
        if width <= 0 then return end

        local alpha = math.clamp(
            (inputX - track.AbsolutePosition.X) / width, 0, 1
        )

        currentValue = minValue + alpha * (maxValue - minValue)
        currentValue = math.floor(currentValue * 10 + 0.5) / 10

        local normalized = (currentValue - minValue) / (maxValue - minValue)
        fill.Size = UDim2.new(normalized, 0, 1, 0)
        knob.Position = UDim2.new(normalized, 0, 0.5, 0)
        valueLabel.Text = tostring(currentValue)
        callback(currentValue)
    end

    valueLabel.Text = tostring(defaultValue)

    hitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input.Position.X)
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            update(input.Position.X)
        end
    end)

    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

createSlider("Mesafe", 29, 4, 40, _G.ananistwaffendivisionOrbitDistance, function(value)
    _G.ananistwaffendivisionOrbitDistance = value
end)

createSlider("Hız", 65, 0.2, 5, _G.ananistwaffendivisionOrbitSpeed, function(value)
    _G.ananistwaffendivisionOrbitSpeed = value
end)

-- Oyuncu listesi
_G.ananistwaffendivisionBodycamPlayersScroll =
    Instance.new("ScrollingFrame")

local scroll = _G.ananistwaffendivisionBodycamPlayersScroll
scroll.Name = "PlayersList"
scroll.Size = UDim2.new(1, -10, 0, 260)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 5
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = _G.ananistwaffendivisionTabPlayers

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scroll

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 8)
end)

function stopOrbit()
    if _G.ananistwaffendivisionOrbitConnection then
        _G.ananistwaffendivisionOrbitConnection:Disconnect()
        _G.ananistwaffendivisionOrbitConnection = nil
    end

    _G.ananistwaffendivisionOrbitTarget = nil
    orbitPanel.Visible = false
end

function startOrbit(target)
    stopOrbit()

    if target == Players.LocalPlayer then
        return
    end

    _G.ananistwaffendivisionOrbitTarget = target
    _G.ananistwaffendivisionOrbitAngle = 0
    orbitPanel.Visible = true

    _G.ananistwaffendivisionOrbitConnection = RunService.RenderStepped:Connect(function(dt)
        if not target.Parent then
            stopOrbit()
            return
        end

        local character = Players.LocalPlayer.Character
        local targetCharacter = target.Character

        local root = character and character:FindFirstChild("HumanoidRootPart")
        local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if not root or not targetRoot or not humanoid or humanoid.Health <= 0 then
            return
        end

        _G.ananistwaffendivisionOrbitAngle +=
            dt * _G.ananistwaffendivisionOrbitSpeed

        local distance = _G.ananistwaffendivisionOrbitDistance
        local angle = _G.ananistwaffendivisionOrbitAngle

        local offset = Vector3.new(
            math.cos(angle) * distance,
            3,
            math.sin(angle) * distance
        )

        -- Yalnızca kendi karakterini hareket ettirir.
        root.CFrame = CFrame.lookAt(
            targetRoot.Position + offset,
            targetRoot.Position
        )
    end)
end

_G.ananistwaffendivisionRefreshPlayersTab = function()
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("Frame") and child.Name == "PlayerRow" then
            child:Destroy()
        end
    end

    for _, target in ipairs(Players:GetPlayers()) do
        local row = Instance.new("Frame")
        row.Name = "PlayerRow"
        row.Size = UDim2.new(1, -8, 0, 72)
        row.BackgroundColor3 = Color3.fromRGB(32, 35, 48)
        row.BorderSizePixel = 0
        row.LayoutOrder = target.UserId
        row.Parent = scroll

        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 9)

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(57, 63, 82)
        stroke.Thickness = 1
        stroke.Parent = row

        local avatar = Instance.new("ImageLabel")
        avatar.Size = UDim2.new(0, 48, 0, 48)
        avatar.Position = UDim2.new(0, 9, 0.5, -24)
        avatar.BackgroundColor3 = Color3.fromRGB(45, 48, 62)
        avatar.BorderSizePixel = 0
        avatar.Parent = row
        Instance.new("UICorner", avatar).CornerRadius = UDim.new(0, 8)

        task.spawn(function()
            local ok, image = pcall(function()
                return Players:GetUserThumbnailAsync(
                    target.UserId,
                    Enum.ThumbnailType.HeadShot,
                    Enum.ThumbnailSize.Size100x100
                )
            end)

            if ok and avatar.Parent then
                avatar.Image = image
            end
        end)

        local name = Instance.new("TextLabel")
        name.Size = UDim2.new(1, -220, 0, 24)
        name.Position = UDim2.new(0, 65, 0, 9)
        name.BackgroundTransparency = 1
        name.Text = target.DisplayName
        name.TextColor3 = Color3.fromRGB(235, 238, 250)
        name.Font = Enum.Font.GothamBold
        name.TextSize = 12
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.TextTruncate = Enum.TextTruncate.AtEnd
        name.Parent = row

        local username = Instance.new("TextLabel")
        username.Size = UDim2.new(1, -220, 0, 20)
        username.Position = UDim2.new(0, 65, 0, 33)
        username.BackgroundTransparency = 1
        username.Text = "@" .. target.Name
        username.TextColor3 = Color3.fromRGB(145, 153, 175)
        username.Font = Enum.Font.Gotham
        username.TextSize = 10
        username.TextXAlignment = Enum.TextXAlignment.Left
        username.TextTruncate = Enum.TextTruncate.AtEnd
        username.Parent = row

        local function makeButton(text, width, xOffset, color, callback)
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(0, width, 0, 27)
            button.Position = UDim2.new(1, xOffset, 0.5, -13)
            button.BackgroundColor3 = color
            button.BorderSizePixel = 0
            button.Text = text
            button.TextColor3 = Color3.new(1, 1, 1)
            button.Font = Enum.Font.GothamBold
            button.TextSize = 10
            button.Parent = row

            Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)

            button.MouseButton1Click:Connect(callback)
            return button
        end

        makeButton("Teleport", 57, -188, Color3.fromRGB(49, 115, 76), function()
            if target == Players.LocalPlayer then return end

            local root = Players.LocalPlayer.Character
                and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local targetRoot = target.Character
                and target.Character:FindFirstChild("HumanoidRootPart")

            if root and targetRoot then
                root.CFrame = targetRoot.CFrame * CFrame.new(0, 3, 0)
            end
        end)

        makeButton("View", 48, -126, Color3.fromRGB(65, 83, 130), function()
            local camera = workspace.CurrentCamera
            local humanoid = target.Character
                and target.Character:FindFirstChildOfClass("Humanoid")

            if camera and humanoid then
                camera.CameraSubject = humanoid
            end
        end)

        local orbitButton
        orbitButton = makeButton("Orbital cannon ON", 68, -73, Color3.fromRGB(90, 80, 145), function()
            if _G.ananistwaffendivisionOrbitTarget == target then
                stopOrbit()
                orbitButton.Text = "Orbital cannon ON"
                orbitButton.BackgroundColor3 = Color3.fromRGB(90, 80, 145)
            else
                for _, otherRow in ipairs(scroll:GetChildren()) do
                    if otherRow:IsA("Frame") then
                        for _, button in ipairs(otherRow:GetChildren()) do
                            if button:IsA("TextButton") and button.Text == "Orbital cannon OFF" then
                                button.Text = "Orbital cannon ON"
                                button.BackgroundColor3 = Color3.fromRGB(90, 80, 145)
                            end
                        end
                    end
                end

                startOrbit(target)
                orbitButton.Text = "Orbital Cannon OFF"
                orbitButton.BackgroundColor3 = Color3.fromRGB(45, 145, 95)
            end
        end)

        if target == Players.LocalPlayer then
            orbitButton.Text = "sen abi sen babapro"
            orbitButton.BackgroundColor3 = Color3.fromRGB(65, 68, 80)
            orbitButton.Active = false
        end
    end
end

Players.PlayerAdded:Connect(function()
    task.defer(_G.ananistwaffendivisionRefreshPlayersTab)
end)

Players.PlayerRemoving:Connect(function(leavingPlayer)
    if _G.ananistwaffendivisionOrbitTarget == leavingPlayer then
        stopOrbit()
    end

    task.defer(_G.ananistwaffendivisionRefreshPlayersTab)
end)

_G.ananistwaffendivisionRefreshPlayersTab()

-- Bodycam tabı kaldırıldı
if false then
_G.ananistwaffendivisionTabBodycamsTitle = AddLabel(_G.ananistwaffendivisionTabBodycams, "ANANISTAN Bodycam")
_G.ananistwaffendivisionBodycamState.selectedPlayerLabel = AddLabel(_G.ananistwaffendivisionTabBodycams, "Seçili Bodycam: " .. player.DisplayName)
_G.ananistwaffendivisionBodycamState.statusLabel = AddLabel(_G.ananistwaffendivisionTabBodycams, "Hazır | Maksimum 25 kayıt | " .. tostring(_G.ananistwaffendivisionBodycamState.fileStatus or "Dosya belleği hazır"))
AddButton(_G.ananistwaffendivisionTabBodycams, "● Kayda Başla", function()
    _G.ananistwaffendivisionBodycamStart()
end)
AddButton(_G.ananistwaffendivisionTabBodycams, "■ Kaydı Durdur & Kaydet", function()
    _G.ananistwaffendivisionBodycamStop()
end)
AddButton(_G.ananistwaffendivisionTabBodycams, "Tüm Kayıtları Sil", function()
    _G.ananistwaffendivisionBodycamClearAll()
end)
AddButton(_G.ananistwaffendivisionTabBodycams, "Kayıtları Dosyaya Kaydet", function()
    local ok = _G.ananistwaffendivisionBodycamSaveToFile()
    if _G.ananistwaffendivisionBodycamState.statusLabel then
        _G.ananistwaffendivisionBodycamState.statusLabel.Text = ok and "Bodycam kayıtları dosyaya kaydedildi" or ("Kaydetme başarısız: " .. tostring(_G.ananistwaffendivisionBodycamState.fileStatus or "bilinmeyen hata"))
    end
end)
AddButton(_G.ananistwaffendivisionTabBodycams, "Dosyadan Kayıtları Yenile", function()
    local ok = _G.ananistwaffendivisionBodycamLoadFromFile()
    if _G.ananistwaffendivisionBodycamState.statusLabel then
        _G.ananistwaffendivisionBodycamState.statusLabel.Text = ok and "Bodycam kayıtları dosyadan yüklendi" or ("Yükleme başarısız: " .. tostring(_G.ananistwaffendivisionBodycamState.fileStatus or "dosya yok"))
    end
    _G.ananistwaffendivisionBodycamRefreshList()
end)
_G.ananistwaffendivisionTabBodycamsHint = AddLabel(_G.ananistwaffendivisionTabBodycams, "Kayıtlar ilk şahıs olarak oynatılır. Üçüncü şahısta kayıt başlatsan bile playback kafanın konumundan ve kaydedilmiş bakış yönünden gider.", true)

_G.ananistwaffendivisionBodycamListScroll = Instance.new("ScrollingFrame", _G.ananistwaffendivisionTabBodycams)
_G.ananistwaffendivisionBodycamListScroll.Size = UDim2.new(1, -10, 0, 250)
_G.ananistwaffendivisionBodycamListScroll.BackgroundTransparency = 1
_G.ananistwaffendivisionBodycamListScroll.ScrollBarThickness = 5
_G.ananistwaffendivisionBodycamListScroll.CanvasSize = UDim2.new(0,0,0,0)
_G.ananistwaffendivisionBodycamListScroll.Parent = _G.ananistwaffendivisionTabBodycams
_G.ananistwaffendivisionBodycamState.bodycamListFrame = _G.ananistwaffendivisionBodycamListScroll
_G.ananistwaffendivisionBodycamListLayout = Instance.new("UIListLayout", _G.ananistwaffendivisionBodycamListScroll)
_G.ananistwaffendivisionBodycamListLayout.Padding = UDim.new(0, 6)
_G.ananistwaffendivisionBodycamListLayout.SortOrder = Enum.SortOrder.LayoutOrder
_G.ananistwaffendivisionBodycamListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    _G.ananistwaffendivisionBodycamListScroll.CanvasSize = UDim2.new(0,0,0,_G.ananistwaffendivisionBodycamListLayout.AbsoluteContentSize.Y + 10)
end)
_G.ananistwaffendivisionBodycamRefreshList()
end
_G.ananistwaffendivisionRefreshPlayersTab()

-- Ana Sayfa

AddLabel(tabMain, "AnanistWaffen Division // ban yerseniz idgaf // eğer alttaki kişilerden biri değilseniz napay (siktirin gidin)", true)
AddLabel(tabMain, "babapro yapımcılar")

function AddCreatorCard(parent, displayName, profileUsername)
    local card = Instance.new("TextButton", parent)
    card.Size = UDim2.new(1, -10, 0, 62)
    card.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    card.Text = ""
    card.AutoButtonColor = true
    card.ZIndex = 5
    registerObj(card, "ButtonBG")

    local corner = Instance.new("UICorner", card)
    corner.CornerRadius = UDim.new(0, 8)

    local avatar = Instance.new("ImageLabel", card)
    avatar.Size = UDim2.new(0, 48, 0, 48)
    avatar.Position = UDim2.new(0, 7, 0.5, -24)
    avatar.BackgroundTransparency = 1
    avatar.ZIndex = 6

    local nameLabel = Instance.new("TextLabel", card)
    nameLabel.Size = UDim2.new(1, -70, 1, 0)
    nameLabel.Position = UDim2.new(0, 65, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = displayName
    nameLabel.TextColor3 = Color3.fromRGB(220, 220, 240)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 6
    registerObj(nameLabel, "Text")

    task.spawn(function()
        local ok, userId = pcall(function()
            return Players:GetUserIdFromNameAsync(profileUsername)
        end)

        if ok and userId then
            avatar.Image = string.format(
                "rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150",
                userId
            )

            card.MouseButton1Click:Connect(function()
                local profile = "https://www.roblox.com/users/" .. tostring(userId) .. "/profile"
                local copied = false

                pcall(function()
                    if setclipboard then
                        setclipboard(profile)
                        copied = true
                    end
                end)

                pcall(function()
                    if toclipboard and not copied then
                        toclipboard(profile)
                        copied = true
                    end
                end)

                notify(
                    displayName,
                    copied and "Profil bağlantısı panoya kopyalandı" or profile
                )
            end)
        end
    end)

    return card
end

-- Görünen isim        -- Profil alınacak gerçek Roblox hesabı
AddCreatorCard(tabMain, "dutchvander4000 (Main)", "35YARGIC")
AddCreatorCard(tabMain, "arthurmorgan4000 (Main)", "Ananistan_Doom")
AddCreatorCard(tabMain, "imstillstand (Idea)", "UTKUATA35609")
AddLabel(tabMain, "dutchvander4000 ve arthurmorgan4000 true yapımcılar sadece bazı fikirler imstillstand (pew gibi)", true)
AddLabel(tabMain, "BU SCRIPT ARTHURMORGAN4000 VE DUTCHVANDER4000 TARAFINDAN YAPILMIŞTIR ÇALANI SİKERİZ", true)
AddLabel(tabMain, "Ana şeysiler")
AddButton(tabMain, "AWD AI", runananistwaffendivisionAI)
AddButton(tabMain, "AWD pew (lacayın kedisi pew oldu ya)", runananistwaffendivisionPew)
AddButton(tabMain, "Infinite sikish", runInfiniteYield)
AddButton(tabMain, "Aimbot (aimbot tabındaki daha iyi)", function() pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/WhJDjCag"))() end) end)
AddButton(tabMain, "Remote spy (dıt dıt dıdıı)", function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/InfernusScripts/Ketamine/refs/heads/main/Ketamine.lua"))() end) end)
AddButton(tabMain, "Server hop", function() serverHop(nil) end)
AddButton(tabMain, "Placeid kopyala", function()
    local placeIdText = tostring(game.PlaceId)
    local copied = false
    pcall(function()
        if setclipboard then
            setclipboard(placeIdText)
            copied = true
        end
    end)
    if not copied then
        pcall(function()
            if toclipboard then
                toclipboard(placeIdText)
                copied = true
            end
        end)
    end
    notify("AWD Hub", copied and "PlaceId kopyalandı: " .. placeIdText or "Clipboard desteklenmiyor: " .. placeIdText)
end)

AddLabel(tabMain, "Server Bulucu")
local serverPlayerCountBox = AddTextBox(tabMain, "sayı gir 123", function() end)
AddButton(tabMain, "Bak şimdi sayı giriyon o kişi kadar server buluyo", function()
    findServerByPlayerCount(serverPlayerCountBox.Text)
end)

AddLabel(tabMain, "Kullanıcı tf2 sniper")
local snipePlaceIdBox = AddTextBox(tabMain, "Oyun ve Placeid", function() end)
snipePlaceIdBox.Text = tostring(game.PlaceId)
local snipeUsernameBox = AddTextBox(tabMain, "Kullanıcı adı", function() end)
AddButton(tabMain, "Milli Joyango", function()
    userSnipe(snipePlaceIdBox.Text, snipeUsernameBox.Text)
end)
AddLabel(tabMain, "Target List (orospu çocukları ve blacklistliler)")
AddCreatorCard(tabMain, "wh*t", "turkyoutube1")
AddCreatorCard(tabMain, "l*ccey", "babaanne_para198")
AddCreatorCard(tabMain, "em*r", "Emodka123321")
AddCreatorCard(tabMain, "*fra", "Afraistee12")
AddCreatorCard(tabMain, "d*mir", "XxDemir_3555")
function AddCreatorCard(parent, imageId, textContent)
    -- Ana kart (İkiliyi yan yana tutmak için)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 50)
    card.BackgroundTransparency = 1
    card.Parent = parent

    -- Resim (Image)
    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(0, 40, 0, 40)
    img.Position = UDim2.new(0, 5, 0, 5)
    img.BackgroundTransparency = 1
    img.Image = "rbxassetid://" .. imageId
    img.Parent = card

    -- Yazı (Text)
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, -55, 1, 0)
    txt.Position = UDim2.new(0, 55, 0, 0)
    txt.BackgroundTransparency = 1
    txt.Text = textContent
    txt.TextColor3 = Color3.new(1, 1, 1)
    txt.TextSize = 16
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.Parent = card
end

-- Kullanımı:
AddCreatorCard(tabMain, "131444549369998", "üstte gördüğünüz orospu çocukları ile iletişime geçmeyin ")
AddCreatorCard(tabMain, "131444549369998", " osama claim bulunmuştur saat gece 3te director modda sikişmeyin")
AddLabel(tabMain, "Server infosu")
local serverInfoLabel = AddLabel(tabMain, getServerInfoText(), true)
task.spawn(function()
    while serverInfoLabel and serverInfoLabel.Parent do
        serverInfoLabel.Text = getServerInfoText()
        task.wait(1)
    end
end)
AddButton(tabMain, "Rejoin", rejoinServer)
AddButton(tabMain, "Hub Öldür", function() 
    stopAimbot()
    stopKosatka()

    espEnabled = false
    parachuteEnabled = false
    fullbrightEnabled = false
    if parachuteConnection then parachuteConnection:Disconnect(); parachuteConnection = nil end
    if parachuteTrack then parachuteTrack:Stop(); parachuteTrack = nil end
    if _G.AnanistanInsert then _G.AnanistanInsert:Disconnect(); _G.AnanistanInsert = nil end
    if espLoopThread then task.cancel(espLoopThread); espLoopThread = nil end
    for _, conn in pairs(espConnections) do if conn then conn:Disconnect() end end
    espConnections = {}
    clearESP()
    pcall(unloadWorkspaceExplorer)
    if infiniteJumpConn then infiniteJumpConn:Disconnect(); infiniteJumpConn = nil end
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    workspace.Gravity = movementGravity
    local Lighting = game:GetService("Lighting")
    if oldLighting.Brightness then
        Lighting.Brightness = oldLighting.Brightness
        Lighting.ClockTime = oldLighting.ClockTime
        Lighting.FogEnd = oldLighting.FogEnd
        Lighting.GlobalShadows = oldLighting.GlobalShadows
        Lighting.OutdoorAmbient = oldLighting.OutdoorAmbient
    end
    if screenGui then screenGui:Destroy(); screenGui = nil end
    if _G.ananistwaffendivisionCleanup then _G.ananistwaffendivisionCleanup = nil end
end)

-- Oyuncu
AddLabel(tabPlayer, "KARAKTERİNE BASAN MODLAR (yimmenü)")
local kosatkaHeightFrame
local kosatkaToggleFrame
kosatkaToggleFrame = AddToggle(tabPlayer, "Kosatka", kosatkaEnabled, function(state)
    toggleKosatka(state)
    if kosatkaHeightFrame then
        kosatkaHeightFrame.Visible = state
    end
end)
local setKosatkaHeightSlider
setKosatkaHeightSlider, kosatkaHeightFrame = AddSlider(tabPlayer, "Kosatka Yüksekliği", 0, 8, kosatkaHeight, function(val)
    setKosatkaHeight(val)
end)
kosatkaHeightFrame.Visible = kosatkaEnabled
AddToggle(tabPlayer, "Paraşüt", parachuteEnabled, function(state)
    local fakeBtn = {Text = ""}
    parachuteEnabled = not state
    runParachute(fakeBtn) 
end)
AddButton(tabPlayer, "Zarnovun scripti", function()
    loadstring(game:HttpGet('https://pastebin.com/raw/3Rnd9rHf'))()
end)
AddButton(tabPlayer, "Yaw Fly", runFly)
AddButton(tabPlayer, "Antigravity", function()
    pcall(function()
        loadstring(game:HttpGet("https://pastebin.com/raw/TPQRxApG"))()
    end)
end)
AddLabel(tabPlayer, "Hareket ayartaşağı")
local setWalkUI, setJumpUI, setGravUI
setWalkUI = AddSlider(tabPlayer, "WalkSpeed", 0, 200, movementWalkSpeed, function(val)
    setWalkSpeed(val)
end)
setJumpUI = AddSlider(tabPlayer, "JumpPower", 0, 300, movementJumpPower, function(val)
    setJumpPower(val)
end)
setGravUI = AddSlider(tabPlayer, "Gravity", 0, 500, movementGravity, function(val)
    setGravity(val)
end)
AddButton(tabPlayer, "Hareket Ayarlarını Normale Çevir", function()
    if kosatkaEnabled then stopKosatka() end
    movementWalkSpeed = 16
    movementJumpPower = 50
    movementGravity = 196.2
    workspace.Gravity = 196.2
    if setWalkUI then setWalkUI(16) end
    if setJumpUI then setJumpUI(50) end
    if setGravUI then setGravUI(196.2) end
    pcall(function() setWalkSpeed(16) end)
    pcall(function() setJumpPower(50) end)
    pcall(function() setGravity(196.2) end)

    infiniteJumpEnabled = false
    if infiniteJumpConn then
        infiniteJumpConn:Disconnect()
        infiniteJumpConn = nil
    end

    noclipEnabled = false
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end

    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = 16
        hum.UseJumpPower = true
        hum.JumpPower = 50
        hum.AutoRotate = true
    end

    if freezeCharacterEnabled then
        toggleFreezeCharacter(false)
    end
    freezeCharacterEnabled = false

    if char then
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.CanCollide = true
                obj.Anchored = false
            end
        end
    end
end)
AddToggle(tabPlayer, "Infinite Jump", infiniteJumpEnabled, function(state)
    toggleInfiniteJump(state)
end)
AddToggle(tabPlayer, "Noclip", noclipEnabled, function(state)
    toggleNoclip(state)
end)
AddToggle(tabPlayer, "Freeze Character", freezeCharacterEnabled, function(state)
    toggleFreezeCharacter(state)
end)
AddButton(tabPlayer, "Reset Character", resetCharacter)
AddLabel(tabPlayer, "Kısayollar")
AddToggle(tabPlayer, "Click-Teleport (Ctrl+Tık)", clickTPEnabled, function(s) clickTPEnabled = s end)
AddLabel(tabPlayer, "Güvenlik")
AddToggle(tabPlayer, "Anti-AFK (IDLE Engelleme)", antiAFKEnabled, function(s) toggleAntiAFK(s) end)
AddToggle(tabPlayer, "Anti-Void", false, function(s)
    antiVoidEnabled = s
    if s then startAntiVoid() else stopAntiVoid() end
end)


-- Aimbot


-- ANANISTAN AIMBOT TAB
AddLabel(tabAimbot, "ANANISTAN Aimbot — Aktif (Mouse)")
AddToggle(tabAimbot, "Aim Lock", AA.aimLock, function(s)
    AA.aimLock = s
    if not s then
        AA.hold.aimLock = false
        if not AA.active("triggerBot") then AA.stopLoop() end
    end
end)
do
    local display = tostring(AA.aimLockKey):gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", "")
    local lockKeyBtn = AddButton(tabAimbot, "Aim Lock Tuşu: [" .. display .. "]", function() end)
    local lockKeyLbl = lockKeyBtn:FindFirstChildOfClass("TextLabel")
    lockKeyBtn.MouseButton1Click:Connect(function()
        if AA.settingKey then return end
        AA.settingKey = true
        if lockKeyLbl then lockKeyLbl.Text = " Aim Lock Tuşu: Tuşa bas..." end
        local conn
        conn = UIS.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                AA.aimLockKey = inp.KeyCode
            elseif inp.UserInputType == Enum.UserInputType.MouseButton1 then
                AA.aimLockKey = Enum.UserInputType.MouseButton1
            elseif inp.UserInputType == Enum.UserInputType.MouseButton2 then
                AA.aimLockKey = Enum.UserInputType.MouseButton2
            else return end
            local kn = tostring(AA.aimLockKey):gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", "")
            if lockKeyLbl then lockKeyLbl.Text = " Aim Lock Tuşu: [" .. kn .. "]" end
            AA.settingKey = false
            conn:Disconnect()
        end)
    end)
end
do
    local modeBtn = AddButton(tabAimbot, "Aim Lock Modu: " .. AA.aimLockMode, function() end)
    local modeLbl = modeBtn:FindFirstChildOfClass("TextLabel")
    modeBtn.MouseButton1Click:Connect(function()
        AA.aimLockMode = (AA.aimLockMode == "toggle") and "hold" or "toggle"
        if modeLbl then modeLbl.Text = " Aim Lock Modu: " .. AA.aimLockMode end
    end)
end
AddToggle(tabAimbot, "Trigger Bot", AA.triggerBot, function(s)
    AA.triggerBot = s
    if not s then
        AA.hold.triggerBot = false
        if not AA.active("aimLock") then AA.stopLoop() end
    end
end)
do
    local display = tostring(AA.triggerKey):gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", "")
    local trigKeyBtn = AddButton(tabAimbot, "Trigger Bot Tuşu: [" .. display .. "]", function() end)
    local trigKeyLbl = trigKeyBtn:FindFirstChildOfClass("TextLabel")
    trigKeyBtn.MouseButton1Click:Connect(function()
        if AA.settingKey then return end
        AA.settingKey = true
        if trigKeyLbl then trigKeyLbl.Text = " Trigger Bot Tuşu: Tuşa bas..." end
        local conn
        conn = UIS.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                AA.triggerKey = inp.KeyCode
            elseif inp.UserInputType == Enum.UserInputType.MouseButton1 then
                AA.triggerKey = Enum.UserInputType.MouseButton1
            elseif inp.UserInputType == Enum.UserInputType.MouseButton2 then
                AA.triggerKey = Enum.UserInputType.MouseButton2
            else return end
            local kn = tostring(AA.triggerKey):gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", "")
            if trigKeyLbl then trigKeyLbl.Text = " Trigger Bot Tuşu: [" .. kn .. "]" end
            AA.settingKey = false
            conn:Disconnect()
        end)
    end)
end
do
    local modeBtn = AddButton(tabAimbot, "Trigger Bot Modu: " .. AA.triggerMode, function() end)
    local modeLbl = modeBtn:FindFirstChildOfClass("TextLabel")
    modeBtn.MouseButton1Click:Connect(function()
        AA.triggerMode = (AA.triggerMode == "toggle") and "hold" or "toggle"
        if modeLbl then modeLbl.Text = " Trigger Bot Modu: " .. AA.triggerMode end
    end)
end
AddLabel(tabAimbot, "ANANISTAN Filtreler")
AddToggle(tabAimbot, "Ölüleri Filtrele", AA.ignoreDead, function(s) AA.ignoreDead = s end)
AddToggle(tabAimbot, "Arkadaşları Filtrele", AA.ignoreFriends, function(s) AA.ignoreFriends = s end)
AddToggle(tabAimbot, "Takım Filtresi (aynı takımı yoksay)", AA.ignoreTeam, function(s) AA.ignoreTeam = s end)
AddTextBox(tabAimbot, "Filtrele (isimler, virgülle)", function(txt) AA.ignoreNames = txt end)
AddLabel(tabAimbot, "ANANISTAN FOV (Mouse/Camera merkezi, px)")
AddSlider(tabAimbot, "Aim FOV", 20, 500, AA.fov, function(val) AA.fov = val end)
AddTextBox(tabAimbot, "FOV sayı gir", function(txt)
    local n = tonumber(txt)
    if n then AA.fov = math.clamp(n, 1, 2000) end
end)
AddLabel(tabAimbot, "ANANISTAN Hedef")
do
    local targetBtn = AddButton(tabAimbot, "Hedef: " .. AA.targetPart, function() end)
    targetBtn.MouseButton1Click:Connect(function()
        AA.targetPart = (AA.targetPart == "Head") and "HumanoidRootPart" or "Head"
        local lbl = targetBtn:FindFirstChildOfClass("TextLabel")
        if lbl then lbl.Text = " Hedef: " .. AA.targetPart end
    end)
end
do
    local lockMethodBtn = AddButton(tabAimbot, "Kilitleme: " .. (AA.lockMethod or "Mouse"), function() end)
    local lockMethodLbl = lockMethodBtn:FindFirstChildOfClass("TextLabel")
    lockMethodBtn.MouseButton1Click:Connect(function()
        AA.lockMethod = (AA.lockMethod == "Camera") and "Mouse" or "Camera"
        if lockMethodLbl then lockMethodLbl.Text = " Kilitleme: " .. AA.lockMethod end
    end)
end

AddLabel(tabAimbot, "AI Prediction")
AddToggle(tabAimbot, "AI Prediction", AA.prediction, function(s)
    AA.prediction = s and true or false
end)
AddSlider(tabAimbot, "Prediction Miktarı", 0, 50, math.floor((AA.predictionAmount or 0.12) * 100), function(val)
    AA.predictionAmount = (tonumber(val) or 12) / 100
end)


-- Grapple
AddLabel(tabSpider, "Grapple Hook")
AddButton(tabSpider, "Grapple 1 (Çekme)", runSpiderWeb1)
AddButton(tabSpider, "Grapple 2 (Tutunma)", runSpiderWeb2)

-- [[ STUDIO TAB ]] --
AddLabel(tabStudio, "Studio Araçları")
AddLabel(tabStudio, "Dex, Scene Creator ve Workspace Explorer bu bölümde toplanır.", true)
AddButton(tabStudio, "Dex Explorer", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
    end)
end)
AddButton(tabStudio, "Scene Creator", function()
    pcall(function()
        loadstring(game:HttpGet("https://pastebin.com/raw/5JQcNHYZ"))()
    end)
end)

-- [[ OYUNLAR TAB // DÜZ ALT TAB LİSTESİ ]] --
AddLabel(tabGames, "Oyunlar")
AddLabel(tabGames, "Bir oyun seç; her satır kendi oyun scriptlerini açar.", true)
AddButton(tabGames, "BRM5", function()
    pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/zfgWDHXC"))() end)
end)
AddButton(tabGames, "Evade", function()
    pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Emerson2-creator/Scripts-Roblox/refs/heads/main/EvadeScript.lua"))() end)
end)
AddButton(tabGames, "Katil Porbo", function()
    pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/vS3pSfXF", true))() end)
end)
AddButton(tabGames, "Animal Hospital", function()
    pcall(function() loadstring(game:HttpGet("https://gist.githubusercontent.com/NoxScriptsZeN/92555dca436989a077ed25b172d4bc78/raw"))() end)
end)
AddButton(tabGames, "Evil Morty Sex", function()
    pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/6GH3j1Vj"))() end)
end)

-- [[ OYUNLAR // KART KATALOĞU + İÇ SIDEBAR ]] --
do -- Register limitini aşmamak için katalog local'ları bu scope içinde kalır.
tDGames.Btn.Visible = false
local gameLibrary, gameLibraryData = CreateTab("Oyunlar")
gameLibraryData.Btn.LayoutOrder = 5
local gameOldLayout = gameLibrary:FindFirstChildOfClass("UIListLayout")
if gameOldLayout then gameOldLayout:Destroy() end
gameLibrary.CanvasSize = UDim2.new(0, 0, 0, 410)
function gameNew(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    o.Parent = parent
    return o
end
gameNew("TextLabel", {Size = UDim2.new(1, -18, 0, 35), Position = UDim2.new(0, 9, 0, 5), BackgroundTransparency = 1, Text = "Oyunlar", TextColor3 = Color3.fromRGB(245, 245, 250), Font = Enum.Font.GothamBold, TextSize = 24, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6}, gameLibrary)
gameNew("TextLabel", {Size = UDim2.new(1, -18, 0, 20), Position = UDim2.new(0, 10, 0, 40), BackgroundTransparency = 1, Text = "oyununu seç, sağdaki karttan scripti aç", TextColor3 = Color3.fromRGB(150, 150, 165), Font = Enum.Font.GothamMedium, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6}, gameLibrary)
gameNew("Frame", {Size = UDim2.new(1, -18, 0, 1), Position = UDim2.new(0, 9, 0, 71), BackgroundColor3 = Color3.fromRGB(82, 82, 98), BorderSizePixel = 0, ZIndex = 6}, gameLibrary)
local gameSidebar = gameNew("ScrollingFrame", {Size = UDim2.new(0, 135, 0, 292), Position = UDim2.new(0, 9, 0, 86), BackgroundColor3 = Color3.fromRGB(8, 8, 10), BorderSizePixel = 0, ScrollBarThickness = 2, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 6}, gameLibrary)
gameNew("UICorner", {CornerRadius = UDim.new(0, 10)}, gameSidebar)
local sideList = gameNew("UIListLayout", {Padding = UDim.new(0, 5)}, gameSidebar)
gameNew("UIPadding", {PaddingTop = UDim.new(0, 7), PaddingBottom = UDim.new(0, 7), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6)}, gameSidebar)
local gameGrid = gameNew("ScrollingFrame", {Size = UDim2.new(1, -162, 0, 292), Position = UDim2.new(0, 153, 0, 86), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 6}, gameLibrary)
local gameGridLayout = gameNew("UIGridLayout", {CellSize = UDim2.new(0, 145, 0, 100), CellPadding = UDim2.new(0, 10, 0, 10), SortOrder = Enum.SortOrder.LayoutOrder}, gameGrid)
local gameTitle = gameNew("TextLabel", {Size = UDim2.new(1, -162, 0, 22), Position = UDim2.new(0, 153, 0, 64), BackgroundTransparency = 1, Text = "TÜM OYUNLAR", TextColor3 = Color3.fromRGB(175, 185, 220), Font = Enum.Font.Code, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6}, gameLibrary)
local games = {
    {"Ftap", "Sandbox", function() pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/JBT1fMAu"))() end) end},
    {"Ftap I Füze", "Sandbox", function() pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/MkxjDhL3"))() end) end}
    {"Ftap I Eşya", "Sandbox", function() pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/nnwZSezd"))() end) end},
    {"Ftap I Roket", "Sandbox", function() pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/JfuiC4za"))() end) end},
    {"Blackhawk Rescue Mission 5", "FPS", function() pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/zfgWDHXC"))() end) end},
    {"Evade", "Survival", function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Emerson2-creator/Scripts-Roblox/refs/heads/main/EvadeScript.lua"))() end) end},
    {"Katil Porbo", "Survival", function() pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/vS3pSfXF", true))() end) end},
    {"Animal Hospital", "Horror", function() pcall(function() loadstring(game:HttpGet("https://gist.githubusercontent.com/NoxScriptsZeN/92555dca436989a077ed25b172d4bc78/raw"))() end) end},
    {"Evil Morty", "OTHER", function() pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/6GH3j1Vj"))() end) end},
}
local selectedGame = "TÜM OYUNLAR"
function buildGameCards(filter)
    for _, c in ipairs(gameGrid:GetChildren()) do if not c:IsA("UIGridLayout") then c:Destroy() end end
    for _, gameInfo in ipairs(games) do
        if filter == "TÜM OYUNLAR" or filter == gameInfo[2] then
            local card = gameNew("TextButton", {BackgroundColor3 = Color3.fromRGB(18, 18, 22), BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = 7}, gameGrid)
            gameNew("UICorner", {CornerRadius = UDim.new(0, 10)}, card)
            gameNew("UIStroke", {Color = Color3.fromRGB(100, 100, 122), Transparency = .32}, card)
            gameNew("TextLabel", {Size = UDim2.new(1, -18, 0, 22), Position = UDim2.new(0, 9, 0, 14), BackgroundTransparency = 1, Text = gameInfo[1], TextColor3 = Color3.fromRGB(245, 245, 250), Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8}, card)
            gameNew("TextLabel", {Size = UDim2.new(1, -18, 0, 17), Position = UDim2.new(0, 9, 0, 39), BackgroundTransparency = 1, Text = gameInfo[2] .. "  /  SCRIPT", TextColor3 = Color3.fromRGB(150, 170, 235), Font = Enum.Font.Code, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8}, card)
            local open = gameNew("TextLabel", {Size = UDim2.new(1, -18, 0, 16), Position = UDim2.new(0, 9, 1, -22), BackgroundTransparency = 1, Text = "AÇMAK İÇİN TIKLA", TextColor3 = Color3.fromRGB(160, 160, 170), Font = Enum.Font.GothamMedium, TextSize = 8, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8}, card)
            card.MouseButton1Click:Connect(gameInfo[3])
            card.MouseEnter:Connect(function() TweenService:Create(card, TweenInfo.new(.15), {BackgroundColor3 = Color3.fromRGB(31, 34, 44)}):Play() end)
            card.MouseLeave:Connect(function() TweenService:Create(card, TweenInfo.new(.15), {BackgroundColor3 = Color3.fromRGB(18, 18, 22)}):Play() end)
        end
    end
end
for _, category in ipairs({"TÜM OYUNLAR", "Sandbox", "FPS", "Survival", "Horror", "OTHER"}) do
    local b = gameNew("TextButton", {Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0, Text = "  " .. category, TextColor3 = Color3.fromRGB(205, 205, 215), TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.GothamMedium, TextSize = 10, ZIndex = 7}, gameSidebar)
    gameNew("UICorner", {CornerRadius = UDim.new(0, 7)}, b)
    b.MouseButton1Click:Connect(function() selectedGame = category; gameTitle.Text = category; buildGameCards(category) end)
end
buildGameCards(selectedGame)
end

-- [[ SCRIPTLER TAB ]] --
do
    AddLabel(tabScripts, "Hazır Scriptler")
    AddButton(tabScripts, "FTAP", function()
        pcall(function()
            loadstring(game:HttpGet("https://pastebin.com/raw/JBT1fMAu"))()
        end)
    end)
    AddButton(tabScripts, "Bodycam", function()
        pcall(function()
            loadstring(game:HttpGet("https://pastebin.com/raw/HSQ9dyXt"))()
        end)
    end)
    AddButton(tabScripts, "Telekinesis", function()
        pcall(function()
            loadstring(game:HttpGet("https://pastebin.com/raw/QAsFzqSh"))()
        end)
    end)
    AddLabel(tabScripts, "Kendi Scriptini Kaydet / Çalıştır")
    local customScriptNameBox = AddTextBox(tabScripts, "Script adı...", function() end)
    local customScriptCodeBox = AddTextBox(tabScripts, "Script kodunu yapıştır (loadstring içeriği)...", function() end)
    customScriptCodeBox.MultiLine = true
    customScriptCodeBox.TextWrapped = false
    customScriptCodeBox.TextYAlignment = Enum.TextYAlignment.Top
    customScriptCodeBox.Size = UDim2.new(1, -10, 0, 120)

    local scriptsSlotsData = {}
    local function saveScriptsSlotsToFile()
        if writefile then
            pcall(function()
                writefile("ananite_hub_scripts.json", HttpService:JSONEncode(scriptsSlotsData))
            end)
        end
    end
    local function loadScriptsSlotsFromFile()
        if isfile and isfile("ananite_hub_scripts.json") then
            local ok, res = pcall(function()
                return HttpService:JSONDecode(readfile("ananite_hub_scripts.json"))
            end)
            if ok and type(res) == "table" then
                return res
            end
        end
        return {}
    end
    scriptsSlotsData = loadScriptsSlotsFromFile()
    local editingSlotName = nil

    local function rebuildScriptsSlotsUI()
        for _, child in pairs(tabScripts:GetChildren()) do
            if child:IsA("Frame") and child.Name == "ScriptSlotEntry" then
                child:Destroy()
            end
        end
        for slotName, data in pairs(scriptsSlotsData) do
            local entry = Instance.new("Frame", tabScripts)
            entry.Name = "ScriptSlotEntry"
            entry.Size = UDim2.new(1, -10, 0, 52)
            entry.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
            entry.ZIndex = 5
            registerObj(entry, "ButtonBG")
            local entryCorner = Instance.new("UICorner", entry)
            entryCorner.CornerRadius = UDim.new(0, 8)
            local label = Instance.new("TextLabel", entry)
            label.Size = UDim2.new(0.34, 0, 1, 0)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = slotName
            label.TextColor3 = Color3.fromRGB(220, 220, 240)
            label.TextSize = 13
            label.Font = Enum.Font.GothamMedium
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.ZIndex = 6
            registerObj(label, "Text")
            local loadBtn = Instance.new("TextButton", entry)
            loadBtn.Size = UDim2.new(0.15, -4, 0, 30)
            loadBtn.Position = UDim2.new(0.36, 0, 0.5, -15)
            loadBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
            loadBtn.Text = "Çalıştır"
            loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            loadBtn.Font = Enum.Font.GothamBold
            loadBtn.TextSize = 11
            loadBtn.ZIndex = 6
            local loadBtnCorner = Instance.new("UICorner", loadBtn)
            loadBtnCorner.CornerRadius = UDim.new(0, 6)
            loadBtn.MouseButton1Click:Connect(function()
                pcall(function()
                    if data.Source then
                        loadstring(data.Source)()
                    end
                end)
            end)
            local editBtn = Instance.new("TextButton", entry)
            editBtn.Size = UDim2.new(0.15, -4, 0, 30)
            editBtn.Position = UDim2.new(0.52, 0, 0.5, -15)
            editBtn.BackgroundColor3 = Color3.fromRGB(70, 100, 165)
            editBtn.Text = "Düzenle"
            editBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            editBtn.Font = Enum.Font.GothamBold
            editBtn.TextSize = 10
            editBtn.ZIndex = 6
            Instance.new("UICorner", editBtn).CornerRadius = UDim.new(0, 6)
            editBtn.MouseButton1Click:Connect(function()
                editingSlotName = slotName
                customScriptNameBox.Text = slotName
                customScriptCodeBox.Text = data.Source or ""
            end)
            local copyBtn = Instance.new("TextButton", entry)
            copyBtn.Size = UDim2.new(0.15, -4, 0, 30)
            copyBtn.Position = UDim2.new(0.68, 0, 0.5, -15)
            copyBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 100)
            copyBtn.Text = "Kopyala"
            copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            copyBtn.Font = Enum.Font.GothamBold
            copyBtn.TextSize = 10
            copyBtn.ZIndex = 6
            Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 6)
            copyBtn.MouseButton1Click:Connect(function()
                pcall(function() if setclipboard then setclipboard(data.Source or "") end end)
                local duplicateName = slotName .. " Kopya"
                local suffix = 2
                while scriptsSlotsData[duplicateName] do
                    duplicateName = slotName .. " Kopya " .. suffix
                    suffix += 1
                end
                scriptsSlotsData[duplicateName] = {Source = data.Source or ""}
                saveScriptsSlotsToFile()
                rebuildScriptsSlotsUI()
            end)
            local deleteBtn = Instance.new("TextButton", entry)
            deleteBtn.Size = UDim2.new(0.15, -4, 0, 30)
            deleteBtn.Position = UDim2.new(0.84, 0, 0.5, -15)
            deleteBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
            deleteBtn.Text = "Sil"
            deleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            deleteBtn.Font = Enum.Font.GothamBold
            deleteBtn.TextSize = 11
            deleteBtn.ZIndex = 6
            local deleteBtnCorner = Instance.new("UICorner", deleteBtn)
            deleteBtnCorner.CornerRadius = UDim.new(0, 6)
            deleteBtn.MouseButton1Click:Connect(function()
                scriptsSlotsData[slotName] = nil
                saveScriptsSlotsToFile()
                rebuildScriptsSlotsUI()
            end)
        end
    end

    AddButton(tabScripts, "Kodu Kaydet", function()
        local name = customScriptNameBox.Text
        local code = customScriptCodeBox.Text
        if name == "" or code == "" then return end
        if editingSlotName and editingSlotName ~= name then
            scriptsSlotsData[editingSlotName] = nil
        end
        scriptsSlotsData[name] = {Source = code}
        editingSlotName = nil
        saveScriptsSlotsToFile()
        rebuildScriptsSlotsUI()
        customScriptNameBox.Text = ""
        customScriptCodeBox.Text = ""
    end)
    AddButton(tabScripts, "Kodu Direkt Çalıştır", function()
        local code = customScriptCodeBox.Text
        if code == "" then return end
        pcall(function()
            loadstring(code)()
        end)
    end)
    AddLabel(tabScripts, "Kayıtlı Script Slotları")
    rebuildScriptsSlotsUI()
end

-- [[ AWD SCRIPT LIBRARY // ARCEUS TARZI YENİ TASARIM ]] --
-- Eski sayfa ve callback'ler görünmez halde tutuluyor; yeni library aynı kayıt dosyasını kullanır.
do -- Büyük library kendi scope'unda; ana scriptin local register sayısını şişirmez.
tDScripts.Btn.Visible = false
local scriptLibrary, scriptLibraryData = CreateTab("Scriptler")
scriptLibraryData.Btn.LayoutOrder = 12
local oldScriptLayout = scriptLibrary:FindFirstChildOfClass("UIListLayout")
if oldScriptLayout then oldScriptLayout:Destroy() end
scriptLibrary.CanvasSize = UDim2.new(0, 0, 0, 610)
function libNew(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    o.Parent = parent
    return o
end
local libTitle = libNew("TextLabel", {Size = UDim2.new(.55, 0, 0, 42), Position = UDim2.new(0, 8, 0, 4), BackgroundTransparency = 1, Text = "Script library", TextColor3 = Color3.fromRGB(245, 245, 250), Font = Enum.Font.GothamBold, TextSize = 25, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6}, scriptLibrary)
local libSub = libNew("TextLabel", {Size = UDim2.new(.56, 0, 0, 20), Position = UDim2.new(0, 10, 0, 43), BackgroundTransparency = 1, Text = "AWD HUB  /  kendi scriptlerini sakla ve yönet", TextColor3 = Color3.fromRGB(145, 145, 160), Font = Enum.Font.GothamMedium, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6}, scriptLibrary)
local libraryStatus = libNew("TextLabel", {Size = UDim2.new(.42, -10, 0, 22), Position = UDim2.new(.58, 0, 0, 12), BackgroundTransparency = 1, Text = "KAYITLI SCRIPT YOK", TextColor3 = Color3.fromRGB(155, 180, 255), Font = Enum.Font.Code, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 6}, scriptLibrary)
local newScriptBtn = libNew("TextButton", {Size = UDim2.new(0, 128, 0, 32), Position = UDim2.new(1, -136, 0, 38), BackgroundColor3 = Color3.fromRGB(36, 48, 78), Text = "the button that dont do anything", TextColor3 = Color3.fromRGB(245, 248, 255), Font = Enum.Font.GothamBold, TextSize = 11, BorderSizePixel = 0, ZIndex = 7}, scriptLibrary)
libNew("UICorner", {CornerRadius = UDim.new(0, 8)}, newScriptBtn)
local libLine = libNew("Frame", {Size = UDim2.new(1, -16, 0, 1), Position = UDim2.new(0, 8, 0, 78), BackgroundColor3 = Color3.fromRGB(75, 75, 90), BorderSizePixel = 0, ZIndex = 6}, scriptLibrary)
local scriptGrid = libNew("ScrollingFrame", {Size = UDim2.new(1, -16, 0, 250), Position = UDim2.new(0, 8, 0, 92), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = Color3.fromRGB(130, 140, 175), CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 6}, scriptLibrary)
local scriptGridLayout = libNew("UIGridLayout", {CellSize = UDim2.new(0, 125, 0, 92), CellPadding = UDim2.new(0, 10, 0, 10), SortOrder = Enum.SortOrder.LayoutOrder}, scriptGrid)
local editor = libNew("Frame", {Size = UDim2.new(1, -16, 0, 225), Position = UDim2.new(0, 8, 0, 362), BackgroundColor3 = Color3.fromRGB(10, 10, 13), BorderSizePixel = 0, ZIndex = 6}, scriptLibrary)
libNew("UICorner", {CornerRadius = UDim.new(0, 12)}, editor)
libNew("UIStroke", {Color = Color3.fromRGB(75, 80, 100), Transparency = .25}, editor)
local editorTitle = libNew("TextLabel", {Size = UDim2.new(.5, 0, 0, 30), Position = UDim2.new(0, 12, 0, 8), BackgroundTransparency = 1, Text = "SCRIPT EDITOR", TextColor3 = Color3.fromRGB(220, 225, 245), Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 7}, editor)
local nameInput = libNew("TextBox", {Size = UDim2.new(1, -24, 0, 31), Position = UDim2.new(0, 12, 0, 40), BackgroundColor3 = Color3.fromRGB(20, 20, 25), BorderSizePixel = 0, PlaceholderText = "script adı", PlaceholderColor3 = Color3.fromRGB(115, 115, 130), Text = "", TextColor3 = Color3.fromRGB(240, 240, 245), Font = Enum.Font.GothamMedium, TextSize = 12, ClearTextOnFocus = false, ZIndex = 7}, editor)
libNew("UICorner", {CornerRadius = UDim.new(0, 7)}, nameInput)
local codeInput = libNew("TextBox", {Size = UDim2.new(1, -24, 0, 92), Position = UDim2.new(0, 12, 0, 79), BackgroundColor3 = Color3.fromRGB(15, 15, 19), BorderSizePixel = 0, PlaceholderText = "Lua kodunu buraya yapıştır...", PlaceholderColor3 = Color3.fromRGB(105, 105, 118), Text = "", TextColor3 = Color3.fromRGB(220, 225, 235), Font = Enum.Font.Code, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, MultiLine = true, ClearTextOnFocus = false, ZIndex = 7}, editor)
libNew("UICorner", {CornerRadius = UDim.new(0, 7)}, codeInput)
function libAction(text, x, color)
    local b = libNew("TextButton", {Size = UDim2.new(0, 92, 0, 30), Position = UDim2.new(0, x, 1, -40), BackgroundColor3 = color, BorderSizePixel = 0, Text = text, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold, TextSize = 10, ZIndex = 7}, editor)
    libNew("UICorner", {CornerRadius = UDim.new(0, 7)}, b); return b
end
local saveLibBtn = libAction("KAYDET", 12, Color3.fromRGB(50, 125, 75))
local runLibBtn = libAction("ÇALIŞTIR", 112, Color3.fromRGB(55, 85, 145))
local copyLibBtn = libAction("KOPYALA", 212, Color3.fromRGB(65, 65, 76))
local deleteLibBtn = libAction("SİL", 312, Color3.fromRGB(145, 50, 55))
local libraryData, editingLibraryName = {}, nil
function loadLibraryData()
    if isfile and isfile("ananite_hub_scripts.json") then
        local ok, decoded = pcall(function() return HttpService:JSONDecode(readfile("ananite_hub_scripts.json")) end)
        if ok and type(decoded) == "table" then return decoded end
    end
    return {}
end
function saveLibraryData()
    if writefile then pcall(function() writefile("ananite_hub_scripts.json", HttpService:JSONEncode(libraryData)) end) end
end
function clearGrid()
    for _, child in ipairs(scriptGrid:GetChildren()) do if not child:IsA("UIGridLayout") then child:Destroy() end end
end
function makeScriptCard(name, source, builtin)
    local card = libNew("TextButton", {BackgroundColor3 = Color3.fromRGB(19, 19, 23), BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = 7}, scriptGrid)
    libNew("UICorner", {CornerRadius = UDim.new(0, 10)}, card)
    libNew("UIStroke", {Color = Color3.fromRGB(94, 94, 112), Transparency = .3}, card)
    local icon = libNew("TextLabel", {Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(0, 10, 0, 10), BackgroundColor3 = Color3.fromRGB(240, 242, 250), Text = "AWD", TextColor3 = Color3.fromRGB(20, 24, 38), Font = Enum.Font.GothamBlack, TextSize = 10, ZIndex = 8}, card)
    libNew("UICorner", {CornerRadius = UDim.new(0, 8)}, icon)
    libNew("TextLabel", {Size = UDim2.new(1, -16, 0, 28), Position = UDim2.new(0, 8, 0, 57), BackgroundTransparency = 1, Text = name, TextColor3 = Color3.fromRGB(235, 235, 245), Font = Enum.Font.GothamBold, TextSize = 10, TextWrapped = true, ZIndex = 8}, card)
    card.MouseButton1Click:Connect(function()
        editingLibraryName = builtin and nil or name
        nameInput.Text, codeInput.Text = name, source
        libraryStatus.Text = builtin and ("HAZIR SCRIPT: " .. name) or ("DÜZENLENİYOR: " .. name)
    end)
end
function rebuildLibrary()
    clearGrid()
    makeScriptCard("Bodycam", "loadstring(game:HttpGet(\"https://pastebin.com/raw/HSQ9dyXt\"))()", true)
    makeScriptCard("Telekinesis", "loadstring(game:HttpGet(\"https://pastebin.com/raw/QAsFzqSh\"))()", true)
    for name, data in pairs(libraryData) do makeScriptCard(name, data.Source or "", false) end
    local count = 0; for _ in pairs(libraryData) do count += 1 end
    libraryStatus.Text = count > 0 and (count .. " KAYITLI SCRIPT") or "KAYITLI SCRIPT YOK"
end
libraryData = loadLibraryData()
newScriptBtn.MouseButton1Click:Connect(function() editingLibraryName = nil; nameInput.Text = ""; codeInput.Text = ""; libraryStatus.Text = "YENİ SCRIPT HAZIR" end)
saveLibBtn.MouseButton1Click:Connect(function()
    local name, code = nameInput.Text, codeInput.Text
    if name == "" or code == "" then return end
    if editingLibraryName and editingLibraryName ~= name then libraryData[editingLibraryName] = nil end
    libraryData[name] = {Source = code}; editingLibraryName = name; saveLibraryData(); rebuildLibrary()
end)
runLibBtn.MouseButton1Click:Connect(function() if codeInput.Text ~= "" then pcall(function() loadstring(codeInput.Text)() end) end end)
copyLibBtn.MouseButton1Click:Connect(function() pcall(function() if setclipboard then setclipboard(codeInput.Text) end end) end)
deleteLibBtn.MouseButton1Click:Connect(function() if editingLibraryName then libraryData[editingLibraryName] = nil; editingLibraryName = nil; nameInput.Text = ""; codeInput.Text = ""; saveLibraryData(); rebuildLibrary() end end)
rebuildLibrary()
end

AddButton(tabMain, "Script Reload", function()
    pcall(function()
        if _G.ananistwaffendivisionReload then
            _G.ananistwaffendivisionReload()
        else
            notify("AWD Hub", "Reload sistemi hazır değil")
        end
    end)
end)

-- Görseller
AddLabel(tabVisuals, "ESP")
espKeyBtn = AddButton(tabVisuals, "ESP Aç/Kapat: [T]", function() end)
espKeyLabel = espKeyBtn:FindFirstChildOfClass("TextLabel")
local updateESPUIs = {}

updateESPUIs.master = AddToggle(tabVisuals, "ESP Aktif", espEnabled, function(state)
    espEnabled = state
    if espEnabled then
        for _, conn in pairs(espConnections) do if conn then conn:Disconnect() end end
        espConnections = {}
        local function setupForPlayer(p)
            if p == player then return end
            table.insert(espConnections, p.CharacterAdded:Connect(function(char)
                local root = char:WaitForChild("HumanoidRootPart", 10)
                if root and espEnabled then buildESP(p) end
            end))
            if p.Character then
                pcall(function() buildESP(p) end)
            end
        end
        for _, p in pairs(Players:GetPlayers()) do setupForPlayer(p) end
        table.insert(espConnections, Players.PlayerAdded:Connect(setupForPlayer))
        table.insert(espConnections, Players.PlayerRemoving:Connect(function(p)
            if espObjects[p] then
                if espObjects[p].box then pcall(game.Destroy, espObjects[p].box) end
                if espObjects[p].billboard then pcall(game.Destroy, espObjects[p].billboard) end
                if espObjects[p].highlight then pcall(game.Destroy, espObjects[p].highlight) end
                espObjects[p] = nil
            end
        end))
        if not espLoopThread then
            espLoopThread = task.spawn(function()
                local refreshTimer = 0
                while espEnabled do
                    pcall(updateAllESP)
                    refreshTimer = refreshTimer + 0.2
                    if refreshTimer >= 30 then
                        refreshTimer = 0
                        clearESP()
                    end
                    task.wait(0.2)
                end
            end)
        end
    else
        clearESP()
        if espLoopThread then task.cancel(espLoopThread); espLoopThread = nil end
        for _, conn in pairs(espConnections) do if conn then conn:Disconnect() end end
        espConnections = {}
    end
end)

updateESPUIs.isim = AddToggle(tabVisuals, "İsim Çiz", espShowNames, function(s) espShowNames = s end)
updateESPUIs.health = AddToggle(tabVisuals, "Sağlık Çubuğu", espShowHealth, function(s) espShowHealth = s end)
updateESPUIs.chams = AddToggle(tabVisuals, "Chams", espShowChams, function(s) espShowChams = s end)
updateESPUIs.kutu = AddToggle(tabVisuals, "Kutu (Box)", espShowBoxes, function(s) espShowBoxes = s end)
updateESPUIs.env = AddToggle(tabVisuals, "Envanter Gör", espShowInventory, function(s) espShowInventory = s end)

AddLabel(tabVisuals, "ESP Mesafe Ayarı")
local setDistSlider, distBox
setDistSlider = AddSlider(tabVisuals, "Mesafe (Slider)", 0, 25000, espMaxDistance, function(val)
    espMaxDistance = val
    if distBox then distBox.Text = tostring(val) end
end)
distBox = AddTextBox(tabVisuals, "Mesafe Gir (Sayı)", function(txt)
    local val = tonumber(txt:match("%d+"))
    if val then
        val = math.clamp(val, 0, 25000)
        espMaxDistance = val
        distBox.Text = tostring(val)
        setDistSlider(val)
    end
end)
distBox.Text = tostring(espMaxDistance)

-- Workspace İsim ESP (Görseller sekmesine ek)
AddLabel(tabVisuals, "Workspace İsim ESP")
_G.ananistwaffendivisionWorkspaceNameESPBoxVisuals = AddTextBox(tabVisuals, "Workspace obje adı gir...", function(text)
    pcall(function()
        _G.ananistwaffendivisionNameSearchWorkspaceESP(text)
    end)
end)
AddButton(tabVisuals, "İsim ESP Temizle", function()
    pcall(function()
        _G.ananistwaffendivisionClearWorkspaceESP()
    end)
    if _G.ananistwaffendivisionWorkspaceNameESPBoxVisuals then
        _G.ananistwaffendivisionWorkspaceNameESPBoxVisuals.Text = ""
    end
end)

AddLabel(tabVisuals, "ESP Renk Yönetimi")
updateESPUIs.friend = AddToggle(tabVisuals, "Arkadaş Rengi Kullan", espUseFriendColor, function(s) espUseFriendColor = s end)
local setFriendColorUI = AddColorPicker(tabVisuals, "Arkadaş Rengi", espFriendColor, function(c) espFriendColor = c end)

updateESPUIs.customColor = AddToggle(tabVisuals, "ESP Rengi Kullan", espUseCustomColor, function(s)
    espUseCustomColor = s
    if s then 
        espUseTeamColor = false 
        updateESPUIs.teamColor(false)
    end
end)
local setEspColorUI = AddColorPicker(tabVisuals, "ESP Rengi", espCustomColor, function(c) espCustomColor = c; espUseCustomColor = true; espUseTeamColor = false; updateESPUIs.customColor(true); updateESPUIs.teamColor(false) end)

updateESPUIs.teamColor = AddToggle(tabVisuals, "Takım Rengi Kullan", espUseTeamColor, function(s)
    espUseTeamColor = s
    if s then
        espUseCustomColor = false
        updateESPUIs.customColor(false)
    end
end)

AddLabel(tabVisuals, "Çevre")
updateESPUIs.bright = AddToggle(tabVisuals, "FullBright", false, function(state)
    local fakeBtn = {Text = ""}
    fullbrightEnabled = not state
    runFullbright(fakeBtn)
end)

espKeyBtn.MouseButton1Click:Connect(function()
    if settingESPKey or settingMenuKey then return end
    settingESPKey = true
    if espKeyLabel then espKeyLabel.Text = " ESP Tuşu: Tuşa bas..." end
    local conn
    conn = UIS.InputBegan:Connect(function(inp, gp)
        if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if gp then return end
        espToggleKey = inp.KeyCode
        local keyName = tostring(inp.KeyCode):gsub("Enum.KeyCode.", "")
        if espKeyLabel then espKeyLabel.Text = " ESP Aç/Kapat: [" .. keyName .. "]" end
        settingESPKey = false
        conn:Disconnect()
    end)
end)
-- Ayarlar (Yeni Tema Sistemi Buraya Eklendi)
AddLabel(tabDesigner, "Temalar")
AddLabel(tabDesigner, "Temalar — Strangers & Freaks")
AddButton(tabDesigner, "ϟϟ Theme (Varsayılan)", function() applyTheme("ϟϟ Theme") end)
AddButton(tabDesigner, "Kırmızı Theme", function() applyTheme("Kırmızı theme") end)
AddButton(tabDesigner, "Beyaz Theme", function() applyTheme("Beyaz theme") end)
AddButton(tabDesigner, "Yeşil Theme", function() applyTheme("Yeşil theme") end)

AddLabel(tabDesigner, "Fobiler")
AddButton(tabDesigner, "Cyberpunk", function() applyTheme("Cyberpunk") end)
AddButton(tabDesigner, "Matrix ", function() applyTheme("Matrix") end)
AddButton(tabDesigner, "Toprak", function() applyTheme("Minecraft") end)
AddButton(tabDesigner, "Half-Life (Lambda)", function() applyTheme("Half-Life") end)
AddButton(tabDesigner, "Aero Glass (Glassmorphism)", function() applyTheme("Aero Glass") end)

AddLabel(tabDesigner, "Doğa")
AddButton(tabDesigner, "Space Void (Deep Purple)", function() applyTheme("Space Void") end)
AddButton(tabDesigner, "Sakura (Soft Pink)", function() applyTheme("Sakura") end)
AddButton(tabDesigner, "Desert Gold", function() applyTheme("Desert Gold") end)
AddButton(tabDesigner, "Ocean Deep (Turquoise)", function() applyTheme("Ocean Deep") end)
AddButton(tabDesigner, "Toxic Waste (Acid Green)", function() applyTheme("Toxic Waste") end)

AddLabel(tabDesigner, "StreSS")
AddButton(tabDesigner, "Bloodlust (True Black & Red)", function() applyTheme("Bloodlust") end)
AddButton(tabDesigner, "Midnight Gold (Premium Black)", function() applyTheme("Midnight Gold") end)
AddButton(tabDesigner, "Plague (Dark Mud)", function() applyTheme("Plague") end)

AddLabel(tabDesigner, "Retroslop")
AddButton(tabDesigner, "Dracula", function() applyTheme("Dracula") end)
AddButton(tabDesigner, "One Dark (Atom)", function() applyTheme("One Dark") end)
AddButton(tabDesigner, "Synthwave (Outrun)", function() applyTheme("Synthwave") end)

AddLabel(tabSettings, "Menü Bilgileri")
AddLabel(tabSettings, "Seçtiğin Tuşlar:\nMenü Gizle/Aç: Ayarlar / Dizayn\nESP Aktif Etme: Görseller sekmesine bak\nAimbot: Aimbot sekmesinden ayarlanır\nW/S: Duvara Tırman (Aktifken)\nGrapple 2: E (Çek) / Q (Sal)", true)



-- ANANISTAN CONFIG + AUTOEXEC + EKSTRA (fixed)
do
    local CFG = {
        folder = "AWD_Hub_Configs",
        settings = "AWD_Hub_Settings.json",
        autoexec = "autoexec/AWD_Hub.lua",
        current = "default",
    }

    local function notify(title, text, dur)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = title or "AWD Hub",
                Text = tostring(text or ""),
                Duration = dur or 3
            })
        end)
    end

    local function sanitizeName(name)
        name = tostring(name or "default"):gsub("^%s+", ""):gsub("%s+$", "")
        if name == "" then name = "default" end
        name = name:gsub("[^%w%_%-%s]", "")
        name = name:gsub("%s+", "_")
        if name == "" then name = "default" end
        return name
    end

    local function path(name)
        return CFG.folder .. "/" .. sanitizeName(name) .. ".json"
    end

    local function ensure()
        pcall(function()
            if type(makefolder) == "function" and type(isfolder) == "function" then
                if not isfolder(CFG.folder) then makefolder(CFG.folder) end
            end
        end)
    end

    local function list()
        local t = {}
        pcall(function()
            if type(listfiles) == "function" and type(isfolder) == "function" and isfolder(CFG.folder) then
                for _, f in pairs(listfiles(CFG.folder)) do
                    local n = tostring(f):match("([^/\\]+)%.json$")
                    if n then t[#t + 1] = n end
                end
            end
        end)
        table.sort(t)
        return t
    end

    local function colorToTable(c)
        if typeof(c) ~= "Color3" then return {255, 255, 255} end
        return {
            math.floor(c.R * 255 + 0.5),
            math.floor(c.G * 255 + 0.5),
            math.floor(c.B * 255 + 0.5)
        }
    end

    local function tableToColor(t)
        if type(t) ~= "table" then return Color3.fromRGB(255, 255, 255) end
        return Color3.fromRGB(
            math.clamp(tonumber(t[1]) or 255, 0, 255),
            math.clamp(tonumber(t[2]) or 255, 0, 255),
            math.clamp(tonumber(t[3]) or 255, 0, 255)
        )
    end

    local function keyToString(k)
        local s = tostring(k or "")
        s = s:gsub("Enum%.KeyCode%.", ""):gsub("Enum%.UserInputType%.", "")
        return s
    end

    local function stringToKey(s)
        if type(s) ~= "string" or s == "" then return nil end
        local ok, k = pcall(function() return Enum.KeyCode[s] end)
        if ok and k then return k end
        local ok2, u = pcall(function() return Enum.UserInputType[s] end)
        if ok2 and u then return u end
        return nil
    end

    local function collect()
        local data = {
            version = 2,
            currentTheme = currentTheme,
            -- Aimbot
            silentAim = AA and AA.silentAim or false,
            wallhack = AA and AA.wallhack or false,
            aimLock = AA and AA.aimLock or false,
            triggerBot = AA and AA.triggerBot or false,
            aimLockKey = AA and keyToString(AA.aimLockKey) or "E",
            triggerBotKey = AA and keyToString(AA.triggerKey) or "Q",
            aimLockMode = AA and AA.aimLockMode or "toggle",
            triggerBotMode = AA and AA.triggerMode or "toggle",
            ignoreDead = AA and (AA.ignoreDead ~= false) or true,
            ignoreFriends = AA and AA.ignoreFriends or false,
            ignoreTeam = AA and AA.ignoreTeam or false,
            ignoreNames = AA and AA.ignoreNames or "",
            fov = AA and AA.fov or 120,
            targetPart = AA and AA.targetPart or "Head",
            lockMethod = AA and AA.lockMethod or "Camera",
            prediction = AA and AA.prediction or false,
            predictionAmount = AA and AA.predictionAmount or 0.12,
            -- ESP
            espEnabled = espEnabled and true or false,
            espShowNames = espShowNames and true or false,
            espShowChams = espShowChams and true or false,
            espShowBoxes = espShowBoxes and true or false,
            espShowInventory = espShowInventory and true or false,
            espShowHealth = espShowHealth and true or false,
            espMaxDistance = espMaxDistance or 5000,
            espUseCustomColor = espUseCustomColor and true or false,
            espUseTeamColor = espUseTeamColor and true or false,
            espUseFriendColor = espUseFriendColor and true or false,
            espCustomColor = colorToTable(espCustomColor),
            espFriendColor = colorToTable(espFriendColor),
            -- Movement
            walkSpeed = movementWalkSpeed or 16,
            jumpPower = movementJumpPower or 50,
            gravity = movementGravity or workspace.Gravity,
            infiniteJump = infiniteJumpEnabled and true or false,
            noclip = noclipEnabled and true or false,
            clickTP = clickTPEnabled and true or false,
            antiAFK = antiAFKEnabled and true or false,
            antiVoid = antiVoidEnabled and true or false,
            -- Keys
            menuToggleKey = keyToString(menuToggleKey),
            espToggleKey = keyToString(espToggleKey),
            -- Fullbright
            fullbright = fullbrightEnabled and true or false,
        }
        return data
    end

    local function applyESPFlags(data)
        if data.espShowNames ~= nil then espShowNames = data.espShowNames and true or false end
        if data.espShowChams ~= nil then espShowChams = data.espShowChams and true or false end
        if data.espShowBoxes ~= nil then espShowBoxes = data.espShowBoxes and true or false end
        if data.espShowInventory ~= nil then espShowInventory = data.espShowInventory and true or false end
        if data.espShowHealth ~= nil then espShowHealth = data.espShowHealth and true or false end
        if data.espMaxDistance then espMaxDistance = tonumber(data.espMaxDistance) or espMaxDistance end
        if data.espUseCustomColor ~= nil then espUseCustomColor = data.espUseCustomColor and true or false end
        if data.espUseTeamColor ~= nil then espUseTeamColor = data.espUseTeamColor and true or false end
        if data.espUseFriendColor ~= nil then espUseFriendColor = data.espUseFriendColor and true or false end
        if data.espCustomColor then espCustomColor = tableToColor(data.espCustomColor) end
        if data.espFriendColor then espFriendColor = tableToColor(data.espFriendColor) end

        if updateESPUIs then
            pcall(function()
                if updateESPUIs.names then updateESPUIs.names(espShowNames) end
                if updateESPUIs.chams then updateESPUIs.chams(espShowChams) end
                if updateESPUIs.kutu then updateESPUIs.kutu(espShowBoxes) end
                if updateESPUIs.env then updateESPUIs.env(espShowInventory) end
                if updateESPUIs.health then updateESPUIs.health(espShowHealth) end
                if updateESPUIs.customColor then updateESPUIs.customColor(espUseCustomColor) end
                if updateESPUIs.teamColor then updateESPUIs.teamColor(espUseTeamColor) end
                if updateESPUIs.friend then updateESPUIs.friend(espUseFriendColor) end
                if updateESPUIs.master then updateESPUIs.master(espEnabled) end
            end)
        end
    end

    local function apply(data)
        if type(data) ~= "table" then return false end

        -- Aimbot
        if AA then
            AA.silentAim = data.silentAim and true or false
            AA.wallhack = data.wallhack and true or false
            AA.aimLock = data.aimLock and true or false
            AA.triggerBot = data.triggerBot and true or false
            AA.aimLockMode = data.aimLockMode or AA.aimLockMode or "toggle"
            AA.triggerMode = data.triggerBotMode or AA.triggerMode or "toggle"
            AA.ignoreDead = data.ignoreDead ~= false
            AA.ignoreFriends = data.ignoreFriends and true or false
            AA.ignoreTeam = data.ignoreTeam and true or false
            AA.ignoreNames = data.ignoreNames or ""
            if data.fov then AA.fov = tonumber(data.fov) or AA.fov end
            AA.targetPart = data.targetPart or AA.targetPart or "Head"
            AA.lockMethod = data.lockMethod or AA.lockMethod or "Camera"
            if data.prediction ~= nil then AA.prediction = data.prediction and true or false end
            if data.predictionAmount then AA.predictionAmount = tonumber(data.predictionAmount) or AA.predictionAmount end
            local alk = stringToKey(data.aimLockKey)
            if alk then AA.aimLockKey = alk end
            local tbk = stringToKey(data.triggerBotKey)
            if tbk then AA.triggerKey = tbk end
            pcall(function()
                if AA.silentAim or AA.wallhack then
                    if AA.setupSilent then AA.setupSilent() end
                end
                if AA.startLoop and (AA.aimLock or AA.triggerBot or AA.silentAim) then
                    AA.startLoop()
                end
            end)
        end

        -- Theme
        if data.currentTheme and themeData[data.currentTheme] then
            pcall(function() applyTheme(data.currentTheme) end)
        end

        -- Movement
        if data.walkSpeed then pcall(function() setWalkSpeed(tonumber(data.walkSpeed) or 16) end) end
        if data.jumpPower then pcall(function() setJumpPower(tonumber(data.jumpPower) or 50) end) end
        if data.gravity then pcall(function() setGravity(tonumber(data.gravity) or workspace.Gravity) end) end
        if data.infiniteJump ~= nil then pcall(function() toggleInfiniteJump(data.infiniteJump and true or false) end) end
        if data.noclip ~= nil then pcall(function() toggleNoclip(data.noclip and true or false) end) end
        if data.clickTP ~= nil then clickTPEnabled = data.clickTP and true or false end
        if data.antiAFK ~= nil then pcall(function() toggleAntiAFK(data.antiAFK and true or false) end) end
        if data.antiVoid ~= nil then
            antiVoidEnabled = data.antiVoid and true or false
            if antiVoidEnabled then pcall(startAntiVoid) else pcall(stopAntiVoid) end
        end

        -- Keys
        local mk = stringToKey(data.menuToggleKey)
        if mk then menuToggleKey = mk end
        local ek = stringToKey(data.espToggleKey)
        if ek then espToggleKey = ek end

        -- Fullbright
        if data.fullbright ~= nil then
            local want = data.fullbright and true or false
            if fullbrightEnabled ~= want then
                local fakeBtn = {Text = ""}
                pcall(function() runFullbright(fakeBtn) end)
            end
        end

        -- ESP flags first, then master toggle
        applyESPFlags(data)

        if data.espEnabled ~= nil then
            local wantEsp = data.espEnabled and true or false
            if wantEsp and not espEnabled then
                -- mirror keybind path: turn on
                espEnabled = true
                if updateESPUIs and updateESPUIs.master then pcall(updateESPUIs.master, true) end
                pcall(function()
                    for _, conn in pairs(espConnections) do if conn then conn:Disconnect() end end
                    espConnections = {}
                    local function setupForPlayer(p)
                        if p == player then return end
                        table.insert(espConnections, p.CharacterAdded:Connect(function(char)
                            local root = char:WaitForChild("HumanoidRootPart", 10)
                            if root and espEnabled then buildESP(p) end
                        end))
                        if p.Character then pcall(function() buildESP(p) end) end
                    end
                    for _, p in pairs(Players:GetPlayers()) do setupForPlayer(p) end
                    table.insert(espConnections, Players.PlayerAdded:Connect(setupForPlayer))
                    table.insert(espConnections, Players.PlayerRemoving:Connect(function(p)
                        if espObjects[p] then
                            if espObjects[p].box then pcall(game.Destroy, espObjects[p].box) end
                            if espObjects[p].billboard then pcall(game.Destroy, espObjects[p].billboard) end
                            if espObjects[p].highlight then pcall(game.Destroy, espObjects[p].highlight) end
                            espObjects[p] = nil
                        end
                    end))
                    if not espLoopThread then
                        espLoopThread = task.spawn(function()
                            local refreshTimer = 0
                            while espEnabled do
                                pcall(updateAllESP)
                                refreshTimer = refreshTimer + 0.2
                                if refreshTimer >= 30 then refreshTimer = 0; clearESP() end
                                task.wait(0.2)
                            end
                        end)
                    end
                end)
            elseif not wantEsp and espEnabled then
                espEnabled = false
                pcall(clearESP)
                if espLoopThread then pcall(function() task.cancel(espLoopThread) end); espLoopThread = nil end
                for _, conn in pairs(espConnections) do if conn then pcall(function() conn:Disconnect() end) end end
                espConnections = {}
                if updateESPUIs and updateESPUIs.master then pcall(updateESPUIs.master, false) end
            end
        end

        return true
    end

    local function save(name)
        name = sanitizeName(name or CFG.current)
        ensure()
        local payload = collect()
        local ok, err = pcall(function()
            if type(writefile) ~= "function" then error("writefile yok") end
            writefile(path(name), HttpService:JSONEncode(payload))
            writefile(CFG.settings, HttpService:JSONEncode({lastConfig = name, version = 2}))
        end)
        if ok then
            CFG.current = name
            return true, name
        end
        return false, tostring(err)
    end

    local function load(name)
        name = sanitizeName(name or CFG.current)
        local ok, data = pcall(function()
            if type(isfile) == "function" and isfile(path(name)) then
                return HttpService:JSONDecode(readfile(path(name)))
            end
            return nil
        end)
        if not ok or type(data) ~= "table" then
            return false, "dosya yok veya bozuk"
        end
        local aok = apply(data)
        if aok then
            CFG.current = name
            pcall(function()
                if type(writefile) == "function" then
                    writefile(CFG.settings, HttpService:JSONEncode({lastConfig = name, version = 2}))
                end
            end)
            return true, name
        end
        return false, "apply başarısız"
    end

    local function delete(name)
        name = sanitizeName(name)
        local ok = pcall(function()
            if type(isfile) == "function" and type(delfile) == "function" and isfile(path(name)) then
                delfile(path(name))
            end
        end)
        if CFG.current == name then CFG.current = "default" end
        return ok
    end

    -- autoload last
    task.spawn(function()
        task.wait(0.6)
        pcall(function()
            if type(isfile) == "function" and isfile(CFG.settings) then
                local meta = HttpService:JSONDecode(readfile(CFG.settings))
                if meta and meta.lastConfig then
                    load(meta.lastConfig)
                end
            end
        end)
    end)

    AddLabel(tabSettings, "AWD Config Manager")
    local statusLabel = AddLabel(tabSettings, "Durum: hazır | Aktif: " .. CFG.current, true)
    local nameBox = AddTextBox(tabSettings, "Config adı (default)", function() end)
    nameBox.Text = CFG.current
    local listLabel = AddLabel(tabSettings, "Kayıtlı: " .. table.concat(list(), ", "))

    local function refreshListUI()
        local names = list()
        listLabel.Text = (#names > 0) and ("Kayıtlı: " .. table.concat(names, ", ")) or "Kayıtlı: (yok)"
        statusLabel.Text = "Durum: hazır | Aktif: " .. tostring(CFG.current)
        for _, child in pairs(tabSettings:GetChildren()) do
            if child.Name == "AnanistanConfigSelectEntry" then child:Destroy() end
        end
        for _, name in ipairs(names) do
            local isActive = (name == CFG.current)
            local entry = Instance.new("Frame")
            entry.Name = "AnanistanConfigSelectEntry"
            entry.Size = UDim2.new(1, -10, 0, 42)
            entry.BackgroundColor3 = isActive and Color3.fromRGB(40, 70, 50) or Color3.fromRGB(32, 32, 45)
            entry.BorderSizePixel = 0
            entry.ZIndex = 5
            entry.Parent = tabSettings
            registerObj(entry, "ButtonBG")
            Instance.new("UICorner", entry).CornerRadius = UDim.new(0, 8)

            local accent = Instance.new("Frame")
            accent.Size = UDim2.new(0, 3, 1, -10)
            accent.Position = UDim2.new(0, 6, 0, 5)
            accent.BackgroundColor3 = isActive and Color3.fromRGB(80, 220, 120) or Color3.fromRGB(90, 90, 120)
            accent.BorderSizePixel = 0
            accent.ZIndex = 6
            accent.Parent = entry
            Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)
            registerObj(accent, "Accent")

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Size = UDim2.new(0.45, 0, 1, 0)
            nameLbl.Position = UDim2.new(0, 16, 0, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Font = Enum.Font.GothamBold
            nameLbl.TextSize = 13
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.TextColor3 = Color3.fromRGB(230, 230, 245)
            nameLbl.Text = (isActive and "● " or "○ ") .. name
            nameLbl.ZIndex = 6
            nameLbl.Parent = entry
            registerObj(nameLbl, "Text")

            local loadBtn = Instance.new("TextButton")
            loadBtn.Size = UDim2.new(0, 70, 0, 28)
            loadBtn.Position = UDim2.new(1, -160, 0.5, -14)
            loadBtn.BackgroundColor3 = Color3.fromRGB(50, 140, 70)
            loadBtn.Text = "Yükle"
            loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            loadBtn.Font = Enum.Font.GothamBold
            loadBtn.TextSize = 12
            loadBtn.ZIndex = 7
            loadBtn.Parent = entry
            Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0, 6)

            local delBtn = Instance.new("TextButton")
            delBtn.Size = UDim2.new(0, 70, 0, 28)
            delBtn.Position = UDim2.new(1, -82, 0.5, -14)
            delBtn.BackgroundColor3 = Color3.fromRGB(160, 50, 50)
            delBtn.Text = "Sil"
            delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            delBtn.Font = Enum.Font.GothamBold
            delBtn.TextSize = 12
            delBtn.ZIndex = 7
            delBtn.Parent = entry
            Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 6)

            -- select on row click
            local hit = Instance.new("TextButton")
            hit.Size = UDim2.new(0.45, 0, 1, 0)
            hit.BackgroundTransparency = 1
            hit.Text = ""
            hit.ZIndex = 7
            hit.Parent = entry
            hit.MouseButton1Click:Connect(function()
                nameBox.Text = name
                statusLabel.Text = "Durum: seçildi | " .. name
            end)

            loadBtn.MouseButton1Click:Connect(function()
                nameBox.Text = name
                local ok, msg = load(name)
                if ok then
                    statusLabel.Text = "Durum: yüklendi | Aktif: " .. name
                    notify("AWD Config", "Yüklendi: " .. name, 3)
                else
                    statusLabel.Text = "Durum: yükleme hatası | " .. tostring(msg)
                    notify("AWD Config", "Yüklenemedi: " .. tostring(msg), 4)
                end
                refreshListUI()
            end)

            delBtn.MouseButton1Click:Connect(function()
                delete(name)
                statusLabel.Text = "Durum: silindi | " .. name
                notify("AWD Config", "Silindi: " .. name, 3)
                if CFG.current == name then nameBox.Text = "default" end
                refreshListUI()
            end)
        end
    end

    AddButton(tabSettings, "Kaydet", function()
        local name = sanitizeName(nameBox.Text)
        nameBox.Text = name
        local ok, msg = save(name)
        if ok then
            statusLabel.Text = "Durum: kaydedildi | Aktif: " .. name
            notify("AWD Config", "Kaydedildi: " .. name, 3)
        else
            statusLabel.Text = "Durum: kayıt hatası | " .. tostring(msg)
            notify("AWD Config", "Kaydedilemedi: " .. tostring(msg), 4)
        end
        refreshListUI()
    end)

    AddButton(tabSettings, "Yükle", function()
        local name = sanitizeName(nameBox.Text)
        nameBox.Text = name
        local ok, msg = load(name)
        if ok then
            statusLabel.Text = "Durum: yüklendi | Aktif: " .. name
            notify("AWD Config", "Yüklendi: " .. name, 3)
        else
            statusLabel.Text = "Durum: yükleme hatası | " .. tostring(msg)
            notify("AWD Config", "Yüklenemedi: " .. tostring(msg), 4)
        end
        refreshListUI()
    end)

    AddButton(tabSettings, "Sil", function()
        local name = sanitizeName(nameBox.Text)
        if name == "" then return end
        delete(name)
        statusLabel.Text = "Durum: silindi | " .. name
        notify("AWD Config", "Silindi: " .. name, 3)
        if CFG.current == name then
            nameBox.Text = "default"
        end
        refreshListUI()
    end)

    AddButton(tabSettings, "Listeyi Yenile", function()
        refreshListUI()
        notify("AWD Config", "Liste yenilendi", 2)
    end)

    AddLabel(tabSettings, "Kayıtlı Configler (tıkla = yükle)")
    refreshListUI()

    AddLabel(tabSettings, "Auto Execute")
    AddToggle(tabSettings, "Executor Açılınca Hub Otomatik Çalışsın", false, function(state)
        if state then
            pcall(function()
                if type(makefolder) == "function" then pcall(function() makefolder("autoexec") end) end
                if type(writefile) == "function" then
                    writefile(CFG.autoexec, _G.ananistwaffendivisionReloadSource or "-- AWD Hub AutoExec")
                end
            end)
            notify("AWD AutoExec", "Aktif", 3)
        else
            pcall(function()
                if type(isfile) == "function" and type(delfile) == "function" and isfile(CFG.autoexec) then
                    delfile(CFG.autoexec)
                end
            end)
            notify("AWD AutoExec", "Kapatıldı", 3)
        end
    end)

    AddLabel(tabSettings, "Ekstra")
    AddButton(tabSettings, "Tüm Aimbot + ESP Kapat", function()
        if AA then
            AA.silentAim = false
            AA.wallhack = false
            AA.aimLock = false
            AA.triggerBot = false
            if AA.hold then
                AA.hold.aimLock = false
                AA.hold.triggerBot = false
            end
            if AA.stopLoop then pcall(AA.stopLoop) end
        end
        espEnabled = false
        pcall(clearESP)
        if espLoopThread then pcall(function() task.cancel(espLoopThread) end); espLoopThread = nil end
        notify("AWD Menu", "Aimbot + ESP kapatıldı", 3)
    end)

    AddButton(tabSettings, "FPS Göster", function()
        if _G.AnanistanFPS then
            pcall(function() _G.AnanistanFPS:Destroy() end)
            _G.AnanistanFPS = nil
            return
        end
        local gui = Instance.new("ScreenGui")
        gui.Name = "AnanistanFPS"
        gui.ResetOnSpawn = false
        gui.Parent = CoreGui
        _G.AnanistanFPS = gui
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0, 180, 0, 40)
        lbl.Position = UDim2.new(1, -190, 0, 10)
        lbl.BackgroundTransparency = 0.4
        lbl.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        lbl.TextColor3 = Color3.fromRGB(0, 255, 120)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 14
        lbl.Text = "FPS: --"
        lbl.Parent = gui
        Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 6)
        local last, frames = tick(), 0
        RunService.RenderStepped:Connect(function()
            if not gui.Parent then return end
            frames = frames + 1
            if tick() - last >= 1 then
                lbl.Text = string.format("FPS: %d", frames)
                frames = 0
                last = tick()
            end
        end)
    end)
end


-- [[ ϟϟ YENİ SÜPER ÖZELLEŞTİRİLEBİLİR DİZAYN (CUSTOM DESIGNER) SEKMESİ ϟϟ ]] --
AddLabel(tabDesigner, "Kendi Temanı Yarat (Real-Time)")
menuKeyBtn = AddButton(tabDesigner, "Menü Aç/Kapat: [Insert]", function() end)
menuKeyLabel = menuKeyBtn:FindFirstChildOfClass("TextLabel")
menuKeyBtn.MouseButton1Click:Connect(function()
    if settingMenuKey or settingESPKey then return end
    settingMenuKey = true
    if menuKeyLabel then menuKeyLabel.Text = " Menü Tuşu: Tuşa bas..." end
    local conn
    conn = UIS.InputBegan:Connect(function(inp, gp)
        if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if gp then return end
        menuToggleKey = inp.KeyCode
        local keyName = tostring(inp.KeyCode):gsub("Enum.KeyCode.", "")
        if menuKeyLabel then menuKeyLabel.Text = " Menü Aç/Kapat: [" .. keyName .. "]" end
        settingMenuKey = false
        conn:Disconnect()
    end)
end)

-- [[ SCRIPT ISMINI DEGISME ]] --
AddLabel(tabDesigner, "Script Başlığı Değiştir")
AddTextBox(tabDesigner, "Örn: Ananistan Hub v3...", function(text)
    if text ~= "" then
        title.Text = text
    end
end)

-- [[ RESİM & BULANIKLIK YÖNETİCİSİ AYARLARI ]] --
AddLabel(tabDesigner, "Menü Arkaplan Resmi")

-- URL ile Arkaplan Resmi Yükleyici
AddTextBox(tabDesigner, "Görsel URL veya AssetID girin...", function(url)
    pcall(function()
        if url == "" then
            bgImageLabel.Image = ""
            bgImageLabel.ImageTransparency = 1
            themeData["Custom Designer"].BGImage = ""
            themeData["Custom Designer"].BGImageTrans = 1
        else
            -- Decal ID'lerini de Image ID'ye dönüştürmek için rbxthumb API entegrasyonu yapıldı
            local cleanId = url:match("%d+")
            local finalImage = ""
            if cleanId then
                finalImage = "rbxthumb://type=Asset&id=" .. cleanId .. "&w=768&h=432"
            else
                finalImage = url
            end
            bgImageLabel.Image = finalImage
            bgImageLabel.ImageTransparency = 0.3
            themeData["Custom Designer"].BGImage = finalImage
            themeData["Custom Designer"].BGImageTrans = 0.3
        end
    end)
end)

-- Arkaplan Opaklığı (Resmin Saydamlığı)
AddSlider(tabDesigner, "Resim Belirginliği (Opaklık)", 0, 100, 30, function(val)
    pcall(function()
        local trans = (100 - val) / 100
        bgImageLabel.ImageTransparency = trans
        themeData["Custom Designer"].BGImageTrans = trans
    end)
end)

-- Bulanıklık Yumuşatma Kontrolü
AddSlider(tabDesigner, "Resim Bulanıklığı (Blur Maske)", 0, 100, 0, function(val)
    pcall(function()
        local trans = (100 - val) / 100
        blurOverlay.BackgroundTransparency = trans
        themeData["Custom Designer"].BlurTrans = trans
    end)
end)

-- 1. Arkaplan Rengi (MainBG)
AddColorPicker(tabDesigner, "Ana Arkaplan Rengi", themeData["Custom Designer"].MainBG, function(col)
    themeData["Custom Designer"].MainBG = col
    applyTheme("Custom Designer")
end)

-- 2. Topbar Rengi (TopbarBG)
AddColorPicker(tabDesigner, "Üst Bar (Topbar) Rengi", themeData["Custom Designer"].TopbarBG, function(col)
    themeData["Custom Designer"].TopbarBG = col
    applyTheme("Custom Designer")
end)

-- 3. Buton Rengi (ButtonBG)
AddColorPicker(tabDesigner, "Buton ve Panel Rengi", themeData["Custom Designer"].ButtonBG, function(col)
    themeData["Custom Designer"].ButtonBG = col
    themeData["Custom Designer"].UnselectedTabBtn = Color3.fromRGB(math.clamp(col.R*255-15,0,255), math.clamp(col.G*255-15,0,255), math.clamp(col.B*255-15,0,255))
    applyTheme("Custom Designer")
end)

-- 4. Accent/Vurgu Rengi (Çizgiler, Aktif Slider'lar, Aktif Toggle'lar)
AddColorPicker(tabDesigner, "Vurgu (Accent) Rengi", themeData["Custom Designer"].Accent, function(col)
    themeData["Custom Designer"].Accent = col
    applyTheme("Custom Designer")
end)

-- 5. Yazı Rengi (Text)
AddColorPicker(tabDesigner, "Yazı (Text) Rengi", themeData["Custom Designer"].Text, function(col)
    themeData["Custom Designer"].Text = col
    applyTheme("Custom Designer")
end)

-- 6. Arkaplan Saydamlığı (MainTrans)
AddSlider(tabDesigner, "Panel Saydamlığı (Opacity)", 0, 100, 10, function(val)
    themeData["Custom Designer"].MainTrans = val / 100
    themeData["Custom Designer"].TopbarTrans = math.clamp((val / 100) + 0.05, 0, 1)
    applyTheme("Custom Designer")
end)

-- 7. Buton Saydamlığı (ButtonTrans)
AddSlider(tabDesigner, "Buton Saydamlığı (Opacity)", 0, 100, 0, function(val)
    themeData["Custom Designer"].ButtonTrans = val / 100
    applyTheme("Custom Designer")
end)

-- 8. Menü Köşe Yuvarlaklığı (UICorner Radius)
AddSlider(tabDesigner, "Köşe Yuvarlaklığı (Corner)", 0, 50, 22, function(val)
    corner.CornerRadius = UDim.new(0, val)
    topCorner.CornerRadius = UDim.new(0, val)
    imgCorner.CornerRadius = UDim.new(0, val)
    overlayCorner.CornerRadius = UDim.new(0, val)
end)

-- 9. Menü Boyut Ayarlayıcıları (Genişlik & Yükseklik)
AddSlider(tabDesigner, "Menü Genişliği (Width)", 400, 1000, 800, function(val)
    mainFrame.Size = UDim2.new(0, val, 0, mainFrame.Size.Y.Offset)
    updateBlur()
end)

AddSlider(tabDesigner, "Menü Yüksekliği (Height)", 350, 800, 480, function(val)
    mainFrame.Size = UDim2.new(0, mainFrame.Size.X.Offset, 0, val)
    contentArea.Size = UDim2.new(1, -20, 1, -110)
    updateBlur()
end)

AddButton(tabDesigner, "Tasarladığım Temayı Uygula", function()
    applyTheme("Custom Designer")
end)

-- [[ ϟϟ TEMA SLOTLARI YÖNETİMİ (PERSISTENT / HARD SAVE) ϟϟ ]] --

slotsData = {}

function saveSlotsToFile()
    if writefile then
        pcall(function()
            writefile("ananite_hub_slots.json", HttpService:JSONEncode(slotsData))
        end)
    end
end

function loadSlotsFromFile()
    if isfile and isfile("ananite_hub_slots.json") then
        local ok, res = pcall(function()
            return HttpService:JSONDecode(readfile("ananite_hub_slots.json"))
        end)
        if ok and type(res) == "table" then
            return res
        end
    end
    return {}
end

slotsData = loadSlotsFromFile()

-- Dynamic Slot Çizici
function rebuildSlotsUI()
    -- Mevcut dinamik slot kutularını temizle
    for _, child in pairs(tabSlots:GetChildren()) do
        if child:IsA("Frame") and child.Name == "SlotEntry" then
            child:Destroy()
        end
    end

    for slotName, data in pairs(slotsData) do
        local entry = Instance.new("Frame", tabSlots)
        entry.Name = "SlotEntry"
        entry.Size = UDim2.new(1, -10, 0, 45)
        entry.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        entry.ZIndex = 5
        registerObj(entry, "ButtonBG")
        
        local entryCorner = Instance.new("UICorner", entry)
        entryCorner.CornerRadius = UDim.new(0, 8)

        local label = Instance.new("TextLabel", entry)
        label.Size = UDim2.new(0.5, 0, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = slotName
        label.TextColor3 = Color3.fromRGB(220, 220, 240)
        label.TextSize = 13
        label.Font = Enum.Font.GothamMedium
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 6
        registerObj(label, "Text")

        -- YÜKLE BUTONU
        local loadBtn = Instance.new("TextButton", entry)
        loadBtn.Size = UDim2.new(0.2, -5, 0, 30)
        loadBtn.Position = UDim2.new(0.6, 0, 0.5, -15)
        loadBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        loadBtn.Text = "Yükle"
        loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        loadBtn.Font = Enum.Font.GothamBold
        loadBtn.TextSize = 11
        loadBtn.ZIndex = 6
        local loadBtnCorner = Instance.new("UICorner", loadBtn)
        loadBtnCorner.CornerRadius = UDim.new(0, 6)

        loadBtn.MouseButton1Click:Connect(function()
            pcall(function()
                if data.TitleText then title.Text = data.TitleText end
                
                themeData["Custom Designer"] = {
                    MainBG = Color3.fromRGB(data.MainBG[1], data.MainBG[2], data.MainBG[3]),
                    TopbarBG = Color3.fromRGB(data.TopbarBG[1], data.TopbarBG[2], data.TopbarBG[3]),
                    ButtonBG = Color3.fromRGB(data.ButtonBG[1], data.ButtonBG[2], data.ButtonBG[3]),
                    Accent = Color3.fromRGB(data.Accent[1], data.Accent[2], data.Accent[3]),
                    Text = Color3.fromRGB(data.Text[1], data.Text[2], data.Text[3]),
                    UnselectedTabBtn = Color3.fromRGB(
                        math.clamp(data.ButtonBG[1]-15, 0, 255),
                        math.clamp(data.ButtonBG[2]-15, 0, 255),
                        math.clamp(data.ButtonBG[3]-15, 0, 255)
                    ),
                    MainTrans = data.MainTrans or 0.1,
                    ButtonTrans = data.ButtonTrans or 0,
                    BGImage = data.BGImage or "",
                    BGImageTrans = data.BGImageTrans or 1,
                    BlurTrans = data.BlurTrans or 1
                }
                
                -- Görsel verilerini direkt olarak elementlere geçir
                bgImageLabel.Image = themeData["Custom Designer"].BGImage
                bgImageLabel.ImageTransparency = themeData["Custom Designer"].BGImageTrans
                blurOverlay.BackgroundTransparency = themeData["Custom Designer"].BlurTrans
                
                if data.CornerRadius then
                    local r = data.CornerRadius
                    corner.CornerRadius = UDim.new(0, r)
                    topCorner.CornerRadius = UDim.new(0, r)
                    imgCorner.CornerRadius = UDim.new(0, r)
                    overlayCorner.CornerRadius = UDim.new(0, r)
                end
                if data.Width and data.Height then
                    mainFrame.Size = UDim2.new(0, data.Width, 0, data.Height)
                    contentArea.Size = UDim2.new(1, -20, 1, -110)
                    updateBlur()
                end
                
                applyTheme("Custom Designer")
            end)
        end)

        -- SİL BUTONU
        local deleteBtn = Instance.new("TextButton", entry)
        deleteBtn.Size = UDim2.new(0.2, -5, 0, 30)
        deleteBtn.Position = UDim2.new(0.8, 5, 0.5, -15)
        deleteBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        deleteBtn.Text = "Sil"
        deleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        deleteBtn.Font = Enum.Font.GothamBold
        deleteBtn.TextSize = 11
        deleteBtn.ZIndex = 6
        local deleteBtnCorner = Instance.new("UICorner", deleteBtn)
        deleteBtnCorner.CornerRadius = UDim.new(0, 6)

        deleteBtn.MouseButton1Click:Connect(function()
            slotsData[slotName] = nil
            saveSlotsToFile()
            rebuildSlotsUI()
        end)
    end
end

-- Slotlar Tabının UI Elemanları
AddLabel(tabSlots, "Tasarımı Kaydet")
slotNameInput = AddTextBox(tabSlots, "Yeni Slot Adı Yaz...", function() end)

AddButton(tabSlots, "Şu Anki Tasarımı Bu Slota Kaydet", function()
    local name = slotNameInput.Text
    if name == "" then return end
    
    -- O anki aktif temanın verilerini al (Böylece preset temalarda görsel ekleyip kaydettiğinde de çalışır)
    local activeThemeData = themeData[currentTheme] or themeData["Custom Designer"]
    local mainBG_C = activeThemeData.MainBG
    local topbarBG_C = activeThemeData.TopbarBG
    local buttonBG_C = activeThemeData.ButtonBG
    local accent_C = activeThemeData.Accent
    local text_C = activeThemeData.Text
    
    slotsData[name] = {
        TitleText = title.Text,
        MainBG = {math.floor(mainBG_C.R*255), math.floor(mainBG_C.G*255), math.floor(mainBG_C.B*255)},
        TopbarBG = {math.floor(topbarBG_C.R*255), math.floor(topbarBG_C.G*255), math.floor(topbarBG_C.B*255)},
        ButtonBG = {math.floor(buttonBG_C.R*255), math.floor(buttonBG_C.G*255), math.floor(buttonBG_C.B*255)},
        Accent = {math.floor(accent_C.R*255), math.floor(accent_C.G*255), math.floor(accent_C.B*255)},
        Text = {math.floor(text_C.R*255), math.floor(text_C.G*255), math.floor(text_C.B*255)},
        MainTrans = activeThemeData.MainTrans,
        ButtonTrans = activeThemeData.ButtonTrans,
        BGImage = bgImageLabel.Image,
        BGImageTrans = bgImageLabel.ImageTransparency,
        BlurTrans = blurOverlay.BackgroundTransparency,
        CornerRadius = corner.CornerRadius.Offset,
        Width = mainFrame.Size.X.Offset,
        Height = mainFrame.Size.Y.Offset
    }
    
    saveSlotsToFile()
    rebuildSlotsUI()
    slotNameInput.Text = "" -- Giriş alanını temizle
end)

AddLabel(tabSlots, "Kayıtlı Profil Slotların")
rebuildSlotsUI() -- İlk açılışta dosyadan yüklenenleri listele

-- Ulaşım
AddLabel(tabUlasim, "Konumum")
coordLabel = AddLabel(tabUlasim, "X: 0  Y: 0  Z: 0")
RunService.Heartbeat:Connect(function()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root and coordLabel then
        local p = root.Position
        coordLabel.Text = string.format(" X: %.1f  Y: %.1f  Z: %.1f", p.X, p.Y, p.Z)
    end
end)

AddLabel(tabUlasim, "Koordinata Işınlan")
coordInputFrame = Instance.new("Frame", tabUlasim)
coordInputFrame.Size = UDim2.new(1, -10, 0, 35)
coordInputFrame.BackgroundTransparency = 1
coordInputFrame.ZIndex = 5

function CreateCoordBox(label, pos, parent)
    local l = Instance.new("TextLabel", parent)
    l.Size = UDim2.new(0, 20, 1, 0)
    l.Position = pos
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = Color3.fromRGB(220, 220, 240)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 14
    l.ZIndex = 6
    registerObj(l, "Text")
    
    local b = AddTextBox(parent, "0", function() end)
    b.Size = UDim2.new(0.25, 0, 1, 0)
    b.Position = pos + UDim2.new(0, 20, 0, 0)
    b.Text = "0"
    b.ZIndex = 6
    return b
end

xBox = CreateCoordBox("X:", UDim2.new(0, 0, 0, 0), coordInputFrame)
yBox = CreateCoordBox("Y:", UDim2.new(0.33, 0, 0, 0), coordInputFrame)
zBox = CreateCoordBox("Z:", UDim2.new(0.66, 0, 0, 0), coordInputFrame)

AddButton(tabUlasim, "Işınlan (Koordinat)", function()
    local x = tonumber(xBox.Text)
    local y = tonumber(yBox.Text)
    local z = tonumber(zBox.Text)
    if x and y and z then
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(x, y, z)
        end
    end
end)

AddLabel(tabUlasim, "Oyuncuya Işınlan")
AddButton(tabUlasim, "Oyuncu Seç & Işınlan", function()
    local plrs = Players:GetPlayers()
    local choices = {}
    for _, p2 in pairs(plrs) do
        if p2 ~= player then
            table.insert(choices, p2.Name)
        end
    end
    if #choices == 0 then return end
    local target = Players:FindFirstChild(choices[1])
    if target and target.Character then
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
        if root and tRoot then
            root.CFrame = tRoot.CFrame + Vector3.new(0, 3, 0)
        end
    end
end)

tpPlayerBox = AddTextBox(tabUlasim, "Oyuncu İsmi Yaz", function() end)
AddButton(tabUlasim, "İsme Göre Işınlan", function()
    local name = tpPlayerBox.Text
    local target = Players:FindFirstChild(name)
    if target and target.Character then
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
        if root and tRoot then
            root.CFrame = tRoot.CFrame + Vector3.new(0, 3, 0)
        end
    end
end)

-- [[ WORKSPACE EXPLORER - STUDIO / LAZY / LOW DROP ]] 
AddLabel(tabStudio, "Workspace Explorer")
workspaceSelectedLabel = AddLabel(tabStudio, "Seçili: Yok")
workspaceExplorerSearch = AddTextBox(tabStudio, "Workspace içinde ara...", function() end)

explorerScroll = Instance.new("ScrollingFrame", tabStudio)
explorerScroll.Size = UDim2.new(1, -10, 0, 180)
explorerScroll.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
explorerScroll.BorderSizePixel = 0
explorerScroll.ScrollBarThickness = 5
explorerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
explorerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
explorerScroll.ZIndex = 5
registerObj(explorerScroll, "ButtonBG")
explorerCorner = Instance.new("UICorner", explorerScroll)
explorerCorner.CornerRadius = UDim.new(0, 8)
explorerLayout = Instance.new("UIListLayout", explorerScroll)
explorerLayout.Padding = UDim.new(0, 2)

explorerLoaded = false
explorerExpanded = {}
explorerPageByParent = {}
EXPLORER_PAGE_SIZE = 50

function clearExplorer()
    for _, child in ipairs(explorerScroll:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
end

function unloadWorkspaceExplorer()
    explorerLoaded = false
    explorerExpanded = {}
    explorerPageByParent = {}
    clearExplorer()
    workspaceSelectedLabel.Text = "Seçili: Yok"
    selectedWorkspaceObject = nil
    pcall(function()
        if _G.ananistwaffendivisionClearWorkspaceESP then _G.ananistwaffendivisionClearWorkspaceESP() end
    end)
end

function getExplorerMatch(instance, query)
    if query == "" then return true end
    local lowerQuery = string.lower(query)
    return string.find(string.lower(instance.Name), lowerQuery, 1, true) ~= nil
        or string.find(string.lower(instance.ClassName), lowerQuery, 1, true) ~= nil
end

function collapseExplorerExcept(target)
    local keep = {}
    local current = target
    while current and current ~= workspace do
        keep[current] = true
        current = current.Parent
    end

    local nextState = {}
    local nextPages = {}
    for obj in pairs(keep) do
        nextState[obj] = explorerExpanded[obj]
        nextPages[obj] = explorerPageByParent[obj] or 1
    end
    explorerExpanded = nextState
    explorerPageByParent = nextPages
end

function buildExplorer()
    clearExplorer()
    explorerLoaded = true

    local query = workspaceExplorerSearch and workspaceExplorerSearch.Text or ""

    local function addNavButton(text, callback)
        local nav = Instance.new("TextButton")
        nav.Parent = explorerScroll
        nav.Size = UDim2.new(1, -6, 0, 28)
        nav.BackgroundTransparency = 0.15
        nav.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        nav.TextColor3 = Color3.fromRGB(230, 230, 240)
        nav.Font = Enum.Font.GothamBold
        nav.TextSize = 12
        nav.Text = text
        nav.ZIndex = 6
        local navCorner = Instance.new("UICorner", nav)
        navCorner.CornerRadius = UDim.new(0, 5)
        nav.MouseButton1Click:Connect(callback)
    end

    local function addItem(instance, depth)
        if not instance or not instance.Parent then return end
        if not getExplorerMatch(instance, query) then return end

        local children = instance:GetChildren()
        local hasChildren = #children > 0
        local expanded = explorerExpanded[instance] == true

        local row = Instance.new("TextButton")
        row.Parent = explorerScroll
        row.Size = UDim2.new(1, -6, 0, 28)
        row.BackgroundTransparency = 0.15
        row.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        row.TextColor3 = Color3.fromRGB(220, 220, 240)
        row.Font = Enum.Font.GothamMedium
        row.TextSize = 12
        row.TextXAlignment = Enum.TextXAlignment.Left
        row.Text = string.rep("   ", depth) .. (hasChildren and (expanded and "v " or "> ") or "• ") .. instance.Name .. "  [" .. instance.ClassName .. "]"
        row.ZIndex = 6
        local rowCorner = Instance.new("UICorner", row)
        rowCorner.CornerRadius = UDim.new(0, 5)

        row.MouseButton1Click:Connect(function()
            selectedWorkspaceObject = instance
            workspaceSelectedLabel.Text = "Seçili: " .. instance:GetFullName()
            if hasChildren then
                collapseExplorerExcept(instance)
                explorerExpanded[instance] = not expanded
                if explorerExpanded[instance] then
                    explorerPageByParent[instance] = explorerPageByParent[instance] or 1
                end
                buildExplorer()
            end
        end)

        if expanded then
            local filteredChildren = {}
            for _, child in ipairs(children) do
                if getExplorerMatch(child, query) then
                    table.insert(filteredChildren, child)
                end
            end

            local page = explorerPageByParent[instance] or 1
            local totalPages = math.max(1, math.ceil(#filteredChildren / EXPLORER_PAGE_SIZE))
            page = math.clamp(page, 1, totalPages)
            explorerPageByParent[instance] = page

            local firstIndex = (page - 1) * EXPLORER_PAGE_SIZE + 1
            local lastIndex = math.min(firstIndex + EXPLORER_PAGE_SIZE - 1, #filteredChildren)

            for i = firstIndex, lastIndex do
                local childObj = filteredChildren[i]
                addItem(childObj, depth + 1)
            end

            if totalPages > 1 then
                local currentPage = page
                if currentPage > 1 then
                    addNavButton("< Önceki", function()
                        explorerPageByParent[instance] = currentPage - 1
                        buildExplorer()
                    end)
                end
                if currentPage < totalPages then
                    addNavButton("Sonraki >", function()
                        explorerPageByParent[instance] = currentPage + 1
                        buildExplorer()
                    end)
                end
                addNavButton("Sayfa " .. currentPage .. "/" .. totalPages .. "  |  " .. #filteredChildren .. " öğe", function() end)
            end
        end
    end

    local roots = workspace:GetChildren()
    for _, child in ipairs(roots) do
        addItem(child, 0)
    end
end

AddButton(tabStudio, "Workspace Yenile", buildExplorer)
AddButton(tabStudio, "Explorer'ı Unload", unloadWorkspaceExplorer)

-- [[ EK: WORKSPACE ESP ARA + SEÇİLİ OBJE ESP ]] --
_G.ananistwaffendivisionWorkspaceESPObjects = _G.ananistwaffendivisionWorkspaceESPObjects or {}
_G.ananistwaffendivisionWorkspaceNameESPHighlight = _G.ananistwaffendivisionWorkspaceNameESPHighlight or nil

_G.ananistwaffendivisionClearWorkspaceESP = function()
    if _G.ananistwaffendivisionWorkspaceESPObjects then
        for _, highlight in pairs(_G.ananistwaffendivisionWorkspaceESPObjects) do
            pcall(function()
                if highlight then highlight:Destroy() end
            end)
        end
    end
    _G.ananistwaffendivisionWorkspaceESPObjects = {}

    if _G.ananistwaffendivisionWorkspaceNameESPHighlight then
        pcall(function()
            _G.ananistwaffendivisionWorkspaceNameESPHighlight:Destroy()
        end)
    end
    _G.ananistwaffendivisionWorkspaceNameESPHighlight = nil
end

_G.ananistwaffendivisionAddWorkspaceESP = function(target)
    if not target or not target.Parent then return end

    if target:IsA("Model") or target:IsA("BasePart") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "WorkspaceTreeESP"
        highlight.Adornee = target
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = CoreGui
        table.insert(_G.ananistwaffendivisionWorkspaceESPObjects, highlight)
        return
    end

    if target:IsA("Folder") then
        local pending = {target}
        local processed = 0

        while #pending > 0 do
            local current = table.remove(pending)
            if current and current.Parent then
                for _, child in ipairs(current:GetChildren()) do
                    if child:IsA("Model") then
                        _G.ananistwaffendivisionAddWorkspaceESP(child)
                    elseif child:IsA("BasePart") then
                        _G.ananistwaffendivisionAddWorkspaceESP(child)
                    else
                        table.insert(pending, child)
                    end

                    processed = processed + 1
                    if processed % 40 == 0 then
                        task.wait()
                    end
                end
            end
        end
    end
end

_G.ananistwaffendivisionNameSearchWorkspaceESP = function(text)
    _G.ananistwaffendivisionClearWorkspaceESP()

    text = tostring(text or "")
    if text == "" then return end

    local target = workspace:FindFirstChild(text, true)
    if not target then return end

    if target:IsA("Folder") then
        _G.ananistwaffendivisionAddWorkspaceESP(target)
        return
    end

    local adornee = target
    if not target:IsA("Model") and not target:IsA("BasePart") then
        adornee = target:FindFirstAncestorOfClass("Model") or target
    end

    if adornee:IsA("Model") or adornee:IsA("BasePart") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "NameESP"
        highlight.Adornee = adornee
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = CoreGui
        _G.ananistwaffendivisionWorkspaceNameESPHighlight = highlight
    end
end

AddButton(tabStudio, "ESP", function()
    if not selectedWorkspaceObject then return end
    pcall(function()
        _G.ananistwaffendivisionClearWorkspaceESP()
        _G.ananistwaffendivisionAddWorkspaceESP(selectedWorkspaceObject)
    end)
end)

AddButton(tabStudio, "Workspace ESP Temizle", function()
    pcall(function()
        _G.ananistwaffendivisionClearWorkspaceESP()
    end)
end)

workspaceExplorerSearch.FocusLost:Connect(function()
    if explorerLoaded then buildExplorer() end
end)

AddButton(tabStudio, "Seçili Objeye Işınlan", function()
    teleportToInstance(selectedWorkspaceObject)
end)
AddButton(tabStudio, "Seçili Objeyi Yanıma Getir", function()
    bringInstanceToPlayer(selectedWorkspaceObject)
end)

saveLocationBox = AddTextBox(tabUlasim, "Konum adı yaz...", function() end)
AddButton(tabUlasim, "Konumu Kaydet", function()
    saveCurrentLocation(saveLocationBox.Text)
end)
AddButton(tabUlasim, "Kayıtlı Konuma Işınlan", function()
    teleportToSavedLocation(saveLocationBox.Text)
end)

AddLabel(tabUlasim, "Yakındaki Oyuncular")
nearbyPlayerBox = AddTextBox(tabUlasim, "Oyuncu seç / adı yaz...", function() end)
nearbyPlayers = {}
function refreshNearbyPlayers()
    nearbyPlayers = {}
    local root = getCharacterRoot()
    if not root then return end
    for _, p2 in ipairs(Players:GetPlayers()) do
        if p2 ~= player and p2.Character then
            local tRoot = p2.Character:FindFirstChild("HumanoidRootPart")
            if tRoot then
                table.insert(nearbyPlayers, {player = p2, distance = (tRoot.Position - root.Position).Magnitude})
            end
        end
    end
    table.sort(nearbyPlayers, function(a, b) return a.distance < b.distance end)
    if nearbyPlayers[1] then
        nearbyPlayerBox.Text = nearbyPlayers[1].player.Name
    else
        nearbyPlayerBox.Text = ""
    end
end
AddButton(tabUlasim, "Oyuncu Listesini Yenile", refreshNearbyPlayers)
AddButton(tabUlasim, "En Yakındaki Oyuncuya Işınlan", function()
    refreshNearbyPlayers()
    local name = nearbyPlayerBox.Text
    local target = Players:FindFirstChild(name)
    local root = getCharacterRoot()
    local tRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if root and tRoot then
        root.CFrame = tRoot.CFrame + Vector3.new(0, 3, 0)
    end
end)


-- Varsayılan aktif tab ayarla
tD1.Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
tD1.Btn.BackgroundTransparency = 0.2
tD1.Indicator.Visible = true
tD1.Frame.Visible = true

-- Varsayılan temayı menü ilk açıldığında yükle
applyTheme("ϟϟ Theme")

-- Insert ve ESP tuşları dinleyicileri
if _G.AnanistanInsert then _G.AnanistanInsert:Disconnect() end
_G.AnanistanInsert = UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == menuToggleKey and not settingMenuKey then
        pcall(function()
            if screenGui.Enabled then
                screenGui.Enabled = false
                mainFrame.Visible = false
            else
                screenGui.Enabled = true
                mainFrame.Visible = true
                applyTheme(currentTheme) -- Açılışta güncel temayı tazele
                updateBlur()
            end
        end)
    end
    
    if input.KeyCode == espToggleKey and not settingESPKey then
        espEnabled = not espEnabled
        if updateESPUIs and updateESPUIs.master then
            updateESPUIs.master(espEnabled)
        end
        if espEnabled then
            for _, conn in pairs(espConnections) do if conn then conn:Disconnect() end end
            espConnections = {}
            local function setupForPlayer(p)
                if p == player then return end
                table.insert(espConnections, p.CharacterAdded:Connect(function(char)
                    local root = char:WaitForChild("HumanoidRootPart", 10)
                    if root and espEnabled then buildESP(p) end
                end))
                if p.Character then pcall(function() buildESP(p) end) end
            end
            for _, p in pairs(Players:GetPlayers()) do setupForPlayer(p) end
            table.insert(espConnections, Players.PlayerAdded:Connect(setupForPlayer))
            table.insert(espConnections, Players.PlayerRemoving:Connect(function(p)
                if espObjects[p] then
                    if espObjects[p].box then pcall(game.Destroy, espObjects[p].box) end
                    if espObjects[p].billboard then pcall(game.Destroy, espObjects[p].billboard) end
                    if espObjects[p].highlight then pcall(game.Destroy, espObjects[p].highlight) end
                    espObjects[p] = nil
                end
            end))
            if not espLoopThread then
                espLoopThread = task.spawn(function()
                    local refreshTimer = 0
                    while espEnabled do
                        pcall(updateAllESP)
                        refreshTimer = refreshTimer + 0.2
                        if refreshTimer >= 30 then refreshTimer = 0; clearESP() end
                        task.wait(0.2)
                    end
                end)
            end
        else
            clearESP()
            if espLoopThread then task.cancel(espLoopThread); espLoopThread = nil end
            for _, conn in pairs(espConnections) do if conn then conn:Disconnect() end end
            espConnections = {}
        end
    end
end)

-- Click-TP dinleyicisi
mouse = player:GetMouse()
UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and clickTPEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 and UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
        end
    end
end)

-- Reload kancası: Script dışarıdan _G.ananistwaffendivisionReloadSource = scriptText atayabilir.
_G.ananistwaffendivisionReload = function()
    if type(_G.ananistwaffendivisionReloadSource) ~= "string" then
        pcall(function()
            game.StarterGui:SetCore("SendNotification", {Title="AWD Menu", Text="Reload source bulunamadı", Duration=3})
        end)
        return
    end
    pcall(function()
        if _G.ananistwaffendivisionBodycamStopPlayback then pcall(_G.ananistwaffendivisionBodycamStopPlayback) end
        if _G.ananistwaffendivisionBodycamState and _G.ananistwaffendivisionBodycamState.recordingConn then
            pcall(function() _G.ananistwaffendivisionBodycamState.recordingConn:Disconnect() end)
            _G.ananistwaffendivisionBodycamState.recordingConn = nil
            _G.ananistwaffendivisionBodycamState.recording = false
        end
        if _G.ananistwaffendivisionCleanup then pcall(_G.ananistwaffendivisionCleanup) end
        if screenGui then screenGui:Destroy() end
        if _G.AnanistanInsert then _G.AnanistanInsert:Disconnect(); _G.AnanistanInsert = nil end
        loadstring(_G.ananistwaffendivisionReloadSource)()
    end)
end

