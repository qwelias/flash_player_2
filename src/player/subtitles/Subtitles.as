package player.subtitles
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import org.osmf.events.TimeEvent;
	import org.osmf.events.TimelineMetadataEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.metadata.CuePoint;
	import org.osmf.metadata.CuePointType;
	import org.osmf.metadata.TimelineMetadata;
	
	
	public class Subtitles extends Sprite
	{
		/*private var _subtitles:Array;
		private var _subsUrl:String;
		private var _subtitlesHandler:SubtitlesHandler;
		private var _subtitlesText:TLFTextField;
		private var _subtitlesTextFormat:TextFormat;
		private var _subsShowed:Boolean = false;
		private var _currentSubsIndex:Number = 0;*/
		
		private var subRight   :uint = 0;
		private var subLeft    :uint = 0;
		private var subTop     :uint = 0;
		private var subBottom  :uint = 0;
		private var subs:Object = [];
		private var subsHandler:Object = [];
		private var current:String = null;
		//private var   timelineMetaData:TimelineMetadata;
		private var       subTitleText:TextField = null;
		private var subTitleTextFormat:TextFormat;
		private var            subSize:Number;
		private var         subOutline:GlowFilter;
		private var            subBlur:BlurFilter;
		private var          subShadow:DropShadowFilter;
		
		
		private var mediaElement:MediaElement = null;
		
		public function Subtitles(me:MediaElement):void
		{
			mediaElement = me;
		}
		
		private function createSubtitlesObjects():void
		{
			if(ExternalInterface.available) ExternalInterface.call("console.log", "Subtitles: creating subtitles");
			subTitleText = new TextField();
			//subTitleText.embedFonts = true;
			subTitleText.antiAliasType = AntiAliasType.NORMAL;
			
			//subTitleText.defaultTextFormat = new TextFormat("PlaybackBlack", subSize, 0xffffff,
			//	null, null, null, null, null, null, null, null, null, -5);
			subTitleTextFormat = new TextFormat("PlaybackBlack", subSize, 0xffffff,
				null, null, null, null, null, null, null, null, null, -5);
			subTitleText.defaultTextFormat = subTitleTextFormat;
			subTitleText.autoSize = TextFieldAutoSize.LEFT;
			subTitleText.selectable = false;
			addChild(subTitleText);
			// add outline, blur & shadow
			subOutline = new GlowFilter(
				0,			//color
				1.0,		//alpha
				subSize/20,	//blurX
				subSize/20,	//blurY
				2,			//strength
				2			//quality
			);
			subBlur = new BlurFilter(
				subSize/24,
				subSize/24,
				2
			);
			subShadow = new DropShadowFilter(
				subSize/6,	//distance
				45,			//angle
				0,			//color
				0.75,		//alpha
				subSize/16,	//blurX
				subSize/16,	//blurY
				1,			//strength
				2			//quality
			);
			subTitleText.filters = [subBlur, subOutline, subShadow];
		}
		
		private function calcSubBounds():void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "Subtitles.calcSubBounds");
			}
			/*subTop    = (_mp_height - _playerHeight)/2 + _playerHeight*0.805;
			subBottom = subTop + _playerHeight*0.115;
			if(_mediaPlayerSprite.x <= 0)
			{
				subLeft  = 0.078*_mp_width;
				subRight = (1 - 0.078)*_mp_width;
			}
			else
			{
				subLeft  = _mediaPlayerSprite.x + 0.078*_playerWidth;
				subRight = _mediaPlayerSprite.x + (1 - 0.078)*_playerWidth;
			}*/
			
			subSize = this.height;
			
			if(subTitleText == null)
			{
				createSubtitlesObjects();
			}
			else
			{
				subTitleText.x     = this.width/2;
				subTitleText.y     = this.height/2;
				subOutline.blurX   = subSize/20;
				subOutline.blurY   = subSize/20;
				subBlur.blurX      = subSize/24;
				subBlur.blurY      = subSize/24;
				subShadow.distance = subSize/6;
				subShadow.blurX    = subSize/16;
				subShadow.blurY    = subSize/16;
			}
			//subTitleText.defaultTextFormat.size = subSize;
			subTitleTextFormat.size = subSize;
			subTitleText.visible = false;
			subTitleText.text  = "$";
			//subTitleText.setTextFormat(subTitleTextFormat);
			//subLineHeight      = subTitleText.textHeight;
		}
		
		private function activate():void
		{
			if(current != null)
			{
				if(ExternalInterface.available) ExternalInterface.call("console.log", "Subtitles.activate(), current: " + current);
				subs[current].addEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED,     onCueEnter, false, 0, true);
				subs[current].addEventListener(TimelineMetadataEvent.MARKER_DURATION_REACHED, onCueLeave, false, 0, true);
				subTitleText.text = " ";
				subTitleText.visible = true;
			}
		}
		
		private function deactivate():void
		{
			if(current != null)
			{
				if(ExternalInterface.available) ExternalInterface.call("console.log", "Subtitles.deactivate(), current: " + current);
				subs[current].removeEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED);
				subs[current].removeEventListener(TimelineMetadataEvent.MARKER_DURATION_REACHED);
				subTitleText.visible = false;
			}
		}
		
		public function select(sub:String):void
		{
			if(ExternalInterface.available) ExternalInterface.call("console.log", "Subtitles.select(" + sub + ")");
			if(current != sub)
			{
				deactivate();
				current = sub;
				activate();
			}
		}
		
		private function onCueEnter(e:TimelineMetadataEvent):void
		{
			var params = e.marker as CuePoint;
			subTitleText.visible = false;
			subTitleText.text = "$";
			//subLineHeight = subTitleText.height;
			subTitleText.text = String(params.parameters[0]);
			subTitleText.setTextFormat(subTitleTextFormat);
			subTitleText.x = (this.width - subTitleText.width)/2;
			subTitleText.y = this.height - subTitleText.height;
			subTitleText.visible = true;
		}
		
		private function onCueLeave(e:TimelineMetadataEvent):void
		{
			subTitleText.text = " ";
		}
		
		public function setDimensions(_x:uint, _y:uint, _w:uint, _h:uint):void
		{
			this.x      = _x;
			this.y      = _y;
			this.width  = _w;
			this.height = _h;
			calcSubBounds();
		}
		
		public function loadSRT(sub:String, url:String):void
		{
			if(mediaElement != null && url != null)
			{
				if(ExternalInterface.available) ExternalInterface.call("console.log", "Load SRT[" + sub + "]: " + url);
				var tld:TimelineMetadata = new TimelineMetadata(mediaElement);
				var sth:SubtitlesHandler = new SubtitlesHandler();
				sth.addEventListener(sub + SubtitlesHandler.SUBTITLES_LOADED, onSRTLoaded);
				sth.loadSubtitles(sub, url);
				subs[sub] = tld;
				subsHandler[sub] = sth;
			}
		}
		
		private function onSRTLoaded(e:Event):void
		{
			var sub:String = e.type.split(".")[0];
			subsHandler[sub].parseSRT(subs[sub]);
			dispatchEvent(new Event("subs.loaded.parsed"));
		}
	}
}
