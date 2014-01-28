package me.scriptor.math {
	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class Interval {
		/**
		 * @private
		 */
		private var _start : Number;
		/**
		 * @private
		 */
		private var _end : Number;

		public function Interval(startValue : Number = 0, endValue : Number = 0) {
			this.start = startValue;
			this.end = endValue;
		}

		public function get start() : Number {
			return this._start;
		}

		public function get end() : Number {
			return this._end;
		}

		public function get length() : Number {
			return this.end - this.start;
		}

		public function set start(value : Number) : void {
			this._start != value && (this._start = value);
		}

		public function set end(value : Number) : void {
			this._end != value && (this._end = value);
		}
	}
}
