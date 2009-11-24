package com.anywebcam.mock
{
    import asx.array.compact;    
    import asx.array.flatten;
    
    import org.floxy.IInterceptor;
    import org.floxy.IInvocation;  
    import org.floxy.IProxyRepository;
    import org.floxy.ProxyRepository;

    import com.anywebcam.mock.Mock;

    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.system.ApplicationDomain;
    import flash.utils.Dictionary;

    public class Mockery extends EventDispatcher
    {
        private var mocksByTarget:Dictionary;
        private var proxyRepository:IProxyRepository;
        private var prepareProxyDispatchers:Array;
        private var _nextNameIndex:int;

        public function Mockery()
        {
            proxyRepository = new ProxyRepository();
            prepareProxyDispatchers = [];
            mocksByTarget = new Dictionary();
            
            _nextNameIndex = 0;
        }

        public function prepare(... classes):void
        {
            classes = flatten(classes);
            
            var dispatcher:IEventDispatcher = proxyRepository.prepare(classes, ApplicationDomain.currentDomain);
            dispatcher.addEventListener(Event.COMPLETE, function(event:Event):void
                {
                    dispatchEvent(event)
                });
            prepareProxyDispatchers.push(dispatcher);
        }

        public function nice(classToMock:Class, constructorArgs:Array=null):*
        {
            return create(classToMock, constructorArgs, true);
        }

        public function strict(classToMock:Class, constructorArgs:Array=null):*
        {
            return create(classToMock, constructorArgs, false);
        }
        
        public function create(classToMock:Class, constructorArgs:Array=null, nicely:Boolean=true, name:String=null):*
        {
            var interceptor:MockInterceptor = new MockInterceptor();
            var target:* = proxyRepository.create(classToMock, constructorArgs || [], interceptor);
            var mock:Mock = new Mock(target, nicely, name ? name : "Mockery$" + _nextNameIndex++);
            interceptor.mock = mock;
            mocksByTarget[target] = mock;
            return target;
        }

        public function mock(target:Object):Mock
        {
            return mocksByTarget[target] as Mock;
        }

        public function verify(... targets):void
        {
            targets = compact(flatten(targets));
            
            for each (var target:Object in targets)
            {
                var mock:Mock = mocksByTarget[target] as Mock;
                if (mock)
                {
                    mock.verify();
                }
            }
        }
    }
}