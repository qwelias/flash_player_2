package ayyo.player.core.commands {
	import ayyo.player.config.api.IAyyoPlayerConfig;
	import ayyo.player.events.PlayerEvent;

	import osmf.patch.SmoothedMediaFactory;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;
	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.framework.api.ILogger;

	import org.osmf.elements.F4MElement;
	import org.osmf.elements.F4MLoader;
	import org.osmf.events.AlternativeAudioEvent;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.media.URLResource;
	import org.osmf.traits.MediaTraitType;

	import flash.events.FullScreenEvent;
	import flash.events.IEventDispatcher;
	import flash.geom.Rectangle;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ConnectToVideo implements ICommand {
		[Inject]
		public var contextView : ContextView;
		[Inject]
		public var playerConfig : IAyyoPlayerConfig;
		[Inject]
		public var logger : ILogger;
		[Inject]
		public var factory : SmoothedMediaFactory;
		[Inject(name="screen")]
		public var screen : Rectangle;
		[Inject]
		/**
		 * @private
		 */
		public var player : MediaPlayerSprite;
		[Inject]
		public var dispatcher : IEventDispatcher;

		public function execute() : void {
			this.playVideo();
		}

		private function playVideo() : void {
			var resource : URLResource = new URLResource(this.playerConfig.video.url);
			if (this.playerConfig.video.url.indexOf("f4m") != -1) {
				this.factory.customToken = this.playerConfig.video.token;
				this.player.mediaPlayer.media = new F4MElement(resource, new F4MLoader(this.factory));
			} else {
				this.player.mediaPlayer.media = this.factory.createMediaElement(resource);
			}

			this.player.mediaPlayer.addEventListener(PlayEvent.PLAY_STATE_CHANGE, this.onPlayStateChange);
			this.player.mediaPlayer.addEventListener(TimeEvent.DURATION_CHANGE, this.onDurationChange);
			this.player.mediaPlayer.addEventListener(AlternativeAudioEvent.NUM_ALTERNATIVE_AUDIO_STREAMS_CHANGE, this.dispatcher.dispatchEvent);
			this.player.media.addEventListener(MediaElementEvent.TRAIT_ADD, this.onAddMediaTrait);

			this.contextView.view.stage.addEventListener(FullScreenEvent.FULL_SCREEN, this.onFullscreen);
		}

		private function onAddMediaTrait(event : MediaElementEvent) : void {
			trace('event.traitType: ' + (event.traitType));
			if (event.traitType == MediaTraitType.DISPLAY_OBJECT) this.onFullscreen(null);
			else if (event.traitType == MediaTraitType.LOAD) this.dispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.CAN_LOAD));
		}

		private function onFullscreen(event : FullScreenEvent) : void {
			this.player.width = this.screen.width;
			this.player.height = this.screen.height;
		}

		private function onPlayStateChange(event : PlayEvent) : void {
			this.logger.debug("Play state changed to {0}", [event.playState]);
		}

		private function onDurationChange(event : TimeEvent) : void {
			if (isNaN(event.time) || event.time == 0) return;
		}
	}
}
