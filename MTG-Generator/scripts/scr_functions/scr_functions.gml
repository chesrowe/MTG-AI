#macro CHATGPT_TEMPERATURE_DEFAULT 1.0

randomize();

var _configPath = "config.json"
global.config = json_load(_configPath);
global.emptyStruct = {};

#region chatgpt_request_send(prompt)

/**
 * Sends a request to the ChatGPT API with the given prompt.
 * @param {string} prompt - The prompt to send to the ChatGPT API.
 * @param {real} temperature - How random the text output will be, higher = more random (ranges 0.1 to 2).
 * @returns The request ID associated with the API call.
 */
function chatgpt_request_send(_prompt, _temperature = CHATGPT_TEMPERATURE_DEFAULT) {
    var _url = "https://api.openai.com/v1/completions";
    var _headers = ds_map_create();
    var _data = {
				model: "text-davinci-003",
				prompt: string(_prompt), 
				max_tokens: int64(2000), 
				n: int64(1), 
				stop: "null", 
				temperature: _temperature
			}
			
	var _dataJson = json_stringify(_data);
	show_debug_message("Text data: " + _data.prompt);

    //Headeres
    ds_map_add(_headers, "Authorization", "Bearer " + global.config.openAiKey);
    ds_map_add(_headers, "Content-Type", "application/json");

    // Send the POST request
    var _requestId = http_request(_url, "POST", _headers, _dataJson);

    // Clean up the headers map
    ds_map_destroy(_headers);

    return _requestId;
}

#endregion

#region dalle_request_send(prompt)

/**
 * Sends a request to the Dalle API with the given prompt.
 * @param {string} prompt - The prompt to send to the Dalle-2 API.
 * @returns The request ID associated with the API call.
 */
function dalle_request_send(_prompt) {
    var _url = "https://api.openai.com/v1/images/generations";
    var _headers = ds_map_create();
    var _data = {
				prompt: string(_prompt) + "Magic the Gathering, Highly detailed, gothic, dark fantasy, realistic digital painting, masterpiece, 4K. By Adam Paquette", 
				size: "1024x1024"
			}
			
	var _dataJson = json_stringify(_data);
	show_debug_message("Image data: " + _dataJson);

    // Headers
    ds_map_add(_headers, "Authorization", "Bearer " + global.config.openAiKey);
    ds_map_add(_headers, "Content-Type", "application/json");

    // Send the POST request
    var _requestId = http_request(_url, "POST", _headers, _dataJson);

    // Clean up the headers map
    ds_map_destroy(_headers);

    return _requestId;
}

#endregion

#region stableDiffusion_request_send(prompt)

/**
 * Sends a request to the Stable Diffusion API with the given prompt.
 * @param {string} prompt - The prompt to send to the Stable-Diffusion API.
 * @returns The request ID associated with the API call.
 */
function stableDiffusion_request_send(_prompt) {
    var _url = "https://api.stability.ai/v1/generation/stable-diffusion-xl-beta-v2-2-2/text-to-image";
    var _headers = ds_map_create();
    var _data = {
		text_prompts: [
			{
				text : string(_prompt + ". Magic the Gathering, Highly detailed, gothic, dark fantasy, realistic digital painting, masterpiece, 4K. By Christopher Rush"),
			}
		],
		samples : int64(1),
		height : int64(512),
		width : int64(512),
		steps : int64(150)
	}
			
	var _dataJson = json_stringify(_data);
	show_debug_message("Image data: " + _dataJson);

    // Headers
    ds_map_add(_headers, "Accept", "application/json");
    ds_map_add(_headers, "Content-Type", "application/json");
    ds_map_add(_headers, "Authorization", "Bearer " + string(global.config.stabilityAiKey));


    // Send the POST request
    var _requestId = http_request(_url, "POST", _headers, _dataJson);

    // Clean up the headers map
    ds_map_destroy(_headers);

    return _requestId;
}

#endregion

#region stableDiffusion_get_models()

function stableDiffusion_get_models() {
    var _url = "https://api.stability.ai/v1/engines/list";
    var _headers = ds_map_create();
    var _data = {}
			
	var _dataJson = json_stringify(_data);
    ds_map_add(_headers, "Authorization", "Bearer " + string(global.config.stabilityAiKey));

    var _requestId = http_request(_url, "GET", _headers, _dataJson);

    ds_map_destroy(_headers);

    return _requestId;
}

#endregion

#region parse_magic_symbols(text)

