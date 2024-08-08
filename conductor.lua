conductor = {}

conductor.BPM = 128
conductor.SongPositionInBeats = 0
conductor.SongPosition = 0.0
conductor.LastBeat = 0.0
conductor.SecondsPerBeat = 0.0

conductor.LastChartBeat = 0.0
conductor.NextChartBeat = 0.0
conductor.NoteIndex = 1
conductor.ChartFinished = false
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
    
    if self.SongPositionInBeats > self.NextChartBeat then
        if not self.ChartFinished then
            print("!")
            if self.Chart[self.NoteIndex] == nil then
                self.ChartFinished = true
                return
            end
            self.LastChartBeat = self.NextChartBeat
            self.NextChartBeat = self.Chart[self.NoteIndex].B
            
            self.NoteIndex = self.NoteIndex + 1
            
           
        end
    end
end

function conductor:LoadChart()
    self.Chart = require("chart")
    
    self.NextChartBeat = self.Chart[1].B
    conductor.NoteIndex = conductor.NoteIndex + 1
end

function conductor:GetHitAccuracy()
    local time = self.SongPositionInBeats

    local lastDiff = math.abs(self.LastChartBeat - time)
    local nextDiff = math.abs(self.NextChartBeat - time)
    
    print(nextDiff, lastDiff)
    print(self.LastChartBeat, self.NextChartBeat)

    if lastDiff > nextDiff then
        return nextDiff
    else
        return lastDiff
    end
end