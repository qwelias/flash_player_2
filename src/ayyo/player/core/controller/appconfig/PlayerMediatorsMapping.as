package ayyo.player.core.controller.appconfig {
	import ayyo.player.core.controller.PlayerModuleMediator;
	import ayyo.player.core.controller.ResizeObjectMediator;
	import ayyo.player.modules.base.api.IAyyoPlayerModule;

	import me.scriptor.additional.api.IResizable;

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
		/**
		 * @private
		 */
		private var resizable : ITypeMatcher;

		[PostConstruct]
		public function initialize() : void {
			this.initMatchers();

			this.mediatorMap.mapMatcher(this.playerModule).toMediator(PlayerModuleMediator);
			this.mediatorMap.mapMatcher(this.resizable).toMediator(ResizeObjectMediator);
		}

		private function initMatchers() : void {
			this.playerModule = new TypeMatcher().anyOf(IAyyoPlayerModule);
			this.resizable = new TypeMatcher().anyOf(IResizable);
		}

		[PreDestroy]
		public function destroy() : void {
			this.mediatorMap.unmapMatcher(this.playerModule).fromMediator(PlayerModuleMediator);
			this.mediatorMap.unmapMatcher(this.resizable).fromMediator(ResizeObjectMediator);

			this.disposeMatchers();
			this.mediatorMap = null;
		}

		private function disposeMatchers() : void {
			this.playerModule = null;
			this.resizable = null;
		}
	}
}
