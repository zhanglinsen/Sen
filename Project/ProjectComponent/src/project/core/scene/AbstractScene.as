package project.core.scene
{
	import flash.system.System;
	
	import project.core.containers.UCanvas;
	import project.core.global.GlobalVariables;

	public class AbstractScene extends UCanvas implements IScene
	{
		public function AbstractScene(sceneType:int)
		{
			super();
			_SceneType = sceneType;
		}
		public function UpdateBg():void {
			if( this.BackgroundUrl ) {
				this.BackgroundUrl = BackgroundUrl;
			}
		}
		
		private var _LastAni:Boolean;
		protected function CheckBgAni():void {
			if( _LastAni!=GlobalVariables.BgAniOn ) {
				this.BackgroundUrl=this.BackgroundUrl;
			}
		}
		private var _SceneType:int;
		public function get SceneType():int {
			return _SceneType;
		}
		private var _LockSelected:Boolean = false;
		private var _SelectedObj:ISceneObject;

		public function ClearSelected():void
		{
			if ( !LockSelected && SelectedObject!=null )
			{
				SelectedObject.UnSelect();
				_SelectedObj = null;
			}
		}
		public function CloseScene():void
		{
			ClearSelected();
			if ( parent!=null )
			{
				parent.removeChild( this );
			}
			System.gc();
			_LastAni = GlobalVariables.BgAniOn;
		}
		public function get LockSelected():Boolean
		{
			return _LockSelected;
		}
		
		public function set LockSelected( val:Boolean ):void
		{
			_LockSelected = val;
		}
		public function OpenScene(params:*=null):void {
			if( this.Background==null ) {
				_LastAni = GlobalVariables.BgAniOn;
			}
			GlobalVariables.Root.addChildAt( this, 0 );
			
			CheckBgAni();
		}
		public function get SelectedObject():ISceneObject{
			return _SelectedObj;
		}
		public function set SelectedObject( obj:ISceneObject ):void{
			
			if ( LockSelected || SelectedObject==obj )
			{
				return;
			}
			
			if ( SelectedObject!=null )
			{
				SelectedObject.UnSelect();
				_SelectedObj = null;
			}
			
			if ( obj!=null )
			{
				_SelectedObj = obj;
				SelectedObject.Select();
			}
		}
	}
}