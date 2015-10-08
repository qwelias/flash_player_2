package ayyo.container
{
	import ayyo.player.AyyoPlayer;
	import ayyo.player.config.impl.support.VideoSettings;
	import ayyo.player.core.model.PlayerCommands;
	import ayyo.player.events.*;

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
		private var _bytesSkipped:uint = 0;
		private var _timeOffset:Number;
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
			var source:Object = {};
			source.url = "http://cdn.ayyo.ru/"+(config.source_id as String)+".f4m";
			source.token = (config.token as String);
//			source.url = "http://cdn.ayyo.ru/u6/68/da/c8255b34-cd6b-40bb-bc44-5926617e8998.f4m";
//			source.token = "begintokensessionid=repow44unrkvrgqffecisuewy9uwd54j,contentid=2418,countrycode=ru,clientkey=6f17269e454fbbd63a1e3e9727ac89:CjZq3ENwpnfcnKvBs2WLXVROgfcendtoken";
			CONFIG::DEBUG{
				trace("--> SOURCE");
				for(var prop:String in source){
					trace(prop," : ",source[prop]);
				}
			}
			var VS:VideoSettings = new VideoSettings();
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
			if(confirmed){
				this.start();
			}else{
				this.stop();
			}
		}

		public function stop():void
		{
			this.player.mediaPlayer.stop();
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
				this._timeOffset = this.time;
				this._bytesSkipped = this._bytesLoaded;
				CONFIG::DEBUG{
					dispatchSimpleEvent("BO"+this.bytesOffset+" BL"+this.bytesLoaded);
				}
				dispatchSimpleEvent(VideoContainerEvents.BUFFERING);
				this.player.mediaPlayer.seek(timeInSeconds);
				if(this.buffering != 0){
					this.buffering = setInterval(this.checkBuffering, 25);
				}
			}
		}
		private function checkBuffering():void
		{
			if(!this.player.mediaPlayer.buffering){
				clearInterval(this.buffering);
				this.buffering = 0;
				dispatchSimpleEvent(VideoContainerEvents.BUFFERED);
			}
		}

		public function setFullscreen(state:Boolean):void
		{
		}

		public function setStageVideoAvailable(available:String, reason:String, stageVideos:Vector.<StageVideo>):void
		{
			CONFIG::DEBUG{
				trace("--> stageVideos availible: ", available, reason, stageVideos.length);
			}
			var stage:Object = {
				stageVideos: stageVideos
			};
			this.player.mediaPlayer.displayObject.dispatchEvent(new WrapperEvent(WrapperEvent.STAGE, [stage]));

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
			return this._bitrate * this._timeOffset / 8 * 1024;
		}

		public function get bytesLoaded():uint
		{
			return this._bytesLoaded - this._bytesSkipped;
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
//				this.player.mediaPlayer.addEventListener(LoadEvent.BYTES_TOTAL_CHANGE, this.onBytesTotal); bytesTotal not working
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
			this._bytesLoaded = event.bytes;
			CONFIG::DEBUG{
				this.dispatchSimpleEvent("ABL"+event.bytes+" BL"+this.bytesLoaded);
			}
		}
//		private function onBytesTotal(event:LoadEvent):void //not in use
//		{
//			if(this.state == VideoContainerStates.INITIALIZED) return;
//			CONFIG::DEBUG{
//				this.dispatchSimpleEvent("BT"+event.bytes);
//			}
//			this._bytesTotal = event.bytes;
//			this._bytesOffset = this.bytesTotal > this._bytesTotal ? this.bytesTotal - this._bytesTotal : 0;
//			CONFIG::DEBUG{
//				this.dispatchSimpleEvent("BO"+this.bytesOffset);
//			}
//		}
		private function onTimeChange(event:TimeEvent):void
		{
			if(this.state == VideoContainerStates.INITIALIZED) return;
			CONFIG::DEBUG{
				this.dispatchSimpleEvent("TIME"+event.time);
			}
			this._time = event.time;
			if(this.duration - this.time <= 0.5){
				this.stop();
			}
		}
	}
}
