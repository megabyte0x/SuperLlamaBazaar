local json = require('json')

-- Change CHAT TARGET
CHAT_TARGET = 'R4hLJ50NtQlheNFyEM6IvjwsIEi4-Ty8psSXlXfJSx0'
POINTS_TOKEN = "Fb4oxhQ_KSDrSHfRsTwXOYUiCOC83qYZdaw8ubaIAG8"
POINTS_TOKEN_DENOMINATION = 1000000000000

schema = json.encode({
    GetPoints = {
        Title = "gm gm gm!!!",
        Description =
        "Submit your request for $PNTS Grant!",
        Schema = {
            Tags = {
                type = "object",
                required = {
                    "Action"
                },
                properties = {
                    Action = {
                        type = "string",
                        const = "RequestGrant"
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
            ['Author-Name'] = '$PNTS Granter',
        },
        Data = message
    })
end

Handlers.add(
    'Schema',
    'Schema',
    function(msg)
        Send({
            Target = msg.From,
            Tags = {
                Type = 'Schema'
            },
            Data = schema
        })
    end)

Handlers.add(
    'Request Grant',
    'RequestGrant',
    function(msg)
        sendMessageToChat("You request for Grant has been approved!")

        Send({
            Target = POINTS_TOKEN,
            Recipient = msg.From,
            Quantity = tostring(100 * POINTS_TOKEN_DENOMINATION),
            Action = 'Transfer'
        })
    end
)

Handlers.add(
    'Announce',
    'Announce',
    function()
        sendMessageToChat(
            "Looking for $PNTS? Come meet me!"
        )
    end
)
