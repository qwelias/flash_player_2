package ayyo.player.core.commands {
	import ayyo.player.core.model.PlayerCommands;
	import ayyo.player.events.PlayerEvent;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;

	import org.osmf.media.MediaPlayerSprite;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class SwitchPlayPause implements ICommand {
		[Inject]
		public var player : MediaPlayerSprite;
		[Inject]
		public var event : PlayerEvent;

		public function execute() : void {
			this.player.mediaPlayer.canPlay && event.type == PlayerCommands.PLAY && this.player.mediaPlayer.play() || this.player.mediaPlayer.canPause && event.type == PlayerCommands.PAUSE && this.player.mediaPlayer.pause();
		}
	}
}
