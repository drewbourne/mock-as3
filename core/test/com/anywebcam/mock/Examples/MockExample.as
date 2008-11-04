package com.anywebcam.mock.examples
{
	import com.anywebcam.mock.Mock;
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class MockExample extends EventDispatcher implements Example
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
			mock.invokeMethod('optional', rest);
		}
		
		public function justCall():void
		{
			mock.justCall();
		}

		public function callWithRest(...rest):void
		{
			// FIXME which is cleaner from a user perspective?
			// mock.callWithRest.apply(mock, rest);*/
			mock.invokeMethod('callWithRest', rest);
		}

		public function dispatchMyEvent():void
		{
			trace('MockExample.dispatchMyEvent');
			mock.dispatchMyEvent();
		}
		
		/*public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			mock.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			mock.removeEventListener(type, listener, useCapture);
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			return mock.dispatchEvent(event);
		}
		
		public function hasEventListener(type:String):Boolean
		{
			return mock.hasEventListener(type);
		}
		
		public function willTrigger(type:String):Boolean
		{
			return mock.willTrigger(type);
		}*/
	}
}
