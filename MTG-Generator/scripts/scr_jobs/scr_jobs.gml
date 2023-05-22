/// @desc Creates a new card gen job 
/// @param {string} theme The theme of the cards being generated
/// @param {real} cardNumber The number of cards being generated with the given theme
/// @param {string} interactionToken The token for the initial interaction response to the generate command
function job(_theme, _cardNumber, _interactionToken){
	theme = _theme;
	cardNumber = _cardNumber;
	cardsLeft = cardNumber;
	interactionToken = _messageId;
	cardTextRequestIdArray = [];
	cardTextArray = [];
	imageRequestIdArray = [];
	cardImages = [];
}