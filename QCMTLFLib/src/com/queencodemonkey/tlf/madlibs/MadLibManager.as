////////////////////////////////////////////////////////////////////////////////
//
//  Copyright © Houghton Mifflin Harcourt 2010.  
//  All Rights Reserved.  
//  This software and documentation is the confidential and proprietary  
//  information of Houghton Mifflin Harcourt ("Confidential Information").  
//  You shall not disclose such Confidential Information and shall use  
//  it only in accordance with the terms of the license agreement you  
//  entered into with Houghton Mifflin Harcourt.  
//  Unauthorized reproduction or distribution of this Confidential  
//  Information, or any portion of it, may result in severe civil and  
//  criminal penalties.  
//
////////////////////////////////////////////////////////////////////////////////
package com.queencodemonkey.tlf.madlibs
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Point;
    import flash.utils.Dictionary;
    
    import flashx.textLayout.compose.IFlowComposer;
    import flashx.textLayout.compose.StandardFlowComposer;
    import flashx.textLayout.container.ContainerController;
    import flashx.textLayout.elements.FlowElement;
    import flashx.textLayout.elements.FlowLeafElement;
    import flashx.textLayout.elements.InlineGraphicElement;
    import flashx.textLayout.elements.InlineGraphicElementStatus;
    import flashx.textLayout.elements.SpanElement;
    import flashx.textLayout.elements.TextFlow;
    import flashx.textLayout.events.StatusChangeEvent;
    import flashx.textLayout.events.UpdateCompleteEvent;
    
    import spark.components.TextInput;

    public class MadLibManager
    {

        public static const DEFAULT_BLANK_HEIGHT:Number = 30;

        public static const DEFAULT_BLANK_WIDTH:Number = 100;

        //------------------------------------------------------------------
        //
        //  G E T T E R S / S E T T E R S 
        //
        //------------------------------------------------------------------

        public function get textFlow():TextFlow
        {
            return _textFlow;
        }

        public function set textFlow(value:TextFlow):void
        {
            if (_textFlow)
                tearDownTextFlow();

            _textFlow = value;

            if (_textFlow)
                setupTextFlow();
        }

        //------------------------------------------------------------------
        //
        //   P U B L I C    P R O P E R T I E S 
        //
        //------------------------------------------------------------------

        public var madLibBlankHeight:Number;

        public var madLibBlankWidth:Number;
		
        //------------------------------------------------------------------
        //
        //  P R I V A T E    P R O P E R T I E S 
        //
        //------------------------------------------------------------------

        private var elementBlankContainerMap:Dictionary;

        private var idLabelMap:Dictionary;

        private var idBlankMap:Dictionary;

        //------------------------------------------------------------------
        //  G E T T E R / S E T T E R    P R O P E R T I E S 
        //------------------------------------------------------------------

        private var _textFlow:TextFlow;

        //------------------------------------------------------------------
        //
        //  P U B L I C    M E T H O D S 
        //
        //------------------------------------------------------------------

        public function MadLibManager()
        {
            construct();
        }

        //------------------------------------------------------------------
        //
        //   P R I V A T E    M E T H O D S 
        //
        //------------------------------------------------------------------

        private function construct():void
        {
            textFlow = null;
            idBlankMap = null;
            madLibBlankWidth = DEFAULT_BLANK_WIDTH;
            madLibBlankHeight = DEFAULT_BLANK_HEIGHT;
        }
		
		private function createNewMadLibElement(id:String):InlineGraphicElement
		{
			var element:InlineGraphicElement = new InlineGraphicElement();
			element.id = id;
			element.width = madLibBlankWidth;
			element.height = madLibBlankHeight;
			element.source = null;
			return element;
		}

        private function createNewMadLibBlank(id:String):TextInput
        {
            var madLibBlank:TextInput = new TextInput();
            idBlankMap[id] = madLibBlank;
            madLibBlank.text = idLabelMap[id];
            return madLibBlank;
        }

        private function getMadLibBlankElementContainer(id:String, flowComposer:IFlowComposer = null):Sprite
        {
            if (!flowComposer)
                flowComposer = textFlow.flowComposer;

            var element:FlowElement = textFlow.getElementByID(id);
            var controllerIndex:int = flowComposer.findControllerIndexAtPosition(element.getAbsoluteStart());
            var controller:ContainerController = flowComposer.getControllerAt(controllerIndex);
            return controller ? controller.container : null;
        }

        private function setupTextFlow():void
        {
            textFlow.addEventListener(UpdateCompleteEvent.UPDATE_COMPLETE, textFlow_updateCompleteHandler);
            textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, textFlow_inlineGraphicStatusChangeHandler);
            idBlankMap = new Dictionary(true);
            idLabelMap = new Dictionary(true);
            elementBlankContainerMap = new Dictionary(true);
        }

        private function tearDownTextFlow():void
        {
            textFlow.removeEventListener(UpdateCompleteEvent.UPDATE_COMPLETE, textFlow_updateCompleteHandler);
            textFlow.removeEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, textFlow_inlineGraphicStatusChangeHandler);
            idBlankMap = null;
            idLabelMap = null;
            elementBlankContainerMap = null;
        }

        private function setupMadLibElements():void
        {
            var leaf:FlowLeafElement = textFlow.getFirstLeaf();
			var leafIndex:int = -1;
            if (MadLibUtil.isMadLibSpanElement(leaf))
            {
				leafIndex = textFlow.getChildIndex(leaf);
				textFlow.replaceChildren(leafIndex, leafIndex + 1, createNewMadLibElement(leaf.id));
            }
        }

        private function updateMadLibBlanks():void
        {
            var flowComposer:IFlowComposer = textFlow.flowComposer;

            var id:String = null;

            var element:InlineGraphicElement = null;
            var elementGraphic:DisplayObject = null;
            var elementGraphicPosition:Point = null;
            var elementContainer:Sprite = null;

            var madLibBlank:TextInput = null;
            var madLibBlankPosition:Point = null;
            var madLibBlankContainer:Sprite = null;

            for (id in idBlankMap)
            {
                textFlow.getElementByID(id) as InlineGraphicElement
                if (!element)
                {
                    getMadLibBlankElementContainer(id, flowComposer).removeChild(idBlankMap[element]);
                }
                else
                {
                    madLibBlank = idBlankMap[id];
                    // Update size of mad-lib blank dimensions.
                    madLibBlank.width = element.width;
                    madLibBlank.height = element.height;
                    // Get underlying graphic component rendered on the stage
                    // by the mad-lib blank element in the TextFlow.
                    elementGraphic = element.graphic;
                    // Match the position of the mad-lib blank input to the
                    // position of element graphic on the stage.
                    elementGraphicPosition = new Point(elementGraphic.x, elementGraphic.y);
                    elementGraphicPosition = elementGraphic.parent.localToGlobal(elementGraphicPosition);
                    elementContainer = getMadLibBlankElementContainer(id, flowComposer);
                    madLibBlankContainer = elementBlankContainerMap[elementContainer];
                    madLibBlankPosition = madLibBlankContainer.globalToLocal(elementGraphicPosition);
                }
            }
        }

        //------------------------------------------------------------------
        //  EVENT  HANDLERS 
        //------------------------------------------------------------------

        private function textFlow_inlineGraphicStatusChangeHandler(event:StatusChangeEvent):void
        {
            var element:InlineGraphicElement = event.element as InlineGraphicElement;
            var id:String = element.id;
            var status:String = event.status;

            if (id in idLabelMap &&
                (status == InlineGraphicElementStatus.SIZE_PENDING || status == InlineGraphicElementStatus.READY))
            {
                var madLibBlank:TextInput = !(id in idBlankMap) ?
                    createNewMadLibBlank(id) : idBlankMap[id];
                getMadLibBlankElementContainer(id, textFlow.flowComposer).addChild(madLibBlank);
            }

        }

        private function textFlow_updateCompleteHandler(event:UpdateCompleteEvent):void
        {
            updateMadLibBlanks();
        }
    }
}