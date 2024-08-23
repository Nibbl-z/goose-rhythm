conductor = {}

conductor.BPM = 90
conductor.SongPositionInBeats = 0
conductor.SongPosition = 0.0
conductor.LastBeat = 0.0
conductor.SecondsPerBeat = 0.0

conductor.LastChartBeats = {{B = 0.0, N = {}, H = {}}, {B = 0.0, N = {}, H = {}}, {B = 0.0, N = {}, H = {}}, {B = 0.0, N = {}, H = {}}}
conductor.NextChartBeats = {{B = 0.0, N = {}, H = {}}, {B = 0.0, N = {}, H = {}}, {B = 0.0, N = {}, H = {}}, {B = 0.0, N = {}, H = {}}}
conductor.NoteIndex = {nil, nil, nil, nil}
conductor.ChartFinished = false
conductor.Chart = {}
conductor.IsSong = false

conductor.HoldingBeats = {nil, nil, nil, nil}
conductor.TotalNotes = 0

local settings = require("modules.settings")
local utils = require("yan.utils")

function conductor:Init()
    self.SongPosition = 0
    self.SongPositionInBeats = 0
    self.LastBeat = 0
    self.LastChartBeats = {{B = 0.0, N = {}, H = {}}, {B = 0.0, N = {}, H = {}}, {B = 0.0, N = {}, H = {}}, {B = 0.0, N = {}, H = {}}}
    self.NextChartBeats = {{B = 0.0, N = {}, H = {}}, {B = 0.0, N = {}, H = {}}, {B = 0.0, N = {}, H = {}}, {B = 0.0, N = {}, H = {}}}
    self.ChartFinished = false
    self.NoteIndex = 1
    self.HoldingBeats = {nil, nil, nil, nil}

    self.SecondsPerBeat = 60 / self.BPM
end

function conductor:Update(dt)
    self.SecondsPerBeat = 60 / self.BPM
    
    self.SongPosition = self.SongPosition + love.timer.getDelta()
    self.SongPositionInBeats = self.SongPosition / self.SecondsPerBeat

    if self.SongPosition > self.LastBeat + self.SecondsPerBeat then
        self.LastBeat = self.LastBeat + self.SecondsPerBeat
        
        if self.Metronome ~= nil then
            self.Metronome()
        end
    end 
    
    for i, v in ipairs(self.NextChartBeats) do
        if self.IsSong then
            if self.SongPositionInBeats > self:GetChartEndBeat() then
                if self.OnChartFinish ~= nil then
                    self.IsSong = false
                    self.OnChartFinish()
                end

                return
            end
        end

        if self.SongPositionInBeats > v.B then
            if not self.ChartFinished then
                if self.Chart[self.NoteIndex] == nil then
                    self.ChartFinished = true

                    return
                end
            end
            
            self.LastChartBeats[i] = v
            
            --[[for _, chartBeat in ipairs(self.Chart) do
                for _, chartBeatNotes in ipairs(chartBeat.N) do
                    for _, n in ipairs(v.N) do
                        if n == chartBeatNotes then
                            self.NextChartBeats[i] = chartBeat
                        end
                    end
                end
            end]]
            local foundBeat = false
            for _, chartBeat in ipairs(self.Chart) do
                for _, n in ipairs(chartBeat.N) do
                    if n == i and chartBeat.C[tostring(n)] == nil then
                        --if #v.N == 1 then
                        self.NextChartBeats[n] = chartBeat
                        chartBeat.C[tostring(n)] = true
                        foundBeat = true

                        --[[else
                            for nindex, n2 in ipairs(v.N) do
                                self.NextChartBeats[n2] = {B = chartBeat.B, N = {n2}, H = {}}
                                
                                if nindex == #v.N then
                                    chartBeat.C = true
                                    foundBeat = true
                                end
                            end
                        end]]
                    end
                end
                
                if foundBeat then break end
            end
        end
    end

    --[[for i, v in ipairs(self.NextChartBeats) do
        if self.SongPositionInBeats > v.B then
            if not self.ChartFinished then
                if self.Chart[self.NoteIndex] == nil then
                    self.ChartFinished = true
    
                    return
                end
                print(v.B)
                self.LastChartBeats[i] = self.NextChartBeats[i]
                
                for _, chartNote in ipairs(self.Chart) do
                    for nindex, chartNoteN in ipairs(chartNote.N) do
                        print(v.N[nindex])
                        if chartNoteN == v.N[nindex] and chartNote.B == v.B then
                            self.NextChartBeats[i] = chartNote
                            break
                        end
                    end
                end
                --self.NextChartBeats[i] = self.Chart[self.NoteIndex]
                
                --self.NoteIndex = self.NoteIndex + 1
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
    end]]
    
    --[[if self.BeatToMiss ~= nil then
        if self.SongPositionInBeats > self.BeatToMiss.B + 1 then
            self.Missed()
            self.BeatToMiss = nil
        end
    end]]
    
