package ayyo.player.plugins.subtitles.impl {
	import ayyo.player.plugins.subtitles.impl.view.SubtextField;

	import org.osmf.elements.ProxyElement;
	import org.osmf.events.TimelineMetadataEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.metadata.CuePoint;
	import org.osmf.metadata.CuePointType;
	import org.osmf.metadata.TimelineMetadata;

	import flash.display.DisplayObjectContainer;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class SubtitlesProxyElement extends ProxyElement {
		/**
		 * @private
		 */
		private var timelineMetaData : TimelineMetadata;
		/**
		 * @private
		 */
		private var subs : Vector.<Subtitle>;
		/**
		 * @private
		 */
		private var _subContainer : DisplayObjectContainer;
		/**
		 * @private
		 */
		private var _subField : SubtextField;

		public function SubtitlesProxyElement(element : MediaElement = null) {
			super(element);
		}

		public function set visible(value : Boolean) : void {
			if (this._subContainer)
				this.subField.visible = value;
		}

		override public function set proxiedElement(value : MediaElement) : void {
			if (value == null) return;
			super.proxiedElement = value;
			this.subs && this.initialize(this.subs);
		}

		public function set subContainer(value : DisplayObjectContainer) : void {
			this._subContainer = value;
			this._subContainer && this._subContainer.addChild(this.subField);
		}

		public function initialize(subtitles : Vector.<Subtitle>) : void {
			if (this.proxiedElement != null) {
				this.createTimelineData();
				const length : uint = subtitles.length;
				var marker : CuePoint;
				var count : uint = 0;
				var text : String = "";
				for (var i : int = 1; i < length; i++) {
					while (count < subtitles[i].lines.length) {
						text = text + (count == 0 ? "" : "\n") + subtitles[i].lines[count];
						count++;
					}
					marker = new CuePoint(CuePointType.ACTIONSCRIPT, subtitles[i].interval.start, "", text, subtitles[i].interval.length);
					this.timelineMetaData.addMarker(marker);
					text = "";
					count = 0;
				}
			} else {
				this.subs = subtitles;
			}
		}

		public function get subField() : SubtextField {
			if (!this._subField) {
				this._subField = new SubtextField();
				this._subContainer && this._subContainer.addChild(this._subField);
			}
			return this._subField;
		}

		private function createTimelineData() : void {
			this.timelineMetaData && this.disposeTimelineData();
			this.timelineMetaData = new TimelineMetadata(this.proxiedElement);
			this.timelineMetaData.addEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED, this.onSubtitlesShow);
			this.timelineMetaData.addEventListener(TimelineMetadataEvent.MARKER_DURATION_REACHED, this.onSubtitlesHide);
		}

		// Handlers
		private function disposeTimelineData() : void {
			if (this.timelineMetaData) {
				this.timelineMetaData.removeEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED, this.onSubtitlesShow);
				this.timelineMetaData.removeEventListener(TimelineMetadataEvent.MARKER_DURATION_REACHED, this.onSubtitlesHide);
				this.timelineMetaData = null;
			}
		}

		private function onSubtitlesShow(event : TimelineMetadataEvent) : void {
			var cue : CuePoint = event.marker as CuePoint;
			this.subField.text = cue.parameters as String;
		}

		private function onSubtitlesHide(event : TimelineMetadataEvent) : void {
			this.subField.text = "";
		}
	}
}
