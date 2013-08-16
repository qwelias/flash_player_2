package ayyo.player.modules.info.impl {
	import ayyo.player.modules.base.api.IAyyoPlayerModule;

	import me.scriptor.additional.api.IDisposable;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ModuleInfoHandler implements IDisposable {
		/**
		 * @private
		 */
		private var isCreated : Boolean;
		/**
		 * @private
		 */
		private var _onHandle : ISignal;

		public function ModuleInfoHandler(autoCreate : Boolean = true) {
			autoCreate && this.create();
		}

		public function create() : void {
			if (!this.isCreated) {
				this.isCreated = true;
			}
		}

		public function dispose() : void {
			if (this.isCreated) {
				this.onHandle.removeAll();
				this._onHandle = null;
				this.isCreated = false;
			}
		}

		public function process(module : IAyyoPlayerModule) : void {
			this.onHandle.dispatch(module);
		}


		public function get onHandle() : ISignal {
			return this._onHandle ||= new Signal(IAyyoPlayerModule);
		}
	}
}
