package ayyo.player {
	import ayyo.player.bundles.MinimalDebugBundle;
	import ayyo.player.core.controller.appconfig.PlayerCommandsMapping;
	import ayyo.player.core.controller.appconfig.PlayerInjections;
	import ayyo.player.core.controller.appconfig.PlayerLaunch;
	import ayyo.player.core.controller.appconfig.PlayerMediatorsMapping;
	import ayyo.player.events.ResizeEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.external.ExternalInterface;
	
	import org.osflash.signals.ISignal;
	import org.osflash.signals.natives.NativeSignal;
	
	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.impl.Context;

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
		/**
		 * @private
		 */
		private var _resize : NativeSignal;
		/**
		 * @private
		 */
		private var _dispatcher : IEventDispatcher;

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
		
		public function get dispatcher() : IEventDispatcher {
			return this._dispatcher ||= this.context.injector.getInstance(IEventDispatcher) as IEventDispatcher;
		}
		
		public function get resize() : ISignal {
			return this._resize ||= new NativeSignal(this.stage, Event.RESIZE);
		}


		// Handlers
		private function onContextReady() : void {
			trace("--> 1")
			this.context.	configure(PlayerInjections, PlayerMediatorsMapping, PlayerCommandsMapping).
							configure(PlayerLaunch);
			trace("--> 2")
			
//			this.resize.add(this.onStageReszied);
			this.onStageReszied(null);
		}
		
		/**
		 * @eventType flash.events.Event.RESIZE
		 */
		private function onStageReszied(event : Event) : void {
//			this.dispatcher.dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE, this.stage.stageWidth, this.stage.stageHeight));
			this.dispatcher.dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE, 720, 480));
		}
	}
}
