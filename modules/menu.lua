local menu = {}

menu.Enabled = true
local settings = require("modules.settings")
local editor = require("modules.editor")
local transitions = require("modules.transitions")
require("modules.conductor")
require("yan") -- i cant wait to use tweens
-- i could wait to use tweens
-- they dont work im sad

local charts = {
    "/charts/greengoose", "/charts/purplegoose", "/charts/orangegoose", "/charts/whitegoose", "/charts/bluegoose"
}

local customCharts = {}

local sfx = {
    Select = love.audio.newSource("/sfx/select.wav", "static"),
    Error = love.audio.newSource("/sfx/error.wav", "static"),
    Success = love.audio.newSource("/sfx/success.wav", "static")
}

local chartSelectionIndex = 1
local customChartSelectionIndex = 1
local selectionPos = 0
local customSelectionPos = 0
local page = "main"

local previewMusic = nil

local scrollX = 0
local scrollY = 0

local fadeDelay = 0
local fading = nil

local bgOffset = {Pos = 0, MusicVolume = 1, SettingsVolume = 0 }

local choosingKeybind = -1
local choosingButton = nil

local menuMoving = false
local menuStopMovingDelay = -1

local customChartFrames = {}

local creatingLevel = {
    SongName = "",
    SongArtist = "",
    Charter = "",
    SongOgg = nil,
    BG = nil,
    Goose = nil,
    GooseMiss = nil,
    Cover = nil
}
local droppingFile = nil

function menu:Reset()
    page = "main"
    transitions:FadeIn(0)
    transitions:FadeOut(0.5)
    menuMusic:play()
    menuMusicSettings:play()
    
    conductor.BPM = 128
    conductor:Init()
    
    mainPage.Position = UIVector2.new(0,0,0,0)
    levelsPage.Position = UIVector2.new(1,0,0,0)
    levelsContainer.Position = UIVector2.new(0,0,0,0)

    customLevelsPage.Position = UIVector2.new(1,0,0,0)
    customLevelsContainer.Position = UIVector2.new(0,0,0,0)
end

function RefreshCustomLevels()
    customCharts = {}

    for _, v in ipairs(customChartFrames) do
        v = nil
    end
    customChartFrames = {}

    for _, file in ipairs(love.filesystem.getDirectoryItems("/customLevels")) do
        print(file)
        if love.filesystem.getInfo("/customLevels/"..file).type == "directory" then
            table.insert(customCharts, "/customLevels/"..file)
        end
    end

    for i, chart in ipairs(customCharts) do
        local metadata = love.filesystem.read(chart.."/metadata.lua")
        local loadedMetadata = loadstring(metadata)()
        
        local bgfileExt = ".png"
        if love.filesystem.getInfo(chart.."/assets/bg.png") ~= nil then
            bgfileExt = ".png"
        elseif love.filesystem.getInfo(chart.."/assets/bg.jpg") ~= nil then
            bgfileExt = ".jpg"
        elseif love.filesystem.getInfo(chart.."/assets/bg.jpeg") ~= nil then
            bgfileExt = ".jpeg"
        elseif love.filesystem.getInfo(chart.."/assets/bg.bmp") ~= nil then
            bgfileExt = ".bmp"
        end
        
        local coverfileExt = ".png"
        if love.filesystem.getInfo(chart.."/cover.png") ~= nil then
            coverfileExt = ".png"
        elseif love.filesystem.getInfo(chart.."/cover.jpg") ~= nil then
            coverfileExt = ".jpg"
        elseif love.filesystem.getInfo(chart.."/cover.jpeg") ~= nil then
            coverfileExt = ".jpeg"
        elseif love.filesystem.getInfo(chart.."/cover.bmp") ~= nil then
            coverfileExt = ".bmp"
        end
        
        local frame = yan:Image(menu.Screen, chart.."/assets/bg"..bgfileExt)
        frame.Size = UIVector2.new(1,0,1,0)
        frame.Position = UIVector2.new(i - 1, 0, 0, 0)
        frame.Color = Color.new(0.5,0.5,0.5,1)
        frame.ZIndex = -2
        
        local cover = yan:Image(menu.Screen, chart.."/cover"..coverfileExt)
        cover.Size = UIVector2.new(0,250,0,250)
        cover.Position = UIVector2.new(0.5,0,0.5,0)
        cover.AnchorPoint = Vector2.new(0.5,0.5)
        
        local title = yan:Label(menu.Screen, loadedMetadata.SongName, 50, "center", "center", "/ComicNeue.ttf")
        title.Size = UIVector2.new(1,0,0.15,0)
        title.TextColor = Color.new(1,1,1,1)
        
        local artist = yan:Label(menu.Screen, "by "..loadedMetadata.SongArtist, 30, "center", "center", "/ComicNeue.ttf")
        artist.Size = UIVector2.new(1,0,0.1,0)
        artist.Position = UIVector2.new(0,0,0.1,0)
        artist.TextColor = Color.new(1,1,1,1)
        
        local mapper = yan:Label(menu.Screen, "mapped by "..loadedMetadata.Charter, 20, "center", "center", "/ComicNeue.ttf")
        mapper.Size = UIVector2.new(1,0,0.05,0)
        mapper.Position = UIVector2.new(0,0,0.17,0)
        mapper.TextColor = Color.new(0.8,0.8,0.8,1)
        
        local playButton = yan:TextButton(menu.Screen, "Play", 50, "center", "center", "/ComicNeue.ttf")
        playButton.Position = UIVector2.new(0.5,0,1,-20)
        playButton.Size = UIVector2.new(0.3,0,0.1,0)
        playButton.AnchorPoint = Vector2.new(0.5, 1)
        

        playButton.MouseEnter = function ()
            playButton.Color = Color.new(0.7,0.7,0.7,1)
        end
        
        playButton.MouseLeave = function ()
            playButton.Color = Color.new(1,1,1,1)
        end
        playButton.MouseDown = function ()
            sfx.Select:play()
            transitions:FadeIn(0.2)

            fading = "play"
            fadeDelay = love.timer.getTime() + 0.5
            menuMusic:stop()
            menuMusicSettings:stop()
        end
        table.insert(customChartFrames, frame)
        frame:SetParent(customLevelsContainer)
        cover:SetParent(frame)
        title:SetParent(frame)
        artist:SetParent(frame)
        playButton:SetParent(frame)
        mapper:SetParent(frame)
    end

    if #customCharts ~= 0 then
        noLevelsLabel.Visible = false
    end
end

