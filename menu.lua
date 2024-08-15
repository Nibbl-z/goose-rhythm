local menu = {}

menu.Enabled = true

local editor = require("editor")
local transitions = require("transitions")
require("conductor")
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
    transitions:FadeIn(0)
    transitions:FadeOut(0.5)
    menuMusic:play()
    
    conductor.BPM = 128
    conductor:Init()
    
    mainPage.Position = UIVector2.new(0,0,0,0)
    levelsPage.Position = UIVector2.new(1,0,0,0)
    levelsContainer.Position = UIVector2.new(0,0,0,0)
end

function menu:Init()
    transitions:Init()
    
    menuMusic = love.audio.newSource("/music/menu.mp3", "stream")
    menuMusic:setLooping(true)
    menuMusic:setVolume(0.2)
    menuMusic:play()

    conductor.BPM = 128
    conductor:Init()
    
    bgImage = love.graphics.newImage("/img/menu_bg.png")
    bgImage:setWrap("repeat", "repeat")
    bgQuad = love.graphics.newQuad(0, 0, 200000, 200000, 800, 600)
    
    self.Screen = yan:Screen()
    
    mainPage = yan:Frame(self.Screen)
    mainPage.Size = UIVector2.new(1,0,1,0)
    mainPage.Color = Color.new(0,0,0,0)

    mainPage.Name = "MainPage"

    levelsPage = yan:Frame(self.Screen)
    levelsPage.Size = UIVector2.new(1,0,1,0)
    levelsPage.Position = UIVector2.new(1,0,0,0)
    levelsPage.Color = Color.new(0,0,0,0)
    
    title = yan:Image(self.Screen, "/img/logo.png")
    title.Size = UIVector2.new(0,439*0.9,0,256*0.9)
    title.Position = UIVector2.new(0.5,0,0.2,0)
    title.AnchorPoint = Vector2.new(0.5,0.5)
    
    titleBop = yan:NewTween(title, yan:TweenInfo(0.3, EasingStyle.QuadOut), {Size = UIVector2.new(0,439*0.9,0,256*0.9)})
    
    title.ZIndex = 3

    playLevels = yan:TextButton(self.Screen, "play levels", 50, "center", "center", "/ComicNeue.ttf")
    playLevels.Position = UIVector2.new(0.5,0,0.4,0)
    playLevels.Size = UIVector2.new(0.5, 0, 0.15, 0)
    playLevels.AnchorPoint = Vector2.new(0.5,0)

    playLevels.Color = Color.new(0,1,33/255, 1)
    playLevels.TextColor = Color.new(1,1,1,1)
    
    playHoverTween = yan:NewTween(playLevels, yan:TweenInfo(0.2, EasingStyle.QuadOut), {Size = UIVector2.new(0.5, 50, 0.15, 0), Color = Color.new(0.3,1,100/255,1)})
    playLeaveTween = yan:NewTween(playLevels, yan:TweenInfo(0.2, EasingStyle.QuadOut), {Size = UIVector2.new(0.5, 0, 0.15, 0), Color = Color.new(0,1,33/255,1)})
    
    playLevels.MouseEnter = function ()
        playHoverTween:Play()
    end
    
    playLevels.MouseLeave = function ()
        print("play leave")
        playLeaveTween:Play()
    end
    
    moveMainTween = yan:NewTween(mainPage, yan:TweenInfo(1, EasingStyle.QuadInOut), {Position = UIVector2.new(-1,0,0,0)})
    moveLevelsTween = yan:NewTween(levelsPage, yan:TweenInfo(1, EasingStyle.QuadInOut), {Position = UIVector2.new(0,0,0,0)})
    
    playLevels.MouseDown = function ()
        page = "levels"
        moveMainTween:Play()
        moveLevelsTween:Play()
        

        chartSelectionIndex = 1
        selectionPos = 0
        if previewMusic ~= nil then 
            previewMusic:stop()
        end
        
        previewMusic = love.audio.newSource( charts[chartSelectionIndex].."/song.mp3", "stream")
        previewMusic:setVolume(0.1)
        previewMusic:play()
        
        menuMusic:stop()
    end 
    
    openEditor = yan:TextButton(self.Screen, "open editor", 50, "center", "center", "/ComicNeue.ttf")
    openEditor.Position = UIVector2.new(0.5,0,0.55,10)
    openEditor.Size = UIVector2.new(0.5, 0, 0.15, 0)
    openEditor.AnchorPoint = Vector2.new(0.5,0)
    
    openEditor.Color = Color.new(178/255,0,1, 1)
    openEditor.TextColor = Color.new(1,1,1,1)

    editorHoverTween = yan:NewTween(openEditor, yan:TweenInfo(0.2, EasingStyle.QuadOut), {Size = UIVector2.new(0.5, 50, 0.15, 0), Color = Color.new(230/255,0,1, 1)})
    editorLeaveTween = yan:NewTween(openEditor, yan:TweenInfo(0.2, EasingStyle.QuadOut), {Size = UIVector2.new(0.5, 0, 0.15, 0), Color = Color.new(178/255,0,1, 1)})
    
    openEditor.MouseEnter = function ()
        editorHoverTween:Play()
    end
    
    openEditor.MouseLeave = function ()
        editorLeaveTween:Play()
    end
    
    openEditor.MouseDown = function ()
        transitions:FadeIn(0.2)
        
        fading = "editor"
        fadeDelay = love.timer.getTime() + 0.5
    end
    
    settingsBtn = yan:TextButton(self.Screen, "settings", 50, "center", "center", "/ComicNeue.ttf")
    settingsBtn.Position = UIVector2.new(0.5,0,0.7,20)
    settingsBtn.Size = UIVector2.new(0.5, 0, 0.15, 0)
    settingsBtn.AnchorPoint = Vector2.new(0.5,0)
    
    settingsHoverTween = yan:NewTween(settingsBtn, yan:TweenInfo(0.2, EasingStyle.QuadOut), {Size = UIVector2.new(0.5, 50, 0.15, 0), Color = Color.new(0.7,0.7,0.7,1)})
    settingsLeaveTween = yan:NewTween(settingsBtn, yan:TweenInfo(0.2, EasingStyle.QuadOut), {Size = UIVector2.new(0.5, 0, 0.15, 0), Color =  Color.new(0.5,0.5,0.5,1)})

    settingsBtn.Color = Color.new(0.5,0.5,0.5,1)
    settingsBtn.TextColor = Color.new(1,1,1,1)
    settingsBtn.MouseEnter = function ()
       settingsHoverTween:Play()
    end
    
    settingsBtn.MouseLeave = function ()
        settingsLeaveTween:Play()
    end

    title:SetParent(mainPage)
    title.Name = "Title"
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
            transitions:FadeIn(0.2)

            fading = "play"
            fadeDelay = love.timer.getTime() + 0.5
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

function menu:Metronome()
    print("Boppin")
    title.Size = UIVector2.new(0,439,0,256)
    titleBop:Play()
end

function menu:Update(dt)
    conductor:Update(dt)
    if fading ~= nil then
        if love.timer.getTime() > fadeDelay then
            if fading == "editor" then
                transitions:FadeOut(0.5)
                editor.Enabled = true
                editor:Init()
                
                self.Enabled = false
                self.Screen.Enabled = false
                menuMusic:stop()
                fading = nil
            end

            if fading == "play" then
                transitions:FadeOut(0.3)
                
                if previewMusic ~= nil then 
                    previewMusic:stop()
                end
    
                menu.playsong(charts[chartSelectionIndex])

                self.Enabled = false
                menuMusic:stop()
                fading = nil
            end
        end
    end
end

function menu:KeyPressed(key)
    if page == "levels" then
        if key == "left" or key == "a" then
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
        elseif key == "right" or key == "d" then
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

            conductor.BPM = 128
            conductor:Init()
        end
    end
end

return menu