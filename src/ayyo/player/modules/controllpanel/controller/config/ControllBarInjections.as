package ayyo.player.modules.controllpanel.controller.config {
	import robotlegs.bender.framework.api.IContext;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ControllBarInjections {
		[Inject]
		public var context : IContext;

		[PostConstruct]
		public function initialize() : void {
		}

		[PreDestroy]
		public function destroy() : void {
			this.context = null;
		}
	}
}