/// @function parse_magic_symbols(text)
/// @param {string} text The input text containing symbols
/// @returns The output string with sprite names and color codes
function parse_magic_symbols(text) {
    var _output = "";
    var _i = 0;
    var _len = string_length(text);

    while (_i < _len) {
        var _currentChar = string_char_at(text, _i + 1);

        if (_currentChar == "{") {
            var _nextChar = string_char_at(text, _i + 2);
            var _spriteName = "";

            switch (_nextChar) {
                case "W":
                    _spriteName = "spr_manaWhite";
                    break;
                case "U":
                    _spriteName = "spr_manaBlue";
                    break;
                case "B":
                    _spriteName = "spr_manaBlack";
                    break;
                case "R":
                    _spriteName = "spr_manaRed";
                    break;
                case "G":
                    _spriteName = "spr_manaGreen";
                    break;
				case "T": 
					_spriteName = "spr_tap"
					break;
                default:
                    if (string_digits(_nextChar) != "") {
                        var _num = real(_nextChar);
                        _spriteName = "spr_manaColorless" + string(_num);
                    }
                    break;
            }

            if (_spriteName != "") {
                _output += "[c_white][" + _spriteName + "][c_black]";
                _i += 3;
            } else {
                _output += _currentChar;
                _i += 1;
            }
        } else {
            _output += _currentChar;
            _i += 1;
        }
    }

    return _output;
}

#endregion

#region export_to_cockatrice(cards, fileName)

/// @function export_to_cockatrice(cards, fileName, [setName])
/// @desc Exports cards in a XML format compatible with Cockatrice
/// @param {array} cards An array of card structs
/// @param {string} fileName The name of the XML file to save
function export_to_cockatrice(cards, fileName, _setName = "CustomSet") {
    var _xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
    _xml += "<cockatrice_carddatabase version=\"4\">\n";
    _xml += "  <sets>\n";
    _xml += "    <set>\n";
    _xml += "      <name>" + _setName + "</name>\n";
    _xml += "      <longname>" + _setName + "</longname>\n";
    _xml += "      <settype>" + "AI Generated" + "</settype>\n";
    _xml += "      <abbreviation>AI</abbreviation>\n";
    _xml += "      <releasedate>" + string(current_year) + "-" + string (current_month) + "-" + string(current_day) + "</releasedate>\n";
    _xml += "    </set>\n";
    _xml += "  </sets>\n";
    _xml += "  <cards>\n";

    for (var _i = 0; _i < array_length(cards); ++_i) {
        var _card = cards[_i];

        // Infer cmc, colors, and colorIdentity from manaCost
        var _cmc = 0;
        var _colors = "";
        var _colorIdentity = "";

        var _manaCost = _card.manaCost;
        var _start = string_pos("{", _manaCost);

        while (_start != 0) {
            _manaCost = string_delete(_manaCost, _start, 1);
            var _symbol = string_copy(_manaCost, _start, 1);
            var _end = string_pos("}", _manaCost);
            _manaCost = string_delete(_manaCost, _end, 1);

            if (string_length(_symbol) == 1 && string_pos(_symbol, "WUBRG") != 0) {
                _colors += _symbol;
                _colorIdentity += _symbol;
                _cmc += 1;
            } else if (string_length(_symbol) > 0 && string_pos(_symbol, "0123456789") != 0) {
                _cmc += real(_symbol);
            }

            _start = string_pos("{", _manaCost);
        }

        _xml += "    <card>\n";
        _xml += "      <name>" + _card.name + "</name>\n";
        _xml += "      <text>";
		try {
			for (var _j = 0; _j < array_length(_card.abilities); ++_j) {
	            if (_j > 0) {
	                _xml += "\n";
	            }
	            _xml += _card.abilities[_j];
	        }
		}catch(_error){
			_xml += "\n";	
		}
        _xml += "</text>\n";
        _xml += "      <prop>\n";
        _xml += "        <type>" + _card.type;
        if (_card.subtype != "") {
            _xml += " - " + _card.subtype;
        }
        _xml += "</type>\n";
        _xml += "        <maintype>" + _card.type + "</maintype>\n";
        _xml += "        <manacost>" + _card.manaCost + "</manacost>\n";
        _xml += "        <cmc>" + string(_cmc) + "</cmc>\n";
        _xml += "        <colors>" + _colors + "</colors>\n";
        _xml += "        <coloridentity>" + _colorIdentity + "</coloridentity>\n";
		
		if (_card.toughness != -1){
			_xml += "        <pt>" + string(_card.power) + "/" + string(_card.toughness) + "</pt>\n";
		}
	    
		_xml += "      </prop>\n";
	    _xml += "      <set rarity=\"" + _card.rarity + "\">CS</set>\n";
	    _xml += "      <flavor>" + _card.flavorText + "</flavor>\n";
	    _xml += "    </card>\n";
	}

	_xml += "  </cards>\n";
	_xml += "</cockatrice_carddatabase>";

	// Save the XML to a file
	var _file = file_text_open_write(fileName);
	file_text_write_string(_file, _xml);
	file_text_close(_file);
}

#endregion

/// @func json_load(filePath)
/// @desc Loads a json file and parses in as a struct then returns that struct or -1 if failed
/// @param {string} filePath The path to the json file
function json_load(_filePath){
	var _buff = buffer_load(_filePath);
	
	if (_buff != -1){
		var _str = buffer_read(_buff, buffer_text);
		buffer_delete(_buff);
		var _parsedJson = json_parse(_str);
		return is_struct(_parsedJson) ? _parsedJson : -1;
	}else{
		return -1;
	}
}

