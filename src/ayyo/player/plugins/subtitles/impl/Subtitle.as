package ayyo.player.plugins.subtitles.impl {
	import me.scriptor.math.Interval;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class Subtitle {
		/**
		 * @private
		 */
		private var _lines : Vector.<String>;
		/**
		 * @private
		 */
		private var _interval : Interval;

		public function Subtitle(source : String) {
			var array : Array = source.split(/[\r\n]/);
			var line : String;
			var count : int = 0;
			while (array.length > 0) {
				line = (array.shift() as String).replace(/^\s+|\s+$/, '');
				if (line.length > 0) {
					if (count == 0) {
						var timecodes : Array = line.split(/\s+-->\s+/);
						this.interval.start = this.stringToSeconds(timecodes[0]);
						this.interval.end = this.stringToSeconds(timecodes[1]);
					} else
						this.lines.push(line);
					count++;
				}
			}
		}

		public function dispose() : void {
			while(this.lines.length > 0) this.lines.pop();
			this._lines = null;
			this._interval = null;
		}

		public function get lines() : Vector.<String> {
			return _lines ||= new Vector.<String>();
		}

		public function toString() : String {
			return "[Subtitle] text:" + this.lines + "\nStarts at:" + this.interval.start.toString() + "\nEnds at:" + this.interval.end.toString();
		}

		public function get interval() : Interval {
			return this._interval ||= new Interval();
		}

		private function stringToSeconds(string : String) : Number {
			var array : Array = string.split(/[\:\,]/);
			var sec : Number = 0;
			if (array.length == 4) {
				sec = 3600 * Number(array[0]) + 60 * Number(array[1]) + Number(array[2]) + 0.001 * Number(array[3]);
			}
			return sec;
		}
	}
}
