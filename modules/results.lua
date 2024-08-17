local results = {}
require "yan"
require "modules.conductor"

local rankDisplayDelay = -1
local dialogueDelay = -1
local displayOthersDelay = -1
local doingDelays = false
local accuracyPercent = 0
local sfx = {
    Reveal = love.audio.newSource("/sfx/reveal.mp3", "static"),
    TryAgain = love.audio.newSource("/sfx/try_again.mp3", "static"),
    OK = love.audio.newSource("/sfx/ok.mp3", "static"),
    Superb = love.audio.newSource("/sfx/superb.mp3", "static"),
    Perfect = love.audio.newSource("/sfx/perfect.mp3", "static"),
}

function results:Init()
    self.Screen = yan:Screen()
    self.Screen.Enabled = false
    self.Screen.ZIndex = 3
    
    mainFrame = yan:Image(self.Screen, "/img/song_complete.png")
    mainFrame.Position = UIVector2.new(0,0,1,0)
    mainFrame.Size = UIVector2.new(1,0,1,0)
    
    container = yan:Frame(self.Screen)
    container.Position = UIVector2.new(0.15,0,0.15,0)
    container.Size = UIVector2.new(0.7,0,0.7,0)
    container.AnchorPoint = Vector2.new(0,0)
    container:SetParent(mainFrame)
    
    container.Color = Color.new(0,0,0,0)
    container.CornerRoundness = 8
    
    bread = yan:Label(self.Screen, "Bread: 0", 40, "left", "center", "/ComicNeue.ttf")
    bread:SetParent(container)
    bread.Size = UIVector2.new(0.6,0,0.1,0)
    bread.Position = UIVector2.new(0,10,0.1,0)
    bread.TextColor = Color.new(1,1,1,1)
    
    notes = yan:Label(self.Screen, "Notes Hit: 0/0", 40, "left", "center", "/ComicNeue.ttf")
    notes:SetParent(container)
    notes.Size = UIVector2.new(0.6,0,0.1,0)
    notes.Position = UIVector2.new(0,10,0.2,10)
    notes.TextColor = Color.new(1,1,1,1)

    accuracy = yan:Label(self.Screen, "Accuracy: 100%", 40, "left", "center", "/ComicNeue.ttf")
    accuracy:SetParent(container)
    accuracy.Size = UIVector2.new(1,0,0.1,0)
    accuracy.Position = UIVector2.new(0,10,0.3,20)
    accuracy.TextColor = Color.new(1,1,1,1)
    
    rankTitle = yan:Label(self.Screen, "Rank:", 50, "center", "center", "/ComicNeue.ttf")
    rankTitle:SetParent(container)
    rankTitle.Size = UIVector2.new(0.5,0,0.1,0)
    rankTitle.Position = UIVector2.new(1,0,0.1,10)
    rankTitle.AnchorPoint = Vector2.new(1,0)
    rankTitle.TextColor = Color.new(1,1,1,1)
    
    rank = yan:Image(self.Screen, "/img/ranks/superb.png")
    rank:SetParent(container)
    rank.Size = UIVector2.new(0,300*0.7,0,200*0.7)
    rank.Position = UIVector2.new(0.5,40,0.2,-20)
    
    goose2 = yan:Image(self.Screen, "/img/ranks/superb.png")
    goose2:SetParent(container)
    goose2.Position = UIVector2.new(0.7,10,0.4,60)
    goose2.Size = UIVector2.new(0,100,0,100)

    gooseDialogue = yan:Label(self.Screen, "Placeholder text.. honk honk..", 30, "center", "center", "/ComicNeue.ttf")
    gooseDialogue.Position = UIVector2.new(0,43,0,235)
    gooseDialogue.Size = UIVector2.new(0,300,0,80)
    gooseDialogue:SetParent(container)
    gooseDialogue.ZIndex = 3
    
    resultsSpeechBubble = yan:Image(self.Screen, "/img/results_speech.png")
    resultsSpeechBubble.Size = UIVector2.new(1,0,1,0)
    resultsSpeechBubble.Position = UIVector2.new(0,0,0,0)
    resultsSpeechBubble:SetParent(mainFrame)
    resultsSpeechBubble.ZIndex = 2
    
    exitButton = yan:TextButton(self.Screen, "Return to Menu", 40, "center", "center", "/ComicNeue.ttf")
    exitButton.Position = UIVector2.new(0,10,1,-10)
    exitButton.Size = UIVector2.new(0.5,0,0.1,0)
    exitButton.AnchorPoint = Vector2.new(0,1)
    exitButton:SetParent(container)

    exitButton.MouseEnter = function ()
        exitButton.Color = Color.new(0.7,0.7,0.7,1)
    end

    exitButton.MouseLeave = function ()
        exitButton.Color = Color.new(1,1,1,1)
    end
    
    exitButton.MouseDown = function ()
        exitButton.Color = Color.new(1,1,1,1)
        results.ReturnToMenu()
    end
