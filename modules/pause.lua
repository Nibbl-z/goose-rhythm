local pause = {}

pause.Paused = false
require("yan")

function pause:Init()
    self.Screen = yan:Screen()
    self.Screen.Enabled = false
    self.Screen.ZIndex = 10
    
    pauseLabel = yan:Label(self.Screen, "PAUSED", 50, "center", "center", "/ComicNeue.ttf")
    pauseLabel.Position = UIVector2.new(0,0,0,0)
    pauseLabel.Size = UIVector2.new(1,0,0.2,0)
    pauseLabel.TextColor = Color.new(1,1,1,1)
    pauseLabel.ZIndex = 5

    resumeButton = yan:TextButton(self.Screen, "resume", 40, "center", "center", "/ComicNeue.ttf")
    resumeButton.Position = UIVector2.new(0.5,0,0.4,0)
    resumeButton.Size = UIVector2.new(0.5,0,0.15,0)
    resumeButton.AnchorPoint = Vector2.new(0.5,0)
    resumeButton.Color = Color.new(0,1,33/255, 1)
    resumeButton.TextColor = Color.new(1,1,1,1)
    resumeButton.ZIndex = 5
    
    quitButton = yan:TextButton(self.Screen, "quit", 40, "center", "center", "/ComicNeue.ttf")
    quitButton.Position = UIVector2.new(0.5,0,0.55,10)
    quitButton.Size = UIVector2.new(0.5,0,0.15,0)
    quitButton.AnchorPoint = Vector2.new(0.5,0)
    quitButton.Color = Color.new(1, 76/255, 76/255, 1)
    quitButton.TextColor = Color.new(1,1,1,1)
    quitButton.ZIndex = 5

    resumeEnterTween = yan:NewTween(resumeButton, yan:TweenInfo(0.2, EasingStyle.QuadOut), {Size = UIVector2.new(0.5, 50, 0.15, 0), Color = Color.new(0.3,1,100/255,1)})
    resumeLeaveTween = yan:NewTween(resumeButton, yan:TweenInfo(0.2, EasingStyle.QuadOut), {Size = UIVector2.new(0.5, 0, 0.15, 0), Color = Color.new(0,1,33/255,1)})
    
    resumeButton.MouseEnter = function ()
        resumeEnterTween:Play()
    end
    
    resumeButton.MouseLeave = function ()
        resumeLeaveTween:Play()
    end

    quitEnterTween = yan:NewTween(quitButton, yan:TweenInfo(0.2, EasingStyle.QuadOut), {Size = UIVector2.new(0.5, 50, 0.15, 0), Color = Color.new(1, 86/255, 86/255, 1)})
    quitLeaveTween = yan:NewTween(quitButton, yan:TweenInfo(0.2, EasingStyle.QuadOut), {Size = UIVector2.new(0.5, 0, 0.15, 0), Color = Color.new(1, 76/255, 76/255, 1)})
    
    quitButton.MouseEnter = function ()
        quitEnterTween:Play()
    end
    
    quitButton.MouseLeave = function ()
        quitLeaveTween:Play()
    end

    backgroundFrame = yan:Frame(self.Screen)
    backgroundFrame.Color = Color.new(0,0,0,0.5)
end

return pause