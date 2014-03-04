package ayyo.player.view.impl.controllbar {
	import me.scriptor.additional.api.IResizable;

	import flash.display.Sprite;
	import flash.geom.Rectangle;

	/**
	 * @author Aziz Zaynutdinov (aziz.zaynutdinov at playstorm.com)
	 */
	public class ActiveZone extends Sprite implements IResizable {
		public function resize(screen : Rectangle = null) : void {
			if(screen) {
				this.graphics.clear();
				this.graphics.beginFill(0xff0000, 0);
				this.graphics.drawRect(screen.x, screen.y, screen.width, screen.height);
			}
		}
	}
}
