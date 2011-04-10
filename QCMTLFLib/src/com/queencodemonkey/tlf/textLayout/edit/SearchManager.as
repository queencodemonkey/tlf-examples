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
package com.queencodemonkey.tlf.textLayout.edit
{
    import com.queencodemonkey.tlf.textLayout.operations.ReplaceSearchResultOperation;
    import com.queencodemonkey.tlf.textLayout.supportClasses.SearchResult;

    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.geom.Rectangle;
    import flash.text.engine.TextLine;
    import flash.utils.Dictionary;

    import flashx.textLayout.compose.IFlowComposer;
    import flashx.textLayout.compose.TextFlowLine;
    import flashx.textLayout.edit.EditManager;
    import flashx.textLayout.edit.IEditManager;
    import flashx.textLayout.edit.SelectionState;
    import flashx.textLayout.elements.TextFlow;
    import flashx.textLayout.operations.InsertTextOperation;
    import flashx.textLayout.tlf_internal;

    use namespace tlf_internal;

    public class SearchManager
    {

        private static const DEFAULT_HIGHLIGHT_ALPHA:Number = 0.5;

        private static const DEFAULT_HIGHLIGHT_COLOR:uint = 0x999999;

        //------------------------------------------------------------------
        //
        //  G E T T E R S / S E T T E R S 
        //
        //------------------------------------------------------------------

        public function get highlightAlpha():Number
        {
            return _highlightAlpha;
        }

        public function set highlightAlpha(value:Number):void
        {
            _highlightAlpha = value;
        }

        public function get highlightColor():uint
        {
            return _highlightColor;
        }

        public function set highlightColor(value:uint):void
        {
            _highlightColor = value;
        }

        public function get lastSearch():String
        {
            return searchHistory[searchHistory.length - 1];
        }

        public function get numResults():int
        {
            return searchResults.length;
        }

        public function get showingHighlights():Boolean
        {
            return _showingHighlights;
        }

        public function get textFlow():TextFlow
        {
            return _textFlow;
        }

        public function set textFlow(value:TextFlow):void
        {
            _textFlow = value;

            clearSearchResults();
        }

        //------------------------------------------------------------------
        //
        //   P U B L I C    P R O P E R T I E S 
        //
        //------------------------------------------------------------------

        public var replaceHistory:Vector.<String>;

        public var searchHistory:Vector.<String>;

        public var searchResults:Vector.<SearchResult>;

        //------------------------------------------------------------------
        //
        //  P R I V A T E    P R O P E R T I E S 
        //
        //------------------------------------------------------------------

        private var spritePool:Vector.<Sprite>;

        private var textFlowLineSpriteMap:Dictionary;

        //------------------------------------------------------------------
        //  G E T T E R / S E T T E R    P R O P E R T I E S 
        //------------------------------------------------------------------

        private var _highlightAlpha:Number;

        private var _highlightColor:uint;

        private var _showingHighlights:Boolean = false;

        private var _textFlow:TextFlow;

        //------------------------------------------------------------------
        //
        //  P U B L I C    M E T H O D S 
        //
        //------------------------------------------------------------------

        public function SearchManager()
        {
            construct();
        }

        public function clearHighlights():void
        {
            for each (var sprite:Sprite in textFlowLineSpriteMap)
            {
                sprite.graphics.clear();
                spritePool[spritePool.length] = sprite.parent.removeChild(sprite) as Sprite;
            }
			textFlowLineSpriteMap = new Dictionary(true);
            _showingHighlights = false;
        }

        public function clearSearchResults():void
        {
            if (searchResults.length > 0)
                searchResults.splice(0, searchResults.length);
        }

        public function highlightResults():void
        {
            var numResults:int = searchResults.length;
            if (numResults > 0)
            {
                for (var i:int = 0; i < numResults; i++)
                {
                    addResultHighlight(searchResults[i]);
                }
                _showingHighlights = true;
            }
        }

        public function search(searchString:String, replaceString:String = null, caseInsensitive:Boolean = false, useRegularExpressions:Boolean = false):void
        {
            clearHighlights();
            if (textFlow)
            {
                searchHistory[searchHistory.length] = searchString;

                clearSearchResults();

                var plainText:String = textFlow.getText();
                var result:Object = null;
                if (useRegularExpressions)
                {
                    var options:String = caseInsensitive ? "gi" : "g";
                    var regex:RegExp = new RegExp(searchString, options);

                    var match:String = null;
                    var absoluteStart:int = -1;
                    var absoluteEnd:int = -1;

                    result = regex.exec(plainText);
                    while (result)
                    {
                        match = result[0];
                        absoluteStart = result.index;
                        absoluteEnd = absoluteStart + match.length - 1;
                        searchResults[searchResults.length] = new SearchResult(searchString, absoluteStart, absoluteEnd);
                        result = regex.exec(plainText);
                    }
                }
                else
                {
                    if (caseInsensitive)
                    {
                        plainText = plainText.toUpperCase();
                        searchString = searchString.toUpperCase();
                    }
                    var length:int = searchString.length;
                    var index:int = plainText.indexOf(searchString);
                    while (index != -1)
                    {
                        searchResults[searchResults.length] = new SearchResult(searchString, index, index + length - 1);
                        index = plainText.indexOf(searchString, index + length);
                    }
                }
                if (replaceString && textFlow.interactionManager is IEditManager)
                {
                    var editManager:IEditManager = textFlow.interactionManager as IEditManager;

                    editManager.beginCompositeOperation();
                    // Currently, specifying a replace string will just replace
                    // all of the instances of search string immediately.
                    var numResults:int = searchResults.length;
                    var searchResult:SearchResult = null;
                    var lengthDiff:int = 0;
                    var replaceStringLength:int = replaceString.length;
                    var oldStringLength:int = -1;
                    for (var i:int = 0; i < numResults; i++)
                    {
                        searchResult = searchResults[i];
                        oldStringLength = searchResult.absoluteEnd - searchResult.absoluteStart + 1;
                        searchResult.absoluteStart += lengthDiff;
                        searchResult.absoluteEnd += lengthDiff;
                        editManager.insertText(replaceString, new SelectionState(textFlow, searchResult.absoluteStart, searchResult.absoluteEnd + 1));
                        searchResult.absoluteEnd = searchResult.absoluteStart + replaceStringLength - 1;
                        lengthDiff += replaceStringLength - oldStringLength;
                    }
                    editManager.endCompositeOperation();
                }

            }
        }

        //------------------------------------------------------------------
        //
        //   P R I V A T E    M E T H O D S 
        //
        //------------------------------------------------------------------

        private function addResultHighlight(result:SearchResult):void
        {
            var flowComposer:IFlowComposer = textFlow.flowComposer;

            var resultAbsoluteStart:int = result.absoluteStart;
            var resultAbsoluteEnd:int = result.absoluteEnd;

            var absoluteStart:int = -1;
            var absoluteEnd:int = -1;

            var highlightSprites:Vector.<Sprite> = new Vector.<Sprite>();
            var containingTextFlowLines:Vector.<TextFlowLine> = new Vector.<TextFlowLine>();

            var textFlowLineIndex:int = flowComposer.findLineIndexAtPosition(resultAbsoluteStart);
            var textFlowLine:TextFlowLine = flowComposer.getLineAt(textFlowLineIndex);

            absoluteEnd = textFlowLine.absoluteStart + textFlowLine.textLength - 1;
            while (textFlowLine && resultAbsoluteEnd >= absoluteEnd)
            {
                containingTextFlowLines[containingTextFlowLines.length] = textFlowLine;
                textFlowLineIndex++;
                textFlowLine = flowComposer.getLineAt(textFlowLineIndex);
            }

            if (resultAbsoluteEnd > textFlowLine.absoluteStart)
                containingTextFlowLines[containingTextFlowLines.length] = textFlowLine;

            var numTextFlowLines:int = containingTextFlowLines.length;
            var textLine:TextLine = null;
            for (var i:int = 0; i < numTextFlowLines; i++)
            {
                textFlowLine = containingTextFlowLines[i];
                textLine = textFlowLine.getTextLine(true);
                if (textLine)
                {
                    var sprite:Sprite = textFlowLineSpriteMap[textFlowLine] as Sprite;
                    if (!sprite)
                    {
                        sprite = spritePool.length > 0 ? spritePool.pop() : new Sprite();
                        textFlowLineSpriteMap[textFlowLine] = sprite;
                        textLine.addChild(sprite);
                    }

                    absoluteStart = textFlowLine.absoluteStart;
                    absoluteEnd = absoluteStart + textFlowLine.textLength - 1;

                    var highlightStart:int = Math.max(resultAbsoluteStart, absoluteStart) - absoluteStart;
                    var highlightEnd:int = Math.min(resultAbsoluteEnd, absoluteEnd) - absoluteStart;

                    var startBounds:Rectangle = textLine.getAtomBounds(highlightStart);
                    var endBounds:Rectangle = textLine.getAtomBounds(highlightEnd);

                    var graphics:Graphics = sprite.graphics;
                    graphics.beginFill(highlightColor, highlightAlpha);
                    graphics.drawRect(startBounds.x, Math.max(startBounds.top, endBounds.top), (endBounds.right - startBounds.left), Math.max(startBounds.height, endBounds.height));
                    graphics.endFill();
                }
            }

        }

        private function construct():void
        {
            highlightColor = DEFAULT_HIGHLIGHT_COLOR;

            highlightAlpha = DEFAULT_HIGHLIGHT_ALPHA;

            searchHistory = new Vector.<String>();
            replaceHistory = new Vector.<String>();
            searchResults = new Vector.<SearchResult>();

            textFlowLineSpriteMap = new Dictionary(true);

            spritePool = new Vector.<Sprite>();
        }
    }
}