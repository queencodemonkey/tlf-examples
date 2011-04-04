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
package com.queencodemonkey.tlf.bookmarks.components
{
    import com.queencodemonkey.tlf.bookmarks.events.LineNumberColumnEvent;

    import flash.display.Graphics;
    import flash.events.MouseEvent;
    import flash.text.engine.ElementFormat;
    import flash.text.engine.FontDescription;
    import flash.text.engine.TextBlock;
    import flash.text.engine.TextElement;
    import flash.text.engine.TextLine;
    import flash.ui.ContextMenu;

    import flashx.textLayout.factory.StringTextLineFactory;
    import flashx.textLayout.formats.TextLayoutFormat;

    import spark.core.SpriteVisualElement;

    [Event(name="lineNumberSelected", type="com.queencodemonkey.tlf.bookmarks.events.LineNumberColumnEvent")]
    public class LineNumberColumn extends SpriteVisualElement
    {
        private static const DEFAULT_BACKGROUND_COLOR:uint = 0xCCCCCC;

        private static const DEFAULT_FONT_COLOR:uint = 0x333333;

        private static const DEFAULT_FONT_FAMILY:String = "Courier New, Courier, mono";

        private static const DEFAULT_FONT_SIZE:Number = 14;

        private static const DEFAULT_PADDING_LEFT:Number = 5;

        private static const DEFAULT_PADDING_RIGHT:Number = 5;

        //------------------------------------------------------------------
        //
        //  G E T T E R S / S E T T E R S 
        //
        //------------------------------------------------------------------

        public function get format():ElementFormat
        {
            return _format;
        }

        public function set format(value:ElementFormat):void
        {
            if (_format != value)
            {
                _format = value;
                formatDirty = true;
                invalidateParentSizeAndDisplayList();
            }
        }

        public function get lineHeight():Number
        {
            return _lineHeight;
        }

        public function set lineHeight(value:Number):void
        {
            if (_lineHeight != value)
            {
                _lineHeight = value;
                lineHeightDirty = true;
                invalidateParentSizeAndDisplayList();
            }
        }

        public function get numLines():int
        {
            return _numLines;
        }

        public function set numLines(value:int):void
        {
            if (_numLines != value)
            {
                _numLines = value;
                numLinesDirty = true;
                invalidateParentSizeAndDisplayList();
            }
        }

        override public function set width(value:Number):void
        {
            if (super.width != value)
            {
                super.width = value;
                widthDirty = true;
                invalidateParentSizeAndDisplayList();
            }
        }

        //------------------------------------------------------------------
        //
        //   P U B L I C    P R O P E R T I E S 
        //
        //------------------------------------------------------------------

        public var backgroundColor:uint;

        public var paddingLeft:Number;

        public var paddingRight:Number;

        //------------------------------------------------------------------
        //
        //  P R I V A T E    P R O P E R T I E S 
        //
        //------------------------------------------------------------------

        private var factory:StringTextLineFactory;

        private var lineNumberPool:Vector.<TextLine>;

        private var lineNumbers:Vector.<TextLine>;

        //------------------------------------------------------------------
        //  G E T T E R / S E T T E R    P R O P E R T I E S 
        //------------------------------------------------------------------

        private var _format:ElementFormat;

        private var _lineHeight:Number;

        private var _numLines:int = 0;

        //------------------------------------------------------------------
        //  D I R T Y    F L A G S 
        //------------------------------------------------------------------

        private var formatDirty:Boolean;

        private var lineHeightDirty:Boolean;

        private var numLinesDirty:Boolean;

        private var widthDirty:Boolean;

        //------------------------------------------------------------------
        //
        //  P U B L I C    M E T H O D S 
        //
        //------------------------------------------------------------------

        public function LineNumberColumn()
        {
            super();

            construct();
        }

        /**
         * Called during the validation pass by the Flex LayoutManager via
         * the layout object.
         * @param width
         * @param height
         * @param postLayoutTransform
         *
         */
        override public function setLayoutBoundsSize(width:Number, height:Number, postLayoutTransform:Boolean = true):void
        {
            super.setLayoutBoundsSize(width, height, postLayoutTransform);

            if (formatDirty || lineHeightDirty || numLinesDirty || widthDirty)
            {
                if (formatDirty || widthDirty)
                {
                    clearNumbers();
                }
                updateNumbers();
            }

            if (formatDirty)
                formatDirty = false;

            if (numLinesDirty)
                numLinesDirty = false;

            if (widthDirty)
                widthDirty = false;

            layoutNumbers();
        }

        //------------------------------------------------------------------
        //
        //   P R I V A T E    M E T H O D S 
        //
        //------------------------------------------------------------------

        private function clearNumbers():void
        {
            lineNumbers = new Vector.<TextLine>();

            lineNumberPool = new Vector.<TextLine>();
        }

        private function construct():void
        {
            clearNumbers();

            backgroundColor = DEFAULT_BACKGROUND_COLOR;

            format = new ElementFormat();
            format.fontDescription = new FontDescription(DEFAULT_FONT_FAMILY);
            format.fontSize = DEFAULT_FONT_SIZE;
            format.color = DEFAULT_FONT_COLOR;

            lineHeight = NaN;

            paddingLeft = DEFAULT_PADDING_LEFT;
            paddingRight = DEFAULT_PADDING_RIGHT;
        }

        private function generateNumbers(start:int = 1, end:int = -1):Vector.<TextLine>
        {
            var numberString:String = "";
            var newLineNumbers:Vector.<TextLine> = new Vector.<TextLine>();
            for (var i:int = start; i <= end; i++)
            {
                if (numberString.length > 0)
                    numberString += "\n";
                numberString += i.toString();
            }
            var textElement:TextElement = new TextElement(numberString, format)
            var textBlock:TextBlock = new TextBlock(textElement);
            var previousLine:TextLine = textBlock.createTextLine(null, width - paddingLeft - paddingRight);
            while (previousLine)
            {
                newLineNumbers[newLineNumbers.length] = previousLine;
                previousLine = textBlock.createTextLine(previousLine, width - paddingLeft - paddingRight);
            }
            return newLineNumbers;
        }

        private function layoutNumbers():void
        {
            var x:Number = 0;
            var totalHeight:Number = 0;
            var textLine:TextLine = null;
            var numLineNumbers:int = lineNumbers.length;
            for (var i:int = 0; i < numLineNumbers; i++)
            {
                textLine = lineNumbers[i];
                textLine.x = width - paddingLeft - textLine.width;
                if (isNaN(lineHeight))
                {
                    textLine.y = totalHeight + textLine.ascent;
                    totalHeight += textLine.height;
                }
                else
                {
                    textLine.y = totalHeight + lineHeight - textLine.descent;
                    totalHeight += lineHeight;
                }
            }
            height = totalHeight;

            var graphics:Graphics = this.graphics;
            graphics.clear();
//            graphics.beginFill(backgroundColor);
            graphics.lineStyle(1, backgroundColor);
            graphics.moveTo(width, 0);
            graphics.lineTo(width, height);
//            graphics.drawRect(0, 0, width, height);
        }

        private function updateNumbers():void
        {
            var numLineNumbers:int = lineNumbers.length;
            var textLine:TextLine = null;
            if (numLineNumbers > numLines)
            {
                var removedLineNumbers:Vector.<TextLine> = lineNumbers.splice(numLines, numLineNumbers - numLines);
                for each (textLine in removedLineNumbers)
                {
                    textLine.removeEventListener(MouseEvent.CLICK, textLine_clickHandler);
                    removeChild(textLine);
                }
                lineNumberPool = lineNumberPool.concat(removedLineNumbers);
            }
            else if (numLineNumbers < numLines)
            {
                var addedLineNumbers:Vector.<TextLine> = null;
                if (lineNumberPool.length > 0)
                {
                    var diff:int = Math.min(lineNumberPool.length, numLines - numLineNumbers);
                    addedLineNumbers = lineNumberPool.splice(0, diff);
                    for each (textLine in addedLineNumbers)
                    {
                        textLine.addEventListener(MouseEvent.CLICK, textLine_clickHandler);
                        addChild(textLine);
                    }
                    lineNumbers = lineNumbers.concat(addedLineNumbers);
                }
                numLineNumbers = lineNumbers.length;
                if (numLineNumbers < numLines)
                {
                    addedLineNumbers = generateNumbers(numLineNumbers + 1, numLines);
                    for each (textLine in addedLineNumbers)
                    {
                        textLine.addEventListener(MouseEvent.CLICK, textLine_clickHandler);
                        addChild(textLine);
                    }
                    lineNumbers = lineNumbers.concat(addedLineNumbers);

                }
            }
        }

        //------------------------------------------------------------------
        //  EVENT  HANDLERS 
        //------------------------------------------------------------------

        private function textLine_clickHandler(event:MouseEvent):void
        {
            dispatchEvent(new LineNumberColumnEvent(LineNumberColumnEvent.LINE_NUMBER_SELECTED, false, false, lineNumbers.indexOf(event.currentTarget) + 1));
        }
    }
}