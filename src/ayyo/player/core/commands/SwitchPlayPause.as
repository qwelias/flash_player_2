package ayyo.player.core.commands {
	import flash.events.IEventDispatcher;

	import ayyo.player.core.model.PlayerCommands;
	import ayyo.player.events.PlayerEvent;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;

	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayerSprite;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class SwitchPlayPause implements ICommand {
		[Inject]
		public var player : MediaPlayerSprite;
		[Inject]
		public var event : PlayerEvent;
		[Inject]
		public var dispatcher : IEventDispatcher;

		public function execute() : void {
			this.check() && this.dispose();
		}

		private function check() : Boolean {
			var result : Boolean = this.player != null && this.player.mediaPlayer != null && (this.player.mediaPlayer.canPlay && this.player.mediaPlayer.canPause);
			this.player.mediaPlayer.canPlay && event.type == PlayerCommands.PLAY && this.player.mediaPlayer.play() ||
			this.player.mediaPlayer.canPause && event.type == PlayerCommands.PAUSE && this.player.mediaPlayer.pause() ||
			!this.player.mediaPlayer.canPlay && !this.player.mediaPlayer.canPause && this.switchMedia();
			return result;
		}

		private function dispose() : void {
			this.event = null;
			this.player = null;
			this.dispatcher = null;
		}

		private function switchMedia() : void {
			this.player.media = this.event.params[0] as MediaElement;
			this.dispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.MEDIA_CHANGED));
			this.execute();
		}
	}
}
