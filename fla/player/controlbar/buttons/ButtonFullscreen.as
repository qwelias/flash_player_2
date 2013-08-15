package player.controlbar.buttons {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	
	public class ButtonFullscreen extends Sprite{
		
		private var _interfaceObject:Object = [];
		private var _selected:Boolean = false;

		public function ButtonFullscreen() {
			_initInterface();
			_initListeners();
		}
		
		public function get selected():Boolean{
			return _selected;
		}
		
		public function set selected(val:Boolean):void{
			_selected = val;
		}
		
		private function _initInterface():void{
			_interfaceObject["on"] = new BtnFsOn();
			_interfaceObject["on"].x = 0;
			_interfaceObject["on"].y = 0;
			addChild(_interfaceObject["on"]);
			
			_interfaceObject["off"] = new BtnFsOff();
			_interfaceObject["off"].x = 0;
			_interfaceObject["off"].y = 0;
		}
		
		private function _initListeners():void{
			_interfaceObject["on"].addEventListener(MouseEvent.CLICK, _onBtnClickHandler);
			_interfaceObject["off"].addEventListener(MouseEvent.CLICK, _onBtnClickHandler);
			this.addEventListener(Event.ADDED_TO_STAGE, _onAddedToStageHandler);
		}
		
		private function _onAddedToStageHandler(evt:Event):void{
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, _onFullscreenEventHandler);
			this.removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStageHandler);
		}
		
		private function _onFullscreenEventHandler(evt:FullScreenEvent):void{
			if(stage.displayState == StageDisplayState.NORMAL){
				if(_interfaceObject["off"].parent){
					removeChild(_interfaceObject["off"]);
				}
				_selected = false;
				if(!_interfaceObject["on"].parent){
					addChild(_interfaceObject["on"]);
				}
			}else{
				if(_interfaceObject["on"].parent){
					removeChild(_interfaceObject["on"]);
				}
				_selected = true;
				if(!_interfaceObject["off"].parent){
					addChild(_interfaceObject["off"]);
				}
			}
			//_selected = !_selected;
			
		}
		
		private function _onBtnClickHandler(evt:MouseEvent):void{
			if(stage.displayState == StageDisplayState.FULL_SCREEN){
				stage.displayState = StageDisplayState.NORMAL;
			}else{
				stage.displayState = StageDisplayState.FULL_SCREEN;
			}
			
		}

	}
	
}
