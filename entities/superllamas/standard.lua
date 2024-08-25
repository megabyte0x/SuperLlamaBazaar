-- Name= "StandardSuperLlama"


local json = require('json')

-- Configure this to the process ID of the world you want to send chat messages to
CHAT_TARGET = 'A26mL0TpW9EwhhQM4JsarWeodv7PVzeisDcZw0Pg5Sw'

_0RBIT = "BaMK1dfayo75s3q1ow6AO64UDpD9SEFbeE8xYrY2fyQ"
_0RBT_TOKEN_PROCESS = "BUhZLMwQ6yZHguLtJYA5lLUa9LQzLXMXRfaq9FVcPJc"

ReceivedData = ReceivedData or {}

function Validate0rbtQuantity(quantity)
    return quantity == 1000000000000
end

function ValidateJsonResource(resource)
    return resource ~= nil and type(resource) == 'string'
end

function serveRequest(account)
    Send({
        Target = account,
        Tags = { Type = 'SchemaExternal' },
        Data = json.encode({
            GetData = {
                Target = _0RBT_TOKEN_PROCESS,
                Title = "Wanna know secrets?",
                Description =
                "Explore what you can know",
                Schema = {
                    Tags = {
                        type = "object",
                        required = {
                            "Quantity",
                            "Recipient",
                            "Action",
                            "X-UrlToSend"
                        },
                        properties = {
                            Quantity = {
                                type = "string",
                                const = "1000000000000"
                            },
                            Recipient = {
                                type = "string",
                                const = ao.id
                            },
                            Action = {
                                type = "string",
                                const = "Transfer"
                            },
                            ["X-UrlToSend"] = {
                                type = "string",
                                minLength = 1,
                                maxLength = 150,
                                default = "https://dummyjson.com/products",
                                title = "Url for your request",
                            }
                        }
                    }
                },
            },
        })
    })
end

function rejectRequest(account)
    Send({
        Target = account,
        Tags = { Type = 'SchemaExternal' },
        Data = json.encode({
            GetData = {
                Target = _0RBT_TOKEN_PROCESS,
                Title = "Not enough $0RBT Points!",
                Description = "DM @megabyte0x on Twitter to get a few.",
                Schema = nil,
            },
        })
    })
end

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

function sendMessageToChat(message)
    Send({
        Target = CHAT_TARGET,
        Tags = {
            Action = 'ChatMessage',
            ['Author-Name'] = 'Shopkeeper',
        },
        Data = message
    })
end

function noOwnershipSchema(target)
    local schema = json.encode({
        GetData = {
            Title = "gm!",
            Description =
            "You don't have ANY Ownership. Please get it from Shopkeeper.",
            Schema = nil
        }
    })
    Send({
        Target = target,
        Tags = {
            Type = 'SchemaExternal'
        },
        Data = schema
    })
end

Handlers.add(
    "CreditNoticeHandler",
    Handlers.utils.hasMatchingTag("Action", "Credit-Notice"),
    function(msg)
        if msg.From ~= _0RBT_TOKEN_PROCESS then
            return print("Credit Notice not from $0RBT")
        end

        local quantity = tonumber(msg.Tags.Quantity)
        if not Validate0rbtQuantity(quantity) then
            return print("Invalid quantity")
        end

        local url = "https://dummyjson.com/products"

        Send({
            Target = _0RBT_TOKEN_PROCESS,
            Action = 'Transfer',
            Recipient = _0RBIT,
            Quantity = msg.Tags.Quantity,
            ["X-Url"] = msg.Tags['X-UrlToSend'],
            ["X-Action"] = "Get-Real-Data"
        })
    end
)

Handlers.add(
    "Receive-Data",
    Handlers.utils.hasMatchingTag("Action", "Receive-Response"),
    function(msg)
        local res = json.decode(msg.Data)
        local constrainedString = string.sub(json.encode(res), 1, 40)
        ReceivedData = res
        print(Colors.green .. "You have received the data from the 0rbit process.")
        -- Write in Chat
        sendMessageToChat("Dtat is:" .. constrainedString)

        print("Dtat is:" .. constrainedString)
    end
)


Handlers.add(
    'TokenBalanceResponse',
    function(msg)
        local fromToken = msg.From == _0RBT_TOKEN_PROCESS
        local hasBalance = msg.Tags.Balance ~= nil
        return fromToken and hasBalance
    end,
    function(msg)
        local account = msg.Tags.Account
        local balance = msg.Tags.Balance
        print('Account: ' .. account .. ', Balance: ' .. balance)
        if (checkBalance(account)) then
            if (balance >= "1000000000000") then
                serveRequest(account)
            else
                rejectRequest(account)
            end
        else
            noOwnershipSchema(account)
        end
    end
)


Handlers.add(
    'SchemaExternal',
    Handlers.utils.hasMatchingTag('Action', 'SchemaExternal'),
    function(msg)
        print('SchemaExternal')
        Send({
            Target = _0RBT_TOKEN_PROCESS,
            Tags = {
                Action = 'Balance',
                Recipient = msg.From,
            },
        })
    end
)
