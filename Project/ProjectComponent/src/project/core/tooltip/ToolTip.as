package project.core.tooltip
{
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	public class ToolTip
	{
		protected static const DELAY_TIME:int = 300;
		protected static const FAST_OCCUR_TIME:int = 50;

		public function ToolTip()
		{
			super();
			_pUI = ToolTipUIFactory.StyleUI;
			_Timer = new Timer( DELAY_TIME, 1 );
			_Timer.addEventListener( TimerEvent.TIMER, OnTimer );
		}

		protected var _pUI:IToolTipUI;
		private var _LastTime:int=0;
		private var _Target:InteractiveObject;
		private var _Timer:Timer;

		public function Hide():void
		{
			PendingClear();
			_pUI.Hide();
		}

		
		public var ToolTipText:String;

		public function Register( comp:InteractiveObject ):void
		{
			comp.addEventListener( MouseEvent.ROLL_OVER, Target_OnRollOver );
			comp.addEventListener( MouseEvent.ROLL_OUT, Target_OnRollOut );
			comp.addEventListener( MouseEvent.MOUSE_DOWN, Target_OnRollOut );
//			comp.addEventListener( Event.REMOVED_FROM_STAGE, Target_OnRollOut );
		}

		public function Show(target:InteractiveObject=null):void
		{
			if( target ) {
				_Target = target;
			}
			UI.Data = GetToolTipData==null?ToolTipText:GetToolTipData( _Target );
			UI.Show(_Target);
		}
		public var GetToolTipData:Function;
		public var GetToolTipUI:Function;
		
		public function get UI():IToolTipUI
		{
			return _pUI;
		}

		public function set UI( ui:IToolTipUI ):void
		{
			if ( _pUI==ui )
			{
				return;
			}

			if ( ui==null )
			{
				_pUI=ToolTipUIFactory.StyleUI;
			}
			else
			{
				_pUI = ui;
			}
		}

		public function UnRegister( comp:InteractiveObject ):void
		{
			comp.removeEventListener( MouseEvent.ROLL_OVER, Target_OnRollOver );
			comp.removeEventListener( MouseEvent.ROLL_OUT, Target_OnRollOut );
			comp.removeEventListener( MouseEvent.MOUSE_DOWN, Target_OnRollOut );
//			comp.removeEventListener( Event.REMOVED_FROM_STAGE, Target_OnRollOut );
			//maybe showing, so this event need to remove
			comp.removeEventListener( MouseEvent.MOUSE_MOVE, Target_OnMouseMove );
			if( _Target==comp ) {
				Hide();
			}
		}

		protected function PendingClear():void
		{
			_Timer.reset();

			if ( _Target )
			{
				_Target.removeEventListener( MouseEvent.MOUSE_MOVE, Target_OnMouseMove );
			}
			_LastTime = getTimer();
		}

		protected function PendingRestart():void
		{
			if ( _Timer.running )
			{
				_Timer.reset();
			}
			_Timer.start();
		}

		protected function PendingShow():void
		{
			if ( getTimer() - _LastTime < FAST_OCCUR_TIME )
			{
				_Timer.delay = FAST_OCCUR_TIME;
			}
			else
			{
				_Timer.delay = DELAY_TIME;
			}
			_Target.addEventListener( MouseEvent.MOUSE_MOVE, Target_OnMouseMove );
			_Timer.start();
		}

		protected function Target_OnMouseMove( e:MouseEvent ):void
		{
			PendingRestart();
		}

		protected function Target_OnRollOut( e:Event ):void
		{
			if ( e.currentTarget==_Target )
			{
				Hide();
			}
		}

		protected function Target_OnRollOver( e:MouseEvent ):void
		{
			_Target = e.currentTarget as InteractiveObject;
			UI = GetToolTipUI==null ? null : GetToolTipUI(_Target);
			PendingShow();
		}

		private function OnTimer( e:TimerEvent ):void
		{
			_Timer.reset();
			Show();
		}
	}
}