package ayyo.player.modules.base.impl {
	import ayyo.player.modules.base.api.IAyyoPlayerModule;
	import ayyo.player.modules.info.impl.ModuleInfo;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class AbstractModule extends Sprite implements IAyyoPlayerModule {
		/**
		 * @private
		 */
		private var isCreated : Boolean;
		/**
		 * @private
		 */
		private var _ready : Signal;

		public function AbstractModule(autoCreate : Boolean = false) {
			var className : String = getQualifiedClassName(this);
			var description : String = "ayyo.player.modules.base.impl::AbstractModule";
			if (description == className) {
				throw new Error("You can't create instances of abstract class.");
			}
			autoCreate && this.create();
		}

		public function create() : void {
			if (!this.isCreated) {
				this.createModule();
				this.isCreated = true;
			}
		}

		public function dispose() : void {
			if (this.isCreated) {
				this.disposeModule();
				this.isCreated = false;
			}
		}

		public function resize(screen : Rectangle = null) : void {
		}

		public function get view() : DisplayObject {
			return this;
		}

		public function initialize(moduleInfo : ModuleInfo) : void {
		}

		public function get ready() : ISignal {
			return this._ready ||= new Signal();
		}
		
		override public function toString() : String {
			return super.toString();
		}
		
		protected function createModule() : void {
		}

		protected function disposeModule() : void {
		}
	}
}
