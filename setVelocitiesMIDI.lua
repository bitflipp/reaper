local reaper = require("reaper")

local function read_velocity()
  local output = reaper.ExecProcess([[C:\Users\phina\Syncthing\folders\Philipp\REAPER\Skripte\MidiInputReader.exe]], 0)
  local lines = {}
  for line in output:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end
  return lines[2]
end

local function run(take)
  local _, notes, _, _ = reaper.MIDI_CountEvts(take)
  for i = 0, notes do
    local _, sel, muted, start, end_, chan, pitch = reaper.MIDI_GetNote(take, i)
    if sel then
      local vel = read_velocity()
      reaper.MIDI_SetNote(take, i, sel, muted, start, end_, chan, pitch, vel)
    end
  end
  reaper.UpdateArrange()
end

local active_midi_editor = reaper.MIDIEditor_GetActive()
local take = reaper.MIDIEditor_GetTake(active_midi_editor)
if take then
  reaper.Undo_BeginBlock()
  run(take)
  reaper.Undo_EndBlock("Set velocities (MIDI)", 0)
end