function menu:Init()
    
    transitions:Init()
    
    menuMusic = love.audio.newSource("/music/menu.mp3", "static")
    menuMusic:setLooping(true)
    menuMusic:setVolume(0.2)

    menuMusicSettings = love.audio.newSource("/music/menu_settings.mp3", "static")
    menuMusicSettings:setLooping(true)
    menuMusicSettings:setVolume(0.2)
    
    menuMusicSettings:play()
    menuMusic:play()

    conductor.BPM = 128
    conductor:Init()
    
    bgImage = love.graphics.newImage("/img/menu_bg.png")
    bgImage:setWrap("repeat", "repeat")
    bgQuad = love.graphics.newQuad(0, 0, 20000000, 20000000, 800, 600)
    
    self.Screen = yan:Screen()
    
    
    mainPage = yan:Frame(self.Screen)
    mainPage.Size = UIVector2.new(1,0,1,0)
    mainPage.Color = Color.new(0,0,0,0)

    mainPage.Name = "MainPage"

    levelsPage = yan:Frame(self.Screen)
    levelsPage.Size = UIVector2.new(1,0,1,0)
    levelsPage.Position = UIVector2.new(1,0,0,0)
    levelsPage.Color = Color.new(0,0,0,0)

    settingsFrame = yan:Frame(self.Screen)
    settingsFrame.Position = UIVector2.new(0,0,1,0)
    settingsFrame.Size = UIVector2.new(1,0,1,0)
    settingsFrame.Color = Color.new(0,0,0,0)

    customLevelsPage = yan:Frame(self.Screen)
    customLevelsPage.Size = UIVector2.new(1,0,1,0)
    customLevelsPage.Position = UIVector2.new(1,0,0,0)
    customLevelsPage.Color = Color.new(0,0,0,0)
    
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
        if menuMoving then return end
        menuMoving = true
        menuStopMovingDelay = love.timer.getTime() + 1
        
        sfx.Select:play()
        page = "levels"
        moveMainTween:Play()
        moveLevelsTween:Play()

        chartSelectionIndex = 1
        selectionPos = 0
        if previewMusic ~= nil then 
            previewMusic:stop()
        end
        
        local metadata = love.filesystem.read(charts[chartSelectionIndex].."/metadata.lua")
        local loadedMetadata = loadstring(metadata)()

        previewMusic = love.audio.newSource( charts[chartSelectionIndex].."/song.ogg", "stream")
        previewMusic:setVolume(0.1)
        previewMusic:play()
        previewMusic:seek(loadedMetadata.PreviewSongTime, "seconds")
        
        menuMusic:stop()
        menuMusicSettings:stop()
    end 
    
    openEditor = yan:TextButton(self.Screen, "custom levels", 50, "center", "center", "/ComicNeue.ttf")
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
    moveCustomLevelsTween = yan:NewTween(customLevelsPage, yan:TweenInfo(1, EasingStyle.QuadInOut), {Position = UIVector2.new(0,0,0,0)})
    openEditor.MouseDown = function ()
        if menuMoving then return end
        menuMoving = true
        menuStopMovingDelay = love.timer.getTime() + 1
        
        sfx.Select:play()
        page = "customlevels"
        moveMainTween:Play()
        moveCustomLevelsTween:Play()

        customChartSelectionIndex = 1
        customSelectionPos = 0
        if previewMusic ~= nil then 
            previewMusic:stop()
        end
        
        local metadata = love.filesystem.read(customCharts[customChartSelectionIndex].."/metadata.lua")
        local loadedMetadata = loadstring(metadata)()

        previewMusic = love.audio.newSource(customCharts[customChartSelectionIndex].."/song.ogg", "stream")
        previewMusic:setVolume(0.1)
        previewMusic:play()
        previewMusic:seek(loadedMetadata.PreviewSongTime, "seconds")
        
        menuMusic:stop()
        menuMusicSettings:stop()
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
    moveMainSettingsTween = yan:NewTween(mainPage, yan:TweenInfo(1, EasingStyle.QuadInOut), {Position = UIVector2.new(0,0,-1,0)})
    moveSettingsTween = yan:NewTween(settingsFrame, yan:TweenInfo(1, EasingStyle.QuadInOut), {Position = UIVector2.new(0,0,0,0)})
    settingsBtn.MouseDown = function ()
        if menuMoving then return end
        menuMoving = true
        menuStopMovingDelay = love.timer.getTime() + 1
        
        sfx.Select:play()
        page = "settings"
        
        moveMainSettingsTween:Play()
        moveSettingsTween:Play()
        yan:NewTween(bgOffset, yan:TweenInfo(1, EasingStyle.QuadInOut), {Pos = 400, MusicVolume = 0, SettingsVolume = 1}):Play()
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

    levelsBackBtn = yan:ImageButton(self.Screen, "/img/back_btn.png")
    levelsBackBtn.Size = UIVector2.new(0,50,0,50)
    levelsBackBtn.Position = UIVector2.new(0,10,0,10)
    levelsBackBtn:SetParent(levelsPage)
    levelsBackBtn.ZIndex = 10
    levelsBackBtn.MouseEnter = function ()
        levelsBackBtn.Color = Color.new(0.7,0.7,0.7,1)
    end

    levelsBackBtn.MouseLeave = function ()
        levelsBackBtn.Color = Color.new(1,1,1,1)
    end

    levelsBackBtn.MouseDown = function ()
        if menuMoving then return end
        menuMoving = true
        menuStopMovingDelay = love.timer.getTime() + 1
        
        sfx.Select:play()
        page = "main"
        yan:NewTween(levelsContainer, yan:TweenInfo(1, EasingStyle.QuadInOut), {Position = UIVector2.new(0, 0, 0, 0)}):Play()
        yan:NewTween(mainPage, yan:TweenInfo(1, EasingStyle.QuadInOut), {Position = UIVector2.new(0,0,0,0)}):Play()
        yan:NewTween(levelsPage, yan:TweenInfo(1, EasingStyle.QuadInOut), {Position = UIVector2.new(1,0,0,0)}):Play()
        
        if previewMusic ~= nil then 
            previewMusic:stop()
        end
        
        menuMusic:play()
        menuMusicSettings:play()

        conductor.BPM = 128
        conductor:Init()
        
        levelsBackBtn.Color = Color.new(1,1,1,1)
    end
    
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
        

        playButton.MouseEnter = function ()
            playButton.Color = Color.new(0.7,0.7,0.7,1)
        end
        
        playButton.MouseLeave = function ()
            playButton.Color = Color.new(1,1,1,1)
        end
        playButton.MouseDown = function ()
            sfx.Select:play()
            transitions:FadeIn(0.2)

            fading = "play"
            fadeDelay = love.timer.getTime() + 0.5
            menuMusic:stop()
            menuMusicSettings:stop()
        end
        
        frame:SetParent(levelsContainer)
        cover:SetParent(frame)
        title:SetParent(frame)
        artist:SetParent(frame)
        playButton:SetParent(frame)
        mapper:SetParent(frame)
    end
    
    

    volumeSlider = yan:Slider(self.Screen, 0.0, 1.0, settings:GetMusicVolume())
    volumeSlider.Style = "fill"
    volumeSlider.Position = UIVector2.new(0.4, 0, 0.2,0)
    volumeSlider.Size = UIVector2.new(0.5, -10, 0.1,0)
    volumeSlider.SliderColor = Color.new(0.5,0.5,0.5,1)
    volumeSlider:SetParent(settingsFrame)
    volumeSlider.CornerRoundness = 8
    
    volumeLabel = yan:Label(self.Screen, "Music Volume", 32, "right", "center", "/ComicNeue.ttf")
    volumeLabel.Size = UIVector2.new(0.5,0,1,0)
    volumeLabel.Position = UIVector2.new(0, -50, 0, 0)
    volumeLabel.AnchorPoint = Vector2.new(1,0)
    volumeLabel.TextColor = Color.new(1,1,1,1)
    volumeLabel:SetParent(volumeSlider)

    settingsBackBtn = yan:ImageButton(self.Screen, "/img/back_btn_up.png")
    settingsBackBtn.Size = UIVector2.new(0,50,0,50)
    settingsBackBtn.Position = UIVector2.new(0,10,0,10)
    settingsBackBtn:SetParent(settingsFrame)
    settingsBackBtn.ZIndex = 10
    settingsBackBtn.MouseEnter = function ()
        settingsBackBtn.Color = Color.new(0.7,0.7,0.7,1)
    end
    
    settingsBackBtn.MouseLeave = function ()
        settingsBackBtn.Color = Color.new(1,1,1,1)
    end

    settingsBackBtn.MouseDown = function ()
        if menuMoving then return end
        menuMoving = true
        menuStopMovingDelay = love.timer.getTime() + 1

        if choosingKeybind ~= -1 then
            choosingButton.Text = settings.Keybinds[choosingKeybind]
            choosingButton.Color = Color.new(1,1,1,1)
            choosingKeybind = -1
            choosingButton = nil
        end
        
        sfx.Select:play()
        page = "main"
        yan:NewTween(settingsFrame, yan:TweenInfo(1, EasingStyle.QuadInOut), {Position = UIVector2.new(0, 0, 1, 0)}):Play()
        yan:NewTween(mainPage, yan:TweenInfo(1, EasingStyle.QuadInOut), {Position = UIVector2.new(0,0,0,0)}):Play()
        yan:NewTween(bgOffset, yan:TweenInfo(1, EasingStyle.QuadInOut), {Pos = 0, MusicVolume = 1, SettingsVolume = 0}):Play()

        settings:Save()

        settingsBackBtn.Color = Color.new(1,1,1,1)
    end
    
    
    for i = 1, 4 do
        local keybutton = yan:TextButton(self.Screen, settings:GetKeybinds()[i], 40, "center", "center", "/ComicNeue.ttf")
        keybutton.Position = UIVector2.new(0.4, 0, 0.2 + (i * 0.1), i * 10)
        keybutton.Size = UIVector2.new(0.5, -10, 0.1,0)
        keybutton:SetParent(settingsFrame)
        keybutton.CornerRoundness = 8

        keylabel = yan:Label(self.Screen, "Note "..i.." Keybind", 32, "right", "center", "/ComicNeue.ttf")
        keylabel.Size = UIVector2.new(0.7,0,1,0)
        keylabel.Position = UIVector2.new(0, -50, 0, 0)
        keylabel.AnchorPoint = Vector2.new(1,0)
        keylabel.TextColor = Color.new(1,1,1,1)
        keylabel:SetParent(keybutton)

        keybutton.MouseEnter = function ()
            if choosingKeybind ~= i then
                keybutton.Color = Color.new(0.7,0.7,0.7,1)
            end
        end

        keybutton.MouseLeave = function ()
            if choosingKeybind ~= i then
                keybutton.Color = Color.new(1,1,1,1)
            end
        end
        
        keybutton.MouseDown = function ()
            sfx.Select:play()
            if choosingKeybind ~= -1 then return end
            keybutton.Color = Color.new(0.5,0.5,0.5,1)
            choosingKeybind = i
            choosingButton = keybutton
            keybutton.Text = "Choose a key"
        end
    end
    
    noteSpeedInput = yan:TextInputter(self.Screen, "300", 40, "center", "center", "/ComicNeue.ttf")
    noteSpeedInput.Position = UIVector2.new(0.4, 0, 0.7, 50)
    noteSpeedInput.Size = UIVector2.new(0.5, -10, 0.1, 0)
    noteSpeedInput.TextColor = Color.new(0,0,0,1)
    noteSpeedInput:SetParent(settingsFrame)
    noteSpeedInput.Text = settings.NoteSpeed
    noteSpeedInput.CornerRoundness = 8

    noteSpeedLabel = yan:Label(self.Screen, "Note Speed", 32, "right", "center", "/ComicNeue.ttf")
    noteSpeedLabel.Size = UIVector2.new(0.7,0,1,0)
    noteSpeedLabel.Position = UIVector2.new(0, -50, 0, 0)
    noteSpeedLabel.AnchorPoint = Vector2.new(1,0)
    noteSpeedLabel.TextColor = Color.new(1,1,1,1)
    noteSpeedLabel:SetParent(noteSpeedInput)

    noteSpeedInput.MouseEnter = function ()
        noteSpeedInput.Color = Color.new(0.7,0.7,0.7,1)
    end
    
    noteSpeedInput.MouseLeave = function ()
        noteSpeedInput.Color = Color.new(1,1,1,1)
    end
    
    noteSpeedInput.MouseDown = function ()
        sfx.Select:play()
        noteSpeedInput.Color = Color.new(0.5,0.5,0.5,1)

        noteSpeedInput.Text = ""
    end
    
    noteSpeedInput.OnEnter = function ()
        local input = tonumber(noteSpeedInput.Text)
        noteSpeedInput.Color = Color.new(0.5,0.5,0.5,1)
        sfx.Select:play()
        if input == nil then 
            noteSpeedInput.Text = "Invalid Input"
            return 
        end
        
        if input < 50 then 
            noteSpeedInput.Text = "Must be above 50"
            return 
        end
        
        settings.NoteSpeed = tonumber(noteSpeedInput.Text)
        
    end
    
    function volumeSlider.OnSlide(value)
        settings.MusicVolume = value
    end
    










    --// CUSTOM LEVELS \\--









    

    customLevelsContainer = yan:Frame(self.Screen)
    customLevelsContainer.Size = UIVector2.new(1,0,1,0)
    customLevelsContainer.Color = Color.new(0,0,0,0)
    customLevelsContainer:SetParent(customLevelsPage)
    
    customLevelsBackBtn = yan:ImageButton(self.Screen, "/img/back_btn.png")
    customLevelsBackBtn.Size = UIVector2.new(0,50,0,50)
    customLevelsBackBtn.Position = UIVector2.new(0,10,0,10)
    customLevelsBackBtn:SetParent(customLevelsPage)
    customLevelsBackBtn.ZIndex = 10
    customLevelsBackBtn.MouseEnter = function ()
        customLevelsBackBtn.Color = Color.new(0.7,0.7,0.7,1)
    end
    
    customLevelsBackBtn.MouseLeave = function ()
        customLevelsBackBtn.Color = Color.new(1,1,1,1)
    end
    
    customLevelsBackBtn.MouseDown = function ()
        if menuMoving then return end
        menuMoving = true
        menuStopMovingDelay = love.timer.getTime() + 1
        sfx.Select:play()
        page = "main"
        --yan:NewTween(levelsContainer, yan:TweenInfo(1, EasingStyle.QuadInOut), {Position = UIVector2.new(0, 0, 0, 0)}):Play()
        yan:NewTween(mainPage, yan:TweenInfo(1, EasingStyle.QuadInOut), {Position = UIVector2.new(0,0,0,0)}):Play()
        yan:NewTween(customLevelsPage, yan:TweenInfo(1, EasingStyle.QuadInOut), {Position = UIVector2.new(1,0,0,0)}):Play()
        if previewMusic ~= nil then 
            previewMusic:stop()
        end
        menuMusic:play()
        menuMusicSettings:play()
        
        conductor.BPM = 128
        conductor:Init()
        
        customLevelsBackBtn.Color = Color.new(1,1,1,1)
    end
    
    
    
    
    
    newLevelBtn = yan:ImageButton(self.Screen, "/img/new_level.png")
    newLevelBtn.Size = UIVector2.new(0,50,0,50)
    newLevelBtn.Position = UIVector2.new(1,-60,0,10)
    newLevelBtn:SetParent(customLevelsPage)
    newLevelBtn.ZIndex = 10
    newLevelBtn.MouseEnter = function ()
        newLevelBtn.Color = Color.new(0.7,0.7,0.7,1)
    end
    
    newLevelBtn.MouseLeave = function ()
        newLevelBtn.Color = Color.new(1,1,1,1)
    end
    
    newLevelBtn.MouseDown = function ()
        sfx.Select:play()
        newLevelBtn.Color = Color.new(1,1,1,1)
        
        yan:NewTween(newLevelPopup, yan:TweenInfo(1, EasingStyle.BackOut), {Position = UIVector2.new(0.5,0,0.5,0)}):Play()
    end

    noLevelsLabel = yan:Label(self.Screen, "You have no custom levels! Try creating one by pressing the + button at the top.", 64, "center", "center", "/ComicNeue.ttf")
    noLevelsLabel.Parent = customLevelsPage
    noLevelsLabel.TextColor = Color.new(1,1,1,1)

    

    newLevelPopup = yan:Frame(self.Screen)
    newLevelPopup.Position = UIVector2.new(0.5,0,1.5,0)
    newLevelPopup.Size = UIVector2.new(0.7,0,0.7,0)
    newLevelPopup.Color = Color.new(0.1,0.1,0.1,1)
    newLevelPopup.AnchorPoint = Vector2.new(0.5,0.5)
    newLevelPopup.CornerRoundness = 8
    newLevelPopup.ZIndex = 10
    
    newLevelTitle = yan:Label(self.Screen, "Creating New Level", 40, "center", "center", "/ComicNeue.ttf")
    newLevelTitle.TextColor = Color.new(1,1,1,1)
    newLevelTitle.Size = UIVector2.new(1,0,0.1,0)
    newLevelTitle.AnchorPoint = Vector2.new(0,1)
    newLevelTitle.ZIndex = 11
    newLevelTitle:SetParent(newLevelPopup)

    newLevelClose = yan:ImageButton(self.Screen, "/img/exit.png")
    newLevelClose.Size = UIVector2.new(0,50,0,50)
    newLevelClose.Position = UIVector2.new(0,5,0,-60)
    newLevelClose:SetParent(newLevelPopup)
    newLevelClose.ZIndex = 10
    newLevelClose.MouseEnter = function () newLevelClose.Color = Color.new(0.7,0.7,0.7,1) end
    
    newLevelClose.MouseLeave = function () newLevelClose.Color = Color.new(1,1,1,1) end
    newLevelClose.MouseDown = function ()
        sfx.Select:play()
        yan:NewTween(newLevelPopup, yan:TweenInfo(1, EasingStyle.BackIn), {Position = UIVector2.new(0.5,0,1.5,0)}):Play()
    end
    -- tabs
    
    local currentTab = "metadata"

    metadataFrame = yan:Frame(self.Screen)
    metadataFrame.Color = Color.new(0,0,0,0)
    metadataFrame:SetParent(newLevelPopup)

    assetsFrame = yan:Frame(self.Screen)
    assetsFrame.Position = UIVector2.new(0,0,-5,0)
    assetsFrame.Color = Color.new(0,0,0,0)
    assetsFrame:SetParent(newLevelPopup)

    dialogueFrame = yan:Frame(self.Screen)
    dialogueFrame.Position = UIVector2.new(0,0,-5,0)
    dialogueFrame.Color = Color.new(0,0,0,0)
    dialogueFrame:SetParent(newLevelPopup)

    metadataTabBtn = yan:TextButton(self.Screen, "Song Metadata", 20, "center", "center", "/ComicNeue.ttf")
    metadataTabBtn.Position = UIVector2.new(0,10,0,10)
    metadataTabBtn.Size = UIVector2.new(0.33,-10,0.1,0)
    metadataTabBtn.AnchorPoint = Vector2.new(0,0)
    metadataTabBtn.Color = Color.new(1,1,1,1)
    metadataTabBtn.TextColor = Color.new(0,0,0,1)
    metadataTabBtn.ZIndex = 11
    metadataTabBtn.CornerRoundness = 8
    metadataTabBtn:SetParent(newLevelPopup)
    
    metadataTabBtn.MouseEnter = function () if currentTab ~= "metadata" then metadataTabBtn.Color = Color.new(0.7,0.7,0.7,1) end end
    metadataTabBtn.MouseLeave = function () if currentTab ~= "metadata" then metadataTabBtn.Color = Color.new(1,1,1,1) end end
    metadataTabBtn.MouseDown = function()
        sfx.Select:play()
        currentTab = "metadata"
        metadataFrame.Position = UIVector2.new(0,0,0,0)
        assetsFrame.Position = UIVector2.new(0,0,-5,0)
        dialogueFrame.Position = UIVector2.new(0,0,-5,0)
        metadataTabBtn.Color = Color.new(0.5,0.5,0.5,1)
        assetsTabBtn.Color = Color.new(1,1,1,1)
        dialogueTabBtn.Color = Color.new(1,1,1,1)
    end

    assetsTabBtn = yan:TextButton(self.Screen, "Assets", 20, "center", "center", "/ComicNeue.ttf")
    assetsTabBtn.Position = UIVector2.new(0.33,7,0,10)
    assetsTabBtn.Size = UIVector2.new(0.33,-10,0.1,0)
    assetsTabBtn.AnchorPoint = Vector2.new(0,0)
    assetsTabBtn.Color = Color.new(1,1,1,1)
    assetsTabBtn.TextColor = Color.new(0,0,0,1)
    assetsTabBtn.ZIndex = 11
    assetsTabBtn.CornerRoundness = 8
    assetsTabBtn:SetParent(newLevelPopup)
    
    assetsTabBtn.MouseEnter = function () if currentTab ~= "assets" then assetsTabBtn.Color = Color.new(0.7,0.7,0.7,1) end end
    assetsTabBtn.MouseLeave = function () if currentTab ~= "assets" then assetsTabBtn.Color = Color.new(1,1,1,1) end end
    assetsTabBtn.MouseDown = function() 
        sfx.Select:play()
        currentTab = "assets"
        metadataFrame.Position = UIVector2.new(0,0,-5,0)
        assetsFrame.Position = UIVector2.new(0,0,0,0)
        dialogueFrame.Position = UIVector2.new(0,0,-5,0)
        metadataTabBtn.Color = Color.new(1,1,1,1)
        assetsTabBtn.Color = Color.new(0.5,0.5,0.5,1)
        dialogueTabBtn.Color = Color.new(1,1,1,1)
    end

    dialogueTabBtn = yan:TextButton(self.Screen, "Results Dialogue", 20, "center", "center", "/ComicNeue.ttf")
    dialogueTabBtn.Position = UIVector2.new(0.66,5,0,10)
    dialogueTabBtn.Size = UIVector2.new(0.33,-10,0.1,0)
    dialogueTabBtn.AnchorPoint = Vector2.new(0,0)
    dialogueTabBtn.Color = Color.new(1,1,1,1)
    dialogueTabBtn.TextColor = Color.new(0,0,0,1)
    dialogueTabBtn.ZIndex = 11
    dialogueTabBtn.CornerRoundness = 8
    dialogueTabBtn:SetParent(newLevelPopup)
    
    dialogueTabBtn.MouseEnter = function () if currentTab ~= "dialogue" then dialogueTabBtn.Color = Color.new(0.7,0.7,0.7,1) end end
    dialogueTabBtn.MouseLeave = function () if currentTab ~= "dialogue" then dialogueTabBtn.Color = Color.new(1,1,1,1) end end
    dialogueTabBtn.MouseDown = function() 
        sfx.Select:play()
        currentTab = "dialogue"
        metadataFrame.Position = UIVector2.new(0,0,-5,0)
        assetsFrame.Position = UIVector2.new(0,0,-5,0)
        dialogueFrame.Position = UIVector2.new(0,0,0,0)
        metadataTabBtn.Color = Color.new(1,1,1,1)
        assetsTabBtn.Color = Color.new(1,1,1,1)
        dialogueTabBtn.Color = Color.new(0.5,0.5,0.5,1)
    end
    
    -- METADATA TAB
    --
    --

    nameInputter = yan:TextInputter(self.Screen, "Enter Song Name", 30, "center", "center", "/ComicNeue.ttf")
    nameInputter.Position = UIVector2.new(0.5,0,0.2,0)
    nameInputter.Size = UIVector2.new(0.8,0,0.15,0)
    nameInputter.AnchorPoint = Vector2.new(0.5,0)
    nameInputter.Color = Color.new(1,1,1,1)
    nameInputter.TextColor = Color.new(0,0,0,1)
    nameInputter.ZIndex = 11
    nameInputter.CornerRoundness = 8
    nameInputter:SetParent(metadataFrame)
    
    nameInputter.MouseEnter = function () nameInputter.Color = Color.new(0.7,0.7,0.7,1) end
    nameInputter.MouseLeave = function () nameInputter.Color = Color.new(1,1,1,1) end
    nameInputter.MouseDown = function() sfx.Select:play() end
    
    artistInputter = yan:TextInputter(self.Screen, "Enter Artist Name", 30, "center", "center", "/ComicNeue.ttf")
    artistInputter.Position = UIVector2.new(0.5,0,0.35,10)
    artistInputter.Size = UIVector2.new(0.8,0,0.15,0)
    artistInputter.AnchorPoint = Vector2.new(0.5,0)
    artistInputter.Color = Color.new(1,1,1,1)
    artistInputter.TextColor = Color.new(0,0,0,1)
    artistInputter.ZIndex = 11
    artistInputter.CornerRoundness = 8
    artistInputter:SetParent(metadataFrame)
    
    artistInputter.MouseEnter = function () artistInputter.Color = Color.new(0.7,0.7,0.7,1) end
    artistInputter.MouseLeave = function () artistInputter.Color = Color.new(1,1,1,1) end
    artistInputter.MouseDown = function() sfx.Select:play() end

    mapperInputter = yan:TextInputter(self.Screen, "Enter Mapper Name (that's you!)", 30, "center", "center", "/ComicNeue.ttf")
    mapperInputter.Position = UIVector2.new(0.5,0,0.5,20)
    mapperInputter.Size = UIVector2.new(0.8,0,0.15,0)
    mapperInputter.AnchorPoint = Vector2.new(0.5,0)
    mapperInputter.Color = Color.new(1,1,1,1)
    mapperInputter.TextColor = Color.new(0,0,0,1)
    mapperInputter.ZIndex = 11
    mapperInputter.CornerRoundness = 8
    mapperInputter:SetParent(metadataFrame)
    
    mapperInputter.MouseEnter = function () mapperInputter.Color = Color.new(0.7,0.7,0.7,1) end
    mapperInputter.MouseLeave = function () mapperInputter.Color = Color.new(1,1,1,1) end
    mapperInputter.MouseDown = function() sfx.Select:play() end
    




    -- ASSETS TAB
    
    songInput = yan:TextButton(self.Screen, "Choose Song", 25, "center", "center", "/ComicNeue.ttf")
    songInput.Position = UIVector2.new(0.5,0,0.15,0)
    songInput.Size = UIVector2.new(0.8,0,0.1,0)
    songInput.AnchorPoint = Vector2.new(0.5,0)
    songInput.Color = Color.new(1,1,1,1)
    songInput.TextColor = Color.new(0,0,0,1)
    songInput.ZIndex = 11
    songInput.CornerRoundness = 8
    songInput:SetParent(assetsFrame)
    
    songInput.MouseEnter = function () songInput.Color = Color.new(0.7,0.7,0.7,1) end
    songInput.MouseLeave = function () songInput.Color = Color.new(1,1,1,1) end
    songInput.MouseDown = function() 
        sfx.Select:play()
        songInput.Text = "Drop an .ogg onto the window"
        droppingFile = "song"
    end
    
    coverInput = yan:TextButton(self.Screen, "Choose Cover Art", 25, "center", "center", "/ComicNeue.ttf")
    coverInput.Position = UIVector2.new(0.5,0,0.25,10)
    coverInput.Size = UIVector2.new(0.8,0,0.1,0)
    coverInput.AnchorPoint = Vector2.new(0.5,0)
    coverInput.Color = Color.new(1,1,1,1)
    coverInput.TextColor = Color.new(0,0,0,1)
    coverInput.ZIndex = 11
    coverInput.CornerRoundness = 8
    coverInput:SetParent(assetsFrame)
    
    coverInput.MouseEnter = function () coverInput.Color = Color.new(0.7,0.7,0.7,1) end
    coverInput.MouseLeave = function () coverInput.Color = Color.new(1,1,1,1) end
    coverInput.MouseDown = function() 
        sfx.Select:play()
        coverInput.Text = "Drop an image onto the window"
        droppingFile = "cover"
    end
    
    bgInput = yan:TextButton(self.Screen, "Choose Background Image (800x600)", 25, "center", "center", "/ComicNeue.ttf")
    bgInput.Position = UIVector2.new(0.5,0,0.35,20)
    bgInput.Size = UIVector2.new(0.8,0,0.1,0)
    bgInput.AnchorPoint = Vector2.new(0.5,0)
    bgInput.Color = Color.new(1,1,1,1)
    bgInput.TextColor = Color.new(0,0,0,1)
    bgInput.ZIndex = 11
    bgInput.CornerRoundness = 8
    bgInput:SetParent(assetsFrame)
    
    bgInput.MouseEnter = function () bgInput.Color = Color.new(0.7,0.7,0.7,1) end
    bgInput.MouseLeave = function () bgInput.Color = Color.new(1,1,1,1) end
    bgInput.MouseDown = function() 
        sfx.Select:play()
        bgInput.Text = "Drop an image onto the window"
        droppingFile = "bg"
    end
    
    gooseInput = yan:TextButton(self.Screen, "Choose Goose Sprite (50x50)", 25, "center", "center", "/ComicNeue.ttf")
    gooseInput.Position = UIVector2.new(0.5,0,0.45,30)
    gooseInput.Size = UIVector2.new(0.8,0,0.1,0)
    gooseInput.AnchorPoint = Vector2.new(0.5,0)
    gooseInput.Color = Color.new(1,1,1,1)
    gooseInput.TextColor = Color.new(0,0,0,1)
    gooseInput.ZIndex = 11
    gooseInput.CornerRoundness = 8
    gooseInput:SetParent(assetsFrame)
    
    gooseInput.MouseEnter = function () gooseInput.Color = Color.new(0.7,0.7,0.7,1) end
    gooseInput.MouseLeave = function () gooseInput.Color = Color.new(1,1,1,1) end
    gooseInput.MouseDown = function() 
        sfx.Select:play()
        gooseInput.Text = "Drop an image onto the window"
        droppingFile = "goose"
    end
    
    gooseMissInput = yan:TextButton(self.Screen, "Choose Goose Miss Sprite (50x50)", 25, "center", "center", "/ComicNeue.ttf")
    gooseMissInput.Position = UIVector2.new(0.5,0,0.55,40)
    gooseMissInput.Size = UIVector2.new(0.8,0,0.1,0)
    gooseMissInput.AnchorPoint = Vector2.new(0.5,0)
    gooseMissInput.Color = Color.new(1,1,1,1)
    gooseMissInput.TextColor = Color.new(0,0,0,1)
    gooseMissInput.ZIndex = 11
    gooseMissInput.CornerRoundness = 8
    gooseMissInput:SetParent(assetsFrame)
    
    gooseMissInput.MouseEnter = function () gooseMissInput.Color = Color.new(0.7,0.7,0.7,1) end
    gooseMissInput.MouseLeave = function () gooseMissInput.Color = Color.new(1,1,1,1) end
    gooseMissInput.MouseDown = function() 
        sfx.Select:play()
        gooseMissInput.Text = "Drop an image onto the window"
        droppingFile = "goosemiss"
    end
    
    
    -- DIALOGUE TABB
    
    tryagainInput = yan:TextInputter(self.Screen, "Enter Try Again Dialogue", 30, "center", "center", "/ComicNeue.ttf")
    tryagainInput.Position = UIVector2.new(0.5,0,0.2,0)
    tryagainInput.Size = UIVector2.new(0.8,0,0.1,0)
    tryagainInput.AnchorPoint = Vector2.new(0.5,0)
    tryagainInput.Color = Color.new(1,1,1,1)
    tryagainInput.TextColor = Color.new(0,0,0,1)
    tryagainInput.ZIndex = 11
    tryagainInput.CornerRoundness = 8
    tryagainInput:SetParent(dialogueFrame)
    
    tryagainInput.MouseEnter = function () tryagainInput.Color = Color.new(0.7,0.7,0.7,1) end
    tryagainInput.MouseLeave = function () tryagainInput.Color = Color.new(1,1,1,1) end
    tryagainInput.MouseDown = function() sfx.Select:play() end
    
    okayInput = yan:TextInputter(self.Screen, "Enter OK Dialogue", 30, "center", "center", "/ComicNeue.ttf")
    okayInput.Position = UIVector2.new(0.5,0,0.3,10)
    okayInput.Size = UIVector2.new(0.8,0,0.1,0)
    okayInput.AnchorPoint = Vector2.new(0.5,0)
    okayInput.Color = Color.new(1,1,1,1)
    okayInput.TextColor = Color.new(0,0,0,1)
    okayInput.ZIndex = 11
    okayInput.CornerRoundness = 8
    okayInput:SetParent(dialogueFrame)
    
    okayInput.MouseEnter = function () okayInput.Color = Color.new(0.7,0.7,0.7,1) end
    okayInput.MouseLeave = function () okayInput.Color = Color.new(1,1,1,1) end
    okayInput.MouseDown = function() sfx.Select:play() end

    superbInput = yan:TextInputter(self.Screen, "Enter Superb Dialogue", 30, "center", "center", "/ComicNeue.ttf")
    superbInput.Position = UIVector2.new(0.5,0,0.4,20)
    superbInput.Size = UIVector2.new(0.8,0,0.1,0)
    superbInput.AnchorPoint = Vector2.new(0.5,0)
    superbInput.Color = Color.new(1,1,1,1)
    superbInput.TextColor = Color.new(0,0,0,1)
    superbInput.ZIndex = 11
    superbInput.CornerRoundness = 8
    superbInput:SetParent(dialogueFrame)
    
    superbInput.MouseEnter = function () superbInput.Color = Color.new(0.7,0.7,0.7,1) end
    superbInput.MouseLeave = function () superbInput.Color = Color.new(1,1,1,1) end
    superbInput.MouseDown = function() sfx.Select:play() end
    
    perfectInput = yan:TextInputter(self.Screen, "Enter Perfect Dialogue", 30, "center", "center", "/ComicNeue.ttf")
    perfectInput.Position = UIVector2.new(0.5,0,0.5,30)
    perfectInput.Size = UIVector2.new(0.8,0,0.1,0)
    perfectInput.AnchorPoint = Vector2.new(0.5,0)
    perfectInput.Color = Color.new(1,1,1,1)
    perfectInput.TextColor = Color.new(0,0,0,1)
    perfectInput.ZIndex = 11
    perfectInput.CornerRoundness = 8
    perfectInput:SetParent(dialogueFrame)
    
    perfectInput.MouseEnter = function () perfectInput.Color = Color.new(0.7,0.7,0.7,1) end
    perfectInput.MouseLeave = function () perfectInput.Color = Color.new(1,1,1,1) end
    perfectInput.MouseDown = function() sfx.Select:play() end

    createSongBtn = yan:TextButton(self.Screen, "Create Level", 30, "center", "center", "/ComicNeue.ttf")
    createSongBtn.Position = UIVector2.new(0.5,0,1,-20)
    createSongBtn.Size = UIVector2.new(0.8,0,0.15,0)
    createSongBtn.AnchorPoint = Vector2.new(0.5,1)
    createSongBtn.Color = Color.new(1,1,1,1)
    createSongBtn.TextColor = Color.new(0,0,0,1)
    createSongBtn.ZIndex = 11
    createSongBtn.CornerRoundness = 8
    createSongBtn:SetParent(newLevelPopup)
    
    createSongBtn.MouseEnter = function () 
       
        createSongBtn.Color = Color.new(0.7,0.7,0.7,1) 
    end
    createSongBtn.MouseLeave = function () 
        createSongBtn.Text = "Create Level"
        createSongBtn.Color = Color.new(1,1,1,1) end
    createSongBtn.MouseDown = function() 
        if nameInputter.Text == "" then
            sfx.Error:play()
            createSongBtn.Text = "You have to name the song, silly!"
            return
        end

        if love.filesystem.getInfo("/customLevels/"..nameInputter.Text) ~= nil then
            sfx.Error:play()
            createSongBtn.Text = "Level with same name already exists!"
            return
        end

        if creatingLevel.SongOgg == nil then
            sfx.Error:play()
            createSongBtn.Text = "Song is missing!"
            return
        end
        
        if creatingLevel.Cover == nil then
            sfx.Error:play()
            createSongBtn.Text = "Cover art is missing!"
            return
        end

        if creatingLevel.BG == nil then
            sfx.Error:play()
            createSongBtn.Text = "Background is missing!"
            return
        end
        
        if creatingLevel.Goose == nil then
            sfx.Error:play()
            createSongBtn.Text = "Goose is missing!"
            return
        end

        if creatingLevel.GooseMiss == nil then
            sfx.Error:play()
            createSongBtn.Text = "Goose miss is missing!"
            return
        end

        sfx.Success:play()

        createSongBtn.Text = "Level Created!"

        -- create folder
        love.filesystem.createDirectory("/customLevels/"..nameInputter.Text)
        -- create metadata
        local metadataString = string.format("return {SongName = \"%s\", SongArtist = \"%s\", Charter = \"%s\",", nameInputter.Text, artistInputter.Text, mapperInputter.Text)
        metadataString = metadataString..("BPM = 150, GooseSize = 2, PreviewSongTime = 0.0,")--todo make these modifiable
        metadataString = metadataString..string.format("DialogueTryAgain = \"%s\", DialogueOK = \"%s\", DialogueSuperb = \"%s\", DialoguePerfect = \"%s\"}", tryagainInput.Text, okayInput.Text, superbInput.Text, perfectInput.Text)

        love.filesystem.write("/customLevels/"..nameInputter.Text.."/metadata.lua", metadataString)
        
        -- create chart.lua

        love.filesystem.write("/customLevels/"..nameInputter.Text.."/chart.lua", "return {}")

        -- create assets
        
        love.filesystem.createDirectory("/customLevels/"..nameInputter.Text.."/assets")
        
        love.filesystem.write("/customLevels/"..nameInputter.Text.."/song.ogg", creatingLevel.SongOgg:read())

        local coverExt = creatingLevel.Cover:getFilename():match("^.+(%..+)$")
        love.filesystem.write("/customLevels/"..nameInputter.Text.."/cover"..coverExt, creatingLevel.Cover:read())
        
        local gooseExt = creatingLevel.Goose:getFilename():match("^.+(%..+)$")
        love.filesystem.write("/customLevels/"..nameInputter.Text.."/assets/goose"..gooseExt, creatingLevel.Goose:read())
        
        local goosemissExt = creatingLevel.GooseMiss:getFilename():match("^.+(%..+)$")
        love.filesystem.write("/customLevels/"..nameInputter.Text.."/assets/goose_miss"..goosemissExt, creatingLevel.GooseMiss:read())

        local bgExt = creatingLevel.BG:getFilename():match("^.+(%..+)$")
        love.filesystem.write("/customLevels/"..nameInputter.Text.."/assets/bg"..bgExt, creatingLevel.BG:read())
        
        yan:NewTween(newLevelPopup, yan:TweenInfo(1, EasingStyle.BackIn), {Position = UIVector2.new(0.5,0,1.5,0)}):Play()
    end

    RefreshCustomLevels()
