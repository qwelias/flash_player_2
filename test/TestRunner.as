package {
	import suits.AllSuits;

	import org.flexunit.internals.TraceListener;
	import org.flexunit.listeners.CIListener;
	import org.flexunit.runner.FlexUnitCore;

	import flash.display.Sprite;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class TestRunner extends Sprite {
		/**
		 * @private
		 */
		private var core : FlexUnitCore;

		public function TestRunner() {
			this.core = new FlexUnitCore();
			this.core.addListener(new CIListener());
			this.core.addListener(new TraceListener());
			
			this.core.run(AllSuits);
		}
	}
}
