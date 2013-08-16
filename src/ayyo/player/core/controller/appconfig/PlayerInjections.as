package ayyo.player.core.controller.appconfig {
	import ayyo.player.config.api.IPlayerConfig;
	import ayyo.player.config.impl.FlashVarsConfig;
	import ayyo.player.modules.info.api.IModuleInfoMap;
	import ayyo.player.modules.info.impl.ModuleInfoMap;

	import robotlegs.bender.framework.api.IContext;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class PlayerInjections {
		[Inject]
		public var context : IContext;
		/**
		 * @private
		 */
		private var config : IPlayerConfig;
		/**
		 * @private
		 */
		private var moduleInfoMap : IModuleInfoMap;

		[PostConstruct]
		public function initialize() : void {
			this.config = new FlashVarsConfig();
			this.moduleInfoMap = new ModuleInfoMap(this.context);
			
			this.context.injector.map(IPlayerConfig).toValue(this.config);
			this.context.injector.map(IModuleInfoMap).toValue(this.moduleInfoMap);
		}

		[PreDestroy]
		public function destroy() : void {
			this.context.injector.unmap(IPlayerConfig);
			this.context.injector.unmap(IModuleInfoMap);
			
			this.moduleInfoMap.dispose();
			
			this.config = null;
			this.moduleInfoMap = null;
			this.context = null;
		}
	}
}
