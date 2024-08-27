local json = require('json')
--#region Model

RealityInfo = {
  Dimensions = 2,
  Name = 'ExampleReality',
  ['Render-With'] = '2D-Tile-0',
}

-- Change this to the process id of your entity.
BIG_TABBLE_GUY = 'K6Ibj9ELAV0DF6AH-GXTtqCpmttmiRp-hZj2R1E1xZA'

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


-- for LLAMAJSONONCLICK.lua
RealityEntitiesStatic = {
  ['Wsdc03LL22HNYmFjuOK07GE0h9cWC6uzGhYza-7rdhk'] = {
    Position = { 8, 5 },
    Type = 'Avatar',
    Metadata = {
      DisplayName = 'DJ',
      SkinNumber = 3,
      Interaction = {
        Type = 'SchemaExternalForm',
        Id = 'SetMusic'
      },
    },
  },
  ['uvAJIfSMKCRgQ4q5jvquxLfHlXCBuYmdDbTTf6chNW4'] = {
    Position = { 10, 10 },
    Type = 'Avatar',
    Metadata = {
      DisplayName = 'Music Allowance Registry',
      SkinNumber = 3,
      Interaction = {
        Type = 'SchemaExternalForm',
        Id = 'BuyMusicAllowance'
      },
    },
  },
}


RealityParameters_Outsiders = {
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
  }
}

RealityEntitiesStatic_Outsiders = {
  [BIG_TABBLE_GUY] = {
    Position = { 10, 10 },
    Type = 'Avatar',
    Metadata = {
      DisplayName = 'Big Table Guy',
      SkinNumber = 3,
      Interaction = {
        Type = 'SchemaExternalForm',
        Id = 'BuySeat'
      },
    },
  },
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
