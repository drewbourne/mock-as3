/*
	Copyright (c) 2007, ANYwebcam.com Pty Ltd. All rights reserved.

	The software in this package is published under the terms of the BSD style 
	license, a copy of which has been included with this distribution in the 
	license.txt file.
*/
package com.anywebcam.mock
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.getQualifiedClassName;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;

	use namespace mock_internal;
	
	/**
	 * Mock and MockExpectation provide the core API of mock-as3. 
	 * 
	 * @see MockExpectation MockExpectation for examples of how to set various expectations.
	 * @example In general usage an instance of Mock will be created and used to specify which methods and properties are expected to be called on an object.
 	 * <listing version="3.0">
	 *  // set an expectation
	 *  mock.method('hello').withArgs(String).andReturn('hi!').once;
	 *  // call the method
	 *  mock.hello('with a string');
	 *  // check that all the expectations were met
	 *  mock.verify();
	 * </listing>
	 * 
	 * @example In order to make Mock Objects work as stand-ins for real objects they need to implement an interface or extend a class and override every method. Here we are going to create a Mock IImageEncoder because we want to test another object that uses an IImageEncoder instead of testing the actual encoding.
	 * <listing version="3.0">
	 *  package {
	 * 
	 * 	  import com.anywebcam.mock.Mock;
	 *    import flash.display.BitmapData;
	 *    import flash.utils.ByteArray;
	 *    import mx.graphics.codec.IImageEncoder;
	 * 
	 *    public class MockImageEncoder implements IImageEncoder {
	 *      public var mock:Mock;
	 * 
	 *      public function MockImageEncoder() {
	 *        mock = new Mock();
	 *      }
	 * 
	 *      public function get contentType():String {
	 *        return mock.contentType;
	 *      }
	 * 
	 *      public function encode(bitmapData:BitmapData):ByteArray {
	 *        return mock.encode(bitmapData);
	 *      }
	 *    
	 *      public function encodeByteArray(byteArray:ByteArray, width:int, height:int, transparent:Boolean = true):ByteArray {
	 *        return mock.encodeByteArray(byteArray, width, height, transparent);
	 *      }
	 *    }
	 *  }
	 * </listing>
	 * 
	 * Now we can use our MockImageEncoder in our tests.
	 * 
	 * <listing version="3.0">
	 *  public function testGrabsImageAndCallEncode():void {
	 * 
	 *    // create the data our class under test will use
	 *    var sprite:Sprite = new Sprite();
	 *    var bytes:ByteArray = new ByteArray();
	 *    var imageEncoder:MockImageEncoder = new MockImageEncoder();
	 *    
	 *    // set expectations for the mocks
	 *    imageEncoder.mock.method('encode').withArgs(BitmapData).andReturn(bytes);
	 *    
	 *    // test our class
	 *    var screenGrabber:ScreenGrabber = new ScreenGrabber(sprite, imageEncoder);
	 *    var encoded:ByteArray = screenGrabber.grab();
	 * 
	 *    // check results
	 *    assertEquals("expecting screenGrabber to return the ByteArray from imageEncoder", bytes, encoded);
	 * 
	 *    // check mock expectations were met
	 *    imageEncoder.mock.verify();
	 *  }
	 * </listing>
	 */
	dynamic public class Mock extends Proxy implements IEventDispatcher
	{
	  /**
	   * 
	   * @example
	   * <listing version="3.0">
	   *  public function testWithLotsOfMocks():void {
	   *    var m1:Mock = new Mock();
	   *    var m2:Mock = new Mock();
	   *    var m2:Mock = new Mock();
	   * 
	   *    // test something using the mocks
	   * 
	   *    Mock.verify(m1, m2, m3);
	   *  }
	   * </listing>
	   */ 
	  public static function verify(...mocks):void {
	    mocks.forEach(function(mock:Mock, i:int, a:Array):void {
	      mock.verify();
	    });
	  }
	  
		/**
		 * Constructor
		 * 
		 * @param target The target that is delegating calls to this Mock
		 * @param ignoreMissing Indicates whether methods and properties without expectations are ignored
		 */
		public function Mock( target:Object = null, ignoreMissing:Boolean = false )
		{
			_target = target;
			_expectations = [];
			_ignoreMissing = ignoreMissing || false;
			_currentOrderNumber = 0;
			_orderedExpectations = [];
			_eventDispatcher = new EventDispatcher(this);
		}
		
		private var _target:Object;
		
		/**
		 * The target object to mock
		 * 
		 * @private
		 */
		public function get target():Object
		{
			return _target;
		}
		
		private var _eventDispatcher:IEventDispatcher;
		
		/**
		 * The IEventDispatcher instance to use for event dispatch.
		 *
		 * @private
		 */
		public function get eventDispatcher():IEventDispatcher 
		{
			return _eventDispatcher;
		}
		
		private var _ignoreMissing:Boolean;

		/**
		 * Indicates whether methods and properties without expectations are ignored.
		 */
		public function get ignoreMissing():Boolean
		{
			return _ignoreMissing;
		}

		public function set ignoreMissing( value:Boolean ):void
		{
			_ignoreMissing = value;
		}
				
		private var _traceMissing:Boolean
		
		/**
		 * When #ignoreMissing is true, indicates whether methods and properties without expectations are recorded using trace().
		 */
		public function get traceMissing():Boolean
		{
			return _traceMissing;
		}

		public function set traceMissing( value:Boolean ):void
		{
			_traceMissing = value;
		}

		private var _expectations:Array; //  of MockExpectation;
		
		/**
		 * Array of Mock Expectations set on this Mock instance
		 *	
		 * @private
		 */
		public function get expectations():Array
		{
			return _expectations;
		}
		
		/**
		 * Current Order
		 */
		private var _currentOrderNumber:int;
		
		/**
		 * Expectations set to be run in order
		 */
		private var _orderedExpectations:Array;
		
		/**
		 * String representation of this Mock
		 */
		public function toString():String
		{
			var className:String = getQualifiedClassName( target );
			return className.slice( className.lastIndexOf(':') + 1 );
		}

		/**
		 * Create an expectation on this Mock
		 *
		 * @return MockExpectaton A new MockExpectation instance
		 * @see #method()
		 * @see #property()
		 * @example
		 * <listing version="3.0">
		 * 	mock.expect().method('methodName');
		 * </listing>
		 */
		public function expect():MockExpectation
		{
			var expectation:MockExpectation = new MockExpectation( this );
			_expectations.push( expectation );
			return expectation;
		}
		
		/**
		 * Shortcut for creating a Method Expectation
		 * 
		 * @param methodName The name of the target method to mock
		 * @return MockExpectation A new MockExpectation instance
		 * @example
		 * <listing version="3.0">
		 *	mock.method('methodName');
		 * </listing>
		 */
		public function method( methodName:String ):MockExpectation
		{
			return expect().method( methodName );
		}
		
		/**
		 * Shortcut for creating a Property Expectation
		 * 
		 * @param propertyName The name of the target property to mock
		 * @return MockExpectation A new MockExpectation instance		
		 * @example
		 * <listing version="3.0">
		 *	mock.property('propertyName');
		 * </listing>
		 */
		public function property( propertyName:String ):MockExpectation
		{
			return expect().property( propertyName );
		}
		
		/**
		 * Verify all the expectations have been met
		 * 
		 * @return True if all expectations are met
		 * @throws MockExpectationError with results of failed expectations
		 * @example
		 * <listing version="3.0">
		 *	mock.verify();
		 * </listing>
		 */
		public function verify():Boolean
		{
			var failedExpectations:Array = _expectations.map( verifyExpectation ).filter( isNotNull );
			var expectationsAllVerified:Boolean = failedExpectations.length == 0;
			
			if( !expectationsAllVerified )
				throw new MockExpectationError( 
					'Verifying Mock Failed: ' 
					+ this.toString() + '\n' 
					+ failedExpectations.map(function(error:MockExpectationError, i:int, a:Array):String {
							return error.message;
						}).join('\n') );

			return expectationsAllVerified;
		}
		
		/**
		 * Iterator function to verify each of the expectations have been met
		 * 
		 * @param expectation The expectation to verify
		 * @param index The index of the expectation
		 * @param array The Expectations Array
		 * @return a MockExpectationError if the expectation fails verify(), null otherwise.
		 * @private
		 */
		protected function verifyExpectation( expectation:MockExpectation, index:int, array:Array ):MockExpectationError
		{
			var result:MockExpectationError = null;
			
			try
			{
				expectation.verify();
			}
			catch( error:MockExpectationError )
			{
				result = error;
			}
			finally
			{
				return result;
			}
		}
		
		/**
		 *	Iterator function for filtering nulls from an array
		 *	
		 *	@private
		 */
		protected function isNotNull( object:*, index:int, array:Array ):Boolean
		{
			return object != null;
		}
		
		/**
		 * Invoke an expected method on the Mock. 
		 *	
		 * @example In order to handle ...rest parameters properly the Mock delegate classes need to be implemented as per the following example.
		 * <listing version="3.0">
		 *	public function methodWithRestArgs(a:Parameter, b:Parameter, ...rest):ReturnType {
		 *		return mock.invokeMethod('methodWithRestArgs', [a, b].concat(rest));
		 *	}
		 * </listing>
		 */
		public function invokeMethod( propertyName:String, args:Array = null):* 
		{	
			return findAndInvokeExpectation( propertyName, true, args );
		}
		
		/**
		 * Find a matching expectation and invoke it
		 *
		 * @param propertyName The property or method name to find an expectation for
		 * @param isMethod Indicates whether the expectation is for a method or a property
	   * @param args An Array of arguments to the method or property setter
	   * @private
		 */
		protected function findAndInvokeExpectation( propertyName:String, isMethod:Boolean, args:Array = null ):*
		{
			var expectation:MockExpectation = findMatchingExpectation( propertyName, isMethod, args );
			var result:* = null;
			
			if( expectation ) {
				result = expectation.invoke( isMethod, args );
			}
			
			// todo: handle almost matching expectations?
			
			return result;
		}
		
		/**
		 * Find a matching expectation
		 *
		 * @param propertyName The property or method name to find an expectaton for
		 * @param isMethod Indicates whether the expectation is for a method or a property
		 * @param args An Array of arguments to the method or property setter
		 * @throw MockExpectationError if no expectation set and ignoreMissing is false 
		 * @private
		 */
		protected function findMatchingExpectation( propertyName:String, isMethod:Boolean, args:Array = null ):MockExpectation
		{
			for each( var expectation:MockExpectation in _expectations )
			{
				if( expectation.matches( propertyName, isMethod, args ) && expectation.eligible() )
				{
					return expectation;
				}
			}
			
			if( traceMissing )
			{
				trace( this, 'missing:', propertyName, args );
			}
			
			if( ! ignoreMissing ) 
			{
				// todo: handle almost matching expectations?
				
				throw new MockExpectationError( 'No Expectation set: '
					+ toString() + '.' + propertyName 
					+ (isMethod ? '(' + (args || []).join(',') + ')' : (args ? ' = ' + args : ''))
					);
			}
			
			return null;
		}
		
		/**
		 * Specify that the given expectation should be received in sequential order, 
		 * optionally within an order-group.
		 * 
		 * @private
		 */
		mock_internal function orderExpectation( expectation:MockExpectation ):Number
		{
			var orderNumber:Number = _orderedExpectations.length;
			_orderedExpectations.push( expectation );
			return orderNumber;
		}
		
		/**
		 * @private
		 */
		mock_internal function receiveOrderedExpectation( expectation:MockExpectation, orderNumber:int ):void
		{
			if( orderNumber < _currentOrderNumber )
			{
				throw new MockExpectationError( 'Called '+ expectation.name +' out of order. Expected order '+ orderNumber +' was '+ _currentOrderNumber );
			}
			
			_currentOrderNumber = orderNumber;
		}
		
		/// ---- mock handling ---- ///
		
		// function calls
		/**
		 * @throw MockExpectationError if not expectation set and ignoreMissing is false 
		 * @private
		 */
		override flash_proxy function callProperty( name:*, ...args ):*
		{
			return findAndInvokeExpectation( name, true, args );
		}
		
		// property get requests
		/**
		 * @throw MockExpectationError if not expectation set and ignoreMissing is false 
		 * @private
		 */
		override flash_proxy function getProperty( name:* ):*
		{
			return findAndInvokeExpectation( name, false );
		}
		
		// property set requests
		/**
		 * @throw MockExpectationError if not expectation set and ignoreMissing is false 
		 * @private
		 */
		override flash_proxy function setProperty( name:*, value:* ):void
		{
			findAndInvokeExpectation( name, false, [value] );
		}
		
		/**
		 * True if we have an expectation for this property name or if ignoreMissing is true, false otherwise.
		 * 
		 * @private
		 */
		override flash_proxy function hasProperty( name:* ):Boolean
		{
			// TODO check that the class we are mocking actually has the requested property
			// always true if we are ignoring missing expectations
			if( ignoreMissing ) return true;
			
			// true if we have an expectation for this name, false otherwise
			return _expectations.some( function( e:MockExpectation, i:int, a:Array ):Boolean { return e.name == name; });
		}
		
		/*
		// property enumeration
		override flash_proxy function nextName( index:int ):String
		{
			
		}
		
		override flash_proxy function nextNameIndex( index:int ):int
		{
			
		}
		
		override flash_proxy function nextValue( index:int ):int
		{
			
		}
		*/
		
		/**
		 * @see flash.events.IEventDispatcher#addEventListener
		 */	
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			_eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		/**
		 * @see flash.events.IEventDispatcher#removeEventListener
		 */
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			_eventDispatcher.removeEventListener(type, listener, useCapture);
		}
		
		/**
		 * @see flash.events.IEventDispatcher#dispatchEvent
		 */
		public function dispatchEvent(event:Event):Boolean
		{
			return _eventDispatcher.dispatchEvent(event);
		}

		/**
		 * @see flash.events.IEventDispatcher#hasEventListener
		 */
		public function hasEventListener(type:String):Boolean
		{
			return _eventDispatcher.hasEventListener(type);
		}

		/**
		 * @see flash.events.IEventDispatcher#willTrigger
		 */
		public function willTrigger(type:String):Boolean
		{
			return _eventDispatcher.willTrigger(type);
		}
	}
}