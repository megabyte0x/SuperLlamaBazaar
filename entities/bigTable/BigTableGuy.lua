local json = require('json')

-- ProcessId: QI_YZ5ff5RYgzkkB9SsF76zpy3ZHYzroyAY-pdEDuTo

-- Change this to the Chat Target for Big Table World
CHAT_TARGET = 'TX1wMBfIQtUm_pvlovUjeGTGXyRBUyvzloSsODKisZ4'
-- Change this to the Atomic Asset used for Token Gating.
BIG_TABLE = 'XPj6VGx6iKUSTdm9XKqp3JQ4HpjvXX7kHYW3D_PxqtU'
POINTS_TOKEN = "Fb4oxhQ_KSDrSHfRsTwXOYUiCOC83qYZdaw8ubaIAG8"
POINTS_TOKEN_DENOMINATION = 1000000000000
REQUIRED_AMOUNT = 50


function validatePointsToken(token)
    if token == POINTS_TOKEN then
        return true
    end
    return false
end

function transferOwnership(buyer)
    Send({
        Target = BIG_TABLE,
        Action = "Transfer",
        Recipient = buyer,
        Quantity = "1"
    })
end

function sendMessageToChat(message)
    Send({
        Target = CHAT_TARGET,
        Tags = {
            Action = 'ChatMessage',
            ['Author-Name'] = 'Big Table Guy',
        },
        Data = message
    })
end

function lowBalance(sender)
    Send({
        Target = sender,
        Tags = { Type = 'SchemaExternal' },
        Data = json.encode({
            BuySeat = {
                Target = BIG_TABLE,
                Title = "Buy BIG TABLE Seat.",
                Description = "You don't have enough $PNTS to buy seat at Big Table.",
                Schema = nil
            }
        })
    })
end

function serveSchema(sender)
    local finalAmount = tostring(REQUIRED_AMOUNT * POINTS_TOKEN_DENOMINATION)
    Send({
        Target = sender,
        Tags = { Type = 'SchemaExternal' },
        Data = json.encode({
            BuySeat = {
                Recipient = ao.id,
                Target = POINTS_TOKEN,
                Quantity = finalAmount,
                Title = "Buy BIG TABLE Seat.",
                Description = "Please pay 50 $PNTS to buy seat at Big Table.",
                Schema = {
                    Tags = {
                        type = "object",
                        required = {
                            "Recipient",
                            "Action",
                            "X-Buyer",
                            "Quantity"
                        },
                        properties = {
                            Recipient = {
                                type = "string",
                                const = ao.id
                            },
                            Quantity = {
                                type = "string",
                                const = finalAmount
                            },
                            Action = {
                                type = "string",
                                const = "Transfer"
                            },
                            ["X-Buyer"] = {
                                type = "string",
                                const = sender
                            }
                        }
                    }
                }
            }
        })
    })
end

Handlers.add(
    'Schema',
    Handlers.utils.hasMatchingTag('Action', 'SchemaExternal'),
    function(msg)
        local sender = msg.From
        local res = Send({
            Target = POINTS_TOKEN,
            Tags = {
                Action = 'Balance',
                Recipient = sender,
            },
        }).receive()

        local balance = tonumber(res.Tags.Balance)

        if (balance >= (REQUIRED_AMOUNT * POINTS_TOKEN_DENOMINATION)) then
            serveSchema(sender)
        else
            lowBalance(sender)
        end
    end
)


Handlers.add(
    'PNTS-Credit',
    'Credit-Notice',
    function(msg)
        if not validatePointsToken(msg.From) then
            msg.reply({ Data = "Please don't send me fake tokens." })
            print("Invalid token received.")
            return
        end

        local buyer = msg.Tags['X-Buyer']

        transferOwnership(buyer)


        sendMessageToChat("You are now the part of BIG TABLE!")
    end
)
