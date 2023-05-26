/// @desc Creates a new card gen job 
/// @param {string} theme The theme of the cards being generated
/// @param {real} cardNumber The number of cards being generated with the given theme
/// @param {string} interactionToken The token for the initial interaction response to the generate command
/// @param {string} userId The id of the user who sent the generate command
function job(_theme, _cardNumber, _interactionToken, _userId = -1, _excludeThemeInImageGen = false) constructor{
	theme = _theme;
	cardNumber = _cardNumber;
	cardsLeft = cardNumber;
	interactionToken = _interactionToken;
	cardTextRequestIdArray = [];
	cardTextArray = [];
	imageRequestArray = [];
	cardsWaitingToBeDrawn = [];
	completeCards = [];
	imageRequestFailures = 0;
	excludeThemeInImageGen = _excludeThemeInImageGen;
	userId = _userId;
}

function cardImageRequest(_requestId, _cardStruct) constructor {
	requestId = _requestId;
	cardStruct = _cardStruct;
}

function cardWaitingToBeDrawn(_cardStruct, _imageFilePath) constructor {
	cardStruct = _cardStruct;
	imageFilePath = _imageFilePath;
}