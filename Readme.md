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
3. Set the `CASHIER` to your **Cashier Entitiy** you created, in `aa-spawn.lua`
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
Send({Target = "SpawnningProcess", Action = "Transfer", Recipient = "<ATOMIC_ASSET_ID>", Quantity = "100"})
```

> Congrats now your user will only be able to interact with your **ATOMIC SuperLlama** if they have ownership of it, and to buy they will need to request **Shopkeeper** and pay **Cashier**.