-- // Credits to Intrer#0421 for the source \\ --
-- // This UI is updated by me (LucidSc1pt) with some vibecode \\ --

-- // MAIN CODE \\ --

if getgenv().TurtleLib then
    pcall(function() 
        getgenv().TurtleLib:Destroy() 
    end)
    getgenv().TurtleLib = nil
    task.wait(0.2)
end

local library = {
	ThemeObjects = {},
	Flags = {},
	Connections = {},
	Elements = {},
	OpenWindows = {},
	Themes = {
		Default = {
			WindowBackground = Color3.fromRGB(47, 54, 64),
			WindowBorder = Color3.fromRGB(47, 54, 64),

			UIWindow = Color3.fromRGB(0, 151, 230),
			UIWindowBorder = Color3.fromRGB(0, 151, 230),

			ElementDivider = Color3.fromRGB(107, 114, 124),
			ElementDividerText = Color3.fromRGB(107, 114, 124),

			TabDivider = Color3.fromRGB(107, 114, 124),
			TabDividerText = Color3.fromRGB(107, 114, 124),
			TabBtnBackground = Color3.fromRGB(40, 148, 215),
			TabBtnBackgroundSelect = Color3.fromRGB(0, 168, 255),

			Header = Color3.fromRGB(0, 168, 255),
			HeaderBorder = Color3.fromRGB(0, 168, 255),
			HeaderText = Color3.fromRGB(47, 54, 64),
			SubHeaderText = Color3.fromRGB(67, 74, 84),

			NormalText = Color3.fromRGB(245, 246, 250),
			NormalBackground = Color3.fromRGB(53, 59, 72),

			DropdownOptionBackground = Color3.fromRGB(53, 59, 72),
			DropdownOptionTextHolder = Color3.fromRGB(180, 180, 180),
			DropdownOptionSelect = Color3.fromRGB(73, 79, 92),

			BtnBorder = Color3.fromRGB(113, 128, 147),
			
			ToggleFiller = Color3.fromRGB(68, 189, 50),

			SliderFiller = Color3.fromRGB(76, 209, 55)
		}
	},
	VerifiedKeys = {},
	IsDebug = true,
	GlobalAutoSave = false,
	SelectedTheme = "Default"
}
local CurrentFolderName = nil
local CurrentConfigName = nil
local windowCount = 0
local dropdowns = {}
local dropdownSizes = {}
local colorPickers = {}
local activeInteraction = nil
local zindex = 1000

getgenv().TurtleLib = library

-- // Service \\ --
local TweenService = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local players = game:service('Players');
local player = players.LocalPlayer;
local mouse = player:GetMouse();
local run = game:service('RunService');
local stepped = run.Stepped;
local HttpService = game:GetService("HttpService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local GuiService = game:GetService("GuiService")

-- // Instances:

local function SafeConnect(signal, callback)
    if typeof(signal) ~= "RBXScriptSignal" then return nil end
    if type(callback) ~= "function" then return nil end

    local ok, connection = pcall(signal.Connect, signal, callback)
    if ok and connection then
        table.insert(library.Connections, connection)
        return connection
    end
    return nil
end

local function GiveSignal(connection)
    if typeof(connection) == "RBXScriptConnection" then
        table.insert(library.Connections, connection)
        return connection
    end
    return nil
end

local function protect_gui(obj)
	if destroyed or not obj then return end
	if gethui then
		obj.Parent = gethui()
	elseif syn and syn.protect_gui then
		syn.protect_gui(obj)
		obj.Parent = game.CoreGui
	elseif get_hidden_gui then
		obj.Parent = get_hidden_gui()
	else
		obj.Parent = game.CoreGui
	end
	OrionGui = obj
end

local function randomNameString()
  local length = math.random(40, 80)
  local array = {}
  for i = 1, length do
  	array[i] = string.char(math.random(0, 255))
  end
  return table.concat(array)
end

local rngName = randomNameString()

-- // Making the ScreenGui \\ --
local TurtleUiLib = Instance.new("ScreenGui")
TurtleUiLib.Name = tostring(rngName)
TurtleUiLib.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
TurtleUiLib.ScreenInsets = Enum.ScreenInsets.None
TurtleUiLib.ClipToDeviceSafeArea = false
protect_gui(TurtleUiLib)

function Lerp(a, b, c)
	return a + ((b - a) * c)
end

local IconPacks = {
	lucide = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/icons.lua"))(),
	solar = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/solar/dist/Icons.lua"))(),
	craft = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/craft/dist/Icons.lua"))(),
	geist = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/geist/dist/Icons.lua"))(),
	sfsymbols = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/sfsymbols/dist/Icons.lua"))(),
	gravity = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/gravity/dist/Icons.lua"))()
}

--[[===========================
		local function var()
	===========================]]

local function getHWID()
	local success, hwid = pcall(function()
		return RbxAnalyticsService:GetClientId()
	end)
	return success and hwid or "UNKNOWN_HWID"
end

local MAIN_ROOT_FOLDER = "TurtleLib"

local function ensureFolder(path)
	if isfolder and makefolder and not isfolder(path) then
		pcall(makefolder, path)
	end
end

local function getFolderPath(folderName, subFolder)
	ensureFolder(MAIN_ROOT_FOLDER)
	
	local userFolder = (folderName and folderName ~= "") and folderName or "DefaultScript"
	local userPath = MAIN_ROOT_FOLDER .. "/" .. userFolder
	ensureFolder(userPath)

	if subFolder then
		local subPath = userPath .. "/" .. subFolder
		ensureFolder(subPath)
		return subPath
	end

	return userPath
end

local function getKeyFilePath(folderName, fileName)
	local keysDir = getFolderPath(folderName, "Keys")
	return keysDir .. "/" .. (fileName or "SavedKey.txt")
end

local API_VALIDATORS = {
	["luarmor"] = function(key, cfg, hwid)
		local scriptId = cfg.ScriptId or cfg.ServiceId or ""
		local url = string.format(
			"https://api.luarmor.net/v3/projects/%s/keys/%s",
			scriptId,
			HttpService:UrlEncode(key)
		)
		
		local success, res = pcall(function() return game:HttpGet(url) end)
		if not success or not res then return false, "NETWORK_ERROR" end
		
		local ok, json = pcall(function() return HttpService:JSONDecode(res) end)
		if ok and type(json) == "table" then
			return json.valid == true, "API_RESPONSE"
		end
		return false, "INVALID_RESPONSE"
	end,

	["pandadevelopment"] = function(key, cfg, hwid)
		local serviceId = cfg.ServiceId or ""
		local url = string.format(
			"https://pandadevelopment.net/v2/validation?hwid=%s&key=%s&service_id=%s",
			HttpService:UrlEncode(hwid),
			HttpService:UrlEncode(key),
			HttpService:UrlEncode(serviceId)
		)

		local success, res = pcall(function() return game:HttpGet(url) end)
		if not success or not res then return false, "NETWORK_ERROR" end

		local ok, json = pcall(function() return HttpService:JSONDecode(res) end)
		if ok and type(json) == "table" then
			return (json.authenticated == true or json.success == true), "API_RESPONSE"
		end
		return res:find("valid") ~= nil, "API_RESPONSE"
	end,

	["platoboost"] = function(key, cfg, hwid)
		local serviceId = cfg.ServiceId or ""
		local url = string.format(
			"https://api.platoboost.com/public/whitelist/check?public_key=%s&key=%s&hwid=%s",
			HttpService:UrlEncode(serviceId),
			HttpService:UrlEncode(key),
			HttpService:UrlEncode(hwid)
		)

		local success, res = pcall(function() return game:HttpGet(url) end)
		if not success or not res then return false, "NETWORK_ERROR" end

		local ok, json = pcall(function() return HttpService:JSONDecode(res) end)
		if ok and type(json) == "table" then
			return (json.valid == true or json.success == true), "API_RESPONSE"
		end
		return res:find("true") ~= nil, "API_RESPONSE"
	end
}

local function parseUniversalIcon(raw)
	if not raw then return nil end

	local result = {
		Image = "",
		RectSize = Vector2.zero,
		RectOffset = Vector2.zero
	}

	if type(raw) == "number" then
		result.Image = "rbxassetid://" .. raw
		return result
	end

	if type(raw) == "string" then
		if string.sub(raw, 1, 13) == "rbxassetid://" or string.find(raw, "://") then
			result.Image = raw
			return result
		elseif tonumber(raw) then
			result.Image = "rbxassetid://" .. raw
			return result
		end
	end

	if type(raw) == "table" then
		local img = raw.Image or raw.image or raw.id or raw.Id or raw.Asset or raw.asset or raw.url or raw[1]
		if type(img) == "number" then
			result.Image = "rbxassetid://" .. img
		elseif type(img) == "string" then
			result.Image = (string.sub(img, 1, 13) == "rbxassetid://" or string.find(img, "://")) and img or ("rbxassetid://" .. img)
		end

		local size = raw.ImageRectSize or raw.imageRectSize or raw.Size or raw.size or raw[2]
		if typeof(size) == "Vector2" then
			result.RectSize = size
		elseif type(size) == "table" then
			result.RectSize = Vector2.new(size[1] or size.X or size.x or 0, size[2] or size.Y or size.y or 0)
		end

		local offset = raw.ImageRectOffset or raw.imageRectOffset or raw.Offset or raw.offset or raw[3]
		if typeof(offset) == "Vector2" then
			result.RectOffset = offset
		elseif type(offset) == "table" then
			result.RectOffset = Vector2.new(offset[1] or offset.X or offset.x or 0, offset[2] or offset.Y or offset.y or 0)
		end

		return (result.Image ~= "") and result or nil
	end

	return nil
end

local function getIconData(input)
	if not input then return nil end

	local directParsed = parseUniversalIcon(input)
	if directParsed then return directParsed end

	if type(input) ~= "string" or input == "" then return nil end

	local packName, iconName = string.match(input, "^(%w+):(.+)$")
	if not packName then
		packName = "lucide"
		iconName = input
	end

	packName = string.lower(packName)
	iconName = string.match(string.lower(iconName), "^%s*(.*)%s*$")

	local selectedPack = IconPacks[packName]
	if not selectedPack then return nil end

	local sizedIcons = selectedPack['48px'] or selectedPack['24px'] or selectedPack
	local rawIcon = sizedIcons[iconName]

	if not rawIcon and type(selectedPack.Get) == "function" then
		rawIcon = selectedPack:Get(iconName)
	end

	return parseUniversalIcon(rawIcon)
end

local function applyIcon(imageInstance, iconInput)
	local data = getIconData(iconInput)
	if not data then 
		imageInstance.Image = ""
		return 
	end

	imageInstance.Image = data.Image
	imageInstance.ImageRectSize = data.RectSize     -- Jika bukan spritesheet, nilainya Vector2(0,0)
	imageInstance.ImageRectOffset = data.RectOffset -- Jika bukan spritesheet, nilainya Vector2(0,0)
end

local function MakeDraggable(DragPoint, Main)
    Main = Main or DragPoint
    if typeof(DragPoint) ~= "Instance" or typeof(Main) ~= "Instance" then return end

    local Dragging = false
    local DragInput = nil
    local MousePos = nil
    local FramePos = nil

    SafeConnect(DragPoint.InputBegan, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            if Dragging and activeInteraction ~= nil then return end

            Dragging = true
            MousePos = Input.Position
            FramePos = Main.Position
            DragInput = Input

            local changedConnection
            changedConnection = Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                    DragInput = nil
                    if changedConnection then
                        changedConnection:Disconnect()
                    end
                end
            end)
        end
    end)

    SafeConnect(DragPoint.InputChanged, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
            if not Dragging then
                DragInput = Input
            end
        end
    end)

    SafeConnect(uis.InputChanged, function(Input)
        if Dragging and activeInteraction == nil and Input == DragInput then
            local Delta = Input.Position - MousePos
            Main.Position = UDim2.new(
                FramePos.X.Scale, 
                FramePos.X.Offset + Delta.X, 
                FramePos.Y.Scale, 
                FramePos.Y.Offset + Delta.Y
            )
        end
    end)
    
    SafeConnect(Main.AncestryChanged, function(_, parent)
        if not parent then
            Dragging = false
        end
    end)
end

local function Create(Name, Properties)
	local Object = Instance.new(Name)
	for i, v in next, Properties or {} do
		Object[i] = v
	end
	return Object
end

local function ReturnProperty(Object)
	if Object:IsA("Frame") or Object:IsA("TextButton") then
		return "BackgroundColor3"
	elseif Object:IsA("ScrollingFrame") then
		return "ScrollBarImageColor3"
	elseif Object:IsA("UIStroke") then
		return "Color"
	elseif Object:IsA("TextLabel") or Object:IsA("TextBox") then
		return "TextColor3"
	elseif Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
		return "ImageColor3"
	end
	return "BackgroundColor3"
end

local function AddThemeObject(Object, ThemeKey, SpecificProperty)
	if not library.ThemeObjects[ThemeKey] then
		library.ThemeObjects[ThemeKey] = {}
	end
	
	local targetProperty = SpecificProperty or ReturnProperty(Object)

	table.insert(library.ThemeObjects[ThemeKey], {
		Object = Object,
		Property = targetProperty
	})

	local currentTheme = library.Themes[library.SelectedTheme]
	if currentTheme and currentTheme[ThemeKey] then
		Object[targetProperty] = currentTheme[ThemeKey]
	end

	return Object
end
-- testing...
local function execCallback(callback, itemConfig, ...)
	if type(callback) ~= "function" then return true end

	local isSafe = true
	if itemConfig and (typeof(itemConfig.SafeCallback) == "boolean" and itemConfig.SafeCallback ~= nil) then
		isSafe = itemConfig.SafeCallback
	elseif library and library.IsDebug ~= nil then
		isSafe = library.IsDebug
	end

	if isSafe then
		local success, err = xpcall(callback, function(errMessage)
			return errMessage .. "\n" .. debug.traceback("", 2)
		end, ...)

		if not success then
			local elementName = "Unknown Element"
			if type(itemConfig) == "table" then
				elementName = itemConfig.Title or itemConfig.Name or itemConfig.Text or "Element"
			end

			warn("[TurtleUI SafeCallback Error on " .. tostring(elementName) .. "]:\n" .. tostring(err))
			return false
		end
		return true
	else
		callback(...)
		return true
	end
end

local function attachLockSystem(controller, targetFrame, initialConfig)
	initialConfig = initialConfig or {}
	local lockOverlay = nil

	local isLocked = false 

	function controller:_isLocked()
		return isLocked
	end

	function controller:Lock(lockConfig)
		isLocked = true
		lockConfig = type(lockConfig) == "table" and lockConfig or { Text = lockConfig }
		local lockText = lockConfig.Text or lockConfig.Reason or "🔒 Premium"

		if lockOverlay and lockOverlay.Parent then
			local label = lockOverlay:FindFirstChild("LockLabel")
			if label then label.Text = lockText end
			lockOverlay.Visible = true
			return
		end

		lockOverlay = Instance.new("TextButton")
		lockOverlay.Name = "LockOverlay"
		lockOverlay.Parent = targetFrame
		lockOverlay.Size = UDim2.new(1, 0, 1, 0)
		lockOverlay.Position = UDim2.new(0, 0, 0, 0)
		lockOverlay.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
		lockOverlay.BackgroundTransparency = 0.35
		lockOverlay.BorderSizePixel = 0
		lockOverlay.Text = ""
		lockOverlay.AutoButtonColor = false
		lockOverlay.ZIndex = (targetFrame.ZIndex or 1) + 50
		lockOverlay.ClipsDescendants = true
		lockOverlay.ZIndex = 15 + zindex

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 4)
		corner.Parent = lockOverlay

		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(241, 196, 15)
		stroke.Transparency = 0.6
		stroke.Thickness = 1
		stroke.Parent = lockOverlay

		local label = Instance.new("TextLabel")
		label.Name = "LockLabel"
		label.Parent = lockOverlay
		label.Size = UDim2.new(1, -10, 1, 0)
		label.Position = UDim2.new(0, 5, 0, 0)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.SourceSansBold
		label.Text = lockText
		label.TextColor3 = Color3.fromRGB(255, 215, 0)
		label.TextSize = 13
		label.ZIndex = lockOverlay.ZIndex + 1
		label.TextTruncate = Enum.TextTruncate.AtEnd

		lockOverlay.Visible = true
	end

	function controller:Unlock()
		isLocked = false
		if lockOverlay then
			lockOverlay.Visible = false
		end
	end

	if initialConfig.Locked then
		controller:Lock((initialConfig.LockText or initialConfig.LockTitle or initialConfig.LockName) or "🔒 Premium")
	end

	return controller
end

