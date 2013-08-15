package ayyo.player.core.controller.appconfig {
	import ayyo.player.config.api.IPlayerConfig;
	import ayyo.player.config.impl.JSONPlayerConfig;

	import robotlegs.bender.framework.api.IContext;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class PlayerInjections {
		[Inject]
		public var context : IContext;

		[PostConstruct]
		public function initialize() : void {
			this.context.injector.map(IPlayerConfig).toSingleton(JSONPlayerConfig);
		}

		[PreDestroy]
		public function destroy() : void {
			this.context = null;
		}
	}
}
