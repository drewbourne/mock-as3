package com.anywebcam.mock.examples
{
	import com.anywebcam.mock.Mock;

	public class MockExample implements Example
	{
		public var mock:Mock;

		public function MockExample( ignoreMissing:Boolean = false )
		{
			mock = new Mock( this, ignoreMissing );
		}

		public function acceptNumber( value:Number ):void
		{
			mock.acceptNumber( value );
		}

		public function giveString():String
		{
			return mock.giveString();
		}

		public function optional( ...rest ):void 
		{
			mock.optional.apply(mock, rest);
		}
	}
}
