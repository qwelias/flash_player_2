package ayyo.player.core.commands {
	import ayyo.player.events.PlayerEvent;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;

	import org.osmf.media.MediaPlayerSprite;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class SetVolume implements ICommand {
		[Inject]
		public var player : MediaPlayerSprite;
		[Inject]
		public var event : PlayerEvent;

		public function execute() : void {
			this.player.mediaPlayer.hasAudio && (this.player.mediaPlayer.volume = this.event.params[0]);
			this.dispose();
		}

		private function dispose() : void {
			this.event = null;
			this.player = null;
		}
	}
}
