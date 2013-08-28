package ayyo.player.modules.controllpanel.commands {
	import ayyo.player.events.ConfigEvent;

	import by.blooddy.crypto.serialization.JSON;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;
	import robotlegs.bender.framework.api.ILogger;

	import flash.events.DataEvent;
	import flash.events.IEventDispatcher;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ParseControllBarConfig implements ICommand {
		[Inject]
		public var event : DataEvent;
		[Inject]
		public var dispatcher : IEventDispatcher;
		[Inject]
		public var logger : ILogger;

		public function execute() : void {
			var config : Object = by.blooddy.crypto.serialization.JSON.decode(this.event.data);
			this.dispatcher.dispatchEvent(new ConfigEvent(ConfigEvent.PARSED, config));
			this.logger.debug("Config file parsed");

			this.dispose();
		}

		private function dispose() : void {
			this.event = null;
			this.dispatcher = null;
			this.logger = null;
		}
	}
}
