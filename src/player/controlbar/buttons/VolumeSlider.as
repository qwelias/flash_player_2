package player.controlbar.buttons {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	import player.events.VolumeChangeEvent;
	
	public class VolumeSlider extends Sprite
	{
		public static const VOLUMESLIDER_OVER :String = "volumeslider.over";
		public static const VOLUMESLIDER_OUT  :String = "volumeslider.out";
		private var _interfaceObject:Object = [];
		private var _selected:Boolean = false;
		private var _volume:Number = 1.03;
		private var _mousePressed:Boolean = false;

		public function VolumeSlider() {
			_initInterface();
			_initListeners();
		}
		
		public function get selected():Boolean{
			return _selected;
		}
		
		public function get buttonX():Number{
			return _interfaceObject["volumeOn"].x;
		}
		
		public function get buttonWidth():Number{
			return _interfaceObject["volumeOn"].width;
		}
		
		private function _initInterface():void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "VolumeSlider._initInterface");
			}
			_interfaceObject["volumeBckg"] = new VolumeSliderBackg();
			_interfaceObject["volumeBckg"].x = 12;
			_interfaceObject["volumeBckg"].y = 2;//-5;
			addChild(_interfaceObject["volumeBckg"]);
			
			_interfaceObject["volumeProgress"] = new VolumeSliderProgress();
			_interfaceObject["volumeProgress"].x = 12;
			_interfaceObject["volumeProgress"].y = 2;//-5;
			_interfaceObject["volumeProgress"].mouseEnabled = false;
			addChild(_interfaceObject["volumeProgress"]);
			
			_interfaceObject["maskSprite"] = new Sprite();
			_interfaceObject["maskSprite"].graphics.beginFill(0x456322);
			_interfaceObject["maskSprite"].graphics.drawRect(0,0,_interfaceObject["volumeProgress"].width,_interfaceObject["volumeProgress"].height);
			_interfaceObject["maskSprite"].graphics.endFill();
			_interfaceObject["maskSprite"].scaleX = _volume;
			_interfaceObject["maskSprite"].x = _interfaceObject["volumeProgress"].x;
			_interfaceObject["maskSprite"].y = _interfaceObject["volumeProgress"].y;
			addChild(_interfaceObject["maskSprite"]);
			
			_interfaceObject["volumeOn"] = new BtnSoundOn();
			_interfaceObject["volumeOn"].x = 0;
			_interfaceObject["volumeOn"].y = 0;
			addChild(_interfaceObject["volumeOn"]);
			
			_interfaceObject["volumeOff"] = new BtnSoundOff();
			_interfaceObject["volumeOff"].x = -1.05;
			_interfaceObject["volumeOff"].y = 0;
			
			_interfaceObject["maskSprite"].mouseEnabled = false;
			_interfaceObject["maskSprite"].mouseChildren = false;
			_interfaceObject["volumeProgress"].mask = _interfaceObject["maskSprite"];
		}
		
		private function _controlVolumeLevel(vol:Number):void{
			vol = (Math.floor(vol*100)-2)/100;
			//if(Math.floor(vol*1000) > 257){
			if(vol > 0){
				dispatchEvent(new VolumeChangeEvent(VolumeChangeEvent.VOLUME_CHANGE, vol, true));
				if(_interfaceObject["volumeOff"].parent){
					removeChild(_interfaceObject["volumeOff"]);
					addChild(_interfaceObject["volumeOn"]);
					_selected = false;
				}
			}else{
				dispatchEvent(new VolumeChangeEvent(VolumeChangeEvent.VOLUME_CHANGE, 0, true));
				if(_interfaceObject["volumeOn"].parent){
					removeChild(_interfaceObject["volumeOn"]);
					addChild(_interfaceObject["volumeOff"]);
					_selected = true;
				}
			}
			
		}
		
		private function _initListeners():void{
			_interfaceObject["volumeBckg"].addEventListener(MouseEvent.MOUSE_OUT, _onBackgClickHandler);
			_interfaceObject["volumeBckg"].addEventListener(MouseEvent.MOUSE_DOWN, _onBackgDownHandler);
			_interfaceObject["volumeBckg"].addEventListener(MouseEvent.MOUSE_MOVE, _onBackgMoveHandler);
			_interfaceObject["volumeBckg"].addEventListener(MouseEvent.CLICK, _onBackgClickHandler);
			_interfaceObject["volumeOff"].addEventListener(MouseEvent.MOUSE_OVER, _onBtnOverHandler);
			_interfaceObject["volumeOn"].addEventListener(MouseEvent.MOUSE_OVER, _onBtnOverHandler);
			_interfaceObject["volumeOff"].addEventListener(MouseEvent.MOUSE_OUT, _onBtnOutHandler);
			_interfaceObject["volumeOn"].addEventListener(MouseEvent.MOUSE_OUT, _onBtnOutHandler);
			_interfaceObject["volumeOn"].addEventListener(MouseEvent.CLICK, _onBtnClickHandler);
			_interfaceObject["volumeOff"].addEventListener(MouseEvent.CLICK, _onBtnClickHandler);
		}
		
		private function _onBtnOverHandler(evt:MouseEvent):void{
			dispatchEvent(new Event(VOLUMESLIDER_OVER, true));
		}
		
		private function _onBtnOutHandler(evt:MouseEvent):void{
			dispatchEvent(new Event(VOLUMESLIDER_OUT, true));
		}
		
		private function _onBackgDownHandler(evt:MouseEvent):void{
			_mousePressed = true;
			_interfaceObject["volumeOn"].mouseEnabled = false;
			_interfaceObject["volumeOn"].mouseChildren = false;
			_interfaceObject["volumeOff"].mouseEnabled = false;
			_interfaceObject["volumeOff"].mouseChildren = false;
			_volume = (mouseX - _interfaceObject["volumeBckg"].x)/_interfaceObject["volumeBckg"].width;
			//_interfaceObject["maskSprite"].scaleX = _volume;
			_interfaceObject["maskSprite"].width = _interfaceObject["volumeBckg"].width*_volume;
			_controlVolumeLevel(_volume);
		}
		
		private function _onBackgMoveHandler(evt:MouseEvent):void{
			if(_mousePressed){
				_volume = (mouseX - _interfaceObject["volumeBckg"].x)/_interfaceObject["volumeBckg"].width;
				//_interfaceObject["maskSprite"].scaleX = _volume;
				_interfaceObject["maskSprite"].width = _interfaceObject["volumeBckg"].width*_volume;
				trace("volume:", _volume, _interfaceObject["volumeBckg"].width, _interfaceObject["volumeBckg"].width*_volume);
				_controlVolumeLevel(_volume);
			}
		}
		
		private function _onBackgClickHandler(evt:MouseEvent):void{
			if(_mousePressed){
				_mousePressed = false;
				_interfaceObject["volumeOn"].mouseEnabled = true;
				_interfaceObject["volumeOn"].mouseChildren = true;
				_interfaceObject["volumeOff"].mouseEnabled = true;
				_interfaceObject["volumeOff"].mouseChildren = true;
				_volume = (mouseX - _interfaceObject["volumeBckg"].x)/_interfaceObject["volumeBckg"].width;
				//_interfaceObject["maskSprite"].scaleX = _volume;
				_interfaceObject["maskSprite"].width = _interfaceObject["volumeBckg"].width*_volume;
			}
		}
		
		private function _onBtnClickHandler(evt:MouseEvent):void{
			if(_selected){
				//removeChild(_interfaceObject["volumeOff"]);
				//addChild(_interfaceObject["volumeOn"]);
				
				_interfaceObject["maskSprite"].scaleX = _volume;
				_controlVolumeLevel(_volume);
			}else{
				//removeChild(_interfaceObject["volumeOn"]);
				//addChild(_interfaceObject["volumeOff"]);
				_interfaceObject["maskSprite"].scaleX = 0;
				_controlVolumeLevel(0);
			}
			//_selected = !_selected;
		}

	}
	
}
