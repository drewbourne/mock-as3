package com.anywebcam.mock.receiveCountValidator
{
	/**
	 * Used by MockExpectation to set receive count ranges, and to test if a MockExpectation is eligible for invocation by the Mock.
	 *
	 * @private
	 */
	public interface ReceiveCountValidator
	{
		/**
		 * Checks if the MockExpectation is eligible to invocation
		 *
		 * @param n The current number of times the containing MockExpectation has already been invoked.
		 * @return true if eligible, false if not.
		 */
		function eligible( n:int ):Boolean;
		
		/**
		 * Checks if the MockExpectation has met its receive count expectations.
		 *	
		 * @param n The number of times the MockExpectation was invoked. 
		 * @return true if the validator was expecting that number of invocations, false if not. 
		 */
		function validate( n:int ):Boolean;
		
		/**
		 * Describes the ReceiveCountValidator in a simple way for use in error messages.
		 *
		 * @param n The number of times the MockExpectation was invoked. 
		 * @return a String describing the ReceiveCountValidator, and its expected vs actual results
		 */
		function describe( n:int ):String;
	}
}