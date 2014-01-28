package ayyo.player.core.commands.hooks {
	import ayyo.player.view.impl.PlayerControllBar;

	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.framework.api.IHook;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class InitInterface implements IHook {
		[Inject]
		public var contextView : ContextView;

		public function hook() : void {
			this.contextView.view.addChild(new PlayerControllBar());

			this.dispose();
		}

		private function dispose() : void {
			this.contextView = null;
		}
	}
}
