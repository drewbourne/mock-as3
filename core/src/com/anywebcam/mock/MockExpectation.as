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

	// TODO should default to receive count at least 1
	// TODO should remove default receive count on setting a receive count manually
	
	/**
	 * Manages expectations of method or property calls.
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
		 * @private
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
		 *
		 * @private
		 */
		mock_internal function eligible():Boolean
		{
			return _receiveCountValidators.every( isValidatorEligible );
		}
		
		/**
		 * Iterator function to check if a ReceiveCountValidator is eligible
		 */
		private function isValidatorEligible( validator:ReceiveCountValidator, i:int, a:Array ):Boolean
		{
			return validator.eligible( _receivedCount );
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
				checkInvocationReceiveCounts();
				
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
		 * @private
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
		 * @private
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
		 *
		 * @private
		 */
		protected function checkInvocationOrder():void
		{
			if( ! isNaN(_orderNumber) ) 
			{
				_mock.receiveOrderedExpectation( this, _orderNumber );
			}
		}
		
		/**
		 * Checks the ReceiveCountValidators to ensure this expectation can be invoked
		 *
		 * @private
		 */
		protected function checkInvocationReceiveCounts():void 
		{
			eligible();
		}
		
		/**
		 * Invoke functions, dispatch events, throw error, return values if set
		 *
		 * @private
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
		 * @private
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
		 * @private
		 */
		protected function _invokeDispatchEvents( args:Array = null ):void
		{
			if( _eventsToDispatch.length == 0 )
				return;
			
			/*var target:IEventDispatcher = (_mock.target as IEventDispatcher);*/
			
			_eventsToDispatch.forEach( function( eventInfo:EventInfo, i:int, a:Array ):void
			{
				if( eventInfo.delay <= 0 ) 
				{
					_mock.dispatchEvent( eventInfo.event );
				}
				else
				{
					eventInfo.timeout = setTimeout( 
						function():void { _mock.dispatchEvent( eventInfo.event ); }, 
						eventInfo.delay );
				}
			});
		}
		
		/**
		 * Determine and return any return value set on this expectation
		 *
		 * @return If set returns the next return value
		 * @private
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
		
		/**
		 * Verify this expectation has had it's expectations met.
		 *
		 * @return true if this expectation is fulfilled
		 * @throws MockExpectationError if the set expectations were not met
		 */
		public function verify():Boolean
		{
			// check if called successfully
			if( _failedInvocation )
			{
				// FIXME report the error that caused the invocation to fail
				throw new MockExpectationError('Failed on invocation: ' + this);
				return false;
			}
			
			var validReceiveCount:Boolean = _receiveCountValidators.every( function( validator:ReceiveCountValidator, i:int, a:Array ):Boolean 
			{
				return validator.validate( _receivedCount );
			});
			
			var expectedReceivedCounts:Array = _receiveCountValidators.map( function( validator:ReceiveCountValidator, i:int, a:Array ):String 
			{
				return validator.describe( _receivedCount );
			});
			
			if( !validReceiveCount ) 
			{
				var message:String = 'Unmet Expectation: ' 
						+ this
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
		 * @private
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
		 * @private
		 */
		mock_internal function setArgumentExpectation( areArgumentsExpected:Boolean, expectedArguments:Object = null ):MockExpectation
		{
		  // FIXME add additional error detail to the MockExpectationError, like which property, what args, which mock instance, etc
			if( _hasExpectationType && ! _isMethodExpectation 
					&& (expectedArguments is Array && (expectedArguments as Array).length > 1 ) ) {
				
				throw new MockExpectationError( toString() + ', Property expectation can only accept one argument' );
			}
			
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
		 * @private
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
		 * @private
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
		 * @private
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
		 * @private
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
		 * @private
		 */
		mock_internal function setDispatchEventExpectation( event:Event, delay:Number = 0 ):MockExpectation
		{
			// FIXME is Error the best error class to throw here?
			if( !(_mock.target is IEventDispatcher) )
				throw new Error( 'Mock.target is not an IEventDispatcher: ' + this + ', target:', _mock.target );

			_eventsToDispatch.push( new EventInfo( event, delay ) );	
			return this;
		}
		
		/**
		 * Set an expectation to be executed in order relative to other ordered expectation
		 * 
		 * @return MockExpectation
		 * @private
		 */
		mock_internal function setOrderedExpectation():MockExpectation
		{
			_orderNumber = _mock.orderExpectation( this );
			return this;
		}
		
		/**
		 * Set this expectation to be a method with the supplied name
		 * 
		 * @param methodName The name of the method
		 * @return MockExpectation
		 * @example 
		 * <listing version="3.0">
		 *	mock.method('cook');
		 *	
		 *	mock.cook();
		 *	mock.verify();
		 * </listing>
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
		 * @example 
		 * <listing version="3.0">
		 *	mock.property('hungry');
		 *	
		 *	mock.hungry = true;
		 *	mock.verify();
		 * </listing>
		 */
		public function property( propertyName:String ):MockExpectation
		{
			return setExpectationType( propertyName, false );
		}
		
		/**
		 * Set this expectation to accept any arguments
		 *	
		 * @example 
		 * <listing version="3.0">
		 *	mock.method('eat').withAnyArgs;
		 *	
		 *	mock.eat(1, new Waffle(), { toppings: ['Syrup', 'IceCream'] });
		 *	mock.verify();
		 * </listing>
		 */
		public function get withAnyArgs():MockExpectation
		{
			return setArgumentExpectation( true, ArgumentExpectation.ANYTHING );
		}
		
		/**
		 * Set this expectation to accept no arguments
		 * 
		 * @example 
		 * <listing version="3.0">
		 *	mock.method('cook').withNoArgs;
		 *	
		 *	mock.cook();
		 *	mock.verify();
		 * </listing>
		 */
		public function get withNoArgs():MockExpectation
		{
			return setArgumentExpectation( false, ArgumentExpectation.NO_ARGS );
		}
		
		/**
		 * Set this expectation to accept the supplied arguments or constraints
		 * 
		 * @example 
		 * <listing version="3.0">
		 *	mock.method('cook').withNoArgs;
		 *	
		 *	mock.cook();
		 *	mock.verify();
		 * </listing>
		 */
		public function withArgs( ...rest ):MockExpectation
		{
			return setArgumentExpectation( true, rest );
		}
		
		/**
		 * Set a single or sequence of return values, alias of #andReturn
		 *	
		 * @example 
		 * <listing version="3.0">
		 *	mock.method('ten').returns(10);
		 *	
		 *	// #ten() will always return 10
		 *	assertEquals(10, mock.ten());
		 *	assertEquals(10, mock.ten());
		 *	assertEquals(10, mock.ten());
		 *	
		 *	mock.method('nextFib').returns(1, 1, 2, 3);
		 *	
		 *	// #nextFib will return the values in sequence and then repeat the last value
		 *	assertEquals(1, mock.nextFib());
		 *	assertEquals(1, mock.nextFib());
		 *	assertEquals(2, mock.nextFib());
		 *	assertEquals(3, mock.nextFib());
		 *	assertEquals(3, mock.nextFib());
		 *	assertEquals(3, mock.nextFib());
		 *	mock.verify();
		 * </listing>
		 */
		public function returns( ...rest ):MockExpectation
		{
			return setReturnExpectation.apply( this, rest );
		}
		
		/**
		 * Set a single or sequence of return values, alias of #returns
		 *	
		 * @see #returns
		 */
		public function andReturn( ...rest ):MockExpectation
		{
			return setReturnExpectation.apply( this, rest );
		}
		
		/**
		 * Set an error to be thrown, alias of andThrow()
		 *	
		 * @example 
		 * <listing version="3.0">
		 *	mock.method('generateError').throws(new IllegalArgumentError('Oh noes!'));
		 *	try {
		 *		mock.generateError();
		 *		fail('did not throw expected error');
		 *	} catch (error:IllegalArgumentError) {
		 *		; // expected
		 *	}
		 *	mock.verify();
		 * </listing>
		 */
		public function throws( error:Error ):MockExpectation
		{
			return setReturnExpectation( error );
		}
		
		/**
		 * Set an error to be thrown, alias of throws()
		 *	
		 * @see #throws
		 */
		public function andThrow( error:Error ):MockExpectation
		{
			return setThrowExpectation( error );
		}
		
		/**
		 * Set the supplied function to be called when the expectation is called, alias of andCall()
		 *	
		 * @example 
		 * <listing version="3.0">
		 *	mock.method('doSomeWork').calls(function():void {
		 *		trace('doing some work');
		 *	});
		 *	
		 *	mock.doSomeWork();
		 *	// 'doing some work'
		 *	
		 *	mock.method('doMoreWork').withArgs(1, 2).calls(function(a:Number, b:Number):void {
		 *		trace('doing more work', a, b);
		 *	});
		 *	
		 *	mock.doMoreWork(1, 2);
		 *	// 'doing more work 1 2'
		 *	
		 *	mock.verify();
		 * </listing>
		 */
		public function calls( func:Function ):MockExpectation
		{
			return setInvokeExpectation( func );
		}
		
		/**
		 * Set the supplied function to be called when the expectation is calls
		 *	
		 * @see #calls
		 */
		public function andCall( func:Function ):MockExpectation
		{
			return setInvokeExpectation( func );
		}
		
		/**
		 * Set the supplied event to be dispatched when the expectation is called, alias of andDispatchEvent()
		 *	
		 * @example
		 * <listing version="3.0">
		 *	mock.method('changeValue').dispatchesEvent(new Event(Event.CHANGE));
		 *	mock.method('changeValueLater').dispatchesEvent(new Event(Event.CHANGE), 1000);
		 *	
		 *	mock.addEventListener(Event.CHANGE, addAsync(function(event:Event):void {
		 *		trace('changed');
		 *	}, 2000));
		 *	
		 *	mock.changeValue();
		 *	mock.changeValueLater();
		 * </listing>
		 */
		public function dispatchesEvent( event:Event, delay:Number = 0 ):MockExpectation
		{
			return setDispatchEventExpectation( event, delay );
		}
		
		/**
		 * Set the supplied event to be dispatched when the expectation is called, alias of dispatchesEvent()
		 *	
		 * @see #dispatchesEvent
		 */
		public function andDispatchEvent( event:Event, delay:Number = 0 ):MockExpectation
		{
			return setDispatchEventExpectation( event, delay );
		}
		
		// receive counts
		/**
		 * Set this expectation to expect NOT to be called
		 *	
		 * @example
		 * <listing version="3.0">
		 *	mock.method('doNotCall').never;
		 *	
		 *	// mock.doNotCall();
		 *	mock.verify();
		 * </listing>
		 */
		public function get never():MockExpectation
		{
			return setReceiveCount( new NeverCountValidator( this ) );
		}
		
		/**
		 * Set this expectation to expect to be called ONCE only.
		 *	
		 * @example
		 * <listing version="3.0">
		 *	mock.method('singular').once;
		 *	
		 *	mock.singular();
		 *	mock.verify();
		 * </listing>
		 */
		public function get once():MockExpectation
		{
			return times( 1 );
		}
		
		/**
		 * Set this expectation to expect to be called TWICE only.
		 *	
		 * @example
		 * <listing version="3.0">
		 *	mock.method('toothy').twice;
		 *	
		 *	mock.toothy();
		 *	mock.toothy();
		 *	mock.verify();
		 * </listing>
		 */
		public function get twice():MockExpectation
		{
			return times( 2 );
		}
		
		/**
		 * Set this expectation to expect to be called exactly the supplied number of times
		 *
		 * <p>Alias of #times</p>
		 * 
		 * @see #times
		 * @example
		 * <listing version="3.0">
		 *	mock.method('save').exactly(1);
		 *	
		 *	mock.save();
		 *	mock.verify();
		 * </listing>
		 */
		public function exactly( count:int ):MockExpectation
		{
			return times( count );
		}
		
		/**
		 * Set this expectation to expect to be called at least the supplied number of times
		 *
		 *	@example
		 * <listing version="3.0">
		 *	mock.method('oneOrMore').atLeast(1);
		 *	
		 *	mock.oneOrMore();
		 *	mock.oneOrMore();
		 *	mock.verify();
		 * </listing>
		 */
		public function atLeast( count:int ):MockExpectation
		{
			return setReceiveCount( new AtLeastCountValidator( this, count ) );
		}
		
		/**
		 * Set this expectation to expect to be called at most the supplied number of times
		 *	
		 * @example
		 * <listing version="3.0">
		 *	mock.method('thricePerhaps').atMost(3);
		 *	
		 *	mock.thricePerhaps();
		 *	mock.thricePerhaps();
		 *	mock.verify();
		 * </listing>
		 */
		public function atMost( count:int ):MockExpectation
		{
			return setReceiveCount( new AtMostCountValidator( this, count ) );
		}
		
		/**
		 * Set this expectation to expect to be called any number of times
		 *
		 * <p>Alias of atLeast(0)</p>
		 *
		 * @example
		 * <listing version="3.0">
		 *	mock.method('youMightCall').anyNumberOfTimes;
		 *	
		 *	mock.youMightCall();
		 *	mock.verify();
		 * </listing>
		 */
		public function get anyNumberOfTimes():MockExpectation
		{
			return atLeast( 0 );
		}
		
		/**
		 * Set this expectation to expect to be called zero or more times. 
		 *	
		 * <p>Alias of #anyNumberOfTimes</p>
		 * <p>Alias of atLeast(0)</p>
		 * 
		 * @see #anyNumberOfTimes
		 * @example
		 * <listing version="3.0">
		 *	mock.method('youMightCall').zeroOrMoreTimes;
		 *	
		 *	mock.youMightCall();
		 *	mock.verify();
		 * </listing>
		 */
		public function get zeroOrMoreTimes():MockExpectation
		{
			return atLeast( 0 );
		}
		
		/**
		 * Set this expectation to expect to be called the supplied number of times
		 *
		 * @example
		 * <listing version="3.0">
		 *	mock.method('one').times(3);
		 *	
		 *	mock.one();
		 *	mock.one();
		 *	mock.one();
		 *	mock.verify();
		 * </listing>
		 */
		public function times( count:int = -1 ):MockExpectation
		{
			return count > -1
				? setReceiveCount( new ExactCountValidator( this, count ) ) 
				: this;
		}
		
		/**
		 * Indicate that this method should be called in order with other expectations marked by #ordered()
		 *	
		 * @example
		 * <listing version="3.0">
		 *	mock.method('one').ordered();
		 *	mock.method('anyOrder').anyNumberOfTimes;
		 *	mock.method('two').ordered();
		 *	
		 *	mock.one();
		 *	mock.anyOrder();
		 *	mock.anyOrder();
		 *	mock.two();
		 *	mock.anyOrder();
		 *	mock.verify();
		 * </listing>
		 */
		public function ordered():MockExpectation
		{
			return setOrderedExpectation();
		}
	}
}

import flash.events.Event;

/**
 * Event and delay data for the expectation
 *
 * @private
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