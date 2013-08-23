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
			this.context.	install(MinimalDebugBundle).
							configure(new ContextView(this.appHolder)).
							afterInitializing(this.onContextReady);
			this.addChild(this.appHolder);
		}

		public function get appHolder() : Sprite {
			return this._appHolder ||= new Sprite();
		}
		
		public function get context() : IContext {
			return this._context ||= new Context();
		}


		// Handlers
		private function onContextReady() : void {
			this.context.	configure(PlayerInjections, PlayerMediatorsMapping, PlayerCommandsMapping).
							configure(PlayerLaunch);
		}
	}
}
