package ayyo.player.modules.controllpanel.commands {
	import robotlegs.bender.extensions.commandCenter.api.ICommand;

	import flash.events.DataEvent;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ParseControllBarConfig implements ICommand {
		[Inject]
		public var event : DataEvent;

		public function execute() : void {
		}
	}
}
