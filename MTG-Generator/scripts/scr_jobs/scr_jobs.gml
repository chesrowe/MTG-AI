/// @desc Creates a new card gen job 
/// @param {string} theme The theme of the cards being generated
/// @param {real} cardNumber The number of cards being generated with the given theme
/// @param {string} interactionToken The token for the initial interaction response to the generate command
/// @param {string} UUID Unique id for this job, used for finding card exports
/// @param {string} userId The id of the user who sent the generate command
/// @param {bool} excludeThemeInImageGen whether or not to exclude the theme in the image gen prompt
/// @param {real} temperature a custom temperature for the text generation
function job(_theme, _cardNumber, _interactionToken, _UUID, _userId = -1, _excludeThemeInImageGen = false, _temperature = 1.0) constructor{
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
	temperature = _temperature;
	UUID = _UUID;
}

function cardImageRequest(_requestId, _cardStruct) constructor {
	requestId = _requestId;
	cardStruct = _cardStruct;
}

function cardWaitingToBeDrawn(_cardStruct, _imageFilePath) constructor {
	cardStruct = _cardStruct;
	imageFilePath = _imageFilePath;
}