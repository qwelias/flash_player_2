package player.utils {
	import flash.external.ExternalInterface;
	
	public class SendEventJS{

		public function SendEventJS():void{
		}
		
		public static function sendEvent(_type:String, _value:String = null):void{
			if(ExternalInterface.available){
				ExternalInterface.call("recieveflashevent",_type, _value);
			}
		}
	}
	
}
