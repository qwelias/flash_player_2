package robotlegs.bender.extensions.sosmaxExtension.impl {
	import robotlegs.bender.extensions.enhancedLogging.impl.LogMessageParser;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.api.ILogTarget;
	import robotlegs.bender.framework.api.LogLevel;

	import org.osflash.signals.natives.sets.XMLSocketSignalSet;

	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.net.XMLSocket;

	/**
	 * @author aziz
	 */
	public class SOSMaxTracerLogTarget implements ILogTarget {
		private const _messageParser : LogMessageParser = new LogMessageParser();
		private var _context : IContext;
		private var socket : XMLSocket;
		private var socketSignals : XMLSocketSignalSet;
		private var isConnected : Boolean;
		private var _missingMessages : Vector.<String>;

		public function SOSMaxTracerLogTarget(context : IContext) {
			this._context = context;
			context.beforeInitializing(this.beforeInitializingHandler);
		}

		/**
		 * @private create <code>XMLSocket</code> object & connect to <code>localhost</code>, using port <code>4444</code>
		 * @return void
		 */
		private function beforeInitializingHandler() : void {
			this.socket = new XMLSocket();
			this.socketSignals = new XMLSocketSignalSet(this.socket);
			this.socketSignals.connect.add(this.onSocketConnectedHandler);
			this.socketSignals.close.add(this.onSocketConnectionCloseHandler);
			this.socketSignals.ioError.add(this.onSocketErrorHandler);
			this.socketSignals.securityError.add(this.onSocketErrorHandler);

			try {
				this.socket.connect("localhost", 4444);
			} catch (error : SecurityError) {
				// handle security error
			}
		}

		/**
		 * @inheritDoc
		 */
		public function log(source : Object, level : uint, timestamp : int, message : String, params : Array = null) : void {
			var logMessage : String = "!SOS<showMessage key='" + (LogLevel.NAME[level] as String).toLowerCase() + "'>" + timestamp.toString() + " " + "[" + LogLevel.NAME[level] + "] " + source + this._messageParser.parseMessage(message, params) + "</showMessage>\n";
			if (this.isConnected) {
				if (this.missingMessages && this.missingMessages.length > 0)
					while (this.missingMessages.length > 0)
						this.socket.send(this.missingMessages.shift());
				this._missingMessages = null;
				this.socket.send(logMessage);
			} else {
				this.missingMessages.push(logMessage);
			}
		}

		public function get missingMessages() : Vector.<String> {
			return this._missingMessages ||= new Vector.<String>();
		}

		// Handlers
		/**
		 * @eventType flash.events.Event.CONNECT
		 */
		private function onSocketConnectedHandler(event : Event) : void {
			this.isConnected = true;
		}

		/**
		 * @eventType flash.events.Event.CONNECT
		 */
		private function onSocketConnectionCloseHandler(event : Event) : void {
			this.isConnected = false;
		}

		/**
		 * @eventType flash.events.ErrorEvent.ERROR
		 */
		private function onSocketErrorHandler(event : ErrorEvent) : void {
			// TODO handle errors
		}
	}
}