local function registerFlag(config, controller)
    if not config.Flag then return end

    if library.Flags[config.Flag] ~= nil and library.IsDebug then
        warn("[Turtle] Duplicate flag: '".. tostring(config.Flag).."' di '".. tostring(config.Title).."' | yang lama bakal kepake, yang baru di-skip")
        library.Elements[config.Flag] = library.Elements[config.Flag] or (controller or config)
        return
    end

    library.Elements[config.Flag] = controller or config
    library.Flags[config.Flag] = config.Default
end

local function checkCustomApiUrl(key, apiUrl, serviceId, hwid)
	local url = apiUrl
	url = string.gsub(url, "{key}", HttpService:UrlEncode(key))
	url = string.gsub(url, "{service_id}", HttpService:UrlEncode(serviceId or ""))
	url = string.gsub(url, "{hwid}", HttpService:UrlEncode(hwid))

	if not string.find(apiUrl, "{key}") then
		local separator = string.find(url, "%?") and "&" or "?"
		url = url .. separator .. "key=" .. HttpService:UrlEncode(key) .. "&hwid=" .. HttpService:UrlEncode(hwid)
	end

	local success, res = pcall(function() return game:HttpGet(url) end)
	if not success or not res then return false, "NETWORK_ERROR" end

	local ok, json = pcall(function() return HttpService:JSONDecode(res) end)
	if ok and type(json) == "table" then
		return (json.valid == true or json.success == true or json.status == "success"), "API_RESPONSE"
	end

	local cleanRes = string.upper(string.gsub(res, "%s+", ""))
	return (cleanRes == "TRUE" or cleanRes == "VALID" or cleanRes == "SUCCESS"), "API_RESPONSE"
end

local function isKeyValid(inputKey, keySettings)
	if not inputKey or inputKey == "" then return false, "EMPTY_KEY" end
	inputKey = string.gsub(inputKey, "%s+", "") -- Hapus spasi liar
	local hwid = getHWID()

	if type(keySettings.API) == "table" then
		for _, apiCfg in ipairs(keySettings.API) do
			local serviceType = apiCfg.Type and string.lower(apiCfg.Type) or ""
			local validatorFn = API_VALIDATORS[serviceType]

			if validatorFn then
				local isValid, reason = validatorFn(inputKey, apiCfg, hwid)
				if reason == "NETWORK_ERROR" then return false, "NETWORK_ERROR" end
				if isValid then return true, "API_VALID" end
			elseif apiCfg.ApiUrl then
				local isValid, reason = checkCustomApiUrl(inputKey, apiCfg.ApiUrl, apiCfg.ServiceId, hwid)
				if reason == "NETWORK_ERROR" then return false, "NETWORK_ERROR" end
				if isValid then return true, "API_VALID" end
			end
		end
		return false, "API_INVALID"

	elseif keySettings.Service or keySettings.ApiUrl then
		local serviceType = keySettings.Service and string.lower(keySettings.Service) or ""
		local validatorFn = API_VALIDATORS[serviceType]

		if validatorFn then
			local isValid, reason = validatorFn(inputKey, keySettings, hwid)
			if reason == "NETWORK_ERROR" then return false, "NETWORK_ERROR" end
			if isValid then return true, "API_VALID" end
		elseif keySettings.ApiUrl then
			local isValid, reason = checkCustomApiUrl(inputKey, keySettings.ApiUrl, keySettings.ServiceId, hwid)
			if reason == "NETWORK_ERROR" then return false, "NETWORK_ERROR" end
			if isValid then return true, "API_VALID" end
		end
		return false, "API_INVALID"
	end

	local validator = keySettings.CustomValidator or keySettings.KeyValidator
	if type(validator) == "function" then
		local s, valid = pcall(validator, inputKey)
		if s and valid == true then return true, "CUSTOM_VALID" end
		return false, "CUSTOM_INVALID"
	end

	local keys = keySettings.Keys or keySettings.Key
	if type(keys) == "table" then
		for _, k in ipairs(keys) do
			if inputKey == k then return true, "LOCAL_VALID" end
		end
	elseif type(keys) == "string" then
		if inputKey == keys then return true, "LOCAL_VALID" end
	end

	return false, "INVALID_KEY"
end

local function saveKey(folderName, fileName, key)
	if not writefile then return end
	local filePath = getKeyFilePath(folderName, fileName)
	pcall(writefile, filePath, key)
end

local function getSavedKey(folderName, fileName, keySettings)
	local filePath = getKeyFilePath(folderName, fileName)
	if not (isfile and isfile(filePath)) then return nil end

	local success, savedKey = pcall(readfile, filePath)
	if not success or not savedKey or savedKey == "" then return nil end
	savedKey = string.gsub(savedKey, "%s+", "")

	local isApiMode = keySettings and (keySettings.API or keySettings.Service or keySettings.ApiUrl or keySettings.CustomValidator or keySettings.KeyValidator)

	if isApiMode then
		local isValid, reason = isKeyValid(savedKey, keySettings)
		if isValid then
			return savedKey
		else
			if reason ~= "NETWORK_ERROR" and delfile then
				pcall(delfile, filePath)
			end
			return nil
		end
	end

	return savedKey
end

--[[===========================
		library:function()
	===========================]]

function library:AddTheme(themeName, themeTable)
	if type(themeName) == "string" and type(themeTable) == "table" then
		library.Themes[themeName] = themeTable
	end
end

function library:SetTheme(themeInput)
	local targetTheme = nil

	if type(themeInput) == "string" then
		if library.Themes[themeInput] then
			library.SelectedTheme = themeInput
			targetTheme = library.Themes[themeInput]
		end
	elseif type(themeInput) == "table" then
		targetTheme = themeInput
		library.SelectedTheme = "Custom"
	end

	if not targetTheme then return end

	for themeKey, objectList in pairs(library.ThemeObjects) do
		local targetColor = targetTheme[themeKey]
		if targetColor then
			for i = #objectList, 1, -1 do
				local item = objectList[i]
				if item.Object and item.Object.Parent then
					item.Object[item.Property] = targetColor
				else
					table.remove(objectList, i)
				end
			end
		end
	end
end

function library:SaveConfig(folderName, configName)
	if not writefile then return false end

	local configDir = getFolderPath(folderName, "Configs")
	configName = (configName and configName ~= "") and configName or tostring(game.GameId)
	local filePath = configDir .. "/" .. configName .. ".json"

	local dataToSave = {}
	for flag, value in pairs(library.Flags) do
		if typeof(value) == "Color3" then
			dataToSave[flag] = { __type = "Color3", r = value.R, g = value.G, b = value.B }
		else
			dataToSave[flag] = value
		end
	end

	local success, json = pcall(function() return HttpService:JSONEncode(dataToSave) end)
	if success then
		pcall(writefile, filePath, json)
		return true
	end
	return false
end

function library:LoadConfig(folderName, configName)
	if not readfile or not isfile then return false end

	local configDir = getFolderPath(folderName, "Configs")
	configName = (configName and configName ~= "") and configName or tostring(game.GameId)
	local filePath = configDir .. "/" .. configName .. ".json"

	if not isfile(filePath) then return false end
	local success, rawData = pcall(readfile, filePath)
	if not success then return false end

	local decodeSuccess, decoded = pcall(function() return HttpService:JSONDecode(rawData) end)
	if decodeSuccess and type(decoded) == "table" then
		for flag, value in pairs(decoded) do
			local parsedValue = value
			if type(value) == "table" and value.__type == "Color3" then
				parsedValue = Color3.new(value.r, value.g, value.b)
			end

			library.Flags[flag] = parsedValue

			local option = library.Elements[flag]
			if option and type(option.SetValue) == "function" then
				pcall(function()
					option:SetValue(parsedValue)
				end)
			end
		end
		return true
	end
	return false
end

local xOffset = 20
local keybindConnection

-- // ⚠️ Function ⚠️ \\ --

-- // Notification Function \\ --
local function getNotificationContainer()
	local container = TurtleUiLib:FindFirstChild("NotificationHolder")
	if not container then
		container = Create("Frame", {
			Name = "NotificationHolder",
			Parent = TurtleUiLib,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -25, 1, -25),
			Size = UDim2.new(0, 280, 1, -25),
			BackgroundTransparency = 1,
			ClipsDescendants = false,
			ZIndex = 99999999999999
		})

		Create("UIListLayout", {
			Parent = container,
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Padding = UDim.new(0, 5)
		})
	end
	return container
end

