package list
{
	import events.ActionEvent;
	
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.display.DisplayObject;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	
	import mx.controls.List;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.core.EventPriority;
	import mx.core.mx_internal;
	import mx.effects.DefaultListEffect;
	
	use namespace mx_internal;

	[Event(name="something", type="events.ActionEvent")]
	

	public class FileDropList extends List
	{
		public function FileDropList()
		{
			super();
			dropEnabled = true;
			showDataTips = true;
			allowMultipleSelection = false;
			variableRowHeight = true;
			setStyle( "itemsChangeEffect", new DefaultListEffect() );
		}
		
		
		/**
		 * Ignore the default drag and drop handlers and use our own similar handlers.
		 * Will handle both drag and drop of files outside the application and inside the application.
		 */
		override public function set dropEnabled(value:Boolean):void
		{
			if( dropEnabled && !value )
			{
				removeEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, nativeDragEnterHandler, false );
				removeEventListener(NativeDragEvent.NATIVE_DRAG_OVER, nativeDragOverHandler, false );
				removeEventListener(NativeDragEvent.NATIVE_DRAG_DROP, nativeDragDropHandler, false );
			}
			
			if( value )
			{
				addEventListener( NativeDragEvent.NATIVE_DRAG_ENTER, nativeDragEnterHandler, false, EventPriority.DEFAULT_HANDLER );
				addEventListener( NativeDragEvent.NATIVE_DRAG_OVER, nativeDragOverHandler, false, EventPriority.DEFAULT_HANDLER );
				addEventListener( NativeDragEvent.NATIVE_DRAG_DROP, nativeDragDropHandler, false, EventPriority.DEFAULT_HANDLER );
			}
		}
		
		protected function nativeDragEnterHandler( event:NativeDragEvent ) :void
		{
			NativeDragManager.acceptDragDrop(this);
		}
		
		protected function nativeDragOverHandler( event:NativeDragEvent ) : void
		{
			if( event.isDefaultPrevented() )
				return;


			var validFormat:Boolean = event.clipboard.hasFormat("items") || event.clipboard.hasFormat( ClipboardFormats.FILE_LIST_FORMAT );

			if( enabled && iteratorValid && validFormat )
			{
				var i:int = calcDropIndex( event );
				var s:IListItemRenderer = indexToItemRenderer(i);
	
				if( !isItemSelected(s) )
				{
					selectItem( s, false, false );
					drawItem(s, true );
				}
			}
		}
		
		protected function nativeDragDropHandler( event:NativeDragEvent ):void
		{
			if (event.isDefaultPrevented())
	            return;
	        
	        // Perhaps in a future version?
	        //resetDragScrolling();
	        
	        if( enabled )
	        {
	        	var items:Array;
	        		        	
	        	if( event.clipboard.hasFormat( "items" ) )
	        	{
		            items = event.clipboard.getData("items") as Array;
		        }
		        else if( event.clipboard.hasFormat( ClipboardFormats.FILE_LIST_FORMAT ) )
		        {
		        	items = event.clipboard.getData( ClipboardFormats.FILE_LIST_FORMAT ) as Array;
		        }
		        
		        if( items )
		        {
		            var dropIndex:int = calcDropIndex(event);
		            var s:IListItemRenderer = indexToItemRenderer(dropIndex);
		            
		            if( s )
		            {
			            for each( var file:File in items )
			            {
			            	var action_event:ActionEvent = new ActionEvent( ActionEvent.SOMETHING );
			            	action_event.action = "> '" + file.name + "' drop selected with '" + s.data + "'\n"; 
			            	dispatchEvent( action_event );
			            }
			        }
		        }
	        }
		}
		
		/**
		 * Based on ListBase.calculateDropIndex but takes in a NativeDragEvent instead and 
		 * calculates the index to drop on.
		 */
		private function calcDropIndex(event:NativeDragEvent = null):int
 	   	{
	        if (event)
	        {
	            var item:IListItemRenderer;
	            var lastItem:IListItemRenderer;
	            var pt:Point = new Point(event.localX, event.localY);
	            pt = DisplayObject(event.target).localToGlobal(pt);
	            pt = listContent.globalToLocal(pt);
	
	            var rc:int = listItems.length;
	            for (var i:int = 0; i < rc; i++)
	            {
	                if (listItems[i][0])
	                    lastItem = listItems[i][0];
	
	                if (rowInfo[i].y <= pt.y && pt.y < rowInfo[i].y + rowInfo[i].height)
	                {
	                    item = listItems[i][0];
	                    break;
	                }
	            }
	
	            if (item)
	            {
	                lastDropIndex = itemRendererToIndex(item);
	            }
	            else
	            {
	                if (lastItem)
	                    lastDropIndex = itemRendererToIndex(lastItem);
	                else
	                    lastDropIndex = collection ? collection.length : 0;
	            }
	
	        }
	
	        return lastDropIndex;
	    }
	}
}