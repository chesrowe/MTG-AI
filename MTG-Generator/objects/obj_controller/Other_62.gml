// In the HTTP Async event
var _requestId = async_load[? "id"];
var _status = async_load[? "status"];

var _i = 0;
var _markedForDeletion = [];

repeat(array_length(jobsInProgressArray)){
	var _currentJob = jobsInProgressArray[_i];
	
	//Card text
	var _j = 0;
	
	repeat(array_length(_currentJob.cardTextRequestIdArray)){
		var _currentTextRequestId = _currentJob.cardTextRequestIdArray[_j];
		
		if (_currentTextRequestId == _requestId){
			//Add card text struct to the job and send off prompt for the card image
			var _response = async_load[? "result"];
	
			try {
				var _responseData = json_parse(_response);

				// Process the response data here
				var _generatedText = _responseData[$ "choices"][0][$ "text"];
				var _cardDataStruct = json_parse(_generatedText);
				array_push(_currentJob.cardTextArray, _cardDataStruct);
	
				var _imagePrompt = "";
				
				if (!_currentJob.excludeThemeInImageGen){				
					_imagePrompt += _currentJob.theme + ", ";	
				}
				
				_imagePrompt += _cardDataStruct.name + ", " + _cardDataStruct.imageDescription;
				
				var _imageRequestId = stableDiffusion_request_send(_imagePrompt);
				var _imageRequestStruct = new cardImageRequest(_imageRequestId, _cardDataStruct);
				array_push(_currentJob.imageRequestArray, _imageRequestStruct);
		   }catch(_error){
				show_debug_message("Failed to generate text");
				discord_error(_error);
				_currentJob.cardTextRequestIdArray[_j] = chatgpt_request_send(card_prompt(_currentJob.theme, _currentJob.cardTextArray));	
		   }
		   
		   break;
		}
		
		_j++;
	}
	
	//Card images
	var _j = 0;
	
	repeat(array_length(_currentJob.imageRequestArray)){
		var _currentTextRequest = _currentJob.imageRequestArray[_j];
		var _currentImageRequestId = _currentTextRequest.requestId;
		
		if (_currentImageRequestId == _requestId){
			 try{
				var _response = async_load[? "result"];
				var _status = async_load[? "status"];
		
				if (is_string(_response)){
					var _responseData = json_parse(_response);
					//show_debug_message(_responseData.finish_reason);
					
					if (variable_struct_exists(_responseData, "artifacts")){
						var _decodedImage = buffer_base64_decode(_responseData.artifacts[0].base64);
			
						var _imageFilePath = "Card Images/" + _currentTextRequest.cardStruct.name + ".png";
						buffer_save(_decodedImage, _imageFilePath);
						buffer_delete(_decodedImage);
					
						var _cardImageTextPair = new cardWaitingToBeDrawn(_currentTextRequest.cardStruct, _imageFilePath);
						array_push(_currentJob.cardsWaitingToBeDrawn, _cardImageTextPair);
						magicBot.interactionResponseEdit(_currentJob.interactionToken, "Card(s) generating (" + string(array_length(_currentJob.cardsWaitingToBeDrawn)) + " of " + string(_currentJob.cardNumber) + ")", function(){
							//show_message(async_load[? "result"]);	
						});
					
						if (array_length(_currentJob.cardsWaitingToBeDrawn) >= _currentJob.cardNumber){
							array_push(jobsWaitingToBeDrawnAndSentArray, _currentJob);
							array_push(_markedForDeletion, _i);
						}else{
							var _nextCardTextRequest = chatgpt_request_send(card_prompt(_currentJob.theme, _currentJob.cardTextArray));
							array_push(_currentJob.cardTextRequestIdArray, _nextCardTextRequest);
						}
					}else{
						var _response = async_load[? "result"];
						_currentJob.imageRequestFailures++;			
					}
				}
			}catch(_error){
				show_debug_message("Failed to generate Image, resending request...");
				discord_error(_error);
				//Try and send off another
				_currentJob.imageRequestFailures++;
				
				if (_currentJob.imageRequestFailures < 5){
					var _imageRequestId = stableDiffusion_request_send(_currentJob.theme + "," + _currentTextRequest.cardStruct.name + "," + _currentTextRequest.cardStruct.imageDescription);
					var _imageRequestStruct = new cardImageRequest(_imageRequestId, _currentTextRequest.cardStruct);
					_currentJob.imageRequestArray[_j] = _imageRequestStruct; 
				}else{
					array_push(jobsWaitingToBeDrawnAndSentArray, _currentJob);
					array_push(_markedForDeletion, _i);		
				}
			}	
			
			break;
		}
		
		_j++;
	}
	
	
	_i++;		
}

var _a = 0;

repeat(array_length(_markedForDeletion)){
	//array_delete(jobsInProgressArray, jobsInProgressArray[_a], 1);
	_a++;
}