function library:Notification(NotificationConfig)
	task.spawn(function()
		NotificationConfig = NotificationConfig or {}
		NotificationConfig.Title = (NotificationConfig.Title or NotificationConfig.Name or NotificationConfig.Text) or "Notification"
		NotificationConfig.Content = (NotificationConfig.Content or NotificationConfig.Desc or NotificationConfig.Description) or "Hello World"
		NotificationConfig.Image = (NotificationConfig.Image or NotificationConfig.Icon) or 4384403532
		NotificationConfig.Type = NotificationConfig.Type or "Info"
		NotificationConfig.Time = ((NotificationConfig.Time or NotificationConfig.Duration) or (NotificationConfig.duration)) or 5
		
		local NotificationHolder = getNotificationContainer()
		
		local accentColors = {
			Info = Color3.fromRGB(52, 152, 219),
			Success = Color3.fromRGB(46, 204, 113),
			Warning = Color3.fromRGB(241, 196, 15),
			Error = Color3.fromRGB(231, 76, 60)
		}
		local accentColor = accentColors[NotificationConfig.Type] or accentColors.Info

		local isDismissed = false

		local NotificationParent = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.None,
			BackgroundTransparency = 1,
			ClipsDescendants = false,
			Parent = NotificationHolder
		})

		local NotificationFrame = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(1, 50, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = library["Themes"]["Default"].WindowBackground,
			BackgroundTransparency = 0,
			Parent = NotificationParent
		})

		Create("UICorner", {
			CornerRadius = UDim.new(0.1, 0),
			Parent = NotificationFrame
		})

		local NotificationFrame_Stroke = Create("UIStroke", {
			Parent = NotificationFrame,
			Thickness = 1.2,
			Color = accentColor,
			Transparency = 0,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Enabled = true
		})

		local Padding = Instance.new("UIPadding")
		Padding.Parent = NotificationFrame
		Padding.PaddingTop = UDim.new(0, 8)
		Padding.PaddingBottom = UDim.new(0, 12)
		Padding.PaddingLeft = UDim.new(0, 10)
		Padding.PaddingRight = UDim.new(0, 10)

		local closeNotifButton = Instance.new("ImageButton")
		closeNotifButton.AnchorPoint = Vector2.new(1, 0)
		closeNotifButton.Size = UDim2.new(0, 20, 0, 20)
		closeNotifButton.Position = UDim2.new(1, 0, 0, 0)
		closeNotifButton.BackgroundTransparency = 1
		closeNotifButton.Image = "rbxassetid://7072725342"
		closeNotifButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
		closeNotifButton.Parent = NotificationFrame

		local contentHolder = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Parent = NotificationFrame
		})
	
		local textLayoutHolder = Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = contentHolder
		})
	
		local textHolder = Create("Frame", {
			Size = UDim2.new(1, -25, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Parent = contentHolder
		})

		local textLayoutHolder2 = Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = textHolder
		})

		local Icon = Create("ImageLabel", {
			Size = UDim2.new(0, 24, 0, 24),
			BackgroundTransparency = 1,
			ImageColor3 = Color3.fromRGB(240, 240, 240),
			Name = "Icon",
			LayoutOrder = 1,
			ImageTransparency = 0,
			Parent = textHolder
		})

		local Title = Instance.new("TextLabel")
		Title.Parent = textHolder
		Title.Size = UDim2.new(1, -32, 0, 0)
		Title.AutomaticSize = Enum.AutomaticSize.Y
		Title.BackgroundTransparency = 1
		Title.Font = Enum.Font.GothamBold
		Title.TextColor3 = Color3.fromRGB(255, 255, 255)
		Title.TextSize = 14
		Title.TextWrapped = true
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.Text = NotificationConfig.Title
		Title.TextTransparency = 0
		Title.LayoutOrder = 2

		if NotificationConfig.Image and (NotificationConfig.Image ~= nil and NotificationConfig.Image ~= "") then
			applyIcon(Icon, NotificationConfig.Image)
		else
			Icon:Destroy()
			Title.Size = UDim2.new(1, 0, 0, 0)
		end

		local Content = Create("TextLabel", {
			Parent = contentHolder,
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.Y,
			Font = Enum.Font.GothamSemibold,
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			TextTransparency = 0,
			LayoutOrder = 2,
			Text = NotificationConfig.Content
		})

		local ProgressBarParent = Instance.new("Frame")
		ProgressBarParent.AnchorPoint = Vector2.new(0, 1)
		ProgressBarParent.Parent = NotificationFrame
		ProgressBarParent.Size = UDim2.new(1, 0, 0, 3)
		ProgressBarParent.Position = UDim2.new(0, 0, 1, 5)
		ProgressBarParent.BackgroundTransparency = 0
		ProgressBarParent.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		ProgressBarParent.BorderSizePixel = 0
		Instance.new("UICorner", ProgressBarParent).CornerRadius = UDim.new(0, 3)

		local ProgressBar = Instance.new("Frame")
		ProgressBar.Parent = ProgressBarParent
		ProgressBar.Size = UDim2.new(1, 0, 1, 0)
		ProgressBar.Position = UDim2.new(0, 0, 0, 0)
		ProgressBar.BackgroundTransparency = 0
		ProgressBar.BackgroundColor3 = accentColor
		ProgressBar.BorderSizePixel = 0
		Instance.new("UICorner", ProgressBar).CornerRadius = UDim.new(0, 3)

		task.wait(0.05) 
		local targetHeight = NotificationFrame.AbsoluteSize.Y

		NotificationParent.Size = UDim2.new(1, 0, 0, 0)
		NotificationParent.AutomaticSize = Enum.AutomaticSize.None

		--NotificationFrame.Size = UDim2.new(1, 0, 0, targetHeight)
		NotificationFrame.AutomaticSize = Enum.AutomaticSize.Y

		local barTween = TweenService:Create(ProgressBar, TweenInfo.new(NotificationConfig.Time, Enum.EasingStyle.Linear), {
			Size = UDim2.new(0, 0, 1, 0)
		})

		local function DismissNotification()
			if isDismissed then return end
			isDismissed = true

			barTween:Cancel()

			NotificationParent.AutomaticSize = Enum.AutomaticSize.None
			NotificationParent.Size = UDim2.new(1, 0, 0, NotificationFrame.AbsoluteSize.Y)

			TweenService:Create(NotificationFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
				Position = UDim2.new(1, 50, 0, 0)
			}):Play()
			TweenService:Create(NotificationFrame_Stroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
			TweenService:Create(Title, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
			TweenService:Create(Content, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
			TweenService:Create(ProgressBarParent, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
			TweenService:Create(ProgressBar, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
			if Icon and Icon.Parent then
				TweenService:Create(Icon, TweenInfo.new(0.2), {ImageTransparency = 1}):Play()
			end

			task.wait(0.25)

			local shrinkTween = TweenService:Create(NotificationParent, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Size = UDim2.new(1, 0, 0, 0)
			})
			shrinkTween:Play()
			shrinkTween.Completed:Connect(function()
				NotificationParent:Destroy()
			end)
		end

		local SizeInTween = TweenService:Create(NotificationParent, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, targetHeight) })

		local SlideInTween = TweenService:Create(NotificationFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { 
			Position = UDim2.new(0, 0, 0, 0) 
		})

		SlideInTween:Play()
		SizeInTween:Play()


		SizeInTween.Completed:Connect(function()
			NotificationParent.AutomaticSize = Enum.AutomaticSize.Y
			NotificationFrame.AutomaticSize = Enum.AutomaticSize.Y
	
			TweenService:Create(NotificationFrame_Stroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
			TweenService:Create(Title, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
			TweenService:Create(Content, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
			TweenService:Create(ProgressBarParent, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
			TweenService:Create(ProgressBar, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
			if Icon and Icon.Parent then
				TweenService:Create(Icon, TweenInfo.new(0.2), {ImageTransparency = 0}):Play()
			end

			task.wait(0.25)

			if (typeof(NotificationConfig.Time) == "string" and NotificationConfig.Time == "inf") or NotificationConfig.Time == 0 then
				ProgressBarParent:Destroy()
			else
				barTween:Play()

				task.delay(NotificationConfig.Time, function()
					if not isDismissed then
						DismissNotification()
					end
				end)
			end
		end)
		
		closeNotifButton.MouseButton1Click:Connect(DismissNotification)
	end)
end

local function getToastContainer()
	local container = TurtleUiLib:FindFirstChild("ToastContainer")
	if not container then
		container = Create("Frame", {
			Name = "ToastContainer",
			Parent = TurtleUiLib,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 18),
			Size = UDim2.new(0, 500, 1, -18),
			BackgroundTransparency = 1,
			ClipsDescendants = false,
			ZIndex = 99999999999999
		})

		Create("UIListLayout", {
			Parent = container,
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Padding = UDim.new(0, 6)
		})
	end
	return container
end

function library:Toast(ToastConfig)
	if type(ToastConfig) == "string" then
		options = { Text = ToastConfig }
	end

	local text = (ToastConfig.Title or ToastConfig.Text or ToastConfig.Name) or "Notification"
	local icon = (ToastConfig.Icon or ToastConfig.Image) or ""
	local duration = (ToastConfig.Time or ToastConfig.Duration) or 2.5
	local isDismissed = false

	local accentColors = {
		Info = Color3.fromRGB(52, 152, 219),
		Success = Color3.fromRGB(46, 204, 113),
		Warning = Color3.fromRGB(241, 196, 15),
		Error = Color3.fromRGB(231, 76, 60)
	}
	local accentColor = accentColors[ToastConfig.Type] or accentColors.Info

	local container = getToastContainer()

	local toastFrame = Create("Frame", {
		Parent = container,
		Size = UDim2.fromOffset(0, 0),
		AutomaticSize = Enum.AutomaticSize.None,
		BackgroundColor3 = library["Themes"]["Default"].WindowBackground,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = false
	})

	local toastbtnFrame = Create("TextButton", {
		Parent = toastFrame,
		Size = UDim2.fromScale(1, 1),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	})

	Create("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = toastFrame
	})

	local stroke = Create("UIStroke", {
		Color = accentColor,
		Thickness = 1,
		Transparency = 1,
		Parent = toastFrame
	})

	Create("UIPadding", {
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 14),
		Parent = toastbtnFrame
	})

	Create("UIListLayout", {
		Parent = toastbtnFrame,
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		Padding = UDim.new(0, 2)
	})

	local iconLabel = Create("ImageLabel", {
		AnchorPoint = Vector2.new(0,0.5),
		Position = UDim2.new(0,0,0.5,0),
		Size = UDim2.new(0, 16, 0, 16),
		BackgroundTransparency = 1,
		ImageColor3 = Color3.fromRGB(240, 240, 240),
		Name = "Icon",
		LayoutOrder = 1,
		Parent = toastbtnFrame
	})

	if icon and (icon ~= "" and icon ~= nil) then
		applyIcon(iconLabel, icon)
	else
		iconLabel:Destroy()
	end

	local textLabel = Create("TextLabel", {
		LayoutOrder = 2,
		Parent = toastbtnFrame,
		Size = UDim2.new(0, -16, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Text = text,
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = Color3.fromRGB(230, 230, 235),
		TextTransparency = 1
	})

	local function DismissToast()
		if isDismissed then return end
		isDismissed = true

		if not toastFrame or not toastFrame.Parent then return end

		local tweenOut = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		TweenService:Create(textLabel, tweenOut, { TextTransparency = 1 }):Play()
		
		TweenService:Create(stroke, tweenOut, { Transparency = 1 }):Play()
		if iconLabel then
			TweenService:Create(iconLabel, tweenOut, { ImageTransparency = 1 }):Play()
		end

		toastFrame.Size = UDim2.new(0,toastbtnFrame.AbsoluteSize.X,0,40)
		toastFrame.AutomaticSize = Enum.AutomaticSize.None
		task.wait(0.25)
		local fadeOut = TweenService:Create(toastFrame, tweenOut, { BackgroundTransparency = 1 })
		TweenService:Create(toastFrame, tweenOut, { Size = UDim2.new(0,0,0,0) }):Play()
		fadeOut:Play()

		fadeOut.Completed:Connect(function()
			toastFrame:Destroy()
		end)
	end

	local tweenIn = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	TweenService:Create(toastFrame, tweenIn, { BackgroundTransparency = 0 }):Play()
	TweenService:Create(stroke, tweenIn, { Transparency = 0.4 }):Play()
	if iconLabel then
		TweenService:Create(iconLabel, tweenIn, { ImageTransparency = 0 }):Play()
	end
	local SizeIn = TweenService:Create(toastFrame, tweenIn, { Size = UDim2.new(0,toastbtnFrame.AbsoluteSize.X,0,40) })
	SizeIn:Play()
	SizeIn.Completed:Connect(function()
		TweenService:Create(textLabel, tweenIn, { TextTransparency = 0 }):Play()
		toastFrame.AutomaticSize = Enum.AutomaticSize.X
		task.delay(duration, function()
			if not isDismissed then
				DismissToast()
			end
		end)
	end)
	
	toastbtnFrame.MouseButton1Click:Connect(DismissToast)
end

function library:Popup(config)
	config = config or {}
	config.Title = config.Title or "Confirmation"
	config.Content = config.Content or "Are you sure you want to proceed?"
	config.Mode = config.Mode or "Alert"
	config.AcceptText = config.AcceptText or (config.Mode == "YesNo" and "Yes" or "OK")
	config.CancelText = config.CancelText or "No"
	config.OnAccept = config.OnAccept or function() end
	config.OnCancel = config.OnCancel or function() end

	local overlay = Instance.new("TextButton") -- Memakai TextButton agar menghentikan input ke UI di belakangnya
	overlay.Name = "PopupOverlay"
	overlay.Parent = TurtleUiLib
	overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	overlay.BackgroundTransparency = 1
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.Text = ""
	overlay.AutoButtonColor = false
	overlay.ZIndex = 15 + zindex

	local popupFrame = Instance.new("Frame")
	local popupCorner = Instance.new("UICorner")
	local popupStroke = Instance.new("UIStroke")
	local titleLabel = Instance.new("TextLabel")
	local contentLabel = Instance.new("TextLabel")
	local buttonHolder = Instance.new("Frame")
	local buttonLayout = Instance.new("UIListLayout")

	popupFrame.Name = "PopupFrame"
	popupFrame.Parent = overlay
	popupFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	popupFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	popupFrame.Size = UDim2.new(0, 320, 0, 160)
	popupFrame.BackgroundColor3 = Color3.fromRGB(35, 39, 42)
	popupFrame.ClipsDescendants = true
	popupFrame.ZIndex = 15 + zindex

	popupCorner.CornerRadius = UDim.new(0, 8)
	popupCorner.Parent = popupFrame

	popupStroke.Color = Color3.fromRGB(60, 64, 72)
	popupStroke.Thickness = 1
	popupStroke.Parent = popupFrame

	titleLabel.Name = "Title"
	titleLabel.Parent = popupFrame
	titleLabel.BackgroundTransparency = 1
	titleLabel.Position = UDim2.new(0, 15, 0, 12)
	titleLabel.Size = UDim2.new(1, -30, 0, 20)
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.Text = config.Title
	titleLabel.TextColor3 = Color3.fromRGB(245, 246, 250)
	titleLabel.TextSize = 16
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left

	contentLabel.Name = "Content"
	contentLabel.Parent = popupFrame
	contentLabel.BackgroundTransparency = 1
	contentLabel.Position = UDim2.new(0, 15, 0, 38)
	contentLabel.Size = UDim2.new(1, -30, 0, 60)
	contentLabel.Font = Enum.Font.SourceSans
	contentLabel.Text = config.Content
	contentLabel.TextColor3 = Color3.fromRGB(189, 195, 199)
	contentLabel.TextSize = 14
	contentLabel.TextWrapped = true
	contentLabel.TextXAlignment = Enum.TextXAlignment.Left
	contentLabel.TextYAlignment = Enum.TextYAlignment.Top

	buttonHolder.Name = "ButtonHolder"
	buttonHolder.Parent = popupFrame
	buttonHolder.BackgroundTransparency = 1
	buttonHolder.Position = UDim2.new(0, 15, 1, -42)
	buttonHolder.Size = UDim2.new(1, -30, 0, 30)

	buttonLayout.Parent = buttonHolder
	buttonLayout.FillDirection = Enum.FillDirection.Horizontal
	buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	buttonLayout.Padding = UDim.new(0, 8)

	local function createButton(text, bgCol, callback)
		local btn = Instance.new("TextButton")
		local btnCorner = Instance.new("UICorner")
		local btnConn

		btn.Parent = buttonHolder
		btn.Size = UDim2.new(0, config.Mode == "YesNo" and 90 or 100, 1, 0)
		btn.BackgroundColor3 = bgCol
		btn.Font = Enum.Font.SourceSansBold
		btn.Text = text
		btn.TextColor3 = Color3.fromRGB(245, 246, 250)
		btn.TextSize = 14
		btn.ZIndex = 1002

		btnCorner.CornerRadius = UDim.new(0, 4)
		btnCorner.Parent = btn

		btnConn = btn.MouseButton1Click:Connect(function()
			local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			TweenService:Create(overlay, tweenInfo, {BackgroundTransparency = 1}):Play()
			local closeTween = TweenService:Create(popupFrame, tweenInfo, {Size = UDim2.new(0, 0, 0, 0)})
			closeTween:Play()
			
			closeTween.Completed:Connect(function()
				if btnConn then btnConn:Disconnect() end
				overlay:Destroy()
				if callback then
					execCallback(callback, config)
				end
			end)
		end)
	end

	if config.Mode == "YesNo" then
		createButton(config.CancelText, Color3.fromRGB(72, 84, 96), config.OnCancel)
		createButton(config.AcceptText, Color3.fromRGB(232, 65, 24), config.OnAccept)
	else
		createButton(config.AcceptText, Color3.fromRGB(9, 132, 227), config.OnAccept)
	end

	popupFrame.Size = UDim2.new(0, 320, 0, 0)
	local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	TweenService:Create(overlay, TweenInfo.new(0.2), {BackgroundTransparency = 0.6}):Play()
	TweenService:Create(popupFrame, tweenInfo, {Size = UDim2.new(0, 320, 0, 160)}):Play()
end



-- // Destroy Function \\ --
function library:Destroy()
	if library.GlobalAutoSave == true and library.OpenWindows then
		for i, windowData in ipairs(library.OpenWindows) do
			if windowData.FolderName then
				pcall(function()
					library:SaveConfig(windowData.FolderName, windowData.ConfigName)
					library:Toast({
						Title = "Wait, Saved " .. windowData.ConfigName .. " for Window " .. i .. "...",
						Icon = "cloud",
						Time = 3
					})
				end)
			end
		end
		task.wait(4)
	end

	if library.Connections then
		for _, conn in ipairs(library.Connections) do
			if typeof(conn) == "RBXScriptConnection" and conn.Connected then
				pcall(function() conn:Disconnect() end)
			end
		end
		table.clear(library.Connections)
	end

	if TurtleUiLib then
		pcall(function() TurtleUiLib:Destroy() end)
		TurtleUiLib = nil
	end

	if library.ThemeObjects then table.clear(library.ThemeObjects) end
	if library.Elements then table.clear(library.Elements) end
	if library.Flags then table.clear(library.Flags) end
	if library.OpenWindows then table.clear(library.OpenWindows) end
	if library.Themes then table.clear(library.Themes) end
	if IconPacks then table.clear(IconPacks) end

	if getgenv().TurtleLib == library then
		getgenv().TurtleLib = nil
	end
end

local function uiKeybind(key, ui)
	if keybindConnection then keybindConnection:Disconnect() end

	SafeConnect(uis.InputBegan, function(input, gp)
		if not gp and input.KeyCode == Enum.KeyCode[key] then
			ui.Visible = not ui.Visible
		end
	end)
end

local function createKeyWindow(keySettings, folderName, onSuccess, onCancel)
	keySettings = keySettings or {}
	local fileName = keySettings.FileName or "SavedKey.txt"
	local checkKeyBtn
	local closeKeyWindowBtn
	local getKeyBtn

	local overlay = Create("Frame", {
		Name = "KeyOverlay",
		Parent = TurtleUiLib,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(10, 10, 12),
		BackgroundTransparency = 0.2,
		ZIndex = 16 + zindex
	})

	local keyFrame = Create("Frame", {
		Name = "KeyFrame",
		Parent = overlay,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 340, 0, 210),
		BackgroundColor3 = library["Themes"]["Default"].WindowBackground,
		ZIndex = 2001
	})

	Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = keyFrame })
	Create("UIStroke", { Color = library["Themes"]["Default"].WindowBorder, Thickness = 1, Parent = keyFrame })

	local btnClose = Create("TextButton", {
		Name = "CloseButton",
		Parent = keyFrame,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 10),
		Size = UDim2.new(0, 24, 0, 24),
		BackgroundTransparency = 1,
		Font = Enum.Font.SourceSansBold,
		Text = "✕",
		TextColor3 = Color3.fromRGB(160, 165, 175),
		TextSize = 16,
		ZIndex = 2002
	})

	closeKeyWindowBtn = btnClose.MouseButton1Click:Connect(function()
		if checkKeyBtn then checkKeyBtn:Disconnect() end
		if closeKeyWindowBtn then closeKeyWindowBtn:Disconnect() end
		if getKeyBtn then getKeyBtn:Disconnect() end
		overlay:Destroy()
		if type(onCancel) == "function" then onCancel() end
	end)

	Create("TextLabel", {
		Parent = keyFrame,
		Position = UDim2.new(0, 15, 0, 12),
		Size = UDim2.new(1, -55, 0, 20),
		Font = Enum.Font.SourceSansBold,
		Text = keySettings.Title or "Key System",
		TextColor3 = Color3.fromRGB(245, 246, 250),
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1
	})

	Create("TextLabel", {
		Parent = keyFrame,
		Position = UDim2.new(0, 15, 0, 32),
		Size = UDim2.new(1, -30, 0, 18),
		Font = Enum.Font.SourceSans,
		Text = keySettings.Subtitle or "Enter key to access script",
		TextColor3 = Color3.fromRGB(160, 165, 175),
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1
	})

	local keyInput = Create("TextBox", {
		Parent = keyFrame,
		Position = UDim2.new(0, 15, 0, 60),
		Size = UDim2.new(1, -30, 0, 36),
		BackgroundColor3 = Color3.fromRGB(20, 22, 26),
		Font = Enum.Font.SourceSans,
		PlaceholderText = "Paste Key Here...",
		Text = "",
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 14,
		ClearTextOnFocus = false
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = keyInput })
	local inputStroke = Create("UIStroke", { Color = Color3.fromRGB(45, 48, 55), Parent = keyInput })

	Create("TextLabel", {
		Parent = keyFrame,
		Position = UDim2.new(0, 15, 0, 102),
		Size = UDim2.new(1, -30, 0, 18),
		Font = Enum.Font.SourceSansItalic,
		Text = keySettings.Note or "",
		TextColor3 = Color3.fromRGB(241, 196, 15),
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1
	})

	local btnCheck = Create("TextButton", {
		Parent = keyFrame,
		Position = UDim2.new(0, 15, 1, -48),
		Size = UDim2.new(0, 150, 0, 34),
		BackgroundColor3 = Color3.fromRGB(46, 204, 113),
		Font = Enum.Font.SourceSansBold,
		Text = "Submit Key",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 14
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btnCheck })

	local btnGetKey = Create("TextButton", {
		Parent = keyFrame,
		Position = UDim2.new(1, -165, 1, -48),
		Size = UDim2.new(0, 150, 0, 34),
		BackgroundColor3 = Color3.fromRGB(52, 152, 219),
		Font = Enum.Font.SourceSansBold,
		Text = "Get Key (Copy Link)",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 14
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btnGetKey })

	local isChecking = false

	checkKeyBtn = btnCheck.MouseButton1Click:Connect(function()
		if isChecking then return end
		isChecking = true
		btnCheck.Text = "Checking..."

		task.spawn(function()
			local input = keyInput.Text
			local isValid, reason = isKeyValid(input, keySettings)

			if isValid then
				if keySettings.SaveKey ~= false then
					saveKey(folderName, fileName, input)
				end
				if checkKeyBtn then checkKeyBtn:Disconnect() end
				if closeKeyWindowBtn then closeKeyWindowBtn:Disconnect() end
				if getKeyBtn then getKeyBtn:Disconnect() end
				overlay:Destroy()
				onSuccess()
			else
				inputStroke.Color = Color3.fromRGB(231, 76, 60)
				keyInput.Text = ""
				keyInput.PlaceholderText = (reason == "NETWORK_ERROR") and "Network Error! Try again..." or "Invalid Key! Try Again..."
				btnCheck.Text = "Submit Key"
				isChecking = false

				task.delay(2, function()
					if inputStroke then
						inputStroke.Color = Color3.fromRGB(45, 48, 55)
						keyInput.PlaceholderText = "Paste Key Here..."
					end
				end)
			end
		end)
	end)

	getKeyBtn = btnGetKey.MouseButton1Click:Connect(function()
		if keySettings.URL and setclipboard then
			setclipboard(keySettings.URL)
			btnGetKey.Text = "Copied to Clipboard!"
			task.delay(1.5, function()
				if btnGetKey then btnGetKey.Text = "Get Key (Copy Link)" end
			end)
		end
	end)
end

