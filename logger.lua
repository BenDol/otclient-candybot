BotLogger = {}

BotLogTypes = {
  warning = 1,
  error = 2,
  debug = 3
}

local MAX_LINES = 35

local logBuffer
local logWindow

function BotLogger.init()
  logWindow = CandyBot.getUI():recursiveGetChildById('logWindow')
  logBuffer = logWindow:getChildById('logBuffer')
end

function BotLogger.warning(msg)
  BotLogger.print(BotLogTypes.warning, msg)
end

function BotLogger.error(msg)
  BotLogger.print(BotLogTypes.error, msg)
end

function BotLogger.debug(msg)
  BotLogger.print(BotLogTypes.debug, msg)
end

function BotLogger.print(type, msg)
  local trace = debug.getinfo(debug.getinfo(3, "f").func)

  local path = BotLogger.trimPath(trace.short_src:explode("/"))
  local msg = --[["[BotLogger - "..path.." "..trace.linedefined.."]: " .. ]]msg

  if type == BotLogTypes.warning then
    --g_logger.warning(msg)
    BotLogger.createLabel(msg, "yellow")
  elseif type == BotLogTypes.error then
    --g_logger.error(msg)
    BotLogger.createLabel(msg, "red")
  elseif type == BotLogTypes.debug then
    --g_logger.debug(msg)
    BotLogger.createLabel(msg, "white")
  end
end

function BotLogger.createLabel(text, color)
  if logBuffer:getChildCount() > MAX_LINES then
    logBuffer:getFirstChild():destroy()
  end
  local label = g_ui.createWidget('LogLabel', logBuffer)
  label:setId('consoleLabel' .. logWindow:getChildCount())
  label:setText(text)
  label:setColor(color)
  return label
end

function BotLogger.trimPath(path)
  local file, i, count = '', #path, 0
  while i > 0 and count < 3 do
    if i < #path then
      file = path[i] .. "/"..file
    elseif i == #path then
      file = path[i]..file
    end
    i = i - 1
    count = count + 1
  end
  return file
end