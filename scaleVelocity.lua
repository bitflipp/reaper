local active_midi_editor = reaper.MIDIEditor_GetActive()
local take = reaper.MIDIEditor_GetTake(active_midi_editor)
if take then
  reaper.PreventUIRefresh(1)
  reaper.Undo_BeginBlock()

  local ok, fac = reaper.GetUserInputs("Scale velocity", 1, "Factor [%]", "50")
  if not ok then
    return
  end

  local _, notes, _, _ = reaper.MIDI_CountEvts(take)
  for i = 0, notes do
    local _, sel, muted, start, end_, chan, pitch, vel = reaper.MIDI_GetNote(take, i)
    if sel then
      reaper.MIDI_SetNote(take, i, sel, muted, start, end_, chan, pitch, math.floor(vel * fac / 100.0))
    end
  end

  reaper.UpdateArrange()

  reaper.Undo_EndBlock("Scale velocity", 0)
  reaper.PreventUIRefresh(-1)
  reaper.SN_FocusMIDIEditor()
end
