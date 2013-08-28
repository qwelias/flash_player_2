package ayyo.player.modules.controllpanel.commands {
	import robotlegs.bender.extensions.commandCenter.api.ICommand;
	import robotlegs.bender.extensions.contextView.ContextView;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class AddControllPanelUIElements implements ICommand {
		[Inject]
		public var contextView : ContextView;

		public function execute() : void {
		}
	}
}