local function makeGroupUI(option, parentContainer)
	local groupFrame = Instance.new("Frame")
	groupFrame.Name = option.Title .. "_Group"
	groupFrame.Size = UDim2.new(1, 0, 0, 32)
	groupFrame.AutomaticSize = Enum.AutomaticSize.Y
	groupFrame.BackgroundColor3 = Color3.fromRGB(35, 39, 42)
	groupFrame.BorderColor3 = Color3.fromRGB(54, 57, 63)
	groupFrame.Parent = parentContainer

	local groupCorner = Instance.new("UICorner")
	groupCorner.CornerRadius = UDim.new(0, 6)
	groupCorner.Parent = groupFrame

	local groupStroke = Instance.new("UIStroke")
	groupStroke.Color = Color3.fromRGB(60, 64, 72)
	groupStroke.Thickness = 1
	groupStroke.Parent = groupFrame

	local headerGroup = Instance.new("TextButton")
	headerGroup.Name = "GroupHeader"
	headerGroup.Size = UDim2.new(1, 0, 0, 30)
	headerGroup.BackgroundTransparency = 1
	headerGroup.Text = ""
	headerGroup.Parent = groupFrame

	local headerGroupHolder = Create("Frame", {
		Name = "headerGroupHolder",
		Size = UDim2.new(1, -30, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Parent = headerGroup
	})

	local ListLayouttt = Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = headerGroupHolder
	})

	local Iccon = Create("ImageLabel", {
		LayoutOrder = 1,
		Size = UDim2.new(0, 24, 0, 24),
		BackgroundTransparency = 1,
		ImageColor3 = Color3.fromRGB(240, 240, 240),
		Name = "Icon",
		LayoutOrder = 1,
		ZIndex = 8 + zindex,
		Parent = headerGroupHolder
	})

	if option.Icon and (option.Icon ~= nil and option.Icon ~= "") then
		applyIcon(Iccon, option.Icon)
	else
		Iccon:Destroy()
	end

	local headerTitle = Instance.new("TextLabel")
	headerTitle.Name = "Title"
	headerTitle.LayoutOrder = 2
	headerTitle.Size = UDim2.new(1, 0, 1, 0)
	headerTitle.Position = UDim2.new(0, 10, 0, 0)
	headerTitle.BackgroundTransparency = 1
	headerTitle.Font = Enum.Font.SourceSansBold
	headerTitle.Text = tostring(option.Title)
	headerTitle.TextColor3 = Color3.fromRGB(245, 246, 250)
	headerTitle.TextSize = 15
	headerTitle.TextXAlignment = Enum.TextXAlignment.Left
	headerTitle.Parent = headerGroupHolder

	local contentHolder = Instance.new("Frame")
	contentHolder.Name = "Content"
	contentHolder.Size = UDim2.new(1, 0, 0, 0)
	contentHolder.Position = UDim2.new(0, 0, 0, 30)
	contentHolder.AutomaticSize = Enum.AutomaticSize.Y
	contentHolder.BackgroundTransparency = 1
	contentHolder.Visible = option.Open
	contentHolder.Parent = groupFrame

	local contentLayout = Instance.new("UIListLayout")
	contentLayout.FillDirection = Enum.FillDirection.Vertical
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	contentLayout.Padding = UDim.new(0, 5)
	contentLayout.Parent = contentHolder

	local contentPadding = Instance.new("UIPadding")
	contentPadding.PaddingLeft = UDim.new(0, 5)
	contentPadding.PaddingRight = UDim.new(0, 5)
	contentPadding.PaddingBottom = UDim.new(0, 5)
	contentPadding.Parent = contentHolder

	if option.Collapsible then
		local arrow = Instance.new("ImageLabel")
		arrow.Name = "Arrow"
		arrow.AnchorPoint = Vector2.new(1,0.5)
		arrow.Size = UDim2.new(0, 12, 0, 12)
		arrow.Position = UDim2.new(1, -5, 0.5, 0)
		arrow.BackgroundTransparency = 1
		arrow.Image = "rbxassetid://4918373417"
		arrow.ImageColor3 = Color3.fromRGB(140, 140, 140)
		arrow.ScaleType = Enum.ScaleType.Fit
		arrow.Rotation = option.Open and 90 or 0
		arrow.Parent = headerGroup

		SafeConnect(headerGroup.MouseButton1Click, function()
			option.Open = not option.Open
			contentHolder.Visible = option.Open
			arrow.Rotation = option.Open and 90 or 0
		end)
	end

	function option:SetTitle(newTitle)
		option.Title = newTitle
		headerTitle.Text = tostring(newTitle)
	end

	return option, contentHolder
end

local function makeColumnsUI(option, parentContainer)
	local columnsFrame = Instance.new("Frame")
	columnsFrame.Name = "ColumnsHolder"
	columnsFrame.Size = UDim2.new(1, 0, 0, 0)
	columnsFrame.AutomaticSize = Enum.AutomaticSize.Y
	columnsFrame.BackgroundTransparency = 1
	columnsFrame.Parent = parentContainer

	local colLayout = Instance.new("UIListLayout")
	colLayout.FillDirection = Enum.FillDirection.Horizontal
	colLayout.SortOrder = Enum.SortOrder.LayoutOrder
	colLayout.Padding = UDim.new(0, 5)
	colLayout.Parent = columnsFrame

	local columnWidth = (1 / option.Count)
	local colFrames = {}

	for i = 1, option.Count do
		local colFrame = Instance.new("Frame")
		colFrame.Name = "Column_" .. i
		colFrame.Size = UDim2.new(columnWidth, -(((option.Count - 1) * 6) / option.Count), 0, 0)
		colFrame.AutomaticSize = Enum.AutomaticSize.Y
		colFrame.BackgroundTransparency = 1
		colFrame.Parent = columnsFrame

		local listLayout = Instance.new("UIListLayout")
		listLayout.FillDirection = Enum.FillDirection.Vertical
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder
		listLayout.Padding = UDim.new(0, 6)
		listLayout.Parent = colFrame
		
		local contentPadding = Create("UIPadding", {
			PaddingLeft = UDim.new(0, 5),
			PaddingRight = UDim.new(0, 5),
			PaddingBottom = UDim.new(0, 5),
			Parent = colFrame
		})

		table.insert(colFrames, colFrame)
	end

	return colFrames
end

local function makeGridUI(option, parentContainer)
	local gridFrame = Instance.new("Frame")
	gridFrame.Name = "_GridHolder_"
	gridFrame.Size = UDim2.new(1, 0, 0, 0)
	gridFrame.AutomaticSize = Enum.AutomaticSize.Y
	gridFrame.BackgroundTransparency = 1
	gridFrame.Parent = parentContainer

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = option.CellSize
	gridLayout.CellPadding = option.CellPadding
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	gridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	gridLayout.Parent = gridFrame

	return option, gridFrame
end

function makeButton(option, parent)
	local btnFrameParent = Create("Frame", {
		Parent = parent,
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		ZIndex = 12 + zindex,
		Name = "_ButtonHolder_"
	})

	local btnFrame = Create("Frame", {
		Parent = btnFrameParent,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ZIndex = 12 + zindex,
		Name = ""
	})

	Create("UIPadding", {
		PaddingLeft = UDim.new(0, 5),
		PaddingRight = UDim.new(0, 5),
		Parent = btnFrame
	})

	local Button = Create("TextButton", {
		AnchorPoint = Vector2.new(0,0.5),
		Parent = btnFrame,
		BackgroundColor3 = Color3.fromRGB(53, 59, 72),
		BorderColor3 = Color3.fromRGB(113, 128, 147),
		Position = UDim2.new(0,0,0.5,0),
		Size = UDim2.new(1, 0, 0, 26),
		Selected = true,
		Font = Enum.Font.SourceSans,
		TextColor3 = Color3.fromRGB(245, 246, 250),
		TextSize = 16.000,
		TextStrokeTransparency = 123.000,
		TextWrapped = true,
		ZIndex = 12 + zindex,
		Text = ""
	})

	local ButtonTitle = Create("TextLabel", {
		AnchorPoint = Vector2.new(0,0.5),
		Name = "ButtonTitle",
		Parent = Button,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1.000,
		Position = UDim2.new(0, 5, 0.5, 0),
		Size = UDim2.new(1, -5, 1, 0),
		Font = Enum.Font.SourceSans,
		Text = option.Title,
		TextColor3 = Color3.fromRGB(245, 246, 250),
		TextSize = 16,
		TextWrapped = true,
		ZIndex = 12 + zindex,
		TextXAlignment = Enum.TextXAlignment.Left,
		Active = false
	})

	function option:SetTitle(newTitle)
		option.Title = newTitle
		ButtonTitle.Text = tostring(newTitle)
	end

	attachLockSystem(option, btnFrameParent, option)

	SafeConnect(Button.MouseButton1Click, function()
		if option:_isLocked() then
			return
		end
		execCallback(option.Callback, option)
	end)

	option.Instance = btnFrameParent
	return option
end

function makeLabel(option, parent)
	local labelFrameParent = Create("Frame", {
		Parent = parent,
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundTransparency = 1,
		ZIndex = 12 + zindex,
		Name = "_LabelHolder_"
	})

	local labelFrame = Create("Frame", {
		Parent = labelFrameParent,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ZIndex = 12 + zindex,
		Name = ""
	})

	local Label = Create("TextLabel", {
		AnchorPoint = Vector2.new(0,0.5),
		Name = "Label",
		Parent = labelFrame,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 1, 0),
		Font = Enum.Font.SourceSans,
		Text = option.Title,
		TextColor3 = Color3.fromRGB(245, 246, 250),
		TextSize = 16,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment[option.XAlignment],
		ZIndex = 12 + zindex,
		Active = false
	})

	function option:SetTitle(newTitle)
		option.Title = newTitle
		Label.Text = tostring(newTitle)
	end

	if typeof(option.Color) == "string" and option.Color == "Rainbow" then
		spawn(function()
			while Label.Parent do
				local hue = tick() % 5 / 5
				Label.TextColor3 = Color3.fromHSV(hue, 1, 1)
				task.wait()
			end
		end)
	elseif option.Color then
		Label.TextColor3 = option.Color
	end
	
	option.Instance = labelFrameParent
	return option
end

function makeToggle(option, parent)
	local togFrameParent = Create("Frame", {
		Parent = parent,
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		ZIndex = 12 + zindex,
		Name = "_ToggleHolder_"
	})

	local togFrame = Create("Frame", {
		Parent = togFrameParent,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ZIndex = 12 + zindex,
		Name = ""
	})

	Create("UIPadding", {
		PaddingLeft = UDim.new(0, 5),
		PaddingRight = UDim.new(0, 5),
		Parent = togFrame
	})

	local ToggleTitle = Create("TextLabel", {
		AnchorPoint = Vector2.new(0,0.5),
		Name = "ToggleTitle",
		Parent = togFrame,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0, 26),
		Font = Enum.Font.SourceSans,
		Text = option.Title,
		TextColor3 = Color3.fromRGB(245, 246, 250),
		TextSize = 16,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 12 + zindex,
		Active = false
	})

	local ToggleButton = Create("TextButton", {
		AnchorPoint = Vector2.new(1,0.5),
		Parent = togFrame,
		BackgroundTransparency = 1,
		Position = UDim2.new(1,0,0.5,0),
		Size = UDim2.new(0, 26, 0, 26),
		Name = "ToggleButton",
		ZIndex = 12 + zindex,
		Text = ""
	})

	local ToggleButton_stroke = Create("UIStroke", {
		Parent = ToggleButton,
		Thickness = 1,
		Color = Color3.fromRGB(113, 128, 147),
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Enabled = true
	})

	local ToggleFiller = Create("Frame", {
		Name = "ToggleFiller",
		AnchorPoint = Vector2.new(0.5,0.5),
		Parent = ToggleButton,
		BackgroundColor3 = Color3.fromRGB(68, 189, 50),
		BorderSizePixel = 0,
		Visible = option.Default,
		ZIndex = 12 + zindex,
		Size = UDim2.new(0.8, 0, 0.8, 0),
		Position = UDim2.fromScale(0.5,0.5)
	})

	attachLockSystem(option, togFrameParent, option)

	function option:SetValue(state)
		if option:_isLocked() then
			return
		end
		self.Default = state
		if self.Flag then
			library.Flags[self.Flag] = state
		end

		if not self.Loop and type(self.Callback) == "function" then
			execCallback(self.Callback, self, state)
		end

		if ToggleFiller then 
			ToggleFiller.Visible = state
		end
	end

	function option:SetTitle(newTitle)
		option.Title = newTitle
		ToggleTitle.Text = tostring(newTitle)
	end

	SafeConnect(ToggleButton.MouseButton1Click, function()
		option:SetValue(not option.Default)
	end)

	if typeof(option.Loop) == "boolean" and option.Loop == true then
		local lastTick = 0

		local conn = game:GetService("RunService").Heartbeat:Connect(function()
			if option.Default then
				if os.clock() - lastTick >= option.Delay then
					lastTick = os.clock()
					task.spawn(function()
						option:SetValue(option.Default)
					end)
				end
			else
				lastTick = 0
			end
		end)
		GiveSignal(conn)
	end
	
	if type(option.Default) == "boolean" and option.Default then
		task.delay(1, function()
			option:SetValue(true)
		end)
	end
	
	option.Instance = togFrameParent
	return option
end

function makeBox(option, parent)
	local boxFrameParent = Create("Frame", {
		Parent = parent,
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		Name = "_BoxHolder_",
		ZIndex = 12 + zindex
	})

	local boxFrame = Create("Frame", {
		Parent = boxFrameParent,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Name = "",
		ZIndex = 12 + zindex
	})

	Create("UIPadding", {
		PaddingLeft = UDim.new(0, 5),
		PaddingRight = UDim.new(0, 5),
		Parent = boxFrame
	})

	local TextBox = Create("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5),
		Parent = boxFrame,
		BackgroundColor3 = Color3.fromRGB(53, 59, 72),
		BorderColor3 = Color3.fromRGB(113, 128, 147),
		Size = UDim2.new(0, 95, 0, 26),
		Position = UDim2.new(1, 0, 0.5, 0),
		Font = Enum.Font.SourceSans,
		PlaceholderText = "...",
		Text = option.Default,
		ZIndex = 12 + zindex,
		ClearTextOnFocus = option.TextDisappear,
		TextColor3 = Color3.fromRGB(245, 246, 250),
		TextSize = 14,
		Name = "TextBox"
	})
	
	local BoxTitle = Create("TextLabel", {
		AnchorPoint = Vector2.new(0,0.5),
		Name = "BoxTitle",
		Parent = boxFrame,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 75, 0, 26),
		Font = Enum.Font.SourceSans,
		Text = option.Title,
		TextColor3 = Color3.fromRGB(245, 246, 250),
		TextSize = 16,
		TextWrapped = true,
		ZIndex = 12 + zindex,
		TextXAlignment = Enum.TextXAlignment.Left,
		Active = false
	})

	attachLockSystem(option, boxFrameParent, option)

	local LastText = ""
	
	function option:SetValue(value)
		if option:_isLocked() then
			return
		end
		self.Default = value
		if self.Flag then
			library.Flags[self.Flag] = value
		end

		if type(self.Callback) == "function" then
			execCallback(self.Callback, self, value, true)
		end
		
		if TextBox then
			TextBox.Text = value
		end
	end

	function option:SetTitle(newTitle)
		option.Title = newTitle
		BoxTitle.Text = tostring(newTitle)
	end

	SafeConnect(TextBox.FocusLost, function()
		option:SetValue(TextBox.Text)
	end)

	option.Instance = boxFrameParent
	return option
end

