/*
	Copyright (c) 2007, ANYwebcam.com Pty Ltd. All rights reserved.

	The software in this package is published under the terms of the BSD style 
	license, a copy of which has been included with this distribution in the 
	license.txt file.
*/
package com.anywebcam.mock
{
	/**
	 * Errors relating to MockExpecations throw errors of this type. 
	 */
	public class MockExpectationError extends Error
	{
		/**
		 * Constructor
		 * 
		 * @param message The error message
		 */
		public function MockExpectationError( message:String )
		{
			super( message );
		}
	}
}