function discord_error(_error){
	var _errorMessage = "";
	_errorMessage += "**MTG-Generator**\r\n"
	_errorMessage += "Where\r\n"
	_errorMessage += "```\r\n" + _error.script + "\r\n```\r\n";
	_errorMessage += "Error\r\n"
	_errorMessage += "```\r\n" + _error.longMessage + "\r\n```\r\n";
	obj_controller.errorBot.messageSend(global.config.errorChannelId, _errorMessage);
	//show_message(_error.longMessage);
}

//exception_unhandled_handler(discord_error);

function card_prompt(_theme, _previousCards = []){
	var _prompt = "Create an idea for a new Magic the Gathering card with the theme of " + _theme + ". Explore all aspects and characters of the theme, not just the main ones. Be creative with card abilites, come up with new ones. Generate cards of any type. Give me the card data as valid JSON and ONLY include the valid JSON and nothing else.\nOnly give me the following properties: \nname, type, subtype, power(if the card is not a creature set this to -1), toughness(if the card is not a creature set this to -1), manaCost(with each mana type with curly braces such as {3}{W}{R}. If the card is a land return \"\"), abilities(as an array), rulings(as an array), flavorText, imageDescription(A highly detailed description of the image that is on the card. It will be used to generate an image with DALLE-2. DO NOT mention the word 'card' in the imageDescription), rarity, and cardFrameSprite(This will be the sprite that is drawn for the card frame to make it match the mana color of the card, this can ONLY be one of the following: spr_cardFrameBlue, spr_cardFrameWhite, spr_cardFrameBlack, spr_cardFrameRed, or spr_cardFrameGreen).";	
	var _i = 0;
	
	repeat(array_length(_previousCards)){
		var _currentCard = _previousCards[_i];
		
		_prompt += " A card with the name '" + _currentCard.name + "' already exists so do not create a card named that, find another aspect of the theme.";	
		_i++;
	}
	
	return _prompt;
}

/// @desc Checks the returned card struct to make sure it has all the properties needed in the right format
function returned_card_struct_is_valid(_cardStruct){
	if ((variable_struct_exists(_cardStruct, "name")            &&
		variable_struct_exists(_cardStruct, "type")             &&
		variable_struct_exists(_cardStruct, "subtype")          &&
		variable_struct_exists(_cardStruct, "manaCost")         &&
		variable_struct_exists(_cardStruct, "abilities")        &&
		variable_struct_exists(_cardStruct, "flavorText")       &&
		variable_struct_exists(_cardStruct, "power")            &&
		variable_struct_exists(_cardStruct, "toughness")        &&
		variable_struct_exists(_cardStruct, "cardFrameSprite")  &&
		variable_struct_exists(_cardStruct, "imageDescription"))){		
		//The only time no ability text is acceptable, is when the card is a land, otherwise the card text is no valid 
		if (string_lower(_cardStruct.type) == "land"){
			return true;
		}else{
			if(string_lower(_cardStruct.type) == "creature" || string_lower(_cardStruct.type) == "legendary creature"){
				if (is_numeric(_cardStruct.toughness)){
					if (_cardStruct.toughness < 1){
						return false;	
					}
				}
			}
			
			if (!is_array(_cardStruct.abilities)){
				return false;	
			}
			
			//If the ability array is blank
			if (is_array(_cardStruct.abilities)){
				if (array_length(_cardStruct.abilities) == 0){
					return false;	
				}
				
				if (string_length(_cardStruct.abilities[0]) < 2){
					return false;		
				}
			}
		}
	}else{
		return false;	
	}
	
	//If nothing has managed to return something, the card must be valid
	return true;
}

/// @function export_button_parse_UUID(input)
/// @description Parse the theme from a string
/// @param {string} input The input string
/// @return {string} The parsed theme
function export_button_parse_UUID(input) {
    var themeStart = "Set ID: ";
    var pos = string_pos(themeStart, input);
    if (pos > 0) {
        var theme = string_copy(input, pos + string_length(themeStart), string_length(input) - pos - string_length(themeStart) + 1);
        return theme;
    } else {
        return "No UUID found";
    }
}


/// @function export_button_parse_theme(inputString)
/// @description Parses the theme from a given input string.
/// @param {string} inputString The input string to parse.
/// @returns {string} The parsed theme.
function export_button_parse_theme(inputString) {
    var themeStart = string_pos("Theme: ", inputString) + string_length("Theme: ");
    var themeEnd = string_pos("\nSet ID:", inputString) - 1;
    var theme = string_copy(inputString, themeStart, themeEnd - themeStart + 1);
    return theme;
}


/// @function UUID_generate()
/// @description Generate a pseudo-random UUID
/// @return {string} The generated UUID
function UUID_generate() {
    var _chars = "0123456789abcdef";
    var _uuid = "";
    for (var _i = 0; _i < 36; _i++) {
        if (_i == 8 || _i == 13 || _i == 18 || _i == 23) {
            _uuid += "-";
        } else if (_i == 14) {
            _uuid += "4";
        } else if (_i == 19) {
            _uuid += choose("8", "9", "a", "b");
        } else {
            _uuid += string_char_at(_chars, irandom_range(1, 16));
        }
    }
    return _uuid;
}









