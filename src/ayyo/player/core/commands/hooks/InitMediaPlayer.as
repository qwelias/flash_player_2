package ayyo.player.core.commands.hooks {
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

		public function hook() : void {
			this.player.mediaPlayer.autoDynamicStreamSwitch = true;
			this.player.mediaPlayer.autoRewind = false;
			this.player.mediaPlayer.autoPlay = false;
			this.player.scaleMode = ScaleMode.LETTERBOX;

			this.contextView.view.addChild(this.player);

			this.dispose();
		}

		private function dispose() : void {
			this.contextView = null;
			this.player = null;
		}
	}
}
