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
			coordinatesDom: "#coordinates"
		});

		var updateHeading = function() {
			$.ajax({
				url: '/heading.js',
				success: updateMapObjects,
				dataType: 'script'
			});
		}
		
		var updateMapObjects = function() {
			var trucks = $('#instant-list').children();
			
			map.resetMarkersList();
			for(idx = 0 ; idx < trucks.length ; idx++) {
				var lat = parseFloat($(trucks[idx]).attr('data-lat'));
				var lon = parseFloat($(trucks[idx]).attr('data-lng'));
				var idD = $(trucks[idx]).attr('id');
				
				map.addCoordinatesAsMarkerToList({ lat: lat, lon: lon, iconName: 'shipment', resourceUrl: idD }, function(opts) {
					//itemUrlSwitch($('.listing-view #'+opts["resourceUrl"]), opts["resourceUrl"]);
				});
			}
		}
		
		setInterval(updateHeading, 10000);
	}

});