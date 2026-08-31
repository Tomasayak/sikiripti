_G.BalikWaffenReloadSource = [====[
-- [[ ANANISTAN WAFFEN 2.0 - FULLY CUSTOMIZABLE SÜRÜM ]] --

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer

-- [[ SINGLETON: AYNI SCRIPTİN ÖNCEKİ KOPYASINI KAPAT ]] --
if type(_G.AnanistanWaffenCleanup) == "function" then
    pcall(_G.AnanistanWaffenCleanup)
end

-- [[ SCOPING İÇİN GEREKLİ ÖN TANIMLAMALAR ]] --
bgImageLabel = nil
blurOverlay = nil

-- [[ ORİJİNAL TÜM FONKSİYONLAR ]] --

parachuteEnabled = false
parachuteConnection = nil
parachuteTrack = nil

local function runParachute(button)
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

local function runFullbright(button)
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

local function runGrapple()
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

local function isFriend(target)
    if friendCache[target.UserId] ~= nil then
        return friendCache[target.UserId]
    end
    local ok, result = pcall(function()
        return player:IsFriendsWith(target.UserId)
    end)
    friendCache[target.UserId] = ok and result or false
    return friendCache[target.UserId]
end

local function getESPColor(target)
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

local function clearESP()
    for _, obj in pairs(espObjects) do
        if obj.box then pcall(game.Destroy, obj.box) end
        if obj.billboard then pcall(game.Destroy, obj.billboard) end
        if obj.highlight then pcall(game.Destroy, obj.highlight) end
    end
    espObjects = {}
end

local function buildESP(target, useChams)
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

local function updateAllESP()
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

local function runFly()
    local UserInputService = game:GetService("UserInputService")
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
 
    if isMobile then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/396abc/Script/refs/heads/main/MobileFly.lua"))()
    else
        loadstring(game:HttpGet("https://pastebin.com/raw/ByKS7S6k"))()
    end
end

local function runInfiniteYield()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end

local function runBalikAI()
    pcall(function()
        loadstring(game:HttpGet("https://pastebin.com/raw/x6G1dmEZ"))()
    end)
end

local function runBalikPew()
    local ok, err = pcall(function()
        local source = game:HttpGet("https://pastebin.com/raw/fsZRgdrB")
        local fn = loadstring(source)
        if not fn then
            error("ANANISTAN Pew loadstring oluşturulamadı")
        end
        fn()
    end)
    if not ok then
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "ANANISTAN Pew",
                Text = "Yükleme başarısız: " .. tostring(err),
                Duration = 5
            })
        end)
    end
end

local function runSpiderWeb1()
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

local function runSpiderWeb2()
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

local function getCharacterHumanoid()
    local char = player.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getCharacterRoot()
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

local function setKosatkaHeight(value)
    kosatkaHeight = math.clamp(tonumber(value) or 0.5, 0, 8)
end

local function saveKosatkaCollision(char)
    kosatkaSavedCollision = {}
    if not char then return end
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("BasePart") then
            kosatkaSavedCollision[obj] = obj.CanCollide
            obj.CanCollide = false
        end
    end
end

local function forceKosatkaNoclip(char)
    if not char then return end
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CanCollide = false
            obj.CanTouch = false
            obj.CanQuery = true
        end
    end
end

local function restoreKosatkaCollision()
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

local function stopKosatka()
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

local function getKosatkaSurfaceY(root, char)
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

local function startKosatka()
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

local function toggleKosatka(state)
    if state then
        startKosatka()
    else
        stopKosatka()
    end
end

local function setWalkSpeed(value)
    movementWalkSpeed = value
    local hum = getCharacterHumanoid()
    if hum and not freezeCharacterEnabled then
        hum.WalkSpeed = value
    end
end

local function setJumpPower(value)
    movementJumpPower = value
    local hum = getCharacterHumanoid()
    if hum and not freezeCharacterEnabled then
        hum.UseJumpPower = true
        hum.JumpPower = value
    end
end

local function setGravity(value)
    movementGravity = value
    workspace.Gravity = value
end

local function toggleInfiniteJump(state)
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

local function toggleNoclip(state)
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

local function toggleFreezeCharacter(state)
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

local function resetCharacter()
    local hum = getCharacterHumanoid()
    if hum then
        hum.Health = 0
    else
        local char = player.Character
        if char then char:BreakJoints() end
    end
end

local function teleportToInstance(instance)
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

local function bringInstanceToPlayer(instance)
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

local function saveCurrentLocation(name)
    local root = getCharacterRoot()
    if not root or not name or name == "" then return false end
    savedLocations[name] = root.CFrame
    return true
end

local function teleportToSavedLocation(name)
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

local function startAntiVoid()
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

local function stopAntiVoid()
    if antiVoidConn then antiVoidConn:Disconnect(); antiVoidConn = nil end
end

local function toggleAntiAFK(state)
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

local function registerObj(obj, category)
    if registry[category] then
        table.insert(registry[category], obj)
    end
end

local function applyTheme(themeName)
    local cfg = themeData[themeName]
    if not cfg then return end
    currentTheme = themeName

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
            tween(btn, {BackgroundColor3 = cfg.ButtonBG, BackgroundTransparency = 0.2, TextColor3 = cfg.Text})
            tween(ind, {BackgroundColor3 = cfg.Accent})
        else -- Seçili olmayan sekme
            tween(btn, {BackgroundColor3 = cfg.UnselectedTabBtn, BackgroundTransparency = 0.6, TextColor3 = cfg.Text})
        end
    end
end

-- [[ YENİ UI - SMOOTH, COOL, KAPANMA SORUNU ÇÖZÜLDÜ, SİMGELER GÜNCELLENDİ ]] --

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ANANISTANWaffenUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling -- Katman uyumluluğu için Sibling yapıldı
screenGui.Parent = CoreGui

-- Bu kopya, bir sonraki ANANISTAN Waffen açılışında temizlenecek.
_G.AnanistanWaffenCleanup = function()
    pcall(function()
        if _G.BalikWaffenBodycamStopPlayback then _G.BalikWaffenBodycamStopPlayback() end
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
    _G.AnanistanWaffenCleanup = nil
end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 760, 0, 560)
mainFrame.Position = UDim2.new(0.5, -380, 0.5, -280)
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

local function updateBlur()
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
title.Text = "ϟϟ ANANISTAN WAFFEN ϟϟ"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 6
registerObj(title, "Text")

local function smoothTween(obj, props, duration)
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
            Title = "ANANISTAN Waffen",
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

-- Tab Navigasyon Alanı
local tabNav = Instance.new("Frame", mainFrame)
tabNav.Size = UDim2.new(1, -20, 0, 48)
tabNav.Position = UDim2.new(0, 10, 0, 55)
tabNav.BackgroundTransparency = 1
tabNav.BorderSizePixel = 0
tabNav.ZIndex = 5

local tabLayout = Instance.new("UIListLayout", tabNav)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 6)

local contentArea = Instance.new("Frame", mainFrame)
contentArea.Size = UDim2.new(1, -20, 1, -110)
contentArea.Position = UDim2.new(0, 10, 0, 100)
contentArea.BackgroundTransparency = 1
contentArea.ZIndex = 5

local tabs = {}

local function CreateTab(name)
    local tabBtn = Instance.new("TextButton", tabNav)
    tabBtn.Size = UDim2.new(1/12, -5, 1, 0) -- 12 Sekme İçin Tam Ölçeklendirme Yapıldı
    tabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    tabBtn.BackgroundTransparency = 0.6
    tabBtn.Text = name
    tabBtn.TextColor3 = Color3.fromRGB(160, 160, 190)
    tabBtn.Font = Enum.Font.GothamMedium
    tabBtn.TextSize = 11.5 -- Büyütülmüş panelde tab isimleri için
    tabBtn.BorderSizePixel = 0
    tabBtn.ZIndex = 6
    registerObj(tabBtn, "Text")
    
    local tabCorner = Instance.new("UICorner", tabBtn)
    tabCorner.CornerRadius = UDim.new(0, 10)

    local indicator = Instance.new("Frame", tabBtn)
    indicator.Size = UDim2.new(1, -10, 0, 3)
    indicator.Position = UDim2.new(0, 5, 1, -5)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
    indicator.BorderSizePixel = 0
    indicator.Visible = false
    indicator.ZIndex = 6
    registerObj(indicator, "Accent")
    
    local indCorner = Instance.new("UICorner", indicator)
    indCorner.CornerRadius = UDim.new(0, 2)

    local scroll = Instance.new("ScrollingFrame", contentArea)
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 5
    scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
    scroll.Visible = false
    scroll.ZIndex = 5
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

    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.Frame.Visible = false
            t.Indicator.Visible = false
        end
        scroll.Visible = true
        indicator.Visible = true
        applyTheme(currentTheme) -- Seçim tetiklendiğinde temayı o butona hemen uygula
    end)

    return scroll, tabData
end

