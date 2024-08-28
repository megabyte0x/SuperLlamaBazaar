local json = require('json')

-- ProcessId: Wsdc03LL22HNYmFjuOK07GE0h9cWC6uzGhYza-7rdhk

-- Change MUSIC_ALLOWANCE
MUSIC_ALLOWANCE = '32UGDRE6gw_GlKz-CcSfngGjppERFWs4Y2unJfDG-hI'

-- Change CHAT_TARGET to Another World
CHAT_TARGET = 'fNHqW6rghEbFZcn1p7k-vB4rqaGnLsjeyjrkkKxRhLI'

POINTS_TOKEN = "Fb4oxhQ_KSDrSHfRsTwXOYUiCOC83qYZdaw8ubaIAG8"
POINTS_TOKEN_DENOMINATION = 1000000000000
REQUIRED_AMOUNT = 10

MUSIC = {
    Skyfall = {
        id = 'bsC6CNeAKTqllbDW1gL3P2u7ooOvSsTyHmlwq7Oc7y0'
    },
    VivaLaVida = {
        id = 'bKCIjUaUCUjq0a0llpd5P3dbFOfNrbk2AVAg-bt4VbM'
    },
    Fairytale = {
        id = '9ccU_xsAhpw4j6K26E5qneI8bi62iKVgF-sipOQY6ME'
    },
    FeelingGood = {
        id = 'Z2EGtSXorgDB-R7K0MEp3SSGKkGSZZUJq1ITSjuYHZc'
    },
}

function validateMusicAllowance(sender)
    if sender == MUSIC_ALLOWANCE then
        return true
    end
    return false
end

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
            ['Author-Name'] = 'DJ',
        },
        Data = message
    })
end

function lowBalance(sender)
    Send({
        Target = sender,
        Tags = { Type = 'SchemaExternal' },
        Data = json.encode({
            SetMusic = {
                Target = MUSIC_ALLOWANCE,
                Title = "Set BIG TABLE Music",
                Description = "You don't have allowance to set BIG TABLE Music. Buy from Music Allowance.",
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
            SetMusic = {
                Recipient = ao.id,
                Target = POINTS_TOKEN,
                Quantity = finalAmount,
                Title = "Set BIG TABLE Music",
                Description = "Please select the BIG TABLE Music and pay 10 $PNTS",
                Schema = {
                    Tags = {
                        type = "object",
                        required = {
                            "Recipient",
                            "Action",
                            "X-Music",
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
                            ["X-Music"] = {
                                type = "string",
                                title = "Select Music",
                                enum = { "Skyfall", "VivaLaVida", "Fairytale", "FeelingGood" }
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
            Target = MUSIC_ALLOWANCE,
            Action = 'Balance',
            Data = json.encode({
                Target = sender,
            })
        }).receive()

        local status = res.Status

        if (status == "Success") then
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

        local music = msg.Tags['X-Music']
        local selectedMusic = MUSIC[music]
        local selectedMusicId = selectedMusic.id

        if selectedMusic then
            Send({
                Target = CHAT_TARGET,
                Action = 'UpdateAudio',
                AudioId = selectedMusicId
            })

            sendMessageToChat("Music has been set to " ..
                music .. "! Please refresh your browser and enjoy being a part of BIG TABLE.")
        end
    end
)
