package ayyo.player.modules.splash.controller.config {
	import robotlegs.bender.framework.api.IContext;

	import flash.geom.Rectangle;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class SplashInjections {
		[Inject]
		public var context : IContext;

		[PostConstruct]
		public function initialize() : void {
			var screen : Rectangle = this.context.injector.parent.getInstance(Rectangle, "screen") as Rectangle;
			this.context.injector.map(Rectangle, "screen").toValue(screen);
		}

		[PreDestroy]
		public function destroy() : void {
			this.context = null;
		}
	}
}
