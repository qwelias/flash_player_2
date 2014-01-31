package ayyo.player.core.commands {
	import org.osmf.events.MediaErrorEvent;
	import ayyo.player.config.api.IAyyoPlayerConfig;
	import ayyo.player.events.PlayerEvent;

	import osmf.patch.SmoothedMediaFactory;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;
	import robotlegs.bender.framework.api.ILogger;

	import org.osmf.events.MediaElementEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.media.URLResource;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;

	import flash.events.IEventDispatcher;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ConnectToVideo implements ICommand {
		[Inject]
		public var playerConfig : IAyyoPlayerConfig;
		[Inject]
		public var logger : ILogger;
		[Inject]
		public var player : MediaPlayerSprite;
		[Inject]
		public var dispatcher : IEventDispatcher;
		/**
		 * @private
		 */
		private var media : MediaElement;

		public function execute() : void {
			var resource : URLResource = new URLResource(this.playerConfig.video.url);
			(this.player.mediaFactory as SmoothedMediaFactory).customToken = this.playerConfig.video.token;
			this.media = this.player.mediaFactory.createMediaElement(resource);

			this.media.addEventListener(MediaElementEvent.TRAIT_ADD, this.onAddMediaTrait);
			this.media.addEventListener(MediaErrorEvent.MEDIA_ERROR, this.onErrorOccured);

			(this.media.getTrait(MediaTraitType.LOAD) as LoadTrait).load();
		}

		private function onErrorOccured(event : MediaErrorEvent) : void {
			this.logger.error(event.error.message);
		}

		private function onAddMediaTrait(event : MediaElementEvent) : void {
			trace('event.traitType: ' + (event.traitType));
			if (event.traitType == MediaTraitType.LOAD) this.dispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.CAN_LOAD, [this.media.getTrait(event.traitType)]));
			else if (event.traitType == MediaTraitType.ALTERNATIVE_AUDIO) this.dispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.ALTERNATIVE_AUDIO, [this.media.getTrait(event.traitType)]));
			else if (event.traitType == MediaTraitType.PLAY) this.dispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.CAN_PLAY, [this.media]));
			else if (event.traitType == MediaTraitType.TIME) this.dispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.TIME_TRAIT, [this.media.getTrait(event.traitType)]));
			else if (event.traitType == MediaTraitType.BUFFER) this.dispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.BUFFER_TRAIT, [this.media.getTrait(event.traitType)]));
		}
	}
}
