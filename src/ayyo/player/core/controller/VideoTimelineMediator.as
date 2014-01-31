package ayyo.player.core.controller {
	import ayyo.player.events.PlayerEvent;
	import ayyo.player.view.api.IVideoTimeline;

	import robotlegs.bender.extensions.mediatorMap.api.IMediator;

	import org.osmf.events.BufferEvent;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.traits.BufferTrait;

	import flash.events.IEventDispatcher;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class VideoTimelineMediator implements IMediator {
		[Inject]
		public var timeline : IVideoTimeline;
		[Inject]
		public var player : MediaPlayerSprite;
		[Inject]
		public var dispatcher : IEventDispatcher;

		public function initialize() : void {
			this.dispatcher.addEventListener(PlayerEvent.BUFFER_TRAIT, this.onBufferTrait);
			this.timeline.action.add(this.onTimeLineAction);
		}

		public function destroy() : void {
			this.timeline.dispose();
			this.player = null;
			this.timeline = null;
			this.dispatcher = null;
		}

		private function onBufferTrait(event : PlayerEvent) : void {
			this.dispatcher.removeEventListener(PlayerEvent.BUFFER_TRAIT, this.onBufferTrait);
			var trait : BufferTrait = event.params[0] as BufferTrait;
			if (trait) {
				trait.addEventListener(BufferEvent.BUFFERING_CHANGE, this.onBufferingChange);
				trait.addEventListener(BufferEvent.BUFFER_TIME_CHANGE, this.onBufferTimeChange);
			}
		}

		private function onBufferingChange(event : BufferEvent) : void {
			trace('event.buffering: ' + (event.buffering));
		}

		private function onBufferTimeChange(event : BufferEvent) : void {
			trace('event.bufferTime: ' + (event.bufferTime));
		}
		
		private function onTimeLineAction(action : String, params : Array) : void {
			this.dispatcher.dispatchEvent(new PlayerEvent(action, params));
		}
	}
}
