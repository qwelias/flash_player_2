package robotlegs.bender.extensions.mosterDebugerLogger.impl {
	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.extensions.enhancedLogging.impl.LogMessageParser;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.api.ILogTarget;
	import robotlegs.bender.framework.api.LogLevel;

	import com.demonsters.debugger.MonsterDebugger;

	/**
	 * @playerversion			Adobe Flashplayer 11.1 or higher
	 * @langversion				Actionscript 3.0
	 * @author					Aziz Zaynutdinov (aziz.zaynutdinoff at gmail.com)
	 */
	public class MonsterDebuggerLogTarget implements ILogTarget {
		private static const COLOR : Vector.<uint> = new <uint>[0, 0, 0xaa0000, // fatal 
		0, 0xff0000, // error 
		0, 0, 0, 0x295461, // warn 
		0, 0, 0, 0, 0, 0, 0, 0x45b39b, // notify 
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0x555555// debug
		];
		private const _messageParser : LogMessageParser = new LogMessageParser();
		private var _context : IContext;

		public function MonsterDebuggerLogTarget(context : IContext) {
			this._context = context;
			context.afterInitializing(this.afterContextInitedHandler);
		}

		private function afterContextInitedHandler() : void {
			if (this._context.logLevel == LogLevel.DEBUG) {
				var contextView : ContextView = this._context.injector.getInstance(ContextView);
				contextView && MonsterDebugger.initialize(contextView.view);
			}
		}

		public function log(source : Object, level : uint, timestamp : int, message : String, params : Array = null) : void {
			if (this._context.logLevel == LogLevel.DEBUG)
				MonsterDebugger.trace(source, this._messageParser.parseMessage(message, params), "", LogLevel.NAME[level], COLOR[level]);
		}
	}
}
