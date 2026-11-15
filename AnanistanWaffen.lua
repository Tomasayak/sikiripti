-- [[ ϟϟ AWD HUB // COMMAND CENTER EDITION ϟϟ ]] --

UIS = game:GetService("UserInputService")
TweenService = game:GetService("TweenService")
CoreGui = game:GetService("CoreGui")
Players = game:GetService("Players")
RunService = game:GetService("RunService")
HttpService = game:GetService("HttpService")
TeleportService = game:GetService("TeleportService")
-- LocalPlayer bazı istemcilerde script ilk çalıştığında henüz hazır olmayabilir.
player = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Önceki çalıştırmadan kalan arayüzleri/bağlantıları temizle; çift yükleme bellek ve FPS çökmesine yol açabilir.
pcall(function()
    if type(_G.ananistwaffendivisionCleanup) == "function" then
        _G.ananistwaffendivisionCleanup()
    end
end)
pcall(function()
    local containers = {CoreGui, player:FindFirstChildOfClass("PlayerGui")}
    for _, container in ipairs(containers) do
        if container then
            for _, child in ipairs(container:GetChildren()) do
                if child.Name == "ananistwaffendivisionUI"
                    or child.Name == "AWD_OptimizedIntro"
                    or child.Name == "AWD_FullscreenIntro"
                    or child.Name == "AWD_PresenceConsent" then
                    pcall(function() child:Destroy() end)
                end
            end
        end
    end
end)

-- AWD HUB: kalıcı kullanıcı dizini izni + dil tercihi. İzin sürümü değişirse tekrar sorulur.
local AWD_CONSENT_FILE = "AWD_PRESENCE_CONSENT_V1.txt"
local AWD_LANGUAGE_FILE = "AWD_LANGUAGE_V1.txt"
local AWD_Language = "Türkçe"
pcall(function()
    if type(isfile) == "function" and type(readfile) == "function" and isfile(AWD_LANGUAGE_FILE) then
        local saved = tostring(readfile(AWD_LANGUAGE_FILE))
        if saved == "English" or saved == "Türkçe" then AWD_Language = saved end
    end
end)
local AWD_ConsentAcceptedThisRun = false
local function AWD_HasSavedConsent()
    local ok, accepted = pcall(function()
        return type(isfile) == "function" and type(readfile) == "function"
            and isfile(AWD_CONSENT_FILE) and tostring(readfile(AWD_CONSENT_FILE)) == "AWD_CONSENT_V1_ACCEPTED"
    end)
    return ok and accepted == true
end
local function AWD_SaveConsent()
    local ok = pcall(function()
        assert(type(writefile) == "function", "writefile desteklenmiyor")
        writefile(AWD_CONSENT_FILE, "AWD_CONSENT_V1_ACCEPTED")
    end)
    return ok
end
local function AWD_ShowPresenceConsent()
    local english = AWD_Language == "English"
    local consentGui = Instance.new("ScreenGui")
    consentGui.Name = "AWD_PresenceConsent"
    consentGui.ResetOnSpawn = false
    consentGui.IgnoreGuiInset = true
    consentGui.DisplayOrder = 1000000
    pcall(function() consentGui.Parent = CoreGui end)
    if not consentGui.Parent then pcall(function() consentGui.Parent = player:WaitForChild("PlayerGui") end) end
    if not consentGui.Parent then return false end

    local backdrop = Instance.new("Frame")
    backdrop.Size = UDim2.fromScale(1, 1)
    backdrop.BackgroundColor3 = Color3.fromRGB(4, 7, 13)
    backdrop.BackgroundTransparency = 0.22
    backdrop.BorderSizePixel = 0
    backdrop.Parent = consentGui

    local panel = Instance.new("Frame")
    panel.Size = UDim2.fromOffset(500, 350)
    panel.Position = UDim2.new(0.5, -250, 0.5, -175)
    panel.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    panel.BorderSizePixel = 0
    panel.Parent = backdrop
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 18)
    local stroke = Instance.new("UIStroke", panel)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.08
    stroke.Thickness = 1.2

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(1, 0, 0, 4)
    accent.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
    accent.BorderSizePixel = 0
    accent.Parent = panel
    Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 18)

    local eyebrow = Instance.new("TextLabel")
    eyebrow.Size = UDim2.new(1, -40, 0, 18)
    eyebrow.Position = UDim2.fromOffset(22, 20)
    eyebrow.BackgroundTransparency = 1
    eyebrow.Font = Enum.Font.GothamBold
    eyebrow.Text = "AWD HUB  /  PRIVACY CENTER"
    eyebrow.TextColor3 = Color3.fromRGB(190, 190, 190)
    eyebrow.TextSize = 10
    eyebrow.TextXAlignment = Enum.TextXAlignment.Left
    eyebrow.Parent = panel

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 0, 34)
    title.Position = UDim2.fromOffset(22, 45)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = english and "USER DIRECTORY PERMISSION" or "KULLANICI DİZİNİ İZNİ"
    title.TextColor3 = Color3.fromRGB(242, 246, 255)
    title.TextSize = 19
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = panel

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, -44, 0, 150)
    info.Position = UDim2.fromOffset(22, 91)
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.Gotham
    info.Text = english
        and "By accepting, this session will be listed in the AWD HUB user directory while the hub is running. Your Roblox UserId, username (masked in the list), experience/place ID and server session ID are sent to the Cloudflare Worker. Other participants can see your masked name, avatar and session details required for JOIN. Choose Decline if you do not want to participate."
        or "‘Okudum, kabul ediyorum’ seçersen AWD HUB açık olduğu sürece bu oturum AWD HUB kullanıcı dizininde listelenir. Roblox UserId'n, kullanıcı adın (listede maskelenir), oyun/place ID ve sunucu oturum ID bilgilerin Cloudflare Worker'a gönderilir. Diğer katılımcılar maskeli adını, avatarını ve JOIN için gereken oturum bilgisini görebilir. Katılmak istemiyorsan Reddet'i seç."
    info.TextColor3 = Color3.fromRGB(181, 193, 213)
    info.TextSize = 12
    info.TextWrapped = true
    info.TextYAlignment = Enum.TextYAlignment.Top
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Parent = panel

    local note = Instance.new("TextLabel")
    note.Size = UDim2.new(1, -44, 0, 20)
    note.Position = UDim2.fromOffset(22, 250)
    note.BackgroundTransparency = 1
    note.Font = Enum.Font.Gotham
    note.Text = english and "Your choice is saved on this device." or "Tercihin bu cihazda saklanır."
    note.TextColor3 = Color3.fromRGB(125, 140, 164)
    note.TextSize = 10
    note.TextXAlignment = Enum.TextXAlignment.Left
    note.Parent = panel

    local accept = Instance.new("TextButton")
    accept.Size = UDim2.new(0.58, -8, 0, 44)
    accept.Position = UDim2.new(0, 22, 1, -62)
    accept.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
    accept.BorderSizePixel = 0
    accept.Font = Enum.Font.GothamBold
    accept.Text = english and "I UNDERSTAND & ACCEPT" or "OKUDUM, KABUL EDİYORUM"
    accept.TextColor3 = Color3.new(1, 1, 1)
    accept.TextSize = 11
    accept.Parent = panel
    Instance.new("UICorner", accept).CornerRadius = UDim.new(0, 10)

    local decline = Instance.new("TextButton")
    decline.Size = UDim2.new(0.42, -8, 0, 44)
    decline.Position = UDim2.new(0.58, 0, 1, -62)
    decline.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    decline.BorderSizePixel = 0
    decline.Font = Enum.Font.GothamBold
    decline.Text = english and "DECLINE" or "REDDET"
    decline.TextColor3 = Color3.fromRGB(230, 235, 245)
    decline.TextSize = 12
    decline.Parent = panel
    Instance.new("UICorner", decline).CornerRadius = UDim.new(0, 10)

    local termsBtn = Instance.new("TextButton")
    termsBtn.Size = UDim2.fromOffset(112, 22)
    termsBtn.Position = UDim2.new(1, -134, 0, 248)
    termsBtn.BackgroundTransparency = 1
    termsBtn.Font = Enum.Font.GothamBold
    termsBtn.Text = "TERMS OF SERVICE"
    termsBtn.TextColor3 = Color3.fromRGB(190, 190, 190)
    termsBtn.TextSize = 9
    termsBtn.Parent = panel
    local showingTerms = false
    local originalInfoText = info.Text
    termsBtn.MouseButton1Click:Connect(function()
        showingTerms = not showingTerms
        if showingTerms then
            info.Text = "TERMS OF SERVICE\n\nAWD HUB arayüzündeki özellikleri kendi sorumluluğunda kullan. Oyun deneyimini, diğer oyuncuları veya Roblox hizmetlerini olumsuz etkileyebilecek kullanımlardan kaçın. Üçüncü taraf executor, ağ bağlantısı ve oyun güncellemelerinden kaynaklanan hatalar garanti kapsamında değildir. Kullanıcı dizinine katılım yalnızca bu formdaki açık rızanla etkinleşir. İstediğin zaman HUB'ı kapatabilirsin."
            termsBtn.Text = "GERİ DÖN"
        else
            info.Text = originalInfoText
            termsBtn.Text = "TERMS OF SERVICE"
        end
    end)

    local choice = nil
    accept.MouseButton1Click:Connect(function() choice = true; AWD_SaveConsent() end)
    decline.MouseButton1Click:Connect(function() choice = false end)
    repeat task.wait() until choice ~= nil or not consentGui.Parent
    pcall(function() consentGui:Destroy() end)
    return choice == true
end

if AWD_HasSavedConsent() then
    AWD_ConsentAcceptedThisRun = true
else
    AWD_ConsentAcceptedThisRun = AWD_ShowPresenceConsent()
    if not AWD_ConsentAcceptedThisRun then return end
    -- If executor file APIs are unavailable, the session still works but consent cannot persist across executions.
    AWD_SaveConsent()
end
if not AWD_ConsentAcceptedThisRun then return end
_G.AWD_PresenceConsentAccepted = true

-- Kullanıcı dizini izni bu cihazda kaydedildi; presence kaydı aşağıdaki modülde başlatılır.

-- Başlangıçta kullanılmayan HTTP isteği kaldırıldı.
-- Gereksiz ağ beklemesi ve executor yükü oluşturuyordu.

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

    local bg = make("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(2, 2, 6),
        BorderSizePixel = 0,
        BackgroundTransparency = 0,
    }, gui)

    local vig = make("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, bg)

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

    local center = make("Frame", {
        Size = UDim2.new(1, -40, 1, -80),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 10,
    }, bg)

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

    task.spawn(function()
        while gui and gui.Parent do
            tw(core, {Size = UDim2.new(0, 18, 0, 18)}, 0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
            task.wait(0.35)
            if not (gui and gui.Parent) then break end
            tw(core, {Size = UDim2.new(0, 10, 0, 10)}, 0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
            task.wait(0.35)
        end
    end)

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

-- [[ ϟϟ AWD HUB // FULLSCREEN INTRO v6 — COMMAND CENTER ϟϟ ]] --
AWD_ENABLE_FULLSCREEN_INTRO = false

function awdShowFullscreenIntro()
    local parentGui = CoreGui
    pcall(function() parentGui = game:GetService("CoreGui") end)

    local gui = Instance.new("ScreenGui")
    gui.Name = "AWD_FullscreenIntro"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 2147483647
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    pcall(function() gui.Parent = parentGui end)
    if not gui.Parent then
        pcall(function() gui.Parent = player:WaitForChild("PlayerGui", 5) end)
    end
    if not gui.Parent then return end

    -- Intro boyunca çalacak açılış sesi
    local introSound
    pcall(function()
        introSound = Instance.new("Sound")
        introSound.Name = "AWD_IntroSound"
        introSound.SoundId = "rbxassetid://127997181362733"
        introSound.Volume = 1
        introSound.Looped = false
        introSound.Parent = game:GetService("SoundService")
        introSound:Play()
    end)

    local finished = false
    local skipConn

    local function finish()
        if finished then return end
        finished = true
        if skipConn then pcall(function() skipConn:Disconnect() end); skipConn = nil end
        if introSound then
            pcall(function()
                introSound:Stop()
                introSound:Destroy()
            end)
            introSound = nil
        end
        local fade = Instance.new("Frame")
        fade.Size = UDim2.fromScale(1, 1)
        fade.BackgroundColor3 = Color3.new(0, 0, 0)
        fade.BackgroundTransparency = 0
        fade.BorderSizePixel = 0
        fade.ZIndex = 999
        fade.Parent = gui
        TweenService:Create(fade, TweenInfo.new(0.32), {BackgroundTransparency = 1}):Play()
        task.delay(0.36, function() pcall(function() gui:Destroy() end) end)
    end

    local function make(class, props, parent)
        local obj = Instance.new(class)
        for k, v in pairs(props or {}) do pcall(function() obj[k] = v end) end
        obj.Parent = parent
        return obj
    end

    local function tw(o, props, duration, style, direction)
        local ok, t = pcall(function()
            return TweenService:Create(o, TweenInfo.new(duration or 0.4, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out), props)
        end)
        if ok and t then t:Play(); return t end
    end

    local bg = make("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(2, 3, 8), BorderSizePixel = 0, ZIndex = 1}, gui)
    local vig = make("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.15, BorderSizePixel = 0, ZIndex = 2}, bg)
    local vigGrad = Instance.new("UIGradient", vig)
    vigGrad.Rotation = 90
    vigGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 20, 38)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(2, 3, 8)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 10, 22))
    })
    vigGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.15),
        NumberSequenceKeypoint.new(0.5, 0.55),
        NumberSequenceKeypoint.new(1, 0.30)
    })

    local grid = make("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 3}, bg)
    for i = 0, 24 do
        local v = make("Frame", {Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(i / 24, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(45, 80, 130), BackgroundTransparency = 0.94, BorderSizePixel = 0, ZIndex = 3}, grid)
        tw(v, {BackgroundTransparency = 0.97}, 1.4 + i * 0.02, Enum.EasingStyle.Sine)
    end
    for i = 0, 14 do
        local h = make("Frame", {Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, i / 14, 0), BackgroundColor3 = Color3.fromRGB(45, 80, 130), BackgroundTransparency = 0.94, BorderSizePixel = 0, ZIndex = 3}, grid)
        tw(h, {BackgroundTransparency = 0.97}, 1.2 + i * 0.03, Enum.EasingStyle.Sine)
    end

    local orbA = make("Frame", {Size = UDim2.fromOffset(520, 520), Position = UDim2.new(0.5, -260, 0.5, -260), BackgroundColor3 = Color3.fromRGB(70, 130, 220), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 4}, bg)
    Instance.new("UICorner", orbA).CornerRadius = UDim.new(1, 0)
    local orbAGrad = Instance.new("UIGradient", orbA)
    orbAGrad.Rotation = 45
    orbAGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(0.55, 0.88), NumberSequenceKeypoint.new(1, 1)})
    tw(orbA, {BackgroundTransparency = 0.86, Size = UDim2.fromOffset(760, 760), Position = UDim2.new(0.5, -380, 0.5, -380)}, 1.8, Enum.EasingStyle.Sine)

    local rings = {}
    for i, spec in ipairs({{300, 0.70, 20}, {210, 0.50, -28}, {145, 0.60, 38}}) do
        local ring = make("Frame", {Size = UDim2.fromOffset(0, 0), Position = UDim2.new(0.5, 0, 0.46, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 5 + i}, bg)
        Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
        local stroke = Instance.new("UIStroke", ring)
        stroke.Color = Color3.fromRGB(180, 210, 255)
        stroke.Thickness = 1.4
        stroke.Transparency = spec[2]
        table.insert(rings, {obj = ring, target = spec[1], speed = spec[3]})
        tw(ring, {Size = UDim2.fromOffset(spec[1], spec[1])}, 0.85, Enum.EasingStyle.Back)
    end

    local crossH = make("Frame", {Size = UDim2.new(0, 0, 0, 1), Position = UDim2.new(0.5, 0, 0.46, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(220, 230, 255), BackgroundTransparency = 0.85, BorderSizePixel = 0, ZIndex = 9}, bg)
    local crossV = make("Frame", {Size = UDim2.new(0, 1, 0, 0), Position = UDim2.new(0.5, 0, 0.46, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(220, 230, 255), BackgroundTransparency = 0.85, BorderSizePixel = 0, ZIndex = 9}, bg)
    tw(crossH, {Size = UDim2.new(0, 440, 0, 1), BackgroundTransparency = 0.15}, 0.55, Enum.EasingStyle.Quart)
    tw(crossV, {Size = UDim2.new(0, 1, 0, 440), BackgroundTransparency = 0.15}, 0.55, Enum.EasingStyle.Quart)

    local core = make("Frame", {Size = UDim2.fromOffset(4, 4), Position = UDim2.new(0.5, 0, 0.46, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, ZIndex = 10}, bg)
    Instance.new("UICorner", core).CornerRadius = UDim.new(1, 0)
    tw(core, {Size = UDim2.fromOffset(16, 16)}, 0.5, Enum.EasingStyle.Back)

    local logo = make("TextLabel", {Size = UDim2.new(1, 0, 0, 100), Position = UDim2.new(0, 0, 0.46, -60), BackgroundTransparency = 1, Font = Enum.Font.GothamBlack, TextSize = 72, TextColor3 = Color3.fromRGB(250, 250, 255), TextStrokeTransparency = 0.5, TextTransparency = 1, Text = "", ZIndex = 12}, bg)
    local sub = make("TextLabel", {Size = UDim2.new(1, 0, 0, 28), Position = UDim2.new(0, 0, 0.63, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, TextSize = 15, TextColor3 = Color3.fromRGB(170, 185, 220), TextTransparency = 1, Text = "ANANISTAN WAFFEN DIVISION", ZIndex = 12}, bg)
    local status = make("TextLabel", {Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0.70, 0), BackgroundTransparency = 1, Font = Enum.Font.Code, TextSize = 12, TextColor3 = Color3.fromRGB(110, 130, 165), TextTransparency = 1, Text = "", ZIndex = 12}, bg)

    local progressBack = make("Frame", {Size = UDim2.fromOffset(440, 3), Position = UDim2.new(0.5, 0, 0.80, 0), AnchorPoint = Vector2.new(0.5, 0), BackgroundColor3 = Color3.fromRGB(45, 55, 80), BackgroundTransparency = 0.2, BorderSizePixel = 0, ZIndex = 12}, bg)
    local progress = make("Frame", {Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(245, 250, 255), BorderSizePixel = 0, ZIndex = 13}, progressBack)

    make("TextLabel", {Size = UDim2.new(0, 280, 0, 18), Position = UDim2.new(0, 24, 1, -44), BackgroundTransparency = 1, Font = Enum.Font.Code, TextSize = 11, TextColor3 = Color3.fromRGB(95, 110, 140), Text = "AWD  //  SECURE SESSION", ZIndex = 12}, bg)
    make("TextLabel", {Size = UDim2.new(0, 300, 0, 18), Position = UDim2.new(1, -324, 1, -44), BackgroundTransparency = 1, Font = Enum.Font.Code, TextSize = 11, TextColor3 = Color3.fromRGB(95, 110, 140), TextXAlignment = Enum.TextXAlignment.Right, Text = "LOCAL  //  BOOT SEQUENCE", ZIndex = 12}, bg)

    local skipLbl = make("TextLabel", {Size = UDim2.new(0, 260, 0, 22), Position = UDim2.new(0.5, -130, 1, -78), BackgroundTransparency = 1, Font = Enum.Font.Code, TextSize = 11, TextColor3 = Color3.fromRGB(120, 135, 165), Text = "PRESS  [SPACE]  TO SKIP", TextTransparency = 1, ZIndex = 14}, bg)
    tw(skipLbl, {TextTransparency = 0}, 0.45)

    skipConn = UIS.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.Escape or input.UserInputType == Enum.UserInputType.MouseButton1 then
            finish()
        end
    end)

    task.spawn(function()
        while gui.Parent and not finished do
            for _, r in ipairs(rings) do
                if r.obj and r.obj.Parent then
                    tw(r.obj, {Rotation = r.obj.Rotation + r.speed * 0.2}, 0.2, Enum.EasingStyle.Linear)
                end
            end
            task.wait(0.2)
        end
    end)

    tw(progress, {Size = UDim2.new(0.25, 0, 1, 0)}, 0.35)
    task.wait(0.3)
    tw(progress, {Size = UDim2.new(0.55, 0, 1, 0)}, 0.4)
    task.wait(0.25)
    tw(progress, {Size = UDim2.new(0.82, 0, 1, 0)}, 0.4)
    task.wait(0.2)

    local full = "ϟϟ AWD COMPHUB ϟϟ"
    logo.Text = ""
    for i = 1, #full do
        if finished then return end
        logo.Text = string.sub(full, 1, i)
        if i == 1 then tw(logo, {TextTransparency = 0}, 0.2) end
        task.wait(0.04)
    end
    if finished then return end

    for _ = 1, 3 do
        logo.TextTransparency = 0.3
        task.wait(0.04)
        logo.TextTransparency = 0
        task.wait(0.05)
    end

    sub.Text = "ANANISTAN WAFFEN DIVISION"
    status.Text = "SYSTEM LINK  //  READY  //  COMMAND CENTER"
    tw(sub, {TextTransparency = 0}, 0.4)
    tw(status, {TextTransparency = 0}, 0.35)
    tw(progress, {Size = UDim2.new(1, 0, 1, 0)}, 0.45)
    tw(core, {Size = UDim2.fromOffset(24, 24)}, 0.3, Enum.EasingStyle.Back)
    task.wait(0.65)

    finish()
end

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
kosatkaEnabled = false
kosatkaConn = nil
kosatkaSavedCollision = {}
kosatkaSavedCharacter = nil
kosatkaAntiFall = nil
kosatkaHeight = 0.5

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

    hum.PlatformStand = false
    hum.AutoRotate = true

    kosatkaConn = RunService.Heartbeat:Connect(function()
        if not kosatkaEnabled then return end

        local currentChar = player.Character
        local currentRoot = currentChar and currentChar:FindFirstChild("HumanoidRootPart")
        local currentHead = currentChar and currentChar:FindFirstChild("Head")
        local currentHum = currentChar and currentChar:FindFirstChildOfClass("Humanoid")
        if not currentChar or not currentRoot or not currentHead or not currentHum then return end

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
            local headOffsetY = currentHead.Position.Y - currentRoot.Position.Y
            local headHalfY = currentHead.Size.Y * 0.5
            local targetRootY = surfaceY + kosatkaHeight + headHalfY - headOffsetY
            local pos = currentRoot.Position

            currentRoot.CFrame = CFrame.new(pos.X, targetRootY, pos.Z) * CFrame.Angles(
                0,
                math.rad(currentRoot.Orientation.Y),
                0
            )

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

themeData = {
  ["ϟϟ Theme"] = {
        MainBG = Color3.fromRGB(8, 8, 8),
        TopbarBG = Color3.fromRGB(15, 15, 15),
        ButtonBG = Color3.fromRGB(35, 35, 35),
        Accent = Color3.fromRGB(235, 235, 235),
        Text = Color3.fromRGB(235, 235, 235),
        UnselectedTabBtn = Color3.fromRGB(22, 22, 22),
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
        MainBG = Color3.fromRGB(45, 34, 25),
        TopbarBG = Color3.fromRGB(74, 57, 42),
        ButtonBG = Color3.fromRGB(94, 73, 54),
        Accent = Color3.fromRGB(92, 179, 44),
        Text = Color3.fromRGB(240, 240, 230),
        UnselectedTabBtn = Color3.fromRGB(61, 46, 34),
        MainTrans = 0.1, TopbarTrans = 0.1, ButtonTrans = 0
    },
    ["Half-Life"] = {
        MainBG = Color3.fromRGB(20, 20, 20),
        TopbarBG = Color3.fromRGB(30, 30, 30),
        ButtonBG = Color3.fromRGB(40, 40, 40),
        Accent = Color3.fromRGB(247, 134, 14),
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
        MainTrans = 0.4, TopbarTrans = 0.45, ButtonTrans = 0.3
    },
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

registry = {
    MainBG = {},
    TopbarBG = {},
    ButtonBG = {},
    Accent = {},
    Text = {},
    TabBtns = {},
    ScrollFrames = {}
}

currentTheme = "ϟϟ Theme"

function registerObj(obj, category)
    if registry[category] then
        table.insert(registry[category], obj)
    end
end

function applyTheme(themeName)
    local cfg = themeData[themeName]
    if not cfg then return end
    currentTheme = themeName

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

    local function tween(obj, props)
        pcall(function()
            TweenService:Create(obj, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
        end)
    end

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
            local hoverColor = cfg.ButtonBG:Lerp(Color3.fromRGB(105, 125, 160), 0.22)
            tween(obj, {
                BackgroundColor3 = obj:GetAttribute("AWD_Hovered") and hoverColor or cfg.ButtonBG,
                BackgroundTransparency = cfg.ButtonTrans
            })
        end
    end

    for _, obj in pairs(registry.ButtonBG) do
        if obj:IsA("Frame") and not obj:GetAttribute("IsToggleBg") and obj:GetAttribute("AWD_Hovered") then
            tween(obj, {BackgroundColor3 = cfg.ButtonBG:Lerp(Color3.fromRGB(105, 125, 160), 0.2)})
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

    for _, item in pairs(registry.TabBtns) do
        local btn = item.Btn
        local ind = item.Indicator
        if ind.Visible then
            tween(btn, {BackgroundColor3 = Color3.fromRGB(18, 18, 18), BackgroundTransparency = 0, TextColor3 = cfg.Text})
            tween(ind, {BackgroundColor3 = cfg.Accent})
        else
            tween(btn, {BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0, TextColor3 = cfg.Text})
        end
    end
end

-- [[ YENİ UI - SMOOTH, COOL, KAPANMA SORUNU ÇÖZÜLDÜ, SİMGELER GÜNCELLENDİ ]] --

screenGui = Instance.new("ScreenGui")
screenGui.Name = "ananistwaffendivisionUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local _awdGuiParented = pcall(function() screenGui.Parent = CoreGui end)
if not _awdGuiParented or not screenGui.Parent then
    local _awdPlayerGui = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui", 8)
    if _awdPlayerGui then
        local _awdFallbackOk = pcall(function() screenGui.Parent = _awdPlayerGui end)
        if not _awdFallbackOk or not screenGui.Parent then
            error("AWD HUB arayüzü CoreGui veya PlayerGui içine yerleştirilemedi.")
        end
    else
        error("AWD HUB yüklenemedi: PlayerGui bulunamadı.")
    end
end

local AWD_Panic, AWD_SetPanicMode
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
        if AWD_Panic and AWD_Panic.connection then AWD_Panic.connection:Disconnect(); AWD_Panic.connection = nil end
        if AWD_Panic and AWD_Panic.active then AWD_SetPanicMode(false) end
    end)
    pcall(function()
        if screenGui then screenGui:Destroy() end
    end)
    _G.ananistwaffendivisionCleanup = nil
end

mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 1020, 0, 680)
mainFrame.Position = UDim2.new(0.5, -510, 0.5, -340)
mainFrame.AnchorPoint = Vector2.new(0, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(8, 11, 18)
mainFrame.BackgroundTransparency = 0.075
mainFrame.ClipsDescendants = true
mainFrame.Active = true
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
registerObj(mainFrame, "MainBG")

silverStroke = Instance.new("UIStroke")
silverStroke.Name = "SilverOutline"
silverStroke.Thickness = 1.25
silverStroke.Color = Color3.fromRGB(104, 143, 198)
silverStroke.Transparency = 0.34
silverStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
silverStroke.Parent = mainFrame

bgImageLabel = Instance.new("ImageLabel")
bgImageLabel.Name = "CustomBGImage"
bgImageLabel.Size = UDim2.new(1, 0, 1, 0)
bgImageLabel.Position = UDim2.new(0, 0, 0, 0)
bgImageLabel.BackgroundTransparency = 1
bgImageLabel.Image = ""
bgImageLabel.ImageTransparency = 1
bgImageLabel.ScaleType = Enum.ScaleType.Crop
bgImageLabel.ZIndex = 2
bgImageLabel.Parent = mainFrame

blurOverlay = Instance.new("Frame")
blurOverlay.Name = "BlurOverlay"
blurOverlay.Size = UDim2.new(1, 0, 1, 0)
blurOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
blurOverlay.BackgroundTransparency = 1
blurOverlay.ZIndex = 3
blurOverlay.Parent = mainFrame

ambientLayer = Instance.new("Frame")
ambientLayer.Name = "AWD_AmbientVisualLayer"
ambientLayer.Size = UDim2.fromScale(1, 1)
ambientLayer.BackgroundTransparency = 1
ambientLayer.BorderSizePixel = 0
ambientLayer.ZIndex = 4
ambientLayer.ClipsDescendants = true
ambientLayer.Parent = mainFrame
ambientWash = Instance.new("Frame")
ambientWash.Name = "AmbientWash"
ambientWash.Size = UDim2.fromScale(1, 1)
ambientWash.BackgroundColor3 = Color3.fromRGB(24, 43, 69)
ambientWash.BackgroundTransparency = 0.91
ambientWash.BorderSizePixel = 0
ambientWash.ZIndex = 4
ambientWash.Parent = ambientLayer
ambientGradient = Instance.new("UIGradient")
ambientGradient.Rotation = 28
ambientGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(38, 67, 105)),
    ColorSequenceKeypoint.new(0.48, Color3.fromRGB(12, 20, 33)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(42, 34, 72))
})
ambientGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.25),
    NumberSequenceKeypoint.new(0.5, 0.92),
    NumberSequenceKeypoint.new(1, 0.28)
})
ambientGradient.Parent = ambientWash
ambientRail = Instance.new("Frame")
ambientRail.Name = "AmbientSweep"
ambientRail.AnchorPoint = Vector2.new(0.5, 0.5)
ambientRail.Position = UDim2.new(-0.25, 0, 0.5, 0)
ambientRail.Size = UDim2.new(0, 2, 1.35, 0)
ambientRail.Rotation = 18
ambientRail.BackgroundColor3 = Color3.fromRGB(118, 171, 235)
ambientRail.BackgroundTransparency = 0.78
ambientRail.BorderSizePixel = 0
ambientRail.ZIndex = 4
ambientRail.Parent = ambientLayer
railGradient = Instance.new("UIGradient")
railGradient.Rotation = 90
railGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.5, 0.12),
    NumberSequenceKeypoint.new(1, 1)
})
railGradient.Parent = ambientRail
ambientTopLine = Instance.new("Frame")
ambientTopLine.Name = "AmbientTopLine"
ambientTopLine.Position = UDim2.new(0, 0, 0, 72)
ambientTopLine.Size = UDim2.new(1, 0, 0, 1)
ambientTopLine.BackgroundColor3 = Color3.fromRGB(111, 155, 211)
ambientTopLine.BackgroundTransparency = 0.72
ambientTopLine.BorderSizePixel = 0
ambientTopLine.ZIndex = 4
ambientTopLine.Parent = ambientLayer

