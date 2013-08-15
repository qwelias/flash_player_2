package robotlegs.bender.extensions.sosmaxExtension {
	import robotlegs.bender.extensions.sosmaxExtension.impl.SOSMaxTracerLogTarget;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.api.IExtension;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 * @require as3-signals
	 */
	public class SOSMaxTracerExtension implements IExtension {
		public function extend(context : IContext) : void {
			context.addLogTarget(new SOSMaxTracerLogTarget(context));
		}
	}
}
