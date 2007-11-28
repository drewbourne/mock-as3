/*
	Copyright (c) 2007, ANYwebcam.com Pty Ltd. All rights reserved.

	The software in this package is published under the terms of the BSD style 
	license, a copy of which has been included with this distribution in the 
	license.txt file.
*/
package com.anywebcam.mock.argumentConstraint
{
	public class FunctionArgumentConstraint implements ArgumentConstraint
	{
		private var _func:Function;

		public function FunctionArgumentConstraint( func:Function )
		{
			_func = func;
		}

		public function matches( value:Object ):Boolean
		{
			if( value is Function )
			{
				return ( (value as Function) === _func );
			}
			
			// todo: should we catch errors here?
			return _func.apply( null, [value] );
		}
	}
}