end

function RemoveDuplicateNotes(chart)
    local seenNotes = {}
    
    function IsDuplicate(note)
        for _, v in ipairs(seenNotes) do
            if v.B == note.B and v.D == note.D and v.N == note.N then
                return true
            end
        end
        
        return false
    end

    for i, v in ipairs(chart) do
        if IsDuplicate(v) == false then
            print(i, #seenNotes)
            table.insert(seenNotes, v)
        end
    end
    
    return seenNotes
end

function conductor:LoadChart(c)
    local chart = RemoveDuplicateNotes(c)
    self.TotalNotes = #chart
    print(#chart)
    self.Chart = {}
    conductor.IsSong = true
    local combineIndex = 0
    local previousBeat = nil
    
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
            self.Chart[combineIndex] = {B = v.B, N = {v.N}, H = {}, C = {}}
            
            if v.D ~= nil then
                if v.D ~= 0 then
                    self.Chart[combineIndex].D = {[tostring(v.N)] = v.D}
                end
            end
            --print(self.Chart[combineIndex])
        end
       
        previousBeat = v.B
    end
    
    print(self:GetNoteCount())
     
    self.NextChartBeat = self.Chart[1]
    conductor.NoteIndex = conductor.NoteIndex + 1
    
    local foundFirstBeats = {false, false, false, false}
    
    for i, v in ipairs(self.Chart) do
        for _, n in ipairs(v.N) do
            if foundFirstBeats[n] == false then
                self.NextChartBeats[n] = v
                v.C = {[tostring(n)] = true}
                foundFirstBeats[n] = true
            end
        end
    end
end

function conductor:GetChartEndBeat()
    if #self.Chart == 0 then return 2 end
    local beat = self.Chart[#self.Chart]
    
    local beatEndTime = beat.B 
    
    if beat.D ~= nil then
        local largestDuration = 0
        for k, d in pairs(beat.D) do
            if d >= largestDuration then
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
    local index = nil
    
    for i, n in ipairs(settings.Keybinds) do
        if key == n then
            index = i 
        end
    end
    
    if index == nil then return end
    
    local lastDiff = math.abs(self.LastChartBeats[index].B - time)
    local nextDiff = math.abs(self.NextChartBeats[index].B - time)
    
    if lastDiff > 0.6 and nextDiff > 0.6 then return end
    
    
    
    if lastDiff > nextDiff then
        for _, n in ipairs(self.NextChartBeats[index].N) do
            if key == settings.Keybinds[n] then
                num = n 
            end
        end
        if num == nil then return end
        if self.NextChartBeats[index].H[tostring(num)] ~= true then
            for _, n in ipairs(self.NextChartBeats[index].N) do
                if key == settings.Keybinds[n] then
                    self.NextChartBeats[index].H[tostring(n)] = true
                    
                    if self.NextChartBeats[index].D ~= nil then
                        if self.NextChartBeats[index].D[tostring(n)] ~= nil then
                            self.HoldingBeats[n] = self.NextChartBeats[index]
                        end
                    end
                    
                    
                    return nextDiff
                end
            end
        end
    else
        for _, n in ipairs(self.LastChartBeats[index].N) do
            if key == settings.Keybinds[n] then
                num = n 
            end
        end
        if num == nil then return end
        if self.LastChartBeats[index].H[tostring(num)]  ~= true then
            for _, n in ipairs(self.LastChartBeats[index].N) do
                if key == settings.Keybinds[n] then
                    self.LastChartBeats[index].H[tostring(n)] = true
                    if self.LastChartBeats[index].D ~= nil then
                        if self.LastChartBeats[index].D[tostring(n)] ~= nil then
                            self.HoldingBeats[n] = self.LastChartBeats[index]
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
    self.HoldingBeats[index] = nil
    
    return diff
end