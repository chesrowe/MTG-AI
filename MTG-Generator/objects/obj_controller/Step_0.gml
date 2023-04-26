if (mouse_check_button_pressed(mb_left)) {
    if (mouse_x >= nextCardButtonX1 && mouse_x <= nextCardButtonX2 && mouse_y >= nextCardButtonY1 && mouse_y <= nextCardButtonY2) {
		chatgptRequestId = send_chatgpt_request(textPrompt);	
    } else if (mouse_x >= exportButtonX1 && mouse_x <= exportButtonX2 && mouse_y >= exportButtonY1 && mouse_y <= exportButtonY2) {
        // Export cards
		export_to_cockatrice(cardSetArray, theme + ".xml");
    }
}