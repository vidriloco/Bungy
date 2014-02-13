//= require concerns/extensions
//= require concerns/gmap

document.writeln("<script src='http://maps.google.com/maps/api/js?libraries=geometry&sensor=true' type='text/javascript'></script>");


$(document).on('rails_admin.dom_ready', function(){ 
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
			coordinatesDom: "#checkpoint",
			isEditable: true
		});
		
		map.setCoordinatesFromDom('#checkpoint', 11);
	}
});