-- [[ AWD GLASSMORPHISM // MULTI-LAYER FROSTED PANELS ]] --
glassFrost = Instance.new("Frame")
glassFrost.Name = "AWD_GlassFrost"
glassFrost.Size = UDim2.new(1, -28, 1, -126)
glassFrost.Position = UDim2.new(0, 14, 0, 88)
glassFrost.BackgroundColor3 = Color3.fromRGB(180, 205, 240)
glassFrost.BackgroundTransparency = 0.94
glassFrost.BorderSizePixel = 0
glassFrost.ZIndex = 4
glassFrost.Parent = ambientLayer
Instance.new("UICorner", glassFrost).CornerRadius = UDim.new(0, 14)
local frostGradient = Instance.new("UIGradient", glassFrost)
frostGradient.Rotation = 118
frostGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 165, 235)),
    ColorSequenceKeypoint.new(0.42, Color3.fromRGB(60, 90, 140)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 30, 50))
})
frostGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.35),
    NumberSequenceKeypoint.new(0.5, 0.92),
    NumberSequenceKeypoint.new(1, 0.60)
})
frostGradient.Parent = glassFrost

glassSpecular = Instance.new("Frame")
glassSpecular.Name = "AWD_GlassSpecular"
glassSpecular.Size = UDim2.new(0, 260, 0, 2)
glassSpecular.Position = UDim2.new(0.08, 0, 0, 92)
glassSpecular.BackgroundColor3 = Color3.fromRGB(230, 240, 255)
glassSpecular.BackgroundTransparency = 0.55
glassSpecular.BorderSizePixel = 0
glassSpecular.ZIndex = 5
glassSpecular.Parent = ambientLayer
Instance.new("UICorner", glassSpecular).CornerRadius = UDim.new(1, 0)
local specGrad = Instance.new("UIGradient", glassSpecular)
specGrad.Rotation = 0
specGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.5, 0.0),
    NumberSequenceKeypoint.new(1, 1)
})
specGrad.Parent = glassSpecular

glassChip = Instance.new("Frame")
glassChip.Name = "AWD_GlassChip"
glassChip.Size = UDim2.new(0, 210, 0, 3)
glassChip.Position = UDim2.new(0, 14, 1, -60)
glassChip.BackgroundColor3 = Color3.fromRGB(155, 185, 230)
glassChip.BackgroundTransparency = 0.85
glassChip.BorderSizePixel = 0
glassChip.ZIndex = 6
glassChip.Parent = ambientLayer
Instance.new("UICorner", glassChip).CornerRadius = UDim.new(1, 0)
local chipGrad = Instance.new("UIGradient", glassChip)
chipGrad.Rotation = 0
chipGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.25),
    NumberSequenceKeypoint.new(0.7, 0.85),
    NumberSequenceKeypoint.new(1, 1)
})
chipGrad.Parent = glassChip

-- [[ AWD GLASSMORPHISM // MULTI-LAYERED SURFACES ]] --
glassSheen = Instance.new("Frame")
glassSheen.Name = "AWD_GlassSheen"
glassSheen.Size = UDim2.fromScale(1, 1)
glassSheen.BackgroundColor3 = Color3.fromRGB(170, 205, 255)
glassSheen.BackgroundTransparency = 0.965
glassSheen.BorderSizePixel = 0
glassSheen.ZIndex = 4
glassSheen.Parent = ambientLayer
glassSheenGradient = Instance.new("UIGradient")
glassSheenGradient.Rotation = 112
glassSheenGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 175, 245)),
    ColorSequenceKeypoint.new(0.34, Color3.fromRGB(34, 57, 86)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(9, 14, 24))
})
glassSheenGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.30),
    NumberSequenceKeypoint.new(0.42, 0.92),
    NumberSequenceKeypoint.new(1, 0.55)
})
glassSheenGradient.Parent = glassSheen

function makeAmbientOrb(name, size, position, color, transparency)
    local orb = Instance.new("Frame")
    orb.Name = name
    orb.AnchorPoint = Vector2.new(0.5, 0.5)
    orb.Size = UDim2.fromOffset(size, size)
    orb.Position = position
    orb.BackgroundColor3 = color
    orb.BackgroundTransparency = transparency
    orb.BorderSizePixel = 0
    orb.ZIndex = 4
    orb.Parent = ambientLayer
    Instance.new("UICorner", orb).CornerRadius = UDim.new(1, 0)
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 35
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.22),
        NumberSequenceKeypoint.new(0.45, 0.68),
        NumberSequenceKeypoint.new(1, 1)
    })
    gradient.Parent = orb
    return orb, gradient
end

ambientOrbA, ambientOrbAGradient = makeAmbientOrb(
    "AWD_AmbientOrb_A", 310, UDim2.new(0.12, 0, 0.18, 0),
    Color3.fromRGB(44, 104, 180), 0.90
)
ambientOrbB, ambientOrbBGradient = makeAmbientOrb(
    "AWD_AmbientOrb_B", 250, UDim2.new(0.88, 0, 0.78, 0),
    Color3.fromRGB(90, 72, 175), 0.92
)
ambientOrbC, ambientOrbCGradient = makeAmbientOrb(
    "AWD_AmbientOrb_C", 190, UDim2.new(0.72, 0, 0.12, 0),
    Color3.fromRGB(40, 135, 155), 0.94
)

glassRim = Instance.new("UIStroke")
glassRim.Name = "AWD_GlassRim"
glassRim.Color = Color3.fromRGB(154, 190, 238)
glassRim.Thickness = 1
glassRim.Transparency = 0.76
glassRim.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
glassRim.Parent = mainFrame

imgCorner = Instance.new("UICorner", bgImageLabel)
imgCorner.CornerRadius = UDim.new(0, 22)

overlayCorner = Instance.new("UICorner", blurOverlay)
overlayCorner.CornerRadius = UDim.new(0, 22)

-- BlurEffect kullanılmıyor; her zaman 0 olan Lighting efekti gereksizdi.
blurEffect = nil

blurHolder = Instance.new("Frame")
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

corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 20)
sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(820, 540)
sizeConstraint.MaxSize = Vector2.new(1320, 900)
sizeConstraint.Parent = mainFrame

shadow = Instance.new("ImageLabel", mainFrame)
shadow.Size = UDim2.new(1, 60, 1, 60)
shadow.Position = UDim2.new(0, -30, 0, -30)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316115263"
shadow.ImageColor3 = Color3.new(0,0,0)
shadow.ImageTransparency = 1
shadow.ZIndex = -1

topbar = Instance.new("Frame", mainFrame)
topbar.Size = UDim2.new(1, 0, 0, 72)
topbar.BackgroundColor3 = Color3.fromRGB(12, 16, 24)
topbar.BackgroundTransparency = 0.02
topbar.BorderSizePixel = 0
topbar.ZIndex = 5
registerObj(topbar, "TopbarBG")
topbarGradient = Instance.new("UIGradient", topbar)
topbarGradient.Rotation = 0
topbarGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 25, 38)),
    ColorSequenceKeypoint.new(0.52, Color3.fromRGB(12, 17, 27)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 12, 19))
})

topCorner = Instance.new("UICorner", topbar)
topCorner.CornerRadius = UDim.new(0, 22)

topFix = Instance.new("Frame", topbar)
topFix.Name = "topFix"
topFix.Size = UDim2.new(1, 0, 0, 28)
topFix.Position = UDim2.new(0, 0, 1, -28)
topFix.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
topFix.BackgroundTransparency = 0.1
topFix.BorderSizePixel = 0
topFix.ZIndex = 5
registerObj(topFix, "MainBG")

title = Instance.new("TextLabel", topbar)
title.Size = UDim2.new(1, -260, 0, 29)
title.Position = UDim2.new(0, 62, 0, 9)
title.BackgroundTransparency = 1
title.Text = "Ananistwaffen Division Hub"
title.TextColor3 = Color3.fromRGB(242, 246, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 6
registerObj(title, "Text")

brandTile = Instance.new("Frame", topbar)
brandTile.Name = "AWD_BrandTile"
brandTile.Size = UDim2.new(0, 34, 0, 34)
brandTile.Position = UDim2.new(0, 16, 0, 9)
brandTile.BackgroundColor3 = Color3.fromRGB(190, 205, 230)
brandTile.BorderSizePixel = 0
brandTile.ZIndex = 7
Instance.new("UICorner", brandTile).CornerRadius = UDim.new(0, 10)
brandGlyph = Instance.new("TextLabel", brandTile)
brandGlyph.Size = UDim2.fromScale(1, 1)
brandGlyph.BackgroundTransparency = 1
brandGlyph.Text = "◎"
brandGlyph.TextColor3 = Color3.fromRGB(9, 13, 20)
brandGlyph.Font = Enum.Font.GothamBlack
brandGlyph.TextSize = 19
brandGlyph.ZIndex = 8

headerSub = Instance.new("TextLabel", topbar)
headerSub.Name = "AWD_HeaderSubtitle"
headerSub.Size = UDim2.new(1, -300, 0, 16)
headerSub.Position = UDim2.new(0, 63, 0, 36)
headerSub.BackgroundTransparency = 1
headerSub.Text = "ANANISTAN WAFFEN DIVISION     /     LOCAL SESSION"
headerSub.TextColor3 = Color3.fromRGB(116, 132, 153)
headerSub.TextSize = 9
headerSub.Font = Enum.Font.Code
headerSub.TextXAlignment = Enum.TextXAlignment.Left
headerSub.ZIndex = 7

sessionBadge = Instance.new("Frame", topbar)
sessionBadge.Name = "AWD_SessionBadge"
sessionBadge.Size = UDim2.new(0, 108, 0, 25)
sessionBadge.Position = UDim2.new(1, -316, 0, 19)
sessionBadge.BackgroundColor3 = Color3.fromRGB(16, 34, 30)
sessionBadge.BorderSizePixel = 0
sessionBadge.ZIndex = 8
Instance.new("UICorner", sessionBadge).CornerRadius = UDim.new(1, 0)
sessionDot = Instance.new("Frame", sessionBadge)
sessionDot.Size = UDim2.new(0, 6, 0, 6)
sessionDot.Position = UDim2.new(0, 11, 0.5, -3)
sessionDot.BackgroundColor3 = Color3.fromRGB(105, 220, 165)
sessionDot.BorderSizePixel = 0
sessionDot.ZIndex = 9
Instance.new("UICorner", sessionDot).CornerRadius = UDim.new(1, 0)
sessionText = Instance.new("TextLabel", sessionBadge)
sessionText.Size = UDim2.new(1, -26, 1, 0)
sessionText.Position = UDim2.new(0, 23, 0, 0)
sessionText.BackgroundTransparency = 1
sessionText.Text = "SESSION LIVE"
sessionText.TextColor3 = Color3.fromRGB(151, 213, 184)
sessionText.TextSize = 9
sessionText.Font = Enum.Font.GothamBold
sessionText.TextXAlignment = Enum.TextXAlignment.Left
sessionText.ZIndex = 9

buildTag = Instance.new("TextLabel", topbar)
buildTag.Name = "AWD_BuildTag"
buildTag.Size = UDim2.new(0, 62, 0, 18)
buildTag.Position = UDim2.new(1, -386, 0, 22)
buildTag.BackgroundColor3 = Color3.fromRGB(22, 29, 40)
buildTag.BackgroundTransparency = 0.08
buildTag.Text = "BUILD  /  02"
buildTag.TextColor3 = Color3.fromRGB(142, 159, 184)
buildTag.TextSize = 8
buildTag.Font = Enum.Font.Code
buildTag.BorderSizePixel = 0
buildTag.ZIndex = 9
Instance.new("UICorner", buildTag).CornerRadius = UDim.new(1, 0)

headerAccent = Instance.new("Frame", topbar)
headerAccent.Name = "AWD_HeaderAccent"
headerAccent.Size = UDim2.new(0, 2, 0, 30)
headerAccent.Position = UDim2.new(0, 7, 0.5, -15)
headerAccent.BackgroundColor3 = Color3.fromRGB(130, 165, 220)
headerAccent.BorderSizePixel = 0
headerAccent.ZIndex = 8
Instance.new("UICorner", headerAccent).CornerRadius = UDim.new(1, 0)

headerDivider = Instance.new("Frame", mainFrame)
headerDivider.Name = "AWD_HeaderDivider"
headerDivider.Position = UDim2.new(0, 0, 0, 71)
headerDivider.Size = UDim2.new(1, 0, 0, 1)
headerDivider.BackgroundColor3 = Color3.fromRGB(95, 112, 140)
headerDivider.BackgroundTransparency = 0.65
headerDivider.BorderSizePixel = 0
headerDivider.ZIndex = 8

-- [[ AWD LAYERED DESIGN // DEPTH + GRADIENT BORDERS + FLOATING CHIPS ]] --
depthShadowA = Instance.new("Frame")
depthShadowA.Name = "AWD_DepthShadowA"
depthShadowA.Size = UDim2.new(1, 0, 1, 0)
depthShadowA.Position = UDim2.new(0, 6, 0, 6)
depthShadowA.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
depthShadowA.BackgroundTransparency = 0.72
depthShadowA.BorderSizePixel = 0
depthShadowA.ZIndex = 3
depthShadowA.Parent = mainFrame
Instance.new("UICorner", depthShadowA).CornerRadius = UDim.new(0, 22)

depthShadowB = Instance.new("Frame")
depthShadowB.Name = "AWD_DepthShadowB"
depthShadowB.Size = UDim2.new(1, 0, 1, 0)
depthShadowB.Position = UDim2.new(0, 14, 0, 14)
depthShadowB.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
depthShadowB.BackgroundTransparency = 0.86
depthShadowB.BorderSizePixel = 0
depthShadowB.ZIndex = 2
depthShadowB.Parent = mainFrame
Instance.new("UICorner", depthShadowB).CornerRadius = UDim.new(0, 22)

topAccentGradient = Instance.new("Frame")
topAccentGradient.Name = "AWD_TopAccentGradient"
topAccentGradient.Size = UDim2.new(1, -32, 0, 1)
topAccentGradient.Position = UDim2.new(0, 16, 0, 71)
topAccentGradient.BackgroundColor3 = Color3.new(1, 1, 1)
topAccentGradient.BorderSizePixel = 0
topAccentGradient.ZIndex = 9
topAccentGradient.Parent = mainFrame
local topAccentGrad = Instance.new("UIGradient", topAccentGradient)
topAccentGrad.Rotation = 0
topAccentGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 110, 200)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 220, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 80, 180))
})
topAccentGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.9),
    NumberSequenceKeypoint.new(0.5, 0.15),
    NumberSequenceKeypoint.new(1, 0.9)
})
topAccentGrad.Parent = topAccentGradient

-- V2 / LIVE dekoratif rozetleri kaldırıldı.

awdMotionMultiplier = 1
function smoothTween(obj, props, duration)
    if not obj then return end
    pcall(function()
        local baseDuration = duration or 0.35
        TweenService:Create(obj, TweenInfo.new(math.max(0.04, baseDuration * awdMotionMultiplier), Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end)
end

closeBtn = Instance.new("TextButton", topbar)
closeBtn.Name = "AWD_CloseButton"
closeBtn.Size = UDim2.new(0, 42, 0, 38)
closeBtn.Position = UDim2.new(1, -50, 0, 13)
closeBtn.BackgroundColor3 = Color3.fromRGB(42, 22, 28)
closeBtn.BackgroundTransparency = 0.12
closeBtn.Text = "ϟϟ"
closeBtn.TextColor3 = Color3.fromRGB(255, 132, 145)
closeBtn.TextSize = 29
closeBtn.Font = Enum.Font.GothamMedium
closeBtn.AutoButtonColor = false
closeBtn.ZIndex = 9
closeBtn:SetAttribute("IsCloseButton", true)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 11)
closeStroke = Instance.new("UIStroke", closeBtn)
closeStroke.Color = Color3.fromRGB(255, 100, 120)
closeStroke.Transparency = 0.72
closeStroke.Thickness = 1

isClosing = false
menuScale = Instance.new("UIScale")
menuScale.Name = "AWD_MenuScale"
menuScale.Scale = 1
menuScale.Parent = mainFrame

function playCloseAnimation()
    if isClosing or not screenGui.Enabled or not mainFrame.Visible then return end
    isClosing = true

    local center = UDim2.fromScale(0.5, 0.5)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Position = center

    smoothTween(closeBtn, {BackgroundColor3 = Color3.fromRGB(75, 27, 39)}, 0.08)
    smoothTween(menuScale, {Scale = 0.035}, 0.32)
    pcall(function()
        if blurEffect then
            TweenService:Create(blurEffect, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 0}):Play()
        end
    end)
    smoothTween(mainFrame, {BackgroundTransparency = 1}, 0.24)
    smoothTween(topbar, {BackgroundTransparency = 1}, 0.20)
    smoothTween(silverStroke, {Transparency = 1}, 0.18)
    if glassFrost then smoothTween(glassFrost, {BackgroundTransparency = 1}, 0.18) end
    if glassSpecular then smoothTween(glassSpecular, {BackgroundTransparency = 1}, 0.15) end
    if glassChip then smoothTween(glassChip, {BackgroundTransparency = 1}, 0.18) end

    task.delay(0.34, function()
        if not mainFrame.Parent then return end
        mainFrame.Visible = false
        mainFrame.AnchorPoint = Vector2.new(0, 0)
        mainFrame.Position = UDim2.new(0.5, -510, 0.5, -340)
        mainFrame.BackgroundTransparency = 0.015
        topbar.BackgroundTransparency = 0.02
        silverStroke.Transparency = 0.34
        menuScale.Scale = 1
        closeBtn.BackgroundColor3 = Color3.fromRGB(42, 22, 28)
        if glassFrost then glassFrost.BackgroundTransparency = 0.94 end
        if glassSpecular then glassSpecular.BackgroundTransparency = 0.55; glassSpecular.Position = UDim2.new(0.08, 0, 0, 92) end
        if glassChip then glassChip.BackgroundTransparency = 0.85 end
        isClosing = false
        pcall(function()
            game.StarterGui:SetCore("SendNotification", {
                Title = "AWD Hub",
                Text = "Menü kapatıldı  /  INSERT ile geri aç",
                Duration = 3
            })
        end)
    end)
end

closeBtn.MouseButton1Click:Connect(playCloseAnimation)

paletteTopButton = Instance.new("TextButton", topbar)
paletteTopButton.Name = "AWD_CommandPaletteButton"
paletteTopButton.Size = UDim2.new(0, 92, 0, 30)
paletteTopButton.Position = UDim2.new(1, -200, 0, 17)
paletteTopButton.BackgroundColor3 = Color3.fromRGB(23, 31, 45)
paletteTopButton.Text = "C.B"
paletteTopButton.TextColor3 = Color3.fromRGB(175, 195, 222)
paletteTopButton.Font = Enum.Font.Code
paletteTopButton.TextSize = 10
paletteTopButton.AutoButtonColor = false
paletteTopButton.ZIndex = 9
Instance.new("UICorner", paletteTopButton).CornerRadius = UDim.new(0, 8)
paletteTopButton.MouseButton1Click:Connect(function()
    if _G.AWD_OpenCommandPalette then _G.AWD_OpenCommandPalette() end
end)
paletteTopButton.MouseEnter:Connect(function() smoothTween(paletteTopButton, {BackgroundColor3 = Color3.fromRGB(42, 59, 83)}, 0.12) end)
paletteTopButton.MouseLeave:Connect(function() smoothTween(paletteTopButton, {BackgroundColor3 = Color3.fromRGB(23, 31, 45)}, 0.14) end)
closeBtn.MouseEnter:Connect(function()
    smoothTween(closeBtn, {BackgroundColor3 = Color3.fromRGB(75, 27, 39)}, 0.14)
    smoothTween(closeStroke, {Transparency = 0.28}, 0.14)
end)
closeBtn.MouseLeave:Connect(function()
    smoothTween(closeBtn, {BackgroundColor3 = Color3.fromRGB(42, 22, 28)}, 0.16)
    smoothTween(closeStroke, {Transparency = 0.72}, 0.16)
end)

