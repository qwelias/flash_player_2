// ------------------------------------------------------------------------------
// Copyright &copy; 2013 the original author or authors. All Rights Reserved.
//
// NOTICE: You are permitted to use, modify, and distribute this file
// in accordance with the terms of the license agreement accompanying it.
// ------------------------------------------------------------------------------
package robotlegs.bender.extensions.mosterDebugerLogger {
	import robotlegs.bender.extensions.mosterDebugerLogger.impl.MonsterDebuggerLogTarget;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.api.IExtension;

	/**
	 * @playerversion			Adobe Flashplayer 11.1 or higher
	 * @langversion				Actionscript 3.0
	 * @author					Aziz Zaynutdinov (aziz.zaynutdinoff at gmail.com)
	 */
	public class MonsterDebuggerExtension implements IExtension {
		public function extend(context : IContext) : void {
			context.addLogTarget(new MonsterDebuggerLogTarget(context));
		}
	}
}