local function AddButton(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    btn.Text = ""
    btn.ZIndex = 5
    registerObj(btn, "ButtonBG")
    
    local cornerBtn = Instance.new("UICorner", btn)
    cornerBtn.CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel", btn)
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 6
    registerObj(label, "Text")
    
    btn.MouseButton1Click:Connect(function() pcall(callback) end)
    return btn
end

local function AddToggle(parent, text, defaultState, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 38)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    frame.ZIndex = 5
    registerObj(frame, "ButtonBG")
    
    local cornerFrame = Instance.new("UICorner", frame)
    cornerFrame.CornerRadius = UDim.new(0, 8)
    
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

local function AddColorPicker(parent, text, defaultColor, callback)
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

local function AddTextBox(parent, placeholder, callback)
    local box = Instance.new("TextBox", parent)
    box.Size = UDim2.new(1, -10, 0, 35)
    box.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
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
    boxCorner.CornerRadius = UDim.new(0, 8)
    box.FocusLost:Connect(function() pcall(function() callback(box.Text) end) end)
    return box
end

local function AddSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    frame.ZIndex = 5
    registerObj(frame, "ButtonBG")
    
    local frameCorner = Instance.new("UICorner", frame)
    frameCorner.CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 6
    registerObj(label, "Text")

    local sliderBg = Instance.new("Frame", frame)
    sliderBg.Size = UDim2.new(1, -20, 0, 5)
    sliderBg.Position = UDim2.new(0, 10, 1, -14)
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    sliderBg.ZIndex = 5
    local sliderBgCorner = Instance.new("UICorner", sliderBg)
    sliderBgCorner.CornerRadius = UDim.new(0, 3)

    local sliderFill = Instance.new("Frame", sliderBg)
    sliderFill.Size = UDim2.new(math.clamp((default - min) / (max - min), 0, 1), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
    sliderFill.ZIndex = 6
    registerObj(sliderFill, "Accent")
    
    local sliderFillCorner = Instance.new("UICorner", sliderFill)
    sliderFillCorner.CornerRadius = UDim.new(0, 3)

    local sliderBtn = Instance.new("TextButton", sliderBg)
    sliderBtn.Size = UDim2.new(0, 14, 0, 14)
    sliderBtn.Position = UDim2.new(math.clamp((default - min) / (max - min), 0, 1), -7, 0.5, -7)
    sliderBtn.BackgroundColor3 = Color3.new(1,1,1)
    sliderBtn.Text = ""
    sliderBtn.ZIndex = 6
    local sliderBtnCorner = Instance.new("UICorner", sliderBtn)
    sliderBtnCorner.CornerRadius = UDim.new(0, 7)

    local function update(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        sliderBtn.Position = UDim2.new(pos, -7, 0.5, -7)
        local val = math.floor(min + (max - min) * pos)
        callback(val)
    end

    local dragging = false
    sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dragging = true 
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

    return function(val)
        local pos = math.clamp((val - min) / (max - min), 0, 1)
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        sliderBtn.Position = UDim2.new(pos, -7, 0.5, -7)
    end, frame
end

local function AddLabel(parent, text, tall)
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


-- [[ AIMBOT / SILENT AIM / TRIGGERBOT ]] --
local aimbotEnabled = false
local aimbotKey = Enum.KeyCode.Q
local aimbotTarget = nil
local aimbotHighlight = nil
local aimbotRenderConn = nil
local triggerbotConn = nil
local settingAimbotKey = false

-- Aim settings
local aimbotMaxFov = 100
local aimbotSmoothness = 0.18
local aimbotTargetPart = "Head"
local aimbotTeamCheck = false
local aimbotFriendCheck = false
local aimbotWallCheck = true
local aimbotAliveCheck = true
local aimbotStickyAim = true
local aimbotPrediction = 0
local aimbotAutoSwitch = false
local aimbotShowFov = false
local aimbotFovCircle = nil

-- Silent aim / triggerbot settings
local silentAimEnabled = false
local silentAimFov = 100
local silentAimPart = "Head"
local silentAimTeamCheck = true
local silentAimFriendCheck = true
local silentAimWallCheck = true
local triggerbotEnabled = false
local triggerbotDelay = 0.05
local triggerbotFov = 8
local triggerbotTeamCheck = true
local triggerbotFriendCheck = true
local triggerbotWallCheck = true
local lastTriggerTime = 0

local friendCache = friendCache or {}

local function isAimbotFriend(target)
    if not target then return false end
    if friendCache[target.UserId] ~= nil then return friendCache[target.UserId] end
    local ok, result = pcall(function()
        return player:IsFriendsWith(target.UserId)
    end)
    friendCache[target.UserId] = ok and result or false
    return friendCache[target.UserId]
end

local function sameAimbotTeam(target)
    if not target or not player then return false end
    if player.Team and target.Team then
        return player.Team == target.Team
    end
    return false
end

local function isAimbotAlive(target)
    if not target or not target.Character then return false end
    local hum = target.Character:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function getAimPart(target, preferred)
    if not target or not target.Character then return nil end
    local char = target.Character
    local part = char:FindFirstChild(preferred or "Head")
    if part and part:IsA("BasePart") then return part end
    for _, name in ipairs({"Head", "UpperTorso", "Torso", "HumanoidRootPart"}) do
        local fallback = char:FindFirstChild(name)
        if fallback and fallback:IsA("BasePart") then return fallback end
    end
    return nil
end

local function hasLineOfSight(target, part)
    if not aimbotWallCheck and not silentAimWallCheck and not triggerbotWallCheck then return true end
    local camera = workspace.CurrentCamera
    if not camera or not part then return false end
    local origin = camera.CFrame.Position
    local direction = part.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {player.Character}
    params.IgnoreWater = true
    local hit = workspace:Raycast(origin, direction, params)
    return hit == nil or (target.Character and hit.Instance and hit.Instance:IsDescendantOf(target.Character))
end

local function passesTargetFilters(target, mode)
    if not target or target == player or not target.Character then return false end
    if aimbotAliveCheck and not isAimbotAlive(target) then return false end

    if mode == "silent" then
        if silentAimTeamCheck and sameAimbotTeam(target) then return false end
        if silentAimFriendCheck and isAimbotFriend(target) then return false end
    elseif mode == "trigger" then
        if triggerbotTeamCheck and sameAimbotTeam(target) then return false end
        if triggerbotFriendCheck and isAimbotFriend(target) then return false end
    else
        if aimbotTeamCheck and sameAimbotTeam(target) then return false end
        if aimbotFriendCheck and isAimbotFriend(target) then return false end
    end
    return true
end

local function clearAimbotTarget()
    if aimbotHighlight then
        pcall(function() aimbotHighlight:Destroy() end)
        aimbotHighlight = nil
    end
    aimbotTarget = nil
end

local function setAimbotTarget(target)
    if aimbotTarget == target and aimbotHighlight and aimbotHighlight.Parent then return end
    clearAimbotTarget()
    if not target or not target.Character then return end
    aimbotTarget = target

    local hl = Instance.new("Highlight")
    hl.Name = "ANANISTAN_AimbotTarget"
    hl.Adornee = target.Character
    hl.FillColor = Color3.fromRGB(255, 0, 0)
    hl.OutlineColor = Color3.fromRGB(255, 0, 0)
    hl.FillTransparency = 0.45
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = target.Character
    aimbotHighlight = hl
end

local function getClosestPlayerToMouse(maxFov, mode, preferredPart, wallCheck)
    local camera = workspace.CurrentCamera
    if not camera then return nil end

    local mousePos = UIS:GetMouseLocation()
    local bestPlayer, bestDistance = nil, math.huge

    for _, target in ipairs(Players:GetPlayers()) do
        if passesTargetFilters(target, mode) then
            local part = getAimPart(target, preferredPart)
            if part then
                local screenPos, visible = camera:WorldToViewportPoint(part.Position)
                if visible and screenPos.Z > 0 then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    local los = true
                    if wallCheck then
                        local origin = camera.CFrame.Position
                        local direction = part.Position - origin
                        local params = RaycastParams.new()
                        params.FilterType = Enum.RaycastFilterType.Exclude
                        params.FilterDescendantsInstances = {player.Character}
                        params.IgnoreWater = true
                        local hit = workspace:Raycast(origin, direction, params)
                        los = hit == nil or (hit.Instance and target.Character and hit.Instance:IsDescendantOf(target.Character))
                    end
                    if los and distance <= maxFov and distance < bestDistance then
                        bestDistance = distance
                        bestPlayer = target
                    end
                end
            end
        end
    end
    return bestPlayer
end

local function getPredictedPosition(part, prediction)
    if not part then return nil end
    local velocity = part.AssemblyLinearVelocity
    return part.Position + velocity * (tonumber(prediction) or 0)
end

local function aimMouseAtTarget(target)
    if not target or not target.Character then return end
    local part = getAimPart(target, aimbotTargetPart)
    if not part then return end
    local camera = workspace.CurrentCamera
    if not camera then return end

    local pos = getPredictedPosition(part, aimbotPrediction)
    local screenPos, visible = camera:WorldToViewportPoint(pos)
    if not visible or screenPos.Z <= 0 then return end

    local mousePos = UIS:GetMouseLocation()
    local delta = Vector2.new(screenPos.X, screenPos.Y) - mousePos
    if type(mousemoverel) == "function" then
        pcall(function()
            mousemoverel(delta.X * aimbotSmoothness, delta.Y * aimbotSmoothness)
        end)
    end
end

local function updateFovCircle()
    -- Drawing API destekleniyorsa FOV dairesi gösterilir.
    if not aimbotShowFov then
        if aimbotFovCircle then pcall(function() aimbotFovCircle.Visible = false end) end
        return
    end
    if type(Drawing) ~= "table" or type(Drawing.new) ~= "function" then return end
    if not aimbotFovCircle then
        local ok, circle = pcall(Drawing.new, "Circle")
        if ok and circle then
            aimbotFovCircle = circle
            circle.Filled = false
            circle.Thickness = 1
            circle.NumSides = 64
            circle.Color = Color3.fromRGB(255, 255, 255)
        end
    end
    if aimbotFovCircle then
        local pos = UIS:GetMouseLocation()
        aimbotFovCircle.Position = pos
        aimbotFovCircle.Radius = aimbotMaxFov
        aimbotFovCircle.Visible = true
    end
end

local function triggerMouse()
    local now = os.clock()
    if now - lastTriggerTime < triggerbotDelay then return end
    lastTriggerTime = now
    if type(mouse1press) == "function" and type(mouse1release) == "function" then
        pcall(function()
            mouse1press()
            task.wait(0.02)
            mouse1release()
        end)
    elseif type(mouse1click) == "function" then
        pcall(mouse1click)
    end
end

local function triggerbotStep()
    if not triggerbotEnabled then return end
    local target = getClosestPlayerToMouse(triggerbotFov, "trigger", "Head", triggerbotWallCheck)
    if target then triggerMouse() end
end

local function stopAimbot()
    aimbotEnabled = false
    if silentAimConn then
        silentAimConn:Disconnect()
        silentAimConn = nil
    end
    clearSilentAimTarget()
    if aimbotRenderConn then
        aimbotRenderConn:Disconnect()
        aimbotRenderConn = nil
    end
    if triggerbotConn then
        triggerbotConn:Disconnect()
        triggerbotConn = nil
    end
    if aimbotFovCircle then pcall(function() aimbotFovCircle.Visible = false end) end
    clearAimbotTarget()
end

local function startAimbot()
    if aimbotRenderConn then aimbotRenderConn:Disconnect() end
    aimbotRenderConn = RunService.RenderStepped:Connect(function()
        if not aimbotEnabled then return end
        updateFovCircle()
        if not UIS:IsKeyDown(aimbotKey) then
            if not aimbotStickyAim then clearAimbotTarget() end
            return
        end

        local target
        if aimbotStickyAim and aimbotTarget and passesTargetFilters(aimbotTarget, "aim") then
            local part = getAimPart(aimbotTarget, aimbotTargetPart)
            if part then
                local cam = workspace.CurrentCamera
                local sp, visible = cam:WorldToViewportPoint(part.Position)
                local dist = visible and (Vector2.new(sp.X, sp.Y) - UIS:GetMouseLocation()).Magnitude or math.huge
                if dist <= aimbotMaxFov then target = aimbotTarget end
            end
        end
        if not target or aimbotAutoSwitch then
            target = getClosestPlayerToMouse(aimbotMaxFov, "aim", aimbotTargetPart, aimbotWallCheck)
        end
        if not target then clearAimbotTarget(); return end
        setAimbotTarget(target)
        aimMouseAtTarget(target)
    end)

    if triggerbotConn then triggerbotConn:Disconnect() end
    triggerbotConn = RunService.RenderStepped:Connect(triggerbotStep)
end

local function toggleAimbot(state)
    aimbotEnabled = state
    if state then startAimbot() else stopAimbot() end
end

local silentAimTarget = nil
local silentAimConn = nil

local function clearSilentAimTarget()
    silentAimTarget = nil
end

local function updateSilentAimTarget()
    if not silentAimEnabled then
        clearSilentAimTarget()
        return
    end
    local target = getClosestPlayerToMouse(silentAimFov, "silent", silentAimPart, silentAimWallCheck)
    silentAimTarget = target
end

local function toggleSilentAim(state)
    silentAimEnabled = state
    if silentAimConn then
        silentAimConn:Disconnect()
        silentAimConn = nil
    end
    clearSilentAimTarget()
    if state then
        silentAimConn = RunService.RenderStepped:Connect(updateSilentAimTarget)
    end
end

local function getSilentAimTarget()
    if not silentAimEnabled then return nil end
    if silentAimTarget and passesTargetFilters(silentAimTarget, "silent") then
        local part = getAimPart(silentAimTarget, silentAimPart)
        if part and hasLineOfSight(silentAimTarget, part) then
            return silentAimTarget, part
        end
    end
    updateSilentAimTarget()
    if silentAimTarget then
        return silentAimTarget, getAimPart(silentAimTarget, silentAimPart)
    end
    return nil
end

-- Keybind Değişkenleri
local menuToggleKey = Enum.KeyCode.Insert
local espToggleKey = Enum.KeyCode.T
local settingESPKey = false
local settingMenuKey = false


-- [[ SERVER / REJOIN / SERVER HOP / SERVER FINDER / USER SNIPE ]] --
local function notify(title, text)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = 4})
    end)
end

local function getRequestFunction()
    return (syn and syn.request) or request or http_request
end

local function requestJson(url)
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

local function rejoinServer()
    pcall(function()
        TeleportService:Teleport(game.PlaceId, player)
    end)
end

local function getPublicServers(placeId, cursor)
    local url = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", tostring(placeId))
    if cursor and cursor ~= "" then
        url = url .. "&cursor=" .. HttpService:UrlEncode(cursor)
    end
    return requestJson(url)
end

local function serverHop(targetMaxPlayers)
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
        notify("ANANISTAN Waffen", "Uygun server bulunamadı")
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

local function findServerByPlayerCount(count)
    count = tonumber(count)
    if not count then
        notify("ANANISTAN Waffen", "Geçerli oyuncu sayısı gir")
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

local function userSnipe(placeId, username)
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

local function getServerInfoText()
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
local tabSpider, tD5 = CreateTab("Grapple")
local tabVisuals, tD3 = CreateTab("Görseller")
local tabKeybinds, tD7 = CreateTab("Keybind")
local tabAimbot, tDAimbot = CreateTab("Aimbot")
local tabSettings, tD4 = CreateTab("Temalar")
local tabDesigner, tD8 = CreateTab("Dizayn")
local tabSlots, tD9 = CreateTab("Slotlar") -- YENİ SLOT TABI
_G.BalikTabPlayers, _G.BalikTabPlayersData = CreateTab("Oyuncular")
_G.BalikTabBodycams, _G.BalikTabBodycamsData = CreateTab("Bodycams")
_G.BalikTabPlayersData.Btn.TextSize = 8.5
_G.BalikTabBodycamsData.Btn.TextSize = 8.5


