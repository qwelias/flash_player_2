package ayyo.player.core.commands {
	import ayyo.player.config.api.IAyyoPlayerConfig;
	import ayyo.player.events.BinDataEvent;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class LoadBinData implements ICommand {
		[Inject]
		public var event : BinDataEvent;
		[Inject]
		public var playerConfig : IAyyoPlayerConfig;

		public function execute() : void {
		}
	}
}
