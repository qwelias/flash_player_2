package ayyo.player.modules.base.commands.hooks {
	import flash.display.Stage;

	import robotlegs.bender.extensions.contextView.ContextView;

	import me.scriptor.additional.api.IResizable;

	import robotlegs.bender.framework.api.IHook;

	import flash.geom.Rectangle;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ResizeModule implements IHook {
		[Inject(name="module")]
		public var module : IResizable;
		[Inject]
		public var contextView : ContextView;

		public function hook() : void {
			var stage : Stage = this.contextView.view.stage;
			if (stage) {
				var screen : Rectangle = new Rectangle(0, stage.stageWidth, stage.stageHeight);
				this.module.resize(screen);
				screen = null;
				stage = null;
			}
			this.dispose();
		}

		private function dispose() : void {
			this.module = null;
			this.contextView = null;
		}
	}
}
