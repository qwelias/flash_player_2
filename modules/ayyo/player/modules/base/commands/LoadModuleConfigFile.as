package ayyo.player.modules.base.commands {
	import ayyo.player.config.api.IPlayerConfig;
	import ayyo.player.modules.info.impl.ModuleInfo;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;

	import org.osflash.signals.natives.sets.URLLoaderSignalSet;

	import flash.events.DataEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class LoadModuleConfigFile implements ICommand {
		[Inject]
		public var info : ModuleInfo;
		[Inject]
		public var dispatcher : IEventDispatcher;
		[Inject]
		public var playerConfig : IPlayerConfig;
		/**
		 * @private
		 */
		private var configLoader : URLLoader;
		/**
		 * @private
		 */
		private var signals : URLLoaderSignalSet;

		public function execute() : void {
			var request : URLRequest = new URLRequest(this.playerConfig.settings.baseURL + this.info.config);

			this.configLoader = new URLLoader();
			this.signals = new URLLoaderSignalSet(this.configLoader);

			this.signals.complete.add(this.onConfigLoadedHandler);
			this.signals.progress.add(this.onConfigLoadingHandler);
			this.signals.ioError.add(this.onErrorOccuredHandler);
			this.signals.securityError.add(this.onErrorOccuredHandler);

			this.configLoader.load(request);
		}

		private function dispose() : void {
			try {
				this.configLoader.close();
			} catch(error : *) {
			}
			this.configLoader = null;
			this.signals.removeAll();
			this.signals = null;
			this.info = null;
			this.playerConfig = null;
			this.dispatcher = null;
		}

		// Handlers
		/**
		 * @eventType flash.events.Event.COMPLETE
		 */
		private function onConfigLoadedHandler(event : Event) : void {
			this.dispatcher.dispatchEvent(new DataEvent(DataEvent.DATA, false, false, this.configLoader.data));
			this.dispose();
		}

		/**
		 * @eventType flash.events.ProgressEvent.PROGRESS
		 */
		private function onConfigLoadingHandler(event : ProgressEvent) : void {
		}

		/**
		 * @eventType flash.events.ErrorEvent.ERROR
		 */
		private function onErrorOccuredHandler(event : ErrorEvent) : void {
			this.dispatcher.dispatchEvent(event);
			this.dispose();
		}
	}
}
