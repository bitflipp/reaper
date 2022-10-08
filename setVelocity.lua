local active_midi_editor = reaper.MIDIEditor_GetActive()
local take = reaper.MIDIEditor_GetTake(active_midi_editor)
if take then
  reaper.PreventUIRefresh(1)
  reaper.Undo_BeginBlock()

  local ok, vel = reaper.GetUserInputs("Set velocity", 1, "Velocity", "60")
  if not ok then
    return
  end

  local _, notes, _, _ = reaper.MIDI_CountEvts(take)
  for i = 0, notes do
    local _, sel, muted, start, end_, chan, pitch = reaper.MIDI_GetNote(take, i)
    if sel then
      reaper.MIDI_SetNote(take, i, sel, muted, start, end_, chan, pitch, vel)
    end
  end

  reaper.UpdateArrange()

  reaper.Undo_EndBlock("Set velocity", 0)
  reaper.PreventUIRefresh(-1)
  reaper.SN_FocusMIDIEditor()
end
