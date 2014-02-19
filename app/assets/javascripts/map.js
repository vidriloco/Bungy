$(document).ready(function() {
	
	if($.isDefined('#map')) {
		mapOptions = {
			center: new google.maps.LatLng(parseFloat(defaultLat), parseFloat(defaultLon)),
			zoom: defaultZoom,
			mapTypeId: google.maps.MapTypeId.ROADMAP,
			streetViewControl: true,
			mapTypeControl: false,
			navigationControl: false,
			navigationControlOptions: {
				position: google.maps.ControlPosition.TOP_RIGHT
			},
			zoomControlOptions: { style: google.maps.ZoomControlStyle.SMALL }
		};

		map = new ViewComponents.Map(new google.maps.Map(document.getElementById("map"), mapOptions), {
			coordinatesDom: "#coordinates",
			addressDom: "#current .address"
		});
				
	}
	
	if($.isDefined('#tracking')) {		
		var core = new Core(map);
		Path.map("#/").to(core.onIndex);
		Path.map("#/gps/:gps_unit").to(core.onGPS);
		Path.map("#/instant/:id").to(core.onInstant);
		Path.root("#/");
		Path.listen();
	}
});