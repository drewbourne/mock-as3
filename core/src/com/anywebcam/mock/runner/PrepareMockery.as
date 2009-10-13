package com.anywebcam.mock.runner
{
	import com.anywebcam.mock.Mockery;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.flexunit.internals.runners.InitializationError;
	import org.flexunit.internals.runners.statements.IAsyncStatement;
	import org.flexunit.token.AsyncTestToken;
	
	public class PrepareMockery implements IAsyncStatement {
		
		public static const TIMEOUT : Number = 5000;
		
		private var mockery : Mockery;
		
		[ArrayElementType("Class")]
		private var classesToPrepare : Array;
		
		public function PrepareMockery(mockery : Mockery, classesToPrepare : Array) {
			this.mockery = mockery;
			this.classesToPrepare = classesToPrepare;
		}
		
		public function evaluate(parentToken : AsyncTestToken) : void {
			if (classesToPrepare.length == 0) {
				parentToken.sendResult(null);
			}
			
			var timer : Timer = new Timer(TIMEOUT);
			timer.addEventListener(TimerEvent.TIMER, function(event : Event = null) : void {
					timer.stop();
					parentToken.sendResult(new InitializationError("Mock preparation timeout of " + TIMEOUT + "exceeded!")); 
				});
			
			mockery.prepare(classesToPrepare);
			
			mockery.addEventListener(Event.COMPLETE, function(event : Event) : void {
					parentToken.sendResult(null);
				});
			
			mockery.addEventListener(ErrorEvent.ERROR, function(event : ErrorEvent) : void{
					parentToken.sendResult(new InitializationError(event.text));
				});
		}
	}
}