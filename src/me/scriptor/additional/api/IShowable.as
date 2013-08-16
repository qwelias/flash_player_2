package me.scriptor.additional.api {
	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public interface IShowable {
		function show(isImmediately : Boolean = false) : void;

		function hide(isImmediately : Boolean = false) : void;
	}
}
