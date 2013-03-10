package project.core.form
{
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    import flash.utils.getTimer;
    
    import project.core.events.UIEvent;
    import project.core.utils.Utility;

    public class UTimerItem extends UFormItem
    {
        private var _Time:Number;
		
		private var _TimeFormat:String = "hh:mm:ss";

        public function UTimerItem( ident:int = 0, autoSize:Boolean=false )
        {
            super( ident, true, autoSize );

			Color = 0x33ffff;
//            RepaintForm();
        }
		
		/**是否冷却中*/
		public function get IsCoolDown():Boolean
		{
			return int(Value) > 0;
		}
		
		public var Index:int;
        private var _AutoTimer:Boolean = false;

        public function set AutoTimer( val:Boolean ):void
        {
            if ( AutoTimer==val )
            {
                return;
            }
            _AutoTimer = val;

            if ( _AutoTimer )
            {
                if ( _Timer==null )
                {
                    _Timer = new Timer( 200 );
                    _Timer.addEventListener( TimerEvent.TIMER, OnTimer );
                    this.addEventListener( Event.REMOVED_FROM_STAGE, OnRemoved );
                }
            }
            else
            {
                if ( _Timer )
                {
                    _Timer.reset();
                }
            }
        }

        public function get AutoTimer():Boolean
        {
            return _AutoTimer;
        }

		private function OnAdded(e:Event):void {
			_AddEvt = false;
			this.removeEventListener( Event.ADDED_TO_STAGE, OnAdded );
			if( _Timer.running ) {
				return ;
			}
			if( _StartTime>0 && _Time>0 ) {
				var t:int = getTimer() - _StartTime;
				if( _Time*1000-t<=0 ) {
					Value = 0;
					this.dispatchEvent( new UIEvent( UIEvent.TIMEOUT ));
				} else {
					Value = _Time - t*0.001;
				}
			}
		}
		private var _AddEvt:Boolean=false;
        private function OnRemoved( e:Event ):void
        {
//			_LastTime = 0;
            if ( _Timer )
            {
                _Timer.reset();
				if( _Time>0 ) {
					_AddEvt = true;
//					_LastTime = getTimer();
					this.addEventListener( Event.ADDED_TO_STAGE, OnAdded );
				}
            }
        }

        override public function Destroy():void
        {
            if ( AutoTimer && _Timer )
            {
                _Timer.reset();
                _Timer.removeEventListener( TimerEvent.TIMER, OnTimer );
            }
            this.removeEventListener( Event.REMOVED_FROM_STAGE, OnRemoved );
            super.Destroy();
        }

        private var _Timer:Timer;

        private function OnTimer( e:TimerEvent ):void
        {
            if ( _Time<=0 )
            {
                Value = 0;
				this.dispatchEvent( new UIEvent( UIEvent.TIMEOUT ));
            }
            else
            {
				var t:int = getTimer();
				if( t - _StartTime>1000 ) {
					_StartTime += 1000;
					_Time--;
					$Value = Utility.FormatTime( _Time, _TimeFormat );
				}
            }
        }

        public var DefaultValue:String = "";
		private var _StartTime:int;
        override public function set Value( value:Object ):void
        {
            if ( _Timer )
            {
                _Timer.reset();
            }

            if ( value is Number )
            {
                _Time = Number( value );

                if ( _Time>0 )
                {
                    value = Utility.FormatTime( _Time, _TimeFormat );

                    if ( AutoTimer  )
                    {
						_StartTime = getTimer();
						if( stage ) {
                        	_Timer.start();
						} else {
							this.OnRemoved(null);
						}
                    }
                }
                else
                {
                    $Value = DefaultValue;
                    return;
                }
            }
            else
            {
                _Time = -1;
            }
            $Value = value;
        }
		protected function set $Value(val:Object):void {
			super.Value = val;
		}

        override public function get Value():Object
        {
            return _Time<=0?super.Value:_Time;
        }
		public function get Time():Number {
			return _Time;
		}
		
		public function set TimeFormat(val:String):void
		{
			_TimeFormat = val;			
		}
    }
}