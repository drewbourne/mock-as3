/*
	Copyright (c) 2007, ANYwebcam.com Pty Ltd. All rights reserved.

	The software in this package is published under the terms of the BSD style 
	license, a copy of which has been included with this distribution in the 
	license.txt file.
*/
package com.anywebcam.mock.argumentConstraint
{
	import flash.utils.getQualifiedClassName;

	/**
	 * Matches if an argument is an instance of the given Class or is the given Class itself.
	 * 
	 * @private
	 */
	public class ClassArgumentConstraint implements ArgumentConstraint
	{
		private var _type:Class;

		public function ClassArgumentConstraint( type:Class )
		{
			_type = type;
		}

		public function matches( value:Object ):Boolean
		{
			if( value is Class )
			{
				return ( (value as Class) === _type );
			}
			
			return (value is _type);
		}
		
		public function toString():String
		{
			var className:String = getQualifiedClassName( _type );
			return className.slice( className.lastIndexOf(':') + 1 );
		}
	}
}