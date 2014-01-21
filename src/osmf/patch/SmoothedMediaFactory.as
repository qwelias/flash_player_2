package osmf.patch {
	import ayyo.player.events.NNetTargetEvent;

	import org.osmf.elements.AudioElement;
	import org.osmf.elements.F4MElement;
	import org.osmf.elements.F4MLoader;
	import org.osmf.elements.ImageElement;
	import org.osmf.elements.ImageLoader;
	import org.osmf.elements.SWFElement;
	import org.osmf.elements.SWFLoader;
	import org.osmf.elements.SoundLoader;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.net.MulticastNetLoader;
	import org.osmf.net.NetLoader;
	import org.osmf.net.dvr.DVRCastNetLoader;
	import org.osmf.net.rtmpstreaming.RTMPDynamicStreamingNetLoader;

	import flash.external.ExternalInterface;

	public class SmoothedMediaFactory extends MediaFactory {
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function SmoothedMediaFactory() {
			super();
			init();
		}

		public function set customToken(val : String) : void {
			_customToken = val;
		}

		public function init() : void {
			if (ExternalInterface.available) ExternalInterface.call("console.log", "SmoothedMediaFactory::init()");
			this.f4mLoader = new F4MLoader(this);
			var f4mLoaderCreator : Function = function() : MediaElement {
				return new F4MElement(null, f4mLoader);
			};
			this.addItem(new MediaFactoryItem("org.osmf.elements.f4m", this.f4mLoader.canHandleResource, f4mLoaderCreator));

			this.dvrCastLoader = new DVRCastNetLoader();
			var dvrCastLoaderCreator : Function = function() : MediaElement {
				var videoElement : VideoElement = new VideoElement(null, dvrCastLoader);
				videoElement.smoothing = true;
				return videoElement;
			};
			this.addItem(new MediaFactoryItem("org.osmf.elements.video.dvr.dvrcast", this.dvrCastLoader.canHandleResource, dvrCastLoaderCreator));

			this.httpStreamingNetLoader = new CustomHTTPStreamingNetLoader();
			var httpStreamingCreator : Function = function() : MediaElement {
				var setNetTargetHandler : Function = function(evt : NNetTargetEvent) : void {
					httpStreamingNetLoader.httpNetStream.inBufferSeek = true;
					httpStreamingNetLoader.httpNetStream.backBufferTime = 120;
					dispatchEvent(new NNetTargetEvent(NNetTargetEvent.SET_NET_TARGET, evt.httpNetConnection, evt.httpNetStream, true));
				};
				httpStreamingNetLoader.addEventListener(NNetTargetEvent.SET_NET_TARGET, setNetTargetHandler);
				var videoElement : VideoElement = new VideoElement(null, httpStreamingNetLoader);
				videoElement.smoothing = true;
				videoElement.customTokenFromPlayer = _customToken;
				return videoElement;
			};
			this.addItem(new MediaFactoryItem("org.osmf.elements.video.httpstreaming", this.httpStreamingNetLoader.canHandleResource, httpStreamingCreator));

			this.multicastLoader = new MulticastNetLoader();
			var multicastCreator : Function = function() : MediaElement {
				var videoElement : VideoElement = new VideoElement(null, multicastLoader);
				videoElement.smoothing = true;
				return videoElement;
			};
			this.addItem(new MediaFactoryItem("org.osmf.elements.video.rtmfp.multicast", this.multicastLoader.canHandleResource, multicastCreator));

			this.rtmpStreamingNetLoader = new RTMPDynamicStreamingNetLoader();
			var rtmpCreator : Function = function() : MediaElement {
				var videoElement : VideoElement = new VideoElement(null, rtmpStreamingNetLoader);
				videoElement.smoothing = true;
				return videoElement;
			};
			this.addItem(new MediaFactoryItem("org.osmf.elements.video.rtmpdynamicStreaming", this.rtmpStreamingNetLoader.canHandleResource, rtmpCreator));

			this.netLoader = new NetLoader();
			var netLoaderCreator : Function = function() : MediaElement {
				var videoElement : VideoElement = new VideoElement(null, netLoader);
				videoElement.smoothing = true;
				return videoElement;
			};
			this.addItem(new MediaFactoryItem("org.osmf.elements.video", this.netLoader.canHandleResource, netLoaderCreator));

			this.soundLoader = new SoundLoader();
			var soundCreator : Function = function() : MediaElement {
				return new AudioElement(null, soundLoader);
			};
			this.addItem(new MediaFactoryItem("org.osmf.elements.audio", this.soundLoader.canHandleResource, soundCreator));

			var netAudioCreator : Function = function() : MediaElement {
				return new AudioElement(null, netLoader);
			};
			this.addItem(new MediaFactoryItem("org.osmf.elements.audio.streaming", this.netLoader.canHandleResource, netAudioCreator));

			this.imageLoader = new ImageLoader();
			var imageCreator : Function = function() : MediaElement {
				return new ImageElement(null, imageLoader);
			};
			this.addItem(new MediaFactoryItem("org.osmf.elements.image", this.imageLoader.canHandleResource, imageCreator));

			this.swfLoader = new SWFLoader();
			var swfCreator : Function = function() : MediaElement {
				return new SWFElement(null, swfLoader);
			};
			this.addItem(new MediaFactoryItem("org.osmf.elements.swf", this.swfLoader.canHandleResource, swfCreator));
		}

		private var rtmpStreamingNetLoader : RTMPDynamicStreamingNetLoader;
		private var f4mLoader : F4MLoader;
		private var dvrCastLoader : DVRCastNetLoader;
		private var netLoader : NetLoader;
		private var imageLoader : ImageLoader;
		private var swfLoader : SWFLoader;
		private var soundLoader : SoundLoader;
		private var httpStreamingNetLoader : CustomHTTPStreamingNetLoader;
		private var multicastLoader : MulticastNetLoader;
		private var _customToken : String = "";
	}
}