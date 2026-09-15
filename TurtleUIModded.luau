-- // Credits to Intrer#0421 for the source \\ --
-- // This UI is updated by me (LucidSc1pt) \\ --

-- // MAIN CODE \\ --

local library = {
	Theme = {
		Default = {
			WindowBackground = Color3.fromRGB(47, 54, 64),
			WindowBorder = Color3.fromRGB(47, 54, 64),
		
			UIWindow = Color3.fromRGB(0, 151, 230),
			UIWindowBorder = Color3.fromRGB(0, 151, 230),
		
			Header = Color3.fromRGB(0, 168, 255),
			HeaderBorder = Color3.fromRGB(0, 168, 255),
			HeaderText = Color3.fromRGB(47, 54, 64),

			NormalText = Color3.fromRGB(245, 246, 250),
			NormalBackground = Color3.fromRGB(53, 59, 72),

			BtnBorder = Color3.fromRGB(113, 128, 147),

			ToggleFiller = Color3.fromRGB(68, 189, 50),

			SliderFiller = Color3.fromRGB(76, 209, 55)
		}
	}
}
local windowCount = 0
local sizes = {}
local listOffset = {}
local windows = {}
local pastSliders = {}
local dropdowns = {}
local dropdownSizes = {}
local colorPickers = {}

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

local function MakeDraggable(DragPoint, Main)
	pcall(function()
		local Dragging = false
		local DragInput
		local MousePos
		local FramePos
		
		DragPoint.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				
				Dragging = true
				MousePos = Input.Position
				FramePos = Main.Position
				
				Input.Changed:Connect(function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)
		
		DragPoint.InputChanged:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
				DragInput = Input
			end
		end)
		
		uis.InputChanged:Connect(function(Input)
			if Input == DragInput and Dragging then
				local Delta = Input.Position - MousePos

				local newPos = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
			    
				TweenService:Create(Main, TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = newPos}):Play()
				Main.Position = newPos
			end
		end)
	end)
end

-- // Instances:

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

-- // Making the ScreenGui \\ --
local TurtleUiLib = Instance.new("ScreenGui")
TurtleUiLib.Name = "TurtleUiLib"

protect_gui(TurtleUiLib)

local xOffset = 20

local keybindConnection

-- // ⚠️ Function ⚠️ \\ --

-- // Notification Function \\ --
local NotificationHolder = Instance.new("Frame")
NotificationHolder.Size = UDim2.new(0, 200, 1, -25)
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
		NotificationConfig.Time = NotificationConfig.Time or 5

		local NotificationParent = Instance.new("Frame")
		NotificationParent.Size = UDim2.new(1,0,0,0)
		NotificationParent.AutomaticSize = Enum.AutomaticSize.Y
		NotificationParent.BackgroundTransparency = 1
		NotificationParent.Parent = NotificationHolder

		local NotificationFrame = Instance.new("Frame")
		NotificationFrame.Size = UDim2.new(1,0,0,0)
		NotificationFrame.AutomaticSize = Enum.AutomaticSize.Y
		NotificationFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
		NotificationFrame.BackgroundTransparency = 0.3
		NotificationFrame.Parent = NotificationParent

		local Stroke = Instance.new("UIStroke", NotificationFrame)
		Stroke.Thickness = 2
		Stroke.Color = Color3.fromRGB(0,168,247)

		local Padding = Instance.new("UIPadding", NotificationFrame)
		Padding.PaddingTop = UDim.new(0,10)
		Padding.PaddingBottom = UDim.new(0,10)
		Padding.PaddingLeft = UDim.new(0,10)
		Padding.PaddingRight = UDim.new(0,10)

		local Title = Instance.new("TextLabel")
		Title.Parent = NotificationFrame
		Title.Size = UDim2.new(1, -10, 0, 20)
		Title.Position = UDim2.new(0,0,0,0)
		Title.BackgroundTransparency = 1
		Title.Font = Enum.Font.GothamBold
		Title.TextColor3 = Color3.fromRGB(255,255,255)
		Title.TextSize = 16
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.Text = NotificationConfig.Title

		local Content = Instance.new("TextLabel")
		Content.Parent = NotificationFrame
		Content.Size = UDim2.new(1,0,0,0)
		Content.Position = UDim2.new(0,0,0,25)
		Content.AutomaticSize = Enum.AutomaticSize.Y
		Content.BackgroundTransparency = 1
		Content.Font = Enum.Font.GothamSemibold
		Content.TextColor3 = Color3.fromRGB(220,220,220)
		Content.TextSize = 14
		Content.TextXAlignment = Enum.TextXAlignment.Left
		Content.TextWrapped = true
		Content.Text = NotificationConfig.Content

		local ProgressBar = Instance.new("Frame")
		ProgressBar.Parent = NotificationFrame
		ProgressBar.Size = UDim2.new(1,0,0,3)
		ProgressBar.Position = UDim2.new(0,0,1,3)
        ProgressBar.BackgroundTransparency = 0
		ProgressBar.BackgroundColor3 = Color3.fromRGB(0,168,247)
		ProgressBar.BorderSizePixel = 0
		Instance.new("UICorner", ProgressBar).CornerRadius = UDim.new(0,3)

		NotificationFrame.Position = UDim2.new(1,50,0,0)
		TweenService:Create(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0,0,0,0)}):Play()

		local barTween = TweenService:Create(ProgressBar, TweenInfo.new(NotificationConfig.Time, Enum.EasingStyle.Linear), {Size = UDim2.new(0,0,0,3)})
		barTween:Play()

		task.wait(NotificationConfig.Time - 1)

		TweenService:Create(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.8}):Play()
        TweenService:Create(ProgressBar, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.7}):Play()
		TweenService:Create(Stroke, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Transparency = 0.6}):Play()
		TweenService:Create(Title, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0.5}):Play()
		TweenService:Create(Content, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0.5}):Play()

		task.wait(1)
		NotificationFrame:TweenPosition(UDim2.new(1, 50, 0, 0), "Out", "Quint", 0.6, true)

		task.wait(1)
		NotificationParent:Destroy()
	end)
