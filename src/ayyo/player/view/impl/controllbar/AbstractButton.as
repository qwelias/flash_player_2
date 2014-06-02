package ayyo.player.view.impl.controllbar {
	import ayyo.player.view.api.IButton;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.sets.InteractiveObjectSignalSet;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class AbstractButton extends Sprite implements IButton {
		/**
		 * @private
		 */
		private var _action : Signal;
		/**
		 * @private
		 */
		private var isCreated : Boolean;
		/**
		 * @private
		 */
		private var _signals : InteractiveObjectSignalSet;
		/**
		 * @private
		 */
		private var _state : String;

		public function AbstractButton(autoCreate : Boolean = true) {
			// TODO disable instanciation of abstract class
			autoCreate && this.create();
		}
		
		public function click() : void {
			this.onButtonClick(null);
		}
		
		public function get signals() : InteractiveObjectSignalSet {
			return this._signals ||= new InteractiveObjectSignalSet(this);
		}

		public function enable() : void {
			if (!this.buttonMode) {
				this.signals.click.add(this.onButtonClick);
				this.enableButton();
				this.mouseChildren = false;
				this.mouseEnabled = this.buttonMode = true;
			}
		}

		protected function enableButton() : void {
		}

		public function disable() : void {
			if (this.buttonMode) {
				this.signals.click.remove(this.onButtonClick);
				this.disableButton();
				this.mouseChildren = true;
				this.mouseEnabled = this.buttonMode = false;
			}
		}

		protected function disableButton() : void {
		}

		public function get action() : ISignal {
			return this._action ||= new Signal(String);
		}

		public function get view() : DisplayObject {
			return this;
		}

		public function create() : void {
			if (!this.isCreated) {
				this.createButton();
				this.isCreated = true;
			}
		}

		protected function createButton() : void {
		}

		public function dispose() : void {
			if (this.isCreated) {
				this.disable();
				this.signals.removeAll();
				this._signals = null;
				this.disposeButton();
				this.parent && this.parent.removeChild(this);
				this.isCreated = false;
			}
		}

		protected function disposeButton() : void {
		}

		// Handlers
		protected function onButtonClick(event : MouseEvent) : void {
		}

		public function set state(value : String) : void {
			this._state = value;
		}

		public function get state() : String {
			return this._state ||= "";
		}
	}
}
