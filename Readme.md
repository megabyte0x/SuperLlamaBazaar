# SuperLlamas Bazaar

## How to Create your OWN?

### Deploy the Reality World

1. Run AOS in `world` folder.
2. Save the process Id somewhere for future reference.
3. Load `Reality.lua`, `World.lua`, and `Chat.lua`
    ```lua
    .load Reality.lua
    .load World.lua
    .load Chat.lua
    ```
4. Add this process's ID to https://reality-viewer.arweave.net/ and connect using a temporary wallet.

> Congratulations you've ran **your own world !**

### Add the World Entities

#### Step 1: Add Cashier

1. Run AOS in `entities` folder.
2. Save the process Id somewhere for future reference.
3. Set the `CHAT_TARGET` to your **World Id** you created.
4. Set the `POINTS_TOKEN` and `POINTS_TOKEN_DENOMINATION` to which ever token you are interested to get paid in.
5. Load `Cashier.lua`
   ```lua
   .load Cashier.lua
   ```


#### Step 2: Add Shopkeeper

1. Run AOS in `entities` folder.
2. Save the process Id somewhere for future reference.
3. Set the `CHAT_TARGET` to your **World Id** you created.
4. Set the `CASHIER` to your **Cashier Entitiy** you created.
5. Load `Shopkeeper.lua`
   ```lua
   .load Shopkeeper.lua
   ```

#### Step 3: Add the Entities to your World.

1. Change the Shopkeeper Process Id.
2. Change the Cashier Process Id.
3. Load `World.lua`
   ```lua
   .load World.lua
   ```
4. Refresh your browser.

> Congratulations! You now have two world entities.

### Create Atomic SuperLlamas

This is a like a work around way to create Atomic Assets which can show up on Bazaar. 

#### Step 1: Create a Atomic Asset Spawnning Process
1. Run AOS in the `atomic-assets` folder.
2. Save the process Id somewhere for future reference.
3. Load the `aa-spawn.lua`
   ```lua
   .load aa-spawn.lua
   ```

#### Step 2: Create an Atomic Asset
1. Send a message to the above **Spawnning Process** with the *title* for the Atomic Asset.
   ```lua
   Send({Target = "<AA-Spawn>", Action ="CreateAA", Title = "Check"})
   ```
2. Save the Atomic Process Id for future reference.

#### Step 3: Add SuperLLama Code in Atomic Asset
1. Open your editor in AOS
   ```lua
   .editor
   ```
2. Create a message to the above **Spawnning Process** with the *Atomic Asset Process Id* and *Lua Code*.
   ```lua
   Send({
      Target = "<AA-Spawn>",
      Action = "AddSuperLlama", 
      SuperLlama ="<ATOMIC_ASSET_ID>", 
      Data=[[
      -- Super Llama Code 
      ... Rest of the code ...
      -- End of the Super Llama Code
      ]]
   })
   ```
   > NOTE: You can use one of SuperLlama Code in `entities/superllamas`
> Congratulations! You have created an **Atomic SuperLlama** (Entity)

### Add Atomic SuperLlama in your World.

This is same like adding entities plus transferring the ownership of Atomic SuperLlama to Cashier so users can buy the Atomic SuperLlama to access it in your world.

#### Step 1: Edit `Shopkeeper.lua`
1. You need to add the `enum` in schema to present users the option to buy the Atomic SuperLlama.
   ```lua
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
                           -- Add the Atomic SuperLlama here like "PriceFeed"
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
   ```
2. Load `Shopkeeper.lua`
   ```lua
   .load Shopkeeper.lua
   ```

#### Step 2: Edit `Cashier.lua`
1. You need to add your Atomic SuperLlamas in the `SUPER_LLAMAS` table so that cashier can send the price to pay and the ownership to the user.
   ```lua
   -- Add the SuperLlama here with thier Atomic Asset Process ID and Price user need to pay for 1 Unit
   SUPER_LLAMAS = {
      Standard = {
         id = '<ATOMIC_ASSET_ID>',
         price = 5
      },
      PriceFeed = {
         id = '<ATOMIC_ASSET_ID>',
         price = 10
      }
   }
   ```
2. Load `Cashier.lua`
   ```lua
   .load Cashier.lua
   ```


#### Step 3: Edit `World.lua`
In this you can add your own type of Entity or can add a PriceFeed SuperLlama like I will doing here.
1. Change the Process Id of Price SuperLlama to your `ATOMIC_ASSET_ID`
   ```lua
   -- Change the Price SuperLlama Process ID
      ['<ATOMIC_ASSET_ID>'] = {
         Position = { 9, 8 },
         Type = 'Avatar',
         Metadata = {
            DisplayName = 'Price SuperLlama',
            SkinNumber = 3,
            Interaction = {
            Type = 'SchemaForm',
            Id = 'PriceFeed'
            },
         },
      },
   ```
