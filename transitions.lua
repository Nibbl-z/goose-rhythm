local transitions = {}
require("yan")
function transitions:Init()
    self.Screen = yan:Screen()
    self.Screen.ZIndex = 100
    self.Screen.Enabled = true
    
    fadeFrame = yan:Frame(self.Screen)
    fadeFrame.Size = UIVector2.new(1,0,1,0)
    fadeFrame.Color = Color.new(0,0,0,0)
end

function transitions:FadeIn(duration)
    yan:NewTween(fadeFrame, yan:TweenInfo(duration, EasingStyle.Linear), {Color = Color.new(0,0,0,1)}):Play()
end

function transitions:FadeOut(duration)
    yan:NewTween(fadeFrame, yan:TweenInfo(duration, EasingStyle.Linear), {Color = Color.new(0,0,0,0)}):Play()
end

return transitions