end

function menu:Draw()
    love.graphics.draw(bgImage, bgQuad, (800 * -20) + scrollX, (600 * -20) + scrollY - bgOffset.Pos)
    
    --scrollX = scrollX + 0.1
    scrollY = scrollY + 0.1
end

function menu:MouseMoved(_, _, x, y)
    scrollX = scrollX + x * 0.2
    scrollY = scrollY + y * 0.2
end

function menu:Metronome()
    title.Size = UIVector2.new(0,439,0,256)
    titleBop:Play()
end

function menu:Update(dt)
    menuMusic:setVolume(settings:GetMusicVolume() * bgOffset.MusicVolume)
    menuMusicSettings:setVolume(settings:GetMusicVolume() * bgOffset.SettingsVolume)
    if previewMusic ~= nil then 
        previewMusic:setVolume(settings:GetMusicVolume())
    end
    
    if menuStopMovingDelay ~= -1 and love.timer.getTime() > menuStopMovingDelay then
        menuStopMovingDelay = -1
        menuMoving = false
    end
    
    --conductor.SongPosition = menuMusic:tell("seconds")
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
                menuMusicSettings:stop()
                fading = nil
            end

            if fading == "play" then
                transitions:FadeOut(0.3)
                
                if previewMusic ~= nil then 
                    previewMusic:stop()
                end
                
                if page == "levels" then
                    menu.playsong(charts[chartSelectionIndex])
                else
                    menu.playsong(customCharts[customChartSelectionIndex])
                end
                

                self.Enabled = false
                menuMusic:stop()
                menuMusicSettings:stop()
                fading = nil
            end
        end
    end
