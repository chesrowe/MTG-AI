// In the HTTP Async event
var _requestId = async_load[? "id"];
var _status = async_load[? "status"];

// For card text
if (_requestId == chatgptRequestId) {   
	var _response = async_load[? "result"];
	
	try {
		var _json = json_parse(_response);

		// Process the response data here
		var _generatedText = _json[$ "choices"][0][$ "text"];
		//show_message(_generatedText);
	}catch(_error){
		show_debug_message("Failed to generate text");
		chatgptRequestId = send_chatgpt_request(textPrompt);	
	}
    
	try {
		var _cardDataStruct = json_parse(_generatedText);
		currentCardStruct = _cardDataStruct;
		//show_message(_cardDataStruct.imageDescription);
		//dalleRequestId = send_dalle_request(_cardDataStruct.imageDescription);
	
		stableDiffusionRequestId = send_stableDiffusion_request(_cardDataStruct.imageDescription);
		
		textPrompt += " A card with the name '" + currentCardStruct.name + "' already exists so do not create a card named that but the card may reference it.";
   }catch(_error){
		show_debug_message("Failed to generate text");
		chatgptRequestId = send_chatgpt_request(textPrompt);
   }
}

//For card images from stable diffusion
if (_requestId == stableDiffusionRequestId) {
    try{
		var _response = async_load[? "result"];
		var _status = async_load[? "status"];
		//show_message(_status);
		//show_debug_message(_response);
		
		if (_response != undefined){
			var _imageJson = json_parse(_response);
			var _decodedImage = buffer_base64_decode(_imageJson.artifacts[0].base64);
			
			buffer_save(_decodedImage, "Card Images/" + currentCardStruct.name + ".png");
			buffer_delete(_decodedImage);
			currentCardImage = sprite_add("Card Images/" + currentCardStruct.name + ".png", 1, false, false, 0, 0);
			array_push(cardSetArray, currentCardStruct);
			screenSaved = false;
		}		
	}catch(_error){
		show_message("Failed to generate Image");
		show_message(_error);
	}
}



