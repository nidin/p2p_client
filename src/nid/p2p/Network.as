package nid.p2p
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	
	public class Network extends EventDispatcher
	{
		public var nc:NetConnection;
		
		public function Network()
		{
			
		}
		public function connect():void
		{
			nc = new NetConnection();
			nc.addEventListener(NetStatusEvent.NET_STATUS,onNetStatus);
		}
		
		private function onNetStatus(e:NetStatusEvent):void
		{
			switch(e.info.code)
			{
				case :
				break;
			}
			
		}
		
		public function getUserlist():Vector<Client>
		{
			var list:Vector<Client> = new Vector<Client>();
			
			return list;
		}
	}
}