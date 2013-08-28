package ayyo.player.modules.controllpanel.controller.config {
	import ayyo.player.modules.controllpanel.controller.ControllPanelPluginMediator;
	import ayyo.player.modules.controllpanel.plugins.api.IControllPanelPlugin;

	import robotlegs.bender.extensions.matching.ITypeMatcher;
	import robotlegs.bender.extensions.matching.TypeMatcher;
	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ControllBarMediatorsMapping {
		[Inject]
		public var mediaorMap : IMediatorMap;
		/**
		 * @private
		 */
		private var controllPanelPlugin : ITypeMatcher;

		[PostConstruct]
		public function initialize() : void {
			this.initMatchers();
			
			this.mediaorMap.mapMatcher(this.controllPanelPlugin).toMediator(ControllPanelPluginMediator);
		}

		private function initMatchers() : void {
			this.controllPanelPlugin = new TypeMatcher().anyOf(IControllPanelPlugin);
		}

		[PreDestroy]
		public function destroy() : void {
			this.mediaorMap.unmapMatcher(this.controllPanelPlugin).fromMediator(ControllPanelPluginMediator);
			
			this.destroyMathcers();
			this.mediaorMap = null;
		}

		private function destroyMathcers() : void {
			this.controllPanelPlugin = null;
		}
	}
}
