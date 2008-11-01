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

	public class MockTest extends TestCase
	{
		public static function suite():TestSuite
		{
			return new TestSuite( MockTest );
		}
		
		public function MockTest( method:String = null )
		{
			super( method );
		}
		
		public var mock	:Mock;
		public var e		:MockExpectation;
		
		override public function setUp():void
		{
			mock = new Mock();
		}
		
		override public function tearDown():void
		{
			mock = null;
		}

		public function testShouldIgnoreMissingMethod():void
		{
			mock.ignoreMissing = true;
			mock.unicorn();
		}

		public function testShouldIgnoreMissingProperty():void
		{
			mock.ignoreMissing = true;
			mock.unicorn;
			mock.unicorn = 'horse with a horn';
		}
		
		public function testMetExpectationsShouldPassWhenIgnoreMissingIsTrue():void 
		{
			mock.ignoreMissing = true;
			mock.method('pass').twice;
			
			mock.pass();
			mock.pass();
			
			mock.verify();
		}
		
		public function testUnmetExpectationsShouldFailWhenIgnoreMissingIsTrue():void
		{
			mock.ignoreMissing = true;
			mock.method('toast').twice;
			
			try 
			{
				mock.verify();
				fail( 'Expecting Mock to throw an error about unmet expectations' );
			} 
			catch( error:MockExpectationError) 
			{
				; // NOOP
			}
		}

		public function testShouldComplainOnMissingMethod():void
		{
			mock.ignoreMissing = false;
			
			try
			{
				mock.unicorn();
				fail( 'Expecting Mock to throw an error about missing method' );
			}
			catch( error:MockExpectationError )
			{
			}
		}
		
		public function testShouldComplainOnMissingProperty():void
		{
			mock.ignoreMissing = false;
			
			// getter
			try
			{
				var creatureOfFable:* = mock.unicorn;
				fail( 'Expecting Mock to throw an error about missing property' );
			}
			catch( error:MockExpectationError )
			{
			}
			
			// setter
			try
			{
				mock.unicorn = 'creature of fable';
				fail( 'Expecting Mock to throw an error about missing property' );
			}
			catch( e:MockExpectationError )
			{
			}
		}
		
		public function testShouldHaveTargetIfSet():void
		{
			assertNull( mock.target );
			mock = new Mock( new Mock() );
			assertNotNull( mock.target );
		}
		
		public function testExpectShouldAddToMockExpectationsAndReturnMockExpectation():void
		{
			e = mock.expect();
			assertNotNull( e );
			assertTrue( e is MockExpectation );
			assertNotNull( mock.expectations );
			assertTrue( mock.expectations.indexOf( e ) != -1 );
		}
		
		public function testMethodShouldSetNameOnMockExpectationAndAddToMockExpectations():void
		{
			e = mock.method('test');
			assertNotNull( e );
			assertTrue( e is MockExpectation );
			assertEquals( 'test', e.name );
			assertNotNull( mock.expectations );
			assertTrue( mock.expectations.indexOf( e ) != -1 );
		}
		
		public function testPropertyShouldSetNameOnMockExpectationAndAddToMockExpectations():void
		{
			e = mock.property('test');
			assertNotNull( e );
			assertTrue( e is MockExpectation );
			assertEquals( 'test', e.name );
			assertNotNull( mock.expectations );
			assertTrue( mock.expectations.indexOf( e ) != -1 );
		}
		
		public function testShouldVerifyAllExpectations():void
		{
			mock.method('one').once;
			mock.method('two').twice;
			mock.method('three').withArgs( 3 );
			
			mock.one();
			mock.two();
			mock.two();
			mock.three( 3 );
			
			assertTrue( mock.verify() );
		}
		
		// ordering
		// fixme: should these ordering tests be moved to the MockTest ?
		public function testOrderedCallsInOrderWillPass():void
		{
			var one:MockExpectation = mock.method('one').ordered();
			var two:MockExpectation = mock.method('two').ordered();
			
			mock.one();
			mock.two();
			
			assertTrue( mock.verify() );
		}
		
		public function testOrderedCallsOutOfOrderWillFail():void
		{
			var one:MockExpectation = mock.method('one').ordered();
			var two:MockExpectation = mock.method('two').ordered();
			
			try
			{
				mock.two();
				mock.one();
				fail( 'Expecting out of order error' );
			}
			catch( error:MockExpectationError )
			{
				// todo: check the right error was thrown
				try 
				{
					mock.verify();
				}
				catch( error:MockExpectationError )
				{
					; // NOOP
				}
			}
		}
		
		public function testOrderedCallsToSameMethodWillPass():void
		{
			var oneCalledCount:int = 0;
			var twoCalledCount:int = 0;
			var threeCalledCount:int = 0;
			
			var one:MockExpectation 	= mock.method('testingOrdering')
				.once.ordered().calls( function():void { oneCalledCount++ } );
				
			var two:MockExpectation 	= mock.method('testingOrdering')
				.twice.ordered().calls( function():void { twoCalledCount++ } );
				
			var three:MockExpectation = mock.method('testingOrdering')
				.ordered().calls( function():void { threeCalledCount++ } );
			
			mock.testingOrdering(); // first expectation
			mock.testingOrdering(); // second expectation
			mock.testingOrdering(); // second expectation
			
			for( var i:int = 0, n:int = 20; i < n; i++ )
				mock.testingOrdering(); // third expectation
			
			assertEquals( 1, oneCalledCount );
			assertEquals( 2, twoCalledCount );
			assertEquals( 20, threeCalledCount );
			
			assertTrue( mock.verify() );
		}

		/*
			This test case is a bit awkward
		 */
		public function testOrderedCallsToSameMethodWithSameArgsDispatchesDifferentEvents():void
		{
			mock = new Mock( new EventDispatcher() );
			
			var eventSequence:Array = [];
			
			// good old FlexUnit::TestCase::addAsync, only one per testcase
			mock.target.addEventListener( 'done', addAsync( function(e:Event):void
			{
				// assert the data we stored about the event sequence is correct
				eventSequence.forEach( function( e:int, i:int, a:Array ):void
				{
					assertEquals( i, e );
				});
				
				assertTrue( mock.verify() );
			}, 100, null));
			
			// add method to dispatch done event
			mock.method('done').dispatchesEvent( new Event( 'done' ) );
			
			// add listener for the event we are actually interested in
			mock.target.addEventListener( 'example', function(e:Event):void
			{
				eventSequence.push( (e as ExampleEvent).data.id );
			});
			
			// setup five versions of callMethod to dispatch the different events
			for( var i:int = 0, n:int = 5; i < n; i++ )
			{
				var token:Object = { id: i };
				var metaData:Object = { id: i };
				var event:ExampleEvent = new ExampleEvent( 'example', metaData );
				
				// add mocked method 
				// note use of once & ordered() as they are what makes this example work
				mock.method('callMethod').withArgs( 'getMetaData' )
					.dispatchesEvent( event ).returns( token )
					.once.ordered();
			}
			
			// invoke callMethod 5 times, checking we get the right return value: a token with an id
			for( var j:int = 0, m:int = 5; j < m; j++ )
			{
				token = mock.callMethod( 'getMetaData' );
				assertEquals( j, token.id );
			}
			
			// dispatch the done event so our addAsync listener gets called
			mock.done();
		}
		
		public function testMockVerifyAggregatesFailedExpectations():void
		{
			mock = new Mock( new EventDispatcher() );
			mock.method('one').withArgs('one').once;
			mock.method('two').withArgs(2).once;
			mock.method('three').withArgs(true).once;
			
			try
			{
				mock.verify();
				fail('Expecting MockExpectationError');
			}
			catch( error:MockExpectationError )
			{
				assertEquals(
					'Verifying Mock Failed: EventDispatcher\n'
					+ 'Unmet Expectation: EventDispatcher.one("one") received: 0, expected: 1 (-1)\n'
					+ 'Unmet Expectation: EventDispatcher.two(2) received: 0, expected: 1 (-1)\n'
					+ 'Unmet Expectation: EventDispatcher.three(true) received: 0, expected: 1 (-1)',
					error.message);
			}
		}
	}
}

import flash.events.*;

internal class ExampleEvent extends Event
{
	public function ExampleEvent( type:String, data:Object )
	{
		super( type );
		this.data = data;
	}
	
	override public function clone():Event
	{
		return new ExampleEvent( type, data );
	}
	
	public var data:Object;
}