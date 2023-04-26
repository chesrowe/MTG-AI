#macro OPENAI_API_KEY ""
#macro STABILITY_API_KEY ""

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

    // Replace "your_OPENAI_API_KEY" with your actual API key
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
    var output = "";
    var i = 0;
    var len = string_length(text);

    while (i < len) {
        var current_char = string_char_at(text, i + 1);

        if (current_char == "{") {
            var next_char = string_char_at(text, i + 2);
            var sprite_name = "";

            switch (next_char) {
                case "W":
                    sprite_name = "spr_manaWhite";
                    break;
                case "U":
                    sprite_name = "spr_manaBlue";
                    break;
                case "B":
                    sprite_name = "spr_manaBlack";
                    break;
                case "R":
                    sprite_name = "spr_manaRed";
                    break;
                case "G":
                    sprite_name = "spr_manaGreen";
                    break;
				case "T": 
					sprite_name = "spr_tap"
					break;
                default:
                    if (string_digits(next_char)) {
                        var num = real(next_char);
                        sprite_name = "spr_manaColorless" + string(num);
                    }
                    break;
            }

            if (sprite_name != "") {
                output += "[c_white][" + sprite_name + "][c_black]";
                i += 3;
            } else {
                output += current_char;
                i += 1;
            }
        } else {
            output += current_char;
            i += 1;
        }
    }

    return output;
}

/// @function export_to_cockatrice(cards, file_name)
/// @param cards An array of card structs
/// @param file_name The name of the XML file to save
function export_to_cockatrice(cards, file_name) {
    var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
    xml += "<cockatrice_carddatabase version=\"4\">\n";
    xml += "  <sets>\n";
    xml += "    <set>\n";
    xml += "      <name>MyCustomSet</name>\n";
    xml += "      <abbreviation>CS</abbreviation>\n";
    xml += "    </set>\n";
    xml += "  </sets>\n";
    xml += "  <cards>\n";

    for (var i = 0; i < array_length(cards); ++i) {
        var card = cards[i];

        // Infer cmc, colors, and colorIdentity from manaCost
        var cmc = 0;
        var colors = "";
        var colorIdentity = "";

        var manaCost = card.manaCost;
        var start = string_pos("{", manaCost);

        while (start != 0) {
            manaCost = string_delete(manaCost, start, 1);
            var symbol = string_copy(manaCost, start, 1);
            var _end = string_pos("}", manaCost);
            manaCost = string_delete(manaCost, _end, 1);

            if (string_length(symbol) == 1 && string_pos(symbol, "WUBRG") != 0) {
                colors += symbol;
                colorIdentity += symbol;
                cmc += 1;
            } else if (string_length(symbol) > 0 && string_pos(symbol, "0123456789") != 0) {
                cmc += real(symbol);
            }

            start = string_pos("{", manaCost);
        }

        xml += "    <card>\n";
        xml += "      <name>" + card.name + "</name>\n";
        xml += "      <text>";
        for (var j = 0; j < array_length(card.abilities); ++j) {
            if (j > 0) {
                xml += "\n";
            }
            xml += card.abilities[j];
        }
        xml += "</text>\n";
        xml += "      <prop>\n";
        xml += "        <type>" + card.type;
        if (card.subtype != "") {
            xml += " - " + card.subtype;
        }
        xml += "</type>\n";
        xml += "        <maintype>" + card.type + "</maintype>\n";
        xml += "        <manacost>" + card.manaCost + "</manacost>\n";
        xml += "        <cmc>" + string(cmc) + "</cmc>\n";
        xml += "        <colors>" + colors + "</colors>\n";
        xml += "        <coloridentity>" + colorIdentity + "</coloridentity>\n";
        xml += "        <pt>" + string(card.power) + "/" + string(card.toughness) + "</pt>\n";
        xml += "      </prop>\n";
        xml += "      <set rarity=\"" + card.rarity + "\">CS</set>\n";
		xml += "      <flavor>" + card.flavorText + "</flavor>\n";
        xml += "    </card>\n";
    }

    xml += "  </cards>\n";
    xml += "</cockatrice_carddatabase>";

    // Save the XML to a file
    var file = file_text_open_write(file_name);
    file_text_write_string(file, xml);
    file_text_close(file);
}

// Define a function to generate a version 4 UUID
function generate_UUID(){
    // Generate a random 16-byte array
    var bytes = array_create(16);
    for (var i = 0; i < 16; i++) {
        bytes[i] = irandom(255);
    }

    // Set the version bits (bits 12-15) to 0100 (version 4)
    bytes[6] = (bytes[6] & 0x0F) | 0x40;

    // Set the variant bits (bits 10-11) to 10 (RFC 4122 variant)
    bytes[8] = (bytes[8] & 0x3F) | 0x80;

    // Convert the byte array to a string in the format "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    var hexChars = "0123456789abcdef";
    var uuid = "";
    for (var i = 0; i < 16; i++) {
        var hexByte = bytes[i];
        var hex1 = string_char_at(hexChars, (hexByte >> 4) & 0x0F + 1);
        var hex2 = string_char_at(hexChars, (hexByte & 0x0F) + 1);
        uuid += hex1 + hex2;
        if (i == 3 || i == 5 || i == 7 || i == 9) {
            uuid += "-";
        }
    }

    return uuid;
}








