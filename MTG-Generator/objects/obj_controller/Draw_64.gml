if (currentCardImage != -1){
	if (sprite_exists(currentCardImage)){
		draw_sprite_stretched(currentCardImage, 0, 92, 95, 580, 500);	
	}
}

if (currentCardStruct != global.emptyStruct){
	try{
		draw_sprite(asset_get_index(currentCardStruct.cardFrameSprite), 0, 10, 10);
		
		var _namefontColor = "[c_black]";
		var _typeFontColor = "[c_black]";
		var _powerFontColor = "[c_black]";
		
		switch (currentCardStruct.cardFrameSprite){
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
		
		
		var _titleText = scribble("[fnt_cardName]" + _namefontColor + "[fa_left]" + currentCardStruct.name);
		_titleText.draw(85, 60);
		var _cardType = scribble("[fnt_cardName]" + _typeFontColor + "[fa_left]" + string(currentCardStruct.type) + " - " + string(currentCardStruct.subtype));
		_cardType.draw(85, 590);
		scribble("[fa_right]" + string(parse_magic_symbols(currentCardStruct.manaCost))).draw(678, 60);
	
		var _concatedAbilityText = "";
		
		var _i = 0;
		
		repeat(array_length(currentCardStruct.abilities)){
			_concatedAbilityText += currentCardStruct.abilities[_i] + "\n\n";
			
			_i++;	
		}
		
		var _abilityScribble = scribble("[fnt_cardText][c_black]" + parse_magic_symbols(_concatedAbilityText));
		_abilityScribble.fit_to_box(570, 200);
		//_abilityScribble.line_spacing("100%");
		
		_abilityScribble.draw(100, 645);
		
		var _flavorScribble = scribble("[fnt_cardFlavorText][c_black]" + currentCardStruct.flavorText);
		_flavorScribble.fit_to_box(570, 190);
		//_flavorScribble.origin(0, 0);
		//_flavorScribble.skew(0.5, 0);
		//_flavorScribble.line_spacing("100%");
		
		_flavorScribble.draw(100, 860);
		
		if (currentCardStruct.toughness != -1){
			var _powerToughness = scribble("[fnt_cardName]" + _powerFontColor + "[fa_right]" + string(currentCardStruct.power) + "/" + string(currentCardStruct.toughness));
			_powerToughness.scale(1.2);	
			_powerToughness.draw(680, 950);
		}
	
		draw_text_ext(1050, 100, string(currentCardStruct.imageDescription), 20, 600);
		draw_text_ext(1050, 200, string(currentCardStruct.rulings), 20, 600);
	}catch(_error){
			
	}
}

if (currentCardImage != -1){
	if (sprite_exists(currentCardImage)){	
		if (!screenSaved){
			screen_save_part(currentCardStruct.name + ".png", 30, 30, 700, 1000);
			screenSaved = true;
		}
	}
}

// Draw "Generate Next Card" button
draw_set_color(c_blue);
draw_rectangle(nextCardButtonX1, nextCardButtonY1, nextCardButtonX2, nextCardButtonY2, false);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text((nextCardButtonX1 + nextCardButtonX2) / 2, (nextCardButtonY1 + nextCardButtonY2) / 2, "Generate Next Card");

// Draw "Export Cards" button
draw_set_color(c_blue);
draw_rectangle(exportButtonX1, exportButtonY1, exportButtonX2, exportButtonY2, false);
draw_set_color(c_white);
draw_text((exportButtonX1 + exportButtonX2) / 2, (exportButtonY1 + exportButtonY2) / 2, "Export Cards");
