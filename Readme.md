# [SuperLlamas Bazaar](https://reality-viewer.arweave.net/#/R4hLJ50NtQlheNFyEM6IvjwsIEi4-Ty8psSXlXfJSx0)

You can visit here: https://reality-viewer.arweave.net/#/R4hLJ50NtQlheNFyEM6IvjwsIEi4-Ty8psSXlXfJSx0

## Process Ids

- superLlamaBazaar: R4hLJ50NtQlheNFyEM6IvjwsIEi4-Ty8psSXlXfJSx0
- bazaarCashier: aBSSTYd9CppyC5Udqb8GB-z4fCNyaNfXphgKeLNMZMI
- bazaarShopKeeper: CRZG8-73qdn8Nhxo4tRaDu9bnc40jMQ-CL2ciR1EaLI
- bazaarSuperLlamaSpawanning: REany43kMRpz7zZN4w2YoOqCCCXB9ZGKEjHsX9TXy30
- standardSuperLlama: WGbbS00KcbZTLexYO40UATkfYXvAUWEfetrHzTm93cY
- priceFeedSuperLlama: 3Q28ws1uvhw8GpDOLup9aICIEc4G2BO9Un3nKiEHgzs
- musicAllowance: 32UGDRE6gw_GlKz-CcSfngGjppERFWs4Y2unJfDG-hI
- musicAllowanceRegistry: uvAJIfSMKCRgQ4q5jvquxLfHlXCBuYmdDbTTf6chNW4
- bazaarDJ: Wsdc03LL22HNYmFjuOK07GE0h9cWC6uzGhYza-7rdhk
- bigTable: XPj6VGx6iKUSTdm9XKqp3JQ4HpjvXX7kHYW3D_PxqtU
- bigTableGuy: K6Ibj9ELAV0DF6AH-GXTtqCpmttmiRp-hZj2R1E1xZA
- bazaarBigTable: fNHqW6rghEbFZcn1p7k-vB4rqaGnLsjeyjrkkKxRhLI


## How to Create your OWN?

### Deploy the Reality World

1. Run AOS in `world` folder.
   ```bash
   aos superLlamaBazaar --module=ghSkge2sIUD_F00ym5sEimC63BDBuBrq4b5OcwxOjiw
   ```
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
3. Change the `Name` in the `ATOMIC_ASSET_STANDARD` to your SuperLlama's name.
4. Load the `aa-spawn.lua`
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
   Send({Target = "<AA-SPAWNSEnd>", Action = "AddSuperLlama", Child ="<ATOMIC_ASSET_ID>", Data=[[<YOUR SUPERLLAMA CODE>]]})
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
Send({Target = ao.id, Action = "TransferOwnership", Child = "<ATOMIC_ASSET_ID>", Recipient = "<CASHIER_PROCESS_ID>"})
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
         TxId = 'HxfGWmXJu9WB0ICCFEtvkpbFxDiJwXWV6P9dABJiOQA',
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

> Congrats! You will be able to change your World BGM.

### Token Gating Music Change
Provide an option to change BGM to users who are holding a particular Atomic Asset.

#### Step 1: Create Music Allowance Atomic Asset.
The holders of this **Music Allowance** Atomic Asset will be able to change the BGM of the world.

