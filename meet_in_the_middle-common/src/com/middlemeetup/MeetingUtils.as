package com.middlemeetup
{
	import com.mapquest.services.search.SearchResult;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	public class MeetingUtils
	{
		public static function openLocationMap(searchResult:SearchResult):void
		{
			navigateToURL(new URLRequest("http://maps.google.com/maps?q=" + searchResult.fields['Address'] + " " + searchResult.fields['City'] + ", " + searchResult.fields['State']));
		}
	}
}