package com.middlemeetup
{
	import com.mapquest.LatLngCollection;
	import com.mapquest.services.geocode.GeocoderLocation;
	import com.mapquest.services.geocode.GeocoderResponse;
	import com.mapquest.services.search.SearchResult;
	
	import mx.collections.ArrayList;

	[Bindable]
	public class Model
	{
		
		public static var instance:Model = new Model();
		
		public var meetingId:String;
		
		public var yourName:String;
		
		public var yourLocation:String;
		
		public var yourLocationGeocoderLocation:GeocoderLocation;
		
		public var theirName:String;
		
		public var theirLocation:String;
		
		public var theirLocationGeocoderLocation:GeocoderLocation;
		
		public var meetingSpots:ArrayList;
		
		public var lineLatLngCollection:LatLngCollection;
		
		public var selectedMeetingSpot:SearchResult;
		
	}
}