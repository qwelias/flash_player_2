package {

import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.NetStatusEvent;
import flash.events.StageVideoAvailabilityEvent;
import flash.events.StageVideoEvent;
import flash.geom.Rectangle;
import flash.media.SoundTransform;
import flash.media.StageVideo;
import flash.media.Video;
import flash.media.VideoStatus;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.system.Security;
import flash.text.engine.RenderingMode;
import flash.utils.getTimer;
import flash.utils.setTimeout;

import ru.yandex.video.IVideoContainer;
import ru.yandex.video.VideoContainerEvents;
import ru.yandex.video.VideoContainerStates;
import ru.yandex.video.VideoContainerAPIVersion;

[SWF(width=800, height=600)]
/**
 * Тестовая реализация API видеоконтейнера. Может использоваться как отправная точка для ваших реализаций
 */
public class TestContainer extends Sprite implements IVideoContainer {

    private static const VIDEO_PATH_LQ:String = "http://kp.cdn.yandex.net/258687/kinopoisk.ru-Interstellar-221650.mp4";
    private static const VIDEO_PATH_MQ:String = "http://kp.cdn.yandex.net/258687/kinopoisk.ru-Interstellar-221651.mp4";

    private var _netStream:NetStream;
    private var _video:Video;
    private var _stageVideo:StageVideo;

    private var _buffering:Boolean;
    private var _muted:Boolean;

    private var _state:String = VideoContainerStates.INACTIVE;
    private var _duration:Number;
    private var _volume:Number = 0.6;

    private var _width:Number = 400;
    private var _height:Number = 300;

    private var _lastTime:Number;
    private var _quality:Object = {name: "standard", url: VIDEO_PATH_LQ};
    private var _qualities:Array = [_quality,
        {name: "high", url: VIDEO_PATH_MQ}];

    public function TestContainer() {
        Security.allowDomain("*");
        init();
    }

    private function init():void {
        // You may want to load some info from the server before we start
        setState(VideoContainerStates.INITIALIZED);
        drawBg();
    }

    private function onStageVideoAvailable(event:StageVideoAvailabilityEvent):void {
        trace("Stage Video event:", event.availability, event.reason);
    }

    private function drawBg():void {
        var g:Graphics = graphics;
        g.clear();
        g.beginFill(0);
        g.drawRect(0, 0, _width, _height);
    }
    private function fitVideo():void {
        var videoWidth:Number = _video.videoWidth || (_stageVideo ? _stageVideo.videoWidth : 0);
        var videoHeight:Number = _video.videoHeight ||  (_stageVideo ? _stageVideo.videoHeight : 0);
        var videoAspectRatio:Number = videoWidth / videoHeight;
        var viewAspectRatio:Number = _width / _height;
        if (videoAspectRatio > viewAspectRatio) {
            _video.width = _width;
            _video.height = int(_width / videoAspectRatio);
            _video.x = 0;
            _video.y = int((_height - _video.height) / 2);
        } else {
            _video.height = _height;
            _video.width = int(_height * videoAspectRatio);
            _video.y = 0;
            _video.x = int((_width - _video.width) / 2);
        }

        if (_stageVideo) {
            _stageVideo.viewPort = new Rectangle(_video.x, _video.y, _video.width, _video.height);
            trace("StageVideo resized to ", _stageVideo.viewPort);
        }
    }

    public function load(config:Object):void {
        var netConnection:NetConnection = new NetConnection();
        netConnection.connect(null);
        _netStream = new NetStream(netConnection);
        _netStream.client = {
            onMetaData: onMetaData
        };
        _netStream.bufferTime = 1;
        _netStream.addEventListener(NetStatusEvent.NET_STATUS, netStream_netStatusHandler);
        _netStream.play(_quality.url);
        _netStream.pause();
        _netStream.soundTransform = new SoundTransform(_volume);
        _video = new Video();
        _video.smoothing = true;
        _video.attachNetStream(_netStream);
        addChild(_video);
        setState(VideoContainerStates.INITIALIZED);
    }

    private function onMetaData(metadata:Object):void {
        _duration = metadata.duration;
        fitVideo();
        if (_state == VideoContainerStates.INITIALIZED) {
            setState(VideoContainerStates.READY);
        }

        if (_lastTime > 0) {
            seek(_lastTime);
            _lastTime = 0;
        }
    }

    private function netStream_netStatusHandler(event:NetStatusEvent):void {
        var code:String = event.info.code;
        trace(code);
        switch (code) {
            case "NetStream.Buffer.Empty":
                setBuffering(true);
                break;
            case "NetStream.Buffer.Full":
                setBuffering(false);
                break;
            case "NetStream.Play.Stop":
                end();
                break;
        }
    }

    public function start():void {
        setState(VideoContainerStates.START);
        // I don't have any Ad yet, so just go on and play video
        trace("video visible?", _video.visible, _video.parent);
        _netStream.resume();
        setState(VideoContainerStates.VIDEO_PLAYING);
    }

    public function stop():void {
        end();
    }

    public function setAgeConfirmed(confirmed:Boolean):void {

    }

    private function end():void {
        setState(VideoContainerStates.VIDEO_ENDED);
        // we don't have ad, so just stop
        setState(VideoContainerStates.END);
        _netStream.removeEventListener(NetStatusEvent.NET_STATUS, netStream_netStatusHandler);
        _netStream.close();
        _video.attachNetStream(null);
        _video.clear();
    }

    public function pause(adAllowed:Boolean=true):void {
        if (_state != VideoContainerStates.VIDEO_PLAYING) return;
        _netStream.pause();
        setState(VideoContainerStates.VIDEO_PAUSED);
    }

    public function resume():void {
        if (_state != VideoContainerStates.VIDEO_PAUSED) return;
        _netStream.resume();
        setState(VideoContainerStates.VIDEO_PLAYING);
    }

    public function mute():void {
        if (_muted) return;
        _muted = true;
        _netStream.soundTransform = new SoundTransform(0);
        dispatchSimpleEvent(VideoContainerEvents.MUTED);
    }

    public function unmute():void {
        if (!_muted) return;
        _muted = false;
        _netStream.soundTransform = new SoundTransform(_volume);
        dispatchSimpleEvent(VideoContainerEvents.UNMUTED);
    }

    public function beginSeek():void {
        _netStream.pause();
    }

    public function endSeek():void {
        _netStream.resume();
    }

    public function seek(timeInSeconds:Number):void {
        _netStream.seek(timeInSeconds);
        setBuffering(true);
    }

    public function setFullscreen(state:Boolean):void {
        // we don't care for this demo, but it may be important for ad systems
    }

    public function setSize(width:Number, height:Number):void {
        _width = width;
        _height = height;
        drawBg();
        fitVideo();
    }

    private function switchQuality(quality:Object):void {
        _quality = quality;
        if (_state != VideoContainerStates.VIDEO_PLAYING && _state != VideoContainerStates.VIDEO_PAUSED) {
            return;
        }
        setBuffering(true);
        _lastTime = time;
        _netStream.play(_quality.url);
        if (_state == VideoContainerStates.VIDEO_PAUSED) {
            _netStream.pause();
        }
    }

    public function get availableQualities():Array {
        return _qualities;
    }
    public function setQuality(quality:Object):void {
        if (_quality == quality) {
            return;
        }
        switchQuality(quality);
    }
    public function get quality():Object {
        return _quality;
    }

    public function get availableAudioTracks():Array {
        return null;
    }
    public function setAudioTrack(audioTrack:Object):void {
    }
    public function get audioTrack():Object {
        return null;
    }

    public function get availableSubtitleTracks():Array {
        return null
    }
    public function setSubtitleTrack(subtitleTrack:Object):void {
    }
    public function get subtitleTrack():Object {
        return null;
    }

    public function get coid():String {
        return "unknown";
    }

    public function get apiVersion():String {
        return VideoContainerAPIVersion.VERSION;
    }

    public function get seekAllowed():Boolean {
        return true;
    }

    public function get state():String {
        return _state;
    }

    private function setState(value:String):void {
        if (_state == value) return;
        trace("STATE:", _state, "->", value);
        _state = value;
        dispatchSimpleEvent(VideoContainerEvents.STATE_CHANGE);
    }

    public function get duration():Number {
        return _duration;
    }

    public function get time():Number {
        return _netStream.time;
    }

    public function get volume():Number {
        return _volume;
    }

    public function set volume(value:Number):void {
        if (_volume == value) return;
        _volume = value;
        if (_netStream) {
            _netStream.soundTransform = new SoundTransform(_volume);
        }
        dispatchSimpleEvent(VideoContainerEvents.VOLUME_CHANGE);
    }

    public function get bytesTotal():uint {
        return _netStream.bytesTotal;
    }

    public function get bytesOffset():uint {
        // byteOffset is always zero for this case: I don't allow loading offset
        return 0;
    }

    public function get bytesLoaded():uint {
        return _netStream.bytesLoaded;
    }

    private function setBuffering(value:Boolean):void {
        if (_state != VideoContainerStates.VIDEO_PLAYING || _buffering == value) return;
        _buffering = value;
        if (_buffering) {
            dispatchSimpleEvent(VideoContainerEvents.BUFFERING);
        } else {
            dispatchSimpleEvent(VideoContainerEvents.BUFFERED);
        }
    }

    private function dispatchSimpleEvent(eventName:String):void {
        trace("DISPATCHING:", eventName);
        dispatchEvent(new Event(eventName));
    }

    public function setStageVideoAvailable(available:String, reason:String,
            stageVideos:Vector.<StageVideo>):void {
        trace(getTimer(), "Oh, now I know stageVideo state:", available, reason);
        trace("Stage Videos?", stageVideos.length);
        if (stageVideos.length > 0) {
            _stageVideo = stageVideos[0];
            trace("Mmm!", stageVideos[0].viewPort);
            if (_video) {
                _video.attachNetStream(null);
                _video.visible = false;
                trace("bg cleared!");
                graphics.clear();
                _stageVideo.addEventListener(StageVideoEvent.RENDER_STATE, onRenderState);
                _stageVideo.attachNetStream(_netStream);
                _stageVideo.viewPort = new Rectangle(_video.x, _video.y, _video.width, _video.height);
            }
        } else {
            if (_video) {
                trace("Switching back to normal video...");
                _video.visible = true;
                _video.attachNetStream(_netStream);
                drawBg();
            }
            _stageVideo = null;
        }
    }

    private function onRenderState(event:StageVideoEvent):void {
        trace(getTimer(),"Render state:", event.status);
        if (event.status == VideoStatus.UNAVAILABLE) {
            trace("Switching back to normal video...");
            _stageVideo.attachNetStream(null);
            _stageVideo = null;
            _video.visible = true;
            _video.attachNetStream(_netStream);
            drawBg();
        }
    }
}
}
