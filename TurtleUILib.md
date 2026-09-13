# Documentation

### Calling Turtle UI Library
```luau
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/LittenHub/Fuckyouman/refs/heads/main/TurtleUI.lua"))()
```
### Creating Window
```luau
local Window = library:Window({Name = "Table Turtle Hub"})
```
Value:
- Name = string
- Size = UDim2
- Position = UDim2

### Creating a Button
```luau
Window:Button({
	Name = "Button",
  Callback = function()
		print("yayyyyy buttonnn!")
	end
})
```
Value:
- Name = string
- Callback = function

### Creating a Toggle
```luau
Window:Toggle({
    Name = "Toggle",
    Default = false,
    Loop = false,
    Callback = function(value)
        print("hmmmm")
    end
})
```
Value:
- Name = string
- Default = boolean
- Loop = boolean
- Callback = function (return boolean value)


### Creating a ColorPicker
```luau
Window:ColorPicker({
   Name = "Color Picker",
   Default = Color3.fromRGB(255, 255, 255),
   Callback = function(color)
        print(color)
   end
})
```
Value:
- Name = string
- Default = Color3
- Callback = function (return HVS value)

### Creating a Slider
```luau
Window:Slider({
   Name = "Example Slider",
   Min = 0,
   Max = 100,
   Default = 20,
   Increment = 1,
   Callback = function(value)
		 print(value)
	 end
})
```
Value:
- Name = string
- Min = number
- Max = number
- Default = number
- Increment = number
- Callback = function (return number value)

### Creating a Label
```luau
Window:Label({
   Name = "Label Example", 
   Color = "Rainbow"
})
```
Value:
- Name = string
- Color = Color3 or "Rainbow"

### Creating a TextBox
```luau
Window:Box({
   Name = "Walkspeed", 
   Callback = function(text, focuslost)
   		if focuslost then
          print(text)
      end
   end
})
```
Value:
- Name = string
- Callback = function (return string value)

### Creating a Dropdown
```luau
local dropdown = Window:Dropdown({
   Name = "Example dropdown", 
   Items = {
            "Button 1",
            "Button 2",
            {PlaceHolder = "- Text here -"},
            "Third button"
   }, 
   Callback = function(name)
        -- // Put your code here \\ --
        print(name)
   end
})
```
Value:
- Name = string
- Items = table or array
- Callback = function (return table value)

Adding new Button to Dropdown:
```luau
dropdown:Button("New button")
```

Removing Button to Dropdown:
```luau
dropdown:Remove("Button")
```
Adding new Placeholder to Dropdown:
```luau
dropdown:AddPlaceholder("New Placeholder")
```

### Creating a Notification
```luau
library:Notification({
	Title = "Title here!",
	Content = "Content here!",
	Time = 5
})
```
Value:
- Title = string
- Content = string
- Time = number

Destroying the UI:
```luau
library:Destroy()
```

# Change Log
### August, 30, Saturday, 2025
- Added a Notificaton function
- Fixed ColorPicker not matching colors

### September, 2, Tuesday, 2025
- Added a PlaceHolder on the Dropdown

### September, 6, Saturday, 2025
- Added a Orion or Rayfield function call style

### December, 15, Tuesday, 2025
- Added Toogle with loop

### December, 22, Monday, 2025
- Revamped window drag function

### September, 12, Saturday, 2026
- Added Loop setting on Toggle function
- Added MultiSelect setting on Dropdown function
- Added X Size setting on Window function
- Added Position setting on Window function

- Remove Toogle feature

- Fixing some Issue
- Updated to Scrolling Ui
