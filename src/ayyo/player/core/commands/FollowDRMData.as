package ayyo.player.core.commands {
	import robotlegs.bender.framework.api.ILogger;
	import ayyo.player.core.model.JavascriptFunctions;
	import ayyo.player.events.PlayerEvent;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;

	import org.osmf.events.DRMEvent;
	import org.osmf.traits.DRMState;
	import org.osmf.traits.DRMTrait;

	import flash.events.IEventDispatcher;

	/**
	 * @author Aziz Zaynutdinov (aziz.zaynutdinov at playstorm.com)
	 */
	public class FollowDRMData implements ICommand {
		[Inject]
		public var event : PlayerEvent;
		[Inject]
		public var logger : ILogger;
		[Inject]
		public var dispatcher : IEventDispatcher;
		/**
		 * @private
		 */
		private var drm : DRMTrait;

		public function execute() : void {
			this.drm = this.event.params[0] as DRMTrait;
			this.drm ? this.drm.addEventListener(DRMEvent.DRM_STATE_CHANGE, this.onDRMStateChange) : this.dispose();
		}

		private function dispose() : void {
			this.drm && this.drm.hasEventListener(DRMEvent.DRM_STATE_CHANGE) && this.drm.removeEventListener(DRMEvent.DRM_STATE_CHANGE, this.onDRMStateChange);
			this.drm = null;
			this.dispatcher = null;
			this.event = null;
		}

		// Handlers
		private function onDRMStateChange(event : DRMEvent) : void {
			if (event.drmState == DRMState.AUTHENTICATION_ERROR) {
				this.logger.error("DRM Auth error");
				this.dispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.SEND_TO_JS, [JavascriptFunctions.LICENSE_ERROR]));
				this.dispose();
			} else {
				this.logger.debug("DRM state changed to '{0}'", [event.drmState]);
			}
		}
	}
}