2. Load the World
   ```lua
   .load World.lua
   ```

#### Step 4: Transfer Ownership of Atomic SuperLlama

We will be trasnfering ownership of the Atomic SuperLlama from your **Spawnning Process** to **Cashier Process.**

We are doing this so that **Cashier** will transfer ownership to user upon successful purchase and enabling users to interact with the Atomic SuperLLama.

Send `Transfer` message `From` your **Spawnning Process** to **Atomic SuperLlam Process** with **Cashier** as `Recipient`

```lua 
Send({Target = "<AA-Spawn-ProcessID>", Action = "TransferOwnership", Child = "<ATOMIC_ASSET_ID>", Recipient = "<CASHIER_PROCESS_ID>"})
```

> Congrats now your user will only be able to interact with your **ATOMIC SuperLlama** if they have ownership of it, and to buy they will need to request **Shopkeeper** and pay **Cashier**.

### Customise Background Music in your World
In this world, you can found a custom music already set. Also, you can provide an option to users to set **Custom BGM.**

#### Step 1: Add parameters to your `World.lua`
```lua
RealityParameters = {
  ...
  ['Audio-0'] = {
    Bgm = {
      Type = 'Fixed',
      Format = 'WEBM',
      -- Set your custom music Arweave TxId
      TxId = 'bsC6CNeAKTqllbDW1gL3P2u7ooOvSsTyHmlwq7Oc7y0',
    }
  }
}
```

#### Step 2: Add a Handler to change Tx Id
```lua
Handlers.add(
  'Reality.UpdateParameters',
  'UpdateAudio',
  function(msg)
    local audioId = msg.AudioId

    RealityParameters['Audio-0'].Bgm.TxId = audioId

    print('Updated audio to ' .. audioId)
  end
)
```

#### Step 3: Spawn a new process for Music Allowance Atomic Asset.
The holders of this **Music Allowance** Atomic Asset will be able to change the BGM of the world.

1. Send a message to the above **Spawnning Process** with the *title* for the Atomic Asset.
   ```lua
   Send({Target = "<AA-Spawn-ProcessID>", Action ="CreateAA", Title = "Music Allowance"})
   ```
2. Save the Process ID for future reference.

#### Step 4: Create Music Allowance Registry
This entity will transfer Music Allowance Atomic Asset to the user in exchange of $PNTS tokens.

1. Run AOS in `entities`
2. Save the Process Id for future reference.
3. Change the process of Music Allowance Atomic Asset
   ```lua
   -- Change the Music Allowance Process Id
   MUSIC_ALLOWANCE = "soTvSG4rCfZIUq5G43REP0CaGebjbiaRB7Dv2wrX5dY"
   ```
5. Load the `MusicAllowanceRegistry.lua`
   ```lua
   .load MusicAllowanceRegistry.lua
   ```

#### Step 5: Create DJ (Entity to change BGM)
This entity will change the World's BGM on user's request who **holds Music Allowance Atomic Asset**. Upon selecting the music user will need to pay some more $PNTS to change the music.

1. Run AOS in `entities`
2. Save the Process Id for future reference.
3. Change the process of Music Allowance Atomic Asset
   ```lua
   -- Change the Music Allowance Process Id
   MUSIC_ALLOWANCE = "soTvSG4rCfZIUq5G43REP0CaGebjbiaRB7Dv2wrX5dY"
   ```
4. Change or Add the Music Ids and Titles
   ```lua
   -- Change or add the Music Ids and Titles
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
   ```
5. Add titles in `enum` in `serveSchema` function.
   ```lua
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
               -- Add titles here.
               enum = {
                     "Skyfall", "VivaLaVida", "Fairytale", "FeelingGood" 
               }
            }
         }
      }
   }
   ```


#### Step 6: Transfer ownership of **Music Allowance** Atomic Asset
We need to transfer the ownership of Music Allowance Atomic Asset we spawnned in [Step 3](#step-3-spawn-a-new-process-for-music-allowance-atomic-asset) from **Spawnning Process** to **Music Allowance Registry** we created in [Step 4](#step-4-create-music-allowance-registry), so that Registry can sell the ownership to users giving them access to DJ we created in [Step 5](#step-5-create-dj-entity-to-change-bgm).

```lua
Send({Target = "<AA-Spawn-ProcessID>", Action = "TransferOwnership", Child = "<MUSIC_ALLOWANCE_ID>", Recipient = "<MUSIC_ALLOWANCE_REGISTRY_ID>"})
```

> Congratulations! Now users will be able to change the Background Music of you world after buying the Music Allowance Atomic Asset.

