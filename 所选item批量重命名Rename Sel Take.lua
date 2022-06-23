retval, txt=reaper.GetUserInputs('Rename Item',1,'New Name,extrawidth=200','')
if retval == false then return end
cont=reaper.CountSelectedMediaItems(0)
idx=0
while idx<cont do
item=reaper.GetSelectedMediaItem(0 ,idx)
tk= reaper.GetMediaItemTake(item, 0)
retval, txt = reaper.GetSetMediaItemTakeInfo_String(tk, 'P_NAME', txt, true)
idx=idx+1
end

