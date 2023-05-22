# MTG-AI
Generate brand new magic cards with ChatGPT and Stable Diffusion via Discord.
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
### Create Discord Application
You will need to setup two Discord applications [here](https://discord.com/developers/applications/) and add them to your server.
One will be for handling the card generation commands and the other will be for error logging. For example "MTG Bot" and "Error Bot".
They will need permissions to and and edit messages.

### API Keys
MTG-AI uses the [ChatGPT API]() and the [Stability Ai API]() to generate the cards, so an API key for each must be provided.

Find your API keys for each here:
- [Stability Ai keys](https://dreamstudio.ai/account)
- [OpenAi keys](https://platform.openai.com/account/api-keys)

### Config file 
You will need to make a folder called `MTG-AI` on your desktop and create a new text file called `config.json`, this is where all your keys/tokens will be stored.
An example `config.json` would be:
```json
{
    "MTGBotToken" : "<Discord bot token of the bot handling the card generation>",
    "MTGApplicationId" : "<Application ID of the bot handling the card generation>",
    "openAiKey" : "sk-sdfgsdfgsdfgsdfg", 
    "stabilityAiKey" : "sk-asdfasdfasdfasdf",
    "MTGChannelId" : "123412341234", // Channel where the card generation will happen
    "errorBotToken" : "<A bot whose job is to log erros>",
    "errorApplicationId" : "124576371906",
    "errorChannelId" : "116772358755783694" // Channel where errors will be logged
}
```

### Generating Cards
- In `obj_controller` under its create event, there is a variable called `theme`; set this variable to whatever you want. 
- If you are only using OpenAi and not Stable Diffusion, change the value of the `USE_DALLE` macro found in `scr_functions` to `true`.  
- When running the project, click the generate card button and it will begin generating a new card.
- Once any number of cards have been generated, you can click the export button to save an XML file compatible with Cockatrice
- All cards and XML files are outputed to `appdata/local/MTG-Generator`


