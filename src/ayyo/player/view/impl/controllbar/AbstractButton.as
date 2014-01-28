package ayyo.player.view.impl.controllbar {
	import ayyo.player.view.api.IButton;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;

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
		private var _click : NativeSignal;

		public function AbstractButton(autoCreate : Boolean = true) {
			// TODO disable instanciation of abstract class
			autoCreate && this.create();
		}

		public function enable() : void {
			if (!this.buttonMode) {
				this._click.add(this.onButtonClick);
				this.enableButton();
				this.mouseChildren = false;
				this.mouseEnabled = this.buttonMode = true;
			}
		}

		protected function enableButton() : void {
		}

		public function disable() : void {
			if (this.buttonMode) {
				this._click.remove(this.onButtonClick);
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
				this._click = new NativeSignal(this, MouseEvent.CLICK);
				this.createButton();
				this.isCreated = true;
			}
		}

		protected function createButton() : void {
		}

		public function dispose() : void {
			if (this.isCreated) {
				this.disable();
				this._click = null;
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
	}
}
