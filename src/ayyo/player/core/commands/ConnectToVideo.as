package ayyo.player.core.commands {
	import ayyo.player.config.api.IAyyoPlayerConfig;
	import ayyo.player.events.PlayerEvent;

	import me.scriptor.mvc.model.api.IApplicationModel;

	import osmf.patch.SmoothedMediaFactory;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;
	import robotlegs.bender.framework.api.ILogger;

	import org.osmf.events.DynamicStreamEvent;
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.media.URLResource;
	import org.osmf.traits.DynamicStreamTrait;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.TimeTrait;

	import flash.events.IEventDispatcher;
	import flash.events.ProgressEvent;

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
		[Inject]
		public var model : IApplicationModel;
		/**
		 * @private
		 */
		private var media : MediaElement;
		/**
		 * @private
		 */
		private var dynamicStreamTrait : DynamicStreamTrait;
		/**
		 * @private
		 */
		private var timeTrait : TimeTrait;
		/**
		 * @private
		 */
		private var lastBytesLoadedValue : Number;

		public function execute() : void {
			var resource : URLResource = new URLResource(this.playerConfig.video.url);
			(this.player.mediaFactory as SmoothedMediaFactory).customToken = this.playerConfig.video.token;
			this.media = this.player.mediaFactory.createMediaElement(resource);

			this.media.addEventListener(MediaElementEvent.TRAIT_ADD, this.onAddMediaTrait);
			this.media.addEventListener(MediaErrorEvent.MEDIA_ERROR, this.onErrorOccured);

			this.player.mediaPlayer.addEventListener(LoadEvent.BYTES_LOADED_CHANGE, this.onLoadedBytesChange);
			(this.media.getTrait(MediaTraitType.LOAD) as LoadTrait).load();

			this.dispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.HIDE_PRELOADER));
		}

		private function parseTrait(trait : MediaTraitBase) : void {
			if (trait is DynamicStreamTrait) {
				this.dynamicStreamTrait = trait as DynamicStreamTrait;
				this.dynamicStreamTrait.addEventListener(DynamicStreamEvent.SWITCHING_CHANGE, this.onDynamicStreamChange);
			} else if (trait is TimeTrait) {
				this.timeTrait = trait as TimeTrait;
				this.dispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.TIME_TRAIT, [trait]));
			}
		}

		private function onErrorOccured(event : MediaErrorEvent) : void {
			this.logger.error(event.error.message);
		}

		private function onAddMediaTrait(event : MediaElementEvent) : void {
			if (event.traitType == MediaTraitType.LOAD) this.dispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.CAN_LOAD, [this.media.getTrait(event.traitType)]));
			else if (event.traitType == MediaTraitType.ALTERNATIVE_AUDIO) this.dispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.ALTERNATIVE_AUDIO, [this.media.getTrait(event.traitType)]));
			else if (event.traitType == MediaTraitType.AUDIO) this.dispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.AUDIO, [this.media.getTrait(event.traitType)]));
			else if (event.traitType == MediaTraitType.PLAY) this.dispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.CAN_PLAY, [this.media]));
			else if (event.traitType == MediaTraitType.BUFFER) this.dispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.BUFFER_TRAIT, [this.media.getTrait(event.traitType)]));
			else if (event.traitType == MediaTraitType.DYNAMIC_STREAM || event.traitType == MediaTraitType.TIME) this.parseTrait(this.media.getTrait(event.traitType));
		}

		private function onLoadedBytesChange(event : LoadEvent) : void {
			var bytesLoaded : Number = this.player.mediaPlayer.bytesLoaded - (isNaN(this.lastBytesLoadedValue) ? 0 : this.lastBytesLoadedValue);
			this.lastBytesLoadedValue = this.player.mediaPlayer.bytesLoaded;
			this.dispatcher.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, bytesLoaded * 8));
		}

		private function onDynamicStreamChange(event : DynamicStreamEvent) : void {
			this.dispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.DYNAMIC_STREAM_CHANGE, [this.dynamicStreamTrait.getBitrateForIndex(this.dynamicStreamTrait.currentIndex)]));
		}
	}
}
