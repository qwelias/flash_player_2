package ayyo.player.core.commands {
	import ayyo.player.events.PlayerEvent;
	import org.osmf.media.MediaPlayerSprite;
	import robotlegs.bender.extensions.commandCenter.api.ICommand;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class SeekVideo implements ICommand {
		[Inject]
		public var player : MediaPlayerSprite;
		[Inject]
		public var event : PlayerEvent;
		
		public function execute() : void {
			this.player.mediaPlayer.canSeek && this.player.mediaPlayer.seek(this.event.params[0]);
			this.dispose();
		}

		private function dispose() : void {
			this.player = null;
			this.event = null;
		}
	}
}
