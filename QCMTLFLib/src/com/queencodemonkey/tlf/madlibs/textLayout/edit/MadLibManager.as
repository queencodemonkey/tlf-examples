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
package com.queencodemonkey.tlf.madlibs.textLayout.edit
{
    import com.queencodemonkey.tlf.madlibs.textLayout.utils.MadLibUtil;
    
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.geom.Point;
    import flash.utils.Dictionary;
    
    import flashx.textLayout.compose.IFlowComposer;
    import flashx.textLayout.compose.TextFlowLine;
    import flashx.textLayout.container.ContainerController;
    import flashx.textLayout.conversion.ConversionType;
    import flashx.textLayout.conversion.TextConverter;
    import flashx.textLayout.edit.TextScrap;
    import flashx.textLayout.elements.FlowElement;
    import flashx.textLayout.elements.FlowGroupElement;
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

        public static const DEFAULT_BLANK_MAX_CHARS:Number = 25;

        public static const DEFAULT_BLANK_PADDING_LEFT:Number = 5;

        public static const DEFAULT_BLANK_PADDING_RIGHT:Number = 5;

        public static const DEFAULT_BLANK_WIDTH:Number = 220;

        //------------------------------------------------------------------
        //
        //  G E T T E R S / S E T T E R S 
        //
        //------------------------------------------------------------------

        public function get blankInputContainer():Sprite
        {
            return _blankInputContainer;
        }

        public function set blankInputContainer(value:Sprite):void
        {
            if (_blankInputContainer)
                tearDownContainer();

            _blankInputContainer = value;

            if (_blankInputContainer)
                setupContainer();
        }

        public function get blankStyleName():String
        {
            return _blankStyleName;
        }

        public function set blankStyleName(value:String):void
        {
            _blankStyleName = value;

            if (_blankStyleName)
                updateBlankInputStyles();
        }

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

        public var blankInputHeight:Number;

        public var blankInputPaddingLeft:Number;

        public var blankInputPaddingRight:Number;

        public var blankInputWidth:Number;

        //------------------------------------------------------------------
        //
        //  P R I V A T E    P R O P E R T I E S 
        //
        //------------------------------------------------------------------

        //        private var elementBlankContainerMap:Dictionary;

        private var idBlankInputMap:Dictionary;

        private var idBlankLabelMap:Dictionary;

        //------------------------------------------------------------------
        //  G E T T E R / S E T T E R    P R O P E R T I E S 
        //------------------------------------------------------------------

        private var _blankInputContainer:Sprite;

        private var _blankStyleName:String;

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

        public function addBlank(label:String):String
        {
            var editManager:MadLibEditManager = textFlow.interactionManager as MadLibEditManager;
            if (editManager && editManager.hasSelection())
            {
                var id:String = MadLibUtil.generateMadLibBlankID();
                idBlankLabelMap[id] = label;
                editManager.insertMadLibBlankElement(id,
                                                     blankInputWidth + blankInputPaddingLeft + blankInputPaddingRight,
                                                     blankInputHeight);
                return id;
            }
            else
            {
                return null;
            }
        }

        public function export():String
        {
            if (textFlow)
            {
                var textFlowCopy:TextFlow = textFlow.deepCopy() as TextFlow;
                var elements:Vector.<InlineGraphicElement> = new Vector.<InlineGraphicElement>();
                for (var id:String in idBlankInputMap)
                {
                    elements[elements.length] = textFlowCopy.getElementByID(id) as InlineGraphicElement;
                }
                var element:InlineGraphicElement = null;
                var elementIndex:int = -1;
                var parent:FlowGroupElement = null;
                var sibling:FlowLeafElement = null;
                var rightSiblingIsBlankElement:Boolean = false;
                while (elements.length > 0)
                {
                    element = elements.pop();
                    parent = element.parent;
                    elementIndex = parent.getChildIndex(element);
                    sibling = element.getNextSibling() as FlowLeafElement;
                    rightSiblingIsBlankElement = sibling && (MadLibUtil.isMadLibBlankElement(sibling) || sibling.textLength == 0);
                    parent.replaceChildren(elementIndex, elementIndex + 1, createFilledBlankElement(element.id, rightSiblingIsBlankElement));
                }
                return TextConverter.export(textFlowCopy, TextConverter.PLAIN_TEXT_FORMAT, ConversionType.STRING_TYPE) as String;
            }
            else
            {
                return "";
            }
        }

        public function replaceDuplicateMadLibIDs(textScrap:TextScrap):void
        {
            var blankElements:Vector.<FlowLeafElement> = MadLibUtil.findBlankElements(textScrap);
            var oldID:String = null;
            var newID:String = null;
            for each (var blankElement:FlowLeafElement in blankElements)
            {
                oldID = blankElement.id
                if (oldID in idBlankLabelMap)
                {
                    newID = MadLibUtil.generateMadLibBlankID();
                    blankElement.id = newID;
                    idBlankLabelMap[newID] = idBlankLabelMap[oldID];
                }
            }
        }

        //------------------------------------------------------------------
        //
        //   P R I V A T E    M E T H O D S 
        //
        //------------------------------------------------------------------

        private function clearContainer():void
        {
            while (blankInputContainer.numChildren > 0)
            {
                blankInputContainer.removeChildAt(0);
            }
        }

        private function construct():void
        {
            textFlow = null;
            idBlankInputMap = null;
            idBlankLabelMap = null;
            blankInputWidth = DEFAULT_BLANK_WIDTH;
            blankInputHeight = DEFAULT_BLANK_HEIGHT;
            blankInputPaddingLeft = DEFAULT_BLANK_PADDING_LEFT;
            blankInputPaddingRight = DEFAULT_BLANK_PADDING_RIGHT;
            blankStyleName = null;
        }

        private function createFilledBlankElement(id:String, addExtraSpace:Boolean = false):SpanElement
        {
            var filledBlankSpan:SpanElement = new SpanElement();
            filledBlankSpan.id = id;
            filledBlankSpan.text = (idBlankInputMap[id] as TextInput).text;
            if (filledBlankSpan.text == idBlankLabelMap[id])
                filledBlankSpan.text = "<" + filledBlankSpan.text + ">";
            if (addExtraSpace)
                filledBlankSpan.text += " ";
            return filledBlankSpan;
        }

        private function createNewBlankElement(id:String):InlineGraphicElement
        {
            var element:InlineGraphicElement = new InlineGraphicElement();
            element.id = id;
            element.width = blankInputWidth + blankInputPaddingLeft + blankInputPaddingRight;
            element.height = blankInputHeight;
            element.source = null;
            return element;
        }

        private function createNewBlankInput(id:String):TextInput
        {
            var blankInput:TextInput = new TextInput();
            idBlankInputMap[id] = blankInput;
            blankInput.text = idBlankLabelMap[id];
            blankInput.maxChars = DEFAULT_BLANK_MAX_CHARS;
            if (blankStyleName)
                blankInput.styleName = blankStyleName;
            return blankInput;
        }

        private function getBlankElementContainer(id:String, flowComposer:IFlowComposer = null):Sprite
        {
            if (!flowComposer)
                flowComposer = textFlow.flowComposer;

            var element:FlowElement = textFlow.getElementByID(id);
            var controllerIndex:int = flowComposer.findControllerIndexAtPosition(element.getAbsoluteStart());
            var controller:ContainerController = flowComposer.getControllerAt(controllerIndex);
            return controller ? controller.container : null;
        }

        private function orderBlanks():void
        {
            var element:InlineGraphicElement = null;
            var elements:Vector.<InlineGraphicElement> = new Vector.<InlineGraphicElement>();
            for (var id:String in idBlankInputMap)
            {
                element = textFlow.getElementByID(id) as InlineGraphicElement;
                if (element)
                    elements[elements.length] = element;
            }
            elements = elements.sort(sortBlankElements);
            var numElements:int = elements.length;
            for (var i:int = 0; i < numElements; i++)
            {
                (idBlankInputMap[elements[i].id] as TextInput).tabIndex = i;
            }
        }

        private function setupBlankElements():void
        {
            var leaf:FlowLeafElement = textFlow.getFirstLeaf();
            var blankElements:Vector.<SpanElement> = new Vector.<SpanElement>();
            while (leaf)
            {
                if (MadLibUtil.isMadLibSpanElement(leaf))
                {
                    blankElements[blankElements.length] = leaf as SpanElement;
                }
                leaf = leaf.getNextLeaf();
            }
            var blankElement:SpanElement = null;
            var newBlankElement:InlineGraphicElement = null;
            var blankID:String = null;
            var blankElementIndex:int = -1;
            var parent:FlowGroupElement = null;
            while (blankElements.length > 0)
            {
                blankElement = blankElements.pop();
                blankID = blankElement.id;
                idBlankLabelMap[blankID] = blankElement.text;
                parent = blankElement.parent;
                blankElementIndex = parent.getChildIndex(blankElement);

                newBlankElement = new InlineGraphicElement();
                newBlankElement.id = blankID;
                newBlankElement.width = blankInputWidth + blankInputPaddingLeft + blankInputPaddingRight;
                newBlankElement.height = blankInputHeight;
                newBlankElement.source = null;

                parent.replaceChildren(blankElementIndex, blankElementIndex + 1, newBlankElement);
            }
        }

        private function setupContainer():void
        {
            clearContainer();
            if (textFlow && !textFlow.flowComposer.composing)
            {
                updateBlankInputs();
            }
        }

        private function setupTextFlow():void
        {
            textFlow.addEventListener(UpdateCompleteEvent.UPDATE_COMPLETE, textFlow_updateCompleteHandler);
            textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, textFlow_inlineGraphicStatusChangeHandler);
            idBlankInputMap = new Dictionary(true);
            idBlankLabelMap = new Dictionary(true);
            //            elementBlankContainerMap = new Dictionary(true);
            setupBlankElements();
            textFlow.flowComposer.updateAllControllers();
        }

        private function sortBlankElements(elementA:InlineGraphicElement, elementB:InlineGraphicElement):Number
        {
            var absoluteStartA:int = elementA.getAbsoluteStart();
            var absoluteStartB:int = elementB.getAbsoluteStart();
            return absoluteStartA == absoluteStartB ? 0 : (absoluteStartA < absoluteStartB ? -1 : 1);
        }

        private function tearDownContainer():void
        {
            clearContainer();
        }

        private function tearDownTextFlow():void
        {
            textFlow.removeEventListener(UpdateCompleteEvent.UPDATE_COMPLETE, textFlow_updateCompleteHandler);
            textFlow.removeEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, textFlow_inlineGraphicStatusChangeHandler);
            idBlankInputMap = null;
            idBlankLabelMap = null;
            //            elementBlankContainerMap = null;
        }

        private function updateBlankInputStyles():void
        {
            for each (var blank:TextInput in idBlankInputMap)
            {
                blank.styleName = blankStyleName;
            }
        }

        private function updateBlankInputs():void
        {
            var flowComposer:IFlowComposer = textFlow.flowComposer;

            var id:String = null;

            var blankElement:InlineGraphicElement = null;
            var blankElementGraphic:DisplayObject = null;
            var blankElementGraphicPosition:Point = null;
            //            var elementContainer:Sprite = null;
            var blankElementTextFlowLine:TextFlowLine = null;

            var blankInput:TextInput = null;
            var blankInputPosition:Point = null;

            for (id in idBlankInputMap)
            {
                blankElement = textFlow.getElementByID(id) as InlineGraphicElement
                if (!blankElement)
                {
                    // TODO: See if we can efficiently use the rendered text
                    // container to place the mad lib inputs.
                    //                    getBlankElementContainer(id, flowComposer).removeChild(idBlankMap[element]);
                    blankInput = idBlankInputMap[id];
                    if (blankInputContainer.contains(blankInput))
                        blankInputContainer.removeChild(blankInput);
                }
                else
                {
                    blankInput = idBlankInputMap[id];

                    if (blankInputContainer.getChildIndex(blankInput) == -1)
                        blankInputContainer.addChild(blankInput);

                    // Update size of mad-lib blank dimensions.
                    blankInput.width = blankInputWidth;
                    blankInput.height = blankInputHeight;

                    // Get underlying graphic component rendered on the stage
                    // by the mad-lib blank element in the TextFlow.
                    blankElementGraphic = blankElement.graphic;
                    if (blankElementGraphic && blankElementGraphic.parent)
                    {
                        // Match the position of the mad-lib blank input to the
                        // position of element graphic on the stage.
                        blankElementGraphicPosition = new Point(blankElementGraphic.x, blankElementGraphic.y);
                        blankElementGraphicPosition = blankElementGraphic.parent.localToGlobal(blankElementGraphicPosition);

                        // TODO: See if we can efficiently use the rendered text
                        // container to place the mad lib inputs.
                        //                    elementContainer = getBlankElementContainer(id, flowComposer);
                        //                    madLibBlankContainer = elementBlankContainerMap[elementContainer];
                        //                    madLibBlankPosition = madLibBlankContainer.globalToLocal(elementGraphicPosition);

                        blankInputPosition = blankInputContainer.globalToLocal(blankElementGraphicPosition);
                        blankElementTextFlowLine = textFlow.flowComposer.findLineAtPosition(blankElement.getAbsoluteStart());
                        blankInput.x = blankInputPosition.x + blankInputPaddingLeft;
                        blankInput.y = blankInputPosition.y + (blankElementTextFlowLine.textHeight >> 2);
                    }
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

            if (id in idBlankLabelMap &&
                (status == InlineGraphicElementStatus.SIZE_PENDING || status == InlineGraphicElementStatus.READY))
            {
                var madLibBlank:TextInput = !(id in idBlankInputMap) ?
                    createNewBlankInput(id) : idBlankInputMap[id];

                // TODO: See if we can efficiently use the rendered text
                // container to place the mad lib inputs.
                //getBlankElementContainer(id, textFlow.flowComposer).addChild(madLibBlank);
                blankInputContainer.addChild(madLibBlank);
            }

        }

        private function textFlow_updateCompleteHandler(event:UpdateCompleteEvent):void
        {
            updateBlankInputs();
            orderBlanks();
        }
    }
}