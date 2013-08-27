package ayyo.player.core.controller.appconfig {
	import me.scriptor.mvc.model.impl.ApplicationModel;
	import me.scriptor.mvc.model.api.IApplicationModel;
	import ayyo.player.config.api.IAyyoPlayerConfig;
	import ayyo.player.config.impl.FlashVarsConfig;
	import ayyo.player.modules.info.api.IModuleInfoMap;
	import ayyo.player.modules.info.impl.ModuleInfoMap;

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
		private var moduleInfoMap : IModuleInfoMap;
		/**
		 * @private
		 */
		private var screen : Rectangle;

		[PostConstruct]
		public function initialize() : void {
			this.config = new FlashVarsConfig();
			this.moduleInfoMap = new ModuleInfoMap(this.context);
			this.screen = new Rectangle();
			
			this.context.injector.map(IAyyoPlayerConfig).toValue(this.config);
			this.context.injector.map(IModuleInfoMap).toValue(this.moduleInfoMap);
			this.context.injector.map(Rectangle, "screen").toValue(this.screen);
			this.context.injector.map(IApplicationModel).toSingleton(ApplicationModel);
		}

		[PreDestroy]
		public function destroy() : void {
			this.context.injector.unmap(IAyyoPlayerConfig);
			this.context.injector.unmap(IModuleInfoMap);
			this.context.injector.unmap(Rectangle, "screen");
			this.context.injector.unmap(IApplicationModel);
			
			this.moduleInfoMap.dispose();
			
			this.config = null;
			this.screen = null;
			this.moduleInfoMap = null;
			this.context = null;
		}
	}
}
