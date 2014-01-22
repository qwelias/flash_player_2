package ayyo.player.plugins.test.info {
	import org.osmf.elements.ProxyElement;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.metadata.Metadata;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class TestProxyElement extends ProxyElement {
		public function TestProxyElement(element : MediaElement = null) {
			super(element);
		}

		override public function set proxiedElement(value : MediaElement) : void {
			trace('value: ' + (value));
			trace("TestProxyElement.proxiedElement(value)");
			super.proxiedElement = value;
			if (value == null) return;
			this.proxiedElement.addEventListener(MediaElementEvent.METADATA_ADD, this.onMetaDataAdd);
			this.onMetaDataAdd(null);
		}

		private function extractData(subs : Metadata) : void {
			this.proxiedElement.removeEventListener(MediaElementEvent.METADATA_ADD, this.onMetaDataAdd);
			this.proxiedElement.removeMetadata("subs");
			trace('subs.keys: ' + (subs.keys));
		}

		private function onMetaDataAdd(event : MediaElementEvent) : void {
			trace("TestProxyElement.onMetaDataAdd(event)");
			var subs : Metadata = this.proxiedElement.getMetadata("subs");
			subs && this.extractData(subs);
		}
	}
}
