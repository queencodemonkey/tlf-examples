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
package com.queencodemonkey.tlf.page.components
{
    import com.queencodemonkey.tlf.page.skins.PageDisplaySkin;
    
    import flashx.textLayout.elements.TextFlow;
    import flashx.textLayout.events.CompositionCompleteEvent;
    
    import mx.core.FlexGlobals;
    import mx.styles.CSSStyleDeclaration;
    
    import spark.components.SkinnableContainer;

    public class PageDisplay extends SkinnableContainer implements IPageDisplay
    {

        private static const DEFAULT_PAGE_HEIGHT:Number = 650;

        private static const DEFAULT_PAGE_WIDTH:Number = 500;

        /**
         * @private
         * Static variable to force setting of default styles.
         */
        private static var defaultStylesSet:Boolean = setDefaultStyles();

        //------------------------------------------------------------------
        //
        // P R I V A T E    S T A T I C    M E T H O D S 
        //
        //------------------------------------------------------------------

        /**
         * @private
         * Sets default values for style properties.
         */
        private static function setDefaultStyles():Boolean
        {
            var pageDisplayStyles:CSSStyleDeclaration = FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration("com.queencodemonkey.tlf.page.components.PageDisplay");

            if (!pageDisplayStyles)
            {
                pageDisplayStyles = new CSSStyleDeclaration();
            }
            pageDisplayStyles.defaultFactory = function():void
            {
                this.skinClass = PageDisplaySkin;
            };

            FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration("com.queencodemonkey.tlf.page.components.PageDisplay", pageDisplayStyles, true);

            return true;
        }

        //------------------------------------------------------------------
        //
        //  G E T T E R S / S E T T E R S 
        //
        //------------------------------------------------------------------

        public function get pageHeight():Number
        {
            return _pageHeight;
        }

        /**
         * @private
         */
        public function set pageHeight(value:Number):void
        {
            if (value != _pageHeight)
            {
                _pageHeight = value;
                pageHeightDirty = true;
                invalidateProperties();
            }
        }

        public function get pageWidth():Number
        {
            return _pageWidth;
        }

        /**
         * @private
         */
        public function set pageWidth(value:Number):void
        {
            if (value != _pageWidth)
            {
                _pageWidth = value;
                pageWidthDirty = true;
                invalidateProperties();
            }
        }

        public function get textFlow():TextFlow
        {
            return _textFlow;
        }

        /**
         * @private
         */
        public function set textFlow(value:TextFlow):void
        {
            if (value != _textFlow)
            {
				if (_textFlow)
					tearDownTextFlow();
                _textFlow = value;
                textFlowDirty = true;
                invalidateProperties();
            }
        }

        //------------------------------------------------------------------
        //
        //  P R I V A T E    P R O P E R T I E S 
        //
        //------------------------------------------------------------------

        private var pagePool:Vector.<PageComponent> = null;

        private var pages:Vector.<PageComponent> = null;

        //------------------------------------------------------------------
        //  G E T T E R / S E T T E R    P R O P E R T I E S 
        //------------------------------------------------------------------

        private var _pageHeight:Number = DEFAULT_PAGE_HEIGHT;

        private var _pageWidth:Number = DEFAULT_PAGE_WIDTH;

        private var _textFlow:TextFlow = null;

        //------------------------------------------------------------------
        //  D I R T Y    F L A G S 
        //------------------------------------------------------------------

        private var pageHeightDirty:Boolean = false;

        private var pageWidthDirty:Boolean = false;

        private var textFlowDirty:Boolean = false;

        //------------------------------------------------------------------
        //
        //  P U B L I C    M E T H O D S 
        //
        //------------------------------------------------------------------

        public function PageDisplay()
        {
            super();

            construct();
        }

        public function addPage():PageComponent
        {
            var page:PageComponent = pagePool.length == 0 ? new PageComponent() : pagePool.pop();
            pages[pages.length] = page;
            addElement(page);
            setupPage(page);
            return page;
        }

        public function removePage(index:int = -1):PageComponent
        {
            var numPages:int = pages.length;
            if (index < 0 && index >= numPages)
                index = numPages - 1;
            var pageToRemove:PageComponent = pages.splice(index, 1)[0];
            removeElement(pageToRemove);
            tearDownPage(pageToRemove);
            pagePool[pagePool.length] = pageToRemove;
            return pageToRemove;
        }

        //------------------------------------------------------------------
        //
        //   P R O T E C T E D    M E T H O D S 
        //
        //------------------------------------------------------------------

        /**
         * @inheritDoc
         */
        override protected function commitProperties():void
        {
            super.commitProperties();

            if (textFlowDirty)
            {
                removeAllPages();
                setupTextFlow();
                addPage();
                textFlowDirty = false;
            }
            else if (pageWidthDirty || pageHeightDirty)
            {
				resizePages();
            }

            if (pageWidthDirty)
            {
                pageWidthDirty = false;
            }

            if (pageHeightDirty)
            {
                pageHeightDirty = false;
            }
        }

        //------------------------------------------------------------------
        //
        //   P R I V A T E    M E T H O D S 
        //
        //------------------------------------------------------------------

        private function construct():void
        {
            pages = new Vector.<PageComponent>();
            pagePool = new Vector.<PageComponent>();
        }

        private function removeAllPages():void
        {
            while (pages.length > 0)
            {
                removePage(0);
            }
        }

        private function resizePages():void
        {
            for each (var page:PageComponent in pages)
            {
                page.width = pageWidth;
                page.height = pageHeight;
            }
        }

        private function setupPage(page:PageComponent):void
        {
            page.width = pageWidth;
            page.height = pageHeight;
            page.linkToTextFlow(textFlow, pageWidth, pageHeight);
        }

        private function setupTextFlow():void
        {
            textFlow.addEventListener(CompositionCompleteEvent.COMPOSITION_COMPLETE, textFlow_compositionCompleteHandler);
        }

        private function tearDownPage(page:PageComponent):void
        {
            page.unlinkFromTextFlow();
        }
		
		private function tearDownTextFlow():void
		{
			textFlow.removeEventListener(CompositionCompleteEvent.COMPOSITION_COMPLETE, textFlow_compositionCompleteHandler);
		}

        //------------------------------------------------------------------
        //  EVENT  HANDLERS 
        //------------------------------------------------------------------

        private function textFlow_compositionCompleteHandler(event:CompositionCompleteEvent):void
        {
            var numPages:int = pages.length;
            var page:PageComponent = pages[numPages - 1];
            if (page.textLength > 0)
            {
                if (!page.isLastPage())
                {
                    addPage();
                }
            }
            else if (numPages > 1)
            {
                removePage(numPages - 1);
            }
        }
    }
}