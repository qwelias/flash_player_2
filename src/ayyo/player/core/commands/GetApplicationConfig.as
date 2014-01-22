package ayyo.player.core.commands {
	import robotlegs.bender.framework.api.ILogger;
	import ayyo.player.config.api.IAyyoPlayerConfig;
	import ayyo.player.core.model.DataType;
	import ayyo.player.events.BinDataEvent;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;
	import robotlegs.bender.extensions.contextView.ContextView;

	import flash.events.IEventDispatcher;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class GetApplicationConfig implements ICommand {
		[Inject]
		public var playerConfig : IAyyoPlayerConfig;
		[Inject]
		public var dispatcher : IEventDispatcher;
		[Inject]
		public var contextView : ContextView;
		[Inject]
		public var logger : ILogger;

		public function execute() : void {
			var source : Object = this.contextView.view.root.loaderInfo.parameters;
			if (source) {
				this.playerConfig.ready.addOnce(this.onConfigParsed);
				this.playerConfig.initialize(source);
			} else {
				this.logger.error("There are no any parameters for player.");
			}
		}

		private function onConfigParsed() : void {
			this.logger.debug("Config successfully parsed");
			this.dispatcher.dispatchEvent(new BinDataEvent(BinDataEvent.LOAD, DataType.ASSETS));
			this.dispose();
		}

		private function dispose() : void {
			this.playerConfig = null;
			this.logger = null;
			this.dispatcher = null;
			this.contextView = null;
		}
	}
}
