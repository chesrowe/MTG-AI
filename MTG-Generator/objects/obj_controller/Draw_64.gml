var _i = 0;

repeat(array_length(jobsWaitingToBeDrawnAndSentArray)){
	var _currentJob = jobsWaitingToBeDrawnAndSentArray[_i];
	var _completedCardImages = [];
	
	var _j = 0;
	
	repeat(array_length(_currentJob.cardsWaitingToBeDrawn)){
		var _currentCardToBeDrawn = _currentJob.cardsWaitingToBeDrawn[_j];
		var _currentCardStruct = _currentCardToBeDrawn.cardStruct;
		var _cardSurface = surface_create(744, 1045);
		var _currentCardImageSprite = sprite_add("Card Images/" + _currentCardStruct.name + ".png", 1, false, false, 0, 0);
		surface_set_target(_cardSurface);
		var _xOrg = -10;
		var _yOrg = -10;
		//Draw card image 
		if (sprite_exists(_currentCardImageSprite)){
			draw_sprite_stretched(_currentCardImageSprite, 0, 92 + _xOrg, 95 + _yOrg, 580, 500);	
		}			
		
		//Draw card text
		try {
			draw_sprite(asset_get_index(_currentCardStruct.cardFrameSprite), 0, 10 + _xOrg, 10 + _yOrg);
		
			var _namefontColor = "[c_black]";
			var _typeFontColor = "[c_black]";
			var _powerFontColor = "[c_black]";
		
			switch (_currentCardStruct.cardFrameSprite){
				case "spr_cardFrameBlack":
				case "spr_cardFrameBlue":
				case "spr_cardFrameGreen":
				case "spr_cardFrameRed":
					_namefontColor = "[c_white]";
					_typeFontColor = "[c_white]";
					_powerFontColor = "[c_white]";
				break;
			
				case "spr_cardFrameWhite":
					_namefontColor = "[c_black]";
					_typeFontColor = "[c_black]";
					_powerFontColor = "[c_black]";
				break;
			}
		
		
			//Title
			var _titleText = scribble("[fnt_cardName]" + _namefontColor + "[fa_left]" + _currentCardStruct.name);
			_titleText.draw(85 + _xOrg, 60 + _yOrg);
			
			//Type
			var _typeText = "[fnt_cardName]" + _typeFontColor + "[fa_left]" + string(_currentCardStruct.type);
			_typeText += (_currentCardStruct.subtype != "") ?  " - " + string(_currentCardStruct.subtype) : "";
			var _cardType = scribble(_typeText);
			_cardType.draw(85 + _xOrg, 590 + _yOrg);
			
			//Mana cost
			if (_currentCardStruct.manaCost != ""){
				scribble("[fa_right]" + string(parse_magic_symbols(_currentCardStruct.manaCost))).draw(678 + _xOrg, 60 + _yOrg);
			}
	
			var _concatedAbilityText = "";
		
			var _i = 0;
		
			repeat(array_length(_currentCardStruct.abilities)){
				_concatedAbilityText += _currentCardStruct.abilities[_i] + "\n";
			
				_i++;	
			}
		
			var _abilityText = "[fnt_cardText][c_black]" + parse_magic_symbols(_concatedAbilityText);
			var _flavorText = "\n[fnt_cardFlavorText][c_black]" + _currentCardStruct.flavorText;
			var _abilityFlavorScribble = scribble(_abilityText + _flavorText);
			_abilityFlavorScribble.fit_to_box(570, 270);
			//_abilityScribble.line_spacing("100%");
		
			_abilityFlavorScribble.draw(100 + _xOrg, 645 + _yOrg);		
		
			if (_currentCardStruct.toughness != -1){
				var _powerToughness = scribble("[fnt_cardName]" + _powerFontColor + "[fa_right]" + string(_currentCardStruct.power) + "/" + string(_currentCardStruct.toughness));
				_powerToughness.scale(1.2);	
				_powerToughness.draw(680 + _xOrg, 950 + _yOrg);
			}
	
			//draw_text_ext(1050, 100, string(_currentCardStruct.imageDescription), 20, 600);
			//draw_text_ext(1050, 200, string(_currentCardStruct.rulings), 20, 600);
		}catch(_error){
			discord_error(_error);	
		}
		
		surface_reset_target();	
		
		var _completedCardFilePath = "Completed Cards/" + string(_currentCardStruct.name) + ".png";
		surface_save(_cardSurface, _completedCardFilePath);
		surface_free(_cardSurface);
		sprite_delete(_currentCardImageSprite);
		var _completedCardAttachment = new discordFileAttachment(_completedCardFilePath, string(_currentCardStruct.name) + ".png");
		array_push(_completedCardImages, _completedCardAttachment);
		_j++;
	}

	//Send the completed card images for this job to Discord
	var _completedCardsEditCallback = function(){
		show_debug_message(async_load[? "result"]);	
	}
	
	var _exportComponent = new discordMessageComponent(DISCORD_COMPONENT_TYPE.button, DISCORD_BUTTON_STYLE.primary, "Export Cards", "exportButton");
	var _generateComponent = new discordMessageComponent(DISCORD_COMPONENT_TYPE.button, DISCORD_BUTTON_STYLE.primary, "Generate More", "generateButton");
	var _actionRow = new discordMessageComponent(DISCORD_COMPONENT_TYPE.actionRow, -1, "Options", "actionRow", -1, "", [_exportComponent, _generateComponent]);
	//In case the user inputs a stupidly long theme
	var _trimmedTheme = string_copy(_currentJob.theme, 0, 1500);
	
	magicBot.interactionResponseFollowUp(_currentJob.interactionToken, "<@" + string(_currentJob.userId) + ">\nCards completed!\nTheme: " + string(_trimmedTheme), _completedCardsEditCallback, [_actionRow], -1, -1, _completedCardImages);
	_i++;
}

jobsWaitingToBeDrawnAndSentArray = [];

var _debugText = "";
_debugText += "heartbeat counter: " + string(magicBot.__gatewayHeartbeatCounter) + "\n";
_debugText += "Number of disconnects: " + string(magicBot.__gatewayNumberOfDisconnects) + "\n";

scribble(_debugText).draw(10, 10);

