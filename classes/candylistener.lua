--[[
  @Authors: Ben Dol (BeniS)
  @Details: CandyListener class for listening events logic.
]]

CandyListener = newclass("CandyListener")

ListenerConnection = {
  connect = 1,
  disconnect = 2
}

CandyListener.create = function(id, connections, state)
  local ls = CandyListener.internalCreate()
  
  if type(id) ~= 'number' then
    error('invalid id provided.')
  end
  ls.id = id

  if type(connections) ~= 'table' or #connections ~= 2 then
    error('invalid connections table provided.')
  end
  ls.connections = connections
  ls.state = state or false

  ls.prevConnections = {}
  ls.connected = false

  return ls
end

-- gets/sets

function CandyListener:getId()
  return self.id
end

function CandyListener:setId(id)
  self.id = id
end

function CandyListener:getConnections(type)
  return self.connections
end

function CandyListener:getConnection(type)
  return self.connections[type]
end

function CandyListener:setConnection(type, connection)
  self.connections[type] = connection
end

function CandyListener:getState()
  return self.state
end

function CandyListener:setState(state)
  self.state = state
end

function CandyListener:setConnection(connection)
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

function CandyListener:connect()
  if CandyBot.isEnabled() then
    self.connections[ListenerConnection.connect](self.id)
    connected = true
  end
end

function CandyListener:disconnect()
  self.connections[ListenerConnection.disconnect](self.id)
  connected = false
end

function CandyListener:reload()
  self:disconnect()
  self:connect()
end

function CandyListener:isConnected()
  return connected
end

function CandyListener:isConnectionEqual(connection)
  if type(connection) ~= "table" then
    error("Invalid connection table parameter")
    return
  end
  return (connection[ListenerConnection.connect] == self.connections[ListenerConnection.connect]
    and connection[ListenerConnection.disconnect] == self.connections[ListenerConnection.disconnect])
end

function CandyListener:usePreviousConnection()
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