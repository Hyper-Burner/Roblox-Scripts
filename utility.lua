local Utility = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

function Utility.sendDiscordWebhook(webhookUrl: string, embed: table)
    print(HttpService:JSONEncode(embed))
    local response = request({
        Url = webhookUrl,
        Method = "POST",
        Body = HttpService:JSONEncode(embed),
        Headers = {["Content-Type"] = "application/json"}
    })
    print(response.StatusCode)
    return response
end

--function Utility.connectWebsocket(url: string, onMessage: function)
--    local webSocket = WebSocket.connect(url)
--    return webSocket
--end

function Utility.formatNumberWithCommas(number: number)
    return tostring(number):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

function Utility.formatNumberWithSuffix(number: number)
    local suffixes = {"K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"}
    if number < 1000 then
        return tostring(number)
    end
    
    local i = math.floor(math.log(number, 1e3))
    local v = math.pow(10, i * 3)
    local scaled = number / v
    
    -- Format to 1 decimal place and remove trailing zeros
    local formatted = string.format("%.1f", scaled):gsub("%.?0+$", "")
    
    return formatted .. (suffixes[i] or "")
end

function Utility.tweenTo(position: Vector3, speed: number, timeout: number)
    local humanoidRootPart = Players.LocalPlayer.Character.HumanoidRootPart
    local timeElapsed = 0
    local heartbeat
    local expectedDuration = (humanoidRootPart.Position - position).Magnitude / speed
    heartbeat = RunService.Heartbeat:Connect(function(deltaTime: number)
        local distanceRemaining = (position - humanoidRootPart.Position).Magnitude
        if distanceRemaining < speed * deltaTime or timeElapsed >= expectedDuration + timeout then
            humanoidRootPart.CFrame = CFrame.new(position)
            heartbeat:Disconnect()
        end
        local direction = (position - humanoidRootPart.Position).Unit
        humanoidRootPart.CFrame = humanoidRootPart.CFrame + (direction * speed * deltaTime)
        timeElapsed += deltaTime
    end)
end

function Utility.getNearestPlayer()
    local nearestPlayer = nil
    local nearestPlayerDistance = math.huge
    local localPlayer = Players.LocalPlayer
    local humanoidRootPart = localPlayer.Character.HumanoidRootPart
    for _, player in Players:GetChildren() do
        if player == Players.LocalPlayer then
            continue
        end
        local distance = (humanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
        if distance < nearestPlayerDistance then
            nearestPlayer = player
            nearestPlayerDistance = distance
        end
    end
    return nearestPlayer
end

function Utility.sortArrayOfDictionaries(array: table, key: string)
    table.sort(array, function(a, b)
        return a[key] > b[key]
    end)
end

function Utility.findFunction(numberOfUpvalues: number, numberOfConstants: number)
    for _, f in getgc() do
        if typeof(f) == 'function' and islclosure(f) then
            local upvalues = debug.getupvalues(f)
            local constants = debug.getconstants(f)
            if upvalues and #upvalues == numberOfUpvalues and constants and #constants == numberOfConstants then
                return f
            end
        end
    end
    return nil
end

return Utility