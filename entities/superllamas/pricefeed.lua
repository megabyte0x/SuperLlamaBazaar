-- Name: Price SuperLlama

local json = require('json')

-- ProcessId:g2fL3WWoeI1O9ztlerAlokd9_gh2DKERQ-UfNnt7eLU

CHAT_TARGET = 'A26mL0TpW9EwhhQM4JsarWeodv7PVzeisDcZw0Pg5Sw'
CASHIER = 'dB7rf5Tmy0QNecKT3xl10SkLrPlKVmpXqV74bRjfTyw'

_0RBIT = "BaMK1dfayo75s3q1ow6AO64UDpD9SEFbeE8xYrY2fyQ"
_0RBT_POINTS_PROCESS = "BUhZLMwQ6yZHguLtJYA5lLUa9LQzLXMXRfaq9FVcPJc"
FEE_AMOUNT = "1000000000000" -- 1 $0RBT


function checkBalance(account)
    if Balances[account] then
        if tonumber(Balances[account]) > 0 then
            return true
        else
            return false
        end
    else
        return false
    end
end

function serveRequest(sender)
    local schema = json.encode({
        PriceFeed = {
            Title = "gm gm gm!!!",
            Description =
            "Select the token you want to check.",
            Schema = {
                Tags = {
                    type = "object",
                    required = {
                        "Token",
                        "Action"
                    },
                    properties = {
                        Token = {
                            title = "Select Token",
                            type = "string",
                            enum = { "AR", "Bitcoin", "ETH" }
                        },
                        Action = {
                            type = "string",
                            const = "CheckPrice"
                        }
                    }
                }
            }
        }
    })

    Send({
        Target = sender,
        Tags = {
            Type = 'Schema'
        },
        Data = schema
    })
end

function noOwnershipSchema(target)
    local schema = json.encode({
        PriceFeed = {
            Title = "gm!",
            Description =
            "You don't have ANY Ownership. Please get it from Shopkeeper.",
            Schema = nil
        }
    })
    Send({
        Target = target,
        Tags = {
            Type = 'Schema'
        },
        Data = schema
    })
end

function sendMessageToChat(message)
    Send({
        Target = CHAT_TARGET,
        Tags = {
            Action = 'ChatMessage',
            ['Author-Name'] = 'Price SuperLlama',
        },
        Data = message
    })
end

function requestPrice(token, baseURL)
    local ticker;

    if (token == "AR") then
        ticker = "arweave"
    elseif (token == "Bitcoin") then
        ticker = "bitcoin"
    elseif (token == "ETH") then
        ticker = "ethereum"
    end

    local finalURL = baseURL .. "?ids=" .. ticker .. "&vs_currencies=usd"

    Send({
        Target = _0RBT_POINTS_PROCESS,
        Action = "Transfer",
        Recipient = _0RBIT,
        Quantity = FEE_AMOUNT,
        ["X-Url"] = finalURL,
        ["X-Action"] = "Get-Real-Data"
    })
end

function receiveData(msg)
    local res = json.decode(msg.Data)
    for k, v in pairs(res) do
        if (k == "arweave") then
            sendMessageToChat("AR price: $" .. v.usd)
        elseif (k == "bitcoin") then
            sendMessageToChat("Bitcoin price: $" .. v.usd)
        elseif (k == "ethereum") then
            sendMessageToChat("ETH price: $" .. v.usd)
        end
    end
end

Handlers.add(
    'Schema',
    Handlers.utils.hasMatchingTag('Action', 'Schema'),
    function(msg)
        local sender = msg.From
        if (checkBalance(sender)) then
            serveRequest(sender)
        else
            noOwnershipSchema(sender)
        end
    end
)

Handlers.add(
    "CheckPrice",
    "CheckPrice",
    function(msg)
        local baseURL = "https://api.coingecko.com/api/v3/simple/price"
        local token = msg.Token
        requestPrice(token, baseURL)
    end
)



Handlers.add(
    "ReceiveData",
    Handlers.utils.hasMatchingTag("Action", "Receive-Response"),
    receiveData
)
