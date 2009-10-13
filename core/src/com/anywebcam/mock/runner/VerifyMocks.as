package com.anywebcam.mock.runner
{
	import com.anywebcam.mock.MockExpectationError;
	import com.anywebcam.mock.Mockery;
	
	import org.flexunit.internals.runners.statements.IAsyncStatement;
	import org.flexunit.runners.model.FrameworkMethod;
	import org.flexunit.token.AsyncTestToken;
	
	public class VerifyMocks implements IAsyncStatement {
		private var method : FrameworkMethod;
		
		private var mockery : Mockery;
		
		[ArrayElementType("String")]
		private var propertyNames : Array;
		
		private var target : Object;
		
		public function VerifyMocks(method : FrameworkMethod, mockery : Mockery, propertyNames : Array, target : Object) {
			this.method = method;
			this.mockery = mockery;
			this.propertyNames = propertyNames;
			this.target = target;
		}
		
		public function evaluate(parentToken : AsyncTestToken) : void {
			if (method.getSpecificMetaDataArg("Test", "verify") == "false") {
                //trace("[mock-as3] Skipping mock verification for " + method.name + ".");
				parentToken.sendResult(null);
				return;
			}
			
			//iterate over all properties and call verify
			var mocksToVerify : Array = propertyNames.map(function(property : String, index : int, source : Array) : Object {
					return target[property];
				});
			
			try {
				//trace("[mock-as3] Verifying expectations...", mocksToVerify.join(', '));
				mockery.verify(mocksToVerify);
			}
			catch(mee : MockExpectationError) {
				//if error is thrown catch it and pass it onto the parentToken
				parentToken.sendResult(mee);
				return;
			}
			
			parentToken.sendResult(null);
		}

	}
}