end

function results:Update()
    if not doingDelays then return end
    
    if love.timer.getTime() > rankDisplayDelay and rankDisplayDelay ~= -1 then
        rank.Visible = true
        yan:NewTween(rank, yan:TweenInfo(1, EasingStyle.ElasticOut), {Size = UIVector2.new(0,300*0.7,0,200*0.7)}):Play()

        if accuracyPercent <= 40 then
            sfx.TryAgain:play()
        elseif accuracyPercent <= 70 then
            sfx.OK:play()
        elseif accuracyPercent < 100 then
            sfx.Superb:play()
        elseif accuracyPercent >= 100 then
            sfx.Perfect:play()
        end
        rankDisplayDelay = -1
    end

    if love.timer.getTime() > dialogueDelay and dialogueDelay ~= -1  then
        gooseDialogue.Visible = true
        resultsSpeechBubble.Visible = true
    end
    
    if love.timer.getTime() > displayOthersDelay and displayOthersDelay ~= -1  then
        exitButton.Visible = true
        yan:NewTween(bread, yan:TweenInfo(1, EasingStyle.BackOut), {Position = UIVector2.new(0,10,0.1,0)}):Play()
        yan:NewTween(notes, yan:TweenInfo(1.2, EasingStyle.BackOut), {Position = UIVector2.new(0,10,0.2,10)}):Play()
        yan:NewTween(accuracy, yan:TweenInfo(1.4, EasingStyle.BackOut), {Position = UIVector2.new(0,10,0.3,20)}):Play()
        yan:NewTween(exitButton, yan:TweenInfo(1, EasingStyle.BackOut), {Position = UIVector2.new(0,10,1,-10)}):Play()
        
        doingDelays = false
    end
end

function results:Open(breadamnt, totalNotes, metadata, chartPath)
    sfx.Reveal:play()
    
    self.Screen.Enabled = true
    mainFrame.Position = UIVector2.new(0,0,1,0)
    rank.Size = UIVector2.new(0,0,0,0)
    rank.Visible = false
    rankTitle.Position = UIVector2.new(1,0,-1,10)
    yan:NewTween(rankTitle, yan:TweenInfo(2, EasingStyle.QuadInOut), {Position = UIVector2.new(1,0,0.1,10)}):Play()
    gooseDialogue.Visible = false
    
    bread.Position = UIVector2.new(0,10,-1,0)
    notes.Position = UIVector2.new(0,10,-1,0)
    accuracy.Position = UIVector2.new(0,10,-1,0)
    exitButton.Visible = false
    exitButton.Position = UIVector2.new(0,10,1.5,0)

    resultsSpeechBubble.Visible = false
    yan:NewTween(mainFrame, yan:TweenInfo(1, EasingStyle.ElasticOut), {Position = UIVector2.new(0,0,0,0)}):Play()
    
    bread.Text = "Bread: "..breadamnt
    notes.Text = "Notes Hit: "..tostring(totalNotes).."/"..tostring(conductor:GetNoteCount())
    
    goose2.Image = love.graphics.newImage(chartPath.."/assets/goose.png")
    goose2.Position = UIVector2.new(0.7,10,-1,60)
    yan:NewTween(goose2, yan:TweenInfo(3, EasingStyle.BounceOut), {Position = UIVector2.new(0.7,10,0.4,60)}):Play()
    
    accuracyPercent = (breadamnt / (conductor:GetBreadCount()) * 100)
    accuracyPercent = accuracyPercent * 100
    accuracyPercent = math.ceil(accuracyPercent)
    
    accuracyPercent = accuracyPercent / 100
    
    if accuracyPercent <= 40 then
        rank.Image = love.graphics.newImage("/img/ranks/try_again.png")
        gooseDialogue.Text = metadata.DialogueTryAgain
    elseif accuracyPercent <= 70 then
        rank.Image = love.graphics.newImage("/img/ranks/ok.png")
        gooseDialogue.Text = metadata.DialogueOK
    elseif accuracyPercent < 100 then
        rank.Image = love.graphics.newImage("/img/ranks/superb.png")
        gooseDialogue.Text = metadata.DialogueSuperb
    elseif accuracyPercent >= 100 then
        rank.Image = love.graphics.newImage("/img/ranks/perfect.png")
        gooseDialogue.Text = metadata.DialoguePerfect
    end
    
    rankDisplayDelay = love.timer.getTime() + 2
    dialogueDelay = love.timer.getTime() + 4
    displayOthersDelay = love.timer.getTime() + 6
    doingDelays = true
    accuracy.Text = "Accuracy: "..accuracyPercent.."%"
end

return results