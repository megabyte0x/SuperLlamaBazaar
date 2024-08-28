BAZAAR_BIG_TABBLE = 'fNHqW6rghEbFZcn1p7k-vB4rqaGnLsjeyjrkkKxRhLI'
BIG_TABLE = 'XPj6VGx6iKUSTdm9XKqp3JQ4HpjvXX7kHYW3D_PxqtU'


Handlers.add(
    'Cron',
    'Cron',
    function(msg)
        local res = Send({
            Target = BIG_TABLE,
            Action = 'Balances'
        }).receive()

        Send({
            Target = BAZAAR_BIG_TABBLE,
            Action = 'UpdateMembers',
            Data = res.Data
        })

        print("Updated Members")
    end
)
