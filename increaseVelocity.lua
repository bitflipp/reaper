local active_midi_editor = reaper.MIDIEditor_GetActive()
local take = reaper.MIDIEditor_GetTake(active_midi_editor)
if take then
  reaper.PreventUIRefresh(1)
  reaper.Undo_BeginBlock()

  local ok, csv = reaper.GetUserInputs("Increase velocity", 1, "Amount (may be negative)", "0")
  if not ok then
    return
  end
  local amount = string.match(csv, "(-*%d+)")
  if not amount then
    return
  end

  local _, notes, _, _ = reaper.MIDI_CountEvts(take)
  for i = 0, notes do
    local _, sel, muted, start, end_, chan, pitch, vel = reaper.MIDI_GetNote(take, i)
    if sel then
      reaper.MIDI_SetNote(take, i, sel, muted, start, end_, chan, pitch, vel + amount)
    end
  end

  reaper.UpdateArrange()
  reaper.Undo_EndBlock("Increase velocity", 0)
  reaper.PreventUIRefresh(-1)
  reaper.SN_FocusMIDIEditor()
end
