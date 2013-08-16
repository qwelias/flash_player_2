package ayyo.player.core.commands {
	import ayyo.player.config.api.IAyyoPlayerConfig;
	import ayyo.player.events.ApplicationEvent;

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

		public function execute() : void {
			var source : Object = this.contextView.view.root.loaderInfo.parameters;
			this.playerConfig.ready.addOnce(this.onConfigParsed);
			this.playerConfig.initialize(source);
		}

		private function onConfigParsed() : void {
			this.dispatcher.dispatchEvent(new ApplicationEvent(ApplicationEvent.CONFIG_READY));
			this.dispose();
		}

		private function dispose() : void {
			this.playerConfig = null;
			this.dispatcher = null;
			this.contextView = null;
		}
	}
}
