/*
	Copyright (c) 2007, ANYwebcam.com Pty Ltd. All rights reserved.

	The software in this package is published under the terms of the BSD style 
	license, a copy of which has been included with this distribution in the 
	license.txt file.
*/
package com.anywebcam.mock
{
	import com.anywebcam.mock.argumentConstraint.*;

	/**
	 * Manages constraints to place on arguments supplied to an expectation
	 */
	public class ArgumentExpectation
	{
		public static const NO_ARGS		:String = 'NoArgs';
		public static const ANYTHING	:String = 'Anything';
		public static const NUMBER		:String = 'Number';
		public static const BOOLEAN		:String = 'Boolean';
		public static const STRING		:String = 'String';
		public static const CLASS			:String	= 'Class';
		public static const FUNCTION	:String = 'Function';
		public static const REGEXP		:String = 'RegExp';
		public static const LITERAL		:String = 'Literal';

		/**
		 * Map of names to ArgumentConstraint classes
		 */
		public static var constraintClasses:Object =
		{
			'Anything': 	AnyArgumentConstraint,
			'Number': 		NumberArgumentConstraint,
			'Boolean': 		BooleanArgumentConstraint,
			'String':			StringArgumentConstraint,
			'Class':			ClassArgumentConstraint,
			'Function':		FunctionArgumentConstraint,
			'RegExp':			RegExpArgumentConstraint,
			'Literal':		LiteralArgumentConstraint
		};
		
		/**
		 * Constructor
		 * 
		 * @param args
		 */
		public function ArgumentExpectation( args:Object=null )
		{
			if( args == null || args == NO_ARGS )
			{ 
				_expectedArguments = []; 
			}
			else if( args == ANYTHING )
			{ 
				_expectedArguments = null; 
			}
			else 
			{ 
				_expectedArguments = convertArgConstraints( args as Array ); 
			}
		}

		private var _expectedArguments:Array;
		
		/**
		 * Array of expected arguments
		 */
		public function get expectedArguments():Array
		{
			return _expectedArguments;
		}
				
		/**
		 * Convert strings to ArgumentConstraint classes
		 */
		public function convertArgConstraints( args:Array ):Array // of ArgumentConstraint
		{
			return args.map( convertConstraint );
		}
		
		/**
		 * Iterator function for converting argument constraints
		 */
		protected function convertConstraint( constraint:Object, index:int, array:Array ):ArgumentConstraint
		{
			// symbol
			if( [ANYTHING, NUMBER, BOOLEAN, STRING].indexOf( constraint ) > -1 )
			{ 
				return (new (constraintClasses[ constraint ] as Class)( constraint )) as ArgumentConstraint; 
			}
			
			if( constraint is Class )
			{
				// todo: check if constraint is an ArgumentConstraint, if so create and use it instead of ClassArgumentConstraint
				
				return new ClassArgumentConstraint( constraint as Class );
			}
			
			// function
			if( constraint is Function )
			{
				return new FunctionArgumentConstraint( constraint as Function );
			}
			
			// regexp
			if( constraint is RegExp )
			{ 
				return new RegExpArgumentConstraint( constraint ) ;
			}
			
			// literal
			return new LiteralArgumentConstraint( constraint );
		}
		
		// todo: make this method mock_internal, maybe
		/**
		 * Check if args match the expected argument expectations
		 */
		public function argumentsMatch( args:Array ):Boolean
		{
			// anything
			if( _expectedArguments == null )
			{
				return true;
			}
			
			// same arg array or NO_ARGS
			if( _expectedArguments == args )
			{
				return true;
			}
			
			// compare to constraints
			return constraintsMatch( args );
		}
		
		/**
		 * Check if args match the argument constraints 
		 */
		protected function constraintsMatch( args:Array ):Boolean
		{
			if( args == null )
			{
				return false;
			}
			
			if( args.length != _expectedArguments.length )
			{
				return false;
			}
			
			for( var i:int=0; i < _expectedArguments.length; i++)
			{
				if( i >= args.length )
				{ 
					return false; 
				}
				if( !((_expectedArguments[ i ] as ArgumentConstraint).matches( args[ i ] )) )
				{
					return false;
				}
			}
			
			return true;
		}
	}
}