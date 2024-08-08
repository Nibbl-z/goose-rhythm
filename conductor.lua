conductor = {}

conductor.BPM = 128
conductor.SongPositionInBeats = 0
conductor.SongPosition = 0.0
conductor.LastBeat = 0.0
conductor.SecondsPerBeat = 0.0

conductor.LastChartBeat = {B = 0.0, N = 0.0}
conductor.NextChartBeat = {B = 0.0, N = 0.0}
conductor.NoteIndex = 1
conductor.ChartFinished = false

local settings = require("settings")

function conductor:Update(dt)
    self.SecondsPerBeat = 60 / self.BPM
    
    self.SongPosition = self.SongPosition + dt
    self.SongPositionInBeats = self.SongPosition / self.SecondsPerBeat

    if self.SongPosition > self.LastBeat + self.SecondsPerBeat then
        self.LastBeat = self.LastBeat + self.SecondsPerBeat
        
        if self.Metronome ~= nil then
            self.Metronome()
        end
    end
    
    if self.SongPositionInBeats > self.NextChartBeat.B then
        if not self.ChartFinished then
            if self.Chart[self.NoteIndex] == nil then
                self.ChartFinished = true
                return
            end
            self.LastChartBeat = self.NextChartBeat
            self.NextChartBeat = self.Chart[self.NoteIndex]
            
            self.NoteIndex = self.NoteIndex + 1
            
           
        end
    end
end

function conductor:LoadChart()
    self.Chart = require("chart")
    
    self.NextChartBeat = self.Chart[1]
    conductor.NoteIndex = conductor.NoteIndex + 1
end

function conductor:GetHitAccuracy(key)
    local time = self.SongPositionInBeats
    
    local lastDiff = math.abs(self.LastChartBeat.B - time)
    local nextDiff = math.abs(self.NextChartBeat.B - time)
    
    if lastDiff > 1 and nextDiff > 1 then return end

    if lastDiff > nextDiff then
        if key == settings.Keybinds[self.NextChartBeat.N] then
            self.NextChartBeat.H = true
            return nextDiff
        end
    else
        if key == settings.Keybinds[self.LastChartBeat.N] then
            self.LastChartBeat.H = true
            return lastDiff
        end
    end
end