1. Go to [Bazaar](https://ao-bazar.arweave.net/) 
2. Create your profile. (This is one time thing)
3. Click on **Create** from the Navigation Bar.
4. You will be redirected to [Helix.](https://helix.arweave.net/)
5. Click on **Upload**
6. Click on **Atomic Assets** on top right.
7. Upload any image of your choice.
8. Give it a Title and Description.
9. Select the **License**
10. Then click on **Upload**. 
11. Go back to your Bazaar Profile, you will see your recently created Atomic Asset, click on it.
12. Copy the Transaction Id, save it as it's your Music Allowance Atomic Asset's Process Id.

> My [Music Allowance Atomic Asset.](https://ao-bazar.arweave.net/#/asset/32UGDRE6gw_GlKz-CcSfngGjppERFWs4Y2unJfDG-hI)

#### Step 2: Create Music Allowance Registry
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

#### Step 3: Create DJ (Entity to change BGM)
This entity will change the World's BGM on user's request who **holds Music Allowance Atomic Asset**. Upon selecting the music user will need to pay some more $PNTS to change the music.

1. Run AOS in `entities/bigTable`
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
6. Load `DJ.lua`
   ```lua
   .load DJ.lua
   ```


#### Step 4: Transfer ownership of **Music Allowance** Atomic Asset
We need to transfer the ownership of Music Allowance Atomic Asset we created [here](#step-1-create-music-allowance-atomic-asset) to **Music Allowance Registry** we created in [Step 4](#step-2-create-music-allowance-registry), so that Registry can sell the ownership to users giving them access to DJ we created in [Step 5](#step-3-create-dj-entity-to-change-bgm).

1. Head to your Music Allowance Atomic Asset on Bazaar. 
2. Select the **Transfer** option. 
3. Enter **Quantity** you want to transfer (eg. 20)
4. Enter the DJ's Process ID as **Recipient** address.
5. Click on **Transfer** and sign the transactions.

> Congratulations! Now users will be able to change the Background Music of you world after buying the Music Allowance Atomic Asset.

### Connect to Another World (with Token Gating)

#### Step 1: Create an Atomic Asset on Bazaar.
Follow the steps mentioned in [here.](#step-3-create-music-allowance-atomic-asset)

> Here's [mine.](https://ao-bazar.arweave.net/#/asset/XPj6VGx6iKUSTdm9XKqp3JQ4HpjvXX7kHYW3D_PxqtU)

#### Step 2: Create an Entity
This entity will be used to interact when the user is not the owner of Atomic Asset and would like to buy ownership.

1. Run AOS in `entities/bigTable`
   ```bash
   aos bigTableGuy
   ```
2. Edit `entities/bigTable/BigTableGuy.lua`
   You will need to change the `BIG_TABLE` process Id to the Atomic Asset process Id you created above.
   ```lua
   -- Change this to the Atomic Asset used for Token Gating.
   BIG_TABLE = 'XPj6VGx6iKUSTdm9XKqp3JQ4HpjvXX7kHYW3D_PxqtU'
   ```
3. Load `BigTableGuy.lua`
   ```bash
   .load BigTableGuy.lua
   ```

#### Step 3: Create Another Reality World.
In this world we will need to edit `Reality.lua` and `World.lua` standard contract to make it token gated world. 

1. Run AOS in `world/BigTable` folder.
   ```bash
   aos AnotherWorld --module=ghSkge2sIUD_F00ym5sEimC63BDBuBrq4b5OcwxOjiw --cron 10-seconds
   ```
   We have started a `CRON` message here so that it will update the owners of `BIG_TABLE` Atomic Asset in `BIG_TABLE_MEMBERS` every 10 seconds.
2. Save the process id for future reference.
3. Edit the `BIG_TABLE` in `BigTable.lua`
   ```lua
   -- Change this to your Atomic Asset for Token Gating.
   BIG_TABLE = 'XPj6VGx6iKUSTdm9XKqp3JQ4HpjvXX7kHYW3D_PxqtU'
   ```
5. Edit the `BigTableWorld.lua`
   You need to change the `BIG_TABLE_GUY` to the process id of the entity you created above.
   ```lua
   -- Change this to the process id of your entity.
   BIG_TABBLE_GUY = 'QI_YZ5ff5RYgzkkB9SsF76zpy3ZHYzroyAY-pdEDuTo'
   ```
6. Load `BigTable.lua`, `BigTableChat.lua` and `BigTableWorld.lua`
   ```bash
   .load BigTable.lua
   .load BigTableWorld.lua
   .load BigTableChat.lua
   ```
7. Update `CHAT_TARGET` in `entities/bigTable/BigTableGuy.lua` to the process Id we just created fro BIG_TABLE world.
   ```lua
   -- Change this to the Chat Target for Big Table World
   CHAT_TARGET = 'fNHqW6rghEbFZcn1p7k-vB4rqaGnLsjeyjrkkKxRhLI'
   ```
8. Load `BigTableGuy.lua`
   ```lua
   .load BigTableGuy.lua
   ```

So, this will create a world which will sending its `Reality.Parameters` and `Reality.EntitiesStatic` based on the condition check if the user is the owner of the Atomic Asset or not.

#### Step 4: Connecting to Main World
We need to connect the Main World to the New World so that user can travel back and forth.

1. Edit `World.lua`
   Change the `Big Table` entity to the process Id of the world created above.'
   ```lua
     -- Change the Big Table Process ID
   ['TQKAOPuE5OKZUBNBBxUKqSCG6qkft45F2ju9IvZSK-Y'] = {
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
   ```
2. Load `World.lua`
   ```bash
   .load World.lua
   ```

> Congrats! Now your user can travel from one world to another if they hold some particular Atomic Asset.