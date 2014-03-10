package ayyo.player.core.controller {
	import ayyo.player.core.model.PlayerCommands;
	import ayyo.player.events.PlayerEvent;
	import ayyo.player.view.impl.controllbar.AudioTrackInfo;

	import robotlegs.bender.extensions.mediatorMap.api.IMediator;
	import robotlegs.bender.framework.api.ILogger;

	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.net.StreamingItem;
	import org.osmf.traits.AlternativeAudioTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.SeekTrait;

	import flash.events.Event;
	import flash.events.IEventDispatcher;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class AudioTrackInfoMediator implements IMediator {
		[Inject]
		public var player : MediaPlayerSprite;
		[Inject]
		public var audioTrackInfo : AudioTrackInfo;
		[Inject]
		public var dispatcher : IEventDispatcher;
		[Inject]
		public var logger : ILogger;
		/**
		 * @private
		 */
		private var _trait : AlternativeAudioTrait;

		public function initialize() : void {
			this.player.media.hasTrait(MediaTraitType.ALTERNATIVE_AUDIO) ? this.extrackAudioTrackData(this.player.media.getTrait(MediaTraitType.ALTERNATIVE_AUDIO) as AlternativeAudioTrait) : this.dispatcher.addEventListener(PlayerEvent.ALTERNATIVE_AUDIO, this.onNumAlternativeAudioChange);
			this.audioTrackInfo.changeTrack.add(this.onChangeTrack);
		}

		public function destroy() : void {
		}

		private function onNumAlternativeAudioChange(event : PlayerEvent) : void {
			this.dispatcher.hasEventListener(PlayerEvent.ALTERNATIVE_AUDIO) && this.dispatcher.removeEventListener(PlayerEvent.ALTERNATIVE_AUDIO, this.onNumAlternativeAudioChange);
			this.extrackAudioTrackData(event.params[0] as AlternativeAudioTrait);
		}

		private function extrackAudioTrackData(trait : AlternativeAudioTrait) : void {
			this._trait = trait;
			this.logger.debug("This stream contains {0} alternative audio", [trait.numAlternativeAudioStreams]);
			this.onChangeTrack(0);
			var tracks : Vector.<StreamingItem> = new Vector.<StreamingItem>();
			const length : uint = trait.numAlternativeAudioStreams;
			for (var i : int = 0; i < length; i++)
				tracks.push(trait.getItemForIndex(i));
			length > 0 && this.audioTrackInfo.initialize(tracks);
			length > 0 && this.dispatcher.dispatchEvent(new Event(Event.RESIZE));
		}

		private function onChangeTrack(trackID : uint) : void {
			this._trait.switchTo(trackID);
			if (this.player.media != null && this.player.media.hasTrait(MediaTraitType.SEEK)) {
				var seekTrait : SeekTrait = this.player.media.getTrait(MediaTraitType.SEEK) as SeekTrait;

				if (seekTrait.canSeekTo(this.player.mediaPlayer.currentTime)) {
					seekTrait.seek(this.player.mediaPlayer.currentTime);
				}
			}
			this.dispatcher.dispatchEvent(new PlayerEvent(PlayerCommands.SUBTITLES_ON, [this._trait.getItemForIndex(trackID).info["language"]]));
		}
	}
}
