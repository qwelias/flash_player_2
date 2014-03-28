package ayyo.player.core.commands {
	import ayyo.player.events.PlayerEvent;
	import ayyo.player.config.api.IAyyoPlayerConfig;
	import ayyo.player.core.model.api.IInfoObject;
	import ayyo.player.events.BinDataEvent;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;
	import robotlegs.bender.framework.api.ILogger;

	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class LoadBinData implements ICommand {
		[Inject]
		public var event : BinDataEvent;
		[Inject]
		public var logger : ILogger;
		[Inject]
		public var playerConfig : IAyyoPlayerConfig;
		[Inject]
		public var dispatcher : IEventDispatcher;
		/**
		 * @private
		 */
		private var binLoader : URLLoader;
		/**
		 * @private
		 */
		private var currentInfoObject : IInfoObject;

		public function execute() : void {
			this.createLoader();
			this.currentInfoObject = this.playerConfig.assets.shift();
			this.currentInfoObject && this.binLoader.load(new URLRequest(this.currentInfoObject.url));
			this.dispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.SHOW_PRELOADER));
		}

		private function createLoader() : void {
			if (!this.binLoader) {
				this.binLoader = new URLLoader();
				this.binLoader.dataFormat = URLLoaderDataFormat.BINARY;
				this.binLoader.addEventListener(Event.COMPLETE, this.onItemLoadedHandler);
				this.binLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onErrorOccuredHandler);
				this.binLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onErrorOccuredHandler);
			}
		}

		private function disposeLoader() : void {
			if (this.binLoader) {
				this.binLoader.close();
				this.binLoader.removeEventListener(Event.COMPLETE, this.onItemLoadedHandler);
				this.binLoader.removeEventListener(IOErrorEvent.IO_ERROR, this.onErrorOccuredHandler);
				this.binLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onErrorOccuredHandler);
				this.binLoader = null;
			}
		}

		private function dispose() : void {
			this.disposeLoader();
			this.event = null;
			this.playerConfig = null;
			this.dispatcher = null;
			this.currentInfoObject = null;
			this.logger = null;
		}

		// Handlers
		private function onItemLoadedHandler(event : Event) : void {
			var bytes : ByteArray = new ByteArray();
			bytes.writeObject(this.currentInfoObject);
			bytes.writeBytes(this.binLoader.data as ByteArray);
			this.currentInfoObject = null;
			bytes && this.dispatcher.dispatchEvent(new BinDataEvent(BinDataEvent.LOADED, this.event.dataType, bytes));
			this.dispose();
		}
		
		private function onErrorOccuredHandler(event : ErrorEvent) : void {
			this.logger.error(event.text);
			this.dispose();
		}
	}
}
