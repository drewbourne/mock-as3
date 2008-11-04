/*
	Copyright (c) 2007, ANYwebcam.com Pty Ltd. All rights reserved.

	The software in this package is published under the terms of the BSD style 
	license, a copy of which has been included with this distribution in the 
	license.txt file.
*/
package com.anywebcam.mock
{
	import com.anywebcam.mock.*;
	import com.anywebcam.mock.examples.*;
	
	use namespace mock_internal;

	import flash.events.*;
	import flexunit.framework.TestCase;
	import flexunit.framework.TestSuite;

	public class Examples extends TestCase
	{
		public static function suite():TestSuite
		{
			return new TestSuite( Examples );
		}
		
		public function Examples( method:String = null )
		{
			super( method );
		}
		
		public function testSomeComponentExample():void 
		{
			var e:MockExample = new MockExample( true );
			e.mock.method( 'acceptNumber' ).withArgs( 10 ).once;
			e.mock.method( 'giveString' ).returns( 'ten' ).once;
			e.mock.method( 'neverCalled' ).withArgs( 'not', 'now', 'not', 'ever' ).never;
			
			var c:SomeComponent = new SomeComponent( e );
			var retval:String = c.doSomethingWithExample( 10 );
			
			assertEquals( 'ten', retval );
			
			e.mock.verify();
		}
		
		public function testSomeComponentExampleAndIgnoreMissing():void 
		{
			var e:MockExample = new MockExample( true );
			e.mock.method( 'acceptNumber' ).withArgs( 10 ).once;
			e.mock.method( 'giveString' ).returns( 'ten' ).once;
			e.mock.method( 'optional' ).withArgs( 'not', 'now', 'not', 'ever' ).never;
			
			e.mock.fake();
			e.mock.doesNotExist();
			e.mock.ignored();
			
			var c:SomeComponent = new SomeComponent( e );
			c.doSomethingWithExample( 10 );

			e.mock.verify();
		}
		
		public function testSomeComponentExampleAndIgnoreMissingFailsForUnmetExpectations():void 
		{
			var e:MockExample = new MockExample( true );
			e.mock.method( 'acceptNumber' ).withArgs( 10 ).twice;
			e.mock.method( 'giveString' ).returns( 'ten' ).twice;
			e.mock.method( 'optional' ).withArgs( 'not', 'now', 'not', 'ever' ).never;
			
			e.mock.fake();
			e.mock.doesNotExist();
			e.mock.ignored();
			
			var c:SomeComponent = new SomeComponent( e );
			c.doSomethingWithExample( 10 );
			
			try 
			{
				e.mock.verify();
				fail('Expecting MockExpectationError for unmet receiveCount expectation');
			}
			catch (error:MockExpectationError) 
			{
				; // NOOP
			}
		}
		
		public function testRestArgumentsAndReceiveCountWorks():void {
			
			var e:MockExample = new MockExample();
			e.mock.method('optional').withArgs(1).once;
			
			e.optional(1);
			
			e.mock.verify();
		}
		
		public function testWithAnyArgsAndReceiveCountWorks():void {
			
			var e:MockExample = new MockExample();
			e.mock.method('optional').withAnyArgs.twice;
			
			e.optional(1, 2);
			e.optional(3);
			
			e.mock.verify();
		}
		
		public function testWithAnyArgsAndReceiveCountFailsWithANiceErrorMessage():void {
			
			var e:MockExample = new MockExample();
			e.mock.method('optional').withAnyArgs.twice;
			
			e.optional(1, 2);
			e.optional(3);
			
			try
			{
				e.optional(4);
				fail('expecting MockExpectationError');
			}
			catch( error:MockExpectationError )
			{
				// TODO in this case we should find the closest almost matching expectations and report on that?
				// TODO the error should be formatted like the Unmet Expectation error
				assertEquals(
					'this should be a nice error message, right now it isnt',
					error.message);
			}
		}
		
		public function testParametersAndReturns():void
		{
		  var e:MockExample = new MockExample( true );
		  e.mock.method( 'acceptNumber' ).withArgs( 15 ).once;
		  e.mock.method( 'giveString' ).returns( 'ten' ).once;
		  
		  var c:SomeComponent = new SomeComponent( e );
		  var retval:String = c.doSomethingWithExample( 15 );
        
		  assertEquals( 'ten', retval );
		  
		  e.mock.verify();
		}
		
		public function testCallThroughs():void
		{
			var e:MockExample = new MockExample( false );
			e.mock.method( 'justCall' ).withNoArgs.never;

			var c:SomeComponent = new SomeComponent( e );
			
			try 
			{
				c.justCallExample();
				fail('Expecing MockExpectationError for never method expectation');
			}
			catch (error:MockExpectationError) 
			{
				; // NOOP
			}
		}

		public function testCallWithRest():void
		{
			var e:MockExample = new MockExample( false );
			e.mock.method( 'callWithRest' ).withArgs("foo", "bar").once;

			var c:SomeComponent = new SomeComponent( e );
			c.callWithRest("foo", "bar");

			e.mock.verify();
		}        

		public function testDispatchMyEvent():void
		{
			var e:MockExample = new MockExample( false );
			var event : Event = new Event( "myEvent" );
			e.mock.method( 'dispatchMyEvent' ).withNoArgs.once.dispatchesEvent( event );
			
			var c:SomeComponent = new SomeComponent( e );
			c.dispatchMyEventWithExample();
			
			e.mock.verify();
			assertTrue( "expected event to be handled", c.isEventHandled );
		}
	}
}