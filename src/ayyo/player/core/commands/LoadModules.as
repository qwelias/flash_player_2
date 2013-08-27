package ayyo.player.core.commands {
	import ayyo.player.core.model.DataType;
	import ayyo.player.events.BinDataEvent;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;

	import flash.events.IEventDispatcher;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class LoadModules implements ICommand {
		[Inject]
		public var dispatcher : IEventDispatcher;

		public function execute() : void {
			this.dispatcher.dispatchEvent(new BinDataEvent(BinDataEvent.LOAD, DataType.MODULES));
			this.dispose();
		}

		private function dispose() : void {
			this.dispatcher = null;
		}
	}
}
