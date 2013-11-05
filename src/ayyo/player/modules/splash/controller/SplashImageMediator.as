package ayyo.player.modules.splash.controller {
	import ayyo.player.modules.splash.view.api.ISplashImageHolder;

	import robotlegs.bender.extensions.mediatorMap.api.IMediator;

	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.geom.Rectangle;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class SplashImageMediator implements IMediator {
		[Inject]
		public var splash : ISplashImageHolder;
		[Inject]
		public var dispatcher : IEventDispatcher;
		[Inject(name="screen")]
		public var screen : Rectangle;

		public function initialize() : void {
			this.dispatcher.addEventListener(Event.RESIZE, this.onScreenResized);
			this.onScreenResized(null);
		}

		public function destroy() : void {
			this.splash = null;
			this.dispatcher = null;
		}

		// Handlers
		private function onScreenResized(event : Event) : void {
			if (this.screen) {
				this.splash.image.width = this.screen.width;
				this.splash.image.scaleY = this.splash.image.scaleX;

				this.splash.view.x = this.screen.width - this.splash.view.width >> 1;
				this.splash.view.y = this.screen.height - this.splash.view.height >> 1;
			}
		}
	}
}
