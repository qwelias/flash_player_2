package ayyo.player.core.controller {
	import flash.geom.Rectangle;
	import me.scriptor.additional.api.IResizable;

	import robotlegs.bender.extensions.mediatorMap.api.IMediator;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.natives.NativeSignal;

	import flash.events.Event;
	import flash.events.IEventDispatcher;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ResizeObjectMediator implements IMediator {
		[Inject]
		public var item : IResizable;
		[Inject(name="screen")]
		public var screen : Rectangle;
		[Inject]
		public var dispatcher : IEventDispatcher;
		/**
		 * @private
		 */
		private var _reszied : ISignal;

		public function initialize() : void {
			this.reszied.add(this.onApplicationReszied);
			this.onApplicationReszied(null);
		}

		public function destroy() : void {
			this.reszied.remove(this.onApplicationReszied);
			this.dispatcher = null;
			this.item = null;
			this.screen = null;
			this._reszied = null;
		}

		public function get reszied() : ISignal {
			return this._reszied ||= new NativeSignal(this.dispatcher, Event.RESIZE);
		}

		// Handlers
		/**
		 * @eventType flash.events.Event.RESIZE
		 */
		private function onApplicationReszied(event : Event) : void {
			this.item.resize(this.screen);
		}
	}
}