-- Küçültme düğmesi kaldırıldı; pencere tek boyutlu ana görünümde kalır.


dragging = false
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

sidebarWidth = 172

tabNav = Instance.new("ScrollingFrame", mainFrame)
tabNav.Name = "AWD_Sidebar"
tabNav.Size = UDim2.new(0, sidebarWidth, 1, -114)
tabNav.Position = UDim2.new(0, 14, 0, 76)
tabNav.BackgroundColor3 = Color3.fromRGB(13, 20, 31)
tabNav.BackgroundTransparency = 0.18
tabNav.BorderSizePixel = 0
tabNav.ZIndex = 5
tabNav.ScrollingDirection = Enum.ScrollingDirection.Y
tabNav.ScrollBarThickness = 3
tabNav.ScrollBarImageColor3 = Color3.fromRGB(115, 115, 140)
tabNav.CanvasSize = UDim2.new(0, 0, 0, 0)
tabNav.AutomaticCanvasSize = Enum.AutomaticSize.Y
tabNav.ClipsDescendants = true
sideCorner = Instance.new("UICorner", tabNav)
sideCorner.CornerRadius = UDim.new(0, 13)
sideStroke = Instance.new("UIStroke", tabNav)
sideStroke.Color = Color3.fromRGB(112, 151, 202)
sideStroke.Transparency = 0.70
sideStroke.Thickness = 1
sideGlassGradient = Instance.new("UIGradient", tabNav)
sideGlassGradient.Rotation = 90
sideGlassGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 38, 57)),
    ColorSequenceKeypoint.new(0.55, Color3.fromRGB(13, 20, 31)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 15, 24))
})
tabLayout = Instance.new("UIListLayout", tabNav)
tabLayout.FillDirection = Enum.FillDirection.Vertical
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 0)
sidePadding = Instance.new("UIPadding", tabNav)
sidePadding.PaddingTop = UDim.new(0, 2)
sidePadding.PaddingBottom = UDim.new(0, 2)
sidePadding.PaddingLeft = UDim.new(0, 4)
sidePadding.PaddingRight = UDim.new(0, 4)

navCaption = Instance.new("TextLabel", tabNav)
navCaption.Name = "AWD_NavigationCaption"
navCaption.Size = UDim2.new(1, 0, 0, 16)
navCaption.BackgroundTransparency = 1
navCaption.Text = "WORKSPACE  /  PAGES"
navCaption.TextColor3 = Color3.fromRGB(94, 111, 137)
navCaption.TextSize = 9
navCaption.Font = Enum.Font.Code
navCaption.TextXAlignment = Enum.TextXAlignment.Left
navCaption.LayoutOrder = -100
navCaption.ZIndex = 6

bottomBar = Instance.new("Frame", mainFrame)
bottomBar.Name = "AWD_StatusBar"
bottomBar.Size = UDim2.new(1, -28, 0, 26)
bottomBar.Position = UDim2.new(0, 14, 1, -34)
bottomBar.BackgroundColor3 = Color3.fromRGB(15, 23, 35)
bottomBar.BackgroundTransparency = 0.16
bottomBar.BorderSizePixel = 0
bottomBar.ZIndex = 7
Instance.new("UICorner", bottomBar).CornerRadius = UDim.new(0, 7)
bottomGradient = Instance.new("UIGradient", bottomBar)
bottomGradient.Rotation = 0
bottomGradient.Color = ColorSequence.new(Color3.fromRGB(16, 22, 32), Color3.fromRGB(9, 12, 18))
bottomStroke = Instance.new("UIStroke", bottomBar)
bottomStroke.Color = Color3.fromRGB(75, 91, 116)
bottomStroke.Transparency = 0.82
bottomStroke.Thickness = 1

function makeStatusText(name, textValue, x, width, color)
    local label = Instance.new("TextLabel", bottomBar)
    label.Name = name
    label.Size = UDim2.new(0, width, 1, 0)
    label.Position = UDim2.new(0, x, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = textValue
    label.TextColor3 = color or Color3.fromRGB(125, 142, 165)
    label.TextSize = 9
    label.Font = Enum.Font.Code
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 8
    return label
end

statusUser = makeStatusText("AWD_StatusUser", "USER  /  " .. tostring(player and player.Name or "LOCAL"), 10, 190, Color3.fromRGB(160, 174, 195))
statusPlace = makeStatusText("AWD_StatusPlace", "PLACE  /  " .. tostring(game.PlaceId), 210, 220)
statusFPS = makeStatusText("AWD_StatusFPS", "FPS  /  --", 0, 90, Color3.fromRGB(135, 210, 175))
statusFPS.Position = UDim2.new(1, -100, 0, 0)
statusFPS.TextXAlignment = Enum.TextXAlignment.Right

fpsFrames, fpsElapsed = 0, 0
fpsConnection = RunService.Heartbeat:Connect(function(dt)
    fpsFrames += 1
    fpsElapsed += dt
    if fpsElapsed >= 0.5 then
        statusFPS.Text = "FPS  /  " .. tostring(math.floor(fpsFrames / math.max(fpsElapsed, 0.001)))
        fpsFrames, fpsElapsed = 0, 0
    end
end)

-- [[ AWD PANIC MODE // FPS GUARD + RESTORE ]] --
-- Roblox LocalScripts cannot force the client's global Graphics Quality slider. This guard
-- temporarily disables expensive visual effects and restores their exact prior states.
AWD_Panic = {active = false, lowTime = 0, recoverTime = 0, saved = {}, connection = nil}
AWD_SetPanicMode = function(enabled)
    if AWD_Panic.active == enabled then return end
    AWD_Panic.active = enabled
    local Lighting = game:GetService("Lighting")
    local Terrain = workspace:FindFirstChildOfClass("Terrain")
    if enabled then
        AWD_Panic.saved.globalShadows = Lighting.GlobalShadows
        AWD_Panic.saved.terrainDecoration = Terrain and Terrain.Decoration
        AWD_Panic.saved.effects = {}
        for _, obj in ipairs(Lighting:GetDescendants()) do
            if obj:IsA("PostEffect") then
                AWD_Panic.saved.effects[obj] = obj.Enabled
                pcall(function() obj.Enabled = false end)
            end
        end
        pcall(function() Lighting.GlobalShadows = false end)
        if Terrain then pcall(function() Terrain.Decoration = false end) end
        pcall(function() notify("PANİK MODU", "Performans koruması etkinleştirildi.") end)
    else
        if AWD_Panic.saved.globalShadows ~= nil then pcall(function() Lighting.GlobalShadows = AWD_Panic.saved.globalShadows end) end
        if Terrain and AWD_Panic.saved.terrainDecoration ~= nil then pcall(function() Terrain.Decoration = AWD_Panic.saved.terrainDecoration end) end
        for obj, oldEnabled in pairs(AWD_Panic.saved.effects or {}) do
            if obj and obj.Parent then pcall(function() obj.Enabled = oldEnabled end) end
        end
        AWD_Panic.saved = {}
        pcall(function() notify("PANİK MODU", "Performans normale döndü; grafik ayarları geri yüklendi.") end)
    end
end
AWD_Panic.connection = RunService.Heartbeat:Connect(function(dt)
    if not screenGui or not screenGui.Parent then return end
    local currentFPS = 1 / math.max(dt, 0.001)
    if currentFPS < 15 then
        AWD_Panic.lowTime += dt
        AWD_Panic.recoverTime = 0
        if AWD_Panic.lowTime >= 2.0 then AWD_SetPanicMode(true) end
    elseif currentFPS > 28 then
        AWD_Panic.recoverTime += dt
        AWD_Panic.lowTime = 0
        if AWD_Panic.recoverTime >= 7.0 then AWD_SetPanicMode(false) end
    else
        AWD_Panic.lowTime = math.max(0, AWD_Panic.lowTime - dt * 0.5)
        AWD_Panic.recoverTime = 0
    end
end)
screenGui.AncestryChanged:Connect(function(_, parent)
    if parent == nil then
        if fpsConnection then fpsConnection:Disconnect(); fpsConnection = nil end
        if AWD_Panic and AWD_Panic.connection then AWD_Panic.connection:Disconnect(); AWD_Panic.connection = nil end
    end
end)

contentArea = Instance.new("Frame", mainFrame)
contentArea.Name = "AWD_ContentArea"
contentArea.Size = UDim2.new(1, -(sidebarWidth + 46), 1, -126)
contentArea.Position = UDim2.new(0, sidebarWidth + 32, 0, 88)
contentArea.BackgroundTransparency = 1
contentArea.ClipsDescendants = true
contentArea.ZIndex = 5

-- [[ LAYERED DESIGN: content overlay (glass) + side overlay ]] --
sideOverlay = Instance.new("Frame")
sideOverlay.Name = "AWD_SideOverlay"
sideOverlay.Size = tabNav.Size
sideOverlay.Position = tabNav.Position
sideOverlay.BackgroundColor3 = Color3.new(1, 1, 1)
sideOverlay.BackgroundTransparency = 1
sideOverlay.BorderSizePixel = 0
sideOverlay.ZIndex = 5
-- Sidebar overlay ScrollingFrame icinde olursa UIListLayout bunu tam ekranlik bir tab gibi sayar ve butonlari asagi iter.
-- Overlay artik ana frame uzerinde ayri katmanda; tab listesinin layoutunu etkilemez.
sideOverlay.Parent = mainFrame
local sideOverlayGrad = Instance.new("UIGradient", sideOverlay)
sideOverlayGrad.Rotation = 90
sideOverlayGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 100, 160)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 30, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 50, 90))
})
sideOverlayGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.85),
    NumberSequenceKeypoint.new(0.5, 0.98),
    NumberSequenceKeypoint.new(1, 0.92)
})
sideOverlayGrad.Parent = sideOverlay
Instance.new("UICorner", sideOverlay).CornerRadius = UDim.new(0, 13)

contentOverlay = Instance.new("Frame")
contentOverlay.Name = "AWD_ContentOverlay"
contentOverlay.Size = UDim2.new(1, 0, 1, 0)
contentOverlay.BackgroundColor3 = Color3.new(1, 1, 1)
contentOverlay.BackgroundTransparency = 1
contentOverlay.BorderSizePixel = 0
contentOverlay.ZIndex = 5
contentOverlay.Parent = contentArea
local contentOverlayGrad = Instance.new("UIGradient", contentOverlay)
contentOverlayGrad.Rotation = 135
contentOverlayGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 60, 95)),
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(15, 22, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 35, 55))
})
contentOverlayGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.92),
    NumberSequenceKeypoint.new(0.5, 0.99),
    NumberSequenceKeypoint.new(1, 0.94)
})
contentOverlayGrad.Parent = contentOverlay

tabs = {}
activeTab = nil
tabSwitchToken = 0

function CreateTab(name)
    local tabBtn = Instance.new("TextButton", tabNav)
    tabBtn.Name = "Nav_" .. name:gsub("%W", "")
    tabBtn.Size = UDim2.new(1, 0, 0, 42)
    tabBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    tabBtn.BackgroundTransparency = 0
    tabBtn.Text = "   " .. name
    tabBtn.TextColor3 = Color3.fromRGB(178, 178, 199)
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.Font = Enum.Font.GothamMedium
    tabBtn.TextSize = 13
    tabBtn.BorderSizePixel = 0
    tabBtn.TextTruncate = Enum.TextTruncate.AtEnd
    tabBtn.AutoButtonColor = false
    tabBtn.ZIndex = 6
    registerObj(tabBtn, "Text")
    local tabCorner = Instance.new("UICorner", tabBtn)
    tabCorner.CornerRadius = UDim.new(0, 10)
    local tabStroke = Instance.new("UIStroke", tabBtn)
    tabStroke.Color = Color3.fromRGB(104, 135, 180)
    tabStroke.Transparency = 1
    tabStroke.Thickness = 1
    local indicator = Instance.new("Frame", tabBtn)
    indicator.Name = "ActiveOutline"
    indicator.Size = UDim2.new(1, -2, 1, -2)
    indicator.Position = UDim2.new(0, 1, 0, 1)
    indicator.BackgroundTransparency = 1
    indicator.BorderSizePixel = 0
    indicator.Visible = false
    indicator.ZIndex = 7
    local outline = Instance.new("UIStroke", indicator)
    outline.Color = Color3.fromRGB(142, 164, 198)
    outline.Thickness = 1
    outline.Transparency = 0.42
    local indCorner = Instance.new("UICorner", indicator)
    indCorner.CornerRadius = UDim.new(0, 8)

    local scroll = Instance.new("ScrollingFrame", contentArea)
    scroll.Name = "Page_" .. name:gsub("%W", "")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.Position = UDim2.new(0, 0, 0, 8)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Color3.fromRGB(125, 148, 180)
    scroll.Visible = false
    scroll.ZIndex = 6
    scroll.ClipsDescendants = true
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
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
            t.Btn:SetAttribute("AWD_Hovered", false)
            local tabOutline = t.Btn:FindFirstChildOfClass("UIStroke")
            if tabOutline then smoothTween(tabOutline, {Transparency = selected and 0.5 or 1}, 0.18) end
            smoothTween(t.Btn, {
                BackgroundColor3 = selected and Color3.fromRGB(24, 35, 52) or Color3.fromRGB(9, 12, 18),
                BackgroundTransparency = 0,
                TextColor3 = selected and Color3.fromRGB(248, 248, 255) or Color3.fromRGB(178, 178, 199)
            }, 0.22)
            if t ~= tabData and t.Frame.Visible then
                t.Frame.Visible = false
            end
        end
        scroll.Visible = true
        scroll.Position = UDim2.new(0, 10, 0, 5)
        scroll.ZIndex = 6
        smoothTween(scroll, {Position = UDim2.new(0, 0, 0, 0)}, 0.28)
        -- Tema zaten uygulandı; sekme değişiminde tüm arayüzü tekrar tweenleme.
    end
    tabBtn.MouseButton1Click:Connect(selectTab)
    tabBtn.MouseEnter:Connect(function()
        if activeTab ~= tabData then
            tabBtn:SetAttribute("AWD_Hovered", true)
            smoothTween(tabBtn, {BackgroundColor3 = Color3.fromRGB(24, 33, 48), TextColor3 = Color3.fromRGB(240, 246, 255)}, 0.13)
            smoothTween(tabStroke, {Transparency = 0.62}, 0.13)
        end
    end)
    tabBtn.MouseLeave:Connect(function()
        tabBtn:SetAttribute("AWD_Hovered", false)
        if activeTab ~= tabData then
            smoothTween(tabBtn, {BackgroundColor3 = Color3.fromRGB(0, 0, 0), TextColor3 = (themeData[currentTheme] and themeData[currentTheme].Text) or Color3.fromRGB(178, 178, 199)}, 0.16)
            smoothTween(tabStroke, {Transparency = 1}, 0.16)
        end
    end)
    tabData.Select = selectTab
    return scroll, tabData
end

-- UI localization registry. Existing control callbacks and values are not modified by language switching.
local AWD_LocalizedObjects = {}
local AWD_Translations = {
    ["Ayarlar"] = "Settings", ["Ana Sayfa"] = "Home", ["Oyuncu"] = "Player", ["Ulaşım"] = "Travel",
    ["Studio"] = "Studio", ["Oyunlar"] = "Games", ["Grapple"] = "Grapple", ["Görseller"] = "Visuals",
    ["Aimbot"] = "Aimbot", ["Dizayn"] = "Design", ["Oyuncular"] = "Players", ["Kullanıcılar"] = "Users",
    ["Scriptler"] = "Scripts", ["Stil"] = "Style", ["Menü Bilgileri"] = "Menu Information",
    ["Seçtiğin Tuşlar:"] = "Your Keybinds:", ["AWD Config Manager"] = "AWD Config Manager",
    ["Kayıtlı Configler (tıkla = yükle)"] = "Saved Configs (click to load)", ["Kaydet"] = "Save",
    ["Yükle"] = "Load", ["Sil"] = "Delete", ["Listeyi Yenile"] = "Refresh List",
    ["Auto Execute"] = "Auto Execute", ["Ekstra"] = "Extras",
    ["Executor Açılınca Hub Otomatik Çalışsın"] = "Run Hub Automatically When Executor Starts",
    ["Tüm Aimbot + ESP Kapat"] = "Disable All Aimbot + ESP",
    ["Ayarlar ve Profil Yönetimi"] = "Settings and Profile Management",
    ["Dil Ayarları"] = "Language Settings", ["Arayüz dili"] = "Interface language",
    ["Türkçe"] = "Turkish", ["İngilizce"] = "English"
}
local function AWD_Localize(text)
    if AWD_Language ~= "English" then return text end
    local leading, body = tostring(text):match("^(%s*)(.*)$")
    return leading .. (AWD_Translations[body] or body)
end
local function AWD_RegisterLocalized(object, original)
    table.insert(AWD_LocalizedObjects, {object = object, original = tostring(original or "")})
    object.Text = AWD_Localize(original)
end
local function AWD_ApplyLanguage(language)
    AWD_Language = language == "English" and "English" or "Türkçe"
    for _, item in ipairs(AWD_LocalizedObjects) do
        if item.object and item.object.Parent then item.object.Text = AWD_Localize(item.original) end
    end
    pcall(function() if writefile then writefile(AWD_LANGUAGE_FILE, AWD_Language) end end)
    if _G.AWD_ApplyTabLanguage then _G.AWD_ApplyTabLanguage() end
end

AWD_ControlRegistry = AWD_ControlRegistry or {}
function AddButton(parent, text, callback)
    table.insert(AWD_ControlRegistry, {kind = "Button", name = tostring(text), callback = callback, parent = parent})
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -12, 0, 46)
    btn.BackgroundColor3 = Color3.fromRGB(17, 21, 29)
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ZIndex = 7
    btn.LayoutOrder = #parent:GetChildren()
    registerObj(btn, "ButtonBG")
    
    local cornerBtn = Instance.new("UICorner", btn)
    cornerBtn.CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(92, 112, 143)
    stroke.Transparency = 0.58
    stroke.Thickness = 1.1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local accent = Instance.new("Frame", btn)
    accent.Size = UDim2.new(0, 3, 0, 18)
    accent.Position = UDim2.new(0, 7, 0.5, -9)
    accent.BackgroundColor3 = Color3.fromRGB(175, 190, 255)
    accent.BackgroundTransparency = 0.78
    accent.BorderSizePixel = 0
    accent.ZIndex = 8
    local accentCorner = Instance.new("UICorner", accent)
    accentCorner.CornerRadius = UDim.new(1, 0)
    
    local label = Instance.new("TextLabel", btn)
    label.Size = UDim2.new(1, -12, 1, 0)
    label.Position = UDim2.new(0, 17, 0, 0)
    label.BackgroundTransparency = 1
    label.BackgroundColor3 = Color3.new(0, 0, 0)
    AWD_RegisterLocalized(label, text)
    label.TextColor3 = Color3.fromRGB(224, 231, 243)
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextStrokeTransparency = 1
    label.ZIndex = 8
    registerObj(label, "Text")
    
    local isHovered = false
    btn.MouseEnter:Connect(function()
        isHovered = true
        btn:SetAttribute("AWD_Hovered", true)
        local cfg = themeData[currentTheme] or themeData["ϟϟ Theme"]
        local base = (cfg and cfg.ButtonBG) or Color3.fromRGB(17, 21, 29)
        smoothTween(btn, {BackgroundColor3 = base:Lerp(Color3.fromRGB(105, 125, 160), 0.22)}, 0.12)
        smoothTween(stroke, {Transparency = 0.12, Color = (cfg and cfg.Accent) or Color3.fromRGB(185, 195, 255)}, 0.12)
        smoothTween(accent, {BackgroundTransparency = 0.05, Size = UDim2.new(0, 3, 0, 24), Position = UDim2.new(0, 7, 0.5, -12)}, 0.12)
    end)
    btn.MouseLeave:Connect(function()
        isHovered = false
        btn:SetAttribute("AWD_Hovered", false)
        local cfg = themeData[currentTheme] or themeData["ϟϟ Theme"]
        smoothTween(btn, {
            BackgroundColor3 = (cfg and cfg.ButtonBG) or Color3.fromRGB(17, 21, 29),
            BackgroundTransparency = (cfg and cfg.ButtonTrans) or 0
        }, 0.16)
        smoothTween(stroke, {Transparency = 0.58, Color = Color3.fromRGB(92, 112, 143)}, 0.16)
        smoothTween(accent, {BackgroundTransparency = 0.78, Size = UDim2.new(0, 3, 0, 18), Position = UDim2.new(0, 7, 0.5, -9)}, 0.16)
    end)
    btn.MouseButton1Down:Connect(function() smoothTween(btn, {Size = UDim2.new(1, -14, 0, 42)}, 0.08) end)
    btn.MouseButton1Up:Connect(function() smoothTween(btn, {Size = UDim2.new(1, -12, 0, 46)}, 0.1) end)
    btn.MouseButton1Click:Connect(function() pcall(callback) end)
    return btn
end

function AddToggle(parent, text, defaultState, callback)
    table.insert(AWD_ControlRegistry, {kind = "Toggle", name = tostring(text), callback = callback, parent = parent})
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 38)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    frame.ZIndex = 7
    frame.LayoutOrder = #parent:GetChildren()
    registerObj(frame, "ButtonBG")
    
    local cornerFrame = Instance.new("UICorner", frame)
    cornerFrame.CornerRadius = UDim.new(0, 10)
    local frameStroke = Instance.new("UIStroke", frame)
    frameStroke.Color = Color3.fromRGB(100, 105, 128)
    frameStroke.Transparency = 0.62
    frameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.BackgroundColor3 = Color3.new(0, 0, 0)
    AWD_RegisterLocalized(label, text)
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextStrokeTransparency = 1
    label.ZIndex = 8
    registerObj(label, "Text")

    local togBg = Instance.new("Frame", frame)
    togBg.Size = UDim2.new(0, 45, 0, 22)
    togBg.Position = UDim2.new(1, -55, 0.5, -11)
    togBg.BackgroundColor3 = defaultState and Color3.fromRGB(80, 220, 80) or Color3.fromRGB(80, 80, 80)
    togBg:SetAttribute("IsToggleBg", true)
    togBg:SetAttribute("ToggleActive", defaultState)
    togBg.ZIndex = 7
    registerObj(togBg, "ButtonBG")
    
    local togCorner = Instance.new("UICorner", togBg)
    togCorner.CornerRadius = UDim.new(0, 11)

    local togCircle = Instance.new("Frame", togBg)
    togCircle.Size = UDim2.new(0, 18, 0, 18)
    togCircle.Position = UDim2.new(defaultState and 0.55 or 0.05, 0, 0.5, -9)
    togCircle.BackgroundColor3 = Color3.new(1,1,1)
    togCircle.ZIndex = 8
    local circleCorner = Instance.new("UICorner", togCircle)
    circleCorner.CornerRadius = UDim.new(0, 9)

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 8

    local state = defaultState
    local function UpdateVis()
        pcall(function()
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
        frame:SetAttribute("AWD_Hovered", true)
        local cfg = themeData[currentTheme] or themeData["ϟϟ Theme"]
        local base = (cfg and cfg.ButtonBG) or Color3.fromRGB(35, 35, 50)
        smoothTween(frame, {BackgroundColor3 = base:Lerp(Color3.fromRGB(105, 125, 160), 0.2)}, 0.12)
        smoothTween(frameStroke, {Transparency = 0.16, Color = (cfg and cfg.Accent) or Color3.fromRGB(145, 165, 205)}, 0.12)
    end)
    btn.MouseLeave:Connect(function()
        frame:SetAttribute("AWD_Hovered", false)
        local cfg = themeData[currentTheme] or themeData["ϟϟ Theme"]
        smoothTween(frame, {BackgroundColor3 = (cfg and cfg.ButtonBG) or Color3.fromRGB(35, 35, 50)}, 0.16)
        smoothTween(frameStroke, {Transparency = 0.62, Color = Color3.fromRGB(100, 105, 128)}, 0.16)
    end)

    return function(forceState)
        if forceState ~= nil then state = forceState end
        UpdateVis()
    end
end

colorPickerFrame = Instance.new("Frame", screenGui)
colorPickerFrame.Size = UDim2.new(0, 220, 0, 260)
colorPickerFrame.Position = UDim2.new(0.5, -110, 0.5, -130)
colorPickerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
colorPickerFrame.Visible = false
colorPickerFrame.ZIndex = 10
registerObj(colorPickerFrame, "TopbarBG")

