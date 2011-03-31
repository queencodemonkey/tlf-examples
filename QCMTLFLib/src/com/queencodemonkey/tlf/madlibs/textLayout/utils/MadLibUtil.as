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
package com.queencodemonkey.tlf.madlibs.textLayout.utils
{
    import flashx.textLayout.edit.ElementRange;
    import flashx.textLayout.edit.SelectionState;
    import flashx.textLayout.edit.TextScrap;
    import flashx.textLayout.elements.FlowElement;
    import flashx.textLayout.elements.FlowGroupElement;
    import flashx.textLayout.elements.FlowLeafElement;
    import flashx.textLayout.elements.InlineGraphicElement;
    import flashx.textLayout.elements.SpanElement;
    import flashx.textLayout.elements.TextFlow;
    import flashx.textLayout.tlf_internal;

    import mx.utils.UIDUtil;

    use namespace tlf_internal;

    public class MadLibUtil
    {
        public static const MAD_LIB_BLANK_ID_PREFIX:String = "madlib_blank_";

        private static const MAD_LIB_BLANK_ID_REGEXP:RegExp = /madlib_blank_[A-F0-9\-]+/;

        //------------------------------------------------------------------
        //
        // P U B L I C    S T A T I C    M E T H O D S 
        //
        //------------------------------------------------------------------

        public static function containsMadLibBlank(selectionState:SelectionState):Boolean
        {
            var elementRange:ElementRange = ElementRange.createElementRange(selectionState.textFlow, selectionState.absoluteStart, selectionState.absoluteEnd);
            var leaf:FlowLeafElement = elementRange.firstLeaf;
            var hasBlanks:Boolean = false;
            while (leaf && leaf != elementRange.lastLeaf && !hasBlanks)
            {
                hasBlanks = isMadLibBlank(leaf);
                leaf = leaf.getNextLeaf();
            }
            return hasBlanks;
        }

        public static function findBlankElements(source:Object):Vector.<FlowLeafElement>
        {
            var blankElements:Vector.<FlowLeafElement> = new Vector.<FlowLeafElement>();
            var elementRange:ElementRange = null;
            var leaf:FlowLeafElement = null;
            if (source is ElementRange)
            {
                elementRange = source as ElementRange;
            }
            else if (source is FlowLeafElement)
            {
                leaf = source as FlowLeafElement;
                if (isMadLibBlank(leaf))
                {
                    blankElements[blankElements.length] = leaf;
                }
            }
            else if (source is TextFlow || source is TextScrap || source is FlowGroupElement)
            {
                var textFlow:TextFlow = source is TextFlow ? source as TextFlow :
                    (source is TextScrap ? (source as TextScrap).textFlow :
                    (source as FlowGroupElement).getTextFlow());
                var absoluteStart:int = textFlow.getAbsoluteStart();
                elementRange = ElementRange.createElementRange(textFlow, absoluteStart, absoluteStart + textFlow.textLength);
            }
            leaf = elementRange.firstLeaf;
            while (leaf && leaf != elementRange.lastLeaf)
            {
                if (isMadLibBlank(leaf))
                {
                    blankElements[blankElements.length] = leaf;
                }
                leaf = leaf.getNextLeaf();
            }
            return blankElements;
        }

        public static function generateMadLibBlankID():String
        {
            return MAD_LIB_BLANK_ID_PREFIX + UIDUtil.createUID();
        }

        public static function isMadLibBlank(element:FlowElement):Boolean
        {
            return (element is SpanElement || element is InlineGraphicElement) && MAD_LIB_BLANK_ID_REGEXP.test(element.id);
        }

        public static function isMadLibBlankElement(element:FlowElement):Boolean
        {
            return element is InlineGraphicElement && MAD_LIB_BLANK_ID_REGEXP.test(element.id);
        }

        public static function isMadLibSpanElement(element:FlowElement):Boolean
        {
            return element is SpanElement && MAD_LIB_BLANK_ID_REGEXP.test(element.id);
        }

        //------------------------------------------------------------------
        //
        //  P U B L I C    M E T H O D S 
        //
        //------------------------------------------------------------------

        /**
         * Constructor.
         *
         * Restricted for type safety.
         */
        public function MadLibUtil(enforcer:StaticEnforcer)
        {
        }
    }
}

/**
 * The StaticEnforcer class is an internal class used for type safety by
 * prohibiting instantiation.
 */
internal class StaticEnforcer
{
}