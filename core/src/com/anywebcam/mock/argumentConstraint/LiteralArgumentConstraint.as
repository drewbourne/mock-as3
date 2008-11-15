/*
	Copyright (c) 2007, ANYwebcam.com Pty Ltd. All rights reserved.

	The software in this package is published under the terms of the BSD style 
	license, a copy of which has been included with this distribution in the 
	license.txt file.
*/
package com.anywebcam.mock.argumentConstraint
{
	/**
	 * Matches actual arguments to expected values using strict equality (===).
	 * 
	 * @private
	 */
	public class LiteralArgumentConstraint implements ArgumentConstraint
	{
		private var _value:Object;

		public function LiteralArgumentConstraint( value:Object )
		{
			_value = value;
		}

		public function matches( value:Object ):Boolean
		{
			return ( _value === value );
		}
		
		public function toString():String
		{
			var result:String = "";
			
			if (_value is String) 
			{
				result = '"' + _value + '"';
			} 
			else if (_value && _value.hasOwnProperty('toString') ) 
			{
				result = _value.toString();
			} 
			else 
			{
				result = String(_value);
			}
			
			return result;
		}
	}
}