pickerCorner = Instance.new("UICorner", colorPickerFrame)
pickerCorner.CornerRadius = UDim.new(0, 12)

pTitle = Instance.new("TextLabel", colorPickerFrame)
pTitle.Size = UDim2.new(1, 0, 0, 30)
pTitle.Position = UDim2.new(0, 0, 0, 0)
pTitle.BackgroundTransparency = 1
pTitle.Text = " Renk Seçici"
pTitle.TextColor3 = Color3.fromRGB(220, 220, 240)
pTitle.TextSize = 14
pTitle.Font = Enum.Font.GothamBold
pTitle.TextXAlignment = Enum.TextXAlignment.Left
registerObj(pTitle, "Text")

closeColorBtn = Instance.new("TextButton", colorPickerFrame)
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

wheelImg = Instance.new("ImageButton", colorPickerFrame)
wheelImg.Size = UDim2.new(0, 170, 0, 170)
wheelImg.Position = UDim2.new(0.5, -85, 0, 35)
wheelImg.Image = "rbxassetid://6020299385"
wheelImg.BackgroundTransparency = 1
wheelImg.ZIndex = 11

rgbBox = Instance.new("TextBox", colorPickerFrame)
rgbBox.Size = UDim2.new(0, 170, 0, 35)
rgbBox.Position = UDim2.new(0.5, -85, 1, -45)
rgbBox.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
rgbBox.TextColor3 = Color3.fromRGB(220, 220, 240)
rgbBox.Font = Enum.Font.GothamMedium
rgbBox.TextSize = 14
rgbBox.Text = "255, 255, 255"
registerObj(rgbBox, "ButtonBG")
registerObj(rgbBox, "Text")

rgbCorner = Instance.new("UICorner", rgbBox)
rgbCorner.CornerRadius = UDim.new(0, 8)
rgbBox.ZIndex = 11

applyPickedColorCallback = nil

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
    frame.ZIndex = 7
    frame.LayoutOrder = #parent:GetChildren()
    registerObj(frame, "ButtonBG")
    
    local frameCorner = Instance.new("UICorner", frame)
    frameCorner.CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.BackgroundColor3 = Color3.new(0, 0, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextStrokeTransparency = 1
    label.ZIndex = 8
    registerObj(label, "Text")

    local cBtn = Instance.new("TextButton", frame)
    cBtn.Size = UDim2.new(0, 35, 0, 22)
    cBtn.Position = UDim2.new(1, -45, 0.5, -11)
    cBtn.BackgroundColor3 = defaultColor
    cBtn.Text = ""
    cBtn.ZIndex = 8
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
    box.ZIndex = 7
    box.LayoutOrder = #parent:GetChildren()
    box.TextStrokeTransparency = 1
    registerObj(box, "ButtonBG")
    registerObj(box, "Text")
    
    local boxCorner = Instance.new("UICorner", box)
    boxCorner.CornerRadius = UDim.new(0, 10)
    local boxStroke = Instance.new("UIStroke", box)
    boxStroke.Color = Color3.fromRGB(100, 105, 128)
    boxStroke.Transparency = 0.58
    boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
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
    frame.ZIndex = 7
    frame.LayoutOrder = #parent:GetChildren()
    registerObj(frame, "ButtonBG")
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    local frameStroke = Instance.new("UIStroke", frame)
    frameStroke.Color = Color3.fromRGB(100, 105, 128)
    frameStroke.Transparency = 0.62
    frameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.55, 0, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 2)
    label.BackgroundTransparency = 1
    label.BackgroundColor3 = Color3.new(0, 0, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextStrokeTransparency = 1
    label.ZIndex = 8
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
    valueBox.ZIndex = 8
    valueBox.TextStrokeTransparency = 1
    Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 4)
    registerObj(valueBox, "ButtonBG")
    registerObj(valueBox, "Text")

    local sliderBg = Instance.new("Frame", frame)
    sliderBg.Size = UDim2.new(1, -20, 0, 5)
    sliderBg.Position = UDim2.new(0, 10, 1, -16)
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    sliderBg.ZIndex = 7
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0, 3)

    local sliderFill = Instance.new("Frame", sliderBg)
    sliderFill.Size = UDim2.new(math.clamp((default - min) / (max - min), 0, 1), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderFill.ZIndex = 8
    registerObj(sliderFill, "Accent")
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0, 3)

    local sliderBtn = Instance.new("TextButton", sliderBg)
    sliderBtn.Size = UDim2.new(0, 14, 0, 14)
    sliderBtn.Position = UDim2.new(math.clamp((default - min) / (max - min), 0, 1), -7, 0.5, -7)
    sliderBtn.BackgroundColor3 = Color3.new(1,1,1)
    sliderBtn.Text = ""
    sliderBtn.ZIndex = 9
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
    box.BackgroundColor3 = Color3.new(0, 0, 0)
    AWD_RegisterLocalized(box, " " .. text)
    box.TextColor3 = Color3.fromRGB(200, 200, 220)
    box.TextSize = 14
    box.Font = Enum.Font.GothamBold
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.TextStrokeTransparency = 1
    box.ZIndex = 7
    box.LayoutOrder = #parent:GetChildren()
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
AA = {
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
                        local screenPos, onScreen = cam:WorldToViewportPoint(aimPos)
                        if onScreen and screenPos.Z > 0 then
                            local mousePos = UIS:GetMouseLocation()
                            local dx = screenPos.X - mousePos.X
                            local dy = screenPos.Y - mousePos.Y
                            local dist = math.sqrt(dx * dx + dy * dy)

                            if dist > 2.5 then
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

function AnanistanAimSetupSilentHook() AA.setupSilent() end
function AnanistanAimStopLoop() AA.stopLoop() end
function AnanistanAimFeatureActive(f) return AA.active(f) end
function AnanistanAimSyncAliases() end

menuToggleKey = Enum.KeyCode.Insert
espToggleKey = Enum.KeyCode.T
settingESPKey = false
settingMenuKey = false


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
    if not player or not TeleportService then
        notify("Rejoin", "Teleport servisi veya LocalPlayer bulunamadı.")
        return
    end
    if not game.JobId or game.JobId == "" then
        notify("Rejoin", "Sunucu kimliği alınamadı; normal teleport deneniyor.")
        local ok, err = pcall(function() TeleportService:Teleport(game.PlaceId, player) end)
        if not ok then notify("Rejoin başarısız", tostring(err)) end
        return
    end
    local ok, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
    end)
    if ok then
        notify("Rejoin", "Mevcut sunucuya yeniden bağlanma isteği gönderildi.")
    else
        notify("Rejoin", "Aynı sunucuya katılma başarısız; normal teleport deneniyor.")
        local fallbackOk, fallbackErr = pcall(function()
            TeleportService:Teleport(game.PlaceId, player)
        end)
        if not fallbackOk then notify("Rejoin başarısız", tostring(fallbackErr or err)) end
    end
end

pcall(function()
    TeleportService.TeleportInitFailed:Connect(function(failedPlayer, result, message)
        if failedPlayer == player then
            notify("Teleport başarısız", tostring(message or result or "Bilinmeyen teleport hatası"))
        end
    end)
end)

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

-- Tabs oluştur
tabMain, tD1 = CreateTab("Ana Sayfa")
tabPlayer, tD2 = CreateTab("Oyuncu")
tabUlasim, tD6 = CreateTab("Ulaşım")
tabStudio, tDStudio = CreateTab("Studio")
tabGames, tDGames = CreateTab("Oyunlar")
tabSpider, tD5 = CreateTab("Grapple")
tabVisuals, tD3 = CreateTab("Görseller")
tabAimbot, tDAimbot = CreateTab("Aimbot")
tabSettings, tD4 = CreateTab("Ayarlar")
tabDesigner, tD8 = CreateTab("Dizayn")
tabSlots, tD9 = tabDesigner, tD8
_G.ananistwaffendivisionTabPlayers, _G.ananistwaffendivisionTabPlayersData = CreateTab("Oyuncular")
tabUsers, tDUsers = CreateTab("Kullanıcılar")
tabScripts, tDScripts = CreateTab("Scriptler")
tabScan, tDScan = CreateTab("Tarama")
_G.ananistwaffendivisionTabPlayersData.Btn.TextSize = 12
tD1.Btn.LayoutOrder, tD2.Btn.LayoutOrder, tD6.Btn.LayoutOrder = 1, 2, 3
tDStudio.Btn.LayoutOrder, tDGames.Btn.LayoutOrder, tD5.Btn.LayoutOrder = 4, 5, 6
tD3.Btn.LayoutOrder, tDAimbot.Btn.LayoutOrder, tD4.Btn.LayoutOrder = 7, 8, 9
tD8.Btn.LayoutOrder, _G.ananistwaffendivisionTabPlayersData.Btn.LayoutOrder, tDScripts.Btn.LayoutOrder = 10, 11, 12
tDUsers.Btn.LayoutOrder = 13
tDScan.Btn.LayoutOrder = 14


-- [[ AWD UI STYLES: layout + visual presets ]] --
-- ANA UI is the untouched default layout. All navigation labels remain text-only.
local awdStyleNames = {
    "ANA UI", "Altta Tablar", "Üstte Tablar", "Cam UI", "Modern UI",
    "Future UI", "EkranÜstü Tablar", "Sağda Tablar", "Solda Tablar",
    "Efektli UI", "Minimal UI", "Kompakt UI", "Geniş Panel",
    "Kart UI", "Terminal UI", "Neon UI", "Çift Sıra Tablar", "Köşeli UI"
}
local awdStylePath = "AWD_HUB_UI_STYLE_V3.txt"
local awdSelectedStyle = "ANA UI"
pcall(function()
    if isfile and readfile and isfile(awdStylePath) then
        local saved = tostring(readfile(awdStylePath))
        for _, name in ipairs(awdStyleNames) do
            if name == saved then awdSelectedStyle = saved break end
        end
    end
end)

local awdOriginalVisual = {
    navColor = tabNav.BackgroundColor3, navTransparency = tabNav.BackgroundTransparency,
    strokeColor = sideStroke.Color, strokeTransparency = sideStroke.Transparency,
    strokeThickness = sideStroke.Thickness, corner = sideCorner.CornerRadius,
    mainColor = mainFrame.BackgroundColor3, mainTransparency = mainFrame.BackgroundTransparency
}

local function awdNavFlow(horizontal, compact, twoRows)
    tabLayout.FillDirection = horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
    tabLayout.Padding = UDim.new(0, (compact and 2) or (twoRows and 5) or 4)
    navCaption.Visible = not horizontal
    if horizontal then
        navCaption.Size = UDim2.new(0, 0, 0, 0)
        tabNav.ScrollingDirection = Enum.ScrollingDirection.X
        tabNav.AutomaticCanvasSize = Enum.AutomaticSize.X
        sidePadding.PaddingTop, sidePadding.PaddingBottom = UDim.new(0, 4), UDim.new(0, 4)
        sidePadding.PaddingLeft, sidePadding.PaddingRight = UDim.new(0, 5), UDim.new(0, 5)
        for _, t in ipairs(tabs) do
            t.Btn.TextXAlignment = Enum.TextXAlignment.Center
            t.Btn.Text = t.Btn.Text:gsub("^%s+", "")
            t.Btn.Size = UDim2.new(0, compact and 92 or 116, 1, -8)
        end
    else
        navCaption.Size = UDim2.new(1, 0, 0, 16)
        tabNav.ScrollingDirection = Enum.ScrollingDirection.Y
        tabNav.AutomaticCanvasSize = Enum.AutomaticSize.Y
        sidePadding.PaddingTop, sidePadding.PaddingBottom = UDim.new(0, 3), UDim.new(0, 3)
        sidePadding.PaddingLeft, sidePadding.PaddingRight = UDim.new(0, 4), UDim.new(0, 4)
        for _, t in ipairs(tabs) do
            t.Btn.TextXAlignment = Enum.TextXAlignment.Left
            if not t.Btn.Text:match("^   ") then t.Btn.Text = "   " .. t.Btn.Text end
            t.Btn.Size = UDim2.new(1, 0, 0, compact and 34 or 42)
        end
    end
end

local function awdApplyVisual(style)
    -- Reset to the hub's original material before applying each preset.
    tabNav.BackgroundColor3, tabNav.BackgroundTransparency = awdOriginalVisual.navColor, awdOriginalVisual.navTransparency
    sideStroke.Color, sideStroke.Transparency, sideStroke.Thickness = awdOriginalVisual.strokeColor, awdOriginalVisual.strokeTransparency, awdOriginalVisual.strokeThickness
    sideCorner.CornerRadius = awdOriginalVisual.corner
    mainFrame.BackgroundColor3, mainFrame.BackgroundTransparency = awdOriginalVisual.mainColor, awdOriginalVisual.mainTransparency
    sideGlassGradient.Enabled = true
    if style == "Cam UI" then
        tabNav.BackgroundColor3, tabNav.BackgroundTransparency = Color3.fromRGB(115, 145, 185), 0.66
        sideStroke.Color, sideStroke.Transparency, sideStroke.Thickness = Color3.fromRGB(190, 220, 255), 0.35, 1.4
        sideCorner.CornerRadius = UDim.new(0, 19)
        sideGlassGradient.Enabled = true
    elseif style == "Modern UI" then
        tabNav.BackgroundColor3, tabNav.BackgroundTransparency = Color3.fromRGB(25, 29, 39), 0.02
        sideStroke.Color, sideStroke.Transparency, sideStroke.Thickness = Color3.fromRGB(90, 105, 130), 0.35, 1
        sideCorner.CornerRadius = UDim.new(0, 8)
        sideGlassGradient.Enabled = false
    elseif style == "Future UI" then
        tabNav.BackgroundColor3, tabNav.BackgroundTransparency = Color3.fromRGB(8, 22, 39), 0.08
        sideStroke.Color, sideStroke.Transparency, sideStroke.Thickness = Color3.fromRGB(45, 190, 255), 0.18, 1.6
        sideCorner.CornerRadius = UDim.new(0, 5)
        sideGlassGradient.Enabled = false
    elseif style == "Efektli UI" then
        tabNav.BackgroundColor3, tabNav.BackgroundTransparency = Color3.fromRGB(24, 18, 42), 0.12
        sideStroke.Color, sideStroke.Transparency, sideStroke.Thickness = Color3.fromRGB(165, 100, 255), 0.12, 2
        sideCorner.CornerRadius = UDim.new(0, 17)
        sideGlassGradient.Enabled = true
    elseif style == "Minimal UI" then
        tabNav.BackgroundColor3, tabNav.BackgroundTransparency = Color3.fromRGB(10, 13, 18), 0.02
        sideStroke.Transparency, sideStroke.Thickness = 1, 0
        sideCorner.CornerRadius = UDim.new(0, 3)
        sideGlassGradient.Enabled = false
    elseif style == "Kompakt UI" then
        tabNav.BackgroundColor3, tabNav.BackgroundTransparency = Color3.fromRGB(15, 21, 30), 0.04
        sideStroke.Transparency, sideStroke.Thickness = 0.8, 1
        sideCorner.CornerRadius = UDim.new(0, 7)
        sideGlassGradient.Enabled = false
    elseif style == "Geniş Panel" then
        tabNav.BackgroundColor3, tabNav.BackgroundTransparency = Color3.fromRGB(17, 27, 42), 0.05
        sideStroke.Color, sideStroke.Transparency, sideStroke.Thickness = Color3.fromRGB(100, 145, 195), 0.55, 1
        sideCorner.CornerRadius = UDim.new(0, 16)
        sideGlassGradient.Enabled = true
    elseif style == "Kart UI" then
        tabNav.BackgroundColor3, tabNav.BackgroundTransparency = Color3.fromRGB(28, 34, 46), 0.02
        sideStroke.Color, sideStroke.Transparency, sideStroke.Thickness = Color3.fromRGB(115, 130, 155), 0.55, 1
        sideCorner.CornerRadius = UDim.new(0, 22)
        sideGlassGradient.Enabled = false
    elseif style == "Terminal UI" then
        tabNav.BackgroundColor3, tabNav.BackgroundTransparency = Color3.fromRGB(3, 19, 13), 0.02
        sideStroke.Color, sideStroke.Transparency, sideStroke.Thickness = Color3.fromRGB(55, 190, 115), 0.25, 1
        sideCorner.CornerRadius = UDim.new(0, 2)
        sideGlassGradient.Enabled = false
    elseif style == "Neon UI" then
        tabNav.BackgroundColor3, tabNav.BackgroundTransparency = Color3.fromRGB(20, 10, 34), 0.05
        sideStroke.Color, sideStroke.Transparency, sideStroke.Thickness = Color3.fromRGB(255, 65, 205), 0.08, 2
        sideCorner.CornerRadius = UDim.new(0, 13)
        sideGlassGradient.Enabled = true
    elseif style == "Köşeli UI" then
        tabNav.BackgroundColor3, tabNav.BackgroundTransparency = Color3.fromRGB(18, 24, 34), 0.02
        sideStroke.Color, sideStroke.Transparency, sideStroke.Thickness = Color3.fromRGB(100, 115, 140), 0.4, 1
        sideCorner.CornerRadius = UDim.new(0, 0)
        sideGlassGradient.Enabled = false
    end
end

local function applyUILayout(styleName)
    local style = styleName or "ANA UI"
    local horizontal = false
    local compact = false
    local twoRows = false
    local navPos, navSize, contentPos, contentSize
    local w = mainFrame.AbsoluteSize.X
    if style == "ANA UI" or style == "Solda Tablar" then
        navPos, navSize = UDim2.new(0,14,0,76), UDim2.new(0,172,1,-114)
        contentPos, contentSize = UDim2.new(0,204,0,88), UDim2.new(1,-218,1,-126)
    elseif style == "Altta Tablar" then
        horizontal = true
        navPos, navSize = UDim2.new(0,14,1,-78), UDim2.new(1,-28,0,48)
        contentPos, contentSize = UDim2.new(0,14,0,76), UDim2.new(1,-28,1,-164)
    elseif style == "Üstte Tablar" then
        horizontal = true
        navPos, navSize = UDim2.new(0,14,0,66), UDim2.new(1,-28,0,48)
        contentPos, contentSize = UDim2.new(0,14,0,124), UDim2.new(1,-28,1,-162)
    elseif style == "Cam UI" then
        horizontal = true
        navPos, navSize = UDim2.new(0,22,0,70), UDim2.new(1,-44,0,50)
        contentPos, contentSize = UDim2.new(0,22,0,132), UDim2.new(1,-44,1,-170)
    elseif style == "Modern UI" then
        horizontal = true
        navPos, navSize = UDim2.new(0,14,0,76), UDim2.new(1,-28,0,42)
        contentPos, contentSize = UDim2.new(0,14,0,130), UDim2.new(1,-28,1,-168)
        compact = true
    elseif style == "Future UI" then
        horizontal = true
        navPos, navSize = UDim2.new(0,14,0,58), UDim2.new(1,-28,0,56)
        contentPos, contentSize = UDim2.new(0,14,0,128), UDim2.new(1,-28,1,-166)
    elseif style == "EkranÜstü Tablar" then
        horizontal = true
        navPos, navSize = UDim2.new(0,0,0,0), UDim2.new(1,0,0,52)
        contentPos, contentSize = UDim2.new(0,14,0,66), UDim2.new(1,-28,1,-104)
    elseif style == "Sağda Tablar" then
        navPos, navSize = UDim2.new(1,-186,0,76), UDim2.new(0,172,1,-114)
        contentPos, contentSize = UDim2.new(0,14,0,88), UDim2.new(1,-218,1,-126)
    elseif style == "Efektli UI" then
        navPos, navSize = UDim2.new(0,18,0,84), UDim2.new(0,190,1,-130)
        contentPos, contentSize = UDim2.new(0,226,0,84), UDim2.new(1,-244,1,-130)
    elseif style == "Minimal UI" then
        horizontal = true
        navPos, navSize = UDim2.new(0,14,0,72), UDim2.new(1,-28,0,34)
        contentPos, contentSize = UDim2.new(0,14,0,118), UDim2.new(1,-28,1,-156)
        compact = true
    elseif style == "Kompakt UI" then
        navPos, navSize = UDim2.new(0,10,0,76), UDim2.new(0,142,1,-114)
        contentPos, contentSize = UDim2.new(0,172,0,88), UDim2.new(1,-186,1,-126)
        compact = true
    elseif style == "Geniş Panel" then
        navPos, navSize = UDim2.new(0,14,0,76), UDim2.new(0,220,1,-114)
        contentPos, contentSize = UDim2.new(0,252,0,88), UDim2.new(1,-266,1,-126)
    elseif style == "Kart UI" then
        navPos, navSize = UDim2.new(0,20,0,92), UDim2.new(0,188,1,-146)
        contentPos, contentSize = UDim2.new(0,230,0,76), UDim2.new(1,-244,1,-114)
    elseif style == "Terminal UI" then
        navPos, navSize = UDim2.new(0,14,0,76), UDim2.new(0,184,1,-114)
        contentPos, contentSize = UDim2.new(0,216,0,88), UDim2.new(1,-230,1,-126)
    elseif style == "Neon UI" then
        horizontal = true
        navPos, navSize = UDim2.new(0.04,0,0,68), UDim2.new(0.92,0,0,48)
        contentPos, contentSize = UDim2.new(0,14,0,128), UDim2.new(1,-28,1,-166)
    elseif style == "Çift Sıra Tablar" then
        horizontal, twoRows = true, true
        navPos, navSize = UDim2.new(0,14,0,60), UDim2.new(1,-28,0,66)
        contentPos, contentSize = UDim2.new(0,14,0,138), UDim2.new(1,-28,1,-176)
    elseif style == "Köşeli UI" then
        navPos, navSize = UDim2.new(0,14,0,76), UDim2.new(0,172,1,-114)
        contentPos, contentSize = UDim2.new(0,204,0,88), UDim2.new(1,-218,1,-126)
    end
    awdNavFlow(horizontal, compact, twoRows)
    if twoRows then
        local half = math.ceil(#tabs / 2)
        for _, t in ipairs(tabs) do t.Btn.Size = UDim2.new(0, math.max(84, math.floor((w-52)/half)), 0, 26) end
    elseif horizontal then
        local count = math.max(#tabs, 1)
        local width = math.max(compact and 78 or 92, math.floor((w-54) / math.min(count, 7)))
        for _, t in ipairs(tabs) do t.Btn.Size = UDim2.new(0, width, 1, -8) end
    end
    tabNav.Position, tabNav.Size = navPos, navSize
    tabNav.AutomaticSize = Enum.AutomaticSize.None
    tabNav.ClipsDescendants, tabNav.ScrollingEnabled = true, true
    contentArea.Position, contentArea.Size = contentPos, contentSize
    sideOverlay.Position, sideOverlay.Size, sideOverlay.Visible = navPos, navSize, true
    for _, t in ipairs(tabs) do t.Frame.Position, t.Frame.Size = UDim2.new(0,0,0,0), UDim2.new(1,0,1,0) end
    bottomBar.Position = UDim2.new(0,14,1,-34)
    bottomBar.Visible = true
    awdApplyVisual(style)
    awdSelectedStyle = style
end

local stylePage, styleTabData = CreateTab("Stil")
styleTabData.Btn.LayoutOrder = 13
AddLabel(stylePage, "ARAYÜZ STİLLERİ", false)
AddLabel(stylePage, "Sekmelerin konumunu ve arayüzün görünümünü değiştiren stillerden birini seç. ANA UI orijinal tasarımdır.", true)
for index, styleName in ipairs(awdStyleNames) do
    local button = AddButton(stylePage, styleName, function()
        applyUILayout(styleName)
        pcall(function() if writefile then writefile(awdStylePath, styleName) end end)
        if notify then notify("Arayüz Stili", styleName .. " uygulandı") end
    end)
    button.LayoutOrder = index + 10
end
applyUILayout(awdSelectedStyle)

StatsService = game:GetService("Stats")
paletteKey = Enum.KeyCode.K
paletteCapture = false
awdNotificationHistory = {}
awdDeveloperLog = {}
paletteCommands = {}

function awdLog(message, kind)
    local stamp = os.date("%H:%M:%S")
    table.insert(awdDeveloperLog, 1, "[" .. stamp .. "] [" .. tostring(kind or "INFO") .. "] " .. tostring(message))
    while #awdDeveloperLog > 35 do table.remove(awdDeveloperLog) end
end

function awdNotify(title, message, duration)
    local item = {time = os.date("%H:%M:%S"), title = tostring(title or "AWD Hub"), message = tostring(message or "")}
    table.insert(awdNotificationHistory, 1, item)
    while #awdNotificationHistory > 30 do table.remove(awdNotificationHistory) end
    awdLog(item.title .. ": " .. item.message, "NOTICE")
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = item.title,
            Text = item.message,
            Duration = duration or 3
        })
    end)
end

function awdMakePanel(parent, name, size, position, z)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = Color3.fromRGB(13, 18, 27)
    frame.BorderSizePixel = 0
    frame.ZIndex = z or 30
    frame.Visible = false
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(95, 125, 170)
    stroke.Transparency = 0.45
    stroke.Thickness = 1
    return frame
end

