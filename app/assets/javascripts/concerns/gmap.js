var defaultZoom = 13;
var defaultMiddleZoom = 16;
var defaultLat = 19.322721;
var defaultLon = -99.184570;
var ViewComponents = {
	Map: {}
};

$.extend(ViewComponents, {
	Map : function(gMap, opts, callback) {
		var obj = {
			initialize: function(googleMap, opts, callback) {
				this.gMap = googleMap;
				this.lastMarker = null;
				this.markerList = [];
				this.polygonList = [];
				this.lineList = [];
				this.lastLine = null;
				this.editable = false;
				this.mode = 'points';
				this.domElementForCoordinates = null;
				this.markerYourLocation = null;

				// Setting options
				this.setMapOptions(opts);

				var instance = this;
				// predefined events binding 
				google.maps.event.addListener(this.gMap, "click", function(event) {
					if(instance.pointsModeEnabled() && instance.isEditable()) {
						instance.propagateClickEvent(event.latLng);
					} 
				});
								
				return this;
			},

			resize: function() {
				var center = this.gMap.getCenter();
				google.maps.event.trigger(this.gMap, 'resize');
				this.gMap.setCenter(center);
			},

			setMapOptions: function(opts) {

				if(opts != undefined) {

					if(opts.isEditable != undefined) {
						this.editable = opts.isEditable;
					}

					if(opts.addressDom != undefined) {
						this.domElementForAddress = opts.addressDom;
					}

					if(opts.coordinatesDom != undefined) {
						this.domElementForCoordinates = opts.coordinatesDom;
					}
				}
			},
			
			eventsForMapCenterChanged: function(baseDom, callback_function) {
				var instance = this;
				this.baseDom = $(baseDom);

				google.maps.event.addListener(this.gMap, "center_changed", function() {
					instance.setSearchMapParams();
					if(typeof callback_function == 'function') {
						callback_function();
					}
					return true;
				});
			},
			
			eventsForMapIdle: function(baseDom, callback_function) {
				var instance = this;
				this.baseDom = $(baseDom);

				google.maps.event.addListener(this.gMap, "idle", function() {
					instance.setSearchMapParams();
					if(typeof callback_function == 'function') {
						callback_function();
					}
					return true;
				});
			},

			// using the convention for dom_lat and dom_lon retrieve
			// the coordinates components for setting them on the map
			setCoordinatesFromDom: function(coordinates, zoom) {
				var latitude = coordinates+"_lat";
				var longitude = coordinates+"_lon";
				if($.isDefined(latitude) && $.isDefined(longitude)) {	
					var lat = $(latitude).val();
					var lon = $(longitude).val();

					if(lat != "" && lon != "") {
						if(zoom == undefined) {
							zoom = 18;
						}
						this.simulatePinPoint(lat, lon, zoom);
					}
				}
			},

			setCoordinatesFromPair: function(latitude, longitude) {
				this.placeViewportAt({ lat: latitude, lon: longitude });
			},

			placeMapOn: function(opts) {
				this.placeViewportAt(opts);
				if(opts.iconName) {
					this.setMarkerOnPosition(this.gMap.getCenter(), opts.iconName);
				} else {
					this.setMarkerOnPosition(this.gMap.getCenter());
				}
			},

			placeViewportAt: function(opts) {
				if(("lat" in opts) && ("lon" in opts)) {
					this.gMap.setCenter(new google.maps.LatLng(parseFloat(opts.lat), parseFloat(opts.lon)));
				}

				if("zoom" in opts) {
					this.gMap.setZoom(opts.zoom);
				}
			},

			simulatePinPointSearch: function(opts) {
				this.placeViewportAt(opts);
				this.setSearchMapParams();
			},

			simulatePinPoint: function(lat, lon, zoom) {
				if(zoom != undefined) {
					this.placeViewportAt({zoom : zoom, lat: lat, lon : lon});
				}
				// this blocks mimics what method writePointToDom does
				this.propagateClickEvent(new google.maps.LatLng(lat, lon));
			},

			enableSearch: function(baseDom, callback) {
				var instance = this;
				this.baseDom = $(baseDom);

				google.maps.event.addListener(this.gMap, "idle", function() {
					instance.setSearchMapParams();
					callback();
					return true;
				});
			},

			setSearchMapParams: function() {
				var limits = this.gMap.getBounds();
				var ne = limits.getNorthEast();
				var sw = limits.getSouthWest();

				$(this.baseDom).attr('sw', sw.lat() + "," + sw.lng());
				$(this.baseDom).attr('ne', ne.lat() + "," + ne.lng());
				return true;
			},

			propagateClickEvent: function(latLng) {
				this.writeCoordinatesToDom(latLng);
				this.setMarkerOnPosition(latLng);
				this.writeAddressOn(latLng);
			},

			setMarkerOnPosition: function(latLng, iconName) {
				var marker = this.lastMarker;

				if(marker != null) {
					marker.setMap(null);
				} 

				var opts = { position: latLng, map: this.gMap };
				if(iconName) {
					opts = $.extend(opts, {icon: $.assetsURL+iconName+'.png'});
				}

				marker = new google.maps.Marker(opts);
				this.lastMarker = marker;
			},

			writeCoordinatesToDom: function(latLng) {
				$(this.domElementForCoordinates+"_lat").val(latLng.lat());
				$(this.domElementForCoordinates+"_lon").val(latLng.lng());
			},

			writeAddressOn: function(latLng) {
				if(this.domElementForAddress) {
					var geocoder = new google.maps.Geocoder();
					var instance = this;

					geocoder.geocode({'location': latLng}, function(results, status) {        
						if (status == google.maps.GeocoderStatus.OK) {
							var address = results[0].formatted_address;
							$(instance.domElementForAddress).html(""+address+"");
						} 
					});
				}
			},

			addMarkerYourLocation: function(opts) {
				if(opts.lat=="" || opts.lon=="") {
					return false;
				}

				var map = this.gMap;
				var marker = new google.maps.Marker({
					position: new google.maps.LatLng(opts.lat, opts.lon),
					map: map,
					icon: $.assetsURL()+'here.png'
				});
				this.markerYourLocation = marker;
			},

			addCoordinatesAsMarkerToList: function(opts, callback) {
				if(opts.lat=="" || opts.lon=="") {
					return false;
				}
				var map = this.gMap;

				var markerOpts = {
					position: new google.maps.LatLng(opts.lat, opts.lon),
					map: map
				};

				if(opts.iconName != undefined) {
					markerOpts = $.extend(markerOpts, {	icon: $.assetsURL() + opts.iconName + '.png'})
				}

				var marker = new google.maps.Marker(markerOpts);
				opts.marker = marker;
				google.maps.event.addListener(marker, 'click', function() {
					callback(opts);
				});
				this.markerList.push(marker);
			},

			clearPolygonsList: function() {
				this.clearGeographicObject(this.polygonList);
			},

			addPolygonNamed: function(points, name, callback) {
				var polygonCoords = [];
				for(var idx in points) {
					var pairs = points[idx].trim().split(' ');
					var lon = parseFloat(pairs[0]);
					var lat = parseFloat(pairs[1]);
					polygonCoords.push(new google.maps.LatLng(lat, lon));
				}
				var polygon = new google.maps.Polygon({
				    paths: polygonCoords,
				    strokeColor: "#FF0000",
				    strokeOpacity: 0.8,
				    strokeWeight: 2,
				    fillColor: "#FF0000",
				    fillOpacity: 0.35
				  });

				polygon.setMap(this.gMap);
				google.maps.event.addListener(polygon, 'click', function() {
					callback({name: name});
				});
				this.polygonList.push(polygon);
			},

			resetMarkersList: function() {
				this.clearGeographicObject(this.markerList);
			},

			clearGeographicObject: function(objectList) {
				if (objectList) {
					for (i in objectList) {
						objectList[i].setMap(null);
					}
				}
			},

			reset: function() {
				this.resetMarkersList();
				if(this.lastMarker != null) {
					this.lastMarker.setMap(null);
				}
				this.lastMarker = null;

				//this.setEditable(false);
				this.placeViewportAt({zoom: defaultZoom });
			},

			isEditable: function() {
				return this.editable;
			},

			setEditable: function(status) {
				this.editable = status;
			},

			setLinesModeOn: function() {
				this.mode = 'lines';
			},

			setPointsModeOn: function() {
				this.mode = 'points';
			},

			pointsModeEnabled: function() {
				return this.mode == 'points';
			},

			linesModeEnabled: function() {
				return this.mode == 'lines';
			}
		}
		return obj.initialize(gMap, opts, callback);
	}
});