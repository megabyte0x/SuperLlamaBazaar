local json = require('json')

--#region Model

RealityInfo = {
  Dimensions = 2,
  Name = 'SuperLlamasBazaar',
  ['Render-With'] = '2D-Tile-0',
}

RealityParameters = {
  ['2D-Tile-0'] = {
    Version = 0,
    Spawn = { 5, 7 },
    -- This is a tileset themed to Llama Land main island
    Tileset = {
      Type = 'Fixed',
      Format = 'PNG',
      TxId = 'h5Bo-Th9DWeYytRK156RctbPceREK53eFzwTiKi0pnE', -- TxId of the tileset in PNG format
    },
    -- This is a tilemap of sample small island
    Tilemap = {
      Type = 'Fixed',
      Format = 'TMJ',
      TxId = 'koH7Xcao-lLr1aXKX4mrcovf37OWPlHW76rPQEwCMMA', -- TxId of the tilemap in TMJ format
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
  ['CRZG8-73qdn8Nhxo4tRaDu9bnc40jMQ-CL2ciR1EaLI'] = {
    Position = { 6, 8 },
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

  -- Change the Cashier Process ID
  ['aBSSTYd9CppyC5Udqb8GB-z4fCNyaNfXphgKeLNMZMI'] = {
    Position = { 5, 5 },
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
  ['WGbbS00KcbZTLexYO40UATkfYXvAUWEfetrHzTm93cY'] = {
    Position = { 10, 10 },
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
  ['3Q28ws1uvhw8GpDOLup9aICIEc4G2BO9Un3nKiEHgzs'] = {
    Position = { 9, 8 },
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
  ['TX1wMBfIQtUm_pvlovUjeGTGXyRBUyvzloSsODKisZ4'] = {
    Position = { 14.6, 5.5 },
    Type = 'Unknown',
    Metadata = {
      DisplayName = 'Big Table',
      Interaction = {
        Type = 'Warp',
        Size = { 2, 2 },
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
