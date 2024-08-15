local settings = {}

settings.Keybinds = {"a", "s", "k", "l"}
settings.MusicVolume = 1.0

function settings:GetMusicVolume()
    return self.MusicVolume -- this is because you have to like rerequire when you uhmmm change it so yea 
end

return settings