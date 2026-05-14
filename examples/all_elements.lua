local Exter = loadstring(game:HttpGet("https://raw.githubusercontent.com/SOBING4413/Exter-Library/main/ExterLibrary.lua"))()

local Window = Exter:CreateWindow({ Name = "All Elements", Subtitle = "Showcase" })
local Tab = Window:CreateTab({ Name = "Elements", Icon = "list" })

Tab:CreateSection("Buttons")
Tab:CreateButton({ Name = "Button", Callback = function() print("clicked") end })
Tab:CreateToggle({ Name = "Toggle", CurrentValue = false, Callback = function(v) print(v) end }, "ToggleFlag")
Tab:CreateSlider({ Name = "Slider", Range = {0, 100}, Increment = 1, CurrentValue = 25, Callback = function(v) print(v) end }, "SliderFlag")
Tab:CreateDropdown({ Name = "Dropdown", Options = {"A", "B", "C"}, CurrentOption = {"A"}, MultipleOptions = false, Callback = function(v) print(v) end }, "DropdownFlag")
Tab:CreateInput({ Name = "Input", PlaceholderText = "Type...", CurrentValue = "", Callback = function(v) print(v) end }, "InputFlag")
Tab:CreateColorPicker({ Name = "Color", Color = Color3.fromRGB(255, 0, 0), Callback = function(v) print(v) end }, "ColorFlag")
Tab:CreateBind({ Name = "Bind", CurrentBind = "F", HoldToInteract = false, Callback = function(v) print(v) end }, "BindFlag")
Tab:CreateLabel({ Text = "Label element" })
Tab:CreateParagraph({ Title = "Paragraph", Text = "This showcases all core UI elements." })

Exter:Notification({
    Title = "Loaded",
    Content = "All element examples created",
    Icon = "check_circle",
    ImageSource = "Material",
    Duration = 5
})
