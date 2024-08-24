local json = require('json')

CHAT_TARGET = 'A26mL0TpW9EwhhQM4JsarWeodv7PVzeisDcZw0Pg5Sw'
POINTS_TOKEN = "Fb4oxhQ_KSDrSHfRsTwXOYUiCOC83qYZdaw8ubaIAG8"
POINTS_TOKEN_DENOMINATION = 1000000000000

LLAMA_TOKEN = "pazXumQI-HPH7iFGfTC-4_7biSnqz_U67oFAGry5zUY"

BUY_REQUESTS = BUY_REQUESTS or {}
SUPER_LLAMAS = {
    PriceFeed = {
        id = '',
        price = 10
    },
    WeatherData = {
        id = '',
        price = 20
    }
}


function sendMessageToChat(message)
    Send({
        Target = CHAT_TARGET,
        Tags = {
            Action = 'ChatMessage',
            ['Author-Name'] = 'Cashier',
        },
        Data = message
    })
end

function validateLlamaToken(token)
    if token == POINTS_TOKEN then
        return true
    end
    return false
end

function completeRequest(sender)
    BUY_REQUESTS[sender] = nil
end

function validateTokenBalanceResponse(sender, ticker)
    return validateLlamaToken(sender) and ticker == "PNTS"
end

function payPoints(sender, superLlama, amount)
    local finalAmount = amount * POINTS_TOKEN_DENOMINATION
    Send({
        Target = sender,
        Tags = { Type = 'SchemaExternal' },
        Data = json.encode({
            PayPoints = {
                Target = POINTS_TOKEN,
                Quantity = finalAmount,
                Recipient = ao.id,
                Title = "Pay for " .. superLlama .. " SuperLlama",
                Description = "Please pay " .. amount .. " $LLAMA to buy the SuperLlama.",
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

function lowBalance(sender, superLlama, amount)
    Send({
        Target = sender,
        Tags = { Type = 'SchemaExternal' },
        Data = json.encode({
            PayPoints = {
                Target = POINTS_TOKEN,
                Title = "Pay for " .. superLlama .. " SuperLlama",
                Description = "You don't have " .. amount .. " $LLAMA to buy the SuperLlama.",
                Schema = nil
            }
        })
    })
end

Handlers.add(
    'Buy SuperLlama',
    'Buy',
    function(msg)
        local selectedBot = msg.SelectedBot
        local sender = msg.Recipient
        BUY_REQUESTS[sender] = selectedBot
        sendMessageToChat("Looking to buy " .. selectedBot .. " SuperLlama? Come meet me.")
    end
)

Handlers.add(
    'LLAMA Credit',
    'Credit-Notice',
    function(msg)
        local from = msg.From

        if not validateLlamaToken(from) then
            msg.reply({ Data = "Please don't send me fake tokens." })
            print("Invalid token received.")
            return
        end

        local sender = msg.Sender
        local amount = tonumber(msg.Quantity)

        if BUY_REQUESTS[sender] then
            local selectedBot = BUY_REQUESTS[sender]
            for key, value in pairs(SUPER_LLAMAS) do
                if key == selectedBot then
                    if amount >= (value.price * POINTS_TOKEN_DENOMINATION) then
                        sendMessageToChat("Thank you for the payment. You have successfully bought the SuperLlama.")
                        completeRequest(sender)
                    else
                        sendMessageToChat("The amount you sent is not correct. Please send " .. value.price .. " $LLAMA.")
                    end
                end
            end
        end
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
        return validateTokenBalanceResponse(msg.From, msg.Tags.Ticker)
    end,
    function(msg)
        local sender = msg.Tags.Account
        local balance = tonumber(msg.Tags.Balance)

        if BUY_REQUESTS[sender] then
            local selectedBot = BUY_REQUESTS[sender]
            for key, value in pairs(SUPER_LLAMAS) do
                if key == selectedBot then
                    if (balance >= (value.price * POINTS_TOKEN_DENOMINATION)) then
                        payPoints(sender, selectedBot, value.price)
                    else
                        lowBalance(sender, selectedBot, value.price)
                    end
                end
            end
        end
    end
)
