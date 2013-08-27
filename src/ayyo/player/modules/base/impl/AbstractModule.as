package ayyo.player.modules.base.impl {
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import robotlegs.bender.extensions.contextView.ContextView;
	import ayyo.player.modules.base.controller.config.ModulePrepare;
	import ayyo.player.bundles.ModuleBundle;
	import robotlegs.bender.framework.impl.Context;
	import robotlegs.bender.framework.api.IContext;
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
		/**
		 * @private
		 */
		private var _context : IContext;
		/**
		 * @private
		 */
		private var _dispatcher : IEventDispatcher;

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
				this.context.destroy();
				this.disposeModule();
				
				this._context = null;
				this._dispatcher = null;
				this.isCreated = false;
				this.parent && this.parent.removeChild(this);
			}
		}

		public function resize(screen : Rectangle = null) : void {
		}

		public function get view() : DisplayObject {
			return this;
		}
		
		public function get dispatcher() : IEventDispatcher {
			return this._dispatcher ||= this.context.injector.getInstance(IEventDispatcher) as IEventDispatcher;
		}

		public function initialize(moduleInfo : ModuleInfo) : void {
			this.context.	injector.map(ModuleInfo).toValue(moduleInfo);
			this.context.	install(ModuleBundle).
							configure(new ContextView(this), ModulePrepare);
			
			this.context.initialized ? this.onContextInited() : this.context.initialize(onContextInited);
		}

		public function get ready() : ISignal {
			return this._ready ||= new Signal();
		}
		
		public function get context() : IContext {
			return this._context ||= new Context();
		}
		
		override public function toString() : String {
			return super.toString();
		}
		
		protected function createModule() : void {
		}

		protected function disposeModule() : void {
		}

		protected function onContextInited() : void {
			this.dispatcher.dispatchEvent(new Event(Event.INIT));
		}
	}
}
