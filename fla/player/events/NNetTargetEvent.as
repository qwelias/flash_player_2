package player.events
{
    import flash.events.Event;
	import flash.net.NetConnection;
	
	import org.osmf.net.httpstreaming.HTTPNetStream;
    
    public class NNetTargetEvent extends Event
	{
        public static const SET_NET_TARGET:String = "set_net_target";
		private var _httpNetConnection:NetConnection;
		private var _httpNetStream:HTTPNetStream;
		        
        public function NNetTargetEvent(type:String, httpNC:NetConnection, httpNS:HTTPNetStream, bubbles:Boolean = false) 
		{
             super(type, bubbles);
             _httpNetConnection = httpNC;
			 _httpNetStream = httpNS;
        }

		public function get httpNetConnection():NetConnection {
             return _httpNetConnection;
		}
		
		public function get httpNetStream():HTTPNetStream {
             return _httpNetStream;
		}
    }
}