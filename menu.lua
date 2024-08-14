local menu = {}

menu.Enabled = true

local editor = require("editor")
local transitions = require("transitions")
require("yan") -- i cant wait to use tweens
-- i could wait to use tweens
-- they dont work im sad

local charts = {
    "/charts/greengoose", "/charts/purplegoose"
}

local chartSelectionIndex = 1
local selectionPos = 0
local page = "main"

local previewMusic = nil

local scrollX = 0
local scrollY = 0

local fadeDelay = 0
local fading = nil

function menu:Reset()
    menuMusic:play()
end

function menu:Init()
    transitions:Init()
    menuMusic = love.audio.newSource("/music/menu.mp3", "stream")
    menuMusic:setLooping(true)
    menuMusic:setVolume(0.2)
    menuMusic:play()

    bgImage = love.graphics.newImage("/img/menu_bg.png")
    bgImage:setWrap("repeat", "repeat")
    bgQuad = love.graphics.newQuad(0, 0, 200000, 200000, 800, 600)
    
    self.Screen = yan:Screen()
    
    mainPage = yan:Frame(self.Screen)
    mainPage.Size = UIVector2.new(1,0,1,0)
    mainPage.Color = Color.new(0,0,0,0)

    levelsPage = yan:Frame(self.Screen)
    levelsPage.Size = UIVector2.new(1,0,1,0)
    levelsPage.Position = UIVector2.new(1,0,0,0)
    levelsPage.Color = Color.new(0,0,0,0)
    
    title = yan:Image(self.Screen, "/img/logo.png")
    title.Size = UIVector2.new(0,439*0.9,0,256*0.9)
    title.Position = UIVector2.new(0.5,0,0,0)
    title.AnchorPoint = Vector2.new(0.5,0)
    
    title.ZIndex = 3

    playLevels = yan:TextButton(self.Screen, "play levels", 50, "center", "center", "/ComicNeue.ttf")
    playLevels.Position = UIVector2.new(0.5,0,0.4,0)
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
        

        chartSelectionIndex = 1
        selectionPos = 0
        if previewMusic ~= nil then 
            previewMusic:stop()
        end
        
        previewMusic = love.audio.newSource( charts[chartSelectionIndex].."/song.mp3", "stream")
        previewMusic:setVolume(0.1)
        previewMusic:play()
        menuMusic:pause()
    end 
    
    openEditor = yan:TextButton(self.Screen, "open editor", 50, "center", "center", "/ComicNeue.ttf")
    openEditor.Position = UIVector2.new(0.5,0,0.55,10)
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
    
    openEditor.MouseDown = function ()
        transitions:FadeIn(1)

        fading = "editor"
        fadeDelay = love.timer.getTime() + 1
    end

    settingsBtn = yan:TextButton(self.Screen, "settings", 50, "center", "center", "/ComicNeue.ttf")
    settingsBtn.Position = UIVector2.new(0.5,0,0.7,20)
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
        local metadata = love.filesystem.read(chart.."/metadata.lua")
        local loadedMetadata = loadstring(metadata)()

        local frame = yan:Image(self.Screen, chart.."/assets/bg.png")
        frame.Size = UIVector2.new(1,0,1,0)
        frame.Position = UIVector2.new(i - 1, 0, 0, 0)
        frame.Color = Color.new(0.5,0.5,0.5,1)
        frame.ZIndex = -2
        
        local cover = yan:Image(self.Screen, chart.."/cover.png")
        cover.Size = UIVector2.new(0,250,0,250)
        cover.Position = UIVector2.new(0.5,0,0.5,0)
        cover.AnchorPoint = Vector2.new(0.5,0.5)
        
        local title = yan:Label(self.Screen, loadedMetadata.SongName, 50, "center", "center", "/ComicNeue.ttf")
        title.Size = UIVector2.new(1,0,0.15,0)
        title.TextColor = Color.new(1,1,1,1)
        
        local artist = yan:Label(self.Screen, "by "..loadedMetadata.SongArtist, 30, "center", "center", "/ComicNeue.ttf")
        artist.Size = UIVector2.new(1,0,0.1,0)
        artist.Position = UIVector2.new(0,0,0.1,0)
        artist.TextColor = Color.new(1,1,1,1)
        
        local mapper = yan:Label(self.Screen, "mapped by "..loadedMetadata.Charter, 20, "center", "center", "/ComicNeue.ttf")
        mapper.Size = UIVector2.new(1,0,0.05,0)
        mapper.Position = UIVector2.new(0,0,0.17,0)
        mapper.TextColor = Color.new(0.8,0.8,0.8,1)
        
        local playButton = yan:TextButton(self.Screen, "Play", 50, "center", "center", "/ComicNeue.ttf")
        playButton.Position = UIVector2.new(0.5,0,1,-20)
        playButton.Size = UIVector2.new(0.3,0,0.1,0)
        playButton.AnchorPoint = Vector2.new(0.5, 1)
        
        playButton.MouseDown = function ()
            if previewMusic ~= nil then 
                previewMusic:stop()
            end

            menu.playsong(chart)
            menuMusic:stop()
        end

        frame:SetParent(levelsContainer)
        cover:SetParent(frame)
        title:SetParent(frame)
        artist:SetParent(frame)
        playButton:SetParent(frame)
        mapper:SetParent(frame)
    end
