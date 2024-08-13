conductor = {}

conductor.BPM = 150
conductor.SongPositionInBeats = 0
conductor.SongPosition = 0.0
conductor.LastBeat = 0.0
conductor.SecondsPerBeat = 0.0

conductor.LastChartBeat = {B = 0.0, N = {}}
conductor.NextChartBeat = {B = 0.0, N = {}}
conductor.NoteIndex = 1
conductor.ChartFinished = false
conductor.Chart = {}
conductor.BeatToMiss = nil

conductor.HoldingBeats = {nil, nil, nil, nil}

local settings = require("settings")

function conductor:Init()
    self.SecondsPerBeat = 60 / self.BPM
end

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
            self.BeatToMiss = self.LastChartBeat
            
            self.NoteIndex = self.NoteIndex + 1
        end
    end
    
    --[[if self.BeatToMiss ~= nil then
        if self.SongPositionInBeats > self.BeatToMiss.B + 1 then
            self.Missed()
            self.BeatToMiss = nil
        end
    end]]
    
end

function conductor:LoadChart()
    local combineIndex = 0
    local previousBeat = nil
    for i, v in ipairs(require("chart")) do
        --print(v.N, v.B)
        if previousBeat == v.B then
            --print(self.Chart[combineIndex])
            table.insert(self.Chart[combineIndex].N, v.N)
            self.Chart[combineIndex].D[tostring(v.N)] = v.D
            
            
            if v.D ~= nil then
                if self.Chart[combineIndex].D == nil then
                    self.Chart[combineIndex].D = {}
                end
                self.Chart[combineIndex].D[tostring(v.N)] = v.D
            end
        else
            combineIndex = combineIndex + 1
            self.Chart[combineIndex] = {B = v.B, N = {v.N}}
            
            if v.D ~= nil then
                self.Chart[combineIndex].D = {[tostring(v.N)] = v.D}
            end
            --print(self.Chart[combineIndex])
        end
       
        previousBeat = v.B
    end
    
    self.NextChartBeat = self.Chart[1]
    conductor.NoteIndex = conductor.NoteIndex + 1
end

function conductor:GetHitAccuracy(key)
    local time = self.SongPositionInBeats
    
    local lastDiff = math.abs(self.LastChartBeat.B - time)
    local nextDiff = math.abs(self.NextChartBeat.B - time)
    
    if lastDiff > 1 and nextDiff > 1 then return end

    if lastDiff > nextDiff then
        if self.NextChartBeat.H ~= true then
            for _, n in ipairs(self.NextChartBeat.N) do
                if key == settings.Keybinds[n] then
                    self.NextChartBeat.H = true
                    
                    if self.NextChartBeat.D[tostring(n)] ~= nil then
                        self.HoldingBeats[n] = self.NextChartBeat
                    end

                    return nextDiff
                end
            end
        end
    else
        if self.LastChartBeat.H ~= true then
            for _, n in ipairs(self.LastChartBeat.N) do
                if key == settings.Keybinds[n] then
                    self.LastChartBeat.H = true

                    if self.LastChartBeat.D[tostring(n)] ~= nil then
                        self.HoldingBeats[n] = self.LastChartBeat
                    end
                    
                    return lastDiff
                end
            end
        end
    end
end

function conductor:ReleaseHeldNote(key)
    local index = 0
    for i, v in pairs(settings.Keybinds) do
        index = index + 1
        if v == key then
            break
        end
    end

    if index == 0 then return end
    
    local heldNote = self.HoldingBeats[index]
    if heldNote == nil then return end

    local time = self.SongPositionInBeats
    local diff = math.abs((heldNote.B + heldNote.D[tostring(index)]) - time)
    
    return diff
end