package ayyo.player.core.controller.appconfig {
	import robotlegs.bender.framework.api.IContext;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class PlayerInjections {
		[Inject]
		public var conetxt : IContext;

		[PostConstruct]
		public function initialize() : void {
		}

		[PreDestroy]
		public function destroy() : void {
			this.conetxt = null;
		}
	}
}
