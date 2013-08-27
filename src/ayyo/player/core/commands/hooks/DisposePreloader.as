package ayyo.player.core.commands.hooks {
	import com.greensock.events.TweenEvent;
	import ayyo.player.core.model.PlayerConstants;
	import ayyo.player.preloader.api.IAyyoPreloader;

	import me.scriptor.mvc.model.api.IApplicationModel;

	import robotlegs.bender.framework.api.IHook;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class DisposePreloader implements IHook {
		[Inject]
		public var model : IApplicationModel;

		public function hook() : void {
			var preloader : IAyyoPreloader = this.model.getVariable(PlayerConstants.PRELOADER) as IAyyoPreloader;
			preloader.animationComplete.add(onTweenComplete);
			preloader.hide();
		}

		private function onTweenComplete(type : String, preloader : IAyyoPreloader) : void {
			if (type == TweenEvent.REVERSE_COMPLETE) {
				preloader.dispose();
				preloader = null;
				this.model.removeVariable(PlayerConstants.PRELOADER);
				this.model = null;
			}
		}
	}
}
