package ayyo.player.core.commands {
	import ayyo.player.core.model.PlayerCommands;
	import ayyo.player.events.PlayerEvent;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;

	import org.osmf.elements.F4MElement;
	import org.osmf.media.MediaPlayerSprite;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class SwitchPlayPause implements ICommand {
		[Inject]
		public var player : MediaPlayerSprite;
		[Inject]
		public var event : PlayerEvent;
		[Inject(name="video")]
		public var video : F4MElement;
		
		public function execute() : void {
			this.player.mediaPlayer.canPlay && event.type == PlayerCommands.PLAY && this.player.mediaPlayer.play() ||
			this.player.mediaPlayer.canPause && event.type == PlayerCommands.PAUSE && this.player.mediaPlayer.pause() ||
			!this.player.mediaPlayer.canPlay && !this.player.mediaPlayer.canPause && this.switchMedia();
			
			this.dispose();
		}

		private function dispose() : void {
			this.event = null;
			this.player = null;
			this.video = null;
		}

		private function switchMedia() : void {
			this.player.media = this.video;
			this.execute();
		}
	}
}
