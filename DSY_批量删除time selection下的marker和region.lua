reaper.Undo_BeginBlock()    

local left, right=reaper.GetSet_LoopTimeRange(0, 1, 0, 0, 0)

reaper.Main_OnCommand(40420, 0)  -- remove markers in time selection

reaper.Main_OnCommand(40635, 0)  -- remove time selection

reaper.Main_OnCommand(40624, 0)  -- remove loop point

if right==0 then return end

local num=reaper.CountProjectMarkers(0)

if num==0 then return end

local region={}

for i=0, num-1 do

    local _, isrgn, pos, rgnend, name, idx=reaper.EnumProjectMarkers(i)

    if isrgn and left-pos<0.0001 and rgnend-right<0.0001 then

        table.insert(region, pos)

    end

end

local cur=reaper.GetCursorPosition()

reaper.PreventUIRefresh(1)

for k, v in pairs(region) do

    reaper.SetEditCurPos(v, 0, 0)

    reaper.Main_OnCommand(40615, 0)  -- delete region near cursor

end

reaper.SetEditCurPos(cur, 0, 0)

reaper.PreventUIRefresh(-1)

reaper.Undo_EndBlock("删除marker", -1)