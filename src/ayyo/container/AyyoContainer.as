package ayyo.container
{
	import ayyo.player.AyyoPlayer;
	import ayyo.player.config.impl.support.VideoSettings;
	import ayyo.player.core.model.PlayerCommands;
	import ayyo.player.events.*;
	import ayyo.player.view.api.IVideoTimeline;
	import ayyo.player.view.impl.controllbar.VideoTimeline;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.media.StageVideo;
	import flash.system.Security;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	import org.osmf.events.LoadEvent;
	import org.osmf.events.LoaderEvent;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.TimeTrait;
	
	import ru.yandex.video.IVideoContainer;
	import ru.yandex.video.VideoContainerAPIVersion;
	import ru.yandex.video.VideoContainerEvents;
	import ru.yandex.video.VideoContainerStates;
	
	public class AyyoContainer extends AyyoPlayer implements IVideoContainer
	{			
		private var _player:MediaPlayerSprite;
		private function get player():MediaPlayerSprite
		{
			return this._player ||=this.context.injector.getInstance(MediaPlayerSprite) as MediaPlayerSprite; 
		}
		
		private var _state:String = VideoContainerStates.INACTIVE;
		private var _volume:Number = 0.6;
		private var _coid:String;
		private var _time:Number;
		private var _duration:Number = 0;
		private var _bytesLoaded:uint;
		private var _bytesOffset:uint;
		private var _bytesTotal:uint;
		private var _bitrate:Number = 0;
		
		private var buffering:uint;
		
		private function dispatchSimpleEvent(eventName:String):void {
			CONFIG::DEBUG{
				trace("-->", "DISPATCHING:", eventName);
			}
			dispatchEvent(new Event(eventName));
		}
		
		private function setState(value:String):void {
			if (_state == value) return;
			CONFIG::DEBUG{
				trace("-->", this.state,"->",value);
			}
			_state = value;
			dispatchSimpleEvent(VideoContainerEvents.STATE_CHANGE);
		}
		
		
		
		
		
		public function AyyoContainer()
		{
			Security.allowDomain("*");
			super();
			this.dispatcher.addEventListener(WrapperEvent.BEFORE_LOAD, this.onReadyToLoad);
//			this.dispatcher.addEventListener(WrapperEvent.DURATION, this.onDuration);
			this.dispatcher.addEventListener(WrapperEvent.PLAYABLE, this.onLoaded);
			this.dispatcher.addEventListener(WrapperEvent.ERROR, this.onError);
			this.dispatcher.addEventListener(PlayerEvent.DYNAMIC_STREAM_CHANGE, this.onBitrate);
		}
		
		public function load(config:Object):void
		{	
			this._coid = config.coid as String;
			CONFIG::DEBUG{
				trace("--> config");
				for(var key:String in config){
					trace(key," : ",config[key]);
				}
			}
			var VS:VideoSettings = new VideoSettings();
			var sid:String = (config.source_id as String);
			var source:Object = {};
			source.url = sid.substr(0, sid.indexOf("begintokensessionid"));
			source.token = sid.substr(sid.indexOf("begintokensessionid"));
			CONFIG::DEBUG{
				trace("--> SOURCE");
				for(var prop:String in source){
					trace(prop," : ",source[prop]);
				}
			}
			if(!source.url || !source.token){
				return setState(VideoContainerStates.ERROR)
			}
			VS.initialize(source);
			this.dispatcher.dispatchEvent(new WrapperEvent(WrapperEvent.LOAD, [VS.url, VS.token]));
		}
		
		public function start():void
		{
			if(this.state != VideoContainerStates.READY) return;
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
			if(this.state != VideoContainerStates.VIDEO_PLAYING) return;
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
			this.player.mediaPlayer.volume = 0;
//			this.dispatcher.dispatchEvent(new WrapperEvent(WrapperEvent.VOLUME, [0]));
			dispatchSimpleEvent(VideoContainerEvents.MUTED);
		}
		
		public function unmute():void
		{
			
			this.player.mediaPlayer.volume = this.volume;
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
			if(!isNaN(timeInSeconds) && this.seekAllowed && this.player.mediaPlayer.canSeekTo(timeInSeconds))
			{
				dispatchSimpleEvent(VideoContainerEvents.BUFFERING);
				this.player.mediaPlayer.seek(timeInSeconds);
				this.buffering = setInterval(this.checkBuffering, 25);
			}
		}
		private function checkBuffering():void
		{
			if(!this.player.mediaPlayer.buffering){
				clearInterval(this.buffering);
				dispatchSimpleEvent(VideoContainerEvents.BUFFERED);
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
			this.player.width = width;
			this.player.height = height;
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
			return this._coid;
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
			return this.player.mediaPlayer.canSeek;
		}
		
		public function get volume():Number
		{
			return this._volume;
		}
		
		public function set volume(value:Number):void
		{
//			this.dispatcher.dispatchEvent(new WrapperEvent(WrapperEvent.VOLUME, [value]));
			this.player.mediaPlayer.volume = value;
			this._volume = value;
			dispatchSimpleEvent(VideoContainerEvents.VOLUME_CHANGE);
		}
		
		public function get bytesTotal():uint
		{
			return this._bitrate * this._duration / 8 * 1024;
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
				this.player.mediaPlayer.addEventListener(LoadEvent.BYTES_LOADED_CHANGE, this.onBytesLoaded);
				this.player.mediaPlayer.addEventListener(LoadEvent.BYTES_TOTAL_CHANGE, this.onBytesTotal);
				this.player.mediaPlayer.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, this.onTimeChange);
				this.setState(VideoContainerStates.INITIALIZED);
			}
		}
		
		private function onLoaded(event:Event):void
		{	
			this._duration = this.player.mediaPlayer.duration;
			this._bytesLoaded = this.player.mediaPlayer.bytesLoaded;
			CONFIG::DEBUG{
				this.dispatchSimpleEvent("DURATION"+this.duration);
			}
		}
		private function onBitrate(event:PlayerEvent):void
		{
			if(event.params[0])
			{
				this._bitrate = event.params[0];
				CONFIG::DEBUG{
					dispatchSimpleEvent("btr"+this._bitrate);
					dispatchSimpleEvent("BT"+this.bytesTotal);
				}
				if(this.state == VideoContainerStates.INITIALIZED){
					this.player.mediaPlayer.bufferTime = 20;
					setState(VideoContainerStates.READY);
				}
			}
		}
		
		//Subhandlers
		private function onBytesLoaded(event:LoadEvent):void
		{
			if(this.state == VideoContainerStates.INITIALIZED) return; 
			CONFIG::DEBUG{
				this.dispatchSimpleEvent("BL"+event.bytes);
			}
			this._bytesLoaded = event.bytes;
		}
		private function onBytesTotal(event:LoadEvent):void
		{
			if(this.state == VideoContainerStates.INITIALIZED) return; 
			CONFIG::DEBUG{
				this.dispatchSimpleEvent("BT"+event.bytes);
			}
			this._bytesTotal = event.bytes;
			this._bytesOffset = this.bytesTotal > this._bytesTotal ? this.bytesTotal - this._bytesTotal : 0;
			CONFIG::DEBUG{
				this.dispatchSimpleEvent("BO"+this.bytesOffset);
			}
		}
		private function onTimeChange(event:TimeEvent):void
		{
			if(this.state == VideoContainerStates.INITIALIZED) return; 
			CONFIG::DEBUG{
				this.dispatchSimpleEvent("TIME"+event.time);
			}
			this._time = event.time;
		}
		//		private function onDuration(event:WrapperEvent):void
		//		{
		//			this._duration = event.params[0];
		//			this.dispatchSimpleEvent("DURATION"+this.duration);
		//		}
	}
}