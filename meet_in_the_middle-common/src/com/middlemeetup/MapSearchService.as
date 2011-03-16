package com.middlemeetup
{
	import com.mapquest.LatLng;
	import com.mapquest.LatLngCollection;
	import com.mapquest.services.directions.Directions;
	import com.mapquest.services.directions.DirectionsEvent;
	import com.mapquest.services.geocode.Geocoder;
	import com.mapquest.services.geocode.GeocoderEvent;
	import com.mapquest.services.geocode.GeocoderLocation;
	import com.mapquest.services.search.Search;
	import com.mapquest.services.search.SearchEvent;
	import com.mapquest.services.search.SearchHostedData;
	import com.mapquest.services.search.SearchRequestCorridor;
	import com.mapquest.services.search.SearchRequestRadius;
	import com.mapquest.services.search.SearchResult;
	import com.mapquest.tilemap.TileMap;
	import com.mapquest.tilemap.TilemapComponent;
	import com.mapquest.tilemap.controls.shadymeadow.SMLargeZoomControl;
	import com.mapquest.tilemap.controls.shadymeadow.SMViewControl;
	import com.mapquest.tilemap.controls.standard.LargeZoomControl;
	import com.mapquest.tilemap.controls.standard.ViewControl;
	import com.mapquest.util.GeodesicCalculatorUtil;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;

	[Event(name="meetingResult", type="com.middlemeetup.MeetingEvent")]
	
	public class MapSearchService extends EventDispatcher
	{
		
		public static const mqApiKey:String = "Fmjtd%7Cluu22lu22h%2C8l%3Do5-5f8lg";
		
		public function MapSearchService()
		{
			tileMap = new TileMap(mqApiKey);
		}
		
		private var tileMap:TileMap;
		
		private var centerLatLng:LatLng;
		
		public function getLocations():void
		{
			var directions:Directions = new Directions(tileMap);
			directions.addEventListener(DirectionsEvent.DIRECTIONS_SUCCESS, handleDirectionsSuccess);
			directions.locations = [Model.instance.yourLocation, Model.instance.theirLocation];
			directions.route();
		}
		
		private function handleDirectionsSuccess(event:DirectionsEvent):void
		{
			if (event.routeType == "route")
			{
				Model.instance.yourLocationGeocoderLocation = getGeocoderLocationFromXml(event.locationsXml.location[0]);
				Model.instance.theirLocationGeocoderLocation = getGeocoderLocationFromXml(event.locationsXml.location[1]);
				
				var distanceBetweenLocations:Number = GeodesicCalculatorUtil.calculateGeodesicDistance(Model.instance.yourLocationGeocoderLocation.displayLatLng, Model.instance.theirLocationGeocoderLocation.displayLatLng);
				
				var search:Search = new Search(tileMap);
				search.addEventListener(SearchEvent.SEARCH_RESPONSE, handleSearchResponse);
					
				var request:SearchRequestRadius = new SearchRequestRadius();
				request.origin = new LatLng((Model.instance.yourLocationGeocoderLocation.displayLatLng.lat + Model.instance.theirLocationGeocoderLocation.displayLatLng.lat) / 2, (Model.instance.yourLocationGeocoderLocation.displayLatLng.lng + Model.instance.theirLocationGeocoderLocation.displayLatLng.lng) / 2);
				request.maxMatches = 20;
				request.radius = (distanceBetweenLocations * 0.1); // max radius of one tenth the total distance between locations
				
				var hostedData:SearchHostedData = new SearchHostedData("MQA.NTPois");
				hostedData.extraCriteria = "facility = '5800' OR facility = '9996'";
				
				request.hostedDataList = [hostedData];

				search.search(request);
			}
			else if (event.routeType == "routeShape")
			{
				Model.instance.lineLatLngCollection = new LatLngCollection();
				Model.instance.lineLatLngCollection.addFromXml(event.shapePointsXml);
			}
		}
		
		private function handleSearchResponse(event:SearchEvent):void
		{
			var meetingResultEvent:MeetingEvent = new MeetingEvent(MeetingEvent.MEETING_RESULT, event.searchResponse.results);
			dispatchEvent(meetingResultEvent);
		}
		
		private function getGeocoderLocationFromXml(xml:XML):GeocoderLocation
		{
			var geocoderLocation:GeocoderLocation = new GeocoderLocation();
			geocoderLocation.street = xml.street;
			geocoderLocation.displayLatLng = new LatLng(Number(xml.latLng.lat), Number(xml.latLng.lng));
			geocoderLocation.city = xml.adminArea5;
			geocoderLocation.state = xml.adminArea3;
			return geocoderLocation;
		}
		
	}
}