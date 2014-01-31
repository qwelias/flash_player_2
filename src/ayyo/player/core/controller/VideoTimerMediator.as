package ayyo.player.core.controller {
	import org.osmf.media.MediaPlayerSprite;
	import ayyo.player.events.PlayerEvent;
	import ayyo.player.view.api.IVideoTimer;

	import robotlegs.bender.extensions.mediatorMap.api.IMediator;

	import org.osmf.events.TimeEvent;
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
			this.dispatcher.addEventListener(PlayerEvent.TIME_TRAIT, this.onTimeTrait);
			this.player.mediaPlayer.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, this.onCurrentTimeChange);
		}

		public function destroy() : void {
			this.timer = null;
			this.dispatcher = null;
		}

		private function onTimeTrait(event : PlayerEvent) : void {
			this.dispatcher.removeEventListener(PlayerEvent.TIME_TRAIT, this.onTimeTrait);
			this.trait = event.params[0] as TimeTrait;
			this.trait.addEventListener(TimeEvent.DURATION_CHANGE, this.onDurationChange);
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
	}
}
