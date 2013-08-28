package ayyo.player.modules.controllpanel.controller {
	import ayyo.player.modules.controllpanel.plugins.api.IControllPanelPlugin;

	import robotlegs.bender.extensions.mediatorMap.api.IMediator;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ControllPanelPluginMediator implements IMediator {
		[Inject]
		public var plugin : IControllPanelPlugin;

		public function initialize() : void {
		}

		public function destroy() : void {
			this.plugin = null;
		}
	}
}
