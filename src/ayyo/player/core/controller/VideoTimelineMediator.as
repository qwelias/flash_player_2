package ayyo.player.core.controller {
	import ayyo.player.view.api.IVideoTimeline;

	import robotlegs.bender.extensions.mediatorMap.api.IMediator;

	import org.osmf.media.MediaPlayerSprite;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class VideoTimelineMediator implements IMediator {
		[Inject]
		public var timeline : IVideoTimeline;
		[Inject]
		public var player : MediaPlayerSprite;

		public function initialize() : void {
		}

		public function destroy() : void {
		}
	}
}
