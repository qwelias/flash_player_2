package ayyo.player.core.controller {
	import ayyo.player.view.impl.controllbar.AudioTrackInfo;

	import robotlegs.bender.extensions.mediatorMap.api.IMediator;
	import robotlegs.bender.framework.api.ILogger;

	import org.osmf.events.AlternativeAudioEvent;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.net.StreamingItem;
	import org.osmf.traits.MediaTraitType;

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

		public function initialize() : void {
			this.player.media.hasTrait(MediaTraitType.ALTERNATIVE_AUDIO) ? this.extrackAudioTrackData() : this.dispatcher.addEventListener(AlternativeAudioEvent.NUM_ALTERNATIVE_AUDIO_STREAMS_CHANGE, this.onNumAlternativeAudioChange);
			this.audioTrackInfo.changeTrack.add(this.onChangeTrack);
		}

		public function destroy() : void {
		}

		private function onNumAlternativeAudioChange(event : AlternativeAudioEvent) : void {
			this.extrackAudioTrackData();
		}

		private function extrackAudioTrackData() : void {
			this.logger.debug("This stream contains {0} alternative audio", [this.player.mediaPlayer.numAlternativeAudioStreams]);
			this.onChangeTrack(0);
			var tracks : Vector.<StreamingItem> = new Vector.<StreamingItem>();
			const length : uint = this.player.mediaPlayer.numAlternativeAudioStreams;
			for (var i : int = 0; i < length; i++)
				tracks.push(this.player.mediaPlayer.getAlternativeAudioItemAt(i));
			length > 0 && this.audioTrackInfo.initialize(tracks);
		}
		
		private function onChangeTrack(trackID : uint) : void {
			this.player.mediaPlayer.switchAlternativeAudioIndex(trackID);
		}
	}
}
