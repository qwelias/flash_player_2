package ayyo.player.plugins.test.info {
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaFactoryItemType;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfo;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.net.StreamType;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class TestPluginInfo extends PluginInfo {
		public function TestPluginInfo() {
			var items : Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
			var item : MediaFactoryItem = new MediaFactoryItem("ayyo.player.plugin.test", this.canHandleResourceFunction, this.mediaElementCreationFunction, MediaFactoryItemType.PROXY);
			items.push(item);
			super(items);
		}

		private function canHandleResourceFunction(resourse : MediaResourceBase) : Boolean {
			trace("TestPlginInfo.canHandleResourceFunction(resourse)");
			var source : DynamicStreamingResource = resourse as DynamicStreamingResource;
			var result : Boolean = source && (source.streamType == StreamType.RECORDED || source.streamType == StreamType.LIVE_OR_RECORDED);
			return result;
		}

		private function mediaElementCreationFunction() : MediaElement {
			trace("TestPlginInfo.mediaElementCreationFunction()");
			return new TestProxyElement();
		}

		override public function initializePlugin(resource : MediaResourceBase) : void {
			trace("TestPlginInfo.initializePlugin(resource)");
			super.initializePlugin(resource);
		}
	}
}
