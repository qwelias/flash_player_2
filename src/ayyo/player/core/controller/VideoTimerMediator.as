package ayyo.player.core.controller {
	import ayyo.player.events.PlayerEvent;
	import ayyo.player.view.api.IVideoTimer;

	import robotlegs.bender.extensions.mediatorMap.api.IMediator;

	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.TimeTrait;

	import flash.events.IEventDispatcher;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class VideoTimerMediator implements IMediator {
		[Inject]
		public var dispatcher : IEventDispatcher;
		[Inject]
		public var timer : IVideoTimer;
		[Inject]
		public var player : MediaPlayerSprite;
		/**
		 * @private
		 */
		private var trait : TimeTrait;

		public function initialize() : void {
			if (this.timer.controlable) {
				this.player.media.hasTrait(MediaTraitType.TIME) ? this.parseTimeTrait(this.player.media.getTrait(MediaTraitType.TIME) as TimeTrait) : this.dispatcher.addEventListener(PlayerEvent.TIME_TRAIT, this.onTimeTrait);
				this.player.mediaPlayer.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, this.onCurrentTimeChange);
				this.dispatcher.addEventListener(PlayerEvent.DYNAMIC_STREAM_CHANGE, this.onDynamicStreamChange);
			} else {
				this.destroy();
			}
		}

		public function destroy() : void {
			this.player.mediaPlayer.hasEventListener(TimeEvent.CURRENT_TIME_CHANGE) && this.player.mediaPlayer.removeEventListener(TimeEvent.CURRENT_TIME_CHANGE, this.onCurrentTimeChange);
			this.dispatcher.hasEventListener(PlayerEvent.DYNAMIC_STREAM_CHANGE) && this.dispatcher.removeEventListener(PlayerEvent.DYNAMIC_STREAM_CHANGE, this.onDynamicStreamChange);
			this.trait && this.trait.hasEventListener(TimeEvent.DURATION_CHANGE) && this.trait.removeEventListener(TimeEvent.DURATION_CHANGE, this.onDurationChange);
			this.trait && this.trait.hasEventListener(TimeEvent.COMPLETE) && this.trait.removeEventListener(TimeEvent.COMPLETE, this.dispatcher.dispatchEvent);
			this.timer = null;
			this.dispatcher = null;
			this.player = null;
			this.trait = null;
		}

		private function onTimeTrait(event : PlayerEvent) : void {
			this.dispatcher.removeEventListener(PlayerEvent.TIME_TRAIT, this.onTimeTrait);
			this.parseTimeTrait(event.params[0] as TimeTrait);
		}

		private function parseTimeTrait(timeTrait : TimeTrait) : void {
			this.trait = timeTrait;
			this.trait.addEventListener(TimeEvent.DURATION_CHANGE, this.onDurationChange);
			this.trait.addEventListener(TimeEvent.COMPLETE, this.dispatcher.dispatchEvent);
			this.trait != null && !isNaN(this.trait.duration) && this.trait.duration != 0 && this.onDurationChange(null);
		}

		private function onDurationChange(event : TimeEvent) : void {
			if (this.trait && !isNaN(this.trait.duration)) {
				this.timer.duration = this.trait.duration;
				this.trait.removeEventListener(TimeEvent.DURATION_CHANGE, this.onDurationChange);
			}
		}

		private function onCurrentTimeChange(event : TimeEvent) : void {
			this.timer.time = event.time;
		}

		private function onDynamicStreamChange(event : PlayerEvent) : void {
			this.timer.bitrate = event.params[0];
		}
	}
}
