package ayyo.player.modules.info.impl {
	import ayyo.player.modules.base.api.IAyyoPlayerModule;
	import ayyo.player.modules.info.api.IModuleInfoMapper;

	import me.scriptor.additional.clearDictionary;

	import robotlegs.bender.framework.api.ILogger;

	import flash.utils.Dictionary;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ModuleInfoMapper implements IModuleInfoMapper {
		/**
		 * @private
		 */
		private var isCreated : Boolean;
		/**
		 * @private
		 */
		private var _mappings : Dictionary;
		/**
		 * @private
		 */
		private var _info : ModuleInfo;
		/**
		 * @private
		 */
		private var _logger : ILogger;
		/**
		 * @private
		 */
		private var _handler : ModuleInfoHandler;

		public function ModuleInfoMapper(info : ModuleInfo, handler : ModuleInfoHandler, logger : ILogger, autoCreate : Boolean = true) {
			this._info = info;
			this._logger = logger;
			this._handler = handler;
			autoCreate && this.create();
		}

		public function create() : void {
			if (!this.isCreated) {
				this._handler && this._handler.onHandle.add(this.onModuleHandle);
				this.isCreated = true;
			}
		}

		public function dispose() : void {
			if (this.isCreated) {
				clearDictionary(this.mappings);
				this._handler && this._handler.onHandle.remove(this.onModuleHandle);
				this._mappings = null;
				this._info = null;
				this._logger = null;
				this._handler = null;
				this.isCreated = false;
			}
		}

		public function toModule(module : IAyyoPlayerModule) : void {
			this.mappings[module] && this._logger.warn("Module info for {0} already exists. Overwriting.", [module]);
			this.mappings[module] = this._info;
		}

		public function fromModule(module : IAyyoPlayerModule) : void {
			delete this.mappings[module];
		}

		public function get mappings() : Dictionary {
			return this._mappings ||= new Dictionary();
		}

		public function get info() : ModuleInfo {
			return this._info;
		}
		
		//	Handlers
		private function onModuleHandle(module : IAyyoPlayerModule) : void {
			if(this.mappings[module] && this.mappings[module] is ModuleInfo) {
				module.initialize(this.mappings[module] as ModuleInfo);
				this._logger.debug("Module info provided to {0}", [module]);
				this.dispose();
			}
		}
	}
}
