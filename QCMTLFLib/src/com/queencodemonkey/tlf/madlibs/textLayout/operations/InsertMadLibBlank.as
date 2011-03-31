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
package com.queencodemonkey.tlf.madlibs.textLayout.operations
{
    import flashx.textLayout.edit.ElementRange;
    import flashx.textLayout.edit.ParaEdit;
    import flashx.textLayout.edit.SelectionState;
    import flashx.textLayout.elements.FlowElement;
    import flashx.textLayout.elements.FlowGroupElement;
    import flashx.textLayout.elements.FlowLeafElement;
    import flashx.textLayout.elements.InlineGraphicElement;
    import flashx.textLayout.elements.SubParagraphGroupElement;
    import flashx.textLayout.formats.ITextLayoutFormat;
    import flashx.textLayout.formats.TextLayoutFormat;
    import flashx.textLayout.operations.DeleteTextOperation;
    import flashx.textLayout.operations.FlowTextOperation;
    import flashx.textLayout.tlf_internal;

    use namespace tlf_internal;

    public class InsertMadLibBlank extends FlowTextOperation
    {

        //------------------------------------------------------------------
        //
        //  G E T T E R S / S E T T E R S 
        //
        //------------------------------------------------------------------

        /**
         * @copy flashx.textLayout.elements.InlineGraphicElement#height
         *
         * @see flashx.textLayout.InlineGraphicElement#height
         *
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         */
        public function get height():Object
        {
            return imageHeight;
        }

        /**
         * @private
         */
        public function set height(value:Object):void
        {
            imageHeight = value;
        }

        /**
         * The ID of the new mad lib blank.
         *
         * @return A string that is the ID of the new mad lib blank.
         *
         * @see com.queencodemonkey.tlf.madlibs.textLayout.utils.MadLibUtil#generateMadLibBlankId
         */
        public function get id():String
        {
            return _id;
        }

        /**
         * @private
         */
        public function set id(value:String):void
        {
            _id = value;
        }

        /**
         * @copy flashx.textLayout.elements.InlineGraphicElement#width
         *
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         */
        public function get width():Object
        {
            return imageWidth;
        }

        public function set width(value:Object):void
        {
            imageWidth = value;
        }

        //------------------------------------------------------------------
        //
        //  P R I V A T E    P R O P E R T I E S 
        //
        //------------------------------------------------------------------

        private var delSelOp:DeleteTextOperation;

        private var imageHeight:Object;

        private var imageWidth:Object;

        private var selPos:int = 0;

        //------------------------------------------------------------------
        //  G E T T E R / S E T T E R    P R O P E R T I E S 
        //------------------------------------------------------------------

        private var _id:String = null;

        //------------------------------------------------------------------
        //
        //  P U B L I C    M E T H O D S 
        //
        //------------------------------------------------------------------

        /**
         * Constructor.
         *
         * @param operationState Describes the insertion point.
         * If a range is selected, the operation deletes the contents of that range.
         * @param id Identifier assigned to mad lib blank.
         * @param width	The width to assign (number of pixels, percent, or the string 'auto').
         * @param height The height to assign (number of pixels, percent, or the string 'auto').
         *
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         */
        function InsertMadLibBlank(operationState:SelectionState, id:String, width:Object, height:Object)
        {
            super(operationState);

            if (absoluteStart != absoluteEnd)
                delSelOp = new DeleteTextOperation(operationState);

            this.id = id;
            imageWidth = width;
            imageHeight = height;
        }

        /**
         * @inheritDoc
         */
        override public function doOperation():Boolean
        {
            var pointFormat:ITextLayoutFormat;

            selPos = absoluteStart;
            if (delSelOp)
            {
                var leafEl:FlowLeafElement = textFlow.findLeaf(absoluteStart);
                var deleteFormat:ITextLayoutFormat = new TextLayoutFormat(textFlow.findLeaf(absoluteStart).format);
                if (delSelOp.doOperation())
                    pointFormat = deleteFormat;
            }
            else
                pointFormat = originalSelectionState.pointFormat;

            // lean left logic included
            var range:ElementRange = ElementRange.createElementRange(textFlow, selPos, selPos);
            var leafNode:FlowElement = range.firstLeaf;
            var leafNodeParent:FlowGroupElement = leafNode.parent;
            while (leafNodeParent is SubParagraphGroupElement)
            {
                var subParInsertionPoint:int = selPos - leafNodeParent.getAbsoluteStart();
                if (((subParInsertionPoint == 0) && (!(leafNodeParent as SubParagraphGroupElement).acceptTextBefore())) ||
                    ((subParInsertionPoint == leafNodeParent.textLength) && (!(leafNodeParent as SubParagraphGroupElement).acceptTextAfter())))
                {
                    leafNodeParent = leafNodeParent.parent;
                }
                else
                {
                    break;
                }
            }

            var blankElement:InlineGraphicElement = ParaEdit.createImage(leafNodeParent, selPos - leafNodeParent.getAbsoluteStart(), null, imageWidth, imageHeight, null, pointFormat);
            blankElement.id = id;
            if (textFlow.interactionManager)
                textFlow.interactionManager.notifyInsertOrDelete(absoluteStart, 1);

            return true;
        }

        /**
         * Re-executes the operation after it has been undone.
         *
         * <p>This function is called by the edit manager, when necessary.</p>
         *
         * @playerversion Flash 10
         * @playerversion AIR 1.5
         * @langversion 3.0
         */
        override public function redo():SelectionState
        {
            doOperation();
            return new SelectionState(textFlow, selPos + 1, selPos + 1, null);
        }

        /**
         * @inheritDoc
         */
        override public function undo():SelectionState
        {
            var leafNode:FlowElement = textFlow.findLeaf(selPos);
            var leafNodeParent:FlowGroupElement = leafNode.parent;
            var elementIdx:int = leafNode.parent.getChildIndex(leafNode);
            leafNodeParent.replaceChildren(elementIdx, elementIdx + 1, null);

            if (textFlow.interactionManager)
                textFlow.interactionManager.notifyInsertOrDelete(absoluteStart, -1);

            return delSelOp ? delSelOp.undo() : originalSelectionState;
        }
    }
}