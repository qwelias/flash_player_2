package ayyo.player.plugins.subtitles.impl {
	import ayyo.player.config.impl.support.PluginMetadata;

	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaFactoryItemType;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfo;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.utils.OSMFStrings;

	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class SubtitlesInfo extends PluginInfo {
		/**
		 * @private
		 */
		private var urlLoader : URLLoader;
		/**
		 * @private
		 */
		private var canHandle : Boolean;
		/**
		 * @private
		 */
		private var _subtitles : Vector.<Subtitle>;
		/**
		 * @private
		 */
		private var _elements : Vector.<SubtitlesProxyElement>;
		/**
		 * @private
		 */
		private var isSubitlesParsed : Boolean;
		/**
		 * @private
		 */
		private var container : DisplayObjectContainer;

		public function SubtitlesInfo() {
			var items : Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
			var item : MediaFactoryItem = new MediaFactoryItem("ayyo.player.plugin.subtitles", this.canHandleResourceFunction, this.mediaElementCreationFunction, MediaFactoryItemType.PROXY);
			items.push(item);
			super(items, mediaElementCreated);
		}

		private function mediaElementCreated(element : MediaElement) : void {
			trace("SubtitlesInfo.mediaElementCreated(element)");
			trace('element: ' + (element));
		}

		override public function initializePlugin(resource : MediaResourceBase) : void {
			super.initializePlugin(resource);
			// TODO if metadata is missing, log error.
			if (resource.getMetadataValue(PluginMetadata.CONFIG) == null) throw new ArgumentError(OSMFStrings.INVALID_PARAM, 8701);
			if (resource.getMetadataValue(PluginMetadata.CONTAINER) == null) throw new ArgumentError(OSMFStrings.INVALID_PARAM, 7201);
			else this.canHandle = true;
			var subtitlesURL : String = resource.getMetadataValue(PluginMetadata.CONFIG) as String;
			this.container = resource.getMetadataValue(PluginMetadata.CONTAINER) as DisplayObjectContainer;
			this.createLoader();
			this.urlLoader.load(new URLRequest(subtitlesURL));
		}

		public function get subtitles() : Vector.<Subtitle> {
			return this._subtitles ||= new Vector.<Subtitle>();
		}

		public function get elements() : Vector.<SubtitlesProxyElement> {
			return this._elements ||= new Vector.<SubtitlesProxyElement>();
		}

		private function canHandleResourceFunction(resourse : MediaResourceBase) : Boolean {
			return resourse is DynamicStreamingResource && this.canHandle;
		}

		private function mediaElementCreationFunction() : MediaElement {
			var element : SubtitlesProxyElement = new SubtitlesProxyElement();
			this.elements.push(element);
			this.isSubitlesParsed && element.initialize(this.subtitles);
			this.container && (element.subContainer = this.container);
			return element;
		}

		private function createLoader() : void {
			if (!this.urlLoader) {
				this.urlLoader = new URLLoader();
				this.urlLoader.addEventListener(Event.COMPLETE, this.onSubtitlesLoaded);
				this.urlLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onSubtitlesLoadingError);
				this.urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onSubtitlesLoadingError);
			}
		}

		private function removeLoader() : void {
			if (this.urlLoader) {
				this.urlLoader.removeEventListener(Event.COMPLETE, this.onSubtitlesLoaded);
				this.urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, this.onSubtitlesLoadingError);
				this.urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onSubtitlesLoadingError);
				this.urlLoader = null;
			}
		}

		private function parseSubtitles() : void {
			var source : String = this.urlLoader.data as String;
			this.removeLoader();
			var array : Array = source.split(/^[0-9]+$/gm);
			var block : String;
			var length : uint = array.length;
			for (var i : int = 0; i < length; i++) {
				block = array[i];
				this.subtitles.push(new Subtitle(block));
			}
			length = this.elements.length;
			if (!this.isSubitlesParsed && length > 0) {
				for (i = 0; i < length; i++) {
					this.elements[i].initialize(this.subtitles);
				}
			}
			this.isSubitlesParsed = true;
		}

		// Handlers
		private function onSubtitlesLoaded(event : Event) : void {
			this.parseSubtitles();
		}

		private function onSubtitlesLoadingError(event : SecurityErrorEvent) : void {
			// TODO log error
		}
	}
}
