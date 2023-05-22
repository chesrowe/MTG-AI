# MTG-AI
Generate brand new magic cards with ChatGPT and Stable Diffusion.
- Will generate cards based on almost any theme.
- Cards can be exported to Cockatrice so they can be played with.

# Disclaimer
This AI Magic the Gathering Card Generator is an unofficial, fan-made project created for entertainment purposes only. It is not affiliated with, endorsed, sponsored, or approved by Wizards of the Coast LLC, the creator and publisher of the Magic: The Gathering trading card game.

The Project utilizes artificial intelligence to generate custom MTG card designs, and the card designs, names, abilities, and any other content generated are purely fictional and not intended for use in any official MTG events, tournaments, or products. The generated cards should not be considered as real cards or official expansions of the MTG game.

All original MTG card images, names, symbols, characters, and associated intellectual property rights are the property of Wizards of the Coast LLC. The creator of this Project acknowledges and respects these rights and does not claim ownership of any MTG-related intellectual property.

By using this Project, users agree to acknowledge that the Project is not endorsed by or associated with Wizards of the Coast, and they are solely responsible for any consequences resulting from the use or distribution of the generated content. Users are also expected to comply with Wizards' intellectual property policies, and the creator of this Project disclaims any liability for any potential infringements or disputes arising from the use of the generated content.

This Project is provided "as is" and "as available" without warranties of any kind, either express or implied, including, but not limited to, the implied warranties of merchantability, fitness for a particular purpose, and non-infringement. In no event shall the creator of this Project be liable for any direct, indirect, incidental, special, consequential, or punitive damages whatsoever arising out of the use of, or inability to use, the Project or its generated content.

# Setup
### API Keys
In the `scr_functions` script there are two macros `OPENAI_API_KEY` and `STABILTIY_API_KEY`, you will need to provide at least an OpenAi API key or both, they can be found here:
- [Stabiltiy Ai](https://dreamstudio.ai/account)
- [OpenAi](https://platform.openai.com/account/api-keys)

### Generating Cards
- In `obj_controller` under its create event, there is a variable called `theme`; set this variable to whatever you want. 
- If you are only using OpenAi and not Stable Diffusion, change the value of the `USE_DALLE` macro found in `scr_functions` to `true`.  
- When running the project, click the generate card button and it will begin generating a new card.
- Once any number of cards have been generated, you can click the export button to save an XML file compatible with Cockatrice
- All cards and XML files are outputed to `appdata/local/MTG-Generator`


