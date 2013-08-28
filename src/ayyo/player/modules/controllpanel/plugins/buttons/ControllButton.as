package ayyo.player.modules.controllpanel.plugins.buttons {
	import ayyo.player.core.model.PlayerConstants;
	import ayyo.player.modules.controllpanel.model.ButtonState;
	import ayyo.player.modules.controllpanel.plugins.api.IControlPanelPlugin;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.sets.InteractiveObjectSignalSet;

	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ControllButton extends Sprite implements IControlPanelPlugin {
		/**
		 * @private
		 */
		private var isCreated : Boolean;
		/**
		 * @private
		 */
		private var _action : Signal;
		/**
		 * @private
		 */
		private var _matrix : Matrix;
		/**
		 * @private
		 */
		private var _signals : InteractiveObjectSignalSet;

		public function ControllButton(autoCreate : Boolean = true) {
			autoCreate && this.create();
		}

		public function create() : void {
			if (!this.isCreated) {
				this.mouseChildren = false;
				this.drawState(ButtonState.NORMAL);
				this.isCreated = true;
			}
		}

		public function dispose() : void {
			if (this.isCreated) {
				this.disable();
				this.matrix.identity();
				this.action.removeAll();
				this._signals = null;
				this._matrix = null;
				this._action = null;
				this.isCreated = false;
				this.parent && this.parent.removeChild(this);
			}
		}

		public function enable() : void {
			if(!this.buttonMode) {
				this.signals.rollOver.add(this.onRolloverRollout);
				this.signals.rollOut.add(this.onRolloverRollout);
				this.signals.mouseDown.add(this.onMouseDownMouseUp);
				this.signals.mouseUp.add(this.onMouseDownMouseUp);
				this.signals.click.add(this.onButtonClick);
				this.buttonMode = this.mouseEnabled = true;
			}
		}

		public function disable() : void {
			if(this.buttonMode) {
				this.signals.removeAll();
				this.buttonMode = this.mouseEnabled = false;
			}
		}

		public function get action() : ISignal {
			return this._action ||= new Signal(String);
		}

		public function get view() : DisplayObject {
			return this;
		}
		
		public function get signals() : InteractiveObjectSignalSet {
			return this._signals ||= new InteractiveObjectSignalSet(this);
		}

		public function get matrix() : Matrix {
			return this._matrix ||= new Matrix();
		}

		protected function drawState(state : String) : void {
			this.matrix.identity();
			this.matrix.createGradientBox(PlayerConstants.CONTROL_BUTTON_PLAY_PAUSE_WIDTH, PlayerConstants.CONTROL_BUTTON_PLAY_PAUSE_HEIGHT, -Math.PI / 2);
			this.graphics.clear();
			this.graphics.beginGradientFill(GradientType.LINEAR, PlayerConstants.COLOR[state], [1, 1], [0, 0xff], this.matrix);
			this.graphics.drawRect(0, 0, PlayerConstants.CONTROL_BUTTON_PLAY_PAUSE_WIDTH, PlayerConstants.CONTROL_BUTTON_PLAY_PAUSE_HEIGHT);
		}
		
		//	Handlers
		protected function onRolloverRollout(event : MouseEvent) : void {
			this.drawState(event.type == MouseEvent.ROLL_OVER ? ButtonState.HOVER : ButtonState.NORMAL);
		}
		
		protected function onMouseDownMouseUp(event : MouseEvent) : void {
			var point : Point = new Point(this.mouseX, this.mouseY);
			var bounds : Rectangle = this.getBounds(this);
			this.drawState(event.type == MouseEvent.MOUSE_DOWN ? ButtonState.CLICKED : (bounds.containsPoint(point) ? ButtonState.HOVER : ButtonState.NORMAL));
		}

		protected function onButtonClick(event : MouseEvent) : void {
			this.action.dispatch("Button");
		}
	}
}
