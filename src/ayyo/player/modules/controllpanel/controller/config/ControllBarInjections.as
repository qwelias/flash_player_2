package ayyo.player.modules.controllpanel.controller.config {
	import me.scriptor.mvc.model.api.IApplicationModel;
	import me.scriptor.mvc.model.impl.ApplicationModel;

	import robotlegs.bender.framework.api.IContext;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ControllBarInjections {
		[Inject]
		public var context : IContext;

		[PostConstruct]
		public function initialize() : void {
			this.context.injector.map(IApplicationModel).toSingleton(ApplicationModel);
		}

		[PreDestroy]
		public function destroy() : void {
			this.context.injector.unmap(IApplicationModel);

			this.context = null;
		}
	}
}
