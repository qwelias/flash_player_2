package ayyo.player.core.controller {
	import ayyo.player.core.model.ApplicationVariables;
	import ayyo.player.core.model.PlayerCommands;
	import ayyo.player.events.PlayerEvent;
	import ayyo.player.view.api.IVideoTimeline;
	import ayyo.player.view.impl.controllbar.ThumbAction;

	import me.scriptor.mvc.model.api.IApplicationModel;

	import robotlegs.bender.extensions.mediatorMap.api.IMediator;
	import robotlegs.bender.framework.api.ILogger;

	import org.osmf.events.BufferEvent;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.traits.BufferTrait;
	import org.osmf.traits.MediaTraitType;

	import flash.events.IEventDispatcher;
	import flash.events.ProgressEvent;

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
		/**
		 * @private
		 */
		private var trait : BufferTrait;

		public function initialize() : void {
			this.player.media != null ? this.check() : this.dispatcher.addEventListener(PlayerEvent.MEDIA_CHANGED, this.onMediaChanged);
		}

		private function check() : void {
			this.player.media.hasTrait(MediaTraitType.BUFFER) ? this.parseBufferTrait(this.player.media.getTrait(MediaTraitType.BUFFER) as BufferTrait) : this.dispatcher.addEventListener(PlayerEvent.BUFFER_TRAIT, this.onBufferTrait);
			this.dispatcher.addEventListener(ProgressEvent.PROGRESS, this.onLoadProgress);
			this.timeline.action.add(this.onTimeLineAction);
		}

		public function destroy() : void {
			this.trait.hasEventListener(BufferEvent.BUFFERING_CHANGE) && this.trait.removeEventListener(BufferEvent.BUFFERING_CHANGE, this.onBufferingChange);
			this.trait.hasEventListener(BufferEvent.BUFFER_TIME_CHANGE) && this.trait.removeEventListener(BufferEvent.BUFFER_TIME_CHANGE, this.onBufferTimeChange);
			this.trait = null;
			this.dispatcher.hasEventListener(ProgressEvent.PROGRESS) && this.dispatcher.removeEventListener(ProgressEvent.PROGRESS, this.onLoadProgress);
			this.timeline.dispose();
			this.player = null;
			this.timeline = null;
			this.dispatcher = null;
			this.logger = null;
			this.model = null;
		}

		private function parseBufferTrait(bufferTrait : BufferTrait) : void {
			this.trait = bufferTrait;
			if (trait) {
				trait.addEventListener(BufferEvent.BUFFERING_CHANGE, this.onBufferingChange);
				trait.addEventListener(BufferEvent.BUFFER_TIME_CHANGE, this.onBufferTimeChange);
			}
		}

		private function onBufferTrait(event : PlayerEvent) : void {
			this.dispatcher.removeEventListener(PlayerEvent.BUFFER_TRAIT, this.onBufferTrait);
			this.parseBufferTrait(event.params[0] as BufferTrait);
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

		private function onLoadProgress(event : ProgressEvent) : void {
			this.timeline.loaded = event.bytesLoaded;
		}

		private function onMediaChanged(event : PlayerEvent) : void {
			this.dispatcher.removeEventListener(PlayerEvent.MEDIA_CHANGED, this.onMediaChanged);
		}
	}
}
