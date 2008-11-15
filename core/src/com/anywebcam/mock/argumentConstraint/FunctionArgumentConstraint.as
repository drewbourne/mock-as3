/*
	Copyright (c) 2007, ANYwebcam.com Pty Ltd. All rights reserved.

	The software in this package is published under the terms of the BSD style 
	license, a copy of which has been included with this distribution in the 
	license.txt file.
*/
package com.anywebcam.mock.argumentConstraint
{
	/**
	 * Matches if an argument is the given Function, or invokes the given function and uses the return value.
	 * 
	 * @private
	 */
	public class FunctionArgumentConstraint implements ArgumentConstraint
	{
		private var _func:Function;
		
		public function FunctionArgumentConstraint( func:Function )
		{
			_func = func;
		}

		public function matches( value:Object ):Boolean
		{
			//trace( this, _func, value, value is Function );

			if( value is Function )
			{
				if( _func != null )
					return ( (value as Function) === _func );
					
				return true;
			}
			
			return _func.apply( null, [value] );
		}
		
		public function toString():String
		{
			// return '[FunctionArg '+ _func +']';
			// return String(_func);
			return 'Function';
		}
	}
}