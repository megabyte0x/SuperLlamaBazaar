-- ProcessId: TQKAOPuE5OKZUBNBBxUKqSCG6qkft45F2ju9IvZSK-Y

local json = require('json')
local sqlite3 = require('lsqlite3')

RealityDb = RealityDb or sqlite3.open_memory()
RealityDbAdmin = RealityDbAdmin or require('DbAdmin').new(RealityDb)

-- Change this to your Atomic Asset for Token Gating.
BIG_TABLE = 'XPj6VGx6iKUSTdm9XKqp3JQ4HpjvXX7kHYW3D_PxqtU'

--#region Initialization

SQLITE_TABLE_REALITY_ENTITIES = [[
  CREATE TABLE IF NOT EXISTS Entities (
    Id TEXT PRIMARY KEY,
    LastUpdated INTEGER NOT NULL,
    Position TEXT NOT NULL,
    Type TEXT NOT NULL,
    Metadata TEXT NOT NULL,
    StateCode INTEGER NOT NULL DEFAULT 2
  );
]]

-- State Codes
-- 0 - Hidden
-- 1 - VisibleAlways
-- 2 - VisibleRecent

function RealityDbInit()
  RealityDb:exec(SQLITE_TABLE_REALITY_ENTITIES)
end

RealityInitialized = RealityInitialized or false
if (not RealityInitialized) then
  RealityDbInit()
  RealityInitialized = true
end

function SetStateCode(timestamp, entityId, stateCode)
  RealityDbAdmin:exec(string.format([[
      UPDATE Entities
      SET StateCode = %d,
          LastUpdated = %d
      WHERE Id = '%s'
    ]],
    stateCode or 2,
    timestamp,
    entityId
  ))
end

--#endregion

--#region Model

RealityInfo = RealityInfo or {
  Parent = nil,
  Name = 'BigTable',
  Dimensions = 0,
  Spawn = {},
  ['Render-With'] = '0D-Null',
}

RealityParameters = RealityParameters or {}

RealityEntitiesStatic = RealityEntitiesStatic or {}

RealityParameters_Outsiders = RealityParameters_Outsiders or {}

RealityEntitiesStatic_Outsiders = RealityEntitiesStatic_Outsiders or {}

BIG_TABLE_MEMBERS = BIG_TABLE_MEMBERS or {}

--#endregion

--#region ReadHandlers

Handlers.add(
  "Reality.Info",
  Handlers.utils.hasMatchingTag("Action", "Reality.Info"),
  function(msg)
    print("Reality.Info")
    Handlers.utils.reply(json.encode(RealityInfo))(msg)
  end
)

Handlers.add(
  "Reality.Parameters",
  Handlers.utils.hasMatchingTag("Action", "Reality.Parameters"),
  function(msg)
    print("Reality.Parameters")
    local entityId = msg.Owner

    if (BIG_TABLE_MEMBERS[entityId]) then
      Handlers.utils.reply(json.encode(RealityParameters))(msg)
    else
      Handlers.utils.reply(json.encode(RealityParameters_Outsiders))(msg)
    end
  end
)

Handlers.add(
  "Reality.EntitiesStatic",
  Handlers.utils.hasMatchingTag("Action", "Reality.EntitiesStatic"),
  function(msg)
    local entityId = msg.Owner

    print("Reality.EntitiesStatic")

    if (BIG_TABLE_MEMBERS[entityId]) then
      Handlers.utils.reply(json.encode(RealityEntitiesStatic))(msg)
    else
      Handlers.utils.reply(json.encode(RealityEntitiesStatic_Outsiders))(msg)
    end
  end
)

Handlers.add(
  "Reality.EntitiesDynamic",
  Handlers.utils.hasMatchingTag("Action", "Reality.EntitiesDynamic"),
  function(msg)
    print("Reality.EntitiesDynamic")

    local data = json.decode(msg.Data)
    if (not data) then
      ReplyError(msg, "Invalid Data")
      return
    end
    local queryTimestamp = data.Timestamp
    -- Validate timestamp
    if (type(queryTimestamp) ~= "number") then
      ReplyError(msg, "Invalid Timestamp")
      return
    end

    local isInitial = data.Initial or false

    local additionalQuery = "LastUpdated > ?"
    if (isInitial) then
      additionalQuery = "(LastUpdated > ? AND StateCode == 2) OR StateCode == 1"
    end
    local query = RealityDb:prepare([[
      SELECT *
      FROM Entities
      WHERE Id == ? OR ]] .. additionalQuery
    )
    query:bind_values(msg.From, queryTimestamp)

    local entities = {}
    for row in query:nrows() do
      entities[row.Id] = {
        Position = json.decode(row.Position),
        Type = row.Type,
        Metadata = json.decode(row.Metadata),
        StateCode = row.StateCode,
      }
    end

    Handlers.utils.reply(json.encode(entities))(msg)
  end
)

--#endregion

--#region WriteHandlers

function ReplyError(msg, error)
  print("[" .. msg.From .. " => " .. msg.Id .. "] Error: " .. error)
  Send({
    Target = msg.From,
    Tags = {
      MsgRef = msg.Id,
      Result = "Error",
    },
    Error = error,
  })
end

function ZeroesArray(size)
  local arr = {}
  for i = 1, size do
    arr[i] = 0
  end
  return arr
end

