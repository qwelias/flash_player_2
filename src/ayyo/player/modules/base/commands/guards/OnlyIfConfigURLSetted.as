package ayyo.player.modules.base.commands.guards {
	import ayyo.player.modules.info.impl.ModuleInfo;

	import robotlegs.bender.framework.api.IGuard;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class OnlyIfConfigURLSetted implements IGuard {
		[Inject]
		public var info : ModuleInfo;

		public function approve() : Boolean {
			var result : Boolean = this.info.config && this.info.config.length > 0;
			this.info = null;
			return result;
		}
	}
}
