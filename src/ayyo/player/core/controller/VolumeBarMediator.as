package ayyo.player.core.controller {
	import ayyo.container.WrapperEvent;
	import ayyo.player.core.model.PlayerCommands;
	import ayyo.player.events.PlayerEvent;
	import ayyo.player.view.api.IVolumeBar;
	
	import flash.events.IEventDispatcher;
	
	import robotlegs.bender.extensions.mediatorMap.api.IMediator;

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
			this.dispatcher.addEventListener(WrapperEvent.VOLUME, this.onWrapperVolume);
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
		private function onWrapperVolume(event:WrapperEvent):void
		{
			this.onVolumeChange(event.params[0]);
		}
	}
}
