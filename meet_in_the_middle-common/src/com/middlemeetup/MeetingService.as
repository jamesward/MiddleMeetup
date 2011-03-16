package com.middlemeetup
{
	import com.mapquest.services.search.SearchResult;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayList;
	import mx.messaging.ChannelSet;
	import mx.messaging.Consumer;
	import mx.messaging.Producer;
	import mx.messaging.channels.AMFChannel;
	import mx.messaging.channels.StreamingAMFChannel;
	import mx.messaging.events.MessageEvent;
	import mx.messaging.messages.AsyncMessage;
	import mx.rpc.AsyncResponder;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;

	[Event(name="meetingCreated", type="com.middlemeetup.MeetingEvent")]
	[Event(name="meetingSpotSelected", type="com.middlemeetup.MeetingEvent")]
	public class MeetingService extends EventDispatcher
	{
		
		public static var instance:MeetingService = new MeetingService();
		
		private var meetServiceRemoteObject:RemoteObject;
		
		private var meetingConsumer:Consumer;
		
		private var meetingProducer:Producer;
		
		public function MeetingService()
		{
			meetServiceRemoteObject = new RemoteObject("meetService");
			meetServiceRemoteObject.endpoint = "http://www.middlemeetup.com/mb/amf";

			var streamingAMFChannel:StreamingAMFChannel = new StreamingAMFChannel("my-streaming-amf", "http://www.middlemeetup.com/mb/s");
			
			var amfLongPollingChannel:AMFChannel = new AMFChannel("my-longpolling-amf", "http://www.middlemeetup.com/mb/lp");
			amfLongPollingChannel.pollingEnabled = true;
			amfLongPollingChannel.pollingInterval = 5000;
			
			var messagingChannelSet:ChannelSet = new ChannelSet();
			messagingChannelSet.channels = [streamingAMFChannel, amfLongPollingChannel];

			meetingProducer = new Producer();
			meetingProducer.channelSet =  messagingChannelSet;
			meetingProducer.destination = "m";

			meetingConsumer = new Consumer();
			meetingConsumer.channelSet = messagingChannelSet;
			meetingConsumer.destination = "m";
			meetingConsumer.addEventListener(MessageEvent.MESSAGE, handleMessage);
		}
		
		public function createMeeting():void
		{
			var token:AsyncToken = meetServiceRemoteObject.createMeeting(Model.instance.yourName, Model.instance.yourLocation, Model.instance.theirName);
			token.addResponder(new AsyncResponder(function(event:ResultEvent, passThrough:Object):void {
				Model.instance.meetingId = (event.result as Meeting).id;
				
				meetingConsumer.subtopic = Model.instance.meetingId;
				meetingConsumer.subscribe();
				
				updateTheirLocation(event.result as Meeting);
			}, function(event:FaultEvent, passThrough:Object):void {
				trace(event);
			}));
		}
		
		public function meetAtLocation(searchResult:SearchResult):void
		{
			var asyncMessage:AsyncMessage = new AsyncMessage(searchResult.key);
			asyncMessage.headers = {DSSubtopic: Model.instance.meetingId};
			meetingProducer.send(asyncMessage);
		}
		
		private function updateTheirLocation(meeting:Meeting):void
		{
			var previousTheirLocation:String = Model.instance.theirLocation;
			
			if (meeting.initiatorName == Model.instance.theirName)
			{
				// I am the receiver
				Model.instance.theirLocation = meeting.initiatorLocation;
			}
			else
			{
				// I am the initiator
				Model.instance.theirLocation = meeting.responderLocation;
			}
			
			if ((Model.instance.theirLocation != null) && (Model.instance.theirLocation != previousTheirLocation))
			{
				var mapSearchService:MapSearchService = new MapSearchService();
				mapSearchService.addEventListener(MeetingEvent.MEETING_RESULT, function(event:MeetingEvent):void {
					Model.instance.meetingSpots = new ArrayList(event.data as Array);
					dispatchEvent(new MeetingEvent(MeetingEvent.MEETING_CREATED));
				});
				mapSearchService.getLocations();
			}
		}
		
		private function handleMessage(event:MessageEvent):void
		{
			if (event.message.body is Meeting)
			{
				updateTheirLocation(event.message.body as Meeting);
			}
			else if (event.message.body is String)
			{
				for each (var searchResult:SearchResult in Model.instance.meetingSpots.source)
				{
					if (searchResult.key == event.message.body)
					{
						dispatchEvent(new MeetingEvent(MeetingEvent.MEETING_SPOT_SELECTED, searchResult));
					}
				}
			}
		}
		
	}
}