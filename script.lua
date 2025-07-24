-- Remove old UI if it exists
if game.CoreGui:FindFirstChild("NameGenUI") then
    game.CoreGui.NameGenUI:Destroy()
end

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

-- === UI Setup ===
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "NameGenUI"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 320, 0, 270)
Frame.Position = UDim2.new(0.5, -160, 0.5, -135)
Frame.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
Frame.Active = true
Frame.Draggable = true

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "Clean Username Generator"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.BackgroundTransparency = 1

local NameLabel = Instance.new("TextLabel", Frame)
NameLabel.Size = UDim2.new(1, -20, 0, 40)
NameLabel.Position = UDim2.new(0, 10, 0, 60)
NameLabel.Text = "Generated Name"
NameLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
NameLabel.TextSize = 18
NameLabel.Font = Enum.Font.Gotham
NameLabel.BackgroundColor3 = Color3.fromRGB(40, 30, 55)
NameLabel.TextWrapped = true

local NameCorner = Instance.new("UICorner", NameLabel)
NameCorner.CornerRadius = UDim.new(0, 8)

-- Buttons
local GenerateBtn = Instance.new("TextButton", Frame)
GenerateBtn.Size = UDim2.new(0, 120, 0, 40)
GenerateBtn.Position = UDim2.new(0, 20, 0, 200)
GenerateBtn.Text = "Generate"
GenerateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GenerateBtn.Font = Enum.Font.Gotham
GenerateBtn.TextSize = 18
GenerateBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 80)

local GenerateCorner = Instance.new("UICorner", GenerateBtn)
GenerateCorner.CornerRadius = UDim.new(0, 8)

local CopyBtn = Instance.new("TextButton", Frame)
CopyBtn.Size = UDim2.new(0, 120, 0, 40)
CopyBtn.Position = UDim2.new(0, 180, 0, 200)
CopyBtn.Text = "Copy"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.Font = Enum.Font.Gotham
CopyBtn.TextSize = 18
CopyBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 80)

local CopyCorner = Instance.new("UICorner", CopyBtn)
CopyCorner.CornerRadius = UDim.new(0, 8)

-- Length Buttons
local lengths = {5, 6, 7, 8}
local currentLength = 6

for i, len in ipairs(lengths) do
    local lenBtn = Instance.new("TextButton", Frame)
    lenBtn.Size = UDim2.new(0, 60, 0, 30)
    lenBtn.Position = UDim2.new(0, 20 + ((i - 1) * 70), 0, 120)
    lenBtn.Text = tostring(len).." letters"
    lenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    lenBtn.Font = Enum.Font.Gotham
    lenBtn.TextSize = 14
    lenBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 65)

    local btnCorner = Instance.new("UICorner", lenBtn)
    btnCorner.CornerRadius = UDim.new(0, 6)

    lenBtn.MouseButton1Click:Connect(function()
        currentLength = len
    end)
end

-- === Username Generation Logic ===
local consonants = {"b","c","d","f","g","h","j","k","l","m","n","p","r","s","t","v","w","z"}
local vowels = {"a","e","i","o","u"}

local function GenerateCleanName(length)
    local name = ""
    local useConsonant = true
    for i = 1, length do
        if useConsonant then
            name = name .. consonants[math.random(1, #consonants)]
        else
            name = name .. vowels[math.random(1, #vowels)]
        end
        useConsonant = not useConsonant
    end
    return name:sub(1,1):upper() .. name:sub(2)
end

-- Check username availability
local function IsUsernameAvailable(username)
    local url = "https://users.roblox.com/v1/usernames/users"
    local body = HttpService:JSONEncode({usernames = {username}})
    local success, result = pcall(function()
        return game:HttpPost(url, body, Enum.HttpContentType.ApplicationJson, false)
    end)
    if success and result then
        local data = HttpService:JSONDecode(result)
        return #data.data == 0
    end
    return false
end

-- Generate Button
GenerateBtn.MouseButton1Click:Connect(function()
    NameLabel.Text = "Checking..."
    task.spawn(function()
        local tries = 0
        while tries < 30 do
            local candidate = GenerateCleanName(currentLength)
            if IsUsernameAvailable(candidate) then
                NameLabel.Text = candidate
                return
            end
            tries += 1
            task.wait(0.2)
        end
        NameLabel.Text = "No available name found"
    end)
end)

-- Copy Button
CopyBtn.MouseButton1Click:Connect(function()
    if typeof(setclipboard) == "function" then
        setclipboard(NameLabel.Text)
    elseif typeof(writeclipboard) == "function" then
        writeclipboard(NameLabel.Text)
    end
end)
