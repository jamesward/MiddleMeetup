package com.middlemeetup
{
	import flash.events.Event;
	
	public class MeetingEvent extends Event
	{
		
		public static const MEETING_RESULT:String = "meetingResult";
		public static const MEETING_SPOT_SELECTED:String = "meetingSpotSelected";
		public static const MEETING_CREATED:String = "meetingCreated";
		
		public var data:Object;
		
		public function MeetingEvent(type:String, data:Object=null)
		{
			super(type, bubbles, cancelable);
			
			this.data = data;
		}
		
		override public function clone():Event
		{
			return new MeetingEvent(type, data);
		}

	}
}