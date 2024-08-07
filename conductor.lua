conductor = {}

conductor.BPM = 128
conductor.SongPositionInBeats = 0
conductor.SongPosition = 0.0
conductor.LastBeat = 0.0
conductor.SecondsPerBeat = 0.0

function conductor:Update(dt)
    self.SecondsPerBeat = 60 / self.BPM
    
    self.SongPosition = self.SongPosition + dt
    
    if self.SongPosition > self.LastBeat + self.SecondsPerBeat then
        self.SongPositionInBeats = self.SongPositionInBeats + 1
        self.LastBeat = self.LastBeat + self.SecondsPerBeat

        if self.Metronome ~= nil then
            self.Metronome()
        end
    end
end

function conductor:GetHitAccuracy()
    local time = self.SongPosition
    local nextBeat = self.LastBeat + self.SecondsPerBeat
    
    local lastDiff = math.abs(self.LastBeat - time)
    local nextDiff = math.abs(nextBeat - time)
    
    if lastDiff > nextDiff then
        return nextDiff
    else
        return lastDiff
    end
end