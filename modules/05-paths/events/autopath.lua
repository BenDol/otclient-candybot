--[[
  @Authors: Ben Dol (BeniS)
  @Details: Auto pathing event logic
]]

PathsModule.AutoPath = {}
AutoPath = PathsModule.AutoPath

-- Variables

-- Methods

function AutoPath.init()
  --
end

function AutoPath.terminate()
  --
end

function AutoPath.onStopped()
  --
end

function AutoPath.Event(event)
  -- Keep the event live
  return Helper.safeDelay(600, 1400)
end