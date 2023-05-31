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

global.testInteractionToken = -1;

//Discord bot setup
errorBot = new discordBot(global.config.errorBotToken, global.config.errorApplicationId, false);
magicBot = new discordBot(global.config.MTGBotToken, global.config.MTGApplicationId, true);
magicBot.gatewayEventCallbacks[$ "INTERACTION_CREATE"] = function(){
	var _event = discord_gateWay_event_parse();
	var _eventData = _event.d;	
	
	switch(_eventData.type){
		case DISCORD_INTERACTION_TYPE.applicationCommand:
			switch(_eventData.data.name){
				// /generate command for creating cards
				case "generate":		
					var _interactionToken = _eventData.token;
					var _userId = _eventData.member.user.id;
					var _cardTheme = _eventData.data.options[0].value;
					var _cardNumber = _eventData.data.options[1].value;
					var _excludeThemeInImageGen = false;
					
					if (array_length(_eventData.data.options) > 2){
						var _excludeThemeInImageGen = _eventData.data.options[2].value;
					}
					
					if (array_length(_eventData.data.options) > 3){
						var _customTemperature = _eventData.data.options[3].value;
					}else{
						var _customTemperature = CHATGPT_TEMPERATURE_DEFAULT;	
					}
					
					obj_controller.magicBot.interactionResponseSend(_eventData.id, _eventData.token, DISCORD_INTERACTION_CALLBACK_TYPE.channelMessageWithSource,  "Card(s) generating (0 of " + string(_cardNumber) + ")");
					var _newJob = new job(_cardTheme, _cardNumber, _interactionToken, UUID_generate(), _userId, _excludeThemeInImageGen, _customTemperature);
					array_push(jobsInProgressArray, _newJob);
					var _firstRequest = chatgpt_request_send(card_prompt(_cardTheme), _customTemperature);
					array_push(_newJob.cardTextRequestIdArray, _firstRequest);
					break;
			}
			break;
			
		//Handling "export cards" and "generate more" buttons
		case DISCORD_INTERACTION_TYPE.messageComponent:
			switch(_eventData.data.custom_id){
				//Export the cards as an .xml file compatible with Cockatrice
				case "exportButton":
					var _UUID = export_button_parse_UUID(_eventData.message.content);
					var _theme = export_button_parse_theme(_eventData.message.content);
					var _userId = _eventData.message.mentions[0].id;
					obj_controller.magicBot.interactionResponseSend(_eventData.id, _eventData.token, DISCORD_INTERACTION_CALLBACK_TYPE.deferredUpdateMessage);
					var _xmlBuffer = buffer_load("Card Exports/" + _UUID + ".xml");
					var _xmlString = buffer_read(_xmlBuffer, buffer_string);
					buffer_delete(_xmlBuffer);
					var _xmlStruct = SnapFromXML(_xmlString);
					
					//Find the names of all the cards in the set
					var _xmlCardArray = _xmlStruct.children[0].children[1].children;
					var _exportZipFile = zip_create();
					var _i = 0;
					
					repeat(array_length(_xmlCardArray)){
						var _currentCardName = _xmlCardArray[_i].children[0].text;
						zip_add_file(_exportZipFile, _currentCardName + ".png", "Completed Cards/" + _currentCardName + ".png", -1);
						_i++;		
					}
					
					zip_add_file(_exportZipFile, _theme + ".xml", "Card Exports/" + _UUID + ".xml", -1);
					
					zip_save(_exportZipFile, "Card Exports/Zips/" + _UUID + ".zip");
					
					var _cardArchive = new discordFileAttachment("Card Exports/Zips/" + _UUID + ".zip", _theme + ".zip", "Exported card data for Cockatrice");
					
					magicBot.interactionResponseFollowUp(_eventData.token, "<@" + string(_userId) + ">\nExported data data.", -1, -1, -1, -1, [_cardArchive]);
					break;
			}
			break;
	}
}

magicBot.gatewayEventCallbacks[$ "MESSAGE_CREATE"] = function(){
	var _event = discord_gateWay_event_parse();	
	var _testing = 0;
}

//Add card generation command to bot
var _optionTheme = new discordCommandOption(DISCORD_COMMAND_OPTION_TYPE.string, "theme", "The theme that the cards will be generated based on.", true);
var _optionCardNumber = new discordCommandOption(DISCORD_COMMAND_OPTION_TYPE.integer, "number", "How many cards to generate(Max of 10).", true, -1, -1, -1, 1, 10);
var _optionCardExcludeTheme = new discordCommandOption(DISCORD_COMMAND_OPTION_TYPE.boolean, "exclude-theme", "Whether to skip sending the theme off as part of the image generation, useful for very long themes", false, -1, -1, -1, 1, 10);
var _temperature = new discordCommandOption(DISCORD_COMMAND_OPTION_TYPE.number, "temperature", "How random the card's text will be. The higher, the more random, default: 1.0", false, -1, -1, -1, 0.1, 2);
var _createCardCommand = new discordGuildCommand("generate", "Generate new magic cards based on a theme", DISCORD_COMMAND_TYPE.chatInput, [_optionTheme, _optionCardNumber, _optionCardExcludeTheme, _temperature], DISCORD_PERMISSIONS.sendMessages);

magicBot.guildCommandCreate(global.config.serverId, _createCardCommand, function(){
	//show_message(async_load[? "result"]);	
});

//Card gen jobs
jobsInProgressArray = [];
jobsWaitingToBeDrawnAndSentArray = [];
jobsFinished = [];


