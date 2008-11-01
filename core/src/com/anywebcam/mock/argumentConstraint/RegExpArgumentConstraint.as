/*
	Copyright (c) 2007, ANYwebcam.com Pty Ltd. All rights reserved.

	The software in this package is published under the terms of the BSD style 
	license, a copy of which has been included with this distribution in the 
	license.txt file.
*/
package com.anywebcam.mock.argumentConstraint
{
	public class RegExpArgumentConstraint implements ArgumentConstraint
	{
		private var _regexp:RegExp;

		public function RegExpArgumentConstraint( regexp:Object )
		{
			_regexp = regexp as RegExp;
		}

		public function matches( value:Object ):Boolean
		{
			if( value is RegExp )
			{
				return ( value == _regexp );
			}
			if( !(value is String) )
			{
				return false;
			}
			return _regexp.test( value as String );
		}
		
		public function toString():String
		{
			// return '[RegExpArg '+ _regexp.toString() +']';
			return _regexp.toString();
		}
	}
}