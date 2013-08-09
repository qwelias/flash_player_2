package player.controlbar.buttons {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import player.events.LangSubsSelectEvent;
	
	public class ButtonEnLang extends Sprite{
		
		private var _interfaceObject:Object = [];
		private var _selected:Boolean = false;

		public function ButtonEnLang():void{
			_initInterface();
			_initListeners();
		}
		
		public function set selected(_val:Boolean):void{
			_selected = _val;
			if(_selected){
				if(_interfaceObject["btn"].parent){
					removeChild(_interfaceObject["btn"]);
				}
				if(!_interfaceObject["marker"].parent){
					addChild(_interfaceObject["marker"]);
				}
			}
		}
		
		public function get selected():Boolean{
			return _selected;
		}
		
		private function _initInterface():void{
			//_interfaceObject["btn"] = new BtnEnLang();
			_interfaceObject["btn"] = new BtnEnLangRuSubs();
			_interfaceObject["btn"].x = 0;
			_interfaceObject["btn"].y = 0;
			addChild(_interfaceObject["btn"]);
			
			_interfaceObject["marker"] = new McEnLangAct();
			_interfaceObject["marker"].x = 0;
			_interfaceObject["marker"].y = 0;
		}
		
		private function _initListeners():void{
			_interfaceObject["btn"].addEventListener(MouseEvent.CLICK, _onBtnClickHandler);
		}
		
		private function _onBtnClickHandler(_evt:MouseEvent):void{
			dispatchEvent(new LangSubsSelectEvent(LangSubsSelectEvent.LANG_SELECT, "eng", true));
		}

	}
	
}
