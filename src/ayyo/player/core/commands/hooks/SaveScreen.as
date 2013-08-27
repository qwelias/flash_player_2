package ayyo.player.core.commands.hooks {
	import ayyo.player.events.ResizeEvent;

	import robotlegs.bender.framework.api.IHook;

	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.geom.Rectangle;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class SaveScreen implements IHook {
		[Inject]
		public var event : ResizeEvent;
		[Inject(name="screen")]
		public var screen : Rectangle;
		[Inject]
		public var dispatcher : IEventDispatcher;

		public function hook() : void {
			this.screen.width = this.event.newWidth;
			this.screen.height = this.event.newHeight;
			this.dispatcher.dispatchEvent(new Event(Event.RESIZE));
			this.dispose();
		}

		private function dispose() : void {
			this.dispatcher = null;
			this.screen = null;
			this.event = null;
		}
	}
}