-- [[ ANANISTAN BODYCAM / OYUNCULAR SİSTEMİ ]] --
_G.BalikWaffenBodycamState = _G.BalikWaffenBodycamState or {
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

_G.BalikWaffenBodycamState.selectedUserId = _G.BalikWaffenBodycamState.selectedUserId or player.UserId

-- [[ ANANISTAN BODYCAM HUD / GERÇEK BODYCAM STİLİ ]]
_G.BalikWaffenBodycamCreateHUD = _G.BalikWaffenBodycamCreateHUD or function()
    local st = _G.BalikWaffenBodycamState
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

_G.BalikWaffenBodycamSetHUD = _G.BalikWaffenBodycamSetHUD or function(enabled, mode, elapsed)
    local hud = _G.BalikWaffenBodycamCreateHUD()
    local st = _G.BalikWaffenBodycamState
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

_G.BalikWaffenBodycamSetHUD(false)

-- [[ BODYCAM DOSYA KAYDI / KALICI DEPOLAMA ]]
_G.BalikWaffenBodycamFileName = _G.BalikWaffenBodycamFileName or "BalikWaffen_Bodycams.json"

_G.BalikWaffenBodycamSerializeCFrame = function(cf)
    local a,b,c,d,e,f,g,h,i,j,k,l = cf:GetComponents()
    return {a,b,c,d,e,f,g,h,i,j,k,l}
end

_G.BalikWaffenBodycamDeserializeCFrame = function(data)
    if type(data) ~= "table" or #data < 12 then return nil end
    local ok, cf = pcall(function()
        return CFrame.new(table.unpack(data, 1, 12))
    end)
    return ok and cf or nil
end

_G.BalikWaffenBodycamHasFileIO = function()
    return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
end

_G.BalikWaffenBodycamSaveToFile = function()
    local st = _G.BalikWaffenBodycamState
    if not _G.BalikWaffenBodycamHasFileIO() then
        st.fileStatus = "File API yok - sadece oturum belleği"
        return false
    end

    local payload = {version = 1, games = {}}
    local okDecode = pcall(function()
        if isfile(_G.BalikWaffenBodycamFileName) then
            local raw = readfile(_G.BalikWaffenBodycamFileName)
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
                local cfData = _G.BalikWaffenBodycamSerializeCFrame(frame.cf)
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

    local okWrite = pcall(function() writefile(_G.BalikWaffenBodycamFileName, encodedText) end)
    if okWrite then
        st.fileStatus = "Kayıtlar dosyaya kaydedildi"
        return true
    end
    st.fileStatus = "Dosyaya yazılamadı"
    return false
end

_G.BalikWaffenBodycamLoadFromFile = function()
    local st = _G.BalikWaffenBodycamState
    if not _G.BalikWaffenBodycamHasFileIO() then
        st.fileStatus = "File API yok - sadece oturum belleği"
        return false
    end
    if not isfile(_G.BalikWaffenBodycamFileName) then
        st.fileStatus = "Bodycam dosyası henüz yok"
        return false
    end

    local raw
    local okRead = pcall(function() raw = readfile(_G.BalikWaffenBodycamFileName) end)
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
                local cf = _G.BalikWaffenBodycamDeserializeCFrame(frame.cf)
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

_G.BalikWaffenBodycamStopPlayback = function()
    local st = _G.BalikWaffenBodycamState
    if st.playbackConn then
        pcall(function() st.playbackConn:Disconnect() end)
        st.playbackConn = nil
    end
    st.playback = false
    _G.BalikWaffenBodycamSetHUD(false)
    local cam = workspace.CurrentCamera
    if cam then
        pcall(function()
            cam.CameraType = Enum.CameraType.Custom
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then cam.CameraSubject = hum end
        end)
    end
end

pcall(function() _G.BalikWaffenBodycamLoadFromFile() end)

_G.BalikWaffenBodycamRefreshList = function()
    local st = _G.BalikWaffenBodycamState
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
            _G.BalikWaffenBodycamStopPlayback()
            local cam = workspace.CurrentCamera
            if not cam then return end
            st.playback = true
            _G.BalikWaffenBodycamSetHUD(true, "PLAYBACK", 0)
            local oldType = cam.CameraType
            local oldSubject = cam.CameraSubject
            local oldFov = cam.FieldOfView
            cam.CameraType = Enum.CameraType.Scriptable
            local started = os.clock()
            local frames = rec.frames
            st.playbackConn = RunService.RenderStepped:Connect(function()
                if not st.playback then return end
                local elapsed = os.clock() - started
                _G.BalikWaffenBodycamSetHUD(true, "PLAYBACK", elapsed)
                if elapsed >= (rec.duration or 0) then
                    st.playback = false
                    _G.BalikWaffenBodycamSetHUD(false)
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
            pcall(function() _G.BalikWaffenBodycamSaveToFile() end)
            _G.BalikWaffenBodycamRefreshList()
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

_G.BalikWaffenBodycamSelectUser = function(userId, displayName)
    local st = _G.BalikWaffenBodycamState
    st.selectedUserId = userId or player.UserId
    if st.selectedPlayerLabel then
        st.selectedPlayerLabel.Text = "Seçili Bodycam: " .. (displayName or player.DisplayName or player.Name)
    end
    _G.BalikWaffenBodycamRefreshList()
    if _G.BalikTabBodycamsData then
        for _, item in pairs(tabs) do
            item.Frame.Visible = false
            item.Indicator.Visible = false
        end
        _G.BalikTabBodycamsData.Frame.Visible = true
        _G.BalikTabBodycamsData.Indicator.Visible = true
        applyTheme(currentTheme)
    end
end

_G.BalikWaffenBodycamStart = function()
    local st = _G.BalikWaffenBodycamState
    if st.recording then return end
    _G.BalikWaffenBodycamStopPlayback()
    st.recording = true
    st.recordingFrames = {}
    st.recordingStarted = os.clock()
    _G.BalikWaffenBodycamSetHUD(true, "REC", 0)
    local userId = player.UserId
    st.statusLabel = st.statusLabel or nil
    if st.recordingConn then pcall(function() st.recordingConn:Disconnect() end) end
    local nextSample = 0
    st.recordingConn = RunService.RenderStepped:Connect(function()
        if not st.recording then return end
        local now = os.clock() - st.recordingStarted
        _G.BalikWaffenBodycamSetHUD(true, "REC", now)
        if now < nextSample then return end
        nextSample = now + (1/12)
        if now >= 3600 then
            _G.BalikWaffenBodycamStop()
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

_G.BalikWaffenBodycamStop = function()
    local st = _G.BalikWaffenBodycamState
    if not st.recording then return end
    st.recording = false
    _G.BalikWaffenBodycamSetHUD(false)
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
    pcall(function() _G.BalikWaffenBodycamSaveToFile() end)
    st.selectedUserId = player.UserId
    if st.selectedPlayerLabel then st.selectedPlayerLabel.Text = "Seçili Bodycam: " .. player.DisplayName end
    if st.statusLabel then st.statusLabel.Text = string.format("Kayıt kaydedildi  |  %d/25", #records) end
    _G.BalikWaffenBodycamRefreshList()
end

_G.BalikWaffenBodycamClearAll = function()
    local st = _G.BalikWaffenBodycamState
    st.recordings[player.UserId] = {}
    pcall(function() _G.BalikWaffenBodycamSaveToFile() end)
    st.selectedUserId = player.UserId
    if st.statusLabel then st.statusLabel.Text = "Tüm Bodycam kayıtları silindi" end
    _G.BalikWaffenBodycamRefreshList()
end

-- Oyuncular tabı
_G.BalikTabPlayersTitle = AddLabel(_G.BalikTabPlayers, "ANANISTAN Bodycam Oyuncuları")
_G.BalikTabPlayersHint = AddLabel(_G.BalikTabPlayers, "Sunucudaki oyuncuların profilini, Join ve Bodycams seçeneklerini görürsün", true)
_G.BalikBodycamPlayersScroll = Instance.new("ScrollingFrame", _G.BalikTabPlayers)
_G.BalikBodycamPlayersScroll.Size = UDim2.new(1, -10, 0, 330)
_G.BalikBodycamPlayersScroll.BackgroundTransparency = 1
_G.BalikBodycamPlayersScroll.ScrollBarThickness = 5
_G.BalikBodycamPlayersScroll.CanvasSize = UDim2.new(0,0,0,0)
_G.BalikBodycamPlayersScroll.Parent = _G.BalikTabPlayers
_G.BalikBodycamPlayersLayout = Instance.new("UIListLayout", _G.BalikBodycamPlayersScroll)
_G.BalikBodycamPlayersLayout.Padding = UDim.new(0, 6)
_G.BalikBodycamPlayersLayout.SortOrder = Enum.SortOrder.LayoutOrder
_G.BalikBodycamPlayersLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    _G.BalikBodycamPlayersScroll.CanvasSize = UDim2.new(0,0,0,_G.BalikBodycamPlayersLayout.AbsoluteContentSize.Y + 10)
end)

_G.BalikWaffenRefreshPlayersTab = function()
    local scroll = _G.BalikBodycamPlayersScroll
    if not scroll then return end
    for _, child in ipairs(scroll:GetChildren()) do
        if not child:IsA("UIListLayout") then child:Destroy() end
    end
    for _, target in ipairs(Players:GetPlayers()) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -8, 0, 66)
        row.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        row.BorderSizePixel = 0
        row.Parent = scroll
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

        local avatar = Instance.new("ImageLabel")
        avatar.Size = UDim2.new(0, 50, 0, 50)
        avatar.Position = UDim2.new(0, 8, 0.5, -25)
        avatar.BackgroundTransparency = 1
        avatar.Parent = row
        pcall(function()
            local image = Players:GetUserThumbnailAsync(target.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            avatar.Image = image
        end)

        local name = Instance.new("TextLabel")
        name.Size = UDim2.new(1, -205, 1, 0)
        name.Position = UDim2.new(0, 68, 0, 0)
        name.BackgroundTransparency = 1
        name.Text = target.DisplayName .. "\n@" .. target.Name
        name.TextColor3 = Color3.fromRGB(220,220,240)
        name.Font = Enum.Font.GothamMedium
        name.TextSize = 12
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.TextYAlignment = Enum.TextYAlignment.Center
        name.Parent = row

        local join = Instance.new("TextButton")
        join.Size = UDim2.new(0, 58, 0, 30)
        join.Position = UDim2.new(1, -125, 0.5, -15)
        join.BackgroundColor3 = Color3.fromRGB(50, 110, 65)
        join.Text = "Join"
        join.TextColor3 = Color3.fromRGB(255,255,255)
        join.Font = Enum.Font.GothamBold
        join.TextSize = 11
        join.Parent = row
        Instance.new("UICorner", join).CornerRadius = UDim.new(0, 6)
        join.MouseButton1Click:Connect(function()
            if target == player then
                notify("ANANISTAN Bodycam", "Zaten bu sunucudasın")
                return
            end
            if target.Parent then
                pcall(function() userSnipe(game.PlaceId, target.Name) end)
            end
        end)

        local bodyBtn = Instance.new("TextButton")
        bodyBtn.Size = UDim2.new(0, 58, 0, 30)
        bodyBtn.Position = UDim2.new(1, -62, 0.5, -15)
        bodyBtn.BackgroundColor3 = Color3.fromRGB(65, 75, 110)
        bodyBtn.Text = "Bodycams"
        bodyBtn.TextColor3 = Color3.fromRGB(255,255,255)
        bodyBtn.Font = Enum.Font.GothamBold
        bodyBtn.TextSize = 9
        bodyBtn.Parent = row
        Instance.new("UICorner", bodyBtn).CornerRadius = UDim.new(0, 6)
        bodyBtn.MouseButton1Click:Connect(function()
            _G.BalikWaffenBodycamSelectUser(target.UserId, target.DisplayName)
        end)
    end
end

_G.BalikTabPlayersRefresh = AddButton(_G.BalikTabPlayers, "Oyuncu Listesini Yenile", _G.BalikWaffenRefreshPlayersTab)

Players.PlayerAdded:Connect(function()
    task.defer(_G.BalikWaffenRefreshPlayersTab)
end)
Players.PlayerRemoving:Connect(function()
    task.defer(_G.BalikWaffenRefreshPlayersTab)
end)

-- Bodycams tabı
_G.BalikTabBodycamsTitle = AddLabel(_G.BalikTabBodycams, "ANANISTAN Bodycam")
_G.BalikWaffenBodycamState.selectedPlayerLabel = AddLabel(_G.BalikTabBodycams, "Seçili Bodycam: " .. player.DisplayName)
_G.BalikWaffenBodycamState.statusLabel = AddLabel(_G.BalikTabBodycams, "Hazır | Maksimum 25 kayıt | " .. tostring(_G.BalikWaffenBodycamState.fileStatus or "Dosya belleği hazır"))
AddButton(_G.BalikTabBodycams, "● Kayda Başla", function()
    _G.BalikWaffenBodycamStart()
end)
AddButton(_G.BalikTabBodycams, "■ Kaydı Durdur & Kaydet", function()
    _G.BalikWaffenBodycamStop()
end)
AddButton(_G.BalikTabBodycams, "Tüm Kayıtları Sil", function()
    _G.BalikWaffenBodycamClearAll()
end)
AddButton(_G.BalikTabBodycams, "Kayıtları Dosyaya Kaydet", function()
    local ok = _G.BalikWaffenBodycamSaveToFile()
    if _G.BalikWaffenBodycamState.statusLabel then
        _G.BalikWaffenBodycamState.statusLabel.Text = ok and "Bodycam kayıtları dosyaya kaydedildi" or ("Kaydetme başarısız: " .. tostring(_G.BalikWaffenBodycamState.fileStatus or "bilinmeyen hata"))
    end
end)
AddButton(_G.BalikTabBodycams, "Dosyadan Kayıtları Yenile", function()
    local ok = _G.BalikWaffenBodycamLoadFromFile()
    if _G.BalikWaffenBodycamState.statusLabel then
        _G.BalikWaffenBodycamState.statusLabel.Text = ok and "Bodycam kayıtları dosyadan yüklendi" or ("Yükleme başarısız: " .. tostring(_G.BalikWaffenBodycamState.fileStatus or "dosya yok"))
    end
    _G.BalikWaffenBodycamRefreshList()
end)
_G.BalikTabBodycamsHint = AddLabel(_G.BalikTabBodycams, "Kayıtlar ilk şahıs olarak oynatılır. Üçüncü şahısta kayıt başlatsan bile playback kafanın konumundan ve kaydedilmiş bakış yönünden gider.", true)

_G.BalikWaffenBodycamListScroll = Instance.new("ScrollingFrame", _G.BalikTabBodycams)
_G.BalikWaffenBodycamListScroll.Size = UDim2.new(1, -10, 0, 250)
_G.BalikWaffenBodycamListScroll.BackgroundTransparency = 1
_G.BalikWaffenBodycamListScroll.ScrollBarThickness = 5
_G.BalikWaffenBodycamListScroll.CanvasSize = UDim2.new(0,0,0,0)
_G.BalikWaffenBodycamListScroll.Parent = _G.BalikTabBodycams
_G.BalikWaffenBodycamState.bodycamListFrame = _G.BalikWaffenBodycamListScroll
_G.BalikWaffenBodycamListLayout = Instance.new("UIListLayout", _G.BalikWaffenBodycamListScroll)
_G.BalikWaffenBodycamListLayout.Padding = UDim.new(0, 6)
_G.BalikWaffenBodycamListLayout.SortOrder = Enum.SortOrder.LayoutOrder
_G.BalikWaffenBodycamListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    _G.BalikWaffenBodycamListScroll.CanvasSize = UDim2.new(0,0,0,_G.BalikWaffenBodycamListLayout.AbsoluteContentSize.Y + 10)
end)
_G.BalikWaffenBodycamRefreshList()
_G.BalikWaffenRefreshPlayersTab()

-- Ana Sayfa
AddLabel(tabMain, "YAPIMCILAR")

local function AddCreatorCard(parent, username)
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
    nameLabel.Text = username
    nameLabel.TextColor3 = Color3.fromRGB(220, 220, 240)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 6
    registerObj(nameLabel, "Text")

    task.spawn(function()
        local ok, userId = pcall(function()
            return Players:GetUserIdFromNameAsync(username)
        end)
        if ok and userId then
            avatar.Image = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", userId)
            card.MouseButton1Click:Connect(function()
                local profile = "https://www.roblox.com/users/" .. tostring(userId) .. "/profile"
                local copied = false
                pcall(function()
                    if setclipboard then setclipboard(profile); copied = true end
                end)
                pcall(function()
                    if toclipboard and not copied then toclipboard(profile); copied = true end
                end)
                notify(username, copied and "Profil bağlantısı panoya kopyalandı" or profile)
            end)
        end
    end)
    return card
end

AddCreatorCard(tabMain, "35YARGIC")
AddCreatorCard(tabMain, "Ananistan_Doom")
AddLabel(tabMain, "BU SCRIPT ARTHURMORGAN4000 VE DUTCHVANDER4000 TARAFINDAN YAPILMIŞTIR ÇALANI SİKERİZ", true)
AddLabel(tabMain, "Menü Araçları")
AddButton(tabMain, "ANANISTAN AI", runBalikAI)
AddButton(tabMain, "ANANISTAN Pew", runBalikPew)
AddButton(tabMain, "Infinite Yield", runInfiniteYield)
AddButton(tabMain, "Aimbot", function() pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/WhJDjCag"))() end) end)
AddButton(tabMain, "Remote Spy", function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/InfernusScripts/Ketamine/refs/heads/main/Ketamine.lua"))() end) end)
AddButton(tabMain, "Server Hop", function() serverHop(nil) end)
AddButton(tabMain, "PlaceId Kopyala", function()
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
    notify("ANANISTAN Waffen", copied and "PlaceId kopyalandı: " .. placeIdText or "Clipboard desteklenmiyor: " .. placeIdText)
end)

AddLabel(tabMain, "Server Bulucu")
local serverPlayerCountBox = AddTextBox(tabMain, "Hedef oyuncu sayısı...", function() end)
AddButton(tabMain, "Oyuncu Sayısına Göre Server Bul", function()
    findServerByPlayerCount(serverPlayerCountBox.Text)
end)

AddLabel(tabMain, "Kullanıcı Snipeleme")
local snipePlaceIdBox = AddTextBox(tabMain, "Oyun / PlaceId...", function() end)
snipePlaceIdBox.Text = tostring(game.PlaceId)
local snipeUsernameBox = AddTextBox(tabMain, "Kullanıcı adı...", function() end)
AddButton(tabMain, "Kullanıcıya Joinlen", function()
    userSnipe(snipePlaceIdBox.Text, snipeUsernameBox.Text)
end)

AddLabel(tabMain, "Server Bilgileri")
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
    if _G.AnanistanWaffenCleanup then _G.AnanistanWaffenCleanup = nil end
end)

-- Oyuncu
AddLabel(tabPlayer, "Karakter Modları")
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
AddToggle(tabPlayer, "Parachute", parachuteEnabled, function(state)
    local fakeBtn = {Text = ""}
    parachuteEnabled = not state
    runParachute(fakeBtn) 
end)
AddButton(tabPlayer, "Görünmezlik", function()
    loadstring(game:HttpGet('https://pastebin.com/raw/3Rnd9rHf'))()
end)
AddButton(tabPlayer, "Yaw Fly", runFly)
AddButton(tabPlayer, "ANANISTAN Antigravity", function()
    pcall(function()
        loadstring(game:HttpGet("https://pastebin.com/raw/TPQRxApG"))()
    end)
end)
AddLabel(tabPlayer, "Hareket Ayarları")
AddSlider(tabPlayer, "WalkSpeed", 0, 200, movementWalkSpeed, function(val)
    setWalkSpeed(val)
end)
AddSlider(tabPlayer, "JumpPower", 0, 300, movementJumpPower, function(val)
    setJumpPower(val)
end)
AddSlider(tabPlayer, "Gravity", 0, 500, movementGravity, function(val)
    setGravity(val)
end)
AddButton(tabPlayer, "Hareket Ayarlarını Normale Çevir", function()
    if kosatkaEnabled then stopKosatka() end
    movementWalkSpeed = 16
    movementJumpPower = 50
    movementGravity = 196.2
    workspace.Gravity = 196.2

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
AddLabel(tabAimbot, "Mouse Aimbot")
AddLabel(tabAimbot, "Mouseyi oyuncunun üstüne getir, Keybind sekmesindeki tuşa basılı tut. Aimbot sadece kafayı takip eder.", true)
AddToggle(tabAimbot, "Aimbot", false, function(state)
    toggleAimbot(state)
end)
AddToggle(tabAimbot, "Team Check", aimbotTeamCheck, function(s) aimbotTeamCheck = s end)
AddToggle(tabAimbot, "Friend Check", aimbotFriendCheck, function(s) aimbotFriendCheck = s end)
AddToggle(tabAimbot, "Wall Check", aimbotWallCheck, function(s) aimbotWallCheck = s end)
AddToggle(tabAimbot, "Sticky Aim", aimbotStickyAim, function(s) aimbotStickyAim = s end)
AddToggle(tabAimbot, "Auto Switch", aimbotAutoSwitch, function(s) aimbotAutoSwitch = s end)
AddToggle(tabAimbot, "FOV Circle", aimbotShowFov, function(s) aimbotShowFov = s end)
AddToggle(tabAimbot, "Silent Aim Targeting", silentAimEnabled, function(s) toggleSilentAim(s) end)
AddToggle(tabAimbot, "Triggerbot", triggerbotEnabled, function(s) triggerbotEnabled = s end)
AddLabel(tabAimbot, "Target: Head | FOV: 100 | Prediction: 0 | Smooth: 0.18")

AddButton(tabAimbot, "Aimbot Tuşunu Değiştir", function()
    if aimbotKeyBtn then
        aimbotKeyBtn:Activate()
    end
end)
local aimbotActiveKeyLabel = AddLabel(tabAimbot, "Aktif Tuş: Q")

-- Grapple
AddLabel(tabSpider, "Grapple Hook")
AddButton(tabSpider, "Grapple 1 (Çekme)", runSpiderWeb1)
AddButton(tabSpider, "Grapple 2 (Tutunma)", runSpiderWeb2)
AddButton(tabMain, "Script Reload", function()
    pcall(function()
        if _G.BalikWaffenReload then
            _G.BalikWaffenReload()
        else
            notify("ANANISTAN Waffen", "Reload sistemi hazır değil")
        end
    end)
end)

-- Görseller
AddLabel(tabVisuals, "ESP")
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
_G.BalikWaffenWorkspaceNameESPBoxVisuals = AddTextBox(tabVisuals, "Workspace obje adı gir...", function(text)
    pcall(function()
        _G.BalikWaffenNameSearchWorkspaceESP(text)
    end)
end)
AddButton(tabVisuals, "İsim ESP Temizle", function()
    pcall(function()
        _G.BalikWaffenClearWorkspaceESP()
    end)
    if _G.BalikWaffenWorkspaceNameESPBoxVisuals then
        _G.BalikWaffenWorkspaceNameESPBoxVisuals.Text = ""
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

-- Keybind Tabı
AddLabel(tabKeybinds, "Kısayol Tuş Atamaları")

local espKeyBtn = AddButton(tabKeybinds, "ESP Aç/Kapat: [T]", function() end)
local espKeyLabel = espKeyBtn:FindFirstChildOfClass("TextLabel")

local menuKeyBtn = AddButton(tabKeybinds, "Menü Aç/Kapat: [Insert]", function() end)
local menuKeyLabel = menuKeyBtn:FindFirstChildOfClass("TextLabel")

local aimbotKeyBtn = AddButton(tabKeybinds, "Aimbot Tuşu: [Q]", function() end)
local aimbotKeyLabel = aimbotKeyBtn:FindFirstChildOfClass("TextLabel")



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


aimbotKeyBtn.MouseButton1Click:Connect(function()
    if settingAimbotKey or settingMenuKey or settingESPKey then return end
    settingAimbotKey = true
    if aimbotKeyLabel then aimbotKeyLabel.Text = " Aimbot Tuşu: Tuşa bas..." end

    local conn
    conn = UIS.InputBegan:Connect(function(inp, gp)
        if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if gp then return end

        aimbotKey = inp.KeyCode
        local keyName = tostring(inp.KeyCode):gsub("Enum.KeyCode.", "")

        if aimbotKeyLabel then
            aimbotKeyLabel.Text = " Aimbot Tuşu: [" .. keyName .. "]"
        end
        if aimbotActiveKeyLabel then
            aimbotActiveKeyLabel.Text = "Aktif Tuş: " .. keyName
        end

        settingAimbotKey = false
        conn:Disconnect()
    end)
end)

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

-- Ayarlar (Yeni Tema Sistemi Buraya Eklendi)
AddLabel(tabSettings, "Strangers & Freaks")
AddButton(tabSettings, "ϟϟ Theme (Varsayılan)", function() applyTheme("ϟϟ Theme") end)
AddButton(tabSettings, "Kırmızı Theme", function() applyTheme("Kırmızı theme") end)
AddButton(tabSettings, "Beyaz Theme", function() applyTheme("Beyaz theme") end)
AddButton(tabSettings, "Yeşil Theme", function() applyTheme("Yeşil theme") end)

AddLabel(tabSettings, "Fobiler")
AddButton(tabSettings, "Cyberpunk", function() applyTheme("Cyberpunk") end)
AddButton(tabSettings, "Matrix ", function() applyTheme("Matrix") end)
AddButton(tabSettings, "Toprak", function() applyTheme("Minecraft") end)
AddButton(tabSettings, "Half-Life (Lambda)", function() applyTheme("Half-Life") end)
AddButton(tabSettings, "Aero Glass (Glassmorphism)", function() applyTheme("Aero Glass") end)

AddLabel(tabSettings, "Doğa")
AddButton(tabSettings, "Space Void (Deep Purple)", function() applyTheme("Space Void") end)
AddButton(tabSettings, "Sakura (Soft Pink)", function() applyTheme("Sakura") end)
AddButton(tabSettings, "Desert Gold", function() applyTheme("Desert Gold") end)
AddButton(tabSettings, "Ocean Deep (Turquoise)", function() applyTheme("Ocean Deep") end)
AddButton(tabSettings, "Toxic Waste (Acid Green)", function() applyTheme("Toxic Waste") end)

AddLabel(tabSettings, "StreSS")
AddButton(tabSettings, "Bloodlust (True Black & Red)", function() applyTheme("Bloodlust") end)
AddButton(tabSettings, "Midnight Gold (Premium Black)", function() applyTheme("Midnight Gold") end)
AddButton(tabSettings, "Plague (Dark Mud)", function() applyTheme("Plague") end)

AddLabel(tabSettings, "Retroslop")
AddButton(tabSettings, "Dracula", function() applyTheme("Dracula") end)
AddButton(tabSettings, "One Dark (Atom)", function() applyTheme("One Dark") end)
AddButton(tabSettings, "Synthwave (Outrun)", function() applyTheme("Synthwave") end)

AddLabel(tabSettings, "Menü Bilgileri")
AddLabel(tabSettings, "Seçtiğin Tuşlar:\nMenü Gizle/Aç: Keybind Sekmesine Bak\nESP Aktif Etme: Keybind Sekmesine Bak\nAimbot: Keybind Sekmesinden ayarlanır\nW/S: Duvara Tırman (Aktifken)\nGrapple 2: E (Çek) / Q (Sal)", true)

-- [[ ϟϟ YENİ SÜPER ÖZELLEŞTİRİLEBİLİR DİZAYN (CUSTOM DESIGNER) SEKMESİ ϟϟ ]] --
AddLabel(tabDesigner, "Kendi Temanı Yarat (Real-Time)")

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
AddSlider(tabDesigner, "Menü Genişliği (Width)", 400, 900, 600, function(val)
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

local slotsData = {}

local function saveSlotsToFile()
    if writefile then
        pcall(function()
            writefile("balik_waffen_slots.json", HttpService:JSONEncode(slotsData))
        end)
    end
end

local function loadSlotsFromFile()
    if isfile and isfile("balik_waffen_slots.json") then
        local ok, res = pcall(function()
            return HttpService:JSONDecode(readfile("balik_waffen_slots.json"))
        end)
        if ok and type(res) == "table" then
            return res
        end
    end
    return {}
end

slotsData = loadSlotsFromFile()

-- Dynamic Slot Çizici
local function rebuildSlotsUI()
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
local slotNameInput = AddTextBox(tabSlots, "Yeni Slot Adı Yaz...", function() end)

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
local coordLabel = AddLabel(tabUlasim, "X: 0  Y: 0  Z: 0")
RunService.Heartbeat:Connect(function()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root and coordLabel then
        local p = root.Position
        coordLabel.Text = string.format(" X: %.1f  Y: %.1f  Z: %.1f", p.X, p.Y, p.Z)
    end
end)

AddLabel(tabUlasim, "Koordinata Işınlan")
local coordInputFrame = Instance.new("Frame", tabUlasim)
coordInputFrame.Size = UDim2.new(1, -10, 0, 35)
coordInputFrame.BackgroundTransparency = 1
coordInputFrame.ZIndex = 5

local function CreateCoordBox(label, pos, parent)
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

local xBox = CreateCoordBox("X:", UDim2.new(0, 0, 0, 0), coordInputFrame)
local yBox = CreateCoordBox("Y:", UDim2.new(0.33, 0, 0, 0), coordInputFrame)
local zBox = CreateCoordBox("Z:", UDim2.new(0.66, 0, 0, 0), coordInputFrame)

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

local tpPlayerBox = AddTextBox(tabUlasim, "Oyuncu İsmi Yaz", function() end)
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

-- [[ WORKSPACE EXPLORER - LAZY / LOW DROP ]] 
AddLabel(tabUlasim, "Workspace Explorer")
local workspaceSelectedLabel = AddLabel(tabUlasim, "Seçili: Yok")
workspaceExplorerSearch = AddTextBox(tabUlasim, "Workspace içinde ara...", function() end)

local explorerScroll = Instance.new("ScrollingFrame", tabUlasim)
explorerScroll.Size = UDim2.new(1, -10, 0, 180)
explorerScroll.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
explorerScroll.BorderSizePixel = 0
explorerScroll.ScrollBarThickness = 5
explorerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
explorerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
explorerScroll.ZIndex = 5
registerObj(explorerScroll, "ButtonBG")
local explorerCorner = Instance.new("UICorner", explorerScroll)
explorerCorner.CornerRadius = UDim.new(0, 8)
explorerLayout = Instance.new("UIListLayout", explorerScroll)
explorerLayout.Padding = UDim.new(0, 2)

local explorerLoaded = false
local explorerExpanded = {}
local explorerPageByParent = {}
local EXPLORER_PAGE_SIZE = 50

local function clearExplorer()
    for _, child in ipairs(explorerScroll:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
end

local function unloadWorkspaceExplorer()
    explorerLoaded = false
    explorerExpanded = {}
    explorerPageByParent = {}
    clearExplorer()
    workspaceSelectedLabel.Text = "Seçili: Yok"
    selectedWorkspaceObject = nil
    pcall(function()
        if _G.BalikWaffenClearWorkspaceESP then _G.BalikWaffenClearWorkspaceESP() end
    end)
end

local function getExplorerMatch(instance, query)
    if query == "" then return true end
    local lowerQuery = string.lower(query)
    return string.find(string.lower(instance.Name), lowerQuery, 1, true) ~= nil
        or string.find(string.lower(instance.ClassName), lowerQuery, 1, true) ~= nil
end

local function collapseExplorerExcept(target)
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

local function buildExplorer()
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

AddButton(tabUlasim, "Workspace Yenile", buildExplorer)
AddButton(tabUlasim, "Explorer'ı Unload", unloadWorkspaceExplorer)

-- [[ EK: WORKSPACE ESP ARA + SEÇİLİ OBJE ESP ]] --
_G.BalikWaffenWorkspaceESPObjects = _G.BalikWaffenWorkspaceESPObjects or {}
_G.BalikWaffenWorkspaceNameESPHighlight = _G.BalikWaffenWorkspaceNameESPHighlight or nil

_G.BalikWaffenClearWorkspaceESP = function()
    if _G.BalikWaffenWorkspaceESPObjects then
        for _, highlight in pairs(_G.BalikWaffenWorkspaceESPObjects) do
            pcall(function()
                if highlight then highlight:Destroy() end
            end)
        end
    end
    _G.BalikWaffenWorkspaceESPObjects = {}

    if _G.BalikWaffenWorkspaceNameESPHighlight then
        pcall(function()
            _G.BalikWaffenWorkspaceNameESPHighlight:Destroy()
        end)
    end
    _G.BalikWaffenWorkspaceNameESPHighlight = nil
end

_G.BalikWaffenAddWorkspaceESP = function(target)
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
        table.insert(_G.BalikWaffenWorkspaceESPObjects, highlight)
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
                        _G.BalikWaffenAddWorkspaceESP(child)
                    elseif child:IsA("BasePart") then
                        _G.BalikWaffenAddWorkspaceESP(child)
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

_G.BalikWaffenNameSearchWorkspaceESP = function(text)
    _G.BalikWaffenClearWorkspaceESP()

    text = tostring(text or "")
    if text == "" then return end

    local target = workspace:FindFirstChild(text, true)
    if not target then return end

    if target:IsA("Folder") then
        _G.BalikWaffenAddWorkspaceESP(target)
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
        _G.BalikWaffenWorkspaceNameESPHighlight = highlight
    end
end

AddButton(tabUlasim, "ESP", function()
    if not selectedWorkspaceObject then return end
    pcall(function()
        _G.BalikWaffenClearWorkspaceESP()
        _G.BalikWaffenAddWorkspaceESP(selectedWorkspaceObject)
    end)
end)

AddButton(tabUlasim, "Workspace ESP Temizle", function()
    pcall(function()
        _G.BalikWaffenClearWorkspaceESP()
    end)
end)

workspaceExplorerSearch.FocusLost:Connect(function()
    if explorerLoaded then buildExplorer() end
end)

AddButton(tabUlasim, "Seçili Objeye Işınlan", function()
    teleportToInstance(selectedWorkspaceObject)
end)
AddButton(tabUlasim, "Seçili Objeyi Yanıma Getir", function()
    bringInstanceToPlayer(selectedWorkspaceObject)
end)

local saveLocationBox = AddTextBox(tabUlasim, "Konum adı yaz...", function() end)
AddButton(tabUlasim, "Konumu Kaydet", function()
    saveCurrentLocation(saveLocationBox.Text)
end)
AddButton(tabUlasim, "Kayıtlı Konuma Işınlan", function()
    teleportToSavedLocation(saveLocationBox.Text)
end)

AddLabel(tabUlasim, "Yakındaki Oyuncular")
local nearbyPlayerBox = AddTextBox(tabUlasim, "Oyuncu seç / adı yaz...", function() end)
local nearbyPlayers = {}
local function refreshNearbyPlayers()
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
local mouse = player:GetMouse()
UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and clickTPEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 and UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
        end
    end
end)

-- Reload kancası: Script dışarıdan _G.BalikWaffenReloadSource = scriptText atayabilir.
_G.BalikWaffenReload = function()
    if type(_G.BalikWaffenReloadSource) ~= "string" then
        pcall(function()
            game.StarterGui:SetCore("SendNotification", {Title="ANANISTAN Waffen", Text="Reload source bulunamadı", Duration=3})
        end)
        return
    end
    pcall(function()
        if _G.BalikWaffenBodycamStopPlayback then pcall(_G.BalikWaffenBodycamStopPlayback) end
        if _G.BalikWaffenBodycamState and _G.BalikWaffenBodycamState.recordingConn then
            pcall(function() _G.BalikWaffenBodycamState.recordingConn:Disconnect() end)
            _G.BalikWaffenBodycamState.recordingConn = nil
            _G.BalikWaffenBodycamState.recording = false
        end
        if _G.AnanistanWaffenCleanup then pcall(_G.AnanistanWaffenCleanup) end
        if screenGui then screenGui:Destroy() end
        if _G.AnanistanInsert then _G.AnanistanInsert:Disconnect(); _G.AnanistanInsert = nil end
        loadstring(_G.BalikWaffenReloadSource)()
    end)
end

]====]

-- [[ ANANISTAN WAFFEN 2.0 - FULLY CUSTOMIZABLE SÜRÜM ]] --

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer

-- [[ SINGLETON: AYNI SCRIPTİN ÖNCEKİ KOPYASINI KAPAT ]] --
if type(_G.AnanistanWaffenCleanup) == "function" then
    pcall(_G.AnanistanWaffenCleanup)
end

-- [[ SCOPING İÇİN GEREKLİ ÖN TANIMLAMALAR ]] --
bgImageLabel = nil
blurOverlay = nil

-- [[ ORİJİNAL TÜM FONKSİYONLAR ]] --

parachuteEnabled = false
parachuteConnection = nil
parachuteTrack = nil

local function runParachute(button)
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

local function runFullbright(button)
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

local function runGrapple()
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

local function isFriend(target)
    if friendCache[target.UserId] ~= nil then
        return friendCache[target.UserId]
    end
    local ok, result = pcall(function()
        return player:IsFriendsWith(target.UserId)
    end)
    friendCache[target.UserId] = ok and result or false
    return friendCache[target.UserId]
end

local function getESPColor(target)
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

local function clearESP()
    for _, obj in pairs(espObjects) do
        if obj.box then pcall(game.Destroy, obj.box) end
        if obj.billboard then pcall(game.Destroy, obj.billboard) end
        if obj.highlight then pcall(game.Destroy, obj.highlight) end
    end
    espObjects = {}
end

local function buildESP(target, useChams)
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

local function updateAllESP()
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

local function runFly()
    local UserInputService = game:GetService("UserInputService")
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
 
    if isMobile then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/396abc/Script/refs/heads/main/MobileFly.lua"))()
    else
        loadstring(game:HttpGet("https://pastebin.com/raw/ByKS7S6k"))()
    end
end

local function runInfiniteYield()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end

local function runBalikAI()
    pcall(function()
        loadstring(game:HttpGet("https://pastebin.com/raw/x6G1dmEZ"))()
    end)
end

local function runBalikPew()
    local ok, err = pcall(function()
        local source = game:HttpGet("https://pastebin.com/raw/fsZRgdrB")
        local fn = loadstring(source)
        if not fn then
            error("ANANISTAN Pew loadstring oluşturulamadı")
        end
        fn()
    end)
    if not ok then
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "ANANISTAN Pew",
                Text = "Yükleme başarısız: " .. tostring(err),
                Duration = 5
            })
        end)
    end
end

local function runSpiderWeb1()
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

local function runSpiderWeb2()
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

local function getCharacterHumanoid()
    local char = player.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getCharacterRoot()
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

local function setKosatkaHeight(value)
    kosatkaHeight = math.clamp(tonumber(value) or 0.5, 0, 8)
end

local function saveKosatkaCollision(char)
    kosatkaSavedCollision = {}
    if not char then return end
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("BasePart") then
            kosatkaSavedCollision[obj] = obj.CanCollide
            obj.CanCollide = false
        end
    end
end

local function forceKosatkaNoclip(char)
    if not char then return end
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CanCollide = false
            obj.CanTouch = false
            obj.CanQuery = true
        end
    end
end

local function restoreKosatkaCollision()
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

local function stopKosatka()
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

local function getKosatkaSurfaceY(root, char)
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

local function startKosatka()
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

local function toggleKosatka(state)
    if state then
        startKosatka()
    else
        stopKosatka()
    end
end

local function setWalkSpeed(value)
    movementWalkSpeed = value
    local hum = getCharacterHumanoid()
    if hum and not freezeCharacterEnabled then
        hum.WalkSpeed = value
    end
end

local function setJumpPower(value)
    movementJumpPower = value
    local hum = getCharacterHumanoid()
    if hum and not freezeCharacterEnabled then
        hum.UseJumpPower = true
        hum.JumpPower = value
    end
end

local function setGravity(value)
    movementGravity = value
    workspace.Gravity = value
end

local function toggleInfiniteJump(state)
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

local function toggleNoclip(state)
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

local function toggleFreezeCharacter(state)
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

local function resetCharacter()
    local hum = getCharacterHumanoid()
    if hum then
        hum.Health = 0
    else
        local char = player.Character
        if char then char:BreakJoints() end
    end
end

local function teleportToInstance(instance)
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

local function bringInstanceToPlayer(instance)
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

local function saveCurrentLocation(name)
    local root = getCharacterRoot()
    if not root or not name or name == "" then return false end
    savedLocations[name] = root.CFrame
    return true
end

local function teleportToSavedLocation(name)
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

local function startAntiVoid()
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

local function stopAntiVoid()
    if antiVoidConn then antiVoidConn:Disconnect(); antiVoidConn = nil end
end

local function toggleAntiAFK(state)
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

local function registerObj(obj, category)
    if registry[category] then
        table.insert(registry[category], obj)
    end
end

local function applyTheme(themeName)
    local cfg = themeData[themeName]
    if not cfg then return end
    currentTheme = themeName

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
            tween(btn, {BackgroundColor3 = cfg.ButtonBG, BackgroundTransparency = 0.2, TextColor3 = cfg.Text})
            tween(ind, {BackgroundColor3 = cfg.Accent})
        else -- Seçili olmayan sekme
            tween(btn, {BackgroundColor3 = cfg.UnselectedTabBtn, BackgroundTransparency = 0.6, TextColor3 = cfg.Text})
        end
    end
end

-- [[ YENİ UI - SMOOTH, COOL, KAPANMA SORUNU ÇÖZÜLDÜ, SİMGELER GÜNCELLENDİ ]] --

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ANANISTANWaffenUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling -- Katman uyumluluğu için Sibling yapıldı
screenGui.Parent = CoreGui

-- Bu kopya, bir sonraki ANANISTAN Waffen açılışında temizlenecek.
_G.AnanistanWaffenCleanup = function()
    pcall(function()
        if _G.BalikWaffenBodycamStopPlayback then _G.BalikWaffenBodycamStopPlayback() end
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
    _G.AnanistanWaffenCleanup = nil
end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 760, 0, 560)
mainFrame.Position = UDim2.new(0.5, -380, 0.5, -280)
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

local function updateBlur()
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
title.Text = "ϟϟ ANANISTAN WAFFEN ϟϟ"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 6
registerObj(title, "Text")

local function smoothTween(obj, props, duration)
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
            Title = "ANANISTAN Waffen",
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

-- Tab Navigasyon Alanı
local tabNav = Instance.new("Frame", mainFrame)
tabNav.Size = UDim2.new(1, -20, 0, 48)
tabNav.Position = UDim2.new(0, 10, 0, 55)
tabNav.BackgroundTransparency = 1
tabNav.BorderSizePixel = 0
tabNav.ZIndex = 5

local tabLayout = Instance.new("UIListLayout", tabNav)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 6)

local contentArea = Instance.new("Frame", mainFrame)
contentArea.Size = UDim2.new(1, -20, 1, -110)
contentArea.Position = UDim2.new(0, 10, 0, 100)
contentArea.BackgroundTransparency = 1
contentArea.ZIndex = 5

local tabs = {}

local function CreateTab(name)
    local tabBtn = Instance.new("TextButton", tabNav)
    tabBtn.Size = UDim2.new(1/12, -5, 1, 0) -- 12 Sekme İçin Tam Ölçeklendirme Yapıldı
    tabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    tabBtn.BackgroundTransparency = 0.6
    tabBtn.Text = name
    tabBtn.TextColor3 = Color3.fromRGB(160, 160, 190)
    tabBtn.Font = Enum.Font.GothamMedium
    tabBtn.TextSize = 11.5 -- Büyütülmüş panelde tab isimleri için
    tabBtn.BorderSizePixel = 0
    tabBtn.ZIndex = 6
    registerObj(tabBtn, "Text")
    
    local tabCorner = Instance.new("UICorner", tabBtn)
    tabCorner.CornerRadius = UDim.new(0, 10)

    local indicator = Instance.new("Frame", tabBtn)
    indicator.Size = UDim2.new(1, -10, 0, 3)
    indicator.Position = UDim2.new(0, 5, 1, -5)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
    indicator.BorderSizePixel = 0
    indicator.Visible = false
    indicator.ZIndex = 6
    registerObj(indicator, "Accent")
    
    local indCorner = Instance.new("UICorner", indicator)
    indCorner.CornerRadius = UDim.new(0, 2)

    local scroll = Instance.new("ScrollingFrame", contentArea)
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 5
    scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
    scroll.Visible = false
    scroll.ZIndex = 5
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

    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.Frame.Visible = false
            t.Indicator.Visible = false
        end
        scroll.Visible = true
        indicator.Visible = true
        applyTheme(currentTheme) -- Seçim tetiklendiğinde temayı o butona hemen uygula
    end)

    return scroll, tabData
