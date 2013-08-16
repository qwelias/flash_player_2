package me.scriptor.additional.api {
	import org.osflash.signals.ISignal;
	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public interface IHaveActionSignal {
		function get action() : ISignal;
	}
}
