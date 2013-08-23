package ayyo.player.core.commands {
	import ayyo.player.events.BinDataEvent;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class RegisterAsset implements ICommand {
		[Inject]
		public var event : BinDataEvent;

		public function execute() : void {
		}
	}
}
