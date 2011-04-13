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
    import com.queencodemonkey.tlf.page.skins.PageComponentSkin;

    import flash.display.Sprite;

    import flashx.textLayout.container.ContainerController;
    import flashx.textLayout.container.ScrollPolicy;
    import flashx.textLayout.elements.TextFlow;

    import mx.core.FlexGlobals;
    import mx.events.MoveEvent;
    import mx.events.ResizeEvent;
    import mx.styles.CSSStyleDeclaration;

    import spark.components.supportClasses.SkinnableComponent;
    /**
     * The Page class is a skinnable component that represents and displays
     * a page worth of text.
     *
     * @author Huyen Tue Dao
     */
    public class PageComponent extends SkinnableComponent
    {
        private static var classConstructed:Boolean = setDefaultStyles();

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
            var pageStyles:CSSStyleDeclaration = FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration("com.queencodemonkey.tlf.page.components.PageComponent");

            if (!pageStyles)
            {
                pageStyles = new CSSStyleDeclaration();
            }
            pageStyles.defaultFactory = function():void
            {
                this.skinClass = PageComponentSkin;
            };

            FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration("com.queencodemonkey.tlf.page.components.PageComponent",
                                                                             pageStyles,
                                                                             true);

            return true;
        }

        //------------------------------------------------------------------
        //
        //   S K I N    P A R T S 
        //
        //------------------------------------------------------------------

        [SkinPart(required="true")]
        /**
         * The sprite that actually holds rendered text.
         */
        public var container:Sprite = null;

        //------------------------------------------------------------------
        //
        //  G E T T E R S / S E T T E R S 
        //
        //------------------------------------------------------------------

        /**
         * The length of text contained in the page.
         */
        public function get textLength():int
        {
            return containerController ? containerController.textLength : NaN;
        }

        /**
         * Whether an update to the text flow composition and display is
         * requested when the page resizes.
         */
        public function get updateOnResize():Boolean
        {
            return _updateOnResize;
        }

        /**
         * @private
         */
        public function set updateOnResize(value:Boolean):void
        {
            _updateOnResize = value;
        }


        //------------------------------------------------------------------
        //
        //  P R O T E C T E D    P R O P E R T I E S 
        //
        //------------------------------------------------------------------

        /**
         * The controller that links this page to a TextFlow.
         */
        protected var containerController:ContainerController = null;

        //------------------------------------------------------------------
        //  G E T T E R / S E T T E R    P R O P E R T I E S 
        //------------------------------------------------------------------

        private var _updateOnResize:Boolean = true;

        //------------------------------------------------------------------
        //
        //  P U B L I C    M E T H O D S 
        //
        //------------------------------------------------------------------

        /**
         * Constructor.
         */
        public function PageComponent()
        {
            super();
        }

        /**
         * Whether the page is the first page displayed for a text flow.
         */
        public function isFirstPage():Boolean
        {
            return containerController && containerController.absoluteStart == 0;
        }

        /**
         * Whether the page is the last page display for a text flow.
         */
        public function isLastPage():Boolean
        {
            return containerController && containerController.textFlow &&
                (containerController.absoluteStart + containerController.textLength) == containerController.textFlow.textLength;
        }

        /**
         * Links the page to a text flow and sets up the page to display
         * content.
         *
         * @param textFlow A TextFlow instance to connect to the page.
         */
        public function linkToTextFlow(textFlow:TextFlow, compositionWidth:Number = NaN, compositionHeight:Number = NaN):void
        {
            if (!containerController || containerController.textFlow != textFlow)
            {
                if (!isNaN(compositionWidth) && !isNaN(compositionHeight))
                    containerController = new ContainerController(container, compositionWidth, compositionHeight);
                else if (container.width > 0 && container.height > 0)
                    containerController = new ContainerController(container, container.width, container.height);
                else
                    containerController = new ContainerController(container);
                // Need to set verticalScrollPolicy to off so that no partial
                // lines are laid out in a container: a page should only be
                // assigned as many text lines as it can display.
                containerController.verticalScrollPolicy = ScrollPolicy.OFF;
                textFlow.flowComposer.addController(containerController);
                textFlow.flowComposer.updateAllControllers();
            }
        }

        /**
         * Unlinks the page from a text flow, clearing out content from that
         * text flow.
         *
         * First checks whether the page is actually linked to the given
         * text flow.
         *
         * @param textFlow A TextFlow instance from which to unlink the page.
         */
        public function unlinkFromTextFlow(textFlow:TextFlow = null):void
        {
            if (containerController && (!textFlow || containerController.textFlow == textFlow))
            {
                for (var i:int = container.numChildren - 1; i >= 0; i--)
                {
                    container.removeChildAt(i);
                }
                if (!textFlow)
                    textFlow = containerController.textFlow;
                textFlow.flowComposer.removeController(containerController);
                textFlow.flowComposer.updateAllControllers();
                containerController = null;
            }
        }

        //------------------------------------------------------------------
        //
        //   P R O T E C T E D    M E T H O D S 
        //
        //------------------------------------------------------------------

        /**
         * @inheritDoc
         */
        override protected function partAdded(partName:String, instance:Object):void
        {
            super.partAdded(partName, instance);
            if (instance == container)
            {
                container.addEventListener(ResizeEvent.RESIZE, container_resizeHandler);
                container.addEventListener(MoveEvent.MOVE, container_moveHandler);
            }
        }

        /**
         * @inheritDoc
         */
        override protected function partRemoved(partName:String, instance:Object):void
        {
            super.partRemoved(partName, instance);
            if (instance == container)
            {
                container.removeEventListener(ResizeEvent.RESIZE, container_resizeHandler);
                container.removeEventListener(MoveEvent.MOVE, container_moveHandler);
            }
        }

        //------------------------------------------------------------------
        //
        //   P R I V A T E    M E T H O D S 
        //
        //------------------------------------------------------------------

        /**
         * @private
         * Resets the composition size and initiates a rendering update.
         */
        private function resetControllerDimensions():void
        {
            if (container.width > 0 && container.height > 0)
                containerController.setCompositionSize(container.width, container.height);
            if (updateOnResize)
                containerController.textFlow.flowComposer.updateAllControllers();
        }

        //------------------------------------------------------------------
        //  EVENT  HANDLERS 
        //------------------------------------------------------------------

        /**
         * @private
         * Resets the composition size when the container has moved.
         */
        private function container_moveHandler(event:MoveEvent):void
        {
            if (containerController)
            {
                resetControllerDimensions();
            }
        }

        /**
         * @private
         * Resets the composition size when the container has resized.
         */
        private function container_resizeHandler(event:ResizeEvent):void
        {
            if (containerController)
            {
                resetControllerDimensions();
            }
        }
    }
}