local json = require('json')

SHOP_KEEPER = 'CRZG8-73qdn8Nhxo4tRaDu9bnc40jMQ-CL2ciR1EaLI'
CASHIER = 'aBSSTYd9CppyC5Udqb8GB-z4fCNyaNfXphgKeLNMZMI'
STANDARD_SUPERLLAMA = 'mydYOu9rRkK61bc0tU_mMlIurqoaP_erSQL-sNBdkFI'
PRICE_FEED_SUPERLLAMA = '3Q28ws1uvhw8GpDOLup9aICIEc4G2BO9Un3nKiEHgzs'
BIG_TABBLE = 'fNHqW6rghEbFZcn1p7k-vB4rqaGnLsjeyjrkkKxRhLI'
GRANTER = 'FnJ0h8LwWmfOh9CN-9gJ1WrdN_FfcDUPW5mZ_TSdIQY'

--#region Model

RealityInfo = {
  Dimensions = 2,
  Name = 'SuperLlamasBazaar',
  ['Render-With'] = '2D-Tile-0',
}

RealityParameters = {
  ['2D-Tile-0'] = {
    Version = 0,
    Spawn = { 4, 44.7 },
    -- This is a tileset themed to Llama Land main island
    Tileset = {
      Type = 'Fixed',
      Format = 'PNG',
      TxId = 'udHA6io6aeSzGONVKR1llb1vttnVSstqV7mhuV1jDXw', -- TxId of the tileset in PNG format
    },
    -- This is a tilemap of sample small island
    Tilemap = {
      Type = 'Fixed',
      Format = 'TMJ',
      TxId = 'OqcUGl4ODdvRqdtNP__JackaeKBsa1hDspdHNfJ6ySk', -- TxId of the tilemap in TMJ format
      -- Since we are already setting the spawn in the middle, we don't need this
      -- Offset = { -10, -10 },
    },
  },
  ['Audio-0'] = {
    Bgm = {
      Type = 'Fixed',
      Format = 'WEBM',
      TxId = 'HxfGWmXJu9WB0ICCFEtvkpbFxDiJwXWV6P9dABJiOQA',
    }
  }
}

RealityEntitiesStatic = {
  -- Change the Shopkeeper Process ID
  [SHOP_KEEPER] = {
    Position = { 68, 25 },
    Type = 'Avatar',
    Metadata = {
      DisplayName = 'Shopkeeper',
      SkinNumber = 3,
      Interaction = {
        Type = 'SchemaForm',
        Id = 'BuySuperLlamas'
      },
    },
  },

  -- Change the Granter Process ID
  [GRANTER] = {
    Position = { 24, 25 },
    Type = 'Avatar',
    Metadata = {
      DisplayName = 'Points Granter',
      SkinNumber = 3,
      Interaction = {
        Type = 'SchemaForm',
        Id = 'GetPoints'
      },
    },
  },

  -- Change the Cashier Process ID
  [CASHIER] = {
    Position = { 46, 71 },
    Type = 'Avatar',
    Metadata = {
      DisplayName = 'Cashier',
      SkinNumber = 3,
      Interaction = {
        Type = 'SchemaExternalForm',
        Id = 'PayPoints'
      },
    },
  },

  -- Change the Standard SuperLlama Process ID
  [STANDARD_SUPERLLAMA] = {
    Position = { 78, 71 },
    Type = 'Avatar',
    Metadata = {
      DisplayName = 'Standard SuperLlama',
      SkinNumber = 3,
      Interaction = {
        Type = 'SchemaExternalForm',
        Id = 'GetData'
      },
    },
  },

  -- Change the Price SuperLlama Process ID
  [PRICE_FEED_SUPERLLAMA] = {
    Position = { 19, 71 },
    Type = 'Avatar',
    Metadata = {
      DisplayName = 'PriceFeed SuperLlama',
      SkinNumber = 3,
      Interaction = {
        Type = 'SchemaForm',
        Id = 'PriceFeed'
      },
    },
  },

  -- Change the Big Table Process ID
  [BIG_TABBLE] = {
    Position = { 95, 46 },
    Type = 'Unknown',
    Metadata = {
      DisplayName = 'Big Table',
      Interaction = {
        Type = 'Warp',
        Size = { 11, 21 },
      },
    },
  }
}

--#endregion

--#write handlers
Handlers.add(
  'Reality.UpdateParameters',
  'UpdateAudio',
  function(msg)
    local audioId = msg.AudioId

    RealityParameters['Audio-0'].Bgm.TxId = audioId

    print('Updated audio to ' .. audioId)

    Handlers.utils.reply(json.encode({
      Success = true,
      Message = 'Updated audio to ' .. audioId
    }))(msg)
  end
)


return print("Loaded Reality Template")
