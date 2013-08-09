package player.mainplayer
{
	import flash.display.DisplayObject;
	import flash.display.LineScaleMode;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import org.osmf.display.ScaleMode;
	import org.osmf.elements.F4MElement;
	import org.osmf.elements.F4MLoader;
	import org.osmf.elements.VideoElement;
	import org.osmf.events.AlternativeAudioEvent;
	import org.osmf.events.DRMEvent;
	import org.osmf.events.DisplayObjectEvent;
	import org.osmf.events.DynamicStreamEvent;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.SeekEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.events.TimelineMetadataEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.media.URLResource;
	import org.osmf.net.NetLoader;
	import org.osmf.net.StreamingItem;
	import org.osmf.traits.DRMState;
	import org.osmf.utils.OSMFSettings;
	
	import player.Parameters;
	import player.State;
	import player.events.LangSubsSelectEvent;
	import player.osmfexpansion.SmoothedMediaFactory;
	import player.subtitles.Subtitles;
	import player.utils.SendEventJS;
	
	public class MainPlayer extends Sprite
	{
		public static const MEDIAPLAYER_READY                :String = "MainPlayer.MediaPlayerState.READY";
		public static const MEDIAPLAYER_TIME_COMPLETE        :String = "player.time.complete";
		public static const MEDIAPLAYER_SPRITE_CLICK         :String = "player.sprite.click";
		public static const MEDIAPLAYER_NEW_WIDTH            :String = "player.new.width";
		public static const MEDIAPLAYER_DS_SWITCH_BEGIN      :String = "player.ds.switch.begin";
		public static const MEDIAPLAYER_DS_SWITCH_COMPLETE   :String = "player.ds.switch.complete";
		public static const MEDIAPLAYER_LANG_SWITCH_BEGIN    :String = "player.lang.switch.begin";
		public static const MEDIAPLAYER_LANG_SWITCH_COMPLETE :String = "player.lang.switch.complete";
		public static const MEDIAPLAYER_SEEK_COMPLETE        :String = "player.seek.complete";
		public static const MEDIAPLAYER_CURRENT_TIME_CHANGE  :String = "player.currentTime.change";
		public static const MEDIAPLAYER_DURATION_CHANGE      :String = "player.duration.change";

		private var _mp_width:Number;
		private var _mp_height:Number;
		private var _playerWidth:Number = 0;
		private var _playerHeight:Number = 0;
		
		private var _mediaPlayerSprite:MediaPlayerSprite;
		private var _urlResource:URLResource;
		private var _media:MediaElement;
		private var _factory:SmoothedMediaFactory;
		private var _played:Boolean = false;
		private var _firstChange:Boolean = true;
		private var _firstRun:Boolean = true;
		private var _preloader:Preloader;
		//private var _systemObject:Object = [];
		private var _globalParameters:Parameters = null;
		private var _globalState:State = null;
		private var _trailer:Boolean;
		private var _itsTrailer:Boolean;
		private var _eventSprite:Sprite;
		private var _bufferTimer:Timer = new Timer(2000);
		private var _sendJsTimer:Timer = new Timer(1000);
		private var _sendJsCQual:Timer = new Timer(10000);
		private var _autoPlay:Boolean = false;
		//private var _isFullscreen:Boolean = false;
		private var _bufferTime:Number = 60;
		private var _minBufferTime:Number = 0.1;
		private var _firstSwitch:Boolean = true;
		private var _completed:Boolean = false;
		private var _emptyBufferTimer:Timer = new Timer(2000);
		private var _normalBuffering:Boolean = true;
		private var _authenticated:Boolean = false;
		
		// Picture dim
		private var  mediaWidth:uint;
		private var mediaHeight:uint;
		// Subtitles
		private var _subtitles :Subtitles = null;
		private var subRight   :uint = 0;
		private var subLeft    :uint = 0;
		private var subTop     :uint = 0;
		private var subBottom  :uint = 0;
		/*private var   timelineMetaData:TimelineMetadata;
		private var       subTitleText:TextField = null;
		private var subTitleTextFormat:TextFormat;
		private var            subSize:Number;
		private var         subOutline:GlowFilter;
		private var            subBlur:BlurFilter;
		private var          subShadow:DropShadowFilter;*/

		public function MainPlayer(w:int, h:int, globalParameters:Parameters, globalState:State)
		{
			_mp_width = w;
			_mp_height = h;
			_globalParameters = globalParameters;
			_globalState = globalState;
			_trailer = _globalParameters._isTrailer;
			_itsTrailer = _trailer;
			if(_globalParameters.auto_play != null)
			{
				_autoPlay = (_globalParameters.auto_play == "true");//? true:false;
			}
			if(_trailer || _autoPlay)
			{
				_initInterface();
				_initListeners();
			}
			else
			{
				_firstChange = false;
			}
			this.addEventListener(Event.ADDED_TO_STAGE, _onAddedToStageHandler);
		}
		
		private function _onAddedToStageHandler(evt:Event):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer._onAddedToStageHandler");
			}
			//stage.addEventListener(FullScreenEvent.FULL_SCREEN, _onFullscreenHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, _onMediaPlayerSpaceHandler);
			removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStageHandler);
		}
		
		private function _initInterface():void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer._initInterface");
			}
			_urlResource = new URLResource(_globalParameters.content_url);
			_factory = new SmoothedMediaFactory();
			
			if(String(_globalParameters.content_url).search("f4m") != -1)
			{
				if(ExternalInterface.available) ExternalInterface.call(
					"console.log", "Token: " + "type=online," + _globalParameters.token
					+ ",os=" + escape(Capabilities.os)
					+ ",flashversion=" + escape(Capabilities.version)
					+ ",browser=" + (ExternalInterface.available ? escape(ExternalInterface.call("window.navigator.userAgent.toString")):"unknown"));
				_factory.customToken = "type=online," + _globalParameters.token + ",os=" + escape(Capabilities.os) +",flashversion=" + escape(Capabilities.version) + ",browser=" + (ExternalInterface.available ? escape(ExternalInterface.call("window.navigator.userAgent.toString")):"unknown");
				_media = new F4MElement(_urlResource, new F4MLoader(_factory));
			}
			else
			{
				_media = _factory.createMediaElement(_urlResource);
				//_media.smoothing = true;
			}
			if(ExternalInterface.available) ExternalInterface.call("console.log", "Load media: "+_urlResource.url);
			//_factory.customToken = _globalParameters.token;
			//_media = new F4MElement(_urlResource, new F4MLoader(_factory));
			_mediaPlayerSprite = new MediaPlayerSprite();
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", " _mediaPlayerSprite.scaleMode: "+_mediaPlayerSprite.scaleMode);
			}
			//_mediaPlayerSprite.scaleMode = ScaleMode.ZOOM;
			_mediaPlayerSprite.mediaPlayer.autoDynamicStreamSwitch = true;
			_mediaPlayerSprite.mediaPlayer.autoPlay = true;
			_mediaPlayerSprite.mediaPlayer.volume = 1;
			_mediaPlayerSprite.mediaPlayer.media = _media;
			_mediaPlayerSprite.mediaPlayer.autoRewind = false;
			addChild(_mediaPlayerSprite);
			if(ExternalInterface.available) ExternalInterface.call("console.log", "Media duration: "+_mediaPlayerSprite.mediaPlayer.duration);
			
			mediaWidth  = _mp_width;
			mediaHeight = _mp_height;
			
			//_createSubTitle();
			// setup player/event
			_mediaPlayerSprite.mediaPlayer.currentTimeUpdateInterval = 200;
			try
			{
				_subtitles = new Subtitles(_mediaPlayerSprite.mediaPlayer.media);
				_subtitles.addEventListener("subs.loaded.parsed", onSubLoadComplete);
				_subtitles.loadSRT("subtitles", _globalParameters.subtitles_url);
				//_subtitles.loadSRT("forced_subtitles", _globalParameters.forced_subtitles_url);
				//_subtitles.select("subtitles");
			}
			catch(err:Error)
			{
				if(ExternalInterface.available) ExternalInterface.call("console.log", "error: " + err.toString());
			}
			/*timelineMetaData = new TimelineMetadata(_mediaPlayerSprite.mediaPlayer.media);
			timelineMetaData.addEventListener(TimelineMetadataEvent.MARKER_DURATION_REACHED, onCueLeave, false, 0, true);
			timelineMetaData.addEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED, onCueEnter, false, 0, true);
			loadSRT(_globalParameters.subtitles_url);*/
			//loadSRT(_urlResource.url);
			if(ExternalInterface.available) ExternalInterface.call("console.log", "Factory: "+_factory.toString());
			
			_preloader = new Preloader();
			_preloader.smoothing = true;
			_preloader.x = _mp_width/2;
			_preloader.y = _mp_height/2;
			_preloader.visible = false;
			addChild(_preloader);
			
			_eventSprite = new Sprite();
			_eventSprite.alpha = 0;
			addChild(_eventSprite);
			
			OSMFSettings.enableStageVideo = true;
		}
		
		private function onSubLoadComplete(e:Event):void
		{
			if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer.onSubLoadComplete");
			_subtitles.removeEventListener("subs.loaded.parsed", onSubLoadComplete);
			_subtitles.select("subtitles");
		}
		
		private function _initListeners():void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer._initListeners");
			}
			_bufferTimer.addEventListener(TimerEvent.TIMER, _onBufferTimerHandler);
			_emptyBufferTimer.addEventListener(TimerEvent.TIMER, _onEmptyBufferTimerHandler);
			_sendJsTimer.addEventListener(TimerEvent.TIMER, _onSendJsTimerTimerHandler);
			_sendJsCQual.addEventListener(TimerEvent.TIMER,_onSendJsCQualTimerHandler);
			_eventSprite.addEventListener(MouseEvent.CLICK, _onMediaPlayerClickHandler);
			_mediaPlayerSprite.mediaPlayer.addEventListener(MediaErrorEvent.MEDIA_ERROR, _onMediaErrorEventHandler);
			_mediaPlayerSprite.mediaPlayer.addEventListener(DRMEvent.DRM_STATE_CHANGE, _onDrmStateChangeHandler);
			_mediaPlayerSprite.mediaPlayer.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, _onMediaPlayerStateHandler);
			_mediaPlayerSprite.mediaPlayer.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, _onMediaSizeChangeHandler);
			_mediaPlayerSprite.mediaPlayer.addEventListener(TimeEvent.CURRENT_TIME_CHANGE,       _onCurrentTimeChangeHandler);
			_mediaPlayerSprite.mediaPlayer.addEventListener(TimeEvent.DURATION_CHANGE,           _onDurationChangeHandler);
			_mediaPlayerSprite.mediaPlayer.addEventListener(SeekEvent.SEEKING_CHANGE,            _onSeekingChangeHandler);
			_mediaPlayerSprite.mediaPlayer.addEventListener(DynamicStreamEvent.SWITCHING_CHANGE, _onDSSwitchingChangeHandler);
			_mediaPlayerSprite.mediaPlayer.addEventListener(TimeEvent.COMPLETE,                  _onPlayerCompleteHandler);
			
			_mediaPlayerSprite.mediaPlayer.addEventListener(AlternativeAudioEvent.AUDIO_SWITCHING_CHANGE, _onPlayerAudioStreamChange);
			
			CONFIG::JSDEBUG {
				_mediaPlayerSprite.mediaPlayer.addEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, _onDisplayObjectChange);
			}
			
			if(ExternalInterface.available)
			{
				ExternalInterface.addCallback("selectLanguage", _onLanguageSelectionChange);
				ExternalInterface.call("console.log", "Audio selection listener added");
			}
		}
		
		CONFIG::JSDEBUG {
			private function _onDisplayObjectChange(evt:DisplayObjectEvent)
			{
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer._onDisplayObjectChange("+evt.toString()+")");
				this.logDimensions();
			}
		}
		
		private function _resizeAll():void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer._resizeAll");
			}
			CONFIG::SUBLINES
			{
				logDimensions();
			}
			try
			{
				if(Number(_globalParameters.bufferSize) > 0 && Number(_globalParameters.bufferSize) < _mediaPlayerSprite.mediaPlayer.duration)
					_bufferTime = Number(_globalParameters.bufferSize);
				else
					_bufferTime = _mediaPlayerSprite.mediaPlayer.duration;
			}
			catch(err:Error)
			{
				_bufferTime = _mediaPlayerSprite.mediaPlayer.duration;
			}
			try
			{
				//var _isResizedMode:Boolean = false;
				mediaWidth = _mediaPlayerSprite.mediaPlayer.mediaWidth;
				mediaHeight = _mediaPlayerSprite.mediaPlayer.mediaHeight;
				
				_preloader.x = _mp_width/2;
				_preloader.y = _mp_height/2;
				
				if(mediaWidth > 0 && mediaHeight > 0)
				{
					if(_globalState.fullscreen || _globalParameters.mode_4x3 == "true")
					{
						// Letterbox scale mode
						_mediaPlayerSprite.height = _mp_height;
						_mediaPlayerSprite.width  = _mp_width;
						_mediaPlayerSprite.scaleMode = ScaleMode.LETTERBOX;
						if(_mp_width/_mp_height > (mediaWidth/mediaHeight + 0.01))
						{
							// Touch top and bottom
							_playerHeight = _mp_height;
							_playerWidth  = mediaWidth*_mp_height/mediaHeight;
						}
						else// if(_mp_height/_mp_width > (mediaHeight/mediaWidth + 0.01))
						{
							// Touch sides
							_playerWidth  = _mp_width;
							_playerHeight = mediaHeight*_mp_width/mediaWidth;
						}
						/*if(_mp_width/_mp_height > (mediaWidth/mediaHeight + 0.02))
						{
							_mediaPlayerSprite.height = _mp_height + 14;
							_playerHeight = _mp_height + 3.5;
							_mediaPlayerSprite.width = mediaWidth * ((_mp_height + 14)/mediaHeight);
							_playerWidth = mediaWidth * ((_mp_height + 3.5)/mediaHeight);
							_mediaPlayerSprite.x = (_mp_width - mediaWidth * ((_mp_height + 14)/mediaHeight)) / 2;
							_mediaPlayerSprite.y = -7;
						}
						else if(_mp_height/_mp_width > (mediaHeight/mediaWidth + 0.02))
						{
							_mediaPlayerSprite.width = _mp_width + 14;
							_playerWidth = _mp_width;
							_mediaPlayerSprite.height = mediaHeight * ((_mp_width+14)/mediaWidth);
							_playerHeight = mediaHeight * (_mp_width/mediaWidth);
							_mediaPlayerSprite.x = -7;
							_mediaPlayerSprite.y = (_mp_height - mediaHeight * ((_mp_width+14)/mediaWidth)) / 2;
						}
						else
						{
							_mediaPlayerSprite.width = _mp_width + 14;
							_playerWidth = _mp_width;
							_mediaPlayerSprite.height = mediaHeight * ((_mp_width+14)/mediaWidth);
							_playerHeight = mediaHeight * (_mp_width/mediaWidth);
							_mediaPlayerSprite.x = -7;
							_mediaPlayerSprite.y = (_mp_height - mediaHeight * ((_mp_width+14)/mediaWidth)) / 2;
						}*/
					}
					else
					{
						// Zoom scale mode
						_mediaPlayerSprite.height = _mp_height;
						_mediaPlayerSprite.width  = _mp_width;
						_mediaPlayerSprite.scaleMode = ScaleMode.ZOOM;
						if(_mp_width/_mp_height < (mediaWidth/mediaHeight - 0.01))
						{
							// Touch top and bottom
							_playerHeight = _mp_height;
							_playerWidth  = mediaWidth*_mp_height/mediaHeight;
						}
						else// if(_mp_height/_mp_width > (mediaHeight/mediaWidth + 0.01))
						{
							// Touch sides
							_playerWidth  = _mp_width;
							_playerHeight = mediaHeight*_mp_width/mediaWidth;
						}
						/*if(_mp_width/_mp_height > (mediaWidth/mediaHeight + 0.02))
						{
							_mediaPlayerSprite.width = _mp_width + 14;
							_playerWidth = _mp_width;
							_mediaPlayerSprite.height = mediaHeight * ((_mp_width+14)/mediaWidth);
							_playerHeight = mediaHeight * (_mp_width/mediaWidth);
							_mediaPlayerSprite.x = -7;
							_mediaPlayerSprite.y = (_mp_height - mediaHeight * ((_mp_width+14)/mediaWidth)) / 2;
						}
						else if(_mp_height/_mp_width > (mediaHeight/mediaWidth + 0.02))
						{
							_mediaPlayerSprite.height = _mp_height + 14;
							_playerHeight = _mp_height + 3.5;
							_mediaPlayerSprite.width = mediaWidth * ((_mp_height + 14)/mediaHeight);
							_playerWidth = mediaWidth * ((_mp_height + 3.5)/mediaHeight);
							_mediaPlayerSprite.x = (_mp_width - mediaWidth * ((_mp_height + 14)/mediaHeight)) / 2;
							_mediaPlayerSprite.y = -7;
						}
						else
						{
							_mediaPlayerSprite.width = _mp_width + 14;
							_playerWidth = _mp_width;
							_mediaPlayerSprite.height = mediaHeight * ((_mp_width+14)/mediaWidth);
							_playerHeight = mediaHeight * (_mp_width/mediaWidth);
							_mediaPlayerSprite.x = -7;
							_mediaPlayerSprite.y = (_mp_height - mediaHeight * ((_mp_width+14)/mediaWidth)) / 2;
						}*/
					}
				}
				/*_playerMask.width = _mp_width;
				_playerMask.height = _mp_height;
				_playerMask.x = 0;
				_playerMask.y = 0;*/
				_eventSprite.graphics.clear();
				_eventSprite.graphics.beginFill(0xffffff);
				_eventSprite.graphics.drawRect(0, 0, _mp_width, _mp_height);
				_eventSprite.graphics.endFill();
				if(_itsTrailer == "true" || _autoPlay)
				{
					_playerWidth = _mp_width;
				}
				if(ExternalInterface.available) ExternalInterface.call(
					"console.log", "_resizeAll: playing = "+_mediaPlayerSprite.mediaPlayer.playing+" paused = "+_mediaPlayerSprite.mediaPlayer.paused);
				//subSize = subSize = _mediaPlayerSprite.height/22;
				//subTitleText.defaultTextFormat.size = subSize;
				
				calcSubBounds();
				CONFIG::SUBLINES
				{
					drawSubLines();
					logDimensions();
				}
				
				dispatchEvent(new Event(MEDIAPLAYER_NEW_WIDTH, true));
				//_bufferTimer.start();
			}
			catch(err:Error){}
		}
	
		private function calcSubBounds():void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "Subtitles.calcSubBounds");
			}
			subTop    = (_mp_height - _playerHeight)/2 + _playerHeight*0.805;
			subBottom = subTop + _playerHeight*0.115;
			if(_mediaPlayerSprite.x <= 0)
			{
				subLeft  = 0.078*_mp_width;
				subRight = (1 - 0.078)*_mp_width;
			}
			else
			{
				subLeft  = _mediaPlayerSprite.x + 0.078*_playerWidth;
				subRight = _mediaPlayerSprite.x + (1 - 0.078)*_playerWidth;
			}
			_subtitles.setDimensions(subLeft, subTop, subRight - subLeft, subBottom - subTop);
		}
		
		public function get playerWidth():Number
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer.get playerWidth");
			}
			//if(ExternalInterface.available) ExternalInterface.call("console.log", "playerWidth: " + _playerWidth);
			return _playerWidth;
		}
		
		/*public function set isFullScreen(val:Boolean):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer.set isFullScreen("+val+")");
			}
			_isFullscreen = val;
		}*/
		
		public function resizeAll():void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer.resizeAll");
			}
			_resizeAll();
		}
		
		public function set mp_width(w:Number):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer.set mp_width("+w+")");
			}
			_mp_width = w;
		}
		
		public function set mp_height(h:Number):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer.set mp_height("+h+")");
			}
			_mp_height = h;
		}
		
		public function set seek(time:Number):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer.set seek("+time+")");
			}
			_normalBuffering = true;
			_mediaPlayerSprite.mediaPlayer.bufferTime = _minBufferTime;
			_mediaPlayerSprite.mediaPlayer.seek(time);
			SendEventJS.sendEvent("begin_seek_to.seekevent",time.toString());
		}
		
		public function get currentTime():Number
		{
			CONFIG::JSDEBUG2 {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer.get currentTime");
			}
			return _mediaPlayerSprite.mediaPlayer.currentTime;
		}
		
		public function get bufferLength():Number
		{
			CONFIG::JSDEBUG2 {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer.get bufferLength");
			}
			return _mediaPlayerSprite.mediaPlayer.bufferLength;
		}
		
		public function get duration():Number
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer.get duration");
			}
			return _mediaPlayerSprite.mediaPlayer.duration;
		}
		
		public function set played(val:Boolean):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer.set played("+val+")");
			}
			_firstRun = false;
			_played = val;
			_normalBuffering = true;
			if(_trailer || _autoPlay)
			{
				try
				{
					_mediaPlayerSprite.mediaPlayer.bufferTime = _minBufferTime;
					_bufferTimer.start();
					if(_played)
					{
						if(_completed && _mediaPlayerSprite.mediaPlayer.currentTime != 0)
						{
							_completed = false;
							_mediaPlayerSprite.mediaPlayer.seek(0);
						}
						_mediaPlayerSprite.mediaPlayer.play();
						SendEventJS.sendEvent("play.playbackevent");
					}
					else
					{
						_mediaPlayerSprite.mediaPlayer.pause();
					}
				}
				catch(err:Error)
				{
					_firstChange = false;
				}
			}
			else
			{
				_trailer = true;
				_initInterface();
				_initListeners();
			}
			
		}
		
		public function set volume(vol:Number):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer.set volume("+vol+")");
			}
			if(_mediaPlayerSprite && _mediaPlayerSprite.mediaPlayer)
			{
				_mediaPlayerSprite.mediaPlayer.volume = vol;
			}
		}
		
		/*private function createSubtitlesObjects():void
		{
			if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer: creating subtitles");
			subTitleText = new TextField();
			//subTitleText.embedFonts = true;
			subTitleText.antiAliasType = AntiAliasType.NORMAL;
			
			//subTitleText.defaultTextFormat = new TextFormat("PlaybackBlack", subSize, 0xffffff,
			//	null, null, null, null, null, null, null, null, null, -5);
			subTitleTextFormat = new TextFormat("PlaybackBlack", subSize, 0xffffff,
				null, null, null, null, null, null, null, null, null, -5);
			subTitleText.defaultTextFormat = subTitleTextFormat;
			subTitleText.autoSize = TextFieldAutoSize.LEFT;
			subTitleText.selectable = false;
			addChild(subTitleText);
			// add outline, blur & shadow
			subOutline = new GlowFilter(
				0,			//color
				1.0,		//alpha
				subSize/20,	//blurX
				subSize/20,	//blurY
				2,			//strength
				2			//quality
			);
			subBlur = new BlurFilter(
				subSize/24,
				subSize/24,
				2
			);
			subShadow = new DropShadowFilter(
				subSize/6,	//distance
				45,			//angle
				0,			//color
				0.75,		//alpha
				subSize/16,	//blurX
				subSize/16,	//blurY
				1,			//strength
				2			//quality
			);
			subTitleText.filters = [subBlur, subOutline, subShadow];
		}*/
		
		/*private function calcSubBounds():void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer.calcSubBounds");
			}
			subTop    = (_mp_height - _playerHeight)/2 + _playerHeight*0.805;
			subBottom = subTop + _playerHeight*0.115;
			if(_mediaPlayerSprite.x <= 0)
			{
				subLeft  = 0.078*_mp_width;
				subRight = (1 - 0.078)*_mp_width;
			}
			else
			{
				subLeft  = _mediaPlayerSprite.x + 0.078*_playerWidth;
				subRight = _mediaPlayerSprite.x + (1 - 0.078)*_playerWidth;
			}
			
			subSize = _playerHeight/18;
			
			if(subTitleText == null)
			{
				createSubtitlesObjects();
			}
			else
			{
				subTitleText.x     = _mp_width/2;
				subTitleText.y     = _mp_height/2;
				subOutline.blurX   = subSize/20;
				subOutline.blurY   = subSize/20;
				subBlur.blurX      = subSize/24;
				subBlur.blurY      = subSize/24;
				subShadow.distance = subSize/6;
				subShadow.blurX    = subSize/16;
				subShadow.blurY    = subSize/16;
			}
			//subTitleText.defaultTextFormat.size = subSize;
			subTitleTextFormat.size = subSize;
			subTitleText.visible = false;
			subTitleText.text  = "$";
			//subTitleText.setTextFormat(subTitleTextFormat);
			//subLineHeight      = subTitleText.textHeight;
		}*/
		
		CONFIG::SUBLINES
		{
			private var lines:Shape = null;
			private function drawSubLines():void
			{
				if(subLeft > 0 && subRight > 0 && subTop > 0 && subBottom > 0)
				{
					if(lines == null)
					{
						lines = new Shape();
						addChild(lines);
					}
					else
						lines.graphics.clear();
					lines.graphics.lineStyle(2, 0x009999);
					
					lines.graphics.moveTo(0, subTop);
					lines.graphics.lineTo(_mp_width, subTop);
					
					
					lines.graphics.moveTo(0, subBottom);
					lines.graphics.lineTo(_mp_width, subBottom);
					
					
					lines.graphics.moveTo(subLeft, 0);
					lines.graphics.lineTo(subLeft, _mp_height);
					
					lines.graphics.moveTo(subRight, 0);
					lines.graphics.lineTo(subRight, _mp_height);
				}
				/*lines.graphics.moveTo(0, 0.92*mediaHeight);
				lines.graphics.lineTo(mediaWidth, 0.92*mediaHeight);
				
				
				lines.graphics.moveTo(0, 0.805*mediaHeight);
				lines.graphics.lineTo(mediaWidth, 0.805*mediaHeight);
				
				
				lines.graphics.moveTo(0.078*mediaWidth, 0);
				lines.graphics.lineTo(0.078*mediaWidth, mediaHeight);
				
				lines.graphics.moveTo((1.0 - 0.078)*mediaWidth, 0);
				lines.graphics.lineTo((1.0 - 0.078)*mediaWidth, mediaHeight);*/
			}
			private function logDimensions():void
			{
				if(ExternalInterface.available) ExternalInterface.call("console.log",
					" Dimensions" +
					"\n  width:        " + width +
					"\n  height:       " + height +
					"\n  x:            " + x +
					"\n  y:            " + y +
					"\n  _mp_width:        " + _mp_width +
					"\n  _mp_height:       " + _mp_height +
//					"\n  _playerWidth:  " + _playerWidth +
//					"\n  _playerHeight: " + _playerHeight +
					"\n   mediaWidth:   " + mediaWidth +
					"\n   mediaHeight:  " + mediaHeight +
					"\n  _mediaPlayerSprite.width:  " + _mediaPlayerSprite.width +
					"\n  _mediaPlayerSprite.height: " + _mediaPlayerSprite.height +
					"\n  _mediaPlayerSprite.x:      " + _mediaPlayerSprite.x +
					"\n  _mediaPlayerSprite.y:      " + _mediaPlayerSprite.y
				);
			}
		}
		
		
		
		private function _onMediaErrorEventHandler(evt:MediaErrorEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer._onMediaErrorEventHandler");
			}
			trace("media error:",evt.error.errorID);
			if(ExternalInterface.available)
			{
					ExternalInterface.call("console.log", "MediaPlayer Error: "+evt.error.errorID);
					ExternalInterface.call("MovieLicenseError");
			}
		}
		
		/*private function _onFullscreenHandler(evt:FullScreenEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer._onFullscreenHandler");
			}
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
		}*/
		
		private function _onBufferTimerHandler(evt:TimerEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer._onBufferTimerHandler");
			}
			try
			{
				_mediaPlayerSprite.mediaPlayer.bufferTime = _bufferTime;//_mediaPlayerSprite.mediaPlayer.duration;
				_bufferTimer.stop();
			}
			catch(err:Error){}
		}
		
		private function _onEmptyBufferTimerHandler(evt:TimerEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer._onEmptyBufferTimerHandler");
			}
			if(_mediaPlayerSprite.mediaPlayer.bufferLength >= 60)
			{
				dispatchEvent(new Event(MEDIAPLAYER_SPRITE_CLICK, true));
				_emptyBufferTimer.stop();
				_emptyBufferTimer.reset();
			}
		}
		
		private function _onSendJsTimerTimerHandler(evt:TimerEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer._onSendJsTimerTimerHandler");
			}
			SendEventJS.sendEvent("current_time.playbackevent", _mediaPlayerSprite.mediaPlayer.currentTime.toString());
		}
		
		private function _onSendJsCQualTimerHandler(evt:TimerEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer._onSendJsCQualTimerHandler");
			}
			SendEventJS.sendEvent("current_quality.qualityevent", _mediaPlayerSprite.mediaPlayer.currentDynamicStreamIndex.toString());
		}
		
		private function _onPlayerCompleteHandler(evt:TimeEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer._onPlayerCompleteHandler");
			}
			if(ExternalInterface.available) ExternalInterface.call("console.log", "player.time.complete111");
			if(!_completed)
			{
				dispatchEvent(new Event(MEDIAPLAYER_TIME_COMPLETE, true));
				_completed = true;
			}
		}
		
		private function _onMediaPlayerSpaceHandler(evt:KeyboardEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer._onMediaPlayerSpaceHandler");
			}
			if(evt.keyCode == Keyboard.SPACE)
			{
				dispatchEvent(new Event(MEDIAPLAYER_SPRITE_CLICK, true));
			}
		}
		
		private function _onMediaPlayerClickHandler(evt:MouseEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer._onMediaPlayerClickHandler");
			}
			dispatchEvent(new Event(MEDIAPLAYER_SPRITE_CLICK, true));
		}
		
		private function _onDSSwitchingChangeHandler(evt:DynamicStreamEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer._onDSSwitchingChangeHandler");
			}
			_normalBuffering = true;
			if(evt.switching)
			{
				dispatchEvent(new Event(MEDIAPLAYER_DS_SWITCH_BEGIN, true));
			}
			else
			{
				dispatchEvent(new Event(MEDIAPLAYER_DS_SWITCH_COMPLETE, true));
				SendEventJS.sendEvent("switch_quality.qualityevent", _mediaPlayerSprite.mediaPlayer.currentDynamicStreamIndex.toString());
			}
		}
		
		private function _onSeekingChangeHandler(evt:SeekEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer._onSeekingChangeHandler");
			}
			if(!evt.seeking)
			{
				dispatchEvent(new Event(MEDIAPLAYER_SEEK_COMPLETE, true));
				SendEventJS.sendEvent("finish_seek_to.seekevent",evt.time.toString());
			}
			else
			{
				if(_completed)
				{
					dispatchEvent(new Event(MEDIAPLAYER_SPRITE_CLICK, true));
				}
			}
		}
		
		private function _onDrmStateChangeHandler(evt:DRMEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer._onDrmStateChangeHandler");
			}
			if(ExternalInterface.available) ExternalInterface.call("console.log", "DRM State: "+evt.drmState);
			switch(evt.drmState)
			{
				case DRMState.AUTHENTICATION_COMPLETE:
				SendEventJS.sendEvent("authentication_complete.drmevent");
					if(_played)
					{
						try
						{
							_authenticated = true;
							_normalBuffering = true;
							_bufferTimer.stop();
							_mediaPlayerSprite.mediaPlayer.bufferTime = _minBufferTime;
							_mediaPlayerSprite.mediaPlayer.play();
						}
						catch(err:Error){}
					}
					break;
				case DRMState.AUTHENTICATION_ERROR:
				SendEventJS.sendEvent("authentication_error.drmerror");
					if(ExternalInterface.available)
					{
						ExternalInterface.call("console.log", "DRM Auth Error: "+evt.mediaError.errorID);
						ExternalInterface.call("MovieLicenseError");
					}
					break;
			}
		}
		
		private function _onMediaPlayerStateHandler(evt:MediaPlayerStateChangeEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer._onMediaPlayerStateHandler");
			}
			//trace(evt.state);
			if(ExternalInterface.available)  ExternalInterface.call("console.log", "MainPlayer._onMediaPlayerStateHandler("+evt.state+")");
			switch(evt.state)
			{
				case MediaPlayerState.READY:
					// Update alternative audio info
					if(_mediaPlayerSprite.mediaPlayer.hasAlternativeAudio)
					{
						// Get list of alternative audio tracks
						_globalState.audioCount = _mediaPlayerSprite.mediaPlayer.numAlternativeAudioStreams;
						if(ExternalInterface.available)
							ExternalInterface.call("console.log", "MediaPlayer State: " + _globalState.audioCount + " alternative audio streams");
						for(var i:uint = 0; i < _globalState.audioCount; i++)
						{
							var AA:StreamingItem = _mediaPlayerSprite.mediaPlayer.getAlternativeAudioItemAt(i);
							_globalState.audioLang[i] = AA.info.language;
							_globalState.audioIndex[AA.info.language] = i;
							if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer.AltAudio"+
								"\n  streamName: " + AA.streamName +
								"\n        type: " + AA.type +
								"\n    language: " + _globalState.audioLang[i] +
								"\n");
						}
					}
					dispatchEvent(new Event(MEDIAPLAYER_READY, false));
					break;
				case MediaPlayerState.BUFFERING: 
					_bufferTimer.stop();
					_sendJsTimer.stop();
					_sendJsCQual.stop();
					_mediaPlayerSprite.mediaPlayer.bufferTime = _minBufferTime;
					if(Math.floor(_mediaPlayerSprite.mediaPlayer.currentTime) == Math.floor(_mediaPlayerSprite.mediaPlayer.duration))
					{
						if(!_completed)
						{
							_firstRun = true;
							if(!_globalParameters._isTrailer)
							{
								_mediaPlayerSprite.mediaPlayer.seek(0);//_mediaPlayerSprite.mediaPlayer.seek(_mediaPlayerSprite.mediaPlayer.duration);
							}/*else{
								_mediaPlayerSprite.mediaPlayer.seek(0);
							}*/
							_mediaPlayerSprite.mediaPlayer.pause();
							_completed = true;
							dispatchEvent(new Event(MEDIAPLAYER_TIME_COMPLETE, true));
						}
					}
					else
					{
						if(!_normalBuffering)
						{
							dispatchEvent(new Event(MEDIAPLAYER_SPRITE_CLICK, true));
							_emptyBufferTimer.start();
						}
						else
						{
							_normalBuffering = false;
						}
					}
					if(!_firstRun)
					{
						_preloader.x = _mp_width/2;
						_preloader.y = _mp_height/2;
						_preloader.visible = true;
					}
					break;
				case MediaPlayerState.PLAYING:
					//SendEventJS.sendEvent("playbackevent.play");
					_completed = false;
					_emptyBufferTimer.stop();
					_emptyBufferTimer.reset();
					_sendJsTimer.start();
					_sendJsCQual.start();
					if(!_firstRun)
					{
						_preloader.visible = false;
					}
					if(_authenticated)
					{
						_authenticated = false;
						if(Number(_globalParameters.start_time) > 0)
						{
							_mediaPlayerSprite.mediaPlayer.seek(Number(_globalParameters.start_time));
						}
					}
					_mediaPlayerSprite.mediaPlayer.bufferTime = _minBufferTime;
					if(!_firstChange)
					{
						_bufferTimer.start();
					}
					break;
				case MediaPlayerState.PAUSED:
					SendEventJS.sendEvent("pause.playbackevent");
					_sendJsTimer.stop();
					_sendJsCQual.stop();
					break;
				case MediaPlayerState.PLAYBACK_ERROR:
					SendEventJS.sendEvent("media_not_found.playbackerror");
					break;
			}
			
		}

		private function _onCurrentTimeChangeHandler(evt:TimeEvent):void
		{
			CONFIG::JSDEBUG2 {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer._onCurrentTimeChangeHandler");
			}
			_preloader.visible = false;
			dispatchEvent(new Event(MEDIAPLAYER_CURRENT_TIME_CHANGE, true));
		}
		
		private function _onDurationChangeHandler(evt:TimeEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer._onDurationChangeHandler");
			}
			dispatchEvent(new Event(MEDIAPLAYER_DURATION_CHANGE, true));
		}
		
		private function _onMediaSizeChangeHandler(evt:DisplayObjectEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer._onMediaSizeChangeHandler");
			}
			if(_firstChange)
			{
				if(!_played)
				{
					_mediaPlayerSprite.mediaPlayer.pause();
					if(_itsTrailer == "true" || _autoPlay)
					{
						dispatchEvent(new Event(MEDIAPLAYER_SPRITE_CLICK, true));
					}
				}
				_firstChange = false;
			}
			
			//only for "movie"
			
			if(_firstSwitch)
			{
				try
				{
					_mediaPlayerSprite.mediaPlayer.switchDynamicStreamIndex(_mediaPlayerSprite.mediaPlayer.maxAllowedDynamicStreamIndex);
				}
				catch(err:Error){}
				_firstSwitch = false;
			}
			_resizeAll();
		}
		
		private function _onLanguageSelectionChange(event:String):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer._onLanguageSelectionChange");
			}
			if(_mediaPlayerSprite.mediaPlayer.hasAlternativeAudio)
			{
				_globalState.audioSelected += 1;
				if(_globalState.audioSelected >= _globalState.audioCount)
				{
					_globalState.audioSelected = 0;
				}
				//ExternalInterface.call("console.log", "Current alt audio: " + _mediaPlayerSprite.mediaPlayer.currentAlternativeAudioStreamIndex());
				_mediaPlayerSprite.mediaPlayer.switchAlternativeAudioIndex(_globalState.audioSelected);
				ExternalInterface.call("console.log", "Switching to lang #" + _globalState.audioSelected);
			}
		}
		
		private function _onLanguageChange(event:LangSubsSelectEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainPlayer._selectLanguageMode");
			}
			_globalState.audioSelected = _globalState.audioIndex[event.val];
			_mediaPlayerSprite.mediaPlayer.switchAlternativeAudioIndex(_globalState.audioSelected);
		}
		
		private function _onPlayerAudioStreamChange(event:AlternativeAudioEvent):void
		{
			if(event.switching)
			{
				//status.text = "Switching Audio Track...";
				//trace( "Alternative audio stream is switching." );
				if(ExternalInterface.available) ExternalInterface.call("console.log", "Alternative audio stream is switching.");
				// Try to skip buffer
				//_switchingTime = _mediaPlayerSprite.mediaPlayer.currentTime;
				//_mediaPlayerSprite.mediaPlayer.stop();
			}
			else
			{
				//status.text = "Audio Switch Complete";
				//trace( "Alternative audio switch is complete." );
				if(ExternalInterface.available) ExternalInterface.call("console.log", "Alternative audio switch is complete.");
				dispatchEvent(new Event(MEDIAPLAYER_LANG_SWITCH_COMPLETE, true));
				//_mediaPlayerSprite.mediaPlayer.play();
				//_mediaPlayerSprite.mediaPlayer.seek(_switchingTime);
			}
		}
		
		/*private var _SRTLoader:URLLoader = new URLLoader();
		
		private function loadSRT(url:String):void
		{
			if(url != null)
			{
				if(ExternalInterface.available)
				{
					ExternalInterface.call("console.log", "Load SRT: " + url);
				}
				try
				{
					//_SRTLoader = new URLLoader();
					_SRTLoader.addEventListener(Event.COMPLETE,                    loadSRT_Complete,      false, 0, true);
					_SRTLoader.addEventListener(Event.OPEN,                        loadSRT_Open,          false, 0, true);
					_SRTLoader.addEventListener(ProgressEvent.PROGRESS,            loadSRT_Progress,      false, 0, true);
					_SRTLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadSRT_SecurityError, false, 0, true);
					_SRTLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS,       loadSRT_HTTP_Status,   false, 0, true);
					_SRTLoader.addEventListener(IOErrorEvent.IO_ERROR,             loadSRT_IO_Error,      false, 0, true);
					_SRTLoader.dataFormat = URLLoaderDataFormat.TEXT;
					_SRTLoader.load(new URLRequest(url));
				}
				catch(err:Error)
				{
					if(ExternalInterface.available) ExternalInterface.call("console.log", "Load SRT error: " + err.toString());
				}
			}
		}
		
		private function loadSRT_Complete(e:Event):void
		{
			if(ExternalInterface.available) ExternalInterface.call("console.log", "loadSRT_Complete");
			parseSRT();
		}
		
		private function loadSRT_Open(e:Event):void
		{
			if(ExternalInterface.available) ExternalInterface.call("console.log", "loadSRT_Open");
		}
		
		private function loadSRT_Progress(e:Event):void
		{
			if(ExternalInterface.available) ExternalInterface.call("console.log", "loadSRT_Progress");
		}
		
		private function loadSRT_SecurityError(e:Event):void
		{
			if(ExternalInterface.available) ExternalInterface.call("console.log", "loadSRT_SecurityError");
		}
		
		private function loadSRT_HTTP_Status(e:Event):void
		{
			if(ExternalInterface.available) ExternalInterface.call("console.log", "loadSRT_HTTP_Status");
		}
		
		private function loadSRT_IO_Error(e:Event):void
		{
			if(ExternalInterface.available) ExternalInterface.call("console.log", "loadSRT_IO_Error");
			CONFIG::SUBLINES
			{
				loadSRT_Default();
			}
		}
		
		CONFIG::SUBLINES
		{
			private function loadSRT_Default():void
			{
				try
				{
					timelineMetaData.addMarker(new CuePoint(CuePointType.ACTIONSCRIPT, 2.5,  "", ["subtitle #1"], 5.2));
					timelineMetaData.addMarker(new CuePoint(CuePointType.ACTIONSCRIPT, 10.5, "", ["subtitle #2 LONG LONG LONG LONG LONG LONG LONG line\nsecond line"], 4.2));
					timelineMetaData.addMarker(new CuePoint(CuePointType.ACTIONSCRIPT, 15.5, "", ["subtitle #3\nsecond line\nthird line"], 4.2));
					timelineMetaData.addMarker(new CuePoint(CuePointType.ACTIONSCRIPT, 20.5, "", ["subtitle #4 LONG LONG LONG LONG LONG LONG LONG line\nsecond line"], 4.2));
					timelineMetaData.addMarker(new CuePoint(CuePointType.ACTIONSCRIPT, 25.5, "", ["subtitle #5"], 4.2));
					timelineMetaData.addMarker(new CuePoint(CuePointType.ACTIONSCRIPT, 30.5, "", ["subtitle #6 LONG LONG LONG LONG LONG LONG LONG line\nsecond line"], 4.2));
					timelineMetaData.addMarker(new CuePoint(CuePointType.ACTIONSCRIPT, 35.5, "", ["subtitle #7\nsecond line\nthird line"], 4.2));
					timelineMetaData.addMarker(new CuePoint(CuePointType.ACTIONSCRIPT, 40.5, "", ["subtitle #8 LONG LONG LONG LONG LONG LONG LONG line\nsecond line"], 4.2));
					timelineMetaData.addMarker(new CuePoint(CuePointType.ACTIONSCRIPT, 45.5, "", ["subtitle #9"], 4.2));
				}
				catch(e:Error)
				{
					if(ExternalInterface.available) ExternalInterface.call("console.log", "TimelineMetaData::addMarker error: " + e.toString());
				}
			}
		}
		
		private function parseSRT():void
		{
			var blocks : Array;
			var rn:uint = 1;
			CONFIG::SUBLINES
			{
				timelineMetaData.addMarker(new CuePoint(CuePointType.ACTIONSCRIPT, 1.0, "", ["тест ТЕСТ русских букв"], 3.5));
			}
			blocks = _SRTLoader.data.split(/^[0-9]+$/gm);
			for each (var block : String in blocks)
			{
				var ln:uint = 0;
				var valid:Boolean = true;
				var start:Number;
				var end:Number;
				var dur:Number;
				var text:String = "";
				var lines:Array;
				
				lines = block.split(/['\n''\r']/);
				for each (var line : String in lines)
				{
					//all lines in a translation block
					var tline:String = trim(line);
					if(tline != "")
					{
						if(ln == 0)
						{
							//timecodes line
							var timecodes : Array = line.split(/ +\-\-\> +/);
							start = stringToSeconds(timecodes[0]);
							end = stringToSeconds(timecodes[1]);
							dur = end - start;
							if(dur <= 0)
							{
								trace("Error (srt): inverse duration");
								valid = false;
							}
						}
						else
						{
							//translation line
							if(ln > 1)
								tline = "\n" + tline;
							text += tline;
						}
						ln++;
					}
				}
				if(ln > 2 && valid)
				{
					// Store sub
					timelineMetaData.addMarker(new CuePoint(CuePointType.ACTIONSCRIPT, start, "", [text], dur));
					rn++;
					CONFIG::SUBLINES
					{
						if(ExternalInterface.available) ExternalInterface.call("console.log", "Parse SRT: added \"" + text + "\"");
					}
				}
			}
			if(ExternalInterface.available) ExternalInterface.call("console.log", "Parse SRT: " + rn + " records");
		}
		
		public static function trim(p_string : String) : String
		{
			if (p_string == null)
			{
				return '';
			}
			return p_string.replace(/^\s+|\s+$/, '');
		}
		
		public static function stringToSeconds(string : String) : Number
		{
			var arr : Array = string.split(/[\:\,]/);
			var sec : Number = 0;
			if(arr.length == 4)
			{
				sec = 3600*Number(arr[0]) + 60*Number(arr[1]) + Number(arr[2]) + 0.001*Number(arr[3])
			}
			return sec;
		}*/

		/*private function onCueEnter(e:TimelineMetadataEvent):void
		{
			var params = e.marker as CuePoint;
			subTitleText.visible = false;
			subTitleText.text = "$";
			//subLineHeight = subTitleText.height;
			subTitleText.text = String(params.parameters[0]);
			subTitleText.setTextFormat(subTitleTextFormat);
			subTitleText.x = (_mp_width - subTitleText.width)/2;
			subTitleText.y = subBottom - subTitleText.height;
			subTitleText.visible = true;
			//if(ExternalInterface.available) ExternalInterface.call("console.log", "onCueEnter: " + params.parameters[0]);
		}
		
		private function onCueLeave(e:TimelineMetadataEvent) : void
		{
			subTitleText.text = " ";
			//if(ExternalInterface.available) ExternalInterface.call("console.log", "onCueLeave");
		}*/
	}
}
