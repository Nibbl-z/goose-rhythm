local results = {}
require "yan"
require "modules.conductor"

function results:Init()
    self.Screen = yan:Screen()
    self.Screen.Enabled = false
    self.Screen.ZIndex = 3

    mainFrame = yan:Frame(self.Screen)
    mainFrame.Position = UIVector2.new(0.15,0,1.5,0)
    mainFrame.Size = UIVector2.new(0.7,0,0.7,0)
    mainFrame.AnchorPoint = Vector2.new(0,0)
    
    mainFrame.Color = Color.new(0,0,0,0.5)
    mainFrame.CornerRoundness = 8
    
    title = yan:Label(self.Screen, "Song Complete!", 60, "center", "center", "/ComicNeue.ttf")
    title:SetParent(mainFrame)
    title.Size = UIVector2.new(1,0,0.1,0)
    title.Position = UIVector2.new(0,0,-0.2,0) -- wtf the positioning is messed up... wahhh
    title.AnchorPoint = Vector2.new(0,0)
    title.TextColor = Color.new(1,1,1,1)
    
    bread = yan:Label(self.Screen, "Bread: 0", 40, "left", "center", "/ComicNeue.ttf")
    bread:SetParent(mainFrame)
    bread.Size = UIVector2.new(0.6,0,0.1,0)
    bread.Position = UIVector2.new(0,10,0.2,0)
    bread.TextColor = Color.new(1,1,1,1)
    
    notes = yan:Label(self.Screen, "Notes Hit: 0/0", 40, "left", "center", "/ComicNeue.ttf")
    notes:SetParent(mainFrame)
    notes.Size = UIVector2.new(0.6,0,0.1,0)
    notes.Position = UIVector2.new(0,10,0.3,10)
    notes.TextColor = Color.new(1,1,1,1)

    accuracy = yan:Label(self.Screen, "Accuracy: 100%", 40, "left", "center", "/ComicNeue.ttf")
    accuracy:SetParent(mainFrame)
    accuracy.Size = UIVector2.new(1,0,0.1,0)
    accuracy.Position = UIVector2.new(0,10,0.4,20)
    accuracy.TextColor = Color.new(1,1,1,1)
    
    rankTitle = yan:Label(self.Screen, "Rank:", 50, "center", "center", "/ComicNeue.ttf")
    rankTitle:SetParent(mainFrame)
    rankTitle.Size = UIVector2.new(0.5,0,0.2,0)
    rankTitle.Position = UIVector2.new(1,0,0.1,10)
    rankTitle.AnchorPoint = Vector2.new(1,0)
    rankTitle.TextColor = Color.new(1,1,1,1)
    
    rank = yan:Image(self.Screen, "/img/ranks/superb.png")
    rank:SetParent(mainFrame)
    rank.Size = UIVector2.new(0,300,0,200)
    rank.Position = UIVector2.new(0.5,0,0.3,0)
    
    exitButton = yan:TextButton(self.Screen, "Return to Menu", 40, "center", "center", "/ComicNeue.ttf")
    exitButton.Position = UIVector2.new(0.5,0,1,-10)
    exitButton.Size = UIVector2.new(0.5,0,0.1,0)
    exitButton.AnchorPoint = Vector2.new(0.5,1)
    exitButton:SetParent(mainFrame)
    
    exitButton.MouseDown = function ()
        results.ReturnToMenu()
    end
end

function results:Open(breadamnt, totalNotes)
    self.Screen.Enabled = true
    yan:NewTween(mainFrame, yan:TweenInfo(1, EasingStyle.ElasticOut), {Position = UIVector2.new(0.15,0,0.15,0)}):Play()
    bread.Text = "Bread: "..breadamnt
    notes.Text = "Notes Hit: "..tostring(totalNotes).."/"..tostring(conductor:GetNoteCount())
    local accuracypercent = (breadamnt / (conductor:GetBreadCount()) * 100)
    accuracypercent = accuracypercent * 100
    accuracypercent = math.ceil(accuracypercent)

    accuracypercent = accuracypercent / 100

    accuracy.Text = "Accuracy: "..accuracypercent.."%"
end

return results