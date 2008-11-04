/*
	Copyright (c) 2007, ANYwebcam.com Pty Ltd. All rights reserved.

	The software in this package is published under the terms of the BSD style 
	license, a copy of which has been included with this distribution in the 
	license.txt file.
*/
package com.anywebcam.mock
{
	import com.anywebcam.mock.*;
	
	use namespace mock_internal;

	import flash.events.*;
	import flexunit.framework.TestCase;
	import flexunit.framework.TestSuite;

	public class MockExpectationTest extends TestCase
	{
		public static function suite():TestSuite
		{
			return new TestSuite( MockExpectationTest );
		}
		
		public function MockExpectationTest( method:String = null )
		{
			super( method );
		}
		
		public var mock	:Mock;
		public var e		:MockExpectation;
		
		override public function setUp():void
		{
			mock = new Mock( new EventDispatcher() );
			e = new MockExpectation( mock );
		}
		
		override public function tearDown():void
		{
			mock = null;
			e = null;
		}
		
		// setting method expectations
		public function testShouldSetMethodExpectation():void
		{
			e.method('testMethod').once;
			e.invoke( true );
			assertTrue( e.verifyMessageReceived() );
		}
		
		public function testMethodExpectationShouldOverridePropertyExpectationIfSetAfterwards():void
		{
			e.property('donuts');
			e.method('testMethod').once;
			e.invoke( true );
			assertTrue( e.verifyMessageReceived() );
		}
		
		public function testMethodExpectationShouldFailIfCalledAsProperty():void
		{
			try
			{
				e.method('testMethod').once;
				e.invoke( false );
				fail( 'Expecting invoking the MockExpectation as property to throw an error' );
			}
			catch( error:MockExpectationError )
			{
				try { e.verifyMessageReceived(); fail('Expecting MockExpectationError'); } 
				catch (error:MockExpectationError) { ;/* NOOP */ }
			}
		}
		
		// method arguments
		public function testMethodExpectationShouldAcceptNoArgumentsAndVerifyIfInvokedWithNoArguments():void
		{
			e.method('testMethod').withNoArgs;
			e.invoke( true );
			assertTrue( e.verifyMessageReceived() );
		}

		public function testMethodExpectationShouldAcceptNoArgumentsAndFailVerifyIfInvokedWithArguments():void
		{
			try
			{
				e.method('testMethod').once.withNoArgs;
				e.invoke( true, [1, 2, 3] );
				
				fail( 'Expecting invocation with arguments to throw an error' );
			}
			catch( error:MockExpectationError )
			{
				try { e.verifyMessageReceived(); fail('Expecting MockExpectationError'); } 
				catch (error:MockExpectationError) { ;/* NOOP */ }
			}
		}

		public function testMethodExpectationShouldVerifyWithNoArgsWhenSetToAcceptAnyArguments():void
		{
			e.method('testMethod').withAnyArgs;
			
			e.invoke( true );
			assertTrue( e.verifyMessageReceived() );
		}

		public function testMethodExpectationShouldVerifyWithNullWhenSetToAcceptAnyArguments():void
		{
			e.method('testMethod').withAnyArgs;
			
			e.invoke( true, null );
			assertTrue( e.verifyMessageReceived() );						
		}

		public function testMethodExpectationShouldVerifyWithAnyArgsWhenSetToAcceptAnyArguments():void
		{
			e.method('testMethod').withAnyArgs;
						
			e.invoke( true, [1, 2, 3, 4] );
			assertTrue( e.verifyMessageReceived() );			
		}
		
		public function testMethodExpectationShouldAcceptSpecificArgumentsAndVerityIfInvokeWithCorrectArguments():void
		{
			e.method('testMethod').withArgs( Number, Boolean, String );
			e.invoke( true, [1, true, 'test'] );
			assertTrue( e.verifyMessageReceived() );
		}
		
		public function testMethodExpectationShouldAcceptSpecificArgumentsAndFailVerifyIfInvokedWithIncorrectArguments():void
		{
			try
			{
				e.method('testMethod').withArgs( Number, Boolean, String );
				e.invoke( true, ['toast', 'crumpets', false] );
				fail( 'Expecting invocation with incorrect arguments to throw an error' );
			}
			catch( error:MockExpectationError )
			{
				try { e.verifyMessageReceived(); fail('Expecting MockExpectationError'); } 
				catch (error:MockExpectationError) { ;/* NOOP */ }
			}
		}
		
		public function testMethodExpectationShouldAcceptSingleLiteralValue():void
		{
			e.method('icanhasone').withArgs( 1 );
			e.invoke( true, [1] );
			assertTrue( e.verifyMessageReceived() );
		}
		
		public function testMethodExpectationShouldAcceptSingleLiteralValueAndFailVerifyIfInvokedWithIncorrectArguments():void
		{
			try
			{
				e.method('icanhasone').withArgs( 1 );
				e.invoke(true, [0]);
				fail( 'Expecting invocation with incorrect arguments to throw an error' );
			}
			catch( error:MockExpectationError )
			{
				try { e.verifyMessageReceived(); fail('Expecting MockExpectationError'); } 
				catch (error:MockExpectationError) { ;/* NOOP */ }
			}
		}
		
		// setting property expectations
		public function testShouldSetPropertyExpectation():void
		{
			e.property('testProperty');
			e.invoke( false );
			assertTrue( e.verifyMessageReceived() );
		}
		
		public function testPropertyExpectationShouldOverrideMethodExpectationIfSetAfterwards():void
		{
			e.method('toast');
			e.property('donuts');
			assertEquals( 'donuts', e.name );
			e.invoke( false );
			assertTrue( e.verifyMessageReceived() );
		}
		
		public function testPropertyExpectationShouldVerifyWithCorrectArgument():void
		{
			e.property('testProperty').withArgs( String );
			e.invoke( false, ['hello'] );
			assertTrue( e.verifyMessageReceived() );
		}
		
		public function testPropertyExpectationShouldFailToVerifyWithIncorrectArgument():void
		{
			try
			{
				e.property('testProperty').withArgs( String );
				e.invoke( false, [4] );
				fail( 'Expecting invocation with incorrect arguments to throw an error' );
			}
			catch( error:MockExpectationError )
			{
				try { e.verifyMessageReceived(); fail('Expecting MockExpectationError'); } 
				catch (error:MockExpectationError) { ;/* NOOP */ }
			}
		}
		
		public function testPropertyExpectationShouldComplainOnSettingMoreThanOneArgumentExpectation():void
		{
			try
			{
				e.property('testProperty').withArgs( String, Number );
				fail( 'Expecting settings multiple argument expectations to throw an error' );
			}
			catch( error:MockExpectationError )
			{
				// true because we didnt invoke the property, and the default receive count is any
				assertTrue( e.verifyMessageReceived() );
			}
		}
		
		public function testPropertyExpectationShouldFailToVerifyIfInvokedWithMultipleArguments():void
		{
			try
			{
				e.property('testProperty').withArgs( String );
				e.invoke( false, ['hello', 'world'] );
				fail( 'Expecting invocation of property with multiple arguments to throw an error' );
			}
			catch( error:MockExpectationError )
			{
				try { e.verifyMessageReceived(); fail('Expecting MockExpectationError'); } 
				catch (error:MockExpectationError) { ;/* NOOP */ }
			}
		}
		
		// settings return values
		public function testShouldSetReturnValuesOverridesPreviouslySetThrowError():void
		{
			e.method('test').andThrow( new Error('NotToBeThrown') ).andReturn( true );
			var retval:* = e.invoke( true );
			assertEquals( true, retval );
		}
		
		public function testShouldSetReturnValueAndReturnItOnInvoke():void
		{
			e.method('test').andReturn( true );
			var retval:* = e.invoke( true );
			assertEquals( true, retval );
		}
		
		public function testShouldSetMulitpleReturnValuesAndReturnValuesInSetSequence():void
		{
			e.method('test').andReturn( 1, 1, 2, 3, 5, 8 );

			var expectedValues:Array = [1, 1, 2, 3, 5, 8 ];
			expectedValues.forEach( function( v:Number, i:int, a:Array ):void
			{
				assertTrue( v, e.invoke( true ) );
			});
			
			assertTrue( e.verifyMessageReceived() );
		}
		
		public function testShouldReturnValuesSequentiallyThenRepeatLastValueForAllSubsequentInvocations():void
		{
			e.method('test').andReturn( 'the good', 'the bad', 'the ugly' );

			var expectedValues:Array = [ 'the good', 'the bad', 'the ugly', 'the ugly', 'the ugly' ];
			expectedValues.forEach( function( v:String, i:int, a:Array ):void
			{
				assertEquals( v, e.invoke( true ) );
			});
			
			assertTrue( e.verifyMessageReceived() );
		}
		
		// settings throw errors
		public function testShouldSetThrowErrorOverridesPreviouslySetReturnValues():void
		{
			try
			{
				e.method('test').andReturn( 'dontReturnMe' ).andThrow( new Error('PleaseThrowMe') );
				e.invoke( true );
				fail( 'Expecting the set throw error to be thrown' );
			}
			catch( error:Error )
			{
				assertEquals( 'PleaseThrowMe', error.message );
			}
		}
		
		public function testShouldSetThrowErrorAndThrowErrorOnInvokeAndVerify():void
		{
			try
			{
				e.method('test').andThrow( new Error('ThrownByMockExpectation') );
				e.invoke( true );
				fail( 'Expecting set error to be thrown on expectation invocation' );
			}
			catch( error:Error )
			{
				assertEquals( 'ThrownByMockExpectation', error.message );
				assertTrue( e.verifyMessageReceived() );
			}
		}
		
		// setting receive counts
		public function testShouldVerifyIfReceiveCountIsAnyAndExpectationIsNotInvoked():void
		{
			e.method('test').anyNumberOfTimes;
			assertTrue( e.verifyMessageReceived() );
		}
		
		public function testShouldVerifyIfReceiveCountIsAnyAndExpectationIsInvoked():void
		{
			e.method('test').anyNumberOfTimes;
			e.invoke( true );
			e.invoke( true );
			e.invoke( true );
			e.invoke( true );
			assertTrue( e.verifyMessageReceived() );
		}
		
		public function testShouldVerifyIfReceiveCountIsNeverAndExpectationIsNotInvoked():void
		{
			e.method('test').never;
			assertTrue( e.verifyMessageReceived() );
		}
		
		public function testShouldNotVerifyIfReceiveCountIsNeverAndExpectationIsInvoked():void
		{
			e.method('test').never;
			
			try
			{
				e.invoke( true );
				fail('Expecting MockExpectation#invoke to throw a MockExpectationError');
			}
			catch( error:MockExpectationError )
			{
				; // NOOP
			}
		}
		
		// invoke exactly
		public function testShouldVerifyIfReceiveCountIsExactlyAndInvokedCorrectNumberOfTimes():void
		{
			e.method('test').exactly( 3 );
			e.invoke( true );
			e.invoke( true );
			e.invoke( true );
			assertTrue( e.verifyMessageReceived() );
		}
		
		public function testShouldNotVerifyIfReceiveCountIsExactlyAndNotInvokedCorrectNumberOfTimes():void
		{
			e.method('test').exactly( 1 );
			e.invoke( true );
			e.invoke( true );
			e.invoke( true );
			try 
			{
				e.verifyMessageReceived();
				fail('Expecting MockExpectation#verifyMessageReceived to throw a MockExpectationError');
			}
			catch( error:MockExpectationError ) 
			{
				; // NOOP
			}
		}
		
		// invoked less than, and more than
		public function testShouldVerifyIfReceiveCountIsAtLeast():void
		{
			e.method('test').atLeast( 3 );
			
			e.invoke( true );
			try { e.verifyMessageReceived(); fail('Expecting MockExpectationError'); } 
			catch (error:MockExpectationError) { ;/* NOOP */ }
			
			e.invoke( true );
			try { e.verifyMessageReceived(); fail('Expecting MockExpectationError'); } 
			catch (error:MockExpectationError) { ;/* NOOP */ }
			
			e.invoke( true );
			assertTrue( e.verifyMessageReceived() );

			e.invoke( true );
			assertTrue( e.verifyMessageReceived() );
		}
		
		// invoked less than, and more than
		public function testShouldVerifyIfReceiveCountIsAtMost():void
		{
			e.method('test').atMost( 2 );
			
			e.invoke( true );
			assertTrue( e.verifyMessageReceived() );
			
			e.invoke( true );
			assertTrue( e.verifyMessageReceived() );
			
			e.invoke( true );
			try { e.verifyMessageReceived(); fail('Expecting MockExpectationError'); } 
			catch (error:MockExpectationError) { ;/* NOOP */ }

			e.invoke( true );
			try { e.verifyMessageReceived(); fail('Expecting MockExpectationError'); } 
			catch (error:MockExpectationError) { ;/* NOOP */ }
		}
		
		// at least, at most, at least & at most
		public function testShouldVerifyIfReceiveCountIsAtLeastAndAtMost():void
		{
			e.method('test').atLeast( 2 ).atMost( 3 );
			
			e.invoke( true );
			try { e.verifyMessageReceived(); fail('Expecting MockExpectationError'); } 
			catch (error:MockExpectationError) { ;/* NOOP */ }

			e.invoke( true );
			assertTrue( e.verifyMessageReceived() );

			e.invoke( true );
			assertTrue( e.verifyMessageReceived() );

			e.invoke( true );
			try { e.verifyMessageReceived(); fail('Expecting MockExpectationError'); } 
			catch (error:MockExpectationError) { ;/* NOOP */ }
		}
		
		// receive counts only apply to matching args
		public function testReceiveCountShouldOnlyApplyToMatchingArguments():void
		{
			mock.method('hi').withArgs(1).once;
			mock.method('hi').withArgs(2).twice;
			mock.method('hi').withArgs(3);
			mock.hi(1);
			mock.hi(2);
			mock.hi(2);
			for( var i:int=0, n:int=20; i < n; i++ )
			{
				mock.hi(3);
			}
			assertTrue( mock.verify() );
		}
		
		public function testReceiveCountShouldNotApplyToMismatchedArguments():void
		{
			mock.method('hi').withArgs(1).once;
			mock.method('hi').withArgs(2).twice;
			mock.method('hi').withArgs(3);
			mock.method('lo');
			
			mock.hi(1);
			mock.hi(2);
			mock.lo();
			for( var i:int=0, n:int=20; i < n; i++ )
			{
				mock.hi(3);
			}
			
			try 
			{
				mock.verify();
				fail('Expecting MockExpectationError for receiveCount not met for mock.method("hi").withArgs(2).twice');
			}
			catch (error:MockExpectationError) 
			{
				; // NOOP
			}
		}
		
		// invoking functions
		public function testShouldSetFunctionToInvokeOnInvokingExpectation():void
		{
			var invoked:int = 0;
			
			e.method('test').andCall( function():void { invoked++; });
			e.invoke( true );
			
			assertEquals( 1, invoked );
		}
		
		public function testShouldSetMultipleFunctionsToInvokeInvokingExpectation():void
		{
			var invoked:int = 0;
			
			e.method('test')
				.andCall( function():void { invoked++; } )
				.andCall( function():void { invoked++; } )
				.andCall( function(args:Array=null):void { invoked++; } )
				.andCall( function(args:Array=null):void { invoked++; } );

			e.invoke( true );
			
			assertEquals( 4, invoked );
		}
		
		public function testFunctionsToCallShouldReceiveArgsFromInvoke():void
		{
			e.method('test').withAnyArgs.calls( function(...rest):void 
			{  
				assertEquals( 3, rest.length );
				assertEquals( rest[0], 'one' );
				assertEquals( rest[1], 2 );
				assertEquals( rest[2], true );
			});
			
			e.invoke( true, ['one', 2, true] );
		}
		
		// dispatching events
		public function testShouldSetEventToDispatchOnInvokingExpectation():void
		{
			var invoked:int = 0;
			/*var target:IEventDispatcher = mock.target as IEventDispatcher;*/
			
			mock.addEventListener( 'testEvent', function(e:Event):void { invoked++; } )
			
			e.method('test').andDispatchEvent( new Event('testEvent') );
			e.invoke( true );
			
			assertEquals( 1, invoked );
		}
		
		public function testShouldDispatchAllEventsSetOnExpectationWhenInvoked():void
		{
			var invoked:int = 0;
			/*var target:IEventDispatcher = mock.target as IEventDispatcher;*/
			
			mock.addEventListener( 'eventOne', function(e:Event):void { invoked++; } );
			mock.addEventListener( 'eventTwo', function(e:Event):void { invoked++; } );
			mock.addEventListener( 'verify', addAsync( function(e:Event):void
			{
				assertEquals( 2, invoked );
			}, 100, null ));
			
			e.method('test')
				.withNoArgs
				.dispatchesEvent( new Event('eventOne') )
				.dispatchesEvent( new Event('eventTwo') );
			
			// dispatches eventOne, and eventTwo
			e.invoke( true );
			
			// dispatch verify, which calls the function with assertEquals
			mock.dispatchEvent( new Event('verify') );
		}
				
		// verify messages sent
		// anything we would do here should be done in other test functions anyway
		/*public function testShouldVerifyIfAllExpectationsAreMet():void
		{
			fail();
		}*/
		
		public function testUnmetReceiveCountExpectationsShouldHaveNiceErrorMessages():void {
			
			//e.method('test').withArgs(Boolean, Mock, function():void {}, "one", true, false, 3, Number, RegExp, /\d+/, String).once;
			e.method('test').withArgs("one", 2, true).atLeast(1).atMost(2);
			
			e.invoke(true, ["one", 2, true]);
			e.invoke(true, ["one", 2, true]);
			e.invoke(true, ["one", 2, true]);
			
			try 
			{
				e.verifyMessageReceived();
				fail('Expecting an UnmetMockExpectationError to be thrown');
			}
			catch( error:MockExpectationError ) 
			{
				assertEquals(
					'Unmet Expectation: EventDispatcher.test("one", 2, true) received: 3, expected: atLeast: 1 (+2), atMost: 2 (+1)',
					error.message);
			}
		}
	}
}