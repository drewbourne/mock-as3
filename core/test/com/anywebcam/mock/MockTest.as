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
		
		public function testShouldVerifyOrderedExpectations():void
		{
			fail( 'Ordering not yet tested or implemented' );
		}
		
		public function testShouldVerifyExpectationsOrderedInGroups():void
		{
			fail( 'Grouped Ordering not yet tested or implemented' );
		}
	}
}