end

function menu:KeyPressed(key)
    if choosingKeybind ~= -1 then
        if key == "escape" then
            choosingButton.Text = settings.Keybinds[choosingKeybind]
            choosingButton.Color = Color.new(1,1,1,1)
            choosingKeybind = -1
            choosingButton = nil
            return
        end
        settings.Keybinds[choosingKeybind] = tostring(key)
        choosingButton.Text = tostring(key)
        choosingButton.Color = Color.new(1,1,1,1)
        choosingKeybind = -1
        choosingButton = nil
    end

    if page == "levels" then
        if key == "left" or key == "a" then
            if chartSelectionIndex > 1 then
                chartSelectionIndex = chartSelectionIndex - 1
                selectionPos = selectionPos + 1
                yan:NewTween(levelsContainer, yan:TweenInfo(1, EasingStyle.BackOut), {Position = UIVector2.new(selectionPos, 0, 0, 0)}):Play()
                
                if previewMusic ~= nil then 
                    previewMusic:stop()
                end
                
                previewMusic = love.audio.newSource( charts[chartSelectionIndex].."/song.ogg", "stream")
                previewMusic:setVolume(settings:GetMusicVolume())
                previewMusic:play()

                local metadata = love.filesystem.read(charts[chartSelectionIndex].."/metadata.lua")
                local loadedMetadata = loadstring(metadata)()
                previewMusic:seek(loadedMetadata.PreviewSongTime, "seconds")
            end
        elseif key == "right" or key == "d" then
            if chartSelectionIndex < #charts then
                chartSelectionIndex = chartSelectionIndex + 1
                selectionPos = selectionPos - 1
                yan:NewTween(levelsContainer, yan:TweenInfo(1, EasingStyle.BackOut), {Position = UIVector2.new(selectionPos, 0, 0, 0)}):Play()

                if previewMusic ~= nil then 
                    previewMusic:stop()
                end
                
                previewMusic = love.audio.newSource( charts[chartSelectionIndex].."/song.ogg", "stream")
                previewMusic:setVolume(settings:GetMusicVolume())
                previewMusic:play()

                local metadata = love.filesystem.read(charts[chartSelectionIndex].."/metadata.lua")
                local loadedMetadata = loadstring(metadata)()
                previewMusic:seek(loadedMetadata.PreviewSongTime, "seconds")
            end
        end
        
        if key == "escape" and not menuMoving then
            menuMoving = true
            menuStopMovingDelay = love.timer.getTime() + 1

            page = "main"
            yan:NewTween(levelsContainer, yan:TweenInfo(1, EasingStyle.QuadInOut), {Position = UIVector2.new(0, 0, 0, 0)}):Play()
            yan:NewTween(mainPage, yan:TweenInfo(1, EasingStyle.QuadInOut), {Position = UIVector2.new(0,0,0,0)}):Play()
            yan:NewTween(levelsPage, yan:TweenInfo(1, EasingStyle.QuadInOut), {Position = UIVector2.new(1,0,0,0)}):Play()
            
            if previewMusic ~= nil then 
                previewMusic:stop()
            end
            
            menuMusic:play()
            menuMusicSettings:play()

            conductor.BPM = 128
            conductor:Init()
        end
    elseif page == "settings" then
        if key == "escape" and not menuMoving then
            menuMoving = true
            menuStopMovingDelay = love.timer.getTime() + 1

            page = "main"
            yan:NewTween(settingsFrame, yan:TweenInfo(1, EasingStyle.QuadInOut), {Position = UIVector2.new(0, 0, 1, 0)}):Play()
            yan:NewTween(mainPage, yan:TweenInfo(1, EasingStyle.QuadInOut), {Position = UIVector2.new(0,0,0,0)}):Play()
            yan:NewTween(bgOffset, yan:TweenInfo(1, EasingStyle.QuadInOut), {Pos = 0, MusicVolume = 1, SettingsVolume = 0}):Play()
            
            settings:Save()
        end
    elseif page == "customlevels" then
        if key == "escape" and not menuMoving then
            menuMoving = true
            menuStopMovingDelay = love.timer.getTime() + 1
            
            page = "main"
            --yan:NewTween(levelsContainer, yan:TweenInfo(1, EasingStyle.QuadInOut), {Position = UIVector2.new(0, 0, 0, 0)}):Play()
            yan:NewTween(mainPage, yan:TweenInfo(1, EasingStyle.QuadInOut), {Position = UIVector2.new(0,0,0,0)}):Play()
            yan:NewTween(customLevelsPage, yan:TweenInfo(1, EasingStyle.QuadInOut), {Position = UIVector2.new(1,0,0,0)}):Play()
            if previewMusic ~= nil then 
                previewMusic:stop()
            end
            menuMusic:play()
            menuMusicSettings:play()
            
            conductor.BPM = 128
            conductor:Init()
        end

        if key == "left" or key == "a" then
            if customChartSelectionIndex > 1 then
                customChartSelectionIndex = customChartSelectionIndex - 1
                customSelectionPos = customSelectionPos + 1
                yan:NewTween(customLevelsContainer, yan:TweenInfo(1, EasingStyle.BackOut), {Position = UIVector2.new(customSelectionPos, 0, 0, 0)}):Play()
                
                if previewMusic ~= nil then 
                    previewMusic:stop()
                end
                
                previewMusic = love.audio.newSource(customCharts[customChartSelectionIndex].."/song.ogg", "stream")
                previewMusic:setVolume(settings:GetMusicVolume())
                previewMusic:play()

                local metadata = love.filesystem.read(customCharts[customChartSelectionIndex].."/metadata.lua")
                local loadedMetadata = loadstring(metadata)()
                previewMusic:seek(loadedMetadata.PreviewSongTime, "seconds")
            end
        elseif key == "right" or key == "d" then
            if customChartSelectionIndex < #customCharts then
                customChartSelectionIndex = customChartSelectionIndex + 1
                customSelectionPos = customSelectionPos - 1
                yan:NewTween(customLevelsContainer, yan:TweenInfo(1, EasingStyle.BackOut), {Position = UIVector2.new(customSelectionPos, 0, 0, 0)}):Play()

                if previewMusic ~= nil then 
                    previewMusic:stop()
                end
                
                previewMusic = love.audio.newSource(customCharts[customChartSelectionIndex].."/song.ogg", "stream")
                previewMusic:setVolume(settings:GetMusicVolume())
                previewMusic:play()
                
                local metadata = love.filesystem.read(customCharts[customChartSelectionIndex].."/metadata.lua")
                local loadedMetadata = loadstring(metadata)()
                previewMusic:seek(loadedMetadata.PreviewSongTime, "seconds")
            end
        end
    end
