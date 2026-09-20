-- // Credits to Intrer#0421 for the source \\ --
-- // This UI is updated by me (LucidSc1pt) \\ --

-- // MAIN CODE \\ --

local library = {
	ThemeObjects = {},
	Flags = {},
	FlagsObjects = {},
	Themes = {
		Default = {
			WindowBackground = Color3.fromRGB(47, 54, 64),
			WindowBorder = Color3.fromRGB(47, 54, 64),
		
			UIWindow = Color3.fromRGB(0, 151, 230),
			UIWindowBorder = Color3.fromRGB(0, 151, 230),
			
			NotificationBackground = Color3.fromRGB(40,40,40),
			NotificationStroke = Color3.fromRGB(0,168,247),
			NotificationBar = Color3.fromRGB(0,168,247),
			
			ElementDivider = Color3.fromRGB(60, 60, 70),
			ElementDividerText = Color3.fromRGB(60, 60, 70),
			TabDivider = Color3.fromRGB(60, 60, 70),
			TabDividerText = Color3.fromRGB(60, 60, 70),
			
			Header = Color3.fromRGB(0, 168, 255),
			HeaderBorder = Color3.fromRGB(0, 168, 255),
			HeaderText = Color3.fromRGB(47, 54, 64),
			SubHeaderText = Color3.fromRGB(67, 74, 84),

			NormalText = Color3.fromRGB(245, 246, 250),
			NormalBackground = Color3.fromRGB(53, 59, 72),

			BtnBorder = Color3.fromRGB(113, 128, 147),
			
			ToggleFiller = Color3.fromRGB(68, 189, 50),

			SliderFiller = Color3.fromRGB(76, 209, 55)
		}
	},
	SelectedTheme = "Default"
}
local windowCount = 0
local sizes = {}
local listOffset = {}
local windows = {}
local pastSliders = {}
local dropdowns = {}
local dropdownSizes = {}
local colorPickers = {}
local activeInteraction = nil
local zindex = 1000

function Lerp(a, b, c)
	return a + ((b - a) * c)
end

-- // Service \\ --
local TweenService = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local players = game:service('Players');
local player = players.LocalPlayer;
local mouse = player:GetMouse();
local run = game:service('RunService');
local stepped = run.Stepped;

local Icons

local Success, Response = pcall(function()
	Icons = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/icons.lua"))()
end)

if not Success then
	warn("\nFailed to load Feather Icons. Error code: " .. Response .. "\n")
end

local function getIcon(name : string): {id: number, imageRectSize: Vector2, imageRectOffset: Vector2}
	if not Icons then
		warn("Lucide Icons: Cannot use icons as icons library is not loaded")
		return
	end
	name = string.match(string.lower(name), "^%s*(.*)%s*$") :: string
	local sizedicons = Icons['48px']
	local r = sizedicons[name]
	if not r then
		error(`Lucide Icons: Failed to find icon by the name of "{name}"`, 2)
	end

	local rirs = r[2]
	local riro = r[3]

	if type(r[1]) ~= "number" or type(rirs) ~= "table" or type(riro) ~= "table" then
		error("Lucide Icons: Internal error: Invalid auto-generated asset entry")
	end

	local irs = Vector2.new(rirs[1], rirs[2])
	local iro = Vector2.new(riro[1], riro[2])

	local asset = {
		id = r[1],
		imageRectSize = irs,
		imageRectOffset = iro,
	}

	return asset
end

local function getAssetUri(id: any): string
	local assetUri = "rbxassetid://0" -- Default to empty image
	if type(id) == "number" then
		assetUri = "rbxassetid://" .. id
	elseif type(id) == "string" and not Icons then
		warn("Cannot use Lucide icons as icons library is not loaded")
	else
		warn("The icon argument must either be an icon ID (number) or a Lucide icon name (string)")
	end
	return assetUri
end

local function MakeDraggable(DragPoint, Main)
	Main = Main or DragPoint
	
	local Dragging = false
	local DragInput = nil
	local MousePos = nil
	local FramePos = nil

	DragPoint.InputBegan:Connect(function(Input)
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

	DragPoint.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
			if not Dragging then
				DragInput = Input
			end
		end
	end)

	uis.InputChanged:Connect(function(Input)
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
end

local function protect_gui(obj) 
	if destroyed then
		obj.Parent = game.CoreGui
		return
	end
	if syn and syn.protect_gui then
		syn.protect_gui(obj)
		obj.Parent = game.CoreGui
	elseif PROTOSMASHER_LOADED or get_hidden_gui then
		obj.Parent = get_hidden_gui()
	elseif gethui then
		obj.Parent = gethui()
	else
		obj.Parent = game.CoreGui
	end
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
	
	-- Simpan referensi ke daftar tracking
	table.insert(library.ThemeObjects[ThemeKey], {
		Object = Object,
		Property = targetProperty
	})
	
	-- Terapkan warna tema yang sedang aktif secara instan
	local currentTheme = library.Themes[library.SelectedTheme]
	if currentTheme and currentTheme[ThemeKey] then
		Object[targetProperty] = currentTheme[ThemeKey]
	end
	
	-- KUNCI UTAMA: Wajib return Object agar bisa dirantai (chained/nested)
	return Object
end

function library:AddTheme(themeName, themeTable)
	if type(themeName) == "string" and type(themeTable) == "table" then
		library.Themes[themeName] = themeTable
	end
end

function library:SetTheme(themeInput)
	local targetTheme = nil

	if type(themeInput) == "string" then
		-- Jika user memasukkan nama tema (contoh: "Dark")
		if library.Themes[themeInput] then
			library.SelectedTheme = themeInput
			targetTheme = library.Themes[themeInput]
		end
	elseif type(themeInput) == "table" then
		-- Jika user memasukkan table Color3 secara langsung
		targetTheme = themeInput
		library.SelectedTheme = "Custom"
	end

	if not targetTheme then return end

	-- Terapkan perubahan warna ke semua UI yang terdaftar di ThemeObjects
	for themeKey, objectList in pairs(library.ThemeObjects) do
		local targetColor = targetTheme[themeKey]
		if targetColor then
			for i = #objectList, 1, -1 do
				local item = objectList[i]
				if item.Object and item.Object.Parent then
					item.Object[item.Property] = targetColor
				else
					table.remove(objectList, i) -- Hapus jika UI sudah di-Destroy
				end
			end
		end
	end
end

local function registerFlag(option)
	option.Flag = option.Flag or option.Title
	
	-- Set nilai awal ke Flags global
	library.Flags[option.Flag] = option.Default or option.Value or option.State or false
	
	-- Simpan referensi tabel option berdasarkan nama Flag-nya
	library.FlagsObjects[option.Flag] = option
end

-- // Instances:

-- // Making the ScreenGui \\ --
local TurtleUiLib = Instance.new("ScreenGui")
TurtleUiLib.Name = "TurtleUiLib"
protect_gui(TurtleUiLib)

local xOffset = 20
local keybindConnection

-- // ⚠️ Function ⚠️ \\ --

-- // Notification Function \\ --
local NotificationHolder = Instance.new("Frame")
NotificationHolder.Name = "NotificationHolder"
NotificationHolder.Size = UDim2.new(0, 280, 1, -25)
NotificationHolder.Position = UDim2.new(1, -25, 1, -25)
NotificationHolder.AnchorPoint = Vector2.new(1, 1)
NotificationHolder.BackgroundTransparency = 1
NotificationHolder.Parent = TurtleUiLib

local ListLayout = Instance.new("UIListLayout")
ListLayout.Parent = NotificationHolder
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 5)
ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom

function library:Notification(NotificationConfig)
	task.spawn(function()
		NotificationConfig = NotificationConfig or {}
		NotificationConfig.Title = NotificationConfig.Title or "Notification"
		NotificationConfig.Desc = NotificationConfig.Desc or "Hello World"
		NotificationConfig.Image = NotificationConfig.Image or 4384403532
		NotificationConfig.Time = NotificationConfig.Time or 5

		local isDismissed = false

		local NotificationParent = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			Parent = NotificationHolder
		})

		local NotificationFrame = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(1, 50, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Color3.fromRGB(40, 40, 40),
			BackgroundTransparency = 0,
			Parent = NotificationParent
		})

		local Stroke = Instance.new("UIStroke")
		Stroke.Parent = NotificationFrame
		Stroke.Thickness = 2
		Stroke.Color = Color3.fromRGB(0, 168, 247)

		local Padding = Instance.new("UIPadding", NotificationFrame)
		Padding.PaddingTop = UDim.new(0, 8)
		Padding.PaddingBottom = UDim.new(0, 12)
		Padding.PaddingLeft = UDim.new(0, 10)
		Padding.PaddingRight = UDim.new(0, 10)

		local closeNotifButton = Instance.new("TextButton")
		closeNotifButton.AnchorPoint = Vector2.new(1, 0)
		closeNotifButton.Size = UDim2.new(0, 20, 0, 20)
		closeNotifButton.Position = UDim2.new(1, 0, 0, 0)
		closeNotifButton.BackgroundTransparency = 1
		closeNotifButton.Name = "CloseNotifications"
		closeNotifButton.Text = "X"
		closeNotifButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		closeNotifButton.Font = Enum.Font.GothamSemibold
		closeNotifButton.TextSize = 14
		closeNotifButton.Parent = NotificationFrame

		local contentHolder = Create("Frame", {
			Size = UDim2.new(1, -25, 1, -5),
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
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Parent = contentHolder
		})

		local textLayoutHolder = Create("UIListLayout", {
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
			Parent = textHolder
		})

		local Title = Instance.new("TextLabel")
		Title.Parent = textHolder
		Title.Size = UDim2.new(1, -32, 0, 0) -- Menyesuaikan lebar sisa setelah dikurangi Icon
		Title.AutomaticSize = Enum.AutomaticSize.Y
		Title.BackgroundTransparency = 1
		Title.Font = Enum.Font.GothamBold
		Title.TextColor3 = Color3.fromRGB(255, 255, 255)
		Title.TextSize = 14
		Title.TextWrapped = true
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.Text = NotificationConfig.Title
		Title.LayoutOrder = 2

		if NotificationConfig.Image then
			if typeof(NotificationConfig.Image) == "string" and Icons then
				local asset = getIcon(NotificationConfig.Image)
				Icon.Image = "rbxassetid://" .. asset.id
				Icon.ImageRectOffset = asset.imageRectOffset
				Icon.ImageRectSize = asset.imageRectSize
			else
				Icon.Image = getAssetUri(NotificationConfig.Image)
			end
		else
			Icon:Destroy()
			Title.Size = UDim2.new(1, 0, 0, 0)
		end

		local Content = Create("TextLabel", {
			Parent = contentHolder,
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(0, 0, 0, 28),
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.Y,
			Font = Enum.Font.GothamSemibold,
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			Text = NotificationConfig.Desc
		})

		local ProgressBarParent = Instance.new("Frame")
		ProgressBarParent.AnchorPoint = Vector2.new(0, 1)
		ProgressBarParent.Parent = NotificationFrame
		ProgressBarParent.Size = UDim2.new(1, 0, 0, 3)
		ProgressBarParent.Position = UDim2.new(0, 0, 1, 5)
		ProgressBarParent.BackgroundTransparency = 0
		ProgressBarParent.BackgroundColor3 = Color3.fromRGB(0, 128, 207)
		ProgressBarParent.BorderSizePixel = 0
		Instance.new("UICorner", ProgressBarParent).CornerRadius = UDim.new(0, 3)

		local ProgressBar = Instance.new("Frame")
		ProgressBar.Parent = ProgressBarParent
		ProgressBar.Size = UDim2.new(1, 0, 1, 0)
		ProgressBar.Position = UDim2.new(0, 0, 0, 0)
		ProgressBar.BackgroundTransparency = 0
		ProgressBar.BackgroundColor3 = Color3.fromRGB(0, 168, 247)
		ProgressBar.BorderSizePixel = 0
		Instance.new("UICorner", ProgressBar).CornerRadius = UDim.new(0, 3)

		TweenService:Create(NotificationFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = UDim2.new(0, 0, 0, 0)
		}):Play()

		local barTween = TweenService:Create(ProgressBar, TweenInfo.new(NotificationConfig.Time, Enum.EasingStyle.Linear), {
			Size = UDim2.new(0, 0, 1, 0)
		})
		barTween:Play()

		local function DismissNotification()
			if isDismissed then return end
			isDismissed = true

			barTween:Cancel()

			TweenService:Create(NotificationFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
				Position = UDim2.new(1, 50, 0, 0),
				BackgroundTransparency = 1
			}):Play()
			TweenService:Create(Stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
			TweenService:Create(Title, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
			TweenService:Create(Content, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
			TweenService:Create(ProgressBarParent, TweenInfo.new(0.1), {BackgroundTransparency = 1}):Play()
			TweenService:Create(ProgressBar, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
			if Icon and Icon.Parent then
				TweenService:Create(Icon, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
			end

			task.wait(0.3)

			NotificationParent.AutomaticSize = Enum.AutomaticSize.None
			NotificationParent.Size = UDim2.new(1, 0, 0, NotificationFrame.AbsoluteSize.Y)
			NotificationFrame:Destroy()

			local shrinkTween = TweenService:Create(NotificationParent, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Size = UDim2.new(1, 0, 0, 0)
			})
			shrinkTween:Play()
			shrinkTween.Completed:Wait()

			NotificationParent:Destroy()
		end

		closeNotifButton.MouseButton1Click:Connect(DismissNotification)

		task.delay(NotificationConfig.Time, function()
			if not isDismissed then
				DismissNotification()
			end
		end)
	end)
end

-- // Destroy Function \\ --
function library:Destroy()
    TurtleUiLib:Destroy()
    if keybindConnection then
        keybindConnection:Disconnect()
    end
end

local function uiKeybind(key, ui)
    if keybindConnection then keybindConnection:Disconnect() end

    keybindConnection = uis.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode[key] then
            ui.Visible = not ui.Visible
        end
    end)
end

local function makeFolderUI(option, parentFrame)
	local folderFrame = Instance.new("Frame")
	folderFrame.Name = option.title .. "_Folder"
	folderFrame.Size = UDim2.new(1, 0, 0, 33)
	folderFrame.AutomaticSize = Enum.AutomaticSize.Y
	folderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	folderFrame.Parent = parentFrame

	local header = Instance.new("TextButton")
	header.Size = UDim2.new(1, 0, 0, 30)
	header.Text = "> " .. option.title
	header.TextColor3 = Color3.fromRGB(200, 200, 200)
	header.Font = Enum.Font.GothamBold
	header.Parent = folderFrame

	local contentHolder = Instance.new("Frame")
	contentHolder.Size = UDim2.new(1, 0, 0, 0)
	contentHolder.AutomaticSize = Enum.AutomaticSize.Y
	contentHolder.Position = UDim2.new(0, 0, 0, 30)
	contentHolder.Visible = true
	contentHolder.Parent = folderFrame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 5)
	layout.Parent = contentHolder

	header.MouseButton1Click:Connect(function()
		contentHolder.Visible = not contentHolder.Visible
	end)

	option.Instance = folderFrame

	return contentHolder
end

function makeButton(option, parent)
	local btnFrame = Create("Frame", {
		Parent = parent,
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		Name = "_ButtonHolder_"
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
		TextXAlignment = Enum.TextXAlignment.Left,
		Active = false
	})

	function option:SetTitle(newTitle)
		ButtonTitle.Text = tostring(newTitle)
	end

	Button.MouseButton1Click:Connect(option.Callback)
	
	option.Instance = btnFrame
	return btnFrame
end

function makeLabel(option, parent)
	local labelFrame = Create("Frame", {
		Parent = parent,
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		Name = "_LabelHolder_"
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
		Active = false
	})

	function option:SetTitle(newTitle)
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
	
	option.Instance = Label
	return Label
end

function makeToggle(option, parent)
	local togFrame = Create("Frame", {
		Parent = parent,
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		Name = "_LabelHolder_"
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
		Active = false
	})

	local ToggleButton = Create("TextButton", {
		AnchorPoint = Vector2.new(1,0.5),
		Parent = togFrame,
		BackgroundTransparency = 1,
		Position = UDim2.new(1,0,0.5,0),
		Size = UDim2.new(0, 26, 0, 26),
		Name = "ToggleButton",
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
		Parent = ToggleButton,
		BackgroundColor3 = Color3.fromRGB(68, 189, 50),
		BorderSizePixel = 0,
		Visible = option.Default,
		Size = UDim2.new(1, 0, 1, 0)
	})

	function option:SetValue(state)
		self.State = state
		self.Default = state
		if self.Flag then
			library.Flags[self.Flag] = state
		end

		if type(self.Callback) == "function" then
			self.Callback(state)
		end

		if self.ToggleFiller then 
			self.ToggleFiller.Visible = state
		end
	end

	function option:SetTitle(newTitle)
		ToggleTitle.Text = tostring(newTitle)
	end

	ToggleButton.MouseButton1Click:Connect(function()
		if not option.Loop then
			option:SetValue(not option.Default)
		end
	end)

	if typeof(option.Loop) == "boolean" and option.Loop then
		local lastTick = 0

		game:GetService("RunService").Heartbeat:Connect(function()
			if option.Default then
				if os.clock() - lastTick >= option.Delay then
					lastTick = os.clock()
					task.spawn(function()
						option.Callback(option.Default)
					end)
				end
			else
				lastTick = 0
			end
		end)
	end
	
	if type(option.Default) == "boolean" and option.Default then
		task.delay(1, function()
			option:SetValue(true)
		end)
	end
	
	option.Instance = togFrame
	return togFrame
end

function makeBox(option, parent)
	local boxFrame = Create("Frame", {
		Parent = parent,
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		Name = "_BoxHolder_"
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
		TextXAlignment = Enum.TextXAlignment.Left,
		Active = false
	})

	local LastText = ""
	
	function option:SetValue(value)
		self.Default = value
		if self.Flag then
			library.Flags[self.Flag] = value
		end

		if type(self.Callback) == "function" then
			self.Callback(value)
		end
		
		if self.TextBox then
			self.TextBox.Text = value
		end
	end

	TextBox:GetPropertyChangedSignal('Text'):connect(function()
		if TextBox.Text ~= LastText then
			LastText = TextBox.Text
			option.Callback(TextBox.Text, false)
		end
	end)
	TextBox.FocusLost:Connect(function()
		option.Callback(TextBox.Text, true)
	end)
	
	function option:SetTitle(newTitle)
		BoxTitle.Text = tostring(newTitle)
	end
	
	option.Instance = boxFrame
	return boxFrame
end
--[[]
function makeSlider(SliConfig)
SliConfig = SliConfig or {}
SliConfig.Name = SliConfig.Name or "Slider"
SliConfig.Min = SliConfig.Min or 1
SliConfig.Max = SliConfig.Max or 100
SliConfig.Increment = SliConfig.Increment or 1
SliConfig.Default = math.clamp(SliConfig.Default, SliConfig.Min, SliConfig.Max)
SliConfig.Callback = SliConfig.Callback or function() end
local offset = 70
local defaultAlpha = (SliConfig.Default - SliConfig.Min) / (SliConfig.Max - SliConfig.Min)

local sliFrame = Instance.new("Frame")
sliFrame.Parent = contentParent
sliFrame.Size = UDim2.new(1, 0, 0, 60)
sliFrame.BackgroundTransparency = 1
sliFrame.Name = tostring(windowContentCount) .. "_SliderHolder_"
windowContentCount = windowContentCount + 1

local Slider = Instance.new("Frame")
local SliderButton = Instance.new("Frame")
local Description = Instance.new("TextLabel")
local SilderFiller = Instance.new("Frame")
local Current = Instance.new("TextBox")

local function snapToIncrement(val)
local stepped = math.round((val - SliConfig.Min) / SliConfig.Increment) * SliConfig.Increment + SliConfig.Min
return math.clamp(stepped, SliConfig.Min, SliConfig.Max)
end

local function updateSliderFromValue(val)
local snappedValue = snapToIncrement(val)
local alpha = (snappedValue - SliConfig.Min) / (SliConfig.Max - SliConfig.Min)

SliderButton.Position = UDim2.new(alpha, 0, -1.33333337, 0)
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

local rawValue = Lerp(SliConfig.Min, SliConfig.Max, alpha)
local snappedValue = snapToIncrement(rawValue)

local snappedAlpha = (snappedValue - SliConfig.Min) / (SliConfig.Max - SliConfig.Min)
SliderButton.Position = UDim2.new(snappedAlpha, 0, 0, 0)
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
local val = tonumber(Current.Text) or SliConfig.Default
SliConfig.Callback(val)
end
end

Slider.Name = "Slider"
Slider.Parent = sliFrame
Slider.Active = true
Slider.BackgroundColor3 = Color3.fromRGB(47, 54, 64)
Slider.BorderColor3 = Color3.fromRGB(113, 128, 147)
Slider.Position = UDim2.new(0, 0, 0.5, 0)
Slider.Size = UDim2.new(1, 0, 0, 6)
Slider.ZIndex = 2 + zindex
Slider.InputBegan:Connect(SliderMovement) 
Slider.InputEnded:Connect(SliderEnd)

SliderButton.AnchorPoint = Vector2.new(0.5, 0.5)
SliderButton.Position = UDim2.new(defaultAlpha, 0, 0, 0)
SliderButton.Name = "SliderButton"
SliderButton.Active = true
SliderButton.Parent = Slider
SliderButton.BackgroundColor3 = Color3.fromRGB(53, 59, 72)
SliderButton.BorderColor3 = Color3.fromRGB(113, 128, 147)
SliderButton.Size = UDim2.new(0, 6, 0, 22)
SliderButton.ZIndex = 3 + zindex
SliderButton.InputBegan:Connect(SliderMovement)
SliderButton.InputEnded:Connect(SliderEnd)    

Current.AnchorPoint = Vector2.new(1,0)
Current.Name = "Current"
Current.Parent = Slider
Current.BackgroundColor3 = Color3.fromRGB(35, 40, 48)
Current.BackgroundTransparency = 1
Current.BorderColor3 = Color3.fromRGB(113, 128, 147)
Current.Position = UDim2.new(1, 0, 0, -33)
Current.Size = UDim2.new(0, 45, 0, 20)
Current.Font = Enum.Font.SourceSans
Current.Text = tostring(SliConfig.Default)
Current.TextColor3 = Color3.fromRGB(220, 221, 225)
Current.TextSize = 14
Current.ZIndex = 2 + zindex
Current.ClearTextOnFocus = false

Current.FocusLost:Connect(function(enterPressed)
local inputNum = tonumber(Current.Text)
if inputNum then
local finalVal = updateSliderFromValue(inputNum)
SliConfig.Callback(finalVal)
else
Current.Text = tostring(snapToIncrement(Lerp(SliConfig.Min, SliConfig.Max, SliderButton.Position.X.Scale)))
end
end)

Description.AnchorPoint = Vector2.new(0, 0)
Description.Name = "Description"
Description.Parent = Slider
Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Description.BackgroundTransparency = 1.000
Description.Position = UDim2.new(0, 0, 0, -35)
Description.Size = UDim2.new(0, 180, 0, 21)
Description.Font = Enum.Font.SourceSans
Description.Text = SliConfig.Name
Description.TextColor3 = Color3.fromRGB(245, 246, 250)
Description.TextSize = 16
Description.TextXAlignment = Enum.TextXAlignment.Left
Description.ZIndex = 2 + zindex

SilderFiller.Name = "SilderFiller"
SilderFiller.Parent = Slider
SilderFiller.BackgroundColor3 = Color3.fromRGB(76, 209, 55)
SilderFiller.Size = UDim2.new(defaultAlpha, 0, 1, 0)
SilderFiller.ZIndex = 2 + zindex
end

-- // Dropdown Function \\ --
function Dropdown(DropConfig)
DropConfig = DropConfig or {}
DropConfig.Name = DropConfig.Name or "Dropdown"
DropConfig.Items = DropConfig.Items or {}
DropConfig.MultiSelect = DropConfig.MultiSelect or false
DropConfig.Floating = DropConfig.Floating or false
DropConfig.Callback = DropConfig.Callback or function() end

local droFrame = Instance.new("Frame")
droFrame.Parent = contentParent
droFrame.Size = UDim2.new(1, 0, 0, 32)
droFrame.BackgroundTransparency = 1
droFrame.AutomaticSize = Enum.AutomaticSize.Y
droFrame.Name = tostring(windowContentCount) .. "_DropdownHolder_"
windowContentCount = windowContentCount + 1

local droLayout = Instance.new("UIListLayout")
droLayout.FillDirection = Enum.FillDirection.Vertical
droLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
droLayout.VerticalAlignment = Enum.VerticalAlignment.Top
droLayout.Padding = UDim.new(0, 5)
droLayout.SortOrder = Enum.SortOrder.LayoutOrder
droLayout.Parent = droFrame

local Dropdown = Instance.new("TextButton")
local DroTitle = Instance.new("TextLabel")
local DownSign = Instance.new("TextLabel")
local DropdownFrame = Instance.new("ScrollingFrame")

Dropdown.AnchorPoint = Vector2.new(0,0)
Dropdown.Name = "Dropdown"
Dropdown.Parent = droFrame
Dropdown.BackgroundColor3 = Color3.fromRGB(53, 59, 72)
Dropdown.BorderColor3 = Color3.fromRGB(113, 128, 147)
Dropdown.Position = UDim2.new(0, 0, 0, 0)
Dropdown.Size = UDim2.new(1, 0, 0, 26)
Dropdown.Selected = true
Dropdown.Font = Enum.Font.SourceSans
Dropdown.Text = ""
Dropdown.ZIndex = 3 + zindex

DroTitle.Name = "Title"
DroTitle.Parent = Dropdown
DroTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
DroTitle.BackgroundTransparency = 1.000
DroTitle.Position = UDim2.new(0, 5, 0, 0)
DroTitle.Size = UDim2.new(1, -30, 1, 0)
DroTitle.Font = Enum.Font.SourceSans
DroTitle.Text = tostring(DropConfig.Name)
DroTitle.TextColor3 = Color3.fromRGB(245, 246, 250)
DroTitle.TextSize = 16
DroTitle.ZIndex = 4 + zindex
DroTitle.TextWrapped = false
DroTitle.TextXAlignment = Enum.TextXAlignment.Left
DroTitle.TextTruncate = Enum.TextTruncate.AtEnd

DownSign.AnchorPoint = Vector2.new(1,0.5)
DownSign.Name = "DownSign"
DownSign.Parent = Dropdown
DownSign.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
DownSign.BackgroundTransparency = 1.000
DownSign.Position = UDim2.new(1, -5, 0.5, 0)
DownSign.Size = UDim2.new(0, 27, 0, 22)
DownSign.Font = Enum.Font.SourceSans
DownSign.Text = "^"
DownSign.Rotation = 180
DownSign.TextColor3 = Color3.fromRGB(220, 221, 225)
DownSign.TextSize = 20.000
DownSign.ZIndex = 4 + zindex
DownSign.TextYAlignment = Enum.TextYAlignment.Bottom

local dragDropFrame = nil
if DropConfig.Floating then
dragDropFrame = Instance.new("Frame")
dragDropFrame.Parent = TurtleUiLib
dragDropFrame.Size = UDim2.new(0, 192, 0, 33)
dragDropFrame.BackgroundColor3 = Color3.fromRGB(53, 59, 72)
dragDropFrame.BorderColor3 = Color3.fromRGB(53, 59, 72)
dragDropFrame.Active = true
dragDropFrame.ZIndex = 10 + zindex
dragDropFrame.Visible = false

local dragDroTitle = Instance.new("TextLabel")
dragDroTitle.Name = "DragTitle"
dragDroTitle.Parent = dragDropFrame
dragDroTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
dragDroTitle.BackgroundTransparency = 1.000
dragDroTitle.Position = UDim2.new(0, 5, 0, 0)
dragDroTitle.Size = UDim2.new(1, -30, 1, 0)
dragDroTitle.Font = Enum.Font.SourceSans
dragDroTitle.Text = tostring(DropConfig.Name)
dragDroTitle.TextColor3 = Color3.fromRGB(245, 246, 250)
dragDroTitle.TextSize = 14
dragDroTitle.ZIndex = 10 + zindex
dragDroTitle.TextWrapped = false
dragDroTitle.Active = false
dragDroTitle.TextXAlignment = Enum.TextXAlignment.Left

MakeDraggable(dragDropFrame, dragDropFrame)
end
DropdownFrame.Name = "DropdownFrame"
DropdownFrame.Parent = DropConfig.Floating and dragDropFrame or droFrame
DropdownFrame.Active = true
DropdownFrame.BackgroundColor3 = Color3.fromRGB(53, 59, 72)
DropdownFrame.BorderColor3 = Color3.fromRGB(53, 59, 72)
DropdownFrame.Position = DropConfig.Floating and UDim2.new(0, 0, 1, 0) or UDim2.new(0, 0, 0, 26)
DropdownFrame.Size = UDim2.new(1, 0, 0, 0)
DropdownFrame.Visible = false
DropdownFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
DropdownFrame.ScrollBarThickness = 2
DropdownFrame.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left
DropdownFrame.ZIndex = 10 + zindex
DropdownFrame.ScrollingDirection = Enum.ScrollingDirection.Y
DropdownFrame.ScrollBarImageColor3 = Color3.fromRGB(220, 221, 225)

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = DropdownFrame
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 3)

local listPaddingLayout = Instance.new("UIPadding")
listPaddingLayout.Parent = DropdownFrame
listPaddingLayout.PaddingBottom = UDim.new(0, 5)
listPaddingLayout.PaddingTop = UDim.new(0, 5)
listPaddingLayout.PaddingRight = UDim.new(0, 5)
listPaddingLayout.PaddingLeft = UDim.new(0, 5)

local dropFunctions = {}
local selectedItems = {}
local selectedSingle = nil
local itemButtons = {}

table.insert(dropdowns, dropFunctions)

local function updateDropdownText()
if DropConfig.MultiSelect then
local chosenList = {}
for name, isSelected in pairs(selectedItems) do
if isSelected then
table.insert(chosenList, name)
end
end

if #chosenList > 0 then
DroTitle.Text = table.concat(chosenList, ", ")
else
DroTitle.Text = tostring(DropConfig.Name)
end
else
if selectedSingle then
DroTitle.Text = selectedSingle
else
DroTitle.Text = tostring(DropConfig.Name)
end
end
end
local function updateDropdownSize()
local contentHeight = listLayout.AbsoluteContentSize.Y + 10
DropdownFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight)