function makeSlider(option, parent)
	local offset = 70
	local defaultAlpha = (option.Default - option.Min) / (option.Max - option.Min)

	local sliFrameParent = Create("Frame", {
		Parent = parent,
		Size = UDim2.new(1, 0, 0, 60),
		BackgroundTransparency = 1,
		Name = "_SliderHolder_",
		ZIndex = 12 + zindex
	})

	local sliFrame = Create("Frame", {
		Parent = sliFrameParent,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Name = "",
		ZIndex = 12 + zindex
	})

	Create("UIPadding", {
		PaddingLeft = UDim.new(0, 5),
		PaddingRight = UDim.new(0, 5),
		Parent = sliFrame
	})

	local Slider = Instance.new("Frame")
	local SliderButton = Instance.new("Frame")
	local Description = Instance.new("TextLabel")
	local SilderFiller = Instance.new("Frame")
	local Current = Instance.new("TextBox")

	local function snapToIncrement(val)
		local stepped = math.round((val - option.Min) / option.Increment) * option.Increment + option.Min
		return math.clamp(stepped, option.Min, option.Max)
	end

	local function updateSliderFromValue(val)
		local snappedValue = snapToIncrement(val)
		local alpha = (snappedValue - option.Min) / (option.Max - option.Min)

		SliderButton.Position = UDim2.new(alpha, 0, 0.5, 0)
		SilderFiller.Size = UDim2.new(alpha, 0, 1, 0)
		Current.Text = tostring(snappedValue)
		return snappedValue
	end

	function SliderMovement(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isdragging = true
			local con
			con = stepped:Connect(function()
				if isdragging then
					local sliderWidth = Slider.AbsoluteSize.X - 20
					local mousePosX = mouse.X - Slider.AbsolutePosition.X - 20
					local alpha = math.clamp(mousePosX / sliderWidth, 0, 1)

					local rawValue = Lerp(option.Min, option.Max, alpha)
					local snappedValue = snapToIncrement(rawValue)

					local snappedAlpha = (snappedValue - option.Min) / (option.Max - option.Min)
					SliderButton.Position = UDim2.new(snappedAlpha, 0, 0.5, 0)
					SilderFiller.Size = UDim2.new(snappedAlpha, 0, 1, 0)
					Current.Text = tostring(snappedValue)
				else
					con:Disconnect()
				end
			end)
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					isdragging = false
				end
			end)
		end
	end

	function SliderEnd(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local val = tonumber(Current.Text) or option.Default
			option:SetValue(val)
		end
	end

	Slider.Name = "Slider"
	Slider.Parent = sliFrame
	Slider.Active = true
	Slider.BackgroundColor3 = Color3.fromRGB(47, 54, 64)
	Slider.BorderColor3 = Color3.fromRGB(113, 128, 147)
	Slider.Position = UDim2.new(0, 0, 0.5, 0)
	Slider.Size = UDim2.new(1, 0, 0, 6)
	Slider.ZIndex = 12 + zindex
	Slider.InputBegan:Connect(SliderMovement) 
	Slider.InputEnded:Connect(SliderEnd)

	SliderButton.AnchorPoint = Vector2.new(0.5, 0.5)
	SliderButton.Position = UDim2.new(defaultAlpha, 0, 0.5, 0)
	SliderButton.Name = "SliderButton"
	SliderButton.Active = true
	SliderButton.Parent = Slider
	SliderButton.BackgroundColor3 = Color3.fromRGB(53, 59, 72)
	SliderButton.BorderColor3 = Color3.fromRGB(113, 128, 147)
	SliderButton.Size = UDim2.new(0, 6, 0, 22)
	SliderButton.ZIndex = 13 + zindex
	SliderButton.InputBegan:Connect(SliderMovement)
	SliderButton.InputEnded:Connect(SliderEnd)    

	Current.AnchorPoint = Vector2.new(1,0)
	Current.Name = "Current"
	Current.Parent = sliFrame
	Current.BackgroundColor3 = Color3.fromRGB(35, 40, 48)
	Current.BackgroundTransparency = 1
	Current.BorderColor3 = Color3.fromRGB(113, 128, 147)
	Current.Position = UDim2.new(1, 0, 0, 0)
	Current.Size = UDim2.new(0, 45, 0, 20)
	Current.Font = Enum.Font.SourceSans
	Current.Text = tostring(option.Default)
	Current.TextColor3 = Color3.fromRGB(220, 221, 225)
	Current.TextSize = 14
	Current.ZIndex = 12 + zindex
	Current.ClearTextOnFocus = false

	SafeConnect(Current.FocusLost, function(enterPressed)
		local inputNum = tonumber(Current.Text)
		if inputNum then
			local finalVal = updateSliderFromValue(inputNum)
			option:SetValue(finalVal)
		else
			Current.Text = tostring(snapToIncrement(Lerp(option.Min, option.Max, SliderButton.Position.X.Scale)))
		end
	end)

	Description.AnchorPoint = Vector2.new(0, 0)
	Description.Name = "Description"
	Description.Parent = sliFrame
	Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Description.BackgroundTransparency = 1.000
	Description.Position = UDim2.new(0, 0, 0, 0)
	Description.Size = UDim2.new(0, 180, 0, 21)
	Description.Font = Enum.Font.SourceSans
	Description.Text = option.Title
	Description.TextColor3 = Color3.fromRGB(245, 246, 250)
	Description.TextSize = 16
	Description.TextXAlignment = Enum.TextXAlignment.Left
	Description.ZIndex = 12 + zindex

	SilderFiller.Name = "SilderFiller"
	SilderFiller.Parent = Slider
	SilderFiller.BackgroundColor3 = Color3.fromRGB(76, 209, 55)
	SilderFiller.Size = UDim2.new(defaultAlpha, 0, 1, 0)
	SilderFiller.ZIndex = 12 + zindex

	attachLockSystem(option, sliFrameParent, option)

	function option:SetValue(value)
		if option:_isLocked() then
			return
		end
		self.Default = value
		if self.Flag then
			library.Flags[self.Flag] = value
		end

		updateSliderFromValue(value)
		if type(self.Callback) == "function" then
			execCallback(self.Callback, self, value)
		end
	end

	function option:SetTitle(newTitle)
		Description.Text = tostring(newTitle)
	end
	
	option.Instance = sliFrameParent
	return option
end

-- // Dropdown Function \\ --
local function makeDropdown(option, parentContainer)
	local contentParent = parentContainer
	local selectedItems = {}
	local selectedSingle = nil
	local itemButtons = {}
	local itemConns = {}

	if option.MultiSelect and type(option.Default) == "table" then
		for _, val in ipairs(option.Default) do
			selectedItems[val] = true
		end
	elseif not option.MultiSelect and type(option.Default) == "string" then
		selectedSingle = option.Default
	end

	local droFrameParent = Create("Frame", {
		Parent = parentContainer,
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		Name = "_DropdownHolder_",
		AutomaticSize = Enum.AutomaticSize.None,
		ZIndex = 12 + zindex
	})

	local droFrame = Create("Frame", {
		Parent = droFrameParent,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Name = "",
		AutomaticSize = Enum.AutomaticSize.None,
		ZIndex = 12 + zindex
	})

	local droLayout = Instance.new("UIListLayout")
	droLayout.FillDirection = Enum.FillDirection.Vertical
	droLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	droLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	droLayout.Padding = UDim.new(0, 5)
	droLayout.SortOrder = Enum.SortOrder.LayoutOrder
	droLayout.Parent = droFrame

	Create("UIPadding", {
		PaddingLeft = UDim.new(0, 5),
		PaddingRight = UDim.new(0, 5),
		Parent = droFrame
	})

	local Dropdown = Instance.new("TextButton")
	Dropdown.Name = "Dropdown"
	Dropdown.Size = UDim2.new(1, 0, 0, 26)
	Dropdown.BackgroundColor3 = Color3.fromRGB(53, 59, 72)
	Dropdown.BorderColor3 = Color3.fromRGB(113, 128, 147)
	Dropdown.Text = ""
	Dropdown.Font = Enum.Font.SourceSans
	Dropdown.ZIndex = 12 + zindex
	Dropdown.Parent = droFrame

	local DroTitle = Instance.new("TextLabel")
	DroTitle.Name = "Title"
	DroTitle.Size = UDim2.new(1, -30, 1, 0)
	DroTitle.Position = UDim2.new(0, 5, 0, 0)
	DroTitle.BackgroundTransparency = 1
	DroTitle.Font = Enum.Font.SourceSans
	DroTitle.Text = tostring(option.Title)
	DroTitle.TextColor3 = Color3.fromRGB(245, 246, 250)
	DroTitle.TextSize = 16
	DroTitle.TextXAlignment = Enum.TextXAlignment.Left
	DroTitle.TextTruncate = Enum.TextTruncate.AtEnd
	DroTitle.ZIndex = 12 + zindex
	DroTitle.Parent = Dropdown

	local DownSign = Instance.new("ImageLabel")
	DownSign.Name = "DownSign"
	DownSign.Size = UDim2.new(0, 8, 0, 8)
	DownSign.Position = UDim2.new(1, -5, 0.5, 0)
	DownSign.AnchorPoint = Vector2.new(1, 0.5)
	DownSign.BackgroundTransparency = 1
	DownSign.Image = "rbxassetid://4918373417"
	DownSign.ImageColor3 = Color3.fromRGB(140, 140, 140)
	DownSign.ScaleType = Enum.ScaleType.Fit
	DownSign.Rotation = 0
	--DownSign.ImageColor3 = Color3.fromRGB(220, 221, 225)
	DownSign.ZIndex = 12 + zindex
	DownSign.Parent = Dropdown

	local dragDropFrame = nil
	if option.Floating then
		dragDropFrame = Instance.new("Frame")
		dragDropFrame.AnchorPoint = Vector2.new(0,0)
		dragDropFrame.Name = "FloatingDropdown"
		dragDropFrame.Size = UDim2.new(0, 192, 0, 33)
		dragDropFrame.BackgroundColor3 = Color3.fromRGB(53, 59, 72)
		dragDropFrame.BorderColor3 = Color3.fromRGB(53, 59, 72)
		dragDropFrame.Active = true
		dragDropFrame.ZIndex = 15 + zindex
		dragDropFrame.Visible = false
		dragDropFrame.Parent = TurtleUiLib

		local dragDroTitle = Instance.new("TextLabel")
		dragDroTitle.Name = "DragTitle"
		dragDroTitle.Size = UDim2.new(1, -30, 1, 0)
		dragDroTitle.Position = UDim2.new(0, 5, 0, 0)
		dragDroTitle.BackgroundTransparency = 1
		dragDroTitle.Font = Enum.Font.SourceSans
		dragDroTitle.Text = tostring(option.Title)
		dragDroTitle.TextColor3 = Color3.fromRGB(245, 246, 250)
		dragDroTitle.TextSize = 14
		dragDroTitle.TextXAlignment = Enum.TextXAlignment.Left
		dragDroTitle.ZIndex = 15 + zindex
		dragDroTitle.Parent = dragDropFrame

		if MakeDraggable then
			MakeDraggable(dragDropFrame, dragDropFrame)
		end
	end

	local DropdownFrame = Instance.new("ScrollingFrame")
	DropdownFrame.Name = "DropdownFrame"
	DropdownFrame.Size = UDim2.new(1, 0, 0, 0)
	DropdownFrame.Position = option.Floating and UDim2.new(0, 0, 1, 0) or UDim2.new(0, 0, 0, 26)
	DropdownFrame.BackgroundColor3 = Color3.fromRGB(53, 59, 72)
	DropdownFrame.BorderColor3 = Color3.fromRGB(53, 59, 72)
	DropdownFrame.ScrollBarThickness = 2
	DropdownFrame.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left
	DropdownFrame.ScrollingDirection = Enum.ScrollingDirection.Y
	DropdownFrame.ScrollBarImageColor3 = Color3.fromRGB(220, 221, 225)
	DropdownFrame.Visible = false
	DropdownFrame.ZIndex = 13 + zindex
	DropdownFrame.Parent = option.Floating and dragDropFrame or droFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Vertical
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 3)
	listLayout.Parent = DropdownFrame

	local listPaddingLayout = Instance.new("UIPadding")
	listPaddingLayout.PaddingBottom = UDim.new(0, 5)
	listPaddingLayout.PaddingTop = UDim.new(0, 5)
	listPaddingLayout.PaddingRight = UDim.new(0, 5)
	listPaddingLayout.PaddingLeft = UDim.new(0, 5)
	listPaddingLayout.Parent = DropdownFrame

	local function updateDropdownText()
		if option.MultiSelect then
			local chosenList = {}
			for name, isSelected in pairs(selectedItems) do
				if isSelected then
					table.insert(chosenList, name)
				end
			end

			if #chosenList > 0 then
				DroTitle.Text = table.concat(chosenList, ", ")
			else
				DroTitle.Text = tostring(option.Title)
			end
		else
			if selectedSingle then
				DroTitle.Text = selectedSingle
			else
				DroTitle.Text = tostring(option.Title)
			end
		end
	end

	local function updateDropdownSize()
		local contentHeight = listLayout.AbsoluteContentSize.Y + 10
		DropdownFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
		DropdownFrame.Size = UDim2.new(1, 0, 0, math.min(contentHeight, 100))
	end

	listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateDropdownSize)

	function option:Close()
		TweenService:Create(DownSign, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Rotation = 0}):Play()
		if dragDropFrame then
			dragDropFrame.Visible = false
		end
		DropdownFrame.Visible = false
		droFrame.AutomaticSize = Enum.AutomaticSize.None
		droFrameParent.AutomaticSize = Enum.AutomaticSize.None
		droLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	end

	function option:Open()
		for _, otherDrop in ipairs(dropdowns) do
			if otherDrop ~= option and otherDrop.Close then
				otherDrop:Close()
			end
		end

		TweenService:Create(DownSign, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Rotation = 90}):Play()

		if option.Floating and dragDropFrame then
			dragDropFrame.Visible = true
			DropdownFrame.Visible = true

			task.defer(function()
				if not Dropdown or not dragDropFrame then return end

				local dropAbs = Dropdown.AbsolutePosition
				local parentAbs = dragDropFrame.Parent.AbsolutePosition

				local targetX = dropAbs.X - parentAbs.X
				local targetY = dropAbs.Y - parentAbs.Y

				dragDropFrame.Position = UDim2.fromOffset(targetX, targetY)
			end)
		else
			droFrame.AutomaticSize = Enum.AutomaticSize.Y
			droFrameParent.AutomaticSize = Enum.AutomaticSize.Y
			droLayout.VerticalAlignment = Enum.VerticalAlignment.Top

			DropdownFrame.Position = UDim2.new(0, 0, 0, 26)
			DropdownFrame.Visible = true
		end
	end

	local function createItemButton(name)
		local name = tostring(name or "")
		local itemBtn = Instance.new("TextButton")
		itemBtn.Name = "Button_" .. name
		itemBtn.Size = UDim2.new(0, 180, 0, 26)
		itemBtn.Position = UDim2.new(0, 6, 0, 0)
		itemBtn.BackgroundColor3 = Color3.fromRGB(53, 59, 72)
		itemBtn.Font = Enum.Font.SourceSans
		itemBtn.Text = name
		itemBtn.TextColor3 = Color3.fromRGB(245, 246, 250)
		itemBtn.TextSize = 14
		itemBtn.TextTruncate = Enum.TextTruncate.AtEnd
		itemBtn.ZIndex = 13 + zindex
		itemBtn.Parent = DropdownFrame

		local btnStroke = Instance.new("UIStroke")
		btnStroke.Color = Color3.fromRGB(113, 128, 147)
		btnStroke.Thickness = 1
		btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		btnStroke.Parent = itemBtn

		itemButtons[name] = itemBtn

		if (option.MultiSelect and selectedItems[name]) or (not option.MultiSelect and selectedSingle == name) then
			itemBtn.BackgroundColor3 = library.Themes[library.SelectedTheme].DropdownOptionSelect
		end

		local conne = itemBtn.MouseButton1Click:Connect(function()
			if option.MultiSelect then
				selectedItems[name] = not selectedItems[name]
				itemBtn.BackgroundColor3 = selectedItems[name] and library.Themes[library.SelectedTheme].DropdownOptionSelect or Color3.fromRGB(53, 59, 72)

				updateDropdownText()

				local activeTable = {}
				for itemName, isSelected in pairs(selectedItems) do
					if isSelected then
						table.insert(activeTable, itemName)
					end
				end

				option:SetValue(activeTable)
			else
				if selectedSingle == name then
					selectedSingle = nil
					itemBtn.BackgroundColor3 = Color3.fromRGB(53, 59, 72)
					updateDropdownText()

					option:SetValue(nil)
				else
					if selectedSingle and itemButtons[selectedSingle] then
						itemButtons[selectedSingle].BackgroundColor3 = Color3.fromRGB(53, 59, 72)
					end

					selectedSingle = name
					itemBtn.BackgroundColor3 = library.Themes[library.SelectedTheme].DropdownOptionSelect
					updateDropdownText()

					option:SetValue(name)
				end
			end
		end)
		itemConns[name] = conne
	end

	local function addPlaceholder(labelText)
		local PlaceholderLabel = Instance.new("TextLabel")
		PlaceholderLabel.Name = "Placeholder"
		PlaceholderLabel.Size = UDim2.new(0, 180, 0, 26)
		PlaceholderLabel.Position = UDim2.new(0, 6, 0, 0)
		PlaceholderLabel.BackgroundTransparency = 1
		PlaceholderLabel.Font = Enum.Font.SourceSansItalic
		PlaceholderLabel.TextColor3 = library.Themes[library.SelectedTheme].DropdownOptionTextHolder
		PlaceholderLabel.TextSize = 14
		PlaceholderLabel.Text = tostring(labelText)
		PlaceholderLabel.TextXAlignment = Enum.TextXAlignment.Left
		PlaceholderLabel.ZIndex = 13 + zindex
		PlaceholderLabel.Parent = DropdownFrame
	end

	attachLockSystem(option, droFrameParent, option)

	function option:Refresh(newItems)
		option.Items = newItems or {}
		
		for _, conn in ipairs(itemConns) do
			if conn.Connected then conn:Disconnect() end
		end
		table.clear(itemConns)
		table.clear(itemButtons)

		for _, child in ipairs(DropdownFrame:GetChildren()) do
			if child:IsA("TextButton") or child:IsA("TextLabel") then
				child:Destroy()
			end
		end

		for _, item in ipairs(option.Items) do
			if typeof(item) == "string" then
				createItemButton(item)
			elseif typeof(item) == "table" and item.PlaceHolder then
				addPlaceholder(item.PlaceHolder)
			end
		end
		updateDropdownSize()
	end

	function option:SetValue(val)
		if option:_isLocked() then
			return
		end

		option.Default = val

		if option.Flag then
			library.Flags[option.Flag] = val
		end

		if option.MultiSelect then
			if type(val) ~= "table" then
				val = { tostring(val) }
			end

			table.clear(selectedItems)
			for k, v in pairs(val) do
				if type(k) == "number" then
					selectedItems[v] = true
				elseif v == true then
					selectedItems[k] = true
				end
			end
		else
			if type(val) == "table" then
				selectedSingle = val[1] or ""
			else
				selectedSingle = val
			end
		end

		for btnName, btnObj in pairs(itemButtons) do
			if (option.MultiSelect and selectedItems[btnName]) or (not option.MultiSelect and selectedSingle == btnName) then
				btnObj.BackgroundColor3 = Color3.fromRGB(76, 79, 92)
			else
				btnObj.BackgroundColor3 = Color3.fromRGB(53, 59, 72)
			end
		end

		updateDropdownText()

		if type(option.Callback) == "function" then
			execCallback(option.Callback, option, val)
		end
	end

	function option:SetTitle(newTitle)
		option.Title = newTitle
		DroTitle.Text = tostring(newTitle)
	end

	option:Refresh(option.Items)
	updateDropdownText()

	table.insert(dropdowns, option)

	SafeConnect(Dropdown.MouseButton1Click, function()
		if DropdownFrame.Visible or (dragDropFrame and dragDropFrame.Visible) then
			option:Close()
		else
			option:Open()
		end
	end)

	option.Instance = droFrameParent
	return option
