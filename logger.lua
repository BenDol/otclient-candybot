--[[
  @Authors: Ben Dol (BeniS)
  @Details: Logger methods for displaying messages
            to the user in the logging window.
]]

BotLogger = {}

BotLogTypes = {
  info = 1,
  warning = 2,
  error = 3,
  debug = 4
}
BotLogger.logType = BotLogTypes.info

local MAX_LINES = 45

local logBuffer
local logWindow
local printLogs

function BotLogger.init()
  logWindow = CandyBot.getUI():recursiveGetChildById('logWindow')
  printLogs = CandyBot.getUI():recursiveGetChildById('PrintLogs')
  logBuffer = logWindow:getChildById('logBuffer')
end

function BotLogger.info(msg)
  BotLogger.print(BotLogTypes.info, msg)
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

  if BotLogger.logType then
    if type == BotLogTypes.info then
      if BotLogger.logType >= BotLogTypes.info then
        --g_logger.info(msg)
        BotLogger.createLabel(msg, "white")
      end
    elseif type == BotLogTypes.warning then
      if BotLogger.logType >= BotLogTypes.warning then
        --g_logger.warning(msg)
        BotLogger.createLabel(msg, "yellow")
      end
    elseif type == BotLogTypes.error then
      if BotLogger.logType >= BotLogTypes.error then
        --g_logger.error(msg)
        BotLogger.createLabel(msg, "red")
      end
    elseif type == BotLogTypes.debug then
      if BotLogger.logType >= BotLogTypes.debug then
        --g_logger.debug(msg)
        BotLogger.createLabel(msg, "green")
      end
    end
  end

  if printLogs:isChecked() then
    print(msg)
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