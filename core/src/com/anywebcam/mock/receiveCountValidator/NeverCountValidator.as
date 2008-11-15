package com.anywebcam.mock.receiveCountValidator
{
	import com.anywebcam.mock.*;
	
	use namespace mock_internal;

	/**
	 * Receive Count Validator that throws a MockExpectationError on #eligible() because the associated MockExpectation should never be called.
	 *	
	 * @private
	 */
	public class NeverCountValidator implements ReceiveCountValidator
	{
		private var _invoked:Boolean;
		
		public var expectation:MockExpectation;
		
		/**
		 * Constructor
		 */
		public function NeverCountValidator( expectation:MockExpectation )
		{
			this.expectation = expectation;
			_invoked = false;
		}
		
		public function eligible( n:int ):Boolean
		{
			_invoked = true;
			
			// TODO move to a method on MockExpectation
			var message:String = 'Unexpected call: ' + expectation.toString() + '';
			throw new MockExpectationError(message);
		}
		
		public function validate( n:int ):Boolean
		{
			return !_invoked;
		}
		
		public function describe( n:int ):String 
		{
			return 'never';
		}
	}
}