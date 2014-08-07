package ayyo.player.core.commands {
	import ayyo.player.core.model.JavascriptFunctions;
	import ayyo.player.core.model.PlayerCommands;
	import ayyo.player.events.ApplicationEvent;
	import ayyo.player.events.PlayerEvent;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;

	import flash.events.IEventDispatcher;

	/**
	 * @author Aziz Zaynutdinov (aziz.zaynutdinov at playstorm.com)
	 */
	public class PlaybackComplete implements ICommand {
		[Inject]
		public var dispatcher : IEventDispatcher;

		public function execute() : void {
			this.dispatcher.dispatchEvent(new PlayerEvent(PlayerCommands.SEEK, [0]));
			this.dispatcher.dispatchEvent(new ApplicationEvent(ApplicationEvent.READY));
			
			this.dispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.SEND_TO_JS, [JavascriptFunctions.RECIEVE_FLASH_EVENT, "complete.playbackevent"]));
			
			this.dispose();
		}

		private function dispose() : void {
			this.dispatcher = null;
		}
	}
}
