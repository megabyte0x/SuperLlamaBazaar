ATOMIC_ASSET_STANDARD = [[
        -- Atomic Asset Standard --

local bint = require('.bint')(256)
local json = require('json')

if Name ~= 'AAStandard' then Name = 'AAStandard' end
if Ticker ~= 'ATOMIC' then Ticker = 'ATOMIC' end
if Denomination ~= '1' then Denomination = '1' end
if not Balances then Balances = { [Owner] = '100' } end

local function checkValidAddress(address)
  if not address or type(address) ~= 'string' then
    return false
  end

  return string.match(address, "^[%w%-_]+$") ~= nil and #address == 43
end

local function checkValidAmount(data)
  return (math.type(tonumber(data)) == 'integer' or math.type(tonumber(data)) == 'float') and bint(data) > 0
end

local function decodeMessageData(data)
  local status, decodedData = pcall(json.decode, data)

  if not status or type(decodedData) ~= 'table' then
    return false, nil
  end

  return true, decodedData
end

-- Read process state
Handlers.add('Info', Handlers.utils.hasMatchingTag('Action', 'Info'), function(msg)
  ao.send({
    Target = msg.From,
    Action = 'Read-Success',
    Data = json.encode({
      Name = Name,
      Ticker = Ticker,
      Denomination = Denomination,
      Balances = Balances,
    })
  })
end)

-- Transfer balance to recipient (Data - { Recipient, Quantity })
Handlers.add('Transfer', Handlers.utils.hasMatchingTag('Action', 'Transfer'), function(msg)
  local data = {
    Recipient = msg.Tags.Recipient,
    Quantity = msg.Tags.Quantity
  }
  print("Quantity:" .. data.Quantity)
  print("Message from" .. msg.From)
  if checkValidAddress(data.Recipient) and checkValidAmount(data.Quantity) then
    -- Transfer is valid, calculate balances
    if not Balances[data.Recipient] then
      Balances[data.Recipient] = '0'
    end

    Balances[msg.From] = tostring(bint(Balances[msg.From]) - bint(data.Quantity))
    Balances[data.Recipient] = tostring(bint(Balances[data.Recipient]) + bint(data.Quantity))

    -- If new balance zeroes out then remove it from the table
    if bint(Balances[msg.From]) <= 0 then
      Balances[msg.From] = nil
    end
    if bint(Balances[data.Recipient]) <= 0 then
      Balances[data.Recipient] = nil
    end

    local debitNoticeTags = {
      Status = 'Success',
      Message = 'Balance transferred, debit notice issued',
      Recipient = msg.Tags.Recipient,
      Quantity = msg.Tags.Quantity,
    }

    local creditNoticeTags = {
      Status = 'Success',
      Message = 'Balance transferred, credit notice issued',
      Sender = msg.From,
      Quantity = msg.Tags.Quantity,
    }

    for tagName, tagValue in pairs(msg) do
      if string.sub(tagName, 1, 2) == 'X-' then
        debitNoticeTags[tagName] = tagValue
        creditNoticeTags[tagName] = tagValue
      end
    end

    -- Send a debit notice to the sender
    ao.send({
      Target = msg.From,
      Action = 'Debit-Notice',
      Tags = debitNoticeTags,
      Data = json.encode({
        Recipient = data.Recipient,
        Quantity = tostring(data.Quantity)
      })
    })

    -- Send a credit notice to the recipient
    ao.send({
      Target = data.Recipient,
      Action = 'Credit-Notice',
      Tags = creditNoticeTags,
      Data = json.encode({
        Sender = msg.From,
        Quantity = tostring(data.Quantity)
      })
    })
  end
end)

-- Mint new tokens (Data - { Quantity })
Handlers.add('Mint', Handlers.utils.hasMatchingTag('Action', 'Mint'), function(msg)
  local decodeCheck, data = decodeMessageData(msg.Data)

  if decodeCheck and data then
    -- Check if quantity is present
    if not data.Quantity then
      ao.send({ Target = msg.From, Action = 'Input-Error', Tags = { Status = 'Error', Message = 'Invalid arguments, required { Quantity }' } })
      return
    end

    -- Check if quantity is a valid integer greater than zero
    if not checkValidAmount(data.Quantity) then
      ao.send({ Target = msg.From, Action = 'Validation-Error', Tags = { Status = 'Error', Message = 'Quantity must be an integer greater than zero' } })
      return
    end

    -- Check if owner is sender
    if msg.From ~= Owner then
      ao.send({ Target = msg.From, Action = 'Validation-Error', Tags = { Status = 'Error', Message = 'Only the process owner can mint new tokens' } })
      return
    end

    -- Mint request is valid, add tokens to the pool
    if not Balances[Owner] then
      Balances[Owner] = '0'
    end

    Balances[Owner] = tostring(bint(Balances[Owner]) + bint(data.Quantity))

    ao.send({ Target = msg.From, Action = 'Mint-Success', Tags = { Status = 'Success', Message = 'Tokens minted' } })
  else
    ao.send({
      Target = msg.From,
      Action = 'Input-Error',
      Tags = {
        Status = 'Error',
        Message = string.format('Failed to parse data, received: %s. %s', msg.Data,
          'Data must be an object - { Quantity }')
      }
    })
  end
end)

-- Read balance (Data - { Target })
Handlers.add('Balance', Handlers.utils.hasMatchingTag('Action', 'Balance'), function(msg)
  local decodeCheck, data = decodeMessageData(msg.Data)

  if decodeCheck and data then
    -- Check if target is present
    if not data.Target then
      ao.send({ Target = msg.From, Action = 'Input-Error', Tags = { Status = 'Error', Message = 'Invalid arguments, required { Target }' } })
      return
    end

    -- Check if target is a valid address
    if not checkValidAddress(data.Target) then
      ao.send({ Target = msg.From, Action = 'Validation-Error', Tags = { Status = 'Error', Message = 'Target is not a valid address' } })
      return
    end

    -- Check if target has a balance
    if not Balances[data.Target] then
      ao.send({ Target = msg.From, Action = 'Read-Error', Tags = { Status = 'Error', Message = 'Target does not have a balance' } })
      return
    end

    ao.send({
      Target = msg.From,
      Action = 'Read-Success',
      Tags = { Status = 'Success', Message = 'Balance received' },
      Data =
          Balances[data.Target]
    })
  else
    ao.send({
      Target = msg.From,
      Action = 'Input-Error',
      Tags = {
        Status = 'Error',
        Message = string.format('Failed to parse data, received: %s. %s', msg.Data,
          'Data must be an object - { Target }')
      }
    })
  end
end)

-- Read balances
Handlers.add('Balances', Handlers.utils.hasMatchingTag('Action', 'Balances'),
  function(msg) ao.send({ Target = msg.From, Action = 'Read-Success', Data = json.encode(Balances) }) end)


-- End of Atomic Asset Standard --

    ]]

