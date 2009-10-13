package com.anywebcam.mock.runner
{
	import com.anywebcam.mock.Mockery;
	
	import org.flexunit.internals.runners.statements.IAsyncStatement;
	import org.flexunit.token.AsyncTestToken;

	public class InjectMockery implements IAsyncStatement
	{
		private var mockery : Mockery;
		private var mockeryFieldName : String;
		private var target : Object;
		
		public function InjectMockery(mockery : Mockery, mockeryFieldName : String, target : Object) {
			this.mockery = mockery;
			this.mockeryFieldName = mockeryFieldName;
			this.target = target;
		}

		public function evaluate(parentToken:AsyncTestToken) : void {
			//find mockery and inject
            //trace("[mock-as3] Injecting [" + mockeryFieldName + "]");
			target[mockeryFieldName] = mockery;
			
			parentToken.sendResult(null);
		}
	}
}
