package ayyo.player.core.controller {
	import ayyo.player.core.model.PlayerCommands;
	import ayyo.player.events.PlayerEvent;
	import ayyo.player.view.api.IVolumeBar;

	import robotlegs.bender.extensions.mediatorMap.api.IMediator;

	import flash.events.IEventDispatcher;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class VolumeBarMediator implements IMediator {
		[Inject]
		public var volume : IVolumeBar;
		[Inject]
		public var dispatcher : IEventDispatcher;

		public function initialize() : void {
			this.volume.enable();
			this.volume.action.add(this.onVolumeChange);
		}

		public function destroy() : void {
			this.volume.dispose();
			this.volume = null;
			this.dispatcher = null;
		}

		// Handlers
		private function onVolumeChange(value : Number) : void {
			this.dispatcher.dispatchEvent(new PlayerEvent(PlayerCommands.VOLUME, [value]));
		}
	}
}
