package nid.p2p
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import flash.net.NetStream;
	import nid.p2p.events.NetEvent;
	
	public class Network extends EventDispatcher
	{
		private var group_specifier:GroupSpecifier;
		private var group_spec:String;
		private var netGroup:NetGroup;
		private var stream_client:NetStreamClient;
		
		public var nc:NetConnection;
		public var near_id:String;
		public var estimatedP2PMembers:int;
		public var out_stream:NetStream;
		public var in_stream:NetStream;
		
		private static var instance:Network;
		
		public var neighbors:Vector.<Client>;
		
		public static function getInstance():Network
		{
			if (instance == null) instance = new Network();
			return instance;
		}
		public function Network()
		{
			stream_client = new NetStreamClient();
			neighbors = new Vector.<Client>();
		}
		public function connect():void
		{
			if (nc != null && nc.connected) return;
			nc = new NetConnection();
			nc.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			nc.connect(CONFIG.uri);
		}
		
		private function onNetStatus(e:NetStatusEvent):void
		{
			trace('code:'+e.info.code);
			switch(e.info.code)
			{
				case NetConnectionStatus.SUCCESS:
					dispatchEvent(new NetEvent(NetEvent.CONNECT));
					near_id = e.target.nearID;
					createGroup();
				break;
				
				case NetConnectionStatus.FAILED:
				break;
			}
			
		}
		
		private function createGroup():void 
		{
			group_specifier = new GroupSpecifier( CONFIG.GROUP_NAME );
			
			group_specifier.multicastEnabled = true;
			group_specifier.objectReplicationEnabled = true;
			group_specifier.postingEnabled = true;
			group_specifier.routingEnabled = true;
			group_specifier.ipMulticastMemberUpdatesEnabled = true;
			group_specifier.addIPMulticastAddress("225.225.0.1:30303");
			
			group_spec = group_specifier.groupspecWithoutAuthorizations();
			
			joinGroup();
		}
		
		private function joinGroup():void 
		{
			netGroup = new NetGroup( nc, group_spec );
			netGroup.addEventListener( NetStatusEvent.NET_STATUS, onNetGroupStatus );	
		}
		
		private function onNetGroupStatus(e:NetStatusEvent):void 
		{
			switch(e.info.code)
			{
				case "NetGroup.LocalCoverage.Notify":
					
					for each(var st:String in e.info) {
						trace(st);
					}
					
				break;
				
				case "NetGroup.Posting.Notify":
				{
					trace('post:' + e.info.message.type);
					if (e.info.message.type == "info")
					{
						var client:Client  = getClient(e.info.message.id);
						client.name = e.info.message.name;
						trace('client:'+client.name);
						dispatchEvent(new NetEvent(NetEvent.UPDATE_CLIENT));
					}
					else
					{
						dispatchEvent(new NetEvent(NetEvent.POST, e.info.message));
					}
					break;
				}																		
				case "NetGroup.Neighbor.Connect":
				{
					if( e.info.neighbor != netGroup.convertPeerIDToGroupAddress( near_id ) )
					{
						trace( 'peerID ' + e.info.peerID + ' has connected' );
						estimatedP2PMembers = netGroup.estimatedMemberCount;
						var client:Client = new Client(e.info.peerID);
						client.index = neighbors.length;
						neighbors.push(client);
						trace('neighbors:' + neighbors.length)
						netGroup.post( { name:CONFIG.USER_NAME, type:"info", id:near_id } );
						dispatchEvent(new NetEvent(NetEvent.NEIGHBOR_CONNECT, { neighbor:e.info.neighbor}));
					}
					break;
				}
				case "NetGroup.Neighbor.Disconnect":
				{
					trace( 'peerID ' + e.info.peerID + ' has disconnected' );	
					estimatedP2PMembers = netGroup.estimatedMemberCount;
					var index:int = getClient(e.info.peerID).index;
					trace('removeEventListener index :' + index);
					neighbors.splice(index, 1);
					trace('neighbors:'+neighbors.length)
					dispatchEvent(new NetEvent(NetEvent.NEIGHBOR_DISCONNECT, { neighbor:e.info.neighbor}));
					break;
				}
				case "NetGroup.SendTo.Notify": // e.info.message, e.info.from, e.info.fromLocal
				case "NetGroup.MulticastStream.PublishNotify": // e.info.name
				case "NetGroup.MulticastStream.UnpublishNotify": // e.info.name
				case "NetGroup.Replication.Fetch.SendNotify": // e.info.index
				case "NetGroup.Replication.Fetch.Failed": // e.info.index
				case "NetGroup.Replication.Fetch.Result": // e.info.index, e.info.object
				case "NetGroup.Replication.Request": // e.info.index, e.info.requestID	
				default:
				{
					break;
				}
			}
			
		}
		
		private function getClient(id:String):Client
		{
			for (var i :int = 0; i < neighbors.length; i++)
			{
				if (neighbors[i].id == id)
				{
					trace('found');
					return neighbors[i];
				}
			}
			return null;
		}
		protected function startOutgoingStream():void
		{			
			out_stream 					= new NetStream( nc, group_spec );
			out_stream.bufferTime 		= 0;
			out_stream.backBufferTime 	= 0;
			out_stream.client 			= stream_client;
			out_stream.addEventListener( NetStatusEvent.NET_STATUS, onNetStatus );
			
		}
		
		protected function startIncomingStream():void
		{					
			in_stream 					= new NetStream( nc, group_spec );
			in_stream.bufferTime 		= 0;
			in_stream.backBufferTime 	= 0;
			in_stream.client 			= stream_client;
		}
	}
}