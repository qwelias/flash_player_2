package ayyo.player.core.commands.guards {
	import ayyo.player.core.model.PlayerConstants;
	import me.scriptor.mvc.model.api.IApplicationModel;
	import robotlegs.bender.framework.api.IGuard;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class OnlyIfPreloaderExists implements IGuard {
		[Inject]
		public var model : IApplicationModel;
		
		public function approve() : Boolean {
			var result : Boolean = this.model.getVariable(PlayerConstants.PRELOADER) != null;
			this.model = null;
			return result;
		}
	}
}
