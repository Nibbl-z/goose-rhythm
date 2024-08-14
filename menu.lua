local menu = {}

menu.Enabled = true

require("yan") -- i cant wait to use tweens
-- i could wait to use tweens
-- they dont work im sad

local charts = {
    "/charts/greengoose", "/charts/purplegoose"
}

local chartSelectionIndex = 1
local selectionPos = 0
local page = "main"

function menu:Init()
    self.Screen = yan:Screen()
    
    mainPage = yan:Frame(self.Screen)
    mainPage.Size = UIVector2.new(1,0,1,0)
    mainPage.Color = Color.new(0,0,0,0)

    levelsPage = yan:Frame(self.Screen)
    levelsPage.Size = UIVector2.new(1,0,1,0)
    levelsPage.Position = UIVector2.new(1,0,0,0)
    levelsPage.Color = Color.new(0,0,0,0)

    title = yan:Label(self.Screen, "goose rhythm", 60, "center", "center", "/ComicNeue.ttf")
    title.Size = UIVector2.new(1,0,0.3,0)
    title.TextColor = Color.new(1,1,1,1)

    playLevels = yan:TextButton(self.Screen, "play levels", 50, "center", "center", "/ComicNeue.ttf")
    playLevels.Position = UIVector2.new(0.5,0,0.3,0)
    playLevels.Size = UIVector2.new(0.5, 0, 0.15, 0)
    playLevels.AnchorPoint = Vector2.new(0.5,0)
    
    playHoverTween = yan:NewTween(playLevels, yan:TweenInfo(0.2, EasingStyle.QuadOut), {Size = UIVector2.new(0.6, 0, 0.15, 0)})
    playLeaveTween = yan:NewTween(playLevels, yan:TweenInfo(0.2, EasingStyle.QuadOut), {Size = UIVector2.new(0.5, 0, 0.15, 0)})
    
    playLevels.MouseEnter = function ()
        print("play enter")
        
        yan:NewTween(playLevels, yan:TweenInfo(0.2, EasingStyle.QuadOut), {Size = UIVector2.new(0.6, 0, 0.15, 0)}):Play()
    end
    
    playLevels.MouseLeave = function ()
        print("play leave")
        --playHoverTween:Stop() 
        yan:NewTween(playLevels, yan:TweenInfo(0.2, EasingStyle.QuadOut), {Size = UIVector2.new(0.5, 0, 0.15, 0)}):Play()
    end
    
    playLevels.MouseDown = function ()
        page = "levels"
        yan:NewTween(mainPage, yan:TweenInfo(1, EasingStyle.QuadInOut), {Position = UIVector2.new(-1,0,0,0)}):Play()
        yan:NewTween(levelsPage, yan:TweenInfo(1, EasingStyle.QuadInOut), {Position = UIVector2.new(0,0,0,0)}):Play()
    end 
    
    openEditor = yan:TextButton(self.Screen, "open editor", 50, "center", "center", "/ComicNeue.ttf")
    openEditor.Position = UIVector2.new(0.5,0,0.45,10)
    openEditor.Size = UIVector2.new(0.5, 0, 0.15, 0)
    openEditor.AnchorPoint = Vector2.new(0.5,0)

    editorHoverTween = yan:NewTween(openEditor, yan:TweenInfo(0.2, EasingStyle.QuadOut), {Size = UIVector2.new(0.5, 50, 0.15, 0)})
    editorLeaveTween = yan:NewTween(openEditor, yan:TweenInfo(0.2, EasingStyle.QuadOut), {Size = UIVector2.new(0.5, 0, 0.15, 0)})
    
    openEditor.MouseEnter = function ()
      --  editorLeaveTween:Stop()
      yan:NewTween(openEditor, yan:TweenInfo(0.2, EasingStyle.QuadOut), {Size = UIVector2.new(0.5, 50, 0.15, 0)}):Play()
    end
    
    openEditor.MouseLeave = function ()
       -- editorHoverTween:Stop()
       yan:NewTween(openEditor, yan:TweenInfo(0.2, EasingStyle.QuadOut), {Size = UIVector2.new(0.5, 0, 0.15, 0)}):Play()
    end

    settingsBtn = yan:TextButton(self.Screen, "settings", 50, "center", "center", "/ComicNeue.ttf")
    settingsBtn.Position = UIVector2.new(0.5,0,0.6,20)
    settingsBtn.Size = UIVector2.new(0.5, 0, 0.15, 0)
    settingsBtn.AnchorPoint = Vector2.new(0.5,0)
    
    settingsHoverTween = yan:NewTween(settingsBtn, yan:TweenInfo(0.2, EasingStyle.QuadOut), {Size = UIVector2.new(0.5, 50, 0.15, 0)})
    settingsLeaveTween = yan:NewTween(settingsBtn, yan:TweenInfo(0.2, EasingStyle.QuadOut), {Size = UIVector2.new(0.5, 0, 0.15, 0)})
    
    settingsBtn.MouseEnter = function ()
       -- settingsLeaveTween:Stop()
       yan:NewTween(settingsBtn, yan:TweenInfo(0.2, EasingStyle.QuadOut), {Size = UIVector2.new(0.5, 50, 0.15, 0)}):Play()
       
    end
    
    settingsBtn.MouseLeave = function ()
        --settingsHoverTween:Stop()
        yan:NewTween(settingsBtn, yan:TweenInfo(0.2, EasingStyle.QuadOut), {Size = UIVector2.new(0.5, 0, 0.15, 0)}):Play()
    end

    title:SetParent(mainPage)
    playLevels:SetParent(mainPage)
    openEditor:SetParent(mainPage)
    settingsBtn:SetParent(mainPage)
    
    chartFrames = {}
    
    levelsContainer = yan:Frame(self.Screen)
    levelsContainer.Size = UIVector2.new(1,0,1,0)
    levelsContainer.Color = Color.new(0,0,0,0)
    levelsContainer:SetParent(levelsPage)

    for i, chart in ipairs(charts) do
        local frame = yan:Frame(self.Screen)
        frame.Size = UIVector2.new(1,0,1,0)
        frame.Position = UIVector2.new(i - 1, 0, 0, 0)
        frame.Color = Color.new(0,0,0,0)
        
        local cover = yan:Image(self.Screen, chart.."/cover.png")
        cover.Size = UIVector2.new(0,150,0,150)
        cover.Position = UIVector2.new(0.5,0,0.5,0)
        cover.AnchorPoint = Vector2.new(0.5,0.5)

        local title = yan:Label(self.Screen, "placeholder", 50, "center", "center", "/ComicNeue.ttf")
        title.Size = UIVector2.new(1,0,0.2,0)
        title.TextColor = Color.new(1,1,1,1)

        frame:SetParent(levelsContainer)
        cover:SetParent(frame)
        title:SetParent(frame)
    end
end

function menu:KeyPressed(key)
    if page == "levels" then
        if key == "left" then
            if chartSelectionIndex > 1 then
                chartSelectionIndex = chartSelectionIndex - 1
                selectionPos = selectionPos + 1
                yan:NewTween(levelsContainer, yan:TweenInfo(0.3, EasingStyle.QuadOut), {Position = UIVector2.new(selectionPos, 0, 0, 0)}):Play()
            end
        elseif key == "right" then
            if chartSelectionIndex < #charts then
                chartSelectionIndex = chartSelectionIndex + 1
                selectionPos = selectionPos - 1
                yan:NewTween(levelsContainer, yan:TweenInfo(0.3, EasingStyle.QuadOut), {Position = UIVector2.new(selectionPos, 0, 0, 0)}):Play()
            end
        end
    end
end

return menu