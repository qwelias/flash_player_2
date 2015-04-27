package ayyo.container
{
	import ayyo.player.AyyoPlayer;
	import ayyo.player.core.model.PlayerCommands;
	import ayyo.player.events.*;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.media.StageVideo;
	import flash.system.Security;
	import flash.utils.setTimeout;
	
	import org.osmf.events.LoadEvent;
	import org.osmf.events.LoaderEvent;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaPlayerSprite;
	
	import ru.yandex.video.IVideoContainer;
	import ru.yandex.video.VideoContainerAPIVersion;
	import ru.yandex.video.VideoContainerEvents;
	import ru.yandex.video.VideoContainerStates;
	
	public class AyyoContainer extends AyyoPlayer implements IVideoContainer
	{			
		private var _player:MediaPlayerSprite;
		private function get player():MediaPlayerSprite
		{
			return this.context.injector.getInstance(MediaPlayerSprite); 
		}
		
		private var _state:String = VideoContainerStates.INACTIVE;
		private var _volume:Number = 0.6;
		private var _coid:String;
		private var _seekable:Boolean = true;
		private var _time:Number;
		private var _duration:Number;
		private var _bytesLoaded:uint;
		private var _bytesOffset:uint;
		private var _bytesTotal:uint;
		private var _initBytesTotal:uint;
		
		private function dispatchSimpleEvent(eventName:String):void {
			trace("-->", "DISPATCHING:", eventName);
			dispatchEvent(new Event(eventName));
		}
		
		private function setState(value:String):void {
			if (_state == value) return;
			trace("-->", this.state,"->",value);
			_state = value;
			dispatchSimpleEvent(VideoContainerEvents.STATE_CHANGE);
		}
		
		
		
		
		
		public function AyyoContainer()
		{
			Security.allowDomain("*");
			super();
			this.dispatcher.addEventListener(WrapperEvent.BEFORE_LOAD, this.onReadyToLoad);
			this.dispatcher.addEventListener(WrapperEvent.PLAYABLE, this.onLoaded);
			this.dispatcher.addEventListener(WrapperEvent.ERROR, this.onError);
		}
		
		public function load(config:Object):void
		{	
			//TODO
		}
		
		public function start():void
		{
			this.dispatcher.dispatchEvent(new WrapperEvent(WrapperEvent.PLAY))
			this.setState(VideoContainerStates.START);
			this.setState(VideoContainerStates.VIDEO_PLAYING);
		}
		
		public function setAgeConfirmed(confirmed:Boolean):void
		{
			//TODO
		}
		
		public function stop():void
		{
			//TODO
			setState(VideoContainerStates.VIDEO_ENDED);
			setState(VideoContainerStates.END);
		}
		
		public function pause(adAllowed:Boolean=false):void
		{
			this.dispatcher.dispatchEvent(new WrapperEvent(WrapperEvent.PAUSE))
			setState(VideoContainerStates.VIDEO_PAUSED);
		}
		
		public function resume():void
		{
			if (this.state != VideoContainerStates.VIDEO_PAUSED) return;
			this.dispatcher.dispatchEvent(new WrapperEvent(WrapperEvent.PLAY))
			setState(VideoContainerStates.VIDEO_PLAYING);
		}
		
		public function mute():void
		{
			this.dispatcher.dispatchEvent(new WrapperEvent(WrapperEvent.VOLUME, [0]));
			dispatchSimpleEvent(VideoContainerEvents.MUTED);
		}
		
		public function unmute():void
		{
			this.volume = this.volume;
			dispatchSimpleEvent(VideoContainerEvents.UNMUTED);
		}
		
		public function beginSeek():void
		{
			this.dispatcher.dispatchEvent(new WrapperEvent(WrapperEvent.PAUSE));
			setState(VideoContainerStates.VIDEO_PAUSED);
		}
		
		public function endSeek():void
		{
			this.resume();
		}
		
		public function seek(timeInSeconds:Number):void
		{
			if(!isNaN(timeInSeconds) && this.seekAllowed)
			{
				this.player.mediaPlayer.seek(timeInSeconds);
			}
		}
		
		public function setFullscreen(state:Boolean):void
		{
		}
		
		public function setStageVideoAvailable(available:String, reason:String, stageVideos:Vector.<StageVideo>):void
		{
		}
		
		public function setSize(width:Number, height:Number):void
		{
		}
		
		public function get quality():Object
		{
			return null;
		}
		
		public function get availableQualities():Array
		{
			return new Array();
		}
		
		public function setQuality(quality:Object):void
		{
		}
		
		public function get audioTrack():Object
		{
			return null;
		}
		
		public function get availableAudioTracks():Array
		{
			return null;
		}
		
		public function setAudioTrack(audioTrack:Object):void
		{
		}
		
		public function get subtitleTrack():Object
		{
			return null;
		}
		
		public function get availableSubtitleTracks():Array
		{
			return null;
		}
		
		public function setSubtitleTrack(subtitleTrack:Object):void
		{
		}
		
		public function get apiVersion():String
		{
			return VideoContainerAPIVersion.VERSION;
		}
		
		public function get coid():String
		{
			return "test" || this._coid;
		}
		
		public function get state():String
		{
			return this._state;
		}
		
		public function get duration():Number
		{
			return this._duration;
		}
		
		public function get time():Number
		{
			return this._time;
		}
		
		public function get seekAllowed():Boolean
		{
			return this._seekable;
		}
		
		public function get volume():Number
		{
			return this._volume;
		}
		
		public function set volume(value:Number):void
		{
			this.dispatcher.dispatchEvent(new WrapperEvent(WrapperEvent.VOLUME, [volume]));
			this._volume = volume;
			dispatchSimpleEvent(VideoContainerEvents.VOLUME_CHANGE);
		}
		
		public function get bytesTotal():uint
		{
			return this._initBytesTotal;
		}
		
		public function get bytesOffset():uint
		{
			return this._bytesOffset;
		}
		
		public function get bytesLoaded():uint
		{
			return this._bytesLoaded;
		}
		
		//Handlers
		private function onError(event:Event):void
		{
			this.setState(VideoContainerStates.ERROR);
		}
		
		private function onReadyToLoad(event:Event):void
		{
			if(this.state == VideoContainerStates.INACTIVE
				|| this.state == VideoContainerStates.END){
				this.addEventListener(LoadEvent.BYTES_LOADED_CHANGE, this.onBytesLoaded);
				this.addEventListener(LoadEvent.BYTES_TOTAL_CHANGE, this.onBytesTotal);
				this.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, this.onTimeChange);
				this.setState(VideoContainerStates.INITIALIZED);
			}
		}
		private function onBytesLoaded(event:LoadEvent):void
		{
			trace(event.bytes);
			this._bytesLoaded = event.bytes;
		}
		private function onBytesTotal(event:LoadEvent):void
		{
			this._bytesTotal = event.bytes;
			this._bytesOffset = this._initBytesTotal - this._bytesTotal;
		}
		private function onTimeChange(event:TimeEvent):void
		{
			this._time = event.time;
		}
		
		private function onLoaded(event:Event):void
		{
			if(this.state == VideoContainerStates.INITIALIZED){
				this._duration = this.player.mediaPlayer.duration;
				this._initBytesTotal = this.player.mediaPlayer.bytesTotal;
				this.setState(VideoContainerStates.READY);
			}
		}
	}
}