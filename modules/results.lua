local results = {}
require "yan"
require "modules.conductor"

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

function results:Open(breadamnt, totalNotes, metadata, chartPath)
    self.Screen.Enabled = true
    mainFrame.Position = UIVector2.new(0,0,1,0)
    yan:NewTween(mainFrame, yan:TweenInfo(1, EasingStyle.ElasticOut), {Position = UIVector2.new(0,0,0,0)}):Play()
    
    bread.Text = "Bread: "..breadamnt
    notes.Text = "Notes Hit: "..tostring(totalNotes).."/"..tostring(conductor:GetNoteCount())
    
    goose2.Image = love.graphics.newImage(chartPath.."/assets/goose.png")

    
    local accuracypercent = (breadamnt / (conductor:GetBreadCount()) * 100)
    accuracypercent = accuracypercent * 100
    accuracypercent = math.ceil(accuracypercent)
    
    accuracypercent = accuracypercent / 100
    
    if accuracypercent <= 40 then
        rank.Image = love.graphics.newImage("/img/ranks/try_again.png")
        gooseDialogue.Text = metadata.DialogueTryAgain
    elseif accuracypercent <= 70 then
        rank.Image = love.graphics.newImage("/img/ranks/ok.png")
        gooseDialogue.Text = metadata.DialogueOK
    elseif accuracypercent < 100 then
        rank.Image = love.graphics.newImage("/img/ranks/superb.png")
        gooseDialogue.Text = metadata.DialogueSuperb
    elseif accuracypercent >= 100 then
        rank.Image = love.graphics.newImage("/img/ranks/perfect.png")
        gooseDialogue.Text = metadata.DialoguePerfect
    end

    accuracy.Text = "Accuracy: "..accuracypercent.."%"
end

return results