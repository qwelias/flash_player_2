package ayyo.player.core.commands {
	import ayyo.player.config.api.IAyyoPlayerConfig;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;
	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.framework.api.ILogger;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class LaunchTestVideo implements ICommand {
		[Inject]
		public var contextView : ContextView;
		[Inject]
		public var playerConfig : IAyyoPlayerConfig;
		[Inject]
		public var logger : ILogger;

		public function execute() : void {
		}
	}
}
