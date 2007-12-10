package com.anywebcam.mock.receiveCountValidator
{
	import com.anywebcam.mock.*;

	public class AtLeastCountValidator implements ReceiveCountValidator
	{
		public var expectation:MockExpectation;
		public var limit:int;

		public function AtLeastCountValidator( expectation:MockExpectation, limit:int )
		{
			this.expectation = expectation;
			this.limit = limit;
		}
		
		public function eligible( n:int ):Boolean
		{
			return true;
		}
		
		public function validate( n:int ):Boolean
		{
			return n >= limit;
		}
	}
}