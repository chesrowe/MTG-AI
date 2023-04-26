theme = "World War 2 Japan";
screenSaved = false;
chatgptRequestId = -1;
dalleRequestId = -1;
stableDiffusionRequestId = -1;
stableDiffusionModelsRequestId = -1;
textPrompt = "Create an idea for a new Magic the Gathering card with the theme of " + theme + ". Explore all aspects and characters of the theme, not just the main ones. Be creative with card abilites, come up with new ones. Generate cards of any type. Give me the card data as valid JSON and ONLY include the valid JSON and nothing else.\nOnly give me the following properties: \nname, type, subtype, power(if the card is not a creature set this to -1), toughness(if the card is not a creature set this to -1), manaCost(with each mana type with curly braces such as {3}{W}{R}), abilities(as an array), rulings(as an array), flavorText, imageDescription(A highly detailed description of the image that is on the card. It will be used to generate an image with DALLE-2. DO NOT mention the word 'card' in the imageDescription), rarity, and cardFrameSprite(This will be the sprite that is drawn for the card frame to make it match the mana color of the card, this can ONLY be one of the following: spr_cardFrameBlue, spr_cardFrameWhite, spr_cardFrameBlack, spr_cardFrameRed, or spr_cardFrameGreen).";
currentCardStruct = {
	name : "Deez Nutz",
	type : "Creature",
	subtype : "Programmer",
	manaCost : "{3}{W}{W}{B}{G}{R}{U}",
	abilities : [
		"Haste",
		"Pay {W}{B}{U}{G}{R} to die",
		"{T}: This creature makes all other creatures stupid in addition to their primary type"
	],
	flavorText : "This is a stupid flavor text that tastes really bad",
	power : 10,
	toughness : 10,
	cardFrameSprite : "spr_cardFrameBlack"
};

currentCardImage = -1;
cardSetArray = [];

nextCardButtonX1 = 1700;
nextCardButtonY1 = 10;
nextCardButtonX2 = 1900;
nextCardButtonY2 = 60;

exportButtonX1 = 1700;
exportButtonY1 = 80;
exportButtonX2 = 1900;
exportButtonY2 = 130;




