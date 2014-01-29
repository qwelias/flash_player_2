package ayyo.player.core.controller {
	import ayyo.player.view.api.IVolumeBar;

	import robotlegs.bender.extensions.mediatorMap.api.IMediator;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class VolumeBarMediator implements IMediator {
		[Inject]
		public var volume : IVolumeBar;

		public function initialize() : void {
		}

		public function destroy() : void {
		}
	}
}
