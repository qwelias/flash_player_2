package player.osmfexpansion
{
	import flash.external.ExternalInterface;
	
	import org.osmf.elements.AudioElement;
	import org.osmf.elements.F4MElement;
	import org.osmf.elements.F4MLoader;
	import org.osmf.elements.ImageElement;
	import org.osmf.elements.ImageLoader;
	import org.osmf.elements.SWFElement;
	import org.osmf.elements.SWFLoader;
	import org.osmf.elements.SoundLoader;
	import org.osmf.elements.VideoElement;
	import org.osmf.net.NetLoader;
	import org.osmf.net.dvr.DVRCastNetLoader;
	import org.osmf.net.MulticastNetLoader;
	import org.osmf.net.rtmpstreaming.RTMPDynamicStreamingNetLoader;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	//import org.osmf.net.httpstreaming.HTTPStreamingNetLoader;
	import player.osmfexpansion.CustomHTTPStreamingNetLoader;
	import player.events.NNetTargetEvent;
	//import elements.videoplayer.events.DRMMetaEvent;
	import org.osmf.events.LoaderEvent;
	
	import osmf_patch.*;
	
	public class SmoothedMediaFactory extends MediaFactory
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function SmoothedMediaFactory()
		{
			super();
			init();
		}
		
		public function set customToken(val:String):void{
			_customToken = val;
		}
				
		public function init():void
		{
			//httpStreamingNetLoader.httpNetStream.inBufferSeek = true;
			//httpStreamingNetLoader.httpNetStream.backBufferTime = 120;
			if(ExternalInterface.available) ExternalInterface.call("console.log", "SmoothedMediaFactory::init()");
			f4mLoader = new F4MLoader(this);
			addItem 
			( new MediaFactoryItem
				( "org.osmf.elements.f4m"
					, f4mLoader.canHandleResource
					, function():MediaElement
					{
						return new F4MElement(null, f4mLoader);
					}
				)
			);
			
			dvrCastLoader = new DVRCastNetLoader();
			addItem
			( new MediaFactoryItem
				( "org.osmf.elements.video.dvr.dvrcast"
					, dvrCastLoader.canHandleResource
					, function():MediaElement
					{
						var videoElement:VideoElement_p = new VideoElement_p(null, dvrCastLoader);
						videoElement.smoothing = true;
						return videoElement;
					}
				)
			);
			
			httpStreamingNetLoader = new CustomHTTPStreamingNetLoader();
			addItem 
			( new MediaFactoryItem
				( "org.osmf.elements.video.httpstreaming"
					, httpStreamingNetLoader.canHandleResource
					, function():MediaElement
					{
						httpStreamingNetLoader.addEventListener(NNetTargetEvent.SET_NET_TARGET,
							function(evt:NNetTargetEvent)
							{
								httpStreamingNetLoader.httpNetStream.inBufferSeek = true;
								httpStreamingNetLoader.httpNetStream.backBufferTime = 120;
								dispatchEvent(new NNetTargetEvent(NNetTargetEvent.SET_NET_TARGET, evt.httpNetConnection, evt.httpNetStream, true));
							}
						);
						//httpStreamingNetLoader.addEventListener(DRMMetaEvent.DRM_META_GETTING, function(evt:DRMMetaEvent):void{
						//dispatchEvent(new DRMMetaEvent(DRMMetaEvent.DRM_META_GETTING, evt.contentData, true));
						//});
						var videoElement:VideoElement_p = new VideoElement_p(null, httpStreamingNetLoader);
						videoElement.smoothing = true;
						videoElement.customTokenFromPlayer = _customToken;
						return videoElement;
					}
				)
			);
			
			multicastLoader = new MulticastNetLoader();
			addItem
			( new MediaFactoryItem
				( "org.osmf.elements.video.rtmfp.multicast"
					, multicastLoader.canHandleResource
					, function():MediaElement
					{
						var videoElement:VideoElement_p = new VideoElement_p(null, multicastLoader);
						videoElement.smoothing = true;
						return videoElement;
					}
				)
			);
			
			rtmpStreamingNetLoader = new RTMPDynamicStreamingNetLoader();
			addItem
			( new MediaFactoryItem
				( "org.osmf.elements.video.rtmpdynamicStreaming"
					, rtmpStreamingNetLoader.canHandleResource
					, function():MediaElement
					{
						var videoElement:VideoElement_p = new VideoElement_p(null, rtmpStreamingNetLoader);
						videoElement.smoothing = true;
						return videoElement;
					}
				)
			);
			
			netLoader = new NetLoader();
			addItem
			( new MediaFactoryItem
				( "org.osmf.elements.video"
					, netLoader.canHandleResource
					, function():MediaElement
					{
						var videoElement:VideoElement_p = new VideoElement_p(null, netLoader);
						videoElement.smoothing = true;
						return videoElement;
					}
				)
			);		
			
			soundLoader = new SoundLoader();
			addItem
			( new MediaFactoryItem
				( "org.osmf.elements.audio"
					, soundLoader.canHandleResource
					, function():MediaElement
					{
						return new AudioElement(null, soundLoader);
					}
				)
			);
			
			addItem
			( new MediaFactoryItem
				( "org.osmf.elements.audio.streaming"
					, netLoader.canHandleResource
					, function():MediaElement
					{
						return new AudioElement(null, netLoader);
					}
				)
			);
			
			imageLoader = new ImageLoader();
			addItem
			( new MediaFactoryItem
				( "org.osmf.elements.image"
					, imageLoader.canHandleResource
					, function():MediaElement
					{
						return new ImageElement(null, imageLoader);
					}
				)
			);
			
			swfLoader = new SWFLoader();
			addItem
			( new MediaFactoryItem
				( "org.osmf.elements.swf"
					, swfLoader.canHandleResource
					, function():MediaElement
					{
						return new SWFElement(null, swfLoader);
					}
				)
			);
		}
		private var rtmpStreamingNetLoader:RTMPDynamicStreamingNetLoader;
		private var f4mLoader:F4MLoader;
		private var dvrCastLoader:DVRCastNetLoader;
		private var netLoader:NetLoader;
		private var imageLoader:ImageLoader;
		private var swfLoader:SWFLoader;
		private var soundLoader:SoundLoader;
		
		private var httpStreamingNetLoader:CustomHTTPStreamingNetLoader;
		private var multicastLoader:MulticastNetLoader;
		
		private var _customToken:String = "";
	}
}