package ayyo.player.core.controller.appconfig {
	import ayyo.player.core.controller.PlayerModuleMediator;
	import ayyo.player.modules.base.api.IAyyoPlayerModule;

	import robotlegs.bender.extensions.matching.ITypeMatcher;
	import robotlegs.bender.extensions.matching.TypeMatcher;
	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class PlayerMediatorsMapping {
		[Inject]
		public var mediatorMap : IMediatorMap;
		/**
		 * @private
		 */
		private var playerModule : ITypeMatcher;

		[PostConstruct]
		public function initialize() : void {
			this.initMatchers();

			this.mediatorMap.mapMatcher(this.playerModule).toMediator(PlayerModuleMediator);
		}

		private function initMatchers() : void {
			this.playerModule = new TypeMatcher().anyOf(IAyyoPlayerModule);
		}

		[PreDestroy]
		public function destroy() : void {
			this.mediatorMap.unmapMatcher(this.playerModule).fromMediator(PlayerModuleMediator);

			this.disposeMatchers();
			this.mediatorMap = null;
		}

		private function disposeMatchers() : void {
			this.playerModule = null;
		}
	}
}
