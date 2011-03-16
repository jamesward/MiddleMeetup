package com.middlemeetup;

import java.util.Date;

import org.hibernate.SessionFactory;
import org.hibernate.criterion.Restrictions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.flex.messaging.MessageTemplate;
import org.springframework.flex.remoting.RemotingDestination;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import flex.messaging.messages.AsyncMessage;

@RemotingDestination
@Repository
@Transactional

public class MeetService
{
	
	@Autowired
	private MessageTemplate defaultMessageTemplate;
	
	@Autowired
	private SessionFactory sessionFactory;
	
	public Meeting createMeeting(String senderName, String senderLocation, String receiverName)
	{
		// try to find it with initiator as the sender
		Meeting meeting = (Meeting)sessionFactory.getCurrentSession().createCriteria(Meeting.class).add(Restrictions.eq("initiatorName", senderName)).add(Restrictions.eq("responderName", receiverName)).uniqueResult();
		
		if (meeting != null)
		{
			// the meeting initiator has already created this meeting and is trying to create it again
			meeting.initiatorLocation = senderLocation;
		}
		else
		{
			// try to find it with the receiver as the initiator
			meeting = (Meeting)sessionFactory.getCurrentSession().createCriteria(Meeting.class).add(Restrictions.eq("initiatorName", receiverName)).add(Restrictions.eq("responderName", senderName)).uniqueResult();
			
			if (meeting != null)
			{
				meeting.responderLocation = senderLocation;
			}
		}
		
		if (meeting != null)
		{
			// meeting existed but lets verify it isn't more than an hour old
			Date now = new Date();
			
			long diff = now.getTime() - meeting.createDate.getTime();
			
			if (diff > (60 * 60 * 1000))
			{
				// delete the meeting
				sessionFactory.getCurrentSession().delete(meeting);
				meeting = null;
			}
		}
		
		if (meeting == null)
		{
			// this is a new meeting
			meeting = new Meeting();
			meeting.initiatorName = senderName;
			meeting.responderName = receiverName;
			meeting.initiatorLocation = senderLocation;
			meeting.createDate = new Date();
			sessionFactory.getCurrentSession().save(meeting);
		}
			
		AsyncMessage asyncMessage = defaultMessageTemplate.createMessageForDestination("m");
		asyncMessage.setHeader(AsyncMessage.SUBTOPIC_HEADER_NAME, meeting.id);
		asyncMessage.setBody(meeting);
		defaultMessageTemplate.getMessageBroker().routeMessageToService(asyncMessage, null);
		
		return meeting;
	}

}