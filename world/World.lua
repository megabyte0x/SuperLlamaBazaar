--#region Model

RealityInfo = {
  Dimensions = 2,
  Name = 'ExampleReality',
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
}


-- for LLAMAJSONONCLICK.lua
RealityEntitiesStatic = {
  ['nQTO3xDx8sjD67QAgN6AP7rf8j-aoTK17emhx-bJo1g'] = {
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
  ['mp1oSeaErtDKfNbAHPQW9ZPiXubCiuCiTaSpUASmTrY'] = {
    Position = { 9, 8 },
    Type = 'Avatar',
    Metadata = {
      DisplayName = 'AAShopkeeper',
      SkinNumber = 3,
      Interaction = {
        Type = 'SchemaForm',
        Id = 'BuySuperLlamas'
      },
    },
  },
  ['dB7rf5Tmy0QNecKT3xl10SkLrPlKVmpXqV74bRjfTyw'] = {
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
  }
}


--#endregion

return print("Loaded Reality Template")