local maxHeight = math.min(contentHeight, 100)
DropdownFrame.Size = UDim2.new(1, 0, 0, maxHeight)
end

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateDropdownSize)

function dropFunctions:Close()
TweenService:Create(DownSign, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Rotation = 180}):Play()
if DropConfig.Floating then
dragDropFrame.Visible = false
end
DropdownFrame.Visible = false
end

function dropFunctions:Open()
for _, otherDrop in ipairs(dropdowns) do
if otherDrop ~= dropFunctions then
otherDrop:Close()
end
end

TweenService:Create(DownSign, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Rotation = 0}):Play()

if DropConfig.Floating then
dragDropFrame.Position = UDim2.fromOffset(Dropdown.AbsolutePosition.X, Dropdown.AbsolutePosition.Y)
dragDropFrame.Visible = true
DropdownFrame.Visible = true
else
DropdownFrame.Position = UDim2.fromOffset(Dropdown.AbsolutePosition.X, Dropdown.AbsolutePosition.Y + 2)
DropdownFrame.Visible = true
end
end
function dropFunctions:Button(name)
local name = name or ""
local Button_2 = Instance.new("TextButton")
Button_2.Name = "Button"
Button_2.Parent = DropdownFrame
Button_2.BackgroundColor3 = Color3.fromRGB(53, 59, 72)
Button_2.BorderColor3 = Color3.fromRGB(113, 128, 147)
Button_2.BorderSizePixel = 0
Button_2.Position = UDim2.new(0, 6, 0, 0)
Button_2.Size = UDim2.new(0, 180, 0, 26)
Button_2.Selected = true
Button_2.Font = Enum.Font.SourceSans
Button_2.TextColor3 = Color3.fromRGB(245, 246, 250)
Button_2.TextSize = 14
Button_2.TextStrokeTransparency = 123.000
Button_2.ZIndex = 11 + zindex
Button_2.Text = name
Button_2.TextWrapped = true
Button_2.TextTruncate = Enum.TextTruncate.AtEnd

