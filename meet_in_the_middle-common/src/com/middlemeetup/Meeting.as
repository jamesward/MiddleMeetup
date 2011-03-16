package com.middlemeetup
{
	[RemoteClass(alias="com.middlemeetup.Meeting")]
	public class Meeting
	{
		public var id:String;
		
		public var initiatorName:String;
		
		public var initiatorLocation:String;
		
		public var responderName:String;
		
		public var responderLocation:String;
	}
}