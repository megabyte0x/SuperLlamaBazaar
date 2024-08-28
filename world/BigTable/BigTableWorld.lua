local json = require('json')
--#region Model

RealityInfo = {
  Dimensions = 2,
  Name = 'ExampleReality',
  ['Render-With'] = '2D-Tile-0',
}

-- Change this to the process id of your entity.
BIG_TABBLE_GUY = 'K6Ibj9ELAV0DF6AH-GXTtqCpmttmiRp-hZj2R1E1xZA'
DJ = 'Wsdc03LL22HNYmFjuOK07GE0h9cWC6uzGhYza-7rdhk'
MUSIC_ALLOWANCE_REGISTRY = 'uvAJIfSMKCRgQ4q5jvquxLfHlXCBuYmdDbTTf6chNW4'
SUPER_LLAMA_BAZAAR = 'R4hLJ50NtQlheNFyEM6IvjwsIEi4-Ty8psSXlXfJSx0'

RealityParameters = {
  ['2D-Tile-0'] = {
    Version = 0,
    Spawn = { 5, 7 },
    -- This is a tileset themed to Llama Land main island
    Tileset = {
      Type = 'Fixed',
      Format = 'PNG',
      TxId = 'qdLI84XucwyOMdEztBXaSqXAza3RKHKt4a5bHX2PR9U', -- TxId of the tileset in PNG format
    },
    -- This is a tilemap of sample small island
    Tilemap = {
      Type = 'Fixed',
      Format = 'TMJ',
      TxId = 'LrVq-wpPwaaxqFfd_9uOPWHFIr4fHUAjLeG6MkhirO4', -- TxId of the tilemap in TMJ format
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
  [DJ] = {
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
  [MUSIC_ALLOWANCE_REGISTRY] = {
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
  -- Change the Big Table Process ID
  [SUPER_LLAMA_BAZAAR] = {
    Position = { 0, 9 },
    Type = 'Unknown',
    Metadata = {
      DisplayName = 'SuperLlama Bazaar',
      Interaction = {
        Type = 'Warp',
        Size = { 2, 5 },
      },
    },
  }
}


RealityParameters_Outsiders = {
  ['2D-Tile-0'] = {
    Version = 0,
    Spawn = { 5, 7 },
    -- This is a tileset themed to Llama Land main island
    Tileset = {
      Type = 'Fixed',
      Format = 'PNG',
      TxId = 'qdLI84XucwyOMdEztBXaSqXAza3RKHKt4a5bHX2PR9U', -- TxId of the tileset in PNG format
    },
    -- This is a tilemap of sample small island
    Tilemap = {
      Type = 'Fixed',
      Format = 'TMJ',
      TxId = 'l0LdYE-C4qOEC3soiLIj_NBvlVXm2b6AixV0ZzjAf6w', -- TxId of the tilemap in TMJ format
      -- Since we are already setting the spawn in the middle, we don't need this
      -- Offset = { -10, -10 },
    },
  }
}

RealityEntitiesStatic_Outsiders = {
  [BIG_TABBLE_GUY] = {
    Position = { 9.5, 9 },
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
  -- Change the Big Table Process ID
  [SUPER_LLAMA_BAZAAR] = {
    Position = { 1, 9 },
    Type = 'Unknown',
    Metadata = {
      DisplayName = 'SuperLlama Bazaar',
      Interaction = {
        Type = 'Warp',
        Size = { 2, 9 },
      },
    },
  },
  [ao.id] = {
    Position = { 18, 8 },
    Type = 'Unknown',
    Metadata = {
      DisplayName = 'Big Table',
      Interaction = {
        Type = 'Warp',
        Size = { 2, 6 },
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
