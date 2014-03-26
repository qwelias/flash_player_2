package ayyo.player.core.commands {
	import ayyo.player.core.model.PlayerCommands;
	import flash.events.IEventDispatcher;
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
		[Inject]
		public var dispatcher : IEventDispatcher;
		
		public function execute() : void {
			const playing : Boolean = this.player.mediaPlayer.playing;
			this.player.mediaPlayer.canSeek && this.player.mediaPlayer.seek(this.event.params[0]);
			playing && this.dispatcher.dispatchEvent(new PlayerEvent(PlayerCommands.PLAY));
			this.dispose();
		}

		private function dispose() : void {
			this.player = null;
			this.event = null;
		}
	}
}
