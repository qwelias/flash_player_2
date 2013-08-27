package ayyo.player.core.commands.hooks {
	import flash.system.Capabilities;
	import flash.geom.Rectangle;
	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.framework.api.IHook;

	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class InitStageOptions implements IHook {
		[Inject]
		public var contextView : ContextView;

		public function hook() : void {
			var stage : Stage = this.contextView.view.stage;

			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.stageFocusRect = false;
			stage.frameRate = 60;
			stage.fullScreenSourceRect = new Rectangle(0, 0, Capabilities.screenResolutionX, Capabilities.screenResolutionY);
			stage.showDefaultContextMenu = false;

			this.dispose();
		}

		private function dispose() : void {
			this.contextView = null;
		}
	}
}
