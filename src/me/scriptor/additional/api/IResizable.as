package me.scriptor.additional.api {
	import flash.geom.Rectangle;

	/**
	 * @author Aziz Zaynutdinov
	 */
	public interface IResizable {
		function resize(screen : Rectangle = null) : void;
	}
}