local btn_2_stroke = Instance.new("UIStroke")
btn_2_stroke.Parent = Button_2
btn_2_stroke.Color = Color3.fromRGB(113, 128, 147)
btn_2_stroke.Thickness = 1
btn_2_stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

itemButtons[name] = Button_2

Button_2.MouseButton1Click:Connect(function()
if DropConfig.MultiSelect then
selectedItems[name] = not selectedItems[name]

if selectedItems[name] then
Button_2.BackgroundColor3 = Color3.fromRGB(76, 79, 92)
else
Button_2.BackgroundColor3 = Color3.fromRGB(53, 59, 72)
end

updateDropdownText()

local activeTable = {}
for itemName, isSelected in pairs(selectedItems) do
if isSelected then
table.insert(activeTable, itemName)
end
end
DropConfig.Callback(activeTable)
else
if selectedSingle == name then
selectedSingle = nil
Button_2.BackgroundColor3 = Color3.fromRGB(53, 59, 72)
updateDropdownText()
DropConfig.Callback(nil)
else
if selectedSingle and itemButtons[selectedSingle] then
itemButtons[selectedSingle].BackgroundColor3 = Color3.fromRGB(53, 59, 72)
end

selectedSingle = name
Button_2.BackgroundColor3 = Color3.fromRGB(76, 79, 92)
updateDropdownText()
DropConfig.Callback(name)
end
end
end)
end
function dropFunctions:Remove(name)
if selectedSingle == name then
selectedSingle = nil
end
selectedItems[name] = nil
itemButtons[name] = nil
updateDropdownText()