end

local function AddButton(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    btn.Text = ""
    btn.ZIndex = 5
    registerObj(btn, "ButtonBG")
    
    local cornerBtn = Instance.new("UICorner", btn)
    cornerBtn.CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel", btn)
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 6
    registerObj(label, "Text")
    
    btn.MouseButton1Click:Connect(function() pcall(callback) end)
    return btn
end

local function AddToggle(parent, text, defaultState, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 38)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    frame.ZIndex = 5
    registerObj(frame, "ButtonBG")
    
    local cornerFrame = Instance.new("UICorner", frame)
    cornerFrame.CornerRadius = UDim.new(0, 8)
    
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

local function AddColorPicker(parent, text, defaultColor, callback)
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

local function AddTextBox(parent, placeholder, callback)
    local box = Instance.new("TextBox", parent)
    box.Size = UDim2.new(1, -10, 0, 35)
    box.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
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
    boxCorner.CornerRadius = UDim.new(0, 8)
    box.FocusLost:Connect(function() pcall(function() callback(box.Text) end) end)
    return box
end

local function AddSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    frame.ZIndex = 5
    registerObj(frame, "ButtonBG")
    
    local frameCorner = Instance.new("UICorner", frame)
    frameCorner.CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 6
    registerObj(label, "Text")

    local sliderBg = Instance.new("Frame", frame)
    sliderBg.Size = UDim2.new(1, -20, 0, 5)
    sliderBg.Position = UDim2.new(0, 10, 1, -14)
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    sliderBg.ZIndex = 5
    local sliderBgCorner = Instance.new("UICorner", sliderBg)
    sliderBgCorner.CornerRadius = UDim.new(0, 3)

    local sliderFill = Instance.new("Frame", sliderBg)
    sliderFill.Size = UDim2.new(math.clamp((default - min) / (max - min), 0, 1), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
    sliderFill.ZIndex = 6
    registerObj(sliderFill, "Accent")
    
    local sliderFillCorner = Instance.new("UICorner", sliderFill)
    sliderFillCorner.CornerRadius = UDim.new(0, 3)

    local sliderBtn = Instance.new("TextButton", sliderBg)
    sliderBtn.Size = UDim2.new(0, 14, 0, 14)
    sliderBtn.Position = UDim2.new(math.clamp((default - min) / (max - min), 0, 1), -7, 0.5, -7)
    sliderBtn.BackgroundColor3 = Color3.new(1,1,1)
    sliderBtn.Text = ""
    sliderBtn.ZIndex = 6
    local sliderBtnCorner = Instance.new("UICorner", sliderBtn)
    sliderBtnCorner.CornerRadius = UDim.new(0, 7)

    local function update(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        sliderBtn.Position = UDim2.new(pos, -7, 0.5, -7)
        local val = math.floor(min + (max - min) * pos)
        callback(val)
    end

    local dragging = false
    sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dragging = true 
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

    return function(val)
        local pos = math.clamp((val - min) / (max - min), 0, 1)
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        sliderBtn.Position = UDim2.new(pos, -7, 0.5, -7)
    end, frame
end

local function AddLabel(parent, text, tall)
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


-- [[ AIMBOT ]] --
local aimbotEnabled = false
local aimbotKey = Enum.KeyCode.Q
local aimbotTarget = nil
local aimbotHighlight = nil
local aimbotRenderConn = nil
local settingAimbotKey = false
local aimbotMaxFov = 100
local cameraAimbotEnabled = false

local function clearAimbotTarget()
    if aimbotHighlight then
        pcall(function() aimbotHighlight:Destroy() end)
        aimbotHighlight = nil
    end
    aimbotTarget = nil
end

local function getClosestPlayerToMouse()
    local camera = workspace.CurrentCamera
    if not camera then return nil end

    local mousePos = UIS:GetMouseLocation()
    local bestPlayer = nil
    local bestDistance = math.huge

    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= player and target.Character then
            local head = target.Character:FindFirstChild("Head")
            local hum = target.Character:FindFirstChildOfClass("Humanoid")

            if head and hum and hum.Health > 0 then
                local screenPos, visible = camera:WorldToViewportPoint(head.Position)
                if visible and screenPos.Z > 0 then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance <= aimbotMaxFov and distance < bestDistance then
                        bestDistance = distance
                        bestPlayer = target
                    end
                end
            end
        end
    end

    return bestPlayer
end

local function setAimbotTarget(target)
    if aimbotTarget == target and aimbotHighlight and aimbotHighlight.Parent then
        return
    end

    clearAimbotTarget()
    if not target or not target.Character then return end

    aimbotTarget = target

    local hl = Instance.new("Highlight")
    hl.Name = "ANANISTAN_AimbotTarget"
    hl.Adornee = target.Character
    hl.FillColor = Color3.fromRGB(255, 0, 0)
    hl.OutlineColor = Color3.fromRGB(255, 0, 0)
    hl.FillTransparency = 0.45
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = target.Character
    aimbotHighlight = hl
end

local function aimMouseAtHead(target)
    if not target or not target.Character then return end

    local head = target.Character:FindFirstChild("Head")
    if not head then return end

    local camera = workspace.CurrentCamera
    if not camera then return end

    local screenPos, visible = camera:WorldToViewportPoint(head.Position)
    if not visible or screenPos.Z <= 0 then return end

    local mousePos = UIS:GetMouseLocation()
    local delta = Vector2.new(screenPos.X, screenPos.Y) - mousePos

    -- Executor ortamlarında mousemoverel varsa gerçek mouse'u kafaya doğru taşır.
    if type(mousemoverel) == "function" then
        pcall(function()
            mousemoverel(delta.X, delta.Y)
        end)
    end
end

local function stopAimbot()
    aimbotEnabled = false
    if aimbotRenderConn then
        aimbotRenderConn:Disconnect()
        aimbotRenderConn = nil
    end
    clearAimbotTarget()
end

local function startAimbot()
    if aimbotRenderConn then
        aimbotRenderConn:Disconnect()
    end

    aimbotRenderConn = RunService.RenderStepped:Connect(function()
        if not aimbotEnabled then return end

        if not UIS:IsKeyDown(aimbotKey) then
            clearAimbotTarget()
            return
        end

        local target = aimbotTarget
        -- Sticky: keep current target until dead or key released
        if target then
            local hum = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 or not target.Character then
                clearAimbotTarget()
                target = nil
            end
        end

        if not target then
            target = getClosestPlayerToMouse()
        end

        if not target then
            clearAimbotTarget()
            return
        end

        setAimbotTarget(target)
        aimMouseAtHead(target)

        -- Camera Aimbot
        if cameraAimbotEnabled then
            local head = target.Character and target.Character:FindFirstChild("Head")
            local cam = workspace.CurrentCamera
            if head and cam then
                local camPos = cam.CFrame.Position
                cam.CFrame = CFrame.lookAt(camPos, head.Position)
            end
        end
    end)
end

local function toggleAimbot(state)
    aimbotEnabled = state
    if state then
        startAimbot()
    else
        stopAimbot()
    end
end

-- Keybind Değişkenleri
local menuToggleKey = Enum.KeyCode.Insert
local espToggleKey = Enum.KeyCode.T
local settingESPKey = false
local settingMenuKey = false


-- [[ SERVER / REJOIN / SERVER HOP / SERVER FINDER / USER SNIPE ]] --
local function notify(title, text)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = 4})
    end)
