local json = require('json')

-- Change Both
CHAT_TARGET = 'A26mL0TpW9EwhhQM4JsarWeodv7PVzeisDcZw0Pg5Sw'
CASHIER = 'dB7rf5Tmy0QNecKT3xl10SkLrPlKVmpXqV74bRjfTyw'

schema = json.encode({
    BuySuperLlamas = {
        Title = "gm gm gm!!!",
        Description =
        "Select the Super Llama you want to buy.",
        Schema = {
            Tags = {
                type = "object",
                required = {
                    "Bots",
                    "Action"
                },
                properties = {
                    Bots = {
                        title = "Select SuperLlama",
                        type = "string",
                        enum = { "Standard", "PriceFeed" }
                    },
                    Action = {
                        type = "string",
                        const = "BuySuperLlama"
                    }
                }
            }
        }
    }
})

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

Handlers.add('Schema', Handlers.utils.hasMatchingTag('Action', 'Schema'),
    function(msg)
        Send({
            Target = msg.From,
            Tags = {
                Type = 'Schema'
            },
            Data = schema
        })
    end)

Handlers.add('Buy SuperLlama',
    Handlers.utils.hasMatchingTag('Action', 'BuySuperLlama'),
    function(msg)
        local selectedLlama = msg.Bots

        sendMessageToChat("Please visit CASHIER.")

        Send({
            Target = CASHIER,
            Recipient = msg.From,
            SelectedBot = selectedLlama,
            Action = 'Buy'
        })
    end
)