function ValidatePosition(Position)
  if (not Position) then
    return false, "Position not found"
  end

  if (#Position ~= RealityInfo.Dimensions) then
    return false, "Invalid Position length"
  end

  for i = 1, #Position do
    if (type(Position[i]) ~= "number") then
      return false, "Invalid Position value"
    end
  end

  return true
end

ValidTypes = { "Unknown", "Avatar", "Hidden" }
function ValidateType(Type)
  for i = 1, #ValidTypes do
    if (Type == ValidTypes[i]) then
      return true
    end
  end

  return false
end

Handlers.add(
  "Reality.EntityCreate",
  Handlers.utils.hasMatchingTag("Action", "Reality.EntityCreate"),
  function(msg)
    print("Reality.EntityCreate")
    local entityId = msg.From
    local data = json.decode(msg.Data)

    local Position = RealityInfo.Spawn or ZeroesArray(RealityInfo.Dimensions)
    if (data.Position) then
      local valid, error = ValidatePosition(data.Position)

      if (not valid) then
        ReplyError(msg, error)
        return
      end

      Position = data.Position
    end

    local Type = "Unknown"
    if (data.Type) then
      if (not ValidateType(data.Type)) then
        ReplyError(msg, "Invalid Type")
        return
      end

      Type = data.Type
    end

    -- Is it necessary to validate this?
    local Metadata = data.Metadata or {}

    -- Ugly workaround for empty tables!
    Metadata['_'] = false;

    local stmt = RealityDb:prepare([[
        INSERT INTO Entities (Id, LastUpdated, Position, Type, Metadata)
        VALUES (?, ?, ?, ?, ?)
        ON CONFLICT(Id) DO UPDATE SET
          LastUpdated = excluded.LastUpdated,
          Type = excluded.Type,
          Metadata = excluded.Metadata,
          StateCode = 2
    ]])
    -- StateCode is reset to default, if it was hidden
    stmt:bind_values(
      entityId,
      msg.Timestamp,
      json.encode(Position),
      Type,
      json.encode(Metadata)
    )
    stmt:step()
    stmt:finalize()

    local result = {
      [entityId] = {
        Position = Position,
        Type = Type,
        Metadata = Metadata
      }
    }

    Send({
      Target = msg.From,
      Tags = {
        MsgRef = msg.Id,
        Result = "OK",
      },
      Data = json.encode(result),
    })
  end
)

Handlers.add(
  "Reality.EntityUpdatePosition",
  Handlers.utils.hasMatchingTag("Action", "Reality.EntityUpdatePosition"),
  function(msg)
    print("Reality.EntityUpdatePosition")
    local entityId = msg.From

    local dbEntry = RealityDbAdmin:exec(string.format([[
        SELECT * FROM Entities WHERE Id = '%s'
      ]],
      entityId
    ))[1]
    if (not dbEntry) then
      ReplyError(msg, "Entity not found")
      return
    end

    local data = json.decode(msg.Data)

    local Position = data.Position
    local valid, error = ValidatePosition(Position)
    if (not valid) then
      ReplyError(msg, error)
      return
    end

    RealityDbAdmin:exec(string.format([[
        UPDATE Entities
        SET LastUpdated = %d, Position = '%s'
        WHERE Id = '%s'
      ]],
      msg.Timestamp,
      json.encode(Position),
      entityId
    ))

    local result = {
      [entityId] = {
        Position = Position,
      }
    }

    Send({
      Target = msg.From,
      Tags = {
        MsgRef = msg.Id,
        Result = "OK",
      },
      Data = json.encode(result),
    })
  end
)

Handlers.add(
  "Reality.EntityHide",
  Handlers.utils.hasMatchingTag("Action", "Reality.EntityHide"),
  function(msg)
    print("Reality.EntityHide")
    local entityId = msg.Tags['EntityId'] or msg.From

    local dbEntry = RealityDbAdmin:exec(string.format([[
        SELECT * FROM Entities WHERE Id = '%s'
      ]],
      entityId
    ))[1]
    if (not dbEntry) then
      ReplyError(msg, "Entity not found")
      return
    end

    SetStateCode(msg.Timestamp, entityId, 0)

    Send({
      Target = msg.From,
      Tags = {
        MsgRef = msg.Id,
        Result = "OK",
      },
    })
  end
)

Handlers.add(
  "Reality.EntityFix",
  Handlers.utils.hasMatchingTag("Action", "Reality.EntityFix"),
  function(msg)
    print("Reality.EntityFix")
    local entityId = msg.Tags['EntityId'] or msg.From

    local dbEntry = RealityDbAdmin:exec(string.format([[
        SELECT * FROM Entities WHERE Id = '%s'
      ]],
      entityId
    ))[1]
    if (not dbEntry) then
      ReplyError(msg, "Entity not found")
      return
    end

    SetStateCode(msg.Timestamp, entityId, 1)

    Send({
      Target = msg.From,
      Tags = {
        MsgRef = msg.Id,
        Result = "OK",
      },
    })
  end
)

Handlers.add(
  "UpdateMemebers",
  "Cron",
  function()
    local res = Send({
      Target = BIG_TABLE,
      Action = 'Balances',
    }).receive()
    local balances = json.decode(res.Data)
    for address, balance in pairs(balances) do
      if tonumber(balance) > 0 then
        BIG_TABLE_MEMBERS[address] = true
      else
        BIG_TABLE_MEMBERS[address] = false
      end
    end

    print("Updated members")
  end
)

--#endregion

return "Loaded Reality Protocol"
