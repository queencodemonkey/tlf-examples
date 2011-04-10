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
package com.queencodemonkey.tlf.texteditor.components.search
{
    import com.queencodemonkey.tlf.textLayout.supportClasses.SearchResult;
    import com.queencodemonkey.tlf.texteditor.components.search.supportClasses.SearchResultsDisplayData;
    import com.queencodemonkey.tlf.texteditor.skins.search.SearchResultsDisplaySkin;
    
    import flashx.textLayout.compose.IFlowComposer;
    import flashx.textLayout.compose.TextFlowLine;
    import flashx.textLayout.elements.TextFlow;
    
    import mx.collections.ArrayList;
    import mx.collections.IList;
    import mx.core.ClassFactory;
    import mx.core.FlexGlobals;
    import mx.core.IFactory;
    import mx.styles.CSSStyleDeclaration;
    
    import spark.components.DataGroup;
    import spark.components.Label;
    import spark.components.List;
    import spark.components.RichText;
    import spark.components.supportClasses.SkinnableComponent;

    public class SearchResultsDisplay extends SkinnableComponent
    {

        private static const DEFAULT_CONTEXT_LENGTH_BEFORE_RESULT:int = 20;

        private static const DEFAULT_CONTEXT_LENGTH_AFTER_RESULT:int = 20;

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
            var searchResultsDisplayStyles:CSSStyleDeclaration = FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration("com.queencodemonkey.tlf.texteditor.components.search.SearchResultsDisplay");

            if (!searchResultsDisplayStyles)
            {
                searchResultsDisplayStyles = new CSSStyleDeclaration();
            }
            searchResultsDisplayStyles.defaultFactory = function():void
            {
                this.skinClass = SearchResultsDisplaySkin;
            };

            FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration("com.queencodemonkey.tlf.texteditor.components.search.SearchResultsDisplay", searchResultsDisplayStyles, true);

            return true;
        }

        //------------------------------------------------------------------
        //
        //   S K I N    P A R T S 
        //
        //------------------------------------------------------------------

//        [SkinPart(required="true")]
//        public var contextDataGroup:DataGroup;

        [SkinPart(required="true")]
        public var searchStringLabel:Label;

        [SkinPart(required="true")]
        public var resultList:List;

        //------------------------------------------------------------------
        //
        //  G E T T E R S / S E T T E R S 
        //
        //------------------------------------------------------------------

        public var contextLengthBeforeResult:int = DEFAULT_CONTEXT_LENGTH_BEFORE_RESULT;

        public var contextLengthAfterResult:int = DEFAULT_CONTEXT_LENGTH_AFTER_RESULT;

        public function get data():SearchResultsDisplayData
        {
            return _data;
        }

        /**
         * @private
         */
        public function set data(value:SearchResultsDisplayData):void
        {
            if (value != _data)
            {
                _data = value;
                dataDirty = true;
                invalidateProperties();
            }
        }

        //------------------------------------------------------------------
        //  G E T T E R / S E T T E R    P R O P E R T I E S 
        //------------------------------------------------------------------

        private var _data:SearchResultsDisplayData;

        //------------------------------------------------------------------
        //  D I R T Y    F L A G S 
        //------------------------------------------------------------------

        private var dataDirty:Boolean = false;

        //------------------------------------------------------------------
        //
        //  P U B L I C    M E T H O D S 
        //
        //------------------------------------------------------------------

        public function SearchResultsDisplay()
        {
            super();
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

            if (dataDirty)
            {
                if (data)
                {
					var results:Vector.<SearchResult> = data.results;
					var numResults:int = results.length;
                    searchStringLabel.text = "\"" + data.searchString + "\", " + numResults.toString() + " matches";

                    var dataProvider:IList = new ArrayList();
                    var textFlow:TextFlow = data.textFlow;
                    var flowComposer:IFlowComposer = textFlow.flowComposer;

                    var result:SearchResult = null;
                    var firstTextFlowLineIndex:int = -1;
                    var firstTextFlowLine:TextFlowLine = null;
                    for (var i:int = 0; i < numResults; i++)
                    {
                        result = results[i];
                        firstTextFlowLineIndex = flowComposer.findLineIndexAtPosition(result.absoluteStart);
                        firstTextFlowLine = flowComposer.getLineAt(firstTextFlowLineIndex);
                        dataProvider.addItem({startLineNumber: firstTextFlowLineIndex + 1,
                                                 context: textFlow.getText(firstTextFlowLine.absoluteStart,
                                                                           firstTextFlowLine.absoluteStart + firstTextFlowLine.textLength)});
                    }
                    resultList.dataProvider = dataProvider;
                }
                else
                {
                    searchStringLabel.text = "";
                    resultList.dataProvider = null;
                }
                dataDirty = false;
            }
        }

        /**
         * @inheritDoc
         */
        override protected function partAdded(partName:String, instance:Object):void
        {
            super.partAdded(partName, instance);

            if (instance == searchStringLabel)
            {

            }
            else if (instance == resultList)
            {
                resultList.itemRendererFunction = resultListRendererFunction;
            }
        }

        private function resultListRendererFunction(item:Object):IFactory
        {
			var classFactory:ClassFactory = new ClassFactory(SearchResultRenderer);
			classFactory.properties = {data: item, styleName: "searchResultLabel",
				width: width};
			return classFactory;
        }

        /**
         * @inheritDoc
         */
        override protected function partRemoved(partName:String, instance:Object):void
        {
            super.partRemoved(partName, instance);

            if (instance == searchStringLabel)
            {

            }
            else if (instance == resultList)
            {

            }
        }

        //------------------------------------------------------------------
        //
        //   P R I V A T E    M E T H O D S 
        //
        //------------------------------------------------------------------
    }
}