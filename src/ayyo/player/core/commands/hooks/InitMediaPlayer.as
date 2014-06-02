package ayyo.player.core.commands.hooks {
	import ayyo.player.config.api.IAyyoPlayerConfig;

	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.framework.api.IHook;

	import org.osmf.display.ScaleMode;
	import org.osmf.media.MediaPlayerSprite;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class InitMediaPlayer implements IHook {
		[Inject]
		public var player : MediaPlayerSprite;
		[Inject]
		public var contextView : ContextView;
		[Inject]
		public var playerConfig : IAyyoPlayerConfig;

		public function hook() : void {
			this.player.mediaPlayer.autoDynamicStreamSwitch = true;
			this.player.mediaPlayer.autoRewind = false;
			this.player.mediaPlayer.autoPlay = false;
			this.player.mediaPlayer.bufferTime = this.playerConfig.settings.buffer;
			this.player.scaleMode = ScaleMode.ZOOM;

			this.contextView.view.addChild(this.player);

			this.dispose();
		}

		private function dispose() : void {
			this.contextView = null;
			this.player = null;
		}
	}
}
