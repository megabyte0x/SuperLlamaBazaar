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

### Create SuperLlamas Atomic Assets
