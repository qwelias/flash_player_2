package ayyo.player.modules.base.commands {
	import ayyo.player.events.ModuleEvent;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;

	import flash.events.IEventDispatcher;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class TellIamReady implements ICommand {
		[Inject]
		public var dispatcher : IEventDispatcher;

		public function execute() : void {
			this.dispatcher.dispatchEvent(new ModuleEvent(ModuleEvent.READY));
			this.dispatcher = null;
		}
	}
}
