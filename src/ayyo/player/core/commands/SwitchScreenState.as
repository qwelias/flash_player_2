package ayyo.player.core.commands {
	import ayyo.player.core.model.PlayerCommands;
	import ayyo.player.events.PlayerEvent;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;
	import robotlegs.bender.extensions.contextView.ContextView;

	import flash.display.StageDisplayState;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class SwitchScreenState implements ICommand {
		[Inject]
		public var event : PlayerEvent;
		[Inject]
		public var contextView : ContextView;

		public function execute() : void {
			if (this.event.type == PlayerCommands.FULLSCREEN) {
				this.contextView.view.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			} else if (this.event.type == PlayerCommands.NORMALSCREEN) {
				this.contextView.view.stage.displayState = StageDisplayState.NORMAL;
			}
			this.dispose();
		}

		private function dispose() : void {
			this.event = null;
			this.contextView = null;
		}
	}
}
