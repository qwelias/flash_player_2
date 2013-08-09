package player.controlbar.buttons
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import player.events.LangSubsSelectEvent;
	import player.controlbar.buttons.ButtonAD;
	
	public class ButtonEnLangRuSubs extends ButtonAD
	{
		//private var _interfaceObject:Object = [];
		//private var _interfaceObject:Object = [];
		//private var _button    :Object = null;
		//private var _active    :Object = null;
		//private var _disabled  :Object = null;
		//private var _state     :String = "btn";
		
		public function ButtonEnLangRuSubs():void
		{
			_initInterface();
			_initListeners();
		}
		
		private function _initInterface():void
		{
			_pool[STATE_BUTTON]   = new BtnEnLangRuSubs();
			_pool[STATE_ACTIVE]   = new McEnLangRuSubsAct();
			_pool[STATE_DISABLED] = new McEnLangRuSubsDis();
			_pool[STATE_BUTTON].x = 0;
			_pool[STATE_BUTTON].y = 0;
			_pool[STATE_ACTIVE].x = 0;
			_pool[STATE_ACTIVE].y = 0;
			_pool[STATE_DISABLED].x = 0;
			_pool[STATE_DISABLED].y = 0;
			
			_state = STATE_BUTTON;
			addChild(_pool[STATE_BUTTON]);
		}
		
		private function _initListeners():void
		{
			_pool[STATE_BUTTON].addEventListener(MouseEvent.CLICK, _onBtnClickHandler);
		}
		
		private function _onBtnClickHandler(_evt:MouseEvent):void
		{
			state = STATE_DISABLED;
			dispatchEvent(new LangSubsSelectEvent(LangSubsSelectEvent.LANG_SELECT, "eng", true));
		}
		
	}
	
}
