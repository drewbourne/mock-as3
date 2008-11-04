/*
	Copyright (c) 2007, ANYwebcam.com Pty Ltd. All rights reserved.

	The software in this package is published under the terms of the BSD style 
	license, a copy of which has been included with this distribution in the 
	license.txt file.
*/
package com.anywebcam.mock
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.setTimeout;

	import com.anywebcam.mock.receiveCountValidator.*;

	use namespace mock_internal;

	// todo: should default to receive count at least 1
	// todo: should remove default receive count on setting a receive count manually
	
	/**
	 * Manages expectations of method or property call(s)
	 */
	public class MockExpectation
	{
		private var _mock	:Mock;
		
		private var _failedInvocation				:Boolean;
		
		// expectation type
		private var _hasExpectationType			:Boolean;
		private var _isMethodExpectation		:Boolean;
		private var _propertyName						:String;
		                                  
		// with arguments                 
		private var _expectsArguments				:Boolean;
		private var _argumentExpectation		:ArgumentExpectation;

		// receive counts
		private var _receivedCount					:int;
		private var _receiveCountValidators	:Array;
		
		// return values
		private var _valuesToYield					:Array;   
		private var _errorToThrow						:Error;   

		// functions and events
		private var _funcsToInvoke					:Array; // of Function
		private var _eventsToDispatch 			:Array; // of EventInfo
		
		// ordering
		private var _orderNumber						:Number;

		/**
		 * Constructor
		 * 
		 * @param Mock The parent Mock object this expectation is set on
		 */
		public function MockExpectation( mock:Mock )
		{
			_mock 								= mock;
			_hasExpectationType 	= false;
			_isMethodExpectation 	= false;
			_propertyName 				= '';
			_receivedCount 				= 0;
			_receiveCountValidators = [];
			_expectsArguments			= false;
			_orderNumber					= NaN;
			
			_funcsToInvoke 				= [];
			_eventsToDispatch 		= [];
		}
		
		public function toString():String 
		{
 			var result:String = _mock.toString() + '.' + name
					+ (_isMethodExpectation 
						? '(' + (_expectsArguments ? _argumentExpectation.toString() : '') + ')' 
						: '');
						
			return result;
		}
		
		// properties
		
		/**
		 * The name of the method or property this expectation relates to
		 */
		public function get name():String
		{
			return _propertyName;
		}

		public function set name( value:String ):void
		{
			_propertyName = value;
		}
		
		// processing //
		
		/**
		 * Check if expectation matches the property, invocation type and arguments. Called by Mock.
		 *
		 * @param propertyName
		 * @param isMethod
		 * @param args
		 */
		mock_internal function matches( propertyName:String, isMethod:Boolean, args:Array = null ):Boolean
		{
			return propertyName == _propertyName 
				&& isMethod == _isMethodExpectation 
				&& ((_argumentExpectation && _argumentExpectation.argumentsMatch( args ))
					|| (_argumentExpectation == null));
		}
		
		/**
		 * Check if the expectation is eligible to be called again. It is eligible only if all the receive count validators agree, ie that its in the specified range
		 */
		mock_internal function eligible():Boolean
		{
			return _receiveCountValidators.every( function( validator:ReceiveCountValidator, i:int, a:Array ):Boolean 
			{ 
				return validator.eligible( _receivedCount );
			});
		}

		mock_internal function receiveCountConstrained():Boolean
		{
			return _receiveCountValidators.length > 0;
		}
		
		/**
		 * Invoke the expectation, checking its called the right way, with the correct arguments, and return any expected value
		 *
		 * @throws MockExpectationError if invoked as a method and not a method
		 * @throws MockExpectationError if invoked as a property and is a method
		 * @throws MockExpectationError if args do not match
		 */
		mock_internal function invoke( invokedAsMethod:Boolean, args:Array = null ):*
		{
			_failedInvocation = false;

			try
			{
				checkInvocationMethod( invokedAsMethod );
				checkInvocationArgs( args );
				checkInvocationOrder();
				
				var retval:* = doInvoke( args );
				
				return retval;
			}
			catch( e:MockExpectationError )
			{
				if( e !== _errorToThrow )
					_failedInvocation = true;
				
				throw e;
			}
			
			return null;
		}
		
		/**
		 * Check the expectation is invoked as expected, method as a method, property as a property
		 *
		 * @throws MockExpectationError if invoked as a method and not a method
		 * @throws MockExpectationError if invoked as a property and is a method
		 */
		protected function checkInvocationMethod( invokedAsMethod:Boolean ):void
		{
			if( _isMethodExpectation && ! invokedAsMethod )
				throw new MockExpectationError( 'Expectation is for a property not a method:' + this );
			
			if( ! _isMethodExpectation && invokedAsMethod )
				throw new MockExpectationError( 'Expectation is for a method not a property:' + this );
		}
		
		/**
		 * Check if there are expected arguments and if the supplied arguments match
		 *
		 * @throws MockExpectationError if not expecting args and was called with args
		 * @throws MockExpectationError if expecting args and was called with without args
		 * @throws MockExpectationError if args do not match
		 */
		protected function checkInvocationArgs( args:Array = null ):void
		{
			if( ! _isMethodExpectation && args != null && args.length > 1 )
				throw new MockExpectationError( 'Property expectations cannot accept multiple arguments: ' + this + ', received:'+ args );

			if( ! _expectsArguments && args != null && args.length > 0 )
				throw new MockExpectationError( 'Not expecting arguments: ' + this + ', received:'+ args );

			// todo: add descriptive of which arguments did not match
			if( _expectsArguments && ! _argumentExpectation.argumentsMatch( args ) )
				throw new MockExpectationError( 'Invocation arguments do not match expected arguments:' + this + ', received:'+ args  );
		}
		
		/**
		 * Checks the Order Number is set and that the Mock is expecting this call
		 */
		protected function checkInvocationOrder():void
		{
			if( ! isNaN(_orderNumber) ) 
			{
				_mock.receiveOrderedExpectation( this, _orderNumber );
			}
		}
		
		/**
		 * Invoke functions, dispatch events, throw error, return values if set
		 */
		protected function doInvoke( args:Array=null ):*
		{
			// todo: handle method call order constraints

			_receivedCount++;
			
			_invokeFuncs( args );
			
			_invokeDispatchEvents( args );
			
			if( _errorToThrow != null )
			{
				throw _errorToThrow;
			}
			
			var retval:* = _invokeReturnValue();
			
			return retval;
		}
		
		/**
		 * Invoke any functions set on this expectation
		 * 
		 * @param args Any arguments supplied when calling this expectation
		 */
		protected function _invokeFuncs( args:Array = null ):void
		{
			if( _funcsToInvoke.length == 0 ) 
				return;

			_funcsToInvoke.forEach( function( func:Function, i:int, a:Array ):void 
			{ 
				func.apply( null, args );
			});
		}
		
		/**
		 * Dispatch any events set on this expectation
		 * 
		 * @param args Any arguments supplied when calling this expectation		
		 */
		protected function _invokeDispatchEvents( args:Array = null ):void
		{
			if( _eventsToDispatch.length == 0 )
				return;
			
			var target:IEventDispatcher = (_mock.target as IEventDispatcher);
			
			_eventsToDispatch.forEach( function( eventInfo:EventInfo, i:int, a:Array ):void
			{
				trace('_eventToDispatch', eventInfo.delay, eventInfo.event);
				if( eventInfo.delay <= 0 ) 
				{
					target.dispatchEvent( eventInfo.event );
				}
				else
				{
					eventInfo.timeout = setTimeout( 
						function():void { target.dispatchEvent( eventInfo.event ); }, 
						eventInfo.delay );
				}
			});
		}
		
		/**
		 * Determine and return any return value set on this expectation
		 *
		 * @return If set returns the next return value
		 */
		protected function _invokeReturnValue():*
		{
			if( _valuesToYield == null ) 
				return null;
			
			var valueIndex:int = (_receivedCount - 1) < _valuesToYield.length 
												 ? _receivedCount - 1
												 : _valuesToYield.length - 1; 
					
			return _valuesToYield[ valueIndex ];
		}
		
		// todo: rename this method
		/**
		 * Verify this expectation has had it's expectations
		 *
		 * @return true if this expecation is fulfilled
		 * @throws MockExpectationError if the set expectations were not met
		 */
		public function verifyMessageReceived():Boolean
		{
			// todo: add more robust verification
			
			// check if called successfully
			if( _failedInvocation )
			{
				// FIXME report the error that caused the invocation to fail
				throw new MockExpectationError(_mock.toString() + '/' + name + '() failed on invocation.');
				return false;
			}
			
			var validReceiveCount:Boolean = _receiveCountValidators.every( function( validator:ReceiveCountValidator, i:int, a:Array ):Boolean 
			{
				return validator.validate( _receivedCount );
			});
			
			var expectedReceivedCounts:Array = _receiveCountValidators.map( function( validator:ReceiveCountValidator, i:int, a:Array ):String 
			{
				return validator.toString( _receivedCount );
			});
			
			// todo: add the expected arguments to the error message
			
			if( !validReceiveCount ) 
			{
				var message:String = 'Unmet Expectation: ' 
						+ toString()
						+ ' received: ' + _receivedCount + ','
						+ ' expected: ' + expectedReceivedCounts.join(', ');
						
				throw new MockExpectationError(message);
			}
			
			return validReceiveCount;
		}
		
		/**
		 * Set the name for this expectation and whether it is for a method or a property
		 * 
		 * @param propertyName
		 * @param isMethodExpectation
		 * @return MockExpectation
		 */
		mock_internal function setExpectationType( propertyName:String, isMethodExpectation:Boolean ):MockExpectation
		{
			_hasExpectationType = true;
			_isMethodExpectation = isMethodExpectation;
			_propertyName = propertyName;
			
			return this;
		}
			
		/**
		 * Set whether arguments are expected and any constraints or literal values to expect
		 *
		 * @param areArgumentsExpected
		 * @param expectedArguments
		 * @return MockExpectation
		 */
		mock_internal function setArgumentExpectation( areArgumentsExpected:Boolean, expectedArguments:Object = null ):MockExpectation
		{
		  // FIXME add additional error detail to the MockExpectationError, like which property, what args, which mock instance, etc
			if( _hasExpectationType && ! _isMethodExpectation 
			&& (expectedArguments is Array && (expectedArguments as Array).length > 1 ) )
				throw new MockExpectationError( toString() + ', Property expectation can only accept one argument' );
			
			_expectsArguments = areArgumentsExpected;
			_argumentExpectation = new ArgumentExpectation( expectedArguments );
			
			return this;
		}
		
		/**
		 * Set the type of and amount of calls this expectation should receive
		 *
		 * @param type
		 * @param number
		 * @return MockExpectation
		 */
		mock_internal function setReceiveCount( validator:ReceiveCountValidator ):MockExpectation
		{
			_receiveCountValidators.push( validator );
			return this;
		}
		
		/**
		 * Set a single or sequence of values to return to calls of this expectation
		 *
		 * @param rest
		 * @return MockExpectation
		 */
		mock_internal function setReturnExpectation( ...rest ):MockExpectation
		{
			if( rest.length == 0 )
			{
				_valuesToYield = null;
			}
			else // if more than zero return values
			{
				// clear error to throw, otherwise return does not work
				_errorToThrow = null;
				_valuesToYield = rest;
			}
			
			return this;
		}
		
		/**
		 * Set an error to be thrown when this expectation is called
		 *
		 * @param error
		 * @return MockExpectation
		 */
		mock_internal function setThrowExpectation( error:Error ):MockExpectation
		{
			_errorToThrow = error;
			return this;
		}
		
		/**
		 * Set a function to be invoked when this expectation is called
		 *
		 * @param func
		 * @return MockExpectation
		 */
		mock_internal function setInvokeExpectation( func:Function ):MockExpectation
		{
			_funcsToInvoke.push( func );
			return this;
		}
		
		/**
		 * Set an event to be dispatched when this expectation is called, requires the mock target to be an IEventDispatcher
		 *
		 * @param event The Event to dispatch
		 * @param delay The number of milliseconds to delay before dispatching the event
		 * @return MockExpectation
		 * @throw Error if mock target is not an IEventDispatcher
		 */
		mock_internal function setDispatchEventExpectation( event:Event, delay:Number = 0 ):MockExpectation
		{
			// fixme: is Error the best error class to throw here?
			if( !(_mock.target is IEventDispatcher) )
				throw new Error( 'Mock Target class is not an IEventDispatcher, target:', _mock.target );

			_eventsToDispatch.push( new EventInfo( event, delay ) );	
			return this;
		}
		
		/**
		 * Set an expectation to be executed in order relative to other ordered expectation
		 * 
		 * @return MockExpectation
		 */
		mock_internal function setOrderedExpectation():MockExpectation
		{
			_orderNumber = _mock.orderExpectation( this );
			return this;
		}
		
		/// ---- mock expectation setup ---- ///
		
		// is expectation for a method or a property?
		
		/**
		 * Set this expectation to be a method with the supplied name
		 * 
		 * @param methodName The name of the method
		 * @return MockExpectation		
		 */
		public function method( methodName:String ):MockExpectation
		{
			return setExpectationType( methodName, true );
		}
		
		/**
		 * Set this expectation to be a property with the supplied name
		 * 
		 * @param propertyName The name of the property
		 * @return MockExpectation
		 */
		public function property( propertyName:String ):MockExpectation
		{
			return setExpectationType( propertyName, false );
		}
		
		// should it expect arguments
		
		/**
		 * Set this expectation to accept any arguments
		 */
		public function get withAnyArgs():MockExpectation
		{
			return setArgumentExpectation( true, ArgumentExpectation.ANYTHING );
		}
		
		/**
		 * Set this expectation to accept no arguments
		 */
		public function get withNoArgs():MockExpectation
		{
			return setArgumentExpectation( false, ArgumentExpectation.NO_ARGS );
		}
		
		/**
		 * Set this expectation to accept the supplied arguments or constraints
		 */
		public function withArgs( ...rest ):MockExpectation
		{
			return setArgumentExpectation( true, rest );
		}
		
		// return values
		
		/**
		 * Set a single or sequence of return values, alias of andReturn()
		 */
		public function returns( ...rest ):MockExpectation
		{
			return setReturnExpectation.apply( this, rest );
		}
		
		/**
		 * Set a single or sequence of return values, alias of returns()
		 */
		public function andReturn( ...rest ):MockExpectation
		{
			return setReturnExpectation.apply( this, rest );
		}
		
		/**
		 * Set an error to be thrown, alias of andThrow()
		 */
		public function throws( error:Error ):MockExpectation
		{
			return setReturnExpectation( error );
		}
		
		/**
		 * Set an error to be thrown, alias of throws()
		 */
		public function andThrow( error:Error ):MockExpectation
		{
			return setThrowExpectation( error );
		}
		
		/**
		 * Set the supplied function to be called when the expectation is called, alias of andCall()
		 */
		public function calls( func:Function ):MockExpectation
		{
			return setInvokeExpectation( func );
		}
		
		/**
		 * Set the supplied function to be called when the expectation is calls
		 */
		public function andCall( func:Function ):MockExpectation
		{
			return setInvokeExpectation( func );
		}
		
		/**
		 * Set the supplied event to be dispatched when the expectation is called, alias of andDispatchEvent()
		 */
		public function dispatchesEvent( event:Event, delay:Number = 0 ):MockExpectation
		{
			return setDispatchEventExpectation( event, delay );
		}
		
		/**
		 * Set the supplied event to be dispatched when the expectation is called, alias of dispatchesEvent()
		 */
		public function andDispatchEvent( event:Event, delay:Number = 0 ):MockExpectation
		{
			return setDispatchEventExpectation( event, delay );
		}
		
		// receive counts
		/**
		 * Set this expectation to expect NOT to be called
		 */
		public function get never():MockExpectation
		{
			return times( 0 );
		}
		
		/**
		 * Set this expectation to expect to be called ONCE only. 
		 */
		public function get once():MockExpectation
		{
			return times( 1 );
		}
		
		/**
		 * Set this expectation to expect to be called TWICE only. 
		 */
		public function get twice():MockExpectation
		{
			return times( 2 );
		}
		
		/**
		 * Set this expectation to expect to be called exactly the supplied number of times
		 */
		public function exactly( count:int ):MockExpectation
		{
			return times( count );
		}
		
		/**
		 * Set this expectation to expect to be called at least the supplied number of times
		 */
		public function atLeast( count:int ):MockExpectation
		{
			return setReceiveCount( new AtLeastCountValidator( this, count ) );
		}
		
		/**
		 * Set this expectation to expect to be called at most the supplied number of times
		 */
		public function atMost( count:int ):MockExpectation
		{
			return setReceiveCount( new AtMostCountValidator( this, count ) );
		}
		
		/**
		 * Set this expectation to expect to be called any number of times
		 */
		public function get anyNumberOfTimes():MockExpectation
		{
			return atLeast( 0 );
		}
		
		/**
		 * Set this expectation to expect to be called zero or more times
		 */
		public function get zeroOrMoreTimes():MockExpectation
		{
			return atLeast( 0 );
		}
		
		// todo: allow a range?		
		/**
		 * Set this expectation to expect to be called the supplied number of times
		 */
		public function times( count:int = -1 ):MockExpectation
		{
			return count > -1
				? setReceiveCount( new ExactCountValidator( this, count ) ) 
				: this;
		}
		
		// method ordering
		public function ordered():MockExpectation
		{
			return setOrderedExpectation();
		}
	}
}

import flash.events.Event;

/**
 * Event and delay data for the expectation
 */
internal class EventInfo
{
	public function EventInfo( event:Event, delay:Number )
	{
		this.event = event;
		this.delay = delay;
	}
	
	public function toString():String
	{
		return '[EventInfo '+ event.type +' '+ delay +']'
	}
	
	public var event:Event;
	public var delay:Number;
	public var timeout:Number;
}