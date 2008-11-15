/*
	Copyright (c) 2007, ANYwebcam.com Pty Ltd. All rights reserved.

	The software in this package is published under the terms of the BSD style 
	license, a copy of which has been included with this distribution in the 
	license.txt file.
*/
package com.anywebcam.mock.argumentConstraint
{
	/**
	 * Checks if an argument provided to the mock when a method or property is invoked matches what is expected.
	 * 
	 * @private
	 */
	public interface ArgumentConstraint
	{
		function matches( value:Object ):Boolean;
		function toString():String;
	}
}
