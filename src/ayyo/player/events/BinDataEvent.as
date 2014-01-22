package ayyo.player.events {
	import ayyo.player.core.model.DataType;

	import flash.events.Event;
	import flash.utils.ByteArray;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class BinDataEvent extends Event {
		public static const LOAD : String = "loadBinaryData";
		public static const LOADED : String = "binaryItemLoaded";
		/**
		 * @private
		 */
		private var _dataType : String;
		private var _data : ByteArray;

		public function BinDataEvent(type : String, dataType : String, data : ByteArray = null) {
			super(type, false, false);
			this._dataType = dataType;
			this._data = data;
		}

		public function get dataType() : String {
			return this._dataType ||= DataType.ASSETS;
		}

		public function get data() : ByteArray {
			return this._data;
		}
	}
}
