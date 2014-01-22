package ayyo.player.core.controller.appconfig {
	import ayyo.player.core.controller.ResizeObjectMediator;

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
		private var resizable : ITypeMatcher;

		[PostConstruct]
		public function initialize() : void {
			this.initMatchers();

			this.mediatorMap.mapMatcher(this.resizable).toMediator(ResizeObjectMediator);
		}

		private function initMatchers() : void {
			this.resizable = new TypeMatcher().anyOf(IResizable);
		}

		[PreDestroy]
		public function destroy() : void {
			this.mediatorMap.unmapMatcher(this.resizable).fromMediator(ResizeObjectMediator);

			this.disposeMatchers();
			this.mediatorMap = null;
		}

		private function disposeMatchers() : void {
			this.resizable = null;
		}
	}
}