-- [[ ANA SAYFA // KULLANICI PROFİL KARTI ]] --
local function awdCreateProfileHeader(parent)
    local card = Instance.new("Frame")
    card.Name = "AWD_UserProfileHeader"
    card.Size = UDim2.new(1, 0, 0, 174)
    card.BackgroundColor3 = Color3.fromRGB(13, 13, 13)
    card.BorderSizePixel = 0
    card.LayoutOrder = -100
    card.ZIndex = 8
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

    local border = Instance.new("UIStroke")
    border.Color = Color3.fromRGB(85, 85, 85)
    border.Thickness = 1
    border.Transparency = 0.2
    border.Parent = card

    local avatar = Instance.new("ImageLabel")
    avatar.Name = "UserAvatar"
    avatar.Size = UDim2.fromOffset(112, 112)
    avatar.Position = UDim2.fromOffset(16, 27)
    avatar.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    avatar.BorderSizePixel = 0
    avatar.ScaleType = Enum.ScaleType.Crop
    avatar.ZIndex = 9
    avatar.Parent = card
    Instance.new("UICorner", avatar).CornerRadius = UDim.new(0, 10)
    local avatarStroke = Instance.new("UIStroke", avatar)
    avatarStroke.Color = Color3.fromRGB(145, 145, 145)
    avatarStroke.Thickness = 1

    local welcome = Instance.new("TextLabel")
    welcome.Name = "WelcomeText"
    welcome.BackgroundTransparency = 1
    welcome.Position = UDim2.fromOffset(144, 16)
    welcome.Size = UDim2.new(1, -160, 0, 29)
    welcome.Font = Enum.Font.GothamBold
    welcome.Text = "Welcome, " .. tostring(player.Name)
    welcome.TextColor3 = Color3.fromRGB(245, 245, 245)
    welcome.TextSize = 21
    welcome.TextXAlignment = Enum.TextXAlignment.Left
    welcome.TextTruncate = Enum.TextTruncate.AtEnd
    welcome.ZIndex = 9
    welcome.Parent = card

    local username = Instance.new("TextLabel")
    username.Name = "UsernameText"
    username.BackgroundTransparency = 1
    username.Position = UDim2.fromOffset(145, 45)
    username.Size = UDim2.new(1, -160, 0, 18)
    username.Font = Enum.Font.Gotham
    username.Text = "@" .. tostring(player.Name)
    username.TextColor3 = Color3.fromRGB(160, 160, 160)
    username.TextSize = 12
    username.TextXAlignment = Enum.TextXAlignment.Left
    username.ZIndex = 9
    username.Parent = card

    local sharingStatus = Instance.new("TextLabel")
    sharingStatus.Name = "UserSharingStatus"
    sharingStatus.BackgroundTransparency = 1
    sharingStatus.Position = UDim2.fromOffset(145, 69)
    sharingStatus.Size = UDim2.new(1, -160, 0, 20)
    sharingStatus.Font = Enum.Font.GothamBold
    sharingStatus.Text = "KULLANICILAR PAYLAŞILIYOR: HAYIR"
    sharingStatus.TextColor3 = Color3.fromRGB(225, 170, 95)
    sharingStatus.TextSize = 10
    sharingStatus.TextXAlignment = Enum.TextXAlignment.Left
    sharingStatus.TextTruncate = Enum.TextTruncate.AtEnd
    sharingStatus.ZIndex = 9
    sharingStatus.Parent = card
    _G.AWD_SharingStatusLabel = sharingStatus

    local stats = Instance.new("Frame")
    stats.Name = "ProfileStats"
    stats.BackgroundTransparency = 1
    stats.Position = UDim2.fromOffset(144, 96)
    stats.Size = UDim2.new(1, -160, 0, 66)
    stats.ZIndex = 9
    stats.Parent = card
    local grid = Instance.new("UIGridLayout", stats)
    grid.CellSize = UDim2.new(0.5, -5, 0, 29)
    grid.CellPadding = UDim2.fromOffset(8, 4)
    grid.SortOrder = Enum.SortOrder.LayoutOrder

    local statLabels = {}
    local statData = {
        {key = "Age", title = "ACCOUNT AGE", value = tostring(player.AccountAge) .. " days"},
        {key = "Friends", title = "FRIENDS", value = "Loading..."},
        {key = "Followers", title = "FOLLOWERS", value = "Loading..."},
        {key = "Following", title = "FOLLOWING", value = "Loading..."},
    }
    for index, item in ipairs(statData) do
        local tile = Instance.new("Frame")
        tile.Name = item.key .. "Stat"
        tile.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
        tile.BorderSizePixel = 0
        tile.LayoutOrder = index
        tile.ZIndex = 9
        tile.Parent = stats
        Instance.new("UICorner", tile).CornerRadius = UDim.new(0, 6)

        local title = Instance.new("TextLabel")
        title.BackgroundTransparency = 1
        title.Position = UDim2.fromOffset(8, 3)
        title.Size = UDim2.new(1, -12, 0, 12)
        title.Font = Enum.Font.GothamBold
        title.Text = item.title
        title.TextColor3 = Color3.fromRGB(145, 145, 145)
        title.TextSize = 8
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 10
        title.Parent = tile

        local value = Instance.new("TextLabel")
        value.Name = "Value"
        value.BackgroundTransparency = 1
        value.Position = UDim2.fromOffset(8, 15)
        value.Size = UDim2.new(1, -12, 0, 16)
        value.Font = Enum.Font.GothamSemibold
        value.Text = item.value
        value.TextColor3 = Color3.fromRGB(235, 235, 235)
        value.TextSize = 12
        value.TextXAlignment = Enum.TextXAlignment.Left
        value.ZIndex = 10
        value.Parent = tile
        statLabels[item.key] = value
    end

    task.spawn(function()
        local ok, image = pcall(function()
            return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        end)
        if ok and avatar and avatar.Parent then avatar.Image = image end
    end)

    -- Count endpoints are fetched independently so a slow endpoint cannot freeze UI creation.
    local function fetchCount(endpoint, key)
        task.spawn(function()
            local ok, result = pcall(function()
                local body = game:HttpGet("https://friends.roblox.com/v1/users/" .. tostring(player.UserId) .. "/" .. endpoint .. "/count")
                local decoded = HttpService:JSONDecode(body)
                return tonumber(decoded.count)
            end)
            if statLabels[key] and statLabels[key].Parent then
                statLabels[key].Text = (ok and result) and tostring(result) or "Unavailable"
            end
        end)
    end
    fetchCount("friends", "Friends")
    fetchCount("followers", "Followers")
    fetchCount("followings", "Following")
    return card
end

awdCreateProfileHeader(tabMain)
AddLabel(tabMain, "AWD COMMAND CENTER", false)
AddLabel(tabMain, "Kontrol paneli • canlı oturum bilgileri • hızlı erişim", true)
dashboardStats = AddLabel(tabMain, "Yükleniyor...", true)
dashboardQuick = AddLabel(tabMain, "QUICK ACCESS", false)
AddButton(tabMain, "Komut Paletini Aç  [Ctrl + K]", function()
    if _G.AWD_OpenCommandPalette then _G.AWD_OpenCommandPalette() end
end)
AddButton(tabMain, "Tema Stüdyosuna Git", function() if tD8 and tD8.Select then tD8.Select() end end)
AddButton(tabMain, "Ayarlar ve Profil Yönetimi", function() if tD4 and tD4.Select then tD4.Select() end end)
AddButton(tabMain, "Oyuncu Araçlarına Git", function() if tD2 and tD2.Select then tD2.Select() end end)

paletteShade = Instance.new("TextButton")
paletteShade.Name = "AWD_PaletteShade"
paletteShade.Size = UDim2.fromScale(1, 1)
paletteShade.BackgroundColor3 = Color3.new(0, 0, 0)
paletteShade.BackgroundTransparency = 0.42
paletteShade.Text = ""
paletteShade.AutoButtonColor = false
paletteShade.Visible = false
paletteShade.ZIndex = 29
paletteShade.Parent = screenGui
palette = awdMakePanel(screenGui, "AWD_CommandPalette", UDim2.new(0, 470, 0, 430), UDim2.new(0.5, -235, 0.5, -215), 30)
paletteShade.MouseButton1Click:Connect(function() palette.Visible = false; paletteShade.Visible = false end)
paletteTitle = Instance.new("TextLabel", palette)
paletteTitle.Size = UDim2.new(1, -28, 0, 30)
paletteTitle.Position = UDim2.new(0, 14, 0, 10)
paletteTitle.BackgroundTransparency = 1
paletteTitle.Text = "COMMAND PALETTE"
paletteTitle.TextColor3 = Color3.fromRGB(230, 238, 250)
paletteTitle.Font = Enum.Font.GothamBold
paletteTitle.TextSize = 14
paletteTitle.TextXAlignment = Enum.TextXAlignment.Left
paletteTitle.ZIndex = 31
paletteHint = Instance.new("TextLabel", palette)
paletteHint.Size = UDim2.new(1, -28, 0, 18)
paletteHint.Position = UDim2.new(0, 14, 0, 37)
paletteHint.BackgroundTransparency = 1
paletteHint.Text = "Sekme veya araç ara • ESC ile kapat"
paletteHint.TextColor3 = Color3.fromRGB(125, 145, 170)
paletteHint.Font = Enum.Font.Gotham
paletteHint.TextSize = 10
paletteHint.TextXAlignment = Enum.TextXAlignment.Left
paletteHint.ZIndex = 31
paletteSearch = Instance.new("TextBox", palette)
paletteSearch.Size = UDim2.new(1, -28, 0, 42)
paletteSearch.Position = UDim2.new(0, 14, 0, 64)
paletteSearch.BackgroundColor3 = Color3.fromRGB(22, 29, 42)
paletteSearch.TextColor3 = Color3.fromRGB(240, 245, 255)
paletteSearch.PlaceholderColor3 = Color3.fromRGB(120, 135, 158)
paletteSearch.PlaceholderText = "Ara: sekme, tema, ayar..."
paletteSearch.Text = ""
paletteSearch.ClearTextOnFocus = false
paletteSearch.Font = Enum.Font.Gotham
paletteSearch.TextSize = 13
paletteSearch.TextXAlignment = Enum.TextXAlignment.Left
paletteSearch.ZIndex = 32
Instance.new("UICorner", paletteSearch).CornerRadius = UDim.new(0, 9)
paletteSearchPad = Instance.new("UIPadding", paletteSearch)
paletteSearchPad.PaddingLeft = UDim.new(0, 12)
paletteResults = Instance.new("ScrollingFrame", palette)
paletteResults.Size = UDim2.new(1, -28, 1, -126)
paletteResults.Position = UDim2.new(0, 14, 0, 116)
paletteResults.BackgroundTransparency = 1
paletteResults.BorderSizePixel = 0
paletteResults.ScrollBarThickness = 3
paletteResults.CanvasSize = UDim2.new(0, 0, 0, 0)
paletteResults.AutomaticCanvasSize = Enum.AutomaticSize.Y
paletteResults.ZIndex = 31
paletteLayout = Instance.new("UIListLayout", paletteResults)
paletteLayout.Padding = UDim.new(0, 6)
paletteLayout.SortOrder = Enum.SortOrder.LayoutOrder
palettePad = Instance.new("UIPadding", paletteResults)
palettePad.PaddingBottom = UDim.new(0, 6)

function awdAddPaletteCommand(label, category, callback)
    table.insert(paletteCommands, {label = label, category = category or "ACTION", callback = callback})
end
for _, tab in ipairs(tabs) do
    local captured = tab
    local tabName = captured.Btn.Text:gsub("^%s+", "")
    awdAddPaletteCommand("Sekmeye Git: " .. tabName, "NAVIGATION", function()
        if captured.Select then captured.Select() end
        palette.Visible = false; paletteShade.Visible = false
    end)
end
awdAddPaletteCommand("Tema: Varsayılan", "THEME", function() applyTheme("ϟϟ Theme"); palette.Visible = false; paletteShade.Visible = false end)
awdAddPaletteCommand("Tema: Cyberpunk", "THEME", function() applyTheme("Cyberpunk"); palette.Visible = false; paletteShade.Visible = false end)
awdAddPaletteCommand("Tema: Ocean Deep", "THEME", function() applyTheme("Ocean Deep"); palette.Visible = false; paletteShade.Visible = false end)
awdAddPaletteCommand("Tema: Dracula", "THEME", function() applyTheme("Dracula"); palette.Visible = false; paletteShade.Visible = false end)
awdAddPaletteCommand("Tema Stüdyosunu Aç", "DESIGN", function() tD8.Select(); palette.Visible = false; paletteShade.Visible = false end)
awdAddPaletteCommand("Bildirim Geçmişini Aç", "SYSTEM", function() tD4.Select(); palette.Visible = false; paletteShade.Visible = false end)

function refreshPalette(query)
    for _, child in ipairs(paletteResults:GetChildren()) do
        if child:IsA("GuiObject") and not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end
    local q = string.lower(tostring(query or ""))
    local shown = 0
    for _, item in ipairs(paletteCommands) do
        if q == "" or string.find(string.lower(item.label), q, 1, true) or string.find(string.lower(item.category), q, 1, true) then
            shown += 1
            local row = Instance.new("TextButton")
            row.Size = UDim2.new(1, -4, 0, 38)
            row.BackgroundColor3 = Color3.fromRGB(22, 29, 42)
            row.Text = ""
            row.AutoButtonColor = false
            row.LayoutOrder = shown
            row.ZIndex = 32
            row.Parent = paletteResults
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
            local name = Instance.new("TextLabel", row)
            name.Size = UDim2.new(1, -100, 1, 0)
            name.Position = UDim2.new(0, 11, 0, 0)
            name.BackgroundTransparency = 1
            name.Text = item.label
            name.TextColor3 = Color3.fromRGB(220, 230, 245)
            name.TextSize = 12
            name.Font = Enum.Font.GothamMedium
            name.TextXAlignment = Enum.TextXAlignment.Left
            name.ZIndex = 33
            local tag = Instance.new("TextLabel", row)
            tag.Size = UDim2.new(0, 82, 1, 0)
            tag.Position = UDim2.new(1, -90, 0, 0)
            tag.BackgroundTransparency = 1
            tag.Text = item.category
            tag.TextColor3 = Color3.fromRGB(115, 145, 185)
            tag.TextSize = 9
            tag.Font = Enum.Font.Code
            tag.TextXAlignment = Enum.TextXAlignment.Right
            tag.ZIndex = 33
            row.MouseEnter:Connect(function() smoothTween(row, {BackgroundColor3 = Color3.fromRGB(38, 52, 73)}, 0.1) end)
            row.MouseLeave:Connect(function() smoothTween(row, {BackgroundColor3 = Color3.fromRGB(22, 29, 42)}, 0.12) end)
            row.MouseButton1Click:Connect(function() pcall(item.callback); awdLog("Command executed: " .. item.label) end)
        end
    end
    if shown == 0 then
        local empty = Instance.new("TextLabel", paletteResults)
        empty.Size = UDim2.new(1, 0, 0, 38)
        empty.BackgroundTransparency = 1
        empty.Text = "Sonuç bulunamadı"
        empty.TextColor3 = Color3.fromRGB(140, 150, 170)
        empty.Font = Enum.Font.Gotham
        empty.TextSize = 12
        empty.ZIndex = 32
    end
end
paletteSearch:GetPropertyChangedSignal("Text"):Connect(function() refreshPalette(paletteSearch.Text) end)
refreshPalette("")
function openPalette()
    palette.Visible = true
    paletteShade.Visible = true
    paletteSearch.Text = ""
    refreshPalette("")
    task.defer(function() pcall(function() paletteSearch:CaptureFocus() end) end)
end
_G.AWD_OpenCommandPalette = openPalette

UIS.InputBegan:Connect(function(input, processed)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if paletteCapture then
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            paletteKey = input.KeyCode
            paletteCapture = false
            if _G.AWD_PaletteKeyLabel then _G.AWD_PaletteKeyLabel.Text = "Komut paleti: " .. paletteKey.Name end
            awdNotify("Keybind güncellendi", "Komut paleti: " .. paletteKey.Name, 2)
        end
        return
    end
    if input.KeyCode == Enum.KeyCode.Escape and palette.Visible then
        palette.Visible = false; paletteShade.Visible = false
        return
    end
    if input.KeyCode == paletteKey and (UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl)) then
        openPalette()
    end
end)

AddLabel(tabDesigner, "THEME STUDIO / LIVE CUSTOMIZATION", false)
AddLabel(tabDesigner, "Özel vurgu rengi, arayüz ölçeği ve animasyon hızını canlı düzenle.", true)
AddColorPicker(tabDesigner, "Özel vurgu rengi", themeData["Custom Designer"].Accent, function(color)
    themeData["Custom Designer"].Accent = color
    applyTheme("Custom Designer")
    awdLog("Custom accent updated")
end)
setScale = AddSlider(tabDesigner, "Arayüz ölçeği", 0.82, 1.18, 1, function(value)
    if menuScale then menuScale.Scale = value end
end)
setMotion = AddSlider(tabDesigner, "Animasyon hızı", 0.45, 1.8, 1, function(value)
    awdMotionMultiplier = value
end)
AddButton(tabDesigner, "Arayüz ölçeğini sıfırla", function() setScale(1); menuScale.Scale = 1 end)
AddButton(tabDesigner, "Animasyon hızını sıfırla", function() setMotion(1); awdMotionMultiplier = 1 end)
AddButton(tabDesigner, "Tema Stüdyosu: Özel temayı uygula", function() applyTheme("Custom Designer"); awdNotify("Tema uygulandı", "Custom Designer aktif", 2) end)

AddLabel(tabDesigner, "WIDGET SYSTEM", false)
AddToggle(tabDesigner, "Canlı alt durum çubuğu", true, function(state)
    bottomBar.Visible = state
end)
AddToggle(tabDesigner, "Ambient arka plan efektleri", true, function(state)
    if ambientLayer then ambientLayer.Visible = state end
end)
AddToggle(tabDesigner, "Blur efekti", true, function(state)
    if blurEffect then blurEffect.Size = state and 8 or 0 end
end)

AddLabel(tabSettings, "NOTIFICATION CENTER", false)
notificationSummary = AddLabel(tabSettings, "Henüz bildirim yok.", true)
AddButton(tabSettings, "Bildirim geçmişini yenile", function()
    local lines = {}
    for i = 1, math.min(#awdNotificationHistory, 8) do
        local n = awdNotificationHistory[i]
        table.insert(lines, n.time .. "  " .. n.title .. " — " .. n.message)
    end
    notificationSummary.Text = #lines > 0 and table.concat(lines, "\n") or "Henüz bildirim yok."
end)
AddButton(tabSettings, "Test bildirimi gönder", function() awdNotify("AWD Hub", "Bildirim merkezi düzgün çalışıyor.", 3) end)
AddButton(tabSettings, "Bildirim geçmişini temizle", function()
    for i = #awdNotificationHistory, 1, -1 do table.remove(awdNotificationHistory, i) end
    notificationSummary.Text = "Bildirim geçmişi temizlendi."
end)
AddLabel(tabSettings, "KEYBIND MANAGER", false)
paletteKeyLabel = AddLabel(tabSettings, "Komut paleti: LeftControl + " .. paletteKey.Name, false)
_G.AWD_PaletteKeyLabel = paletteKeyLabel
AddButton(tabSettings, "Komut paleti tuşunu değiştir", function()
    paletteCapture = true
    paletteKeyLabel.Text = "Komut paleti için bir tuşa bas..."
    awdNotify("Keybind", "Şimdi yeni tuşa bas.", 3)
end)
AddLabel(tabSettings, "DEVELOPER CONSOLE", false)
developerLogLabel = AddLabel(tabSettings, "Kayıt bekleniyor...", true)
AddButton(tabSettings, "Son sistem kayıtlarını göster", function()
    developerLogLabel.Text = #awdDeveloperLog > 0 and table.concat(awdDeveloperLog, "\n") or "Henüz kayıt yok."
end)
AddButton(tabSettings, "Sistem kayıtlarını temizle", function()
    for i = #awdDeveloperLog, 1, -1 do table.remove(awdDeveloperLog, i) end
    developerLogLabel.Text = "Kayıtlar temizlendi."
end)
AddLabel(tabSettings, "PROFILE SYSTEM", false)
AddLabel(tabSettings, "Mevcut AWD Config Manager; profil kaydetme, yükleme, silme ve liste yenileme işlemlerini yönetir.", true)

dashboardRunning = true
task.spawn(function()
    while dashboardRunning and screenGui and screenGui.Parent do
        task.wait(2)
        local fpsText = statusFPS and statusFPS.Text or "FPS / --"
        local memoryText = "-- MB"
        pcall(function() memoryText = string.format("%.1f MB", StatsService:GetTotalMemoryUsageMb()) end)
        local playerCount = #Players:GetPlayers()
        if dashboardStats and dashboardStats.Parent then
            dashboardStats.Text = "LIVE SESSION\nOyuncu: " .. playerCount .. "/" .. tostring(Players.MaxPlayers)
                .. "\n" .. fpsText .. "\nBellek: " .. memoryText
                .. "\nPlace ID: " .. tostring(game.PlaceId)
        end
    end
end)
screenGui.AncestryChanged:Connect(function(_, parent)
    if parent == nil then dashboardRunning = false end
end)
awdLog("AWD Command Center initialized")

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
            -- Playback cursor: avoid scanning every recorded frame on every render frame.
            local frameIndex = 1
            local lastHudUpdate = 0
            st.playbackConn = RunService.RenderStepped:Connect(function()
                if not st.playback then return end
                local elapsed = os.clock() - started
                if elapsed - lastHudUpdate >= 0.15 then
                    lastHudUpdate = elapsed
                    _G.ananistwaffendivisionBodycamSetHUD(true, "PLAYBACK", elapsed)
                end
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
                while frameIndex < #frames - 1 and elapsed > frames[frameIndex + 1].t do
                    frameIndex += 1
                end
                local a = frames[frameIndex]
                local b = frames[math.min(frameIndex + 1, #frames)]
                if not a or not b then return end
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
        if now < nextSample then return end
        nextSample = now + (1/12)
        _G.ananistwaffendivisionBodycamSetHUD(true, "REC", now)
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

Players = game:GetService("Players")
RunService = game:GetService("RunService")

_G.ananistwaffendivisionOrbitDistance = _G.ananistwaffendivisionOrbitDistance or 12
_G.ananistwaffendivisionOrbitSpeed = _G.ananistwaffendivisionOrbitSpeed or 1
_G.ananistwaffendivisionOrbitTarget = nil
_G.ananistwaffendivisionOrbitConnection = nil
_G.ananistwaffendivisionOrbitAngle = 0

if _G.ananistwaffendivisionOrbitConnection then
    _G.ananistwaffendivisionOrbitConnection:Disconnect()
    _G.ananistwaffendivisionOrbitConnection = nil
end

_G.ananistwaffendivisionTabPlayersTitle =
    AddLabel(_G.ananistwaffendivisionTabPlayers, "Oyuncular")

_G.ananistwaffendivisionTabPlayersHint =
    AddLabel(
        _G.ananistwaffendivisionTabPlayers,
        "Oyuncuları görüntüle ve karakter kontrollerini yönet",
        true
    )

-- [[ KULLANICILAR SEKME UI - CLOUDFLARE PRESENCE ]] --
-- Bu sürüm yalnızca dizini görüntüler; bu istemciden otomatik kullanıcı kaydı gönderilmez.
local AWD_PRESENCE_URL = "https://awd-presence.utkuatayilmaz.workers.dev"
local AWD_PresenceSessionId = HttpService:GenerateGUID(false)
local AWD_PresenceOptIn = (_G.AWD_PresenceConsentAccepted == true)
local AWD_PresenceHeartbeatRunning = false
local AWD_UserDirectoryCards = {}
local AWD_UserDirectoryTitle = AddLabel(tabUsers, "AWD KULLANICILARI")
local AWD_UserDirectoryHint = AddLabel(
    tabUsers,
    "Onay veren AWD HUB kullanıcıları burada listelenir. İsimler maskelenir; avatar Roblox profilinden yüklenir. Liste ve JOIN, harici Worker erişimine ve Roblox teleport izinlerine bağlıdır.",
    true
)
local AWD_UserDirectoryStatus = Instance.new("TextLabel")
AWD_UserDirectoryStatus.Name = "UserDirectoryStatus"
AWD_UserDirectoryStatus.Size = UDim2.new(1, -12, 0, 38)
AWD_UserDirectoryStatus.BackgroundTransparency = 1
AWD_UserDirectoryStatus.Font = Enum.Font.Gotham
AWD_UserDirectoryStatus.Text = "Onay durumuna göre kullanıcı dizini etkinleştiriliyor..."
AWD_UserDirectoryStatus.TextColor3 = Color3.fromRGB(175, 185, 205)
AWD_UserDirectoryStatus.TextSize = 12
AWD_UserDirectoryStatus.TextWrapped = true
AWD_UserDirectoryStatus.LayoutOrder = 9998
AWD_UserDirectoryStatus.Parent = tabUsers

local function AWD_PresenceRequest(method, path, payload)
    local req = getRequestFunction and getRequestFunction() or nil
    if not req then return nil, "Executor HTTP isteği desteklemiyor." end
    local requestData = {
        Url = AWD_PRESENCE_URL .. path,
        Method = method,
        Headers = { ["Content-Type"] = "application/json" }
    }
    if payload then requestData.Body = HttpService:JSONEncode(payload) end
    local ok, response = pcall(function() return req(requestData) end)
    if not ok or not response then return nil, tostring(response or "HTTP isteği başarısız") end
    local statusCode = tonumber(response.StatusCode or response.Status or 0) or 0
    local responseBody = response.Body or response.body or "{}"
    local decodedOk, decoded = pcall(function() return HttpService:JSONDecode(responseBody) end)
    if statusCode < 200 or statusCode >= 300 then
        return nil, decodedOk and tostring(decoded.error or ("HTTP " .. statusCode)) or ("HTTP " .. statusCode)
    end
    if not decodedOk then return nil, "Sunucudan geçersiz JSON geldi." end
    return decoded
end

local function AWD_MaskUsername(username)
    username = tostring(username or "User")
    if #username <= 1 then return username .. "*****" end
    return string.sub(username, 1, 1) .. string.rep("*", math.max(5, #username - 1))
end

local function AWD_ClearUserDirectoryCards()
    for _, card in ipairs(AWD_UserDirectoryCards) do
        pcall(function() card:Destroy() end)
    end
    table.clear(AWD_UserDirectoryCards)
end

local function AWD_JoinDirectoryUser(placeId, jobId)
    placeId = tonumber(placeId)
    jobId = tostring(jobId or "")
    if not placeId or placeId <= 0 or jobId == "" then
        notify("Kullanıcılar", "Bu kullanıcının sunucu bilgisi geçersiz.")
        return
    end
    task.spawn(function()
        local joined, joinError = pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
        end)
        if not joined then
            notify("Kullanıcılar", "Katılma başarısız: " .. tostring(joinError))
        end
    end)
end

local function AWD_RenderUserDirectory(users)
    AWD_ClearUserDirectoryCards()
    -- Keep UI creation and avatar requests bounded to prevent large directory responses freezing the client.
    local maxVisibleUsers = 30
    for index, entry in ipairs(users or {}) do
        if index > maxVisibleUsers then break end
        local userId = tonumber(entry.userId or entry.UserId)
        local maskedName = tostring(entry.maskedName or "AWD User")
        if userId and tonumber(entry.placeId) and tostring(entry.jobId or "") ~= "" then
            local card = Instance.new("Frame")
            card.Name = "AWDUser_" .. tostring(userId)
            card.Size = UDim2.new(1, -12, 0, 66)
            card.BackgroundColor3 = Color3.fromRGB(27, 30, 42)
            card.BorderSizePixel = 0
            card.LayoutOrder = 10000 + index
            card.Parent = tabUsers
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

            local avatar = Instance.new("ImageLabel")
            avatar.Name = "Avatar"
            avatar.Size = UDim2.fromOffset(48, 48)
            avatar.Position = UDim2.new(0, 9, 0.5, -24)
            avatar.BackgroundColor3 = Color3.fromRGB(42, 46, 60)
            avatar.BorderSizePixel = 0
            avatar.Parent = card
            Instance.new("UICorner", avatar).CornerRadius = UDim.new(0, 8)
            task.spawn(function()
                local okThumb, imageUrl = pcall(function()
                    return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                end)
                if okThumb and avatar.Parent then avatar.Image = imageUrl end
            end)

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -150, 0, 26)
            nameLabel.Position = UDim2.new(0, 66, 0, 7)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.Text = maskedName
            nameLabel.TextColor3 = Color3.fromRGB(230, 235, 245)
            nameLabel.TextSize = 13
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = card

            local statusLabel = Instance.new("TextLabel")
            statusLabel.Size = UDim2.new(1, -150, 0, 20)
            statusLabel.Position = UDim2.new(0, 66, 0, 34)
            statusLabel.BackgroundTransparency = 1
            statusLabel.Font = Enum.Font.Gotham
            statusLabel.Text = tostring(entry.placeName or "Roblox deneyimi")
            statusLabel.TextColor3 = Color3.fromRGB(145, 175, 205)
            statusLabel.TextSize = 10
            statusLabel.TextXAlignment = Enum.TextXAlignment.Left
            statusLabel.TextTruncate = Enum.TextTruncate.AtEnd
            statusLabel.Parent = card

            local joinButton = Instance.new("TextButton")
            joinButton.Size = UDim2.new(0, 66, 0, 32)
            joinButton.Position = UDim2.new(1, -76, 0.5, -16)
            joinButton.BackgroundColor3 = Color3.fromRGB(45, 105, 75)
            joinButton.BorderSizePixel = 0
            joinButton.Font = Enum.Font.GothamBold
            joinButton.Text = "JOIN"
            joinButton.TextColor3 = Color3.new(1, 1, 1)
            joinButton.TextSize = 11
            joinButton.Parent = card
            Instance.new("UICorner", joinButton).CornerRadius = UDim.new(0, 7)
            joinButton.MouseButton1Click:Connect(function()
                AWD_JoinDirectoryUser(entry.placeId, entry.jobId)
            end)
            table.insert(AWD_UserDirectoryCards, card)
        end
    end
end

local AWD_DirectoryRefreshing = false
_G.AWD_RefreshUserDirectory = function()
    if AWD_DirectoryRefreshing then return end
    AWD_DirectoryRefreshing = true
    if AWD_UserDirectoryStatus and AWD_UserDirectoryStatus.Parent then
        AWD_UserDirectoryStatus.Text = "Kullanıcı dizini yenileniyor..."
    end
    -- Ağ isteğini ana yükleme akışından ayır; yavaş Worker yanıtı arayüzün açılmasını kilitlemesin.
    task.spawn(function()
        local ok, data, err = pcall(function()
            local result, requestError = AWD_PresenceRequest("GET", "/list")
            return result, requestError
        end)
        if AWD_UserDirectoryStatus and AWD_UserDirectoryStatus.Parent then
            if not ok or not data or type(data.users) ~= "table" then
                AWD_UserDirectoryStatus.Text = "Dizin bağlantısı başarısız: " .. tostring(err or data or "yanıt hatalı") .. " | HTTP/Worker erişimini kontrol et."
            else
                AWD_UserDirectoryStatus.Text = #data.users > 0 and (tostring(#data.users) .. " katılımcı çevrimiçi.") or "Şu anda katılımcı yok."
                pcall(AWD_RenderUserDirectory, data.users)
            end
        end
        AWD_DirectoryRefreshing = false
    end)
end

AddButton(tabUsers, "Listeyi Yenile", function()
    AWD_UserDirectoryStatus.Text = "Kullanıcı dizini yenileniyor..."
    _G.AWD_RefreshUserDirectory()
end)
_G.AWD_RefreshUserDirectory()

-- Onay verildiyse bu çalıştırmada otomatik presence heartbeat başlat.
if AWD_PresenceOptIn then
    AWD_UserDirectoryStatus.Text = "Paylaşım açık: AWD HUB oturumun dizine kaydediliyor."
    if _G.AWD_SharingStatusLabel then
        _G.AWD_SharingStatusLabel.Text = "KULLANICILAR PAYLAŞILIYOR: EVET"
        _G.AWD_SharingStatusLabel.TextColor3 = Color3.fromRGB(100, 210, 135)
    end
    task.spawn(function()
        while AWD_PresenceOptIn do
            local payload = {
                userId = tostring(player.UserId),
                username = tostring(player.Name),
                sessionId = AWD_PresenceSessionId,
                placeId = tonumber(game.PlaceId),
                jobId = tostring(game.JobId),
                placeName = tostring(game.Name)
            }
            if payload.placeId and payload.placeId > 0 and payload.jobId ~= "" then
                local ok = AWD_PresenceRequest("POST", "/heartbeat", payload)
                if ok then
                    AWD_PresenceHeartbeatRunning = true
                    AWD_UserDirectoryStatus.Text = "Paylaşım açık. Kullanıcı dizinine bağlısın."
                else
                    AWD_UserDirectoryStatus.Text = "Paylaşım izni açık; sunucuya bağlanılamadı."
                end
            else
                AWD_UserDirectoryStatus.Text = "Bu sunucuda paylaşım yapılamıyor (sunucu ID yok)."
            end
            task.wait(25)
        end
    end)
    task.spawn(function()
        while AWD_PresenceOptIn do
            task.wait(20)
            if _G.AWD_RefreshUserDirectory then _G.AWD_RefreshUserDirectory() end
        end
    end)
else
    if _G.AWD_SharingStatusLabel then
        _G.AWD_SharingStatusLabel.Text = "KULLANICILAR PAYLAŞILIYOR: HAYIR"
    end
end

_G.ananistwaffendivisionTabPlayersRefresh = AddButton(
    _G.ananistwaffendivisionTabPlayers,
    "Listeyi Yenile",
    function()
        if _G.ananistwaffendivisionRefreshPlayersTab then
            _G.ananistwaffendivisionRefreshPlayersTab()
        end
    end
)

orbitPanel = Instance.new("Frame")
orbitPanel.Name = "OrbitSettings"
orbitPanel.Size = UDim2.new(1, -10, 0, 105)
orbitPanel.BackgroundColor3 = Color3.fromRGB(27, 29, 40)
orbitPanel.BorderSizePixel = 0
orbitPanel.Visible = false
orbitPanel.Parent = _G.ananistwaffendivisionTabPlayers
orbitPanel.LayoutOrder = #_G.ananistwaffendivisionTabPlayers:GetChildren()
Instance.new("UICorner", orbitPanel).CornerRadius = UDim.new(0, 8)

orbitTitle = Instance.new("TextLabel")
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

_G.ananistwaffendivisionBodycamPlayersScroll =
    Instance.new("ScrollingFrame")

scroll = _G.ananistwaffendivisionBodycamPlayersScroll
scroll.Name = "PlayersList"
scroll.Size = UDim2.new(1, -10, 0, 260)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 5
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = _G.ananistwaffendivisionTabPlayers
scroll.LayoutOrder = #_G.ananistwaffendivisionTabPlayers:GetChildren()

listLayout = Instance.new("UIListLayout")
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
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
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
        name.TextStrokeTransparency = 1
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
        username.TextStrokeTransparency = 1
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
            button.TextStrokeTransparency = 1
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

AddLabel(tabMain, "AnanistWaffen Division // ban yerseniz idgaf // eğer alttaki kişilerden biri değilseniz napay (siktirin gidin)", true)
AddLabel(tabMain, "babapro yapımcılar")

function AddCreatorCard(parent, displayName, profileUsername)
    local card = Instance.new("TextButton", parent)
    card.Size = UDim2.new(1, -10, 0, 62)
    card.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    card.Text = ""
    card.AutoButtonColor = true
    card.ZIndex = 7
    card.LayoutOrder = #parent:GetChildren()
    registerObj(card, "ButtonBG")

    local corner = Instance.new("UICorner", card)
    corner.CornerRadius = UDim.new(0, 8)

    local avatar = Instance.new("ImageLabel", card)
    avatar.Size = UDim2.new(0, 48, 0, 48)
    avatar.Position = UDim2.new(0, 7, 0.5, -24)
    avatar.BackgroundTransparency = 1
    avatar.ZIndex = 8

    local nameLabel = Instance.new("TextLabel", card)
    nameLabel.Size = UDim2.new(1, -70, 1, 0)
    nameLabel.Position = UDim2.new(0, 65, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = displayName
    nameLabel.TextColor3 = Color3.fromRGB(220, 220, 240)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextStrokeTransparency = 1
    nameLabel.ZIndex = 8
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
serverPlayerCountBox = AddTextBox(tabMain, "sayı gir 123", function() end)
AddButton(tabMain, "Bak şimdi sayı giriyon o kişi kadar server buluyo", function()
    findServerByPlayerCount(serverPlayerCountBox.Text)
end)

AddLabel(tabMain, "Kullanıcı tf2 sniper")
snipePlaceIdBox = AddTextBox(tabMain, "Oyun ve Placeid", function() end)
snipePlaceIdBox.Text = tostring(game.PlaceId)
snipeUsernameBox = AddTextBox(tabMain, "Kullanıcı adı", function() end)
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
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 50)
    card.BackgroundTransparency = 1
    card.Parent = parent
    card.LayoutOrder = #parent:GetChildren()

    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(0, 40, 0, 40)
    img.Position = UDim2.new(0, 5, 0, 5)
    img.BackgroundTransparency = 1
    img.Image = "rbxassetid://" .. imageId
    img.Parent = card

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, -55, 1, 0)
    txt.Position = UDim2.new(0, 55, 0, 0)
    txt.BackgroundTransparency = 1
    txt.Text = textContent
    txt.TextColor3 = Color3.new(1, 1, 1)
    txt.TextSize = 16
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.TextStrokeTransparency = 1
    txt.Parent = card
end

AddCreatorCard(tabMain, "131444549369998", "üstte gördüğünüz orospu çocukları ile iletişime geçmeyin ")
AddCreatorCard(tabMain, "131444549369998", " osama claim bulunmuştur saat gece 3te director modda sikişmeyin")
AddLabel(tabMain, "Server infosu")
serverInfoLabel = AddLabel(tabMain, getServerInfoText(), true)
task.spawn(function()
    while serverInfoLabel and serverInfoLabel.Parent do
        serverInfoLabel.Text = getServerInfoText()
        task.wait(1)
    end
end)
AddButton(tabMain, "Rejoin", rejoinServer)
AddButton(tabMain, "Rıza Formu", function()
    task.spawn(function()
        local accepted = AWD_ShowPresenceConsent()
        if accepted then
            AWD_ConsentAcceptedThisRun = true
            _G.AWD_PresenceConsentAccepted = true
            notify("Rıza Formu", "Tercihin kaydedildi.")
        end
    end)
end)
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

AddLabel(tabPlayer, "KARAKTERİNE BASAN MODLAR (yimmenü)")
kosatkaToggleFrame = AddToggle(tabPlayer, "Kosatka", kosatkaEnabled, function(state)
    toggleKosatka(state)
    if kosatkaHeightFrame then
        kosatkaHeightFrame.Visible = state
    end
end)
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

AddLabel(tabSpider, "Grapple Hook")
AddButton(tabSpider, "Grapple 1 (Çekme)", runSpiderWeb1)
AddButton(tabSpider, "Grapple 2 (Tutunma)", runSpiderWeb2)

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

do
tDGames.Btn.Visible = false
gameLibrary, gameLibraryData = CreateTab("Oyunlar")
gameLibraryData.Btn.LayoutOrder = 5
gameOldLayout = gameLibrary:FindFirstChildOfClass("UIListLayout")
if gameOldLayout then gameOldLayout:Destroy() end
gameLibrary.CanvasSize = UDim2.new(0, 0, 0, 410)
function gameNew(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    o.Parent = parent
    return o
end
gameNew("TextLabel", {Size = UDim2.new(1, -18, 0, 35), Position = UDim2.new(0, 9, 0, 5), BackgroundTransparency = 1, Text = "Oyunlar", TextColor3 = Color3.fromRGB(245, 245, 250), Font = Enum.Font.GothamBold, TextSize = 24, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8, TextStrokeTransparency = 1}, gameLibrary)
gameNew("TextLabel", {Size = UDim2.new(1, -18, 0, 20), Position = UDim2.new(0, 10, 0, 40), BackgroundTransparency = 1, Text = "oyununu seç, sağdaki karttan scripti aç", TextColor3 = Color3.fromRGB(150, 150, 165), Font = Enum.Font.GothamMedium, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8, TextStrokeTransparency = 1}, gameLibrary)
gameNew("Frame", {Size = UDim2.new(1, -18, 0, 1), Position = UDim2.new(0, 9, 0, 71), BackgroundColor3 = Color3.fromRGB(82, 82, 98), BorderSizePixel = 0, ZIndex = 8}, gameLibrary)
gameSidebar = gameNew("ScrollingFrame", {Size = UDim2.new(0, 135, 0, 292), Position = UDim2.new(0, 9, 0, 86), BackgroundColor3 = Color3.fromRGB(8, 8, 10), BorderSizePixel = 0, ScrollBarThickness = 2, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 8}, gameLibrary)
gameNew("UICorner", {CornerRadius = UDim.new(0, 10)}, gameSidebar)
sideList = gameNew("UIListLayout", {Padding = UDim.new(0, 5)}, gameSidebar)
gameNew("UIPadding", {PaddingTop = UDim.new(0, 7), PaddingBottom = UDim.new(0, 7), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6)}, gameSidebar)
gameGrid = gameNew("ScrollingFrame", {Size = UDim2.new(1, -162, 0, 292), Position = UDim2.new(0, 153, 0, 86), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 8}, gameLibrary)
gameGridLayout = gameNew("UIGridLayout", {CellSize = UDim2.new(0, 145, 0, 100), CellPadding = UDim2.new(0, 10, 0, 10), SortOrder = Enum.SortOrder.LayoutOrder}, gameGrid)
gameTitle = gameNew("TextLabel", {Size = UDim2.new(1, -162, 0, 22), Position = UDim2.new(0, 153, 0, 64), BackgroundTransparency = 1, Text = "TÜM OYUNLAR", TextColor3 = Color3.fromRGB(175, 185, 220), Font = Enum.Font.Code, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8, TextStrokeTransparency = 1}, gameLibrary)
games = {

    {"Ftap", "Sandbox", function()
        pcall(function()
            loadstring(game:HttpGet("https://pastebin.com/raw/JBT1fMAu"))()
        end)
    end},

    {"Ftap I Füze", "Sandbox", function()
        pcall(function()
            loadstring(game:HttpGet("https://pastebin.com/raw/MkxjDhL3"))()
        end)
    end},

    {"Ftap I Eşya", "Sandbox", function()
        pcall(function()
            loadstring(game:HttpGet("https://pastebin.com/raw/nnwZSezd"))()
        end)
    end},

    {"Ftap I Roket", "Sandbox", function()
        pcall(function()
            loadstring(game:HttpGet("https://pastebin.com/raw/JfuiC4za"))()
        end)
    end},

    {"Blackhawk Rescue Mission 5", "FPS", function()
        pcall(function()
            loadstring(game:HttpGet("https://pastebin.com/raw/zfgWDHXC"))()
        end)
    end},

    {"Evade", "Survival", function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Emerson2-creator/Scripts-Roblox/refs/heads/main/EvadeScript.lua"))()
        end)
    end},

    {"Katil Porbo", "Survival", function()
        pcall(function()
            loadstring(game:HttpGet("https://pastebin.com/raw/vS3pSfXF", true))()
        end)
    end},

    {"Animal Hospital", "Horror", function()
        pcall(function()
            loadstring(game:HttpGet("https://gist.githubusercontent.com/NoxScriptsZeN/92555dca436989a077ed25b172d4bc78/raw"))()
        end)
    end},

    {"Evil Morty", "OTHER", function()
        pcall(function()
            loadstring(game:HttpGet("https://pastebin.com/raw/6GH3j1Vj"))()
        end)
    end},

}
selectedGame = "TÜM OYUNLAR"
function buildGameCards(filter)
    for _, c in ipairs(gameGrid:GetChildren()) do if not c:IsA("UIGridLayout") then c:Destroy() end end
    for _, gameInfo in ipairs(games) do
        if filter == "TÜM OYUNLAR" or filter == gameInfo[2] then
            local card = gameNew("TextButton", {BackgroundColor3 = Color3.fromRGB(18, 18, 22), BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = 9}, gameGrid)
            gameNew("UICorner", {CornerRadius = UDim.new(0, 10)}, card)
            gameNew("UIStroke", {Color = Color3.fromRGB(100, 100, 122), Transparency = .32, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, card)
            gameNew("TextLabel", {Size = UDim2.new(1, -18, 0, 22), Position = UDim2.new(0, 9, 0, 14), BackgroundTransparency = 1, Text = gameInfo[1], TextColor3 = Color3.fromRGB(245, 245, 250), Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10, TextStrokeTransparency = 1}, card)
            gameNew("TextLabel", {Size = UDim2.new(1, -18, 0, 17), Position = UDim2.new(0, 9, 0, 39), BackgroundTransparency = 1, Text = gameInfo[2] .. "  /  SCRIPT", TextColor3 = Color3.fromRGB(150, 170, 235), Font = Enum.Font.Code, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10, TextStrokeTransparency = 1}, card)
            local open = gameNew("TextLabel", {Size = UDim2.new(1, -18, 0, 16), Position = UDim2.new(0, 9, 1, -22), BackgroundTransparency = 1, Text = "AÇMAK İÇİN TIKLA", TextColor3 = Color3.fromRGB(160, 160, 170), Font = Enum.Font.GothamMedium, TextSize = 8, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10, TextStrokeTransparency = 1}, card)
            card.MouseButton1Click:Connect(gameInfo[3])
            card.MouseEnter:Connect(function() TweenService:Create(card, TweenInfo.new(.15), {BackgroundColor3 = Color3.fromRGB(31, 34, 44)}):Play() end)
            card.MouseLeave:Connect(function() TweenService:Create(card, TweenInfo.new(.15), {BackgroundColor3 = Color3.fromRGB(18, 18, 22)}):Play() end)
        end
    end
end
for _, category in ipairs({"TÜM OYUNLAR", "Sandbox", "FPS", "Survival", "Horror", "OTHER"}) do
    local b = gameNew("TextButton", {Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0, Text = "  " .. category, TextColor3 = Color3.fromRGB(205, 205, 215), TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.GothamMedium, TextSize = 10, ZIndex = 9, TextStrokeTransparency = 1}, gameSidebar)
    gameNew("UICorner", {CornerRadius = UDim.new(0, 7)}, b)
    b.MouseButton1Click:Connect(function() selectedGame = category; gameTitle.Text = category; buildGameCards(category) end)
end
buildGameCards(selectedGame)
end

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
            entry.ZIndex = 7
            entry.LayoutOrder = #tabScripts:GetChildren()
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
            label.TextStrokeTransparency = 1
            label.ZIndex = 8
            registerObj(label, "Text")
            local loadBtn = Instance.new("TextButton", entry)
            loadBtn.Size = UDim2.new(0.15, -4, 0, 30)
            loadBtn.Position = UDim2.new(0.36, 0, 0.5, -15)
            loadBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
            loadBtn.Text = "Çalıştır"
            loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            loadBtn.Font = Enum.Font.GothamBold
            loadBtn.TextSize = 11
            loadBtn.TextStrokeTransparency = 1
            loadBtn.ZIndex = 8
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
            editBtn.TextStrokeTransparency = 1
            editBtn.ZIndex = 8
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
            copyBtn.TextStrokeTransparency = 1
            copyBtn.ZIndex = 8
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
            deleteBtn.TextStrokeTransparency = 1
            deleteBtn.ZIndex = 8
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

do
_AWDLibrary = {}
tDScripts.Btn.Visible = false
_AWDLibrary.scriptLibrary, _AWDLibrary.scriptLibraryData = CreateTab("Scriptler")
_AWDLibrary.scriptLibraryData.Btn.LayoutOrder = 12
_AWDLibrary.oldScriptLayout = _AWDLibrary.scriptLibrary:FindFirstChildOfClass("UIListLayout")
if _AWDLibrary.oldScriptLayout then _AWDLibrary.oldScriptLayout:Destroy() end
_AWDLibrary.scriptLibrary.CanvasSize = UDim2.new(0, 0, 0, 610)
function libNew(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    o.Parent = parent
    return o
end
_AWDLibrary.libTitle = libNew("TextLabel", {Size = UDim2.new(.55, 0, 0, 42), Position = UDim2.new(0, 8, 0, 4), BackgroundTransparency = 1, Text = "Script library", TextColor3 = Color3.fromRGB(245, 245, 250), Font = Enum.Font.GothamBold, TextSize = 25, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8, TextStrokeTransparency = 1}, _AWDLibrary.scriptLibrary)
_AWDLibrary.libSub = libNew("TextLabel", {Size = UDim2.new(.56, 0, 0, 20), Position = UDim2.new(0, 10, 0, 43), BackgroundTransparency = 1, Text = "AWD HUB  /  kendi scriptlerini sakla ve yönet", TextColor3 = Color3.fromRGB(145, 145, 160), Font = Enum.Font.GothamMedium, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8, TextStrokeTransparency = 1}, _AWDLibrary.scriptLibrary)
_AWDLibrary.libraryStatus = libNew("TextLabel", {Size = UDim2.new(.42, -10, 0, 22), Position = UDim2.new(.58, 0, 0, 12), BackgroundTransparency = 1, Text = "KAYITLI SCRIPT YOK", TextColor3 = Color3.fromRGB(155, 180, 255), Font = Enum.Font.Code, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 8, TextStrokeTransparency = 1}, _AWDLibrary.scriptLibrary)
_AWDLibrary.newScriptBtn = libNew("TextButton", {Size = UDim2.new(0, 128, 0, 32), Position = UDim2.new(1, -136, 0, 38), BackgroundColor3 = Color3.fromRGB(36, 48, 78), Text = "the button that dont do anything", TextColor3 = Color3.fromRGB(245, 248, 255), Font = Enum.Font.GothamBold, TextSize = 11, BorderSizePixel = 0, ZIndex = 9}, _AWDLibrary.scriptLibrary)
libNew("UICorner", {CornerRadius = UDim.new(0, 8)}, _AWDLibrary.newScriptBtn)
_AWDLibrary.libLine = libNew("Frame", {Size = UDim2.new(1, -16, 0, 1), Position = UDim2.new(0, 8, 0, 78), BackgroundColor3 = Color3.fromRGB(75, 75, 90), BorderSizePixel = 0, ZIndex = 8}, _AWDLibrary.scriptLibrary)
_AWDLibrary.scriptGrid = libNew("ScrollingFrame", {Size = UDim2.new(1, -16, 0, 250), Position = UDim2.new(0, 8, 0, 92), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = Color3.fromRGB(130, 140, 175), CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 8}, _AWDLibrary.scriptLibrary)
_AWDLibrary.scriptGridLayout = libNew("UIGridLayout", {CellSize = UDim2.new(0, 125, 0, 92), CellPadding = UDim2.new(0, 10, 0, 10), SortOrder = Enum.SortOrder.LayoutOrder}, _AWDLibrary.scriptGrid)
_AWDLibrary.editor = libNew("Frame", {Size = UDim2.new(1, -16, 0, 225), Position = UDim2.new(0, 8, 0, 362), BackgroundColor3 = Color3.fromRGB(10, 10, 13), BorderSizePixel = 0, ZIndex = 8}, _AWDLibrary.scriptLibrary)
libNew("UICorner", {CornerRadius = UDim.new(0, 12)}, _AWDLibrary.editor)
libNew("UIStroke", {Color = Color3.fromRGB(75, 80, 100), Transparency = .25, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, _AWDLibrary.editor)
_AWDLibrary.editorTitle = libNew("TextLabel", {Size = UDim2.new(.5, 0, 0, 30), Position = UDim2.new(0, 12, 0, 8), BackgroundTransparency = 1, Text = "SCRIPT EDITOR", TextColor3 = Color3.fromRGB(220, 225, 245), Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9, TextStrokeTransparency = 1}, _AWDLibrary.editor)
_AWDLibrary.nameInput = libNew("TextBox", {Size = UDim2.new(1, -24, 0, 31), Position = UDim2.new(0, 12, 0, 40), BackgroundColor3 = Color3.fromRGB(20, 20, 25), BorderSizePixel = 0, PlaceholderText = "script adı", PlaceholderColor3 = Color3.fromRGB(115, 115, 130), Text = "", TextColor3 = Color3.fromRGB(240, 240, 245), Font = Enum.Font.GothamMedium, TextSize = 12, ClearTextOnFocus = false, ZIndex = 9, TextStrokeTransparency = 1}, _AWDLibrary.editor)
libNew("UICorner", {CornerRadius = UDim.new(0, 7)}, _AWDLibrary.nameInput)
_AWDLibrary.codeInput = libNew("TextBox", {Size = UDim2.new(1, -24, 0, 92), Position = UDim2.new(0, 12, 0, 79), BackgroundColor3 = Color3.fromRGB(15, 15, 19), BorderSizePixel = 0, PlaceholderText = "Lua kodunu buraya yapıştır...", PlaceholderColor3 = Color3.fromRGB(105, 105, 118), Text = "", TextColor3 = Color3.fromRGB(220, 225, 235), Font = Enum.Font.Code, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, MultiLine = true, ClearTextOnFocus = false, ZIndex = 9, TextStrokeTransparency = 1}, _AWDLibrary.editor)
libNew("UICorner", {CornerRadius = UDim.new(0, 7)}, _AWDLibrary.codeInput)
function libAction(text, x, color)
    local b = libNew("TextButton", {Size = UDim2.new(0, 92, 0, 30), Position = UDim2.new(0, x, 1, -40), BackgroundColor3 = color, BorderSizePixel = 0, Text = text, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold, TextSize = 10, ZIndex = 9, TextStrokeTransparency = 1}, _AWDLibrary.editor)
    libNew("UICorner", {CornerRadius = UDim.new(0, 7)}, b); return b
end
_AWDLibrary.saveLibBtn = libAction("KAYDET", 12, Color3.fromRGB(50, 125, 75))
_AWDLibrary.runLibBtn = libAction("ÇALIŞTIR", 112, Color3.fromRGB(55, 85, 145))
_AWDLibrary.copyLibBtn = libAction("KOPYALA", 212, Color3.fromRGB(65, 65, 76))
_AWDLibrary.deleteLibBtn = libAction("SİL", 312, Color3.fromRGB(145, 50, 55))
_AWDLibrary.libraryData, _AWDLibrary.editingLibraryName = {}, nil
function loadLibraryData()
    if isfile and isfile("ananite_hub_scripts.json") then
        local ok, decoded = pcall(function() return HttpService:JSONDecode(readfile("ananite_hub_scripts.json")) end)
        if ok and type(decoded) == "table" then return decoded end
    end
    return {}
end
function saveLibraryData()
    if writefile then pcall(function() writefile("ananite_hub_scripts.json", HttpService:JSONEncode(_AWDLibrary.libraryData)) end) end
end
function clearGrid()
    for _, child in ipairs(_AWDLibrary.scriptGrid:GetChildren()) do if not child:IsA("UIGridLayout") then child:Destroy() end end
end
function makeScriptCard(name, source, builtin)
    local card = libNew("TextButton", {BackgroundColor3 = Color3.fromRGB(19, 19, 23), BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = 9}, _AWDLibrary.scriptGrid)
    libNew("UICorner", {CornerRadius = UDim.new(0, 10)}, card)
    libNew("UIStroke", {Color = Color3.fromRGB(94, 94, 112), Transparency = .3, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, card)
    local icon = libNew("TextLabel", {Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(0, 10, 0, 10), BackgroundColor3 = Color3.fromRGB(240, 242, 250), Text = "AWD", TextColor3 = Color3.fromRGB(20, 24, 38), Font = Enum.Font.GothamBlack, TextSize = 10, ZIndex = 10, TextStrokeTransparency = 1}, card)
    libNew("UICorner", {CornerRadius = UDim.new(0, 8)}, icon)
    libNew("TextLabel", {Size = UDim2.new(1, -16, 0, 28), Position = UDim2.new(0, 8, 0, 57), BackgroundTransparency = 1, Text = name, TextColor3 = Color3.fromRGB(235, 235, 245), Font = Enum.Font.GothamBold, TextSize = 10, TextWrapped = true, ZIndex = 10, TextStrokeTransparency = 1}, card)
    card.MouseButton1Click:Connect(function()
        _AWDLibrary.editingLibraryName = builtin and nil or name
        _AWDLibrary.nameInput.Text, _AWDLibrary.codeInput.Text = name, source
        _AWDLibrary.libraryStatus.Text = builtin and ("HAZIR SCRIPT: " .. name) or ("DÜZENLENİYOR: " .. name)
    end)
end
function rebuildLibrary()
    clearGrid()
    makeScriptCard("Bodycam", "loadstring(game:HttpGet(\"https://pastebin.com/raw/HSQ9dyXt\"))()", true)
    makeScriptCard("Telekinesis", "loadstring(game:HttpGet(\"https://pastebin.com/raw/QAsFzqSh\"))()", true)
    for name, data in pairs(_AWDLibrary.libraryData) do makeScriptCard(name, data.Source or "", false) end
    local count = 0; for _ in pairs(_AWDLibrary.libraryData) do count += 1 end
    _AWDLibrary.libraryStatus.Text = count > 0 and (count .. " KAYITLI SCRIPT") or "KAYITLI SCRIPT YOK"
end
_AWDLibrary.libraryData = loadLibraryData()
_AWDLibrary.newScriptBtn.MouseButton1Click:Connect(function() _AWDLibrary.editingLibraryName = nil; _AWDLibrary.nameInput.Text = ""; _AWDLibrary.codeInput.Text = ""; _AWDLibrary.libraryStatus.Text = "YENİ SCRIPT HAZIR" end)
_AWDLibrary.saveLibBtn.MouseButton1Click:Connect(function()
    local name, code = _AWDLibrary.nameInput.Text, _AWDLibrary.codeInput.Text
    if name == "" or code == "" then return end
    if _AWDLibrary.editingLibraryName and _AWDLibrary.editingLibraryName ~= name then _AWDLibrary.libraryData[_AWDLibrary.editingLibraryName] = nil end
    _AWDLibrary.libraryData[name] = {Source = code}; _AWDLibrary.editingLibraryName = name; saveLibraryData(); rebuildLibrary()
end)
_AWDLibrary.runLibBtn.MouseButton1Click:Connect(function() if _AWDLibrary.codeInput.Text ~= "" then pcall(function() loadstring(_AWDLibrary.codeInput.Text)() end) end end)
_AWDLibrary.copyLibBtn.MouseButton1Click:Connect(function() pcall(function() if setclipboard then setclipboard(_AWDLibrary.codeInput.Text) end end) end)
_AWDLibrary.deleteLibBtn.MouseButton1Click:Connect(function() if _AWDLibrary.editingLibraryName then _AWDLibrary.libraryData[_AWDLibrary.editingLibraryName] = nil; _AWDLibrary.editingLibraryName = nil; _AWDLibrary.nameInput.Text = ""; _AWDLibrary.codeInput.Text = ""; saveLibraryData(); rebuildLibrary() end end)
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

thirdPersonEnabled = false
thirdPersonRenderName = "Hub_ThirdPersonVisibility"

function setThirdPerson(state)
    thirdPersonEnabled = state

    RunService:UnbindFromRenderStep(thirdPersonRenderName)

    if state then
        player.CameraMode = Enum.CameraMode.Classic
        player.CameraMinZoomDistance = 0.5
        player.CameraMaxZoomDistance = 30

        RunService:BindToRenderStep(
            thirdPersonRenderName,
            Enum.RenderPriority.Camera.Value + 1,
            function()
                local character = player.Character
                local camera = workspace.CurrentCamera

                if not character or not camera then return end

                local head = character:FindFirstChild("Head")
                if not head then return end

                local distance = (camera.CFrame.Position - head.Position).Magnitude
                local firstPerson = distance < 1.5

                for _, obj in ipairs(character:GetDescendants()) do
                    if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
                        obj.LocalTransparencyModifier = firstPerson and 1 or 0
                    end
                end
            end
        )
    else
        player.CameraMode = Enum.CameraMode.Classic
        player.CameraMinZoomDistance = 0.5
        player.CameraMaxZoomDistance = 128

        if player.Character then
            for _, obj in ipairs(player.Character:GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.LocalTransparencyModifier = 0
                end
            end
        end
    end
end

player.CharacterAdded:Connect(function()
    task.wait(0.5)

    if thirdPersonEnabled then
        setThirdPerson(true)
    end
end)

AddLabel(tabVisuals, "Kamera")

thirdPersonToggle = AddToggle(
    tabVisuals,
    "Force Third Person + Character Visibility",
    false,
    function(state)
        setThirdPerson(state)
    end
)

AddLabel(tabVisuals, "ESP")

espKeyBtn = AddButton(tabVisuals, "ESP Aç/Kapat: [T]", function() end)
espKeyLabel = espKeyBtn:FindFirstChildOfClass("TextLabel")

updateESPUIs = {}

updateESPUIs.master = AddToggle(tabVisuals, "ESP Aktif", espEnabled, function(state)
    espEnabled = state

    if espEnabled then
        for _, conn in pairs(espConnections) do
            if conn then conn:Disconnect() end
        end

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

        for _, p in pairs(Players:GetPlayers()) do
            setupForPlayer(p)
        end

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

        if espLoopThread then
            task.cancel(espLoopThread)
            espLoopThread = nil
        end

        for _, conn in pairs(espConnections) do
            if conn then conn:Disconnect() end
        end

        espConnections = {}
    end
end)

updateESPUIs.isim = AddToggle(tabVisuals, "İsim Çiz", espShowNames, function(s)
    espShowNames = s
end)

updateESPUIs.health = AddToggle(tabVisuals, "Sağlık Çubuğu", espShowHealth, function(s)
    espShowHealth = s
end)

updateESPUIs.chams = AddToggle(tabVisuals, "Chams", espShowChams, function(s)
    espShowChams = s
end)

updateESPUIs.kutu = AddToggle(tabVisuals, "Kutu (Box)", espShowBoxes, function(s)
    espShowBoxes = s
end)

updateESPUIs.env = AddToggle(tabVisuals, "Envanter Gör", espShowInventory, function(s)
    espShowInventory = s
end)

AddLabel(tabVisuals, "ESP Mesafe Ayarı")

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

AddLabel(tabVisuals, "Workspace İsim ESP")

_G.ananistwaffendivisionWorkspaceNameESPBoxVisuals = AddTextBox(
    tabVisuals,
    "Workspace obje adı gir...",
    function(text)
        pcall(function()
            _G.ananistwaffendivisionNameSearchWorkspaceESP(text)
        end)
    end
)

AddButton(tabVisuals, "İsim ESP Temizle", function()
    pcall(function()
        _G.ananistwaffendivisionClearWorkspaceESP()
    end)

    if _G.ananistwaffendivisionWorkspaceNameESPBoxVisuals then
        _G.ananistwaffendivisionWorkspaceNameESPBoxVisuals.Text = ""
    end
end)

AddLabel(tabVisuals, "ESP Renk Yönetimi")

updateESPUIs.friend = AddToggle(tabVisuals, "Arkadaş Rengi Kullan", espUseFriendColor, function(s)
    espUseFriendColor = s
end)

setFriendColorUI = AddColorPicker(tabVisuals, "Arkadaş Rengi", espFriendColor, function(c)
    espFriendColor = c
end)

updateESPUIs.customColor = AddToggle(tabVisuals, "ESP Rengi Kullan", espUseCustomColor, function(s)
    espUseCustomColor = s

    if s then
        espUseTeamColor = false
        updateESPUIs.teamColor(false)
    end
end)

setEspColorUI = AddColorPicker(tabVisuals, "ESP Rengi", espCustomColor, function(c)
    espCustomColor = c
    espUseCustomColor = true
    espUseTeamColor = false

    updateESPUIs.customColor(true)
    updateESPUIs.teamColor(false)
end)

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

    if espKeyLabel then
        espKeyLabel.Text = " ESP Tuşu: Tuşa bas..."
    end

    local conn

    conn = UIS.InputBegan:Connect(function(inp, gp)
        if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if gp then return end

        espToggleKey = inp.KeyCode

        local keyName = tostring(inp.KeyCode):gsub("Enum.KeyCode.", "")

        if espKeyLabel then
            espKeyLabel.Text = " ESP Aç/Kapat: [" .. keyName .. "]"
        end

        settingESPKey = false
        conn:Disconnect()
    end)
end)

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

AddLabel(tabSettings, "Dil Ayarları")
local awdLanguageStatus = AddLabel(tabSettings, AWD_Language == "English" and "Interface language: English" or "Arayüz dili: Türkçe", false)
local awdLanguageButton
awdLanguageButton = AddButton(tabSettings, AWD_Language == "English" and "Language: English  •  Switch" or "Dil: Türkçe  •  Değiştir", function()
    AWD_ApplyLanguage(AWD_Language == "English" and "Türkçe" or "English")
    awdLanguageStatus.Text = AWD_Language == "English" and " Interface language: English" or " Arayüz dili: Türkçe"
    local awdLanguageButtonLabel = awdLanguageButton:FindFirstChildWhichIsA("TextLabel")
    if awdLanguageButtonLabel then
        awdLanguageButtonLabel.Text = AWD_Language == "English" and "Language: English  •  Switch" or "Dil: Türkçe  •  Değiştir"
    end
end)
local function AWD_RefreshTabLanguage()
    local tabNames = {
        {tD1, "Ana Sayfa"}, {tD2, "Oyuncu"}, {tD6, "Ulaşım"}, {tDStudio, "Studio"},
        {tDGames, "Oyunlar"}, {tD5, "Grapple"}, {tD3, "Görseller"}, {tDAimbot, "Aimbot"},
        {tD4, "Ayarlar"}, {tD8, "Dizayn"}, {_G.ananistwaffendivisionTabPlayersData, "Oyuncular"},
        {tDScripts, "Scriptler"}, {tDUsers, "Kullanıcılar"}, {styleTabData, "Stil"}
    }
    for _, item in ipairs(tabNames) do
        if item[1] and item[1].Btn then item[1].Btn.Text = AWD_Localize("   " .. item[2]) end
    end
end
_G.AWD_ApplyTabLanguage = AWD_RefreshTabLanguage
AWD_RefreshTabLanguage()

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
            walkSpeed = movementWalkSpeed or 16,
            jumpPower = movementJumpPower or 50,
            gravity = movementGravity or workspace.Gravity,
            infiniteJump = infiniteJumpEnabled and true or false,
            noclip = noclipEnabled and true or false,
            clickTP = clickTPEnabled and true or false,
            antiAFK = antiAFKEnabled and true or false,
            antiVoid = antiVoidEnabled and true or false,
            menuToggleKey = keyToString(menuToggleKey),
            espToggleKey = keyToString(espToggleKey),
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

        if data.currentTheme and themeData[data.currentTheme] then
            pcall(function() applyTheme(data.currentTheme) end)
        end

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

        local mk = stringToKey(data.menuToggleKey)
        if mk then menuToggleKey = mk end
        local ek = stringToKey(data.espToggleKey)
        if ek then espToggleKey = ek end

        if data.fullbright ~= nil then
            local want = data.fullbright and true or false
            if fullbrightEnabled ~= want then
                local fakeBtn = {Text = ""}
                pcall(function() runFullbright(fakeBtn) end)
            end
        end

        applyESPFlags(data)

        if data.espEnabled ~= nil then
            local wantEsp = data.espEnabled and true or false
            if wantEsp and not espEnabled then
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
            entry.ZIndex = 7
            entry.LayoutOrder = #tabSettings:GetChildren()
            entry.Parent = tabSettings
            registerObj(entry, "ButtonBG")
            Instance.new("UICorner", entry).CornerRadius = UDim.new(0, 8)

            local accent = Instance.new("Frame")
            accent.Size = UDim2.new(0, 3, 1, -10)
            accent.Position = UDim2.new(0, 6, 0, 5)
            accent.BackgroundColor3 = isActive and Color3.fromRGB(80, 220, 120) or Color3.fromRGB(90, 90, 120)
            accent.BorderSizePixel = 0
            accent.ZIndex = 8
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
            nameLbl.TextStrokeTransparency = 1
            nameLbl.ZIndex = 8
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
            loadBtn.TextStrokeTransparency = 1
            loadBtn.ZIndex = 9
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
            delBtn.TextStrokeTransparency = 1
            delBtn.ZIndex = 9
            delBtn.Parent = entry
            Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 6)

            local hit = Instance.new("TextButton")
            hit.Size = UDim2.new(0.45, 0, 1, 0)
            hit.BackgroundTransparency = 1
            hit.Text = ""
            hit.ZIndex = 9
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
        lbl.TextStrokeTransparency = 1
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

AddLabel(tabDesigner, "Script Başlığı Değiştir")
AddTextBox(tabDesigner, "Örn: Ananistan Hub v3...", function(text)
    if text ~= "" then
        title.Text = text
    end
end)

AddLabel(tabDesigner, "Menü Arkaplan Resmi")

AddTextBox(tabDesigner, "Görsel URL veya AssetID girin...", function(url)
    pcall(function()
        if url == "" then
            bgImageLabel.Image = ""
            bgImageLabel.ImageTransparency = 1
            themeData["Custom Designer"].BGImage = ""
            themeData["Custom Designer"].BGImageTrans = 1
        else
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

AddSlider(tabDesigner, "Resim Belirginliği (Opaklık)", 0, 100, 30, function(val)
    pcall(function()
        local trans = (100 - val) / 100
        bgImageLabel.ImageTransparency = trans
        themeData["Custom Designer"].BGImageTrans = trans
    end)
end)

AddSlider(tabDesigner, "Resim Bulanıklığı (Blur Maske)", 0, 100, 0, function(val)
    pcall(function()
        local trans = (100 - val) / 100
        blurOverlay.BackgroundTransparency = trans
        themeData["Custom Designer"].BlurTrans = trans
    end)
end)

AddColorPicker(tabDesigner, "Ana Arkaplan Rengi", themeData["Custom Designer"].MainBG, function(col)
    themeData["Custom Designer"].MainBG = col
    applyTheme("Custom Designer")
end)

AddColorPicker(tabDesigner, "Üst Bar (Topbar) Rengi", themeData["Custom Designer"].TopbarBG, function(col)
    themeData["Custom Designer"].TopbarBG = col
    applyTheme("Custom Designer")
end)

AddColorPicker(tabDesigner, "Buton ve Panel Rengi", themeData["Custom Designer"].ButtonBG, function(col)
    themeData["Custom Designer"].ButtonBG = col
    themeData["Custom Designer"].UnselectedTabBtn = Color3.fromRGB(math.clamp(col.R*255-15,0,255), math.clamp(col.G*255-15,0,255), math.clamp(col.B*255-15,0,255))
    applyTheme("Custom Designer")
end)

AddColorPicker(tabDesigner, "Vurgu (Accent) Rengi", themeData["Custom Designer"].Accent, function(col)
    themeData["Custom Designer"].Accent = col
    applyTheme("Custom Designer")
end)

AddColorPicker(tabDesigner, "Yazı (Text) Rengi", themeData["Custom Designer"].Text, function(col)
    themeData["Custom Designer"].Text = col
    applyTheme("Custom Designer")
end)

AddSlider(tabDesigner, "Panel Saydamlığı (Opacity)", 0, 100, 10, function(val)
    themeData["Custom Designer"].MainTrans = val / 100
    themeData["Custom Designer"].TopbarTrans = math.clamp((val / 100) + 0.05, 0, 1)
    applyTheme("Custom Designer")
end)

AddSlider(tabDesigner, "Buton Saydamlığı (Opacity)", 0, 100, 0, function(val)
    themeData["Custom Designer"].ButtonTrans = val / 100
    applyTheme("Custom Designer")
end)

AddSlider(tabDesigner, "Köşe Yuvarlaklığı (Corner)", 0, 50, 22, function(val)
    corner.CornerRadius = UDim.new(0, val)
    topCorner.CornerRadius = UDim.new(0, val)
    imgCorner.CornerRadius = UDim.new(0, val)
    overlayCorner.CornerRadius = UDim.new(0, val)
end)

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

function rebuildSlotsUI()
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
        entry.ZIndex = 7
        entry.LayoutOrder = #tabSlots:GetChildren()
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
        label.TextStrokeTransparency = 1
        label.ZIndex = 8
        registerObj(label, "Text")

        local loadBtn = Instance.new("TextButton", entry)
        loadBtn.Size = UDim2.new(0.2, -5, 0, 30)
        loadBtn.Position = UDim2.new(0.6, 0, 0.5, -15)
        loadBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        loadBtn.Text = "Yükle"
        loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        loadBtn.Font = Enum.Font.GothamBold
        loadBtn.TextSize = 11
        loadBtn.TextStrokeTransparency = 1
        loadBtn.ZIndex = 8
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

        local deleteBtn = Instance.new("TextButton", entry)
        deleteBtn.Size = UDim2.new(0.2, -5, 0, 30)
        deleteBtn.Position = UDim2.new(0.8, 5, 0.5, -15)
        deleteBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        deleteBtn.Text = "Sil"
        deleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        deleteBtn.Font = Enum.Font.GothamBold
        deleteBtn.TextSize = 11
        deleteBtn.TextStrokeTransparency = 1
        deleteBtn.ZIndex = 8
        local deleteBtnCorner = Instance.new("UICorner", deleteBtn)
        deleteBtnCorner.CornerRadius = UDim.new(0, 6)

        deleteBtn.MouseButton1Click:Connect(function()
            slotsData[slotName] = nil
            saveSlotsToFile()
            rebuildSlotsUI()
        end)
    end
end

AddLabel(tabSlots, "Tasarımı Kaydet")
slotNameInput = AddTextBox(tabSlots, "Yeni Slot Adı Yaz...", function() end)

AddButton(tabSlots, "Şu Anki Tasarımı Bu Slota Kaydet", function()
    local name = slotNameInput.Text
    if name == "" then return end
    
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
    slotNameInput.Text = ""
end)

AddLabel(tabSlots, "Kayıtlı Profil Slotların")
rebuildSlotsUI()

AddLabel(tabUlasim, "Konumum")
coordLabel = AddLabel(tabUlasim, "X: 0  Y: 0  Z: 0")
task.spawn(function()
    while coordLabel and coordLabel.Parent do
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root and coordLabel then
            local p = root.Position
            coordLabel.Text = string.format(" X: %.1f  Y: %.1f  Z: %.1f", p.X, p.Y, p.Z)
        end
        task.wait(0.2)
    end
end)

AddLabel(tabUlasim, "Koordinata Işınlan")
coordInputFrame = Instance.new("Frame", tabUlasim)
coordInputFrame.Size = UDim2.new(1, -10, 0, 35)
coordInputFrame.BackgroundTransparency = 1
coordInputFrame.ZIndex = 7
coordInputFrame.LayoutOrder = #tabUlasim:GetChildren()

function CreateCoordBox(label, pos, parent)
    local l = Instance.new("TextLabel", parent)
    l.Size = UDim2.new(0, 20, 1, 0)
    l.Position = pos
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = Color3.fromRGB(220, 220, 240)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 14
    l.TextStrokeTransparency = 1
    l.ZIndex = 8
    registerObj(l, "Text")
    
    local b = AddTextBox(parent, "0", function() end)
    b.Size = UDim2.new(0.25, 0, 1, 0)
    b.Position = pos + UDim2.new(0, 20, 0, 0)
    b.Text = "0"
    b.ZIndex = 8
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
explorerScroll.ZIndex = 7
explorerScroll.LayoutOrder = #tabStudio:GetChildren()
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
        nav.TextStrokeTransparency = 1
        nav.Text = text
        nav.ZIndex = 8
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
        row.TextStrokeTransparency = 1
        row.Text = string.rep("   ", depth) .. (hasChildren and (expanded and "v " or "> ") or "• ") .. instance.Name .. "  [" .. instance.ClassName .. "]"
        row.ZIndex = 8
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


tD1.Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
tD1.Btn.BackgroundTransparency = 0.2
tD1.Indicator.Visible = true
tD1.Frame.Visible = true

applyTheme("ϟϟ Theme")

-- [[ BLACK & WHITE PASS // UI öğelerindeki mavi tonları griye çevir ]] --
local function awdGray(color)
    local luminance = math.floor(
        color.R * 0.299 * 255 +
        color.G * 0.587 * 255 +
        color.B * 0.114 * 255 + 0.5
    )
    return Color3.fromRGB(luminance, luminance, luminance)
end

pcall(function()
    for _, object in ipairs(screenGui:GetDescendants()) do
        if object:IsA("GuiObject") then
            object.BackgroundColor3 = awdGray(object.BackgroundColor3)
            if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
                object.TextColor3 = awdGray(object.TextColor3)
                object.TextStrokeColor3 = awdGray(object.TextStrokeColor3)
            end
            if object:IsA("ImageLabel") or object:IsA("ImageButton") then
                object.ImageColor3 = awdGray(object.ImageColor3)
            end
        end
        if object:IsA("UIStroke") then
            object.Color = awdGray(object.Color)
        elseif object:IsA("UIGradient") then
            local oldSequence = object.Color
            local keypoints = {}
            for _, point in ipairs(oldSequence.Keypoints) do
                table.insert(keypoints, ColorSequenceKeypoint.new(point.Time, awdGray(point.Value)))
            end
            object.Color = ColorSequence.new(keypoints)
        end
    end
end)

-- [[ AWD INTRO // interface itself animates in; visual effect stays behind UI ]] --
function playAWDInterfaceIntro()
    if not mainFrame or not mainFrame.Parent then return end

    -- Hafif siyah-beyaz açılış: tek overlay, az sayıda UI öğesi ve kısa tween'ler.
    local introGui = Instance.new("ScreenGui")
    introGui.Name = "AWD_OptimizedIntro"
    introGui.ResetOnSpawn = false
    introGui.IgnoreGuiInset = true
    introGui.DisplayOrder = 2147483000
    introGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    local introParent = screenGui and screenGui.Parent
    if not introParent then return end
    introGui.Parent = introParent

    local introSound
    pcall(function()
        introSound = Instance.new("Sound")
        introSound.Name = "AWD_OptimizedIntroSound"
        introSound.SoundId = "rbxassetid://127997181362733"
        introSound.Volume = 0.8
        introSound.Looped = false
        introSound.Parent = game:GetService("SoundService")
        introSound:Play()
    end)

    local overlay = Instance.new("Frame")
    overlay.Name = "Overlay"
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    overlay.BackgroundTransparency = 0
    overlay.BorderSizePixel = 0
    overlay.Parent = introGui

    local panel = Instance.new("Frame")
    panel.Name = "IntroPanel"
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.Position = UDim2.fromScale(0.5, 0.5)
    panel.Size = UDim2.fromOffset(390, 132)
    panel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    panel.BackgroundTransparency = 0.08
    panel.BorderSizePixel = 0
    panel.Parent = overlay
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 9)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(105, 105, 105)
    stroke.Transparency = 0.35
    stroke.Thickness = 1
    stroke.Parent = panel

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(22, 19)
    title.Size = UDim2.new(1, -44, 0, 34)
    title.Font = Enum.Font.GothamBold
    title.Text = "AWD HUB"
    title.TextColor3 = Color3.fromRGB(245, 245, 245)
    title.TextSize = 25
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextTransparency = 1
    title.Parent = panel

    local subtitle = Instance.new("TextLabel")
    subtitle.BackgroundTransparency = 1
    subtitle.Position = UDim2.fromOffset(23, 55)
    subtitle.Size = UDim2.new(1, -46, 0, 20)
    subtitle.Font = Enum.Font.Gotham
    subtitle.Text = "COMMAND CENTER  /  INITIALIZING"
    subtitle.TextColor3 = Color3.fromRGB(165, 165, 165)
    subtitle.TextSize = 11
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.TextTransparency = 1
    subtitle.Parent = panel

    local track = Instance.new("Frame")
    track.Position = UDim2.fromOffset(23, 94)
    track.Size = UDim2.new(1, -46, 0, 3)
    track.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
    track.BorderSizePixel = 0
    track.Parent = panel

    local progress = Instance.new("Frame")
    progress.Size = UDim2.new(0, 0, 1, 0)
    progress.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
    progress.BorderSizePixel = 0
    progress.Parent = track

    mainFrame.Visible = true
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Position = UDim2.fromScale(0.5, 0.5)
    menuScale.Scale = 0.96

    local function tween(object, duration, properties, style)
        local animation = TweenService:Create(
            object,
            TweenInfo.new(duration, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            properties
        )
        animation:Play()
        return animation
    end

    title.TextTransparency = 0
    subtitle.TextTransparency = 0
    panel.Position = UDim2.fromScale(0.5, 0.53)
    tween(panel, 0.28, {Position = UDim2.fromScale(0.5, 0.5)}, Enum.EasingStyle.Quart)
    tween(progress, 0.72, {Size = UDim2.new(1, 0, 1, 0)}, Enum.EasingStyle.Sine)
    tween(menuScale, 0.42, {Scale = 1}, Enum.EasingStyle.Quart)

    task.delay(0.88, function()
        if not introGui or not introGui.Parent then return end
        tween(overlay, 0.24, {BackgroundTransparency = 1})
        tween(panel, 0.2, {BackgroundTransparency = 1})
        tween(title, 0.16, {TextTransparency = 1})
        tween(subtitle, 0.16, {TextTransparency = 1})
        tween(track, 0.16, {BackgroundTransparency = 1})
        tween(progress, 0.16, {BackgroundTransparency = 1})
        tween(stroke, 0.16, {Transparency = 1})
        task.delay(0.27, function()
            if introSound then
                pcall(function()
                    introSound:Stop()
                    introSound:Destroy()
                end)
                introSound = nil
            end
            if introGui and introGui.Parent then introGui:Destroy() end
            if mainFrame and mainFrame.Parent then
                mainFrame.AnchorPoint = Vector2.new(0, 0)
                mainFrame.Position = UDim2.new(0.5, -510, 0.5, -340)
            end
        end)
    end)
end

-- Intro sequence: fullscreen → interface
task.spawn(function()
    if AWD_ENABLE_FULLSCREEN_INTRO then
        pcall(awdShowFullscreenIntro)
    end
    -- Intro efektindeki bir tween/ses hatası ana arayüzü düşürmesin.
    local introOk, introErr = pcall(playAWDInterfaceIntro)
    if not introOk then
        pcall(function() awdLog("Intro atlandı: " .. tostring(introErr), "warning") end)
        pcall(function() if mainFrame and mainFrame.Parent then mainFrame.Visible = true end end)
    end
end)

-- [[ AWD SMART MOTION SYSTEM // AMBIENT PARALLAX + BREATHING GLASS ]] --
awdAmbientMotionAlive = true
function awdPlayAmbientCycle()
    task.spawn(function()
        while awdAmbientMotionAlive and screenGui and screenGui.Parent do
            if mainFrame.Visible and screenGui.Enabled then
                local duration = 7.5
                local orbATween = TweenService:Create(ambientOrbA, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    Position = UDim2.new(0.23, 0, 0.29, 0),
                    Size = UDim2.fromOffset(360, 360),
                    BackgroundTransparency = 0.925
                })
                local orbBTween = TweenService:Create(ambientOrbB, TweenInfo.new(duration + 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    Position = UDim2.new(0.78, 0, 0.68, 0),
                    Size = UDim2.fromOffset(300, 300),
                    BackgroundTransparency = 0.935
                })
                local orbCTween = TweenService:Create(ambientOrbC, TweenInfo.new(duration + 0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    Position = UDim2.new(0.63, 0, 0.20, 0),
                    Size = UDim2.fromOffset(230, 230),
                    BackgroundTransparency = 0.95
                })
                local rimTween = TweenService:Create(glassRim, TweenInfo.new(3.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    Transparency = 0.58
                })
                local sheenTween = TweenService:Create(glassSheenGradient, TweenInfo.new(9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    Rotation = 142
                })
                orbATween:Play()
                orbBTween:Play()
                orbCTween:Play()
                rimTween:Play()
                sheenTween:Play()
                task.wait(duration + 1.6)
                if not (screenGui and screenGui.Parent) then break end

                TweenService:Create(ambientOrbA, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    Position = UDim2.new(0.12, 0, 0.18, 0),
                    Size = UDim2.fromOffset(310, 310),
                    BackgroundTransparency = 0.90
                }):Play()
                TweenService:Create(ambientOrbB, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    Position = UDim2.new(0.88, 0, 0.78, 0),
                    Size = UDim2.fromOffset(250, 250),
                    BackgroundTransparency = 0.92
                }):Play()
                TweenService:Create(ambientOrbC, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    Position = UDim2.new(0.72, 0, 0.12, 0),
                    Size = UDim2.fromOffset(190, 190),
                    BackgroundTransparency = 0.94
                }):Play()
                TweenService:Create(glassRim, TweenInfo.new(3.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    Transparency = 0.78
                }):Play()
                TweenService:Create(glassSheenGradient, TweenInfo.new(9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    Rotation = 112
                }):Play()
                task.wait(duration + 1.6)
            else
                task.wait(0.6)
            end
        end
    end)
end
-- Ağır ambient/parallax animasyonu kapalı: UI açılışındaki GPU yükünü azaltır.
awdAmbientMotionAlive = false
if ambientLayer then ambientLayer.Visible = false end

-- Glassmorphism nefes alma döngüsü
task.spawn(function()
    while false and screenGui and screenGui.Parent do
        if mainFrame.Visible and screenGui.Enabled then
            TweenService:Create(glassFrost, TweenInfo.new(4.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = 0.90
            }):Play()
            TweenService:Create(glassSpecular, TweenInfo.new(2.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Position = UDim2.new(0.42, 0, 0, 92),
                BackgroundTransparency = 0.35
            }):Play()
            task.wait(4.2)
            if not (screenGui and screenGui.Parent) then break end
            TweenService:Create(glassFrost, TweenInfo.new(4.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = 0.94
            }):Play()
            TweenService:Create(glassSpecular, TweenInfo.new(2.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Position = UDim2.new(0.62, 0, 0, 92),
                BackgroundTransparency = 0.65
            }):Play()
            task.wait(4.2)
        else
            task.wait(0.6)
        end
    end
end)

-- Hover watchdog
task.spawn(function()
    while screenGui and screenGui.Parent do
        task.wait(0.35)
        if not screenGui.Enabled or not mainFrame.Visible then continue end
        local mousePos = UIS:GetMouseLocation()
        local cfg = themeData[currentTheme] or themeData["ϟϟ Theme"]
        for _, obj in ipairs(registry.ButtonBG) do
            if obj and obj.Parent and obj:GetAttribute("AWD_Hovered") then
                local pos, size = obj.AbsolutePosition, obj.AbsoluteSize
                local inside = mousePos.X >= pos.X and mousePos.X <= pos.X + size.X
                    and mousePos.Y >= pos.Y and mousePos.Y <= pos.Y + size.Y
                if not inside then
                    obj:SetAttribute("AWD_Hovered", false)
                    local base = (cfg and cfg.ButtonBG) or Color3.fromRGB(17, 21, 29)
                    smoothTween(obj, {BackgroundColor3 = base, BackgroundTransparency = (cfg and cfg.ButtonTrans) or 0}, 0.12)
                    local stroke = obj:FindFirstChildOfClass("UIStroke")
                    if stroke then
                        smoothTween(stroke, {Transparency = obj:IsA("Frame") and 0.62 or 0.58}, 0.12)
                    end
                end
            end
        end
        for _, item in ipairs(registry.TabBtns) do
            local btn = item.Btn
            if btn and btn.Parent and btn:GetAttribute("AWD_Hovered") and activeTab ~= item then
                local pos, size = btn.AbsolutePosition, btn.AbsoluteSize
                local inside = mousePos.X >= pos.X and mousePos.X <= pos.X + size.X
                    and mousePos.Y >= pos.Y and mousePos.Y <= pos.Y + size.Y
                if not inside then
                    btn:SetAttribute("AWD_Hovered", false)
                    smoothTween(btn, {
                        BackgroundColor3 = Color3.fromRGB(9, 12, 18),
                        TextColor3 = (cfg and cfg.Text) or Color3.fromRGB(178, 178, 199)
                    }, 0.12)
                    local stroke = btn:FindFirstChildOfClass("UIStroke")
                    if stroke then smoothTween(stroke, {Transparency = 1}, 0.12) end
                end
            end
        end
    end
end)

-- Ambient sweep loop
task.spawn(function()
    while false and screenGui and screenGui.Parent do
        if mainFrame.Visible and screenGui.Enabled then
            ambientRail.Position = UDim2.new(-0.25, 0, 0.5, 0)
            TweenService:Create(ambientRail, TweenInfo.new(5.5, Enum.EasingStyle.Linear), {
                Position = UDim2.new(1.25, 0, 0.5, 0)
            }):Play()
            task.wait(5.7)
        else
            task.wait(0.5)
        end
    end
end)

-- Insert ve ESP tuşları dinleyicileri
if _G.AnanistanInsert then _G.AnanistanInsert:Disconnect() end
_G.AnanistanInsert = UIS.InputBegan:Connect(function(input, gameProcessed)
    -- Insert menü kısayolu GUI odağı/processed durumundan bağımsız çalışır.
    
    if input.KeyCode == menuToggleKey and not settingMenuKey then
        -- Insert tek basışta aç/kapatır; gameProcessed kontrolüne takılmaz.
        pcall(function()
            local shouldOpen = not mainFrame.Visible
            if shouldOpen then
                screenGui.Enabled = true
                mainFrame.Visible = true
                mainFrame.BackgroundTransparency = 1
                menuScale.Scale = 0.86
                topbar.BackgroundTransparency = 1
                glassSheen.BackgroundTransparency = 1
                glassRim.Transparency = 1
                ambientOrbA.BackgroundTransparency = 1
                ambientOrbB.BackgroundTransparency = 1
                ambientOrbC.BackgroundTransparency = 1
                if glassFrost then glassFrost.BackgroundTransparency = 1 end
                if glassSpecular then glassSpecular.BackgroundTransparency = 1 end
                if glassChip then glassChip.BackgroundTransparency = 1 end
                mainFrame.Position = UDim2.new(0.5, -510, 0.5, -340)
                -- Açılışta tüm UI nesnelerine yeniden tema tween'i uygulama.
                -- Bu işlem büyük arayüzlerde takılmaya neden oluyordu.
                -- Insert ile menü açılırken arka plan blur uygulanmaz.
                if blurEffect then
                    pcall(function()
                        blurEffect.Size = 0
                    end)
                end
                smoothTween(mainFrame, {
                    Position = UDim2.new(0.5, -510, 0.5, -340),
                    BackgroundTransparency = 0.015
                }, 0.38)
                smoothTween(menuScale, {Scale = 1}, 0.44)
                smoothTween(topbar, {BackgroundTransparency = 0.02}, 0.3)
                smoothTween(glassSheen, {BackgroundTransparency = 0.965}, 0.5)
                smoothTween(glassRim, {Transparency = 0.76}, 0.5)
                smoothTween(ambientOrbA, {BackgroundTransparency = 0.90}, 0.55)
                smoothTween(ambientOrbB, {BackgroundTransparency = 0.92}, 0.6)
                smoothTween(ambientOrbC, {BackgroundTransparency = 0.94}, 0.5)
                if glassFrost then smoothTween(glassFrost, {BackgroundTransparency = 0.94}, 0.55) end
                if glassSpecular then smoothTween(glassSpecular, {BackgroundTransparency = 0.55}, 0.5) end
                if glassChip then smoothTween(glassChip, {BackgroundTransparency = 0.85}, 0.55) end
                -- Menü açılışında blur tween'i kaldırıldı.
            else
                -- Blur kapanışla aynı anda sıfırlanır; ekranda kalıcı bulanıklık bırakılmaz.
                pcall(function()
                    if blurEffect then
                        TweenService:Create(blurEffect, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 0}):Play()
                    end
                end)
                mainFrame.Visible = false
                menuScale.Scale = 1
                mainFrame.BackgroundTransparency = 0.015
                topbar.BackgroundTransparency = 0.02
                glassRim.Transparency = 0.76
                if glassFrost then glassFrost.BackgroundTransparency = 0.94 end
                if glassSpecular then glassSpecular.BackgroundTransparency = 0.55 end
                if glassChip then glassChip.BackgroundTransparency = 0.85 end
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
                        refreshTimer = refreshTimer + 0.5
                        if refreshTimer >= 30 then refreshTimer = 0; clearESP() end
                        task.wait(0.5)
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

-- Reload kancası
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

-- [[ AWD SCRIPT TARAMA / RUNTIME INTEGRITY REPORT ]] --
do
    local scanTitle = AddLabel(tabScan, "AWD SCRIPT TARAMA")
    local scanHint = AddLabel(tabScan,
        "Çalışma anında erişilebilen servisleri, sekmeleri ve arayüz callback bağlantılarını denetler. Kaynak kodu Roblox tarafından çalışma anında okunamadığı için bu bir statik kaynak kodu garantisi değildir.", true)
    local scanStatus = Instance.new("TextLabel")
    scanStatus.Name = "AWDScanStatus"
    scanStatus.Size = UDim2.new(1, -12, 0, 34)
    scanStatus.BackgroundTransparency = 1
    scanStatus.Font = Enum.Font.GothamMedium
    scanStatus.Text = "Tarama başlatılmadı."
    scanStatus.TextColor3 = Color3.fromRGB(175, 190, 215)
    scanStatus.TextSize = 12
    scanStatus.TextWrapped = true
    scanStatus.LayoutOrder = 9990
    scanStatus.Parent = tabScan

    local scanOutput = Instance.new("TextBox")
    scanOutput.Name = "AWDScanLog"
    scanOutput.Size = UDim2.new(1, -12, 0, 260)
    scanOutput.BackgroundColor3 = Color3.fromRGB(13, 17, 25)
    scanOutput.BorderSizePixel = 0
    scanOutput.ClearTextOnFocus = false
    scanOutput.MultiLine = true
    scanOutput.TextEditable = false
    scanOutput.TextXAlignment = Enum.TextXAlignment.Left
    scanOutput.TextYAlignment = Enum.TextYAlignment.Top
    scanOutput.TextWrapped = true
    scanOutput.Font = Enum.Font.Code
    scanOutput.TextSize = 11
    scanOutput.TextColor3 = Color3.fromRGB(205, 215, 230)
    scanOutput.Text = "Tarama sonucunuz burada görünecek."
    scanOutput.LayoutOrder = 9991
    scanOutput.Parent = tabScan
    Instance.new("UICorner", scanOutput).CornerRadius = UDim.new(0, 8)
    local scanPadding = Instance.new("UIPadding", scanOutput)
    scanPadding.PaddingTop = UDim.new(0, 8)
    scanPadding.PaddingBottom = UDim.new(0, 8)
    scanPadding.PaddingLeft = UDim.new(0, 8)
    scanPadding.PaddingRight = UDim.new(0, 8)

    local lastScanLog = ""
    local function runAWDScan()
        local lines = {}
        local passed, failed, warnings = 0, 0, 0
        local function record(ok, label, detail)
            if ok then
                passed += 1
                table.insert(lines, "[OK] " .. label .. (detail and (" — " .. tostring(detail)) or ""))
            else
                failed += 1
                table.insert(lines, "[HATA] " .. label .. (detail and (" — " .. tostring(detail)) or ""))
            end
        end
        local function warn(label, detail)
            warnings += 1
            table.insert(lines, "[UYARI] " .. label .. (detail and (" — " .. tostring(detail)) or ""))
        end
        table.insert(lines, "AWD HUB RUNTIME TARAMA RAPORU")
        table.insert(lines, "Tarih: " .. os.date("%Y-%m-%d %H:%M:%S"))
        table.insert(lines, "PlaceId: " .. tostring(game.PlaceId) .. " | JobId: " .. tostring(game.JobId))
        table.insert(lines, "")

        local serviceNames = {"Players", "RunService", "TweenService", "HttpService", "TeleportService", "UserInputService"}
        for _, serviceName in ipairs(serviceNames) do
            local ok, service = pcall(function() return game:GetService(serviceName) end)
            record(ok and service ~= nil, "Servis: " .. serviceName)
        end
        record(player ~= nil and player.Parent == Players, "LocalPlayer", player and player.Name or "LocalPlayer yok")
        record(type(CreateTab) == "function" and type(AddButton) == "function" and type(AddToggle) == "function", "UI çekirdek fonksiyonları")
        record(type(rejoinServer) == "function", "Rejoin fonksiyonu")
        record(type(_G.AWD_RefreshUserDirectory) == "function", "Kullanıcı dizini yenileme fonksiyonu")
        if type(getRequestFunction) ~= "function" or not getRequestFunction() then
            warn("HTTP isteği", "Executor request/syn.request/http_request sağlamıyor; çevrimiçi dizin gibi ağ özellikleri çalışmayabilir.")
        else
            record(true, "HTTP request fonksiyonu")
        end
        record(type(tabs) == "table" and #tabs >= 10, "Sekme kayıtları", tostring(type(tabs) == "table" and #tabs or 0) .. " sekme")

        local scanned, missingCallbacks, orphaned = 0, 0, 0
        for _, item in ipairs(AWD_ControlRegistry or {}) do
            scanned += 1
            local parentOk = item.parent ~= nil and item.parent.Parent ~= nil
            local callbackOk = type(item.callback) == "function"
            if not parentOk then orphaned += 1 end
            if not callbackOk then missingCallbacks += 1 end
            if not parentOk or not callbackOk then
                record(false, item.kind .. ": " .. tostring(item.name), not parentOk and "UI öğesi artık bağlı değil" or "callback fonksiyonu yok")
            end
        end
        record(missingCallbacks == 0 and orphaned == 0,
            "Arayüz callback denetimi",
            string.format("%d kontrol incelendi; %d callback eksik; %d UI öğesi kopuk", scanned, missingCallbacks, orphaned))

        -- Tarama butonu ve rapor kutusu da kontrol listesine dahil edildiğinden raporu ürettikten sonra kendisini de sayar.
        table.insert(lines, "")
        table.insert(lines, string.format("ÖZET: %d başarılı | %d hata | %d uyarı | %d kontrol", passed, failed, warnings, scanned))
        table.insert(lines, "Not: Callback'ler güvenlik için otomatik çalıştırılmaz. Dış servislerin, oyun içi koşulların ve teleport'un gerçek başarısı yalnızca bu statik/runtime kontrollerle garanti edilemez.")
        lastScanLog = table.concat(lines, "\n")
        scanOutput.Text = lastScanLog
        scanStatus.Text = string.format("Tarama tamamlandı: %d başarılı / %d hata / %d uyarı", passed, failed, warnings)
        scanStatus.TextColor3 = failed > 0 and Color3.fromRGB(255, 125, 125) or Color3.fromRGB(115, 220, 155)
        local copied = false
        local saved = false
        pcall(function() if writefile then writefile("AWD_SCAN_LOG.txt", lastScanLog); saved = true end end)
        pcall(function() if setclipboard then setclipboard(lastScanLog); copied = true end end)
        if not copied then pcall(function() if toclipboard then toclipboard(lastScanLog); copied = true end end) end
        local delivery = copied and "Rapor panoya kopyalandı" or "Rapor Tarama sekmesinde hazır"
        if saved then delivery = delivery .. " ve AWD_SCAN_LOG.txt dosyasına kaydedildi" end
        notify("AWD Tarama", delivery .. ".")
    end
    AddButton(tabScan, "Tüm Scripti Tara", runAWDScan)
    AddButton(tabScan, "Logu Panoya Kopyala", function()
        if lastScanLog == "" then notify("AWD Tarama", "Önce tarama yap."); return end
        local copied = false
        pcall(function() if setclipboard then setclipboard(lastScanLog); copied = true end end)
        if not copied then pcall(function() if toclipboard then toclipboard(lastScanLog); copied = true end end) end
        notify("AWD Tarama", copied and "Log kopyalandı." or "Clipboard desteği yok; log kutusundan kopyala.")
    end)
end
