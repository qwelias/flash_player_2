package player.controlbar.buttons {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import player.events.PlayButtonEvent;
	
	public class PlayPauseButton extends Sprite
	{
		//private var _interfaceObject:Object = [];
		private var _btnBigPlay:BtnBigPlay = null;
		private var _btnPause:BtnPause = null;
		private var _btnPlay:BtnPlay = null;
		private var _systemObject:Object = [];
		private var _played:Boolean = false;
		private var _firstLaunch:Boolean = false;

		public function PlayPauseButton(firstLaunch:Boolean)
		{
			_firstLaunch = firstLaunch;
			_initInterface();
			_initListeners();
		}
		
		public function set played(val:Boolean):void
		{
			_played = val;
			if(_played)
			{
				if(_btnBigPlay.parent)
				{
					removeChild(_btnBigPlay);
				}
				else if(_btnPlay)
				{
					removeChild(_btnPlay);
				}
				addChild(_btnPause);
			}
			else
			{
				if(_btnPause.parent)
				{
					removeChild(_btnPause);
				}
				addChild(_btnPlay);
			}
		}
		
		public function get played():Boolean
		{
			return _played;
		}
		
		public function get playWidth():Number
		{
			return _btnPlay.width;
		}
		
		public function get playWidthMax():Number
		{
			return _btnBigPlay.width;
		}
		
		public function outsidePlayClick(evt:MouseEvent):void
		{
			if(_btnBigPlay.parent){
				_onBigPlayClickHandler(evt);
			}else if(_btnPlay.parent){
				_onPlayClickHandler(evt);
			}else if(_btnPause.parent){
				_onPauseClickHandler(evt);
			}
		}
		
		private function _initInterface():void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "PlayPauseButton._initInterface");
			}
			_btnBigPlay = new BtnBigPlay();
			_btnBigPlay.x = 0;
			_btnBigPlay.y = 0;
			
			_btnPlay = new BtnPlay();
			_btnPlay.x = 0;
			_btnPlay.y = 0;
			
			_btnPause = new BtnPause();
			_btnPause.x = 0;
			_btnPause.y = 0;
			
			if(_firstLaunch)
			{
				addChild(_btnBigPlay);
			}
			else
			{
				if(_played)
				{
					addChild(_btnPause);
				}
				else
				{
					addChild(_btnPlay);
				}
			}
			
		}
		
		private function _initListeners():void
		{
			_btnBigPlay.addEventListener(MouseEvent.CLICK, _onBigPlayClickHandler);
			_btnPlay.addEventListener(MouseEvent.CLICK, _onPlayClickHandler);
			_btnPause.addEventListener(MouseEvent.CLICK, _onPauseClickHandler);
		}
		
		private function _onBigPlayClickHandler(evt:MouseEvent):void
		{
			dispatchEvent(new PlayButtonEvent(PlayButtonEvent.PLAYED_CHANGE, true, true));
		}
		
		private function _onPlayClickHandler(evt:MouseEvent):void
		{
			dispatchEvent(new PlayButtonEvent(PlayButtonEvent.PLAYED_CHANGE, true, true));
		}
		
		private function _onPauseClickHandler(evt:MouseEvent):void
		{
			dispatchEvent(new PlayButtonEvent(PlayButtonEvent.PLAYED_CHANGE, false, true));
		}
		
	}
	
}
