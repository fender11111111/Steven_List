--------------------------------------

tail = 0

name = 'Mixdown'

time_selection = 1

mono_stereo = 2

pre_render_length = 0
   
   trim_start = 1


---------------------------------------

local values_for_render = tostring(tail)
..","..tostring(name)
..","..tostring(time_selection)
..","..tostring(mono_stereo)
..","..tostring(pre_render_length)
..","..tostring(trim_start)

---------------------------------------

---Test----

function OpenURL(url)
  local OS = reaper.GetOS()
  if OS == "OSX32" or OS == "OSX64" then
    os.execute('open "" "' .. url .. '"')
  else
    os.execute('start "" "' .. url .. '"')
  end
end
      
      
local test = reaper.NF_GetMediaItemPeakRMS_Windowed --function added in 2.9.7 SWS
if not test then 
window = reaper.MB('Please install or udpate SWS extension', 'Error', 0) end
if window  then
OpenURL("http://www.sws-extension.org/") return
end



if reaper.CountSelectedMediaItems(0) == 0 then reaper.MB('Please select an item', 'Error', 0) return end




local function Create_global_folder_for_render()
  local track_for_folder = reaper.GetTrack(0,0)
    if track_for_folder then
      local numb = reaper.GetMediaTrackInfo_Value(track_for_folder,"IP_TRACKNUMBER")
      reaper.InsertTrackAtIndex(numb-1,false)
      local track_for_folder_two = reaper.GetTrack(0,numb-1)
        reaper.SetMediaTrackInfo_Value(track_for_folder_two, 'I_FOLDERDEPTH', 1)
        reaper.SetOnlyTrackSelected(track_for_folder_two)
    end
end

 


reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)
if reaper.CountSelectedMediaItems(0) == 0 then return end

::START::
local retval, value = reaper.GetUserInputs("Mixdown selection", 6, "Set tail (sec)... ,Set name,Time selection? (1 - yes, 0 - no),Mono-1  Stereo-2,Pre-render length (sec)...,    Trim item's start? (pre-ren)", values_for_render)
   if retval then
     local val1, name1, val2, val3, val4, val5  = value:match("([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)")
     
     local val_tail = tonumber(val1)
     local val_name = tostring(name1)
     local val_timesel = tonumber(val2)
     local val_chan = tonumber(val3)
     local val_pre = tonumber(val4)
     local val_trim = tonumber(val5)

     if not val_tail or not val_timesel or not val_chan or not val_pre or not val_trim then 
     reaper.MB('No value. Please enter a number', 'Error', 0) goto START end
        
        ---if not value for render, script must return---
        if val_chan < 1 then reaper.MB('No value for rendering. Please enter a number - Mono(1), Stereo(2)', 'Error', 0) goto START end 
            
        ---for playing project in real time :)---
        reaper.Main_OnCommand(1016, 0) reaper.Main_OnCommand(40345, 0)
        
        local save_item_selection = reaper.NamedCommandLookup("_SWS_SAVEALLSELITEMS1")
        local restore_item_selection = reaper.NamedCommandLookup("_SWS_RESTALLSELITEMS1")
        
        reaper.Main_OnCommand(save_item_selection,0)
        
        for i=reaper.CountSelectedMediaItems(0), 0, -1 do
          local get_sel_item = reaper.GetSelectedMediaItem(0,i)
          if get_sel_item then
            if reaper.GetMediaItemInfo_Value(get_sel_item, 'B_MUTE') == 1 then
              reaper.SetMediaItemSelected(get_sel_item, 0)
            end
          end
        end

        reaper.Main_OnCommand(41559, 0) -- solo items

        Create_global_folder_for_render()
        
        
        local save_selection_start, save_selection_end = reaper.GetSet_LoopTimeRange(0, false, 0, 0, 0)
        local save_cursor_position = reaper.GetCursorPosition()
        
        
           if val_timesel == 1 and save_selection_start == save_selection_end then
              reaper.Main_OnCommand(40290, 0) -- Set time selection to items
           elseif val_timesel == 0 then 
              reaper.Main_OnCommand(40290, 0) -- Set time selection to items
           end
           
        local render_selection_start, render_selection_end = reaper.GetSet_LoopTimeRange(0, false, 0, 0, 0)
        reaper.GetSet_LoopTimeRange(1, false, render_selection_start-val_pre, render_selection_end+val_tail, 0)
          
          
           local count_tracks_1 = reaper.CountTracks(0)

           if val_chan == 1 then
              reaper.Main_OnCommand(41718, 0) -- Render mono
           elseif val_chan >= 2 then
              reaper.Main_OnCommand(41716, 0) -- Render stereo
           end
        
        
        
        

            local get_selected_track_render = reaper.GetSelectedTrack(0,0)
                        if reaper.GetMediaTrackInfo_Value(get_selected_track_render, 'I_FOLDERDEPTH') == 1 then 
                          reaper.DeleteTrack(get_selected_track_render) else
                          reaper.GetSetMediaTrackInfo_String(get_selected_track_render, 'P_NAME',val_name,true)
                          local get_item_item = reaper.GetTrackMediaItem(get_selected_track_render, 0)
                          if get_item_item then
                            local get_take_get = reaper.GetActiveTake(get_item_item)
                            if get_take_get then
                            reaper.GetSetMediaItemTakeInfo_String(get_take_get, 'P_NAME', val_name, true)
                            local get_number_track = reaper.GetMediaTrackInfo_Value(get_selected_track_render,"IP_TRACKNUMBER")
                            local get_folder_track = reaper.GetTrack(0, get_number_track)
                              reaper.DeleteTrack(get_folder_track)
                              local count_tr = reaper.CountTracks(0)
                              reaper.ReorderSelectedTracks(count_tr,0)
                            end
                          end
                        end
            
            local count_tracks_2 = reaper.CountTracks(0)
                                
                     if val_trim > 0 and val_pre > 0 then
                          if count_tracks_1 == count_tracks_2 then
                            local get_selected_track_ren = reaper.GetSelectedTrack(0,0)
                            local get_sel_it = reaper.GetTrackMediaItem(get_selected_track_ren, 0)
                            reaper.SplitMediaItem(get_sel_it, render_selection_start)
                            local get_sel = reaper.GetTrackMediaItem(get_selected_track_ren, 0)
                            reaper.DeleteTrackMediaItem(get_selected_track_ren, get_sel)
                        end
                      end   
        
        
     reaper.GetSet_LoopTimeRange(1, false, save_selection_start, save_selection_end, 0)  
     reaper.SetEditCurPos(save_cursor_position, 0, 0)     
        
    reaper.Main_OnCommand(41560, 0) -- unsolo items
    
    reaper.Main_OnCommand(restore_item_selection,0)

  else return end


reaper.UpdateArrange()
reaper.Undo_EndBlock('Mixdwon selection', -1)
reaper.PreventUIRefresh(-1)
