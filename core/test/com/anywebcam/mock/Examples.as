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
			var e:MockExample = new MockExample( false );
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
		
	}
}