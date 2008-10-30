/*
	Copyright (c) 2007, ANYwebcam.com Pty Ltd. All rights reserved.

	The software in this package is published under the terms of the BSD style 
	license, a copy of which has been included with this distribution in the 
	license.txt file.
*/
package com.anywebcam.mock
{
	import flexunit.framework.TestSuite;

	public class MockFrameworkTest
	{
		public static function suite():TestSuite
		{
			var ts:TestSuite = new TestSuite();
			
			ts.addTest( ArgumentExpectationTest.suite() );
			ts.addTest( MockExpectationTest.suite() );
			ts.addTest( MockTest.suite() );
			ts.addTest( Examples.suite() );
			
			return ts;
		}
	}
}