package player
{
	import fl.transitions.Tween;
	import fl.transitions.easing.Regular;
	
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	
	import org.osmf.utils.OSMFSettings;
	
	import player.Parameters;
	import player.State;
	import player.controlbar.ControlBarA;
	import player.events.HDButtonEvent;
	import player.events.PlayButtonEvent;
	import player.events.SeekTimeEvent;
	import player.events.VolumeChangeEvent;
	import player.mainplayer.MainPlayer;
	import player.utils.SendEventJS;
	
	public class VideoSprite extends Sprite
	{
		public static const VIDEOSPRITE_PLAYER_RUN          :String = "videosprite.run";
		public static const VIDEOSPRITE_PLAYER_TIMECOMPLETE :String = "videosprite.timecomplete";
		private var _width:int;
		private var _height:int;
		
		//private var _interfaceObject:Object = [];
		private var _controlBar       :ControlBarA = null;
		private var _mainPlayer       :MainPlayer = null;
		private var _controlBarTween  :Tween      = null;
		//private var _systemObject:Object = [];
		private var _globalParameters :Parameters = null;
		private var _globalState      :State      = null;
		private var _mainTimer        :Timer      = new Timer(250);
		//private var _played           :Boolean    = false;
		private var _prevTime         :Number     = 0;
		private var _cbTimerDelay     :Number     = 1000;
		private var _cbTimer          :Timer      = new Timer(_cbTimerDelay);
		private var _isFullscreen     :Boolean    = false;
		private var _cbDeltaWidth     :Number     = 50;
		private var _cbDeltaHeight    :Number     = 80;
		private var _cbWidth          :Number     = 0;
		private var _cbNewWidth       :Boolean    = false;

		public function VideoSprite(width:int, height:int, globalParameters:Parameters, globalState:State)
		{
			_width = width;
			_height = height;
			_globalParameters = globalParameters;
			_globalState = globalState;
			_initInterface();
			this.addEventListener(Event.ADDED_TO_STAGE, _onAddedToStageHandler);
		}
		
		private function _initInterface():void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "VideoSprite._initInterface");
			}
			if(_globalParameters._isTrailer)
			{
				_cbDeltaWidth = 10;
				_cbDeltaHeight = 44;
			}
			else
			{
				_cbDeltaWidth = 50;
				_cbDeltaHeight = 80;
			}
			_cbWidth = _width - _cbDeltaWidth;
			_controlBar = new ControlBarA(_globalParameters, _globalState, _cbWidth);
			_controlBar.visible = !_globalParameters._isTrailer;
			
			//_controlBar.width = _cbWidth;
			addChild(_controlBar);
			_controlBar.x = (_width - _controlBar.width)/2;
			_controlBar.y = _height - _cbDeltaHeight;
			
			_controlBarTween = new Tween(_controlBar, "alpha", Regular.easeOut, 1, 0, 20);
			_controlBarTween.stop();
			
			_mainPlayer = new MainPlayer(_width, _height, _globalParameters, _globalState);
			addChildAt(_mainPlayer, 0);
		}
		
		private function _onAddedToStageHandler(evt:Event):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "VideoSprite._onAddedToStageHandler");
			}
			stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, _onThisMouseMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_OUT, _onThisMouseOutHandler);
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, _onFullscreenEventHandler);
			this.removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStageHandler);
			_initListeners();
		}
		
		private function _initListeners():void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "VideoSprite._initListeners");
			}
			//this.addEventListener(Event.ADDED_TO_STAGE, _onAddedToStageHandler);
			//_mainPlayer.addEventListener(MouseEvent.CLICK, _onVideoPlayerClickHandler);
			_mainTimer.addEventListener(TimerEvent.TIMER, _onMainTimerTickHandler);
			_controlBar.addEventListener(MouseEvent.MOUSE_OVER,          _onCbMouseOverHandler);
			_controlBar.addEventListener(MouseEvent.MOUSE_OUT,           _onCbMouseOutHandler);
			_controlBar.addEventListener(PlayButtonEvent.PLAYED_CHANGE,  _onPlayButtonClickHandler);
			_controlBar.addEventListener(SeekTimeEvent.SEEK_TIME_CHANGE, _onSeekTimeChangeHandler);
			_controlBar.addEventListener(VolumeChangeEvent.VOLUME_CHANGE, _onVolumeChangeHandler);
			//_controlBar.addEventListener(LangSubsSelectEvent.SUBS_TOGGLE, _onSubsToggleHandler); move it to MainPlayer
			_controlBar.addEventListener(ControlBarA.CONTROLBAR_MOTION_FINISH,  _onCBMotionFinishHandler);
			
			_mainPlayer.addEventListener(MainPlayer.MEDIAPLAYER_READY,                _onMainPlayerReady);
			_mainPlayer.addEventListener(MainPlayer.MEDIAPLAYER_SPRITE_CLICK,         _onMainPlayerClick);
			_mainPlayer.addEventListener(MainPlayer.MEDIAPLAYER_DURATION_CHANGE,      _onMainPlayerDurationChange);
			_mainPlayer.addEventListener(MainPlayer.MEDIAPLAYER_CURRENT_TIME_CHANGE,  _onMainPlayerCurrentTimeChange);
			_mainPlayer.addEventListener(MainPlayer.MEDIAPLAYER_SEEK_COMPLETE,        _onMainPlayerSeekComplete);
			_mainPlayer.addEventListener(MainPlayer.MEDIAPLAYER_NEW_WIDTH,            _onMainPlayerNewWidth);
			_mainPlayer.addEventListener(MainPlayer.MEDIAPLAYER_DS_SWITCH_BEGIN,      _onMainPlayerDSSwitchBegin);
			_mainPlayer.addEventListener(MainPlayer.MEDIAPLAYER_DS_SWITCH_COMPLETE,   _onMainPlayerDSSwitchComplete);
			_mainPlayer.addEventListener(MainPlayer.MEDIAPLAYER_LANG_SWITCH_COMPLETE, _onMainPlayerLangSwitchComplete);
			_mainPlayer.addEventListener(MainPlayer.MEDIAPLAYER_TIME_COMPLETE,        _onMainPlayerComplete);
		}
		
		public function onVideoPlayerClickHandler():void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "VideoSprite.onVideoPlayerClickHandler");
			}
			_controlBar.outsidePlayerPauseClick(new MouseEvent(MouseEvent.CLICK));
		}
		
		/*public function resizeAll():void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "VideoSprite.resizeAll");
			}
			_width = stage.stageWidth;
			_height = stage.stageHeight;
			_mainPlayer.mp_width = _width;
			_mainPlayer.mp_height = _height;
			_mainPlayer.resizeAll();
			
			_cbWidth = _width - _cbDeltaWidth;
			
			_controlBar.width = _cbWidth;
			_controlBar.x = (_width - _controlBar.width)/2;
			_controlBar.y = _height - _cbDeltaHeight;
		}*/

		private function _onMainPlayerComplete(evt:Event):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "VideoSprite._onMainPlayerComplete");
			}
			if(stage.displayState == StageDisplayState.FULL_SCREEN)
			{
				stage.displayState = StageDisplayState.NORMAL;
			}
			_mainTimer.stop();
			if(!_globalParameters._isTrailer)
			{
				_mainPlayer.visible = false;
			}
			_controlBar.playerComplete();
			dispatchEvent(new Event(VIDEOSPRITE_PLAYER_TIMECOMPLETE, true));
			SendEventJS.sendEvent("complete.playbackevent", _globalParameters.player_type);
		}
		
		private function _onCbMouseOverHandler(evt:MouseEvent):void
		{
			CONFIG::JSDEBUG2 {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "VideoSprite._onCbMouseOverHandler");
			}
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, _onThisMouseMoveHandler);
			_cbTimer.removeEventListener(TimerEvent.TIMER, _onCbTimerHandler);
			_cbTimer.stop();			
		}
		
		private function _onCbMouseOutHandler(evt:MouseEvent):void
		{
			CONFIG::JSDEBUG2 {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "VideoSprite._onCbMouseOutHandler");
			}
			stage.addEventListener(MouseEvent.MOUSE_MOVE, _onThisMouseMoveHandler);
		}
		
		private function _onMainPlayerReady(evt:Object):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "VideoSprite._onMainPlayerReady");
			}
			// Tell _controlBar language mode
			if(_globalState.audioCount > 1)
			{
				if(_globalParameters.subtitles_url != null)
				{
					_controlBar.langMode = 0;
				}
			}
			//_controlBar.outsidePlayerPauseClick(new MouseEvent(MouseEvent.CLICK));
		}
		
		private function _onMainPlayerClick(evt:Object):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "VideoSprite._onMainPlayerClick");
			}
			_controlBar.outsidePlayerPauseClick(new MouseEvent(MouseEvent.CLICK));
		}
		
		private function _onCBMotionFinishHandler(evt:Event):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "VideoSprite._onCBMotionFinishHandler");
			}
			if(!_cbNewWidth)
			{
				if(((_mainPlayer.playerWidth - _cbDeltaWidth - 10) < _cbWidth)
					&& (_mainPlayer.playerWidth > 0))
				{
					_controlBar.firstWidth = true;
					_controlBar.width = _mainPlayer.playerWidth - _cbDeltaWidth - 10;
					_controlBar.x = (_width - _controlBar.width)/2;
					
					_controlBar.visible = true;
				}
				_cbNewWidth = true;
			}
			_controlBar.removeEventListener(ControlBarA.CONTROLBAR_MOTION_FINISH, _onCBMotionFinishHandler);
		}
		
		private function _onMainPlayerNewWidth(evt:Event):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "VideoSprite._onMainPlayerNewWidth");
			}
			if(!_controlBar.motionActive)
			{
				if(((_mainPlayer.playerWidth - _cbDeltaWidth - 10) < _cbWidth)
					&& (_mainPlayer.playerWidth > 0))
				{
					_cbWidth = _mainPlayer.playerWidth - 10;
					
					_controlBar.firstWidth = true;
					_controlBar.width = _mainPlayer.playerWidth - _cbDeltaWidth - 10;
					_controlBar.x = (_width - _controlBar.width)/2;
					
					_controlBar.visible = true;
				}
				_cbNewWidth = true;
			}
			else
			{
				_cbNewWidth = false;
			}
			_mainPlayer.removeEventListener(MainPlayer.MEDIAPLAYER_NEW_WIDTH, _onMainPlayerNewWidth);
		}
		
		private function _onThisMouseOutHandler(evt:MouseEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "VideoSprite._onThisMouseOutHandler");
			}
			stage.addEventListener(MouseEvent.MOUSE_MOVE, _onThisMouseMoveHandler);
			if(_globalState.played || _globalParameters._isTrailer)
			{
				_cbTimerDelay = 1000;
				_cbTimer.delay = _cbTimerDelay;
				_cbTimer.addEventListener(TimerEvent.TIMER, _onCbTimerHandler);
				_cbTimer.reset();
				_cbTimer.start();
			}
		}
		
		private function _onThisMouseMoveHandler(evt:MouseEvent):void
		{
			CONFIG::JSDEBUG2 {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "VideoSprite._onThisMouseMoveHandler");
			}
			if(_globalState.played || _globalParameters._isTrailer)
			{
				_cbTimerDelay = 1000;
				_cbTimer.delay = _cbTimerDelay;
				_cbTimer.addEventListener(TimerEvent.TIMER, _onCbTimerHandler);
				_cbTimer.reset();
				_cbTimer.start();
			}
			_controlBarTween.continueTo(1, 20);
			Mouse.show();
		}
		
		private function _onCbTimerHandler(evt:TimerEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "VideoSprite._onCbTimerHandler");
			}
			_cbTimer.removeEventListener(TimerEvent.TIMER, _onCbTimerHandler);
			_cbTimer.stop();
			_controlBarTween.continueTo(0, 20);
			if(_isFullscreen)
			{
				Mouse.hide();
			}
		}
		
		private function _onKeyDownHandler(evt:KeyboardEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "VideoSprite._onKeyDownHandler");
			}
			//trace("vs key:", evt.keyCode);
		}
		
		private function _onFullscreenEventHandler(evt:FullScreenEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "VideoSprite._onFullscreenEventHandler("+evt.fullScreen+")");
			}
			//stage.focus = _mainPlayer;
			_controlBar.resetMaxBuffer();
			//_isFullscreen = evt.fullScreen;
			_globalState.fullscreen = evt.fullScreen;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, _onThisMouseMoveHandler);
			//_mainPlayer.isFullScreen = evt.fullScreen;
			if(evt.fullScreen)
			{
				//_controlBar.checkOptionsWindow();
				_controlBar.width = stage.stageWidth/1.5;
				_controlBar.x = (stage.stageWidth - _controlBar.width)/2;
				_controlBar.y = stage.stageHeight - 80;
				
				_mainPlayer.mp_width  = stage.stageWidth;
				_mainPlayer.mp_height = stage.stageHeight;
				_mainPlayer.resizeAll();
			}
			else
			{
				//_controlBar.checkOptionsWindow();
				_controlBar.width = _cbWidth;
				_controlBar.x = (_width - _controlBar.width)/2;
				_controlBar.y = _height - _cbDeltaHeight;
				
				_mainPlayer.mp_width = _width;
				_mainPlayer.mp_height = _height;
				_mainPlayer.resizeAll();
			}
			_controlBar.resetMaxBuffer();
			
			// Moved from MainPlayer
			try
			{
				if(evt.fullScreen)
				{
					SendEventJS.sendEvent("fullscreen.screenevent");
				}
				else
				{
					SendEventJS.sendEvent("normalscreen.screenevent");
				}
				OSMFSettings.enableStageVideo = true;
			}
			catch(err:Error){}
		}
		
		private function _onVolumeChangeHandler(evt:VolumeChangeEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "VideoSprite._onVolumeChangeHandler");
			}
			_mainPlayer.volume = evt.volume;
		}
		
		private function _onMainPlayerDSSwitchBegin(evt:Event):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "VideoSprite._onMainPlayerDSSwitchBegin");
			}
			//_controlBar.HDButtonEnabled = false;
		}
		
		private function _onMainPlayerDSSwitchComplete(evt:Event):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "VideoSprite._onMainPlayerDSSwitchComplete");
			}
			//_controlBar.HDButtonEnabled = true;
			_controlBar.resetMaxBuffer();
		}
		
		private function _onMainPlayerLangSwitchComplete(evt:Event):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "VideoSprite._onMainPlayerLangSwitchComplete");
			}
			//_controlBar.HDButtonEnabled = true;
			_controlBar.langMode = _globalState.audioSelected;
		}
		
		private function _onMainPlayerSeekComplete(evt:Event):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "VideoSprite._onMainPlayerSeekComplete");
			}
			//_controlBar.seeking = false;
		}
		
		private function _onSeekTimeChangeHandler(evt:SeekTimeEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "VideoSprite._onSeekTimeChangeHandler");
			}
			if(evt.seekTime <= _mainPlayer.duration)
			{
				_mainPlayer.seek = evt.seekTime;
			}
		}
		
		private function _onPlayButtonClickHandler(evt:PlayButtonEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "VideoSprite._onPlayButtonClickHandler");
			}
			_globalState.played = evt.played;
			_mainPlayer.played = evt.played;
			dispatchEvent(new Event(VIDEOSPRITE_PLAYER_RUN, true));
			_mainPlayer.visible = true;
			//_mainTimer.reset();
			//_mainTimer.start();
		}
		
		private function _onMainPlayerDurationChange(evt:Event):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "VideoSprite._onMainPlayerDurationChange");
			}
			_mainTimer.start();
			//_controlBar.duration = _mainPlayer.duration;
		}
		
		private function _onMainPlayerCurrentTimeChange(evt:Event):void
		{
			CONFIG::JSDEBUG2 {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "VideoSprite._onMainPlayerCurrentTimeChange");
			}
			if(!_controlBar.motionActive
				&& Math.round(_prevTime) != Math.round(_mainPlayer.currentTime)
				&& _mainPlayer.currentTime > 0)
			{
				_controlBar.seeking = false;
				_controlBar.currentTime = _mainPlayer.currentTime - 0.2;
			}
			_prevTime = _mainPlayer.currentTime;
		}
		
		private function _onMainTimerTickHandler(evt:TimerEvent):void
		{
			CONFIG::JSDEBUG2 {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "VideoSprite._onMainTimerTickHandler");
			}
			//trace("focus on:",stage.focus);
			//stage.focus = null;
			stage.focus = this;
			if(!_controlBar.motionActive)
			{
				if(_globalParameters.virtual_duration != null && Number(_globalParameters.virtual_duration) > 0)
				{
					_controlBar.duration = Number(_globalParameters.virtual_duration);
				}
				else
				{
					_controlBar.duration = _mainPlayer.duration;
				}
				_controlBar.bufferLength = _mainPlayer.bufferLength;
			}
		}
	}
}
