package ayyo.player.core.commands {
	import ayyo.player.core.model.JavascriptFunctions;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	import ayyo.player.core.model.ApplicationVariables;
	import ayyo.player.core.model.PlayerCommands;
	import ayyo.player.events.PlayerEvent;

	import me.scriptor.mvc.model.api.IApplicationModel;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;

	import org.osmf.media.MediaPlayerSprite;

	import flash.events.IEventDispatcher;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class SeekVideo implements ICommand {
		[Inject]
		public var player : MediaPlayerSprite;
		[Inject]
		public var event : PlayerEvent;
		[Inject]
		public var model : IApplicationModel;
		[Inject]
		public var dispatcher : IEventDispatcher;
		/**
		 * @private
		 */
		private var checkPlayingState : uint;
		
		public function execute() : void {
			clearTimeout(this.checkPlayingState);
			if(this.player.mediaPlayer.canSeek){
				this.player.mediaPlayer.seek(this.event.params[0]);
				this.dispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.SEND_TO_JS, [JavascriptFunctions.RECIEVE_FLASH_EVENT, "seek_to.seekevent", this.event.params[0]]));
			}
			this.checkPlayingState = setTimeout(this.checkPlayingStatus, 10);
		}

		private function checkPlayingStatus() : void {
			clearTimeout(this.checkPlayingState);
			this.model.getVariable(ApplicationVariables.PLAYING) && this.dispatcher.dispatchEvent(new PlayerEvent(PlayerCommands.PLAY));
			this.dispose();
		}

		private function dispose() : void {
			this.player = null;
			this.event = null;
			this.model = null;
		}
	}
}