end

-- // Destroy Function \\ --
function library:Destroy()
    TurtleUiLib:Destroy()
    if keybindConnection then
        keybindConnection:Disconnect()
    end
end

-- // Keybind Function \\ --
function library:Keybind(key)
    if keybindConnection then keybindConnection:Disconnect() end

    keybindConnection = uis.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode[key] then
            TurtleUiLib.Enabled = not TurtleUiLib.Enabled
        end
    end)
end

-- // Window Function \\ --
function library:Window(WinConfig)
	WinConfig = WinConfig or {}
    WinConfig.Name = WinConfig.Name or "Window"
    WinConfig.Size = WinConfig.Size or UDim2.new(0,220,0,288)
    WinConfig.MultiWindow = WinConfig.MultiWindow or true
    WinConfig.Position = WinConfig.Position or UDim2.new(0, xOffset, 0, 20)
	
	local winCount
    local zindex
    local winPaddingLayout
    local winLayout
    
    if WinConfig.MultiWindow then
    	windowCount = windowCount + 1
    	winCount = windowCount
    	zindex = winCount * 7
   	else
    	zindex = zindex * 7
		for _, Interface in ipairs(TurtleUiLib:GetChildren()) do
			if Interface.Name == "UiWindow" and Interface then
				Interface.Visible = false
				Interface.Active = false
				Interface.Name = "UiWindow-Old"
			end
		end
	end
  
	local UiWindow = Instance.new("Frame")
    UiWindow.Name = "UiWindow"
    UiWindow.Parent = TurtleUiLib
    UiWindow.BackgroundTransparency = 1
    UiWindow.BorderColor3 = Color3.fromRGB(0, 151, 230)
    UiWindow.Position = WinConfig.Position
    UiWindow.Size = WinConfig.Size
    UiWindow.ZIndex = 4 + zindex
    UiWindow.Active = false
	
    xOffset = xOffset + 230

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Parent = UiWindow
    Header.BackgroundColor3 = Color3.fromRGB(0, 168, 255)
    Header.BorderColor3 = Color3.fromRGB(0, 168, 255)
    Header.Position = UDim2.new(0, 0, 0, 0)
    Header.Size = UDim2.new(1, 0, 0, 33)
    Header.Active = true
    Header.ZIndex = 5 + zindex

    local HeaderText = Instance.new("TextLabel")
    HeaderText.Name = "HeaderText"
    HeaderText.Parent = Header
    HeaderText.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    HeaderText.BackgroundTransparency = 1.000
    HeaderText.Position = UDim2.new(0, 5, 0, 0)
    HeaderText.Size = UDim2.new(1, -47, 0, 33)
    HeaderText.ZIndex = 6 + zindex
    HeaderText.Font = Enum.Font.SourceSansBold
    HeaderText.Text = WinConfig.Name
    HeaderText.TextColor3 = Color3.fromRGB(47, 54, 64)
    HeaderText.TextXAlignment = Enum.TextXAlignment.Left
    HeaderText.TextSize = 17

	MakeDraggable(Header, UiWindow)

    local Window = Instance.new("Frame")
    Window.Name = "Window"
    Window.Parent = UiWindow
    Window.BackgroundColor3 = Color3.fromRGB(47, 54, 64)
    Window.BorderColor3 = Color3.fromRGB(47, 54, 64)
    Window.Position = UDim2.new(0, 0, 0, 33)
    Window.Size = UDim2.new(1, 0, 1, -33)
    Window.Active = false
    Window.ZIndex = 1 + zindex
    
    local WindowScroll = Instance.new("ScrollingFrame")
	WindowScroll.Parent = Window
	WindowScroll.Size = UDim2.new(1,0,1,0)
	WindowScroll.BackgroundTransparency = 1
	WindowScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	WindowScroll.CanvasSize = UDim2.new(0,0,0,0)
	WindowScroll.ScrollBarThickness = 0
	WindowScroll.Active = true
    WindowScroll.Position = UDim2.new(0, 0, 0, 0)
    WindowScroll.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left
    WindowScroll.ZIndex = 1 + zindex
    WindowScroll.ScrollingDirection = Enum.ScrollingDirection.Y
    WindowScroll.ElasticBehavior = Enum.ElasticBehavior.Never
        
	winPaddingLayout = Instance.new("UIPadding")
	winPaddingLayout.PaddingBottom = UDim.new(0, 5)
	winPaddingLayout.PaddingTop = UDim.new(0, 5)
	winPaddingLayout.PaddingRight = UDim.new(0, 5)
	winPaddingLayout.PaddingLeft = UDim.new(0, 5)
	winPaddingLayout.Parent = WindowScroll

	winLayout = Instance.new("UIListLayout")
	winLayout.FillDirection = Enum.FillDirection.Vertical
	winLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	winLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	winLayout.Padding = UDim.new(0, 5)
	winLayout.SortOrder = Enum.SortOrder.LayoutOrder
	winLayout.Parent = WindowScroll

    local Minimise = Instance.new("TextButton")
    Minimise.Name = "Minimise"
    Minimise.Parent = Header
    Minimise.BackgroundColor3 = Color3.fromRGB(0, 168, 255)
	Minimise.BackgroundTransparency = 1
    Minimise.BorderColor3 = Color3.fromRGB(0, 168, 255)
    Minimise.Position = UDim2.new(1, -25, 0, 2)
    Minimise.Size = UDim2.new(0, 22, 0, 22)
    Minimise.ZIndex = 7 + zindex
    Minimise.Font = Enum.Font.SourceSansBold
    Minimise.Text = "–"
    Minimise.TextColor3 = Color3.fromRGB(47, 54, 64)
    Minimise.TextSize = 20.000

    Minimise.MouseButton1Click:Connect(function()
       Window.Visible = not Window.Visible
       if Window.Visible then
          Minimise.Text = "–"
       else
          Minimise.Text = "+"
       end
    end)
    
	local contentParent = WindowScroll

	local DropdownParent = Instance.new("Frame")
	DropdownParent.Name = "DropdownParent"
    DropdownParent.Parent = Header
    DropdownParent.Active = false
    DropdownParent.BackgroundColor3 = Color3.fromRGB(53, 59, 72)
    DropdownParent.BorderColor3 = Color3.fromRGB(53, 59, 72)
    DropdownParent.Position = UDim2.new(1, 15, 1, 9)
    DropdownParent.Size = UDim2.new(0, 192, 0, 0)
    DropdownParent.Visible = true
    DropdownParent.BackgroundTransparency = 1

    local functions = {}
    sizes[winCount] = 33
    listOffset[winCount] = 10
    local windowContentCount = 0
    
	local function autoSizeWin(winC, sizeWin)
		if windowContentCount <= 6 then
			sizes[winCount] = sizes[winCount] + winC
			Window.Size = UDim2.new(1,0,0,sizes[winCount] + sizeWin)
		end
	end

	  -- // Button Function \\ --
    function functions:Button(ButConfig)
        ButConfig = ButConfig or {}
        ButConfig.Name = ButConfig.Name or "Button"
        ButConfig.Callback = ButConfig.Callback or function() end

		local btnFrame = Instance.new("Frame")
		btnFrame.Parent = contentParent
		btnFrame.Size = UDim2.new(1, 0, 0, 32)
		btnFrame.BackgroundTransparency = 1
		btnFrame.Name = tostring(windowContentCount) .. "_ButtonHolder_"
		windowContentCount = windowContentCount + 1
		
        local Button = Instance.new("TextButton")
        Button.AnchorPoint = Vector2.new(0,0.5)
        Button.Name = "THEBUTTON"
        Button.Parent = btnFrame
        Button.BackgroundColor3 = Color3.fromRGB(53, 59, 72)
        Button.BorderColor3 = Color3.fromRGB(113, 128, 147)
        Button.Position = UDim2.new(0,0,0.5,0)
        Button.Size = UDim2.new(1, 0, 0, 26)
        Button.ZIndex = 2 + zindex
        Button.Selected = true
        Button.Font = Enum.Font.SourceSans
        Button.TextColor3 = Color3.fromRGB(245, 246, 250)
        Button.TextSize = 16.000
        Button.TextStrokeTransparency = 123.000
        Button.TextWrapped = true
        Button.Text = ""
        
        local ButtonTitle = Instance.new("TextLabel")
        ButtonTitle.AnchorPoint = Vector2.new(0,0.5)
        ButtonTitle.Name = "ButtonTitle"
        ButtonTitle.Parent = Button
        ButtonTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ButtonTitle.BackgroundTransparency = 1.000
        ButtonTitle.Position = UDim2.new(0, 5, 0.5, 0)
        ButtonTitle.Size = UDim2.new(1, -5, 1, 0)
        ButtonTitle.Font = Enum.Font.SourceSans
        ButtonTitle.Text = ButConfig.Name
        ButtonTitle.TextColor3 = Color3.fromRGB(245, 246, 250)
        ButtonTitle.TextSize = 16
        ButtonTitle.TextWrapped = true
        ButtonTitle.TextXAlignment = Enum.TextXAlignment.Left
        ButtonTitle.Active = false
        ButtonTitle.ZIndex = 2 + zindex
        
        Button.MouseButton1Click:Connect(ButConfig.Callback)

        pastSliders[winCount] = false
    end

	-- // Label Function \\ --
    function functions:Label(LabConfig)
        LabConfig = LabConfig or {}
        LabConfig.Name = LabConfig.Name or "Label"
        LabConfig.Color = LabConfig.Color or Color3.fromRGB(220, 221, 225)
        
        local labelFrame = Instance.new("Frame")
		labelFrame.Parent = contentParent
		labelFrame.Size = UDim2.new(1, 0, 0, 32)
		labelFrame.BackgroundTransparency = 1
		labelFrame.Name = tostring(windowContentCount) .. "_LabelHolder_"
		windowContentCount = windowContentCount + 1
        
        local Label = Instance.new("TextLabel")
        Label.AnchorPoint = Vector2.new(0,0.5)
        Label.Name = "LABEL"
        Label.Parent = labelFrame
        Label.BackgroundColor3 = Color3.fromRGB(220, 221, 225)
        Label.BackgroundTransparency = 1.000
        Label.BorderColor3 = Color3.fromRGB(27, 42, 53)
        Label.Position = UDim2.new(0, 0, 0.5, 0)
        Label.Size = UDim2.new(1, 0, 0, 29)
        Label.Font = Enum.Font.SourceSans
        Label.Text = LabConfig.Name
        Label.TextSize = 16
        Label.ZIndex = 2 + zindex

        if LabConfig.Color == "Rainbow" then
	    	spawn(function()
                while Label.Parent do
                    local hue = tick() % 5 / 5
                    Label.TextColor3 = Color3.fromHSV(hue, 1, 1)
					task.wait()
                end
	    	end)
        else
            Label.TextColor3 = LabConfig.Color
        end
        
        pastSliders[winCount] = false
    end
 
    -- // Toggle Function \\ --
    function functions:Toggle(TogConfig)
		TogConfig = TogConfig or {}
        TogConfig.Name = TogConfig.Name or "Toggle"
        TogConfig.Default = TogConfig.Default or false
        TogConfig.Loop = TogConfig.Loop or false
        TogConfig.Delay = TogConfig.Delay or 0
        TogConfig.Callback = TogConfig.Callback or function() end
        
        local togFrame = Instance.new("Frame")
		togFrame.Parent = contentParent
		togFrame.Size = UDim2.new(1, 0, 0, 32)
		togFrame.BackgroundTransparency = 1
		togFrame.Name = tostring(windowContentCount) .. "_ToggleHolder_"
		windowContentCount = windowContentCount + 1

        local ToggleDescription = Instance.new("TextLabel")
        local ToggleButton = Instance.new("TextButton")
		local ToggleButton_stroke = Instance.new("UIStroke")
        local ToggleFiller = Instance.new("Frame")

		ToggleDescription.AnchorPoint = Vector2.new(0,0.5)
        ToggleDescription.Name = "ToggleDescription"
        ToggleDescription.Parent = togFrame
        ToggleDescription.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleDescription.BackgroundTransparency = 1.000
        ToggleDescription.Position = UDim2.new(0, 0, 0.5, 0)
        ToggleDescription.Size = UDim2.new(1, 0, 0, 26)
        ToggleDescription.Font = Enum.Font.SourceSans
        ToggleDescription.Text = TogConfig.Name
        ToggleDescription.TextColor3 = Color3.fromRGB(245, 246, 250)
        ToggleDescription.TextSize = 16.000
        ToggleDescription.TextWrapped = true
        ToggleDescription.TextXAlignment = Enum.TextXAlignment.Left
        ToggleDescription.ZIndex = 2 + zindex

		ToggleButton.AnchorPoint = Vector2.new(1, 0.5)
        ToggleButton.Name = "ToggleButton"
        ToggleButton.Parent = togFrame
        ToggleButton.BackgroundColor3 = Color3.fromRGB(47, 54, 64)
		ToggleButton.BackgroundTransparency = 1
        ToggleButton.BorderColor3 = Color3.fromRGB(113, 128, 147)
        ToggleButton.Position = UDim2.new(1, 0, 0.5, 0)
        ToggleButton.Size = UDim2.new(0, 22, 0, 22)
        ToggleButton.Font = Enum.Font.SourceSans
        ToggleButton.Text = ""
        ToggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        ToggleButton.TextSize = 14
        ToggleButton.ZIndex = 2 + zindex
		
        ToggleButton.MouseButton1Click:Connect(function()
            ToggleFiller.Visible = not ToggleFiller.Visible
            if not TogConfig.Loop then
            	TogConfig.Callback(ToggleFiller.Visible)
        	end
        end)
        
		if TogConfig.Loop then
			local lastTick = 0

        	game:GetService("RunService").Heartbeat:Connect(function()
            	if ToggleFiller.Visible then
					if os.clock() - lastTick >= TogConfig.Delay then
                    	lastTick = os.clock()
                    	task.spawn(function()
                        	TogConfig.Callback(ToggleFiller.Visible)
                    	end)
                	end
            	else
					lastTick = 0
            	end
        	end)
        end

		ToggleButton_stroke.Parent = ToggleButton
		ToggleButton_stroke.Color = Color3.fromRGB(113, 128, 147)
		ToggleButton_stroke.Thickness = 1
		ToggleButton_stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		ToggleButton_stroke.Enabled = true

        ToggleFiller.Name = "ToggleFiller"
        ToggleFiller.Parent = ToggleButton
        ToggleFiller.BackgroundColor3 = Color3.fromRGB(68, 189, 50)
        ToggleFiller.BorderColor3 = Color3.fromRGB(47, 54, 64)
        ToggleFiller.Position = UDim2.new(0, 4, 0, 4)
        ToggleFiller.Size = UDim2.new(0, 14, 0, 14)
        ToggleFiller.Visible = TogConfig.Default
        ToggleFiller.ZIndex = 2 + zindex
        
        pastSliders[winCount] = false
    end

	-- // TextBox Function \\ --
    function functions:Box(BoxConfig)
        BoxConfig = BoxConfig or {}
        BoxConfig.Name = BoxConfig.Name or "Box"
        BoxConfig.Callback = BoxConfig.Callback or function() end

        local boxFrame = Instance.new("Frame")
		boxFrame.Parent = contentParent
		boxFrame.Size = UDim2.new(1, 0, 0, 32)
		boxFrame.BackgroundTransparency = 1
		boxFrame.Name = tostring(windowContentCount) .. "_BoxHolder_"
		windowContentCount = windowContentCount + 1
        
        local TextBox = Instance.new("TextBox")
        local BoxDescription = Instance.new("TextLabel")
        TextBox.AnchorPoint = Vector2.new(1, 0.5)
        TextBox.Parent = boxFrame
        TextBox.BackgroundColor3 = Color3.fromRGB(53, 59, 72)
        TextBox.BorderColor3 = Color3.fromRGB(113, 128, 147)
        TextBox.Position = UDim2.new(1, 0, 0.5, 0)
        TextBox.Size = UDim2.new(0, 95, 0, 26)
        TextBox.Font = Enum.Font.SourceSans
        TextBox.PlaceholderColor3 = Color3.fromRGB(220, 221, 225)
        TextBox.PlaceholderText = "..."
        TextBox.Text = ""
        TextBox.TextColor3 = Color3.fromRGB(245, 246, 250)
        TextBox.TextSize = 14
        TextBox.TextStrokeColor3 = Color3.fromRGB(245, 246, 250)
        TextBox.ZIndex = 2 + zindex

        local LastText = ""

        TextBox:GetPropertyChangedSignal('Text'):connect(function()
            if TextBox.Text ~= LastText then
				LastText = TextBox.Text
                BoxConfig.Callback(TextBox.Text, false)
            end
        end)
        TextBox.FocusLost:Connect(function()
            BoxConfig.Callback(TextBox.Text, true)
        end)
        
        BoxDescription.AnchorPoint = Vector2.new(0,0.5)
        BoxDescription.Name = "BoxDescription"
        BoxDescription.Parent = boxFrame
        BoxDescription.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        BoxDescription.BackgroundTransparency = 1.000
        BoxDescription.Position = UDim2.new(0, 0, 0.5, 0)
        BoxDescription.Size = UDim2.new(0, 75, 0, 26)
        BoxDescription.Font = Enum.Font.SourceSans
        BoxDescription.Text = BoxConfig.Name
        BoxDescription.TextColor3 = Color3.fromRGB(245, 246, 250)
        BoxDescription.TextSize = 16
        BoxDescription.TextXAlignment = Enum.TextXAlignment.Left
        BoxDescription.ZIndex = 2 + zindex
        
        pastSliders[winCount] = false
    end

	-- // Slider Function \\ --
    function functions:Slider(SliConfig)
        SliConfig = SliConfig or {}
        SliConfig.Name = SliConfig.Name or "Slider"
        SliConfig.Min = SliConfig.Min or 1
        SliConfig.Max = SliConfig.Max or 100
        SliConfig.Increment = SliConfig.Increment or 1
        SliConfig.Default = math.clamp(SliConfig.Default, SliConfig.Min, SliConfig.Max)
		SliConfig.Callback = SliConfig.Callback or function() end
        local offset = 70
        local defaultAlpha = (SliConfig.Default - SliConfig.Min) / (SliConfig.Max - SliConfig.Min)

        if pastSliders[winCount] then
            offset = 60
        end
        
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
                    	local sliderWidth = Slider.AbsoluteSize.X - 10
                    	local mousePosX = mouse.X - Slider.AbsolutePosition.X - 10
                    	local alpha = math.clamp(mousePosX / sliderWidth, 0, 1)
                    
                    	local rawValue = Lerp(SliConfig.Min, SliConfig.Max, alpha)
                    	local snappedValue = snapToIncrement(rawValue)
                    
                    	local snappedAlpha = (snappedValue - SliConfig.Min) / (SliConfig.Max - SliConfig.Min)
                    	SliderButton.Position = UDim2.new(snappedAlpha, 0, -1.33333337, 0)
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

        SliderButton.Position = UDim2.new(defaultAlpha, 0, -1.333337, 0)
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
            	-- Kembalikan teks ke nilai slider saat ini jika input bukan angka valid
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
        
        pastSliders[winCount] = true
    end

	-- // Dropdown Function \\ --
    function functions:Dropdown(DropConfig)
        DropConfig = DropConfig or {}
        DropConfig.Name = DropConfig.Name or "Dropdown"
        DropConfig.Items = DropConfig.Items or {}
        DropConfig.MultiSelect = DropConfig.MultiSelect or false
        DropConfig.Floating = DropConfig.Floating or false
        --DropConfig.Draggable = DropConfig.Draggable or false
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
        
        local dragDropFrame
        if DropConfig.Floating then
			dragDropFrame = Instance.new("Frame")
			dragDropFrame.Parent = DropdownFrame
			dragDropFrame.Size = UDim2.new(1, 0, 0, 26)
			dragDropFrame.BackgroundColor3 = Color3.fromRGB(53, 59, 72)
			dragDropFrame.BorderColor3 = Color3.fromRGB(53, 59, 72)
			
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
        	dragDroTitle.ZIndex = 4 + zindex
        	dragDroTitle.TextWrapped = false
        	dragDroTitle.Active = false
        	dragDroTitle.TextXAlignment = Enum.TextXAlignment.Left
        	
        	MakeDraggable(dragDropFrame, DropdownFrame)
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
        DropdownFrame.ZIndex = 1000
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

        table.insert(dropdowns, DropdownFrame)
        local dropFunctions = {}
        local selectedItems = {}
    	local selectedSingle = nil
    	local itemButtons = {}

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
        
			local maxHeight = math.min(contentHeight, 140)
        	DropdownFrame.Size = UDim2.new(0, Dropdown.AbsoluteSize.X, 0, maxHeight)
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
            	otherDrop.Visible = false
            	TweenService:Create(otherDrop.Parent.Dropdown.DownSign, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Rotation = 180}):Play()
        	end

			DropdownFrame.Position = UDim2.fromOffset(Dropdown.AbsolutePosition.X, Dropdown.AbsolutePosition.Y + Dropdown.AbsoluteSize.Y + 2)
	        DropdownFrame.Size = UDim2.new(0, Dropdown.AbsoluteSize.X, 0, math.min(listLayout.AbsoluteContentSize.Y, 140))
        
		    TweenService:Create(DownSign, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Rotation = 0}):Play()
		    if DropConfig.Floating then
	        	dragDropFrame.Visible = true
	        end
	        DropdownFrame.Visible = true
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
            Button_2.ZIndex = 1001
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
    		PlaceholderLabel.ZIndex = 1001
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
			if DropdownFrame.Visible then
				dropFunctions:Close()
			else
				dropFunctions:Open()
			end
        end)

		return dropFunctions
    end

	-- // ColorPicker Function \\ --
    function functions:ColorPicker(ColConfig)
		ColConfig = ColConfig or {}
        ColConfig.Name = ColConfig.Name or "Color picker"
        ColConfig.Default = ColConfig.Default or Color3.fromRGB(255, 0, 0)
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

        ColorPickerFrame.Name = "ColorPickerFrame"
        ColorPickerFrame.Parent = colFrame
        ColorPickerFrame.BackgroundColor3 = Color3.fromRGB(47, 54, 64)
        ColorPickerFrame.BorderColor3 = Color3.fromRGB(47, 54, 64)
        ColorPickerFrame.Position = UDim2.new(0, 0, 0, 31)
        ColorPickerFrame.Size = UDim2.new(1, 0, 0, 125)
        ColorPickerFrame.ZIndex = 3 + zindex
        ColorPickerFrame.Active = true
        ColorPickerFrame.Visible = false

		ToggleRGB.AnchorPoint = Vector2.new(1,0)
        ToggleRGB.Name = "ToggleRGB"
        ToggleRGB.Parent = ColorPickerFrame
        ToggleRGB.BackgroundColor3 = Color3.fromRGB(47, 54, 64)
        ToggleRGB.BorderColor3 = Color3.fromRGB(113, 128, 147)
        ToggleRGB.Position = UDim2.new(1, 0, 0, 97)
        ToggleRGB.Size = UDim2.new(0, 22, 0, 22)
        ToggleRGB.Font = Enum.Font.SourceSans
        ToggleRGB.Text = ""
        ToggleRGB.TextColor3 = Color3.fromRGB(0, 0, 0)
        ToggleRGB.TextSize = 14
        ToggleRGB.ZIndex = 4 + zindex

        ToggleFiller_2.Name = "ToggleFiller"
        ToggleFiller_2.Parent = ToggleRGB
        ToggleFiller_2.BackgroundColor3 = Color3.fromRGB(76, 209, 55)
        ToggleFiller_2.BorderColor3 = Color3.fromRGB(47, 54, 64)
        ToggleFiller_2.Position = UDim2.new(0, 5, 0, 5)
        ToggleFiller_2.Size = UDim2.new(0, 12, 0, 12)
        ToggleFiller_2.ZIndex = 4 + zindex
        ToggleFiller_2.Visible = false

        TextLabel.Parent = ColorPickerFrame
        TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.BackgroundTransparency = 1.000
        TextLabel.Position = UDim2.new(0, 0, 0, 97)
        TextLabel.Size = UDim2.new(0, 106, 0, 22)
        TextLabel.Font = Enum.Font.SourceSans
        TextLabel.Text = "Rainbow"
        TextLabel.TextColor3 = Color3.fromRGB(245, 246, 250)
        TextLabel.TextSize = 16
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.ZIndex = 4 + zindex

        CanvasGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))}
        CanvasGradient.Name = "CanvasGradient"
        CanvasGradient.Parent = Canvas

        BlackOverlay.Name = "BlackOverlay"
        BlackOverlay.Parent = Canvas
        BlackOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        BlackOverlay.BackgroundTransparency = 1.000
        BlackOverlay.Size = UDim2.new(1, 0, 1, 0)
        BlackOverlay.Image = "rbxassetid://5107152095"
        BlackOverlay.ZIndex = 5 + zindex

        UICorner.Parent = Canvas
        UICorner.Name = "UICorner"
        UICorner.CornerRadius = UDim.new(0,2)

        Cursor.Name = "Cursor"
        Cursor.Parent = Canvas
        Cursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Cursor.BackgroundTransparency = 1.000
        Cursor.Size = UDim2.new(0, 8, 0, 8)
        Cursor.Image = "rbxassetid://5100115962"
        Cursor.ZIndex = 5 + zindex

        local draggingColor = false
        local hue = 0
        local sat = 1
        local brightness = 1

        local con
        
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
        end

        Canvas.Name = "Canvas"
        Canvas.Parent = ColorPickerFrame
        Canvas.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Canvas.Position = UDim2.new(0, 0, 0, 0)
        Canvas.Size = UDim2.new(1, 0, 0, 64)
        Canvas.Active = true
        Canvas.ZIndex = 4 + zindex

        CanvasGradient.Color = ColorSequence.new{
             ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), 
             ColorSequenceKeypoint.new(1.00, Color3.fromHSV(0, 1, 1))
        }

		Canvas.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				local isdragging = true
				local con

				con = stepped:Connect(function()
					if isdragging then
						local mousePos = Vector2.new(mouse.X, mouse.Y)
						local relX = math.clamp((mousePos.X - Canvas.AbsolutePosition.X) / Canvas.AbsoluteSize.X, 0, 1)
						local relY = math.clamp((mousePos.Y - Canvas.AbsolutePosition.Y) / Canvas.AbsoluteSize.Y, 0, 1)
								
						sat = relX
						brightness = 1 - relY
						color3 = Color3.fromHSV(hue, sat, brightness)
								
						Cursor.Position = UDim2.fromOffset(relX * Canvas.AbsoluteSize.X - 4, relY * Canvas.AbsoluteSize.Y - 4)
						ColorPicker.BackgroundColor3 = color3
						ColConfig.Callback(color3)
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
		end)

        Color.Name = "Color"
        Color.Parent = ColorPickerFrame
        Color.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Color.Position = UDim2.new(0, 5, 0, 75)
        Color.Size = UDim2.new(1, -10, 0, 14)
        Color.BorderMode = Enum.BorderMode.Inset
        Color.Active = true
        Color.ZIndex = 4 + zindex

        Color.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					draggingColor = true
					local con
					con = stepped:Connect(function()
                
					if draggingColor then
						local rel = math.clamp((mouse.X - Color.AbsolutePosition.X) / Color.AbsoluteSize.X, 0, 1)
						hue = rel
                    
						CanvasGradient.Color = ColorSequence.new{
							ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)),
							ColorSequenceKeypoint.new(1.00, Color3.fromHSV(hue, 1, 1))
						}
                    
						local xOffset = rel * Color.AbsoluteSize.X
						ColorSlider.Position = UDim2.new(0, xOffset, 0, -1)

						color3 = Color3.fromHSV(hue, sat, brightness)
						ColorPicker.BackgroundColor3  = color3
						ColConfig.Callback(color3)
					else
						con:Disconnect()
					end
				end)
			end
		end)
    
		Color.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				draggingColor = false
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
		ColorGradient.Parent = Color

        ColorCorner.Parent = Color
        ColorCorner.Name = "ColorCorner"
        ColorCorner.CornerRadius = UDim.new(0,2)

        ColorSlider.Name = "ColorSlider"
        ColorSlider.Parent = Color
        ColorSlider.BackgroundColor3 = Color3.fromRGB(245, 246, 250)
        ColorSlider.BorderColor3 = Color3.fromRGB(245, 246, 250)
        ColorSlider.Position = UDim2.new(0, 0, 0, -1)
        ColorSlider.Size = UDim2.new(0, 2, 0, 14)
        ColorSlider.Active = true
        ColorSlider.ZIndex = 5 + zindex

		table.insert(colorPickers, ColorPickerFrame)

		local colorFuncs = {}
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
	        ColorPickerFrame.Visible = false
	    end

	    function colorFuncs:Open()
			for _, otherColor in ipairs(colorPickers) do
            	otherColor.Visible = false
        	end

			ColorPickerFrame.Visible = true
	    end
	    
	    ColorPicker.MouseButton1Click:Connect(function()
            if ColorPickerFrame.Visible then
            	colorFuncs:Close()
            else
            	colorFuncs:Open()
            end
        end)
    
		return colorFuncs
    end

   return functions
end

return library
