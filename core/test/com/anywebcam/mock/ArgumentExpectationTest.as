/*
	Copyright (c) 2007, ANYwebcam.com Pty Ltd. All rights reserved.

	The software in this package is published under the terms of the BSD style 
	license, a copy of which has been included with this distribution in the 
	license.txt file.
*/
package com.anywebcam.mock
{
	import com.anywebcam.mock.argumentConstraint.*;

	import flexunit.framework.TestCase;
	import flexunit.framework.TestSuite;

	public class ArgumentExpectationTest extends TestCase
	{
		public static function suite():TestSuite
		{
			return new TestSuite( ArgumentExpectationTest );
		}
		
		public function ArgumentExpectationTest( method:String = null )
		{
			super( method );
		}
		
		public function testShouldAcceptZeroArgumentConstraintsInConstructor():void 
		{
			var expect:ArgumentExpectation = new ArgumentExpectation();
		}
		
		public function testShouldAcceptOneArrayOfArgumentConstraintsInConstructor():void
		{
			var expect1:ArgumentExpectation = new ArgumentExpectation( [] );
			var expect2:ArgumentExpectation = new ArgumentExpectation( [ 1 ] );
			var expect3:ArgumentExpectation = new ArgumentExpectation( [ 1, 'two', {value: 3} ] );
		}
		
		public function testShouldConvertStringConstantToStringArgumentConstraint():void
		{
			var expect:ArgumentExpectation = new ArgumentExpectation( [ ArgumentExpectation.STRING ] );
			
			assertTrue( 'Expecting expectedArguments to be an Array', expect.expectedArguments is Array );
			assertTrue( 'Expecting 1 ArgumentConstraint', expect.expectedArguments.length == 1 );
			assertTrue( 'Expecting ArgumentConstraint to be a StringArgumentConstraint', 
				(expect.expectedArguments[ 0 ] as ArgumentConstraint) 
				is (ArgumentExpectation.constraintClasses[ ArgumentExpectation.STRING ] as Class) );
		}
		
		public function testShouldConvertNumberConstantToNumberArgumentConstraint():void
		{
			var expect:ArgumentExpectation = new ArgumentExpectation( [ ArgumentExpectation.NUMBER ] );
			
			assertTrue( 'Expecting expectedArguments to be an Array', expect.expectedArguments is Array );
			assertTrue( 'Expecting 1 ArgumentConstraint', expect.expectedArguments.length == 1 );
			assertTrue( 'Expecting ArgumentConstraint to be a NumberArgumentConstraint', 
				(expect.expectedArguments[ 0 ] as ArgumentConstraint) 
				is (ArgumentExpectation.constraintClasses[ ArgumentExpectation.NUMBER ] as Class) );
		}
		
		public function testShouldConvertBooleanConstantToNumberArgumentConstraint():void
		{
			var expect:ArgumentExpectation = new ArgumentExpectation( [ ArgumentExpectation.BOOLEAN ] );
			
			assertTrue( 'Expecting expectedArguments to be an Array', expect.expectedArguments is Array );
			assertTrue( 'Expecting 1 ArgumentConstraint', expect.expectedArguments.length == 1 );
			assertTrue( 'Expecting ArgumentConstraint to be a BooleanArgumentConstraint', 
				(expect.expectedArguments[ 0 ] as ArgumentConstraint) 
				is (ArgumentExpectation.constraintClasses[ ArgumentExpectation.BOOLEAN ] as Class) );
		}
		
		public function testShouldConvertAnythingConstantToAnythingArgumentConstraint():void
		{
			var expect:ArgumentExpectation = new ArgumentExpectation( [ ArgumentExpectation.ANYTHING ] );
			assertTrue( 'Expecting expectedArguments to be null', expect.expectedArguments == null );
		}
		
		public function testShouldConvertClassArgumentsToClassArgumentConstraint():void
		{
			var expect:ArgumentExpectation = new ArgumentExpectation( [ TestCase ] );
			
			assertTrue( 'Expecting expectedArguments to be an Array', expect.expectedArguments is Array );
			assertTrue( 'Expecting 1 ArgumentConstraint', expect.expectedArguments.length == 1 );
			assertTrue( 'Expecting ArgumentConstraint to be a ClassArgumentConstraint', 
				(expect.expectedArguments[ 0 ] as ArgumentConstraint) 
				is (ArgumentExpectation.constraintClasses[ ArgumentExpectation.CLASS ] as Class) );
		}
		
		public function testShouldConvertFunctionArgumentsToFunctionArgumentConstraint():void
		{
			var func:Function = function( value:Object ):Boolean { return true; };
			var expect:ArgumentExpectation = new ArgumentExpectation( [ func ] );
			
			assertTrue( 'Expecting expectedArguments to be an Array', expect.expectedArguments is Array );
			assertTrue( 'Expecting 1 ArgumentConstraint', expect.expectedArguments.length == 1 );
			assertTrue( 'Expecting ArgumentConstraint to be a FunctionArgumentConstraint', 
				(expect.expectedArguments[ 0 ] as ArgumentConstraint) 
				is (ArgumentExpectation.constraintClasses[ ArgumentExpectation.FUNCTION ] as Class) );
		}
		
		public function testShouldConvertRegExpArgumentsToRegExpArgumentConstraint():void
		{
			var regexp:RegExp = /[a-z]+/gi
			var expect:ArgumentExpectation = new ArgumentExpectation( [ regexp ] );

			assertTrue( 'Expecting expectedArguments to be an Array', expect.expectedArguments is Array );
			assertTrue( 'Expecting 1 ArgumentConstraint', expect.expectedArguments.length == 1 );
			assertTrue( 'Expecting ArgumentConstraint to be a RegExpArgumentConstraint', 
				(expect.expectedArguments[ 0 ] as ArgumentConstraint) 
				is (ArgumentExpectation.constraintClasses[ ArgumentExpectation.REGEXP ] as Class) );
		}
		
		public function testShouldConvertLiteralValueToLiteralValueArgumentConstraintIfArgumentIsNotAClassFunctionRegExpOrCustomMatcher():void
		{
			var literalObject:Object = {value:'literalObject'};
			var literalValue:String = 'literalValue';
			var literalNumber:Number = 3000;
			var type:Class = TestCase;
			var func:Function = function( value:Object ):Boolean { return true; };
			var regexp:RegExp = /[a-z]+/gi
			
			var expect:ArgumentExpectation = new ArgumentExpectation( [ literalObject, literalValue, literalNumber, type, func, regexp ] );
			
			assertTrue( 'Expecting expectedArguments to be an Array', expect.expectedArguments is Array );
			assertTrue( 'Expecting 6 ArgumentConstraints', expect.expectedArguments.length == 6 );
			assertTrue( 'Expecting ArgumentConstraint to be a LiteralArgumentConstraint', 
				(expect.expectedArguments[ 0 ] as ArgumentConstraint) 
				is (ArgumentExpectation.constraintClasses[ ArgumentExpectation.LITERAL ] as Class) );
			assertTrue( 'Expecting ArgumentConstraint to be a LiteralArgumentConstraint', 
				(expect.expectedArguments[ 1 ] as ArgumentConstraint) 
				is (ArgumentExpectation.constraintClasses[ ArgumentExpectation.LITERAL ] as Class) );
			assertTrue( 'Expecting ArgumentConstraint to be a LiteralArgumentConstraint', 
				(expect.expectedArguments[ 2 ] as ArgumentConstraint) 
				is (ArgumentExpectation.constraintClasses[ ArgumentExpectation.LITERAL ] as Class) );
			assertTrue( 'Expecting ArgumentConstraint to be a ClassArgumentConstraint', 
				(expect.expectedArguments[ 3 ] as ArgumentConstraint) 
				is (ArgumentExpectation.constraintClasses[ ArgumentExpectation.CLASS ] as Class) );
			assertTrue( 'Expecting ArgumentConstraint to be a FunctionArgumentConstraint', 
				(expect.expectedArguments[ 4 ] as ArgumentConstraint) 
				is (ArgumentExpectation.constraintClasses[ ArgumentExpectation.FUNCTION ] as Class) );
			assertTrue( 'Expecting ArgumentConstraint to be a RegExpArgumentConstraint', 
				(expect.expectedArguments[ 5 ] as ArgumentConstraint) 
				is (ArgumentExpectation.constraintClasses[ ArgumentExpectation.REGEXP ] as Class) );
		}
		
		public function testAnyArgumentConstraintShouldMatchAnyValue():void
		{
			var expect:ArgumentExpectation = new ArgumentExpectation( ArgumentExpectation.ANYTHING );
			
			assertTrue( 'Expecting True', expect.argumentsMatch( null ) );
			assertTrue( 'Expecting True', expect.argumentsMatch([ null ]) );
			assertTrue( 'Expecting True', expect.argumentsMatch([ true ]) );			
			assertTrue( 'Expecting True', expect.argumentsMatch([ false ]) );			
			assertTrue( 'Expecting True', expect.argumentsMatch([ TestCase ]) );			
			assertTrue( 'Expecting True', expect.argumentsMatch([ 1, 2, 3 ]) );			
			assertTrue( 'Expecting True', expect.argumentsMatch([{value: 'one'}]) );			
		}
		
		public function testNumberArgumentConstraintShouldMatchNumberUintOrInt():void
		{
			var expect:ArgumentExpectation = new ArgumentExpectation([ ArgumentExpectation.NUMBER ]);
			
			var n:Number = Number( 1 );
			var u:uint = uint( 10000 );
			var i:int = int( -10000 );
			
			assertFalse( 'Expecting False', expect.argumentsMatch( null ) );
			assertTrue( 'Expecting True', expect.argumentsMatch([ n ]) );
			assertTrue( 'Expecting True', expect.argumentsMatch([ u ]) );
			assertTrue( 'Expecting True', expect.argumentsMatch([ i ]) );
			assertFalse( 'Expecting False', expect.argumentsMatch([ n, u, i ]) );
			assertFalse( 'Expecting False', expect.argumentsMatch([ 'test' ]) );
			assertFalse( 'Expecting False', expect.argumentsMatch([ {} ]) );
		}
		
		public function testBooleanArgumentConstraintShouldMatchBooleanTrueOrFalseOnly():void
		{
			var expect:ArgumentExpectation = new ArgumentExpectation([ ArgumentExpectation.BOOLEAN ]);
			
			var t:Boolean = true;
			var f:Boolean = false;
			var none:Object = {};
			
			assertFalse( 'Expecting False', expect.argumentsMatch( null ) );
			assertTrue( 'Expecting True', expect.argumentsMatch( [t] ) );
			assertTrue( 'Expecting True', expect.argumentsMatch( [f] ) );			
			assertTrue( 'Expecting True', expect.argumentsMatch( [true] ) );						
			assertTrue( 'Expecting True', expect.argumentsMatch( [false] ) );
			assertFalse( 'Expecting False', expect.argumentsMatch( [none] ) );
			assertFalse( 'Expecting False', expect.argumentsMatch( [0] ) );			
			assertFalse( 'Expecting False', expect.argumentsMatch( [1] ) );			
		}
		
		public function testStringArgumentConstraintShouldMatchAnyString():void
		{
			var expect:ArgumentExpectation = new ArgumentExpectation([ ArgumentExpectation.STRING ]);

			assertFalse( 'Expecting False', expect.argumentsMatch( null ) );
			assertTrue( 'Expecting True', expect.argumentsMatch( [''] ) );
			assertTrue( 'Expecting True', expect.argumentsMatch( ['1'] ) );
			assertTrue( 'Expecting True', expect.argumentsMatch( ['donuts'] ) );
			assertFalse( 'Expecting False', expect.argumentsMatch( [true] ) );
			assertFalse( 'Expecting False', expect.argumentsMatch( [{}] ) );
			assertFalse( 'Expecting False', expect.argumentsMatch( [TestCase] ) );			
		}
		
		public function testClassArgumentConstraintShouldMatchIfValueIsTheExpectedClass():void
		{
			var expect:ArgumentExpectation = new ArgumentExpectation([ ArgumentExpectation ]);
			
			assertFalse( 'Expecting False', expect.argumentsMatch( null ) );
			assertTrue( 'Expecting True', expect.argumentsMatch([ ArgumentExpectation ]) );			
		}
		
		public function testClassArgumentConstraintShouldMatchIfValueIsInstanceOfExpectedClass():void
		{
			var expect:ArgumentExpectation = new ArgumentExpectation([ ArgumentExpectation ]);
			
			assertFalse( 'Expecting False', expect.argumentsMatch( null ) );
			assertTrue( 'Expecting True', expect.argumentsMatch([ expect ]) );
			assertFalse( 'Expecting False', expect.argumentsMatch( [1] ) );			
			assertFalse( 'Expecting False', expect.argumentsMatch( ['two'] ) );
			assertFalse( 'Expecting False', expect.argumentsMatch( [{}] ) );
			assertFalse( 'Expecting False', expect.argumentsMatch( [ TestCase ] ) );
			assertFalse( 'Expecting False', expect.argumentsMatch( [ this ] ) );
		}
		
		public function testFunctionArgumentConstraintShouldMatchIfValueIsTheExpectedFunction():void
		{
			var func:Function = function( value:Object ):Boolean { return true; };
			var expect:ArgumentExpectation = new ArgumentExpectation([ func ]);
			
			assertTrue( 'Expecting True', expect.argumentsMatch([ func ]) );
			assertFalse( 'Expecting False', expect.argumentsMatch( null ) );			
		}
		
		public function testFunctionArgumentConstraintShouldMatchIfFunctionApplyArgumentValueReturnsTrue():void
		{
			var donut:Number = 0;
			var func:Function = function( value:Object ):Boolean { return value === donut; };
			var expect:ArgumentExpectation = new ArgumentExpectation([ func ]);
			
			assertTrue( 'Expecting True', expect.argumentsMatch([ donut ]) );			
			assertTrue( 'Expecting False', expect.argumentsMatch([ func ]) );			
			assertFalse( 'Expecting False', expect.argumentsMatch( null ) );
			assertFalse( 'Expecting False', expect.argumentsMatch([ 1 ]) );			
			assertFalse( 'Expecting False', expect.argumentsMatch([ true ]) );	
			assertFalse( 'Expecting False', expect.argumentsMatch([ false ]) );							
			assertFalse( 'Expecting False', expect.argumentsMatch([ 'two' ]) );
			assertFalse( 'Expecting False', expect.argumentsMatch([ {} ]) );
			assertFalse( 'Expecting False', expect.argumentsMatch([ TestCase ]) );
			assertFalse( 'Expecting False', expect.argumentsMatch([ this ]) );
		}
		
		public function testRegExpArgumentConstraintShouldMatchIfValueIsRegExp():void
		{
			var regexp:RegExp = /[a-z]{1,3}/;
			var expect:ArgumentExpectation = new ArgumentExpectation([ regexp ]);
			
			assertTrue( 'Expecting True', expect.argumentsMatch([ regexp ]) );
			assertFalse( 'Expecting False', expect.argumentsMatch( null ) );
			assertFalse( 'Expecting False', expect.argumentsMatch([ '0-9' ]) );
			assertFalse( 'Expecting False', expect.argumentsMatch([ 0 ] ) );
			assertFalse( 'Expecting False', expect.argumentsMatch([ 1 ] ) );
			assertFalse( 'Expecting False', expect.argumentsMatch([ true ] ) );
			assertFalse( 'Expecting False', expect.argumentsMatch([ false ] ) );
			assertFalse( 'Expecting False', expect.argumentsMatch([ {} ] ) );
			assertFalse( 'Expecting False', expect.argumentsMatch([ TestCase ] ) );
			assertFalse( 'Expecting False', expect.argumentsMatch([ this ] ) );
		}
		
		public function testRegExpArgumentConstraintShouldMatchIfValueIsStringAndRegExpTestMatches():void
		{
			var regexp:RegExp = /[a-z]{1,3}/;
			var expect:ArgumentExpectation = new ArgumentExpectation([ regexp ]);
			
			assertTrue( 'Expecting True', expect.argumentsMatch([ regexp ]) );
			assertTrue( 'Expecting True', expect.argumentsMatch([ 'abc' ]) );
			assertTrue( 'Expecting True', expect.argumentsMatch([ 'def' ]) );
			assertTrue( 'Expecting True', expect.argumentsMatch([ 'abc123' ]) );			
			assertTrue( 'Expecting True', expect.argumentsMatch([ 'abcdefg' ]) );
			assertFalse( 'Expecting False', expect.argumentsMatch([ '' ]) );
			assertFalse( 'Expecting False', expect.argumentsMatch([ '123' ]) );
			assertFalse( 'Expecting False', expect.argumentsMatch( null ) );
		}
		
		public function testShouldFailToMatchIfSentArgumentsWhenSetToNoArgs():void
		{
			var expect:ArgumentExpectation = new ArgumentExpectation( ArgumentExpectation.NO_ARGS );
			
			assertTrue( 'Expecting True', expect.argumentsMatch( [] ) );						
			assertFalse( 'Expecting False', expect.argumentsMatch( null ) );
			assertFalse( 'Expecting False', expect.argumentsMatch( [1, 2, 3] ) );			
		}
	}
}