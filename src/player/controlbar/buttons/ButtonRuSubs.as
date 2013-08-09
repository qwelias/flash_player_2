package player.controlbar.buttons {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import player.events.LangSubsSelectEvent;
	
	public class ButtonRuSubs extends Sprite{
		
		private var _interfaceObject:Object = [];
		private var _selected:Boolean = false;

		public function ButtonRuSubs():void{
			_initInterface();
			_initListeners();
		}
		
		public function set selected(_val:Boolean):void{
			_selected = _val;
			trace("subs button:", _val);
			if(_selected){
				if(_interfaceObject["btn"].parent){
					removeChild(_interfaceObject["btn"]);
				}
				if(!_interfaceObject["marker"].parent){
					addChild(_interfaceObject["marker"]);
				}
			}else{
				if(!_interfaceObject["btn"].parent){
					addChild(_interfaceObject["btn"]);
				}
				if(_interfaceObject["marker"].parent){
					removeChild(_interfaceObject["marker"]);
				}
			}
		}
		
		public function get selected():Boolean{
			return _selected;
		}
		
		private function _initInterface():void{
			_interfaceObject["btn"] = new BtnRuSubs();
			_interfaceObject["btn"].x = 0;
			_interfaceObject["btn"].y = 0;
			addChild(_interfaceObject["btn"]);
			
			_interfaceObject["marker"] = new McRuSubsAct();
			_interfaceObject["marker"].x = 0;
			_interfaceObject["marker"].y = 0;
			_interfaceObject["marker"].buttonMode = true;
		}
		
		private function _initListeners():void{
			_interfaceObject["btn"].addEventListener(MouseEvent.CLICK, _onBtnClickHandler);
			_interfaceObject["marker"].addEventListener(MouseEvent.CLICK, _onMarkerClickHandler);
		}
		
		private function _onBtnClickHandler(_evt:MouseEvent):void{
			dispatchEvent(new LangSubsSelectEvent(LangSubsSelectEvent.SUBS_TOGGLE, "on", true));
		}
		
		private function _onMarkerClickHandler(_evt:MouseEvent):void{
			dispatchEvent(new LangSubsSelectEvent(LangSubsSelectEvent.SUBS_TOGGLE, "off", true));
		}

	}
	
}
