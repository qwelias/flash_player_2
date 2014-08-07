package ayyo.player.core.controller.appconfig {
	import robotlegs.bender.framework.api.ILogger;
	import flash.external.ExternalInterface;
	import ayyo.player.events.PlayerEvent;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;

	/**
	 * @author Aziz Zaynutdinov (aziz.zaynutdinov at playstorm.com)
	 */
	public class SendToJavascript implements ICommand {
		[Inject]
		public var event : PlayerEvent;
		[Inject]
		public var logger : ILogger;

		public function execute() : void {
			if (ExternalInterface.available) {
				ExternalInterface.call.apply(null, this.event.params);
				
				this.logger.debug("Called '{0}' js-function", [this.event.params[0]]);
			}
			this.dispose();
		}

		private function dispose() : void {
			this.event = null;
			this.logger = null;
		}
	}
}