end

local function getRequestFunction()
    return (syn and syn.request) or request or http_request
end

local function requestJson(url)
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

local function rejoinServer()
    pcall(function()
        TeleportService:Teleport(game.PlaceId, player)
    end)
end

local function getPublicServers(placeId, cursor)
    local url = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", tostring(placeId))
    if cursor and cursor ~= "" then
        url = url .. "&cursor=" .. HttpService:UrlEncode(cursor)
    end
    return requestJson(url)
end

local function serverHop(targetMaxPlayers)
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
        notify("ANANISTAN Waffen", "Uygun server bulunamadı")
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

local function findServerByPlayerCount(count)
    count = tonumber(count)
    if not count then
        notify("ANANISTAN Waffen", "Geçerli oyuncu sayısı gir")
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

local function userSnipe(placeId, username)
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

local function getServerInfoText()
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
local tabSpider, tD5 = CreateTab("Grapple")
local tabVisuals, tD3 = CreateTab("Görseller")
local tabKeybinds, tD7 = CreateTab("Keybind")
local tabAimbot, tDAimbot = CreateTab("Aimbot")
local tabSettings, tD4 = CreateTab("Temalar")
local tabDesigner, tD8 = CreateTab("Dizayn")
local tabSlots, tD9 = CreateTab("Slotlar") -- YENİ SLOT TABI
_G.BalikTabPlayers, _G.BalikTabPlayersData = CreateTab("Oyuncular")
_G.BalikTabBodycams, _G.BalikTabBodycamsData = CreateTab("Bodycams")
_G.BalikTabPlayersData.Btn.TextSize = 8.5
_G.BalikTabBodycamsData.Btn.TextSize = 8.5


