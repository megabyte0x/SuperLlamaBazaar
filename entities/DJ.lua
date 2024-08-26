local json = require('json')

-- ProcessId: 2D08rRT0bcstnBZnZFZMXJbYB7Bgm_8n_JtZ6jos5d0

CHAT_TARGET = 'A26mL0TpW9EwhhQM4JsarWeodv7PVzeisDcZw0Pg5Sw'
MUSIC_ALLOWANCE = 'soTvSG4rCfZIUq5G43REP0CaGebjbiaRB7Dv2wrX5dY'

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
    Send({
        Target = sender,
        Tags = { Type = 'Schema' },
        Data = json.encode({
            SetMusic = {
                Recipient = ao.id,
                Title = "Set BIG TABLE Music",
                Description = "Please select the BIG TABLE Music.",
                Schema = {
                    Tags = {
                        type = "object",
                        required = {
                            "Recipient",
                            "Action",
                            "Music"
                        },
                        properties = {
                            Recipient = {
                                type = "string",
                                const = ao.id
                            },
                            Action = {
                                type = "string",
                                const = "SetMusic"
                            },
                            Music = {
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
    Handlers.utils.hasMatchingTag('Action', 'Schema'),
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
    'SetMusic',
    Handlers.utils.hasMatchingTag('Action', 'SetMusic'),
    function(msg)
        local selectedMusic = MUSIC[msg.Music]
        local selectedMusicId = selectedMusic.id

        if selectedMusic then
            Send({
                Target = CHAT_TARGET,
                Action = 'UpdateAudio',
                AudioId = selectedMusicId
            })

            sendMessageToChat("BIG TABLE Music has been set to " .. msg.Music)
        end
    end
)
