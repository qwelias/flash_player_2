package player.controlbar.buttons
{
	import flash.display.Sprite;
	
	public class ButtonAD extends Sprite
	{
		public static const STATE_BUTTON   = "button";
		public static const STATE_ACTIVE   = "active";
		public static const STATE_DISABLED = "disabled";
		
		//private var _interfaceObject:Object = [];
		protected var _pool  :Object = [];
		protected var _state :String = null;
		
		public function ButtonAD():void
		{
		}
		
		public function set state(_val:String):void
		{
			if(_state != _val)
			{
				removeChild(_pool[_state]);
				addChild(_pool[_val]);
				_state = _val;
			}
		}
		
		public function get state():String
		{
			return _state;
		}
	}
}
