function Main()

  reaper.Undo_BeginBlock()

  -- COUNT NUM OF SELECTED TRACK
  count_sel_tracks = reaper.CountSelectedTracks(0) -- Get number of selected tracks

  if count_sel_tracks > 0 then -- If 1 or more tracks are selected

      -- LOOP THROUGH SELECTED TRACKS
      for i = 0, count_sel_tracks - 1 do --Iterate through selected tracks

        track = reaper.GetSelectedTrack(0, i) --Get current track in loop
        numFX =  reaper.TrackFX_GetCount(track) --Get number of Track Fx
        
        -- LOOP THROUGH TRACK FX
        for j = 0, numFX - 1 do
          
          count_params = reaper.TrackFX_GetNumParams(track, j) --Count number of track fx parameters
          param_retval, minval, maxval = reaper.TrackFX_GetParam(track, j, 0) --Get value of parameter 0 (Should be'Azimuth')
          retval, buf = reaper.TrackFX_GetParamName(track, j, 0, "") --Check parameter name
         
          if buf == "Azimuth" then -- If param name matches 'Azimuth'
        
            param_retval = (param_retval *360) - 180 --Scale param value between -180:180
            
            --SCALE PARAMAETER VALUES TO DEGREES
            if param_retval <= 179 and param_retval > 90 then
              pan = param_retval % 90 
              pan = 90 - pan
            elseif param_retval <= -179 and param_retval > -90 then
              pan = param_retval % -90
              pan = -90 - pan
            elseif param_retval == 180 or param_retval == -180 then
              pan = 0
            else 
              pan = param_retval
            end
            
            --SCALE AND SET PAN
            pan = pan * 0.011 --Scale from -90:90deg to -1:1%
            reaper.SetMediaTrackInfo_Value(track, "D_PAN", pan) --Apply panning to track
            
          end
       end
   end 
  reaper.Undo_EndBlock("Set Pan from Azimuth", -1)

  end
end

reaper.PreventUIRefresh(1)

Main()

reaper.PreventUIRefresh(-1)
