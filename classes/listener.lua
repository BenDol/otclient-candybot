Listener = {}
Listener.__index = Listener

Listener.__class = "Listener"

ListenerConnection = {
  connect = 1,
  disconnect = 2
}

Listener.new = function(id, connections, state)
  ls = {
    id = 0,
    connections = {},
    prevConnections = {},
    state = false,
    connected = false
  }

  if type(id) ~= 'number' then
    error('invalid id provided.')
  end
  ls.id = id

  if type(connections) ~= 'table' or #connections ~= 2 then
    error('invalid connections table provided.')
  end
  ls.connections = connections
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

function Listener:getConnections(type)
  return self.connections
end

function Listener:getConnection(type)
  return self.connections[type]
end

function Listener:setConnection(type, connection)
  self.connections[type] = connection
end

function Listener:getState()
  return self.state
end

function Listener:setState(state)
  self.state = state
end

function Listener:setConnection(connection)
  if type(connection) ~= "table" then
    error("Invalid connection table parameter")
    return
  end
  self:disconnect()

  self.prevConnections[ListenerConnection.connect] = self.connections[ListenerConnection.connect]
  self.connections[ListenerConnection.connect] = connection[ListenerConnection.connect]

  self.prevConnections[ListenerConnection.disconnect] = self.connections[ListenerConnection.disconnect]
  self.connections[ListenerConnection.disconnect] = connection[ListenerConnection.disconnect]

  self:connect()
end

-- methods

function Listener:connect()
  if UIBotCore.isEnabled() then
    self.connections[ListenerConnection.connect](self.id)
    connected = true
  end
end

function Listener:disconnect()
  self.connections[ListenerConnection.disconnect](self.id)
  connected = false
end

function Listener:reload()
  self:disconnect()
  self:connect()
end

function Listener:isConnected()
  return connected
end

function Listener:isConnectionEqual(connection)
  if type(connection) ~= "table" then
    error("Invalid connection table parameter")
    return
  end
  return (connection[ListenerConnection.connect] == self.connections[ListenerConnection.connect]
    and connection[ListenerConnection.disconnect] == self.connections[ListenerConnection.disconnect])
end

function Listener:usePreviousConnection()
  if table.empty(self.prevConnections) then
    error("previous connection is empty")
    return
  elseif not self.prevConnections[ListenerConnection.connect] then
    error("previous connection ListenerConnection.connect is nil")
    return
  elseif not self.prevConnections[ListenerConnection.disconnect] then
    error("previous connection ListenerConnection.disconnect is nil")
    return
  end

  self:setConnection(self.prevConnections)
end