package ayyo.player.modules.splash.controller.config {
	import ayyo.player.modules.splash.controller.SplashImageMediator;
	import ayyo.player.modules.splash.view.api.ISplashImageHolder;

	import robotlegs.bender.extensions.matching.ITypeMatcher;
	import robotlegs.bender.extensions.matching.TypeMatcher;
	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class SplashMediatorsMapping {
		[Inject]
		public var mediatorMap : IMediatorMap;
		/**
		 * @private
		 */
		private var splashImageHolder : ITypeMatcher;

		[PostConstruct]
		public function initialize() : void {
			this.initMatchers();
			
			this.mediatorMap.mapMatcher(this.splashImageHolder).toMediator(SplashImageMediator);
		}

		private function initMatchers() : void {
			this.splashImageHolder = new TypeMatcher().anyOf(ISplashImageHolder);
		}

		[PreDestroy]
		public function destroy() : void {
			this.destroyMathcers();
			this.mediatorMap = null;
		}

		private function destroyMathcers() : void {
			this.splashImageHolder = null;
		}
	}
}
