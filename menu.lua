local menu = {}

menu.Enabled = true

require("yan") -- i cant wait to use tweens

function menu:Init()
    self.Screen = yan:Screen()

    title = yan:Label(self.Screen, "goose rhythm", 60, "center", "center", "/ComicNeue.ttf")
    title.Size = UIVector2.new(1,0,0.3,0)
    title.TextColor = Color.new(1,1,1,1)
    
    playLevels = yan:TextButton(self.Screen, "play levels", 50, "center", "center", "/ComicNeue.ttf")
    playLevels.Position = UIVector2.new(0.5,0,0.3,0)
    playLevels.Size = UIVector2.new(0.5, 0, 0.15, 0)
    playLevels.AnchorPoint = Vector2.new(0.5,0)
    
    playHoverTween = yan:NewTween(playLevels, yan:TweenInfo(0.2, EasingStyle.QuadOut), {Size = UIVector2.new(0.5, 50, 0.15, 0)})
    playLeaveTween = yan:NewTween(playLevels, yan:TweenInfo(0.2, EasingStyle.QuadOut), {Size = UIVector2.new(0.5, 0, 0.15, 0)})

    playLevels.MouseEnter = function ()
        playHoverTween:Play()
        playLeaveTween:Stop()
    end
    
    playLevels.MouseLeave = function ()
        playHoverTween:Stop()
        playLeaveTween:Play()
    end
    
    openEditor = yan:TextButton(self.Screen, "open editor", 50, "center", "center", "/ComicNeue.ttf")
    openEditor.Position = UIVector2.new(0.5,0,0.45,10)
    openEditor.Size = UIVector2.new(0.5, 0, 0.15, 0)
    openEditor.AnchorPoint = Vector2.new(0.5,0)

    editorHoverTween = yan:NewTween(openEditor, yan:TweenInfo(0.2, EasingStyle.QuadOut), {Size = UIVector2.new(0.5, 50, 0.15, 0)})
    editorLeaveTween = yan:NewTween(openEditor, yan:TweenInfo(0.2, EasingStyle.QuadOut), {Size = UIVector2.new(0.5, 0, 0.15, 0)})
    
    openEditor.MouseEnter = function ()
        editorHoverTween:Play()
        editorLeaveTween:Stop()
    end
    
    openEditor.MouseLeave = function ()
        editorHoverTween:Stop()
        editorLeaveTween:Play()
    end

    settingsBtn = yan:TextButton(self.Screen, "settings", 50, "center", "center", "/ComicNeue.ttf")
    settingsBtn.Position = UIVector2.new(0.5,0,0.6,20)
    settingsBtn.Size = UIVector2.new(0.5, 0, 0.15, 0)
    settingsBtn.AnchorPoint = Vector2.new(0.5,0)

    settingsHoverTween = yan:NewTween(settingsBtn, yan:TweenInfo(0.2, EasingStyle.QuadOut), {Size = UIVector2.new(0.5, 50, 0.15, 0)})
    settingsLeaveTween = yan:NewTween(settingsBtn, yan:TweenInfo(0.2, EasingStyle.QuadOut), {Size = UIVector2.new(0.5, 0, 0.15, 0)})
    
    settingsBtn.MouseEnter = function ()
        settingsHoverTween:Play()
        settingsLeaveTween:Stop()
    end
    
    settingsBtn.MouseLeave = function ()
        settingsHoverTween:Stop()
        settingsLeaveTween:Play()
    end
end

return menu