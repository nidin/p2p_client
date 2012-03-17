package nid.p2p 
{
	/**
	 * ...
	 * @author Nidin P Vinayakan
	 */
	public class CONFIG
	{
		static public const SERVER:String 		= "rtmfp://stratus.adobe.com/";
		static public const DEVKEY:String 		= "d686a308d66dfab49e517141-7fde4acf4f89";
		static public const GROUP_NAME:String 	= "IGI_P2P_GROUP";
		static public var 	USER_NAME:String	= "guest_";
		static public var 	LAN:Boolean 		= false;
		
		static public function get uri():String
		{
			return LAN?"rtmfp:":SERVER + DEVKEY;
		}
	}
}