/*
	Copyright (c) 2007, ANYwebcam.com Pty Ltd. All rights reserved.

	The software in this package is published under the terms of the BSD style 
	license, a copy of which has been included with this distribution in the 
	license.txt file.
*/
package com.anywebcam.mock.argumentConstraint
{
	public class StringArgumentConstraint implements ArgumentConstraint
	{
		public function StringArgumentConstraint( ignore:Object )
		{
		}

		public function matches( value:Object ):Boolean
		{
			return ( value is String );
		}
		
		public function toString():String
		{
			return '[StringArg]'
		}
	}
}