-- [[ ANANISTAN BODYCAM / OYUNCULAR SİSTEMİ ]] --
_G.BalikWaffenBodycamState = _G.BalikWaffenBodycamState or {
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

_G.BalikWaffenBodycamState.selectedUserId = _G.BalikWaffenBodycamState.selectedUserId or player.UserId

-- [[ ANANISTAN BODYCAM HUD / GERÇEK BODYCAM STİLİ ]]
_G.BalikWaffenBodycamCreateHUD = _G.BalikWaffenBodycamCreateHUD or function()
    local st = _G.BalikWaffenBodycamState
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

_G.BalikWaffenBodycamSetHUD = _G.BalikWaffenBodycamSetHUD or function(enabled, mode, elapsed)
    local hud = _G.BalikWaffenBodycamCreateHUD()
    local st = _G.BalikWaffenBodycamState
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

_G.BalikWaffenBodycamSetHUD(false)

-- [[ BODYCAM DOSYA KAYDI / KALICI DEPOLAMA ]]
_G.BalikWaffenBodycamFileName = _G.BalikWaffenBodycamFileName or "BalikWaffen_Bodycams.json"

_G.BalikWaffenBodycamSerializeCFrame = function(cf)
    local a,b,c,d,e,f,g,h,i,j,k,l = cf:GetComponents()
    return {a,b,c,d,e,f,g,h,i,j,k,l}
end

_G.BalikWaffenBodycamDeserializeCFrame = function(data)
    if type(data) ~= "table" or #data < 12 then return nil end
    local ok, cf = pcall(function()
        return CFrame.new(table.unpack(data, 1, 12))
    end)
    return ok and cf or nil
end

_G.BalikWaffenBodycamHasFileIO = function()
    return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
end

_G.BalikWaffenBodycamSaveToFile = function()
    local st = _G.BalikWaffenBodycamState
    if not _G.BalikWaffenBodycamHasFileIO() then
        st.fileStatus = "File API yok - sadece oturum belleği"
        return false
    end

    local payload = {version = 1, games = {}}
    local okDecode = pcall(function()
        if isfile(_G.BalikWaffenBodycamFileName) then
            local raw = readfile(_G.BalikWaffenBodycamFileName)
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
                local cfData = _G.BalikWaffenBodycamSerializeCFrame(frame.cf)
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

    local okWrite = pcall(function() writefile(_G.BalikWaffenBodycamFileName, encodedText) end)
    if okWrite then
        st.fileStatus = "Kayıtlar dosyaya kaydedildi"
        return true
    end
    st.fileStatus = "Dosyaya yazılamadı"
    return false
end

_G.BalikWaffenBodycamLoadFromFile = function()
    local st = _G.BalikWaffenBodycamState
    if not _G.BalikWaffenBodycamHasFileIO() then
        st.fileStatus = "File API yok - sadece oturum belleği"
        return false
    end
    if not isfile(_G.BalikWaffenBodycamFileName) then
        st.fileStatus = "Bodycam dosyası henüz yok"
        return false
    end

    local raw
    local okRead = pcall(function() raw = readfile(_G.BalikWaffenBodycamFileName) end)
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
                local cf = _G.BalikWaffenBodycamDeserializeCFrame(frame.cf)
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

_G.BalikWaffenBodycamStopPlayback = function()
    local st = _G.BalikWaffenBodycamState
    if st.playbackConn then
        pcall(function() st.playbackConn:Disconnect() end)
        st.playbackConn = nil
    end
    st.playback = false
    _G.BalikWaffenBodycamSetHUD(false)
    local cam = workspace.CurrentCamera
    if cam then
        pcall(function()
            cam.CameraType = Enum.CameraType.Custom
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then cam.CameraSubject = hum end
        end)
    end
end

pcall(function() _G.BalikWaffenBodycamLoadFromFile() end)

_G.BalikWaffenBodycamRefreshList = function()
    local st = _G.BalikWaffenBodycamState
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
            _G.BalikWaffenBodycamStopPlayback()
            local cam = workspace.CurrentCamera
            if not cam then return end
            st.playback = true
            _G.BalikWaffenBodycamSetHUD(true, "PLAYBACK", 0)
            local oldType = cam.CameraType
            local oldSubject = cam.CameraSubject
            local oldFov = cam.FieldOfView
            cam.CameraType = Enum.CameraType.Scriptable
            local started = os.clock()
            local frames = rec.frames
            st.playbackConn = RunService.RenderStepped:Connect(function()
                if not st.playback then return end
                local elapsed = os.clock() - started
                _G.BalikWaffenBodycamSetHUD(true, "PLAYBACK", elapsed)
                if elapsed >= (rec.duration or 0) then
                    st.playback = false
                    _G.BalikWaffenBodycamSetHUD(false)
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
            pcall(function() _G.BalikWaffenBodycamSaveToFile() end)
            _G.BalikWaffenBodycamRefreshList()
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

_G.BalikWaffenBodycamSelectUser = function(userId, displayName)
    local st = _G.BalikWaffenBodycamState
    st.selectedUserId = userId or player.UserId
    if st.selectedPlayerLabel then
        st.selectedPlayerLabel.Text = "Seçili Bodycam: " .. (displayName or player.DisplayName or player.Name)
    end
    _G.BalikWaffenBodycamRefreshList()
    if _G.BalikTabBodycamsData then
        for _, item in pairs(tabs) do
            item.Frame.Visible = false
            item.Indicator.Visible = false
        end
        _G.BalikTabBodycamsData.Frame.Visible = true
        _G.BalikTabBodycamsData.Indicator.Visible = true
        applyTheme(currentTheme)
    end
end

_G.BalikWaffenBodycamStart = function()
    local st = _G.BalikWaffenBodycamState
    if st.recording then return end
    _G.BalikWaffenBodycamStopPlayback()
    st.recording = true
    st.recordingFrames = {}
    st.recordingStarted = os.clock()
    _G.BalikWaffenBodycamSetHUD(true, "REC", 0)
    local userId = player.UserId
    st.statusLabel = st.statusLabel or nil
    if st.recordingConn then pcall(function() st.recordingConn:Disconnect() end) end
    local nextSample = 0
    st.recordingConn = RunService.RenderStepped:Connect(function()
        if not st.recording then return end
        local now = os.clock() - st.recordingStarted
        _G.BalikWaffenBodycamSetHUD(true, "REC", now)
        if now < nextSample then return end
        nextSample = now + (1/12)
        if now >= 3600 then
            _G.BalikWaffenBodycamStop()
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

_G.BalikWaffenBodycamStop = function()
    local st = _G.BalikWaffenBodycamState
    if not st.recording then return end
    st.recording = false
    _G.BalikWaffenBodycamSetHUD(false)
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
    pcall(function() _G.BalikWaffenBodycamSaveToFile() end)
    st.selectedUserId = player.UserId
    if st.selectedPlayerLabel then st.selectedPlayerLabel.Text = "Seçili Bodycam: " .. player.DisplayName end
    if st.statusLabel then st.statusLabel.Text = string.format("Kayıt kaydedildi  |  %d/25", #records) end
    _G.BalikWaffenBodycamRefreshList()
end

_G.BalikWaffenBodycamClearAll = function()
    local st = _G.BalikWaffenBodycamState
    st.recordings[player.UserId] = {}
    pcall(function() _G.BalikWaffenBodycamSaveToFile() end)
    st.selectedUserId = player.UserId
    if st.statusLabel then st.statusLabel.Text = "Tüm Bodycam kayıtları silindi" end
    _G.BalikWaffenBodycamRefreshList()
end

-- Oyuncular tabı
_G.BalikTabPlayersTitle = AddLabel(_G.BalikTabPlayers, "ANANISTAN Bodycam Oyuncuları")
_G.BalikTabPlayersHint = AddLabel(_G.BalikTabPlayers, "Sunucudaki oyuncuların profilini, Join ve Bodycams seçeneklerini görürsün", true)
_G.BalikBodycamPlayersScroll = Instance.new("ScrollingFrame", _G.BalikTabPlayers)
_G.BalikBodycamPlayersScroll.Size = UDim2.new(1, -10, 0, 330)
_G.BalikBodycamPlayersScroll.BackgroundTransparency = 1
_G.BalikBodycamPlayersScroll.ScrollBarThickness = 5
_G.BalikBodycamPlayersScroll.CanvasSize = UDim2.new(0,0,0,0)
_G.BalikBodycamPlayersScroll.Parent = _G.BalikTabPlayers
_G.BalikBodycamPlayersLayout = Instance.new("UIListLayout", _G.BalikBodycamPlayersScroll)
_G.BalikBodycamPlayersLayout.Padding = UDim.new(0, 6)
_G.BalikBodycamPlayersLayout.SortOrder = Enum.SortOrder.LayoutOrder
_G.BalikBodycamPlayersLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    _G.BalikBodycamPlayersScroll.CanvasSize = UDim2.new(0,0,0,_G.BalikBodycamPlayersLayout.AbsoluteContentSize.Y + 10)
end)

_G.BalikWaffenRefreshPlayersTab = function()
    local scroll = _G.BalikBodycamPlayersScroll
    if not scroll then return end
    for _, child in ipairs(scroll:GetChildren()) do
        if not child:IsA("UIListLayout") then child:Destroy() end
    end
    for _, target in ipairs(Players:GetPlayers()) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -8, 0, 66)
        row.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        row.BorderSizePixel = 0
        row.Parent = scroll
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

        local avatar = Instance.new("ImageLabel")
        avatar.Size = UDim2.new(0, 50, 0, 50)
        avatar.Position = UDim2.new(0, 8, 0.5, -25)
        avatar.BackgroundTransparency = 1
        avatar.Parent = row
        pcall(function()
            local image = Players:GetUserThumbnailAsync(target.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            avatar.Image = image
        end)

        local name = Instance.new("TextLabel")
        name.Size = UDim2.new(1, -205, 1, 0)
        name.Position = UDim2.new(0, 68, 0, 0)
        name.BackgroundTransparency = 1
        name.Text = target.DisplayName .. "\n@" .. target.Name
        name.TextColor3 = Color3.fromRGB(220,220,240)
        name.Font = Enum.Font.GothamMedium
        name.TextSize = 12
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.TextYAlignment = Enum.TextYAlignment.Center
        name.Parent = row

        local join = Instance.new("TextButton")
        join.Size = UDim2.new(0, 58, 0, 30)
        join.Position = UDim2.new(1, -125, 0.5, -15)
        join.BackgroundColor3 = Color3.fromRGB(50, 110, 65)
        join.Text = "Join"
        join.TextColor3 = Color3.fromRGB(255,255,255)
        join.Font = Enum.Font.GothamBold
        join.TextSize = 11
        join.Parent = row
        Instance.new("UICorner", join).CornerRadius = UDim.new(0, 6)
        join.MouseButton1Click:Connect(function()
            if target == player then
                notify("ANANISTAN Bodycam", "Zaten bu sunucudasın")
                return
            end
            if target.Parent then
                pcall(function() userSnipe(game.PlaceId, target.Name) end)
            end
        end)

        local bodyBtn = Instance.new("TextButton")
        bodyBtn.Size = UDim2.new(0, 58, 0, 30)
        bodyBtn.Position = UDim2.new(1, -62, 0.5, -15)
        bodyBtn.BackgroundColor3 = Color3.fromRGB(65, 75, 110)
        bodyBtn.Text = "Bodycams"
        bodyBtn.TextColor3 = Color3.fromRGB(255,255,255)
        bodyBtn.Font = Enum.Font.GothamBold
        bodyBtn.TextSize = 9
        bodyBtn.Parent = row
        Instance.new("UICorner", bodyBtn).CornerRadius = UDim.new(0, 6)
        bodyBtn.MouseButton1Click:Connect(function()
            _G.BalikWaffenBodycamSelectUser(target.UserId, target.DisplayName)
        end)
    end
end

_G.BalikTabPlayersRefresh = AddButton(_G.BalikTabPlayers, "Oyuncu Listesini Yenile", _G.BalikWaffenRefreshPlayersTab)

Players.PlayerAdded:Connect(function()
    task.defer(_G.BalikWaffenRefreshPlayersTab)
end)
Players.PlayerRemoving:Connect(function()
    task.defer(_G.BalikWaffenRefreshPlayersTab)
end)

-- Bodycams tabı
_G.BalikTabBodycamsTitle = AddLabel(_G.BalikTabBodycams, "ANANISTAN Bodycam")
_G.BalikWaffenBodycamState.selectedPlayerLabel = AddLabel(_G.BalikTabBodycams, "Seçili Bodycam: " .. player.DisplayName)
_G.BalikWaffenBodycamState.statusLabel = AddLabel(_G.BalikTabBodycams, "Hazır | Maksimum 25 kayıt | " .. tostring(_G.BalikWaffenBodycamState.fileStatus or "Dosya belleği hazır"))
AddButton(_G.BalikTabBodycams, "● Kayda Başla", function()
    _G.BalikWaffenBodycamStart()
end)
AddButton(_G.BalikTabBodycams, "■ Kaydı Durdur & Kaydet", function()
    _G.BalikWaffenBodycamStop()
end)
AddButton(_G.BalikTabBodycams, "Tüm Kayıtları Sil", function()
    _G.BalikWaffenBodycamClearAll()
end)
AddButton(_G.BalikTabBodycams, "Kayıtları Dosyaya Kaydet", function()
    local ok = _G.BalikWaffenBodycamSaveToFile()
    if _G.BalikWaffenBodycamState.statusLabel then
        _G.BalikWaffenBodycamState.statusLabel.Text = ok and "Bodycam kayıtları dosyaya kaydedildi" or ("Kaydetme başarısız: " .. tostring(_G.BalikWaffenBodycamState.fileStatus or "bilinmeyen hata"))
    end
end)
AddButton(_G.BalikTabBodycams, "Dosyadan Kayıtları Yenile", function()
    local ok = _G.BalikWaffenBodycamLoadFromFile()
    if _G.BalikWaffenBodycamState.statusLabel then
        _G.BalikWaffenBodycamState.statusLabel.Text = ok and "Bodycam kayıtları dosyadan yüklendi" or ("Yükleme başarısız: " .. tostring(_G.BalikWaffenBodycamState.fileStatus or "dosya yok"))
    end
    _G.BalikWaffenBodycamRefreshList()
end)
_G.BalikTabBodycamsHint = AddLabel(_G.BalikTabBodycams, "Kayıtlar ilk şahıs olarak oynatılır. Üçüncü şahısta kayıt başlatsan bile playback kafanın konumundan ve kaydedilmiş bakış yönünden gider.", true)

_G.BalikWaffenBodycamListScroll = Instance.new("ScrollingFrame", _G.BalikTabBodycams)
_G.BalikWaffenBodycamListScroll.Size = UDim2.new(1, -10, 0, 250)
_G.BalikWaffenBodycamListScroll.BackgroundTransparency = 1
_G.BalikWaffenBodycamListScroll.ScrollBarThickness = 5
_G.BalikWaffenBodycamListScroll.CanvasSize = UDim2.new(0,0,0,0)
_G.BalikWaffenBodycamListScroll.Parent = _G.BalikTabBodycams
_G.BalikWaffenBodycamState.bodycamListFrame = _G.BalikWaffenBodycamListScroll
_G.BalikWaffenBodycamListLayout = Instance.new("UIListLayout", _G.BalikWaffenBodycamListScroll)
_G.BalikWaffenBodycamListLayout.Padding = UDim.new(0, 6)
_G.BalikWaffenBodycamListLayout.SortOrder = Enum.SortOrder.LayoutOrder
_G.BalikWaffenBodycamListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    _G.BalikWaffenBodycamListScroll.CanvasSize = UDim2.new(0,0,0,_G.BalikWaffenBodycamListLayout.AbsoluteContentSize.Y + 10)
end)
_G.BalikWaffenBodycamRefreshList()
_G.BalikWaffenRefreshPlayersTab()

-- Ana Sayfa
AddLabel(tabMain, "YAPIMCILAR")

local function AddCreatorCard(parent, username)
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
    nameLabel.Text = username
    nameLabel.TextColor3 = Color3.fromRGB(220, 220, 240)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 6
    registerObj(nameLabel, "Text")

    task.spawn(function()
        local ok, userId = pcall(function()
            return Players:GetUserIdFromNameAsync(username)
        end)
        if ok and userId then
            avatar.Image = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", userId)
            card.MouseButton1Click:Connect(function()
                local profile = "https://www.roblox.com/users/" .. tostring(userId) .. "/profile"
                local copied = false
                pcall(function()
                    if setclipboard then setclipboard(profile); copied = true end
                end)
                pcall(function()
                    if toclipboard and not copied then toclipboard(profile); copied = true end
                end)
                notify(username, copied and "Profil bağlantısı panoya kopyalandı" or profile)
            end)
        end
    end)
    return card
end

AddCreatorCard(tabMain, "35YARGIC")
AddCreatorCard(tabMain, "Ananistan_Doom")
AddLabel(tabMain, "BU SCRIPT ARTHURMORGAN4000 VE DUTCHVANDER4000 TARAFINDAN YAPILMIŞTIR ÇALANI SİKERİZ", true)
AddLabel(tabMain, "Menü Araçları")
AddButton(tabMain, "ANANISTAN AI", runBalikAI)
AddButton(tabMain, "ANANISTAN Pew", runBalikPew)
AddButton(tabMain, "Infinite Yield", runInfiniteYield)
AddButton(tabMain, "Aimbot", function() pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/WhJDjCag"))() end) end)
AddButton(tabMain, "Remote Spy", function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/InfernusScripts/Ketamine/refs/heads/main/Ketamine.lua"))() end) end)
AddButton(tabMain, "Server Hop", function() serverHop(nil) end)
AddButton(tabMain, "PlaceId Kopyala", function()
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
    notify("ANANISTAN Waffen", copied and "PlaceId kopyalandı: " .. placeIdText or "Clipboard desteklenmiyor: " .. placeIdText)
end)

AddLabel(tabMain, "Server Bulucu")
local serverPlayerCountBox = AddTextBox(tabMain, "Hedef oyuncu sayısı...", function() end)
AddButton(tabMain, "Oyuncu Sayısına Göre Server Bul", function()
    findServerByPlayerCount(serverPlayerCountBox.Text)
end)

AddLabel(tabMain, "Kullanıcı Snipeleme")
local snipePlaceIdBox = AddTextBox(tabMain, "Oyun / PlaceId...", function() end)
snipePlaceIdBox.Text = tostring(game.PlaceId)
local snipeUsernameBox = AddTextBox(tabMain, "Kullanıcı adı...", function() end)
AddButton(tabMain, "Kullanıcıya Joinlen", function()
    userSnipe(snipePlaceIdBox.Text, snipeUsernameBox.Text)
end)

AddLabel(tabMain, "Server Bilgileri")
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
    if _G.AnanistanWaffenCleanup then _G.AnanistanWaffenCleanup = nil end
end)

-- Oyuncu
AddLabel(tabPlayer, "Karakter Modları")
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
AddToggle(tabPlayer, "Parachute", parachuteEnabled, function(state)
    local fakeBtn = {Text = ""}
    parachuteEnabled = not state
    runParachute(fakeBtn) 
end)
AddButton(tabPlayer, "Görünmezlik", function()
    loadstring(game:HttpGet('https://pastebin.com/raw/3Rnd9rHf'))()
end)
AddButton(tabPlayer, "Yaw Fly", runFly)
AddButton(tabPlayer, "ANANISTAN Antigravity", function()
    pcall(function()
        loadstring(game:HttpGet("https://pastebin.com/raw/TPQRxApG"))()
    end)
end)
AddLabel(tabPlayer, "Hareket Ayarları")
AddSlider(tabPlayer, "WalkSpeed", 0, 200, movementWalkSpeed, function(val)
    setWalkSpeed(val)
end)
AddSlider(tabPlayer, "JumpPower", 0, 300, movementJumpPower, function(val)
    setJumpPower(val)
end)
AddSlider(tabPlayer, "Gravity", 0, 500, movementGravity, function(val)
    setGravity(val)
end)
AddButton(tabPlayer, "Hareket Ayarlarını Normale Çevir", function()
    if kosatkaEnabled then stopKosatka() end
    movementWalkSpeed = 16
    movementJumpPower = 50
    movementGravity = 196.2
    workspace.Gravity = 196.2

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
AddLabel(tabAimbot, "AIMBOT / SILENT AIM / TRIGGERBOT")
AddLabel(tabAimbot, "Aimbot, Silent Aim hedefleme ve Triggerbot ayarları tek sekmede.", true)

AddToggle(tabAimbot, "Aimbot", aimbotEnabled, function(state)
    toggleAimbot(state)
end)
AddToggle(tabAimbot, "Camera Aimbot", cameraAimbotEnabled, function(state)
    cameraAimbotEnabled = state
end)
AddToggle(tabAimbot, "Silent Aim Targeting", silentAimEnabled, function(state)
    toggleSilentAim(state)
end)
AddToggle(tabAimbot, "Triggerbot", triggerbotEnabled, function(state)
    triggerbotEnabled = state
end)

AddLabel(tabAimbot, "Target Filters")
AddToggle(tabAimbot, "Team Check", aimbotTeamCheck, function(state) aimbotTeamCheck = state end)
AddToggle(tabAimbot, "Friend Check", aimbotFriendCheck, function(state) aimbotFriendCheck = state end)
AddToggle(tabAimbot, "Wall Check", aimbotWallCheck, function(state) aimbotWallCheck = state end)
AddToggle(tabAimbot, "Alive Check", aimbotAliveCheck, function(state) aimbotAliveCheck = state end)
AddToggle(tabAimbot, "Sticky Aim", aimbotStickyAim, function(state) aimbotStickyAim = state end)
AddToggle(tabAimbot, "Auto Switch", aimbotAutoSwitch, function(state) aimbotAutoSwitch = state end)

AddLabel(tabAimbot, "Visual / FOV")
AddToggle(tabAimbot, "FOV Circle", aimbotShowFov, function(state) aimbotShowFov = state end)
AddLabel(tabAimbot, "Aimbot FOV: 100 | Silent FOV: 100 | Trigger FOV: 8")
AddLabel(tabAimbot, "Target: Head | Prediction: 0 | Smoothness: 0.18")

AddButton(tabAimbot, "Aimbot Tuşunu Değiştir", function()
    if aimbotKeyBtn then
        aimbotKeyBtn:Activate()
    end
end)
local aimbotActiveKeyLabel = AddLabel(tabAimbot, "Aktif Tuş: Q")

AddLabel(tabAimbot, "Durum")
AddLabel(tabAimbot, "Aimbot: mouse hedefleme | Silent Aim: ortak hedef seçimi | Triggerbot: otomatik tıklama", true)

-- Grapple
AddLabel(tabSpider, "Grapple Hook")
AddButton(tabSpider, "Grapple 1 (Çekme)", runSpiderWeb1)
AddButton(tabSpider, "Grapple 2 (Tutunma)", runSpiderWeb2)
AddButton(tabMain, "Script Reload", function()
    pcall(function()
        if _G.BalikWaffenReload then
            _G.BalikWaffenReload()
        else
            notify("ANANISTAN Waffen", "Reload sistemi hazır değil")
        end
    end)
end)

-- Görseller
AddLabel(tabVisuals, "ESP")
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
_G.BalikWaffenWorkspaceNameESPBoxVisuals = AddTextBox(tabVisuals, "Workspace obje adı gir...", function(text)
    pcall(function()
        _G.BalikWaffenNameSearchWorkspaceESP(text)
    end)
end)
AddButton(tabVisuals, "İsim ESP Temizle", function()
    pcall(function()
        _G.BalikWaffenClearWorkspaceESP()
    end)
    if _G.BalikWaffenWorkspaceNameESPBoxVisuals then
        _G.BalikWaffenWorkspaceNameESPBoxVisuals.Text = ""
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

-- Keybind Tabı
AddLabel(tabKeybinds, "Kısayol Tuş Atamaları")

local espKeyBtn = AddButton(tabKeybinds, "ESP Aç/Kapat: [T]", function() end)
local espKeyLabel = espKeyBtn:FindFirstChildOfClass("TextLabel")

local menuKeyBtn = AddButton(tabKeybinds, "Menü Aç/Kapat: [Insert]", function() end)
local menuKeyLabel = menuKeyBtn:FindFirstChildOfClass("TextLabel")

local aimbotKeyBtn = AddButton(tabKeybinds, "Aimbot Tuşu: [Q]", function() end)
local aimbotKeyLabel = aimbotKeyBtn:FindFirstChildOfClass("TextLabel")



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


aimbotKeyBtn.MouseButton1Click:Connect(function()
    if settingAimbotKey or settingMenuKey or settingESPKey then return end
    settingAimbotKey = true
    if aimbotKeyLabel then aimbotKeyLabel.Text = " Aimbot Tuşu: Tuşa bas..." end

    local conn
    conn = UIS.InputBegan:Connect(function(inp, gp)
        if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if gp then return end

        aimbotKey = inp.KeyCode
        local keyName = tostring(inp.KeyCode):gsub("Enum.KeyCode.", "")

        if aimbotKeyLabel then
            aimbotKeyLabel.Text = " Aimbot Tuşu: [" .. keyName .. "]"
        end
        if aimbotActiveKeyLabel then
            aimbotActiveKeyLabel.Text = "Aktif Tuş: " .. keyName
        end

        settingAimbotKey = false
        conn:Disconnect()
    end)
end)

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

-- Ayarlar (Yeni Tema Sistemi Buraya Eklendi)
AddLabel(tabSettings, "Strangers & Freaks")
AddButton(tabSettings, "ϟϟ Theme (Varsayılan)", function() applyTheme("ϟϟ Theme") end)
AddButton(tabSettings, "Kırmızı Theme", function() applyTheme("Kırmızı theme") end)
AddButton(tabSettings, "Beyaz Theme", function() applyTheme("Beyaz theme") end)
AddButton(tabSettings, "Yeşil Theme", function() applyTheme("Yeşil theme") end)

AddLabel(tabSettings, "Fobiler")
AddButton(tabSettings, "Cyberpunk", function() applyTheme("Cyberpunk") end)
AddButton(tabSettings, "Matrix ", function() applyTheme("Matrix") end)
AddButton(tabSettings, "Toprak", function() applyTheme("Minecraft") end)
AddButton(tabSettings, "Half-Life (Lambda)", function() applyTheme("Half-Life") end)
AddButton(tabSettings, "Aero Glass (Glassmorphism)", function() applyTheme("Aero Glass") end)

AddLabel(tabSettings, "Doğa")
AddButton(tabSettings, "Space Void (Deep Purple)", function() applyTheme("Space Void") end)
AddButton(tabSettings, "Sakura (Soft Pink)", function() applyTheme("Sakura") end)
AddButton(tabSettings, "Desert Gold", function() applyTheme("Desert Gold") end)
AddButton(tabSettings, "Ocean Deep (Turquoise)", function() applyTheme("Ocean Deep") end)
AddButton(tabSettings, "Toxic Waste (Acid Green)", function() applyTheme("Toxic Waste") end)

AddLabel(tabSettings, "StreSS")
AddButton(tabSettings, "Bloodlust (True Black & Red)", function() applyTheme("Bloodlust") end)
AddButton(tabSettings, "Midnight Gold (Premium Black)", function() applyTheme("Midnight Gold") end)
AddButton(tabSettings, "Plague (Dark Mud)", function() applyTheme("Plague") end)

AddLabel(tabSettings, "Retroslop")
AddButton(tabSettings, "Dracula", function() applyTheme("Dracula") end)
AddButton(tabSettings, "One Dark (Atom)", function() applyTheme("One Dark") end)
AddButton(tabSettings, "Synthwave (Outrun)", function() applyTheme("Synthwave") end)

AddLabel(tabSettings, "Menü Bilgileri")
AddLabel(tabSettings, "Seçtiğin Tuşlar:\nMenü Gizle/Aç: Keybind Sekmesine Bak\nESP Aktif Etme: Keybind Sekmesine Bak\nAimbot: Keybind Sekmesinden ayarlanır\nW/S: Duvara Tırman (Aktifken)\nGrapple 2: E (Çek) / Q (Sal)", true)

-- [[ ϟϟ YENİ SÜPER ÖZELLEŞTİRİLEBİLİR DİZAYN (CUSTOM DESIGNER) SEKMESİ ϟϟ ]] --
AddLabel(tabDesigner, "Kendi Temanı Yarat (Real-Time)")

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
AddSlider(tabDesigner, "Menü Genişliği (Width)", 400, 900, 600, function(val)
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

local slotsData = {}

local function saveSlotsToFile()
    if writefile then
        pcall(function()
            writefile("balik_waffen_slots.json", HttpService:JSONEncode(slotsData))
        end)
    end
end

local function loadSlotsFromFile()
    if isfile and isfile("balik_waffen_slots.json") then
        local ok, res = pcall(function()
            return HttpService:JSONDecode(readfile("balik_waffen_slots.json"))
        end)
        if ok and type(res) == "table" then
            return res
        end
    end
    return {}
end

slotsData = loadSlotsFromFile()

-- Dynamic Slot Çizici
local function rebuildSlotsUI()
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
local slotNameInput = AddTextBox(tabSlots, "Yeni Slot Adı Yaz...", function() end)

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
local coordLabel = AddLabel(tabUlasim, "X: 0  Y: 0  Z: 0")
RunService.Heartbeat:Connect(function()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root and coordLabel then
        local p = root.Position
        coordLabel.Text = string.format(" X: %.1f  Y: %.1f  Z: %.1f", p.X, p.Y, p.Z)
    end
end)

AddLabel(tabUlasim, "Koordinata Işınlan")
local coordInputFrame = Instance.new("Frame", tabUlasim)
coordInputFrame.Size = UDim2.new(1, -10, 0, 35)
coordInputFrame.BackgroundTransparency = 1
coordInputFrame.ZIndex = 5

local function CreateCoordBox(label, pos, parent)
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

local xBox = CreateCoordBox("X:", UDim2.new(0, 0, 0, 0), coordInputFrame)
local yBox = CreateCoordBox("Y:", UDim2.new(0.33, 0, 0, 0), coordInputFrame)
local zBox = CreateCoordBox("Z:", UDim2.new(0.66, 0, 0, 0), coordInputFrame)

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

local tpPlayerBox = AddTextBox(tabUlasim, "Oyuncu İsmi Yaz", function() end)
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

-- [[ WORKSPACE EXPLORER - LAZY / LOW DROP ]] 
AddLabel(tabUlasim, "Workspace Explorer")
local workspaceSelectedLabel = AddLabel(tabUlasim, "Seçili: Yok")
workspaceExplorerSearch = AddTextBox(tabUlasim, "Workspace içinde ara...", function() end)

local explorerScroll = Instance.new("ScrollingFrame", tabUlasim)
explorerScroll.Size = UDim2.new(1, -10, 0, 180)
explorerScroll.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
explorerScroll.BorderSizePixel = 0
explorerScroll.ScrollBarThickness = 5
explorerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
explorerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
explorerScroll.ZIndex = 5
registerObj(explorerScroll, "ButtonBG")
local explorerCorner = Instance.new("UICorner", explorerScroll)
explorerCorner.CornerRadius = UDim.new(0, 8)
explorerLayout = Instance.new("UIListLayout", explorerScroll)
explorerLayout.Padding = UDim.new(0, 2)

local explorerLoaded = false
local explorerExpanded = {}
local explorerPageByParent = {}
local EXPLORER_PAGE_SIZE = 50

local function clearExplorer()
    for _, child in ipairs(explorerScroll:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
end

local function unloadWorkspaceExplorer()
    explorerLoaded = false
    explorerExpanded = {}
    explorerPageByParent = {}
    clearExplorer()
    workspaceSelectedLabel.Text = "Seçili: Yok"
    selectedWorkspaceObject = nil
    pcall(function()
        if _G.BalikWaffenClearWorkspaceESP then _G.BalikWaffenClearWorkspaceESP() end
    end)
end

local function getExplorerMatch(instance, query)
    if query == "" then return true end
    local lowerQuery = string.lower(query)
    return string.find(string.lower(instance.Name), lowerQuery, 1, true) ~= nil
        or string.find(string.lower(instance.ClassName), lowerQuery, 1, true) ~= nil
end

local function collapseExplorerExcept(target)
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

local function buildExplorer()
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

AddButton(tabUlasim, "Workspace Yenile", buildExplorer)
AddButton(tabUlasim, "Explorer'ı Unload", unloadWorkspaceExplorer)

-- [[ EK: WORKSPACE ESP ARA + SEÇİLİ OBJE ESP ]] --
_G.BalikWaffenWorkspaceESPObjects = _G.BalikWaffenWorkspaceESPObjects or {}
_G.BalikWaffenWorkspaceNameESPHighlight = _G.BalikWaffenWorkspaceNameESPHighlight or nil

_G.BalikWaffenClearWorkspaceESP = function()
    if _G.BalikWaffenWorkspaceESPObjects then
        for _, highlight in pairs(_G.BalikWaffenWorkspaceESPObjects) do
            pcall(function()
                if highlight then highlight:Destroy() end
            end)
        end
    end
    _G.BalikWaffenWorkspaceESPObjects = {}

    if _G.BalikWaffenWorkspaceNameESPHighlight then
        pcall(function()
            _G.BalikWaffenWorkspaceNameESPHighlight:Destroy()
        end)
    end
    _G.BalikWaffenWorkspaceNameESPHighlight = nil
end

_G.BalikWaffenAddWorkspaceESP = function(target)
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
        table.insert(_G.BalikWaffenWorkspaceESPObjects, highlight)
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
                        _G.BalikWaffenAddWorkspaceESP(child)
                    elseif child:IsA("BasePart") then
                        _G.BalikWaffenAddWorkspaceESP(child)
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

_G.BalikWaffenNameSearchWorkspaceESP = function(text)
    _G.BalikWaffenClearWorkspaceESP()

    text = tostring(text or "")
    if text == "" then return end

    local target = workspace:FindFirstChild(text, true)
    if not target then return end

    if target:IsA("Folder") then
        _G.BalikWaffenAddWorkspaceESP(target)
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
        _G.BalikWaffenWorkspaceNameESPHighlight = highlight
    end
end

AddButton(tabUlasim, "ESP", function()
    if not selectedWorkspaceObject then return end
    pcall(function()
        _G.BalikWaffenClearWorkspaceESP()
        _G.BalikWaffenAddWorkspaceESP(selectedWorkspaceObject)
    end)
end)

AddButton(tabUlasim, "Workspace ESP Temizle", function()
    pcall(function()
        _G.BalikWaffenClearWorkspaceESP()
    end)
end)

workspaceExplorerSearch.FocusLost:Connect(function()
    if explorerLoaded then buildExplorer() end
end)

AddButton(tabUlasim, "Seçili Objeye Işınlan", function()
    teleportToInstance(selectedWorkspaceObject)
end)
AddButton(tabUlasim, "Seçili Objeyi Yanıma Getir", function()
    bringInstanceToPlayer(selectedWorkspaceObject)
end)

local saveLocationBox = AddTextBox(tabUlasim, "Konum adı yaz...", function() end)
AddButton(tabUlasim, "Konumu Kaydet", function()
    saveCurrentLocation(saveLocationBox.Text)
end)
AddButton(tabUlasim, "Kayıtlı Konuma Işınlan", function()
    teleportToSavedLocation(saveLocationBox.Text)
end)

AddLabel(tabUlasim, "Yakındaki Oyuncular")
local nearbyPlayerBox = AddTextBox(tabUlasim, "Oyuncu seç / adı yaz...", function() end)
local nearbyPlayers = {}
local function refreshNearbyPlayers()
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
local mouse = player:GetMouse()
UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and clickTPEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 and UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
        end
    end
end)

-- Reload kancası: Script dışarıdan _G.BalikWaffenReloadSource = scriptText atayabilir.
_G.BalikWaffenReload = function()
    if type(_G.BalikWaffenReloadSource) ~= "string" then
        pcall(function()
            game.StarterGui:SetCore("SendNotification", {Title="ANANISTAN Waffen", Text="Reload source bulunamadı", Duration=3})
        end)
        return
    end
    pcall(function()
        if _G.BalikWaffenBodycamStopPlayback then pcall(_G.BalikWaffenBodycamStopPlayback) end
        if _G.BalikWaffenBodycamState and _G.BalikWaffenBodycamState.recordingConn then
            pcall(function() _G.BalikWaffenBodycamState.recordingConn:Disconnect() end)
            _G.BalikWaffenBodycamState.recordingConn = nil
            _G.BalikWaffenBodycamState.recording = false
        end
        if _G.AnanistanWaffenCleanup then pcall(_G.AnanistanWaffenCleanup) end
        if screenGui then screenGui:Destroy() end
        if _G.AnanistanInsert then _G.AnanistanInsert:Disconnect(); _G.AnanistanInsert = nil end
        loadstring(_G.BalikWaffenReloadSource)()
    end)
end

