package com.anywebcam.mock.receiveCountValidator
{
	public interface ReceiveCountValidator
	{
		function eligible( n:int ):Boolean;
		function validate( n:int ):Boolean;
	}
}