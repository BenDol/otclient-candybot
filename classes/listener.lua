Listener = {}
Listener.__index = Listener

Listener.__class = "Listener"

ListenerCallback = {
  connect = 1,
  disconnect = 2
}

Listener.new = function(id, callbacks, state)
  ls = {
    id = 0,
    callbacks = {},
    state = false,
    connected = false
  }

  if type(id) ~= 'number' then
    error('invalid id provided.')
  end
  ls.id = id

  if type(callbacks) ~= 'table' or #callbacks ~= 2 then
    error('invalid callbacks table provided.')
  end
  ls.callbacks = callbacks
  ls.state = state

  setmetatable(ls, Listener)
  return ls
end

-- gets/sets

function Listener:getId()
  return self.id
end

function Listener:setId(id)
  self.id = id
end

function Listener:getCallbacks(type)
  return self.callbacks
end

function Listener:getCallback(type)
  return self.callbacks[type]
end

function Listener:setCallback(type)
  self.callbacks[type] = callback
end

function Listener:getState()
  return self.state
end

function Listener:setState(state)
  self.state = state
end

-- methods

function Listener:connect()
  if UIBotCore.isEnabled() then
    self.callbacks[ListenerCallback.connect](self.id)
    connected = true
  end
end

function Listener:disconnect()
  self.callbacks[ListenerCallback.disconnect](self.id)
  connected = false
end

function Listener:isConnected()
  return connected
end