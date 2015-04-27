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
	
	import org.osmf.events.MediaErrorEvent;
	
	import ru.yandex.video.IVideoContainer;
	import ru.yandex.video.VideoContainerAPIVersion;
	import ru.yandex.video.VideoContainerEvents;
	import ru.yandex.video.VideoContainerStates;
	
	public class AyyoContainer extends AyyoPlayer implements IVideoContainer
	{		
		private var _state:String = VideoContainerStates.INACTIVE;
		
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
			this.dispatcher.addEventListener(WrapperEvent.PLAYABLE, this.onLoaded);
		}
		
		public function load(config:Object):void
		{	
			trace("-->", "config", config.toString())
			if(this.state == VideoContainerStates.INITIALIZED){
				this.setState(VideoContainerStates.READY);
			}
		}
		
		public function start():void
		{
			this.dispatcher.dispatchEvent(new WrapperEvent(WrapperEvent.PLAY))
			this.setState(VideoContainerStates.START);
			this.setState(VideoContainerStates.VIDEO_PLAYING);
		}
		
		public function setAgeConfirmed(confirmed:Boolean):void
		{
		}
		
		public function stop():void
		{
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
			dispatchSimpleEvent(VideoContainerEvents.MUTED);
		}
		
		public function unmute():void
		{
			dispatchSimpleEvent(VideoContainerEvents.UNMUTED);
		}
		
		public function beginSeek():void
		{
		}
		
		public function endSeek():void
		{
		}
		
		public function seek(timeInSeconds:Number):void
		{
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
			return "test";
		}
		
		public function get state():String
		{
			return this._state;
		}
		
		public function get duration():Number
		{
			return 0;
		}
		
		public function get time():Number
		{
			return 0;
		}
		
		public function get seekAllowed():Boolean
		{
			return false;
		}
		
		public function get volume():Number
		{
			return 0.6;
		}
		
		public function set volume(value:Number):void
		{
			dispatchSimpleEvent(VideoContainerEvents.VOLUME_CHANGE);
		}
		
		public function get bytesTotal():uint
		{
			return 0;
		}
		
		public function get bytesOffset():uint
		{
			return 0;
		}
		
		public function get bytesLoaded():uint
		{
			return 0;
		}
		
		//Handlers
		private function onError(event:Event):void
		{
			this.setState(VideoContainerStates.ERROR);
		}
		private function onLoaded(event:Event):void
		{
			if(this.state == VideoContainerStates.INACTIVE){
				this.setState(VideoContainerStates.INITIALIZED);
			}
			if(this.state == VideoContainerStates.INITIALIZED){
				//this.setState(VideoContainerStates.READY);
			}
		}
		private function onStart(event:Event):void
		{
			this.setState(VideoContainerStates.START);
			this.setState(VideoContainerStates.VIDEO_PLAYING);
		}
		private function onPause(event:Event):void
		{
			this.setState(VideoContainerStates.VIDEO_PAUSED);
		}
		private function onEnd(event:Event):void
		{
			this.setState(VideoContainerStates.VIDEO_ENDED);
			this.setState(VideoContainerStates.END);
		}
	}
}