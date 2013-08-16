package ayyo.player.modules.info.impl {
	import ayyo.player.modules.info.api.IModuleInfoMap;
	import ayyo.player.modules.info.api.IModuleInfoMapper;

	import me.scriptor.additional.clearDictionary;

	import robotlegs.bender.framework.api.IContext;

	import flash.utils.Dictionary;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ModuleInfoMap implements IModuleInfoMap {
		/**
		 * @private
		 */
		private var isCreated : Boolean;
		/**
		 * @private
		 */
		private var _mappers : Dictionary;
		/**
		 * @private
		 */
		private var _context : IContext;
		/**
		 * @private
		 */
		private var _handler : ModuleInfoHandler;

		public function ModuleInfoMap(context : IContext, autoCreate : Boolean = true) {
			this._context = context;
			autoCreate && this.create();
		}

		public function create() : void {
			if (!this.isCreated) {
				this.isCreated = true;
			}
		}

		public function dispose() : void {
			if (this.isCreated) {
				this.handler.dispose();
				clearDictionary(this.mappers);
				this._mappers = null;
				this._context = null;
				this._handler = null;
				this.isCreated = false;
			}
		}

		public function map(info : ModuleInfo) : IModuleInfoMapper {
			return this.mappers[info] ||= this.createMapper(info);
		}

		public function unmap(info : ModuleInfo) : IModuleInfoMapper {
			return this.mappers[info];
		}

		public function get mappers() : Dictionary {
			return this._mappers ||= new Dictionary();
		}
		
		public function get handler() : ModuleInfoHandler {
			return this._handler ||= new ModuleInfoHandler();
		}

		private function createMapper(info : ModuleInfo) : IModuleInfoMapper {
			return new ModuleInfoMapper(info, this.handler, this._context.getLogger(this));
		}
	}
}
