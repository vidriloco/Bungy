Core = function(map) {
	var Modes = {Collection: 1, Member: 2};
	
	var map;
	var currentState = { mode: Modes.Collection, gpsUnit: null };
	
	var initialize = function(map) {
		this.map = map;
		$(document).on( "click", '#close-panel', function() {
			itemUrlSwitch();
		});
		setInterval(willFetchUpdate, 10000);
	}
	
	var itemUrlSwitch = function(url) {
		if(currentState.mode == Modes.Member) {
			window.location.hash="#/";
		} else if(url != undefined) {
			window.location.hash=url;			
		}
	}
	
	var domReferenceToCurrentMember = function() {
		return $('*[data-gps-id='+currentState.gpsUnit+']');
	}
	
	var willFetchUpdate = function(callback) {
		var url;
		//if(currentState.mode == Modes.Collection) {
			url = '/heading.js';
		//} else {
			//url = '/heading/'+currentState.gpsUnit+'.js';
		//}
		
		$.ajax({
			url: url,
			success: function() {
				if(callback != undefined) {
					callback();
				}
				afterFetchUpdatedWithSuccess();
			},
			dataType: 'script'
		});
	}
	
	var afterFetchUpdatedWithSuccess = function() {
		if(currentState.mode == Modes.Member) {
			makePanelAppear();
			map.placeViewportAt({lat: domReferenceToCurrentMember().attr('data-lat'), lon: domReferenceToCurrentMember().attr('data-lng') });
		}
		updateMapObjects();
	}
	
	var makePanelAppear = function() {
		$('#current').html('');
		$('#current').html($('*[data-gps-id='+currentState.gpsUnit+']').clone());
	}
	
	var updateMapObjects = function() {
		var trucks = $('#instant-list').children();
		
		map.resetMarkersList();
		for(idx = 0 ; idx < trucks.length ; idx++) {
			var lat = parseFloat($(trucks[idx]).attr('data-lat'));
			var lon = parseFloat($(trucks[idx]).attr('data-lng'));
			var idD = $(trucks[idx]).attr('data-gps-id');
			
			map.addCoordinatesAsMarkerToList({ lat: lat, lon: lon, iconName: 'shipment', resourceUrl: idD }, function(opts) {
				itemUrlSwitch("#/gps/"+idD);
			});
		}
	}
		
	this.onIndex = function() {
		currentState.mode = Modes.Collection;
		$('#current').html('');
	}
	
	this.onInstant = function() {
		currentState.mode = Modes.Member;
		willFetchUpdate(function() {
			currentState.gpsUnit = $('#instant-'+this.params['id']).attr('data-gps-id');
		});
	}
	
	this.onGPS = function() {
		currentState.mode = Modes.Member;
		currentState.gpsUnit = this.params['gps_unit'];
		willFetchUpdate();
	}
	
	initialize(map);
}