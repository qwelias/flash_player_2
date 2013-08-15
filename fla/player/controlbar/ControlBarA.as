package player.controlbar
{
	
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.Regular;
	
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import player.State;
	import player.Parameters;
	import player.controlbar.buttons.ButtonAD;
	import player.controlbar.buttons.ButtonEnLang;
	import player.controlbar.buttons.ButtonEnLangRuSubs;
	import player.controlbar.buttons.ButtonFullscreen;
	import player.controlbar.buttons.ButtonRuLang;
	import player.controlbar.buttons.ButtonRuSubs;
	import player.controlbar.buttons.PlayPauseButton;
	import player.controlbar.buttons.VolumeSlider;
	import player.controlbar.timeline.TimeLine;
	import player.controlbar.timetext.TimeText;
	import player.controlbar.tooltips.ToolTips;
	import player.events.PlayButtonEvent;
	
	public class ControlBarA extends Sprite
	{
		public static const CONTROLBAR_MOTION_FINISH :String = "controlbar.motion.finish";
		private var _width:int;
		private var _height:int = 40;
		
		// Interface objects
		private var i_volumeSlider:VolumeSlider = null;
		private var i_timeLine:TimeLine = null;
		private var i_ButtonRuLang:ButtonRuLang = null;
		private var i_ButtonEnLangRuSubs:ButtonEnLangRuSubs = null;
		//private var i_ButtonEnLang:ButtonEnLang = null;
		//private var i_ButtonRuSubs:ButtonRuSubs = null;
		private var i_mainSprite:Sprite = new Sprite();
		private var i_PlayPauseButton:PlayPauseButton = null;
		private var i_ToolTips:ToolTips = new ToolTips();
		private var i_TimeText:TimeText = null;
		private var _useTimeText:Boolean = true;
		private var i_TimeText_mask:Sprite = new Sprite();
		private var i_TimeText_X:Number = 0;
		private var _timeTextTween:Tween = null;
		private var i_ButtonFullscreen:ButtonFullscreen = null;
		//private var i_ButtonHD:ButtonHD = null;
		private var i_CbFragLeft   :CbFragLeft   = new CbFragLeft();
		private var i_CbFragRight  :CbFragRight  = new CbFragRight();
		private var i_CbFragCenter :CbFragCenter = new CbFragCenter();
		//private var _interfaceObject:Object = [];
		//private var _systemObject:Object = [];
		private var _globalParameters:Parameters = null;
		private var _globalState:State = null;
		private var _playing:Boolean = false;
		
		private var _tweenInterval:Number = 10;
		private var _motionActive:Boolean = false;
		private var _seeking:Boolean = false;
		private var _firstStart:Boolean = true;
		private var _firstLaunch:Boolean = true;
		private var _mousePressed:Boolean = false;
		public var firstWidth:Boolean = true;
		private var _langMode:Number = -1;	// -1 = disabled, 0 = RU, 1 = EN+subs

		public function ControlBarA(globalParameters:Parameters, globalState:State, w:Number)
		{
			_globalParameters = globalParameters;
			_globalState = globalState;
			_width = w;
			_initInterface();
			_initListeners();
			//this.addEventListener(Event.ADDED_TO_STAGE, function():void{stage.addEventListener(KeyboardEvent.KEY_DOWN, _onMediaPlayerSpaceHandler);});
			this.blendMode = BlendMode.LAYER;
			//this.scale9Grid = new Rectangle(1,1,1,1);
		}
		
		public function set langMode(m:Number)
		{
			_langMode = m;
			if(_langMode == -1)
			{
				// Выяснить, нужно ли удалять Event Listeners
				if(i_ButtonRuLang.parent)
					i_mainSprite.removeChild(i_ButtonRuLang);
				if(i_ButtonEnLangRuSubs.parent)
					i_mainSprite.removeChild(i_ButtonEnLangRuSubs);
			}
			else
			{
				if(_langMode == 0 && i_ButtonEnLangRuSubs.state != ButtonAD.STATE_BUTTON)
				{
					i_ButtonRuLang.selected = true;
					i_ButtonEnLangRuSubs.state = ButtonAD.STATE_BUTTON;
				}
				else if(_langMode == 1 && i_ButtonRuLang.selected)
				{
					i_ButtonRuLang.selected = false;
					i_ButtonEnLangRuSubs.state = ButtonAD.STATE_DISABLED;
				}
				if(!i_ButtonRuLang.parent)
				{
					i_mainSprite.addChild(i_ButtonRuLang);
					i_ButtonRuLang.addEventListener(MouseEvent.MOUSE_OVER, _onButtonRusLangOverHandler);
					i_ButtonRuLang.addEventListener(MouseEvent.MOUSE_OUT,  _onElementMouseOutHandler);
					i_ButtonRuLang.addEventListener(MouseEvent.MOUSE_DOWN, _onElementMouseOutHandler);
				/*}
				if(!i_ButtonEnLangRuSubs.parent)
				{*/
					i_mainSprite.addChild(i_ButtonEnLangRuSubs);
					i_ButtonEnLangRuSubs.addEventListener(MouseEvent.MOUSE_OVER, _onButtonEngLangRuSubsOverHandler);
					i_ButtonEnLangRuSubs.addEventListener(MouseEvent.MOUSE_OUT,  _onElementMouseOutHandler);
					i_ButtonEnLangRuSubs.addEventListener(MouseEvent.MOUSE_DOWN, _onElementMouseOutHandler);
					
					reLocate(_width);
				}
			}
		}
		
		public function playerComplete():void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar.playerComplete");
			}
			i_PlayPauseButton.played = false;
			if(!_globalParameters._isTrailer)
			{
				i_timeLine.playerComplete();
			}
		}
		
		public function resetMaxBuffer():void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar.resetMaxBuffer");
			}
			i_timeLine.resetMaxBuffer();
		}
		
		/*public function set paramsObject(val:Object):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar.set paramsObject");
			}
			_systemObject = val;
			_initInterface();
			_initListeners();
		}*/
		
		/*public function set subsButtonSelected(val:Boolean):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar.set subsButtonSelected("+val+")");
			}
			i_ButtonRuSubs.selected = val;
		}*/
		
		public function get motionActive():Boolean
		{
			CONFIG::JSDEBUG2 {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar.get motionActive");
			}
			return _motionActive;
		}
		
		public function set seeking(val:Boolean):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar.set seeking("+val+")");
			}
			_seeking = val;
		}
		
		public function outsidePlayerPauseClick(evt:MouseEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar.outsidePlayerPauseClick");
			}
			i_PlayPauseButton.outsidePlayClick(evt);
		}
		override public function get width():Number
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar.get width");
			}
			return _width;
		}
		override public function set width(w:Number):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar.set width("+w+")");
			}
			if(_width != w)
			{
				reLocate(w);
			}
		}

		public function set currentTime(val:Number)
		{
			CONFIG::JSDEBUG2 {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar.set currentTime("+val+")");
			}
			if(!_seeking && _playing)
			{
				i_timeLine.currentTime = val;
			}
		}
		
		public function set bufferLength(val:Number)
		{
			CONFIG::JSDEBUG2 {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar.set bufferLength("+val+")");
			}
			i_timeLine.bufferLength= val;
		}
		
		public function set duration(val:Number)
		{
			CONFIG::JSDEBUG2 {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar.set duration("+val+")");
			}
			i_timeLine.duration= val;
		}
		
		private function _initInterface():void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar._initInterface");
			}
			_firstLaunch = !(_globalParameters.first_run == "false" || _globalParameters._isTrailer);
			_firstStart = _firstLaunch;
			
			i_ToolTips.y = -24;
			
			i_PlayPauseButton = new PlayPauseButton(_firstLaunch);

			i_timeLine         = new TimeLine(_globalState);
			i_timeLine.y       = 12;
			//i_timeLine.trailer = _systemObject["trailer"];
			
			i_ButtonRuLang      = new ButtonRuLang();
			i_ButtonRuLang.y    = 8;
			i_ButtonRuLang.selected = true;
			
			i_ButtonEnLangRuSubs      = new ButtonEnLangRuSubs();
			i_ButtonEnLangRuSubs.y    = 8;
			/*i_ButtonEnLang      = new ButtonEnLang();
			i_ButtonEnLang.y    = 3;
			
			i_ButtonRuSubs      = new ButtonRuSubs();
			i_ButtonRuSubs.y    = 3;*/
			
			i_volumeSlider       = new VolumeSlider();
			i_volumeSlider.y     = 13;
			
			i_ButtonFullscreen   = new ButtonFullscreen();
			i_ButtonFullscreen.y = 2;
			
			i_mainSprite.addChild(i_CbFragLeft);
			i_mainSprite.addChild(i_CbFragCenter);
			i_mainSprite.addChild(i_CbFragRight);
			i_mainSprite.addChild(i_PlayPauseButton);
			_useTimeText = !(_globalParameters._isTrailer || _globalParameters.free == "true" || _globalParameters.hours_until_stop == -1);
			CONFIG::JSDEBUG {
				if(ExternalInterface.available){
					ExternalInterface.call("console.log", "_globalParameters._isTrailer:       "+_globalParameters._isTrailer);
					ExternalInterface.call("console.log", "_globalParameters.free:             "+_globalParameters.free);
					ExternalInterface.call("console.log", "_globalParameters.hours_until_stop: "+_globalParameters.hours_until_stop);
					ExternalInterface.call("console.log", "   _useTimeText: "+_useTimeText);
				}
			}

			if(_useTimeText)
			{
				i_TimeText = new TimeText();
				i_TimeText.y = -1;
				i_TimeText.startLeft  = _globalParameters.hours_until_start;
				i_TimeText.finishLeft = _globalParameters.hours_until_stop;
				//i_TimeText.firstLaunch = _firstLaunch;
				i_TimeText.firstLaunch = false;	// Update TimeText
			}

			if(!_firstLaunch)
			{
				i_mainSprite.addChild(i_timeLine);
			}
			i_mainSprite.addChild(i_volumeSlider);
			i_mainSprite.addChild(i_ButtonFullscreen);
			addChild(i_mainSprite);
			reLocate(_width);
			i_TimeText.x = i_TimeText_X;
			_timeTextTween = new Tween(i_TimeText, "x", Regular.easeInOut, i_TimeText.x, i_TimeText.x - i_TimeText.width, 10);
			_timeTextTween.addEventListener(TweenEvent.MOTION_START,  _onTweenMotionStartHandler);
			_timeTextTween.addEventListener(TweenEvent.MOTION_CHANGE, _onTweenMotionChangeHandler);
			_timeTextTween.addEventListener(TweenEvent.MOTION_FINISH, _onTweenMotionFinishHandler);
			_timeTextTween.stop();
			i_TimeText_mask.x = 0;
			i_TimeText_mask.y = i_TimeText.y;
			addChild(i_TimeText_mask);
			i_mainSprite.addChild(i_TimeText);
			i_TimeText.mask = i_TimeText_mask;
		}
		
		private function _initListeners():void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar._initListeners");
			}
			this.addEventListener(Event.ADDED_TO_STAGE,  _onAddedToStageHandler);
			this.addEventListener(MouseEvent.MOUSE_DOWN, _onThisMouseDownHandler);
			this.addEventListener(MouseEvent.MOUSE_UP,   _onThisMouseUpHandler);
			
			i_PlayPauseButton.addEventListener(PlayButtonEvent.PLAYED_CHANGE, _onPlayButtonEventHandler);
			i_PlayPauseButton.addEventListener(MouseEvent.MOUSE_OVER, _onPlayButtonOverHandler);
			i_PlayPauseButton.addEventListener(MouseEvent.MOUSE_OUT, _onElementMouseOutHandler);
			i_ButtonFullscreen.addEventListener(MouseEvent.MOUSE_DOWN, _onElementMouseOutHandler);
			
			if(_useTimeText)
			{
				i_TimeText.addEventListener(MouseEvent.MOUSE_OVER, _onTimeTextOverHandler);
				i_TimeText.addEventListener(MouseEvent.MOUSE_OUT, _onElementMouseOutHandler);
			}
			i_ButtonFullscreen.addEventListener(MouseEvent.MOUSE_DOWN, _onElementMouseOutHandler);
			
			i_timeLine.addEventListener(TimeLine.TIMELINE_DURATION_OVER, _onDurationOverHandler);
			i_timeLine.addEventListener(TimeLine.TIMELINE_DURATION_OUT,  _onElementMouseOutHandler);
			i_timeLine.addEventListener(MouseEvent.MOUSE_DOWN, _onElementMouseOutHandler);
			
			/*i_ButtonHD.addEventListener(MouseEvent.MOUSE_OVER, _onButtonHDOverHandler);
			i_ButtonHD.addEventListener(MouseEvent.MOUSE_OUT, _onElementMouseOutHandler);
			i_ButtonHD.addEventListener(MouseEvent.MOUSE_DOWN, _onElementMouseOutHandler);*/
						
			i_ButtonFullscreen.addEventListener(MouseEvent.MOUSE_OVER, _onButtonFSOverHandler);
			i_ButtonFullscreen.addEventListener(MouseEvent.MOUSE_OUT, _onElementMouseOutHandler);
			i_ButtonFullscreen.addEventListener(MouseEvent.MOUSE_DOWN, _onElementMouseOutHandler);
			
			i_volumeSlider.addEventListener(VolumeSlider.VOLUMESLIDER_OVER, _onVolumeOverHandler);
			i_volumeSlider.addEventListener(VolumeSlider.VOLUMESLIDER_OUT,  _onElementMouseOutHandler);
			i_volumeSlider.addEventListener(MouseEvent.MOUSE_DOWN, _onElementMouseOutHandler);
			
			//i_ButtonFullscreen.addEventListener(MouseEvent.MOUSE_DOWN, _onElementMouseOutHandler);
			
			i_timeLine.addEventListener(PlayButtonEvent.PLAYED_CHANGE, _onTimeLinePlayButtonEventHandler);
			i_timeLine.addEventListener(TimeLine.TIMELINE_SEEK_BEGIN,  _onTimeLineSeekBeginHandler);
			i_timeLine.addEventListener(TimeLine.TIMELINE_SEEK_FINISH, _onTimeLineSeekFinishHandler);
		}
		
		private function _onAddedToStageHandler(evt:Event):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar._onAddedToStageHandler");
			}
			stage.addEventListener(MouseEvent.MOUSE_DOWN, _onThisMouseDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, _onThisMouseUpHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDownHandler);
			this.removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStageHandler);
		}
		
		private function _onKeyDownHandler(evt:KeyboardEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar._onKeyDownHandler");
			}
			//trace("cb key:", evt.keyCode);
		}
		
		private function _onThisMouseDownHandler(evt:MouseEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar._onThisMouseDownHandler");
			}
			_mousePressed = true;
		}
		
		private function _onThisMouseUpHandler(evt:MouseEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar._onThisMouseUpHandler");
			}
			_mousePressed = false;
		}
		
		private function _onButtonFSOverHandler(evt:MouseEvent):void
		{
			CONFIG::JSDEBUG2 {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar._onButtonFSOverHandler");
			}
			if(!_mousePressed)
			{
				if(i_ButtonFullscreen.selected)
				{
					i_ToolTips.text = _globalParameters.tooltip_unfullscreen;
				}
				else
				{
					i_ToolTips.text = _globalParameters.tooltip_fullscreen;
				}
				i_ToolTips.x = (i_ButtonFullscreen.x*2 + i_ButtonFullscreen.width - i_ToolTips.width)/2;
				var _deltaX:Number;
				if(this.x + i_ToolTips.x + i_ToolTips.width > stage.stageWidth)
				{
					_deltaX = (this.x + i_ToolTips.x + i_ToolTips.width) -  stage.stageWidth;
					i_ToolTips.x = i_ToolTips.x - _deltaX;
				}
				i_ToolTips.arrowX = i_ButtonFullscreen.x - Math.abs(i_ToolTips.x) + i_ButtonFullscreen.width/2;
				addChild(i_ToolTips);
			}
		}
		
		private function _onVolumeOverHandler(evt:Event):void
		{
			CONFIG::JSDEBUG2 {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar._onVolumeOverHandler");
			}
			if(!_mousePressed)
			{
				if(i_volumeSlider.selected)
				{
					i_ToolTips.text = _globalParameters.tooltip_sound_icon_on;
				}
				else
				{
					i_ToolTips.text = _globalParameters.tooltip_sound_icon_off;
				}
				var _totalX:Number = i_volumeSlider.buttonX + i_volumeSlider.x;
				i_ToolTips.x = (_totalX*2 + i_volumeSlider.buttonWidth - i_ToolTips.width)/2;
				if(this.x + i_ToolTips.x + i_ToolTips.width > stage.stageWidth)
				{
					var _deltaX:Number = (this.x + i_ToolTips.x + i_ToolTips.width) -  stage.stageWidth;
					i_ToolTips.x = i_ToolTips.x - _deltaX;
				}
				i_ToolTips.arrowX = _totalX - Math.abs(i_ToolTips.x) + i_volumeSlider.buttonWidth/2;
				addChild(i_ToolTips);
			}
		}
		
		private function _onButtonRusLangOverHandler(_evt:Event):void
		{
			CONFIG::JSDEBUG2 {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar._onButtonRusLangOverHandler");
			}
			if(!_mousePressed)
			{
				if(!i_ButtonRuLang.selected)
				{
					i_ToolTips.text = _globalParameters.tooltip_rus_lang_button;
					i_ToolTips.x = (i_ButtonRuLang.x*2 + i_ButtonRuLang.width - i_ToolTips.width)/2;
					if(this.x + i_ToolTips.x + i_ToolTips.width > stage.stageWidth)
					{
						var _deltaX:Number = (this.x + i_ToolTips.x + i_ToolTips.width) -  stage.stageWidth;
						i_ToolTips.x = i_ToolTips.x - _deltaX;
					}
					i_ToolTips.arrowX = i_ButtonRuLang.x - Math.abs(i_ToolTips.x) + i_ButtonRuLang.width/2;
					addChild(i_ToolTips);
				}
			}
		}
		
		private function _onButtonEngLangRuSubsOverHandler(_evt:Event):void
		{
			CONFIG::JSDEBUG2 {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar._onButtonEngLangOverHandler");
			}
			if(!_mousePressed)
			{
				if(i_ButtonEnLangRuSubs.state == ButtonAD.STATE_BUTTON)
				{
					i_ToolTips.text = _globalParameters.tooltip_eng_lang_rus_subs_button;
					i_ToolTips.x =
						(i_ButtonEnLangRuSubs.x*2
							+ i_ButtonEnLangRuSubs.width
							- i_ToolTips.width)/2;
					if(this.x + i_ToolTips.x + i_ToolTips.width > stage.stageWidth)
					{
						var _deltaX:Number = (this.x + i_ToolTips.x + i_ToolTips.width) -  stage.stageWidth;
						i_ToolTips.x = i_ToolTips.x - _deltaX;
					}
					i_ToolTips.arrowX =
						i_ButtonEnLangRuSubs.x
						- Math.abs(i_ToolTips.x)
						+ i_ButtonEnLangRuSubs.width/2;
					addChild(i_ToolTips);
				}
			}
		}
		
		private function _onDurationOverHandler(evt:Event):void
		{
			CONFIG::JSDEBUG2 {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar._onDurationOverHandler");
			}
			//i_ToolTips = new ToolTips();
			//i_ToolTips.y = -24;
			if(!_mousePressed)
			{
				if(i_timeLine.reverseDuration)
				{
					i_ToolTips.text = _globalParameters.tooltip_timer_reverse;
				}
				else
				{
					i_ToolTips.text = _globalParameters.tooltip_timer;
				}
				var _totalX:Number = i_timeLine.durationX + i_timeLine.x;
				i_ToolTips.x = (_totalX*2 + i_timeLine.durationWidth - i_ToolTips.width)/2;
				if(this.x + i_ToolTips.x + i_ToolTips.width > stage.stageWidth)
				{
					var _deltaX:Number = (this.x + i_ToolTips.x + i_ToolTips.width) -  stage.stageWidth;
					i_ToolTips.x = i_ToolTips.x - _deltaX;
				}
				i_ToolTips.arrowX = _totalX - Math.abs(i_ToolTips.x) + i_timeLine.durationWidth/2;
				addChild(i_ToolTips);
			}
		}
		
		private function _onTimeTextOverHandler(evt:MouseEvent):void
		{
			CONFIG::JSDEBUG2 {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar._onTimeTextOverHandler");
			}
			if(!(_mousePressed || _firstStart || _globalParameters.tooltip_license_icon == null))
			{
				//i_ToolTips.text = "У Вас осталось "+i_TimeText.finishLeft+" часов, чтобы посмотреть фильм";
				i_ToolTips.text = String(_globalParameters.tooltip_license_icon).replace("N", i_TimeText.finishLeft);
				i_ToolTips.x = (i_TimeText.x*2 + i_TimeText.width - i_ToolTips.width)/2;
				if(i_ToolTips.x + this.x < 0)
				{
					i_ToolTips.x = -this.x;
				}
				i_ToolTips.arrowX = i_TimeText.x + Math.abs(i_ToolTips.x) + i_TimeText.width/2;
				addChild(i_ToolTips);
			}
		}
		
		private function _onPlayButtonOverHandler(evt:MouseEvent):void
		{
			CONFIG::JSDEBUG2 {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar._onPlayButtonOverHandler");
			}
			if(!(_mousePressed || _firstStart))
			{
				var _text = i_PlayPauseButton.played?_globalParameters.tooltip_pause_button:_globalParameters.tooltip_play_button;
				if(_text)
				{
					i_ToolTips.text = _text;
					i_ToolTips.x = (i_PlayPauseButton.x*2 + i_PlayPauseButton.width - i_ToolTips.width)/2;
					if(i_ToolTips.x + this.x < 0)
					{
						i_ToolTips.x = -this.x;
					}
					i_ToolTips.arrowX = i_PlayPauseButton.x + Math.abs(i_ToolTips.x) + i_PlayPauseButton.width/2;
					addChild(i_ToolTips);
				}
			}
		}
		
		private function _onElementMouseOutHandler(evt:Object):void
		{
			CONFIG::JSDEBUG2 {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar._onElementMouseOutHandler");
			}
			if(i_ToolTips.parent)
			{
				removeChild(i_ToolTips);
			}
		}
		
		private function _onTimeLineSeekBeginHandler(evt:Event):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar._onTimeLineSeekBeginHandler");
			}
			_seeking = true;
		}
		
		private function _onTimeLineSeekFinishHandler(evt:Event):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar._onTimeLineSeekFinishHandler");
			}
			//_seeking = false;
		}
		
		private function _onPlayButtonEventHandler(evt:PlayButtonEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar._onPlayButtonEventHandler("+evt.played+")");
			}
			//i_timeLine.resetMaxBuffer();
			i_timeLine.resetPlayerComplete();
			_playing = evt.played;
			_firstStart = false;
			i_PlayPauseButton.played = _playing;
			if(_useTimeText)
			{
				// Play/Pause in movie mode, hide/show TimeText object
				reLocateTimeText();
				/*if(!i_TimeText.parent)
				{
					// Show TimeText
					i_mainSprite.addChild(i_TimeText);
				}*/
				if(!_motionActive)
				{
					_timeTextTween.continueTo(i_TimeText_X, _tweenInterval);
				}
			}
		}
		
		private function reLocateCB():void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar.reLocateCB");
			}
			// Relocates ControlBar's base
			i_CbFragLeft.x       = 0;
			i_CbFragRight.x      = _width - i_CbFragRight.width;
			i_CbFragCenter.x     =          i_CbFragLeft.x     + i_CbFragLeft.width;
			i_CbFragCenter.width = _width - i_CbFragLeft.width - i_CbFragRight.width;
			
			i_PlayPauseButton.x = 3;
			i_PlayPauseButton.y = 2;
			i_ButtonFullscreen.x = i_CbFragRight.x + i_CbFragRight.width - i_ButtonFullscreen.width - 1;
			i_volumeSlider.x     = i_ButtonFullscreen.x - i_volumeSlider.width;
		}
		
		private function reLocateTimeText():void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar.reLocateTimeText");
			}
			// Relocates Timeline/TimeText/RuEnSub/Volume/Fullscreen objects
			if(_useTimeText)
			{
				if(_playing)
					i_TimeText_X = i_PlayPauseButton.x + i_PlayPauseButton.width - i_TimeText.width;
				else
					i_TimeText_X = i_PlayPauseButton.x + i_PlayPauseButton.width;
				// TimeText mask
				i_TimeText_mask.graphics.clear();
				i_TimeText_mask.graphics.beginFill(0x135689);
				i_TimeText_mask.graphics.drawRect(
					i_PlayPauseButton.x + i_PlayPauseButton.playWidth,
					i_TimeText.y,
					i_TimeText.width + i_PlayPauseButton.playWidthMax,
					i_TimeText.height + 20);	//???
				i_TimeText_mask.graphics.endFill();
			}
		}
		
		private function reLocateTimeline():void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar.reLocateTimeline");
			}
			// Relocates Timeline/RuEnSub/Volume/Fullscreen objects
			if(_langMode == -1)
			{
				// Position Timeline only
				if(_useTimeText)
					i_timeLine.width = i_volumeSlider.x - i_TimeText.x - i_TimeText.width;
				else
					i_timeLine.width = i_volumeSlider.x - i_PlayPauseButton.x - i_PlayPauseButton.width;
				i_timeLine.x     = i_volumeSlider.x - i_timeLine.width - 5;
			}
			else
			{
				//
				i_ButtonEnLangRuSubs.x    = i_volumeSlider.x    - i_ButtonEnLangRuSubs.width;
				i_ButtonRuLang.x    = i_ButtonEnLangRuSubs.x    - i_ButtonRuLang.width;
				if(_useTimeText)
					i_timeLine.width = i_volumeSlider.x - i_TimeText.x - i_TimeText.width - i_ButtonRuLang.width - i_ButtonEnLangRuSubs.width;
				else
					i_timeLine.width = i_volumeSlider.x - i_PlayPauseButton.x - i_PlayPauseButton.width - i_ButtonRuLang.width - i_ButtonEnLangRuSubs.width;
				i_timeLine.x = i_ButtonRuLang.x - i_timeLine.width - 5;
			}
		}
		
		private function reLocate(w:Number):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar.reLocate("+w+")");
			}
			_width = w;
			reLocateCB();
			reLocateTimeText();
			reLocateTimeline();
			
			/*i_TimeText_mask.graphics.clear();
			i_TimeText_mask.graphics.beginFill(0x135689);
			i_TimeText_mask.graphics.drawRect(
				i_PlayPauseButton.x + i_PlayPauseButton.playWidth,
				i_TimeText.y,
				i_TimeText.width + ( i_PlayPauseButton.width - i_PlayPauseButton.playWidth),
				i_TimeText.height + 20);
			i_TimeText_mask.graphics.endFill();
			addChild(i_TimeText_mask);
			i_TimeText.mask = i_TimeText_mask;*/
		}
		
		private function _onTimeLinePlayButtonEventHandler(evt:PlayButtonEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar._onTimeLinePlayButtonEventHandler");
			}
			//i_timeLine.played = _playing;
		}
		
		private function _onTweenMotionStartHandler(evt:TweenEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar._onTweenMotionStartHandler");
			}
			_motionActive = true;
			i_timeLine.activeTween = true;
		}
		
		private function _onTweenMotionChangeHandler(evt:TweenEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar._onTweenMotionChangeHandler("+TweenEvent+")");
			}
			//i_timeLine.resizeAll = i_ButtonHD.x - i_TimeText.x - i_TimeText.width;
			if(!_firstLaunch)
			{
				if(_langMode == -1)
				{
					i_timeLine.resizeAll = i_volumeSlider.x - 10 - i_TimeText.x - i_TimeText.width;
				}
				else
				{
					i_timeLine.resizeAll = i_volumeSlider.x - 10 - i_TimeText.x - i_TimeText.width - i_ButtonRuLang.width - i_ButtonEnLangRuSubs.width;
				}
				i_timeLine.x         = i_TimeText.x + i_TimeText.width + 5;
			}
		}
		
		private function _onTweenMotionFinishHandler(evt:TweenEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ControlBar._onTweenMotionFinishHandler");
			}
			_motionActive = false;
			i_timeLine.activeTween = false;
			if(_firstLaunch)
			{
				_tweenInterval = 10;
				_firstLaunch = false;
				//i_TimeText.firstLaunch = false;
				//i_TimeText.x = -23;
				reLocateTimeline();
				addChild(i_timeLine);
			}
			/*if(i_TimeText_X < (i_PlayPauseButton.x + i_PlayPauseButton.width) && i_TimeText.parent)
			{
				if(ExternalInterface.available) ExternalInterface.call("console.log", "Removing i_TimeText, pos="+i_TimeText_X);
				//i_mainSprite.removeChild(i_TimeText);
			}*/
			dispatchEvent(new Event(CONTROLBAR_MOTION_FINISH, true));
			//i_TimeText.x = (i_PlayPauseButton.x + i_PlayPauseButton.width) - i_TimeText.width - 3
		}
	}
}