end

local function makeColorPicker(option, parentContainer)
	local colFrameParent = Create("Frame", {
		Parent = parentContainer,
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		Name = "_ColorPickerHolder_",
		AutomaticSize = Enum.AutomaticSize.None,
		ZIndex = 12 + zindex
	})

	local colFrame = Create("Frame", {
		Parent = colFrameParent,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Name = "",
		AutomaticSize = Enum.AutomaticSize.None,
		ZIndex = 12 + zindex
	})

	Create("UIPadding", {
		PaddingLeft = UDim.new(0, 5),
		PaddingRight = UDim.new(0, 5),
		Parent = colFrame
	})

	local colLayout = Instance.new("UIListLayout")
	colLayout.FillDirection = Enum.FillDirection.Vertical
	colLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	colLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	colLayout.Padding = UDim.new(0, 5)
	colLayout.SortOrder = Enum.SortOrder.LayoutOrder
	colLayout.Parent = colFrame

	local ColorPicker = Instance.new("TextButton")
	local PickerCorner = Instance.new("UICorner")
	local PickerDescription = Instance.new("TextLabel")
	local ColorPickerFrame = Instance.new("Frame")
	local ToggleRGB = Instance.new("TextButton")
	local ToggleFiller_2 = Instance.new("Frame")
	local TextLabel = Instance.new("TextLabel")
	local Canvas = Instance.new("Frame")
	local CanvasGradient = Instance.new("UIGradient")
	local Cursor = Instance.new("ImageLabel")
	local Color = Instance.new("Frame")
	local ColorGradient = Instance.new("UIGradient")
	local ColorSlider = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local ColorCorner = Instance.new("UICorner")
	local BlackOverlay = Instance.new("ImageLabel")

	ColorPicker.AnchorPoint = Vector2.new(1, 0.5)
	ColorPicker.Name = "ColorPicker"
	ColorPicker.Parent = PickerDescription
	ColorPicker.Position = UDim2.new(1, 0, 0.5, 0)
	ColorPicker.Size = UDim2.new(0, 57, 1, 0)
	ColorPicker.Font = Enum.Font.SourceSans
	ColorPicker.Text = ""
	ColorPicker.TextColor3 = Color3.fromRGB(0, 0, 0)
	ColorPicker.TextSize = 14
	ColorPicker.ZIndex = 2 + (zindex or 0)

	PickerCorner.Parent = ColorPicker
	PickerCorner.Name = "PickerCorner"
	PickerCorner.CornerRadius = UDim.new(0, 2)

	PickerDescription.AnchorPoint = Vector2.new(0, 0.5)
	PickerDescription.Name = "PickerTitle"
	PickerDescription.Parent = colFrame
	PickerDescription.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	PickerDescription.BackgroundTransparency = 1.000
	PickerDescription.Position = UDim2.new(0, 0, 0.5, 0)
	PickerDescription.Size = UDim2.new(1, 0, 0, 26)
	PickerDescription.Font = Enum.Font.SourceSans
	PickerDescription.Text = option.Title
	PickerDescription.TextColor3 = Color3.fromRGB(245, 246, 250)
	PickerDescription.TextSize = 16
	PickerDescription.TextXAlignment = Enum.TextXAlignment.Left
	PickerDescription.ZIndex = 2 + (zindex or 0)

	local dragColFrame = nil
	if option.Floating then
		dragColFrame = Instance.new("Frame")
		dragColFrame.Name = "FloatingColorPicker"
		dragColFrame.Parent = TurtleUiLib
		dragColFrame.Size = UDim2.new(0, 192, 0, 33)
		dragColFrame.BackgroundColor3 = Color3.fromRGB(53, 59, 72)
		dragColFrame.BorderColor3 = Color3.fromRGB(53, 59, 72)
		dragColFrame.Active = true
		dragColFrame.ZIndex = 10 + (zindex or 0)
		dragColFrame.Visible = false

		local dragColTitle = Instance.new("TextLabel")
		dragColTitle.Name = "DragTitle"
		dragColTitle.Parent = dragColFrame
		dragColTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		dragColTitle.BackgroundTransparency = 1.000
		dragColTitle.Position = UDim2.new(0, 5, 0, 0)
		dragColTitle.Size = UDim2.new(1, -30, 1, 0)
		dragColTitle.Font = Enum.Font.SourceSans
		dragColTitle.Text = tostring(option.Title)
		dragColTitle.TextColor3 = Color3.fromRGB(245, 246, 250)
		dragColTitle.TextSize = 14
		dragColTitle.ZIndex = 10 + (zindex or 0)
		dragColTitle.TextWrapped = false
		dragColTitle.Active = false
		dragColTitle.TextXAlignment = Enum.TextXAlignment.Left

		local colPaddingLayout = Instance.new("UIPadding")
		colPaddingLayout.Parent = ColorPickerFrame
		colPaddingLayout.PaddingBottom = UDim.new(0, 5)
		colPaddingLayout.PaddingTop = UDim.new(0, 5)
		colPaddingLayout.PaddingRight = UDim.new(0, 5)
		colPaddingLayout.PaddingLeft = UDim.new(0, 5)

		if MakeDraggable then
			MakeDraggable(dragColFrame, dragColFrame)
		end
	end

	ColorPickerFrame.Name = "ColorPickerFrame"
	ColorPickerFrame.Parent = option.Floating and dragColFrame or colFrame
	ColorPickerFrame.BackgroundColor3 = Color3.fromRGB(47, 54, 64)
	ColorPickerFrame.BorderColor3 = Color3.fromRGB(47, 54, 64)
	ColorPickerFrame.Position = option.Floating and UDim2.new(0, 0, 1, 0) or UDim2.new(0, 0, 0, 31)
	ColorPickerFrame.Size = UDim2.new(1, 0, 0, 155)
	ColorPickerFrame.ZIndex = 10 + (zindex or 0)
	ColorPickerFrame.Active = true
	ColorPickerFrame.Visible = false

	ToggleRGB.AnchorPoint = Vector2.new(1, 0)
	ToggleRGB.Name = "ToggleRGB"
	ToggleRGB.Parent = ColorPickerFrame
	ToggleRGB.BackgroundColor3 = Color3.fromRGB(47, 54, 64)
	ToggleRGB.BorderColor3 = Color3.fromRGB(113, 128, 147)
	ToggleRGB.Position = UDim2.new(1, 0, 0, 112)
	ToggleRGB.Size = UDim2.new(0, 22, 0, 22)
	ToggleRGB.Font = Enum.Font.SourceSans
	ToggleRGB.Text = ""
	ToggleRGB.TextColor3 = Color3.fromRGB(0, 0, 0)
	ToggleRGB.TextSize = 14
	ToggleRGB.ZIndex = 10 + (zindex or 0)

	ToggleFiller_2.Name = "ToggleFiller"
	ToggleFiller_2.Parent = ToggleRGB
	ToggleFiller_2.BackgroundColor3 = Color3.fromRGB(76, 209, 55)
	ToggleFiller_2.BorderColor3 = Color3.fromRGB(47, 54, 64)
	ToggleFiller_2.Position = UDim2.new(0, 5, 0, 5)
	ToggleFiller_2.Size = UDim2.new(0, 12, 0, 12)
	ToggleFiller_2.ZIndex = 10 + (zindex or 0)
	ToggleFiller_2.Visible = false

	TextLabel.Parent = ColorPickerFrame
	TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.BackgroundTransparency = 1.000
	TextLabel.Position = UDim2.new(0, 0, 0, 112)
	TextLabel.Size = UDim2.new(0, 106, 0, 22)
	TextLabel.Font = Enum.Font.SourceSans
	TextLabel.Text = "Rainbow"
	TextLabel.TextColor3 = Color3.fromRGB(245, 246, 250)
	TextLabel.TextSize = 16
	TextLabel.TextXAlignment = Enum.TextXAlignment.Left
	TextLabel.ZIndex = 10 + (zindex or 0)

	Canvas.Name = "Canvas"
	Canvas.Parent = ColorPickerFrame
	Canvas.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Canvas.Position = UDim2.new(0, 0, 0, 0)
	Canvas.Size = UDim2.new(1, -32, 0, 80)
	Canvas.Active = true
	Canvas.ZIndex = 10 + (zindex or 0)

	CanvasGradient.Name = "CanvasGradient"
	CanvasGradient.Parent = Canvas

	BlackOverlay.Name = "BlackOverlay"
	BlackOverlay.Parent = Canvas
	BlackOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	BlackOverlay.BackgroundTransparency = 1.000
	BlackOverlay.Size = UDim2.new(1, 0, 1, 0)
	BlackOverlay.Image = "rbxassetid://5107152095"
	BlackOverlay.ZIndex = 10 + (zindex or 0)

	UICorner.Parent = Canvas
	UICorner.Name = "UICorner"
	UICorner.CornerRadius = UDim.new(0, 2)

	Cursor.Name = "Cursor"
	Cursor.Parent = Canvas
	Cursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Cursor.BackgroundTransparency = 1.000
	Cursor.Size = UDim2.new(0, 8, 0, 8)
	Cursor.Image = "rbxassetid://5100115962"
	Cursor.ZIndex = 10 + (zindex or 0)

	Color.Name = "Color"
	Color.Parent = ColorPickerFrame
	Color.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Color.Position = UDim2.new(1, -25, 0, 0)
	Color.Size = UDim2.new(0, 25, 0, 80)
	Color.BorderMode = Enum.BorderMode.Inset
	Color.Active = true
	Color.ZIndex = 10 + (zindex or 0)

	ColorGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
		ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),
		ColorSequenceKeypoint.new(0.82, Color3.fromRGB(255, 0, 255)),
		ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
	})
	ColorGradient.Name = "ColorGradient"
	ColorGradient.Rotation = 90
	ColorGradient.Parent = Color

	ColorCorner.Parent = Color
	ColorCorner.Name = "ColorCorner"
	ColorCorner.CornerRadius = UDim.new(0, 2)

	ColorSlider.Name = "ColorSlider"
	ColorSlider.Parent = Color
	ColorSlider.BackgroundColor3 = Color3.fromRGB(245, 246, 250)
	ColorSlider.BorderColor3 = Color3.fromRGB(245, 246, 250)
	ColorSlider.Position = UDim2.new(0, -1, 0, 0)
	ColorSlider.Size = UDim2.new(1, 2, 0, 3)
	ColorSlider.Active = true
	ColorSlider.ZIndex = 10 + (zindex or 0)

	local defaultColor = (type(option.Default) == "userdata" and option.Default) or Color3.fromRGB(255, 0, 0)
	local initH, initS, initV = Color3.toHSV(defaultColor)
	local hue, sat, brightness = initH, initS, initV

	CanvasGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), 
		ColorSequenceKeypoint.new(1.00, Color3.fromHSV(hue, 1, 1))
	}
	Cursor.Position = UDim2.new(sat, -4, 1 - brightness, -4)
	ColorSlider.Position = UDim2.new(0, -1, hue, 0)

	Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
	ColorSlider.AnchorPoint = Vector2.new(0, 0.5)

	local function createRGBBox(name, xOffset, defaultText)
		local box = Instance.new("TextBox")
		box.Name = name
		box.Parent = ColorPickerFrame
		box.BackgroundColor3 = Color3.fromRGB(53, 59, 72)
		box.Position = UDim2.new(0, xOffset, 0, 85)
		box.Size = UDim2.new(0, 32, 0, 22)
		box.Font = Enum.Font.SourceSans
		box.Text = defaultText
		box.TextColor3 = Color3.fromRGB(245, 246, 250)
		box.TextSize = 13
		box.ZIndex = 10 + (zindex or 0)
		box.ClearTextOnFocus = false

		local stroke = Instance.new("UIStroke")
		stroke.Parent = box
		stroke.Color = Color3.fromRGB(113, 128, 147)
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		return box
	end

	local RInput = createRGBBox("RInput", 0, "255")
	local GInput = createRGBBox("GInput", 36, "0")
	local BInput = createRGBBox("BInput", 72, "0")

	local function setRGBText(color)
		RInput.Text = tostring(math.round(color.R * 255))
		GInput.Text = tostring(math.round(color.G * 255))
		BInput.Text = tostring(math.round(color.B * 255))
	end

	local defaultColor = option.Default or Color3.fromRGB(255, 0, 0)
	local hue, sat, brightness = Color3.toHSV(defaultColor)

	ColorPicker.BackgroundColor3 = defaultColor
	setRGBText(defaultColor)

	local con = nil
	local stepService = game:GetService("RunService").RenderStepped

	local function stopRainbow()
		if con then
			con:Disconnect()
			con = nil
		end
	end

	local function updatePicker(h, s, v, skipRainbowStop, triggerCallback)
		if option:_isLocked() then return end

		if not skipRainbowStop then
			ToggleFiller_2.Visible = false
			stopRainbow()
		end

		hue = h
		sat = s
		brightness = v

		local color = Color3.fromHSV(hue, sat, brightness)

		option.Value = color
		if option.Flag and library and library.Flags then
			library.Flags[option.Flag] = color
		end

		CanvasGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1.00, Color3.fromHSV(hue, 1, 1))
		}

		Cursor.Position = UDim2.new(sat, 0, 1 - brightness, 0)
		ColorSlider.Position = UDim2.new(0, -1, hue, 0)

		ColorPicker.BackgroundColor3 = color
		setRGBText(color)

		if triggerCallback ~= false then
			execCallback(option.Callback, option, color)
		end
	end

	local function startRainbow()
		stopRainbow()
		con = stepService:Connect(function()
			if ToggleFiller_2.Visible then
				local hue2 = (tick() % 5) / 5
				updatePicker(hue2, 1, 1, true, true)
			else
				stopRainbow()
			end
		end)
	end

	if option.Default and type(option.Default) == "boolean" then
		ToggleFiller_2.Visible = true
		startRainbow()
	end

	SafeConnect(Canvas.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if activeInteraction ~= nil then return end
			activeInteraction = Canvas

			local moveConn, releaseConn

			local function updateCanvas(inputObj)
				if Canvas.AbsoluteSize.X == 0 or Canvas.AbsoluteSize.Y == 0 then return end
				local relX = math.clamp((inputObj.Position.X - Canvas.AbsolutePosition.X) / Canvas.AbsoluteSize.X, 0, 1)
				local relY = math.clamp((inputObj.Position.Y - Canvas.AbsolutePosition.Y) / Canvas.AbsoluteSize.Y, 0, 1)

				updatePicker(hue, relX, 1 - relY, false, true)
			end

			updateCanvas(input)

			moveConn = uis.InputChanged:Connect(function(moveInput)
				if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
					updateCanvas(moveInput)
				end
			end)

			releaseConn = uis.InputEnded:Connect(function(endInput)
				if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
					activeInteraction = nil
					if moveConn then moveConn:Disconnect() end
					if releaseConn then releaseConn:Disconnect() end
				end
			end)
		end
	end)

	SafeConnect(Color.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if activeInteraction ~= nil then return end
			activeInteraction = Color

			local moveConn, releaseConn

			local function updateHue(inputObj)
				if Color.AbsoluteSize.Y == 0 then return end
				local relY = math.clamp((inputObj.Position.Y - Color.AbsolutePosition.Y) / Color.AbsoluteSize.Y, 0, 1)

				updatePicker(relY, sat, brightness, false, true)
			end

			updateHue(input)

			moveConn = uis.InputChanged:Connect(function(moveInput)
				if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
					updateHue(moveInput)
				end
			end)

			releaseConn = uis.InputEnded:Connect(function(endInput)
				if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
					activeInteraction = nil
					if moveConn then moveConn:Disconnect() end
					if releaseConn then releaseConn:Disconnect() end
				end
			end)
		end
	end)

	local function updateFromRGB()
		local r = math.clamp(tonumber(RInput.Text) or 0, 0, 255)
		local g = math.clamp(tonumber(GInput.Text) or 0, 0, 255)
		local b = math.clamp(tonumber(BInput.Text) or 0, 0, 255)

		local newColor = Color3.fromRGB(r, g, b)
		local h, s, v = Color3.toHSV(newColor)
		updatePicker(h, s, v, false, true)
	end

	RInput.FocusLost:Connect(updateFromRGB)
	GInput.FocusLost:Connect(updateFromRGB)
	BInput.FocusLost:Connect(updateFromRGB)

	SafeConnect(ToggleRGB.MouseButton1Down, function()
		ToggleFiller_2.Visible = not ToggleFiller_2.Visible
		if ToggleFiller_2.Visible then
			startRainbow()
		else
			stopRainbow()
		end
	end)

	SafeConnect(ColorPickerFrame.AncestryChanged, function(_, parent)
		if not parent then
			stopRainbow()
		end
	end)

	attachLockSystem(option, colFrameParent, option)

	function option:SetValue(color, skipRainbowStop)
		if option:_isLocked() then return end

		if typeof(color) == "Color3" then
			local h, s, v = Color3.toHSV(color)
			updatePicker(h, s, v, skipRainbowStop, true)
		elseif type(color) == "boolean" then
			ToggleFiller_2.Visible = color
			if color then
				startRainbow()
			else
				stopRainbow()
			end
		end
	end

	function option:Close()
		if option.Floating and dragColFrame then
			dragColFrame.Visible = false
		end
		ColorPickerFrame.Visible = false
		colFrame.AutomaticSize = Enum.AutomaticSize.None
		colFrameParent.AutomaticSize = Enum.AutomaticSize.None
		colLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	end

	function option:Open()
		if colorPickers then
			for _, otherCol in ipairs(colorPickers) do
				if otherCol ~= option and otherCol.Close then
					otherCol:Close()
				end
			end
		end

		if option.Floating and dragColFrame then
			dragColFrame.Visible = true
			ColorPickerFrame.Visible = true
			
			task.defer(function()
				if not ColorPickerFrame or not dragColFrame then return end

				local dropAbs = ColorPicker.AbsolutePosition
				local parentAbs = dragColFrame.Parent.AbsolutePosition

				local targetX = dropAbs.X - parentAbs.X
				local targetY = dropAbs.Y - parentAbs.Y

				dragColFrame.Position = UDim2.fromOffset(targetX, targetY)
			end)
		else
			colFrame.AutomaticSize = Enum.AutomaticSize.Y
			colFrameParent.AutomaticSize = Enum.AutomaticSize.Y
			colLayout.VerticalAlignment = Enum.VerticalAlignment.Top
			
			ColorPickerFrame.Visible = true
		end
	end

	function option:SetTitle(newTitle)
		option.Title = newTitle
		PickerDescription.Text = tostring(newTitle)
	end

	if colorPickers then
		table.insert(colorPickers, option)
	end

	SafeConnect(ColorPicker.MouseButton1Click, function()
		if ColorPickerFrame.Visible then
			option:Close()
		else
			option:Open()
		end
	end)

	option.Instance = colFrameParent
	return option
