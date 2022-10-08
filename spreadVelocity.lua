--[[
SPDX-License-Identifier: MIT
Copyright (c) 2021 Philipp Naumann
Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:
The above copyright notice and this permission notice (including the next paragraph) shall be included
in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]--

local function run(take)
  local _, notes, _, _ = reaper.MIDI_CountEvts(take)
  local t = {}
  for i = 0, notes do
    local _, sel = reaper.MIDI_GetNote(take, i)
    if sel then
      t[#t + 1] = i
    end
  end
  local min, max = 127, 1
  for i = 1, #t do
    local _, _, _, _, _, _, _, vel = reaper.MIDI_GetNote(take, t[i])
    if vel < min then
      min = vel
    end
    if vel > max then
      max = vel
    end
  end

  local ok, csv = reaper.GetUserInputs("Spread velocity", 2, "Bounds (left, right)", string.format("%d,%d", min, max))
  if not ok then
    return
  end
  local left, right = string.match(csv, "([^,]+),(.+)")
  if not left or not right then
    return
  end

  for i = 1, #t do
    local _, sel, muted, start, end_, chan, pitch, vel = reaper.MIDI_GetNote(take, t[i])
    vel = math.ceil(((vel - min) / (max - min)) * (right - left) + left)
    reaper.MIDI_SetNote(take, t[i], sel, muted, start, end_, chan, pitch, vel)
  end

  reaper.UpdateArrange()
end

local active_midi_editor = reaper.MIDIEditor_GetActive()
local take = reaper.MIDIEditor_GetTake(active_midi_editor)
if take then
  reaper.PreventUIRefresh(1)
  reaper.Undo_BeginBlock()
  run(take)
  reaper.Undo_EndBlock("Spread velocity", 0)
  reaper.PreventUIRefresh(-1)
  reaper.SN_FocusMIDIEditor()
end
