/*
	Aseba - an event-based middleware for distributed robot control
	Copyright (C) 2006 - 2007:
		Stephane Magnenat <stephane at magnenat dot net>
		(http://stephane.magnenat.net)
		Valentin Longchamp <valentin dot longchamp at epfl dot ch>
		Laboratory of Robotics Systems, EPFL, Lausanne
	
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	any other version as decided by the two original authors
	Stephane Magnenat and Valentin Longchamp.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef ASEBA_SWITCH
#define ASEBA_SWITCH

#include <dashel/dashel.h>

namespace Aseba
{
	/**
	\defgroup switch Software router of messages.
	*/
	/*@{*/

	/*!
		Route Aseba messages on the TCP part of the network.
	*/
	class Switch: public Dashel::Hub
	{
		public:
			/*! Creates the switch, listen to TCP on port.
				@param verbose should we print a notification on each message
				@param dump should we dump content of each message
				@param forward should we only forward messages instead of transmit them back to the sender
			*/
			Switch(unsigned port, bool verbose, bool dump, bool forward);
			
			/*! Forwards the data received for a connections to the other ones.
				If forward is false, transmit it back to the sender too.
				@param stream the stream the packet was received from
			*/
			void forwardDataFrom(Dashel::Stream* stream);
			
			/*!	Send a dummy user message to all connected pears. */
			void broadcastDummyUserMessage();
			
		private:
			virtual void connectionCreated(Dashel::Stream *stream);
			virtual void incomingData(Dashel::Stream *stream);
			virtual void connectionClosed(Dashel::Stream *stream, bool abnormal);

		private:
			bool verbose; //!< should we print a notification on each message
			bool dump; //!< should we dump content of CAN messages
			bool forward; //!< should we only forward messages instead of transmit them back to the sender
	};
	
	/*@}*/
};

#endif
