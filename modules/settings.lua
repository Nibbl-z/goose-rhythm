local settings = {}

settings.Keybinds = {"a", "s", "k", "l"}
settings.MusicVolume = 1.0
settings.NoteSpeed = 300

function settings:GetMusicVolume()
    return self.MusicVolume -- this is because you have to like rerequire when you uhmmm change it so yea 
end

function settings:GetKeybinds()
    return self.Keybinds
end

function settings:Load()
    love.filesystem.setIdentity(love.filesystem.getIdentity())

    if love.filesystem.getInfo("settings") == nil then return end
    local index = 1
    for value in love.filesystem.lines("settings") do
        if index == 1 then
            self.MusicVolume = value
        end

        if index >= 2 and index <= 5 then
            self.Keybinds[index - 1] = value
        end

        if index == 6 then
            self.NoteSpeed = value
        end
        index = index + 1
    end
end

function settings:Save()
    love.filesystem.setIdentity(love.filesystem.getIdentity())
    
    local settingsString = tostring(self.MusicVolume)
    for _, v in ipairs(self.Keybinds) do
        settingsString = settingsString.."\n"..v
    end
    settingsString = settingsString.."\n"..self.NoteSpeed
    
    love.filesystem.write("settings", settingsString)
end

return settings