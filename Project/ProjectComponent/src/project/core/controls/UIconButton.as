package project.core.controls
{
    import flash.display.DisplayObject;
    import flash.system.System;
    
    import project.core.global.AlignConst;
    import project.core.utils.EffectUtils;
	
    /**
     * 带图标的按钮
     * @author jacky
     */
    public class UIconButton extends USkinButton
    {

        /**
         * 
         * @param label
         * @param skinId
         * @param fixedSize
         * @param folder
         */
        public function UIconButton( label:String = "", skinId:String = "0", fixedSize:Boolean = true, folder:String = "Button" )
        {
            super( label, skinId, fixedSize, folder );
        }

        /**
         * 
         * @default 
         */
        protected var _Icon:DisplayObject;
        private var _Align:String = AlignConst.CENTER;

        /**
         * 
         * @param child
         * @param align
         */
        public function SetIcon( child:DisplayObject, align:String = AlignConst.CENTER ):void
        {
            if ( this._Icon && this.contains( this._Icon ))
            {
				EffectUtils.ClearEffect(_Icon);
				_Icon = null;
				System.gc();
//                this.removeChild( this._Icon );
            }

            this._Align = align;
            this._Icon = child;

            if ( this._Icon )
            {
                this.addChildAt( this._Icon, 1 );
            }

            this.ValidateSize();
        }

        /**
         * 
         */
        protected function ValidateIcon():void
        {
			if(!_Align) return ;
            if ( this._Icon )
            {
                if ( this._Align == AlignConst.LEFT )
                {
                    this._Icon.x = this.PaddingLeft;
                }
                else if ( this._Align == AlignConst.CENTER )
                {
                    this._Icon.x = Math.round(( this.width - this._Icon.width )*0.5 );
                }
                else if ( this._Align == AlignConst.RIGHT )
                {
                    this._Icon.x = Math.round( this.width-this._Icon.width-this.PaddingRight );
                }

                this._Icon.y = Math.round(( this.height - this._Icon.height )*0.5 );
            }
        }

        override protected function ValidateSize():void
        {
            super.ValidateSize();

            ValidateIcon();
        }
    }
}