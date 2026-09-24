-- // Credits to Intrer#0421 for the source \\ --
-- // This UI is updated by me (LucidSc1pt) with some vibecode \\ --

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
			NotificationBarHolder = Color3.fromRGB(0,108,187),
			
			ElementDivider = Color3.fromRGB(60, 60, 70),
			ElementDividerText = Color3.fromRGB(60, 60, 70),
			
			TabDivider = Color3.fromRGB(60, 60, 70),
			TabDividerText = Color3.fromRGB(60, 60, 70),
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
TurtleUiLib.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
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
		NotificationConfig.Content = NotificationConfig.Content or "Hello World"
		NotificationConfig.Image = NotificationConfig.Image or 4384403532
		NotificationConfig.Time = NotificationConfig.Time or 5

		local isDismissed = false

		local NotificationParent = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			ClipsDescendants = false,
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

		local NotificationFrame_Stroke = Create("UIStroke", {
			Parent = NotificationFrame,
			Thickness = 1,
			Color = Color3.fromRGB(0, 168, 247),
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
			Size = UDim2.new(1, 0, 1, -5),
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
			Size = UDim2.new(1,-25, 0, 0),
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
		ProgressBarParent.BackgroundColor3 = Color3.fromRGB(0, 108, 187)
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
			TweenService:Create(NotificationFrame_Stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
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

local function makeGroupUI(option, parentContainer)
	local groupFrame = Instance.new("Frame")
	groupFrame.Name = option.Title .. "_Group"
	groupFrame.Size = UDim2.new(1, 0, 0, 0)
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

	local header = Instance.new("TextButton")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 30)
	header.BackgroundTransparency = 1
	header.Text = ""
	header.Parent = groupFrame

	local headerTitle = Instance.new("TextLabel")
	headerTitle.Name = "Title"
	headerTitle.Size = UDim2.new(1, -30, 1, 0)
	headerTitle.Position = UDim2.new(0, 10, 0, 0)
	headerTitle.BackgroundTransparency = 1
	headerTitle.Font = Enum.Font.SourceSansBold
	headerTitle.Text = tostring(option.Title)
	headerTitle.TextColor3 = Color3.fromRGB(245, 246, 250)
	headerTitle.TextSize = 15
	headerTitle.TextXAlignment = Enum.TextXAlignment.Left
	headerTitle.Parent = header

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
	contentLayout.Padding = UDim.new(0, 6)
	contentLayout.Parent = contentHolder

	local contentPadding = Instance.new("UIPadding")
	contentPadding.PaddingLeft = UDim.new(0, 8)
	contentPadding.PaddingRight = UDim.new(0, 8)
	contentPadding.PaddingBottom = UDim.new(0, 8)
	contentPadding.Parent = contentHolder

	if option.Collapsible then
		local arrow = Instance.new("TextLabel")
		arrow.Name = "Arrow"
		arrow.Size = UDim2.new(0, 20, 1, 0)
		arrow.Position = UDim2.new(1, -25, 0, 0)
		arrow.BackgroundTransparency = 1
		arrow.Font = Enum.Font.SourceSansBold
		arrow.Text = option.Open and "v" or ">"
		arrow.TextColor3 = Color3.fromRGB(180, 180, 180)
		arrow.TextSize = 14
		arrow.Parent = header

		header.MouseButton1Click:Connect(function()
			option.Open = not option.Open
			contentHolder.Visible = option.Open
			arrow.Text = option.Open and "v" or ">"
		end)
	end

	renderOptions(option.options, contentHolder)

	option.Instance = groupFrame
	return groupFrame
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
	colLayout.Padding = UDim.new(0, 6)
	colLayout.Parent = columnsFrame

	local columnWidth = (1 / #option.Columns)

	for i, colData in ipairs(option.Columns) do
		local colFrame = Instance.new("Frame")
		colFrame.Name = "Column_" .. i
		colFrame.Size = UDim2.new(columnWidth, -(((#option.Columns - 1) * 6) / #option.Columns), 0, 0)
		colFrame.AutomaticSize = Enum.AutomaticSize.Y
		colFrame.BackgroundTransparency = 1
		colFrame.Parent = columnsFrame

		local listLayout = Instance.new("UIListLayout")
		listLayout.FillDirection = Enum.FillDirection.Vertical
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder
		listLayout.Padding = UDim.new(0, 6)
		listLayout.Parent = colFrame

		renderOptions(colData.options, colFrame)
	end

	option.Instance = columnsFrame
	return columnsFrame
end

local function makeRowUI(option, parentContainer)
	local rowFrame = Instance.new("Frame")
	rowFrame.Name = "RowHolder"
	rowFrame.Size = UDim2.new(1, 0, 0, 0)
	rowFrame.AutomaticSize = Enum.AutomaticSize.Y
	rowFrame.BackgroundTransparency = 1
	rowFrame.Parent = parentContainer

	local rowLayout = Instance.new("UIListLayout")
	rowLayout.FillDirection = Enum.FillDirection.Horizontal
	rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
	rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	rowLayout.Padding = UDim.new(0, option.Padding)
	rowLayout.Parent = rowFrame

	renderOptions(option.options, rowFrame)

	option.Instance = rowFrame
	return rowFrame
end

local function makeGridUI(option, parentContainer)
	local gridFrame = Instance.new("Frame")
	gridFrame.Name = "GridHolder"
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

	renderOptions(option.options, gridFrame)

	option.Instance = gridFrame
	return gridFrame
end

function makeButton(option, parent)
	local btnFrame = Create("Frame", {
		Parent = parent,
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		ZIndex = 12 + zindex,
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
		ZIndex = 12 + zindex,
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
		ZIndex = 12 + zindex,
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
		ZIndex = 12 + zindex,
		Name = "_ToggleHolder_"
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

	function option:SetValue(state)
		self.Default = state
		if self.Flag then
			library.Flags[self.Flag] = state
		end

		if not self.Loop and type(self.Callback) == "function" then
			self.Callback(state)
		end

		if ToggleFiller then 
			ToggleFiller.Visible = state
		end
	end

	function option:SetTitle(newTitle)
		ToggleTitle.Text = tostring(newTitle)
	end

	ToggleButton.MouseButton1Click:Connect(function()
		option:SetValue(not option.Default)
	end)

	if typeof(option.Loop) == "boolean" and option.Loop == true then
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
		Name = "_BoxHolder_",
		ZIndex = 12 + zindex
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

	local LastText = ""
	
	function option:SetValue(value)
		self.Default = value
		if self.Flag then
			library.Flags[self.Flag] = value
		end

		if type(self.Callback) == "function" then
			self.Callback(value)
		end
		
		if TextBox then
			TextBox.Text = value
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

function makeSlider(option, parent)
	local offset = 70
	local defaultAlpha = (option.Default - option.Min) / (option.Max - option.Min)

	local sliFrame = Instance.new("Frame")
	sliFrame.Parent = parent
	sliFrame.Size = UDim2.new(1, 0, 0, 60)
	sliFrame.BackgroundTransparency = 1
	sliFrame.Name = "_SliderHolder_"

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
			option.Callback(val)
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
	Current.Parent = Slider
	Current.BackgroundColor3 = Color3.fromRGB(35, 40, 48)
	Current.BackgroundTransparency = 1
	Current.BorderColor3 = Color3.fromRGB(113, 128, 147)
	Current.Position = UDim2.new(1, 0, 0, -33)
	Current.Size = UDim2.new(0, 45, 0, 20)
	Current.Font = Enum.Font.SourceSans
	Current.Text = tostring(option.Default)
	Current.TextColor3 = Color3.fromRGB(220, 221, 225)
	Current.TextSize = 14
	Current.ZIndex = 12 + zindex
	Current.ClearTextOnFocus = false

	Current.FocusLost:Connect(function(enterPressed)
		local inputNum = tonumber(Current.Text)
		if inputNum then
			local finalVal = updateSliderFromValue(inputNum)
			option.Callback(finalVal)
		else
			Current.Text = tostring(snapToIncrement(Lerp(option.Min, option.Max, SliderButton.Position.X.Scale)))
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
	
	function option:SetValue(value)
		self.Default = value
		if self.Flag then
			library.Flags[self.Flag] = value
		end

		updateSliderFromValue(value)
		if type(self.Callback) == "function" then
			self.Callback(value)
		end
	end

	function option:SetTitle(newTitle)
		Description.Text = tostring(newTitle)
	end
end

-- // Dropdown Function \\ --
local function makeDropdown(option, parentContainer)
	local contentParent = parentContainer
	local selectedItems = {}
	local selectedSingle = nil
	local itemButtons = {}

	-- Jika nilai awal dalam bentuk tabel (multi-select) atau string (single)
	if option.MultiSelect and type(option.Value) == "table" then
		for _, val in ipairs(option.Value) do
			selectedItems[val] = true
		end
	elseif not option.MultiSelect and type(option.Value) == "string" then
		selectedSingle = option.Value
	end

	-- Frame Utama Holder
	local droFrame = Instance.new("Frame")
	droFrame.Name = "_DropdownHolder"
	droFrame.Size = UDim2.new(1, 0, 0, 32)
	droFrame.BackgroundTransparency = 1
	droFrame.AutomaticSize = Enum.AutomaticSize.Y
	droFrame.Parent = contentParent

	local droLayout = Instance.new("UIListLayout")
	droLayout.FillDirection = Enum.FillDirection.Vertical
	droLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	droLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	droLayout.Padding = UDim.new(0, 5)
	droLayout.SortOrder = Enum.SortOrder.LayoutOrder
	droLayout.Parent = droFrame

	-- Header Button
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
	DownSign.ImageColor3 = Color3.fromRGB(220, 221, 225)
	DownSign.ZIndex = 12 + zindex
	DownSign.Parent = Dropdown

	-- Floating Drag Frame Logic
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
		dragDropFrame.Parent = library.Gui or parentContainer:FindFirstAncestorWhichIsA("ScreenGui")

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

	-- ScrollingFrame untuk list item
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

	-- Helper internal untuk update visual
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

	-- Method Open & Close
	function option:Close()
		TweenService:Create(DownSign, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Rotation = 0}):Play()
		if dragDropFrame then
			dragDropFrame.Visible = false
		end
		DropdownFrame.Visible = false
	end

	function option:Open()
		for _, otherDrop in ipairs(dropdowns) do
			if otherDrop ~= option and otherDrop.Close then
				otherDrop:Close()
			end
		end

		TweenService:Create(DownSign, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Rotation = 90}):Play()

		if option.Floating and dragDropFrame then
			dragDropFrame.Position = UDim2.fromOffset(Dropdown.AbsolutePosition.X, Dropdown.AbsolutePosition.Y + 2)
			dragDropFrame.Visible = true
			DropdownFrame.Visible = true
		else
			DropdownFrame.Position = UDim2.fromOffset(Dropdown.AbsolutePosition.X, Dropdown.AbsolutePosition.Y + 2)
			DropdownFrame.Visible = true
		end
	end

	-- Method pembuatan Button Item
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

		-- Set Highlight jika sudah terpilih
		if (option.MultiSelect and selectedItems[name]) or (not option.MultiSelect and selectedSingle == name) then
			itemBtn.BackgroundColor3 = library.Themes[library.SelectedTheme].DropdownOptionSelect
		end

		itemBtn.MouseButton1Click:Connect(function()
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

				option.Value = activeTable
				library.Flags[option.Flag] = activeTable
				option.Callback(activeTable)
			else
				if selectedSingle == name then
					selectedSingle = nil
					itemBtn.BackgroundColor3 = Color3.fromRGB(53, 59, 72)
					updateDropdownText()

					option.Value = nil
					library.Flags[option.Flag] = nil
					option.Callback(nil)
				else
					if selectedSingle and itemButtons[selectedSingle] then
						itemButtons[selectedSingle].BackgroundColor3 = Color3.fromRGB(53, 59, 72)
					end

					selectedSingle = name
					itemBtn.BackgroundColor3 = library.Themes[library.SelectedTheme].DropdownOptionSelect
					updateDropdownText()

					option.Value = name
					library.Flags[option.Flag] = name
					option.Callback(name)
				end
			end
		end)
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

	-- Method Refresh untuk memperbarui daftar isi item
	function option:Refresh(newItems)
		option.Items = newItems or {}
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

	-- Timpa SetValue untuk update visual & flag secara manual
	function option:SetValue(val)
		option.Value = val
		library.Flags[option.Flag] = val

		if option.MultiSelect and type(val) == "table" then
			table.clear(selectedItems)
			for _, v in ipairs(val) do
				selectedItems[v] = true
			end
		elseif not option.MultiSelect then
			selectedSingle = val
		end

		-- Refresh tampilan tombol
		for btnName, btnObj in pairs(itemButtons) do
			if (option.MultiSelect and selectedItems[btnName]) or (not option.MultiSelect and selectedSingle == btnName) then
				btnObj.BackgroundColor3 = Color3.fromRGB(76, 79, 92)
			else
				btnObj.BackgroundColor3 = Color3.fromRGB(53, 59, 72)
			end
		end

		updateDropdownText()

		if type(option.Callback) == "function" then
			option.Callback(val)
		end
	end

	function option:SetTitle(newTitle)
		option.Title = newTitle
		DroTitle.Text = tostring(newTitle)
	end

	-- Render item awal
	option:Refresh(option.Items)
	updateDropdownText()

	-- Register ke penampung dropdown global
	table.insert(dropdowns, option)

	-- Event Klik Header
	Dropdown.MouseButton1Click:Connect(function()
		if DropdownFrame.Visible or (dragDropFrame and dragDropFrame.Visible) then
			option:Close()
		else
			option:Open()
		end
	end)

	option.Instance = droFrame
	return droFrame
end
--[[
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
		config.Delay = config.Delay or 0
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
	
	function targetContainer:AddSlider(config)
		config = type(config) == "table" and config or {}
		config.type = "slider"
		config.Title = config.Title or "Slider"
		config.Min = config.Min or 1
		config.Max = config.Max or 100
		config.Increment = config.Increment or 1
		config.Default = config.Default or (config.Max / 2)
		config.Flag = config.Flag or config.Title
		config.Callback = config.Callback or function() end
		
		registerFlag(config)
		
		table.insert(self.options, config)
		return config
	end
	
	function targetContainer:AddDropdown(config)
		config = type(config) == "table" and config or {}
		config.type = "dropdown"
		config.Title = config.Title or config.text or "Dropdown"
		config.Items = config.Items or config.items or {}
		config.MultiSelect = config.MultiSelect or config.multiSelect or false
		config.Floating = config.Floating or config.floating or false
		config.Flag = config.flag or config.Flag or config.text
		config.Callback = config.callback or config.Callback or function() end
		config.Value = config.Value or config.Default or (config.MultiSelect and {} or nil)

		registerFlag(config)

		function config:SetValue(val)
			self.Value = val
			library.Flags[self.Flag] = val
			if type(self.Callback) == "function" then
				self.Callback(val)
			end
		end

		function config:SetTitle(newTitle)
			self.Title = newTitle
		end

		function config:Refresh(newItems)
			self.Items = newItems or {}
		end

		table.insert(self.options, config)
		return config
	end

	function targetContainer:AddColumns(config)
		config = type(config) == "table" and config or {}
		config.type = "columns"
		config.Count = config.Count or config.count or 2 -- Default 2 kolom
		config.Columns = {}

		for i = 1, config.Count do
			local col = {
				type = "column",
				options = {}
			}
			injectElements(col) -- Suntikkan method AddButton, AddToggle, dll ke tiap kolom
			table.insert(config.Columns, col)
		end

		table.insert(self.options, config)
		return unpack(config.Columns) -- Mengembalikan tabel kolom agar bisa diisi
	end
	
	function targetContainer:AddRow(config)
		config = type(config) == "table" and config or {}
		config.type = "row"
		config.Padding = config.Padding or config.padding or 6
		config.options = {}

		injectElements(config)

		table.insert(self.options, config)
		return config
	end

	function targetContainer:AddGrid(config)
		config = type(config) == "table" and config or {}
		config.type = "grid"
		config.CellSize = config.CellSize or config.cellSize or UDim2.new(0, 80, 0, 80)
		config.CellPadding = config.CellPadding or config.cellPadding or UDim2.new(0, 6, 0, 6)
		config.options = {}

		injectElements(config)

		table.insert(self.options, config)
		return config
	end

	function targetContainer:AddGroup(config)
		config = type(config) == "table" and config or {}
		config.type = "group"
		config.Title = config.Title or config.Name or config.text or "Group Box"
		config.Collapsible = config.Collapsible or false
		config.Open = config.Open ~= nil and config.Open or true
		config.options = {}

		injectElements(config)

		table.insert(self.options, config)
		return config
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
			
		elseif option.type == "slider" then
			makeSlider(option, parentContainerFrame)

		elseif option.type == "dropdown" then
			makeDropdown(option, parentContainerFrame)

		elseif option.type == "columns" then
			makeColumnsUI(option, parentContainer)

		elseif option.type == "row" then
			makeRowUI(option, parentContainer)

		elseif option.type == "grid" then
			makeGridUI(option, parentContainer)

		elseif option.type == "group" then
			makeGroupUI(option, parentContainer)
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
	WinConfig.TabPosition = WinConfig.TabPosition or "Top"
	WinConfig.ContentFillDirection = WinConfig.ContentFillDirection or "Vertical"
	WinConfig.AutoInit = WinConfig.AutoInit or true
	WinConfig.HeaderIcon = WinConfig.HeaderIcon or ""
	if typeof(WinConfig.Theme) == "string" and (WinConfig.Theme and WinConfig.Theme ~= "") then
		library.SelectedTheme = WinConfig.Theme or "Default"
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
    	Name = "UiWindow" .. windowCount,
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
		Position = UDim2.new(0, 5, 0.5, 0),
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

	local HeaderIconLabel = Create("ImageLabel", {
		Size = UDim2.new(0, 30, 1, 0),
		BackgroundTransparency = 1,
		ImageColor3 = Color3.fromRGB(240, 240, 240),
		Name = "HeaderIconLabel",
		LayoutOrder = 1,
		ZIndex = 8 + zindex,
		Parent = HeaderContentHolder
	})

	if WinConfig.HeaderIcon and WinConfig.HeaderIcon ~= nil and WinConfig.HeaderIcon ~= "" then
		if typeof(WinConfig.HeaderIcon) == "string" and Icons then
			local asset = getIcon(WinConfig.HeaderIcon)
			HeaderIconLabel.Image = "rbxassetid://" .. asset.id
			HeaderIconLabel.ImageRectOffset = asset.imageRectOffset
			HeaderIconLabel.ImageRectSize = asset.imageRectSize
		else
			HeaderIconLabel.Image = getAssetUri(WinConfig.HeaderIcon)
		end
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
		Size = UDim2.new(1, 0, 1, 0),
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
		Size = UDim2.new(1, 0, 0.5, 0),
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
		Size = UDim2.new(1, 0, 0.5, 0),
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
    
    if not WinConfig.SubTitle or WinConfig.SubTitle == nil then
    	HeaderText.Size = UDim2.new(1,0,1,0)
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
		Visible = true,
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
	
	function window:AddBadge(BadgeConfig)
		BadgeConfig = BadgeConfig or {}
		BadgeConfig.Title = BadgeConfig.Title or "V1.0.0"
		BadgeConfig.Color = BadgeConfig.Color or Color3.fromRGB(255,68,68)
		BadgeConfig.TitleColor = BadgeConfig.TitleColor or Color3.fromRGB(255,255,255)
		BadgeConfig.Icon = BadgeConfig.Icon or ""
		
		local BagdeFrame = Create("Frame", {
			Name = BagdeConfig.Title,
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

		local Iccon = Create("ImageLabel", {
			Size = UDim2.new(0, 24, 0, 24),
			BackgroundTransparency = 1,
			ImageColor3 = Color3.fromRGB(240, 240, 240),
			Name = "Icon",
			LayoutOrder = 1,
			ZIndex = 8 + zindex,
			Parent = BagdeFrame
		})

		if BagdeConfig.Icon and BagdeConfig.Icon ~= nil and BagdeConfig.Icon ~= "" then
			if typeof(BagdeConfig.Icon) == "string" and Icons then
				local asset = getIcon(BagdeConfig.Icon)
				Iccon.Image = "rbxassetid://" .. asset.id
				Iccon.ImageRectOffset = asset.imageRectOffset
				Iccon.ImageRectSize = asset.imageRectSize
			else
				Iccon.Image = getAssetUri(BagdeConfig.Icon)
			end
		else
			Iccon:Destroy()
		end

		local BagdeTitle = Create("TextLabel", {
			LayoutOrder = 2,
			Parent = BagdeFrame,
			BackgroundColor3 = Color3.fromRGB(25,25,25),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0,0,0,0),
			Size = UDim2.new(1,-29,1,0),
			Font = Enum.Font.GothamSemibold,
			Text = BadgeConfig.Title,
			TextSize = 14,
			TextColor3 = BadgeConfig.TextColor,
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
			BackgroundColor3 = Color3.fromRGB(25,25,25),
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

		if TabConfig.Icon and TabConfig.Icon ~= nil and TabConfig.Icon ~= "" then
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
					otherTab.buttonInstance.BackgroundColor3 = library.Themes[library.SelectedTheme].TabBtnBackground
				end
			end

			if not tab.rendered then
				renderOptions(tab.options, tab.containerInstance)
				tab.rendered = true
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
			task.defer(function()
				if window.activeTab == nil then
					tab:Select()
				end
			end)
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
				ZIndex = 10 + zindex,
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