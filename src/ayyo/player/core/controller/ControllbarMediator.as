package ayyo.player.core.controller {
	import ayyo.player.events.PlayerEvent;
	import ayyo.player.view.api.IPlayerControllBar;

	import robotlegs.bender.extensions.mediatorMap.api.IMediator;
	import robotlegs.bender.framework.api.ILogger;

	import flash.events.IEventDispatcher;
	import flash.geom.Rectangle;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ControllbarMediator implements IMediator {
		[Inject]
		public var controlls : IPlayerControllBar;
		[Inject]
		public var logger : ILogger;
		[Inject]
		public var dispatcher : IEventDispatcher;
		[Inject(name="screen")]
		public var screen : Rectangle;

		public function initialize() : void {
			this.controlls.show();
			this.controlls.action.add(this.onControlAction);
		}

		public function destroy() : void {
			this.controlls.action.remove(this.onControlAction);
			this.controlls = null;
			this.logger = null;
			this.screen = null;
			this.dispatcher = null;
		}

		// Handlers
		private function onControlAction(action : String) : void {
			this.dispatcher.dispatchEvent(new PlayerEvent(action));
		}
	}
}
