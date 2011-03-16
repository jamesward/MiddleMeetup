package com.middlemeetup;

import java.util.Date;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;

import org.hibernate.annotations.GenericGenerator;

@Entity
public class Meeting
{
	
	@Id
	@GeneratedValue(generator="system-uuid")
	@GenericGenerator(name="system-uuid", strategy = "uuid")
	public String id;

	public String initiatorName;
	
	public String initiatorLocation;
	
	public String responderName;
	
	public String responderLocation;
	
	public Date createDate;

}