for _, v in pairs(DropdownFrame:GetChildren()) do
if v:IsA("TextButton") and v.Text == name then
v:Destroy()
break
end
end
end
function dropFunctions:AddPlaceholder(labelText)
local PlaceholderLabel = Instance.new("TextLabel")
PlaceholderLabel.Name = "Placeholder"
PlaceholderLabel.Parent = DropdownFrame
PlaceholderLabel.BackgroundColor3 = Color3.fromRGB(53, 59, 72)
PlaceholderLabel.BorderSizePixel = 0
PlaceholderLabel.Size = UDim2.new(0, 180, 0, 26)
PlaceholderLabel.Position = UDim2.new(0, 6, 0, 0)
PlaceholderLabel.Font = Enum.Font.SourceSansItalic
PlaceholderLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
PlaceholderLabel.TextSize = 14
PlaceholderLabel.Text = tostring(labelText)
PlaceholderLabel.ZIndex = 11 + zindex
PlaceholderLabel.TextWrapped = true
PlaceholderLabel.TextXAlignment = Enum.TextXAlignment.Left
end

for _, item in ipairs(DropConfig.Items) do
if typeof(item) == "string" then
dropFunctions:Button(item)
elseif typeof(item) == "table" and item.PlaceHolder then
dropFunctions:AddPlaceholder(item.PlaceHolder)
end
end

Dropdown.MouseButton1Click:Connect(function()
if DropdownFrame.Visible or (dragDropFrame ~= nil and dragDropFrame.Visible) then
dropFunctions:Close()
else
dropFunctions:Open()
end
end)

return dropFunctions
end

function ColorPicker(ColConfig)
ColConfig = ColConfig or {}
ColConfig.Name = ColConfig.Name or "Color picker"
ColConfig.Default = ColConfig.Default or Color3.fromRGB(255, 0, 0)
ColConfig.Floating = ColConfig.Floating or false
ColConfig.Callback = ColConfig.Callback or function() end

local colFrame = Instance.new("Frame")
colFrame.Parent = contentParent
colFrame.Size = UDim2.new(1, 0, 0, 32)
colFrame.BackgroundTransparency = 1
colFrame.AutomaticSize = Enum.AutomaticSize.Y
colFrame.Name = tostring(windowContentCount) .. "_ColorPickerHolder_"
windowContentCount = windowContentCount + 1

local colLayout = Instance.new("UIListLayout")
colLayout.FillDirection = Enum.FillDirection.Vertical
colLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
colLayout.VerticalAlignment = Enum.VerticalAlignment.Top
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

ColorPicker.AnchorPoint = Vector2.new(1,0.5)
ColorPicker.Name = "ColorPicker"
ColorPicker.Parent = PickerDescription
ColorPicker.Position = UDim2.new(1, 0, 0.5, 0)
ColorPicker.Size = UDim2.new(0, 57, 1, 0)
ColorPicker.Font = Enum.Font.SourceSans
ColorPicker.Text = ""
ColorPicker.TextColor3 = Color3.fromRGB(0, 0, 0)
ColorPicker.TextSize = 14
ColorPicker.ZIndex = 2 + zindex

PickerCorner.Parent = ColorPicker
PickerCorner.Name = "PickerCorner"
PickerCorner.CornerRadius = UDim.new(0,2)

PickerDescription.AnchorPoint = Vector2.new(0,0.5)
PickerDescription.Name = "PickerDescription"
PickerDescription.Parent = colFrame
PickerDescription.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
PickerDescription.BackgroundTransparency = 1.000
PickerDescription.Position = UDim2.new(0, 0, 0.5, 0)
PickerDescription.Size = UDim2.new(1, 0, 0, 26)
PickerDescription.Font = Enum.Font.SourceSans
PickerDescription.Text = ColConfig.Name
PickerDescription.TextColor3 = Color3.fromRGB(245, 246, 250)
PickerDescription.TextSize = 16
PickerDescription.TextXAlignment = Enum.TextXAlignment.Left
PickerDescription.ZIndex = 2 + zindex

