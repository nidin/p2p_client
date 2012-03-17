package nid.p2p.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Nidin P Vinayakan
	 */
	public class NetEvent extends Event 
	{
		static public const POST:String = "post";
		static public const UPDATE_CLIENT:String = "update_client";
		static public const CONNECT:String = "connect";
		static public const NEIGHBOR_CONNECT:String = "neighborConnect";
		static public const NEIGHBOR_DISCONNECT:String = "neighborDisconnect";
		
		public var data:Object;
		
		public function NetEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) 
		{ 
			this.data = data;
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new NetEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("NetEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}