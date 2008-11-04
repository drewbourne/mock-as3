package com.anywebcam.mock.examples
{
	import flash.events.Event;
	
	public class SomeComponent
  {
		public var isEventHandled : Boolean;
		private var myExample:Example;

		public function SomeComponent( e : Example )
		{
			isEventHandled = false;
			myExample = e;
			myExample.addEventListener( "myEvent", handleEvent );
		}

		public function doSomethingWithExample( value:Number ):String
		{
			 myExample.acceptNumber( value );
			 return myExample.giveString();
		}

		public function justCallExample():void
		{
		   myExample.justCall();
		}

		public function callWithRest(...rest):void
		{
			myExample.callWithRest.apply(myExample, rest);
		}

		public function dispatchMyEventWithExample():void
		{
			myExample.dispatchMyEvent();
		}

		private function handleEvent( event : Event ) : void
		{
			isEventHandled = true;
		}
		
  }
}
