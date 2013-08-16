package ayyo.player {
	import ayyo.player.bundles.MinimalDebugBundle;
	import ayyo.player.core.controller.appconfig.PlayerCommandsMapping;
	import ayyo.player.core.controller.appconfig.PlayerInjections;
	import ayyo.player.core.controller.appconfig.PlayerLaunch;
	import ayyo.player.core.controller.appconfig.PlayerMediatorsMapping;

	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.impl.Context;

	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	[SWF(backgroundColor="#000000", frameRate="60", width="640", height="480")]
	public class AyyoPlayer extends Sprite {
		/**
		 * @private
		 */
		private var _context : IContext;
		/**
		 * @private
		 */
		private var _appHolder : Sprite;

		public function AyyoPlayer() {
			this.stage ? this.init() : this.waitForStage();
		}

		public function get context() : IContext {
			return this._context ||= new Context().
				install(MinimalDebugBundle).
				configure(new ContextView(this.appHolder), PlayerInjections, PlayerMediatorsMapping, PlayerCommandsMapping);
		}

		public function get appHolder() : Sprite {
			return this._appHolder ||= new Sprite();
		}

		private function init() : void {
			this.addChild(this.appHolder);
			this.context.initialize(this.onContextReady);
		}

		private function waitForStage() : void {
			this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
		}

		// Handlers
		/**
		 * @eventType flash.event.Event.ADDED_TO_STAGE
		 * @private app added to stage 
		 */
		private function onAddedToStage(event : Event) : void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
			this.init();
		}

		private function onContextReady() : void {
			this.context.configure(PlayerLaunch);
		}
	}
}
