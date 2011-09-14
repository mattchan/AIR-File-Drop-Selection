package events 
{
	import flash.events.Event;

	public class ActionEvent extends Event
	{
		public static const SOMETHING:String = "something";
		
		public var action:String;
		
		public function ActionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new ActionEvent(type, bubbles, cancelable);
		}
	}
}