end

local function makeElementDivider(option, parentContainer)
	local divFrameParent = Create("Frame", {
		Parent = parentContainer,
		Size = UDim2.new(1,0,0,2),
		BackgroundTransparency = 1,
		Name = "_Div_",
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 12 + zindex
	})

	Create("UIPadding", {
		PaddingLeft = UDim.new(0, 5),
		PaddingRight = UDim.new(0, 5),
		Parent = divFrameParent
	})

	local divParentLayout = Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = divFrameParent
	})

	local divFrame = Create("Frame", {
		LayoutOrder = 2,
		Parent = divFrameParent,
		Size = option.Size,
		BackgroundColor3 = option.Color,
		BorderSizePixel = 0,
		Name = "Div",
		ZIndex = 12 + zindex
	})

	if option.Title and (option.Title ~= nil and option.Title ~= "") then
		local BoxTitle = Create("TextLabel", {
			LayoutOrder = 1,
			AnchorPoint = Vector2.new(0,0),
			Name = "DivText",
			Parent = divFrameParent,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 0, 5),
			Font = Enum.Font.SourceSans,
			Text = option.Title,
			TextColor3 = option.TextColor,
			TextSize = 16,
			TextWrapped = true,
			ZIndex = 12 + zindex,
			TextXAlignment = Enum.TextXAlignment[option.XAlignment],
			AutomaticSize = Enum.AutomaticSize.Y,
			Active = false
		})
	end
	
	option.Instance = divFrameParent
	return option
end

local function injectElements(targetContainer, parentUI, winConfig)
	function targetContainer:AddButton(config)
		config = type(config) == "table" and config or {}
		config.Title = ((config.Title or config.Name or config.Text) or (config.title or config.name or config.text)) or "Button"
		config.Callback = (config.Callback or config.callback) or function() end

		return makeButton(config, parentUI)
	end

	function targetContainer:AddToggle(config)
		config = type(config) == "table" and config or {}
		config.Title = ((config.Title or config.Name or config.Text) or (config.title or config.name or config.text)) or "Toggle"
		config.Default = ((config.Default or config.Value or config.state) or (config.default or config.value or config.state)) or false
		config.Delay = (config.Delay or config.delay) or 0
		config.Flag = (config.Flag or config.flag) or config.Title
		config.Callback = (config.Callback or config.callback) or function() end

		if registerFlag then
			registerFlag(config)
		end

		return makeToggle(config, parentUI)
	end

	function targetContainer:AddLabel(config)
		config = type(config) == "table" and config or {}
		config.Title = ((config.Title or config.Name or config.Text) or (config.title or config.name or config.text)) or "Label"
		config.XAlignment = (config.XAlignment or config.xAlignment or config.xalignment) or "Left"
		config.Color = (config.Color or config.color) or Color3.new(1, 1, 1)

		return makeLabel(config, parentUI)
	end

	function targetContainer:AddDivider(config)
		config = type(config) == "table" and config or {}
		config.Title = ((config.Title or config.Name or config.Text) or (config.title or config.name or config.text)) or "Label"
		config.XAlignment = (config.XAlignment or config.xAlignment or config.xalignment) or "Left"
		config.Size = (config.Size or config.size) or UDim2.new(1,0,0,1)
		config.Color = (config.Color or config.color) or library["Themes"][library.SelectedTheme].ElementDivider
		config.TextColor = (config.TextColor or config.textColor or config.textcolor) or library["Themes"][library.SelectedTheme].ElementDividerText

		return makeElementDivider(config, parentUI)
	end

	function targetContainer:AddTextBox(config)
		config = type(config) == "table" and config or {}
		config.Title = ((config.Title or config.Name or config.Text) or (config.title or config.name or config.text)) or "TextBox"
		config.TextDisappear = ((config.TextDisappear or config.ClearText) or (config.textDisappear or config.clearText) or (config.textdisappear or config.cleartext)) or false
		config.Default = ((config.Default or config.Value) or (config.default or config.value)) or ""
		config.Flag = (config.Flag or config.flag) or config.Title
		config.Callback = (config.Callback or config.callback) or function() end

		if registerFlag then
			registerFlag(config)
		end

		return makeBox(config, parentUI)
	end

	function targetContainer:AddSlider(config)
		config = type(config) == "table" and config or {}
		config.Title = ((config.Title or config.Name or config.Text) or (config.title or config.name or config.text)) or "Slider"
		config.Min = (config.Min or config.min) or 1
		config.Max = (config.Max or config.max) or 100
		config.Increment = (config.Increment or config.increment) or 1
		config.Default = ((config.Default or config.Value) or (config.default or config.value)) or (config.Max / 2)
		config.Flag = (config.Flag or config.flag) or config.Title
		config.Callback = (config.Callback or config.callback) or function() end

		if registerFlag then
			registerFlag(config)
		end

		return makeSlider(config, parentUI)
	end

	function targetContainer:AddDropdown(config)
		config = type(config) == "table" and config or {}
		config.Title = ((config.Title or config.Name or config.Text) or (config.title or config.name or config.text)) or config.text or "Dropdown"
		config.Items = (config.Items or config.items) or {}
		config.MultiSelect = (config.MultiSelect or config.multiSelect) or false
		config.Floating = (config.Floating or config.floating) or false
		config.Flag = (config.Flag or config.flag) or config.Title
		config.Callback = (config.Callback or config.callback) or function() end
		config.Default = (config.Default or config.default) or (config.MultiSelect and {} or nil)

		if registerFlag then
			registerFlag(config)
		end

		return makeDropdown(config, parentUI)
	end

	function targetContainer:AddColorPicker(config)
		config = type(config) == "table" and config or {}
		config.Title = ((config.Title or config.Name or config.Text) or (config.title or config.name or config.text)) or "Color Picker"
		config.Default = (config.Default or config.default) or Color3.fromRGB(255, 0, 0)
		config.Floating = (config.Floating or config.floating) or false
		config.Flag = (config.Flag or config.flag) or config.Title
		config.Callback = (config.Callback or config.callback) or function() end

		if registerFlag then
			registerFlag(config)
		end

		return makeColorPicker(config, parentUI)
	end

	function targetContainer:AddGroup(config)
		config = type(config) == "table" and config or {}
		config.Title = ((config.Title or config.Name or config.Text) or (config.title or config.name or config.text)) or "Group Box"
		config.Collapsible = (config.Collapsible or config.collapsible) or false
		config.Open = config.Open ~= nil and config.Open or true

		local groupController, contentHolder = makeGroupUI(config, parentUI)

		local groupObj = groupController or config
		injectElements(groupObj, contentHolder)

		return groupObj
	end

	function targetContainer:AddColumns(config)
		config = type(config) == "table" and config or {}
		config.Count = (config.Count or config.count) or 2

		local colFrames = makeColumnsUI(config, parentUI, config.Count)

		local columnObjs = {}
		for i = 1, config.Count do
			local colObj = {}
			injectElements(colObj, colFrames[i])
			table.insert(columnObjs, colObj)
		end

		return table.unpack(columnObjs)
	end

	function targetContainer:AddGrid(config)
		config = type(config) == "table" and config or {}
		config.CellSize = (config.CellSize or config.cellSize) or UDim2.new(0, 80, 0, 80)
		config.CellPadding = (config.CellPadding or config.cellPadding) or UDim2.new(0, 6, 0, 6)

		local gridController, gridHolder = makeGridUI(config, parentUI)

		local gridObj = gridController or config
		injectElements(gridObj, gridHolder)

		return gridObj
	end
end

