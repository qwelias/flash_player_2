package ayyo.player.core.controller.appconfig {
	import ayyo.player.events.ApplicationEvent;

	import flash.events.Event;
	import flash.events.IEventDispatcher;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class PlayerLaunch {
		[Inject]
		public var dispatcher : IEventDispatcher;

		[PostConstruct]
		public function initialize() : void {
			trace("--> Launch")
			this.dispatcher.dispatchEvent(new Event(ApplicationEvent.LAUNCH));
		}

		[PreDestroy]
		public function destroy() : void {
			this.dispatcher = null;
		}
	}
}
