package ayyo.player.core.controller {
	import ayyo.player.plugins.subtitles.impl.view.ISubtextField;

	import robotlegs.bender.extensions.mediatorMap.api.IMediator;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class SubtitlesMediator implements IMediator {
		[Inject]
		public var field : ISubtextField;

		public function initialize() : void {
		}

		public function destroy() : void {
			this.field = null;
		}
	}
}