local dragColFrame = nil
if ColConfig.Floating then
dragColFrame = Instance.new("Frame")
dragColFrame.Parent = TurtleUiLib
dragColFrame.Size = UDim2.new(0, 192, 0, 33)
dragColFrame.BackgroundColor3 = Color3.fromRGB(53, 59, 72)
dragColFrame.BorderColor3 = Color3.fromRGB(53, 59, 72)
dragColFrame.Active = true
dragColFrame.ZIndex = 10 + zindex
dragColFrame.Visible = false

local dragColTitle = Instance.new("TextLabel")
dragColTitle.Name = "DragTitle"
dragColTitle.Parent = dragColFrame
dragColTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
dragColTitle.BackgroundTransparency = 1.000
dragColTitle.Position = UDim2.new(0, 5, 0, 0)
dragColTitle.Size = UDim2.new(1, -30, 1, 0)
dragColTitle.Font = Enum.Font.SourceSans
dragColTitle.Text = tostring(ColConfig.Name)
dragColTitle.TextColor3 = Color3.fromRGB(245, 246, 250)
dragColTitle.TextSize = 14
dragColTitle.ZIndex = 10 + zindex
dragColTitle.TextWrapped = false
dragColTitle.Active = false
dragColTitle.TextXAlignment = Enum.TextXAlignment.Left

local colPaddingLayout = Instance.new("UIPadding")
colPaddingLayout.Parent = ColorPickerFrame
colPaddingLayout.PaddingBottom = UDim.new(0, 5)
colPaddingLayout.PaddingTop = UDim.new(0, 5)
colPaddingLayout.PaddingRight = UDim.new(0, 5)
colPaddingLayout.PaddingLeft = UDim.new(0, 5)

MakeDraggable(dragColFrame, dragColFrame)
end

ColorPickerFrame.Name = "ColorPickerFrame"
ColorPickerFrame.Parent = ColConfig.Floating and dragColFrame or colFrame
ColorPickerFrame.BackgroundColor3 = Color3.fromRGB(47, 54, 64)
ColorPickerFrame.BorderColor3 = Color3.fromRGB(47, 54, 64)
ColorPickerFrame.Position = ColConfig.Floating and UDim2.new(0, 0, 1, 0) or UDim2.new(0, 0, 0, 31)
ColorPickerFrame.Size = UDim2.new(1, 0, 0, 155)
ColorPickerFrame.ZIndex = 10 + zindex
ColorPickerFrame.Active = true
ColorPickerFrame.Visible = false

ToggleRGB.AnchorPoint = Vector2.new(1,0)
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
ToggleRGB.ZIndex = 10 + zindex

ToggleFiller_2.Name = "ToggleFiller"
ToggleFiller_2.Parent = ToggleRGB
ToggleFiller_2.BackgroundColor3 = Color3.fromRGB(76, 209, 55)
ToggleFiller_2.BorderColor3 = Color3.fromRGB(47, 54, 64)
ToggleFiller_2.Position = UDim2.new(0, 5, 0, 5)
ToggleFiller_2.Size = UDim2.new(0, 12, 0, 12)
ToggleFiller_2.ZIndex = 10 + zindex
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
TextLabel.ZIndex = 10 + zindex

CanvasGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))}
CanvasGradient.Name = "CanvasGradient"
CanvasGradient.Parent = Canvas

BlackOverlay.Name = "BlackOverlay"
BlackOverlay.Parent = Canvas
BlackOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BlackOverlay.BackgroundTransparency = 1.000
BlackOverlay.Size = UDim2.new(1, 0, 1, 0)
BlackOverlay.Image = "rbxassetid://5107152095"
BlackOverlay.ZIndex = 10 + zindex

UICorner.Parent = Canvas
UICorner.Name = "UICorner"
UICorner.CornerRadius = UDim.new(0,2)

Cursor.Name = "Cursor"
Cursor.Parent = Canvas
Cursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Cursor.BackgroundTransparency = 1.000
Cursor.Size = UDim2.new(0, 8, 0, 8)
Cursor.Image = "rbxassetid://5100115962"
Cursor.ZIndex = 10 + zindex

local draggingColor = false
local hue = 0
local sat = 1
local brightness = 1

local con

-- Helper untuk buat TextBox RGB dengan cepat
local function createRGBBox(name, xOffset, defaultText)
local box = Instance.new("TextBox")
box.Name = name
box.Parent = ColorPickerFrame
box.BackgroundColor3 = Color3.fromRGB(53, 59, 72)
box.Position = UDim2.new(0, xOffset, 0, 97)
box.Size = UDim2.new(0, 32, 0, 22)
box.Font = Enum.Font.SourceSans
box.Text = defaultText
box.TextColor3 = Color3.fromRGB(245, 246, 250)
box.TextSize = 13
box.ZIndex = 10 + zindex
box.ClearTextOnFocus = false

local stroke = Instance.new("UIStroke")
stroke.Parent = box
stroke.Color = Color3.fromRGB(113, 128, 147)
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

return box
end

local RInput = createRGBBox("RInput", 5, "255")
local GInput = createRGBBox("GInput", 42, "0")
local BInput = createRGBBox("BInput", 79, "0")

RInput.Position = UDim2.new(0, 0, 0, 85)
GInput.Position = UDim2.new(0, 36, 0, 85)
BInput.Position = UDim2.new(0, 72, 0, 85)

local function setRGBText(color)
RInput.Text = tostring(math.round(color.R * 255))
GInput.Text = tostring(math.round(color.G * 255))
BInput.Text = tostring(math.round(color.B * 255))
end

if ColConfig.Default and type(ColConfig.Default) == "boolean" then
ToggleFiller_2.Visible = true
if ToggleFiller_2.Visible then
con = stepped:Connect(function()
if ToggleFiller_2.Visible then
local hue2 = tick() % 5 / 5
color3 = Color3.fromHSV(hue2, 1, 1)
ColConfig.Callback(color3)
ColorPicker.BackgroundColor3 = color3
else
con:Disconnect()
end
end)
end
else
ColorPicker.BackgroundColor3 = ColConfig.Default or Color3.fromRGB(0, 168, 255)
setRGBText(ColorPicker.BackgroundColor3)
end

Canvas.Name = "Canvas"
Canvas.Parent = ColorPickerFrame
Canvas.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Canvas.Position = UDim2.new(0, 0, 0, 0)
Canvas.Size = UDim2.new(1, -32, 0, 80)
Canvas.Active = true
Canvas.ZIndex = 10 + zindex

CanvasGradient.Color = ColorSequence.new{
ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), 
ColorSequenceKeypoint.new(1.00, Color3.fromHSV(0, 1, 1))
}

Canvas.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
if activeInteraction ~= nil then return end
activeInteraction = Canvas

local moveConn, releaseConn

local function updateCanvas(inputObj)
local relX = math.clamp((inputObj.Position.X - Canvas.AbsolutePosition.X) / Canvas.AbsoluteSize.X, 0, 1)
local relY = math.clamp((inputObj.Position.Y - Canvas.AbsolutePosition.Y) / Canvas.AbsoluteSize.Y, 0, 1)

sat = relX
brightness = 1 - relY
color3 = Color3.fromHSV(hue, sat, brightness)

Cursor.Position = UDim2.fromOffset(relX * Canvas.AbsoluteSize.X - 4, relY * Canvas.AbsoluteSize.Y - 4)
ColorPicker.BackgroundColor3 = color3
setRGBText(color3)
ColConfig.Callback(color3)
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
moveConn:Disconnect()
releaseConn:Disconnect()
end
end)
end
end)

