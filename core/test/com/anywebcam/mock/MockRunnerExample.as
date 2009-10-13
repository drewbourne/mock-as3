package com.anywebcam.mock
{
    import com.anywebcam.mock.examples.Example;
    
    import org.hamcrest.assertThat;
    import org.hamcrest.core.*;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.notNullValue;    
    import org.hamcrest.object.nullValue;    
    import org.hamcrest.object.instanceOf;    
    
    [RunWith("com.anywebcam.mock.runner.MockRunner")]
    public class MockRunnerExample
    {
        public var mockery:Mockery;
        
        [Mock(type="nice")]
        public var nicelyImplicitlyInjected:Example;
        
        [Mock(type="strict")]
        public var strictlyImplicitlyInjected:Example;

        [Mock(type="nice",inject="true")]
        public var nicelyExplicitlyInjected:Example;
        //
        [Mock(type="strict",inject="true")]
        public var strictlyExplicitlyInjected:Example;
        //
        [Mock(type="nice",inject="false")]
        public var nicelyExplicitlyNotInjected:Example;
        
        [Mock(type="strict",inject="false")]
        public var strictlyExplicitlyNotInjected:Example;
        
        [Before]
        public function mockeryShouldBeAvailableInBefore():void 
        {
            assertThat(mockery, notNullValue());
        }
        
        [Before]
        public function mocksShouldBeAvailableInBefore():void 
        {
            assertThat("nicely implicitly injected", nicelyImplicitlyInjected, notNullValue());
            assertThat("strictly implicitly injected", strictlyImplicitlyInjected, notNullValue());            
            assertThat("nicely explicity injected", nicelyExplicitlyInjected, notNullValue());
            assertThat("strictly explicity injected", strictlyExplicitlyInjected, notNullValue());
            assertThat("nicely explicitly not injected", nicelyExplicitlyNotInjected, nullValue());
            assertThat("strictly explicitly not injected", strictlyExplicitlyNotInjected, nullValue());
        }
        
        [Test]
        public function mockeryShouldBeAvailableInTests():void 
        {
            assertThat(mockery, notNullValue());
            assertThat(mockery.mock(strictlyImplicitlyInjected), instanceOf(Mock));
        }
                
        [Test]
        public function mocksShouldBeAvailableInTests():void 
        {
            assertThat("nicely implicitly injected", nicelyImplicitlyInjected, notNullValue());
            assertThat("strictly implicitly injected", strictlyImplicitlyInjected, notNullValue());            
            assertThat("nicely explicity injected", nicelyExplicitlyInjected, notNullValue());
            assertThat("strictly explicity injected", strictlyExplicitlyInjected, notNullValue());
            
            assertThat("nicely explicitly not injected", nicelyExplicitlyNotInjected, nullValue());
            assertThat("strictly explicitly not injected", strictlyExplicitlyNotInjected, nullValue());            
        }
        
        // Cannot use expected error for Mock Errors as the expects metadata is processed before the automatic mock verification
        // [Test(expected="com.anywebcam.mock.MockExpectationError")]
        [Test]
        public function mocksShouldBeAutomaticallyVerified():void 
        {
            var expected:String = "how long is a piece of string";
            
            mockery.mock(strictlyImplicitlyInjected).method("giveString").withNoArgs.returns(expected).once;
            
            assertThat(strictlyImplicitlyInjected.giveString(), equalTo(expected));
        }       
                
        [Test(verify="false")]
        public function mocksShouldNotBeAutomaticallyVerified():void 
        {
            var expected:String = "how long is a piece of string";
            
            mockery.mock(strictlyImplicitlyInjected).method("giveString").withNoArgs.returns(expected).once;
        }               
    }
}
