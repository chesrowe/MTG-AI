#macro OPENAI_API_KEY "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"
#macro STABILITY_API_KEY "sk-C5QldRF1OkJ9QOFvWJ7u70UcXnINdPOXEwGB2YmNMVzbKqeA"
#macro USE_DALLE false

randomize();
global.emptyStruct = {};

/**
 * Sends a request to the ChatGPT API with the given prompt.
 * @param {string} prompt - The prompt to send to the ChatGPT API.
 * @returns The request ID associated with the API call.
 */
function send_chatgpt_request(_prompt) {
    var _url = "https://api.openai.com/v1/completions";
    var _headers = ds_map_create();
    var _data = {
				model: "text-davinci-003",
				prompt: string(_prompt), 
				max_tokens: int64(1024), 
				n: int64(1), 
				stop: "null", 
				temperature: 0.7
			}
			
	var _dataJson = json_stringify(_data);
	show_debug_message("Text data: " +_dataJson);

    // Replace "your_OPENAI_API_KEY" with your actual API key
    ds_map_add(_headers, "Authorization", "Bearer " + OPENAI_API_KEY);
    ds_map_add(_headers, "Content-Type", "application/json");

    // Send the POST request
    var _request_id = http_request(_url, "POST", _headers, _dataJson);

    // Clean up the headers map
    ds_map_destroy(_headers);

    return _request_id;
}

/**
 * Sends a request to the Dalle API with the given prompt.
 * @param {string} prompt - The prompt to send to the Dalle-2 API.
 * @returns The request ID associated with the API call.
 */
function send_dalle_request(_prompt) {
    var _url = "https://api.openai.com/v1/images/generations";
    var _headers = ds_map_create();
    var _data = {
				prompt: string(_prompt) + "Magic the Gathering, Highly detailed, gothic, dark fantasy, realistic digital painting, masterpiece, 4K. By Adam Paquette", 
				size: "1024x1024"
			}
			
	var _dataJson = json_stringify(_data);
	show_debug_message("Image data: " + _dataJson);

    // Headers
    ds_map_add(_headers, "Authorization", "Bearer " + OPENAI_API_KEY);
    ds_map_add(_headers, "Content-Type", "application/json");

    // Send the POST request
    var _request_id = http_request(_url, "POST", _headers, _dataJson);

    // Clean up the headers map
    ds_map_destroy(_headers);

    return _request_id;
}

/**
 * Sends a request to the Stable Diffusion API with the given prompt.
 * @param {string} prompt - The prompt to send to the Stable-Diffusion API.
 * @returns The request ID associated with the API call.
 */
function send_stableDiffusion_request(_prompt) {
	var _xl = "stable-diffusion-xl-beta-v2-2-2"
    var _url = "https://api.stability.ai/v1/generation/stable-diffusion-xl-beta-v2-2-2/text-to-image";
    var _headers = ds_map_create();
    var _data = {
				text_prompts: [
					{
						text : string(currentCardStruct.name + ". " + theme + ". " +  _prompt + ". Magic the Gathering, Highly detailed, gothic, dark fantasy, realistic digital painting, masterpiece, 4K. By Christopher Rush"),
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
    ds_map_add(_headers, "Authorization", "Bearer " + string(STABILITY_API_KEY));


    // Send the POST request
    var _request_id = http_request(_url, "POST", _headers, _dataJson);

    // Clean up the headers map
    ds_map_destroy(_headers);

    return _request_id;
}

function get_stableDiffusion_models() {
    var _url = "https://api.stability.ai/v1/engines/list";
    var _headers = ds_map_create();
    var _data = { }
			
	var _dataJson = json_stringify(_data);
	show_debug_message("Image data: " + _dataJson);

    ds_map_add(_headers, "Authorization", "Bearer " + string(STABILITY_API_KEY));

    // Send the POST request
    var _request_id = http_request(_url, "GET", _headers, _dataJson);

    // Clean up the headers map
    ds_map_destroy(_headers);

    return _request_id;
}

/// @function parse_magic_symbols(text)
/// @param text The input text containing symbols
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
                    if (string_digits(_nextChar)) {
                        var num = real(_nextChar);
                        _spriteName = "spr_manaColorless" + string(num);
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

/// @function export_to_cockatrice(cards, file_name)
/// @param cards An array of card structs
/// @param file_name The name of the XML file to save
function export_to_cockatrice(cards, fileName) {
    var _xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
    _xml += "<cockatrice_carddatabase version=\"4\">\n";
    _xml += "  <sets>\n";
    _xml += "    <set>\n";
    _xml += "      <name>MyCustomSet</name>\n";
    _xml += "      <abbreviation>CS</abbreviation>\n";
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
        for (var _j = 0; _j < array_length(_card.abilities); ++_j) {
            if (_j > 0) {
                _xml += "\n";
            }
            _xml += _card.abilities[_j];
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
        _xml += "        <pt>" + string(_card.power) + "/" + string(_card.toughness) + "</pt>\n";
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