Color.Name = "Color"
Color.Parent = ColorPickerFrame
Color.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Color.Position = UDim2.new(1, -25, 0, 0)
Color.Size = UDim2.new(0, 25, 0, 80)
Color.BorderMode = Enum.BorderMode.Inset
Color.Active = true
Color.ZIndex = 10 + zindex

Color.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
if activeInteraction ~= nil then return end
activeInteraction = Color

local moveConn, releaseConn

local function updateHue(inputObj)
local relY = math.clamp((inputObj.Position.Y - Color.AbsolutePosition.Y) / Color.AbsoluteSize.Y, 0, 1)
hue = relY

CanvasGradient.Color = ColorSequence.new{
ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)),
ColorSequenceKeypoint.new(1.00, Color3.fromHSV(hue, 1, 1))
}

ColorSlider.Position = UDim2.new(0, -1, 0, math.clamp(relY * Color.AbsoluteSize.Y - 1, 0, Color.AbsoluteSize.Y - 3))

color3 = Color3.fromHSV(hue, sat, brightness)
ColorPicker.BackgroundColor3 = color3
setRGBText(color3)
ColConfig.Callback(color3)
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
moveConn:Disconnect()
releaseConn:Disconnect()
end
end)
end
end)

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
ColorCorner.CornerRadius = UDim.new(0,2)

ColorSlider.Name = "ColorSlider"
ColorSlider.Parent = Color
ColorSlider.BackgroundColor3 = Color3.fromRGB(245, 246, 250)
ColorSlider.BorderColor3 = Color3.fromRGB(245, 246, 250)
ColorSlider.Position = UDim2.new(0, -1, 0, 0)
ColorSlider.Size = UDim2.new(1, 2, 0, 3)
ColorSlider.Active = true
ColorSlider.ZIndex = 10 + zindex

local colorFuncs = {}

table.insert(colorPickers, colorFuncs)

local function updateFromRGB()
local r = math.clamp(tonumber(RInput.Text) or 0, 0, 255)
local g = math.clamp(tonumber(GInput.Text) or 0, 0, 255)
local b = math.clamp(tonumber(BInput.Text) or 0, 0, 255)

local newColor = Color3.fromRGB(r, g, b)
local h, s, v = Color3.toHSV(newColor)
hue, sat, brightness = h, s, v

-- Update Posisi UI Visual
CanvasGradient.Color = ColorSequence.new{
ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)),
ColorSequenceKeypoint.new(1.00, Color3.fromHSV(hue, 1, 1))
}
Cursor.Position = UDim2.fromOffset(sat * Canvas.AbsoluteSize.X - 4, (1 - brightness) * Canvas.AbsoluteSize.Y - 4)
ColorSlider.Position = UDim2.new(0, -1, 0, hue * Color.AbsoluteSize.Y)
ColorPicker.BackgroundColor3 = newColor

setRGBText(newColor)
ColConfig.Callback(newColor)
end

function colorFuncs:UpdateColorPicker(color)
if type(color) == "userdata" then
ToggleFiller_2.Visible = false
ColorPicker.BackgroundColor3 = color
elseif color and type(color) == "boolean" and not con then
ToggleFiller_2.Visible = true
con = stepped:Connect(function()
if ToggleFiller_2.Visible then
local hue2 = tick() % 5 / 5
color3 = Color3.fromHSV(hue2, 1, 1)
ColConfig.Callback(color3)
ColorPicker.BackgroundColor3 = color3
else
con:Disconnect()
end
end)
end
end
function colorFuncs:Close()
if ColConfig.Floating then
dragColFrame.Visible = false
end
ColorPickerFrame.Visible = false
end

function colorFuncs:Open()
for _, otherCol in ipairs(colorPickers) do
if otherCol ~= dropFunctions then
otherCol:Close()
end
end

if ColConfig.Floating then
dragColFrame.Position = UDim2.fromOffset(colFrame.AbsolutePosition.X, colFrame.AbsolutePosition.Y)
dragColFrame.Visible = true
ColorPickerFrame.Visible = true
else
ColorPickerFrame.Visible = true
end
end

RInput.FocusLost:Connect(updateFromRGB)
GInput.FocusLost:Connect(updateFromRGB)
BInput.FocusLost:Connect(updateFromRGB)

ToggleRGB.MouseButton1Down:Connect(function()
ToggleFiller_2.Visible = not ToggleFiller_2.Visible
if ToggleFiller_2.Visible then
con = stepped:Connect(function()
if ToggleFiller_2.Visible then
local hue2 = tick() % 5 / 5
color3 = Color3.fromHSV(hue2, 1, 1)
ColConfig.Callback(color3, true)
ColorPicker.BackgroundColor3 = color3
else
con:Disconnect()
end
end)
end
end)

ColorPicker.MouseButton1Click:Connect(function()
if ColorPickerFrame.Visible then
colorFuncs:Close()
else
colorFuncs:Open()
end
end)

return colorFuncs
end
]]

local function injectElements(targetContainer)
	targetContainer.options = targetContainer.options or {}

	function targetContainer:AddToggle(config)
		config = type(config) == "table" and config or {}
		config.type = "toggle"
		config.Title = config.text or "Toggle"
		config.Default = config.Default or false
		config.Flag = config.Flag or config.Title
		config.Callback = config.Callback or function() end

		registerFlag(config)

		table.insert(self.options, config)
		return config
	end

	function targetContainer:AddButton(config)
		config = type(config) == "table" and config or {}
		config.type = "button"
		config.Title = config.Title or "Button"
		config.Callback = config.Callback or function() end

		table.insert(self.options, config)
		return config
	end

	function targetContainer:AddLabel(config)
		config = type(config) == "table" and config or {}
		config.type = "label"
		config.Title = config.Title or "Label"
		config.XAlignment = config.XAlignment or "Left"
		config.Color = config.Color or Color3.new(1,1,1)
		
		table.insert(self.options, config)
		return config
	end
	
	function targetContainer:AddTextBox(config)
		config = type(config) == "table" and config or {}
		config.type = "box"
		config.Title = config.Title or "TextBox"
		config.Default = config.Default or ""
		config.Flag = config.Flag or config.Title
		config.Callback = config.Callback or function() end
		
		registerFlag(config)
		
		table.insert(self.options, config)
		return config
	end

	function targetContainer:AddFolder(title)
		local folder = {
			type = "folder",
			title = title or "Folder",
			options = {}
		}

		injectElements(folder)

		table.insert(self.options, folder)
		return folder
	end
end

local function renderOptions(optionsList, parentContainerFrame)
	for _, option in ipairs(optionsList) do
		if option.type == "button" then
			makeButton(option, parentContainerFrame)

		elseif option.type == "label" then
			makeLabel(option, parentContainerFrame)

		elseif option.type == "toggle" then
			makeToggle(option, parentContainerFrame)

		elseif option.type == "box" then
			makeBox(option, parentContainerFrame)

		elseif option.type == "folder" then
			local folderContentContainer = makeFolderUI(option, parentContainerFrame)

			renderOptions(option.options, folderContentContainer)
		end
	end
end

