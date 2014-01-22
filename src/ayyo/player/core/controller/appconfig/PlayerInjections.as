package ayyo.player.core.controller.appconfig {
	import ayyo.player.config.api.IAyyoPlayerConfig;
	import ayyo.player.config.impl.FlashVarsConfig;

	import me.scriptor.mvc.model.api.IApplicationModel;
	import me.scriptor.mvc.model.impl.ApplicationModel;

	import osmf.patch.SmoothedMediaFactory;

	import robotlegs.bender.framework.api.IContext;

	import flash.geom.Rectangle;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class PlayerInjections {
		[Inject]
		public var context : IContext;
		/**
		 * @private
		 */
		private var config : IAyyoPlayerConfig;
		/**
		 * @private
		 */
		private var screen : Rectangle;
		/**
		 * @private OSMF media factory instance
		 */
		private var factory : SmoothedMediaFactory;

		[PostConstruct]
		public function initialize() : void {
			this.initTools();
			this.initPlayer();
			
		}

		[PreDestroy]
		public function destroy() : void {
			this.context.injector.unmap(IAyyoPlayerConfig);
			this.context.injector.unmap(Rectangle, "screen");
			this.context.injector.unmap(IApplicationModel);
			this.context.injector.unmap(SmoothedMediaFactory);
			
			this.config = null;
			this.screen = null;
			this.factory = null;
			
			this.context = null;
		}
		
		/**
		 * @private initializes tools
		 * @return void
		 */
		private function initTools() : void {
			this.config = new FlashVarsConfig();
			this.screen = new Rectangle();
			
			this.context.injector.map(IAyyoPlayerConfig).toValue(this.config);
			this.context.injector.map(Rectangle, "screen").toValue(this.screen);
			this.context.injector.map(IApplicationModel).toSingleton(ApplicationModel);
		}
		
		/**
		 * @private initializes OSMF player
		 * @return void
		 */
		private function initPlayer() : void {
			this.factory = new SmoothedMediaFactory();
			
			this.context.injector.map(SmoothedMediaFactory).toValue(this.factory);
		}
	}
}
