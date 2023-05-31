/// Async Networking event
var _data = async_load;
var _socketId = _data[? "id"];

/* 
   Here we are looping through each bot and seeing which one had a gateway event fire.
   Once we find the responible bot via its _socketId, we process the event accordingly
*/

var _i = 0;

repeat(array_length(obj_discordController.botArray)){
	var _currentBot = obj_discordController.botArray[_i];
	
	if (_currentBot.__gatewaySocket == _socketId){
		/// Async Networking event
		switch (async_load[? "type"]) {
			case network_type_connect:
				//This event never seems to be triggered
				__discordTrace("Connected!");
		        break;
			
			case network_type_disconnect:
				//Doesn't ever get triggered 
				var _url = "wss://gateway.discord.gg/?v=10&encoding=json";
				network_destroy(_currentBot.__gatewaySocket);
				_currentBot.__gatewaySocket = network_create_socket_ext(network_socket_wss, 443);
				_currentBot.__gatewayConnection = network_connect_raw_async(_currentBot.__gatewaySocket, _url, 443);
				__discordTrace("DISCONNECTED");
				break;

			case network_type_data:
				var _receivedData = discord_gateWay_event_parse();
		
				// Event Handling
				switch (_receivedData.op){
				    //This event is the first event that is received. For setting up an initial heartbeat with the gateway
					case DISCORD_GATEWAY_OP_CODE.hello:
						if (_currentBot.__gatewayReconnect){
							_currentBot.__gatewaySendResume();	
						}
						
						_currentBot.__gatewaySendHeartbeat();
				        var _heartbeatInterval = floor(_receivedData.d.heartbeat_interval / 1000);  // Convert ms to seconds
						__discordTrace("hello: Heartbeat interval: " + string(_heartbeatInterval));
						
						//Make sure a heartbeat timesource doesn't already exist
						if (time_source_exists(_currentBot.__gatewayHeartbeatTimeSource)){
							time_source_destroy(_currentBot.__gatewayHeartbeatTimeSource);		
						}
						
						//Create a Time Source to send heartbeats
						_currentBot.__gatewayHeartbeatTimeSource = time_source_create(
					        time_source_global,
					        _heartbeatInterval,
					        time_source_units_seconds,
					        _currentBot.__gatewaySendHeartbeat,
							[],
							-1
				        );
				        time_source_start(_currentBot.__gatewayHeartbeatTimeSource);					
				        break;
				
					//Discord acknowledges each heartbeat sent over the gateway
					case DISCORD_GATEWAY_OP_CODE.heartbeatACK:
						__discordTrace("Heartbeat received");
						break;
				
					//Heartbeats must be sent if requested
					case DISCORD_GATEWAY_OP_CODE.heartbeat:
						__discordTrace("Heatbeat required");
						_currentBot.__gatewaySendHeartbeat();
						break;
						
					//attempt to reconnect and resume 
					case DISCORD_GATEWAY_OP_CODE.reconnect:
						__discordTrace("Reconnect required, attempting...");			
						__discord_gateway_reconnect(_currentBot);
						break;
						
					case DISCORD_GATEWAY_OP_CODE.invalidSession:
						__discordTrace("Session invalid, reconnecting...");
						var _sessionIsResumable = _receivedData.d;
							
						if (_sessionIsResumable){
							__discordTrace("Session invalid is resumable, attempting to resume session");	
							__discord_gateway_reconnect(_currentBot);
						}else{
							__discordTrace("Session invalid is NOT resumable, creating new connection");	
							__discord_gateway_new_connection(_currentBot);
						}
						break;
				
					//Identity handshakes and normal gateway events sent from your discord app
					case DISCORD_GATEWAY_OP_CODE.dispatch:
						// Store the sequence number if it exists
						if (_receivedData.s != pointer_null) {
						    _currentBot.__gatewaySequenceNumber = _receivedData.s;
						}
					
						if (is_string(_receivedData.t)){
							var _eventName = _receivedData.t; 
							var _eventData = _receivedData.d;
							__discordTrace(_eventName);
							
							switch (_eventName){
								/*
								   Before your app can start receiving gateway events, an indentity handshake must be performed.
								   This response confirms the handshake has succeeded.
								*/
								case "READY":
									_currentBot.__gatewayIndentityHandshake = true;
									_currentBot.__gatewayResumeUrl = _eventData.resume_gateway_url;
									_currentBot.__gatewaySessionId = _eventData.session_id;
									__discordTrace("Identity handshake complete");
									break;
								
								//This executes the callbacks for events defined in the gatewayEventCallback struct for your bot
								default: 
									if (variable_struct_exists(_currentBot.gatewayEventCallbacks, _receivedData.t)){
										var _callback = _currentBot.gatewayEventCallbacks[$	_receivedData.t];
										_callback();
									}
									break
							}
						}
						break;
				}
				break;
		}	
	}
	
	_i++;
}

