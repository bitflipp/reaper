local active_midi_editor = reaper.MIDIEditor_GetActive()
local take = reaper.MIDIEditor_GetTake(active_midi_editor)
if take then
  reaper.PreventUIRefresh(1)
  reaper.Undo_BeginBlock()

  local ok, csv = reaper.GetUserInputs("Scale velocity linearly", 2, "Bounds (left, right)", "60,100")
  if not ok then
    return
  end
  local left, right = string.match(csv, "([^,]+),(.+)")
  if not left or not right then
    return
  end

  local _, notes, _, _ = reaper.MIDI_CountEvts(take)
  local t = {}
  for i = 0, notes do
    local _, sel = reaper.MIDI_GetNote(take, i)
    if sel then
      t[#t + 1] = i
    end
  end
  for i = 1, #t do
    local _, sel, muted, start, end_, chan, pitch, vel = reaper.MIDI_GetNote(take, t[i])
    vel = math.ceil(left + (right - left) / (#t - 1) * (i - 1))
    reaper.MIDI_SetNote(take, t[i], sel, muted, start, end_, chan, pitch, vel)
  end

  reaper.UpdateArrange()

  reaper.Undo_EndBlock("Scale velocity linearly", 0)
  reaper.PreventUIRefresh(-1)
  reaper.SN_FocusMIDIEditor()
end
