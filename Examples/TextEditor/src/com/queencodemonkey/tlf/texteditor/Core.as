////////////////////////////////////////////////////////////////////////////////
//
//  Copyright © 2011, Huyen Tue Dao 
//  All rights reserved. 
// 
//  Redistribution and use in source and binary forms, with or without 
//  modification, are permitted provided that the following conditions are met: 
//      * Redistributions of source code must retain the above copyright 
//        notice, this list of conditions and the following disclaimer. 
//      * Redistributions in binary form must reproduce the above copyright 
//        notice, this list of conditions and the following disclaimer in the 
//        documentation and/or other materials provided with the distribution. 
//      * Neither the name of Huyen Tue Dao nor the names of other contributors 
//        may be used to endorse or promote products derived from this software 
//        without specific prior written permission. 
// 
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS 
//  IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
//  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL HUYEN TUE DAO BE LIABLE FOR 
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
//  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY 
//  OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF 
//  SUCH DAMAGE. 
//
////////////////////////////////////////////////////////////////////////////////
package com.queencodemonkey.tlf.texteditor
{
    import com.queencodemonkey.tlf.page.components.IPageDisplay;
    import com.queencodemonkey.tlf.textLayout.edit.SearchManager;
    import com.queencodemonkey.tlf.textLayout.operations.BlockQuoteOperation;
    import com.queencodemonkey.tlf.textLayout.utils.TextLayoutFormatUtil;
    import com.queencodemonkey.tlf.texteditor.components.ICommonFormatDisplay;
    import com.queencodemonkey.tlf.texteditor.components.search.supportClasses.SearchResultsDisplayData;
    
    import flashx.textLayout.edit.EditManager;
    import flashx.textLayout.edit.EditingMode;
    import flashx.textLayout.edit.IEditManager;
    import flashx.textLayout.edit.SelectionManager;
    import flashx.textLayout.edit.SelectionState;
    import flashx.textLayout.elements.InlineGraphicElementStatus;
    import flashx.textLayout.elements.TextFlow;
    import flashx.textLayout.events.SelectionEvent;
    import flashx.textLayout.events.StatusChangeEvent;
    import flashx.textLayout.formats.TextLayoutFormat;
    import flashx.textLayout.tlf_internal;
    import flashx.undo.UndoManager;
	
	use namespace tlf_internal;

    public class Core
    {

        //------------------------------------------------------------------
        //
        //  G E T T E R S / S E T T E R S 
        //
        //------------------------------------------------------------------

        public function get editingMode():String
        {
            return _editingMode;
        }

        public function set editingMode(value:String):void
        {
            if (value == EditingMode.READ_ONLY || value == EditingMode.READ_SELECT ||
                value == EditingMode.READ_WRITE)
            {
                _editingMode = value;
                setupTextFlow();
            }
        }

        public function get pageDisplay():IPageDisplay
        {
            return _pageDisplay;
        }

        public function set pageDisplay(value:IPageDisplay):void
        {
            if (_pageDisplay)
                tearDownPageDisplay();

            _pageDisplay = value;

            if (_pageDisplay)
                setupPageDisplay();
        }

        public function get textFlow():TextFlow
        {
            return _textFlow;
        }

        public function set textFlow(value:TextFlow):void
        {
            if (_textFlow)
            {
                tearDownTextFlow();
                if (pageDisplay)
                    tearDownPageDisplay();
				tearDownSearchManager();
            }

            _textFlow = value;

            if (_textFlow)
            {
                setupTextFlow();
                if (pageDisplay)
                    setupPageDisplay();
				setupSearchManager();
            }
        }

        //------------------------------------------------------------------
        //
        //   P U B L I C    P R O P E R T I E S 
        //
        //------------------------------------------------------------------

        public var searchManager:SearchManager;

        //------------------------------------------------------------------
        //
        //  P R I V A T E    P R O P E R T I E S 
        //
        //------------------------------------------------------------------

        private var commonFormatDisplays:Vector.<ICommonFormatDisplay> = null;

        //------------------------------------------------------------------
        //  G E T T E R / S E T T E R    P R O P E R T I E S 
        //------------------------------------------------------------------

        private var _editingMode:String = EditingMode.READ_ONLY;

        private var _pageDisplay:IPageDisplay = null;

        private var _textFlow:TextFlow = null;

        //------------------------------------------------------------------
        //
        //  P U B L I C    M E T H O D S 
        //
        //------------------------------------------------------------------

        public function Core()
        {
            construct();
        }

        public function addCommonFormatDisplay(display:ICommonFormatDisplay):void
        {
            commonFormatDisplays[commonFormatDisplays.length] = display;
			display.commonFormat = TextLayoutFormatUtil.getSelectionCommonFormat(textFlow);
        }

        public function applyFormat(property:String, value:*):void
        {
            if (textFlow.interactionManager is IEditManager)
            {
                var format:TextLayoutFormat = new TextLayoutFormat();
                format[property] = value;
                if (TextLayoutFormatUtil.isLeafFormat(property))
                {
                    (textFlow.interactionManager as IEditManager).applyLeafFormat(format);
                }
                else if (TextLayoutFormatUtil.isParagraphFormat(property))
                {
                    (textFlow.interactionManager as IEditManager).applyParagraphFormat(format);
                }
                else if (TextLayoutFormatUtil.isContainerFormat(property))
                {
                    var absoluteStart:int = textFlow.getAbsoluteStart();
                    var absoluteEnd:int = absoluteStart + textFlow.textLength;
                    var selectionState:SelectionState = new SelectionState(textFlow, absoluteStart, absoluteEnd);
                    (textFlow.interactionManager as IEditManager).applyContainerFormat(format, selectionState);
                }
                textFlow.flowComposer.updateAllControllers();
            }
        }

        public function removeCommonFormatDisplay(display:ICommonFormatDisplay):void
        {
            var index:int = commonFormatDisplays.indexOf(display);
            if (index != -1)
                commonFormatDisplays.splice(index, 1);
        }

        public function search(searchString:String, caseInsensitive:Boolean = false, useRegularExpressions:Boolean = false):void
        {
			if (!textFlow.flowComposer.composing)
			{
            	searchManager.search(searchString, null, caseInsensitive, useRegularExpressions);
				searchManager.highlightResults();
			}
        }
		
		public function replace(searchString:String, replaceString:String = null, caseInsensitive:Boolean = false, useRegularExpressions:Boolean = false):void
		{
			if (!textFlow.flowComposer.composing)
			{
				searchManager.search(searchString, replaceString, caseInsensitive, useRegularExpressions);
				searchManager.highlightResults();
			}
		}
		
		public function getSearchResultsDisplayData():SearchResultsDisplayData
		{
			if (searchManager.searchResults.length > 0)
				return new SearchResultsDisplayData(textFlow, 
					searchManager.lastSearch, 
					searchManager.searchResults);
			else
				return null;
		}
		
		public function insertImage(path:String):void
		{
			if (textFlow.interactionManager is IEditManager)
			{
				(textFlow.interactionManager as IEditManager).insertInlineGraphic(path, 100, 100);
			}
		}

		public function createBlockQuote():void
		{
			if (textFlow.interactionManager is EditManager)
			{
				var editManager:EditManager = textFlow.interactionManager as EditManager;
				
				var operationState:SelectionState = editManager.defaultOperationState(operationState);
				if (operationState)
					editManager.doOperation(new BlockQuoteOperation(operationState));	
			}
		}
		
        //------------------------------------------------------------------
        //
        //   P R O T E C T E D    M E T H O D S 
        //
        //------------------------------------------------------------------

		protected function setupSearchManager():void
		{
			searchManager.textFlow = textFlow;
		}
		
        protected function setupPageDisplay():void
        {
            pageDisplay.textFlow = textFlow;
        }

        protected function setupTextFlow():void
        {
            if (textFlow.interactionManager)
            {
                textFlow.removeEventListener(SelectionEvent.SELECTION_CHANGE, textFlow_selectionChangeHandler);
            }
            if (editingMode == EditingMode.READ_ONLY)
            {
                textFlow.interactionManager = null;
            }
            else if (editingMode == EditingMode.READ_SELECT)
            {
                textFlow.interactionManager = new SelectionManager();
            }
            else
            {
                textFlow.interactionManager = new EditManager(new UndoManager());
            }
            if (textFlow.interactionManager)
            {
				textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, textFlow_inlineGraphicStatusChangeHandler); 
                textFlow.addEventListener(SelectionEvent.SELECTION_CHANGE, textFlow_selectionChangeHandler);
                textFlow.interactionManager.selectRange(0, 0);
                textFlow.interactionManager.setFocus();
            }
        }

		private function textFlow_inlineGraphicStatusChangeHandler(event:StatusChangeEvent):void
		{
			if (event.status == InlineGraphicElementStatus.SIZE_PENDING || event.status == InlineGraphicElementStatus.READY)
			{
				
				textFlow.flowComposer.updateAllControllers();
			}
		}

        protected function tearDownPageDisplay():void
        {
            pageDisplay.textFlow = null;
        }
		
		protected function tearDownSearchManager():void
		{
			searchManager.textFlow = null;
		}

        protected function tearDownTextFlow():void
        {
            textFlow.removeEventListener(SelectionEvent.SELECTION_CHANGE, textFlow_selectionChangeHandler);
        }

        //------------------------------------------------------------------
        //
        //   P R I V A T E    M E T H O D S 
        //
        //------------------------------------------------------------------

        private function construct():void
        {
            commonFormatDisplays = new Vector.<ICommonFormatDisplay>();

            searchManager = new SearchManager();
        }

        //------------------------------------------------------------------
        //  EVENT  HANDLERS 
        //------------------------------------------------------------------

        private function textFlow_selectionChangeHandler(event:SelectionEvent):void
        {
			var commonFormat:TextLayoutFormat = TextLayoutFormatUtil.getSelectionCommonFormat(textFlow);
			
			for each (var commonFormatDisplay:ICommonFormatDisplay in commonFormatDisplays)
			{
				commonFormatDisplay.commonFormat = commonFormat;
			}
			
			if (searchManager.numResults > 0)
				searchManager.clearHighlights();
        }
    }
}