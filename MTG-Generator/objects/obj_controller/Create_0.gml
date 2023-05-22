theme = "minecraft";
screenSaved = false;
chatgptRequestId = -1;
dalleRequestId = -1;
stableDiffusionRequestId = -1;
stableDiffusionModelsRequestId = -1;
textPrompt = "Create an idea for a new Magic the Gathering card with the theme of " + theme + ". Explore all aspects and characters of the theme, not just the main ones. Be creative with card abilites, come up with new ones. Generate cards of any type. Give me the card data as valid JSON and ONLY include the valid JSON and nothing else.\nOnly give me the following properties: \nname, type, subtype, power(if the card is not a creature set this to -1), toughness(if the card is not a creature set this to -1), manaCost(with each mana type with curly braces such as {3}{W}{R}), abilities(as an array), rulings(as an array), flavorText, imageDescription(A highly detailed description of the image that is on the card. It will be used to generate an image with DALLE-2. DO NOT mention the word 'card' in the imageDescription), rarity, and cardFrameSprite(This will be the sprite that is drawn for the card frame to make it match the mana color of the card, this can ONLY be one of the following: spr_cardFrameBlue, spr_cardFrameWhite, spr_cardFrameBlack, spr_cardFrameRed, or spr_cardFrameGreen).";
currentCardStruct = {
	name : "Card Name",
	type : "Creature",
	subtype : "Programmer",
	manaCost : "{3}{W}{W}{B}{G}{R}{U}",
	abilities : [
		"Haste",
		"Pay {W}{B}{U}{G}{R} to die",
		"{T}: This creature makes all other creatures stupid in addition to their primary type"
	],
	flavorText : "This is a stupid flavor text that tastes really bad",
	power : 10,
	toughness : 10,
	cardFrameSprite : "spr_cardFrameBlack"
};

currentCardImage = -1;
cardSetArray = [];

nextCardButtonX1 = 1700;
nextCardButtonY1 = 10;
nextCardButtonX2 = 1900;
nextCardButtonY2 = 60;

exportButtonX1 = 1700;
exportButtonY1 = 80;
exportButtonX2 = 1900;
exportButtonY2 = 130;

global.testInteractionToken = -1;

//Discord bot setup
errorBot = new discordBot(global.config.errorBotToken, global.config.errorApplicationId, false);
magicBot = new discordBot(global.config.MTGBotToken, global.config.MTGApplicationId, true);
magicBot.gatewayEventCallbacks[$ "INTERACTION_CREATE"] = function(){
	var _event = __discord_gateWay_event_parse();
	var _eventData = _event.d;	
	
	switch(_eventData.type){
		case DISCORD_INTERACTION_TYPE.applicationCommand:
			switch(_eventData.data.name){
				case "generate":		
					var _interactionToken = _eventData.token;
					global.testInteractionToken = _interactionToken;
					var _cardTheme = _eventData.data.options[0].value;
					var _cardNumber = _eventData.data.options[1].value;
					
					obj_controller.magicBot.interactionResponseSend(_eventData.id, _eventData.token, DISCORD_INTERACTION_CALLBACK_TYPE.channelMessageWithSource,  "Card(s) generating (0 of " + string(_cardNumber) + ")");
					var _newJob = new job(_cardTheme, _cardNumber, _interactionToken);
					var _firstRequest = send_chatgpt_request(card_prompt(_cardTheme));
					array_push(_newJob.cardTextRequestIdArray, _firstCardRequest);
					
					with(_newJob){
						array_push(obj_controller.jobsArray, self);
						var _firstCardRequest = send_chatgpt_request()
					}
					break;
			}
			break;
	}
}

//Add card generation command to bot
var _optionTheme = new discordCommandOption(DISCORD_COMMAND_OPTION_TYPE.string, "theme", "The theme that the cards will be generated based on.", true);
var _optionCardNumber = new discordCommandOption(DISCORD_COMMAND_OPTION_TYPE.integer, "number", "How many cards to generate.", true);
var _createCardCommand = new discordGuildCommand("generate", "Generate new magic cards based on a theme", DISCORD_COMMAND_TYPE.chatInput, [_optionTheme, _optionCardNumber], DISCORD_PERMISSIONS.sendMessages);

magicBot.guildCommandCreate("1090453953482866738", _createCardCommand, function(){
	show_message(async_load[? "result"]);	
});


//Card gen jobs
jobsArray = [];



