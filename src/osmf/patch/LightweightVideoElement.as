/*****************************************************
 *  
 *  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
 *  
 *****************************************************
 *  The contents of this file are subject to the Mozilla Public License
 *  Version 1.1 (the "License"); you may not use this file except in
 *  compliance with the License. You may obtain a copy of the License at
 *  http://www.mozilla.org/MPL/
 *   
 *  Software distributed under the License is distributed on an "AS IS"
 *  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *  License for the specific language governing rights and limitations
 *  under the License.
 *   
 *  
 *  The Initial Developer of the Original Code is Adobe Systems Incorporated.
 *  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
 *  Incorporated. All Rights Reserved. 
 *  
 *****************************************************/
// Rustem OK
package osmf.patch {
	import flash.events.DRMErrorEvent;
	import flash.events.DRMStatusEvent;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.StatusEvent;
	import flash.media.Video;
	import flash.net.NetStream;
	import flash.net.drm.DRMContentData;
	import flash.system.SystemUpdater;
	import flash.system.SystemUpdaterType;
	import flash.utils.ByteArray;
	
	import org.osmf.events.DRMEvent;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.DefaultTraitResolver;
	import org.osmf.media.LoadableElementBase;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.media.videoClasses.VideoSurface;
	import org.osmf.metadata.CuePoint;
	import org.osmf.metadata.Metadata;
	import org.osmf.metadata.MetadataNamespaces;
	import org.osmf.metadata.TimelineMetadata;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.net.ModifiableTimeTrait;
	import org.osmf.net.NetClient;
	import org.osmf.net.NetConnectionCodes;
	import org.osmf.net.NetLoader;
	import org.osmf.net.NetStreamAlternativeAudioTrait;
	import org.osmf.net.NetStreamAudioTrait;
	import org.osmf.net.NetStreamBufferTrait;
	import org.osmf.net.NetStreamCodes;
	import org.osmf.net.NetStreamDisplayObjectTrait;
	import org.osmf.net.NetStreamDynamicStreamTrait;
	import org.osmf.net.NetStreamLoadTrait;
	import org.osmf.net.NetStreamPlayTrait;
	import org.osmf.net.NetStreamSeekTrait;
	import org.osmf.net.NetStreamTimeTrait;
	import org.osmf.net.NetStreamUtils;
	import org.osmf.net.StreamType;
	import org.osmf.net.StreamingURLResource;
	import org.osmf.traits.AlternativeAudioTrait;
	import org.osmf.traits.AudioTrait;
	import org.osmf.traits.BufferTrait;
	import org.osmf.traits.DRMState;
	import org.osmf.traits.DVRTrait;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.DynamicStreamTrait;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.SeekTrait;
	import org.osmf.traits.TimeTrait;
	import org.osmf.utils.OSMFSettings;
	import org.osmf.utils.OSMFStrings;

	/**
	 * LightweightVideoElement is a media element specifically created for video playback.
	 * It supports both streaming and progressive formats.
	 *
	 * <p>LightweightVideoElement is a lightweight alternative to VideoElement.  Whereas
	 * LightweightVideoElement supports only a subset of video delivery modes (specifically
	 * progressive and simple RTMP streaming), VideoElement supports all video delivery
	 * modes.</p>   
	 * 
	 * <p>The LightweightVideoElement uses a NetLoader class to load and unload its media.
	 * Developers requiring custom loading logic for video
	 * can pass their own loaders to the LightweightVideoElement constructor. 
	 * These loaders should subclass NetLoader.</p>
	 * <p>The basic steps for creating and using a LightweightVideoElement are:
	 * <ol>
	 * <li>Create a new URLResource pointing to the URL of the video stream or file
	 * containing the video to be loaded.</li>
	 * <li>Create a new NetLoader.</li>
	 * <li>Create the new LightweightVideoElement, 
	 * passing the NetLoader and URLResource
	 * as parameters.</li>
	 * <li>Create a new MediaPlayer.</li>
	 * <li>Assign the LightweightVideoElement to the MediaPlayer's <code>media</code> property.</li>
	 * <li>Control the media using the MediaPlayer's methods, properties, and events.</li>
	 * <li>When done with the LightweightVideoElement, set the MediaPlayer's <code>media</code>  
	 * property to null.  This will unload the LightweightVideoElement.</li>
	 * </ol>
	 * </p>
	 * 
	 * <p>The LightweightVideoElement supports Flash Media Token Authentication,  
	 * for passing authentication tokens through the NetConnection.</p>
	 *
	 * <p>The LightweightVideoElement has support for the Flash Player's DRM implementation.
	 * Note that the <code>startDate</code>, <code>endDate</code>, and <code>period</code>
	 * properties of the DRMTrait on this element correspond to the voucher validity before
	 * playback starts.  Once playback begins, these properties correspond to the playback
	 * time window (as found on flash.net.drm.DRMVoucher).</p>
	 * 
	 * @includeExample LightweightVideoElementExample.as -noswf
	 * 
	 * @see org.osmf.elements.VideoElement
	 * @see org.osmf.media.URLResource
	 * @see org.osmf.media.MediaElement
	 * @see org.osmf.media.MediaPlayer
	 * @see org.osmf.net.NetLoader
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0	 	 	
	 **/
	public class LightweightVideoElement extends LoadableElementBase {
		/**
		 * @private
		 */
		private var timeTrait : TimeTrait;
		/**
		 * @private
		 */
		private var seekTrait : SeekTrait;
		/**
		 * Constructor.
		 * 
		 * @param resource URLResource that points to the video source that the LightweightVideoElement
		 * will use.  For dynamic streaming content, use a DynamicStreamingResource.
		 * @param loader NetLoader used to load the video.  If null, then a NetLoader will
		 * be used.
		 * 
		 * @throws ArgumentError If resource is not an URLResource. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function LightweightVideoElement(resource : MediaResourceBase = null, loader : NetLoader = null) {
			if (loader == null) {
				loader = new NetLoader();
			}

			super(resource, loader);

			if (!(resource == null || resource is URLResource)) {
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
		}

		/**
		 * The NetClient used by this object's NetStream.  Will be null until this 
		 * object has been loaded (as indicated by its LoadTrait entering the READY
		 * state).
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get client() : NetClient {
			return stream != null ? stream.client as NetClient : null;
		}

		/**
		 * Defines the duration that the element's TimeTrait will expose until the
		 * element's content is loaded.
		 * 
		 * Setting this property to a positive value results in the element becoming
		 * temporal. Any other value will remove the element's TimeTrait, unless the
		 * loaded content is exposing a duration. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get defaultDuration() : Number {
			return defaultTimeTrait ? defaultTimeTrait.duration : NaN;
		}

		public function set defaultDuration(value : Number) : void {
			if (isNaN(value) || value < 0) {
				if (defaultTimeTrait != null) {
					// Remove the default trait if the default duration
					// gets set to not a number:
					removeTraitResolver(MediaTraitType.TIME);
					defaultTimeTrait = null;
				}
			} else {
				if (defaultTimeTrait == null) {
					// Add the default trait if when default duration
					// gets set:
					defaultTimeTrait = new ModifiableTimeTrait();
					addTraitResolver(MediaTraitType.TIME, new DefaultTraitResolver(MediaTraitType.TIME, defaultTimeTrait));
				}

				defaultTimeTrait.duration = value;
			}
		}

		/**
		 * Specifies whether the video should be smoothed (interpolated) when it is scaled. 
		 * For smoothing to work, the runtime must be in high-quality mode (the default). 
		 * The default value is false (no smoothing).  Set this property to true to take
		 * advantage of mipmapping image optimization.
		 * 
		 * @see flash.media.Video
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 **/
		public function get smoothing() : Boolean {
			return _smoothing;
		}

		public function set smoothing(value : Boolean) : void {
			_smoothing = value;
			if (videoSurface != null) {
				// videoSurface.smoothing = value;
			}
		}

		/**
		 * Indicates the type of filter applied to decoded video as part of post-processing. The
		 * default value is 0, which lets the video compressor apply a deblocking filter as needed.
		 * See flash.media.Video for more information on deblocking modes.
		 * 
		 * @see flash.media.Video
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get deblocking() : int {
			return _deblocking;
		}

		public function set deblocking(value : int) : void {
			_deblocking = value;
			if (videoSurface != null) {
				// videoSurface.deblocking = value;
			}
		}

		/**
		 * The number of frames per second being displayed.  Will be zero until
		 * the video is loaded and playing.
		 **/
		public function get currentFPS() : Number {
			return stream != null ? stream.currentFPS : 0;
		}

		// Overrides
		//
		/**
		 * @private
		 */
		override protected function createLoadTrait(resource : MediaResourceBase, loader : LoaderBase) : LoadTrait {
			return new NetStreamLoadTrait(loader, resource);
		}

		/**
		 * @private
		 */
		protected function createVideo() : Video {
			return new Video();
		}

		/**
		 * @private
		 */
		override protected function processReadyState() : void {
			// var loadTrait:*;
			// var _DRM_ContentData:* = null;
			if (!this.stream) {
				var loadTrait : NetStreamLoadTrait = getTrait(MediaTraitType.LOAD) as NetStreamLoadTrait;
				stream = loadTrait.netStream;

				// Set the video's dimensions so that it doesn't appear at the wrong size.
				// We'll set the correct dimensions once the metadata is loaded.  (FM-206)
				this.dispatchEvent(new Event("BEFORE_VIDEOSURFACE"));
				videoSurface = new VideoSurface(OSMFSettings.enableStageVideo, createVideo);
				videoSurface.smoothing = _smoothing;
				videoSurface.deblocking = _deblocking;
				videoSurface.width = videoSurface.height = 0;

				videoSurface.attachNetStream(stream);

				// Hook up our metadata listeners
				NetClient(stream.client).addHandler(NetStreamCodes.ON_META_DATA, onMetaData);
				NetClient(stream.client).addHandler(NetStreamCodes.ON_CUE_POINT, onCuePoint);

				stream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatusEvent);
				loadTrait.connection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatusEvent, false, 0, true);

				CONFIG::FLASH_10_1 {
					// Listen for all errors
					stream.addEventListener(DRMErrorEvent.DRM_ERROR, onDRMErrorEvent);

					// Rustem
					var _DRM_ContentData : ByteArray = this.getDRMContentData(resource);
					if (!(_DRM_ContentData == null) && _DRM_ContentData.bytesAvailable > 0) {
						this.setupDRMTrait(_DRM_ContentData);
					} else {
						this.stream.addEventListener(flash.events.StatusEvent.STATUS, this.onStatus);
						this.stream.addEventListener(flash.events.DRMStatusEvent.DRM_STATUS, this.onDRMStatus);
					}
					// Rustem/
				
					// Check for DRMContentData
					/*var streamingResource:StreamingURLResource = resource as StreamingURLResource;
					if (streamingResource != null 
					&& streamingResource.drmContentData)
					{
					var metadata:ByteArray = streamingResource.drmContentData;
					setupDRMTrait(metadata);					    				 			
					}
					else
					{
					// Non sidecar, we need to play before getting access to the DRMTrait.
					stream.addEventListener(StatusEvent.STATUS, onStatus);
					stream.addEventListener(DRMStatusEvent.DRM_STATUS, onDRMStatus);
					}*/
				}
				finishLoad();
			}
		}

		// Rustem
		private function removeAllTraits() : void {
			if (hasTrait(org.osmf.traits.MediaTraitType.DVR)) {
				removeTrait(org.osmf.traits.MediaTraitType.DVR);
			}
			if (hasTrait(org.osmf.traits.MediaTraitType.AUDIO)) {
				removeTrait(org.osmf.traits.MediaTraitType.AUDIO);
			}
			if (hasTrait(org.osmf.traits.MediaTraitType.BUFFER)) {
				removeTrait(org.osmf.traits.MediaTraitType.BUFFER);
			}
			if (hasTrait(org.osmf.traits.MediaTraitType.TIME)) {
				removeTrait(org.osmf.traits.MediaTraitType.TIME);
			}
			if (hasTrait(org.osmf.traits.MediaTraitType.DISPLAY_OBJECT)) {
				removeTrait(org.osmf.traits.MediaTraitType.DISPLAY_OBJECT);
			}
			if (hasTrait(org.osmf.traits.MediaTraitType.PLAY)) {
				removeTrait(org.osmf.traits.MediaTraitType.PLAY);
			}
			if (hasTrait(org.osmf.traits.MediaTraitType.SEEK)) {
				removeTrait(org.osmf.traits.MediaTraitType.SEEK);
			}
			if (hasTrait(org.osmf.traits.MediaTraitType.DYNAMIC_STREAM)) {
				removeTrait(org.osmf.traits.MediaTraitType.DYNAMIC_STREAM);
			}
			if (hasTrait(org.osmf.traits.MediaTraitType.ALTERNATIVE_AUDIO)) {
				removeTrait(org.osmf.traits.MediaTraitType.ALTERNATIVE_AUDIO);
			}
			return;
		}

		// Rustem/
		private function finishLoad() : void {
			// Rustem
			// var dvrTrait:org.osmf.traits.MediaTraitBase;
			// var audioTrait:org.osmf.traits.MediaTraitBase;
			// var bufferTrait:org.osmf.traits.BufferTrait;
			// var timeTrait:org.osmf.traits.TimeTrait;
			// var displayObjectTrait:org.osmf.traits.DisplayObjectTrait;
			// var playTrait:org.osmf.traits.PlayTrait;
			// var seekTrait:org.osmf.traits.SeekTrait;
			// var dsResource:org.osmf.net.DynamicStreamingResource;
			// var sResource:org.osmf.net.StreamingURLResource;
			// var loadTrait:org.osmf.net.NetStreamLoadTrait;
			// var reconnectStreams:Boolean;
			// var onDurationChange:Function;
			// var dsTrait:org.osmf.traits.MediaTraitBase;
			// var aaTrait:org.osmf.traits.AlternativeAudioTrait;

			// var loc1:*;
			try {
				var loadTrait : NetStreamLoadTrait = getTrait(MediaTraitType.LOAD) as NetStreamLoadTrait;
				// loadTrait = getTrait(org.osmf.traits.MediaTraitType.LOAD) as org.osmf.net.NetStreamLoadTrait;
			} catch (err : Error) {
			}
			;
			// Rustem/

			// var loadTrait:NetStreamLoadTrait = getTrait(MediaTraitType.LOAD) as NetStreamLoadTrait;

			// setup dvr trait
			if (loadTrait) {
				if (!this.hasTrait(MediaTraitType.DVR)) {
					var dvrTrait : MediaTraitBase = loadTrait.getTrait(MediaTraitType.DVR) as DVRTrait;
					if (dvrTrait != null) {
						addTrait(MediaTraitType.DVR, dvrTrait);
					}
				}

				// setup audio trait
				if (!this.hasTrait(MediaTraitType.AUDIO)) {
					var audioTrait : MediaTraitBase = loadTrait.getTrait(MediaTraitType.AUDIO) as AudioTrait;
					// audioTrait = loadTrait.getTrait(MediaTraitType.AUDIO) as AudioTrait;
					if (audioTrait == null) {
						audioTrait = new NetStreamAudioTrait(stream);
					}
					addTrait(MediaTraitType.AUDIO, audioTrait);
				}

				// setup buffer trait
				if (!this.hasTrait(MediaTraitType.BUFFER)) {
					var bufferTrait : BufferTrait = loadTrait.getTrait(MediaTraitType.BUFFER) as BufferTrait;
					if (bufferTrait == null) {
						bufferTrait = new NetStreamBufferTrait(stream);
					}
					addTrait(MediaTraitType.BUFFER, bufferTrait);
				}

				// setup time trait
				this.hasTrait(MediaTraitType.TIME) && this.removeTrait(MediaTraitType.TIME);
				this.timeTrait = loadTrait.getTrait(MediaTraitType.TIME) as TimeTrait;
				if (timeTrait == null) {
					timeTrait = new NetStreamTimeTrait(stream, loadTrait.resource, defaultDuration);
				}
				addTrait(MediaTraitType.TIME, timeTrait);

				// setup display object trait
				if (!this.hasTrait(MediaTraitType.DISPLAY_OBJECT)) {
					var displayObjectTrait : DisplayObjectTrait = loadTrait.getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
					if (displayObjectTrait == null) {
						displayObjectTrait = new NetStreamDisplayObjectTrait(stream, videoSurface, NaN, NaN);
					}
					addTrait(MediaTraitType.DISPLAY_OBJECT, displayObjectTrait);
				}

				// setup play trait
				if (!this.hasTrait(MediaTraitType.PLAY)) {
					var playTrait : PlayTrait = loadTrait.getTrait(MediaTraitType.PLAY) as PlayTrait;
					// playTrait = loadTrait.getTrait(MediaTraitType.PLAY) as PlayTrait;
					if (playTrait == null) {
						var reconnectStreams : Boolean = false;
						CONFIG::FLASH_10_1 {
							reconnectStreams = (loader as NetLoader).reconnectStreams;
						}
						playTrait = new NetStreamPlayTrait(stream, resource, reconnectStreams, loadTrait.connection);
					}
					addTrait(MediaTraitType.PLAY, playTrait);
				}

				// setup seek trait
				if (!this.hasTrait(MediaTraitType.SEEK)) {
					this.seekTrait = loadTrait.getTrait(MediaTraitType.SEEK) as SeekTrait;
					if (seekTrait == null && NetStreamUtils.getStreamType(resource) != StreamType.LIVE) {
						seekTrait = new NetStreamSeekTrait(timeTrait, loadTrait, stream, videoSurface);
					}
					if (seekTrait != null) {
						// Only add the SeekTrait if/when the TimeTrait has a duration,
						// otherwise the user might try to seek when a seek cannot actually
						// be executed (FM-440).
						if (isNaN(timeTrait.duration) || timeTrait.duration == 0) {
							timeTrait.addEventListener(TimeEvent.DURATION_CHANGE, this.onDurationChange);
						} else {
							addTrait(MediaTraitType.SEEK, seekTrait);
						}
					}
				}

				// setup dynamic resource trait
				if (!this.hasTrait(MediaTraitType.DYNAMIC_STREAM)) {
					var dsResource : DynamicStreamingResource = resource as DynamicStreamingResource;
					// dsResource = resource as DynamicStreamingResource;
					if (dsResource != null && loadTrait.switchManager != null) {
						var dsTrait : MediaTraitBase = loadTrait.getTrait(MediaTraitType.DYNAMIC_STREAM) as DynamicStreamTrait;
						if (dsTrait == null) {
							dsTrait = new NetStreamDynamicStreamTrait(stream, loadTrait.switchManager, dsResource);
						}
						addTrait(MediaTraitType.DYNAMIC_STREAM, dsTrait);
					}
				}

				/*
				// setup alternative audio trait (OSMF v1.6)
				var sResource:StreamingURLResource = resource as StreamingURLResource;
				// sResource = resource as StreamingURLResource;
				if (sResource != null && sResource.alternativeAudioItems != null && sResource.alternativeAudioItems.length > 0)
				{
				var aaTrait:AlternativeAudioTrait = loadTrait.getTrait(MediaTraitType.ALTERNATIVE_AUDIO) as AlternativeAudioTrait;
				// aaTrait = loadTrait.getTrait(MediaTraitType.ALTERNATIVE_AUDIO) as AlternativeAudioTrait;
				if (aaTrait == null)
				{
				aaTrait = new NetStreamAlternativeAudioTrait(stream, sResource);
				}
				addTrait(MediaTraitType.ALTERNATIVE_AUDIO, aaTrait);
				}*/

				// setup alternative audio trait (OSMF v2.0)
				if (!this.hasTrait(MediaTraitType.ALTERNATIVE_AUDIO)) {
					var sResource : StreamingURLResource = resource as StreamingURLResource;
					if (sResource != null && sResource.alternativeAudioStreamItems != null && sResource.alternativeAudioStreamItems.length > 0) {
						var aaTrait : AlternativeAudioTrait = loadTrait.getTrait(MediaTraitType.ALTERNATIVE_AUDIO) as AlternativeAudioTrait;
						if (aaTrait == null) {
							aaTrait = new NetStreamAlternativeAudioTrait(stream, sResource);
						}
						addTrait(MediaTraitType.ALTERNATIVE_AUDIO, aaTrait);
					}
				}
			}
		}

		private function onDurationChange(event : TimeEvent) : void {
			timeTrait.removeEventListener(TimeEvent.DURATION_CHANGE, this.onDurationChange);
			// Rustem
			try {
				addTrait(MediaTraitType.SEEK, this.seekTrait);
			} catch (err : Error) {
			}
		}

		override protected function processUnloadingState() : void {
			var loadTrait : NetStreamLoadTrait = getTrait(MediaTraitType.LOAD) as NetStreamLoadTrait;

			NetClient(stream.client).removeHandler(NetStreamCodes.ON_META_DATA, onMetaData);

			stream.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatusEvent);
			loadTrait.connection.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatusEvent);

			removeTrait(MediaTraitType.AUDIO);
			removeTrait(MediaTraitType.BUFFER);
			removeTrait(MediaTraitType.PLAY);
			removeTrait(MediaTraitType.TIME);
			removeTrait(MediaTraitType.DISPLAY_OBJECT);
			removeTrait(MediaTraitType.SEEK);
			removeTrait(MediaTraitType.DYNAMIC_STREAM);
			removeTrait(MediaTraitType.DVR);

			CONFIG::FLASH_10_1 {
				stream.removeEventListener(DRMErrorEvent.DRM_ERROR, onDRMErrorEvent);
				stream.removeEventListener(DRMStatusEvent.DRM_STATUS, onDRMStatus);
				stream.removeEventListener(StatusEvent.STATUS, onStatus);
				if (drmTrait != null) {
					drmTrait.removeEventListener(DRMEvent.DRM_STATE_CHANGE, reloadAfterAuth);
					removeTrait(MediaTraitType.DRM);
					drmTrait = null;
				}  					
			}

			// Null refs to garbage collect.
			videoSurface.attachNetStream(null);
			videoSurface = null;
			stream = null;
			displayObjectTrait = null;
		}

		private function onMetaData(info : Object) : void {
			var cuePoints : Array = info["cuePoints"] as Array;

			if (cuePoints != null && cuePoints.length > 0) {
				var dynamicCuePoints : TimelineMetadata = getMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE) as TimelineMetadata;
				if (dynamicCuePoints == null) {
					dynamicCuePoints = new TimelineMetadata(this);
					addMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE, dynamicCuePoints);
				}

				for (var i : int = 0; i < cuePoints.length; i++) {
					var cuePoint : CuePoint = new CuePoint(cuePoints[i]["type"], cuePoints[i]["time"], cuePoints[i]["name"], cuePoints[i]["parameters"]);

					try {
						dynamicCuePoints.addMarker(cuePoint);
					} catch (error : ArgumentError) {
						// Invalid cue points should be ignored.
					}
				}
			}
		}

		private function onCuePoint(info : Object) : void {
			if (embeddedCuePoints == null) {
				embeddedCuePoints = new TimelineMetadata(this);
				addMetadata(CuePoint.EMBEDDED_CUEPOINTS_NAMESPACE, embeddedCuePoints);
			}

			var cuePoint : CuePoint = new CuePoint(info["type"], info["time"], info["name"], info["parameters"]);

			try {
				embeddedCuePoints.addMarker(cuePoint);
			} catch (error : ArgumentError) {
				// Invalid cue points should be ignored.
			}
		}

		// Fired when the DRM subsystem is updated.  NetStream needs to be recreated.
		private function onUpdateComplete(event : Event) : void {
			(getTrait(MediaTraitType.LOAD) as LoadTrait).unload();
			(getTrait(MediaTraitType.LOAD) as LoadTrait).load();
		}

		private function onNetStatusEvent(event : NetStatusEvent) : void {
			var error : MediaError = null;
			switch (event.info["code"]) {
				case NetStreamCodes.NETSTREAM_PLAY_FAILED:
				case NetStreamCodes.NETSTREAM_FAILED:
					error = new MediaError(MediaErrorCodes.NETSTREAM_PLAY_FAILED, event.info["description"]);
					break;
				case NetStreamCodes.NETSTREAM_PLAY_STREAMNOTFOUND:
					error = new MediaError(MediaErrorCodes.NETSTREAM_STREAM_NOT_FOUND, event.info["description"]);
					break;
				case NetStreamCodes.NETSTREAM_PLAY_FILESTRUCTUREINVALID:
					error = new MediaError(MediaErrorCodes.NETSTREAM_FILE_STRUCTURE_INVALID, event.info["description"]);
					break;
				case NetStreamCodes.NETSTREAM_PLAY_NOSUPPORTEDTRACKFOUND:
					error = new MediaError(MediaErrorCodes.NETSTREAM_NO_SUPPORTED_TRACK_FOUND, event.info["description"]);
					break;
				case NetConnectionCodes.CONNECT_IDLE_TIME_OUT:
					error = new MediaError(MediaErrorCodes.NETCONNECTION_TIMEOUT, event.info["description"]);
					break;
			}

			CONFIG::FLASH_10_1 {
				if (event.info["code"] == NetStreamCodes.NETSTREAM_DRM_UPDATE) {
					update(SystemUpdaterType.DRM);
				}
			}

			if (error != null) {
				dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, error));
			}
		}

		private function onDRMErrorEvent(event : DRMErrorEvent) : void {
			if (event.errorID == DRM_NEEDS_AUTHENTICATION)  // Needs authentication
			{
				drmTrait.addEventListener(DRMEvent.DRM_STATE_CHANGE, reloadAfterAuth);
				drmTrait.drmMetadata = event.contentData;
			} else if (event.drmUpdateNeeded) {
				update(SystemUpdaterType.DRM);
			} else if (event.systemUpdateNeeded) {
				update(SystemUpdaterType.SYSTEM);
			} else // Inline DRM - Errors need to be forwarded
			{
				drmTrait.inlineDRMFailed(new MediaError(event.errorID));
			}
		}

		private function update(type : String) : void {
			if (drmTrait == null) {
				createDRMTrait();
			}
			var updater : SystemUpdater = drmTrait.update(type);
			updater.addEventListener(Event.COMPLETE, onUpdateComplete);
		}

		// Rustem
		private function setupDRMTrait(arg1 : flash.utils.ByteArray) : void {
			this.createDRMTrait();
			this.drmTrait.drmMetadata = arg1;
			return;
		}

		private function getDRMContentData(arg1 : MediaResourceBase) : ByteArray {
			// var loc2:*=null;
			// var loc3:*=null;
			// var loc4:*=null;
			// var loc5:*=null;
			// var loc6:*=null;
			// var loc7:*=0;
			// var loc8:*=null;
			var loc1 : StreamingURLResource = arg1 as StreamingURLResource;
			if (loc1 == null) {
				if (this._customDRMData != null) {
					return this._customDRMData;
				}
			} else {
				if (loc1.drmContentData != null) {
					return loc1.drmContentData;
				}
				var loc2 : Metadata = arg1.getMetadataValue(MetadataNamespaces.DRM_METADATA) as Metadata;
				if (!(loc2 == null) && loc2.keys.length > 0) {
					var loc3 : * = null;
					var loc4 : DynamicStreamingResource = arg1 as DynamicStreamingResource;
					if (!(loc4 == null) && loc4.initialIndex > -1 && loc4.initialIndex < loc4.streamItems.length) {
						loc3 = loc4.streamItems[loc4.initialIndex].streamName;
					}
					var loc5 : * = null;
					if (loc3 != null) {
						loc5 = loc2.getValue(loc3) as flash.utils.ByteArray;
					}
					if (loc5 == null) {
						var loc6 : Vector.<String> = loc2.keys;
						var loc7 : int = 0;
						do {
							if (loc6[loc7].indexOf(MetadataNamespaces.DRM_ADDITIONAL_HEADER_KEY) != 0) {
								loc5 = loc2.getValue(loc6[loc7]);
							}
							++loc7;
						} while (loc5 == null && loc7 < loc6.length);
					}
					return loc5;
				}
			}
			return null;
		}
		// Rustem/
		// DRM APIs
		CONFIG::FLASH_10_1 {
			private function onStatus(event : StatusEvent) : void {
				if (event.code == DRM_STATUS_CODE && getTrait(MediaTraitType.DRM) == null) {
					createDRMTrait();
				}
			}

			public function onVoucherLoaded(arg1 : flash.events.DRMStatusEvent) : void {
				this.createDRMTrait();
				this.drmTrait.inlineOnVoucher(arg1);
				return;
			}

			private function onDRMStatus(event : DRMStatusEvent) : void {
				// Rustem
				// Rustem/
				drmTrait.inlineOnVoucher(event);
			}

			// Inline metadata + credentials.  The NetStream is dead at this point, restart with new credentials
			private function reloadAfterAuth(event : DRMEvent) : void {
				if (drmTrait.drmState == DRMState.AUTHENTICATION_COMPLETE) {
					var loadTrait : NetStreamLoadTrait = getTrait(MediaTraitType.LOAD) as NetStreamLoadTrait;
					if (loadTrait.loadState == LoadState.READY) {
						loadTrait.unload();
					}
					loadTrait.load();
				}
			}

			// Rustem
			public function customDRMData(arg1 : flash.utils.ByteArray) : void {
				this._customDRMData = arg1;
				return;
			}

			public function customToken(arg1 : String) : void {
				this._customToken = arg1;
				return;
			}

			// Rustem/
			private function createDRMTrait() : void {
				// Rustem
				drmTrait = new NetStreamDRMTrait();
				this.drmTrait.customToken = this._customToken;
				addTrait(MediaTraitType.DRM, drmTrait);
				// Rustem
			}

			public function customSetupDRMTrait(arg1 : flash.net.drm.DRMContentData) : void {
				this.createDRMTrait();
				this.drmTrait.drmMetadata = arg1;
				this.removeAllTraits();
				this.finishLoad();
			}
			/*private function setupDRMTrait(contentData:ByteArray):void
			{			
			createDRMTrait();
			drmTrait.drmMetadata = contentData;
			}*/
			
			
			
		}
		private var displayObjectTrait : DisplayObjectTrait;
		private var defaultTimeTrait : ModifiableTimeTrait;
		private var _customDRMData : ByteArray;
		// Rustem
		private var embeddedCuePoints : TimelineMetadata;
		private var _smoothing : Boolean;
		private var _deblocking : int;
		private var stream : NetStream;
		// Rustem
		private var videoSurface : VideoSurface;
		private var _customToken : String = "";
		// Rustem
		CONFIG::FLASH_10_1 {
			private static const DRM_STATUS_CODE : String = "DRM.encryptedFLV";
			private static const DRM_NEEDS_AUTHENTICATION : int = 3330;
			private var drmTrait : NetStreamDRMTrait;	
		}
	}
}
