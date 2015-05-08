package ayyo.player.config.impl.support {
	import ayyo.player.config.api.IAyyoVideoSettings;
	
	import flash.external.ExternalInterface;
	import flash.system.Capabilities;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class VideoSettings implements IAyyoVideoSettings {
		/**
		 * @private
		 */
		private var _url : String;
		/**
		 * @private
		 */
		private var _token : String;
		
		private var _sessionid : String;
		private var _contentid : String;
		private var _countrycode : String;
		private var _clientkey : String;

		public function get url() : String {
			return this._url;
		}

		public function get token() : String {
			return this._token && "type=online," + this._token + ",os=" + escape(Capabilities.os) +",flashversion=" + escape(Capabilities.version) + ",browser=" + "unknown";
		}
		
		public function get tokenShards() : Object
		{
			var shards:Object = {
				sessionid:this._sessionid,
				contentid:this._contentid,
				countrycode:this._countrycode,
				clientkey:this._clientkey
			};
			return shards;
		}

		public function initialize(source : Object) : void {
			for (var property : String in source) {
				if (property in this) this["_" + property] = source[property];
			}
		}
	}
}
