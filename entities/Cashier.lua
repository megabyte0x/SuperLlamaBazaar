local json = require('json')

CHAT_TARGET = 'R4hLJ50NtQlheNFyEM6IvjwsIEi4-Ty8psSXlXfJSx0'
POINTS_TOKEN = "Fb4oxhQ_KSDrSHfRsTwXOYUiCOC83qYZdaw8ubaIAG8"
POINTS_TOKEN_DENOMINATION = 1000000000000
GRANTER = 'FnJ0h8LwWmfOh9CN-9gJ1WrdN_FfcDUPW5mZ_TSdIQY'

BUY_REQUESTS = BUY_REQUESTS or {}
SUPER_LLAMAS = {
    Standard = {
        id = 'mydYOu9rRkK61bc0tU_mMlIurqoaP_erSQL-sNBdkFI',
        price = 5
    },
    PriceFeed = {
        id = '3Q28ws1uvhw8GpDOLup9aICIEc4G2BO9Un3nKiEHgzs',
        price = 10
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
    BUY_REQUESTS[sender] = '0'
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
                Description = "Please pay " .. amount .. " $PNTS to buy the SuperLlama.",
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
                Description = "You don't have " .. amount .. " $PNTS to buy the SuperLlama. Request $PNTS Granter!",
                Schema = nil
            }
        })
    })

    Send({
        Target = GRANTER,
        Action = "Announce"
    })
end

function noRequestExists(sender)
    Send({
        Target = sender,
        Tags = { Type = 'SchemaExternal' },
        Data = json.encode({
            PayPoints = {
                Target = sender,
                Title = "Buy SuperLlamas",
                Description = "Please visit Shopkeeper first.",
                Schema = nil
            }
        })
    })
end

function transferOwnership(recipient, selectedLlama)
    Send({
        Target = selectedLlama,
        Action = "Transfer",
        Recipient = recipient,
        Quantity = "1"
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
    'PNTS Credit',
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
                        transferOwnership(sender, value.id)
                        sendMessageToChat("Thank you for the payment. You have successfully bought the SuperLlama.")
                        completeRequest(sender)
                    else
                        sendMessageToChat("The amount you sent is not correct. Please send " .. value.price .. " $PNTS.")
                    end
                end
            end
        end
    end
)

Handlers.add(
    'SchemaExternal',
    'SchemaExternal',
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

        if BUY_REQUESTS[sender] and BUY_REQUESTS[sender] ~= '0' then
            print("In if condition")
            local selectedBot = BUY_REQUESTS[sender]
            local price = SUPER_LLAMAS[selectedBot].price
            if (balance >= (price * POINTS_TOKEN_DENOMINATION)) then
                payPoints(sender, selectedBot, price)
            else
                lowBalance(sender, selectedBot, price)
            end
        else
            print("In else condition")
            noRequestExists(sender)
        end
    end
)
