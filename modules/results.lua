local results = {}
require "yan"

function results:Init()
    self.Screen = yan:Screen()
    self.Screen.Enabled = false
    self.Screen.ZIndex = 3

    mainFrame = yan:Frame(self.Screen)
    mainFrame.Position = UIVector2.new(0.5,0,1.5,0)
    mainFrame.Size = UIVector2.new(0.7,0,0.7,0)
    mainFrame.AnchorPoint = Vector2.new(0.5,0.5)
    
    mainFrame.Color = Color.new(0,0,0,0.5)
    mainFrame.CornerRoundness = 8
    
    title = yan:Label(self.Screen, "Song Complete!", 60, "center", "center", "/ComicNeue.ttf")
    title:SetParent(mainFrame)
    title.Size = UIVector2.new(0.6,0,0.1,0)
    title.Position = UIVector2.new(0.5,0,-0.2,0) -- wtf the positioning is messed up... wahhh
    title.AnchorPoint = Vector2.new(0.5,0)
    title.TextColor = Color.new(1,1,1,1)
    
    bread = yan:Label(self.Screen, "Bread: 0", 40, "center", "center", "/ComicNeue.ttf")
    bread:SetParent(mainFrame)
    bread.Size = UIVector2.new(0.6,0,0.1,0)
    bread.Position = UIVector2.new(0.5,0,0.2,0) -- wtf the positioning is messed up... wahhh
    bread.AnchorPoint = Vector2.new(0.5,0)
    bread.TextColor = Color.new(1,1,1,1)
    
    notes = yan:Label(self.Screen, "Notes Hit: 0/0", 40, "center", "center", "/ComicNeue.ttf")
    notes:SetParent(mainFrame)
    notes.Size = UIVector2.new(0.6,0,0.1,0)
    notes.Position = UIVector2.new(0.5,0,0.3,10) -- wtf the positioning is messed up... wahhh
    notes.AnchorPoint = Vector2.new(0.5,0)
    notes.TextColor = Color.new(1,1,1,1)

    exitButton = yan:TextButton(self.Screen, "Return to Menu", 40, "center", "center", "/ComicNeue.ttf")
    exitButton.Position = UIVector2.new(0.5,0,1,-10)
    exitButton.Size = UIVector2.new(0.5,0,0.1,0)
    exitButton.AnchorPoint = Vector2.new(0.5,1)
    exitButton:SetParent(mainFrame)
    
    exitButton.MouseDown = function ()
        results.ReturnToMenu()
    end
end

function results:Open(breadamnt)
    self.Screen.Enabled = true
    yan:NewTween(mainFrame, yan:TweenInfo(1, EasingStyle.ElasticOut), {Position = UIVector2.new(0.5,0,0.5,0)}):Play()
    bread.Text = "Bread: "..breadamnt
end

return results