end

function love.filedropped(file)
    if droppingFile == nil then return end
    
    if droppingFile == "song" then
        
        droppingFile = nil
        
        if file:getFilename():match("^.+(%..+)$") ~= ".ogg" then 
            songInput.Text = "File must be a .ogg"
            return
        end

        creatingLevel.SongOgg = file

        

        local t={}
        for str in string.gmatch(file:getFilename(), "([^".."\\".."]+)") do
            table.insert(t, str)
        end
        
        songInput.Text = t[#t]
    end
    
    if droppingFile == "cover" then
        droppingFile = nil
        
        local fileExt = file:getFilename():match("^.+(%..+)$")
        
        if fileExt ~= ".png" and fileExt ~= ".jpg" and fileExt ~= ".jpeg" and fileExt ~= ".bmp" then
            coverInput.Text = "File must be a .png, .jpg, .jpeg, or .bmp"
            return
        end

        creatingLevel.Cover = file
        local t={}
        for str in string.gmatch(file:getFilename(), "([^".."\\".."]+)") do
            table.insert(t, str)
        end
        
        coverInput.Text = t[#t]
    end

    if droppingFile == "bg" then
        droppingFile = nil
        local fileExt = file:getFilename():match("^.+(%..+)$")
        
        if fileExt ~= ".png" and fileExt ~= ".jpg" and fileExt ~= ".jpeg" and fileExt ~= ".bmp" then
            bgInput.Text = "File must be a .png, .jpg, .jpeg, or .bmp"
            return
        end
        creatingLevel.BG = file
        local t={}
        for str in string.gmatch(file:getFilename(), "([^".."\\".."]+)") do
            table.insert(t, str)
        end
        
        bgInput.Text = t[#t]
    end

    if droppingFile == "goose" then
        droppingFile = nil
        local fileExt = file:getFilename():match("^.+(%..+)$")
        
        if fileExt ~= ".png" and fileExt ~= ".jpg" and fileExt ~= ".jpeg" and fileExt ~= ".bmp" then
            gooseInput.Text = "File must be a .png, .jpg, .jpeg, or .bmp"
            return
        end
        creatingLevel.Goose = file
        local t={}
        for str in string.gmatch(file:getFilename(), "([^".."\\".."]+)") do
            table.insert(t, str)
        end
        
        gooseInput.Text = t[#t]
    end

    if droppingFile == "goosemiss" then
        droppingFile = nil
        local fileExt = file:getFilename():match("^.+(%..+)$")
        
        if fileExt ~= ".png" and fileExt ~= ".jpg" and fileExt ~= ".jpeg" and fileExt ~= ".bmp" then
            gooseMissInput.Text = "File must be a .png, .jpg, .jpeg, or .bmp"
            return
        end
        creatingLevel.GooseMiss = file
        local t={}
        for str in string.gmatch(file:getFilename(), "([^".."\\".."]+)") do
            table.insert(t, str)
        end
        
        gooseMissInput.Text = t[#t]
    end
end

return menu