function library:CreateWindow(WinConfig)
	WinConfig = WinConfig or {}
	WinConfig.Title = WinConfig.Title or "TurtleUiLib"
	WinConfig.SubTitle = WinConfig.SubTitle or "Ui Library V2"
	WinConfig.Size = WinConfig.Size or UDim2.new(0,220,0,288)
	WinConfig.MultiWindow = WinConfig.MultiWindow or true
	WinConfig.Keybind = WinConfig.Keybind or "LeftControl"
	WinConfig.MobileUI = WinConfig.MobileUI or false
	WinConfig.MobileUIText = WinConfig.MobileUIText or "Show TurtleUiLib"
	WinConfig.Position = WinConfig.Position or UDim2.new(0, xOffset, 0, 20)
	WinConfig.ContentFillDirection = WinConfig.ContentFillDirection or "Vertical"
	WinConfig.AutoInit = WinConfig.AutoInit or true
	if typeof(WinConfig.Theme) == "string" and (WinConfig.Theme and WinConfig.Theme ~= "") then
		library.SelectedTheme = WinConfig.Theme
	end
	
	if WinConfig.MultiWindow then
    	windowCount = windowCount + 1
    	winCount = windowCount
    	zindex = zindex * winCount
   	else
   		if gethui then
   			for _, Interface in ipairs(gethui():GetChildren()) do
				if Interface.Name == TurtleUiLib.Name and Interface ~= TurtleUiLib then
					Interface:Destroy()
				end
			end
   		end
	end
	
	local UiWindow = Create("Frame", {
    	Name = "UiWindow",
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

	local HeaderTextHolder = Create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Name = "Header",
		Parent = Header,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 5, 0.5, 0),
		Size = UDim2.new(1, -67, 1, 0),
		ZIndex = 5 + zindex,
		Active = true
	})

	Create("UIListLayout", {
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
		Size = UDim2.new(1, 0, 0.5, 0),
		Position = UDim2.new(0, 0, 0, 0),
		Font = Enum.Font.SourceSansBold,
		TextSize = 16,
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
		Size = UDim2.new(1, 0, 0.5, 0),
		Position = UDim2.new(0, 0, 0, 0),
		Font = Enum.Font.SourceSansBold,
		TextSize = 15,
		BackgroundTransparency = 1,
		Text = WinConfig.SubTitle,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 6 + zindex,
		Active = false
	})
    AddThemeObject(SubHeaderText, "SubHeaderText", "TextColor3")
    
    if not WinConfig.SubTitle or WinConfig.SubTitle == nil then
    	HeaderText.Size = UDim2.new(1,0,1,0)
    end

	MakeDraggable(Header, UiWindow)
	
	local Window = Create("Frame", {
		Name = "Window",
		Parent = UIWindow,
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
		VerticalAlignment = Enum.VerticalAlignment.Center,
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
	
	if UiWindow.Size.X.Offset >= 400 then
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
			Position = UDim2.new(0.5, 0, 0, -23),
			BackgroundTransparency = 1,
        	Visible = false
		})
		AddThemeObject(MobileUIToggle, "WindowBackground", "BackgroundColor3")
        local MobileUIButton = Create("TextButton", {
        	Parent = MobileUIToggle,
            AutomaticSize = Enum.AutomaticSize.X,
            Name = "Click",
            BackgroundTransparency = 0.05,
            Size = UDim2.new(1, 0, 1, 0)
		})
		AddThemeObject(MobileUIButton, "WindowBackground", "BackgroundColor3")
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
		Visible = true,
		Active = true
	})

	local TabHolderListLayout = Create("UIListLayout", {
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
	contentArea.Position = UDim2.new(0, 0, 0, 0)
	contentArea.Size = UDim2.new(1, -135, 1, 0)
	contentArea.Parent = Window

	local window = {
		gui = TurtleUiLib,
		mainFrame = UiWindow,
		contentArea = contentArea,
		sidebarFrame = TabHolder,
		tabs = {},
		options = {},
		isInitialized = false,
		isTabMode = false,
		activeTab = nil
	}

	injectElements(window)

	function window:AddTab(TabConfig)
		TabConfig = TabConfig or {}
		TabConfig.Title = TabConfig.Title or "Main"
		TabConfig.Icon = TabConfig.Icon or "sword"
		window.isTabMode = true

		local tab = {
			type = "tab",
			title = TabConfig.Title,
			options = {},
			rendered = false,
			buttonInstance = nil,
			containerInstance = nil
		}

		injectElements(tab)
		
		local tabButton = Create("TextButton", {
			Name = TabConfig.Title .. "_TabButton_",
			Parent = window.sidebarFrame,
			BackgroundColor3 = Color3.fromRGB(25,25,25),
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Position = UDim2.new(0,0,0,0),
			Size = UDim2.new(0.24,0,0,30),
			Font = Enum.Font.GothamSemibold,
			TextTransparency = 1,
			Visible = true,
			Active = true
		})

		local ListLayouttt = Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Left,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = tabContainer
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
			Parent = textHolder
		})

		if TabConfig.Icon then
			if typeof(TabConfig.Icon) == "string" and Icons then
				local asset = getIcon(TabConfig.Icon)
				Iccon.Image = "rbxassetid://" .. asset.id
				Iccon.ImageRectOffset = asset.imageRectOffset
				Iccon.ImageRectSize = asset.imageRectSize
			else
				Iccon.Image = getAssetUri(TabConfig.Icon)
			end
		else
			Iccon:Destroy()
		end

		local tabButtonTitle = Create("TextLabel", {
			LayoutOrder = 2,
			Parent = tabButton,
			BackgroundColor3 = Color3.fromRGB(25,25,25),
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Position = UDim2.new(0,0,0,0),
			Size = UDim2.new(0.24,0,1,0),
			Font = Enum.Font.GothamSemibold,
			Text = TabConfig.Title,
			TextSize = 14,
			Visible = true,
			Active = true
		})
		tab.buttonInstance = tabButton
		
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
			Size = UDim2.new(1,0,1,0),
			Visible = false,
			Active = true
		})

		local PaddingLayouttt = Create("UIPadding", {
			PaddingBottom = UDim.new(0, 5),
			PaddingTop = UDim.new(0, 5),
			PaddingRight = UDim.new(0, 5),
			PaddingLeft = UDim.new(0, 5),
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

		function tab:Select()
			for _, otherTab in ipairs(window.tabs) do
				if otherTab.containerInstance then
					otherTab.containerInstance.Visible = false
				end
				if otherTab.buttonInstance then
					otherTab.buttonInstance.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				end
			end

			if not tab.rendered then
				renderOptions(tab.options, tab.containerInstance)
				tab.rendered = true
			end

			tab.containerInstance.Visible = true
			tab.buttonInstance.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
			window.activeTab = tab
		end

		tabButton.MouseButton1Click:Connect(function()
			tab:Select()
		end)

		table.insert(window.tabs, tab)

		if #window.tabs == 1 then
			tab:Select()
		end

		return tab
	end

	function window:Init()
		if window.isInitialized then return end
		window.isInitialized = true
		if not window.isTabMode then
			window.sidebarFrame.Visible = false
			window.contentArea.Position = UDim2.new(0, 0, 0, 0)
			window.contentArea.Size = UDim2.new(1, 0, 1, 0)

			local WindowScroll = Create("ScrollingFrame", {
				Name = "Scroll",
				Parent = window.contentArea,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				CanvasSize = UDim2.new(0,0,0,0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				ScrollBarThickness = 0,
				ElasticBehavior = Enum.ElasticBehavior.Never,
				Size = UDim2.new(1,0,1,0),
				ZIndex = 1 + zindex,
				Visible = true,
				Active = true
			})

			local winPaddingLayout = Create("UIPadding", {
				PaddingBottom = UDim.new(0, 5),
				PaddingTop = UDim.new(0, 5),
				PaddingRight = UDim.new(0, 5),
				PaddingLeft = UDim.new(0, 5),
				Parent = WindowScroll
			})

			local winLayout = Create("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				Padding = UDim.new(0, 6),
				SortOrder = Enum.SortOrder.LayoutOrder,
				Parent = WindowScroll
			})

			renderOptions(window.options, WindowScroll)
		end
	end
	
	if WinConfig.AutoInit ~= false then
		task.defer(function()
			if not window.isTabMode and not window.isInitialized then
				window:Init()
			end
		end)
	end
	return window
end


return library