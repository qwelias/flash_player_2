package ayyo.player.core.controller {
	import robotlegs.bender.framework.api.ILogger;
	import ayyo.player.core.model.ApplicationVariables;
	import ayyo.player.core.model.PlayerCommands;
	import ayyo.player.events.PlayerEvent;
	import ayyo.player.view.api.IVideoTimeline;
	import ayyo.player.view.impl.controllbar.ThumbAction;

	import me.scriptor.mvc.model.api.IApplicationModel;

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
		public var model : IApplicationModel;
		[Inject]
		public var logger : ILogger;
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
			this.logger = null;
			this.model = null;
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
			event.buffering && this.logger.info("Buffering video.");
			this.dispatcher.dispatchEvent(new PlayerEvent(event.buffering ? PlayerEvent.SHOW_PRELOADER : PlayerEvent.HIDE_PRELOADER));
		}

		private function onBufferTimeChange(event : BufferEvent) : void {
		}

		private function onTimeLineAction(action : String, params : Array) : void {
			this.dispatcher.dispatchEvent(new PlayerEvent(action, params));
			if (action == ThumbAction.PRESSED) {
				this.model.setVariable(ApplicationVariables.PLAYING, this.player.mediaPlayer.playing);
				this.dispatcher.dispatchEvent(new PlayerEvent(PlayerCommands.PAUSE));
			}
		}
	}
}
