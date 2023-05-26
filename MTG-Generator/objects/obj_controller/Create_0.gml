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
				case "generate":		
					var _interactionToken = _eventData.token;
					var _userId = _eventData.member.user.id;
					var _cardTheme = _eventData.data.options[0].value;
					var _cardNumber = _eventData.data.options[1].value;
					var _excludeThemeInImageGen = false;
					
					if (array_length(_eventData.data.options) > 2){
						var _excludeThemeInImageGen = _eventData.data.options[2].value;
					}
					
					obj_controller.magicBot.interactionResponseSend(_eventData.id, _eventData.token, DISCORD_INTERACTION_CALLBACK_TYPE.channelMessageWithSource,  "Card(s) generating (0 of " + string(_cardNumber) + ")");
					var _newJob = new job(_cardTheme, _cardNumber, _interactionToken, _userId, _excludeThemeInImageGen);
					array_push(jobsInProgressArray, _newJob);
					var _firstRequest = chatgpt_request_send(card_prompt(_cardTheme));
					array_push(_newJob.cardTextRequestIdArray, _firstRequest);
					break;
			}
			break;
	}
}

//magicBot.gatewayEventCallbacks[$ "MESSAGE_CREATE"] = function(){
//    var _event = discord_gateWay_event_parse();
//    var _eventData = _event.d;
//    //show_debug_message("New message: " + string(_eventData.content));
//}

//Add card generation command to bot
var _optionTheme = new discordCommandOption(DISCORD_COMMAND_OPTION_TYPE.string, "theme", "The theme that the cards will be generated based on.", true);
var _optionCardNumber = new discordCommandOption(DISCORD_COMMAND_OPTION_TYPE.integer, "number", "How many cards to generate(Max of 10).", true, -1, -1, -1, 1, 10);
var _optionCardExcludeTheme = new discordCommandOption(DISCORD_COMMAND_OPTION_TYPE.boolean, "exclude-theme", "Whether to skip sending the theme off as part of the image generation, useful for very long themes", false, -1, -1, -1, 1, 10);
var _createCardCommand = new discordGuildCommand("generate", "Generate new magic cards based on a theme", DISCORD_COMMAND_TYPE.chatInput, [_optionTheme, _optionCardNumber, _optionCardExcludeTheme], DISCORD_PERMISSIONS.sendMessages);

magicBot.guildCommandCreate(global.config.serverId, _createCardCommand, function(){
	//show_message(async_load[? "result"]);	
});

//Card gen jobs
jobsInProgressArray = [];
jobsWaitingToBeDrawnAndSentArray = [];


