local json = require('json')

-- ProcessId: r5XP4avaIC4VVtf3Hv4K9ezNyVZTy0ayhGRjlI2g660

CHAT_TARGET = 'fNHqW6rghEbFZcn1p7k-vB4rqaGnLsjeyjrkkKxRhLI'
POINTS_TOKEN = "Fb4oxhQ_KSDrSHfRsTwXOYUiCOC83qYZdaw8ubaIAG8"
POINTS_TOKEN_DENOMINATION = 1000000000000
REQUIRED_AMOUNT = 10
-- Change the Music Allowance Process Id
MUSIC_ALLOWANCE = "32UGDRE6gw_GlKz-CcSfngGjppERFWs4Y2unJfDG-hI"


function validatePointsToken(token)
    if token == POINTS_TOKEN then
        return true
    end
    return false
end

function sendMessageToChat(message)
    Send({
        Target = CHAT_TARGET,
        Tags = {
            Action = 'ChatMessage',
            ['Author-Name'] = 'Music Allowance',
        },
        Data = message
    })
end

function lowBalance(sender)
    Send({
        Target = sender,
        Tags = { Type = 'SchemaExternal' },
        Data = json.encode({
            BuyMusicAllowance = {
                Target = POINTS_TOKEN,
                Title = "Buy BIG TABLE Music",
                Description = "You don't have enough $PNTS to buy BIG TABLE Music.",
                Schema = nil
            }
        })
    })
end

function transferOwnership(recipient)
    Send({
        Target = MUSIC_ALLOWANCE,
        Action = "Transfer",
        Recipient = recipient,
        Quantity = "1"
    })
end

function payPoints(sender)
    local finalAmount = REQUIRED_AMOUNT * POINTS_TOKEN_DENOMINATION
    Send({
        Target = sender,
        Tags = { Type = 'SchemaExternal' },
        Data = json.encode({
            BuyMusicAllowance = {
                Target = POINTS_TOKEN,
                Quantity = finalAmount,
                Recipient = ao.id,
                Title = "Buy BIG TABLE Music",
                Description = "Please pay 10 $PNTS to buy BIG TABLE Music.",
                Schema = {
                    Tags = {
                        type = "object",
                        required = {
                            "Quantity",
                            "Recipient",
                            "Action"
                        },
                        properties = {
                            Quantity = {
                                type = "string",
                                const = tostring(finalAmount)
                            },
                            Recipient = {
                                type = "string",
                                const = ao.id
                            },
                            Action = {
                                type = "string",
                                const = "Transfer"
                            }
                        }
                    }
                }
            }
        })
    })
end

Handlers.add(
    'PNTS-Credit',
    'Credit-Notice',
    function(msg)
        local sender = msg.Sender

        if not validatePointsToken(msg.From) then
            print("Invalid token received.")
            return
        end

        Send({
            Target = MUSIC_ALLOWANCE,
            Action = "Transfer",
            Recipient = sender,
            Quantity = "1"
        })
        sendMessageToChat("Thank you for the payment. You have successfully bought the Music Allowance.")
    end
)

Handlers.add(
    'SchemaExternal',
    Handlers.utils.hasMatchingTag('Action', 'SchemaExternal'),
    function(msg)
        Send({
            Target = POINTS_TOKEN,
            Tags = {
                Action = 'Balance',
                Recipient = msg.From,
            },
        })
    end
)

Handlers.add(
    'TokenBalanceResponse',
    function(msg)
        return validatePointsToken(msg.From)
    end,
    function(msg)
        local sender = msg.Tags.Account
        local balance = tonumber(msg.Tags.Balance)

        if (balance >= (REQUIRED_AMOUNT * POINTS_TOKEN_DENOMINATION)) then
            payPoints(sender)
        else
            lowBalance(sender)
        end
    end
)