ATOMIC_ASSETS = ATOMIC_ASSETS or {}


Handlers.add(
  "CreateAA",
  "CreateAA",
  function(msg)
    local title = msg.Tags.Title
    Spawn(ao.env.Module.Id,
      {
        Tags = {
          Authority = ao.authorities[1],
          ["Collection-Id"] = "xdHpifVXXzEIgaF1aKnGSNn1UQm7jjaftxh2-qsEVAg",
          ["Collection-Name"] = "[[AA]]",
          Creator = "uguMyaC1NVryTnp3QnlvojTanGSzsbKIur3YVAZ8fnE",
          Description = "AA Super Llamas",
          Title = title
        },

      }
    )
    local child = Receive({ Action = "Spawned" }).Process

    ATOMIC_ASSETS[child] = title

    print("Atomic Asset: " .. child)

    Send({
      Target = child,
      Action = "Eval",
      Data = ATOMIC_ASSET_STANDARD
    })
  end

)

Handlers.add(
  "AddSuperLlama",
  "AddSuperLlama",
  function(msg)
    local data = msg.Data;
    local child = msg.SuperLlama

    Send({
      Target = child,
      Action = "Eval",
      Data = data
    })
  end
)

Handlers.add(
  "TransferOwnership",
  "TransferOwnership",
  function(msg)
    local child = msg.Child
    local recipient = msg.Recipient

    Send({
      Target = child,
      Action = "Transfer",
      Recipient = recipient,
      Quantity = "100"
    })
  end
)
