conductor = {}

conductor.BPM = 90
conductor.SongPositionInBeats = 0
conductor.SongPosition = 0.0
conductor.LastBeat = 0.0
conductor.SecondsPerBeat = 0.0

conductor.LastChartBeat = {B = 0.0, N = {}}
conductor.NextChartBeat = {B = 0.0, N = {}}
conductor.NoteIndex = 1
conductor.ChartFinished = false
conductor.Chart = {}
conductor.IsSong = false

conductor.HoldingBeats = {nil, nil, nil, nil}

local settings = require("modules.settings")

function conductor:Init()
    self.SongPosition = 0
    self.SongPositionInBeats = 0
    self.LastBeat = 0
    self.LastChartBeat = {B = 0.0, N = {}}
    self.NextChartBeat = {B = 0.0, N = {}}
    self.ChartFinished = false
    self.NoteIndex = 1
    self.HoldingBeats = {nil, nil, nil, nil}

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
            
            self.NoteIndex = self.NoteIndex + 1
        else
            if self.IsSong then
                if self.SongPositionInBeats > self:GetChartEndBeat() then
                    if self.OnChartFinish ~= nil then
                        self.IsSong = false
                        self.OnChartFinish()
                    end
                end
            end
        end
    end
    
    --[[if self.BeatToMiss ~= nil then
        if self.SongPositionInBeats > self.BeatToMiss.B + 1 then
            self.Missed()
            self.BeatToMiss = nil
        end
    end]]
    
end

function conductor:LoadChart(chart)
    self.Chart = {}
    conductor.IsSong = true
    local combineIndex = 0
    local previousBeat = nil
    
    for _, v in ipairs(chart) do
        v.B = v.B + 4
    end

    table.sort(chart, function (a, b)
        return a.B < b.B
    end)
    for i, v in ipairs(chart) do
        --print(v.N, v.B)
        if previousBeat == v.B then
            --print(self.Chart[combineIndex])
            table.insert(self.Chart[combineIndex].N, v.N)
            --self.Chart[combineIndex].D[tostring(v.N)] = v.D
            
            
            if v.D ~= nil then
                if self.Chart[combineIndex].D == nil then
                    self.Chart[combineIndex].D = {}
                end
                self.Chart[combineIndex].D[tostring(v.N)] = v.D
            end
        else
            combineIndex = combineIndex + 1
            self.Chart[combineIndex] = {B = v.B, N = {v.N}, H = {}}
            
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

function conductor:GetChartEndBeat()
    if #self.Chart == 0 then return end
    local beat = self.Chart[#self.Chart]

    local beatEndTime = beat.B 
    
    if beat.D ~= nil then
        local largestDuration = 0
        for _, d in ipairs(beat.D) do
            if d > largestDuration then
                largestDuration = d
            end
        end

        beatEndTime = beatEndTime + largestDuration
    end

    beatEndTime = beatEndTime + 2 -- maybe later add a thing to metadata for chart end delay

    return beatEndTime
end

function conductor:GetNoteCount()
    local count = 0
    
    for _, beat in ipairs(self.Chart) do
        count = count + #beat.N
    end
    
    return count
end

function conductor:GetBreadCount()
    local count = 0
    
    for _, beat in ipairs(self.Chart) do
        count = count + #beat.N * 10
        print(count)
        if beat.D ~= nil then
            for _, v in pairs(beat.D) do -- #beat.D doesnt work bc its a dictonary wahhh
                count = count + 10
            end
        end
    end
    
    return count
end

function conductor:GetHitAccuracy(key)
    local time = self.SongPositionInBeats
    
    local lastDiff = math.abs(self.LastChartBeat.B - time)
    local nextDiff = math.abs(self.NextChartBeat.B - time)
    
    if lastDiff > 1 and nextDiff > 1 then return end
    print(key)
    print(lastDiff, nextDiff)
    local num = nil
    
    
    if lastDiff > nextDiff then
        for _, n in ipairs(self.NextChartBeat.N) do
            if key == settings.Keybinds[n] then
                num = n 
            end
        end
        if num == nil then return end
        if self.NextChartBeat.H[tostring(num)] ~= true then
            for _, n in ipairs(self.NextChartBeat.N) do
                if key == settings.Keybinds[n] then
                    self.NextChartBeat.H[tostring(n)] = true
                    
                    if self.NextChartBeat.D ~= nil then
                        if self.NextChartBeat.D[tostring(n)] ~= nil then
                            self.HoldingBeats[n] = self.NextChartBeat
                        end
                    end
                    
                    
                    return nextDiff
                end
            end
        end
    else
        for _, n in ipairs(self.LastChartBeat.N) do
            if key == settings.Keybinds[n] then
                num = n 
            end
        end
        if num == nil then return end
        if self.LastChartBeat.H[tostring(num)]  ~= true then
            for _, n in ipairs(self.LastChartBeat.N) do
                if key == settings.Keybinds[n] then
                    self.LastChartBeat.H[tostring(n)] = true
                    if self.LastChartBeat.D ~= nil then
                        if self.LastChartBeat.D[tostring(n)] ~= nil then
                            self.HoldingBeats[n] = self.LastChartBeat
                        end
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

    if heldNote.D[tostring(index)] == nil then return end

    local time = self.SongPositionInBeats
    local diff = math.abs((heldNote.B + heldNote.D[tostring(index)]) - time)
    
    table.remove(self.HoldingBeats, index)
    
    return diff
end