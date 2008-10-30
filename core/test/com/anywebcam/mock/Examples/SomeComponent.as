package com.anywebcam.mock.examples
{
  public class SomeComponent
  {
    private var myExample:Example;

    public function SomeComponent( e : Example )
    {
    	myExample = e;
    }
    
    public function doSomethingWithExample( value:Number ):String
    {
      myExample.acceptNumber( value );
      return myExample.giveString();
    }
  }
}
