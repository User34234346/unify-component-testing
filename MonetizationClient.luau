-- Services
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Variables
local Client = Players.LocalPlayer
local PlayerGui = Client:WaitForChild("PlayerGui")

local MainCanvas

-- Module
local MonetizationClient = {
    Cache = {},
    Connections = {}
}

type PromptOptions = {
    isDevProduct: boolean?,
    savetoCache: boolean?
}

local TWEEN_TIME = 0.6
local TWEEN_STYLE = Enum.EasingStyle.Back
local TWEEN_DIRECTION = Enum.EasingDirection.Out

local function tween(inst : Instance, properties : { [any] : any }, ... : any)
    local tween = TweenService:Create(inst, TweenInfo.new(...), properties)
    tween:Play()
    return tween
end

do
    local monetizationGui = Instance.new("ScreenGui", PlayerGui)
    monetizationGui.Name = HttpService:GenerateGUID(false)
    monetizationGui.ResetOnSpawn = false
    monetizationGui.IgnoreGuiInset = true
    monetizationGui.ScreenInsets = Enum.ScreenInsets.None
    monetizationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local mainCanvas = Instance.new("CanvasGroup", monetizationGui)
    mainCanvas.Name = "MainCanvas"
    mainCanvas.Size = UDim2.new(1, 0, 1, 0)
    mainCanvas.AnchorPoint = Vector2.new(0.5, 0.5)
    mainCanvas.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainCanvas.BackgroundTransparency = 0.5
    mainCanvas.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainCanvas.GroupTransparency = 1
    MainCanvas = mainCanvas

    local imageLabel = Instance.new("ImageLabel", mainCanvas)
    imageLabel.Size = UDim2.new(0.1, 0, 0.1, 0)
    imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    imageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    imageLabel.BackgroundTransparency = 1
    imageLabel.Image = "rbxassetid://137888440831159"
    imageLabel.ScaleType = Enum.ScaleType.Fit

    tween(imageLabel, { Rotation = 360 }, TWEEN_TIME * 2, TWEEN_STYLE, TWEEN_DIRECTION, -1, false, 0.5)
end

function MonetizationClient:GetProductInfo(assetId: number, type: Enum.InfoType, savetoCache: boolean?): {[string]: any}?
    savetoCache = savetoCache ~= false

    local cache = self.Cache[assetId]
    if cache and savetoCache then return cache end
    
    local data
    local success, err = pcall(function()
        data = MarketplaceService:GetProductInfo(assetId, type)
    end)

    if not success then return end

    if savetoCache then
        self.Cache[assetId] = data
    end

    return data
end

function MonetizationClient:Prompt(assetId: number, options: PromptOptions): RBXScriptSignal
    if self.Connections[assetId] then return self.Connections[assetId].Signal.Event end
    options = options or {}

    local signal = Instance.new("BindableEvent")

    self.Connections[assetId] = {}
    self.Connections[assetId].Signal = signal

    if options.isDevProduct then
        MarketplaceService:PromptProductPurchase(Client, assetId)
    else
        MarketplaceService:PromptGamePassPurchase(Client, assetId)
    end

    tween(MainCanvas, { GroupTransparency = 0 }, TWEEN_TIME, TWEEN_STYLE, TWEEN_DIRECTION)

    local productData = self:GetProductInfo(assetId, Enum.InfoType[options.isDevProduct and "Product" or "GamePass"], options.savetoCache)
    
    local finishType = options.isDevProduct and MarketplaceService.PromptProductPurchaseFinished or MarketplaceService.PromptGamePassPurchaseFinished
    self.Connections[assetId].Connection = finishType:Connect(function(player: number | Player, id: number, isPurchased: boolean)
        player = type(player) == "number" and player or player.UserId
        if player ~= Client.UserId or id ~= assetId then return end
        tween(MainCanvas, { GroupTransparency = 1 }, TWEEN_TIME, TWEEN_STYLE, TWEEN_DIRECTION)

        signal:Fire(isPurchased, productData)
        signal:Destroy()
        self.Connections[assetId].Connection:Disconnect()
        self.Connections[assetId] = nil
    end)

    return signal.Event
end

--[[
    Example:

    MonetizationClient:Prompt(1436321165):Connect(function(isPurchased: boolean, productData: table)
        print(isPurchased, productData)
    end)
]]


return MonetizationClient