end

function menu:Draw()
    love.graphics.draw(bgImage, bgQuad, (800 * -20) + scrollX, (600 * -20) + scrollY)

    --scrollX = scrollX + 0.1
    scrollY = scrollY + 0.1
end

function menu:MouseMoved(_, _, x, y)
    scrollX = scrollX + x * 0.2
    scrollY = scrollY + y * 0.2
end

function menu:Update(dt)
    if fading ~= nil then
        if love.timer.getTime() > fadeDelay then
            if fading == "editor" then
                transitions:FadeOut(1)
                
                editor:Init()
                editor.Enabled = true
                self.Enabled = false
                self.Screen.Enabled = false
                menuMusic:stop()
            end
        end
    end
end

function menu:KeyPressed(key)
    if page == "levels" then
        if key == "left" then
            if chartSelectionIndex > 1 then
                chartSelectionIndex = chartSelectionIndex - 1
                selectionPos = selectionPos + 1
                yan:NewTween(levelsContainer, yan:TweenInfo(1, EasingStyle.BackOut), {Position = UIVector2.new(selectionPos, 0, 0, 0)}):Play()

                if previewMusic ~= nil then 
                    previewMusic:stop()
                end
                
                previewMusic = love.audio.newSource( charts[chartSelectionIndex].."/song.mp3", "stream")
                previewMusic:setVolume(0.1)
                previewMusic:play()
               
            end
        elseif key == "right" then
            if chartSelectionIndex < #charts then
                chartSelectionIndex = chartSelectionIndex + 1
                selectionPos = selectionPos - 1
                yan:NewTween(levelsContainer, yan:TweenInfo(1, EasingStyle.BackOut), {Position = UIVector2.new(selectionPos, 0, 0, 0)}):Play()

                if previewMusic ~= nil then 
                    previewMusic:stop()
                end
                
                previewMusic = love.audio.newSource( charts[chartSelectionIndex].."/song.mp3", "stream")
                previewMusic:setVolume(0.1)
                previewMusic:play()
            end
        end
        
        if key == "escape" then
            page = "main"
            yan:NewTween(levelsContainer, yan:TweenInfo(1, EasingStyle.QuadInOut), {Position = UIVector2.new(0, 0, 0, 0)}):Play()
            yan:NewTween(mainPage, yan:TweenInfo(1, EasingStyle.QuadInOut), {Position = UIVector2.new(0,0,0,0)}):Play()
            yan:NewTween(levelsPage, yan:TweenInfo(1, EasingStyle.QuadInOut), {Position = UIVector2.new(1,0,0,0)}):Play()

            if previewMusic ~= nil then 
                previewMusic:stop()
            end

            menuMusic:play()
        end
    end
end

return menu