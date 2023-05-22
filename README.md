# MTG-AI
Generate brand new magic cards with ChatGPT and Stable Diffusion via a Discord bot.
- Will generate cards based on almost any theme in batches of 1 - 10 cards.
- Uses a Discord interface similar to Midjourney
- Cards can be exported to Cockatrice so they can be played with.

## Disclaimer
This AI Magic the Gathering Card Generator is an unofficial, fan-made project created for entertainment purposes only. It is not affiliated with, endorsed, sponsored, or approved by Wizards of the Coast LLC, the creator and publisher of the Magic: The Gathering trading card game.

The Project utilizes artificial intelligence to generate custom MTG card designs, and the card designs, names, abilities, and any other content generated are purely fictional and not intended for use in any official MTG events, tournaments, or products. The generated cards should not be considered as real cards or official expansions of the MTG game.

All original MTG card images, names, symbols, characters, and associated intellectual property rights are the property of Wizards of the Coast LLC. The creator of this Project acknowledges and respects these rights and does not claim ownership of any MTG-related intellectual property.

By using this Project, users agree to acknowledge that the Project is not endorsed by or associated with Wizards of the Coast, and they are solely responsible for any consequences resulting from the use or distribution of the generated content. Users are also expected to comply with Wizards' intellectual property policies, and the creator of this Project disclaims any liability for any potential infringements or disputes arising from the use of the generated content.

This Project is provided "as is" and "as available" without warranties of any kind, either express or implied, including, but not limited to, the implied warranties of merchantability, fitness for a particular purpose, and non-infringement. In no event shall the creator of this Project be liable for any direct, indirect, incidental, special, consequential, or punitive damages whatsoever arising out of the use of, or inability to use, the Project or its generated content.

## Setup
### Create Discord Applications
You will need to setup two Discord applications [here](https://discord.com/developers/applications/) and add them to your server.
One will be for handling the card generation commands and the other will be for error logging. For example "MTG Bot" and "Error Bot".
They will need permissions to send messages, edit messages, and create server commands.

### API Keys
MTG-AI uses the [ChatGPT API](https://platform.openai.com/docs/api-reference/) and the [Stability Ai API](https://api.stability.ai/docs) to generate the cards, so an API key for each must be provided.

Find your API keys for each here:
- [Stability Ai keys](https://dreamstudio.ai/account)
- [OpenAi keys](https://platform.openai.com/account/api-keys)

### Config file 
You will need to make a folder called `MTG-AI` on your desktop and create a new text file called `config.json`, this is where all your keys/tokens will be stored.
An example `config.json` would be:
```json
{
    "MTGBotToken" : "DFDSDFJ34DFD64DGFSDGFDSGSGD45OIREOTIU", // Discord bot token of the bot handling the card generation
    "MTGApplicationId" : "112246984056985", // Application ID of the bot handling the card generation
    "openAiKey" : "sk-sdfgsdfgsdfgsdfg", 
    "stabilityAiKey" : "sk-asdfasdfasdfasdf",
    "MTGChannelId" : "123412341234", // Channel where the card generation will happen
    "errorBotToken" : "ZGDFGDSDFJ34DFD64DIOUYPISGSGD45OIREOTIU", // A bot whose job is to log errors
    "errorApplicationId" : "124576371906",
    "errorChannelId" : "116772358755783694" // Channel where errors will be logged
    "serverId" : "1010438968482866738" // The server where the bots live
}
```

### Generating Cards
Once your GameMaker program is connected to the Discord Gateway, it should automatically register the `/generate` command to your Discord server. You can then use `/generate` to start generating cards. 