function library:CreateWindow(WinConfig)
	WinConfig = WinConfig or {}
	WinConfig.Title = WinConfig.Title or "TurtleUiLib"
	WinConfig.SubTitle = WinConfig.SubTitle or "Ui Library V2"
	WinConfig.Size = WinConfig.Size or UDim2.new(0,220,0,288)
	WinConfig.Keybind = WinConfig.Keybind or "LeftControl"
	WinConfig.MobileUI = WinConfig.MobileUI or false
	WinConfig.MobileUIText = WinConfig.MobileUIText or "Show TurtleUiLib"
	WinConfig.Position = WinConfig.Position or UDim2.new(0, xOffset, 0, 90)
	WinConfig.TabPosition = WinConfig.TabPosition or "Top"
	WinConfig.ContentFillDirection = WinConfig.ContentFillDirection or "Vertical"
	WinConfig.HeaderIcon = WinConfig.HeaderIcon or ""
	WinConfig.IsDebugMode = WinConfig.IsDebugMode or true
	
	windowCount = windowCount + 1
	winCount = windowCount
	zindex = zindex * winCount
	
	if WinConfig.IsDebugMode ~= nil and WinConfig.IsDebugMode then
		library.IsDebug = WinConfig.IsDebugMode
	end
	
	local configSettings = WinConfig.ConfigurationSaving or {}
	local folderName = configSettings.FolderName or "TurtleUI_Settings"
	
	local defaultFileName = (configSettings.FileName and configSettings.FileName ~= "") 
		and configSettings.FileName 
		or tostring(game.GameId)
	CurrentConfigName = defaultFileName
	CurrentFolderName = folderName
	
	if WinConfig.KeySystem and WinConfig.KeySettings then
		local keySettings = WinConfig.KeySettings
		local fileName = keySettings.FileName or "SavedKey.txt"
		
		local savedKey = getSavedKey(folderName, fileName, keySettings)
		local isVerified = false

		if savedKey then
			isVerified = true
		else
			local keySignal = Instance.new("BindableEvent")

			createKeyWindow(
				keySettings, 
				folderName, 
				function()
					isVerified = true
					keySignal:Fire(true)
				end,
				function()
					isVerified = false
					keySignal:Fire(false)
				end
			)

			local success = keySignal.Event:Wait()
			keySignal:Destroy()

			if not success or not isVerified then
				return nil
			end
		end
	end

	if typeof(WinConfig.Theme) == "string" and (WinConfig.Theme and WinConfig.Theme ~= "") then
		library.SelectedTheme = WinConfig.Theme or "Default"
	end

	local UiWindow = Create("Frame", {
		Name = "UiWindow_" .. windowCount,
		Parent = TurtleUiLib,
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 151, 230),
		Position = WinConfig.Position,
		Size = WinConfig.Size,
		ZIndex = 4 + zindex,
		Active = false,
		ClipsDescendants = true
	})

	local uiwinLayout = Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Padding = UDim.new(0, 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = UiWindow
	})

	xOffset = xOffset + 230

	local Header = Create("Frame", {
		Name = "Header",
		Parent = UiWindow,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 33),
		ZIndex = 5 + zindex,
		Active = true
	})
	AddThemeObject(Header, "Header", "BackgroundColor3")

	local HeaderContentHolder = Create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Name = "HeaderContentHolder",
		Parent = Header,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, -67, 1, 0),
		ZIndex = 5 + zindex,
		Active = false
	})

	local HeaderContentHolder_Layout = Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = HeaderContentHolder
	})

	local HeaderContentHolder_Padding = Create("UIPadding", {
		Parent = HeaderContentHolder,
		PaddingTop = UDim.new(0, 5),
		PaddingBottom = UDim.new(0, 5),
		PaddingLeft = UDim.new(0, 5),
		PaddingRight = UDim.new(0, 5)
	})

	local HeaderIconLabel = Create("ImageLabel", {
		Size = UDim2.new(0, 30, 0, 30),
		BackgroundTransparency = 1,
		ImageColor3 = Color3.fromRGB(240, 240, 240),
		Name = "HeaderIconLabel",
		LayoutOrder = 1,
		ZIndex = 8 + zindex,
		Parent = HeaderContentHolder
	})
	AddThemeObject(HeaderIconLabel, "HeaderText", "ImageColor3")

	if WinConfig.HeaderIcon and (WinConfig.HeaderIcon ~= nil and WinConfig.HeaderIcon ~= "") then
		applyIcon(HeaderIconLabel, WinConfig.HeaderIcon)
	else
		HeaderIconLabel:Destroy()
	end

	local HeaderTextHolder = Create("Frame", {
		LayoutOrder = 2,
		AnchorPoint = Vector2.new(0, 0),
		Name = "HeaderTextHolder",
		AutomaticSize = Enum.AutomaticSize.X,
		Parent = HeaderContentHolder,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(0, 30, 1, 0),
		ZIndex = 5 + zindex,
		Active = false
	})

	local HeaderTextHolder_Layout = Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Padding = UDim.new(0, 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = HeaderTextHolder
	})

    local HeaderText = Create("TextLabel", {
		LayoutOrder = 1,
		Parent = HeaderTextHolder,
		Name = "HeaderText",
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 30, 0.5, 0),
		Position = UDim2.new(0, 0, 0, 0),
		Font = Enum.Font.SourceSansBold,
		TextSize = 18,
		BackgroundTransparency = 1,
		Text = WinConfig.Title,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 6 + zindex,
		Active = false
	})
	AddThemeObject(HeaderText, "HeaderText", "TextColor3")

	local SubHeaderText = Create("TextLabel", {
		LayoutOrder = 2,
		Parent = HeaderTextHolder,
		Name = "SubHeaderText",
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 30, 0.5, 0),
		Position = UDim2.new(0, 0, 0, 0),
		Font = Enum.Font.SourceSansBold,
		TextSize = 12,
		BackgroundTransparency = 1,
		Text = WinConfig.SubTitle,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 6 + zindex,
		Active = false
	})
	AddThemeObject(SubHeaderText, "SubHeaderText", "TextColor3")

	if not WinConfig.SubTitle and (WinConfig.SubTitle == nil and WinConfig.SubTitle == "") then
		HeaderText.Size = UDim2.new(1,0,1,0)
		SubHeaderText:Destroy()
	end

	MakeDraggable(Header, UiWindow)

	local Window = Create("Frame", {
		Name = "Window",
		Parent = UiWindow,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, -33),
		ZIndex = 1 + zindex,
		Active = false
	})
	AddThemeObject(Window, "WindowBackground", "BackgroundColor3")

	local winsLayoutHolder = Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = Window
	})

	local utilityButt = Create("Frame", {
		AnchorPoint = Vector2.new(1,0.5),
		Size = UDim2.new(0, 22, 0, 22),
		Position = UDim2.new(1,-5,0.5,0),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		
		Parent = Header
	})

	local textLayoutHolder = Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = utilityButt
	})

	local Minimise = Instance.new("TextButton")
	local CloseWindowBtn

	Minimise.Name = "Minimise"
	Minimise.Parent = utilityButt
	Minimise.BackgroundColor3 = Color3.fromRGB(0, 168, 255)
	Minimise.BackgroundTransparency = 1
	Minimise.BorderColor3 = Color3.fromRGB(0, 168, 255)
	Minimise.Position = UDim2.new(0, 0, 0, 0)
	Minimise.Size = UDim2.new(0, 22, 0, 22)
	Minimise.ZIndex = 7 + zindex
	Minimise.Font = Enum.Font.SourceSansBold
	Minimise.Text = "–"
	Minimise.TextSize = 20
	AddThemeObject(Minimise, "HeaderText", "TextColor3")

	if UiWindow.Size.X.Offset >= 380 then
		CloseWindowBtn = Create("ImageButton", {
			Size = UDim2.new(0, 22, 0, 22),
			BackgroundTransparency = 1,
			ZIndex = 7 + zindex,
			Parent = utilityButt,
			Image = "rbxassetid://7072725342"
		})
		AddThemeObject(CloseWindowBtn, "HeaderText", "ImageColor3")

		if WinConfig.Keybind then
			uiKeybind(WinConfig.Keybind, UiWindow)
		end

		local MobileUIToggle = Create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			AutomaticSize = Enum.AutomaticSize.X,
			Parent = TurtleUiLib,
			Size = UDim2.new(0.1, 0, 0, 40),
			Position = UDim2.new(0.5, 0, 0.1, 0),
			BackgroundTransparency = 0.05,
			Visible = false
		})
		AddThemeObject(MobileUIToggle, "WindowBackground", "BackgroundColor3")
		local MobileUIButton = Create("TextButton", {
			Parent = MobileUIToggle,
			AutomaticSize = Enum.AutomaticSize.X,
			Name = "Click",
			BackgroundTransparency = 1,
			ZIndex = 15 + zindex,
			Size = UDim2.new(1, 0, 1, 0)
		})
		local mobilePaddingui = Create("UIPadding", {
			Parent = MobileUIButton,
			PaddingTop = UDim.new(0, 2),
			PaddingBottom = UDim.new(0, 2),
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8)
		})
		local uiMobileDragPoint = Create("ImageLabel", {
			Parent = MobileUIButton,
			Name = "DragPoint",
			Active = true,
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(0, 20, 0, 20),
			ZIndex = 15 + zindex,
			Image = "rbxassetid://7072725342"
		})
		local uiMobileTitle = Create("TextLabel", {
			Parent = MobileUIButton,
			AnchorPoint = Vector2.new(0, 0.5),
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, 0),
			Position = UDim2.new(0, 25, 0.5, 0),
			Font = Enum.Font.GothamBlack,
			TextSize = 14,
			BackgroundTransparency = 1,
			ZIndex = 15 + zindex,
			Text = WinConfig.MobileUIText,
			TextSize = 14
		})
		AddThemeObject(uiMobileTitle, "NormalText", "TextColor3")

		MakeDraggable(uiMobileDragPoint, MobileUIToggle)

		MobileUIButton.MouseButton1Click:Connect(function()
			UiWindow.Visible = not UiWindow.Visible
			if WinConfig.MobileUI then
				MobileUIToggle.Visible = false
			end
		end)

		CloseWindowBtn.MouseButton1Click:Connect(function()
			UiWindow.Visible = not UiWindow.Visible
			if WinConfig.MobileUI then
				MobileUIToggle.Visible = true
			end
		end)
	end

	Minimise.MouseButton1Click:Connect(function()
		Window.Visible = not Window.Visible
		if Window.Visible then
			Minimise.Text = "–"
		else
			Minimise.Text = "+"
		end
	end)

	local TabHolder = Create("ScrollingFrame", {
		Name = "TabFrame",
		Parent = Window,
		BackgroundColor3 = Color3.fromRGB(45,45,45),
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0,0,0,0),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollingDirection = Enum.ScrollingDirection.X,
		ElasticBehavior = Enum.ElasticBehavior.Never,
		ScrollBarThickness = 0,
		Size = UDim2.new(1,0,0,35),
		ZIndex = 8 + zindex,
		Visible = false,
		Active = true
	})

	local TabHolderListLayout = Create("UIListLayout", {
		Name = "TabHolderListLayout",
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = TabHolder
	})

	local TabHolderPadding = Create("UIPadding", {
		PaddingRight = UDim.new(0, 5),
		PaddingLeft = UDim.new(0, 5),
		Parent = TabHolder
	})

	local contentArea = Instance.new("Frame")
	contentArea.Name = "contentArea"
	contentArea.ZIndex = 9 + zindex
	contentArea.BackgroundTransparency = 1
	contentArea.Position = UDim2.new(0, 0, 0, 0)
	contentArea.Size = UDim2.new(1, 0, 1, 0)
	contentArea.Parent = Window

	local WindowScroll = Create("ScrollingFrame", {
		Name = "WindowScroll",
		Parent = contentArea,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0,0,0,0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 0,
		ElasticBehavior = Enum.ElasticBehavior.Never,
		Size = UDim2.new(1,0,1,0),
		ZIndex = 10 + zindex,
		Visible = true,
		Active = true
	})

	local winPaddingLayout = Create("UIPadding", {
		PaddingBottom = UDim.new(0, 5),
		PaddingTop = UDim.new(0, 5),
		PaddingRight = UDim.new(0, 0),
		PaddingLeft = UDim.new(0, 0),
		Parent = WindowScroll
	})

	local winLayout = Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = WindowScroll
	})

	local window = {
		_autoSaveConnected = false,
		gui = TurtleUiLib,
		mainFrame = UiWindow,
		contentArea = contentArea,
		sidebarFrame = TabHolder,
		fastScroll = WindowScroll,
		FolderName = folderName,
		ConfigName = defaultFileName,
		tabs = {},
		isInitialized = false,
		isTabMode = false,
		activeTab = nil
	}

	injectElements(window, window.fastScroll)

	function window:AddBadge(BadgeConfig)
		BadgeConfig = BadgeConfig or {}
		BadgeConfig.Title = BadgeConfig.Title or "V1.0.0"
		BadgeConfig.Color = BadgeConfig.Color or Color3.fromRGB(255,68,68)
		BadgeConfig.TitleColor = BadgeConfig.TitleColor or Color3.fromRGB(255,255,255)
		BadgeConfig.Icon = BadgeConfig.Icon or ""

		local BagdeFrame = Create("Frame", {
			Name = BadgeConfig.Title,
			LayoutOrder = 3,
			Parent = HeaderContentHolder,
			BackgroundColor3 = BadgeConfig.Color,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Position = UDim2.new(0,0,0,0),
			Size = UDim2.new(0.25,0,0,30),
			ZIndex = 8 + zindex,
			Visible = true,
			Active = false
		})

		local ListLayouttt = Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = BagdeFrame
		})

		local PadLayouttt = Create("UIPadding", {
			PaddingBottom = UDim.new(0, 5),
			PaddingTop = UDim.new(0, 5),
			PaddingRight = UDim.new(0, 5),
			PaddingLeft = UDim.new(0, 5),
			Parent = BagdeFrame
		})
	
		Create("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Parent = BagdeFrame
		})

		local Iccon = Create("ImageLabel", {
			Size = UDim2.new(0, 24, 0, 24),
			BackgroundTransparency = 1,
			ImageColor3 = Color3.fromRGB(240, 240, 240),
			Name = "Icon",
			LayoutOrder = 1,
			ZIndex = 8 + zindex,
			Parent = BagdeFrame
		})

		if BadgeConfig.Icon and (BadgeConfig.Icon ~= nil and BadgeConfig.Icon ~= "") then
			applyIcon(Iccon, BadgeConfig.Icon)
		else
			Iccon:Destroy()
		end

		local BagdeTitle = Create("TextLabel", {
			LayoutOrder = 2,
			Parent = BagdeFrame,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0,0,0,0),
			Size = UDim2.new(1,-29,1,0),
			Font = Enum.Font.Gotham,
			Text = BadgeConfig.Title,
			TextSize = 14,
			TextColor3 = BadgeConfig.TitleColor,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 8 + zindex,
			Visible = true,
			Active = false
		})

		return BagdeFrame
	end

	function window:AddTab(TabConfig)
		TabConfig = TabConfig or {}
		TabConfig.Title = TabConfig.Title or "Main"
		TabConfig.Icon = TabConfig.Icon or "sword"
		if not window.isTabMode then
			window.isTabMode = true
			window.fastScroll.Visible = false
			window.sidebarFrame.Visible = true
		end

		local tab = {
			type = "tab",
			title = TabConfig.Title,
			buttonInstance = nil,
			containerInstance = nil
		}

		if WinConfig.TabPosition == "Top" then
			winsLayoutHolder.FillDirection = Enum.FillDirection.Vertical
			window.sidebarFrame.LayoutOrder = 1
			window.contentArea.Size = UDim2.new(1, 0, 1, -35)
			window.contentArea.LayoutOrder = 2
			window.sidebarFrame.TabHolderListLayout.FillDirection = Enum.FillDirection.Horizontal
			window.sidebarFrame.TabHolderListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		elseif WinConfig.TabPosition == "Bottom" then
			winsLayoutHolder.FillDirection = Enum.FillDirection.Vertical
			window.sidebarFrame.LayoutOrder = 2
			window.contentArea.Size = UDim2.new(1, 0, 1, -35)
			window.contentArea.LayoutOrder = 1
			window.sidebarFrame.TabHolderListLayout.FillDirection = Enum.FillDirection.Horizontal
			window.sidebarFrame.TabHolderListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		elseif WinConfig.TabPosition == "Left" then
			winsLayoutHolder.FillDirection = Enum.FillDirection.Horizontal
			window.sidebarFrame.LayoutOrder = 1
			window.sidebarFrame.Size = UDim2.new(0, 65, 1, 0)
			window.contentArea.Size = UDim2.new(1, -65, 1, 0)
			window.contentArea.LayoutOrder = 2
			window.sidebarFrame.TabHolderListLayout.FillDirection = Enum.FillDirection.Vertical
			window.sidebarFrame.TabHolderListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
		elseif WinConfig.TabPosition == "Right" then
			winsLayoutHolder.FillDirection = Enum.FillDirection.Horizontal
			window.sidebarFrame.LayoutOrder = 2
			window.sidebarFrame.Size = UDim2.new(0, 65, 1, 0)
			window.contentArea.Size = UDim2.new(1, -65, 1, 0)
			window.contentArea.LayoutOrder = 1
			window.sidebarFrame.TabHolderListLayout.FillDirection = Enum.FillDirection.Vertical
			window.sidebarFrame.TabHolderListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
		end

		local tabButtonFrame = Create("Frame", {
			Name = TabConfig.Title,
			Parent = window.sidebarFrame,
			BackgroundColor3 = library.Themes[library.SelectedTheme].TabBtnBackground,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Position = UDim2.new(0,0,0,0),
			Size = UDim2.new(0.25,0,0,30),
			ZIndex = 8 + zindex,
			Visible = true,
			Active = true
		})

		local tabButton = Create("TextButton", {
			Name = "_Button",
			Parent = tabButtonFrame,
			BackgroundColor3 = Color3.fromRGB(25,25,25),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0,0,0,0),
			Size = UDim2.new(1,0,1,0),
			Font = Enum.Font.GothamSemibold,
			TextTransparency = 1,
			ZIndex = 8 + zindex,
			Visible = true,
			Active = false
		})

		local ListLayouttt = Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = tabButton
		})

		local PadLayouttt = Create("UIPadding", {
			PaddingBottom = UDim.new(0, 5),
			PaddingTop = UDim.new(0, 5),
			PaddingRight = UDim.new(0, 5),
			PaddingLeft = UDim.new(0, 5),
			Parent = tabButton
		})

		local Iccon = Create("ImageLabel", {
			Size = UDim2.new(0, 24, 0, 24),
			BackgroundTransparency = 1,
			ImageColor3 = Color3.fromRGB(240, 240, 240),
			Name = "Icon",
			LayoutOrder = 1,
			ZIndex = 8 + zindex,
			Parent = tabButton
		})

		if TabConfig.Icon and (TabConfig.Icon ~= nil and TabConfig.Icon ~= "") then
			applyIcon(Iccon, TabConfig.Icon)
		else
			Iccon:Destroy()
		end

		local tabButtonTitle = Create("TextLabel", {
			LayoutOrder = 2,
			Parent = tabButton,
			BackgroundColor3 = Color3.fromRGB(25,25,25),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0,0,0,0),
			Size = UDim2.new(1,-29,1,0),
			Font = Enum.Font.GothamSemibold,
			Text = TabConfig.Title,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 8 + zindex,
			Visible = true,
			Active = false
		})
		AddThemeObject(tabButtonTitle, "NormalText", "TextColor3")
		tab.buttonInstance = tabButtonFrame

		local tabContainer = Create("ScrollingFrame", {
			Name = "Content_" .. TabConfig.Title,
			Parent = window.contentArea,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(0,0,0,0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ElasticBehavior = Enum.ElasticBehavior.Never,
			ScrollBarThickness = 0,
			ZIndex = 10 + zindex,
			Size = UDim2.new(1,0,1,0),
			Visible = false,
			Active = true
		})

		local PaddingLayouttt = Create("UIPadding", {
			PaddingBottom = UDim.new(0, 5),
			PaddingTop = UDim.new(0, 5),
			PaddingRight = UDim.new(0, 0),
			PaddingLeft = UDim.new(0, 0),
			Parent = tabContainer
		})

		local containerLayout = Create("UIListLayout", {
			FillDirection = Enum.FillDirection[WinConfig.ContentFillDirection],
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = tabContainer
		})
		tab.containerInstance = tabContainer

		injectElements(tab, tab.containerInstance)

		function tab:Select()
			for _, otherTab in ipairs(window.tabs) do
				if otherTab.containerInstance then
					otherTab.containerInstance.Visible = false
				end
				if otherTab.buttonInstance then
					otherTab.buttonInstance.BackgroundColor3 = library.Themes[library.SelectedTheme].TabBtnBackground
				end
			end

			tab.containerInstance.Visible = true
			tab.buttonInstance.BackgroundColor3 = library.Themes[library.SelectedTheme].TabBtnBackgroundSelect
			window.activeTab = tab
		end

		tabButton.MouseButton1Click:Connect(function()
			tab:Select()
		end)

		table.insert(window.tabs, tab)

		if #window.tabs == 1 then
			if window.activeTab == nil then
				tab:Select()
			end
		end

		return tab
	end

	function window:AddTabDivider(TabDivConfig)
		-- WIP
	end

	function window:AddTabLabel(TabLabelConfig)
		-- WIP
	end

	if configSettings.Enabled and (configSettings.AutoLoadConfig and configSettings.AutoLoadConfig ~= nil) then
		task.defer(function()
			pcall(function()
				library:LoadConfig(folderName, defaultFileName)
				library:Notification({
					Title = "Configuration",
					Content = "Auto-loaded configuration for the game " .. game.GameId .. ".",
					Time = 5
				})
			end)
		end)
	end

	if configSettings.Enabled and (configSettings.AutoSave and configSettings.AutoSave ~= nil) then
		if not window._autoSaveConnected then
			window._autoSaveConnected = true
			library.GlobalAutoSave = true
			game:GetService("Players").LocalPlayer.AncestryChanged:Connect(function(_, parent)
				if not parent then
					pcall(function()
						library:SaveConfig(folderName, defaultFileName)
						warn("_autoSaveConnected | configuration saved")
					end)
				end
			end)
		end
	end

	table.insert(library.OpenWindows, window)

	return window
end

return library